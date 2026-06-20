# Mapping a recipe into Notion

How to turn a recipe into one Notion page in the recipes database. Read
`recipe-schema.md` for property types/options; this file covers the property
*values* and the page *body*.

Before building body content, read the MCP resource
`notion://docs/enhanced-markdown-spec` for exact block syntax. The block types
used here — numbered lists, bulleted lists, to-do checkboxes, callouts,
headings — are all standard, but confirm the callout/to-do syntax there rather
than guessing.

## 1. Create the page

Use `notion-create-pages` with:
- `parent`: `{ "data_source_id": "<the recipes data source id>" }`
- `properties`: the JSON map below
- `content`: the Notion-Markdown body (section 3)
- `cover`: the hero image URL when available (section 4)
- `icon`: a relevant food emoji is a nice touch (e.g. 🥧, 🍝, 🥗) — optional

### Properties JSON

Keys must match the **fetched** data source schema exactly. Include only what the
recipe supports; omit the rest (don't pass empty strings for selects).

Worked example — "Dairy-Free Tahini Veggie Quiche" (serves 6, a brunch quiche,
no times stated):

```json
{
  "Name": "Dairy-Free Tahini Veggie Quiche",
  "Servings": 6,
  "Dietary": "[\"Dairy-Free\", \"Vegetarian\"]",
  "Meal Type": "[\"Breakfast\", \"Brunch\"]",
  "Cuisine": "Mediterranean",
  "Claude Source": "https://claude.ai/share/…"
}
```

Notes:
- **Multi-select** values are a **JSON-array string**, e.g.
  `"Meal Type": "[\"Breakfast\", \"Brunch\"]"` — verified against the live
  connector; a plain comma-separated string does NOT work. Single-select,
  number, URL, and title are plain values. (For reference: checkbox is
  `"__YES__"`/`"__NO__"` and a date uses the expanded key `date:<Property>:start`
  with an ISO-8601 value — but the skill leaves those for the user.)
- `Difficulty`, `Prep Time`, `Cook Time`, `Nutrition`, `External Source` were
  omitted here because the recipe didn't state them. That's correct — leave them
  for the user.
- Never set `Total Time`, `Rating`, `Made It?`, `Last Made`, `Date Added`.

## 2. Body structure (in order)

Build the page body with these sections, each under an H2 heading. Skip a
section only if the recipe genuinely has nothing for it (e.g. no tips).

```
## Ingredients
## 🛒 Grocery Checklist
## Steps
## 🔄 Substitutions
## 📝 Notes
## Tips
```

## 3. Section templates

### Ingredients (reference list — preserve quantities & wording exactly)
A plain bulleted list, verbatim from the recipe. This is the cooking source of
truth, so do not round, reorder for "tidiness," or drop prep notes ("diced").

```
## Ingredients
- 6 large eggs
- 3 tablespoons tahini
- 3 tablespoons water
- 1 onion, diced
- … (every ingredient, as written)
```

### 🛒 Grocery Checklist (to-do checkboxes — derived from ingredients)
A to-do list the user checks off while shopping. Rules:
- One checkbox per shoppable item, using `- [ ]` to-do syntax.
- **Strip prep instructions** — buy "1 onion", not "1 onion, diced".
- **Keep the quantity** so they know how much to buy.
- **Group common pantry staples at the bottom under a "Pantry (check you have
  these)" line** and still list them — many kitchens already stock them.
  Pantry staples: salt, pepper, olive oil, neutral/vegetable oil, water, sugar,
  flour, common dried spices (paprika, cumin, etc.), baking soda/powder, vinegar.
- Combine duplicates (if two steps each need garlic, list garlic once with the
  total).

```
## 🛒 Grocery Checklist
- [ ] 6 large eggs
- [ ] Tahini
- [ ] 1 onion
- [ ] 1 head garlic
- [ ] 2 cups squash
- [ ] 3 cups fresh spinach
- [ ] 1 tomato
- [ ] Walnuts or almonds (3 tbsp)
- [ ] **Pantry (check you have these):**
- [ ] Olive oil
- [ ] Salt · black pepper · smoked paprika
```

### Steps (numbered, with bold step titles when the recipe has them)
```
## Steps
1. **Preheat oven:** Heat your oven to 375°F (190°C). Lightly oil a 9-inch dish.
2. **Cook the aromatics and squash:** Warm 2 tbsp olive oil … 8–10 minutes.
3. … (every step, in order)
```

### 🔄 Substitutions (bulleted `ingredient → swap`)
Populate from substitution hints the recipe gives; otherwise add a couple of
sensible, clearly-marked suggestions, or leave a single placeholder line for the
user. Mark anything you suggest so it's distinguishable from the recipe's own.

```
## 🔄 Substitutions
- Tahini → sunflower-seed butter (nut-free) or Greek yogurt (if not dairy-free)
- Squash → zucchini or sweet potato
```

### 📝 Notes (callout)
The recipe's own notes/cautions. Use a Notion **callout** block — the
`<callout>` tag with the body tab-indented as a child (NOT a `> [!NOTE]`
blockquote; that's GitHub syntax and won't render as a callout). Keep the
recipe's wording.

```
## 📝 Notes
<callout icon="📝" color="gray_bg">
	Whisk the tahini smooth with the water before it touches the eggs, or it clumps. Don't let the squash and spinach release too much water, or the custard won't set.
</callout>
```

### Tips (optional)
claude.ai often ends a recipe with a short conversational tips paragraph below
the artifact. If present, capture it here as plain text. If it duplicates Notes,
fold it into Notes instead of repeating.

## 4. Cover image (the hero photo)

The Notion connector accepts an image only as an external URL. There is no
file-upload tool, so raw image bytes can't be pushed in. Work through this
priority order, and never block creating the recipe page on the image:

1. **Recipe came with a reachable image URL?** Pass it as the page `cover` (and
   optionally embed it at the top of the body with `![caption](https://…)`).
   This is the truest representation, so prefer it whenever it exists.

2. **No real photo exists (for example, the recipe was generated in chat as a
   recipe card)?** Find a representative image using an available image-search
   or web-search tool and use it as the cover:
   - Query with the dish's defining traits, meaning the title plus key
     components (`"dairy-free spinach squash quiche"`), not just `"quiche"`.
   - Pick a directly-hosted, stable image URL (one ending in `.jpg`, `.jpeg`,
     `.png`, or `.webp`, from a reachable host). Skip search-result pages,
     thumbnails, hotlink-protected CDNs, and anything behind a login.
   - Sanity-check that the picture matches the dish before using it.
   - Set it as the page `cover`. Embed it at the top of the body with a caption
     marking it as representative, for example `![Representative image](https://…)`.
   - This is a generic stock photo, not the user's actual dish. Say so plainly
     in the confirmation, and tell them they can swap in their own once they've
     cooked it. Prefer an image clearly licensed for reuse where possible.

3. **User would rather supply their own?** Ask them to paste the image address
   (in most interfaces: right-click the image, then "Copy image address"), then
   set it as the `cover`.

4. **No image-search tool available, no URL offered, or search finds nothing
   usable?** Create the page without a cover and tell the user the photo
   couldn't be carried over. They can drag one onto the Notion page manually.

## 5. Confirm back to the user

After creating the page, report:
- The page link.
- A one-line summary of properties you set.
- Anything intentionally left blank for them (e.g. "Rating, Prep/Cook Time, and
  External Source are empty for you to fill in").
- Whether a cover image was set, and if so whether it's the recipe's own image
  or a representative stock photo standing in for the user's dish.
