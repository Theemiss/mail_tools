#!/bin/bash
set -euo pipefail

S3_BUCKET="${S3_BUCKET:-your-backup-bucket}"
IMG_NAME="${IMG_NAME:-iredmail-full.img.gz}"
DISK="${DISK:-/dev/sda}"
BS="${BS:-4M}"

echo "[INFO] Creating full disk image and uploading to S3..."
sudo dd if="$DISK" bs="$BS" conv=sparse status=progress | gzip -c | aws s3 cp - "s3://$S3_BUCKET/$IMG_NAME"

echo "[INFO] Done. Image uploaded to s3://$S3_BUCKET/$IMG_NAME"
