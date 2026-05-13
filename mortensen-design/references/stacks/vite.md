# 🅥 Vite + vanilla HTML + posthtml-include stack reference

The atomic structure, fidelity rules, and non-negotiables in `SKILL.md` apply unchanged. This file covers the Vite-specific syntax, conventions, and patterns for projects using plain HTML pages with `posthtml-include` partials.

---

## Project layout

```
src/
├── components/
│   ├── atoms/        # button.html, input.html, badge.html, icon.html, …
│   ├── molecules/    # search-bar.html, card.html, nav-item.html, …
│   ├── organisms/    # header.html, footer.html, event-grid.html, …
│   └── templates/    # page-shell.html, dashboard-layout.html, …
├── layouts/          # base.html (HTML doc shell, links app.css)
├── views/            # index.html, events.html (one HTML file per page; each is a Vite entry)
└── styles/
    └── app.css
vite.config.ts        # multi-page input + posthtml-include plugin
```

- **Filenames**: kebab-case (`event-grid.html`), one component per file.
- **Page entries**: each file in `src/views/*.html` is its own Vite entry — they must be listed in `rollupOptions.input` in `vite.config.ts`.
- **Dev port**: `http://localhost:5173`. Pages are served at `/<filename>.html`.

---

## Partial authoring conventions

Each partial is a plain HTML file. Variables are referenced via `{{name}}` (`posthtml-expressions` syntax). Every partial must document its expected `locals` in a comment at the top.

```html
<!-- src/components/atoms/button.html
     locals:
       label   (string, required)              — visible button text
       href    (string, optional)              — if set, renders <a>; otherwise <button>
       variant (string, optional)              — 'primary' (default) | 'secondary' | 'ghost'
       size    (string, optional)              — 'sm' | 'md' (default) | 'lg'
       type    (string, optional)              — 'button' (default) | 'submit' | 'reset'
-->
{{#if href}}
<a href="{{href}}" class="inline-flex items-center justify-center gap-2 rounded-md font-medium
  transition-[opacity,background-color] duration-200
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2
  {{size === 'sm' ? 'px-3 py-1.5 text-sm' : size === 'lg' ? 'px-6 py-3 text-md' : 'px-4 py-2 text-base'}}
  {{variant === 'secondary' ? 'border border-line text-ink hover:bg-silk-cream' :
    variant === 'ghost'     ? 'text-ink hover:bg-silk-cream' :
                              'bg-ink text-silk-cream hover:opacity-90'}}
">{{label}}</a>
{{else}}
<button type="{{type || 'button'}}" class="inline-flex items-center justify-center gap-2 rounded-md font-medium
  transition-[opacity,background-color] duration-200
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2
  {{size === 'sm' ? 'px-3 py-1.5 text-sm' : size === 'lg' ? 'px-6 py-3 text-md' : 'px-4 py-2 text-base'}}
  {{variant === 'secondary' ? 'border border-line text-ink hover:bg-silk-cream' :
    variant === 'ghost'     ? 'text-ink hover:bg-silk-cream' :
                              'bg-ink text-silk-cream hover:opacity-90'}}
">{{label}}</button>
{{/if}}
```

