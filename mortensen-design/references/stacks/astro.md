# 🅐 Astro stack reference

The atomic structure, fidelity rules, and non-negotiables in `SKILL.md` apply unchanged. This file covers Astro-specific syntax, conventions, and patterns.

---

## Project layout

```
src/
├── components/
│   ├── atoms/        # Button.astro, Input.astro, Badge.astro, Icon.astro, …
│   ├── molecules/    # SearchBar.astro, Card.astro, NavItem.astro, …
│   ├── organisms/    # Header.astro, Footer.astro, EventGrid.astro, …
│   └── templates/    # PageShell.astro, DashboardLayout.astro, …
├── layouts/          # BaseLayout.astro (HTML doc shell, imports app.css)
├── pages/            # index.astro, events.astro (file-based routing)
└── styles/
    └── app.css
```

- **Filenames**: PascalCase (`EventGrid.astro`), one component per file.
- **Page routes**: file-based via `src/pages/*.astro` — Astro maps file path to URL.
- **Dev port**: `http://localhost:4321`.

---

## Component authoring conventions

Every `.astro` component must:

1. Have a typed `interface Props` with sensible defaults
2. Use a semantic root element
3. Use `class:list` for conditional classes
4. Use `<slot />` for composition (prefer slots over prop-stuffing)
5. Avoid `<style>` blocks (Tailwind utilities first; tokens second)
6. Avoid inline `style="…"` except for dynamic values that can't be expressed in classes

```astro
---
// src/components/atoms/Button.astro
interface Props {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  type?: 'button' | 'submit' | 'reset';
  href?: string;
}
const { variant = 'primary', size = 'md', type = 'button', href, ...rest } = Astro.props;
const Tag = href ? 'a' : 'button';
---
<Tag
  href={href}
  type={href ? undefined : type}
  class:list={[
    'inline-flex items-center justify-center gap-2 rounded-md font-medium',
    'transition-[opacity,background-color] duration-200',
    'focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2',
    size === 'sm' && 'px-3 py-1.5 text-sm',
    size === 'md' && 'px-4 py-2 text-base',
    size === 'lg' && 'px-6 py-3 text-md',
    variant === 'primary'   && 'bg-ink text-silk-cream hover:opacity-90',
    variant === 'secondary' && 'border border-line text-ink hover:bg-silk-cream',
    variant === 'ghost'     && 'text-ink hover:bg-silk-cream',
  ]}
  {...rest}
>
  <slot />
</Tag>
```

---

## Organism — container-fluid + grid-standard

```astro
---
// src/components/organisms/EventGrid.astro
import EventCard from '@/components/molecules/EventCard.astro';

interface Event {
  title: string;
  date: string;
  href: string;
  image: string;
}
interface Props { events: Event[]; }
const { events } = Astro.props;
---
<section class="container-fluid py-16">
  <div class="grid-standard">
    {events.map((event) => (
      <EventCard {...event} class="col-span-8 md:col-span-6 lg:col-span-4" />
    ))}
  </div>
</section>
```

---

## Page using a template

```astro
---
// src/pages/events.astro
import PageShell from '@/components/templates/PageShell.astro';
import Hero from '@/components/organisms/Hero.astro';
import EventGrid from '@/components/organisms/EventGrid.astro';
---
<PageShell title="Events — <Project>">
  <Hero
    eyebrow="Upcoming"
    heading="Events that move <Project> forward"
    lede="Workshops, meetups, demo nights, member-only sessions."
  />
  <EventGrid events={[
    /* real content provided by designer — do not invent */
  ]} />
</PageShell>
```

---

## BaseLayout — fidelity switch and app.css import

```astro
---
// src/layouts/BaseLayout.astro
import '@/styles/app.css';
interface Props {
  title: string;
  fidelity?: 'lo' | 'hi';
}
const { title, fidelity = 'lo' } = Astro.props;
---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{title}</title>
  </head>
  <body data-fidelity={fidelity}>
    <a href="#main" class="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 bg-ink text-silk-cream px-3 py-2 rounded-md">
      Skip to main content
    </a>
    <slot />
  </body>
</html>
```

A template (`PageShell.astro`) typically wraps `BaseLayout` and adds shared organisms like `<Header />` and `<Footer />`, then exposes a `<slot />` for the page's main content.

---

## Header, Footer, and placeholder home

These three files are scaffolded in Mode N and updated by Mode A / Mode B whenever a page is created. The `<!-- PAGES:START -->` / `<!-- PAGES:END -->` markers are the only editing points — agents append `<a>` links inside, never restructure the surrounding HTML.

