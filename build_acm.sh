#!/bin/sh

SCRIPT_DIR="$(realpath $(dirname "$0"))"
INPUT_FILE="$(realpath "$1")"
WORKDIR="$(dirname "$INPUT_FILE")"

cd "$WORKDIR"

SCRIPT_DIR_REL="$(realpath --relative-to="$(pwd)" "$SCRIPT_DIR")"

# Handle directory projects
METADATA_ARGS=
if [ -d "$INPUT_FILE" ]; then
  echo $INPUT_FILE
  INPUT_FILE="$(realpath "$INPUT_FILE")"
  WORKDIR="$INPUT_FILE"
  if [ -f "$INPUT_FILE/meta.yml" ]; then
    METADATA_ARGS="--metadata-file $INPUT_FILE/meta.yml"
  fi
  awk 'FNR==1{print ""}1' "$INPUT_FILE"/*.md > "$INPUT_FILE/main.mdc"
  INPUT_FILE="${INPUT_FILE}/main.mdc"
  OUTPUT_PDF="${INPUT_FILE/mdc/pdf}"
  OUTPUT_TEX="${INPUT_FILE/mdc/tex}"
else
  OUTPUT_PDF="${INPUT_FILE/md/pdf}"
  OUTPUT_TEX="${INPUT_FILE/md/tex}"
fi

cd "$WORKDIR"

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
  $METADATA_ARGS \
  -f $SOURCE_FORMAT \
  --filter pandoc-theoremnos \
  --filter pandoc-xnos \
  --filter pandoc-comments"

VAR_TEXINPUTS=".:$WORKDIR:$SCRIPT_DIR/templates:$TEXINPUTS"
echo "Building $OUTPUT_PDF from $INPUT_FILE"
if [ $DEBUG ]; then
  TEXINPUTS="$VAR_TEXINPUTS" $BUILD_COMMAND -i "$INPUT_FILE" -o "$OUTPUT_TEX"
  echo TEXINPUTS="$VAR_TEXINPUTS" $BUILD_COMMAND -i "$INPUT_FILE" -o "$OUTPUT_PDF"
fi
TEXINPUTS="$VAR_TEXINPUTS" $BUILD_COMMAND -i "$INPUT_FILE" -o "$OUTPUT_PDF"
