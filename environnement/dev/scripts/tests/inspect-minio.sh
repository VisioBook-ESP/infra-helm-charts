#!/bin/bash

NAMESPACE="visiobook-namespace"
MINIO_CONTAINER="minio"
MINIO_PORT=9000
MINIO_INSTANCES=("minio-storage" "minio-analysis")

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

fmt_size() {
  python3 -c "
b = $1
for u in ['B','KB','MB','GB','TB']:
    if b < 1024: print(f'{b:.1f} {u}'); break
    b /= 1024
else: print(f'{b:.1f} PB')
" 2>/dev/null
}

# Fonction pour executer mc dans un pod
mc_exec() {
  local pod="$1"
  local cmd="$2"
  kubectl exec -n "$NAMESPACE" "$pod" -c "$MINIO_CONTAINER" -- \
    sh -c "mc alias set myminio http://localhost:${MINIO_PORT} \$MINIO_ROOT_USER \$MINIO_ROOT_PASSWORD >/dev/null 2>&1 && $cmd" 2>/dev/null
}

inspect_instance() {
  local INSTANCE="$1"
  local INSTANCE_TOTAL_FILES=0
  local INSTANCE_TOTAL_SIZE=0
  local INSTANCE_BUCKET_COUNT=0

  # Trouver le pod
  POD=$(kubectl get pods -n "$NAMESPACE" -l "app=${INSTANCE}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  if [ -z "$POD" ]; then
    echo -e "  ${RED}Aucun pod trouve pour '${INSTANCE}'${NC}"
    echo ""
    return
  fi
  echo -e "  ${DIM}Pod: $POD${NC}"
  echo ""

  # Info serveur
  section "Info serveur"
  SERVER_INFO=$(mc_exec "$POD" "mc admin info myminio --json" 2>/dev/null)
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
    echo -e "  ${DIM}(mc admin info non disponible)${NC}"
  fi
  echo ""

  # Liste des buckets
  section "Buckets et contenu"
  echo ""

  BUCKETS=$(mc_exec "$POD" "mc ls myminio --json" 2>/dev/null)
  if [ -z "$BUCKETS" ]; then
    echo -e "  ${YELLOW}Aucun bucket trouve.${NC}"
    echo ""
    return
  fi

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
    return
  fi

  while IFS= read -r BUCKET; do
    INSTANCE_BUCKET_COUNT=$((INSTANCE_BUCKET_COUNT + 1))

    # Taille du bucket
    BUCKET_DU=$(mc_exec "$POD" "mc du myminio/${BUCKET} --json" 2>/dev/null)
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
    BUCKET_SIZE_FMT=$(fmt_size "$BUCKET_SIZE")

    echo -e "  ${CYAN}${BOLD}[$BUCKET]${NC}  ${YELLOW}${BUCKET_SIZE_FMT}${NC}"

    # Lister les fichiers
    FILES=$(mc_exec "$POD" "mc ls --recursive myminio/${BUCKET} --json" 2>/dev/null)

    if [ -z "$FILES" ]; then
      echo -e "    ${DIM}(vide)${NC}"
    else
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
    max_name = max(len(f[0]) for f in files)
    max_name = min(max_name, 60)
    for name, size, mod in files:
        b = size
        for u in ['B','KB','MB','GB','TB']:
            if b < 1024: sz = f'{b:.1f} {u}'; break
            b /= 1024
        else: sz = f'{b:.1f} PB'
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
      INSTANCE_TOTAL_FILES=$((INSTANCE_TOTAL_FILES + FILE_COUNT_BUCKET))
    fi

    INSTANCE_TOTAL_SIZE=$((INSTANCE_TOTAL_SIZE + BUCKET_SIZE))
    echo ""
  done <<< "$BUCKET_NAMES"

  # Resume de l'instance
  INSTANCE_SIZE_FMT=$(fmt_size "$INSTANCE_TOTAL_SIZE")
  echo -e "  ${BOLD}Sous-total:${NC} ${INSTANCE_BUCKET_COUNT} bucket(s), ${INSTANCE_TOTAL_FILES} fichier(s), ${YELLOW}${INSTANCE_SIZE_FMT}${NC}"
  echo ""

  # Exporter pour le total global
  GLOBAL_BUCKETS=$((GLOBAL_BUCKETS + INSTANCE_BUCKET_COUNT))
  GLOBAL_FILES=$((GLOBAL_FILES + INSTANCE_TOTAL_FILES))
  GLOBAL_SIZE=$((GLOBAL_SIZE + INSTANCE_TOTAL_SIZE))
}

# =============================================
# Main
# =============================================
GLOBAL_BUCKETS=0
GLOBAL_FILES=0
GLOBAL_SIZE=0

for INSTANCE in "${MINIO_INSTANCES[@]}"; do
  header "MINIO: ${INSTANCE^^}"
  inspect_instance "$INSTANCE"
done

# =============================================
# Resume global
# =============================================
GLOBAL_SIZE_FMT=$(fmt_size "$GLOBAL_SIZE")

header "RESUME GLOBAL"
echo -e "  Instances    : ${BOLD}${#MINIO_INSTANCES[@]}${NC}"
echo -e "  Buckets      : ${BOLD}${GLOBAL_BUCKETS}${NC}"
echo -e "  Fichiers     : ${BOLD}${GLOBAL_FILES}${NC}"
echo -e "  Taille totale: ${YELLOW}${BOLD}${GLOBAL_SIZE_FMT}${NC}"
echo ""
