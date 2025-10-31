# WebAssembly (WASI) Support

Dartian includes experimental support for compiling to the WebAssembly System Interface (WASI), which allows your application to run in a variety of sandboxed environments, such as serverless platforms and edge computing runtimes.

**Note:** WASI support in Dart is still under active development. This feature is considered experimental and may have limitations.

## What is WASI?

WASI is a standardized interface for WebAssembly that allows `.wasm` modules to interact with the underlying system in a controlled way. This means you can compile your Dartian application to a portable, sandboxed WebAssembly module that can run outside of a traditional browser or server environment.

Potential use cases include:

-   Serverless functions (e.g., Cloudflare Workers, Fastly Compute)
-   Edge computing
-   Plugin systems

## Compilation

To compile your Dartian application to a WASI-compatible WebAssembly module, you can use the `build wasm` CLI command:

```bash
dartian build wasm
```

This command will produce a `build/server.wasm` file. This file contains your compiled application and can be executed by any WASI-compliant runtime.

## Running with a WASI Runtime

To run your `.wasm` module, you will need a WASI runtime, such as [Wasmtime](https://wasmtime.dev/) or [Wasmer](https://wasmer.io/).

Once you have a runtime installed, you can execute your module:

```bash
wasmtime run build/server.wasm
```

## Current Limitations

-   **Network I/O**: WASI does not yet have a stable, standardized specification for server-side networking. As such, running a full HTTP server in a WASI environment may not be possible in all runtimes.
-   **Filesystem Access**: Filesystem access is limited by the capabilities and permissions granted by the WASI runtime.
-   **Package Compatibility**: Not all Dart packages are compatible with the WASI compilation target.

As the Dart and WASI ecosystems mature, these limitations are expected to be addressed. We are committed to improving WASI support in Dartian as the technology evolves.
