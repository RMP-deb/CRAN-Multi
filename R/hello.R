#' Say hello
#'
#' An example exported function. Replace or delete this file.
#'
#' @param name A single string: who to greet.
#'
#' @returns A character string containing the greeting.
#' @export
#'
#' @examples
#' hello("world")
hello <- function(name = "world") {
  if (!is.character(name) || length(name) != 1L) {
    stop("`name` must be a single string.", call. = FALSE)
  }
  paste0("Hello, ", name, "!")
}
