<div align="center">

<pre align="center">
  ██████╗ ██████╗  █████╗ ██████╗ ███████╗██╗      █████╗ 
 ██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║     ██╔══██╗
 ██║  ███╗██████╔╝███████║██║  ██║█████╗  ██║     ███████║
 ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝  ██║     ██╔══██║
 ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗███████╗██║  ██║
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝
 ─────────────────────────────────────────────────────────
  GRADient Evaluation & Learned Academic Performance Radar 
 ─────────────────────────────────────────────────────────

                ┌── [ PREDICTION TELEMETRY ENGINE ] ──┐
                │                                     │
    [ INPUT VECTORS ]            [ DUAL NEURAL NODES ]     [ RISK RADAR ]
    ┌───────────────┐                  ╭───╮                .---.
    │ Attendance ───┼───────────╮     (  N1 )────╮         /  ▲  \
    │ Study SEI ────┼──────╮    ╰────▶ ╰───╯     │        |  / \  |
    │ Sleep Var ────┼───╮  │           ╭───╮     ├───▶   /  / τ* \ \
    │ Milestones ───┼─╮ │  ╰─────────▶(  N2 )────╯      |  / 0.38 \ |
    └───────────────┘ │ │              ╰───╯             \ '-----' /
                      ▼ ▼                                 '-------'
            ┌──────────────────┐                     CALIBRATED GAUGES
            │ [||||||||||....] │ 84.04% SENSITIVITY     [OK] [WARN] [CRIT]
            └──────────────────┘                     └───┴──────┴────┘
</pre>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=16&duration=2800&pause=900&color=F43F5E&center=true&vCenter=true&width=620&lines=Intelligent+Academic+Early-Warning+Architecture;Preemptive+Risk+Stratification+Powered+by+R;Precision+Student-Success+Interventions" alt="Typing Banner" />
</p>

<p align="center">
  <b>An end-to-end predictive machine learning framework developed in R to shift institutional advising from retroactive post-exam grading to proactive, early-term telemetry.</b>
</p>

<p align="center">
  <a href="#-system-overview"><img src="https://img.shields.io/badge/Language-R%20%3E%3D%204.2-276DC3?style=for-the-badge&logo=r&logoColor=white" alt="R" /></a>
  <a href="#-architecture--pipeline"><img src="https://img.shields.io/badge/Architecture-Random%20Forest%20%7C%20GLM-8B5CF6?style=for-the-badge&logo=probot&logoColor=white" alt="ML" /></a>
  <a href="#-empirical-evaluation--benchmarks"><img src="https://img.shields.io/badge/ROC--AUC-0.976-10B981?style=for-the-badge&logo=databricks&logoColor=white" alt="ROC-AUC" /></a>
  <a href="#-empirical-evaluation--benchmarks"><img src="https://img.shields.io/badge/Recall%20(%CF%84*)-84.04%25-EC4899?style=for-the-badge&logo=target&logoColor=white" alt="Recall" /></a>
  <a href="#-decision-boundary-tuning"><img src="https://img.shields.io/badge/%CF%84*-0.38%20Optimal-F59E0B?style=for-the-badge&logo=speedtest&logoColor=white" alt="Threshold" /></a>
  <a href="#-license"><img src="https://img.shields.io/badge/License-MIT-3B82F6?style=for-the-badge&logo=open-source-initiative&logoColor=white" alt="License" /></a>
</p>

<p align="center">
  <a href="#-system-overview">System Overview</a> •
  <a href="#-architecture--pipeline">Architecture & Pipeline</a> •
  <a href="#-feature-synthesis-study-efficiency-index-sei">Feature Synthesis</a> •
  <a href="#-empirical-evaluation--benchmarks">Empirical Results</a> •
  <a href="#-behavioral-impact--feature-importance">Feature Importance</a> •
  <a href="#-risk-stratification--advising-protocols">Advising Protocols</a> •
  <a href="#-quickstart--usage">Quickstart</a> •
  <a href="#-collaborators">Collaborators</a>
</p>

---

</div>

## 📌 System Overview

Most academic early-warning systems suffer from an institutional **latency flaw**: alerts trigger *after* midterms or assignment deadlines have failed, leaving minimal runway for recovery[cite: 2].

