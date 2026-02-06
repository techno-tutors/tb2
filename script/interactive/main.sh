#!/usr/bin/env bash
set -euo pipefail

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
#shellcheck source=script/utils.sh
source "$base_dir/utils.sh"

log "Starting interactive setup..."
