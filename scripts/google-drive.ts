#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-net
/**
 * Google Drive & Sheets CLI — multi-club support
 *
 * Provides programmatic access to Google Drive and Sheets for each club
 * in the monorepo, using per-club GCP service accounts.
 *
 * Usage:
 *   deno task google -- <club> <command> [args]
 *
 * Clubs:
 *   georgetown (gt)      RC Georgetown
 *   pitchmasters (pm)    Pitchmasters Toastmasters Club
 *
 * Commands:
 *   list-files [folder-alias|id]          List files in a Drive folder
 *   list-sheets <sheet-alias|id>          List tabs in a spreadsheet
 *   read-sheet <sheet-alias|id> "<tab>"   Read a sheet tab (TSV output)
 *   download <file-id> [output]           Download a file
 *
 * Examples:
 *   deno task google -- gt list-files club-folder
 *   deno task google -- pm list-sheets member-directory
 *   deno task google -- georgetown read-sheet attendance-roster "Dashboard"
 */

import { JWT } from "npm:google-auth-library@9";
import { google } from "npm:googleapis@144";
import { parse as parsePath } from "https://deno.land/std@0.224.0/path/mod.ts";

// --- Club configuration ---

/**
 * A sync job copies one column from a canonical source sheet into a destination
 * sheet, matching rows by a composite name key (preferred/rotary name + last name)
 * rather than by position — the two sheets are sorted differently. A single field
 * may sync across several tab-pairs (e.g. both "Active Members" and "Honorary
 * Members"), since their column layouts differ.
 */
interface SyncEndpoint { alias: string; tab: string; keyCols: [string, string]; valueCol: string }
interface SyncPair { source: SyncEndpoint; dest: SyncEndpoint }
type SyncJob = SyncPair[];

interface ClubConfig {
  name: string;
  envKey: string;
  aliases: Record<string, string>;
  syncs?: Record<string, SyncJob>;
}

