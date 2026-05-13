# Variants — exploring alternatives of a block

Use this reference whenever a designer wants to see **two or more structural or visual alternatives of the same block** side by side and pick one. Examples:

- "Give me three versions of this hero — stacked, split, and image-bg"
- "Try the testimonial section as a carousel and as a static grid"
- "Show two header variants — minimal logo-left and centered-with-eyebrow"

Variants work in **lo-fi** (structural alternatives) and **hi-fi** (visual / motion alternatives). They are a design-time exploration tool: the production build renders **one** chosen variant per block; the others stay in source for future iteration.

If a difference can be expressed as a small prop tweak (color, size, label), **don't** make it a variant — make it a prop. Variants are for genuinely different layouts or visual directions.

---

## File convention — folder per block

A block becomes variant-aware the moment it has a second alternative. At that point, convert the single component file into a folder with one entry and one file per variant.

### 🅐 Astro

```
src/components/organisms/Hero/
├── index.astro       ← entry; routes to a variant
├── Stacked.astro     ← variant
├── Split.astro
└── ImageBg.astro
```

### 🅥 Vite + posthtml-include

```
src/components/organisms/hero/
├── index.html        ← entry; routes to a variant
├── stacked.html
├── split.html
└── image-bg.html
```

**Rules**:
- Every variant file accepts **the same props/locals**. The content contract is shared; only structure or styling differs.
- Variant filenames are PascalCase (Astro) / kebab-case (Vite) — same as any other component.
- Variants live at organism, molecule, or template tier. **Atoms don't get variants** — use a `variant` prop on the single atom file (see `Button.astro` in the stack reference).
- Pages and other components import the entry (`Hero` / `hero/index.html`), never an individual variant file directly. The entry routes; the page picks.

---

## The variant prop

The entry takes a `variant` prop with a sensible default. It's documented in the entry's contract (Astro `interface Props` / Vite `locals:` block). All other content props pass through to the chosen variant file untouched.

The page sets `variant` to declare the **final chosen alternative**. In dev, the sidebar can override this via a URL param without editing the page. At handoff, the value on the page is the production pick.

```astro
<!-- src/pages/home.astro -->
<Hero
  variant="split"
  eyebrow="Upcoming"
  heading="Events that move <Project> forward"
  lede="…"
/>
```

```html
<!-- src/views/home.html -->
<include src="components/organisms/hero/index.html" locals='{
  "variant": "split",
  "eyebrow": "Upcoming",
  "heading": "Events that move <Project> forward",
  "lede": "…"
}'></include>
```

---

## The registry — data attributes on the rendered block

In dev, the entry renders **all variants** and wraps each in a positioned `<div data-variant="<key>">`. The outer wrapper emits the registry the sidebar reads:

```html
<div
  data-variant-key="hero"
  data-variants="stacked,split,image-bg"
  data-variant-current="split"
  class="container-fluid"
>
  <div data-variant="stacked" hidden>…stacked markup…</div>
  <div data-variant="split">…split markup…</div>
  <div data-variant="image-bg" hidden>…image-bg markup…</div>
</div>
```

The sidebar discovers blocks by querying `[data-variant-key]` — no central registry file, nothing to keep in sync.

In production, the entry renders **only the chosen variant** (no wrapper, no `hidden` siblings). The same source file does both via an env check; see the stack references for the exact pattern.

---

## URL state — shareable, non-destructive

The sidebar writes the current selections to the URL as query params:

```
/events?hero=split&card-grid=v2
```

On page load, the bootstrap script reads `URLSearchParams`, finds each `[data-variant-key]` block, and toggles `[data-variant]` children to show the matching one. No reload needed when the sidebar switches a variant — the script flips `hidden` on the relevant children and pushes the new param to `history.replaceState`.

The page's prop-level default is used when no URL param is present. Sending a link with the URL params lets a stakeholder open the exact combo the designer is looking at.

---

## The sidebar

A floating bottom-right panel, collapsed by default to a chip like `🎛 Variants (3)`. Expanded, it lists one `<select>` per `[data-variant-key]` block on the current page.

- **Source**: `assets/variant-sidebar.html` (markup) and `assets/variant-sidebar.js` (behavior).
- **Wiring**: include **once** in the layout (`BaseLayout.astro` / `base.html`), behind a gate. Pages never include it themselves.
- **Gate**:
  - 🅐 Astro: `import.meta.env.DEV || Astro.url.searchParams.has('devtools')` — the `?devtools=1` query param works against built previews because Astro can render per request.
  - 🅥 Vite: `env.DEV` only (via posthtml-expressions; see `stacks/vite.md`). Vite serves static HTML, so use `npm run dev` for the sidebar. No runtime escape hatch on built output.
