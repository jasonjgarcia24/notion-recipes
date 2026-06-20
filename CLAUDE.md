# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

This repository is a **development and test workspace for a single Agent Skill** that will be
uploaded to **claude.ai**. The skill's job: take a recipe that claude.ai has generated in a
conversation and **move it into Jason's preferred Notion page** (a recipes database/page),
formatted consistently.

The deliverable is the skill bundle itself — not a long-lived application. We build and test it
here in Claude Code, then upload the packaged skill to claude.ai.

## Current state

Greenfield. As of init the directory contains only this file — no `SKILL.md`, no scripts, no
build system, no tests. Do not assume commands or structure exist; verify before referencing them.

## How an Agent Skill is structured (the thing we're building)

A claude.ai-uploadable skill is a directory containing a `SKILL.md` at its root with YAML
frontmatter plus a Markdown body, optionally accompanied by supporting files (scripts,
references, assets) that the body points to:

```
notion-recipes/                 (the skill folder we package & upload)
├── SKILL.md                    required — frontmatter + instructions
├── scripts/                    optional — helper code the skill invokes
├── references/                 optional — docs Claude reads on demand
└── assets/                     optional — templates/files used in output
```

`SKILL.md` frontmatter has two required fields:
- `name` — kebab-case, matches the folder name.
- `description` — third-person, states *what it does* **and** *when to use it*. This is the
  only part always loaded into context, so it is what determines whether the skill triggers.
  Make it specific to the recipe-from-Claude → Notion use case.

The body should be concise, imperative instructions. Push long content (field mappings, Notion
schema, formatting templates) into `references/` and link to it so it loads only when needed.

## Authoring workflow

- Use the **`skill-creator`** skill (available here as `example-skills:skill-creator`) to
  scaffold, edit, and package the skill, and to optimize the `description` for reliable
  triggering. Prefer it over hand-rolling the structure.
- Validate `SKILL.md` frontmatter (valid YAML, required `name`/`description`) before packaging.
- The skill is destined for **claude.ai**, not Claude Code. Its instructions must rely only on
  capabilities available in the claude.ai runtime (e.g. the Notion connector/MCP the user has
  enabled there) — not on Claude Code-only tools.

## Notion target — confirm before building

The skill writes to Jason's **preferred Notion recipes page**. The exact destination (page vs.
database), its property schema (e.g. ingredients, steps, tags, prep time, source), and the
access method (Notion MCP connector vs. raw API) are **not yet captured**. Pin these down with
the user before writing the migration/formatting logic, and record the confirmed schema in
`references/` so the skill maps recipe fields deterministically.

## Git workflow — Hubert owns all git

All git activity in this repo runs through the **`claude-dev-team:hubert`** subagent: staging,
commits, branch creation, and history curation. The main agent does **not** run `git add` /
`git commit` / `git branch` directly.

- Make files commit-ready first — Hubert has no Edit/Write tools.
- Hubert refuses pushes, force-pushes, PR creation, and destructive ops by design. Those
  (e.g. creating the public GitHub repo and the first push) are done by the main agent **only
  with Jason's explicit go-ahead**.
- Surface Hubert's verified result line (e.g. `hubert: committed <sha> "<msg>" ✓`) as-is.

## Testing

There is no test harness yet. Once the skill exists, "testing" means exercising it end-to-end:
feed it a representative claude.ai-generated recipe and confirm a correctly structured Notion
entry is produced. Capture sample recipes used for testing under a `tests/` or `references/`
folder so runs are repeatable.
