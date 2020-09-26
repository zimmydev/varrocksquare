# Varrock Square [![Build Status](https://travis-ci.com/zimmydev/varrocksquare.svg?branch=master)](https://travis-ci.com/zimmydev/varrocksquare)

Varrock Square is a social blogging platform designed for the free-to-play [Old School RuneScape](https://oldschool.runescape.com) community. It's perfect if you want to write a guide for your fellow players, or simply keep a log of your daily progress. Perhaps you want to write an article discussing potential updates to the game, attaching a poll for quick feedback? On Varrock Square, you can do all this and more!

## Project Status

*Pre-alpha (under development)*

## Why does this project exist?
The answer is twofold. Primarily, it's merely a pet project for me to use to hone my full-stack web development and design skills; in that regard, this project exists for its own sake. On the other hand, there is a lot of potential value for just such a platform in the F2P community.

Currently, the *de jure* platform for the W385 community for anything resembling an article/blog/post is [the W385 subreddit](https://www.reddit.com/r/W385), which, while wonderful, active and well-moderated in its own right, leaves much to be desired as a blogging platform. The format of reddit just isn't conducive to writing articles or account diaries or blogposts <sup>[author's opinion]</sup>. The typical option for guides has typically just been a big pastebin blob; while it works, again, it's not optimal.

What if we can combine a written-content platform with the social aspect of, say, the subreddit or the [W385 Discord server](https://discord.gg/RA8bujG)? There are lots of potential ideas here. The Varrock Square project comes in here, as an exploration of some of those ideas.

# Repo

## Documents

* [API JSON Response Formats](API.md)

## Building

Build for production using: (*must have* `uglify-js` *installed*)

```bash
elm make src/Main.elm --optimize --output=public/main.js && uglifyjs public/main.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=public/main.js
```

## To-do
* Write more tests…
* `Decoder`s for all the server resources
* `Http` requests

## Contributions

While contributions are usually appreciated and welcome, I won't be accepting pull requests for this repo, but that is liable to change once the backend and frontend are fleshed out. Thanks for your interest!

## License

This project is licensed under the `GNU GPL v3`. See the [`LICENSE`](https://github.com/zimmydev/varrocksquare/blob/master/LICENSE) for details.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTIyMzU2NTQ5Nl19
-->