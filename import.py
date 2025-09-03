import json
import gzip
import io
import os
from datetime import datetime
import shutil
import re
from html.parser import HTMLParser
import zlib
import requests

# Sélection de langue et URL dynamique
LANG = os.getenv("DUNE_LANG", "fr").strip() or "fr"
BASE_URL = "https://data.gtcdn.info/dune/1.1.25.0/data"
CDN_ROOT = "https://gtcdn.info/dune/1.1.25.0"
ASSET_VERSION = "1755896551038"
VERSION_QS = f"version={ASSET_VERSION}"
URL = f"{BASE_URL}/{LANG}/items.json.gz?{VERSION_QS}"
class ItemsHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.items = []
        self.stack = []
        self.current = None
        self.in_icon_container = 0
        self.in_name_span = 0
        self.in_inner_name = 0
        self.in_cat_span = 0
        self.in_tier_span = 0

    @staticmethod
    def _has_class(attrs, needle_substrings):
        cls = ''
        for k, v in attrs:
            if k == 'class' and v:
                cls = v
                break
        return all(sub in cls for sub in needle_substrings)

    @staticmethod
    def _get_attr(attrs, key):
        for k, v in attrs:
            if k == key:
                return v
        return None

    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            href = self._get_attr(attrs, 'href') or ''
            cls_ok = self._has_class(attrs, ['rounded', 'bg-slate-900'])
            if href and '/items/' in href and cls_ok:
                self.current = {
                    'url_fiche': href,
                    'nom': '',
                    'categorie': '',
                    'tier': None,
                    'image_url': '',
                }
        elif self.current is not None and tag == 'div':
            if self._has_class(attrs, ['icon-container']):
                self.in_icon_container += 1
        elif self.current is not None and tag == 'img' and self.in_icon_container > 0:
            src = self._get_attr(attrs, 'src') or ''
            if src and src.lower().endswith('.webp') and not self.current.get('image_url'):
                self.current['image_url'] = src
        elif self.current is not None and tag == 'span':
            # Name span wrapper
            if self._has_class(attrs, ['text-xl']) and self._has_class(attrs, ['font-bold']):
                self.in_name_span += 1
            # Inner name span
            elif self.in_name_span > 0:
                self.in_inner_name += 1
            # Category
            if self._has_class(attrs, ['text-sm']):
                self.in_cat_span += 1
            # Tier tag
            if self._has_class(attrs, ['tag']):
                self.in_tier_span += 1

    def handle_endtag(self, tag):
        if self.current is not None and tag == 'div' and self.in_icon_container > 0:
            self.in_icon_container -= 1
        elif self.current is not None and tag == 'span':
            if self.in_inner_name > 0:
                self.in_inner_name -= 1
            elif self.in_name_span > 0:
                self.in_name_span -= 1
            if self.in_cat_span > 0:
                self.in_cat_span -= 1
            if self.in_tier_span > 0:
                self.in_tier_span -= 1
        elif tag == 'a' and self.current is not None:
            # finalize current
            if self.current.get('nom') and self.current.get('image_url'):
                self.items.append(self.current)
            self.current = None

    def handle_data(self, data):
        if self.current is None:
            return
        txt = (data or '').strip()
        if not txt:
            return
        if self.in_inner_name > 0 and not self.current.get('nom'):
            self.current['nom'] = txt
        elif self.in_cat_span > 0 and not self.current.get('categorie'):
            self.current['categorie'] = txt
        elif self.in_tier_span > 0 and self.current.get('tier') is None:
            m = re.search(r'(\d+)', txt)
            if m:
                try:
                    self.current['tier'] = int(m.group(1))
                except Exception:
                    pass


