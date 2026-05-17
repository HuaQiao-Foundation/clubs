# Plan Document Format — Shape Up Pitch Template

All plan documents in `docs/plans/` written after 2026-05-17 use the Shape Up pitch shape. Derived from Basecamp's *Shape Up* (Ryan Singer, 2019).

## The solo-dev pitch workflow (CEO ↔ CTO)

The clubs monorepo is a one-person shop with an AI collaborator. The Shape Up bet/build cycle still applies; the roles just collapse. This is the canonical flow every pitch goes through:

1. **Shape** — CTO (or CEO) drafts a pitch in `docs/plans/YYYY-MM-DD-<slug>.md` using the template below. Status: `DRAFT`.

2. **Present** — CTO surfaces the pitch to CEO with a one-paragraph summary (problem · appetite · what's in · what's out) and a link to the full doc.

3. **Bet** — CEO reads, asks questions, either:
   - **APPROVES** → CTO flips status to `APPROVED YYYY-MM-DD — ready to execute`, adds or updates the item in `BACKLOG.md`, and starts work
   - **RESHAPES** → CEO names the specific change needed; CTO redrafts and re-presents
   - **DECLINES** → pitch moves to `docs/archive/plans/` with a one-line note on why; status becomes `DROPPED YYYY-MM-DD — <reason>`

4. **Build** — CTO executes, committing after each session. Sessions track against the appetite line in the pitch. If appetite is blown:
   - **Reshape** (preferred) — rewrite the pitch with a smaller scope, move the cut work to a *new* pitch or `BACKLOG.md`
   - **Drop** — archive the pitch, document what was learned
   - **Never** — extend the appetite to accommodate growth. That defeats the purpose of having one.

5. **Ship** — When the pitch's success criteria are met, CTO:
   - Marks the `BACKLOG.md` item as done
   - Writes a brief entry in the dev journal (`docs/dev-journal/`)
   - Notes any follow-up items for a future pitch or the backlog

6. **Archive** — On ship (or drop), CTO moves the pitch to `docs/archive/plans/` in the same commit that closes the work. The `/archive-prompts-plans` command handles the move cleanly.

## Where pitches live

| Folder | Contains | Status markers |
|---|---|---|
| `docs/plans/` | **Active only** — pitches you can act on today | `DRAFT` · `APPROVED` · `IN-FLIGHT` |
| `BACKLOG.md` | Shelved ideas and upcoming work — not yet shaped for execution | (backlog IDs, no pitch doc needed) |
| `docs/archive/plans/` | Completed or dropped — historical record | `DONE` · `DROPPED` · `SUPERSEDED` |

For work scoped to a single app, pitches may also live at `apps/georgetown/docs/plans/` or `apps/pitchmasters/docs/plans/` — use root `docs/plans/` when the work touches both apps or the monorepo structure.

Mental model: the root of `docs/plans/` should only ever hold pitches waiting for a bet or actively being built. Anything else is a context-switching tax.

## Pitch precheck (before declaring no-gos)

Before declaring a scope exclusion in a pitch (e.g., "X is out of scope because Y"), verify the premise empirically. Read the file, grep the pattern, check the component. Wrong premises cost more than precheck time.

Rule of thumb: every no-go bullet should be defensible with a one-liner shell command or a file read. If you can't name the command, the no-go isn't a no-go — it's an assumption.

## How to request a new pitch

CEO phrasing: *"CTO, draft a pitch for [thing]"* or *"CTO, shape [concern] as a pitch."* That's it. CTO will:
- Check the relevant app's `CLAUDE.md` and `BACKLOG.md` for existing context
- Check whether the work touches Georgetown, Pitchmasters, or both
- Write the pitch in 30–90 min
- Present with a summary for the bet

CEO does not need to provide the Problem/Appetite/Solution/Rabbit-holes/No-gos sections — CTO drafts those. CEO provides:
- The itch (what hurts, or what opportunity)
- Any appetite constraint ("one session", "this week", "small batch")
- Any no-gos they already know ("don't touch X")

## How CTO ensures pitches stay in shape

- **Session-start protocol**: CTO checks `docs/plans/` for drafts/approved pitches at the start of each conversation
- **Pitch format** (this file): the template enforces the five sections
- **App alignment**: every pitch cross-references which app(s) it touches and cites the relevant `CLAUDE.md` context — catches scope drift at draft time, not ship time
- **Benchmark discipline**: pitches for user-facing features cite at least one comparable product (Toastmasters app, Rotary apps, club management SaaS competitors) — forces "what are we stealing from whom" to be explicit

## The five sections

A pitch has exactly these five sections, in this order:

1. **Problem** — the raw need. What's broken or missing right now, in one paragraph. No solution language. If the problem can be stated in ≤3 sentences it probably isn't worth a plan doc.

2. **Appetite** — how much time the work is worth. Named in sessions or days, not in lines of code or story points. *"One session"* or *"small batch (≤1 day)"* or *"big batch (one week)"*. The appetite is a fixed budget; scope flexes to fit, not the reverse.

3. **Solution** — the shaped approach, at the level of breadboards or fat-marker sketches. Name the key elements and how they connect. Skip implementation detail the builder can figure out. Include a rough element list or ASCII sketch when the shape is spatial.

4. **Rabbit holes** — specific details the shaper has thought about and wants the builder to either avoid or handle a particular way. Named risks, not generic ones.

5. **No-gos** — explicit scope exclusions. Things a builder might reasonably assume are in-scope but aren't.

## Template

```markdown
# [Title] — Shape Up Pitch

**Status**: DRAFT | APPROVED [date] | IN-FLIGHT | DONE [date]
**App**: Georgetown | Pitchmasters | Both | Monorepo
**Owner**: CTO
**Appetite**: [e.g. "1 session (~2 hrs)" | "small batch (1 day)" | "big batch (1 week)"]
**Parent**: [path to parent pitch or backlog item ID, if any]

---

## Problem

[One paragraph — the raw need. What hurts today. No solution language.]

## Appetite

[e.g. "One session, roughly 2 hours. If it grows past that, reshape or drop."]

## Solution

[Shaped approach. Element list or sketch. Not a task list — the shape.]

## Rabbit holes

- [Named risk 1 + how to handle it]
- [Named risk 2 + how to handle it]

## No-gos

- [Explicit exclusion 1]
- [Explicit exclusion 2]

---

End of pitch.
```

## When NOT to use this shape

- **One-off session work** that takes an hour and is obvious in scope. Just do the work; no pitch needed.
- **Bug fixes** that are clearly defined. Add to `BACKLOG.md` and fix; no pitch doc needed.
- **ADRs** (`docs/adr/`) — architectural decision records document *why* a choice was made, not what to build.
- **Research or audits** — these explore a space rather than shape a build.

## Circuit-breaker rule

If a shaped project runs past its appetite, the default action is *reshape or drop* — **not extend**. A pitch that needs another week isn't a bigger version of the original pitch; it's a different pitch. Write a new one or put the work down.

## References

- Shape Up (Ryan Singer, 2019) — https://basecamp.com/shapeup
- Backlog management: `docs/backlog-management-system.md`
- Plans index: `docs/plans/README.md`
