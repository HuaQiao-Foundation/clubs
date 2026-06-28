# Pitch Hardening Rounds — a 4+1-angle review framework for Shape Up pitches

> Companion to `.claude/rules/plan-format.md`. That file defines the pitch *shape*
> (the five sections) and the *workflow* (shape → present → bet → build → ship → archive).
> This file defines how a **DRAFT** pitch is hardened *before* it goes to the bet.

**Adopted**: 2026-06-29 (ported from the Brandmine framework, adapted for the clubs monorepo's solo-dev CEO ↔ CTO flow)
**Owner**: CEO (runs the rounds) · CTO (drafts, then answers R1–R4) · independent reviewer (R5)
**Why it exists**: Every draft, when challenged 4–5 times from different angles, surfaces gaps,
contradictions, and anomalies that produce a stronger pitch to bet on. This framework makes that
challenge repeatable instead of ad hoc — four CTO rounds, each from a deliberately different
angle, plus an optional fifth **independent** round.

Two principles run through it:
- **Different angles, not repetition.** Each round has a distinct lens so the rounds find
  *different* classes of gap rather than re-finding the same one. This is **triangulation** —
  four angles fanning out onto the same object — not a single root-cause drill.
- **Push past the symptom.** When a round surfaces a finding, don't stop at its surface form; ask
  what assumption sits *beneath* it. (This is the one useful kernel of 5-whys — depth, not the
  literal recursive chain. The rounds fan out; they don't drill a single thread.) The place this
  matters most is the **R4 → R5 handoff**, where R4 names the one root assumption all rounds keep
  returning to and the independent reviewer pressure-tests it from outside.
- **Verification scales with blast radius — the reshape gate.** A finding that merely *adds a
  rabbit hole* needs ordinary rigor. A finding that *reshapes the pitch* — inverts its frame,
  changes its appetite, deletes or adds a phase — must be **re-derived from the primary artifact
  before the reshape is written**, not after. If the finding is a factual claim about how code
  behaves (e.g. "component X renders Y in context Z", "this route feeds that display", "this
  Supabase column drives that filter"), read the artifact top-to-bottom and quote the specific
  lines that prove it. The asymmetry is the whole point: cheap findings get cheap checks;
  pitch-inverting findings get proof. A confident-but-false root that reshapes a whole pitch is the
  single most expensive error this framework exists to catch — and self-review is structurally the
  worst at catching it, which is why R5 exists.

---

## Round 0 — Is this pitch ready to harden? *(a 60-second gate, not a round)*

Don't spend rounds on a draft too thin to reward them. Before Round 1, confirm the pitch has all
five sections filled with *content*, not placeholders — a stated Problem, a named Appetite, a
Solution with actual shape, and at least a first attempt at Rabbit holes and No-gos. If any
section is a stub, **reshape the draft first** — hardening an empty Solution just produces "write
the Solution" as a finding four times over. A pitch that can't pass Round 0 isn't ready for
review; it's ready for more drafting.

## How to run it

- Run each round as its **own turn**. Fold the findings into the pitch, then run the next round.
  Do **not** batch rounds into one prompt — that collapses the angle-switching that makes each
  round find something new.
- **Name a deepest finding per round.** Close each round by naming its single deepest finding —
  the one most likely to be a symptom of something beneath it. These don't chain mechanically
  (the rounds fan out, they don't drill one thread), but the set of them feeds R4, which distils
  the one **root assumption** the whole pitch rests on and hands it to R5.
- **Capture as you go.** Append a one-line entry per round to the pitch's `## Hardening log`
  (format below). The log makes the rigor visible at bet time and survives into the archive — a
  pitch that shows its hardening earns more trust than one that merely asserts it.
- **Three CTO rounds is the floor.** Round 4 (pre-mortem) is mandatory when the appetite is
  ≥1 week **or** the change is hard to reverse. Round 5 (independent) is the independence break — see below.
- The rounds escalate: inward (is the pitch coherent?) → outward (is it right for *this* repo?)
  → against (is it the right move at all?) → forward (what breaks when we build it?) →
  **independent** (what can the author structurally not see?).
- This sequence is deliberate. Don't audit blast radius (Round 2) until the Solution actually
  solves the Problem (Round 1) — no point mapping coverage of an incoherent Solution.

| Round | Run by | Lens | Direction | Catches |
|---|---|---|---|---|
| 1 — Internal consistency | CTO | Self-contradiction | Inward | Drifted Solution, under-budgeted Appetite, undefined load-bearing terms, unverified premises |
| 2 — Coverage / blast radius | CTO | The fixup tail | Outward (repo) | Places the change must land that the pitch ignored |
| 3 — Adversary / red-team | CTO | Wrong move | Against | Over-engineering, simpler alternatives, fragile load-bearing assumptions, second-order harm |
| 4 — Build-reality / pre-mortem | CTO | What breaks | Forward | Appetite-blow risks, builder misunderstandings, fuzzy stop conditions, the follow-up tail |
| 5 — Independent review | **fresh eyes** | What the author can't see | Outside | Blind spots, motivated reasoning, strategic-fit drift, the gap self-review structurally misses |

---

## Round 1 — Internal-Consistency Pass *(does the pitch contradict itself?)*

```text
Review this pitch for internal contradictions and structural gaps only — do not yet judge whether it's a good idea. Walk the five sections in order and check each against the others:
- Does the Solution actually solve the Problem as stated, or has it drifted to solve an adjacent problem?
- Does the Appetite match the true size of the Solution? Cost the Solution honestly in sessions and tell me if it's under-budgeted.
- Do any Rabbit holes or No-gos silently contradict something the Solution depends on? (e.g. a no-go that excludes work the Solution needs.)
- Is anything load-bearing in the Solution left undefined — a term, a file, a component, a data shape, a Supabase table/column, an owner?
- Flag every claim stated as fact that isn't yet verified. List them as a precheck queue.
- If the pitch claims the Problem has one cause and the Solution touches one site: is that claim verified, or assumed? Name the upstream steps that produce the artifact the Solution fixes — could any of those steps also carry the wrong value?

Output: a numbered list of contradictions, undefined load-bearing elements, and unverified premises. Then name the single deepest finding — the one most likely to be a symptom of a deeper problem. No fixes yet — just the holes.
```

Ties to the standard's **Pitch precheck** rule: every no-go (and every factual claim) should be
defensible with a one-liner shell command. Round 1's precheck queue is where those get named.

## Round 2 — Coverage / Blast-Radius Pass *(what does this touch that the pitch doesn't mention?)*

```text
This pitch changes a rule/convention/schema/field/component/route. Run a coverage audit against the actual repo, not the pitch's description of it. Specifically:
- Read every file the pitch names. Then grep for the primary entities (table names, component names, type names, field names, route paths) to discover unlisted consumers. Enumerate every place the change must land: shared types, React components, hooks, routes, Supabase migrations/RLS policies, both apps if it touches shared conventions (Georgetown AND Pitchmasters), skills/slash-commands that teach the rule, and config/data files.
- For each, state: encodes the rule? needs change? owner?
- Probe the known failure modes: intra-file duplication (does any single file encode the rule more than once — a primary path + a fallback?); cross-layer divergence (is the same rule encoded in more than one place — a TS type, a Zod schema, a Supabase column constraint, a UI validation — so they can drift independently?); and teaching docs (does any CLAUDE.md, skill, or how-to doc prescribe a concrete value that will re-teach the old rule?).
- For a monorepo change: does this touch only one app, or both? If a convention lives in both apps/georgetown and apps/pitchmasters, enumerate both.
- Then tell me honestly: which discovered locations belong in scope for this appetite, and which are documented "known, not now"? (Inventory ≠ commitment.)
- For any finding based on a grep result, read the matched file directly to confirm before recording it as a finding. A grep line number from a multi-file result can appear to belong to the wrong file — verify by opening it.
- **Invocation ≠ behavior.** For any claim that component X "does Y in context Z" inferred from X being *invoked* in Z — read X's **body**, not just the call site. A component rendered unconditionally can still gate its data behind an internal conditional; a function called can early-return; a route registered doesn't mean the handler runs; a validator invoked can no-op on a flag. The call site proves the callee is *reached*, never what it *does*.

Output: the coverage checklist + an explicit in-scope / deferred split. Flag if the Appetite can't survive the true blast radius. Name this round's deepest finding.
```

Skip this round only if the pitch is a genuine single-site change (the standard's coverage-audit
trigger: *"if I change this, is there more than one file that has to agree?"* — if no, skip).

## Round 3 — Adversary / Red-Team Pass *(argue against your own pitch)*

```text
Take the strongest possible opposing position — argue against this pitch as a skeptical reviewer who thinks it's the wrong move. (If a prior round's deepest finding hints the whole approach is wrong rather than just incomplete, start there.)
- What's the simplest alternative that gets 80% of the value for 20% of the work? Why didn't the pitch choose it?
- Where is the pitch over-engineering — building for a future case that may never arrive?
- Does the Solution's proposed mechanism match the target component's actual type and data shape — or was it copied from an analogue that stores data differently? (A common component-level over-engineering failure: a pattern lifted from a free-string field applied to a FK/enum-bound field, or vice versa. Read the target file if R2 didn't already.)
- If the Solution proposes inline code inside a skill/slash-command file: is the mechanism described as if it executes mechanically, or as what it actually is — an instruction the CTO reads and decides to follow? A skill is not a shell script. `exit 1` in a skill is a signal to stop, not a gate that enforces stopping. Does the pitch's prose make the stop condition explicit?
- What assumption, if false, collapses the whole pitch? Name the single most load-bearing assumption and how we'd test it cheaply before betting.
- Who/what does this pitch make worse — a workflow, a future pitch, a user, the other app, an existing convention? (Second-order effects.)
- If we ship this and it's wrong, how hard is it to reverse? Is the bet appropriately sized to its reversibility? (A Supabase migration with data loss is harder to reverse than a component refactor.)

Output: the strongest case against approving. If the pitch survives, it's stronger; if it doesn't, better now than mid-build. Name this round's deepest finding.
```

## Round 4 — Build-Reality / Pre-Mortem Pass *(fast-forward: it's done and it went sideways)*

```text
Assume it's [appetite] later and the build blew past its appetite or shipped something subtly wrong. Write the post-mortem and work backward:
- What was the most likely reason the appetite was blown? Is that risk named as a Rabbit hole? If not, add it.
- Where would a builder reasonably misunderstand the Solution and build the wrong thing? Is that boundary a No-go? If not, add it.
- What's the first concrete step a builder takes — and is everything they need to take it actually present in the pitch (file paths, component names, data shape, the verify one-liner)?
- **Temporal placement**: for every check, gate, migration, or preflight the Solution introduces — does it run at a point where the thing it checks can actually exist? Name the preconditions. A gate that runs before its target resource (a Supabase table, a built artifact, a deployed route) is created always fails or always passes trivially, regardless of whether the logic is correct. This is a sequencing question, not a logic question — and R1 won't catch it because the pitch may be internally consistent while still being wrong about when the target system is ready.
- Is the success criterion stated sharply enough that we'll know unambiguously when to stop? (Shape Up: scope flexes, appetite is fixed — can this pitch actually be reshaped, or is it all-or-nothing?)
- **Inherited vs. verified root.** Before you build on the root R3 named, ask: is it a *verified fact* or an *inherited assumption*? If R4 is accepting R3's root without independent evidence — especially if that root already reshaped the pitch — name what single observation would falsify it and spend five minutes trying to disprove it (read the artifact, run the one-liner). Two rounds agreeing on an unchecked claim is one error counted twice, not two confirmations. Convergence should *lower* your confidence until the shared root is independently checked, then raise it once it survives.
- What's the small tail of follow-up work this will leave, and is it captured?

Convergence check before naming the root: if R3's deepest finding and R4's emerging root are the same assumption, that is convergence — but convergence is *confirmation only after the root has been verified once against the artifact* (see the inherited-vs-verified probe above). If the shared root is verified, do not re-argue it; pivot R4's remaining energy entirely to build-reality (appetite blow, builder misunderstandings, fuzzy stop condition, follow-up tail). If it has *not* been independently checked — and it reshaped the pitch — verifying it IS R4's highest-value work.

Output: revised Rabbit holes + No-gos, a sharpened success criterion, and the follow-up tail. Name the root finding — the single assumption all four rounds keep returning to — **stated as a falsifiable proposition with its cheapest disproof attached**, not as a topic. Not "the speaker-display assumption" but "*the speaker card reads from pm_meetings, not pm_speakers* — disprove by reading the SpeakerCard component's query." Hand R5 the *test*, not just the area to look at.
```

Ties to the standard's **Circuit-breaker rule**: a pitch that can't be reshaped to fit its
appetite is all-or-nothing, which is a Round-4 red flag, not a Round-4 finding to wave through.

## Round 5 — Independent Review *(the independence break — first non-author eyes)*

**This is the most important round, and it is categorically different from R1–R4.**

Rounds 1–4 are all the *author* (CTO) critiquing the author's own pitch. That has a structural
blind spot: the shaper can't see the assumption they didn't know they made, can't red-team the
framing they're attached to, and will rate their own Appetite generously. R5 is the **independence
break**: the first reviewer who isn't the author.

In this solo-dev shop there is no COO role, so the independent reviewer is **fresh eyes from a
clean context** — whoever runs R5 must *not* have authored or hardened the pitch. The mechanism
matters less than the independence, but in practice there are three ways to get it, in rough order
of how reliably they deliver true independence:

1. **Spawn a fresh subagent** (the default, and what works best for code-grounded pitches). The
   CTO launches a `general-purpose` (or `Explore`) agent that has *not* seen the drafting or the
   hardening conversation, and hands it **only** the hardened pitch + the R5 prompt below. Because
   the agent starts from a clean context, it genuinely re-derives the root from the primary files
   rather than inheriting the author's reading. This is the closest thing to Brandmine's COO break
   that a one-person shop has — and it scales: the agent reads the actual code, runs the disproof,
   and returns a verdict. *(Proven on the 2026-06-29 knowledge-base-wiki run: a fresh subagent ran
   the falsifiable root's disproof cold against `RichTextEditor.tsx` + `package.json` and
   **falsified it** — the four self-review rounds had kept the same question framed as an open
   toss-up the code already settled.)*
2. **A new Claude Code / Claude Console session** the CEO opens separately and pastes the pitch into.
3. **The CEO reading it cold** — weakest as a *disproof* engine (a human won't run the one-liner),
   but strongest at the premise/strategic-fit questions a subagent can't judge.

For a code-behavior root (most clubs pitches), prefer (1) — it's the only option that reliably
*runs the disproof*. For a strategic-fit or premise root, (3) complements it. The CEO hands over
the hardened pitch (with its `## Hardening log`), and the reviewer reads it cold and answers:

```text
You are reviewing a Shape Up pitch the CTO has already hardened through four self-review rounds (the ## Hardening log shows what each round found). Your job is the one thing four rounds of self-review structurally cannot do: catch what the author can't see.
- The root finding in the log is [root], stated as a falsifiable proposition with a named disproof. **Run that disproof yourself first** — read the artifact, run the one-liner — before reading the CTO's resolution. If the root is a factual claim about how code behaves, verify it against the primary file (its body, not its call site); do not accept the CTO's reading of it. A reshaped pitch built on an unverified root is the single highest-value thing this round catches. If the root survives your disproof, then pressure-test the CTO's *resolution* of it from outside.
- What assumption is so baked into the framing that none of the four rounds even questioned it? (The rounds challenge the Solution; you challenge the premise.)
- Does this pitch actually serve the goal, or is it locally sensible but strategically off? (Self-review optimizes the pitch; you judge whether it's the right pitch.)
- Where has the CTO been generous with its own Appetite or optimistic about reversibility?
- Is there a class of risk — UX, data-integrity, cross-app, user-facing — the CTO's framing simply doesn't have the vantage to see?

Output: an independent verdict — APPROVE / RESHAPE (name the change) / DECLINE — plus the one thing the four self-review rounds missed.
```

**When R5 is required vs. optional:**
- **Required** (blocking): big-batch pitches (≥1 week), anything hard to reverse (Supabase
  migrations with data loss, destructive changes, auth/RLS changes), anything touching both apps
  or a shared monorepo convention.
- **Optional**: small-batch, easily-reversible, single-app pitches where the CTO's own lens is the
  relevant one and R1–R4 already converged cleanly.

**Making the optional/required call explicit.** Before running R5, answer three questions:
(1) Is the appetite ≥1 week? (2) Is the change hard to reverse? (3) Does it touch both apps or a
shared convention? If all three are No, record `R5 optional — [criteria met]` in the hardening log
and proceed to bet. The explicit record means "skipped R5" is a decision, not an omission.

---

## Convergence — when to stop

You are not obligated to run all five rounds, nor forbidden from stopping early. **Stop hardening
when any of these is true:**
- A round surfaces **nothing materially new** — the well is dry.
- Every finding across the rounds **traces back to one root assumption**, and that assumption has
  been either resolved or accepted with eyes open.
- The pitch has been **reshaped or dropped** — a pitch that fails Round 3 hard doesn't need
  Round 4; reshape it and, if the reshape is substantial, restart from Round 1.

**Mid-sequence convergence (R3 → R4)**: if R3's deepest finding and R4's emerging root name the
same assumption, convergence has arrived one round early — **but only if that root has been
verified once against the artifact** (R4's inherited-vs-verified probe). A verified shared root is
confirmed: R4 should not re-argue it; pivot fully to build-reality. An *unverified* shared root
that reshaped the pitch is the danger case — there, verifying it is R4's highest-value move,
because two rounds agreeing on an unchecked claim is one error counted twice.

Conversely, **don't stop short** of the floor (three CTO rounds) just because early rounds were
quiet — a clean R1 often means R2's coverage audit hasn't been run yet, where the real tail hides.

## The Hardening log (lives in the pitch)

Append this section to the pitch during hardening. One line per round — the angle, the deepest
finding, and what changed. This is the artifact that proves the rigor and carries into the archive.

```markdown
## Hardening log

- **R1 (consistency)** — [deepest finding] → [what changed in the pitch]
- **R2 (coverage)** — [deepest finding] → [in-scope / deferred split recorded]
- **R3 (red-team)** — [deepest finding] → [alternative considered / assumption tested]
- **R4 (pre-mortem)** — [root finding] → [rabbit holes + No-gos + success criterion sharpened]
- **R5 (independent, [date])** — [the thing self-review missed] → [verdict: APPROVE / RESHAPE / DECLINE]

# When R5 is skipped (use this variant instead of leaving the line blank):
- **R5 (independent)** — optional, skipped — appetite <1 week · reversible · single-app
```

---

## References

- `.claude/rules/plan-format.md` — pitch shape, workflow, precheck, circuit-breaker
- Shape Up (Ryan Singer, 2019) — https://basecamp.com/shapeup
- Backlog management: `docs/backlog-management-system.md`

End of framework.
