# Recipes database — schema

This is the canonical schema for the recipes database. Create it during **Setup**
with `notion-create-database`, passing the DDL below and `parent.page_id` set to
the **Recipes** hub page.

## CREATE TABLE DDL

Pass this as the `schema` argument (the connector creates a Notion database from
SQL DDL). Column names are double-quoted; select options use single quotes with
an optional `:color`.

```sql
CREATE TABLE (
  "Name" TITLE,
  "Servings" NUMBER,
  "Difficulty" SELECT('Easy':green, 'Medium':yellow, 'Hard':red),
  "Prep Time" NUMBER COMMENT 'minutes',
  "Cook Time" NUMBER COMMENT 'minutes',
  "Total Time" FORMULA('prop("Prep Time") + prop("Cook Time")') COMMENT 'minutes; auto = Prep + Cook',
  "Dietary" MULTI_SELECT('Dairy-Free':blue, 'Vegetarian':green, 'Vegan':green, 'Gluten-Free':orange, 'Nut-Free':brown, 'Low-Carb':purple, 'High-Protein':red),
  "Meal Type" MULTI_SELECT('Breakfast':yellow, 'Brunch':orange, 'Lunch':blue, 'Dinner':purple, 'Dessert':pink, 'Snack':gray, 'Side':brown, 'Appetizer':green),
  "Cuisine" SELECT('American':blue, 'Mediterranean':green, 'Italian':red, 'Mexican':orange, 'Asian':yellow, 'Indian':purple, 'French':pink, 'Middle Eastern':brown, 'Other':gray),
  "Claude Source" URL,
  "External Source" URL,
  "Rating" SELECT('⭐':gray, '⭐⭐':gray, '⭐⭐⭐':yellow, '⭐⭐⭐⭐':orange, '⭐⭐⭐⭐⭐':green),
  "Made It?" CHECKBOX,
  "Last Made" DATE,
  "Nutrition" RICH_TEXT,
  "Date Added" CREATED_TIME
)
```

Select/multi-select option lists are **starting sets** — Notion lets the user add
more later, and creating a page with a new option value adds it automatically. So
if a recipe is, say, Thai, you may use `"Cuisine": "Thai"` even though it isn't
listed; Notion will create the option.

## Property reference

| Property | Type | Set by skill? | Notes |
|----------|------|---------------|-------|
| Name | Title | ✅ always | The recipe title. |
| Servings | Number | ✅ if stated | From the recipe's servings/yield. |
| Difficulty | Select | ⚠️ only if stated | Easy/Medium/Hard. Don't guess if the recipe doesn't say. |
| Prep Time | Number (min) | ⚠️ only if stated | Active prep minutes. |
| Cook Time | Number (min) | ⚠️ only if stated | Cooking/baking minutes. |
| Total Time | Formula | ⛔ never set | Auto-computes Prep + Cook. Read-only. |
| Dietary | Multi-select | ✅ if inferable | See inference rules below. |
| Meal Type | Multi-select | ✅ if inferable | Breakfast/Dinner/etc. |
| Cuisine | Select | ✅ if inferable | One cuisine; use `Other` if unclear. |
| Claude Source | URL | ✅ if available | Link to the Claude conversation/share. |
| External Source | URL | ⚠️ only if present | Original site, if the recipe cites one. Else leave blank. |
| Rating | Select ⭐ | ⛔ never set | The user rates after cooking. |
| Made It? | Checkbox | ⛔ never set | The user checks after cooking. |
| Last Made | Date | ⛔ never set | The user sets after cooking. |
| Nutrition | Rich text | ⚠️ only if stated | Calories/macros if the recipe provides them. |
| Date Added | Created time | ⛔ auto | Notion fills it on creation. |

`✅` = set when you have the data · `⚠️` = set only if the recipe explicitly
states it · `⛔` = leave for the user / system.

## Inference rules (allowed — these reorganize, they don't fabricate)

These map cleanly from recipe content, so it's fine to set them:

- **Dietary**: infer from the title and ingredients. "Dairy-Free Tahini Veggie
  Quiche" → `Dairy-Free`; no meat/fish in ingredients → `Vegetarian`; no animal
  products at all → `Vegan`; no wheat/flour → consider `Gluten-Free` only if
  clearly so. When unsure, omit the tag rather than overclaim.
- **Meal Type**: infer from the dish. A quiche → `Breakfast`/`Brunch`; a hearty
  main → `Dinner`; a cookie → `Dessert`. Multiple are fine.
- **Cuisine**: infer the dominant cuisine; use `Other` if genuinely unclear.

Everything under `⚠️`/`⛔` stays empty unless the recipe states it. A blank field
the user fills in is better than a wrong value that pollutes their filters.
