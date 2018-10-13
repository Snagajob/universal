workspace(name = "nguniversal")

# Add NodeJS rules (explicitly used for sass bundle rules)
http_archive(
  name = "build_bazel_rules_nodejs",
  url = "https://github.com/bazelbuild/rules_nodejs/archive/0.15.0.zip",
  strip_prefix = "rules_nodejs-0.15.0",
  sha256 = "5f5b6464ca20aa63d278caaf4736f0381eb838800d7375132057a48f09d0b837",
)

# Add TypeScript rules
http_archive(
  name = "build_bazel_rules_typescript",
  url = "https://github.com/bazelbuild/rules_typescript/archive/0.20.2.zip",
  strip_prefix = "rules_typescript-0.20.2",
  sha256 = "2879fbd7168ba5d17db22bc2f585c0d1d3a82dd5e6f8af118e8b2f74d290024e",
)

# Fetch transient dependencies of the TypeScript bazel rules.
load("@build_bazel_rules_typescript//:package.bzl", "rules_typescript_dependencies")
rules_typescript_dependencies()

# Add sass rules
http_archive(
  name = "io_bazel_rules_sass",
  url = "https://github.com/bazelbuild/rules_sass/archive/1.13.4.zip",
  strip_prefix = "rules_sass-1.13.4",
  sha256 = "5ddde0d3df96978fa537f76e766538c031dee4d29f91a895f4b1345b5e3f9b16",
)

load("@io_bazel_rules_sass//sass:sass_repositories.bzl", "sass_repositories")
sass_repositories()

# The @angular repo contains rule for building Angular applications
http_archive(
    name = "angular",
    url = "https://github.com/angular/angular/archive/08e4489cf5a93a352954f1639da5e92112993753.zip",
    strip_prefix = "angular-08e4489cf5a93a352954f1639da5e92112993753",
)

# The @rxjs repo contains targets for building rxjs with bazel
http_archive(
    name = "rxjs",
    url = "https://registry.yarnpkg.com/rxjs/-/rxjs-6.3.3.tgz",
    strip_prefix = "package/src",
    sha256 = "72b0b4e517f43358f554c125e40e39f67688cd2738a8998b4a266981ed32f403",
)

# This local_repository rule is needed to prevent `bazel build ...` from
# drilling down into the @rxjs workspace BUILD files in node_modules/rxjs/src.
# In the future this will no longer be needed.
local_repository(
    name = "ignore_node_modules_rxjs",
    path = "node_modules/rxjs/src",
)

# Prevent Bazel from trying to build rxjs under angular devkit
# TODO(alexeagle): remove after Bazel 0.18 upgrade
local_repository(
    name = "rxjs_ignore_nested_1",
    path = "node_modules/@angular-devkit/core/node_modules/rxjs/src",
)
local_repository(
    name = "rxjs_ignore_nested_2",
    path = "node_modules/@angular-devkit/schematics/node_modules/rxjs/src",
)

#
# Load and install our dependencies downloaded above.
#
load("@build_bazel_rules_nodejs//:defs.bzl", "check_bazel_version", "node_repositories", "yarn_install")

check_bazel_version("0.17.1", """
If you are on a Mac and using Homebrew, there is a breaking change to the installation in Bazel 0.16
See https://blog.bazel.build/2018/08/22/bazel-homebrew.html
""")

node_repositories(
  # For deterministic builds, specify explicit NodeJS and Yarn versions. Keep the Yarn version
  # in sync with the version of Travis.
  node_version = "10.10.0",
  package_json = ["//:package.json"],
  preserve_symlinks = True,
  yarn_version = "1.9.4",
)

# Use Bazel managed node modules. See more below:
# https://github.com/bazelbuild/rules_nodejs#bazel-managed-vs-self-managed-dependencies
yarn_install(
  name = "npm",
  package_json = "//:package.json",
  yarn_lock = "//:yarn.lock",
)

# Setup TypeScript Bazel workspace
load("@build_bazel_rules_typescript//:defs.bzl", "ts_setup_workspace")
ts_setup_workspace()

# Setup Angular bazel rules
load("@angular//packages/bazel:package.bzl", "rules_angular_dependencies")
rules_angular_dependencies()

# Setup Angular workspace for building (Bazel managed node modules)
load("@angular//:index.bzl", "ng_setup_workspace")
ng_setup_workspace()

# Setup Go toolchain (required for Bazel web testing rules)
load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")
go_rules_dependencies()
go_register_toolchains()

# Setup web testing. We need to setup a browser because the web testing rules for TypeScript need
# a reference to a registered browser (ideally that's a hermetic version of a browser)
load("@io_bazel_rules_webtesting//web:repositories.bzl", "browser_repositories",
  "web_test_repositories")

web_test_repositories()
browser_repositories(
  chromium = True,
)

