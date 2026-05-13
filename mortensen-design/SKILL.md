---
name: mortensen-design
description: Designer-first workflow for producing lo-fi wireframes and hi-fi components in Astro or Vite+HTML projects. Generates pages and components with strict atomic structure (atoms/molecules/organisms/templates/pages), Tailwind v4 tokens from app.css, mandatory container-fluid and the 12-col grid-standard utility, WCAG AA accessibility on hi-fi, and CMS-ready handoff. Use this skill whenever the user wants to create, iterate, or promote wireframes / components / pages — including phrases like "create a lo-fi for…", "wireframe a new page", "hi-fi this page", "turn this into a hi-fi", "vibe-design this hero", "make a component out of this", "promote this to an atom", "extract this into a molecule", or any request to build pages / sections / components in this mockup project. Lo-fi wireframes can start from three entry paths — (1) from scratch via collaborative vibe-design, (2) from a hand-drawn sketch image plus real content ("wireframe this sketch", "turn this drawing into a lo-fi"), or (3) from a Figma URL ("lo-fi from this Figma", "wireframe this Figma frame in grayscale"). Also use when the user provides real content and asks for a page, when the user shares a Figma URL or website reference for hi-fi inspiration, or when an existing lo-fi needs to evolve toward final design. Even if the user does not explicitly say "lo-fi" / "hi-fi" / "wireframe", use this skill whenever they ask to build, design, or restructure any page or component in this project.
---

# mortensen-design — Wireframes & Hi-Fi Workflow

Designer-first workflow for the Mortensen-style mockup projects. Designers author **lo-fi wireframes** and **hi-fi designs** as near-final components, validate them in-browser, and hand the result to coders for CMS integration.

This skill is a router. The core file (this one) sets the non-negotiables that apply everywhere. Mode-, stack-, and concern-specific details live in `references/`; load them on demand once you know which mode and stack are active.

---

## Step 1 — Confirm three things up front

Before touching any file, state these back to the designer in one short message and wait for confirmation. Do not assume — even when a clue is present, confirm.

1. **Stack** — `Astro` or `Vite + vanilla HTML + posthtml-include`
   - If `package.json` exists, infer from `dependencies` / `scripts` and ask the designer to confirm.
   - If no stack is set up yet, ask before scaffolding.
2. **Fidelity** — `lo` or `hi`
   - First wireframe of a page → almost always `lo`.
   - "Make this final / production / pretty / branded" → `hi`.
   - Hi-fi requires designer-provided palette + fonts before starting.
3. **Mode** — A, B, or C (see below)

Confirmation message template:

> Stack: **<Astro | Vite>**. Fidelity: **<lo | hi>**. Mode: **<A | B | C>** — <one-line mode description>. Confirm before I plan.

---

## Step 2 — Pick the mode

| Mode | When it applies | Load |
|---|---|---|
| **A — Lo-Fi wireframe** | Starting a new page. Three entry paths: **A1** from scratch (vibe-design the structure), **A2** from a hand-drawn sketch image + content, **A3** from a Figma URL (structure only — palette/fonts ignored for lo-fi). | `references/modes/lo-fi.md` |
| **B — Hi-Fi vibe-design** | A validated lo-fi exists; the designer wants to evolve it into the final visual design. May incorporate Figma URLs or external website references as inspiration. | `references/modes/hi-fi.md` |
| **C — Component promotion** | Inline markup should be reused; a molecule is doing too much and should be split; an organism turns out to be page-specific and should be inlined. | `references/modes/promotion.md` |

Read **only the relevant mode file**. Do not preload all three.

---

## Step 3 — Load the active stack reference

Once the stack is confirmed, read its reference once and follow it for syntax, file paths, naming, build commands, and stack-specific component patterns.

- 🅐 **Astro** → `references/stacks/astro.md`
- 🅥 **Vite + HTML + posthtml-include** → `references/stacks/vite.md`

The atomic structure and fidelity rules are identical across stacks; only syntax differs.

---

## Non-negotiables — apply to every mode, every stack

These rules don't change. Internalize them once.

### Atomic 5-tier structure (Brad Frost)

```
src/components/atoms/        — Button, Input, Badge, Icon, Avatar, Tag, Divider
src/components/molecules/    — SearchBar, Card, NavItem, FormField, Pagination
src/components/organisms/    — Header, Footer, EventGrid, Hero, FilterBar
src/components/templates/    — PageShell, DashboardLayout, ArticleLayout
src/pages/  (Astro)  |  src/views/  (Vite)   — concrete pages with real content
src/layouts/                 — HTML doc shell that imports app.css
src/styles/app.css           — single source of truth for tokens
```

**Promotion rule**: when something is used in 2+ places, promote it to the appropriate tier. Never duplicate markup.

### container-fluid is mandatory; grid-standard only when a grid is needed

