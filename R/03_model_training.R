# ==============================================================================
# GRADELA: GRADient Evaluation & Learned Academic Performance Radar
# Script: 03_model_training.R
# Purpose: Supervised Model Suite Training (GLM, Random Forest, GBM, CART)
#          and Continuous Exam Score Regression (RF Regressor 120 trees).
# Authors: Aishi De (23070521008) & Parthiv Abhani (23070521106)
# Guide: Dr. Snehlata Wankhade | Course: Business Intelligence
# ==============================================================================

suppressPackageStartupMessages({
  if (!require("tidyverse", quietly = TRUE)) install.packages("tidyverse")
  if (!require("caret", quietly = TRUE)) install.packages("caret")
  if (!require("randomForest", quietly = TRUE)) install.packages("randomForest")
  if (!require("gbm", quietly = TRUE)) install.packages("gbm")
  if (!require("pROC", quietly = TRUE)) install.packages("pROC")
  if (!require("rpart", quietly = TRUE)) install.packages("rpart")
  if (!require("rpart.plot", quietly = TRUE)) install.packages("rpart.plot")
  if (!require("yaml", quietly = TRUE)) install.packages("yaml")
  library(tidyverse)
  library(caret)
  library(randomForest)
  library(gbm)
  library(pROC)
  library(rpart)
  library(rpart.plot)
  library(yaml)
})

cat("======================================================================\n")
cat(" [03 SUPERVISED MODEL SUITE] Benchmarking Ensemble & Regression Models\n")
cat("======================================================================\n\n")

# 1. LOAD CONFIGURATION & INGEST TRAINING DATA
config_file <- "config.yml"
models_dir  <- "models/"
reports_dir <- "reports/"
seed_val    <- 42

if (file.exists(config_file)) {
  cfg <- yaml::read_yaml(config_file)
  models_dir  <- cfg$paths$models_dir
  reports_dir <- cfg$paths$reports_dir
  seed_val    <- cfg$pipeline$random_seed
}

dir.create(models_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reports_dir, showWarnings = FALSE, recursive = TRUE)
dir.create("reports/figures", showWarnings = FALSE, recursive = TRUE)

train_file <- "data/processed/train_cohort.csv"
test_file  <- "data/processed/test_cohort.csv"

if (!file.exists(train_file) || !file.exists(test_file)) {
  cat(">>> Partitions missing. Running data preprocessor...\n")
  source("R/01_data_preprocessing.R")
}

train_df <- read.csv(train_file, stringsAsFactors = TRUE)
test_df  <- read.csv(test_file, stringsAsFactors = TRUE)

target_col <- "exam_score"
risk_col   <- "risk_status"

train_features <- train_df %>% select(-all_of(c(target_col, risk_col)))
train_risk     <- train_df[[risk_col]]
train_scores   <- train_df[[target_col]]

test_features  <- test_df %>% select(-all_of(c(target_col, risk_col)))
test_risk      <- test_df[[risk_col]]
test_scores    <- test_df[[target_col]]

# Cross-Validation Configuration (5-Fold CV with ROC Optimization)
cv_ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

# 2. LOGISTIC REGRESSION (GLM BASELINE)
cat(">>> [1/5] Fitting Logistic Regression (GLM Binomial Link)...\n")
fit_glm <- suppressWarnings(
  train(
    x = train_features, y = train_risk,
    method = "glm", family = "binomial",
    metric = "ROC", trControl = cv_ctrl
  )
)

# 3. RANDOM FOREST CLASSIFIER (BAGGING ENSEMBLE - 100 TREES)
cat(">>> [2/5] Fitting Random Forest Classifier (100 De-Correlated Trees)...\n")
set.seed(seed_val)
fit_rf <- train(
  x = train_features, y = train_risk,
  method = "rf", ntree = 100,
  metric = "ROC", trControl = cv_ctrl
)

# 4. GRADIENT BOOSTING MACHINE (GBM BOOSTING ENSEMBLE)
cat(">>> [3/5] Fitting Gradient Boosting Machine (GBM)...\n")
set.seed(seed_val)
fit_gbm <- suppressWarnings(
  train(
    x = train_features, y = train_risk,
    method = "gbm", metric = "ROC",
    trControl = cv_ctrl, verbose = FALSE,
    tuneLength = 2
  )
)