const CLUBS: Record<string, ClubConfig> = {
  georgetown: {
    name: "RC Georgetown",
    envKey: "GOOGLE_SA_KEY_PATH_GEORGETOWN",
    aliases: {
      "member-directory": "1SVlgSKCQ0oWx0tfOjGTYidltsSYbKLPs_1uVVooNPvw",
      "member-master": "1GNhFF7syJKFUgonEdxk4hKH4i8dZIfqc5GD-h0Weqo8",
      "attendance-roster": "1L2MpF-TN8JW80DJUrSZiqZ_SmErbS52FqTobKS71f2s",
      "club-folder": "1tXvyP8KdLl7gHLBNAf3-JsK5CwRtmYCt",
      "bod-folder": "1LmW-VuJM_tmbWRN2olp0sHlEI8V7V05y",
      "minutes-folder": "1N0vKcV2KZA2e9yfoMiiOv14exOPgf6O-",
    },
    // member-master (canonical) → member-directory, matched by name.
    // Key cols differ per tab/sheet because layouts differ:
    //   Master  Active:   A=Preferred, B=Last  | Honorary: A=Preferred, B=Last
    //   Dir     Active:   A=Rotary,    D=Last  | Honorary: B=Preferred, C=Last
    syncs: {
      // Master G→Dir K (Active); Master G→Dir H (Honorary)
      birthday: [
        { source: { alias: "member-master", tab: "Active Members", keyCols: ["A", "B"], valueCol: "G" },
          dest:   { alias: "member-directory", tab: "Active Members", keyCols: ["A", "D"], valueCol: "K" } },
        { source: { alias: "member-master", tab: "Honorary Members", keyCols: ["A", "B"], valueCol: "G" },
          dest:   { alias: "member-directory", tab: "Honorary Members", keyCols: ["B", "C"], valueCol: "H" } },
      ],
      // Email (primary): Master H → Dir H (Active) / Dir F (Honorary)
      email: [
        { source: { alias: "member-master", tab: "Active Members", keyCols: ["A", "B"], valueCol: "H" },
          dest:   { alias: "member-directory", tab: "Active Members", keyCols: ["A", "D"], valueCol: "H" } },
        { source: { alias: "member-master", tab: "Honorary Members", keyCols: ["A", "B"], valueCol: "H" },
          dest:   { alias: "member-directory", tab: "Honorary Members", keyCols: ["B", "C"], valueCol: "F" } },
      ],
      // Mobile: Master J → Dir J (Active) / Dir G (Honorary)
      mobile: [
        { source: { alias: "member-master", tab: "Active Members", keyCols: ["A", "B"], valueCol: "J" },
          dest:   { alias: "member-directory", tab: "Active Members", keyCols: ["A", "D"], valueCol: "J" } },
        { source: { alias: "member-master", tab: "Honorary Members", keyCols: ["A", "B"], valueCol: "J" },
          dest:   { alias: "member-directory", tab: "Honorary Members", keyCols: ["B", "C"], valueCol: "G" } },
      ],
      // Classification: Master Active T / Honorary S → Dir G (Active) / Dir E (Honorary)
      classification: [
        { source: { alias: "member-master", tab: "Active Members", keyCols: ["A", "B"], valueCol: "T" },
          dest:   { alias: "member-directory", tab: "Active Members", keyCols: ["A", "D"], valueCol: "G" } },
        { source: { alias: "member-master", tab: "Honorary Members", keyCols: ["A", "B"], valueCol: "S" },
          dest:   { alias: "member-directory", tab: "Honorary Members", keyCols: ["B", "C"], valueCol: "E" } },
      ],
      // Company: Master Active U / Honorary T → Dir L (Active) / Dir I (Honorary)
      company: [
        { source: { alias: "member-master", tab: "Active Members", keyCols: ["A", "B"], valueCol: "U" },
          dest:   { alias: "member-directory", tab: "Active Members", keyCols: ["A", "D"], valueCol: "L" } },
        { source: { alias: "member-master", tab: "Honorary Members", keyCols: ["A", "B"], valueCol: "T" },
          dest:   { alias: "member-directory", tab: "Honorary Members", keyCols: ["B", "C"], valueCol: "I" } },
      ],
    },
  },
  pitchmasters: {
    name: "Pitchmasters Toastmasters",
    envKey: "GOOGLE_SA_KEY_PATH_PITCHMASTERS",
    aliases: {
      "member-directory": "1TlT3DRid9MHQEOb8IS1jauwIerXFIyage_ofKv70Gnk",
      "member-master": "13rvddxL0qdhMthlzzBeV9eJgmx2WX6b0PALstvpqOv4",
      "club-folder": "1ndj6dlV529bTn4b1XubxR04XRhk1g5IF",
      "meetings-folder": "1A3HKm80q6_-023FexZ_a87ZR-Yb4qtmW",
      "documents-folder": "1WZoolkfT1cuI3F0tu19J4zlzspb7dJG1",
      "assets-folder": "1nXpd8Hmo0F7G0wiB__2Cym0WddCNVaUB",
      "exco-folder": "1L0xc2mgN7_LB_t_a1yq836MKmKIKfrpW",
    },
  },
};

const CLUB_SHORTCUTS: Record<string, string> = {
  gt: "georgetown",
  pm: "pitchmasters",
};

function resolveClub(input: string): ClubConfig | null {
  const key = CLUB_SHORTCUTS[input] ?? input;
  return CLUBS[key] ?? null;
}

function resolveId(club: ClubConfig, input: string): string {
  return club.aliases[input] ?? input;
}

// --- Auth ---
async function getAuthClient(club: ClubConfig): Promise<JWT> {
  const keyPath = Deno.env.get(club.envKey);
  if (!keyPath) {
    console.error(`Error: ${club.envKey} env var not set.`);
    console.error(`Add it to .env:`);
    console.error(`  ${club.envKey}=/path/to/service-account-key.json`);
    Deno.exit(1);
  }

  const keyJson = JSON.parse(await Deno.readTextFile(keyPath));
  const auth = new JWT({
    email: keyJson.client_email,
    key: keyJson.private_key,
    scopes: [
      "https://www.googleapis.com/auth/spreadsheets",
      "https://www.googleapis.com/auth/drive",
    ],
  });
  return auth;
}

