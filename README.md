# CRAN-Multi: an R package template with optional C++ and Rust

A starting point for an R package aimed at [CRAN](https://cran.r-project.org/). Every
package gets R code. You can also add compiled code in **C++** (through
[Rcpp](https://www.rcpp.org/)), in **Rust** (through [extendr](https://extendr.github.io/)),
or both. One setup command removes the parts you don't need and renames everything to
your package name.

> **This README describes the template, not your package.** `setup.R` deletes it. Your
> package's own README is generated from `README.Rmd`, which you edit later.
> For a Bioconductor package, use
> [Bioc-Multi](https://github.com/RMP-deb/Bioc-Multi) instead.

## How the template works

The repository is a complete, working package called `pkgname`, with one small
example function in each language:

| Language | Example function | Source | Test |
|---|---|---|---|
| R | `hello()` | `R/hello.R` | `tests/testthat/test-hello.R` |
| C++ | `sum_squares_cpp()` | `src/sum_squares_cpp.cpp` | `tests/testthat/test-sum_squares_cpp.R` |
| Rust | `sum_squares_rust()` | `src/rust/src/lib.rs` | `tests/testthat/test-sum_squares_rust.R` |

When you run `Rscript setup.R <name> [--cpp] [--rust]`, the script:

1. **Removes the languages you didn't pick.** It deletes their source files, tests,
   man pages and build files, and removes their entries from `DESCRIPTION`,
   `NAMESPACE`, `README.Rmd`, the `.gitignore`/`.Rbuildignore` files and the GitHub
   Actions workflow.
2. **Renames the package.** It replaces `pkgname` everywhere, in file contents and in
   file names (e.g. `pkgname.Rproj` becomes `mynewpkg.Rproj`).
3. **Regenerates the C++ glue code** if you kept C++ (`Rcpp::compileAttributes()`).
4. **Deletes itself and this README.**

What's left is a package that passes `R CMD check` with only the languages you asked
for. All four combinations (R, R + C++, R + Rust, R + C++ + Rust) are tested.

## Step by step

### 1. Install what you need

| You want | Install |
|---|---|
| Any package | R (>= 4.1), plus `install.packages(c("devtools", "roxygen2", "testthat", "knitr", "rmarkdown"))` |
| C++ | A C++ compiler (Rtools on Windows, Xcode command line tools on macOS, `build-essential` on Linux) and `install.packages("Rcpp")` |
| Rust | R (>= 4.2), the Rust toolchain from <https://rustup.rs>, and `install.packages("rextendr")` |
| Vignettes | [pandoc](https://pandoc.org/installing.html). RStudio includes a copy |

### 2. Pick a name

Check that it's free and valid: `pak::pkg_name_check("mynewpkg")`. Use letters,
numbers and `.`. If you'll use Rust, use letters and numbers only: the name is also
the Rust crate name, and crate names can't contain `.`.

### 3. Create your own copy

Pick one of these. The first two give you a new GitHub repository with a clean history.

**With the GitHub CLI**

```sh
gh repo create mynewpkg --private --template RMP-deb/CRAN-Multi --clone
cd mynewpkg
```

**On the GitHub website**: click **Use this template → Create a new repository**, then
clone the new repository and `cd` into it.

**Without GitHub**

```sh
cp -r CRAN-Multi ~/code/mynewpkg
cd ~/code/mynewpkg
rm -rf .git          # drop the template's own history
git init
```

### 4. Run the setup script (once)

From inside your copy, run **one** of these:

```sh
Rscript setup.R mynewpkg                 # R only
Rscript setup.R mynewpkg --cpp           # R + C++
Rscript setup.R mynewpkg --rust          # R + Rust
Rscript setup.R mynewpkg --cpp --rust    # R + C++ + Rust
```

It prints something like `Set up 'mynewpkg' with R + C++. Next: see SETUP.md`.

### 5. Fill in the placeholders

| File | What to change |
|---|---|
| `DESCRIPTION` | `Title`, `Description`, `Authors@R` (your name and email), `USERNAME` in `URL` and `BugReports` |
| `README.Rmd` | What the package does and an example. Render it with `devtools::build_readme()` |
| `vignettes/mynewpkg.Rmd` | A long-form introduction, or delete `vignettes/` and the knitr/rmarkdown entries in `DESCRIPTION` |
| `_pkgdown.yml` | `USERNAME`, or delete the file if you don't want a pkgdown site |
| `NEWS.md` | Your first changelog entry |

### 6. Build and check it

Open the project in RStudio (`mynewpkg.Rproj`) or any R session in the folder:

```r
devtools::document()   # generates NAMESPACE and man/ (and compiles C++/Rust code)
devtools::test()       # runs the example tests
devtools::check()      # full R CMD check
```

The first build with Rust downloads and compiles the Rust dependencies, which takes a
minute or two. Later builds are faster.

### 7. Replace the examples with your code

Delete the example functions and their tests, and write your own:

* **R**: `usethis::use_r("myfun")` and `usethis::use_test("myfun")`.
* **C++**: add `.cpp` files to `src/` and put `// [[Rcpp::export]]` above each function
  R should see.
* **Rust**: add functions to `src/rust/src/lib.rs` with `#[extendr]` and list them in the
  `extendr_module!` block.

Document everything with roxygen comments (`#'` in R, `//'` in C++, `///` in Rust),
then run `devtools::document()` again.

### 8. Commit and push

```sh
git add -A
git commit -m "Set up mynewpkg from template"
git push
```

GitHub Actions then runs `R CMD check` on macOS, Windows and Linux for every push and
pull request (`.github/workflows/R-CMD-check.yaml`).

### 9. Delete `SETUP.md` when you're done

`SETUP.md` is the detailed reference: the full file layout, C++ and Rust details,
CRAN's rules for Rust, and the release checklist. It's excluded from the package build,
so you can keep it while you work and delete it later.

## Things to know

* **C++ and Rust together**: when you add, remove or rename a Rust function, run
  `devtools::document()`, then `Rcpp::compileAttributes()`, then `devtools::document()`
  again. A single `document()` isn't enough, because Rcpp has to register the Rust
  functions too. Changes inside existing functions need just one `document()`. See
  SETUP.md section 6.
* **Adding a language later** isn't automated. Copy the matching files from a fresh copy
  of this template and adjust `DESCRIPTION` (SETUP.md lists which files belong to which
  language).
* **Folder paths with spaces** work, including for Rust builds.
* **License**: the template uses GPL (>= 3). To change it, use for example
  `usethis::use_mit_license()`.
