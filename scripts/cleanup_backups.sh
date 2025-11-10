#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Looking for old rc-sync backups..."

# Define which rc files we are managing backups for
RC_FILES=("$HOME/.bashrc" "$HOME/.zshrc")
# How many recent backups to keep for each file
NUM_BACKUPS_TO_KEEP=5

for rc_file in "${RC_FILES[@]}"; do
  # List all backup files for the current rc file, sorted by name (which is chronological)
  # The `|| true` prevents the script from exiting if no files are found
  BACKUP_FILES=($(ls -d "${rc_file}.bak-"* 2>/dev/null || true))
  
  # Check if there are more backups than we want to keep
  if [[ ${#BACKUP_FILES[@]} -gt $NUM_BACKUPS_TO_KEEP ]]; then
    # How many backups to delete
    NUM_TO_DELETE=$(( ${#BACKUP_FILES[@]} - $NUM_BACKUPS_TO_KEEP ))
    
    echo "Found ${#BACKUP_FILES[@]} backups for $(basename "$rc_file"). Keeping $NUM_BACKUPS_TO_KEEP, removing $NUM_TO_DELETE."
    
    # Get the list of files to delete (the oldest ones)
    FILES_TO_DELETE=($(ls -d "${rc_file}.bak-"* | head -n $NUM_TO_DELETE))
    
    for file_to_delete in "${FILES_TO_DELETE[@]}"; do
      echo "  - Deleting ${file_to_delete}"
      rm "$file_to_delete"
    done
  else
    echo "Found ${#BACKUP_FILES[@]} backups for $(basename "$rc_file"). No old backups to remove."
  fi
done

echo "✅ Cleanup complete."
