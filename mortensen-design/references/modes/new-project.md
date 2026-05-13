# Mode N — New project kickoff

**When**: starting a brand-new project. The designer explicitly asks ("start a new project", "kick off a new project for `<client>`"), or `Step 0` in `SKILL.md` detected an empty `src/pages/` (Astro) / `src/views/` (Vite) with no `site-architecture.md` and the designer confirmed they want a kickoff.

The output of Mode N is a project that's **ready to wireframe** — stack scaffolded, atomic folders in place, `app.css` carrying the lo-fi tokens and grid/container utilities, BaseLayout wired with the fidelity switch, variant sidebar present (and dev-gated), `project-brief.md` and (optionally) `site-architecture.md` at the project root. The first page wireframe happens in Mode A immediately after.

**What's deliberately not gathered at kickoff**: brand palette, fonts, reference URLs. Those are hi-fi inputs and are gathered in Mode B when the designer is ready to upgrade a lo-fi. Don't ask for them in Mode N — they'll feel premature and the designer often hasn't decided yet.

---

## Phase 1 — Brief (conversational, no walls of questions)

Gather **only what's needed to start lo-fi work**. Ask in this order, **2–3 questions per turn at most** so the designer can answer naturally. Don't ask everything in one wall.

### Turn 1 — Project identity

- **Project name** — the canonical name. Used for `<title>`, `package.json` `name`, and the heading of `project-brief.md`. Ask for the exact casing the designer wants.
- **About** — 1–3 sentences. Who is the client? What does the site do? Who is it for? This anchors every later decision (is a page in scope, what tone does content suggest, etc.).

### Turn 2 — Stack

- **Stack** — `Astro` or `Vite + vanilla HTML + posthtml-include`. Default suggestion: **Astro**, unless the designer says otherwise or the project context implies Vite (e.g., "I need this in plain HTML"). Confirm before scaffolding.

### Turn 3 — Architecture entry path

- **Architecture** — does the designer have a site tree / sitemap ready?
  - If **yes**, ask which form: **D1** FigJam URL, **D2** PNG export, **D3** typed indented list, **D4** an existing site to crawl. Then hand off to Mode D (`architecture.md`) for the actual ingestion.
  - If **no, discover as we go**, fine — skip the architecture step entirely. Project will not have `site-architecture.md` until the designer decides to add one later (re-enter Mode D anytime).

### Things NOT to ask in Mode N

These come later, in the mode where they're actually used. Asking now is friction without payoff:

- **Brand palette / fonts** — Mode B gathers these when the first hi-fi starts.
- **Reference Figma URLs / inspiration sites** — Mode A or Mode B gathers these per page, when needed.
- **Audience / tone** — implicit in the "About" sentences; surface again only if the designer brings it up.
- **CMS target / i18n / deadlines** — out of scope for the design phase. The designer-to-coder handoff is when these get re-surfaced.

If the designer **volunteers** any of this up front, capture it in `project-brief.md` under an "Open notes" section — don't refuse it, but don't drag for it either.

---

## Phase 2 — Persist + scaffold

Once Phase 1 is gathered and confirmed, execute the scaffold in this order. Pause and confirm before running `npm` commands.

### 1. Write `project-brief.md` at the project root

Use this exact template — substitute the gathered values.

```markdown
# <Project Name>

Created: <YYYY-MM-DD>
Stack: <Astro | Vite + vanilla HTML + posthtml-include>

## About

<1–3 sentences from Phase 1, Turn 1.>

## Visual identity

To be defined at hi-fi kickoff (Mode B). The lo-fi pass uses grayscale neutrals
and the system font stack — no brand decisions required yet.

## References

To be added when the designer shares Figma URLs, inspiration sites, or mood
boards (typically at hi-fi kickoff).

## Open notes

<Anything the designer volunteered that doesn't fit elsewhere. Delete the
section if empty.>

---

See also:
- `site-architecture.md` (if it exists) — page list, routes, descriptions.
```

### 2. Architecture (if the designer brought one)

Hand off to Mode D's Phase 1 + Phase 2 (`architecture.md`). It will write `site-architecture.md` at the project root. Return here when done.

If the designer opted out of architecture, skip this step. Add one line to `project-brief.md` under "Open notes": `Architecture not yet defined — to be captured later via Mode D.`

### 3. Scaffold the stack

Confirm with the designer before running install commands. Then:

#### 🅐 Astro

```bash
# from project root
npm create astro@latest . -- --template basics --typescript strict --no-install --no-git --skip-houston
npm install
npm install -D tailwindcss @tailwindcss/vite
```

Then edit `astro.config.mjs` to include the Tailwind Vite plugin (`@tailwindcss/vite` — Tailwind v4):

```js
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  vite: { plugins: [tailwindcss()] },
});
```

#### 🅥 Vite

```bash
npm init -y
npm install -D vite tailwindcss @tailwindcss/vite vite-plugin-posthtml posthtml-include posthtml-expressions
```

Create `vite.config.ts` with multi-page input + posthtml plugin chain. The full shape lives in `../stacks/vite.md` — copy that scaffold and adapt the project root + `src/views/` path.

### 4. Create the atomic folder structure

