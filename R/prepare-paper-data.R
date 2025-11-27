source("R/helpers.R")

# Extract a smaller subset of the full aggregated data for quicker loading
prepare_data_for_paper <- function(path_in, path_out) {
  stopifnot(
    length(path_in) == 1,
    length(path_out) == 1
  )

  df <- vroom::vroom(
    path_in,
    col_select = list(
      starts_with("sett_"),
      "universe_id",
      starts_with("fair_main_"),
      starts_with("perf_ovrl_")
    )
  )

  df %>%
    vroom::vroom_write(
      path_out
    )
}

# Helper: pick analysis id from env or from output/counter.txt
get_latest_analysis_id <- function() {
  # 1) allow override via environment variable, if you ever need it
  env_id <- Sys.getenv("ANALYSIS_ID", unset = NA)
  if (!is.na(env_id) && nzchar(env_id)) {
    message("Using ANALYSIS_ID from environment: ", env_id)
    return(env_id)
  }

  # 2) otherwise, read output/counter.txt (like analysis__setup.ipynb)
  counter_path <- file.path("output", "counter.txt")
  if (!file.exists(counter_path)) {
    stop(
      "output/counter.txt not found. ",
      "Run multiverse_analysis.py at least once, ",
      "or set ANALYSIS_ID in the environment."
    )
  }

  id <- trimws(readLines(counter_path, n = 1))
  message("Using ANALYSIS_ID from output/counter.txt: ", id)
  id
}

# Main Data
analysis_id <- get_latest_analysis_id()
prepare_data_for_paper(
  file.path("output", "analyses", analysis_id, "df_agg_full.csv.gz"),
  file.path("paper", "data", "df_agg_prepared.csv.gz")
)
