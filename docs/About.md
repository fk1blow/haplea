# About

should define the sections of a recipe document instead of building a full-fledged
markdown parser.

https://chatgpt.com/c/68e69583-a528-8327-8328-1a27ec69d20e

## what we're interested in

we want to search by any ingredients or by grouping like vegetarian, soups, cooked food,
owen/cooked food, salads, etc

We also want free search, like any word(although too greedy), and maybe rank it(which one first?)

Should we have a separate section for this, like `## tags`? Maybe...

## Parsing & Search Strategy

Treat each `##` section as a named block.
Example: parse with regex like /^## (.+)$/ and split content by section.

For search:

Match tags exactly (for filters like “vegetarian”).

Match words in ingredients and description for full-text search.

Use simple weighting (e.g., title > ingredients > description).

## sections

(see)[Recipe-examples.md]

| Section                       | Purpose                               | Format                           | Notes                                               |
| ----------------------------- | ------------------------------------- | -------------------------------- | --------------------------------------------------- |
| `# Title`                     | Name of the recipe                    | Single line                      | Required                                            |
| `## description` _(optional)_ | Summary or story                      | Paragraph                        | Optional, but adds flavor                           |
| `## tags`                     | Categories or searchable keywords     | Comma- or newline-separated list | Used for filtering/search                           |
| `## ingredients`              | List of ingredients                   | Markdown list (`- item`)         | You can later parse quantities                      |
| `## instructions`             | Steps to make it                      | Numbered list or paragraphs      | “instructions” or “method” is better than “process” |
| `## notes` _(optional)_       | Tips, variations, serving suggestions | Paragraph                        | Optional but helpful                                |

## Optional Enhancements (Later)

If you later want to extend this schema without changing your parser too much, you could add optional sections like:

```
## time – prep/cook/total time

## servings – number of servings

## nutrition – optional table

## source – link or attribution
```

Example:

```
## time
prep: 5 min
cook: 10 min
total: 15 min

## servings
2
```
