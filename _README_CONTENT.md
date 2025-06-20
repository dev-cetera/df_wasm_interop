## Summary

A modern utility to load and use wasm-bindgen modules in Flutter web apps, with support for the WasmGC (--wasm) compiler.

See this [Live Example](https://dev-cetera.github.io/df_wasm_interop/). It runs some Rust functions and was compiled with the `--wasm` flag. Here is the[ Source Code](https://github.com/dev-cetera/df_wasm_interop/tree/main/hosted_example).

## Features

- **WasmGC Compatible:** Built from the ground up for `flutter build web --wasm`.
- **Minimal Boilerplate:** A single line in your `index.html` and one function call in Dart is all you need to get started.
- **Type-Safe: Encourages using dart:** js_interop's static types for robust function calls.
- **No Manual JS:** A generic, reusable loader script handles the complexities of WASM instantiation.
- **Multi-Language Support:** Works with any language that compiles to WASM and uses wasm-bindgen (e.g., Rust, C/C++ with Emscripten).

## Quick Start Guide

Follow these steps to get your WASM module running in your Flutter app.

### Step 1: Create Your WASM Module (Rust Example)

First, build your code to a WASM module. Here is a Rust example that matches the Dart API below.

`Cargo.toml`

Make sure you have `wasm-bindgen` as a dependency and the `cdylib` crate-type.

```toml
[package]
name = "my_module"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
wasm-bindgen = "0.2"
```

`src/lib.rs`

Annotate any function you want to call from Dart with `#[wasm_bindgen]`.

```rust
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[wasm_bindgen]
pub fn is_answer_forty_two(x: i32) -> bool {
    x == 42
}
```

### Build the Module

Run `wasm-pack` to compile the code. This will create a pkg directory.

```sh
wasm-pack build --target web
```

### Step 2: Add Assets to Your Flutter Project

Copy the generated pkg directory into your Flutter project's `web/assets/` folder.

Your final file structure should look like this:

```
flutter_project/
└── web/
    ├── assets/
    │   └── my_module/
    │       ├── my_module.js
    │       └── my_module_bg.wasm
    ├── index.html
    └── loader.js <------ OPTIONAL
```

Or in Flutter, define the assets path in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - my_module/
```

### Step 3: Setup `index.html`

You must include the `loader.js` script to handle the WASM initialization.

### Option A

Add the following `<script>` tag to your `web/index.html` file:

```html
<head>
  <!-- ... -->
  <script src="https://cdn.jsdelivr.net/gh/dev-cetera/df_wasm_interop@v0.1.1/web/loader.js"></script>
</head>
```

### Option B

1. Create a new file in your Flutter project at `web/loader.js` and paste the contents of the loader script into it. You can find the official loader script here: [loader.js on GitHub](https://github.com/ev-cetera/df_wasm_interop/blob/v0.1.1/web/loader.js)

2. Add the following `<script>` tag to your `web/index.html` file:

```html
<head>
  <!-- ... -->
  <script src="loader.js"></script>
</head>
```

### Step 4: Use it in Dart

#### A. Craete a Type-Safe Wrapper

This file translates your WASM functions into a clean Dart API.

```dart
// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

@JS()
@staticInterop
class MyModule {} // leave it blank

extension MyModuleExtension on MyWasmApi {
  external int add(int a, int b);

  @protected // hide "is_answer_forty_two" from the developer
  external bool is_answer_forty_two(int x); // make sure the function signatures match exactly!

  bool isAnswerFortyTwo(int x) => is_answer_forty_two(x); // rename is_answer_forty_two
}
```

#### B. Initialize and Call from your App

```dart
MyWasmApi createMyWasmApi() {
  final module = await WasmModule.initialize(jsPath: 'assets/my_module/my_module.js');
  return module.instance as MyWasmApi;
}

void main() async {
  final api = await createMyWasmApi();
  print(api.add(1, 2));
  print(api.isAnswerFortyTwo(42));

  runApp(MyApp());
}
```