def parse_items_from_html(html_path: str):
    if not os.path.exists(html_path):
        return []
    html = open(html_path, 'r', encoding='utf-8', errors='ignore').read()

    # Préparer une table CDN: basename.webp -> /images/.../basename.webp (depuis items.json si dispo)
    cdn_by_basename: dict[str, str] = {}
    try:
        pool = load_pool()
        if isinstance(pool, list):
            for s in pool:
                if isinstance(s, str) and s.startswith('/images/') and s.endswith('.webp'):
                    base = os.path.splitext(os.path.basename(s))[0].lower()
                    cdn_by_basename[base] = s
    except Exception:
        pass

    def normalize_copy(src: str) -> str | None:
        if not src:
            return None
        # Laisser tomber les absolus HTTP pour l'instant
        if src.startswith('http://') or src.startswith('https://'):
            return None
        html_dir = os.path.dirname(os.path.abspath(html_path))
        src_rel = src[2:] if src.startswith('./') else src
        src_abs = os.path.normpath(os.path.join(html_dir, src_rel))
        if not os.path.exists(src_abs):
            return None
        # Préserver la sous-arborescence après le répertoire *_files s'il existe
        # ex: "Dune Awakening Items_files/path/to/img.webp" → "html_assets/path/to/img.webp"
        parts = src_rel.replace('\\', '/').split('/')
        sub_rel = None
        if len(parts) >= 2 and parts[0].endswith('_files'):
            sub_rel = '/'.join(parts[1:])
        else:
            # sinon conserver le chemin relatif tel quel
            sub_rel = '/'.join(parts)
        dest_rel = os.path.join('images', 'html_assets', *sub_rel.split('/'))
        dest_abs = os.path.normpath(os.path.join(os.getcwd(), dest_rel))
        os.makedirs(os.path.dirname(dest_abs), exist_ok=True)
        try:
            if not os.path.exists(dest_abs) or os.path.getsize(dest_abs) != os.path.getsize(src_abs):
                shutil.copyfile(src_abs, dest_abs)
            return dest_rel.replace('\\', '/')
        except Exception:
            return None

    def ensure_from_cdn(basename: str) -> str | None:
        key = os.path.splitext(basename)[0].lower()
        cdn_rel = cdn_by_basename.get(key)
        if not cdn_rel:
            return None
        url = f"{CDN_ROOT}{cdn_rel}?v={ASSET_VERSION}"
        # Sauvegarder sous images/html_assets/<basename>
        dest_rel = os.path.join('images', 'html_assets', os.path.basename(cdn_rel))
        dest_abs = os.path.normpath(os.path.join(os.getcwd(), dest_rel))
        os.makedirs(os.path.dirname(dest_abs), exist_ok=True)
        if os.path.exists(dest_abs):
            return dest_rel.replace('\\', '/')
        try:
            with requests.get(url, stream=True, timeout=60) as resp:
                resp.raise_for_status()
                with open(dest_abs, 'wb') as f:
                    for chunk in resp.iter_content(8192):
                        if chunk:
                            f.write(chunk)
            return dest_rel.replace('\\', '/')
        except Exception:
            return None

    parser = ItemsHTMLParser()
    parser.feed(html)
    # post-process: remap image_url local to CDN when possible
    out = []
    for it in parser.items:
        img = it.get('image_url') or ''
        copied_rel = None
        if img and not (img.startswith('http://') or img.startswith('https://')):
            base_name = os.path.basename(img)
            key = os.path.splitext(base_name)[0].lower()
            cdn_rel = None
            try:
                pool = load_pool()
                if isinstance(pool, list):
                    for s in pool:
                        if isinstance(s, str) and s.startswith('/images/') and s.endswith('.webp'):
                            if os.path.splitext(os.path.basename(s))[0].lower() == key:
                                cdn_rel = s
                                break
            except Exception:
                pass
            if cdn_rel:
                it['image_url'] = f"{CDN_ROOT}{cdn_rel}?v={ASSET_VERSION}"
            copied_rel = normalize_copy(img)
        it['image_local'] = copied_rel or ''
        out.append({
            'id': None,
            'nom': it.get('nom',''),
            'categorie': it.get('categorie',''),
            'sous_categorie': '',
            'tier': it.get('tier'),
            'unique': False,
            'description': '',
            'statistiques': [],
            'schema': [],
            'sources': [],
            'image': '',
            'image_url': it.get('image_url',''),
            'image_local': it.get('image_local',''),
            'tier_icon_url': '',
            'tier_icon_local': '',
            'url_fiche': it.get('url_fiche','')
        })
    return out


def _load_local_pool(path: str):
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _fetch_pool(url: str):
    resp = requests.get(url, timeout=60)
    resp.raise_for_status()
    raw = resp.content
    try:
        text = gzip.decompress(raw).decode("utf-8")
    except OSError:
        # Déjà du JSON brut
        text = raw.decode("utf-8")
    return json.loads(text)


def load_pool():
    # N'utilise le cache local que si explicitement demandé
    use_local = os.getenv("USE_LOCAL", "0") == "1"
    local_path = f"items_{LANG}.json"
    if use_local:
        pool = _load_local_pool(local_path)
        if pool is not None:
            return pool
    pool = _fetch_pool(URL)
    try:
        with open(local_path, "w", encoding="utf-8") as f:
            json.dump(pool, f)
    except Exception:
        pass
    return pool


