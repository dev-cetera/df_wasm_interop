import 'dart:js_interop';

/// Represents an initialized WASM module, providing access to its exported functions.
///
/// This class is a Dart-side container for a JavaScript module object. You should
/// cast the [instance] to your own `@staticInterop` type for type-safe access
/// to your WASM functions.
//
// REMOVED: @JS() and @anonymous annotations. This is now a regular Dart class.
class WasmModule {
  /// The raw JavaScript module object containing all exported functions
  /// from your WASM module.
  ///
  /// Cast this object to your custom, type-safe interop class.
  final JSObject instance;

  /// Initializes a WASM module using the `wasm-bindgen` generated JavaScript
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
        WASM loader script not found. Please add the following script tag to your web/index.html file:
        <script src="https://cdn.jsdelivr.net/gh/robmllze/df_wasm_interop@v0.1.0/web/loader.js"></script> <!-- Replace with your actual repo/version -->
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
          'Failed to get WASM module instance for: $jsPath. The module might have failed to initialize.',
        );
      }

      // The `moduleInstance` is the JSObject we need.  We can create a Dart
      //object that holds it.
      return WasmModule._(instance: moduleInstance);
    } catch (e) {
      // Propagate errors from JS.
      throw Exception('Failed to initialize WASM module from $jsPath: ${e.toString()}');
    }
  }

  // Private constructor is now valid because `instance` is a regular field.
  const WasmModule._({required this.instance});
}

@JS('window.flutter_wasm_interop.loadModule')
external JSPromise<JSAny?> _loadModule(JSString jsPath);

@JS('window.flutter_wasm_interop.getModule')
external JSObject? _getModule(JSString jsPath);

@JS('window.flutter_wasm_interop')
external JSObject? get _loader;

/// Checks if the `loader.js` script has been loaded and initialized.
bool isLoaderScriptPresent() => _loader != null;
