// web/loader.js

/**
 * df_wasm_interop v0.1.0
 *
 * A generic loader for wasm-bindgen modules that can be called from Dart.
 * This script is intended to be included in your index.html.
 */
(() => {
    // Use a well-known object on the window to avoid polluting the global scope.
    const interop = {
      // Cache for loaded modules to prevent re-fetching and re-initializing.
      _modules: new Map(),
  
      /**
       * Loads and initializes a wasm-bindgen module.
       * Dart will call this function.
       * @param {string} jsPath The path to the wasm-bindgen generated JS file.
       * @returns {Promise<void>}
       */
      async loadModule(jsPath) {
        if (this._modules.has(jsPath)) {
          console.log(`Wasm module already loaded: ${jsPath}`);
          return;
        }
  
        try {
          // Dynamically import the user's wasm-bindgen JS glue file.
          // The `import()` function returns a promise that resolves to the module's exports.
          const module = await import(jsPath);
  
          // By convention, the wasm binary is in the same directory and has a `_bg.wasm` suffix.
          // The default export of the glue file is the `init` function.
          const wasmPath = jsPath.replace(/\.js$/, '_bg.wasm');
          await module.default(wasmPath);
  
          // Store the entire module (including all its named exports) in our cache.
          this._modules.set(jsPath, module);
          console.log(`Successfully loaded and initialized Wasm module: ${jsPath}`);
        } catch (e) {
          console.error(`Failed to load Wasm module from ${jsPath}:`, e);
          throw e; // Re-throw the error so the Dart future fails.
        }
      },
  
      /**
       * Retrieves a previously loaded module's exports.
       * Dart will call this function after `loadModule` completes.
       * @param {string} jsPath The path to the wasm-bindgen generated JS file.
       * @returns {object | undefined} The module's exports.
       */
      getModule(jsPath) {
        return this._modules.get(jsPath);
      },
    };
  
    // Expose the interop object on the window.
    window.flutter_wasm_interop = interop;
  })();