#!/bin/bash
#
# Script to run sharpen_pitest.
#

SHARPEN_PITEST_DIR="/opt/sharpen_pitest"

java -jar "$SHARPEN_PITEST_DIR/sharpenpitest-1.0-SNAPSHOT-jar-with-dependencies.jar" "$@"