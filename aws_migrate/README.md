# iRedMail VPS → AWS Migration Scripts

This repository provides scripts and guidance to **migrate an iRedMail VPS from OVH (or similar VPS providers) to AWS**. It handles:

* Creating a full disk image of the VPS.
* Uploading it to S3.
* Importing the disk image into AWS as an AMI using VM Import/Export.
* Monitoring import progress.
* Launching a new EC2 instance from the imported AMI.

These scripts aim to **minimize downtime, preserve mail data, LDAP, and configurations**, and streamline migration.

---

## **Repository Structure**

| Script                       | Description                                                                                                          |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `create_push_iredmail.sh`    | Creates a **full disk image** of the VPS (`/dev/sda`), including boot/EFI partitions, and uploads it directly to S3. |
| `download_unzip_iredmail.sh` | Downloads a `.gz` disk image from S3, decompresses it locally, and optionally re-uploads for AWS import.             |
| `import_iredmail_ami.sh`     | Creates `containers.json` and starts an AWS VM Import task to create an AMI.                                         |
| `monitor_import.sh`          | Monitors the status and progress of an AWS import task and outputs the final AMI ID.                                 |

---

## **Prerequisites**

### On OVH iRedMail VPS

* Root access.
* Installed packages: `dd`, `gzip`, `awscli`.
* Enough free disk space for temporary zero-fill (optional but recommended for compression).

### On Home/Management Server

* AWS CLI configured with an IAM user with:

  * `s3:GetObject`, `s3:PutObject`
  * `ec2:ImportImage`, `ec2:DescribeImportImageTasks`
* Installed packages: `pv`, `gzip`.
* Sufficient disk space if downloading and decompressing images locally.

### AWS Requirements

* S3 bucket to store disk images.
* EC2 permissions to create AMIs and launch instances.
* Target region where the AMI will be created.

---

## **Workflow Diagram**

```
+-------------------+       +-------------------+       +----------------------+
|   OVH VPS Server  |       |        S3         |       |      AWS EC2/AMI     |
|-------------------|       |-------------------|       |----------------------|
| /dev/sda disk     |  -->  | iredmail-full.img |  -->  | AMI created from S3  |
| iRedMail, LDAP,   |       | (gzipped)         |       | Launch EC2 instance  |
| Maildir, configs  |       |                   |       | Assign Elastic IP    |
+-------------------+       +-------------------+       +----------------------+
        |                               ^
        |                               |
        |                               |
  create_push_iredmail.sh          import_iredmail_ami.sh
```

---

## **Step-by-Step Migration Guide**

### **Step 1: Create and upload image on OVH VPS**

```bash
chmod +x create_push_iredmail.sh
./create_push_iredmail.sh
```

* Creates a compressed **full disk image** of `/dev/sda`.
* Uploads directly to your configured S3 bucket.
* Optional: zero-fill free space before imaging for better compression.

---

### **Step 2: Download and decompress locally (optional)**

```bash
chmod +x download_unzip_iredmail.sh
./download_unzip_iredmail.sh
```

* Downloads `.gz` image from S3.
* Decompresses it to a raw `.img`.
* Optional: re-upload uncompressed image for AWS import.

> **Tip:** If you have a fast connection and enough S3 storage, you can skip local decompression and import directly from `.gz` using AWS VM Import.

---

### **Step 3: Create AMI from S3 image**

```bash
chmod +x import_iredmail_ami.sh
./import_iredmail_ami.sh
```

* Generates `containers.json` pointing to your S3 image.
* Starts an AWS VM Import task.
* Returns an **ImportTaskId** for monitoring.

---

### **Step 4: Monitor import progress**

```bash
chmod +x monitor_import.sh
./monitor_import.sh <ImportTaskId>
```

* Checks status and progress every 30 seconds.
* Outputs **AMI ID** when complete.

---

### **Step 5: Launch a new EC2 instance from AMI**

1. Go to **EC2 Console → AMIs** → find your new AMI.
2. Launch an instance:

   * Choose instance type (e.g., `t3.medium`).
   * Assign **Elastic IP** for consistent mail routing.
   * Security group: open ports:

     ```
     25, 587, 465, 993, 80, 443
     ```
3. Optional: attach separate **EBS volume for /var/vmail** if mailboxes are large.
4. Mount volume and adjust ownership:

```bash
mount /dev/xvdf /var/vmail
chown -R vmail:vmail /var/vmail
```

---

### **Step 6: Post-launch configuration**

* **Update Let’s Encrypt certificates**:

```bash
certbot certonly --standalone -d mail.example.com
```

* Update Postfix/Dovecot configs to point to new certs:

```
ssl_cert = </etc/letsencrypt/live/mail.example.com/fullchain.pem
ssl_key  = </etc/letsencrypt/live/mail.example.com/privkey.pem
```

* **Verify `/etc/fstab`** - ensure root volume matches EC2 device (`/dev/xvda1`).

* Start services:

```bash
systemctl restart postfix dovecot amavis
systemctl enable postfix dovecot amavis
```

* Update DNS (MX, SPF, DKIM, DMARC, PTR) to point to Elastic IP.

---

## **Tips & Best Practices**

* Always backup DNS and mail data before migration.
* Use separate EBS volume for `/var/vmail` - easier for snapshots/backups.
* Zero-fill free space before imaging to reduce image size:

```bash
sudo dd if=/dev/zero of=/EMPTY bs=1M status=progress
sudo rm -f /EMPTY
```

* Use `pv` when downloading large files to monitor progress.
* Test the new EC2 instance thoroughly before decommissioning OVH VPS.

---

## **License**

MIT License - free to use, modify, and distribute.