**Rules**:
- One partial per file. Filename = component name in kebab-case (`button.html`, `event-grid.html`).
- Always provide fallbacks for optional locals (`{{key || 'default'}}` or ternaries).
- No inline `<script>` tags unless the script belongs to that component; if so, keep it scoped and reduced-motion-aware.
- No inline `style="…"` attributes (except dynamic values that can't be classes).
- No `<style>` blocks unless absolutely necessary.

---

## Including a partial

The `<include>` tag takes a `src` (relative to the posthtml-include `root`, typically `src/`) and a `locals` JSON object (double-quoted keys, valid JSON).

```html
<include src="components/atoms/button.html" locals='{
  "label": "Join",
  "href": "/join",
  "variant": "primary"
}'></include>
```

---

## Organism — container-fluid + grid-standard

```html
<!-- src/components/organisms/event-grid.html
     locals:
       events (array of { title, date, href, image })
-->
<section class="container-fluid py-16">
  <div class="grid-standard">
    {{#each events}}
      <include src="components/molecules/event-card.html" locals='{
        "title": "{{title}}",
        "date":  "{{date}}",
        "href":  "{{href}}",
        "image": "{{image}}",
        "class": "col-span-8 md:col-span-6 lg:col-span-4"
      }'></include>
    {{/each}}
  </div>
</section>
```

---

## Page using a template

```html
<!-- src/views/events.html -->
<include src="components/templates/page-shell.html" locals='{ "title": "Events — <Project>" }'>
  <include src="components/organisms/hero.html" locals='{
    "eyebrow": "Upcoming",
    "heading": "Events that move <Project> forward",
    "lede": "Workshops, meetups, demo nights, member-only sessions."
  }'></include>

  <include src="components/organisms/event-grid.html" locals='{
    "events": [/* real content provided by designer — do not invent */]
  }'></include>
</include>
```

Inside `page-shell.html`, use `<content></content>` (or the equivalent `<yield>` in your posthtml-include version) to render the parent block content.

---

## Base layout — fidelity switch and app.css link

```html
<!-- src/layouts/base.html
     locals:
       title    (string, required)
       fidelity (string, optional) — 'lo' (default) | 'hi'
-->
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{{title}}</title>
    <link rel="stylesheet" href="/styles/app.css" />
  </head>
  <body data-fidelity="{{fidelity || 'lo'}}">
    <a href="#main" class="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 bg-ink text-silk-cream px-3 py-2 rounded-md">
      Skip to main content
    </a>
    <content></content>
  </body>
</html>
```

---

## Hi-fi imagery

Use `<img>` with explicit dimensions and `loading="lazy"` to prevent CLS and defer offscreen images:

```html
<img
  src="/assets/hero.jpg"
  alt="…"
  width="1200"
  height="675"
  loading="lazy"
  decoding="async"
/>
```

For above-the-fold images, use `loading="eager"` and `fetchpriority="high"`.

---

## Three.js — lazy via IntersectionObserver

```html
<!-- src/components/organisms/hero-scene.html -->
<div id="hero-scene" class="aspect-video bg-ink/5">
  <img src="/assets/hero-poster.jpg" alt="" class="w-full h-full object-cover" />
</div>

<script type="module">
  const target = document.getElementById('hero-scene');
  const io = new IntersectionObserver(async (entries, obs) => {
    if (!entries[0].isIntersecting) return;
    obs.disconnect();
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const three = await import('three');
    // initialize scene, mount canvas into #hero-scene, hide poster
  }, { rootMargin: '200px' });
  io.observe(target);
</script>
```

---

## vite.config.ts (multi-page input + posthtml-include)

```ts
// vite.config.ts — sketch, adapt to project
import { defineConfig } from 'vite';
import posthtml from 'vite-plugin-posthtml';   // or equivalent
import posthtmlInclude from 'posthtml-include';
import posthtmlExpressions from 'posthtml-expressions';
import { resolve } from 'node:path';
import { readdirSync } from 'node:fs';

const viewsDir = resolve(__dirname, 'src/views');
const views = readdirSync(viewsDir).filter(f => f.endsWith('.html'));
const input = Object.fromEntries(
  views.map(file => [file.replace(/\.html$/, ''), resolve(viewsDir, file)])
);

export default defineConfig({
  root: 'src',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: { input },
  },
  plugins: [
    posthtml({
      plugins: [
        posthtmlInclude({ root: resolve(__dirname, 'src') }),
        posthtmlExpressions(),
      ],
    }),
  ],
});
```

The exact plugin name and configuration depend on the project's chosen Vite + posthtml integration. Verify with `package.json` before scaffolding.

---

## Build & dev commands

```bash
npm install
npm run dev      # http://localhost:5173
npm run build    # bundles HTML entries listed in rollupOptions.input
npm run preview
```

Pages are accessed at `http://localhost:5173/views/<name>.html` (or `/<name>.html` depending on `root`).

---

## Variants — folder per block, entry routes to a variant

When a block needs 2+ alternatives, convert it into a folder with an entry and one file per variant. Pages keep including the entry; the entry decides which variant renders. The full pattern (file convention, lo-fi vs hi-fi, handoff) lives in `../variants.md` — this section is the Vite-specific shape.

```
src/components/organisms/hero/
├── index.html           ← entry
├── stacked.html
├── split.html
└── image-bg.html
```

Every variant file accepts **the same `locals`**. The entry forwards them. The trick is that `<include>` paths are static, so the entry uses posthtml-expressions conditionals to pick which `<include>` runs.

```html
<!-- src/components/organisms/hero/index.html
     locals:
       variant  (string, optional)   — 'stacked' (default) | 'split' | 'image-bg'
       eyebrow  (string, optional)
       heading  (string, required)
       lede     (string, optional)
-->
{{#if env.DEV}}
  <div
    data-variant-key="hero"
    data-variants="stacked,split,image-bg"
    data-variant-current="{{variant || 'stacked'}}"
  >
    <div data-variant="stacked"{{(variant && variant !== 'stacked') ? ' hidden' : ''}}>
      <include src="components/organisms/hero/stacked.html" locals='{
        "eyebrow": "{{eyebrow}}",
        "heading": "{{heading}}",
        "lede":    "{{lede}}"
      }'></include>
    </div>
    <div data-variant="split"{{variant !== 'split' ? ' hidden' : ''}}>
      <include src="components/organisms/hero/split.html" locals='{
        "eyebrow": "{{eyebrow}}",
        "heading": "{{heading}}",
        "lede":    "{{lede}}"
      }'></include>
    </div>
    <div data-variant="image-bg"{{variant !== 'image-bg' ? ' hidden' : ''}}>
      <include src="components/organisms/hero/image-bg.html" locals='{
        "eyebrow": "{{eyebrow}}",
        "heading": "{{heading}}",
        "lede":    "{{lede}}"
      }'></include>
    </div>
  </div>
{{else}}
  {{#if !variant || variant === 'stacked'}}
    <include src="components/organisms/hero/stacked.html" locals='{
      "eyebrow": "{{eyebrow}}", "heading": "{{heading}}", "lede": "{{lede}}"
    }'></include>
  {{/if}}
  {{#if variant === 'split'}}
    <include src="components/organisms/hero/split.html" locals='{
      "eyebrow": "{{eyebrow}}", "heading": "{{heading}}", "lede": "{{lede}}"
    }'></include>
  {{/if}}
  {{#if variant === 'image-bg'}}
    <include src="components/organisms/hero/image-bg.html" locals='{
      "eyebrow": "{{eyebrow}}", "heading": "{{heading}}", "lede": "{{lede}}"
    }'></include>
  {{/if}}
{{/if}}
```

Pages include the entry with the chosen variant:

```html
<include src="components/organisms/hero/index.html" locals='{
  "variant": "split",
  "heading": "Events that move <Project> forward",
  "lede":    "Workshops, meetups, demo nights."
}'></include>
```

### Wiring `env.DEV` for posthtml-expressions

`env.DEV` isn't built into posthtml-expressions — inject it as a global local from the plugin config so every partial can read it:

```ts
// vite.config.ts (excerpt)
posthtml({
  plugins: [
    posthtmlInclude({ root: resolve(__dirname, 'src') }),
    posthtmlExpressions({
      locals: {
        env: { DEV: process.env.NODE_ENV !== 'production' },
      },
    }),
  ],
}),
```

This is a one-time setup. Once it's there, the variant pattern (and any other dev/prod conditional) just works.

### Wiring the sidebar in base.html

The sidebar markup + script lives in `assets/variant-sidebar.html` and `assets/variant-sidebar.js` inside this skill. Copy the HTML into `src/components/_dev/variant-sidebar.html` and the JS into `public/scripts/variant-sidebar.js`. Then in the layout:

```html
<!-- src/layouts/base.html (excerpt) -->
<body data-fidelity="{{fidelity || 'lo'}}">
  <a href="#main" class="sr-only focus:not-sr-only …">Skip to main content</a>
  <content></content>
  {{#if env.DEV}}
    <include src="components/_dev/variant-sidebar.html"></include>
    <script src="/scripts/variant-sidebar.js" defer></script>
  {{/if}}
</body>
```

In Vite, the dev gate is `env.DEV` only — Vite serves static HTML, so a runtime `?devtools=1` escape hatch isn't available the way it is in Astro. Run `npm run dev` to use the sidebar.

---

## Vite-specific troubleshooting

- **"posthtml-include can't find a partial"** — `<include src="…">` paths are relative to the `root` passed to `posthtml-include` (typically `src/`). Verify the path and that the file exists.
- **A new page isn't bundled in production** — multi-page input is opt-in. Add the file to `rollupOptions.input` in `vite.config.ts`.
- **A `locals` value isn't substituting** — `locals` must be valid JSON. Single-quoted JSON, unquoted keys, or trailing commas will break silently. Use double quotes everywhere.
- **Expressions like `{{a ? b : c}}` aren't evaluating** — confirm `posthtml-expressions` is in the plugin chain. Without it, `{{…}}` is treated as literal text by `posthtml-include` alone.
- **Tailwind class on an `<include>` element doesn't apply** — Tailwind scans the result after posthtml processes the page; if a class is only present inside a `locals` string, ensure that string ends up in rendered HTML (no silent typo killing the substitution).
- **Build succeeds but the page is blank** — check the console for missing partials, or that `index.html` (or the relevant view) exists at `src/views/` and is listed in `rollupOptions.input`.