- Every organism / template section / page section MUST wrap in `container-fluid`.
- Use `grid-standard` only when laying out columns. The grid is **fixed at 8 cols mobile / 12 cols from `md:` up**. **Never create a custom grid with a different column count.**
- For non-grid layouts (vertical stacks, flex rows, single columns), use `container-fluid` alone with Tailwind flex / spacing utilities.

```html
<section class="container-fluid">
  <div class="grid-standard">
    <article class="col-span-8 md:col-span-8">…</article>
    <aside   class="col-span-8 md:col-span-4">…</aside>
  </div>
</section>
```

### Default Tailwind v4 breakpoints only, mobile-first

`sm` 640 · `md` 768 · `lg` 1024 · `xl` 1280 · `2xl` 1536 · `3xl` 1600 (set in app.css). **No custom breakpoints.** Default styles target mobile; prefixes add larger-screen behavior.

### app.css is the only home for tokens

- ❌ Never hardcode hex colors in component files.
- ❌ Never hardcode raw pixel values for anything reused.
- ✅ Use Tailwind utilities backed by tokens (`text-ink`, `bg-silk-cream`).
- ✅ For one-off values, use arbitrary syntax referencing a token (`w-[var(--hero-min-width)]`).
- ✅ Add new tokens to app.css `@theme` when a value is reused 2+ times.

Token discipline + grid details: `references/tokens-and-grid.md`.

### Lo-fi vs hi-fi

| | Lo-fi | Hi-fi |
|---|---|---|
| Colors | Grayscale neutrals only (`--color-lo-*`) | Designer-provided palette (project-specific each time) |
| Typography | System font stack | Designer-provided brand fonts |
| Images | Grey placeholder boxes with explicit aspect-ratio | Real imagery |
| Content | **Real content (always provided by designer)** | Real content |
| Polish | Flat — no shadows, gradients, animations, hover micro-interactions | Shadows, hover/focus states, micro-interactions, GSAP/Three.js when justified |
| A11y | Semantic HTML + alt text + labels | All of lo-fi **plus** WCAG AA (see `references/a11y-checklist.md`) |

The fidelity switch is `data-fidelity="lo"` / `data-fidelity="hi"` on `<body>`. The same component source serves both.

**Hi-fi tokens are project-specific.** Do not carry palette/fonts between projects. At the start of every hi-fi session the designer provides them and the `@theme` block in app.css is updated to match.

Lo-fi token CSS to drop into app.css: `assets/lo-fi-tokens.css`.

---

## Phase discipline (every mode)

Every mode has the same two-phase shape.

**Phase 1 — Plan (read-only)**
- Restate the brief in one paragraph.
- List the organisms needed and which atoms/molecules each requires.
- For each component, state **exists** (path) or **needs creating** (target tier + filename in the stack's naming convention).
- Confirm the page route and which template/layout it will use.
- Confirm fidelity mode.
- **STOP and wait for designer approval.** No file changes yet.

**Phase 2 — Build**
- Create/update components in the correct tier folders following all non-negotiables.
- Run `npm run build` (catch errors) then `npm run dev`.
- Visual-check at 375 / 768 / 1024 / 1440 via Chrome MCP or Playwright MCP.
- For hi-fi: run the A11y checklist before declaring done.

---

## When to load more

- A11y review or hi-fi handoff verification → `references/a11y-checklist.md`
- Token discipline, container-fluid / grid-standard edge cases → `references/tokens-and-grid.md`
- "Is this ready for the coder?" → `references/handoff-checklist.md`
- Animation work → invoke `gsap-skills:gsap-core` (and `gsap-timeline` / `gsap-scrolltrigger` / `gsap-performance` as needed). Always respect `prefers-reduced-motion` via `gsap.matchMedia()`.
- 3D / WebGL → Three.js, lazy-load only, provide a static poster fallback.
- New page brainstorming → `superpowers:brainstorming`.

---

## What NOT to do

- ❌ Skip Phase 1. No "I'll just build it real quick."
- ❌ Hardcode hex colors or pixel values in component files.
- ❌ Create custom grids — use `grid-standard` (8 cols mobile / 12 from `md:` up) or no grid at all.
- ❌ Introduce custom breakpoints.
- ❌ Carry brand tokens between projects — hi-fi palette + fonts are designer-provided each time.
- ❌ Touch CMS integration or wire data — that is the coder's job after handoff.
- ❌ Add `<style>` blocks or inline `style="…"` attributes unless absolutely necessary (dynamic values that can't be expressed in classes are the only exception).
- ❌ Trigger JS alerts/confirms when validating in Chrome MCP — they block all further tool calls.

---

## Designer → coder handoff

When the designer says "this is ready", run `references/handoff-checklist.md` end-to-end. A page or component is only handed off when every box ticks; otherwise call out what's missing and stay in Phase 2.

Coders integrate components with the CMS (swap real-content props/locals for CMS-driven data) and refine. They do not rewrite. Hand off code that respects that boundary.
