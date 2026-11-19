// Only needed when the package has both C++ and Rust code.
//
// Rcpp::compileAttributes() generates the package's single R_init_pkgname()
// in RcppExports.cpp. It registers the Rcpp exports AND the extendr
// `wrap__*` routines (found by scanning `.Call()` in R/extendr-wrappers.R),
// so extendr's own entrypoint.c is not used. The [[Rcpp::init]] hook below
// makes R_init_pkgname() also install extendr's panic hook, so a Rust panic
// becomes an R error instead of a crash message.

#include <Rcpp.h>

extern "C" void register_extendr_panic_hook(void);

// [[Rcpp::init]]
void pkgname_init_rust(DllInfo* dll) {
  register_extendr_panic_hook();
}