```astro
---
// src/components/organisms/Header.astro
---
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

```astro
---
// src/components/organisms/Footer.astro
---
<footer class="container-fluid border-t border-lo-border py-8 mt-16">
  <div class="grid-standard">
    <nav class="col-span-8 md:col-span-12 flex flex-wrap gap-6 text-sm text-lo-text-muted">
      <!-- PAGES:START -->
      <!-- PAGES:END -->
    </nav>
  </div>
</footer>
```

```astro
---
// src/pages/index.astro — placeholder home
import BaseLayout from '@/layouts/BaseLayout.astro';
---
<!-- placeholder home: true -->
<BaseLayout title="Home — placeholder">
  <main id="main" class="container-fluid py-24">
    <div class="grid-standard">
      <section class="col-span-8 md:col-span-8 md:col-start-3 text-center">
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
</BaseLayout>
```

**Appending a page link** (inside `PAGES:START` / `PAGES:END`):

```html
<a href="/events/" class="hover:underline">Events</a>
```

Insert at the end of the list, preserving existing entries and the marker lines.

**When the designer wireframes the home page**: overwrite `src/pages/index.astro` entirely with the real home wireframe (drops the `placeholder home: true` marker and the page-list), then prepend `<a href="/" class="hover:underline">Home</a>` inside the `PAGES` markers in `Header.astro` and `Footer.astro` if it isn't already there.

---

## Rich status index (when `site-architecture.md` exists)

If Mode N produced a `site-architecture.md`, replace the simple placeholder above with this version. It reads the architecture markdown at build time via `?raw`, parses the **Pages** table, and renders rows with `Wireframe` / `UI` status badges using lo-fi tokens.

```astro
---
// src/pages/index.astro — rich status index (placeholder home)
import BaseLayout from '@/layouts/BaseLayout.astro';
import architectureMd from '../../site-architecture.md?raw';

interface PageRow {
  route: string;
  parent: string;
  title: string;
  description: string;
  wireframe: string;
  ui: string;
}

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
      route: cells[0],
      parent: cells[1],
      title: cells[2],
      description: cells[3],
      wireframe: cells[4],
      ui: cells[5],
    });
  }
  return rows;
}

const pages = parsePagesTable(architectureMd);

