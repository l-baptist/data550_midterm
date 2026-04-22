report_config_${WHICH_CONFIG}.html: report.Rmd code/04_render_report.R figures regression
	Rscript code/04_render_report.R

figures: code/02_make_visuals.R data_prep
	Rscript code/02_make_visuals.R

regression: code/03_regression.R data_prep
	Rscript code/03_regression.R
	
data_prep: data/covid_sub.csv code/01_clean_data.R
	Rscript code/01_clean_data.R 

.PHONY: clean
clean:
	rm -f output/*.rds && rm -f output/*.png && rm -f data/*.rds && rm -f report*.html
	
.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"
    