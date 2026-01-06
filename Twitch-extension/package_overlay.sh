#!/bin/bash

# Ensure we are in the directory containing this script
cd "$(dirname "$0")"

echo "--- Packaging Overlay ---"

# Remove old zip if it exists
rm -f overlay.zip

# Create the zip file
zip overlay.zip overlay.html overlay.js

echo "✅ Created overlay.zip"
