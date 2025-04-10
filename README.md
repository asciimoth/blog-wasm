# blog-wasm
Some materials related to my WASM blog

## Content
- [helpers.js](helpers.js) - usefull functions to laod and run WASM code from nodejs REPL
- [debug.wat](debug.wat) - example of debug functions from [helpers.js](helpers.js) usage

## Dependency installation
### With NIX flakes
Just run `nix develop` in root of this repo.  
For direnv users there is also an [.envrc file](.envrc) already.

### In fedora
```sh
yum install wabt nodejs
```
### In arch
```sh
pacman -S wabt nodejs
```
### In ubuntu
```sh
apt install wabt nodejs
```
## WAT code running example
[![asciicast](https://asciinema.org/a/710855.svg)](https://asciinema.org/a/710855) 
```js
node
.load helpers.js
let example = await load("intro/basic-example")
example.theAnswer()
```
