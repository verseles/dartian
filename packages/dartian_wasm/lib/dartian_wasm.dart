/// WebAssembly (WASM) deployment support for Dartian framework
///
/// This package provides:
/// - Base classes for WASM applications
/// - Cloudflare Workers support
/// - Telemetry integration
/// - Request/Response handling
/// - WASM module management
/// - Runtime utilities
/// - JavaScript/Dart bridge
library dartian_wasm;

export 'src/wasm_app.dart';
export 'src/wasm_runtime.dart'
    show WasmRuntime, WasmRuntimeConfig, WasmModuleProxy;
export 'src/wasm_bridge.dart';
export 'src/wasm_worker.dart';
export 'src/cloudflare_worker.dart';
