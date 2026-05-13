# Mortensen Skills

Colección oficial de **Agent Skills** de [Mortensen](https://mortensen.cat) para Claude Code.

## Skills disponibles

| Skill | Descripción |
|---|---|
| [`mortensen-design`](./mortensen-design) | Workflow designer-first para wireframes lo-fi y componentes hi-fi en proyectos Astro o Vite+HTML. |

---

## Instalación

### Opción 1 — `npx` (recomendado)

Te pregunta qué skill instalar y si lo quieres **global** (disponible en todas tus sesiones de Claude Code) o **local** (sólo en el proyecto actual):

```bash
npx github:we-are-mortensen/skills
```

También puedes pasarle el nombre del skill directamente:

```bash
npx github:we-are-mortensen/skills mortensen-design
```

### Opción 2 — `npx skills add` (instalación global rápida)

Usa el CLI genérico de Agent Skills. **No pregunta nada**, instala siempre en global (`~/.claude/skills/`):

```bash
npx skills add https://github.com/we-are-mortensen/skills --skill mortensen-design
```

### Opción 3 — `curl | bash`

Mismo instalador interactivo que la opción 1, sin necesidad de Node:

```bash
curl -fsSL https://raw.githubusercontent.com/we-are-mortensen/skills/main/install.sh | bash
# o con el skill por argumento:
curl -fsSL https://raw.githubusercontent.com/we-are-mortensen/skills/main/install.sh | bash -s mortensen-design
```

### Opción 4 — Manual

```bash
# Global (todas las sesiones)
git clone https://github.com/we-are-mortensen/skills.git /tmp/mortensen-skills
mkdir -p ~/.claude/skills
cp -R /tmp/mortensen-skills/mortensen-design ~/.claude/skills/

# Local (sólo el proyecto actual)
mkdir -p .claude/skills
cp -R /tmp/mortensen-skills/mortensen-design .claude/skills/
```

---

## Global vs Local: ¿qué elijo?

| | **Global** (`~/.claude/skills/`) | **Local** (`<proyecto>/.claude/skills/`) |
|---|---|---|
| Disponibilidad | Todas tus sesiones | Sólo este proyecto |
| Versionable en git | No | Sí (se sube con el repo) |
| Buen caso de uso | Skills personales / cross-project | Skills específicos del cliente o del repo |

Para `mortensen-design` lo más habitual es **local**: lo commiteas en el repo del mockup y todo el equipo de diseño lo usa con la misma versión.

---

## Actualizar un skill

Vuelve a ejecutar el instalador — sobreescribe la versión instalada:

```bash
curl -fsSL https://raw.githubusercontent.com/we-are-mortensen/skills/main/install.sh | bash -s mortensen-design
```

## Desinstalar

```bash
# Global
rm -rf ~/.claude/skills/mortensen-design

# Local
rm -rf .claude/skills/mortensen-design
```

---

## Estructura del repo

```
.
├── README.md
├── install.sh
└── <nombre-skill>/
    ├── SKILL.md          # frontmatter + cuerpo del skill
    ├── assets/           # imágenes, plantillas, etc.
    └── references/       # docs cargadas bajo demanda
```

Para añadir un skill nuevo: crea una carpeta a nivel raíz con su `SKILL.md` y añádelo a la tabla de arriba.

---

## Licencia

© Mortensen. Uso interno y para clientes.
