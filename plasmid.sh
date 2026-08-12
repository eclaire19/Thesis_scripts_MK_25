#!/bin/bash
for d in prokka*/; do
  # Find the first fasta/fa file in the directory
  f=$(find "$d" -maxdepth 1 -type f \( -iname "*.fasta" -o -iname "*.fna" \) | head -n 1)

  # Proceed only if a file is found
  if [ -n "$f" ]; then
    # Get total sequence length (ignoring headers)
    len=$(grep -v "^>" "$f" | tr -d '\n' | wc -c)

    # Construct new directory name
    new="pcf_plasmid_len${len}"

    # Rename if different
    if [ "${d%/}" != "$new" ]; then
      mv "$d" "$new"
    fi
  fi
done

