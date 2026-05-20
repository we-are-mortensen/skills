# Mode A — Lo-Fi wireframe

**When**: starting a new page. The output is a grayscale, system-font, real-content wireframe whose purpose is to validate **structure, hierarchy, and content fit** — not visual polish.

Lo-fi has three entry paths. Identify which one applies, then follow its Phase 1. **Phase 2 is the same for all three.**

| Entry path | Designer brings | Phase 1 specifics |
|---|---|---|
| **A1 — From scratch (vibe-design)** | Page purpose + real content. No reference. | Propose 2–3 structural directions; designer picks one. |
| **A2 — From a hand-drawn sketch** | Sketch image + real content. | Read the sketch, transcribe the structure, map to atomic components. |
| **A3 — From a Figma URL** | Figma URL + (optional) real content. | Extract structure via Figma MCP; ignore Figma palette/fonts (lo-fi is grayscale). |

The fidelity is `lo` regardless of entry path. If the designer wants to skip lo-fi and go straight to hi-fi from a Figma URL, that's **Mode B** (`hi-fi.md`) — switch modes and ask for palette + fonts.

---

## Phase 1 by entry path

### A1 — From scratch (vibe-design)

The designer describes the goal in plain language; there is no concrete reference. The job is to **propose structure** collaboratively before building anything.

**Inputs**:
- **Page purpose** — e.g., "events listing for tech meetups", "member directory with search"
- **Real content** — copy, item lists, hierarchy, specific UI affordances the page must support
- **(Optional)** ambient direction — "feels like Eventbrite", "should feel calm and editorial"

If any of these is missing, ask. Don't invent content.

**Phase 1 steps**:
1. **Restate the brief** in one paragraph. Surface anything ambiguous.
2. **Propose 2–3 structural directions** (vibe-design). Each direction is a one-paragraph sketch in prose:
   - Top-to-bottom section list (hero, filters, grid, footer, etc.)
   - For each section: what it contains, how it sits in the page rhythm
   - Strengths and trade-offs of this direction
   - No styling decisions yet — just structure
3. **Designer picks a direction** (or asks for more options).
4. Proceed to the **Shared Phase 1 close-out** below.

### A2 — From a hand-drawn sketch + content

The designer provides a photo or scan of a sketch (typically referenced via `@<filename>` in chat) plus real content. The sketch is the structural blueprint.

**Inputs**:
- **Sketch image** — hand-drawn page layout. Whiteboard photo, napkin sketch, tablet drawing — anything legible.
- **Real content** — copy, items, hierarchy.

**Phase 1 steps**:
1. **Read the sketch image** (use the Read tool on the provided path). Transcribe what you see into a structural outline:
   - Top-to-bottom: list every distinct region in the sketch
   - For each region: position, relative size, what's inside (text block, image, list, form, etc.), any annotations the designer wrote
   - If anything is unclear, **ask** before guessing. A sketch with ambiguous regions is normal; surface the ambiguity rather than invent.
2. **Map regions to atomic components**:
   - "Top bar with logo + nav" → Header organism (Logo atom + NavItem molecules)
   - "Three cards in a row" → CardGrid organism (Card molecules)
   - "Sidebar with filters" → FilterSidebar organism, etc.
3. **Cross-check the content against the regions** — every piece of real content the designer provided should have a home in the sketch, and every region in the sketch should have content (or be flagged as a "TBD" the designer needs to fill).
4. Proceed to the **Shared Phase 1 close-out** below.

### A3 — From a Figma URL

The designer pastes a Figma URL. Lo-fi from Figma uses the **structure** from Figma but ignores its palette and fonts (those belong to hi-fi).

**Inputs**:
- **Figma URL** with a `fileKey` and `node-id`
- **(Optional) Real content** — if the Figma frame already has real text, use it; otherwise ask the designer to provide or confirm.

