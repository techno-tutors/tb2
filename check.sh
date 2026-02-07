#!/usr/bin/env bash
set -euo pipefail
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/script"
#shellcheck source=script/utils.sh
source "$base_dir/utils.sh"

for cmd in shfmt shellcheck; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "Error: $cmd not found. Install it first."
    exit 1
  fi
done

mapfile -t FILES < <(find . -name "*.sh")

if [ ${#FILES[@]} -eq 0 ]; then
  error "No .sh files found."
  exit 0
fi

info "Running shfmt..."
shfmt -i 2 -w "${FILES[@]}"
info "-----------------------------------------------"
info "Running shellcheck..."
shellcheck --external-sources "${FILES[@]}"

info "Checking strict mode (set -euo pipefail)..."
for f in "${FILES[@]}"; do
  if ! grep -Eq '^[^#]*set -euo pipefail' "$f"; then
    error "Strict mode missing in $f"
    exit 1
  fi
done

info "Checking shebang (#!/usr/bin/env bash)..."
for f in "${FILES[@]}"; do
  first_line=$(head -n1 "$f")
  if [ "$first_line" != "#!/usr/bin/env bash" ]; then
    error "Bad shebang in $f: $first_line"
    exit 1
  fi
done

info "All checks passed."
