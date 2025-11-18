#!/bin/bash

# === SETTINGS ===
SOURCE="/Users/healmiy/Library/CloudStorage/OneDrive-Personal/{{choose-your-dir}}"
BASE_DEST="{{find-your-mount-dir}}"
MOUNT_URL="smb://{{find-your-mount-url}}"
LOGFILE="$HOME/Documents/rsync_backup_log.txt"
DATE=$(date +"%Y-%m-%d")


# === MOUNT SHARE ===
echo "[$(date)] Mounting share..." >> "$LOGFILE"
/usr/bin/open "$MOUNT_URL"

# Wait up to 20 seconds for the drive to mount
for i in {1..20}; do
    if [ -d "/Volumes/rauterdrive" ]; then
        echo "[$(date)] Share mounted successfully." >> "$LOGFILE"
        break
    fi
    sleep 1
done

# Check base destination
if [ ! -d "$BASE_DEST" ]; then
    mkdir -p "$BASE_DEST"
fi

# === CREATE DATED BACKUP FOLDER ===
DEST="$BASE_DEST/$DATE"
PREV=$(ls -1dt "$BASE_DEST"/*/ 2>/dev/null | head -n 1)

if [ -d "$PREV" ]; then
    echo "[$(date)] Using previous backup as hardlink base: $PREV" >> "$LOGFILE"
    /usr/bin/rsync -avh --delete --link-dest="$PREV" "$SOURCE" "$DEST" >> "$LOGFILE" 2>&1
else
    echo "[$(date)] No previous backup found. Creating fresh copy." >> "$LOGFILE"
    /usr/bin/rsync -avh "$SOURCE" "$DEST" >> "$LOGFILE" 2>&1
fi

RSYNC_EXIT=$?

# === CLEANUP OLD BACKUPS (older than 7 days) ===
find "$BASE_DEST" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; >> "$LOGFILE" 2>&1
