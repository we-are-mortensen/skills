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
├── views/
│   ├── index.html    # placeholder home OR lo-fi home (route: /)
│   ├── events.html   # lo-fi page (route: /events.html)
│   └── ui/           # hi-fi copies, parallel route tree (/ui/…)
│       ├── index.html
│       └── events.html
└── styles/
    └── app.css
vite.config.ts        # multi-page input + posthtml-include plugin
```

The `ui/` subtree mirrors the lo-fi tree one-for-one — every hi-fi page has a lo-fi counterpart at the same relative path. Mode B copies lo-fi → `ui/` before promotion; the lo-fi file is never touched after that. See SKILL.md "Lo-fi and hi-fi are separate files".

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

## Header, Footer, and placeholder home

Same role as the Astro versions — scaffolded in Mode N, edited via `<!-- PAGES:START -->` / `<!-- PAGES:END -->` markers as pages are created. Agents append `<a>` links inside the markers and never touch the surrounding HTML.

```html
<!-- src/components/organisms/header.html -->
<header class="container-fluid border-b border-lo-border py-4">
  <div class="grid-standard items-center">
    <a href="/" class="col-span-4 md:col-span-3 font-semibold text-lo-text">Site</a>
    <nav class="col-span-4 md:col-span-9 flex justify-end gap-6 text-sm text-lo-text-muted">
      <!-- PAGES:START -->
      <!-- PAGES:END -->
    </nav>
  </div>
</header>
```

```html
<!-- src/components/organisms/footer.html -->
<footer class="container-fluid border-t border-lo-border py-8 mt-16">
  <div class="grid-standard">
    <nav class="col-span-8 md:col-span-12 flex flex-wrap gap-6 text-sm text-lo-text-muted">
      <!-- PAGES:START -->
      <!-- PAGES:END -->
    </nav>
  </div>
</footer>
```

```html
<!-- src/views/index.html — placeholder home -->
<!-- placeholder home: true -->
<include src="layouts/base.html" locals='{ "title": "Home — placeholder", "fidelity": "lo" }'>
  <main id="main" class="container-fluid py-24">
    <div class="grid-standard">
      <section class="col-span-8 md:col-span-8 md:col-start-3 text-center">
        <img src="/assets/mortensen.png" alt="Mortensen" class="h-8 mx-auto mb-6" />
        <h1 class="text-2xl font-semibold text-lo-text mb-4">Page directory</h1>
        <p class="text-sm text-lo-text-muted mb-8">
          Temporary index while the home wireframe is in progress. It is replaced
          the moment a real home page is wireframed.
        </p>
        <ul class="flex flex-col gap-2 text-sm text-lo-text">
          <!-- PAGES:START -->
          <!-- PAGES:END -->
        </ul>
      </section>
    </div>
  </main>
