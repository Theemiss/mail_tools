#!/bin/bash
set -euo pipefail

BACKUP_BASE="${BACKUP_BASE:-/var/vmail/backup}"
TMP_DIR="${TMP_DIR:-/tmp/iredmail_backup}"
S3_BUCKET="${S3_BUCKET:-s3://your-backup-bucket}"
HOSTNAME=$(hostname -s)
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

MAILBOX_DIR="${MAILBOX_DIR:-/var/vmail/vmail1}"
DKIM_DIR="${DKIM_DIR:-/var/lib/dkim}"
CONFIG_DIRS=(
  "/etc/iredmail"
  "/etc/postfix"
  "/etc/dovecot"
  "/etc/amavis"
  "/etc/clamav"
  "/etc/spamassassin"
  "/opt/www/roundcubemail"
  "/opt/www/iredadmin"
  "/etc/letsencrypt"
  "/etc/nginx"
)
ROOT_DIRS=(
  "/root"
)

mkdir -p "$TMP_DIR/$DATE"

echo "[*] Running built-in iRedMail backup scripts..."
/bin/bash "$BACKUP_BASE/backup_openldap.sh"
/bin/bash "$BACKUP_BASE/backup_mysql.sh"
/bin/bash "$BACKUP_BASE/backup_sogo.sh" || echo "[!] SOGo backup skipped (not installed?)"

cp -r "$BACKUP_BASE"/*.{bz2,gz,sql,ldif} "$TMP_DIR/$DATE/" 2>/dev/null || true

echo "[*] Backing up mailboxes..."
tar -czf "$TMP_DIR/$DATE/mailboxes.tar.gz" -C "$MAILBOX_DIR" .

echo "[*] Backing up DKIM keys..."
tar -czf "$TMP_DIR/$DATE/dkim.tar.gz" -C "$DKIM_DIR" .

echo "[*] Backing up iRedMail configs + Nginx + SSL..."
tar -czf "$TMP_DIR/$DATE/configs.tar.gz" "${CONFIG_DIRS[@]}" || echo "[!] Some config dirs missing, continuing..."

echo "[*] Backing up /root directory..."
tar -czf "$TMP_DIR/$DATE/root_home.tar.gz" "${ROOT_DIRS[@]}" || echo "[!] /root backup failed, continuing..."

echo "[*] Uploading to S3 bucket: $S3_BUCKET"
aws s3 cp --recursive "$TMP_DIR/$DATE" "$S3_BUCKET/$HOSTNAME/$DATE/"

rm -rf "$TMP_DIR/$DATE"

echo "[OK] Backup completed and uploaded to S3: $S3_BUCKET/$HOSTNAME/$DATE/"
