# 📘 Cluster Randomized Trial Analysis

**Author:** Rob Daniels, MS, MPH, CPH  
**Email:** rdanielsstat@gmail.com  

This repository contains a fully reproducible analysis workflow for a **cluster randomized trial (CRT)**, demonstrating best practices in statistical programming, project organization, and reproducible research.

The project includes data processing, descriptive statistics, treatment-group comparisons using **generalized estimating equations (GEE) and linear models**, and a permutation test that accounts for clustering. It is designed to demonstrate clear workflow structure and proper statistical methods for analyzing CRT data in R.

A Quarto file was also created that walks through the analysis end-to-end and can be accessed here: [schisto-cluster-analysis](https://rdanielsstat.github.io/schisto-cluster-analysis/). The R scripts provide additional technical details and remain the best way to work through the analysis step by step.

---

## Overview

This project demonstrates:

- Clean and modular data processing  
- Descriptive statistics and baseline characterization  
- Construction of publication-quality tables  
- Treatment-group comparisons using methods appropriate for clustered data  
- A **cluster-aware permutation test**, implemented from first principles  
- A reproducible, well-organized R workflow using modern tools

All packages required to run the analysis are listed in `0-config.R`.  
The `here` package is used for robust path management and project organization.

The project structure and workflow reflect best practices in reproducible data science (modular scripts, literate comments, consistent naming, and output separation).

---

## Folder Structure
```text
base folder/
├── 0-config.R                  # Libraries, global settings, path configuration
├── R/
│   ├── 0-project-functions.R   # Custom functions used throughout the workflow
│   ├── 1-process-data.R        # Data cleaning and preparation
│   ├── 2-describe-data.R       # Descriptive summaries and exploratory analysis
│   ├── 3-baseline-table1.R     # Construction of baseline Table 1
│   ├── 4-compare-groups.R      # Treatment comparisons (cluster-aware)
│   ├── 5-permutation-test.R    # Cluster-level permutation test
│   └── run-all.R               # Convenience script to run the full workflow
├── tables/                     # Generated tables (e.g., baseline & comparison)
├── figures/                    # Generated plots/figures
└── data/final/                 # Input data files (cleaned or analysis-ready)
```
---

## ▶️ How to Run the Analysis

You can reproduce the analysis in three ways:

---

### **Option 1: Recommended – Use an R Project with here()**

1. Create an R Project (`.Rproj`) in the base folder.  
2. Install required packages (`0-config.R` lists them).  
3. Run the scripts in the following sequence:

```text
R/1-process-data.R
R/2-describe-data.R
R/3-baseline-table1.R
R/4-compare-groups.R
R/5-permutation-test.R
```

Paths will resolve automatically using `here()`.

### **Option 2: Manual Script Execution**

If not using an R Project:

1. Open each script in the `R/` folder.  
2. Update file paths at the top of each script to match your machine.  
3. Run scripts in the sequence listed above.

### **Option 3: Run the Entire Workflow at Once**

Use the master script:

`R/run-all.R`

This executes the complete workflow sequentially and outputs tables, figures, and console results.

---

## 📌 Notes

- The project is structured to reflect modern, reproducible data science practices.  
- All analyses and code organization choices were made intentionally to demonstrate principled statistical workflow, clear documentation, and reproducible design.  
- No external dependencies beyond standard R packages are required.