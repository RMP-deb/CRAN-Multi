#include <Rcpp.h>
using namespace Rcpp;

//' Sum of squares (C++ example)
//'
//' An example function implemented in C++ via 'Rcpp'. Replace or delete
//' this file. Roxygen comments use `//'` and are copied into
//' `R/RcppExports.R` by `Rcpp::compileAttributes()` / `devtools::document()`.
//'
//' @param x A numeric vector.
//'
//' @returns A single number: the sum of the squared elements of `x`.
//' @export
//'
//' @examples
//' sum_squares_cpp(c(1, 2, 3))
// [[Rcpp::export]]
double sum_squares_cpp(NumericVector x) {
  double total = 0;
  for (R_xlen_t i = 0; i < x.size(); ++i) {
    total += x[i] * x[i];
  }
  return total;
}
