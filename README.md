# Data Analysis Assessment
Statistician Position at NCIRE

**Prepared by:** Rob Daniels

**Email:** rdanielsstat@gmail.com

**Date:** 10/6/2025

**For:** Drs. Kelly and Rubin, NCIRE

---

## Overview

This folder contains R scripts and associated outputs for the "Proctor Data Analysis Assessment" for the NCIRE Statistician position.

The project demonstrates data processing, descriptive statistics, table generation, and statistical comparison of treatment groups, including a permutation test.

I recommend running each script sequentially, reviewing the output, and reading the comments, which provide both the answers to the assessment questions and details on my approach to the analysis.

All required R packages are listed in `0-config.R`. The [`here`](https://cran.r-project.org/package=here) package is used for path management.

Throughout this project, I have attempted to follow best practices for reproducible workflows and project organization as presented in the [Proctor Foundation Data Science Handbook](https://proctor-ucsf.github.io/dcc-handbook/){target="_blank"}. I used ChatGPT for help with coding and phrasing. The project design, analyses, organization, methods, and presentation choices were all my own decisions.

---

## Folder Structure
```text
base folder/
├── 0-config.R                  # Project configuration (libraries, paths, settings)
├── R/
│   ├── 0-project-functions.R   # Custom functions used in the project
│   ├── 1-process-data.R        # Processes the data
│   ├── 2-describe-data.R       # Descriptive statistics
│   ├── 3-baseline-table1.R     # Creates Table 1
│   ├── 4-compare-groups.R      # Compare treatment groups; creates Table 2
│   ├── 5-permutation-test.R    # Permutation test
│   └── run-all.R               # Convenience script to run all steps sequentially
├── tables/                     # Output tables (Table 1 and Table 2)
├── figures/                    # Output figures
└── data/final/                 # Input study data files
```
---

## How to Run the Analysis

You can reproduce the analysis in three different ways:

**Option 1: Sequential run using an R Project with `here()`**

- Create a new R Project in the base folder (where the unzipped files are located).
- The `0-config.R` script uses the `here()` package to manage paths, so with the project file in place you should be able to run scripts without editing paths manually.
- Once the project is set up, run the scripts in the following order:

```text
R/1-process-data.R
R/2-describe-data.R
R/3-baseline-table1.R
R/4-compare-groups.R
R/5-permutation-test.R
```

**Option 2: Run scripts sequentially and manually update folder paths**
  
- Open each script in the `R/` folder and run them one by one in the order above.
- If you do not use an R Project and the `here()` package, you will need to manually edit the file paths at the top of each script to match your local folder structure.

**Option 3: Use the master script**

- Run `R/run-all.R` to execute the full workflow sequentially.
- This script outputs results to the R console, Plots pane, and Viewer window.