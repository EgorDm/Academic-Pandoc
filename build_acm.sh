#!/bin/sh

SCRIPT_DIR="$(realpath $(dirname "$0"))"
INPUT_FILE="$(realpath "$1")"
WORKDIR="$(dirname $INPUT_FILE)"

cd $WORKDIR

SCRIPT_DIR_REL="$(realpath --relative-to="$(pwd)" "$SCRIPT_DIR")"
OUTPUT_PDF="${INPUT_FILE/md/pdf}"
OUTPUT_TEX="${INPUT_FILE/md/tex}"

SOURCE_FORMAT="markdown\
+pipe_tables\
+backtick_code_blocks\
+strikeout\
+yaml_metadata_block\
+implicit_figures\
+all_symbols_escapable\
+link_attributes\
+smart\
+fenced_divs"

BUILD_COMMAND="pandoc \
  --number-sections \
  --standalone \
  -t latex --pdf-engine=latexmk \
  --natbib \
  --resource-path="$SCRIPT_DIR:$WORKDIR:." \
  --template="$SCRIPT_DIR/templates/acmart.tex" \
  --metadata-file="$SCRIPT_DIR/templates/acmart.yml" \
  --metadata documentclass="$SCRIPT_DIR_REL/templates/acmart" \
  -f $SOURCE_FORMAT \
  --filter pandoc-xnos \
  -i $INPUT_FILE"

echo "Building $OUTPUT_PDF from $INPUT_FILE"
if [ $DEBUG ]; then
  $BUILD_COMMAND -o "$OUTPUT_TEX"
fi
$BUILD_COMMAND -o "$OUTPUT_PDF"
