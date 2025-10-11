#!/bin/bash

# To install run `crontab -e` with an ssh `gh auth login`
# 15 10 * * 3 ~/dotfiles/scripts/git_backup.sh >> ~/.git_backup/log 2>&1

set -e

BACKUP_DIR="$HOME/.git_backup"
INPUT_CSV="$BACKUP_DIR/input.csv"
ARCHIVE_DIR="$BACKUP_DIR/archives"
TEMP_DIR="$BACKUP_DIR/temp"
KEEP_LATEST=6


# Init
mkdir -p "$ARCHIVE_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Input Validation
if [ ! -f "$INPUT_CSV" ]; then
  echo "❌ backup list not found: $INPUT_CSV"
  exit 1
fi

# Backup
while IFS= read -r REPO; do
  # Skip empty or comment lines
  [[ -z "$REPO" || "$REPO" =~ ^# ]] && continue

  D=$(echo "$REPO" | sed -E 's#(git@|https://)github\.com[:/]+([^/]+)/.*#\2#')
  R=$(basename "$REPO" .git)
  git clone --depth 1 --branch main "$REPO" "$TEMP_DIR/$D/$R" -q
done < "$INPUT_CSV"

# Compress Backup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
ZIP_NAME="backup_$TIMESTAMP.zip"
ZIP_PATH="$ARCHIVE_DIR/$ZIP_NAME"

cd "$TEMP_DIR"
zip -rq "$ZIP_PATH" .

# Cleanup
rm -rf "$TEMP_DIR"

# Expire Old Backups
cd "$ARCHIVE_DIR"
ls -tp backup_*.zip 2>/dev/null | grep -v '/$' | tail -n +$((KEEP_LATEST+1)) | xargs -r rm --
