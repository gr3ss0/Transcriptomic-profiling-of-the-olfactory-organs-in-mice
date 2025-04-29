#!/bin/bash

# Usage: ./extract_fastq.sh /path/to/input_dir /path/to/output_dir

INPUT_DIR="$1"
OUTPUT_DIR="$2"

# Check arguments
if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 <input_dir_with_bam> <output_dir_for_fastq>"
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop over all BAM files in input directory
for BAM in "$INPUT_DIR"/*.bam; do
  BASENAME=$(basename "$BAM" .bam)
  R1="$OUTPUT_DIR/${BASENAME}_R1.fastq"
  R2="$OUTPUT_DIR/${BASENAME}_R2.fastq"
  ORPHANS="$OUTPUT_DIR/${BASENAME}_orphans.fastq"
  SINGLETONS="$OUTPUT_DIR/${BASENAME}_singletons.fastq"

  # Extract FASTQ only if not already present
  if [[ -f "$R1" && -f "$R2" && -f "$ORPHANS" && -f "$SINGLETONS" ]]; then
    echo "FASTQ files already exist for $BASENAME. Skipping extraction..."
  else
    echo "Extracting FASTQ from $BAM..."
    samtools fastq "$BAM" \
      -1 "$R1" \
      -2 "$R2" \
      -0 "$ORPHANS" \
      -s "$SINGLETONS" \
      -n
  fi

  # Compute counts if files exist
  if [[ -f "$R1" && -f "$R2" && -f "$ORPHANS" && -f "$SINGLETONS" ]]; then
    R1_COUNT=$(($(wc -l < "$R1") / 4))
    R2_COUNT=$(($(wc -l < "$R2") / 4))
    ORPHAN_COUNT=$(($(wc -l < "$ORPHANS") / 4))
    SINGLETON_COUNT=$(($(wc -l < "$SINGLETONS") / 4))

    # Each pair has one R1 and one R2
    PAIRED_COUNT=$((R1_COUNT))  # or R2_COUNT, should be the same
    UNPAIRED_COUNT=$((ORPHAN_COUNT + SINGLETON_COUNT))

    # Calculate ratio safely (avoid division by zero)
    if [[ $UNPAIRED_COUNT -eq 0 ]]; then
      RATIO="∞"
    else
      RATIO=$(awk "BEGIN {printf \"%.4f\", $UNPAIRED_COUNT / $PAIRED_COUNT}")
    fi

    echo "####$BASENAME stats:"
    echo "    Paired reads (R1):     $R1_COUNT"
    echo "    Paired reads (R2):     $R2_COUNT"
    echo "    Orphaned reads:        $ORPHAN_COUNT"
    echo "    Singleton reads:       $SINGLETON_COUNT"
    echo "    Ratio unpaired/paired: $RATIO"
    echo
  else
    echo "!!!!Missing expected FASTQ files for $BASENAME — skipping stats."
  fi
done

echo "All done!"