// --- Commands ---

async function listFiles(club: ClubConfig, folderId: string) {
  const auth = await getAuthClient(club);
  const drive = google.drive({ version: "v3", auth });

  const res = await drive.files.list({
    q: `'${folderId}' in parents and trashed=false`,
    fields: "files(id, name, mimeType, size, modifiedTime)",
    orderBy: "name",
  });

  const files = res.data.files ?? [];
  if (files.length === 0) {
    console.log("No files found.");
    return;
  }

  console.log(`[${club.name}] Found ${files.length} files:\n`);
  const maxName = Math.max(...files.map(f => (f.name ?? "").length), 4);
  console.log(`${"Name".padEnd(maxName)}  ${"Type".padEnd(40)}  ${"Modified".padEnd(20)}  ID`);
  console.log(`${"─".repeat(maxName)}  ${"─".repeat(40)}  ${"─".repeat(20)}  ${"─".repeat(40)}`);
  for (const f of files) {
    const name = (f.name ?? "").padEnd(maxName);
    const type = (f.mimeType ?? "").padEnd(40);
    const mod = (f.modifiedTime ?? "").substring(0, 19).padEnd(20);
    console.log(`${name}  ${type}  ${mod}  ${f.id}`);
  }
}

async function listSheets(club: ClubConfig, sheetId: string) {
  const auth = await getAuthClient(club);
  const sheets = google.sheets({ version: "v4", auth });

  const res = await sheets.spreadsheets.get({ spreadsheetId: sheetId });
  const tabs = res.data.sheets ?? [];

  console.log(`[${club.name}] Spreadsheet: ${res.data.properties?.title}\n`);
  console.log(`${"Tab".padEnd(30)}  ${"Rows".padEnd(8)}  ${"Cols".padEnd(8)}  Sheet ID`);
  console.log(`${"─".repeat(30)}  ${"─".repeat(8)}  ${"─".repeat(8)}  ${"─".repeat(12)}`);
  for (const tab of tabs) {
    const props = tab.properties;
    const name = (props?.title ?? "").padEnd(30);
    const rows = String(props?.gridProperties?.rowCount ?? "").padEnd(8);
    const cols = String(props?.gridProperties?.columnCount ?? "").padEnd(8);
    console.log(`${name}  ${rows}  ${cols}  ${props?.sheetId}`);
  }
}

async function readSheet(club: ClubConfig, sheetId: string, tabName: string) {
  const auth = await getAuthClient(club);
  const sheets = google.sheets({ version: "v4", auth });

  const res = await sheets.spreadsheets.values.get({
    spreadsheetId: sheetId,
    range: tabName,
  });

  const rows = res.data.values ?? [];
  for (const row of rows) {
    console.log(row.join("\t"));
  }
}

const colToIndex = (col: string) =>
  [...col.toUpperCase()].reduce((n, c) => n * 26 + (c.charCodeAt(0) - 64), 0) - 1;

