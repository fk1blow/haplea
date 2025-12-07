# Todo

- storing user files and app config?
    - recupe stored in `~/Documents/Haplea`
    - config stored in `~/Library/Application Support/Haplea/`
        - not really needed atm
    - define a `paths` module
- feed the dictionary with actual files
    - get the user's document path
        - how do we get all the recipes without using too much memory?
    - feed each document/recipe to the reverse index
- use the `main` module as orchestrator
    - build the index
        - rebuilding or diffing not important atm
    - starts the http server
