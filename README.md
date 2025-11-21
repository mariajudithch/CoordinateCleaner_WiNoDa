# \# Using CoordinateCleaner to Flag Recurrent Errors in Collection Databases  

# \### \*WiNoDa School 2025 – Epiphyte Case Study\*  

# \*\*Author:\*\* Maria Judith Carmona Higuita  

# \*\*Co-instructor:\*\* Prof. Dr. Alexander Zizka (University of Marburg)

# 

# ---

# 

# \## 📘 Overview

# 

# This repository contains the materials for the WiNoDa School 2025 tutorial:

# 

# \*\*“Using CoordinateCleaner to Flag Recurrent Errors in Collection Databases: An Epiphyte Case Study”\*\*

# 

# The tutorial focuses on cleaning biodiversity occurrence data, with an emphasis on herbarium collections and epiphytic plants. Participants learn how to:

# 

# \- Download data from GBIF  

# \- Understand Darwin Core fields relevant to spatial quality  

# \- Detect common coordinate errors  

# \- Visualize problematic records  

# \- Apply automated cleaning using \*CoordinateCleaner\*  

# \- Export a cleaned dataset  

# 

# The workflow is designed to be \*\*simple, reproducible, and accessible\*\*, especially for participants new to biodiversity informatics.

# 

# ---

# 

# \## 🌐 Tutorial (HTML)

# 

# You can access the full rendered tutorial here:

# 

# 👉 \*\*https://mariajudithch.github.io/CoordinateCleaner\_WiNoDa/coordinate\_cleaner\_epiphytes.html\*\*

# 

# This online version includes navigation, collapsible code blocks, and visualizations.

# 

# ---

# 

# \## 📁 Repository Structure

# 

# ```

# CoordinateCleaner\_WiNoDa/

# │

# ├── coordinate\_cleaner\_epiphytes.qmd   # Source file (Quarto)

# ├── coordinate\_cleaner\_epiphytes.html  # Rendered tutorial (HTML)

# │

# ├── data/                              # Raw data (GBIF or example CSV)

# │   └── herbaria\_epiphytes.csv

# │

# ├── output/                            # Cleaned data exported during tutorial

# │   └── epiphytes\_cleaned\_coordinates.csv

# │

# ├── README.md                          # This file

# └── LICENSE

# ```

# 

# ---

# 

# \## 📦 Requirements

# 

# Participants need:

# 

# \- \*\*R (≥ 4.0)\*\*

# \- \*\*Quarto\*\* (optional; knitting in RStudio also works)

# \- R packages:

# &nbsp; - `CoordinateCleaner`

# &nbsp; - `rgbif`

# &nbsp; - `dplyr`

# &nbsp; - `ggplot2`

# &nbsp; - `countrycode`

# &nbsp; - `sf`

# &nbsp; - `tibble`

# &nbsp; - `readr`

# 

# To install all dependencies:

# 

# ```r

# install.packages(c(

# &nbsp; "CoordinateCleaner",

# &nbsp; "rgbif",

# &nbsp; "dplyr",

# &nbsp; "ggplot2",

# &nbsp; "countrycode",

# &nbsp; "sf",

# &nbsp; "tibble",

# &nbsp; "readr"

# ))

# ```

# 

# ---

# 

# \## 📚 Background

# 

# The tutorial is based on and enriched from:

# 

# \- The \*CoordinateCleaner\* vignette:  

# &nbsp; \*Cleaning GBIF data for the use in biogeography\*  

# &nbsp; https://ropensci.github.io/CoordinateCleaner/articles/Cleaning\_GBIF\_data\_with\_CoordinateCleaner.html

# 

# \- The original publication:  

# &nbsp; \*\*Zizka, A., Silvestro, D., Andermann, T., et al. (2019).\*\*  

# &nbsp; \*CoordinateCleaner: Standardized cleaning of occurrence records from biological collection databases.\*  

# &nbsp; \*\*Methods in Ecology and Evolution, 10\*\*, 744–751.  

# &nbsp; https://doi.org/10.1111/2041-210X.13152

# 

# ---

# 

# \## 📝 License

# 

# Distributed under the MIT License.  

# You are welcome to reuse and adapt the tutorial with appropriate credit.

# 

# ---

# 

# \## 🙌 Acknowledgments

# 

# Thanks to the WiNoDa School organizers and participants.  

# Special thanks to Prof. Dr. Alexander Zizka for co-teaching and guidance.



