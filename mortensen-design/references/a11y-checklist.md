# Hi-Fi Accessibility Checklist (WCAG AA)

Hi-fi is the final design that ships. Coders integrate exactly what is handed off, so accessibility cannot be "the coder's problem". A hi-fi page is **not** done until every box below passes.

Lo-fi inherits the semantic-HTML / alt-text / labels half of this list; lo-fi skips contrast (grayscale) and motion. The full list applies to hi-fi.

---

## Structure & semantics

- [ ] **Semantic HTML**: `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>` used for their intended purposes.
- [ ] **One `<h1>` per page**, and heading levels never skip (no `<h1>` → `<h3>`).
- [ ] **Landmarks**: every major region is either a landmark element or has an explicit `role="…"`.
- [ ] **Lists** (`<ul>` / `<ol>`) used for actual lists of items; not for layout.
- [ ] **Tables** (`<table>`) used only for tabular data, with `<th scope="…">` for headers.
- [ ] **Forms**: every input has an associated `<label>` (preferred) or `aria-label` / `aria-labelledby` when visually unlabeled. Required fields marked with `required` and visually indicated.

## Contrast & visibility

- [ ] **Text contrast**: ≥ 4.5:1 against background for body text; ≥ 3:1 for ≥ 18pt or bold ≥ 14pt. Verify via DevTools or:
  ```js
  // mcp__claude-in-chrome__javascript_tool
  () => {
    const el = document.querySelector('<selector>');
    const s = getComputedStyle(el);
    return { color: s.color, background: s.backgroundColor };
  }
  ```
- [ ] **Non-text contrast** (icons, form borders, focus rings): ≥ 3:1 against adjacent background.
- [ ] **Focus visible**: every interactive element has a `focus-visible` outline/ring meeting 3:1 contrast. Never `outline: none` without an equivalent replacement.
- [ ] **No information conveyed by color alone**: status, errors, and required indicators have a non-color cue (icon, text).

## Keyboard & interaction

- [ ] **Tab order is logical**: matches the visual reading order.
- [ ] **Every interactive control is reachable and operable by keyboard**: `Tab` to focus, `Enter`/`Space` to activate, `Esc` to dismiss dialogs.
- [ ] **No keyboard traps**: focus can always move out of any region.
- [ ] **Custom widgets** (carousels, menus, accordions): keyboard interactions follow [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/patterns/) (arrow keys for menus, etc.).
- [ ] **Target size**: interactive targets ≥ 24×24 CSS px (44 preferred for primary actions).

## Images & media

- [ ] **`alt` on every `<img>`**: meaningful for informative images, empty (`alt=""`) for decorative.
- [ ] **SVGs** that convey meaning have `<title>` + `role="img"` and `aria-labelledby`; decorative SVGs have `aria-hidden="true"`.
- [ ] **Background images** that convey information are mirrored as `<img>` or have an accessible name nearby.
- [ ] **Video / audio**: captions for video; transcripts for audio.

## ARIA & roles

- [ ] **ARIA only when semantic HTML cannot express the intent.** No `role="button"` on a `<button>`. No `role="navigation"` on a `<nav>`.
- [ ] **`aria-current="page"`** on the current nav link.
- [ ] **`aria-expanded`** on disclosure triggers (accordions, menus). Updates correctly when toggled.
- [ ] **Live regions** (`aria-live="polite"` or `assertive`) on parts of the page that update dynamically (toasts, form-validation messages).
- [ ] **No bogus roles** — every ARIA attribute follows the spec; invalid combos break screen readers.

## Motion & 3D

- [ ] **`prefers-reduced-motion: reduce`** is respected. GSAP uses `gsap.matchMedia()` so reduced-motion users get a static experience. Three.js scenes do not auto-play.
- [ ] **No motion infinite loops** without a pause control.
- [ ] **Three.js scenes** are lazy-loaded with a static poster fallback. The scene is keyboard-skippable.

## Navigation aids

- [ ] **Skip link**: a "Skip to main content" link is the first focusable element on pages with top navigation. Visible on focus.
- [ ] **Page `<title>`** is unique and describes the page.
- [ ] **`<html lang="…">`** is set correctly.
- [ ] **Breadcrumbs** (if present) use `<nav aria-label="Breadcrumb">` with `<ol>`.

## Verification tools

- **Chrome DevTools** → Lighthouse → Accessibility audit (target: 100).
- **Chrome MCP**:
  ```
  mcp__claude-in-chrome__navigate(url: "<page>")
  mcp__claude-in-chrome__javascript_tool(function: "<contrast check>")
  ```
- **Keyboard pass**: unplug the mouse; navigate the entire page with `Tab`, `Shift+Tab`, `Enter`, `Space`, arrows, `Esc`. Note any element you can't reach or activate.
- **Screen reader sanity check**: macOS VoiceOver (`Cmd+F5`); read the page top-to-bottom. Note any landmark that says "group" or "region" without a name.

---

## Failure modes that frequently sneak through

- A custom-styled `<div role="button">` that's not focusable (`tabindex="0"`) and doesn't respond to Enter/Space.
- Focus ring removed via `focus:outline-none` without a `focus-visible` replacement.
- Form inputs with placeholder-as-label — placeholder disappears on input.
- Icon-only buttons with no `aria-label`.
- Modal dialogs that don't trap focus or restore it on close.
- Color-only error states (red border, no icon or text).
- A pretty-but-low-contrast palette (light grey on white headings).

Catch these in Phase 2 of hi-fi, before declaring done.
