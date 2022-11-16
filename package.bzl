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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Version information.
# This is here to make it easier to update this file.
VERSIONS = {
    "bazelbuild/bazel-skylib": "1.0.2",
    "kkos/oniguruma": "6.9.8",
    "stedolan/jq": "1.6",
}
SHA256_SUMS = {
    "bazelbuild/bazel-skylib": "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2",
    "kkos/oniguruma": "28cd62c1464623c7910565fb1ccaaa0104b2fe8b12bcd646e81f73b47535213e",
    "stedolan/jq": "5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72",
}

def register_repositories():
    """Fetch transitive dependencies.

    If the user wants to get a different version of these, they can just fetch
    it from their WORKSPACE before calling this function, or not call this
    function at all.
    """

    # The jq binary.
    _github_archive(
        name = "jq",
        repo = "stedolan/jq",
        url = "releases/download/jq-{version}/jq-{version}.tar.gz",
        strip_prefix = "jq-{version}",
        vendor_build_file = True,
    )

    # The oniguruma library, a dependency of jq.
    _github_archive(
        name = "oniguruma",
        repo = "kkos/oniguruma",
        url = "releases/download/v{version}/onig-{version}.tar.gz",
        strip_prefix = "onig-{version}",
        vendor_build_file = True,
    )

    # Skylib is a dependency of our own .bzl files.
    _github_archive(
        name = "bazel_skylib",
        repo = "bazelbuild/bazel-skylib",
        url = "archive/{version}.tar.gz",
        strip_prefix = "bazel-skylib-{version}",
    )

def _github_archive(name, repo, url, strip_prefix = None, vendor_build_file = False):
    """Add a GitHub repository, if not already present."""
    if name in native.existing_rules():
        return

    version = VERSIONS[repo]

    if strip_prefix:
        strip_prefix = strip_prefix.format(version = version)

    build_file = None
    if vendor_build_file:
        build_file = str(Label("//:{}.bazel".format(name)))

    http_archive(
        name = name,
        sha256 = SHA256_SUMS[repo],
        urls = [
            "https://github.com/" + repo + "/" + url.format(version = version),
        ],
        strip_prefix = strip_prefix,
        build_file = build_file,
    )
