# Mode D — Site architecture

**Relationship to Mode N**: when the designer is starting a brand-new project end-to-end, use **Mode N (`new-project.md`)** — the kickoff umbrella that gathers the project brief, calls into the Phase 1 + Phase 2 of this file for the architecture portion, and scaffolds the stack. Use **Mode D directly (this file)** when the project is already scaffolded but the architecture was never captured, or when scope has shifted substantially mid-project and it's cleaner to redo the doc than patch it.

**When**: starting a new project (via Mode N), or revisiting scope mid-project (directly). The output is `site-architecture.md` at the project root — a structured page list (route, parent, short description) that anchors every subsequent Mode A / Mode B request to a known scope.

The architecture is a **starting point, not a contract**. Pages can be added, removed, or restructured later; the doc evolves with the project. But agreeing on the scope up front prevents drift and lets the skill confidently say "this is in scope" or "this isn't — should we add it?" when the designer brings work for a specific page.

This mode is **strongly suggested** when a new project is detected (empty `src/pages/` or `src/views/`, no existing `site-architecture.md`). Skip it only if the designer says they want to discover the structure as they go — and even then, offer to capture what's been built into a `site-architecture.md` later.

---

## Four entry paths

Identify which one applies, then follow its Phase 1. **Phase 2 is the same for all four.**

| Entry path | Designer brings | Phase 1 specifics |
|---|---|---|
| **D1 — FigJam URL** | A figma.com/board/... URL pointing at a tree map (connector-based or sticky-note + arrows). | Extract structure via `mcp__claude_ai_Figma__get_figjam`; transcribe nodes and edges into a hierarchy. |
| **D2 — PNG image** | A screenshot of the tree map (FigJam export, whiteboard photo, slide capture). | Read the image, transcribe the visible tree, ask before guessing on illegible regions. |
| **D3 — Typed indented list** | A markdown bullet list pasted directly in chat. | Parse as-is. Confirm route slugs. |
| **D4 — External website URL** | A URL to an existing site (theirs to redesign, or a competitor for inspiration). | Try `/sitemap.xml` first; fall back to Chrome MCP crawl of the nav. Treat result as a **starting proposal**, not the final scope. |

---

## Phase 1 by entry path

### D1 — FigJam URL

The designer pastes a FigJam URL. FigJam tree maps usually live at `figma.com/board/<fileKey>/...`.

**Inputs**:
- **FigJam URL** with a `fileKey` (and optionally a `node-id` if the tree is one specific frame within a larger board).

**Phase 1 steps**:
1. **Confirm it's a FigJam board** by URL shape (`figma.com/board/...`). If it's `figma.com/design/...`, that's a regular Figma file — still works via `get_design_context`, but the tree map convention is more reliably found on FigJam boards.
2. **Extract via Figma MCP**:
   - `mcp__claude_ai_Figma__get_figjam` with the original board URL passed as `figjamUrl`.
   - Optionally `mcp__claude_ai_Figma__get_screenshot` of the relevant frame as a sanity check — useful if the structured extraction looks sparse or ambiguous.
   - Save raw outputs to `temp-outputs/architecture/` at the project root for reference.
3. **Transcribe nodes and edges** into a hierarchy:
   - Each node = a page (or section). Each connector = a parent/child relation.
   - If the tree has nodes that aren't pages (e.g., "Auth flow", "Modals", "States") — flag them: ask the designer whether they're pages, components, or out of scope.
4. **Ambiguity check**: if the FigJam uses freeform drawing, sticky notes without connectors, or mixed layouts, surface the parts you couldn't parse confidently and ask before guessing.
5. Proceed to the **Shared Phase 1 close-out** below.

### D2 — PNG image

The designer drops a PNG (`@<path>` reference in chat) of the tree map.

**Phase 1 steps**:
1. **Read the image** with the Read tool on the provided path.
2. **Transcribe the visible tree**:
   - Top-to-bottom, left-to-right, or whatever flow the image follows. Don't guess at the convention — ask if the structure is ambiguous (e.g., trees with multiple roots, dotted lines, color-coded groupings).
   - Capture every legible label as a page name.
   - Note any annotations (arrows with labels, "v2", "stretch", "maybe") — they are scope signals, not page names.
