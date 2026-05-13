/*
 * Variant sidebar bootstrap — design-time only.
 *
 * Discovers every [data-variant-key] block on the page, applies URL params
 * to toggle which variant is visible per block, and wires the floating
 * panel emitted by variant-sidebar.html.
 *
 * Drop this file into the project's static assets (e.g. `public/scripts/`
 * for Astro/Vite) and load it with `<script src="/scripts/variant-sidebar.js" defer></script>`
 * inside the same dev gate that includes variant-sidebar.html.
 *
 * No build step, no dependencies. Works the same in Astro and Vite.
 */
(function () {
  'use strict';

  function $(selector, root) {
    return (root || document).querySelector(selector);
  }
  function $$(selector, root) {
    return Array.from((root || document).querySelectorAll(selector));
  }

  function readBlocks() {
    return $$('[data-variant-key]').map(function (el) {
      var key = el.getAttribute('data-variant-key');
      var variants = (el.getAttribute('data-variants') || '')
        .split(',')
        .map(function (v) { return v.trim(); })
        .filter(Boolean);
      var fallback = el.getAttribute('data-variant-current') || variants[0];
      return { el: el, key: key, variants: variants, fallback: fallback };
    });
  }

  function applyVariant(block, value) {
    var chosen = block.variants.indexOf(value) !== -1 ? value : block.fallback;
    $$('[data-variant]', block.el).forEach(function (child) {
      var isMatch = child.getAttribute('data-variant') === chosen;
      if (isMatch) {
        child.removeAttribute('hidden');
      } else {
        child.setAttribute('hidden', '');
      }
    });
    block.el.setAttribute('data-variant-current', chosen);
    return chosen;
  }

  function writeParam(key, value, isFallback) {
    var url = new URL(window.location.href);
    if (isFallback) {
      url.searchParams.delete(key);
    } else {
      url.searchParams.set(key, value);
    }
    window.history.replaceState({}, '', url.toString());
  }

  function buildRow(block, onChange) {
    var row = document.createElement('div');
    row.className = 'vs-row';

    var label = document.createElement('label');
    label.className = 'vs-label';
    label.textContent = block.key;
    var selectId = 'vs-select-' + block.key;
    label.setAttribute('for', selectId);
    row.appendChild(label);

    var select = document.createElement('select');
    select.className = 'vs-select';
    select.id = selectId;
    block.variants.forEach(function (v) {
      var opt = document.createElement('option');
      opt.value = v;
      opt.textContent = v;
      select.appendChild(opt);
    });
    select.value = block.el.getAttribute('data-variant-current') || block.fallback;
    select.addEventListener('change', function () {
      onChange(block, select.value);
    });
    row.appendChild(select);
    return row;
  }

  function init() {
    var sidebar = $('[data-variant-sidebar]');
    var blocks = readBlocks();

    var params = new URLSearchParams(window.location.search);
    blocks.forEach(function (block) {
      var fromUrl = params.get(block.key);
      var initial = fromUrl || block.fallback;
      applyVariant(block, initial);
    });

    if (!sidebar) return;
    var count = $('[data-vs-count]', sidebar);
    var rowsHost = $('[data-vs-rows]', sidebar);
    var toggle = $('[data-vs-toggle]', sidebar);
    var reset = $('[data-vs-reset]', sidebar);

    count.textContent = String(blocks.length);

    if (blocks.length === 0) {
      sidebar.style.display = 'none';
      return;
    }

    rowsHost.innerHTML = '';
    blocks.forEach(function (block) {
      rowsHost.appendChild(buildRow(block, function (b, value) {
        var applied = applyVariant(b, value);
        writeParam(b.key, applied, applied === b.fallback);
      }));
    });

    toggle.addEventListener('click', function () {
      var collapsed = sidebar.getAttribute('data-collapsed') === 'true';
      sidebar.setAttribute('data-collapsed', collapsed ? 'false' : 'true');
      toggle.setAttribute('aria-expanded', collapsed ? 'true' : 'false');
    });

    reset.addEventListener('click', function () {
      var url = new URL(window.location.href);
      blocks.forEach(function (block) {
        url.searchParams.delete(block.key);
        applyVariant(block, block.fallback);
        var select = $('#vs-select-' + block.key, rowsHost);
        if (select) select.value = block.fallback;
      });
      window.history.replaceState({}, '', url.toString());
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
