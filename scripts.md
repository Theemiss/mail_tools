# System Maintenance and Backup Scripts

This repository contains a collection of system maintenance and backup scripts designed for iRedMail server environments. These scripts handle various cleanup, backup, and maintenance tasks for different components of the mail server infrastructure.

## 📋 Script Overview

The main script executes the following maintenance tasks in sequence:

### 🔒 Backup Operations
- **OpenLDAP Backup**: `/var/vmail/backup/backup_openldap.sh`
- **MySQL Databases Backup**: `/var/vmail/backup/backup_mysql.sh` (runs at 03:30 AM)
- **SOGo Data Backup**: `/var/vmail/backup/backup_sogo.sh` (runs at 04:01 AM)

### 🧹 Cleanup Operations
- **iRedAPD Maintenance**:
  - Cleanup expired tracking records hourly
  - Convert SPF DNS records to IP addresses/networks hourly
- **Amavisd Database Cleanup**: Cleans up Amavisd database
- **iRedAdmin Maintenance**:
  - General SQL database cleanup
  - Delete mailboxes belonging to removed accounts from filesystem
- **Roundcube Maintenance**:
  - Cleanup SQL database
  - Cleanup temporary files from 'temp/' directory

### 🛡️ Security Operations
- **Fail2ban Management**: Unban IP addresses pending for removal from SQL database

## 🚀 Usage

The script is designed to be run as a cron job or scheduled task. To execute manually:

```bash
./maintenance_script.sh
```

## ⚙️ Scheduling Recommendations

For optimal performance, schedule this script to run during off-peak hours:
- **Backup tasks**: Early morning hours (3-4 AM)
- **Cleanup tasks**: Hourly or daily depending on server load
- **Database maintenance**: During low-traffic periods

## 📁 File Structure

```
/var/vmail/backup/
├── backup_openldap.sh
├── backup_mysql.sh
└── backup_sogo.sh

/opt/iredapd/tools/
├── cleanup_db.py
└── spf_to_greylist_whitelists.py

/opt/www/iredadmin/tools/
├── cleanup_amavisd_db.py
├── cleanup_db.py
└── delete_mailboxes.py

/opt/www/roundcubemail/bin/
├── cleandb.sh
└── gc.sh

/usr/local/bin/
└── fail2ban_banned_db
```

## 🔧 Dependencies

- **bash**: Shell script execution
- **python3**: Python script execution
- **php**: Roundcube maintenance scripts
- **MySQL/OpenLDAP**: Database systems
- **Fail2ban**: IP banning system

## 📊 Logging

Most scripts output to `/dev/null` by default. For debugging purposes, you may want to redirect output to log files:

```bash
python3 /opt/iredapd/tools/cleanup_db.py >> /var/log/iredapd_cleanup.log 2>&1
```

## 🛠️ Configuration

Ensure proper permissions on all script files:
```bash
chmod +x /var/vmail/backup/*.sh
chmod +x /usr/local/bin/fail2ban_banned_db
```

## 🔒 Security Considerations

- Ensure backup files are stored securely with appropriate permissions
- Verify that cleanup scripts don't remove active data
- Regularly test backup restoration procedures
- Monitor script execution for failures

## 📝 Monitoring

Recommended monitoring checks:
- Backup file creation timestamps
- Script exit codes
- Disk space for backup storage
- Database sizes before/after cleanup

## 🤝 Contributing

When modifying scripts:
1. Test changes in a development environment
2. Maintain existing logging practices
3. Ensure backward compatibility
4. Update documentation accordingly

## ⚠️ Troubleshooting

Common issues:
- Permission denied errors: Check script executable permissions
- Python module errors: Verify Python dependencies
- Database connection issues: Check database service status
- Insufficient disk space: Monitor backup storage capacity

## 📄 License

These scripts are part of the iRedMail ecosystem. Please refer to the iRedMail licensing terms for usage rights and restrictions.

## 📞 Support

For issues related to these scripts, refer to:
- iRedMail documentation
- Server system logs
- Script-specific error messages

---

*Note: Always test scripts in a non-production environment before deployment.*
