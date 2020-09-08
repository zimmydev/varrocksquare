# Varrock Square

Varrock Square is a social blogging platform designed for the free-to-play [Old School RuneScape](https://oldschool.runescape.com/) community. It's perfect if you want to write a guide for your fellow players, or simply keep a log of your daily progress. Perhaps you want to write an article discussing potential updates to the game, attaching a poll for quick feedback? On Varrock Square, you can do all this and more!

# Building

Build for production using: (must have `uglifyjs` installed)

```bash
elm make src/Main.elm --optimize --output=public/main.js && uglifyjs public/main.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=public/main.js
```