def build_resolver(pool):
    cache = {}

    def deref_once(value):
        if isinstance(value, int) and 0 <= value < len(pool):
            return pool[value]
        return value

    def deref_chain(value, max_steps: int = 8):
        seen = set()
        current = value
        steps = 0
        while isinstance(current, int) and 0 <= current < len(pool) and steps < max_steps:
            if current in seen:
                break
            seen.add(current)
            nxt = pool[current]
            if nxt is current:
                break
            current = nxt
            steps += 1
        return current

    def to_text(value):
        # Suit les indices jusqu'à obtenir une chaîne, ou un dict avec champ 'name'
        v = deref_chain(value)
        if isinstance(v, str):
            # Écarter les chemins d'images et tokens évidents non textuels
            if v.startswith("/images/") or "/textures/icons/" in v:
                return None
            return v
        if isinstance(v, dict):
            name_val = v.get("name")
            if name_val is not None:
                nv = deref_chain(name_val)
                if isinstance(nv, str):
                    if nv.startswith("/images/") or "/textures/icons/" in nv:
                        return None
                    return nv
        return None

    def to_value(value):
        # Déréférence en chaîne mais sans expansion récursive de dict/list
        v = deref_chain(value)
        return v

    return to_text, to_value


def _take_text(to_text, value):
    return to_text(value)