</include>
```

**Appending a page link** (inside `PAGES:START` / `PAGES:END`):

```html
<a href="/events.html" class="hover:underline">Events</a>
```

Insert at the end of the list, preserving existing entries and the marker lines. Note that Vite serves pages at `/<name>.html` unless your config rewrites them; pick href values that match your routing.

**When the designer wireframes the home page**: overwrite `src/views/index.html` entirely with the real home wireframe (drops the `placeholder home: true` marker and the page-list), then prepend `<a href="/" class="hover:underline">Home</a>` inside the `PAGES` markers in `header.html` and `footer.html` if it isn't already there.

> Vite's multi-page build only bundles files listed in `rollupOptions.input`. `index.html` is normally included by default; verify after scaffolding.

---

## Rich status index (when `site-architecture.md` exists)

If Mode N produced a `site-architecture.md`, replace the simple placeholder above with this version. **`site-architecture.md` is the single source of truth for status**, exactly as on the Astro side: the rich index pulls its rows from there at build time via a small Vite plugin (defined further below). The agent never edits row markup — it only edits the architecture table, and the dev server reloads automatically.

```html
<!-- src/views/index.html — rich status index (placeholder home) -->
<!-- placeholder home: true -->
<include src="layouts/base.html" locals='{ "title": "Project index", "fidelity": "lo" }'>
  <main id="main" class="container-fluid py-16">
    <img src="/assets/mortensen.png" alt="Mortensen" class="h-8 mb-6" />
    <h1 class="text-2xl md:text-3xl font-semibold text-lo-text">Project index</h1>
    <p class="mt-4 text-sm text-lo-text-muted">
      Status from <code class="font-mono">site-architecture.md</code>. Temporary index while the home wireframe is in progress — replaced when the real home is wireframed.
      The <strong>Wireframe</strong> badge links to the lo-fi route; the <strong>UI</strong> badge links to the UI route under <code class="font-mono">/ui/</code>.
    </p>

    <section class="mt-12">
      <table class="w-full border-t border-lo-border">
        <thead>
          <tr class="text-left text-xs uppercase tracking-widest text-lo-text-muted">
            <th class="py-3 pr-4">Page</th>
            <th class="py-3 pr-4">Path</th>
            <th class="py-3 pr-4">Wireframe</th>
            <th class="py-3 pr-4">UI</th>
          </tr>
        </thead>
        <tbody>
          <!-- PAGES_ROWS -->
        </tbody>
      </table>
    </section>
  </main>
</include>
```

The `<!-- PAGES_ROWS -->` token is replaced by the plugin defined in the next section. **Do not edit the rows in this file** — they're generated. To change a status, edit the corresponding cell in `site-architecture.md`.

### The architecture-status Vite plugin

Add the following plugin to `vite.config.ts` alongside the existing posthtml chain. It reads `site-architecture.md` at request time (and on every dev-server file change), parses the Pages table, renders the `<tr>` block, and substitutes it for `<!-- PAGES_ROWS -->` in any HTML it sees.

```ts
// vite.config.ts (additions for the architecture-status plugin)
import { readFileSync, existsSync } from 'node:fs';
import type { Plugin } from 'vite';

interface PageRow {
  route: string;
  parent: string;
  title: string;
  description: string;
  wireframe: string;
  ui: string;
}

const architectureMdPath = resolve(__dirname, 'site-architecture.md');

