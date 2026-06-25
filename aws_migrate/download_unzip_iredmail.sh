#!/bin/bash
set -euo pipefail

S3_BUCKET="${S3_BUCKET:-your-backup-bucket}"
IMG_NAME="${IMG_NAME:-iredmail-full.img.gz}"
LOCAL_IMG="${LOCAL_IMG:-iredmail-full.img}"

echo "[INFO] Downloading $IMG_NAME from S3..."
aws s3 cp "s3://$S3_BUCKET/$IMG_NAME" - | pv | gunzip -c > "$LOCAL_IMG"

echo "[INFO] Download and unzip complete: $LOCAL_IMG"

if [ "${UPLOAD_RAW:-false}" = "true" ]; then
  echo "[INFO] Uploading raw image back to S3..."
  aws s3 cp "$LOCAL_IMG" "s3://$S3_BUCKET/$LOCAL_IMG"
fi
