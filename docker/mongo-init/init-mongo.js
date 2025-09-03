// Script d'initialisation MongoDB pour créer l'utilisateur admin
print('🚀 Initialisation de MongoDB en cours...');

// Attendre que la base admin soit disponible
db = db.getSiblingDB('admin');

// Vérifier si l'utilisateur existe déjà
var userExists = db.getUser('admin');

if (!userExists) {
  print('👤 Création de l\'utilisateur admin...');

  // Créer l'utilisateur root admin
  db.createUser({
    user: 'admin',
    pwd: 'password123',
    roles: [
      {
        role: 'root',
        db: 'admin'
      },
      {
        role: 'userAdminAnyDatabase',
        db: 'admin'
      },
      {
        role: 'dbAdminAnyDatabase',
        db: 'admin'
      },
      {
        role: 'readWriteAnyDatabase',
        db: 'admin'
      }
    ]
  });

  print('✅ Utilisateur admin créé avec succès');
} else {
  print('ℹ️  Utilisateur admin existe déjà');
}

// Créer la base de données dune_awakening
db = db.getSiblingDB('dune_awakening');

// Vérifier si l'utilisateur existe déjà dans dune_awakening
var userExistsDune = db.getUser('admin');

if (!userExistsDune) {
  print('👤 Création de l\'utilisateur admin pour dune_awakening...');

  // Créer un utilisateur spécifique pour la base de données dune_awakening
  db.createUser({
    user: 'admin',
    pwd: 'password123',
    roles: [
      {
        role: 'dbOwner',
        db: 'dune_awakening'
      },
      {
        role: 'readWrite',
        db: 'dune_awakening'
      }
    ]
  });

  print('✅ Utilisateur admin créé pour dune_awakening');
} else {
  print('ℹ️  Utilisateur admin existe déjà dans dune_awakening');
}

print('🎉 Initialisation de MongoDB terminée avec succès!');
