# Search

cascading search strategy

User searches: "fluffy eggs"

Priority 1: Tags
"fluffy" → no results
"eggs" → [file1, file2, file3]

Priority 2: Ingredients
Check those 3 files for "fluffy" in ingredients
→ no results

Priority 3: Title (load files now)
Load file1, file2, file3
Search titles for "fluffy"
→ file1 found!

Priority 4: Instructions/notes (if still searching)
Search full text in remaining files

search by **tags** first
