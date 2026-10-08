# ==============================================================================
# GRADELA: GRADient Evaluation & Learned Academic Performance Radar
# Script: 01_data_preprocessing.R
# Purpose: Cohort Ingestion, Missingness Audit, Mode/Median Imputation,
#          Risk Formulation (25th Percentile Rule), and Stratified Partitioning.
# Authors: Aishi De (23070521008) & Parthiv Abhani (23070521106)
# Guide: Dr. Snehlata Wankhade | Course: Business Intelligence
# ==============================================================================

suppressPackageStartupMessages({
  if (!require("tidyverse", quietly = TRUE)) install.packages("tidyverse")
  if (!require("caret", quietly = TRUE)) install.packages("caret")
  if (!require("yaml", quietly = TRUE)) install.packages("yaml")
  library(tidyverse)
  library(caret)
  library(yaml)
})

cat("======================================================================\n")
cat(" [01 INGESTION & PREPROCESSING] Starting GRADELA Data Pipeline...\n")
cat("======================================================================\n\n")

# 1. LOAD CONFIGURATION
config_file <- "config.yml"
if (file.exists(config_file)) {
  cfg <- yaml::read_yaml(config_file)
  raw_path    <- cfg$paths$raw_data
  out_dir     <- cfg$paths$processed_dir
  seed_val    <- cfg$pipeline$random_seed
  split_ratio <- cfg$pipeline$train_split_ratio
  risk_pct    <- cfg$pipeline$risk_quantile_cutoff
} else {
  raw_path    <- "data/raw/Student_Performance_Factors_Dataset.csv"
  out_dir     <- "data/processed/"
  seed_val    <- 42
  split_ratio <- 0.80
  risk_pct    <- 0.25
}

# Resolve input dataset file with resilient fallback
if (!file.exists(raw_path)) {
  fallback_candidates <- c(
    "Student_Performance_Factors_Dataset.csv",
    "Gradela-main/Student_Performance_Factors_Dataset.csv",
    "../Student_Performance_Factors_Dataset.csv"
  )
  for (cand in fallback_candidates) {
    if (file.exists(cand)) {
      raw_path <- cand
      break
    }
  }
}

if (!file.exists(raw_path)) {
  stop(sprintf("[ERROR] Raw dataset not found at: %s", raw_path))
}

cat(sprintf(">>> Ingesting raw student cohort corpus: '%s'\n", raw_path))
df_raw <- read.csv(raw_path, stringsAsFactors = FALSE)
cat(sprintf("    Total Records: %d | Feature Dimensions: %d\n\n", nrow(df_raw), ncol(df_raw)))

# 2. STANDARDIZE COLUMN NAMES TO SNAKE_CASE
names(df_raw) <- tolower(gsub("[ .]", "_", names(df_raw)))
cat(">>> Standardized all feature headers to snake_case.\n")

target_col <- grep("exam_score", names(df_raw), value = TRUE)
if (length(target_col) == 0) {
  target_col <- names(df_raw)[ncol(df_raw)]
}
cat(sprintf("    Identified Target Outcome Vector: '%s'\n\n", target_col))

# 3. STRUCTURED MISSINGNESS AUDIT & IMPUTATION
cat(">>> Executing Missingness Audit & Value Imputation:\n")
missing_summary <- colSums(is.na(df_raw) | df_raw == "")
missing_cols <- missing_summary[missing_summary > 0]
if (length(missing_cols) > 0) {
  for (col in names(missing_cols)) {
    cat(sprintf("    - Column '%s': %d missing cells detected\n", col, missing_cols[[col]]))
  }
} else {
  cat("    - No missing values initially flagged.\n")
}

# Impute numerical features with median and categorical with 'Unknown'
df_clean <- df_raw %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .))) %>%
  mutate(across(where(is.character), ~ ifelse(is.na(.) | trimws(.) == "", "Unknown", trimws(.)))) %>%
  mutate(across(where(is.character), as.factor))

cat("    [SUCCESS] Numerical gaps resolved via median(na.rm=TRUE);\n")
cat("    [SUCCESS] Categorical gaps tagged as 'Unknown' and converted to factors.\n\n")

# 4. RISK FORMULATION (25TH PERCENTILE THRESHOLDING)
risk_threshold <- as.numeric(quantile(df_clean[[target_col]], risk_pct, na.rm = TRUE))
cat(sprintf(">>> Risk Cutoff Formulation (25th Percentile Rule): <= %.2f marks\n", risk_threshold))

df_model <- df_clean %>%
  mutate(
    risk_status = factor(
      ifelse(.data[[target_col]] <= risk_threshold, "High_Risk", "Normal"),
      levels = c("High_Risk", "Normal")
    )
  )

class_counts <- table(df_model$risk_status)
cat(sprintf("    - High_Risk Cohort : %d (%.2f%%)\n", class_counts["High_Risk"], (class_counts["High_Risk"] / nrow(df_model)) * 100))
cat(sprintf("    - Normal Cohort    : %d (%.2f%%)\n\n", class_counts["Normal"], (class_counts["Normal"] / nrow(df_model)) * 100))

# 5. STRATIFIED PARTITIONING (80/20 SPLIT)
set.seed(seed_val)
train_idx <- createDataPartition(df_model$risk_status, p = split_ratio, list = FALSE)

train_cohort <- df_model[train_idx, ]
test_cohort  <- df_model[-train_idx, ]

cat(sprintf(">>> Stratified Partitioning Completed (Seed: %d, Split: %.0f/%.0f):\n", seed_val, split_ratio * 100, (1 - split_ratio) * 100))
cat(sprintf("    - Training Partition : %d records\n", nrow(train_cohort)))
cat(sprintf("    - Holdout Validation : %d records\n\n", nrow(test_cohort)))

# 6. EXPORT INTERMEDIATE MATRICES
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

write.csv(df_clean, file.path(out_dir, "gradela_cleaned_cohort.csv"), row.names = FALSE)
write.csv(train_cohort, file.path(out_dir, "train_cohort.csv"), row.names = FALSE)
write.csv(test_cohort, file.path(out_dir, "test_cohort.csv"), row.names = FALSE)

cat(sprintf("[EXPORT] Saved cleaned cohort matrices to '%s'\n", out_dir))
cat("======================================================================\n\n")
