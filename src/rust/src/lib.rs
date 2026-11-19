use extendr_api::prelude::*;

/// Sum of squares (Rust example)
///
/// An example function implemented in Rust via 'extendr'. Replace or delete
/// it. Roxygen tags go in `///` doc comments and are copied into
/// `R/extendr-wrappers.R` by `devtools::document()`.
///
/// @param x A numeric vector.
///
/// @returns A single number: the sum of the squared elements of `x`.
/// @export
///
/// @examples
/// sum_squares_rust(c(1, 2, 3))
#[extendr]
fn sum_squares_rust(x: &[f64]) -> f64 {
    x.iter().map(|v| v * v).sum()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod pkgname;
    fn sum_squares_rust;
}
