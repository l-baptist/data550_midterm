library(tidyverse)
library(here)
library(broom)

clean_data <- readRDS(here("data", "clean_data.rds"))

dat_model <- clean_data %>%
  mutate(
    DEATH = if_else(DEATH == "Yes", 1, if_else(DEATH == "No", 0, NA_real_)),
    ICU = if_else(ICU == "Yes", 1, if_else(ICU == "No", 0, NA_real_)),
    INTUBED = if_else(INTUBED == "Yes", 1, if_else(INTUBED == "No", 0, NA_real_)),
    SEX = if_else(SEX == "male", 1, if_else(SEX == "female", 0, NA_real_)),
    PNEUMONIA = if_else(PNEUMONIA == "Yes", 1, if_else(PNEUMONIA == "No", 0, NA_real_)),
    DIABETES = if_else(DIABETES == "Yes", 1, if_else(DIABETES == "No", 0, NA_real_)),
    COPD = if_else(COPD == "Yes", 1, if_else(COPD == "No", 0, NA_real_)),
    ASTHMA = if_else(ASTHMA == "Yes", 1, if_else(ASTHMA == "No", 0, NA_real_)),
    INMSUPR = if_else(INMSUPR == "Yes", 1, if_else(INMSUPR == "No", 0, NA_real_)),
    HIPERTENSION = if_else(HIPERTENSION == "Yes", 1, if_else(HIPERTENSION == "No", 0, NA_real_)),
    CARDIOVASCULAR = if_else(CARDIOVASCULAR == "Yes", 1, if_else(CARDIOVASCULAR == "No", 0, NA_real_)),
    OBESITY = if_else(OBESITY == "Yes", 1, if_else(OBESITY == "No", 0, NA_real_)),
    RENAL_CHRONIC = if_else(RENAL_CHRONIC == "Yes", 1, if_else(RENAL_CHRONIC == "No", 0, NA_real_)),
    TOBACCO = if_else(TOBACCO == "Yes", 1, if_else(TOBACCO == "No", 0, NA_real_))
  ) %>%
  select(
    DEATH, ICU, INTUBED, AGE, SEX, PNEUMONIA, DIABETES, COPD,
    ASTHMA, INMSUPR, HIPERTENSION, CARDIOVASCULAR,
    OBESITY, RENAL_CHRONIC, TOBACCO
  ) %>%
  drop_na()

predictors <- c(
  "AGE", "SEX", "PNEUMONIA", "DIABETES", "COPD", "ASTHMA",
  "INMSUPR", "HIPERTENSION", "CARDIOVASCULAR",
  "OBESITY", "RENAL_CHRONIC", "TOBACCO"
)

valid_predictors <- predictors[
  sapply(dat_model[predictors], function(x) length(unique(x)) > 1)
]

form_icu <- as.formula(paste("ICU ~", paste(valid_predictors, collapse = " + ")))
form_intub <- as.formula(paste("INTUBED ~", paste(valid_predictors, collapse = " + ")))
form_death <- as.formula(paste("DEATH ~", paste(valid_predictors, collapse = " + ")))

mod_icu <- glm(form_icu, data = dat_model, family = binomial())
mod_intub <- glm(form_intub, data = dat_model, family = binomial())
mod_death <- glm(form_death, data = dat_model, family = binomial())

tidy_or <- function(model, outcome_name) {
  tidy(model, exponentiate = TRUE, conf.int = TRUE) %>%
    mutate(outcome = outcome_name) %>%
    select(outcome, term, estimate, conf.low, conf.high, p.value)
}

results_table <- bind_rows(
  tidy_or(mod_icu, "ICU admission"),
  tidy_or(mod_intub, "Intubation"),
  tidy_or(mod_death, "Death")
)

saveRDS(results_table, here("output", "table_regression_results.rds"))
