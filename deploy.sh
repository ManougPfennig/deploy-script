#!/usr/bin/env bash

###############################################################################
#                                PRÉREQUIS                                    #
###############################################################################
#
# FICHIERS REQUIS :
#   - deploy.sh   (ce script)
#   - .env        (configuration et secrets)
#
# CONTENU DU .env (obligatoire) :
#   SSH_HOST
#   SSH_PORT
#   SSH_USER
#   SSH_KEY
#   GIT_REPO_URL
#   GIT_USERNAME
#   GIT_TOKEN
#   GIT_CLONE_DIR
#   ENTRYPOINT_CMD
#
# PRÉREQUIS LOCAUX :
#   - bash (>= 4.x)
#   - ssh
#   - git
#
# PRÉREQUIS DISTANTS :
#   - bash
#   - git
#   - make (si utilisé par ENTRYPOINT_CMD)
#
###############################################################################


###############################################################################
#                        CHARGEMENT DU .env                                   #
###############################################################################

set -o errexit
set -o nounset
set -o pipefail

ENV_FILE="$(dirname "$0")/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Fichier .env introuvable : $ENV_FILE"
  exit 1
fi

# Chargement contrôlé des variables
set -o allexport
source "$ENV_FILE"
set +o allexport

###############################################################################
#                            FONCTIONS                                        #
###############################################################################

LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

fail() {
  log "ERREUR : $1"
  exit 1
}

###############################################################################
#                            VALIDATIONS                                      #
###############################################################################

required_vars=(
  SSH_HOST
  SSH_PORT
  SSH_USER
  SSH_KEY
  GIT_REPO_URL
  GIT_USERNAME
  GIT_TOKEN
  GIT_CLONE_DIR
  ENTRYPOINT_CMD
)

for var in "${required_vars[@]}"; do
  [[ -z "${!var:-}" ]] && fail "Variable manquante dans .env : $var"
done

[[ ! -f "$SSH_KEY" ]] && fail "Clé SSH introuvable : $SSH_KEY"

###############################################################################
#                            EXECUTION                                        #
###############################################################################

log "[Déploiement vers ${SSH_USER}@${SSH_HOST}:${SSH_PORT}]"
log "[Clé SSH utilisée : ${SSH_KEY}]"
log "[Dépôt Git : ${GIT_REPO_URL}]"
log "[Dossier cible : ${GIT_CLONE_DIR}]"

ssh -i "$SSH_KEY" \
    -p "$SSH_PORT" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    "${SSH_USER}@${SSH_HOST}" << EOF | tee -a "$LOG_FILE"

set -euo pipefail

echo "[Préparation du dossier distant]"

if [ -d "$GIT_CLONE_DIR" ]; then
  echo "[Suppression de l'ancien dépôt]"
  rm -rf "$GIT_CLONE_DIR"
fi

echo "[Clonage du dépôt Git]"
git clone https://${GIT_USERNAME}:${GIT_TOKEN}@${GIT_REPO_URL} "$GIT_CLONE_DIR"

cd "$GIT_CLONE_DIR"

echo "[Lancement de l'entrypoint]"
$ENTRYPOINT_CMD

echo "[Déploiement terminé avec succès]"

EOF

log "[Script terminé sans erreur]"
