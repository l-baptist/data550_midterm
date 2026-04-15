library(here)
library(tidyverse)
library(ggplot2)

# Load cleaned dataset
df <- readRDS(here("data", "clean_data.rds"))

df_hosp <- df %>% filter(PATIENT_TYPE == "hospitalization")

comorbidity_vars <- c("DIABETES", "COPD", "ASTHMA", "INMSUPR",
                      "HIPERTENSION", "CARDIOVASCULAR", "OBESITY",
                      "RENAL_CHRONIC", "TOBACCO", "OTHER_DISEASE")
#------------------------------------------------------------------------
# Age group visualization
df_hosp <- df_hosp %>%
  mutate(age_group = cut(AGE,
                         breaks = c(0, 18, 40, 60, 80, Inf),
                         labels = c("<18", "18–40", "41–60", "61–80", "80+"),
                         right = TRUE))

age_summary <- df_hosp %>%
  filter(!is.na(INTUBED)) %>%
  group_by(age_group) %>%
  summarise(
    n = n(),
    intubated = sum(INTUBED == "Yes"),
    prop = intubated / n,
    lower = prop.test(intubated, n)$conf.int[1],
    upper = prop.test(intubated, n)$conf.int[2],
    .groups = "drop"
  )

p_age <- ggplot(age_summary, aes(x = age_group, y = prop)) +
  geom_col(fill = "#2C7BB6", width = 0.6) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, NA)) +
  labs(
    title = "Intubation Rate by Age Group",
    subtitle = "Among hospitalized COVID-19 patients",
    x = "Age Group",
    y = "Intubation Rate (95% CI)"
  ) +
  theme_minimal(base_size = 13)

ggsave(here("output", "fig_intubation_by_age.png"),
       plot = p_age, width = 8, height = 5, dpi = 300)

#------------------------------------------------------------------------
# Sex Visualization
sex_summary <- df_hosp %>%
  filter(!is.na(INTUBED), !is.na(SEX)) %>%
  group_by(SEX) %>%
  summarise(
    n = n(),
    intubated = sum(INTUBED == "Yes"),
    prop = intubated / n,
    lower = prop.test(intubated, n)$conf.int[1],
    upper = prop.test(intubated, n)$conf.int[2],
    .groups = "drop"
  )

p_sex <- ggplot(sex_summary, aes(x = SEX, y = prop)) +
  geom_col(fill = "#2C7BB6", width = 0.5) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.15) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, NA)) +
  labs(
    title = "Intubation Rate by Sex",
    subtitle = "Among hospitalized COVID-19 patients",
    x = "Sex",
    y = "Intubation Rate (95% CI)"
  ) +
  theme_minimal(base_size = 13)

ggsave(here("output", "fig_intubation_by_sex.png"),
       plot = p_sex, width = 6, height = 5, dpi = 300)

#------------------------------------------------------------------------
# Comorbidity category visualization 
# Lock in factor order so plot reads None → 1 → 2+
df_hosp <- df_hosp %>%
  mutate(
    across(all_of(comorbidity_vars), ~ as.integer(. == "Yes")),
    comorbidity_score = rowSums(across(all_of(comorbidity_vars)), na.rm = TRUE),
    comorbidity_cat = case_when(
      comorbidity_score == 0 ~ "None",
      comorbidity_score == 1 ~ "1",
      comorbidity_score >= 2 ~ "2+"
    ),
    comorbidity_cat = factor(comorbidity_cat, levels = c("None", "1", "2+"))
  )

comorbidity_summary <- df_hosp %>%
  filter(!is.na(INTUBED), !is.na(comorbidity_cat)) %>%
  group_by(comorbidity_cat) %>%
  summarise(
    n = n(),
    intubated = sum(INTUBED == "Yes"),
    prop = intubated / n,
    lower = prop.test(intubated, n)$conf.int[1],
    upper = prop.test(intubated, n)$conf.int[2],
    .groups = "drop"
  )

p_comorbidity <- ggplot(comorbidity_summary, aes(x = comorbidity_cat, y = prop)) +
  geom_col(fill = "#2C7BB6", width = 0.5) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.15) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, NA)) +
  labs(
    title = "Intubation Rate by Comorbidity Burden",
    subtitle = "Among hospitalized COVID-19 patients",
    x = "Number of Comorbidities",
    y = "Intubation Rate (95% CI)"
  ) +
  theme_minimal(base_size = 13)

ggsave(here("output", "fig_intubation_by_comorbidity.png"),
       plot = p_comorbidity, width = 6, height = 5, dpi = 300)
