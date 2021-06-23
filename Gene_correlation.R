library(ggplot2)
require(scales)
library(ggpubr)

## Gene Count in log scale ##
data<-read.table("matrix_table.txt", header=T)
a <- log10(data[,2])
b <- log10(data[,6])
#plot(a, b)
ggplot(data, aes(x=a, y=b)) + geom_point(shape=1) +
  geom_smooth(method='lm', formula= y~x, colour = "red", size = 0.3) +
  # scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  # scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  xlab("bwa-agent") +
  ylab("STAR-Standard") +
  ggtitle("Gene Count in log scale") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face="bold", size=18)) +
  stat_cor(method="spearman") 

## Gene Ranking ##
data<-read.table("matrix_rank_table.txt", header=T)
a <- data[,2]
b <- data[,6]
#plot(a, b)
ggplot(data, aes(x=a, y=b)) + geom_point(shape=1) +
  geom_smooth(method='lm', formula= y~x, colour = "red", size = 0.3) +
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  xlab("bwa-agent") +
  ylab("STAR-Standard") +
  ggtitle("Gene Ranking") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face="bold", size=18)) +
  stat_cor(method="pearson") 

