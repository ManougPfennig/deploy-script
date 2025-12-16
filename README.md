# Déploiement Remote via SSH et Git

Ce script Bash permet de déployer automatiquement un dépôt Git sur une machine distante via SSH en utilisant une clé privée et un token Git pour l'authentification. Le script est conçu pour être sécurisé, réutilisable et facilement configurable via un fichier `.env`.

## Fonctionnalités

- Connexion SSH avec clé privée
- Clonage d’un dépôt Git privé avec token Git
- Exécution d’une commande personnalisée (`ENTRYPOINT_CMD`) sur la machine distante
- Gestion des logs
- Vérification et gestion des erreurs
- Configuration centralisée dans un fichier `.env`
- Aucun secret stocké en clair dans le script

## Structure du projet
```
deploy-script/
│
├── deploy.sh # Script principal
├── .env # Variables de configuration et secrets
├── logs/ # Dossier créé automatiquement pour les logs
└── README.md # Ce fichier
```

## Prérequis

### Sur la machine locale

- Bash >= 4.x
- SSH (`ssh`)
- Git (`git`)

### Sur la machine distante

- Bash
- Git
- Commandes utilisées par `ENTRYPOINT_CMD`

### Fichier `.env` obligatoire

- Doit être situé dans le même dossier que le script
- Contient toutes les variables de configuration et secrets
- Ne jamais commiter ce fichier (`.gitignore` recommandé)
- Un exemple est fourni dans ce repos


## Utilisation

1. Assurez-vous que votre fichier `.env` est correctement configuré.  
2. Rendez le script exécutable :
*`chmod +x deploy.sh`*
3. Lancez le script :
*`./deploy.sh`*
4. Les logs sont créés automatiquement dans le dossier `logs/`.

## Bonnes pratiques

- Utiliser des tokens Git à durée de validité limitée pour la sécurité.
- Un token Git ne doit jamais être commité.
- Toujours tester sur une machine de staging avant la production.
- Les variables d’environnement sont isolées au processus du script et ne persistent pas après l’exécution.
- Pour des commandes complexes dans `ENTRYPOINT_CMD`, utiliser `bash -c "$ENTRYPOINT_CMD"`.

## Références utiles

- Documentation GitHub Tokens : https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- Guide SSH Key Authentication : https://www.ssh.com/ssh/key/
- Bash `set -o allexport` : https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
