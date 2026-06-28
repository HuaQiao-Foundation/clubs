---
description: Sync member fields (birthday, email, mobile, etc.) from each club's canonical member-master sheet into its member-directory. Syncs both Georgetown and Pitchmasters by default; pass --club gt|pm to scope one.
allowed-tools: Bash
---

# Sync Members

Sync member data from each club's **canonical `member-master` sheet** into its
public-facing **`member-directory`**, matched by name (the two sheets are sorted
differently). The underlying engine is `deno task google -- <club> sync <field>`
in `scripts/google-drive.ts`.

By default this syncs **both clubs**. Always **dry-run first, show the diff, get
confirmation, then apply** — this writes to live member data.

## Step 1: Parse arguments

Parse `$ARGUMENTS`:
- `--club gt` or `--club georgetown` → only Georgetown
- `--club pm` or `--club pitchmasters` → only Pitchmasters
- no `--club` flag → **both clubs**
- `--field <name>` → sync only that field (e.g. `birthday`). Default: `all`.
- `--yes` → skip the confirmation prompt and apply directly (use sparingly).

Resolve which club codes to run:
- both → `["gt", "pm"]`
- gt only → `["gt"]`
- pm only → `["pm"]`

Available fields:
- **Georgetown**: birthday, email, mobile, classification, company
- **Pitchmasters**: birthday, email, mobile, pathway-level

(`all` runs every field configured for that club.)

## Step 2: Dry-run (always)

For each resolved club code, run the dry-run (no `--apply`):

```bash
deno task google -- <club> sync <field>
```

e.g. `deno task google -- gt sync all` then `deno task google -- pm sync all`.

Show the user the combined output. Pay attention to two things in the output:
- **"N cell(s) to update"** — the changes that will be written
- **"N not found in source (skipped)"** — directory members with no matching
  master row. These are NOT errors (sync never deletes), but if the count is
  unexpectedly high, surface it — it usually means a name mismatch or a member
  missing from the master.

## Step 3: Decide

- If the dry-run reports **0 cells would change** for every club → tell the user
  everything is already in sync and stop. Nothing to apply.
- Otherwise summarize the pending changes (which clubs, how many cells, which
  fields) and ask:

  > Apply these N change(s) to the live directory sheet(s)? (yes/no)

  Skip this prompt only if `--yes` was passed.

## Step 4: Apply

On confirmation (or `--yes`), re-run each club with `--apply`:

```bash
deno task google -- <club> sync <field> --apply
```

## Step 5: Report

```
✅ Member sync complete

  Georgetown:    <N> cell(s) written  (or "already in sync")
  Pitchmasters:  <N> cell(s) written  (or "already in sync")

Source of truth: member-master (per club). Edit birthdays/contact info there,
then re-run /sync-members to push to the directory.
```

If only one club was run (via `--club`), report just that club.

## Notes

- **Master is canonical.** Always edit member data in `member-master`; the
  directory is a derived view. Running this sync never writes back to the master.
- The sync **only writes cells that differ** and **never deletes** — a blank
  master value leaves the directory untouched.
- Matching is by name (preferred/first + last), with fallback across name
  variants. If a member is reported as "not found in source," check that their
  name in the directory matches an entry in the master.
- Requires the Google service-account keys in `.env`
  (`GOOGLE_SA_KEY_PATH_GEORGETOWN` / `GOOGLE_SA_KEY_PATH_PITCHMASTERS`). If a run
  fails with a missing-env error, that key path is wrong or the file is missing.

## Error handling

- If `deno task google` fails to connect (auth/key error): show the error and
  stop — do not attempt `--apply`.
- If a dry-run shows a surprising number of unmatched members, report it and ask
  the user before applying, rather than silently proceeding.
