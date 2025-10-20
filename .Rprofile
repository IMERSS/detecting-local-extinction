options(blogdown.hugo.version = "0.121.0")
options(blogdown.method = "markdown")

# Knit hook to prevent inline math conversion
knitr::knit_hooks$set(post_process_math = function(x, options) {
  cat("DOCUMENT HOOK CALLED\n")
  # Undo \( ... \) → $ ... $ for inline math
  x <- gsub("\\\\\\((.*?)\\\\\\)", "\\$\\1\\$", x, perl = TRUE)
  x
})

# Automatically apply hook to every chunk
knitr::opts_chunk$set(post.hook = knitr::knit_hooks$get("post_process_math"))
