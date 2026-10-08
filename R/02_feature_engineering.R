# ==============================================================================
# GRADELA: GRADient Evaluation & Learned Academic Performance Radar
# Script: 02_feature_engineering.R
# Purpose: Feature Synthesis, Study Efficiency Index (SEI) Formulation,
#          Circadian Variance Modeling, and Behavioral Interaction Logic.
# Authors: Aishi De (23070521008) & Parthiv Abhani (23070521106)
# Guide: Dr. Snehlata Wankhade | Course: Business Intelligence
# ==============================================================================

suppressPackageStartupMessages({
  if (!require("tidyverse", quietly = TRUE)) install.packages("tidyverse")
  if (!require("yaml", quietly = TRUE)) install.packages("yaml")
  library(tidyverse)
  library(yaml)
})

cat("======================================================================\n")
cat(" [02 FEATURE SYNTHESIS & SEI ENGINE] Behavioral Vector Modeling...\n")
cat("======================================================================\n\n")

# 1. LOAD CONFIGURATION & CLEANED MATRICES
config_file <- "config.yml"
out_dir <- "data/processed/"
if (file.exists(config_file)) {
  cfg <- yaml::read_yaml(config_file)
  out_dir <- cfg$paths$processed_dir
}

clean_file <- file.path(out_dir, "gradela_cleaned_cohort.csv")
if (!file.exists(clean_file)) {
  clean_file <- "gradela_cleaned_cohort.csv"
}

if (!file.exists(clean_file)) {
  cat(">>> Cleaned dataset not found in processed directory. Triggering preprocessor...\n")
  source("R/01_data_preprocessing.R")
  clean_file <- file.path(out_dir, "gradela_cleaned_cohort.csv")
}

df_clean <- read.csv(clean_file, stringsAsFactors = FALSE)
cat(sprintf(">>> Loaded cleaned cohort: %d records, %d dimensions\n\n", nrow(df_clean), ncol(df_clean)))

# 2. STUDY EFFICIENCY INDEX (SEI) SYNTHESIS
# Formula: SEI = (Weekly Study Hours * Continuous Assessment Performance) / (Sleep Variance + eps)
# eps = 1e-4 stabilizer
cat(">>> Formulating Behavioral Friction Vector: Study Efficiency Index (SEI)\n")
eps <- 1e-4

df_fe <- df_clean %>%
  mutate(
    # Circadian sleep variance metric (deviation from regular 7h circadian baseline)
    sleep_variance = abs(sleep_hours - 7.0) + 0.80,
    # Study Efficiency Index: gross study hours modulated by prior score and sleep stability
    study_efficiency_index = round((hours_studied * previous_scores) / (sleep_variance + eps), 2),
    # Attendance x Tutoring interaction synergy
    attendance_tutoring_synergy = round(attendance * (tutoring_sessions + 1), 2),
    # Total Academic Engagement Index
    academic_engagement_ratio = round((hours_studied + tutoring_sessions * 2) / (sleep_hours + 1), 2)
  )

cat("    [SYNTHESIZED] 'study_efficiency_index' (SEI)\n")
cat("    [SYNTHESIZED] 'sleep_variance'\n")
cat("    [SYNTHESIZED] 'attendance_tutoring_synergy'\n")
cat("    [SYNTHESIZED] 'academic_engagement_ratio'\n\n")

# Preview SEI distribution across cohort
cat(">>> SEI Summary Statistics across Cohort:\n")
print(summary(df_fe$study_efficiency_index))
cat("\n")

# 3. EXPORT SYNTHESIZED MATRICES
out_feat_file <- file.path(out_dir, "gradela_features_engineered.csv")
write.csv(df_fe, out_feat_file, row.names = FALSE)

cat(sprintf("[EXPORT] Feature-engineered dataset written to: '%s'\n", out_feat_file))
cat("======================================================================\n\n")
