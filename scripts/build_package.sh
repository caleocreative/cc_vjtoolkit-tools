#!/bin/bash
# VJToolkit build_package.sh script
# Used by Nicolas to package tool folders into verified .vjtool ZIP archives.

set -e

if [ -z "$1" ]; then
    echo "Error: Please specify the tool package directory name."
    echo "Usage: ./build_package.sh <tool_directory_name>"
    echo "Example: ./build_package.sh extractor"
    exit 1
fi

TOOL_NAME="$1"
VJTOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_SRC_DIR="$VJTOOLKIT_DIR/src/tools/$TOOL_NAME"

# Check if target tool directory exists
if [ ! -d "$TOOL_SRC_DIR" ]; then
    echo "Error: Tool directory not found at $TOOL_SRC_DIR"
    exit 1
fi

# Check if __init__.py exists inside the directory
if [ ! -f "$TOOL_SRC_DIR/__init__.py" ]; then
    echo "Error: Missing __init__.py in tool directory: $TOOL_SRC_DIR"
    exit 1
fi

# Determine version from metadata or default
# Read version from __init__.py dynamically using Python's importlib
VERSION=$(python3 -c "
import sys
import importlib
import inspect
sys.path.append('$VJTOOLKIT_DIR')
try:
    mod = importlib.import_module('src.tools.$TOOL_NAME')
    from src.tools.tool_base import ToolBase
    found = False
    for name, obj in inspect.getmembers(mod):
        if inspect.isclass(obj) and issubclass(obj, ToolBase) and obj is not ToolBase:
            print(obj.get_metadata().get('version', '1.0.0'))
            found = True
            break
    if not found:
        print('1.0.0')
except Exception as e:
    print('1.0.0')
" 2>/dev/null || echo "1.0.0")

# Setup distribution directory
DIST_DIR="$VJTOOLKIT_DIR/dist"
mkdir -p "$DIST_DIR"

OUTPUT_FILE="$DIST_DIR/$TOOL_NAME-$VERSION.vjtool"
TEMP_ZIP="$DIST_DIR/$TOOL_NAME_temp.zip"

echo "Packaging tool '$TOOL_NAME' version $VERSION..."

# Zip the tool package folder from its parent directory to keep the root folder in the archive
cd "$VJTOOLKIT_DIR/src/tools"
zip -r "$TEMP_ZIP" "$TOOL_NAME" -x "**/__pycache__/*" "**/*.pyc" "**/.DS_Store"

mv "$TEMP_ZIP" "$OUTPUT_FILE"

# Calculate SHA256 checksum
if command -v shasum &> /dev/null; then
    SHA256_HASH=$(shasum -a 256 "$OUTPUT_FILE" | awk '{print $1}')
elif command -v sha256sum &> /dev/null; then
    SHA256_HASH=$(sha256sum "$OUTPUT_FILE" | awk '{print $1}')
else
    SHA256_HASH="Unable to calculate SHA256 (neither shasum nor sha256sum installed)"
fi

echo "--------------------------------------------------------"
echo "Package built successfully!"
echo "Location: $OUTPUT_FILE"
echo "SHA256 Checksum: $SHA256_HASH"
echo "--------------------------------------------------------"
echo "Copy the SHA256 checksum above and paste it into"
echo "your vjtoolkit-tools repository's tools_manifest.json."
echo "--------------------------------------------------------"