async function syncOnePair(
  sheets: ReturnType<typeof google.sheets>,
  club: ClubConfig,
  syncName: string,
  pair: SyncPair,
  apply: boolean,
): Promise<number> {
  const sourceId = resolveId(club, pair.source.alias);
  const destId = resolveId(club, pair.dest.alias);

  const read = async (id: string, tab: string) => {
    const res = await sheets.spreadsheets.values.get({ spreadsheetId: id, range: `${tab}!A2:AZ` });
    return res.data.values ?? [];
  };
  const srcRows = await read(sourceId, pair.source.tab);
  const dstRows = await read(destId, pair.dest.tab);

  const key = (row: string[], cols: [string, string]) =>
    `${(row[colToIndex(cols[0])] ?? "").trim()}|${(row[colToIndex(cols[1])] ?? "").trim()}`;

  const srcVal = colToIndex(pair.source.valueCol);
  const lookup = new Map<string, string>();
  for (const r of srcRows) {
    const k = key(r, pair.source.keyCols);
    if (k !== "|") lookup.set(k, (r[srcVal] ?? "").trim());
  }

  const dstVal = colToIndex(pair.dest.valueCol);
  const updates: { row: number; name: string; from: string; to: string }[] = [];
  const unmatched: string[] = [];
  dstRows.forEach((r, i) => {
    const k = key(r, pair.dest.keyCols);
    if (k === "|") return; // blank row
    if (!lookup.has(k)) { unmatched.push(k.replace("|", " ")); return; }
    const to = lookup.get(k)!;
    const from = (r[dstVal] ?? "").trim();
    if (to !== "" && to !== from) {
      updates.push({ row: i + 2, name: k.replace("|", " "), from, to }); // +2: skipped header + 0-index
    }
  });

  console.log(`  ${pair.source.tab}: ${pair.source.alias}.${pair.source.valueCol} → ${pair.dest.alias}.${pair.dest.valueCol}`);
  if (updates.length === 0) {
    console.log(`    already in sync.`);
  } else {
    console.log(`    ${updates.length} cell(s) ${apply ? "updated" : "to update"}:`);
    for (const u of updates) {
      console.log(`      ${pair.dest.valueCol}${u.row}  ${u.name.padEnd(28)}  "${u.from}" → "${u.to}"`);
    }
  }
  if (unmatched.length) {
    console.log(`    ${unmatched.length} not found in source (skipped): ${unmatched.join(", ")}`);
  }

  if (apply && updates.length > 0) {
    await sheets.spreadsheets.values.batchUpdate({
      spreadsheetId: destId,
      requestBody: {
        valueInputOption: "RAW",
        data: updates.map(u => ({ range: `${pair.dest.tab}!${pair.dest.valueCol}${u.row}`, values: [[u.to]] })),
      },
    });
  }
  return updates.length;
}

async function syncField(club: ClubConfig, syncName: string, opts: { apply: boolean }) {
  // "all" runs every configured sync in turn.
  const names = syncName === "all" ? Object.keys(club.syncs ?? {}) : [syncName];
  if (names.length === 0 || (syncName !== "all" && !club.syncs?.[syncName])) {
    console.error(`Unknown sync: "${syncName}". Available: ${Object.keys(club.syncs ?? {}).join(", ") || "(none)"}, all`);
    Deno.exit(1);
  }

  const auth = await getAuthClient(club);
  const sheets = google.sheets({ version: "v4", auth });

  let total = 0;
  for (const name of names) {
    const job = club.syncs![name];
    console.log(`\n[${club.name}] sync "${name}" (by name):`);
    for (const pair of job) {
      total += await syncOnePair(sheets, club, name, pair, opts.apply);
    }
  }

  if (!opts.apply) {
    console.log(`\nDry run — ${total} cell(s) would change. Re-run with --apply to write.`);
  } else {
    console.log(`\n✓ Done — ${total} cell(s) written.`);
  }
}

async function downloadFile(club: ClubConfig, fileId: string, outputPath?: string) {
  const auth = await getAuthClient(club);
  const drive = google.drive({ version: "v3", auth });

  const meta = await drive.files.get({ fileId, fields: "name, mimeType, size" });
  const fileName = meta.data.name ?? "download";
  const mimeType = meta.data.mimeType ?? "";

  let destPath = outputPath ?? fileName;

  const exportTypes: Record<string, string> = {
    "application/vnd.google-apps.document": "application/pdf",
    "application/vnd.google-apps.spreadsheet": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.google-apps.presentation": "application/pdf",
  };

  let data: ArrayBuffer;
  if (exportTypes[mimeType]) {
    const exportMime = exportTypes[mimeType];
    const res = await drive.files.export(
      { fileId, mimeType: exportMime },
      { responseType: "arraybuffer" }
    );
    data = res.data as ArrayBuffer;
    if (!outputPath) {
      const ext = exportMime.includes("spreadsheet") ? ".xlsx" : ".pdf";
      destPath = parsePath(fileName).name + ext;
    }
  } else {
    const res = await drive.files.get(
      { fileId, alt: "media" },
      { responseType: "arraybuffer" }
    );
    data = res.data as ArrayBuffer;
  }

  await Deno.writeFile(destPath, new Uint8Array(data));
  console.log(`[${club.name}] Downloaded: ${destPath} (${new Uint8Array(data).length} bytes)`);
}

