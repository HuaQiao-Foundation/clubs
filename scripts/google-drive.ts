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
interface ClubConfig {
  name: string;
  envKey: string;
  aliases: Record<string, string>;
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
  default:
    console.error(`Unknown command: "${command}"`);
    showHelp();
    Deno.exit(1);
}
