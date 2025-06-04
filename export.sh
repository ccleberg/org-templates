#!/bin/bash

set -e

SRC_ROOT="${1:-$(pwd)/templates}"
DEST_ROOT="$(pwd)/.build"
CSS_SRC="$(pwd)/assets/styles.css"
CSS_DEST="$DEST_ROOT/assets/styles.css"

# Clean and recreate build directory
rm -rf "$DEST_ROOT"
mkdir -p "$DEST_ROOT/assets"
cp "$CSS_SRC" "$CSS_DEST"

# Export and relocate
find "$SRC_ROOT" -name "*.org" | while read -r org_file; do
    # Relative path from templates root
    rel_path="${org_file#$SRC_ROOT/}"
    rel_dir=$(dirname "$rel_path")
    base_name=$(basename "$org_file" .org)

    # Temporary output will go next to source
    echo "Exporting: $rel_path"

    emacs "$org_file" \
        --batch \
        --eval '(require '\''ox-html)' \
        --eval "(setq org-html-head \"<link rel=\\\"stylesheet\\\" type=\\\"text/css\\\" href=\\\"../assets/styles.css\\\" />\")" \
        --eval '(org-html-export-to-html)'

    # Move output file to .build
    mkdir -p "$DEST_ROOT/$rel_dir"
    mv "$(dirname "$org_file")/${base_name}.html" "$DEST_ROOT/$rel_dir/"
done

echo "Export complete. Output is in .build/"