**Phase 1 steps**:
1. **Extract via Figma MCP** and save raw outputs to `temp-outputs/` inside the relevant component folder. Outputs are **reference only**; do not paste them directly into pages.
   - `mcp__figma__get_metadata` → `*-metadata.xml` (structure, measurements)
   - `mcp__figma__get_screenshot` → `*-screenshot-description.txt` (visual reference)
   - `mcp__figma__get_design_context` → `*-design-context.html` (best structural reference)
   - `mcp__figma__get_variable_defs` → `*-variable-defs.json` (capture for hi-fi later, but **do not apply** in lo-fi)
   - `mcp__figma__get_code_connect_map` → `*-code-connect-map.json` (check for existing component mappings)
2. **Read `*-design-context.html`** to identify the structure: what's a flex layout, what's a grid, where are the sections, what are the dimensions.
3. **Map Figma frames to atomic components**:
   - A "Card" frame in Figma → `Card` molecule
   - A grid of cards → CardGrid organism using `grid-standard`
   - Reuse existing atoms/molecules wherever the Figma structure matches; do not duplicate.
4. **Strip styling decisions**: convert Figma's colors and fonts into lo-fi neutrals (`--color-lo-*`) and the system font stack. Note the original palette/fonts in a comment for the future hi-fi pass:
   ```html
   <!-- hi-fi palette source: temp-outputs/*-variable-defs.json -->
   ```
5. **Content check**: if Figma had placeholder text and the designer hasn't provided real content, ask. Lo-fi still requires real content.
6. Proceed to the **Shared Phase 1 close-out** below.

---

## Shared Phase 1 close-out (all entry paths)

Regardless of how you got here, produce **one** plan as text in the chat. Do not modify any files yet.

0. **Scope check** — if `site-architecture.md` exists at the project root, look up the page being wireframed in its table. Three outcomes:
   - **Present** — note the route and the description; use them as constraints on the wireframe.
   - **Missing but the designer treats it as in-scope** — surface this and offer to add it to `site-architecture.md` as part of this work. Don't proceed without resolving — silent additions undermine the scope record.
   - **Architecture doc doesn't exist** — fine; the designer chose to discover structure as the project unfolds. Skip this check.
1. **Component list** — every organism the page needs, in stacking order. For each organism, list the molecules and atoms it composes.
2. **For every component**, mark one of:
   - ✅ **exists** — give the path
   - 🆕 **needs creating** — give the target tier + filename in the stack's naming convention (PascalCase `.astro` for Astro, kebab-case `.html` for Vite)
3. **Page route + template/layout**:
   - Astro: `src/pages/<route>.astro`; template from `src/components/templates/`
   - Vite: `src/views/<route>.html`; template from `src/components/templates/`
   - If no fitting template exists, propose creating one as part of this plan.
4. **Fidelity confirmation**: page sets `data-fidelity="lo"` on `<body>` (via the layout).
5. **STOP** — present the plan and wait for designer approval. Do not write files yet.

---

## Phase 2 — Build (same for all three entry paths)

Once the plan is approved:

