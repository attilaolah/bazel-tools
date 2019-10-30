# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_skylib//lib:shell.bzl", "shell")

def _json_extract_impl(ctx):
    flags = list(ctx.attr.flags)

    if ctx.attr.raw:
        flags += ["-r"]

    outputs = []
    for src in ctx.files.srcs:
        parts = [ctx.executable._jq.path] + flags
        parts += [shell.quote(ctx.attr.query), shell.quote(src.path)]

        basename, _, _ = src.basename.rpartition(".json")
        output = ctx.actions.declare_file(basename + ctx.attr.suffix)
        outputs.append(output)

        parts += [">", shell.quote(output.path), "\n"]
        cmd = " ".join([part for part in parts if part])

        # Using run() would be much nicer, but jq insts on writing to stdout.
        ctx.actions.run_shell(
            inputs = [src],
            outputs = [output],
            progress_message = "Executing jq for {}".format(src.short_path),
            tools = [ctx.executable._jq],
            command = cmd,
        )

    return [DefaultInfo(
        runfiles = ctx.runfiles(files = outputs),
    )]

json_extract = rule(
    implementation = _json_extract_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".json"],
            doc = "List of inputs. Must all be valid JSON files.",
        ),
        "suffix": attr.string(
            default = "",
            doc = ("Output file extensions. Each input file will be renamed " +
                   "from basename.json to basename+suffix."),
        ),
        "raw": attr.bool(
            default = False,
            doc = ("Whether or not to pass -r to jq. Passing -r will result " +
                   "in raw data being extracted, i.e. non-JSQN output."),
        ),
        "query": attr.string(
            default = ".",
            doc = ("Query to pass to the jq binary. The default is '.', " +
                   "meaning just copy the validated input."),
        ),
        "flags": attr.string_list(
            allow_empty = True,
            doc = "List of flags to pass to the jq binary.",
        ),
        "_jq": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@jq"),
        ),
    },
)

def _json_test_impl(ctx):
    inputs = [f.path for f in ctx.files.srcs]

    parts = [ctx.executable._jq.short_path, "."] + inputs
    parts += [">", "/dev/null"]  # silence jq, only show errors
    cmd = " ".join([part for part in parts if part])

    # Write the file that will be executed by 'bazel test'.
    ctx.actions.write(
        output = ctx.outputs.test,
        content = cmd,
    )

    return [DefaultInfo(
        executable = ctx.outputs.test,
        runfiles = ctx.runfiles(files = [
            ctx.executable._jq,
        ] + ctx.files.srcs),
    )]

json_test = rule(
    implementation = _json_test_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".json"],
            doc = ("List of inputs. The test will verify that they are " +
                   "valid JSON files."),
        ),
        "_jq": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@jq"),
        ),
    },
    outputs = {"test": "%{name}.sh"},
    test = True,
)
