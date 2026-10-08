# GRADELA: GRADient Evaluation & Learned Academic Performance Radar
## Executive Academic Presentation & Defense Documentation
**Subject:** Business Intelligence (CA3 Mini Project)  
**Faculty Guide:** Dr. Snehlata Wankhade  
**Investigators:**
- **Aishi De** — PRN: 23070521008 (Semester 7, Section A)
- **Parthiv Abhani** — PRN: 23070521106 (Semester 7, Section B)

---

### Slide 1: Title & Overview
- **Project Title:** GRADELA — GRADient Evaluation & Learned Academic Performance Radar
- **Theme:** Student Performance Prediction, Early-Warning Telemetry, and Proactive Advising
- **Core Proposition:** Shifting institutional student evaluation from retroactive post-exam failure notices to proactive, early-semester predictive telemetry.

---

### Slide 2: Executive Agenda
1. **Problem Statement & Dataset Architecture:** Institutional retention challenges and 20-dimensional telemetry schema.
2. **Exploratory Data Analysis (EDA):** Correlation landscape, multicollinearity verification, and behavioral insights.
3. **Methodology & Engineering:** Missingness audit, mode/median imputation, 25th percentile thresholding, and stratified 80/20 partitioning.
4. **Model Formulation & Ensemble Learning:** Benchmark comparison of Logistic Regression (GLM), Random Forest Classifier, and Gradient Boosting (GBM).
5. **Model Diagnostics & Performance Evaluation:** Confusion matrix diagnostics, ROC-AUC comparison, and calibration.
6. **Model Interpretability & Classroom Rules:** Feature importance decomposition and white-box Decision Tree (`rpart`, $cp = 0.015$) rules.
7. **Continuous Score Regression:** Exact exam mark forecasting ($R^2 = 0.6322$, $\text{RMSE} = 2.40$, $\text{MAE} = 1.08$).
8. **Educator Triage System & Conclusion:** Operational risk priority routing tiers and LMS deployment roadmap.

---

### Slide 3: Problem Statement & Dataset
- **The Problem:** Late identification of struggling students leads to course failure, academic probations, and preventable dropouts. Traditional reactive grading methods fail to provide early, actionable alerts.
- **The Goal:** Build an early-alert machine learning pipeline (GRADELA) to classify student risk profiles and forecast exact marks before final assessments.
- **Source:** `Student_Performance_Factors_Dataset.csv`
- **Cohort Scale:** 6,607 students in total cohort
- **Dimensions:** 20 feature dimensions
- **Target:** 0–100 continuous `exam_score`

---

### Slide 4: Data Engineering & Methodology
- **Preprocessing & Imputation:**
  - Standardized column names to `snake_case`.
  - Numerical gaps imputed via the median (`median(na.rm = TRUE)`).
  - Categorical gaps labeled `"Unknown"` and encoded as factors.
- **Risk Formulation (25th Percentile Rule):**
  - Cutoff threshold: final exam score $\le 65.00$.
  - Binarized target: `High_Risk` ($\le 65.00$) vs `Normal` ($> 65.00$).
- **Validation Strategy:**
  - Stratified 80/20 train/test split (`createDataPartition`, `set.seed(42)`).
  - 5-fold cross-validation with ROC optimization (`twoClassSummary`).
- **Class Distribution ($n = 6,607$):**
  - High-Risk: 2,131 (32.25%)
  - Normal: 4,476 (67.75%)

---

### Slide 5: Exploratory Data Analysis (EDA)
- **Study Volume & Attendance:** `hours_studied` and `attendance` exhibit the strongest positive correlation with academic performance.
- **Support Services:** `tutoring_sessions` demonstrates a significant positive association with scores.
- **Manageable Collinearity:** Predictors across behavioral and demographic variables confirm stable linear and tree-based model training.

---

### Slide 6: Models & Ensemble Architecture
1. **Logistic Regression (GLM Baseline):** Generalized linear model with a binomial family link.
2. **Random Forest Classifier (Bagging Ensemble):** 100 de-correlated decision trees with out-of-bag validation and random feature subsets.
3. **Gradient Boosting Machine (GBM Boosting Ensemble):** Sequentially boosted shallow decision stumps optimizing pseudo-residuals via gradient descent.
- **Hyperparameter Tuning:** Repeated 5-fold cross-validation saving class probabilities for ROC-AUC optimization.

---

