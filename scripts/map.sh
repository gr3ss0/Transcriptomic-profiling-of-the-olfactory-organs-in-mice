#!/bin/bash

# Usage: ./map_star.sh FASTQ_DIR OUTPUT_DIR

FASTQ_DIR="$1"
OUTPUT_DIR="$2"
GENOME_DIR="GenomeDir"  # adjust if needed


# Check arguments
if [[ -z "$FASTQ_DIR" || -z "$OUTPUT_DIR" ]]; then
  echo "Usage: $0 <input_dir_with_fastq> <output_dir_for_bam>"
  exit 1
fi

# Threads for STAR
THREADS=15

# Create output directory if not exists
mkdir -p "$OUTPUT_DIR"

# Loop over R1 files to find samples
for R1 in "$FASTQ_DIR"/*_R1.fastq; do
    SAMPLE=$(basename "$R1" _R1.fastq)
    R2="$FASTQ_DIR/${SAMPLE}_R2.fastq"
    SINGLE="$FASTQ_DIR/${SAMPLE}_singletons.fastq"
    OUT_PREFIX="$OUTPUT_DIR/${SAMPLE}_"

    # Skip if already aligned
    if [[ -f "${OUT_PREFIX}Aligned.sortedByCoord.out.bam" ]]; then
        echo "[SKIP] $SAMPLE — STAR output already exists."
    else
        echo "[MAP] Aligning paired-end reads for $SAMPLE..."

        STAR \
            --runThreadN $THREADS \
            --genomeDir "$GENOME_DIR" \
            --readFilesIn "$R1" "$R2" \
            --outFileNamePrefix "$OUT_PREFIX" \
            --outSAMtype BAM SortedByCoordinate \
            --quantMode TranscriptomeSAM GeneCounts

        echo "[DONE] Paired-end alignment for $SAMPLE."
    fi

    # Align singletons if available
    if [[ -f "$SINGLE" ]]; then
        OUT_PREFIX_SINGLE="$OUTPUT_DIR/${SAMPLE}_singleton_"

        if [[ -f "${OUT_PREFIX_SINGLE}Aligned.sortedByCoord.out.bam" ]]; then
            echo "[SKIP] $SAMPLE (singletons) — STAR output already exists."
        else
            echo "[MAP] Aligning singleton reads for $SAMPLE..."

            STAR \
                --runThreadN $THREADS \
                --genomeDir "$GENOME_DIR" \
                --readFilesIn "$SINGLE" \
                --outFileNamePrefix "$OUT_PREFIX_SINGLE" \
                --outSAMtype BAM SortedByCoordinate \
                --quantMode TranscriptomeSAM GeneCounts

            echo "[DONE] Singleton alignment for $SAMPLE."
        fi
    fi

    echo ""
done

echo "All mappings completed (or skipped if already done)."
