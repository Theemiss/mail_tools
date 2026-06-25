#!/bin/bash
set -euo pipefail

IMPORT_TASK_ID="${1:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"

if [ -z "$IMPORT_TASK_ID" ]; then
  echo "Usage: $0 <ImportTaskId>"
  exit 1
fi

echo "[INFO] Monitoring import task: $IMPORT_TASK_ID in region $AWS_REGION"

while true; do
  STATUS=$(aws ec2 describe-import-image-tasks \
    --import-task-ids "$IMPORT_TASK_ID" \
    --region "$AWS_REGION" \
    --query 'ImportImageTasks[0].Status' \
    --output text)

  PROGRESS=$(aws ec2 describe-import-image-tasks \
    --import-task-ids "$IMPORT_TASK_ID" \
    --region "$AWS_REGION" \
    --query 'ImportImageTasks[0].Progress' \
    --output text)

  echo "Status: $STATUS | Progress: ${PROGRESS:-0}%"

  if [ "$STATUS" = "completed" ]; then
    AMI_ID=$(aws ec2 describe-import-image-tasks \
      --import-task-ids "$IMPORT_TASK_ID" \
      --region "$AWS_REGION" \
      --query 'ImportImageTasks[0].ImageId' \
      --output text)
    echo "[INFO] Import completed. AMI ID: $AMI_ID"
    break
  elif [ "$STATUS" = "deleted" ] || [ "$STATUS" = "deleting" ] || [ "$STATUS" = "deleted_failed" ]; then
    echo "[ERROR] Import task ended with status: $STATUS"
    break
  fi

  sleep 30
done