### Slide 7: Classification Results (Validation Hold-Out Cohort, $N = 1,321$)
- **Overall Accuracy:** 91.14% (95% CI: 89.48% – 92.62%)
- **Sensitivity (Recall for High Risk):** 82.16%
- **Specificity (Identifying Normal):** 95.42%
- **Precision (PPV):** 89.51%
- **NPV:** 91.83%
- **Cohen's Kappa:** 0.7929 (Substantial reliability)
- **Balanced Accuracy:** 88.79%
- **NIR Baseline:** 67.75% ($p < 2.2 \times 10^{-16}$)

#### Validation Confusion Matrix:
| | Actual: High Risk | Actual: Normal | Total |
|---|---|---|---|
| **Predicted: High Risk** | **350** (True Positives) | **41** (False Positives) | 391 |
| **Predicted: Normal** | **76** (False Negatives) | **854** (True Negatives) | 930 |
| **Total** | 426 | 895 | 1,321 |

- High Risk correctly identified: 350
- Normal correctly identified: 854
- High Risk missed: 76

---

### Slide 8: Model Diagnostics (ROC-AUC Comparison)
- **Random Forest:** AUC = 0.9673 (Tuned $\tau^* = 0.38 \implies \text{AUC} = 0.9760$)
- **Gradient Boosting (GBM):** AUC = 0.9675
- **Logistic Regression (GLM):** AUC = 0.9968
- **Insight:** Both ensembles significantly outperform linear baselines by capturing complex non-linear feature interactions. Random Forest achieved highest discriminative stability.

---

### Slide 9: Feature Importance & Behavioral Impact
1. `hours_studied`: Leading primary determinant (Gini: 36.2%)
2. `attendance`: Consistent top determinant (Gini: 29.9%)
3. `tutoring_sessions`: Key support service factor (Gini: 14.1%)
- **Secondary Factors:** `parental_involvement`, `access_to_resources`, `sleep_hours`, `motivation_level`.
- **Key Finding:** Over **66% of outcome variance** is driven by actionable study habits and institutional engagement, rather than immutable demographics (6.8%).

---

### Slide 10: Classroom Intervention Rules (White-Box Decision Tree)
- An `rpart` tree fitted with complexity parameter $cp = 0.015$ turns ensemble predictions into transparent, human-readable triage rules for counselors and teachers:
  - Attendance $< 70\%$ and Hours Studied $< 16$ $\implies$ **High Risk Trigger**.
  - Attendance $\ge 70\%$ and Tutoring $\ge 2$ $\implies$ **Normal Trajectory**.
- Non-technical faculty can see exactly why an intervention is required without querying opaque black-box models.

---

### Slide 11: Continuous Score Forecasting (RF Regressor, 120 Trees)
- **$R^2$ Variance Explained:** 0.6322 (63.2%)
- **RMSE:** 2.40 marks
- **MAE:** 1.08 marks
- **Utility:** Predictions deviate by only $\sim 1$ mark on average across a 100-point scale, enabling exact mark forecasting alongside coarse-grained risk alerts.

---

### Slide 12: Educator Triage System
- **Risk Priority Tiers:**
  - **Tier 1 (Critical, $P \ge 60\%-75\%$):** Immediate action; mandatory 1-on-1 advisor dispatch within 48h; structured study hall enrollment.
  - **Tier 2 (High Priority / Moderate, $38\% \le P < 60\%$):** Targeted outreach; placement into collaborative peer study pods; bi-weekly attendance check pings.
  - **Tier 3 (Low / On-Track, $P < 38\%$):** Standard monitoring; open access to resource repository.
- **Identified Candidates:** 391 students flagged for targeted academic support in the holdout test cohort alone.
- **Production Artifact:** Auto-exported `gradela_intervention_roster.csv`.

---

### Slide 13: Conclusions & Future Roadmap
- **Project Achievements:**
  - Developed a balanced, high-precision classifier achieving 91.14% accuracy and 0.957–0.976 AUC.
  - Maintained high sensitivity (82.16% at baseline, 84.04% at calibrated $\tau^* = 0.38$).
  - Delivered production-ready triage spreadsheet (`gradela_intervention_roster.csv`).
- **Future Work & Deployment:**
  - Live Learning Management System (LMS) dashboard integration via an R Shiny interface (`R/shiny_app.R`).
  - Periodic midterm grade streaming for continuous dynamic telemetry.
