# Uso:
# Rscript scripts/liberar_aula.R 3
#
# Libera, no index.qmd, as aulas até o número informado.
# O script é idempotente e pode ser executado novamente a cada aula.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || is.na(suppressWarnings(as.integer(args)))) {
  stop("Informe o número da aula, por exemplo: Rscript scripts/liberar_aula.R 3")
}

aula <- as.integer(args[[1]])
if (aula < 3 || aula > 8) stop("A aula deve estar entre 3 e 8.")

arquivo <- "index.qmd"
x <- readLines(arquivo, warn = FALSE, encoding = "UTF-8")

for (i in 3:8) {
  tag <- sprintf("%02d", i)
  start_locked <- paste0("<!-- AULA_", tag, "_START")
  end_locked <- paste0("AULA_", tag, "_END -->")
  start_open <- paste0("<!-- AULA_", tag, "_LIBERADA -->")
  end_open <- paste0("<!-- /AULA_", tag, "_LIBERADA -->")

  if (i <= aula) {
    x[x == start_locked] <- start_open
    x[x == end_locked] <- end_open
  } else {
    x[x == start_open] <- start_locked
    x[x == end_open] <- end_locked
  }
}

writeLines(x, arquivo, useBytes = TRUE)
message("Conteúdo liberado até a Aula ", sprintf("%02d", aula), ". Revise COLE_AQUI_A_URL antes de publicar.")
