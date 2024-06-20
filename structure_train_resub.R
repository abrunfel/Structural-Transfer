# Load packages and df.reg.el --------------------------------------------------
library(tidyverse)
library(readxl)
#df.reg = read_xls('//Volumes//mnl//Data//UURAF Projects//UURAF 2019 Structural Learning and Transfer//struct_learn_paper//regData.xls',
df.reg = read_xls('C:\\Users\\abrun\\OneDrive - Georgetown University\\Strxfer Manuscript\\resub JMB 2023\\R1-2024\\figures\\regData.xls',
                     col_names = c("Subject", "beta.ide", "pval.ide",
                                   "beta.rmse", "pval.rmse",
                                   "beta.mt", "pval.mt",
                                   "beta.mov_int", "pval.mov_int",
                                   "beta.norm_jerk", "pval.norm_jerk"))

#df.reg.el = read_xls('//Volumes//mnl//Data//UURAF Projects//UURAF 2019 Structural Learning and Transfer//struct_learn_paper//regDataEL.xls',
df.reg.el = read_xls('C:\\Users\\abrun\\OneDrive - Georgetown University\\Strxfer Manuscript\\resub JMB 2023\\R1-2024\\figures\\regDataEL.xls',
                col_names = c("Subject", "Time", "beta.ide", "pval.ide",
                              "beta.rmse", "pval.rmse",
                              "beta.mt", "pval.mt",
                              "beta.mov_int", "pval.mov_int",
                              "beta.norm_jerk", "pval.norm_jerk"))
df.reg.el$Time = as.factor(df.reg.el$Time)
df.reg.el$Time = recode_factor(df.reg.el$Time, '1' = "Early", '2' = "Late")

# Add Study factor
df.reg = df.reg %>% mutate(Study = case_when(nchar(Subject) < 3 ~ "Transfer",
                                             nchar(Subject) == 3 ~ "Replication")) %>%
  relocate(Study, .after = Subject)
df.reg$Study = as.factor(df.reg$Study)

df.reg.el = df.reg.el %>% mutate(Study = case_when(nchar(Subject) < 3 ~ "Transfer",
                                                   nchar(Subject) == 3 ~ "Replication")) %>%
  relocate(Study, .after = Subject)
df.reg.el$Study = as.factor(df.reg.el$Study)

# Keep or remove "Replication" Study
study = readline(prompt = "Do you want to include 'Replication' Study (y/n)? ")
if (study == "N" | study == "n"){
  df.reg = subset(df.reg, !Study %in% "Replication")
  df.reg.el = subset(df.reg.el, !Study %in% "Replication")
}
# Full Training t-tests ---------------------------------------------------
# ide
t.test(df.reg$beta.ide, mu = 0)

# Early vs. Late t-tests -----------------------------------------------------------------
# ide
t.test(subset(df.reg.el, Time == "Early")$beta.ide, subset(df.reg.el, Time == "Late")$beta.ide, paired = T)
# rmse
t.test(subset(df.reg.el, Time == "Early")$beta.rmse, subset(df.reg.el, Time == "Late")$beta.rmse, paired = T)
# mt
t.test(subset(df.reg.el, Time == "Early")$beta.mt, subset(df.reg.el, Time == "Late")$beta.mt, paired = T)
# mov_int
t.test(subset(df.reg.el, Time == "Early")$beta.mov_int, subset(df.reg.el, Time == "Late")$beta.mov_int, paired = T)
# norm_jerk
t.test(subset(df.reg.el, Time == "Early")$beta.norm_jerk, subset(df.reg.el, Time == "Late")$beta.norm_jerk, paired = T)


# Follow-up tests ---------------------------------------------------------
t.test(subset(df.reg.el, Time == "Early")$beta.ide, mu = 0) # to get mean and 95% CI
t.test(subset(df.reg.el, Time == "Late")$beta.ide, mu = 0) # to get mean and 95% CI

# Early vs. Late Plots -------------------------------------------------------------------
ggplot(data = df.reg.el, aes(x = Time, y = beta.ide, color = Time))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.25)

ggplot(data = df.reg.el, aes(x = Time, y = beta.rmse, color = Time))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.25)

ggplot(data = df.reg.el, aes(x = Time, y = beta.mt, color = Time))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.25)

ggplot(data = df.reg.el, aes(x = Time, y = beta.mov_int, color = Time))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.25)

ggplot(data = df.reg.el, aes(x = Time, y = beta.norm_jerk, color = Time))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(width = 0.25)

