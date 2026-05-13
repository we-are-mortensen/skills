# Mode B — Hi-Fi vibe-design (lo-fi → hi-fi)

**When**: a validated lo-fi exists and the designer wants to iterate it into the final visual design. The hi-fi pass may incorporate Figma URLs or external-website references as inspiration.

The output is the final design ready for CMS integration: project-specific palette + fonts, real imagery, shadows / hover / focus states, WCAG AA accessibility, and optionally GSAP motion or Three.js scenes.

---

## Required inputs

Hi-fi is **strictly downstream** of a lo-fi. It cannot start without a lo-fi HTML file in the project, plus a project-specific palette and fonts. Confirm all three before any work:

1. **Lo-fi source path** (required) — the exact file the designer wants upgraded:
   - 🅐 Astro: `src/pages/<route>.astro` (whole page) or `src/components/<tier>/<Name>.astro` (single component)
   - 🅥 Vite: `src/views/<route>.html` (whole page) or `src/components/<tier>/<name>.html` (single component)

   **Validation gate**: read the file. If it doesn't exist or the path is wrong, stop and ask the designer for the correct path. If the file exists but contains no `data-fidelity="lo"` marker and no `--color-lo-*` token usage, surface that — it may not actually be a lo-fi and the upgrade may need to start from Mode A instead.

2. **Project palette** (required) — hex values with semantic names (e.g., `--color-brand-primary: #…`). Project-specific; do not assume any defaults from a previous project.

3. **Project typography** (required) — font families (display, body, mono if needed) and a type scale.

4. **(Optional) References** — Figma URL(s), external website URL(s), screenshots, mood boards. These inform direction, not structure.

If any of (1)/(2)/(3) is missing, ask. Don't infer a palette from a Figma reference unless the designer explicitly says "use the Figma palette" — references are inspiration, not specification.

### What "the lo-fi" can be

- **A whole page** — most common. The page file plus all the components it transitively uses are upgraded together.
- **A single organism / molecule / atom** — when promoting one piece in isolation. The wider page may stay lo-fi; only the targeted component goes hi-fi (uncommon but legitimate during exploration).
- **A set of pages** — multiple lo-fi files at once. Treat as one Phase 1 (one direction proposal that covers all of them) so the visual language stays coherent.

---

## Phase 1 — Reference gathering & direction (read-only)

1. **Update `app.css` `@theme` block** with the designer-provided palette and fonts. **Replace** any prior project palette — do not keep tokens from a previous project. Add font imports if needed (in app.css or the HTML head).
2. **If Figma references provided**: extract via Figma MCP and save raw outputs to `temp-outputs/` inside the relevant component folder. Outputs are **reference only** — do not paste them directly:
   - `mcp__figma__get_variable_defs` → `*-variable-defs.json`
   - `mcp__figma__get_metadata` → `*-metadata.xml`
   - `mcp__figma__get_screenshot` → `*-screenshot-description.txt`
   - `mcp__figma__get_design_context` → `*-design-context.html`
   - `mcp__figma__get_code_connect_map` → `*-code-connect-map.json`
3. **If external URL references provided**: capture via Chrome MCP (`mcp__claude-in-chrome__*`). Take screenshots at desktop + mobile widths and a DOM snapshot. Save under `temp-outputs/`. Don't trigger JS dialogs.
4. **Propose 2–3 visual directions** for the page, each with:
   - A one-paragraph rationale (mood, hierarchy, intent)
   - Specific tokens it would use (palette + typography)
   - Any motion / WebGL ideas (GSAP via `gsap-skills:*`, Three.js — only when justified)
5. **STOP** — the designer picks a direction (or asks for more options). Do not write files until a direction is chosen.

---

## Phase 2 — Build the chosen direction

Components stay the same; styles and motion change. Do not restructure unless the direction explicitly demands it.

1. **Switch the layout's body attribute** to `data-fidelity="hi"`.
2. **Apply the chosen direction**: replace `--color-lo-*` references with project palette tokens; replace system font stack with brand fonts via Tailwind utilities (`font-display`, `font-body`, `font-mono`).
3. **Replace grey placeholders with real imagery**:
   - 🅐 Astro: use the `<Image />` component for optimization.
   - 🅥 Vite: use `<img>` with `loading="lazy"` and explicit `width`/`height` to prevent CLS.
4. **Apply shadows, gradients, hover/focus states** consistent with the direction. Use existing `--shadow-*`, `--radius-*`, `--ease-*` tokens; add new ones in `@theme` when reused.
5. **A11y is mandatory** — run every box in `../a11y-checklist.md`. Hi-fi is not done until each one passes.
6. **Animations** (optional, when the direction calls for them):
   - Invoke the relevant gsap skill **before** writing GSAP code: `gsap-skills:gsap-core` for the basics, plus `gsap-timeline`, `gsap-scrolltrigger`, `gsap-plugins`, `gsap-performance` as needed.
   - Wrap effects in `gsap.matchMedia()` so `prefers-reduced-motion: reduce` users get a static experience.
   - Animate transforms and opacity only. Avoid animating properties that trigger layout (width, top, etc.).
7. **3D / WebGL** (optional, only when clearly justified — a hero scene, an interactive showcase):
   - 🅐 Astro: render the Three.js island with `client:visible`.
   - 🅥 Vite: dynamic `import()` triggered by an `IntersectionObserver`.
   - Provide a static poster image as a fallback. Lazy-load all Three.js modules.
8. **Build & visual-validate**:
   - `npm run build` (fix any errors)
   - `npm run dev` and check 375 / 768 / 1024 / 1440 via Chrome MCP or Playwright MCP
   - Confirm contrast and focus states at each breakpoint

---

## Iteration loop

Expect multiple rounds. Each round:

- Designer reviews the rendered hi-fi at relevant breakpoints.
- Designer gives notes ("tighten the hero margin at lg:", "swap the secondary button to ghost", "the gradient is too aggressive").
- Apply notes, rebuild, revalidate.
- Repeat until the designer says **"ready for coder"** — at which point run `../handoff-checklist.md`.

Multiple directions can be explored in parallel branches if the designer wants a side-by-side comparison. Use git worktrees or duplicated page files for that — confirm with the designer.

---

## Common pitfalls

- **Reusing a previous project's palette.** Each project provides its own. Wipe and replace.
- **Animating before invoking the gsap skill.** Always invoke the relevant gsap skill first; their guidance compounds (timelines + performance + reduced motion).
- **Three.js on initial paint.** It must be lazy. A scene that costs the LCP fails handoff.
- **Skipping A11y because "it's just a mockup".** Hi-fi IS the production design. Coders will integrate exactly what's handed off.
- **Adding components or restructuring during Phase 2.** If the visual direction needs a new molecule, surface it explicitly — don't smuggle it in.
- **Hardcoding palette values in components.** Always tokens. If a value doesn't have a token yet, add one in app.css `@theme` first.
- **Changing the lo-fi structure.** If the page structure needs to change in hi-fi, you're not doing vibe-design — you're back in Mode A. Surface that and switch modes.
