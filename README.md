# [Starlark] Macros for [Bazel]

This repo contains a collection of Starlark macros, the required [genrule
tools][genrule] and the corresponding [`WORKSPACE` configuration][workspace] to
use them.

Load the macros from `defs.bzl` like so:

```bzl
load("@tools//:defs.bzl", "json_extract", "json_test")
```

The following macros are defined:

## `json_extract`

Extract data from a JSQN file. By default, it extracts the entire file (`query =
"."`). To extract a raw field, use it like so:

```bzl
json_extract(
    name = "geometry",
    srcs = [
        "geometry.json",
    ],
    out = "geometry.wkt",
    query = ".geom",
    raw = True,
)
```

## `json_test`

This is a test rule to validate the syntax of JSON files.

```bzl
json_test(
    name = "json_test",
    srcs = glob(["*.json"]),
)
```

## Disclaimer

This is not an official Google product (experimental or otherwise), it is just
code that happens to be owned by Google.

[Bazel]: https://bazel.build/
[Starlark]: https://github.com/bazelbuild/starlark
[genrule]: https://docs.bazel.build/versions/master/be/general.html#genrule
[workspace]: https://docs.bazel.build/versions/master/be/workspace.html
