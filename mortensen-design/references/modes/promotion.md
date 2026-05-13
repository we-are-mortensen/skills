# Mode C — Component promotion

**When**: any of the following:

- A page contains **inline markup that should be reused** across other pages or contexts.
- A **molecule is doing too much** and should be split into smaller atoms/molecules.
- An **organism turns out to be page-specific** and should be inlined back into the page (de-promotion).
- A repeated **pattern emerges across two or more pages** and should be hoisted into a shared component.

The output is a refactor: a new (or removed) component in the correct atomic tier, every call site updated, and zero visual change at any breakpoint.

---

## Phase 1 — Plan (read-only)

1. **Identify the exact markup** the designer points at. Quote it back so there's no ambiguity.
2. **Decide the target tier**:
   - **Atom** — smallest UI primitive; no business logic; no children of different types
   - **Molecule** — a small group of atoms that functions as a unit
   - **Organism** — a distinct section composed of molecules and/or atoms
   - **Template** — a page-level skeleton
   - **Inline (de-promotion)** — only used once and not worth abstracting; remove the standalone component and inline the markup
3. **Determine the component contract**:
   - 🅐 Astro: typed `interface Props` — list each prop with type, required/optional, default value.
   - 🅥 Vite (posthtml-include): list expected `locals` keys with type, required/optional, default value. Use `{{key || 'default'}}` for fallbacks.
4. **List every call site** that should adopt the new component (use grep / Glob to find them).
5. **Stack convention check**: filename matches the stack's naming (PascalCase `.astro` / kebab-case `.html`), lives in the correct tier folder.
6. **STOP** — present the plan with the proposed file path, contract, and call sites. Wait for designer approval.

---

## Phase 2 — Refactor

1. **Create the new component** in the correct tier folder following its stack's conventions (`../stacks/astro.md` or `../stacks/vite.md`).
2. **Define the interface**:
   - 🅐 Astro: typed `interface Props { … }` with defaults destructured from `Astro.props`.
   - 🅥 Vite: a `locals:` block at the top of the partial that documents every expected key, type, and default; always provide fallbacks for optional locals.
3. **Replace inline markup at every call site**:
   - 🅐 Astro: import the component and replace the markup with `<ComponentName … />`. Pass props matching the contract.
   - 🅥 Vite: replace the markup with `<include src="components/<tier>/<name>.html" locals='{ … }'></include>`. The JSON in `locals` must be valid (double-quoted keys and string values).
4. **Build** to catch any errors:
   - 🅐 Astro: prop type errors are the most common cause of failure.
   - 🅥 Vite: missing `<include>` targets or unbalanced posthtml expressions.
5. **Visual diff**: take screenshots at 375 / 768 / 1024 / 1440 **before** and **after** the refactor (Chrome MCP or Playwright MCP). They must be visually identical. Any difference means the contract is wrong or a class got lost — investigate before declaring done.
6. **Token consistency**: if the new component's markup hardcoded any value that was reused, extract it to app.css `@theme` as part of this promotion (see `../tokens-and-grid.md`).

---

## De-promotion (the reverse)

If a component turns out to be used only once and not worth abstracting:

1. **Phase 1**: confirm with the designer that there's only one call site and no plan to reuse soon.
2. **Phase 2**: inline the markup at the single call site; delete the component file. Build. Visual diff to confirm no regression.

De-promotion is rare but legitimate — it keeps the component library focused on what's actually shared.

---

## Common pitfalls

- **Promoting too eagerly.** A pattern used twice is a candidate; used once is not. Wait for the second use unless the designer explicitly asks.
- **Wrong tier.** An "atom" with three internal sub-elements is probably a molecule. An "organism" that's just a styled button is an atom. Re-check the definitions in `SKILL.md`.
- **Leaky contract.** If two call sites need slightly different markup, that's fine — but pick the right tool. Small differences (color, size, label, single conditional) → **prop/local**. Structural differences (different child arrangement, different sub-elements, a giant ternary in the markup) → **variants** (`../variants.md`). Never duplicate the component.
- **Hidden hardcoded values.** Inline markup often hides hex colors or fixed pixel sizes that need to become tokens during promotion. Surface them; don't bury them in the new component.
- **Skipping the visual diff.** A "successful" refactor that drops a class breaks hi-fi. The diff is non-negotiable.
- **Big-bang refactors.** Promote one component at a time. Multi-component refactors hide regressions.
