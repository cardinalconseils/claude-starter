---
name: database-recovery
description: >
  Database backup and recovery strategy selection for production applications.
  Use when: designing backup schedules, implementing WAL or point-in-time
  recovery (PITR), choosing between full/differential/incremental backups,
  defining RTO and RPO targets, or recovering from data loss events.
allowed-tools: Read, Grep, Glob, Bash
---

# Database Recovery

## Overview

Every production database needs a backup strategy before it has users. The right strategy depends on one question: what is the business cost of losing one hour of data? One day? One week? Match the strategy to the answer.

## RTO and RPO

**Recovery Point Objective (RPO)** — How much data loss is acceptable? "RPO = 1 hour" means losing up to one hour of writes is tolerable.

**Recovery Time Objective (RTO)** — How long can the system be unavailable during recovery? "RTO = 30 minutes" means the service must be restored within 30 minutes of a failure.

Define both before choosing a strategy. If you cannot answer these, ask the business stakeholders — they own the risk.

## Strategies

### Noob: Weekly Full Dumps

The entire database is dumped to object storage once per week. The dump is replicated to a second geographic region.

- **RPO**: Up to 1 week — data written after the last dump is permanently lost on failure
- **RTO**: Minutes to hours depending on database size (full restore from dump)
- **Storage impact**: High — storing full dumps
- **Complexity**: Low — one cron job, one `pg_dump` command
- **Use for**: Prototypes, internal tools, throwaway projects with no real user data

### Pro: Daily Base + Hourly Differential

A full "base" backup is taken once per day. Every hour, a differential backup captures only the changes since the last base backup. Recovery combines the latest base with the most recent differential.

- **RPO**: Up to 1 hour — data between the last differential and the failure is lost
- **RTO**: Base restore time + differential replay time (typically faster than full restore)
- **Storage impact**: Moderate — one full dump daily plus small hourly diffs
- **Complexity**: Medium — requires tooling to manage base + diff relationship
- **Use for**: Applications with real users where losing a day of data is unacceptable but minute-level precision is not required

### Hacker: Write-Ahead Logging (WAL) / Point-in-Time Recovery (PITR)

Every write to the database is first written to a sequential log (the Write-Ahead Log). Only after the log entry is persisted does the actual database write occur. Periodic base backups provide a starting point; the WAL provides the path from there to any point in time.

- **RPO**: Near zero — typically seconds or minutes of data loss in worst case
- **RTO**: Base restore time + WAL replay (can be long for large WAL, but can be targeted to exact timestamp)
- **Storage impact**: Optimal — WAL entries are small; logs capture exact transactions
- **Complexity**: High — requires WAL archiving infrastructure; managed by most cloud databases
- **Use for**: Financial applications, regulated industries, AI billing systems, any system where data loss has direct monetary or legal consequences

## Strategy Comparison

| Level | Backup Frequency | RPO (Data Loss) | RTO | Storage Impact | Complexity |
|---|---|---|---|---|---|
| Noob | Weekly full | Up to 1 week | Hours | High | Low |
| Pro | Daily base + hourly diff | Up to 1 hour | Medium | Moderate | Medium |
| Hacker | Continuous WAL + periodic base | Near zero (minutes) | Variable | Optimal | High |

## WAL Deep Dive

WAL works by enforcing log-first writes:

1. Write request arrives
2. Transaction details written to the sequential WAL file
3. WAL write confirmed
4. Actual database pages updated
5. Success returned to caller

On failure, recovery loads the last base backup and replays WAL entries in sequence up to the desired restore point. This enables restoring to any timestamp between the last base backup and the failure.

**Managed WAL in practice:**
- **Supabase**: PITR enabled per-project in dashboard; WAL archived to S3 automatically
- **AWS RDS / Aurora**: Enable automated backups + PITR; restore to any second within the retention window
- **Neon**: Branching is built on WAL; PITR available via branch-to-timestamp
- **Self-hosted Postgres**: Use `pg_basebackup` + WAL archiving to S3/GCS with `archive_command`

## When to Choose Each

| Context | Strategy |
|---|---|
| Prototype, internal tool, no real users | Noob (weekly full) |
| Real users, no financial data | Pro (daily base + hourly diff) |
| Payments, user-generated content, regulated data | Hacker (WAL / PITR) |
| AI billing or metered usage | Hacker — usage data loss = revenue loss |

## Testing Backups

Untested backups are not backups. A backup that has never been restored is an assumption.

- **Restore test quarterly**: Pick a random point in time, restore to a staging environment, verify data integrity
- **Measure actual RTO**: Time the restore. If it takes 4 hours and your RTO is 30 minutes, the strategy is wrong
- **Automate restore testing**: Schedule quarterly restore tests; alert if they fail
- **Document the runbook**: Every engineer on-call must be able to execute a restore without tribal knowledge

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add proper backups before launch" | Data loss happens before launches too. Implement the strategy before first real user. |
| "We have automated backups enabled" | Automated backups exist. Have you ever restored from one? Test it. |
| "WAL is too complex for our stage" | Supabase and RDS enable WAL/PITR with a checkbox. Complexity argument no longer holds. |
| "We can recover from app logs if needed" | App logs are not a recovery mechanism. They are missing schema, foreign key state, and transaction ordering. |
| "Weekly backups are fine, we don't change much" | The week you change the least is often the week you lose the most. |

## Red Flags

- No backup strategy at all ("we'll add it later")
- Backups that have never been restored
- Backup stored in the same region as the database
- No documented RTO/RPO targets
- WAL enabled but archiving not configured (WAL fills disk and crashes the DB)
- Restore runbook exists only in one engineer's head

## Verification

- [ ] RPO and RTO targets defined and signed off by stakeholders
- [ ] Backup strategy matches RPO target
- [ ] Backups geo-replicated to a second region
- [ ] Restore test completed against staging environment
- [ ] Actual restore time measured and within RTO target
- [ ] Restore runbook documented and accessible to all on-call engineers
- [ ] WAL archiving configured (if using PITR) — not just enabled
- [ ] Backup retention period set to cover the longest acceptable recovery window