// --- CLI ---
const rawArgs = Deno.args.filter(a => a !== "--");
const [clubArg, command, ...args] = rawArgs;

function showHelp() {
  const clubList = Object.entries(CLUBS).map(([key, c]) => {
    const shortcuts = Object.entries(CLUB_SHORTCUTS)
      .filter(([, v]) => v === key)
      .map(([k]) => k);
    const shortcut = shortcuts.length ? ` (${shortcuts.join(", ")})` : "";
    return `  ${key}${shortcut}`.padEnd(28) + c.name;
  }).join("\n");

  const aliasList = Object.entries(CLUBS).map(([key, c]) => {
    const lines = Object.keys(c.aliases).map(a => `    ${a}`).join("\n");
    return `  ${c.name}:\n${lines}`;
  }).join("\n\n");

  console.log(`Google Drive & Sheets CLI — Multi-Club

Usage: deno task google -- <club> <command> [args]

Clubs:
${clubList}

Commands:
  list-files [folder-alias|id]          List files in a Drive folder
  list-sheets <sheet-alias|id>          List tabs in a spreadsheet
  read-sheet <sheet-alias|id> "<tab>"   Read a sheet tab (TSV output)
  download <file-id> [output]           Download a file
  sync <field|all> [--apply]            Sync field(s) master → directory by name (dry-run by default)

Aliases:
${aliasList}

Examples:
  deno task google -- gt list-files club-folder
  deno task google -- gt list-sheets member-directory
  deno task google -- pm list-sheets member-directory
  deno task google -- georgetown read-sheet attendance-roster "Dashboard"
  deno task google -- pitchmasters download <file-id> ./output.pdf
`);
}

if (!clubArg || !command) {
  showHelp();
  Deno.exit(clubArg ? 1 : 0);
}

const club = resolveClub(clubArg);
if (!club) {
  console.error(`Unknown club: "${clubArg}". Use one of: ${Object.keys(CLUBS).join(", ")}`);
  Deno.exit(1);
}

switch (command) {
  case "list-files": {
    const folderId = resolveId(club, args[0] ?? "club-folder");
    await listFiles(club, folderId);
    break;
  }
  case "list-sheets": {
    if (!args[0]) { console.error("Usage: list-sheets <sheet-alias-or-id>"); Deno.exit(1); }
    await listSheets(club, resolveId(club, args[0]));
    break;
  }
  case "read-sheet": {
    if (!args[0] || !args[1]) { console.error('Usage: read-sheet <sheet-alias-or-id> "<tab>"'); Deno.exit(1); }
    await readSheet(club, resolveId(club, args[0]), args[1]);
    break;
  }
  case "download": {
    if (!args[0]) { console.error("Usage: download <file-id> [output-path]"); Deno.exit(1); }
    await downloadFile(club, args[0], args[1]);
    break;
  }
  case "sync": {
    if (!args[0]) {
      console.error(`Usage: sync <field> [--apply]   (available: ${Object.keys(club.syncs ?? {}).join(", ") || "none"})`);
      Deno.exit(1);
    }
    await syncField(club, args[0], { apply: args.includes("--apply") });
    break;
  }
  default:
    console.error(`Unknown command: "${command}"`);
    showHelp();
    Deno.exit(1);
}
