#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

python3 python/generate_synthetic_virtue_data.py
python3 python/virtue_panel_model.py
python3 python/virtue_network_analysis.py
python3 python/virtue_sensitivity_analysis.py

printf '\nArticle workflow complete. Outputs written to:\n  %s\n' "$(pwd)/outputs"
