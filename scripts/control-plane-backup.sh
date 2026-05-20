#!/bin/bash
# Backup .cks/control-plane/ to .cks/backups/control-plane-YYYY-MM-DD-HHMM.tar.gz
# Safe to run anytime. Exits 0 always.

BACKUP_DIR=".cks/backups"
CP_DIR=".cks/control-plane"

[ -d "$CP_DIR" ] || { echo "No control plane found at ${CP_DIR}"; exit 0; }
mkdir -p "$BACKUP_DIR" 2>/dev/null

STAMP=$(date +%Y-%m-%d-%H%M)
OUTFILE="${BACKUP_DIR}/control-plane-${STAMP}.tar.gz"

tar -czf "$OUTFILE" "$CP_DIR" 2>/dev/null
if [ $? -eq 0 ]; then
  SIZE=$(du -sh "$OUTFILE" 2>/dev/null | cut -f1)
  echo "✓ Backup: ${OUTFILE} (${SIZE})"
else
  echo "✗ Backup failed — check disk space"
fi
exit 0
