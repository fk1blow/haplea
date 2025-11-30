# Rankger Retrival

Consider a simple term frequency model instead:

```
score(recipe, query) = sum of (times each query term appears in recipe)
```

let's document the main terms:

- TF Term Frequency: how many times "term" appears in the recipe
- DF Document Frequency: how many recipes contain the term
- IDF Inverse Document Frequency

## indexing time

- parse recipe doc and extract terms
- build an intermediate hash map
- for each term in recipe, update the hash map(TF/count, field)

```
doc_terms = {
    soup: {count, field}
    tomato: {count, field}
}
```
