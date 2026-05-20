#!/bin/bash
# Restore .cks/control-plane/ from a named backup file.
# Usage: control-plane-restore.sh <backup-file>
# Moves existing control-plane dir to .cks/control-plane.bak-TIMESTAMP before restore.

BACKUP_FILE="$1"
CP_DIR=".cks/control-plane"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <path-to-backup.tar.gz>"
  echo "Available backups:"
  ls -t .cks/backups/control-plane-*.tar.gz 2>/dev/null | sed 's/^/  /'
  exit 1
fi

[ -f "$BACKUP_FILE" ] || { echo "Backup file not found: ${BACKUP_FILE}"; exit 1; }

if [ -d "$CP_DIR" ]; then
  BAK="${CP_DIR}.bak-$(date +%s)"
  mv "$CP_DIR" "$BAK" 2>/dev/null
  echo "Moved existing control plane to: ${BAK}"
fi

tar -xzf "$BACKUP_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "✓ Restored from: ${BACKUP_FILE}"
  echo "  Verify with: /cks:control-plane --status"
else
  echo "✗ Restore failed"
fi
exit 0
