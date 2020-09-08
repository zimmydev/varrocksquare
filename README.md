# Building

Build using:

```bash
elm make src/Main.elm --output=public/main.js
```

Build for production using: (must have `uglifyjs` installed)

```bash
elm make src/Main.elm --optimize --output=public/main.js && uglifyjs public/main.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=public/main.js
```

Try live using: (must have `elm-live` installed)

```bash
elm-live src/Main.elm --port=8001 --hot --pushstate --open --dir=public/ -- --output=public/main.js && rm -rf public/main.js
```
