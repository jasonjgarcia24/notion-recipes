# notion-recipes

A [Claude.ai](https://claude.ai) **Agent Skill** that moves a recipe from a Claude
conversation into a structured **Notion** recipes database — formatted consistently,
every time.

You generate (or paste) a recipe in Claude, say *"save this to my recipes,"* and the
skill creates a clean Notion page: properties (servings, times, difficulty, dietary,
cuisine, source links, rating) plus a structured body — ingredients, an auto-built
🛒 grocery checklist, numbered steps, substitutions, and notes.

This repo is the **development & test workspace**. The shippable artifact is the skill
bundle in [`recipe-to-notion/`](recipe-to-notion/), packaged as a `.skill` file.

## The skill

`recipe-to-notion` does two things:

1. **Setup (first run)** — provisions the destination idempotently: a **Recipes** hub
   page containing a recipes **database** with the full schema. If it already exists,
   it's reused (no duplicates).
2. **Save a recipe** — locates the database (by search — Claude.ai skills are stateless
   across conversations) and creates one well-formatted recipe page.

It runs on Claude.ai using the **Notion connector**, relying only on the Notion tools
(`notion-search`, `notion-fetch`, `notion-create-database`, `notion-create-pages`,
`notion-update-page`). Recipe images are carried over when a URL exists; otherwise the
skill finds a clearly-labeled representative photo or falls back to a clean photo-less
page (the connector has no file-upload, so raw image bytes can't be pushed in).

## Install (on Claude.ai)

1. Grab `recipe-to-notion.skill` from the [latest release](../../releases) (or build it
   yourself — see below).
2. In Claude.ai: **Settings → Capabilities → Skills → Upload skill** and select the file.
   *(Skills require a plan with the Skills capability enabled.)*
3. Enable the **Notion** connector (Settings → Connectors) for the workspace where your
   recipes should live.
4. In a conversation with a recipe, say *"save this recipe to my Notion."* First run
   builds the database; after that it just adds entries.

## Repo layout

```
recipe-to-notion/          # the skill bundle (this is what gets packaged & uploaded)
├── SKILL.md               # frontmatter + concise workflow
└── references/
    ├── recipe-schema.md   # the database schema (CREATE TABLE DDL + per-field rules)
    └── notion-mapping.md  # property values + page-body templates + image handling
tests/sample-recipes/      # sample recipes for repeatable testing
utils/                     # packaging helpers (package_skill.py, quick_validate.py)
.mcp.json                  # wires up the remote Notion MCP for local dev (no secrets)
```

## Developing & testing

- **Notion MCP**: `.mcp.json` registers the official remote Notion MCP
  (`https://mcp.notion.com/mcp`). Authenticate per-user via OAuth — no token is stored in
  the repo.
- **Package the skill**: `python3 utils/package_skill.py recipe-to-notion dist`
  → validates the bundle and writes `dist/recipe-to-notion.skill`.
- **Testing** means exercising it end-to-end: run setup, then save a sample recipe from
  `tests/`, and confirm a correctly structured Notion entry.

## Notes

- **This repo ships `.claude/` dev hooks.** Opening this repo in
  [Claude Code](https://claude.com/claude-code) inherits a few benign, fail-closed
  guards (block writes to system dirs, prompt on auth'd `curl`, warn on credential-shaped
  output). They're convenience guardrails for development, not required to use the skill.
- **Local config convention**: anything ending in `.local.json` is gitignored. If you add
  machine-specific config, commit a redacted `*.example` companion, never the real file.
- `dist/` (build output) is gitignored; the packaged `.skill` is published via Releases.

## License

[MIT](LICENSE) © 2026 Jason J. Garcia