const badgeClasses = (state: string) => {
  const s = state.toLowerCase();
  if (s.includes('validated')) return 'bg-lo-text text-lo-bg';
  if (s.includes('pending'))   return 'border border-lo-text text-lo-text bg-lo-surface';
  return 'border border-lo-border text-lo-text-muted bg-lo-bg';
};
---
<!-- placeholder home: true -->
<BaseLayout title="Project index">
  <main id="main" class="container-fluid py-16">
    <h1 class="text-2xl md:text-3xl font-semibold text-lo-text">Project index</h1>
    <p class="mt-4 text-sm text-lo-text-muted">
      Status from <code class="font-mono">site-architecture.md</code>. Temporary index while the home wireframe is in progress — replaced when the real home is wireframed.
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
          {pages.map((p) => (
            <tr class="border-t border-lo-border">
              <td class="py-3 pr-4">
                <a href={p.route} class="font-medium text-lo-text hover:text-lo-text-muted">{p.title}</a>
              </td>
              <td class="py-3 pr-4 font-mono text-sm text-lo-text-muted">{p.route}</td>
              <td class="py-3 pr-4">
                <span class:list={['inline-block px-2 py-0.5 rounded text-xs', badgeClasses(p.wireframe)]}>{p.wireframe}</span>
              </td>
              <td class="py-3 pr-4">
                <span class:list={['inline-block px-2 py-0.5 rounded text-xs', badgeClasses(p.ui)]}>{p.ui}</span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  </main>
</BaseLayout>
```

The `?raw` import resolves at build time. After Mode A / Mode B updates a status cell in `site-architecture.md`, Astro's dev server picks it up on the next reload — no edit to `index.astro` is needed.

If `site-architecture.md` is deleted, the build fails on the `?raw` import — that's intentional. The rich index requires architecture; remove the rich index (or replace it with the simple placeholder) if the project deliberately drops architecture tracking.

When the designer wireframes the home page, overwrite the whole file the same way as the simple placeholder — drops the `placeholder home: true` marker and the architecture-reading code.

---

## Hi-fi imagery

Use Astro's built-in image component for optimization:

```astro
---
import { Image } from 'astro:assets';
import heroImg from '@/assets/hero.jpg';
---
<Image src={heroImg} alt="…" width={1200} height={675} />
```

For remote images, pass `inferSize: true` or explicit dimensions to prevent CLS.

---

## Three.js with `client:visible`

Render the 3D component only when scrolled into view:

```astro
---
import HeroScene from '@/components/organisms/HeroScene.astro';
---
<HeroScene client:visible />
```

Inside the component, dynamically import Three.js so it's not in the initial bundle:

```ts
const { Scene, PerspectiveCamera, /* … */ } = await import('three');
```

Provide a static poster image as a `<noscript>` fallback or default `<img>` that the JS replaces on hydration.

---

## Build & dev commands

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # catches template + prop type errors
npm run preview
```

If `npm run build` fails, the most common cause is a prop type mismatch (extra prop, missing default, wrong literal union). Read the error message — Astro is precise about which file and which prop.

---

## Variants — folder per block, entry routes to a variant

When a block needs 2+ alternatives, convert it into a folder with an entry and one file per variant. Pages keep importing the entry; the entry routes based on the `variant` prop. The full pattern (file convention, lo-fi vs hi-fi, handoff) lives in `../variants.md` — this section just shows the Astro-specific code.

```
src/components/organisms/Hero/
├── index.astro
├── Stacked.astro
├── Split.astro
└── ImageBg.astro
```

Each variant file has the same `interface Props` and consumes the same content. The entry maps variant keys to components and renders accordingly:

```astro
---
// src/components/organisms/Hero/index.astro
import Stacked from './Stacked.astro';
import Split from './Split.astro';
import ImageBg from './ImageBg.astro';

interface Props {
  variant?: 'stacked' | 'split' | 'image-bg';
  eyebrow?: string;
  heading: string;
  lede?: string;
}
const { variant = 'stacked', ...rest } = Astro.props;

const variants = { stacked: Stacked, split: Split, 'image-bg': ImageBg };
const variantKeys = Object.keys(variants) as Array<keyof typeof variants>;

const isDevtools =
  import.meta.env.DEV || Astro.url.searchParams.has('devtools');
const ActiveVariant = variants[variant] ?? Stacked;
---
{isDevtools ? (
  <div
    data-variant-key="hero"
    data-variants={variantKeys.join(',')}
    data-variant-current={variant}
  >
    {variantKeys.map((key) => {
      const V = variants[key];
      return (
        <div data-variant={key} hidden={key !== variant}>
          <V {...rest} />
        </div>
      );
    })}
  </div>
) : (
  <ActiveVariant {...rest} />
)}
```

Pages set the chosen variant as a prop, exactly like any other prop:

```astro
<Hero
  variant="split"
  heading="Events that move <Project> forward"
  lede="…"
/>
```

In production builds (`astro build` without `?devtools=1`), only the chosen variant renders — no registry wrapper, no hidden siblings. At handoff, the page's `variant=` value IS the production pick.

### Wiring the sidebar in BaseLayout

The sidebar markup + script lives in `assets/variant-sidebar.html` and `assets/variant-sidebar.js` inside this skill. Copy the HTML into a component (e.g., `src/components/_dev/VariantSidebar.astro`) and the JS into `public/scripts/variant-sidebar.js`. Then in the layout:

```astro
---
// src/layouts/BaseLayout.astro (excerpt)
import VariantSidebar from '@/components/_dev/VariantSidebar.astro';
const isDevtools =
  import.meta.env.DEV || Astro.url.searchParams.has('devtools');
---
<body data-fidelity={fidelity}>
  <slot />
  {isDevtools && (
    <>
      <VariantSidebar />
      <script src="/scripts/variant-sidebar.js" is:inline defer></script>
    </>
  )}
</body>
```

Never include the sidebar from a page — once in the layout is enough, and the gate keeps it out of production.

---

## Astro-specific troubleshooting

- **"Cannot find module '@/components/…'"** — Astro path aliases need to be set up in `tsconfig.json` (`"paths": { "@/*": ["src/*"] }`). If `@/` isn't configured, fall back to relative imports.
- **A component renders fine in dev but breaks in build** — most likely a prop type error suppressed by dev mode's leniency. Fix the contract.
- **`class:list` outputs nothing** — every entry must be a string or a falsy value. `variant === 'primary' && 'bg-ink'` is fine; objects need the special object-syntax `{ 'bg-ink': variant === 'primary' }`.
- **An island doesn't mount** — check that you used a `client:*` directive (`client:load`, `client:visible`, `client:idle`). Without one, Astro ships static HTML only.
