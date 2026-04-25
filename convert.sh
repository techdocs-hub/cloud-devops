#!/bin/bash

PDF="input.pdf"
OUTPUT_DIR="images"
BATCH_SIZE=50

mkdir -p $OUTPUT_DIR

echo "🔄 Converting PDF to images..."

pdftoppm -jpeg -r 110 "$PDF" temp

count=1

for file in temp-*.jpg; do
  newname=$(printf "$OUTPUT_DIR/page-%03d.jpg" $count)

  convert "$file" -resize 1200x -quality 70 "$newname"

  rm "$file"
  ((count++))
done

total=$((count-1))

echo "📦 Total pages: $total"

echo "🚀 Uploading in batches..."

start=1

while [ $start -le $total ]; do
  end=$((start + BATCH_SIZE - 1))

  echo "➡️ Batch: $start to $end"

  for i in $(seq $start $end); do
    file=$(printf "$OUTPUT_DIR/page-%03d.jpg" $i)
    if [ -f "$file" ]; then
      git add "$file"
    fi
  done

  git commit -m "Add pages $start to $end"
  git push

  start=$((end + 1))
done

echo "✅ Done!"