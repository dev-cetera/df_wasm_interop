// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

// A static interop class representing the Wasm module's exports.
@JS()
@staticInterop
class RustApi {}

// Extension methods that match the function signatures in your Rust code.
extension RustApiExtension on RustApi {
  // Corresponds to: `pub fn greet(name: &str) -> String`
  external bool is_answer_forty_two();

  // Corresponds to: `pub fn add(a: i32, b: i32) -> i32`
  external int add(int a, int b);
}
