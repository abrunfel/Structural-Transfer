library(RColorBrewer)
library(tidyverse)
library(Cairo)
library(cowplot)
setwd("Z:/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper/figures") #PC
# IDE - Testing Phase -----------------------------------------------------
siz = 3 # Used to scale the size of the data points
ggplot()+
  geom_point(data = testData_mbb, aes(x = block, y = ide.bc, color = group, shape = group), size = siz, stat = 'summary', fun.y = 'mean')+
  geom_line(data = testData_mbb, aes(x = block, y = ide.bc, group = group, color = group), size = .5, stat = 'summary', fun.y = 'mean')+
  geom_ribbon(data = subset(testData_mbb, block %in% c(1:4)), aes(x = as.numeric(block), y = ide.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Baseline
  geom_ribbon(data = subset(testData_mbb, block %in% c(5:14)), aes(x = as.numeric(block), y = ide.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Exposure
  geom_ribbon(data = subset(testData_mbb, block %in% c(15:18)), aes(x = as.numeric(block), y = ide.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Post-Exposure
  labs(y = "IDE (deg)")+
  theme_cowplot()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  guides(fill = FALSE)+
  scale_color_manual(labels = c("Control", "Structure"), values = c("#F8766D", "#00BFC4"))+
  scale_shape_manual(labels = c("Control", "Structure"), values = c(16,17))+
  geom_vline(xintercept = c(4.5, 14.5), linetype = "dotted")+
  geom_hline(yintercept = c(0), linetype = "dotted")
ggsave("ide.test.eps", plot = last_plot(), device = cairo_ps, width = 7.5, height = 4.5, units = "in")
#

# RMSE - Testing Phase -----------------------------------------------------
siz = 3 # Used to scale the size of the data points
ggplot()+
  geom_point(data = testData_mbb, aes(x = block, y = fbrmse.bc, color = group, shape = group), size = siz, stat = 'summary', fun.y = 'mean')+
  geom_line(data = testData_mbb, aes(x = block, y = fbrmse.bc, group = group, color = group), size = .5, stat = 'summary', fun.y = 'mean')+
  geom_ribbon(data = subset(testData_mbb, block %in% c(1:4)), aes(x = as.numeric(block), y = fbrmse.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Baseline
  geom_ribbon(data = subset(testData_mbb, block %in% c(5:14)), aes(x = as.numeric(block), y = fbrmse.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Exposure
  geom_ribbon(data = subset(testData_mbb, block %in% c(15:18)), aes(x = as.numeric(block), y = fbrmse.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Post-Exposure
  labs(y = "RMSE (mm)")+
  theme_cowplot()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  guides(fill = FALSE)+
  scale_color_manual(labels = c("Control", "Structure"), values = c("#F8766D", "#00BFC4"))+
  scale_shape_manual(labels = c("Control", "Structure"), values = c(16,17))+
  geom_vline(xintercept = c(4.5, 14.5), linetype = "dotted")
ggsave("rmse.test.eps", plot = last_plot(), device = cairo_ps, width = 7.5, height = 4.5, units = "in")
#

# Movement Length - Testing Phase -----------------------------------------------------
siz = 3 # Used to scale the size of the data points
ggplot()+
  geom_point(data = testData_mbb, aes(x = block, y = fbmov_int.bc, color = group, shape = group), size = siz, stat = 'summary', fun.y = 'mean')+
  geom_line(data = testData_mbb, aes(x = block, y = fbmov_int.bc, group = group, color = group), size = .5, stat = 'summary', fun.y = 'mean')+
  geom_ribbon(data = subset(testData_mbb, block %in% c(1:4)), aes(x = as.numeric(block), y = fbmov_int.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Baseline
  geom_ribbon(data = subset(testData_mbb, block %in% c(5:14)), aes(x = as.numeric(block), y = fbmov_int.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Exposure
  geom_ribbon(data = subset(testData_mbb, block %in% c(15:18)), aes(x = as.numeric(block), y = fbmov_int.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Post-Exposure
  labs(y = expression(paste(Delta, " Movement Length (cm)")))+
  theme_cowplot()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  guides(fill = FALSE)+
  scale_color_manual(labels = c("Control", "Structure"), values = c("#F8766D", "#00BFC4"))+
  scale_shape_manual(labels = c("Control", "Structure"), values = c(16,17))+
  geom_vline(xintercept = c(4.5, 14.5), linetype = "dotted")
ggsave("mov_int.test.eps", plot = last_plot(), device = cairo_ps, width = 7.5, height = 4.5, units = "in")
#

# Movement Time - Testing Phase -----------------------------------------------------
siz = 3 # Used to scale the size of the data points
ggplot()+
  geom_point(data = testData_mbb, aes(x = block, y = fbMT_c, color = group, shape = group), size = siz, stat = 'summary', fun.y = 'mean')+
  geom_line(data = testData_mbb, aes(x = block, y = fbMT_c, group = group, color = group), size = .5, stat = 'summary', fun.y = 'mean')+
  geom_ribbon(data = subset(testData_mbb, block %in% c(1:4)), aes(x = as.numeric(block), y = fbMT_c, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Baseline
  geom_ribbon(data = subset(testData_mbb, block %in% c(5:14)), aes(x = as.numeric(block), y = fbMT_c, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Exposure
  geom_ribbon(data = subset(testData_mbb, block %in% c(15:18)), aes(x = as.numeric(block), y = fbMT_c, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Post-Exposure
  labs(y = "Movement Time (s)")+
  theme_cowplot()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  guides(fill = FALSE)+
  scale_color_manual(labels = c("Control", "Structure"), values = c("#F8766D", "#00BFC4"))+
  scale_shape_manual(labels = c("Control", "Structure"), values = c(16,17))+
  geom_vline(xintercept = c(4.5, 14.5), linetype = "dotted")
ggsave("MT.test.eps", plot = last_plot(), device = cairo_ps, width = 7.5, height = 4.5, units = "in")
#

# Jerk - Testing Phase -----------------------------------------------------
siz = 3 # Used to scale the size of the data points
ggplot()+
  geom_point(data = testData_mbb, aes(x = block, y = fbnorm_jerk.bc, color = group, shape = group), size = siz, stat = 'summary', fun.y = 'mean')+
  geom_line(data = testData_mbb, aes(x = block, y = fbnorm_jerk.bc, group = group, color = group), size = .5, stat = 'summary', fun.y = 'mean')+
  geom_ribbon(data = subset(testData_mbb, block %in% c(1:4)), aes(x = as.numeric(block), y = fbnorm_jerk.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Baseline
  geom_ribbon(data = subset(testData_mbb, block %in% c(5:14)), aes(x = as.numeric(block), y = fbnorm_jerk.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Exposure
  geom_ribbon(data = subset(testData_mbb, block %in% c(15:18)), aes(x = as.numeric(block), y = fbnorm_jerk.bc, fill = group), alpha = .3, stat = 'summary', fun.data = 'mean_se')+ # Post-Exposure
  labs(y = "Norm. Jerk Score (a.u.)")+
  theme_cowplot()+
  theme(axis.text.y = element_text(size = 16),
        axis.text.x = element_text(size = 12),
        axis.title.y = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())+
  guides(fill = FALSE)+
  scale_color_manual(labels = c("Control", "Structure"), values = c("#F8766D", "#00BFC4"))+
  scale_shape_manual(labels = c("Control", "Structure"), values = c(16,17))+
  geom_vline(xintercept = c(4.5, 14.5), linetype = "dotted")
ggsave("norm_jerk.test.eps", plot = last_plot(), device = cairo_ps, width = 7.5, height = 4.5, units = "in")
#


# # IDE Bargraph - First block exp TEST PHASE --------------------------------------------
# ggplot(data = subset(testData_mbb, testData_mbb$block == 5))+
#   geom_bar(aes(x = group, y = ide.bc, fill = group), stat = "summary", fun.y = 'mean')+
#   geom_errorbar(aes(x = group, y = ide.bc), stat = 'summary', fun.data = 'mean_se', width = 0.3)+
#   geom_point(aes(x = group, y = ide.bc))+
#   scale_fill_discrete(labels = c("Control", "Structure"))+
#   labs(y = "IDE (deg)")+
#   theme_bw()+
#   theme(axis.text.y = element_text(size = 16),
#         axis.text.x = element_blank(),
#         axis.title.y = element_text(size = 20),
#         axis.title.x = element_blank(),
#         legend.title = element_blank())
# #
# 
# # Norm. Jerk Bargraph - First block exp TEST PHASE --------------------------------------------
# ggplot(data = subset(testData_mbb, testData_mbb$block == 5))+
#   geom_bar(aes(x = group, y = norm_jerk.bc, fill = group), stat = "summary", fun.y = 'mean')+
#   geom_errorbar(aes(x = group, y = norm_jerk.bc), stat = 'summary', fun.data = 'mean_se', width = 0.3)+
#   geom_point(aes(x = group, y = norm_jerk.bc))+
#   scale_fill_discrete(labels = c("Control", "Structure"))+
#   labs(y = "Norm. Jerk Score (a.u.)")+
#   theme_bw()+
#   theme(axis.text.y = element_text(size = 16),
#         axis.text.x = element_blank(),
#         axis.title.y = element_text(size = 20),
#         axis.title.x = element_blank(),
#         legend.title = element_blank())
# #
# 
# # IDE Bargraph - First block post-exp TRAIN PHASE  --------------------------------------------
# ggplot(data = subset(trainData_mbb, trainData_mbb$block %in% c(65)))+
#   geom_bar(aes(x = group, y = ide.bc, fill = group), stat = "summary", fun.y = 'mean')+
#   geom_errorbar(aes(x = group, y = ide.bc), stat = 'summary', fun.data = 'mean_se', width = 0.3)+
#   #geom_point(aes(x = group, y = ide.bc))+
#   scale_fill_discrete(labels = c("Control", "Structure"))+
#   labs(y = "IDE (deg)")+
#   theme_bw()+
#   theme(axis.text.y = element_text(size = 16),
#         axis.text.x = element_blank(),
#         axis.title.y = element_text(size = 20),
#         axis.title.x = element_blank(),
#         legend.title = element_blank())
# #