Empty directories with `.gitkeep` (so they survive git):

```
src/
├── components/
│   ├── atoms/.gitkeep
│   ├── molecules/.gitkeep
│   ├── organisms/.gitkeep
│   ├── templates/.gitkeep
│   └── _dev/.gitkeep              # dev-only helpers (variant sidebar lives here)
├── layouts/
│   └── (BaseLayout.astro | base.html — see step 6)
├── pages/                          # Astro
│   └── (created by Mode A per page)
├── views/                          # Vite
│   └── (created by Mode A per page)
└── styles/
    └── app.css                     # see step 5
```

### 5. Write `src/styles/app.css`

Drop in this **starter** — lo-fi-ready, no project palette yet. Hi-fi will add palette + fonts to `@theme` later.

```css
@import 'tailwindcss';

/* Astro: */
@source "../components/**/*.astro";
@source "../pages/**/*.astro";
@source "../layouts/**/*.astro";

/* Vite (swap the above three for these): */
/* @source "../components/**/*.html"; */
/* @source "../views/**/*.html"; */
/* @source "../layouts/**/*.html"; */

@theme {
  --breakpoint-3xl: 100rem;

  /* Lo-fi neutrals — always present, used when [data-fidelity="lo"] */
  --color-lo-bg: #ffffff;
  --color-lo-surface: #f4f4f5;
  --color-lo-surface-2: #e4e4e7;
  --color-lo-border: #d4d4d8;
  --color-lo-text: #18181b;
  --color-lo-text-muted: #71717a;
  --color-lo-placeholder: #d4d4d8;

  /* Project palette — added at hi-fi kickoff (Mode B). Do not invent values. */
}

@utility container-fluid {
  @apply w-full px-4 md:px-8 2xl:px-16 3xl:px-[calc((100%+calc(var(--spacing)*32)-100rem)/2)];
}

@utility grid-standard {
  @apply grid grid-cols-8 gap-2 md:grid-cols-12 md:gap-4 lg:gap-6 xl:gap-8;
}

body[data-fidelity="lo"] {
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
               "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  color: var(--color-lo-text);
  background-color: var(--color-lo-bg);
}
```

Pick the right `@source` lines for the chosen stack and delete the other set.

### 6. Write the BaseLayout / base.html

Use the layout shape from the stack reference (`../stacks/astro.md` for Astro, `../stacks/vite.md` for Vite). Both include:

- `data-fidelity` attribute on `<body>` (default `"lo"`)
- Skip-link to `#main`
- `app.css` import / link
- Variant sidebar gate at the bottom of `<body>` — copy from `../variants.md` (Astro snippet or Vite snippet).

The layout is the single place the variant sidebar is wired. Pages never include it.

### 7. Copy the variant sidebar assets into the project

From this skill's `assets/`:

- `variant-sidebar.html` → `src/components/_dev/VariantSidebar.astro` (Astro) or `src/components/_dev/variant-sidebar.html` (Vite). Wrap the HTML in an Astro component declaration for Astro.
- `variant-sidebar.js` → `public/scripts/variant-sidebar.js` (both stacks).

The script is loaded via `<script src="/scripts/variant-sidebar.js" defer></script>` inside the same dev gate as the sidebar markup (already shown in `../variants.md`).

### 8. Verify

```bash
npm run dev
```

Open the dev URL (Astro 4321 / Vite 5173). The browser should render an empty page (no pages yet) without console errors. If errors, fix before declaring kickoff done.

`npm run build` should also succeed; run it to catch config typos early.

---

## Phase 3 — Hand off to Mode A

Print a summary that confirms what's ready and asks for the first page:

> Project **`<Project Name>`** is set up.
>
> - Stack: `<Astro | Vite>`, dev server: `<http://localhost:4321 | http://localhost:5173>`
> - `project-brief.md` written.
> - `site-architecture.md` <written with N pages | not yet defined>.
> - Atomic structure, lo-fi tokens, container-fluid, grid-standard, BaseLayout, variant sidebar — all wired.
>
> Ready to wireframe. Which page first?

The designer's answer is the trigger to switch to **Mode A** (`lo-fi.md`). Pass the page name, the route from `site-architecture.md`, and the description as starting context.

---

## Common pitfalls

- **Asking everything in one wall.** A 7-question kickoff is intimidating. Stick to the three turns: identity / stack / architecture. Defer the rest to the modes that actually need them.
- **Inventing brand details.** No palette, no fonts, no logos at lo-fi kickoff. If the designer volunteers some, capture them under "Open notes" but don't apply them — lo-fi is grayscale.
- **Scaffolding before confirming the stack.** Always pause for explicit "yes, Astro" / "yes, Vite" before running `npm create` / `npm install`. Half-scaffolded projects in the wrong stack are messy to unwind.
- **Hardcoding the project palette into the starter `app.css`.** The starter is intentionally palette-less. Hi-fi adds it later.
- **Skipping the dev-server verification.** A green `npm run dev` is the gate that the scaffold actually works. Don't hand off to Mode A on a broken setup.
- **Treating kickoff as a one-time, irreversible event.** Scope, architecture, and brand all change. `project-brief.md` is editable plain text. Update it when the project drifts; do not pretend it was right forever.
