---
name: recipe-to-notion
description: >-
  Saves a recipe from a Claude conversation into the user's personal Notion
  recipes database, formatted consistently — properties (servings, times,
  difficulty, dietary, source links, rating) plus a structured page body
  (ingredients, an auto-built grocery checklist, numbered steps, substitutions,
  notes). Use this whenever the user wants to move, save, add, send, or put a
  recipe into Notion — e.g. "save this recipe to Notion", "add this to my
  recipes", "put this in my Notion recipe book", "move this recipe over" — even
  if they don't name the database, and even when the recipe was just generated
  in the conversation. Also handles first-run setup: creating the Recipes hub
  page and the recipes database with the right schema. Reach for it for any
  recipe→Notion request.
---

# Recipe → Notion

Move a recipe (one Claude just generated, or one the user pasted) into the
user's Notion recipes database, mapped to a consistent schema so their
collection stays uniform and filterable.

This skill runs on **claude.ai using the Notion connector**. It relies only on
the Notion tools (`notion-search`, `notion-fetch`, `notion-create-database`,
`notion-create-pages`, `notion-update-page`). It does not assume any other
runtime.

## Two things this skill does

1. **Setup** — provision the destination once: a **Recipes** hub page
   containing a recipes **database** with the full schema. Idempotent: if it
   already exists, reuse it.
2. **Save a recipe** (the common path) — locate the database and create one
   well-formatted recipe page in it.

## Reference files — read when you need them

- `references/recipe-schema.md` — the exact database schema (the
  `CREATE TABLE` DDL, every property, allowed select options, and what each
  field means). Read this before **Setup**, or whenever you need a property's
  type or options.
- `references/notion-mapping.md` — how to turn a recipe into Notion: the
  property JSON, the page-body block templates (ingredients, grocery checklist,
  steps, substitutions, notes), grocery-checklist rules, and the cover-image
  handling. Read this before **Save**.

Before writing any page body, read the Notion MCP resource
`notion://docs/enhanced-markdown-spec` for exact block syntax (callouts,
to-do checkboxes, etc.). Do not guess Markdown syntax.

## Locate the database (do this first, every time)

Skills are **stateless across conversations** — never assume you already know
the database ID. Find it fresh:

1. `notion-search` for the recipes database (query like `"Recipes database"`).
2. If exactly one clear match, `notion-fetch` it to get its **data source ID**
   (the `collection://…` URL in the `<data-source>` tag) and property schema.
   That data source ID is what you create pages under.
3. If **none** is found → this is first run. Do **Setup** (below).
4. If **several** plausible matches → show them and ask the user which to use.
   Don't guess into the wrong workspace.

## Workflow: Setup (first run)

Read `references/recipe-schema.md`, then:

1. Search to confirm a Recipes database doesn't already exist (avoid
   duplicates). If one does, stop and use it.
2. Create the **Recipes** hub page (`notion-create-pages`). If the user named a
   parent location, create it there; otherwise create it at the workspace root
   and tell them they can move it.
3. Create the database **under that hub page** (`notion-create-database` with
   `parent.page_id` = the hub page) using the DDL in the schema reference.
4. Capture the returned **data source ID** and confirm to the user that setup
   is done (link the hub page). Then continue to Save if they gave you a recipe.

## Workflow: Save a recipe

Read `references/notion-mapping.md`, then:

1. **Gather the recipe** from the conversation (or ask the user to paste it).
   Capture: title, servings, ingredients (with quantities), steps, notes/tips,
   any times or difficulty stated, dietary cues, source links, and the hero
   image URL if one exists.
2. **Locate the database** (above). Fetch its schema so you use the exact
   current property names.
3. **Build the properties** per the mapping reference. Only fill fields the
   recipe actually supports; leave the rest empty rather than inventing values
   (the user fills those in — e.g. Rating, External Source).
4. **Build the page body** per the mapping reference, in order: Ingredients →
   🛒 Grocery Checklist → Steps → 🔄 Substitutions → 📝 Notes → Tips.
5. **Create the page** under the data source (`notion-create-pages` with
   `parent.data_source_id`). Set the hero image as the page `cover`: use the
   recipe's own image URL if it has one, otherwise find a representative image
   via web or image search per the mapping reference and label it as
   representative. Only fall back to no cover if no usable image can be found.
6. **Confirm** with the page link and a one-line summary of what you set
   (and anything left blank for them to fill).

## Principles

- **Never fabricate recipe data.** If prep time or difficulty wasn't stated,
  leave it blank — don't estimate into a structured field. (You *may* derive
  the grocery checklist from the ingredients; that's reorganizing, not
  inventing.)
- **Preserve quantities and wording** in the Ingredients section exactly as the
  recipe gives them — that section is the source of truth for cooking.
- **Match the live schema**, not your memory of it. Property names come from the
  fetched data source, in case the user renamed something.
- **Ask, don't guess**, when the target database is ambiguous or the recipe is
  incomplete.
