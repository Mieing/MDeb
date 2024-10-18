#!/bin/bash

# Create necessary directories
mkdir -p /var/mobile/Documents/Mdeb/deb
mkdir -p /var/mobile/Documents/Mdeb/dylib

# Function to extract dylib files from a deb file
extract_dylibs() {
    DEB_FILE="$1"
    TEMP_DIR=$(mktemp -d)
    
    dpkg-deb -x "$DEB_FILE" "$TEMP_DIR"
    
    find "$TEMP_DIR" -name "*.dylib" -exec mv {} /var/mobile/Documents/Mdeb/dylib/ \;
    
    rm -rf "$TEMP_DIR"
}

# Extract dylib files from all deb files in the directory
for DEB_FILE in /var/mobile/Documents/Mdeb/deb/*.deb; do
    extract_dylibs "$DEB_FILE"
done