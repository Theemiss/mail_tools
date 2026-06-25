#!/bin/bash
set -euo pipefail

S3_BUCKET="${S3_BUCKET:-your-backup-bucket}"
IMG_NAME="${IMG_NAME:-iredmail-full.img}"
AMI_NAME="${AMI_NAME:-iRedMail-AMI}"
AWS_REGION="${AWS_REGION:-us-east-1}"

CONTAINERS_FILE="containers.json"
cat > "$CONTAINERS_FILE" <<EOF
[
  {
    "Description": "$AMI_NAME",
    "Format": "raw",
    "UserBucket": {
      "S3Bucket": "$S3_BUCKET",
      "S3Key": "$IMG_NAME"
    }
  }
]
EOF

echo "[INFO] containers.json created:"
cat "$CONTAINERS_FILE"

echo "[INFO] Starting import-image task..."
IMPORT_TASK_ID=$(aws ec2 import-image \
  --description "$AMI_NAME" \
  --disk-containers "file://$CONTAINERS_FILE" \
  --region "$AWS_REGION" \
  --query 'ImportTaskId' \
  --output text)

echo "[INFO] Import task started: $IMPORT_TASK_ID"
echo "Monitor with: ./monitor_import.sh $IMPORT_TASK_ID"
