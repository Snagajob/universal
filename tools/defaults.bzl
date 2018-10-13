"""Re-export of some bazel rules with repository-wide defaults."""
load("@build_bazel_rules_typescript//:defs.bzl", _ts_library = "ts_library", _ts_web_test_suite = "ts_web_test_suite")
load("@angular//:index.bzl", _ng_module = "ng_module")
load("@angular//:index.bzl", _ng_package = "ng_package")
load("@build_bazel_rules_nodejs//:defs.bzl", _npm_package = "npm_package", _jasmine_node_test = "jasmine_node_test")

DEFAULT_TSCONFIG_BUILD = "//modules:bazel-tsconfig-build.json"
DEFAULT_TSCONFIG_TEST = "//modules:bazel-tsconfig-test.json"

def _getDefaultTsConfig(testonly):
  if testonly:
    return DEFAULT_TSCONFIG_TEST
  else:
    return DEFAULT_TSCONFIG_BUILD

def ts_library(tsconfig = None, testonly = False, **kwargs):
  if not tsconfig:
    tsconfig = _getDefaultTsConfig(testonly)

  _ts_library(
    tsconfig = tsconfig,
    testonly = testonly,
    **kwargs
  )


NG_VERSION = "^6.0.0"
RXJS_VERSION = "^6.0.0"
HAPI_VERSION = "^17.0.0"
EXPRESS_VERSION = "^4.15.2"

NGUNIVERSAL_SCOPED_PACKAGES = ["@nguniversal/%s" % p for p in [
    "aspnetcore-engine",
    "common",
    "express-engine",
    "hapi-engine",
    "module-map-ngfactory-loader",
]]

PKG_GROUP_REPLACEMENTS = {
    "NG_VERSION": NG_VERSION,
    "RXJS_VERSION": RXJS_VERSION,
    "HAPI_VERSION": HAPI_VERSION,
    "EXPRESS_VERSION": EXPRESS_VERSION,
    "\"NG_UPDATE_PACKAGE_GROUP\"": """[
      %s
    ]""" % ",\n      ".join(["\"%s\"" % s for s in NGUNIVERSAL_SCOPED_PACKAGES])
}

GLOBALS = {
      "@angular/animations": "ng.animations",
      "@angular/core": "ng.core",
      "@angular/common": "ng.common",
      "@angular/common/http": "ng.common.http",
      "@angular/compiler": "ng.compiler",
      "@angular/http": "ng.http",
      "@angular/platform-browser": "ng.platformBrowser",
      "@angular/platform-server": "ng.platformServer",
      "@angular/platform-browser-dynamic": "ng.platformBrowserDynamic",
      "@nguniversal/aspnetcore-engine/tokens": "nguniversal.aspnetcoreEngine.tokens",
      "@nguniversal/express-engine/tokens": "nguniversal.expressEngine.tokens",
      "@nguniversal/hapi-engine/tokens": "nguniversal.hapiEngine.tokens",
      'tslib': 'tslib',
      "rxjs": "rxjs",
      "rxjs/operators": "rxjs.operators",
      "fs": "fs",
      "express": "express",
      "hapi": "hapi"
    }

# TODO(Toxicable): when a better api for defaults is avilable use that instead of these macros
def ts_test_library(node_modules=None, **kwargs):
    ts_library(testonly=1, **kwargs)

def ng_module(deps = [], tsconfig = None, testonly = False, **kwargs):
  if not tsconfig:
    tsconfig = _getDefaultTsConfig(testonly)

  local_deps = [
    # Since we use the TypeScript import helpers (tslib) for each TypeScript configuration,
    # we declare TSLib as default dependency
    "@npm//tslib",
    "@npm//@types/node",
  ] + deps

  _ng_module(
    deps = local_deps,
    tsconfig = tsconfig,
    testonly = testonly,
    **kwargs
  )

def jasmine_node_test(deps = [], **kwargs):
  local_deps = [
    # Workaround for: https://github.com/bazelbuild/rules_nodejs/issues/344
    "@npm//jasmine",
    "@npm//source-map-support",
  ] + deps

  _jasmine_node_test(
    deps = local_deps,
    **kwargs
  )

def ng_test_library(deps = [], tsconfig = None, **kwargs):
  local_deps = [
    # We declare "@angular/core" and "@angular/core/testing" as default dependencies because
    # all Angular component unit tests use the `TestBed` and `Component` exports.
    "@angular//packages/core",
    "@angular//packages/core/testing",
    "@npm//@types/jasmine",
    "@npm//@types/node",
  ] + deps;

  ts_library(
    testonly = 1,
    deps = local_deps,
    **kwargs
  )

def ng_package(globals = {}, **kwargs):
  globals = dict(globals, **GLOBALS)

  _ng_package(globals = globals, replacements=PKG_GROUP_REPLACEMENTS, **kwargs)

def npm_package(name, replacements = {}, **kwargs):
    _npm_package(
        name = name,
        replacements = dict(replacements, **PKG_GROUP_REPLACEMENTS),
        **kwargs
    )

def ng_web_test_suite(deps = [], srcs = [], **kwargs):
  _ts_web_test_suite(
    # Required for running the compiled ng modules that use TypeScript import helpers.
    srcs = ["@npm//node_modules/tslib:tslib.js"] + srcs,
    # Depend on our custom test initialization script. This needs to be the first dependency.
    deps = ["//test:angular_test_init"] + deps,
    bootstrap = [
      "@npm//node_modules/zone.js:dist/zone-testing-bundle.js",
      "@npm//node_modules/reflect-metadata:Reflect.js",
    ],
    **kwargs
  )
