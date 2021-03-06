### Header material ---------
### Final set of analyses for microbe/competition theory MS
### Gaurav Kandlikar, gaurav.kandlikar@gmail.com
### Last edit: 18 April 2019  

### This file generates Figure S5.2 for Appendix S5 of the manuscript.  
rm(list = ls())
library(tidyverse)
library(patchwork)
source("figures_and_tables/core-functions.R")

# Note: The code here is similar to the code in figure_4.R.

# Make a vector of numbers from 10^-1.5 to 10^1.5,
# log-distributed.
# This vector will get used to set the values of resource replacement
# rate, to simulate a fertility gradient.
itervec <- emdbook::lseq(from = 10^-1.5, to = 10^1.5, length.out = 1000)
rhos_vec <- numeric(length(itervec))
fitdiff <- numeric(length(itervec))
rhos_c_vec <- numeric(length(itervec))
rhos_m_vec <- numeric(length(itervec))
mvec1 <- numeric(length(itervec))
mvec2 <- numeric(length(itervec))

# Attack rates vary with rl ------
# In each iteration of the following for-loop, 
# the values of the resource replacement rates r vary,
# as do the plant-microbe interaction parameters m. 
# At low values of r, the m terms are positive;
# and the m terms decline linearly with increasing r. 
# The net niche overlap and fitness difference, as well as
# the SND and FD generated by competition alone or microbes alone
# are saved.
for (ii in 1:length(itervec)) {
  parameter_vector <- c(u1l = .01*.2, u1n = .001*.2,
                        u2l = .001*.2, u2n = .01*.2,
                        mu1 = .001, mu2 = .001,
                        rl = itervec[ii], rn = itervec[ii],
                        s_l = .001, s_n = .001,
                        
                        m1A = .01  -.00004*ii, m1B = .005 -.00002*ii,
                        m2A = .005 -.00002*ii, m2B = .01  -.00004*ii,
                        
                        vA1 = 0.005, vA2 = 0, vB1 = 0, vB2 = 0.005,
                        qA = .005, qB = .005)
  outcome <- do.call(predict_interaction_outcome_RC, as.list(parameter_vector))
  rhos_vec[ii]<- outcome$rho
  fitdiff[ii]<- outcome$fitness_ratio
  rhos_c_vec[ii] <- outcome$rho_comp
  mvec1[ii] <- parameter_vector["m1A"]
  mvec2[ii] <- parameter_vector["m1B"]
  
  rhos_m_vec[ii] <- outcome$rho_micr
  print(outcome$alpha_matrix)
  
}

relative_fx <- data.frame(resource_replacement = itervec,
                          rho = rhos_vec,
                          rho_comp = rhos_c_vec,
                          rho_micr = rhos_m_vec,
                          fitdiff = fitdiff,
                          mvec1 = mvec1,
                          mvec2 = mvec2,
                          rl = itervec)
relative_fx_1 <- gather(relative_fx, which, value, rho, rho_micr, rho_comp)

# make a plot of how net niche overlap changes over
# the resource replacement gradient
figure_S5.2b <- ggplot(relative_fx_1) +
  geom_line(aes(y = value, x = resource_replacement, col = which, size = which)) +
  scale_color_manual(values = c('black',"grey25", "grey25")) + 
  scale_size_manual(values = c(1,.5,.5)) + 
  scale_x_log10() + 
  scale_y_log10() +
  theme_gsk() +
  annotate("text", x = 10^-1.5, y = .52, hjust = 0,
           label = "Microbial niche overlap", size = 3.5) + 
  annotate("text", x = 10^1.5, y = .205, hjust = 1,
           label = "Resource use niche overlap", size = 3.5) + 
  annotate("text", x = .065, y = .35, hjust = 0,
           label = "Net niche\noverlap", size = 5, fontface = "bold.italic") + 
  theme(legend.position = "none") +
  ylab(latex2exp::TeX("Niche overlap ($\\rho$)")) + 
  xlab(latex2exp::TeX("Resource replacement rates ($r_l$)")) + 
  theme(axis.title = element_text(size = 10),
        axis.text = element_text(size = 10)) 

# make a plot of how the m terms change over the resource replacement gradient
figure_S5.2a <- ggplot(relative_fx) + 
  geom_line(aes(x = rl, y = mvec1)) +
  geom_line(aes(x = rl, y = mvec2, color = "red")) + 
  theme_gsk() +
  scale_x_log10() +  
  xlab(latex2exp::TeX("Resource replacement rate ($r_l$)")) + 
  ylab(latex2exp::TeX("Plant-microbe interaction strength")) + 
  theme(axis.title = element_text(size = 9),
        legend.position = "none") + 
  annotate("text", x = .07, y = .01, hjust = 0, 
           label = latex2exp::TeX("$m_{1A}$ and $m_{2B}$")) + 
  annotate("text", x = 1, y = -.0025, hjust = 0,
           label = latex2exp::TeX("$m_{1B}$ and $m_{2A}$"),
           color = "red") + 
  geom_hline(aes(yintercept = 0), linetype = 2)

# Combine the two figures together.
figure_S5.2 <- figure_S5.2a + labs(tag = "A") +  
  figure_S5.2b + labs(tag = "B") + 
  plot_layout(widths = c(2,3))

ggsave(filename = "figures_and_tables/figures/figure_S5.22.pdf", plot = figure_S5.2, 
       height = 5, width = 10, units = "in")
