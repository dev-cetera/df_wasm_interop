(() => {
  const interop = {
    _modules: new Map(),
    async loadModule(jsPath) {
      if (this._modules.has(jsPath)) {
        return;
      }
      try {
        const absoluteJsPath = new URL(jsPath, document.baseURI).href;
        const module = await import(absoluteJsPath);
        const absoluteWasmPath = new URL(
          jsPath.replace(/\.js$/, '_bg.wasm'),
          document.baseURI
        ).href;

        await module.default(absoluteWasmPath);
        
        this._modules.set(jsPath, module);
        console.log(`Successfully loaded WASM module from: ${absoluteJsPath}`);

      } catch (e) {
        console.error(`Failed to load WASM module from ${jsPath}:`, e);
        throw e;
      }
    },
    getModule(jsPath) {
      return this._modules.get(jsPath);
    },
  };
  window.flutter_wasm_interop = interop;
})();