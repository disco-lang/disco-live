Disco-live

This is the source code for a web UI where you can run programs written in [disco][].

  [disco]: https://github.com/disco-lang/disco

# Building

Building

```
nix develop
./build.sh
```

If you get an error about experimental features being disabled, then instead
of `nix develop` you may need to use a command like

```
nix --extra-experimental-features "nix-command flakes" develop
```

before running `./build.sh`.

Running

```
cd www
python -m http.server
```

Then, navigate to <http://localhost:8000/disco-live.html>.
