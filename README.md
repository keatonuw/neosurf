# neosurf

`neosurf` is a simple webring service, allowing clients to request
HTML and JSON representations of persisted [webrings](https://w.wiki/BQAj). It is written in OCaml, using the Dream framework.

### build

Install dependencies:
```
opam install .
```

Build:
```
dune build
```

### run
```
./_build/default/neosurf/main.exe
```
