#!/bin/bash
set -e

# To install run `crontab -e`
# 15 11 * * 3 ~/dotfiles/scripts/git_backup_redundancy.sh >> ~/.git_backup/redundancy_log 2>&1

SOURCE_DIR="$HOME/.git_backup/archives"
TARGET_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backups/git"

# Init
mkdir -p "$TARGET_DIR"

# Backup
rsync -aq "$SOURCE_DIR/" "$TARGET_DIR/"