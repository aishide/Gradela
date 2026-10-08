#!/usr/bin/env Rscript
# ==============================================================================
#                      G R A D E L A
#   GRADient Evaluation & Learned Academic Performance Radar
#   End-to-End Predictive Machine Learning Pipeline in R
#
#   Investigators:
#     - Aishi De       | PRN: 23070521008 | Sem 7, Sec A
#     - Parthiv Abhani | PRN: 23070521106 | Sem 7, Sec B
#   Faculty Guide: Dr. Snehlata Wankhade
#   Department: Business Intelligence, Computer Science & Engineering
# ==============================================================================

cat("\n")
cat("  ██████╗ ██████╗  █████╗ ██████╗ ███████╗██╗      █████╗ \n")
cat(" ██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║     ██╔══██╗\n")
cat(" ██║  ███╗██████╔╝███████║██║  ██║█████╗  ██║     ███████║\n")
cat(" ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝  ██║     ██╔══██║\n")
cat(" ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗███████╗██║  ██║\n")
cat("  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝\n")
cat(" ─────────────────────────────────────────────────────────\n")
cat("  GRADient Evaluation & Learned Academic Performance Radar \n")
cat(" ─────────────────────────────────────────────────────────\n\n")

start_time <- Sys.time()
cat(sprintf(">>> Master Execution Initialized at: %s\n\n", format(start_time, "%Y-%m-%d %H:%M:%S")))

# Verify and execute Stage 1: Preprocessing & Imputation
cat(">>> [STAGE 1/5] Ingesting Cohort & Imputing Missing Values...\n")
source("R/01_data_preprocessing.R")

# Verify and execute Stage 2: Feature Synthesis & SEI Engine
cat("\n>>> [STAGE 2/5] Synthesizing Study Efficiency Index (SEI) & Interaction Vectors...\n")
source("R/02_feature_engineering.R")

# Verify and execute Stage 3: Supervised Modeling Suite & Score Regression
cat("\n>>> [STAGE 3/5] Benchmarking Classifiers & Continuous Regressor...\n")
source("R/03_model_training.R")

# Verify and execute Stage 4: Decision Boundary Tuning (tau* = 0.38)
cat("\n>>> [STAGE 4/5] Calibrating Cost-Sensitive Decision Boundary (tau* = 0.38)...\n")
source("R/04_threshold_tuning.R")

# Verify and execute Stage 5: Alert Dispatch & Advisory Routing
cat("\n>>> [STAGE 5/5] Generating Actionable Triage Roster & Exporting Alerts...\n")
source("R/05_alert_dispatch.R")

end_time <- Sys.time()
elapsed <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)

cat("\n======================================================================\n")
cat("                  GRADELA PIPELINE EXECUTION SUMMARY                   \n")
cat("======================================================================\n")
cat(sprintf("Total Pipeline Runtime : %.2f seconds\n", elapsed))
cat("Generated Artifacts:\n")
cat("  1. data/processed/gradela_cleaned_cohort.csv      (Imputed dataset)\n")
cat("  2. data/processed/gradela_features_engineered.csv (SEI synthesized)\n")
cat("  3. models/gradela_classifier_rf.rds               (RF Classifier)\n")
cat("  4. models/gradela_regressor_rf.rds                (RF Regressor)\n")
cat("  5. models/gradela_metadata.rds                    (Pipeline Metadata)\n")
cat("  6. reports/student_risk_alerts.csv                (Full Risk Alerts)\n")
cat("  7. reports/gradela_intervention_roster.csv        (Actionable Triage)\n")
cat("  8. reports/GRADELA_IEEE_Benchmark_Table.txt       (IEEE Performance)\n")
cat("======================================================================\n")
cat("Collaborators: Aishi De (23070521008) & Parthiv Abhani (23070521106)\n")
cat("Faculty Guide: Dr. Snehlata Wankhade | Business Intelligence CA3\n")
cat("======================================================================\n\n")