**GRADELA** shifts performance evaluation directly upstream into the opening weeks of the academic semester[cite: 2]:

- 🎯 **Cohort Scale:** Benchmarked on **6,607 student records** spanning **20 multidimensional telemetry vectors**[cite: 2].
- 🔍 **Target Condition:** Early isolation of students likely to fall into the lower quartile ($\text{Exam Score} \le 65$)[cite: 2].
- 🎛️ **Optimized Detection:** Decision cutoff recalibrated from the conventional $0.50$ baseline down to **$\tau^* = 0.38$**, capturing **84.04% of at-risk students** ($F_1 = 0.8658$) with an overall **ROC-AUC of 0.976**[cite: 2].
- 💡 **Actionable Focus:** Over **66% of outcome variance** is governed by modifiable behavioral routines (attendance cadence, study efficiency) rather than fixed demographic background[cite: 2].

---

## 🏗️ Architecture & Pipeline

```text
+---------------------------------------------------------------------------------------+
|                         GRADELA PREDICTIVE ENGINE PIPELINE                            |
+---------------------------------------------------------------------------------------+
                                           |
  [01 INGESTION]                           v
  +-------------------------------------------------------------------------------------+
  |  Cohort Corpus: 6,607 Student Records across 20 Telemetry Dimensions                |
  |  * Historical Baselines  * Study Pacing  * Sleep Variance  * Real-time Attendance   |
  +-------------------------------------------------------------------------------------+
                                           |
  [02 IMPUTATION]                          v
  +-------------------------------------------------------------------------------------+
  |  Structured Missingness Resolution                                                  |
  |  * Discrete / Categorical: Localized Mode Imputation                                |
  |  * Continuous Features: Min-Max Normalization & Robust Scaling                      |
  +-------------------------------------------------------------------------------------+
                                           |
  [03 FEATURE SYNTHESIS]                   v
  +-------------------------------------------------------------------------------------+
  |  Study Efficiency Index (SEI) Engine                                                |
  |  SEI = (Weekly Study Hours * Continuous Milestones) / (Sleep Variance + eps)        |
  +-------------------------------------------------------------------------------------+
                                           |
  [04 CROSS-VALIDATION]                    v
  +-------------------------------------------------------------------------------------+
  |  Stratified 10-Fold CV Matrix                                                       |
  |  [ CART Trees ]  <=====>  [ Logistic Regression ]  <=====>  [ Random Forest ]       |
  +-------------------------------------------------------------------------------------+
                                           |
  [05 TUNING (τ* = 0.38)]                  v
  +-------------------------------------------------------------------------------------+
  |  Cost-Sensitive Threshold Optimization (Target: Score <= 65)                        |
  |  Recall: 77.10% -> 84.04%  |  ROC-AUC: 0.976  |  F1: 0.8658                         |
  +-------------------------------------------------------------------------------------+
                                           |
  [06 ACTION DISPATCH]                     v
  +-------------------------------------------------------------------------------------+
  |  Automated Advising Triage Delivery                                                 |
  |  * Tier 1 (P >= 0.60): Critical Risk -> 1-on-1 Clinical Advising & Mandatory Study  |
  |  * Tier 2 (0.38 <= P < 0.60): Moderate Risk -> Peer Collaborative Learning Pods     |
  |  * Tier 3 (P < 0.38): Low Risk -> Standard Advisory Cadence                         |
  +-------------------------------------------------------------------------------------+
```
## 🎯 Behavioral Impact & Feature Importance

Decomposition of Mean Decrease in Gini Impurity underscores that behavioral habits—not unalterable demographics—steer semester outcomes:

========================================================================================
FEATURE DIMENSION                 GINI %    RELATIVE IMPACT (ACTIONABLE VS STATIC)
========================================================================================
Class Attendance Rate             36.2%     [████████████████████████████████████]
Study Efficiency Index (SEI)      29.9%     [██████████████████████████████]
Prior Assessment Milestones       14.1%     [██████████████]
Sleep Routine Consistency         9.3%      [█████████]
Socio-Demographic Indicators      6.8%      [███████]  <- Fixed Background
Other Environmental Factors       3.7%      [████]
========================================================================================
[Actionable Behavioral Vectors: 66.1%]                    [Static Demographics: 6.8%]
