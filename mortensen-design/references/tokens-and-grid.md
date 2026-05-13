# Tokens, container-fluid, grid-standard, breakpoints

The non-negotiables in `SKILL.md` cover the rules. This file is the detail: what belongs in `@theme`, how to extend it safely, when to use `grid-standard`, and how the breakpoints map.

---

## `app.css` is the only home for tokens

All design tokens — colors, typography, spacing, radii, shadows, motion — live in the `@theme` block of `app.css`. Components consume them as Tailwind utilities or arbitrary values referencing the CSS variable.

```css
/* app.css */
@import 'tailwindcss';
@source "../views/";          /* Vite */
@source "../components/";     /* Vite */
/* For Astro, @source paths point at src/components and src/pages */

@theme {
  --breakpoint-3xl: 100rem;

  /* Project palette goes here (replaced per project) */
  --color-ink: #2A2622;
  --color-line: #C9B89A;
  /* … */

  /* Lo-fi neutrals (always present) */
  --color-lo-bg: #ffffff;
  --color-lo-surface: #f4f4f5;
  --color-lo-surface-2: #e4e4e7;
  --color-lo-border: #d4d4d8;
  --color-lo-text: #18181b;
  --color-lo-text-muted: #71717a;
  --color-lo-placeholder: #d4d4d8;
}
```

### Allowed token categories

- **Colors** — `--color-*`
- **Typography** — `--font-*` (families), `--text-*` (sizes), `--leading-*` (line heights), `--tracking-*` (letter spacing)
- **Spacing** — `--spacing-*`
- **Radii** — `--radius-*`
- **Shadows** — `--shadow-*`
- **Motion** — `--ease-*`, `--duration-*`
- **Breakpoints** — `--breakpoint-*` (already set; do not add new ones)

### Adding a new token

When a value is reused 2+ times in components, hoist it to `@theme`:

```css
@theme {
  --hero-min-width: 768px;
  --card-radius: 14px;
}
```

Then consume via Tailwind:

```html
<div class="w-[var(--hero-min-width)] rounded-[var(--card-radius)]">…</div>
```

For Tailwind utilities Tailwind generates automatically from tokens (colors, font sizes, spacing, etc.), use the utility directly: `bg-ink`, `text-base`, `p-4`.

### Component rules

- ❌ Never hardcode hex colors in component files.
- ❌ Never hardcode raw pixel values for anything reused.
- ✅ Tailwind utilities backed by tokens: `text-ink bg-silk-cream`.
- ✅ Arbitrary syntax for one-off values, referencing tokens: `w-[var(--hero-min-width)]`.
- ✅ When a value would be reused, add a token first; don't paste the literal twice.

---

## `container-fluid` — mandatory on every section

Every organism section, template section, and page section MUST wrap in `container-fluid`. It enforces consistent gutters across breakpoints.

```html
<section class="container-fluid">
  <!-- section content -->
</section>
```

**No exceptions**:
- No hand-rolled `max-width` wrappers.
- No ad-hoc `px-4 md:px-8` padding wrappers.
- No "I'll just nest two containers" — `container-fluid` already nests safely.

Reference the `@utility container-fluid` definition in `app.css`:

```css
@utility container-fluid {
  @apply w-full px-4 md:px-8 2xl:px-16 3xl:px-[calc((100%+calc(var(--spacing)*32)-100rem)/2)];
}
```

---

## `grid-standard` — only when a grid is needed

The project's grid system is **fixed**:

- **Mobile**: 8 columns, `gap-2`
- **`md:` and up (≥ 768px)**: 12 columns, `gap-4`
- **`lg:` and up**: 12 columns, `gap-6`
- **`xl:` and up**: 12 columns, `gap-8`

Reference (from `app.css`):

```css
@utility grid-standard {
  @apply grid grid-cols-8 gap-2 md:grid-cols-12 md:gap-4 lg:gap-6 xl:gap-8;
}
```

### When to use `grid-standard`

Use it for any column-based layout: card grids, sidebar+content layouts, multi-column lists.

```html
<section class="container-fluid">
  <div class="grid-standard">
    <article class="col-span-8 md:col-span-8">…</article>
    <aside   class="col-span-8 md:col-span-4">…</aside>
  </div>
</section>
```

### When NOT to use `grid-standard`

For non-grid layouts, use `container-fluid` alone with Tailwind flex / spacing utilities:

```html
<section class="container-fluid flex flex-col gap-8">
  <!-- vertical stack -->
</section>

<section class="container-fluid">
  <div class="flex items-center justify-between">…</div>
</section>
```

### What's NOT allowed

- ❌ A custom grid with a different column count (`grid grid-cols-5`, `grid grid-cols-7`, etc.).
- ❌ Nested grids that fork from `grid-standard` (a child can re-use `grid-standard` inside a `col-span-*` cell, but cannot define a new column system).
- ❌ Manual percentage widths to simulate a different grid.

If a design "needs" 5 cols, fit it into the 12-col system: 5 cols at lg becomes `col-span-12 lg:col-span-2` (six items across 12 = 5 visible plus gutter, etc.). If that genuinely doesn't work, surface the conflict to the designer — don't fork the grid.

---

## Tailwind v4 default breakpoints

Mobile-first. **No custom breakpoints.**

| Prefix | Min-width | Typical device |
|---|---|---|
| (none) | 0px | Mobile base |
| `sm:` | 640px | Large phones / small tablets |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large desktops |
| `3xl:` | 1600px | Extra-large desktops (defined in app.css `@theme`) |

### Mobile-first patterns

Default styles target mobile. Prefixes add larger-screen behavior:

```html
<!-- Hero: stacked on mobile, side-by-side on lg+ -->
<div class="flex flex-col gap-6 lg:flex-row lg:gap-12">…</div>

<!-- Type scale: smaller on mobile, larger on desktop -->
<h1 class="text-xl md:text-2xl lg:text-3xl">…</h1>

<!-- Reveal an aside only at lg+ -->
<aside class="hidden lg:block">…</aside>
```

### Never

- ❌ `lg:flex md:block sm:hidden` — desktop-first; reorder mobile-first.
- ❌ Custom values like `min-[900px]:`.
- ❌ Per-component breakpoints invented to fit a specific design — always pick from the standard six.

---

## Quick checklist when writing or reviewing a component

- [ ] Section wrapped in `container-fluid`?
- [ ] If a grid layout: uses `grid-standard` with the 12-col system?
- [ ] No `grid-cols-*` outside `grid-standard`?
- [ ] No hardcoded hex colors or pixel values? Tokens used everywhere?
- [ ] Mobile-first: default styles target mobile, breakpoint prefixes add larger-screen behavior?
- [ ] Only `sm` / `md` / `lg` / `xl` / `2xl` / `3xl` prefixes?
- [ ] If a new value is used 2+ times, has it been hoisted to `@theme`?