- **Reset**: a "Reset" control clears all variant URL params and reverts to each block's prop default.

Production builds (no dev flag, no `?devtools=1`) render zero sidebar markup and zero sidebar JS. The coder never has to strip anything.

---

## Lo-fi vs hi-fi variants

| | Lo-fi variants | Hi-fi variants |
|---|---|---|
| Purpose | Compare structural layouts of the same content | Compare visual / motion directions of the same structure |
| Examples | Hero stacked vs split vs image-bg · Filter row top vs sidebar · Card grid vs list | Hero with subtle scroll-parallax vs static photo vs short loop · Buttons primary-filled vs ghost vs gradient |
| Tokens | All variants share the same lo-fi tokens (grayscale, system font) | All variants share the same project palette + fonts |
| When you might add a variant | Lo-fi review reveals the structure isn't right — explore 2–3 alternatives before iterating further | Hi-fi review can't pick between two visual directions — render both, decide in browser |

The same variant folder can carry through both fidelities — Mode B doesn't restructure variants, it restyles each.

---

## Workflow

Same two phases as every other mode (still inside lo-fi or hi-fi — variants don't have their own mode).

### Phase 1 — Plan

When a designer asks for variants:

1. **Confirm the block** and the **tier** (must not be an atom).
2. **List the variants** — give each a short, descriptive key (`stacked`, `split`, `image-bg`, not `v1`/`v2`). 2–4 variants is the useful range; more dilutes the comparison.
3. **State the shared contract** — what props/locals every variant must accept. Variants differ in markup, not in their content interface.
4. **State the default** — which variant the page will pass as the prop value. Usually the most conservative or "current" option; the others are exploratory.
5. **STOP** and wait for designer approval before creating files.

### Phase 2 — Build

1. If the block is currently a single file, **convert it** to a folder:
   - Move the existing file into the folder as one of the variant files (rename to the chosen variant key).
   - Create the entry (`index.astro` / `index.html`) and the additional variant files.
2. **Each variant file** is a standalone component: its own structure, its own classes, its own (if needed) tokens.
3. **Update every call site** to import the entry (already does, if you just moved files); confirm with the designer that the page passes the intended default.
4. **Wire the sidebar** in the layout if it isn't already (one-time setup per project).
5. **Build & dev**, then visually flip through every variant via the sidebar at 375 / 768 / 1024 / 1440 (Chrome MCP / Playwright MCP).

---

## When variants intersect with promotion (Mode C)

Mode C's "leaky contract" pitfall — two call sites need slightly different markup of the same molecule — has two valid resolutions:

- If the difference is small and expressible as a prop value → **prop**.
- If the difference is structural (different child arrangement, different sub-elements) → **variants**.

Decide based on the diff, not on call-site count. A two-line ternary inside one file is a prop. A 30-line `{variant === 'split' ? <Split/> : <Stacked/>}` branching inside one file should be split into variant files.

---

## Handoff resolution

Before declaring a page ready (run `handoff-checklist.md`):

- [ ] Every variant-bearing block on the page has a **chosen `variant` value** explicitly set in the page source. No reliance on the entry's fallback.
- [ ] The chosen variant matches what the designer ratified (cross-check against the final reviewed URL — query params should match the props).
- [ ] Unused variant files **stay in the folder**. They are cheap to keep and useful for future iteration. Document the chosen one in the entry file's `Props` interface / `locals` block with a brief comment ("default: split — chosen 2026-05-12 review").
- [ ] The sidebar gate is correctly configured and confirmed inert in `npm run build` output (grep the built HTML for `data-variant-key` — there should be no variant siblings, only the chosen one rendered).

---

## Pitfalls

- **Variants for what should be a prop.** If three "variants" only differ by a color or a label, you're making the component library noisier for no benefit. Use props.
- **Diverging content contracts across variants.** Every variant must accept the same props. If one variant needs an extra piece of data, either give it a sensible default in the entry, or add the prop to the shared contract — never silently accept different shapes per variant.
- **Designing variants atomically without a page in view.** Variants exist to be compared in situ. Render them on the page they'll live on; comparing isolated component previews misleads.
- **Forgetting the env gate.** Shipping all variants to production bloats the page, ships dead markup, and weakens lighthouse / CLS. The entry must render one variant in production builds.
- **Adding a 5th variant.** Past 4, designers and reviewers can't hold the comparison in their head. If you find yourself adding more, prune first.
- **Promoting a variant without checking the others.** When you change the entry's `data-variants` attribute, make sure every listed key has a real file in the folder — a 404 on switch is jarring.
