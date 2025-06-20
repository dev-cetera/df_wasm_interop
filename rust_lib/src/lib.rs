use wasm_bindgen::prelude::*;

// This function is now callable from JS/Dart.
#[wasm_bindgen]
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[wasm_bindgen]
pub fn is_answer_forty_two(x: i32) -> bool {
    x == 42
}