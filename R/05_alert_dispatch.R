# ==============================================================================
# GRADELA: GRADient Evaluation & Learned Academic Performance Radar
# Script: 05_alert_dispatch.R
# Purpose: Automated Educator Triage Dispatch, Advisory Routing Protocols,
#          and Production Batch Telemetry Scoring Engine.
# Authors: Aishi De (23070521008) & Parthiv Abhani (23070521106)
# Guide: Dr. Snehlata Wankhade | Course: Business Intelligence
# ==============================================================================

suppressPackageStartupMessages({
  if (!require("tidyverse", quietly = TRUE)) install.packages("tidyverse")
  if (!require("randomForest", quietly = TRUE)) install.packages("randomForest")
  if (!require("caret", quietly = TRUE)) install.packages("caret")
  if (!require("yaml", quietly = TRUE)) install.packages("yaml")
  library(tidyverse)
  library(randomForest)
  library(caret)
  library(yaml)
})

cat("======================================================================\n")
cat(" [05 EDUCATOR TRIAGE & ALERT DISPATCH] Operational Advisory Engine...\n")
cat("======================================================================\n\n")

# 1. LOAD CONFIGURATION
config_file <- "config.yml"
models_dir  <- "models/"
reports_dir <- "reports/"

if (file.exists(config_file)) {
  cfg <- yaml::read_yaml(config_file)
  models_dir  <- cfg$paths$models_dir
  reports_dir <- cfg$paths$reports_dir
}

dir.create(reports_dir, showWarnings = FALSE, recursive = TRUE)

test_file <- "data/processed/test_cohort.csv"
if (!file.exists(test_file)) {
  test_file <- "test_cohort.csv"
}

clf_file <- file.path(models_dir, "gradela_classifier_rf.rds")
reg_file <- file.path(models_dir, "gradela_regressor_rf.rds")

if (!file.exists(clf_file) || !file.exists(test_file)) {
  cat(">>> Model artifacts or test partitions missing. Running previous stages...\n")
  source("R/03_model_training.R")
}

clf_model <- readRDS(clf_file)
test_df   <- read.csv(test_file, stringsAsFactors = TRUE)

test_features <- test_df %>% select(-all_of(c("exam_score", "risk_status")))
prob_rf <- predict(clf_model, test_features, type = "prob")$High_Risk

# 2. POPULATE TRIAGE ROSTER WITH PRIMARY RISK DRIVER & ACTIONS
cat(">>> Synthesizing Telemetry Advisory Roster across Test Cohort (N =", nrow(test_df), ")...\n")

triage_df <- test_df %>%
  mutate(
    risk_probability = round(as.numeric(prob_rf), 4),
    risk_tier = case_when(
      risk_probability >= 0.60 ~ "High Risk (Tier 1)",
      risk_probability >= 0.38 ~ "Moderate Risk (Tier 2)",
      TRUE ~ "Low Risk (Tier 3)"
    ),
    primary_driver = case_when(
      attendance < 72 ~ "Severe Attendance Deficit",
      hours_studied < 18 ~ "Insufficient Study Volume",
      tutoring_sessions == 0 & previous_scores < 70 ~ "Lack of Tutoring Support",
      sleep_hours < 6 | sleep_hours > 9 ~ "Circadian Irregularity",
      motivation_level == "Low" ~ "Low Academic Motivation",
      TRUE ~ "Multivariate Risk Factor"
    ),
    recommended_intervention = case_when(
      risk_probability >= 0.60 ~ "Immediate 1-on-1 Clinical Advising within 48h; Mandatory Study Hall",
      risk_probability >= 0.38 ~ "Assignment to Peer Collaborative Learning Pod; Bi-Weekly Attendance Ping",
      TRUE ~ "Standard Curriculum Monitoring; Self-Directed Academic Portal Access"
    )
  )

# Extract and display top flagged students
flagged_students <- triage_df %>%
  filter(risk_probability >= 0.38) %>%
  arrange(desc(risk_probability))

cat(sprintf(">>> Total Students Flagged for Active Intervention (tau* >= 0.38): %d\n\n", nrow(flagged_students)))
cat(">>> Top 5 High-Priority Candidates Flagged by GRADELA:\n")

