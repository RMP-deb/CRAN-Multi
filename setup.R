# One-time setup: copy this template to a new folder, then run from inside it:
#
#   Rscript setup.R mynewpkg                 # R only
#   Rscript setup.R mynewpkg --cpp           # R + C++ (Rcpp)
#   Rscript setup.R mynewpkg --rust          # R + Rust (extendr)
#   Rscript setup.R mynewpkg --cpp --rust    # R + C++ + Rust
#
# It deletes the files for the languages you didn't pick, replaces every
# "pkgname" placeholder (file contents and file names) with your package
# name, then deletes itself. Edit the remaining placeholders (First Last,
# email, USERNAME, Title, Description) by hand. See SETUP.md.

args <- commandArgs(trailingOnly = TRUE)
flags <- args[startsWith(args, "--")]
name <- args[!startsWith(args, "--")]
bad <- setdiff(flags, c("--cpp", "--rust"))
if (length(name) != 1L || length(bad) > 0L) {
  stop("Usage: Rscript setup.R <newname> [--cpp] [--rust]", call. = FALSE)
}
new <- name[[1]]
cpp <- "--cpp" %in% flags
rust <- "--rust" %in% flags

if (!grepl("^[a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9]$", new)) {
  stop("Invalid package name: use letters, numbers and '.', start with a letter, ",
       "no trailing '.' (see https://r-pkgs.org/workflow101.html#name-your-package).",
       call. = FALSE)
}
if (rust && grepl(".", new, fixed = TRUE)) {
  stop("With --rust the name is also the Rust crate name, which can't contain '.'.",
       call. = FALSE)
}

# Helpers ---------------------------------------------------------------------

drop <- function(...) unlink(c(...), recursive = TRUE)

# Remove lines matching any of the fixed strings in `patterns`.
drop_lines <- function(file, patterns) {
  if (!file.exists(file)) return(invisible())
  txt <- readLines(file, warn = FALSE)
  hit <- Reduce(`|`, lapply(patterns, function(p) grepl(p, txt, fixed = TRUE)))
  writeLines(txt[!hit], file)
}

edit_text <- function(file, from, to) {
  txt <- paste(readLines(file, warn = FALSE), collapse = "\n")
  writeLines(gsub(from, to, txt, fixed = TRUE), file)
}

# Strip languages that weren't requested --------------------------------------

if (!cpp) {
  drop("src/sum_squares_cpp.cpp", "src/RcppExports.cpp", "R/RcppExports.R",
       "man/sum_squares_cpp.Rd", "tests/testthat/test-sum_squares_cpp.R")
  edit_text("DESCRIPTION", "Imports: \n    Rcpp\n", "")
  edit_text("DESCRIPTION", "LinkingTo: \n    Rcpp\n", "")
  # Rust's R/extendr-wrappers.R carries its own @useDynLib.
  drop_lines("R/pkgname-package.R", c("@importFrom Rcpp", "@useDynLib"))
  drop_lines("NAMESPACE", c("sum_squares_cpp", "importFrom(Rcpp"))
  drop_lines("README.Rmd", "sum_squares_cpp")
}

if (!rust) {
  drop("src/rust", "src/Makevars.in", "src/Makevars.win.in", "src/pkgname-win.def",
       "configure", "configure.win", "cleanup", "cleanup.win", "tools", ".vscode",
       "R/extendr-wrappers.R", "man/sum_squares_rust.Rd",
       "tests/testthat/test-sum_squares_rust.R")
  edit_text("DESCRIPTION", "R (>= 4.2)", "R (>= 4.1.0)")
  drop_lines("DESCRIPTION", c("SystemRequirements:", "Config/rextendr/"))
  drop_lines("NAMESPACE", "sum_squares_rust")
  drop_lines("README.Rmd", "sum_squares_rust")
  drop_lines(".Rbuildignore", c("^\\.vscode$", "^src/\\.cargo$", "^src/rust/", "^src/Makevars"))
  drop_lines(".gitignore", c("src/rust/vendor", "src/Makevars"))
  drop_lines("src/.gitignore", c("target", ".cargo", "rust/vendor", "Makevars"))
  drop_lines(".github/workflows/R-CMD-check.yaml",
             c("dtolnay/rust-toolchain", "targets: ${{ runner.os"))
  # The rust-toolchain step also had a `with:` line and a blank line after it.
  wf <- ".github/workflows/R-CMD-check.yaml"
  txt <- readLines(wf)
  i <- which(txt == "        with:" & c(txt[-1], "") == "")
  if (length(i)) txt <- txt[-c(i[1], i[1] + 1L)]
  writeLines(txt, wf)
}

if (!(cpp && rust)) drop("src/init-rust.cpp")
if (rust && !cpp) invisible(file.rename("src/rust/entrypoint.c", "src/entrypoint.c"))
if (cpp && rust) drop("src/rust/entrypoint.c")
if (!cpp && !rust) {
  drop("src")
  drop_lines("NAMESPACE", "useDynLib")
}

# Rename "pkgname" -------------------------------------------------------------

files <- list.files(".", recursive = TRUE, all.files = TRUE, no.. = TRUE)
files <- files[!grepl("^(\\.git|\\.Rproj\\.user|src/rust/target|src/rust/vendor)/", files) &
                 !grepl("\\.(xz|so|o|a|dll)$", files) & files != "setup.R"]

for (f in files) {
  txt <- readLines(f, warn = FALSE)
  new_txt <- gsub("pkgname", new, txt, fixed = TRUE)
  if (!identical(txt, new_txt)) writeLines(new_txt, f)
}
for (f in files[grepl("pkgname", basename(files), fixed = TRUE)]) {
  file.rename(f, file.path(dirname(f), gsub("pkgname", new, basename(f), fixed = TRUE)))
}

# Regenerate the Rcpp glue so it matches the kept languages --------------------

if (cpp) {
  if (requireNamespace("Rcpp", quietly = TRUE)) {
    Rcpp::compileAttributes(".")
  } else {
    message("Rcpp isn't installed: install it, then run devtools::document().")
  }
}

unlink("setup.R")
langs <- c("R", if (cpp) "C++", if (rust) "Rust")
message("Set up '", new, "' with ", paste(langs, collapse = " + "), ". Next: see SETUP.md")
