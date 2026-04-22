README
================

This code renders a report showing the associations of sverable
covariate and several outcomes, using COVID-19 data from Mexico.

`data/`

- Dataset as csv

- Data dictionary as csv

Code Description

`code/01_data_clean.R`git init

- Loads and cleans data

- Filters data based on WHICH_CONFIG

- Saves cleaned dataset as a .rds object (`clean_data.rds`) in `data/`
  folder

`code/02_make_visuals`

- Reads in cleaned data

- Makes figures and saves in the `output/` folder

  - `fig_intubation_by_age.png`

  - `fig_intubation_by_sex.png`

  - `fig_intubation_by_comorbidity.png`

`code/03_regression.R`

- Creates a logistic regression model for each of the outcome variables

- Saves the results as an rds object (`table_regression_results.rds`) in
  the `output` folder

`code/render_report.R`

- Renders report.Rmd

`report.Rmd`

- Reads cleaned data created by code/data_clean.R

- Creates a descriptive table

- Reads in contents of the `results/` folder

`config.yml`

- specifies configuration settings

- Default: Only confirmed cases

- All: all confirmed and possible cases

`Makefile`

- Can be used to render the contents of the `code/` folder, including
  rendering the report

- To run the code with default settings either type `make` or
  `WHICH_CONFIG="default" make report_config_default.html` in the
  terminal

- To run the code with all cases type
  `WHICH_CONFIG="all" make report_config_all.html` in the terminal

- Use the command `make install` to restore the project library using
  renv

- Can remove .rds, .png, and .html files using the `clean` command