preview_cols <- c("risk_probability", "risk_tier", "primary_driver", "hours_studied", "attendance", "tutoring_sessions")
print(head(flagged_students %>% select(any_of(preview_cols)), 5))
cat("\n")

# 3. EXPORT ADVISORY CSV REPORTS
out_alerts <- file.path(reports_dir, "student_risk_alerts.csv")
out_roster <- file.path(reports_dir, "gradela_intervention_roster.csv")

write.csv(triage_df, out_alerts, row.names = FALSE)
write.csv(flagged_students, out_roster, row.names = FALSE)
write.csv(flagged_students, "gradela_intervention_roster.csv", row.names = FALSE)

cat(sprintf("[EXPORT] Exported full early-warning triage roster to: '%s'\n", out_alerts))
cat(sprintf("[EXPORT] Exported actionable intervention roster to:   '%s'\n\n", out_roster))

# 4. STANDALONE PRODUCTION BATCH INFERENCE FUNCTION
cat(">>> [BATCH ENGINE] Defining production inference API: run_gradela_inference()...\n")

run_gradela_inference <- function(input_csv_path, output_csv_path = "gradela_batch_scored.csv") {
  meta_file <- file.path(models_dir, "gradela_metadata.rds")
  clf_file  <- file.path(models_dir, "gradela_classifier_rf.rds")
  reg_file  <- file.path(models_dir, "gradela_regressor_rf.rds")

  if (!file.exists(clf_file) || !file.exists(meta_file)) {
    stop("Missing serialized production artifacts in models directory.")
  }

  model_clf <- readRDS(clf_file)
  model_reg <- if (file.exists(reg_file)) readRDS(reg_file) else NULL
  meta      <- readRDS(meta_file)

  raw_batch <- read.csv(input_csv_path, stringsAsFactors = FALSE)
  names(raw_batch) <- tolower(gsub("[ .]", "_", names(raw_batch)))

  clean_batch <- raw_batch %>%
    mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .))) %>%
    mutate(across(where(is.character), ~ ifelse(is.na(.) | trimws(.) == "", "Unknown", trimws(.))))

  # Align factor levels
  for (f_col in names(meta$factor_levels)) {
    if (f_col %in% names(clean_batch)) {
      clean_batch[[f_col]] <- factor(clean_batch[[f_col]], levels = meta$factor_levels[[f_col]])
    }
  }

  eval_features <- as.data.frame(clean_batch[, meta$feature_names])
  prob_mat <- predict(model_clf, eval_features, type = "prob")
  prob_v   <- if ("High_Risk" %in% colnames(prob_mat)) prob_mat[, "High_Risk"] else prob_mat[, 1]
  pred_v   <- ifelse(prob_v >= 0.38, "High_Risk", "Normal")

  scored_batch <- clean_batch %>%
    mutate(
      gradela_risk_probability  = round(as.numeric(prob_v), 4),
      gradela_predicted_status  = pred_v,
      gradela_intervention_tier = case_when(
        gradela_risk_probability >= 0.60 ~ "Tier 1: High Risk (Mandatory 1-on-1 Advising)",
        gradela_risk_probability >= 0.38 ~ "Tier 2: Moderate Risk (Peer Study Pods)",
        TRUE ~ "Tier 3: Low Risk (Standard Curriculum)"
      )
    )

  if (!is.null(model_reg)) {
    scored_batch$gradela_predicted_exam_score <- round(as.numeric(predict(model_reg, eval_features)), 2)
  }

  write.csv(scored_batch, output_csv_path, row.names = FALSE)
  cat(sprintf("[SUCCESS] Batch inference completed. Scored %d records -> '%s'\n", nrow(scored_batch), output_csv_path))
  return(invisible(scored_batch))
}

# Create sample validation batch
sample_batch <- test_df[1:min(25, nrow(test_df)), test_features %>% names()]
write.csv(sample_batch, "sample_new_cohort.csv", row.names = FALSE)
cat("[SAMPLE] Created 'sample_new_cohort.csv' (25 records) for batch scoring validation.\n")
cat("======================================================================\n\n")