# 5. CART DECISION TREE (WHITE-BOX CLASSROOM RULES)
cat(">>> [4/5] Fitting Interpretability Decision Tree (rpart cp = 0.015)...\n")
cart_data <- train_features
cart_data$risk_status <- train_risk
fit_cart <- rpart(
  risk_status ~ .,
  data = cart_data,
  method = "class",
  control = rpart.control(cp = 0.015)
)

# 6. CONTINUOUS EXAM SCORE REGRESSOR (RF REGRESSOR - 120 TREES)
cat(">>> [5/5] Fitting Continuous Exam Score Regressor (RF Regressor 120 Trees)...\n")
reg_data <- train_features
reg_data$exam_score <- train_scores
set.seed(seed_val)
fit_reg_rf <- randomForest(
  exam_score ~ .,
  data = reg_data,
  ntree = 120,
  importance = TRUE
)

# 7. MODEL EVALUATION & METRICS COMPUTATION
cat("\n>>> Evaluating Models on Holdout Test Partition (N =", nrow(test_df), ")...\n")
pred_rf   <- predict(fit_rf, test_features)
prob_rf   <- predict(fit_rf, test_features, type = "prob")$High_Risk

pred_gbm  <- predict(fit_gbm, test_features)
prob_gbm  <- predict(fit_gbm, test_features, type = "prob")$High_Risk

pred_glm  <- predict(fit_glm, test_features)
prob_glm  <- predict(fit_glm, test_features, type = "prob")$High_Risk

cm_rf <- confusionMatrix(pred_rf, test_risk, positive = "High_Risk")
cat("\n======================================================\n")
cat("          RANDOM FOREST CLASSIFICATION METRICS         \n")
cat("======================================================\n")
print(cm_rf)

# Continuous Regression Metrics
score_preds <- predict(fit_reg_rf, test_features)
reg_rmse <- sqrt(mean((test_scores - score_preds)^2))
reg_mae  <- mean(abs(test_scores - score_preds))
reg_r2   <- 1 - (sum((test_scores - score_preds)^2) / sum((test_scores - mean(test_scores))^2))

cat("\n======================================================\n")
cat("          GRADELA EXAM SCORE FORECASTING METRICS       \n")
cat("======================================================\n")
cat(sprintf("R-squared (R2)                 : %.4f (%.1f%% variance explained)\n", reg_r2, reg_r2 * 100))
cat(sprintf("Root Mean Squared Error (RMSE) : %.2f marks\n", reg_rmse))
cat(sprintf("Mean Absolute Error (MAE)      : %.2f marks\n", reg_mae))
cat("======================================================\n\n")

# 8. SERIALIZE PRODUCTION ARTIFACTS
saveRDS(fit_rf, file.path(models_dir, "gradela_classifier_rf.rds"))
saveRDS(fit_rf, file.path(models_dir, "gradela_rf_final.rds"))
saveRDS(fit_reg_rf, file.path(models_dir, "gradela_regressor_rf.rds"))

factor_levels_map <- list()
for (c_name in colnames(train_features)) {
  if (is.factor(train_features[[c_name]])) {
    factor_levels_map[[c_name]] <- levels(train_features[[c_name]])
  }
}

cohort_summary <- train_df %>%
  group_by(risk_status) %>%
  summarise(across(where(is.numeric), ~ round(mean(., na.rm = TRUE), 2)), .groups = "drop")

metadata <- list(
  risk_threshold  = 65.00,
  feature_names   = colnames(train_features),
  factor_levels   = factor_levels_map,
  cohort_baseline = cohort_summary,
  optimal_cutoff  = 0.38,
  rf_accuracy     = as.numeric(cm_rf$overall["Accuracy"]),
  rf_sensitivity  = as.numeric(cm_rf$byClass["Sensitivity"]),
  reg_r2          = reg_r2,
  reg_rmse        = reg_rmse
)
saveRDS(metadata, file.path(models_dir, "gradela_metadata.rds"))

cat(sprintf("[SAVED] Production models & metadata serialized to: '%s'\n", models_dir))
cat("======================================================================\n\n")
