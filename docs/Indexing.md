# Indexing

where do i start or what do i need to get started?

1. trigram generation
    - build an ngram function
    - have edge padding using `$`
    - word length is >= 4, generate trigram, otherwise keep as exact
    - "soup" = ` ["$so","sou","oup","up$"]

    - edge cases(empty string, single character, two characters)

2. define reverse index structure(dictionary, posting list)
    - define structure `{ "tri": [recipe_id1, recipe_id2, ...], "rig": [...], ... }`
        - posting list contains list of recie ids, maybe weight by number of occurences
3. unit tests
    - Trigram generation: "chicken" produces expected trigrams
    - Short strings: "eg" behavior (produces only one trigram "egg" if word is "egg")
    - Edge cases: empty strings, single characters, two characters
    - Index building: multiple recipes with overlapping ingredients produce correct inverted index
    - Posting lists are deduplicated per trigram
    - Case insensitivity: "Chicken" and "chicken" produce same trigrams
4. build the indexing functionality
    - extract trigrams from recipes
        - for each recipe, extract trigrams from title + ingredients + tags
    - use the recipe extractor's result
    - Consider: deduplicating recipe IDs in posting lists
        - same recipe shouldn't appear twice for the same trigram even if "tomato" appears in both title and ingredients

## resources

https://www.youtube.com/watch?v=iHHqnyThrqE
https://www.youtube.com/watch?v=bnP6TsqyF30
https://www.youtube.com/watch?v=foMMYyycRgk