1. **Create/update components** in the correct tier folders. Smallest first (atoms → molecules → organisms → templates → page). Reuse existing components wherever possible.
2. **Wrap every section in `container-fluid`**. Use `grid-standard` only where a grid layout is needed (and only with the 12-col system — see `../tokens-and-grid.md`).
3. **Tokens**:
   - Only `--color-lo-*` tokens for color (from `assets/lo-fi-tokens.css` — drop into app.css if not already present).
   - System font stack for typography. Do not import brand fonts in lo-fi (even if Figma provided them — they're saved for Mode B).
4. **Images**: grey placeholder boxes with explicit `aspect-ratio`:
   ```html
   <div
     class="bg-lo-placeholder aspect-[4/3] w-full rounded-md flex items-center justify-center"
     role="img"
     aria-label="<descriptive label of what will go here>"
   >
     <svg class="w-8 h-8 text-lo-text-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
       <path d="M3 16l5-5 4 4 3-3 6 6M3 4h18v16H3V4z"/>
     </svg>
   </div>
   ```
5. **A11y basics (lo-fi)**: semantic HTML elements, meaningful headings (one `<h1>`; no skipped levels), `alt` on every `<img>`, `<label>` on every form input, focusable controls are real buttons/links.
6. **No polish**: no shadows, gradients, animations, transitions, or hover micro-interactions. Flat, structural.
7. **Link the page**. The same turn that creates a page must add it to the site nav (see SKILL.md "Header, Footer, and the home placeholder"):
   - Append `<a href="/<slug>/">Label</a>` inside the `<!-- PAGES:START --> … <!-- PAGES:END -->` markers in `Header` and `Footer`. Never edit anything outside the markers.
   - If the placeholder home is still present (`<!-- placeholder home: true -->` in the project's index file), append the same link inside its `PAGES:START` / `PAGES:END` markers too.
   - **If this page IS the home** (route `/`, or the designer asks to wireframe `home` / `Home` / `index`): overwrite the placeholder index file (`src/pages/index.astro` for Astro, `src/views/index.html` for Vite) with the new home wireframe — dropping the `placeholder home: true` marker and its page-list — then prepend `Home → /` to the `PAGES` markers in `Header` and `Footer` if it isn't already there. From now on, page creation only updates `Header` and `Footer`.
8. **Build & dev**:
   - 🅐 Astro: `npm run build` then `npm run dev` (http://localhost:4321)
   - 🅥 Vite: `npm run build` then `npm run dev` (http://localhost:5173)
   Fix any build error before continuing.
9. **Hand off to designer for verification**. Print a short message:
   > Ready at `<dev URL>`. Please verify at **375 / 768 / 1024 / 1440** — check that the hierarchy holds, no horizontal scroll, content fits. Tell me what to adjust.

   Do not run Chrome MCP / Playwright / Claude for Chrome on your own. If the designer reports a visual bug *and asks for inspection*, then invoke browser tools — see SKILL.md "Visual validation".

---

## Iteration

The designer responds with notes — "this section should be above that one", "add a filter row", "the card should also show date". Apply notes inside Mode A (still lo-fi) until the designer says **"this is good, let's hi-fi it"** — at which point switch to Mode B (`hi-fi.md`).

If the designer wants to **change entry path mid-iteration** (e.g., "actually let me send you a Figma instead"), treat that as a fresh Phase 1: restart with the new entry path's steps, then reconcile the plan with whatever's already been built.

### Exploring 2+ structural alternatives → variants

If during iteration the designer asks for **alternative layouts of a single block** — "let me see this hero stacked vs split", "try the filters as a sidebar instead of a top row" — that's a structural variant exploration, not a structural rebuild. Stay in lo-fi, convert the block into a variant folder, and let the designer flip between options via the variant sidebar.

See `../variants.md` for the file convention and sidebar wiring. 2–4 variants per block is the useful range.

---

## Common pitfalls (apply to all entry paths)

- **Inventing content.** If a section needs copy the designer didn't provide, ask. Don't write filler.
- **Sneaking in brand colors.** Lo-fi is grayscale, full stop. Any color belongs to hi-fi — even when a Figma URL hands you a palette on a plate.
- **Adding hover/focus polish.** Save it for hi-fi. Lo-fi has only the bare focus-visible outline (browser default is fine).
- **Custom grids.** If a layout doesn't fit the 12-col grid, rethink the layout — don't fork the grid.
- **Building before approval.** Phase 1 stops; Phase 2 starts only after the designer signs off on the plan.

### Entry-path-specific pitfalls

- **A1 (from scratch)**: Jumping to a single structural direction without proposing alternatives. Vibe-design = exploration, even briefly. Two minutes of options beats a wrong commitment.
- **A2 (from sketch)**: Guessing at illegible regions. A photo of a whiteboard has blur, ambiguity, scribbles. Ask before assuming. Also: the sketch is the **structural** source; if the sketch shows colored highlights or shading, those are lo-fi-irrelevant — translate to grayscale.
- **A3 (from Figma)**: Forgetting that lo-fi ignores Figma's palette and fonts. Save them for hi-fi (note the source in a comment). Also: don't paste Figma's `design-context.html` directly — it's React+Tailwind reference code; adapt to the project's stack and atomic structure.
