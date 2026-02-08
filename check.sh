#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/share/tb2"
export ROOT

if [ ! -f "$ROOT/utils.sh" ]; then
  echo "Error: utils.sh not found at $ROOT/utils.sh" >&2
  exit 1
fi

# shellcheck source=script/utils.sh
# shellcheck disable=SC1091
. "$ROOT/utils.sh"

for cmd in shfmt shellcheck bash bashate checkbashisms; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    warn "Error: $cmd not found. Install it first."
    exit 1
  fi
done

while IFS= read -r -d '' file; do
    FILES+=("$file")
done < <(find "$ROOT" -type f -name '*.sh' -print0)

if [ ${#FILES[@]} -eq 0 ]; then
  info "No .sh files found."
  exit 0
fi

info "Running shfmt..."
shfmt -i 2 -ci -sr -w "${FILES[@]}"
info "-----------------------------------------------"
info "Running bash -n..."
for f in "${FILES[@]}"; do
  if ! bash -n "$f"; then
    error "Syntax error in $f"
    exit 1
  fi
done

info "-----------------------------------------------"
info "Running shellcheck..."

set +e
shellcheck --external-sources "$ROOT/utils.sh" "${FILES[@]}"
sc_status=$?
set -e

if [ $sc_status -eq 2 ]; then
  error "shellcheck: fatal parsing error"
  exit 1
elif [ $sc_status -eq 1 ]; then
  warn "shellcheck: warnings found"
fi

info "-----------------------------------------------"
info "Running bashate..."
bashate -i E003,E006 --max-line-length 1000 "${FILES[@]}"

info "-----------------------------------------------"
info "Running checkbashisms..."
set +e
for f in "${FILES[@]}"; do
  checkbashisms --force "$f"
done
set -e

info "-----------------------------------------------"
info "Checking strict mode (set -euo pipefail)..."
for f in "${FILES[@]}"; do
  if ! grep -Eq '^[[:space:]]*set -euo pipefail' "$f"; then
    error "Strict mode missing in $f"
    exit 1
  fi
done

info "-----------------------------------------------"
info "Checking shebang (#!/usr/bin/env bash)..."
for f in "${FILES[@]}"; do
  read -r first_line < "$f"
  if [ "$first_line" != "#!/usr/bin/env bash" ]; then
    error "Bad shebang in $f: $first_line"
    exit 1
  fi
done

info "-----------------------------------------------"
info "Running bats tests (if tests exist)..."
if ls test/*.bats 1> /dev/null 2>&1; then
  bats test
else
  info "No bats tests found."
fi

info "All checks passed."
