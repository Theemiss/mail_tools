# mail_tools

Shell scripts for **iRedMail** backup and **VPS to AWS** migration using disk imaging, S3, and EC2 VM Import/Export.

---

## Repository structure

```
.
├── aws_migrate/          # VPS disk image -> S3 -> AWS AMI
│   ├── create_push_iredmail.sh
│   ├── download_unzip_iredmail.sh
│   ├── import_iredmail_ami.sh
│   ├── monitor_import.sh
│   └── README.md
├── backup/
│   └── iredmail_full_backup.sh
└── scripts.md            # Reference cron/maintenance task index
```

---

## Quick start

```bash
git clone https://github.com/Theemiss/mail_tools.git
cd mail_tools
```

### Full backup to S3

```bash
export S3_BUCKET="s3://your-backup-bucket"
sudo -E ./backup/iredmail_full_backup.sh
```

### Migrate VPS to AWS

See [aws_migrate/README.md](aws_migrate/README.md) for the full workflow.

```bash
export S3_BUCKET="your-backup-bucket"
export AWS_REGION="us-east-1"
sudo -E ./aws_migrate/create_push_iredmail.sh
```

---

## Environment variables

| Variable | Used in | Default | Purpose |
|----------|---------|---------|---------|
| `S3_BUCKET` | all scripts | `your-backup-bucket` | S3 bucket name (backup script accepts `s3://` prefix) |
| `AWS_REGION` | aws_migrate | `us-east-1` | Target AWS region |
| `DISK` | create_push | `/dev/sda` | Source disk device on VPS |
| `IMG_NAME` | aws_migrate | `iredmail-full.img.gz` | Image object key |
| `UPLOAD_RAW` | download_unzip | `false` | Set `true` to re-upload uncompressed image |

---

## Requirements

- Root access on the mail server
- AWS CLI configured (`aws configure`)
- IAM permissions: S3 read/write, EC2 import/describe (for migration)
- Packages: `dd`, `gzip`, `awscli`, `pv` (optional, for progress)

---

## Best practices

- Test in staging before production runs.
- Use separate buckets for backups vs migration images.
- Never commit credentials or bucket names with real hostnames to git.
- Verify DNS (MX, SPF, DKIM, DMARC) after migration.

---

## License

MIT - see [LICENSE](LICENSE).
