// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';

@JS()
@staticInterop
class RustApi {}

extension RustApiExtension on RustApi {
  external bool is_answer_forty_two(int x);
  external int add(int a, int b);
}
