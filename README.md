# scRNA-seq Clinical Metadata Integration

## Overview
This repository contains an R script for integrating multi-level clinical and cellular metadata into a `Seurat` object. It is designed for Single-Cell RNA-seq (scRNA-seq) analysis, specifically structured to handle complex patient phenotypes (e.g., Multiple Sclerosis cohorts) alongside cell-level metrics.

## Objective
To safely merge sample-level clinical data (e.g., diagnosis, EDSS scores, treatment status) with cell-level data (e.g., cluster IDs, mitochondrial percentages) and seamlessly inject it into a Seurat object without losing data integrity or cell barcode matching.

## Prerequisites
Ensure you have the following R packages installed:
- `Seurat`
- `dplyr`

## Workflow Summary
1. **Define Sample-Level Metadata:** Contains patient demographics and clinical phenotypes (e.g., PPMS, Natalizumab treatment).
2. **Define Cell-Level Metadata:** Contains cell-specific quality control metrics and initial annotations.
3. **Data Integration:** Uses `dplyr::left_join` to merge both datasets based on the sample identifier (`orig.ident`).
4. **Sanity Checks:** Verifies that row counts remain consistent before and after the join.
5. **Seurat Injection:** Uses `AddMetaData()` to append the unified metadata to the Seurat object.

## Usage
Modify the `per_sample_metadata` and `per_cell_metadata` data frames in the script to match your specific study design, then run the script to update your `Seurat_Object`.
