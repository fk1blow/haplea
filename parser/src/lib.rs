use wasm_bindgen::prelude::*;
use pulldown_cmark::{Parser, Options};

#[wasm_bindgen]
pub fn parse_recipe(markdown: &str) -> JsValue {
    let parser = Parser::new_ext(markdown, Options::all());
    // TODO: Implement actual parsing logic
    JsValue::from_str("Parsed Recipe Stub")
}
