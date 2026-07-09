#!/bin/bash
#
# Installs sharpen_pitest into /opt, and creates a link from /usr/bin to the sharpen_pitest script.
#
# Note: Requires root permissions to create the directory. Use sudo to execute this script.
#

SHARPEN_PITEST_DIR="/opt/sharpen_pitest"

if [ -d "$SHARPEN_PITEST_DIR" ]; then
    rm -R "$SHARPEN_PITEST_DIR"
fi

mkdir "$SHARPEN_PITEST_DIR"

cp sharpen_pitest.sh "$SHARPEN_PITEST_DIR"
chmod a+x "$SHARPEN_PITEST_DIR/sharpen_pitest.sh"

ln -f "$SHARPEN_PITEST_DIR/sharpen_pitest.sh" /usr/bin/sharpen_pitest
