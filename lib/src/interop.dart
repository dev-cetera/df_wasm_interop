// lib/src/interop.dart

import 'dart:js_interop';

/// Represents an initialized Wasm module, providing access to its exported functions.
///
/// This class is a Dart-side container for a JavaScript module object. You should
/// cast the [instance] to your own `@staticInterop` type for type-safe access
/// to your Wasm functions.
//
// REMOVED: @JS() and @anonymous annotations. This is now a regular Dart class.
class WasmModule {
  /// The raw JavaScript module object containing all exported functions
  /// from your Wasm module.
  ///
  /// Cast this object to your custom, type-safe interop class.
  ///
  /// Example:
  /// ```dart
  /// @JS()
  /// @staticInterop
  /// class MyRustApi {}
  ///
  /// extension MyRustApiExtension on MyRustApi {
  ///   external JSString hello_world();
  /// }
  ///
  /// final module = await WasmModule.initialize(...);
  /// final myApi = module.instance as MyRustApi;
  /// print(myApi.hello_world().toDart);
  /// ```
  // REMOVED: `external` keyword. This is now a regular Dart field.
  final JSObject instance;

  /// Initializes a Wasm module using the `wasm-bindgen` generated JavaScript
  /// glue file. This is the primary entry point for using the package.
  ///
  /// This function assumes a loader script (`loader.js` from this package)
  /// has been included in your `index.html`.
  ///
  /// - [jsPath]: The path to the `wasm-bindgen` generated `.js` file, relative
  ///   to the `web` directory (e.g., 'assets/my_module.js').
  ///
  /// Throws an exception if the module fails to load or if the loader script
  /// is not found.
  static Future<WasmModule> initialize({required String jsPath}) async {
    if (!isLoaderScriptPresent()) {
      throw StateError(
        '''
        Wasm loader script not found. Please add the following script tag to your web/index.html file:
        <script src="https://cdn.jsdelivr.net/gh/robmllze/df_wasm_interop@v0.1.0/loader/loader.js"></script> <!-- Replace with your actual repo/version -->
        ''',
      );
    }

    try {
      // Call the `loadModule` function from our JS loader.
      await _loadModule(jsPath.toJS).toDart;

      // After loading, retrieve the module's exports.
      final moduleInstance = _getModule(jsPath.toJS);

      if (moduleInstance == null) {
        throw Exception(
            'Failed to get Wasm module instance for: $jsPath. The module might have failed to initialize.');
      }

      // The `moduleInstance` is the JSObject we need.
      // We can create a Dart object that holds it.
      return WasmModule._(instance: moduleInstance);
    } catch (e) {
      // Propagate errors from JS.
      throw Exception('Failed to initialize Wasm module from $jsPath: ${e.toString()}');
    }
  }

  // Private constructor is now valid because `instance` is a regular field.
  const WasmModule._({required this.instance});
}

// Private JS interop bindings to the functions in `loader.js`. These are unchanged.

@JS('window.flutter_wasm_interop.loadModule')
external JSPromise<JSAny?> _loadModule(JSString jsPath);

@JS('window.flutter_wasm_interop.getModule')
external JSObject? _getModule(JSString jsPath);

@JS('window.flutter_wasm_interop')
external JSObject? get _loader;

/// Checks if the `loader.js` script has been loaded and initialized.
bool isLoaderScriptPresent() => _loader != null;
