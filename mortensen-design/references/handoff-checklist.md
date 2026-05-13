# Designer → Coder Handoff Checklist

Run this end-to-end when the designer says **"this is ready"**. A page or component is only handed off when every box ticks. If anything fails, stay in Phase 2 of the active mode, fix it, and re-run.

Coders integrate components with the CMS (swap real-content props / `locals` for CMS-driven data) and refine. They do not rewrite. Hand off code that respects that boundary.

---

## Structure

- [ ] Component lives at the correct path in the atomic structure (5 tiers, correct stack-specific filename convention — PascalCase `.astro` or kebab-case `.html`).
- [ ] All reused markup has been promoted to atoms/molecules/organisms (no copy-paste duplication).
- [ ] Component contract is explicit:
  - 🅐 Astro: typed `interface Props { … }` with sensible defaults; all optional props default-destructured.
  - 🅥 Vite: `locals:` comment block at the top of the partial documenting every expected key, type, and default; fallbacks for optional locals.
- [ ] Page uses a template from `components/templates/` or a layout from `layouts/` — pages are not free-form HTML.

---

## Layout

- [ ] Every section wrapped in `container-fluid`.
- [ ] `grid-standard` used only where a grid is needed; no custom grids (no `grid-cols-5`, no nested forks).
- [ ] Default Tailwind v4 breakpoints only (`sm` / `md` / `lg` / `xl` / `2xl` / `3xl`); no custom values.
- [ ] Mobile-first: default styles target mobile; prefixes add larger-screen behavior.

---

## Tokens

- [ ] No hardcoded hex colors in component files.
- [ ] No repeated raw pixel values (anything used 2+ times has been hoisted to `app.css @theme`).
- [ ] All tokens live in `app.css @theme`. No duplicate token files anywhere else.
- [ ] No leftover lo-fi tokens in hi-fi output (and vice versa).
- [ ] Project palette and fonts in `@theme` match what the designer provided (no carry-over from a previous project).

---

## Code quality

- [ ] `npm run build` passes without errors or warnings.
- [ ] `npm run dev` starts cleanly with no console errors.
- [ ] No `console.log` / `debugger` left in source.
- [ ] No inline `style="…"` attributes (except dynamic values that can't be expressed in classes).
- [ ] No `<style>` blocks unless absolutely necessary; Tailwind utilities first, tokens second.
- [ ] No TODO comments referencing CMS integration ("TODO: fetch this from CMS") — that's the coder's job; the designer hands off near-final markup with real content.

---

## Variants

If any block on the page has variants (folder with an entry + 2+ variant files — see `variants.md`):

- [ ] Every variant-bearing block has an **explicit `variant` value passed in by the page**. The entry's fallback is a safety net, not the handoff value.
- [ ] The chosen variant matches what the designer ratified in the most recent review (cross-check against the URL params in the final reviewed preview; the page props should match what the sidebar was showing).
- [ ] The entry's contract documents the available variants and notes the default in a comment (e.g., `default: split — chosen 2026-05-12 review`).
- [ ] Unused variant files remain in the folder — they are cheap to keep and useful for future iteration. No silent deletions.
- [ ] The sidebar is **inert in `npm run build` output**:
  - Grep the built HTML for `data-variant-key` — there should be **zero** matches (only the chosen variant renders in production, without the registry wrapper).
  - Grep the built HTML for `variant-sidebar` — zero matches (the sidebar markup and script are dev-gated).

---

## Hi-fi only

If the page is hi-fi (`data-fidelity="hi"`):

- [ ] Every box in `a11y-checklist.md` ticks (semantic HTML, contrast, focus-visible, keyboard, alt, labels, ARIA, reduced motion, target size, skip link).
- [ ] `prefers-reduced-motion` respected for any animation (`gsap.matchMedia()` or equivalent).
- [ ] Real images are optimized:
  - 🅐 Astro: `<Image />` component with explicit dimensions.
  - 🅥 Vite: `<img>` with explicit `width`/`height`, `loading="lazy"` (or `eager` + `fetchpriority="high"` above the fold), `decoding="async"`.
- [ ] GSAP / Three.js (if used) are lazy-loaded:
  - 🅐 Astro: `client:visible` on the island.
  - 🅥 Vite: dynamic `import()` triggered by `IntersectionObserver`.
- [ ] Three.js scenes have a static poster fallback.

---

## Visual

- [ ] Verified at **375 / 768 / 1024 / 1440** via Chrome MCP or Playwright MCP.
- [ ] No horizontal scroll at any breakpoint.
- [ ] No broken layouts or content overflow.
- [ ] Hover, focus, and active states all function and are visible on hi-fi.
- [ ] Animations (if any) start, complete, and don't loop indefinitely without user control.

---

## Content

- [ ] All content is real — provided by the designer, not invented.
- [ ] Placeholder strings, lorem ipsum, or "TBD" text have been replaced.
- [ ] All links resolve (or are clearly marked as routes the CMS will fill in).
- [ ] Images have meaningful filenames in `src/assets/` (or wherever the project keeps them).

---

## What the coder receives

- A working project that builds cleanly (`npm run build` green) in the chosen stack.
- Atomic components with explicit contracts (Astro typed props / posthtml `locals` blocks).
- An `app.css` with the project's tokens: lo-fi neutrals + project palette + project fonts.
- Real-content pages that demonstrate every component in use at hi-fi.
- A11y-clean hi-fi markup.
- Optional GSAP / Three.js scenes that are isolated and lazy-loaded.
- A short "what's hi-fi vs lo-fi in the repo" note in the PR / handoff message, plus any open design questions.

---

## Final sanity check before declaring done

Print a one-paragraph summary of what was handed off, listing:

- Stack and fidelity
- New components created (path + tier)
- Components reused (path)
- Variant-bearing blocks with the chosen variant per block (e.g., `Hero → split`, `CardGrid → masonry`)
- New tokens added to `app.css @theme`
- Any GSAP/Three.js work and where it lives
- Any items the designer flagged as "coder decides" (e.g., empty-state copy, error states)
- If `site-architecture.md` exists: which pages from the doc are handed off vs. still planned (and any pages added/dropped during this round so the doc reflects current scope)

The summary lets the coder pick up the work without re-reading every file.
