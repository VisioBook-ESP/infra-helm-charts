#!/bin/bash

NAMESPACE="visiobook-namespace"
MINIO_CONTAINER="minio"
MINIO_PORT=9000

# Couleurs
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

header() {
  echo ""
  echo -e "${GREEN}${BOLD}========================================${NC}"
  echo -e "${GREEN}${BOLD}  $1${NC}"
  echo -e "${GREEN}${BOLD}========================================${NC}"
  echo ""
}

section() {
  echo -e "${CYAN}${BOLD}--- $1 ---${NC}"
}

error() {
  echo -e "${RED}[ERREUR] $1${NC}"
  exit 1
}

# Trouver le pod MinIO
POD=$(kubectl get pods -n "$NAMESPACE" -l app=minio -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD" ]; then
  error "Aucun pod MinIO trouve dans le namespace '$NAMESPACE'"
fi

echo -e "${DIM}Pod MinIO: $POD${NC}"

# Fonction pour executer mc dans le pod
mc_exec() {
  kubectl exec -n "$NAMESPACE" "$POD" -c "$MINIO_CONTAINER" -- \
    sh -c "mc alias set myminio http://localhost:${MINIO_PORT} \$MINIO_ROOT_USER \$MINIO_ROOT_PASSWORD >/dev/null 2>&1 && $1" 2>/dev/null
}

# =============================================
# Info serveur
# =============================================
header "INSPECTION MINIO"

section "Info serveur"
SERVER_INFO=$(mc_exec "mc admin info myminio --json" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$SERVER_INFO" ]; then
  echo "$SERVER_INFO" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    info = data.get('info', data)
    disks = info.get('usage', info.get('disks', {}))
    used = disks.get('used', 0)
    total = disks.get('total_space', disks.get('available', 0))
    def fmt(b):
        for u in ['B','KB','MB','GB','TB']:
            if b < 1024: return f'{b:.1f} {u}'
            b /= 1024
        return f'{b:.1f} PB'
    print(f'  Espace utilise : {fmt(used)}')
    if total > 0:
        print(f'  Espace total   : {fmt(total)}')
        pct = (used/total)*100 if total else 0
        print(f'  Utilisation    : {pct:.1f}%')
except:
    print('  (info detaillee non disponible)')
" 2>/dev/null || echo -e "  ${DIM}(info serveur non disponible)${NC}"
else
  echo -e "  ${DIM}(mc admin info non disponible, affichage des buckets uniquement)${NC}"
fi
echo ""

# =============================================
# Liste des buckets et contenu
# =============================================
section "Buckets et contenu"
echo ""

BUCKETS=$(mc_exec "mc ls myminio --json" 2>/dev/null)
if [ -z "$BUCKETS" ]; then
  echo -e "  ${YELLOW}Aucun bucket trouve.${NC}"
  echo ""
  exit 0
fi

TOTAL_FILES=0
TOTAL_SIZE=0
BUCKET_COUNT=0

BUCKET_NAMES=$(echo "$BUCKETS" | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        obj = json.loads(line)
        key = obj.get('key', '')
        if key.endswith('/'):
            print(key.rstrip('/'))
    except: pass
" 2>/dev/null)

if [ -z "$BUCKET_NAMES" ]; then
  echo -e "  ${YELLOW}Aucun bucket trouve.${NC}"
  echo ""
  exit 0
fi

while IFS= read -r BUCKET; do
  BUCKET_COUNT=$((BUCKET_COUNT + 1))

  # Taille du bucket
  BUCKET_DU=$(mc_exec "mc du myminio/${BUCKET} --json" 2>/dev/null)
  BUCKET_SIZE=$(echo "$BUCKET_DU" | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        d = json.loads(line.strip())
        print(d.get('size', 0))
        break
    except: pass
" 2>/dev/null)
  BUCKET_SIZE=${BUCKET_SIZE:-0}

  BUCKET_SIZE_FMT=$(python3 -c "
b = $BUCKET_SIZE
for u in ['B','KB','MB','GB','TB']:
    if b < 1024: print(f'{b:.1f} {u}'); break
    b /= 1024
else: print(f'{b:.1f} PB')
" 2>/dev/null)

  echo -e "  ${CYAN}${BOLD}[$BUCKET]${NC}  ${YELLOW}${BUCKET_SIZE_FMT}${NC}"

  # Lister les fichiers
  FILES=$(mc_exec "mc ls --recursive myminio/${BUCKET} --json" 2>/dev/null)

  if [ -z "$FILES" ]; then
    echo -e "    ${DIM}(vide)${NC}"
  else
    FILE_COUNT=0
    echo "$FILES" | python3 -c "
import sys, json

files = []
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        obj = json.loads(line)
        key = obj.get('key', '')
        size = obj.get('size', 0)
        last_mod = obj.get('lastModified', '')
        if key and not key.endswith('/'):
            files.append((key, size, last_mod))
    except: pass

if not files:
    print('    (vide)')
else:
    # Trouver la largeur max pour aligner
    max_name = max(len(f[0]) for f in files)
    max_name = min(max_name, 60)
    for name, size, mod in files:
        # Formater la taille
        b = size
        for u in ['B','KB','MB','GB','TB']:
            if b < 1024: sz = f'{b:.1f} {u}'; break
            b /= 1024
        else: sz = f'{b:.1f} PB'
        # Formater la date
        date_str = mod[:10] if len(mod) >= 10 else mod
        display_name = name if len(name) <= 60 else '...' + name[-57:]
        print(f'    {display_name:<{max_name}}  {sz:>10}  {date_str}')
    print(f'    -- {len(files)} fichier(s)')
" 2>/dev/null

    FILE_COUNT_BUCKET=$(echo "$FILES" | python3 -c "
import sys, json
count = 0
for line in sys.stdin:
    try:
        obj = json.loads(line.strip())
        if obj.get('key','') and not obj['key'].endswith('/'):
            count += 1
    except: pass
print(count)
" 2>/dev/null)
    FILE_COUNT_BUCKET=${FILE_COUNT_BUCKET:-0}
    TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT_BUCKET))
  fi

  TOTAL_SIZE=$((TOTAL_SIZE + BUCKET_SIZE))
  echo ""

done <<< "$BUCKET_NAMES"

# =============================================
# Resume
# =============================================
TOTAL_SIZE_FMT=$(python3 -c "
b = $TOTAL_SIZE
for u in ['B','KB','MB','GB','TB']:
    if b < 1024: print(f'{b:.1f} {u}'); break
    b /= 1024
else: print(f'{b:.1f} PB')
" 2>/dev/null)

header "RESUME"
echo -e "  Buckets      : ${BOLD}${BUCKET_COUNT}${NC}"
echo -e "  Fichiers     : ${BOLD}${TOTAL_FILES}${NC}"
echo -e "  Taille totale: ${YELLOW}${BOLD}${TOTAL_SIZE_FMT}${NC}"
echo ""
