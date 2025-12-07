# Indexing

- define the structure of the index
    - postings
        - `Field` a field withing a Posting
            - title, title_phrase, tags, ingredients
        - `Posting` which contains the reference and metadata
            - document_id, term_frequency, fields(where it came from)
        - `Postings` list which contains one or more Posting's
- research into information retrival ranking
    - added `document_frequency` helper function to the `Postings`
    - use IDF Inverse Document Frequency
    - use BM25 combined with BM25-IDF for ranking
    - add tests to cover a few examples that combines both indexing and then ranking over terms in the index
- build the reverse index
    - `ReverseIndex.dictionary` StringHashMap(Postings)
        - contains the map between a term(eg: salt, chicken, saffron) the occurences of a term, in how many documents, how many times, where in the document(`Posting.field`)
    - have a `indexDocument` function, which takes in a document's id and a `RecipeData` struct
    - the indexing is simple:
        - build an intermediary hash map(`postings_map`) of the terms found in the current document(the one being indexed currently)
        - update the `postings_map` for each section of a document's RecipeData
        - iterate over the `postings_map` and for each entry, update the index' dictionary itself(upsert)

## Ngrams

- ngram generation
    - added `ngrams.zig` module and played around with generating trigrams from recipe data items/terms
        - have edge padding using `$`
        - word length is >= 4, generate trigram, otherwise keep as exact
        - "soup" = ` ["$so","sou","oup","up$"]
        - edge cases(empty string, single character, two characters)

## Field ranking

I need some sort of ranking that would differentiate between a query which contains the terms (or the whole phrase) found in the recipe's title, vs a query that finds the terms scattered(one in the Ingredients section, another one in the tags, etc).

Consider bm25F for this(https://sourcegraph.com/blog/keeping-it-boring-and-relevant-with-bm25f)

Ranking is: **title > tags > ingredients**

## resources

https://www.youtube.com/watch?v=iHHqnyThrqE
https://www.youtube.com/watch?v=bnP6TsqyF30
https://www.youtube.com/watch?v=foMMYyycRgk