function parsePagesTable(md: string): PageRow[] {
  const lines = md.split('\n');
  const sectionStart = lines.findIndex((l) => l.trim().toLowerCase().startsWith('## pages'));
  if (sectionStart === -1) return [];
  let headerIdx = -1;
  for (let i = sectionStart + 1; i < lines.length; i++) {
    const t = lines[i].trim();
    if (t.startsWith('## ')) break;
    if (t.startsWith('|')) { headerIdx = i; break; }
  }
  if (headerIdx === -1) return [];
  const rows: PageRow[] = [];
  for (let i = headerIdx + 2; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line.startsWith('|')) break;
    const cells = line.split('|').slice(1, -1).map((c) => c.trim().replace(/`/g, ''));
    if (cells.length < 6) continue;
    rows.push({
      route: cells[0], parent: cells[1], title: cells[2],
      description: cells[3], wireframe: cells[4], ui: cells[5],
    });
  }
  return rows;
}

function badgeClasses(state: string): string {
  const s = state.toLowerCase();
  if (s.includes('validated')) return 'bg-lo-text text-lo-bg';
  if (s.includes('pending'))   return 'border border-lo-text text-lo-text bg-lo-surface';
  return 'border border-lo-border text-lo-text-muted bg-lo-bg';
}

const isStarted = (s: string) => !s.toLowerCase().includes('to do');
const uiHref = (route: string) =>
  route === '/' ? '/ui/' : `/ui${route.startsWith('/') ? route : `/${route}`}`;

function renderRows(): string {
  if (!existsSync(architectureMdPath)) return '';
  const md = readFileSync(architectureMdPath, 'utf-8');
  return parsePagesTable(md).map((p) => {
    const wfCell = isStarted(p.wireframe)
      ? `<a href="${p.route}" class="inline-block px-2 py-0.5 rounded text-xs no-underline hover:opacity-80 ${badgeClasses(p.wireframe)}">${p.wireframe}</a>`
      : `<span class="inline-block px-2 py-0.5 rounded text-xs ${badgeClasses(p.wireframe)}">${p.wireframe}</span>`;
    const uiCell = isStarted(p.ui)
      ? `<a href="${uiHref(p.route)}" class="inline-block px-2 py-0.5 rounded text-xs no-underline hover:opacity-80 ${badgeClasses(p.ui)}">${p.ui}</a>`
      : `<span class="inline-block px-2 py-0.5 rounded text-xs ${badgeClasses(p.ui)}">${p.ui}</span>`;
    return `<tr class="border-t border-lo-border">
      <td class="py-3 pr-4"><a href="${p.route}" class="font-medium text-lo-text hover:text-lo-text-muted">${p.title}</a></td>
      <td class="py-3 pr-4 font-mono text-sm text-lo-text-muted">${p.route}</td>
      <td class="py-3 pr-4">${wfCell}</td>
      <td class="py-3 pr-4">${uiCell}</td>
    </tr>`;
  }).join('\n');
}

const architectureStatusPlugin = (): Plugin => ({
  name: 'mortensen:architecture-status',
  enforce: 'pre',
  configureServer(server) {
    server.watcher.add(architectureMdPath);
    server.watcher.on('change', (file) => {
      if (file === architectureMdPath) server.ws.send({ type: 'full-reload' });
    });
  },
  transformIndexHtml: {
    order: 'pre',
    handler(html) {
      return html.replace(/<!--\s*PAGES_ROWS\s*-->/g, renderRows());
    },
  },
});
```

Register the plugin BEFORE the posthtml chain so the `<tr>` block is in place before posthtml processes the file:

```ts
export default defineConfig({
  // … (root, build, input as before)
  plugins: [
    architectureStatusPlugin(),
    posthtml({ /* … existing config … */ }),
  ],
});
```

**Behavior**:
- Editing a status cell in `site-architecture.md` triggers a dev-server full reload; the index renders the new state instantly.
- If `site-architecture.md` is absent or has no Pages table, `renderRows()` returns an empty string and the tbody renders empty — useful while scope is still being captured.
- The plugin only affects HTML files that actually contain the `<!-- PAGES_ROWS -->` token. Other pages pass through untouched.
- For ESM projects (`"type": "module"` in `package.json`), replace `__dirname` with `dirname(fileURLToPath(import.meta.url))` from `node:path` + `node:url`.

When the designer wireframes the home page, overwrite the whole `src/views/index.html` with the real home wireframe — that drops the `<!-- PAGES_ROWS -->` token, and the plugin becomes a no-op on this file (other pages with the token would still pick up rows, but the placeholder home is the only consumer).

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
import { resolve, relative } from 'node:path';
import { readdirSync } from 'node:fs';

const viewsDir = resolve(__dirname, 'src/views');

// Walk src/views/ recursively so both lo-fi and ui/ pages are picked up.
function walkHtml(dir: string): string[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = resolve(dir, entry.name);
    if (entry.isDirectory()) return walkHtml(full);
    return entry.isFile() && entry.name.endsWith('.html') ? [full] : [];
  });
}

const input = Object.fromEntries(
  walkHtml(viewsDir).map((file) => {
    const key = relative(viewsDir, file).replace(/\.html$/, '').replace(/[\\/]/g, '__');
    return [key, file];
  })
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

`ui/events.html` produces an entry keyed `ui__events`; its dev URL is `/ui/events.html`. Adjust the routing/output settings if your project rewrites `.html` away from URLs.

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