def extract_items(pool):
    to_text, to_value = build_resolver(pool)
    items_out = []
    def is_valid_text(s: str) -> bool:
        if not isinstance(s, str):
            return False
        if s.startswith("/images/") or "/textures/icons/" in s:
            return False
        # doit contenir au moins une lettre (y compris accentuée)
        return any(ch.isalpha() for ch in s)

    # Index des chemins d'images du pool pour retrouver un chemin complet à partir d'un token
    image_paths = [s for s in pool if isinstance(s, str) and s.startswith("/images/")]
    base_to_path = {}
    for p in image_paths:
        base = os.path.splitext(os.path.basename(p))[0].lower()
        base_to_path.setdefault(base, p)
    images_found_pool = len(image_paths)
    images_downloaded_ok = 0
    images_downloaded_ko = 0
    items_with_icon = 0
    items_with_tier_icon = 0

    def deep_find_image_path(node, max_depth: int = 10, visited_idx: set | None = None, depth: int = 0):
        if node is None or depth > max_depth:
            return None
        # Chaîne directe
        if isinstance(node, str) and node.startswith("/images/"):
            return node
        # Index dans le pool
        if isinstance(node, int) and 0 <= node < len(pool):
            if visited_idx is None:
                visited_idx = set()
            if node in visited_idx:
                return None
            visited_idx.add(node)
            return deep_find_image_path(pool[node], max_depth, visited_idx, depth + 1)
        # Dictionnaire: explorer valeurs
        if isinstance(node, dict):
            for v in node.values():
                found = deep_find_image_path(v, max_depth, visited_idx, depth + 1)
                if found:
                    return found
            return None
        # Liste/tuple: explorer éléments
        if isinstance(node, (list, tuple)):
            for v in node:
                found = deep_find_image_path(v, max_depth, visited_idx, depth + 1)
                if found:
                    return found
            return None
        # Autres types
        return None

    def resolve_icon_path(ref):
        if ref is None:
            return None
        # 1) Recherche profonde autour du nœud
        found = deep_find_image_path(ref)
        if isinstance(found, str):
            return found
        # 2) Heuristique avec token de base
        s = to_text(ref) or to_value(ref)
        if isinstance(s, str):
            key = os.path.splitext(os.path.basename(s))[0].lower()
            if key in base_to_path:
                return base_to_path[key]
            matches = [p for p in image_paths if key and key in p.lower()]
            if len(matches) == 1:
                return matches[0]
        return None

    def build_image_urls(path_str: str):
        if not path_str:
            return None, None
        url = f"{CDN_ROOT}{path_str}?v={ASSET_VERSION}"
        # Répertoire local miroir de l'arborescence CDN sous dossier racine 'images' (sans doubler)
        sub_path = path_str.lstrip("/")
        if sub_path.startswith("images/"):
            sub_path = sub_path[len("images/"):]
        local_path = os.path.join("images", sub_path)
        return url, local_path

    def ensure_download(url: str, local_path: str):
        if not url or not local_path:
            return False
        # Création des dossiers
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        if os.path.exists(local_path) and os.getenv("REDOWNLOAD_IMAGES", "0") != "1":
            return True
        try:
            with requests.get(url, stream=True, timeout=60) as resp:
                resp.raise_for_status()
                with open(local_path, "wb") as out:
                    for chunk in resp.iter_content(chunk_size=8192):
                        if chunk:
                            out.write(chunk)
            return True
        except Exception:
            return False

    def to_bool(value):
        v = to_value(value)
        if isinstance(v, bool):
            return v
        if isinstance(v, (int, float)):
            return v != 0
        return bool(v)

    def to_number(value):
        # Tente d'obtenir un nombre sans expansion profonde
        if isinstance(value, (int, float)):
            return value
        if isinstance(value, int) and 0 <= value < len(pool):
            v2 = pool[value]
            if isinstance(v2, (int, float)):
                return v2
        # Évite d'interpréter arbitrairement d'autres structures
        return None

    def humanize_attribute_values(ref):
        # Résout une liste d'objets { key, attribute, value }
        root = to_value(ref)
        # Si ref pointe vers une liste d'indices, déréf une fois
        if isinstance(root, int) and 0 <= root < len(pool):
            root = pool[root]
        if not isinstance(root, list):
            return []
        output = []
        for elem in root:
            e = elem
            if isinstance(e, int) and 0 <= e < len(pool):
                e = pool[e]
            if not isinstance(e, dict):
                continue
            attr_desc = to_value(e.get("attribute"))
            # Déréf léger de l'attribut
            if isinstance(attr_desc, int) and 0 <= attr_desc < len(pool):
                attr_desc = pool[attr_desc]
            attr_name = None
            percent_based = None
            higher_is_better = None
            if isinstance(attr_desc, dict):
                attr_name = to_text(attr_desc.get("name")) or to_text(attr_desc)
                percent_based = to_bool(attr_desc.get("percentBased")) if "percentBased" in attr_desc else None
                higher_is_better = to_bool(attr_desc.get("higherIsBetter")) if "higherIsBetter" in attr_desc else None
            else:
                attr_name = to_text(attr_desc)

            val_num = to_number(e.get("value"))

            output.append({
                "attribut": attr_name or "",
                "valeur": val_num if val_num is not None else e.get("value"),
                "est_pourcentage": percent_based,
                "mieux_plus_haut": higher_is_better
            })
        # Filtrer attributs sans nom
        return [o for o in output if o.get("attribut")]

    # Pas d'index global id->libellé (trop de collisions inter-tables)

    def looks_like_item(entry_dict: dict) -> bool:
        # Exclure les objets "stat" simples
        if all(k in entry_dict for k in ("key", "attribute", "value")) and len(entry_dict) <= 5:
            return False
        if "id" not in entry_dict or "name" not in entry_dict:
            return False
        # Au moins un des champs typiques d'item
        typical_keys = {"mainCategoryId", "subCategoryId", "iconPath", "tier", "highestSellToVendorPrice", "volume", "filterCategoryIds"}
        if not any(k in entry_dict for k in typical_keys):
            return False
        return True

    for entry in pool:
        if not isinstance(entry, dict):
            continue
        if not looks_like_item(entry):
            continue

        # ID numérique prioritaire
        raw_id = entry.get("id")
        id_out = None
        if isinstance(raw_id, int):
            id_out = raw_id
        else:
            id_raw = to_value(raw_id)
            if isinstance(id_raw, dict) and "id" in id_raw and isinstance(id_raw["id"], (int, float)):
                id_out = int(id_raw["id"])  # normaliser en int
            elif isinstance(id_raw, int):
                id_out = id_raw
        if not isinstance(id_out, int):
            continue

        nom = _take_text(to_text, entry.get("name"))
        if not is_valid_text(nom):
            continue
        # Exclure noms manifestement non items
        bad_tokens = ("BP_", "InfoCard_", "ItemStats_", "seconds", "RPM")
        if any(tok in nom for tok in bad_tokens):
            continue

        # Catégories: tenter divers chemins textuels
        # Catégories lisibles si possible
        main_cat_val = to_value(entry.get("mainCategoryId"))
        sub_cat_val = to_value(entry.get("subCategoryId"))
        categorie = _take_text(to_text, entry.get("mainCategoryId"))
        if not is_valid_text(categorie):
            categorie = None
        sous_categorie = _take_text(to_text, entry.get("subCategoryId"))
        if not is_valid_text(sous_categorie):
            sous_categorie = None

        tier = to_value(entry.get("tier")) if "tier" in entry else None
        unique_raw = to_value(entry.get("isUnique")) if "isUnique" in entry else False
        unique = unique_raw if isinstance(unique_raw, bool) else bool(unique_raw)
        description = _take_text(to_text, entry.get("description"))
        statistiques = humanize_attribute_values(entry.get("attributeValues")) if "attributeValues" in entry else []
        # Recettes et sources: laisser la structure brute si non textuelle,
        # mais tenter une extraction de libellés quand possible
        def humanize_list_entries(ref_list):
            v = to_value(ref_list)
            if isinstance(v, int) and 0 <= v < len(pool):
                v = pool[v]
            if not isinstance(v, list):
                return v
            out = []
            for x in v:
                label = to_text(x)
                out.append(label if isinstance(label, str) and label else to_value(x))
            return out

        schema = humanize_list_entries(entry.get("recipe")) if "recipe" in entry else []
        sources = humanize_list_entries(entry.get("sources")) if "sources" in entry else []
        # Icône d'item
        icon_path = resolve_icon_path(entry.get("iconPath")) or resolve_icon_path(entry.get("icon"))
        image_url, image_local = build_image_urls(icon_path)
        if image_url and image_local:
            if ensure_download(image_url, image_local):
                images_downloaded_ok += 1
            else:
                images_downloaded_ko += 1
            items_with_icon += 1
        # Icône de tier (palier)
        tier_icon_path = resolve_icon_path(entry.get("tierIconPath"))
        tier_icon_url, tier_icon_local = build_image_urls(tier_icon_path)
        if tier_icon_url and tier_icon_local:
            if ensure_download(tier_icon_url, tier_icon_local):
                images_downloaded_ok += 1
            else:
                images_downloaded_ko += 1
            items_with_tier_icon += 1
        image = _take_text(to_text, entry.get("iconPath")) or _take_text(to_text, entry.get("icon"))
        url_fiche = _take_text(to_text, entry.get("url"))

        items_out.append({
            "id": id_out,
            "nom": nom,
            "categorie": categorie or "",
            "sous_categorie": sous_categorie or "",
            "tier": tier,
            "unique": unique,
            "description": description or "",
            "statistiques": statistiques,
            "schema": schema if isinstance(schema, list) else (schema or []),
            "sources": sources if isinstance(sources, list) else (sources or []),
            "image": image or "",
            "image_url": image_url or tier_icon_url or "",
            "image_local": image_local or tier_icon_local or "",
            "tier_icon_url": tier_icon_url or "",
            "tier_icon_local": tier_icon_local or "",
            "url_fiche": url_fiche or ""
        })

    # Option: télécharger toutes les images présentes dans le pool (au-delà des items extraits)
    if os.getenv("DOWNLOAD_ALL_IMAGES", "0") == "1":
        seen = set()
        for p in image_paths:
            if p in seen:
                continue
            seen.add(p)
            url, local = build_image_urls(p)
            if url and local:
                if ensure_download(url, local):
                    images_downloaded_ok += 1
                else:
                    images_downloaded_ko += 1

    print(f"[images] pool={images_found_pool} items_with_icon={items_with_icon} items_with_tier_icon={items_with_tier_icon} dl_ok={images_downloaded_ok} dl_ko={images_downloaded_ko}")

    return items_out


def main():
    use_html = os.getenv("USE_HTML", "0") == "1"
    html_path = os.getenv("HTML_PATH", "Dune Awakening Items.html")
    items = []

    if use_html or os.path.exists(html_path):
        items = parse_items_from_html(html_path)
    else:
        pool = load_pool()
        if not isinstance(pool, list):
            raise RuntimeError("Le JSON racine attendu est une liste (pool)")
        items = extract_items(pool)

    meta = {
        "derniere_mise_a_jour": datetime.utcnow().strftime("%Y-%m-%d"),
        "nb_items": len(items)
    }

with open("dune_awakening_items_fr.json", "w", encoding="utf-8") as f:
        json.dump({"meta": meta, "items": items}, f, ensure_ascii=False, indent=2)

    print(f"{len(items)} items exportés dans 'dune_awakening_items_fr.json'")


if __name__ == "__main__":
    main()