3. **Ask before guessing** on illegible labels, faint connectors, or regions the designer's annotations suggest are uncertain.
4. Proceed to the **Shared Phase 1 close-out** below.

### D3 — Typed indented list

The designer pastes a markdown bullet tree directly:

```
- Home
  - About
    - Team
    - Press
  - Events
    - Upcoming
    - Past
  - Contact
```

**Phase 1 steps**:
1. **Parse the indentation** to determine the parent/child relationships. Two-space indents are common; the parser must be forgiving.
2. **Propose route slugs** for each page (default: kebab-case of the label, nested under the parent's route).
3. **Surface any ambiguities** — duplicate names at different levels, unusual characters, "TBD" entries.
4. Proceed to the **Shared Phase 1 close-out** below.

### D4 — External website URL

The designer points at an existing site as a starting proposal — typically because they're redesigning that site, or because a competitor's structure is close to what they want.

**Phase 1 steps**:
1. **Try `<url>/sitemap.xml` first** via WebFetch. Sitemaps are cheap, structured, and complete. Parse the URL list into a hierarchy by path depth.
2. **Fall back to Chrome MCP** if no sitemap exists or it's not useful:
   - Navigate to the home page.
   - Capture the visible nav (`mcp__claude-in-chrome__*` tools).
   - Follow top-level nav links one level deep to capture sub-navs.
   - Don't crawl exhaustively — the goal is the **intended** structure, which is usually visible in the top nav and footers.
3. **Treat the result as a starting proposal**, not the final scope. The designer almost always wants to trim, rename, or reorganize. Present what you found and ask: "what should I keep / drop / rename?"
4. Save raw outputs to `temp-outputs/architecture/` for reference.
5. Proceed to the **Shared Phase 1 close-out** below.

---

## Shared Phase 1 close-out (all entry paths)

Regardless of how you got the tree, produce **one** plan as text in the chat. Do not write `site-architecture.md` yet.

1. **Propose the page list** as a tree with proposed route slugs:
   ```
   - Home                /
     - About             /about
       - Team            /about/team
       - Press           /about/press
     - Events            /events
       - Past events     /events/past
     - Contact           /contact
   ```
2. **For each page**, ask (or propose, if you have enough context) **one short description** — a single sentence describing what the page does. Don't invent content; if you don't know, ask. Empty descriptions are fine if the designer wants to fill them later.
3. **Flag scope questions explicitly**:
   - Nodes that look like they might be components, not pages (e.g., "Search", "Cart").
   - Pages that conventionally exist but aren't in the tree (e.g., no 404, no privacy/terms).
   - Pages that might be CMS-driven children vs. discrete files (e.g., "Event detail" — one page template per event, or many static pages?).
4. **STOP** — present the plan and wait for designer confirmation. No file changes yet.

---

## Phase 2 — Persist

Once the plan is approved:

1. **Write `site-architecture.md` at the project root** using the format below. This is the canonical scope doc; every other mode reads it.
2. **Note the source** at the top of the doc (FigJam URL / PNG path / typed / external URL) so future updates know where it came from.
3. **Save raw FigJam / crawl outputs** in `temp-outputs/architecture/` if any were generated. They are reference-only; the canonical record is `site-architecture.md`.
4. **Do not scaffold page files yet** — Mode A creates page files when the designer is ready to wireframe each one. The architecture doc declares scope; Mode A delivers structure.

### `site-architecture.md` format

```markdown
# Site architecture — <Project>

Last updated: <YYYY-MM-DD>
Source: <FigJam URL | PNG @path | typed | crawl of <url>>

## Tree

- Home (`/`)
  - About (`/about`)
    - Team (`/about/team`)
    - Press (`/about/press`)
  - Events (`/events`)
    - Past events (`/events/past`)
  - Contact (`/contact`)

## Pages

| Route          | Parent     | Title       | Description                                              | Wireframe | UI    |
|----------------|------------|-------------|----------------------------------------------------------|-----------|-------|
| `/`            | —          | Home        | Landing page; hero + featured events + contact CTA.      | To do     | To do |
| `/about`       | `/`        | About       | Mission, story, leadership snapshot.                     | To do     | To do |
| `/about/team`  | `/about`   | Team        | Member directory with photo + bio.                       | To do     | To do |
| `/about/press` | `/about`   | Press       | Press releases and media kit.                            | To do     | To do |
| `/events`      | `/`        | Events      | Upcoming events grid with filters.                       | To do     | To do |
| `/events/past` | `/events`  | Past events | Archive of completed events.                             | To do     | To do |
| `/contact`     | `/`        | Contact     | Inquiry form + office locations.                         | To do     | To do |

The **Wireframe** and **UI** cells track progress per page. Three states each: `To do`, `Pending validation`, `Validated`. See SKILL.md "Page status" for the transition rules — Mode A and Mode B edit these cells; never edit them by hand unless re-baselining scope.

## Notes

- This is a starting scope. Pages can be added/removed/renamed as the project evolves; update this file when that happens.
- Out of initial scope (parked for later): <list anything the designer explicitly deferred>
- Open questions: <anything the designer flagged as TBD>
```

The **table** is the source of truth — every page the project will build has exactly one row. The **tree** is a human-readable companion; keep it in sync but don't treat it as authoritative.

The project's index page (Astro: `src/pages/index.astro`; Vite: `src/views/index.html`) reads this table and renders the Wireframe + UI statuses per row. See `../stacks/astro.md` and `../stacks/vite.md` ("Rich status index") for the scaffolds.

---

## How the rest of the skill uses this doc

Once `site-architecture.md` exists, every other mode reads it as a scope check:

- **Mode A (lo-fi)** — Phase 1 cross-references the page being wireframed against the table. If the page isn't there, the skill surfaces this as scope drift before any file work: *"`/blog` isn't in the architecture. Want to add it (I'll update `site-architecture.md`), or did you mean a page that is in scope?"*
- **Mode B (hi-fi)** — same check, plus: if a hi-fi page is being shipped, the description column is a useful reminder of what the page is supposed to communicate.
- **Mode C (promotion)** — no direct dependency; promotion is component-level, not page-level.
- **Handoff** — the final summary mentions which pages from `site-architecture.md` were handed off vs. still planned.

The doc is plain markdown so it stays diffable, readable, and editable by hand. Designers don't need to wait on the skill to update it — they can edit it directly.

---

## Updating the architecture mid-project

When the designer says "let's add `/blog`" or "the press page is dropping", they're updating the scope. Two options:

- **Inline update** — the skill edits `site-architecture.md` as part of the same conversation that created the new page (or before deleting one). Update the table, the tree, the "Last updated" date, and the notes section if relevant. New rows initialize `Wireframe` and `UI` to `To do`.
- **Re-run Mode D** — if the structural change is large (a whole section being added or reorganized), it's cleaner to re-enter Mode D with the updated input rather than patching the doc piecemeal. Same workflow, same close-out.

Either path is valid. Choose based on the size of the change.

---

## Common pitfalls

- **Inventing pages.** If the FigJam has a "Maybe?" sticky or the typed list ends with "more TBD", don't fill it in. Leave it as a flagged open question and let the designer decide.
- **Treating the doc as frozen.** It's a snapshot, not a contract. When scope shifts, update it — don't argue against the change because the doc says otherwise.
- **Conflating pages and components.** A FigJam node called "Search" might be a header molecule, not a page. Ask. The architecture doc is for routable pages.
- **Crawling exhaustively in D4.** External-URL trees are starting proposals. A full deep crawl produces noise; the top-nav + one level deep is usually enough.
- **Skipping the descriptions.** A bare route table tells you nothing about what the page is *for*. The one-line description is what makes the doc useful in Mode A — it anchors the wireframe's content.
- **Scaffolding empty page files in Phase 2.** Mode D records scope; Mode A creates files. Empty stubs accumulate stale TODOs and break `npm run build` if their imports aren't wired. Wait until the designer is ready to wireframe each one.
