use wasm_bindgen_test::*;
use parser::parse_recipe;

wasm_bindgen_test_configure!(run_in_browser);

#[wasm_bindgen_test]
fn test_parse_recipe_wasm() {
    let md = "# My Recipe";
    let result = parse_recipe(md);
    assert_eq!(result.as_string().unwrap(), "Parsed Recipe Stub");
}
