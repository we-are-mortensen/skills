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
