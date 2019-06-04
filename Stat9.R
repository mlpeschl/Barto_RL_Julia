#4

library(ggplot2)
library(gridExtra)
df1 <- data.frame(sample = sort(rnorm(10)),
                  probs = seq(0.1,1,0.1))

p1 <- ggplot(df1, aes(x = sample,y = probs)) + 
    geom_step(aes(color = "black")) +
    stat_function(fun = pnorm, aes(x = sample,color = "red"), size = 1) + 
    scale_color_manual(name =  "",values = c("black" , "red"),
                       labels = c("Ecdf","Cdf"))


df2 <- data.frame(sample = sort(rnorm(100)),
                  probs = seq(0.01,1,0.01))


p2 <- ggplot(df2, aes(x = sample,y = probs)) + 
  geom_step(aes(color = "black")) +
  stat_function(fun = pnorm, aes(x = sample,color = "red"), size = 1) + 
  scale_color_manual(name =  "",values = c("black" , "red"),
                     labels = c("Ecdf","Cdf"))

grid.arrange(p1, p2, ncol=2)


#5

data <- c(138,164,150,132,144,125,149,157,146,158,140,147,136,
          148,152,144,168,126,138,176,163,119,154,165,146,173,
          142,147,135,153,140,135,161,145,135,142,150,156,145,128)
stem(data)
table(data)
summary(data)
var(data)
sd(data)

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

getmode(data)


#6

data <- c(0,2,0,0,1,3,0,3,1,1,0,0,1,2,00,0,1,1,3,0,1,0,0,0,5,1,0,2,0)
table(data)
df <- data.frame(cumsum(table(data)))
qplot(x = c(0,1,2,3,5), y = df$cumsum.table.data.., geom = "step", ylab = "cumsum")
median(data)
quantile(data,0.6)


#7
data <- c(117,140,107,102, 95, 132,163,123,103,144,123,92,
          89,102,112,115,123,130,102,119,100,106,115,145,115,
          108,122,113,153,116,120,113,140,117,119,121,130,114,
          107,125,123,91,120,125,125,103,133,102,131,147,108,
          89,118,119,114,119,81,85,122,94,96,118,119,98,105)


data <- sort(data)
summary(data)
range(data)
getmode(data)
IQR(data)

hist(data)
df <- data.frame(cumsum(table(data)))

qplot(x = unique(data), y = df$cumsum.table.data.., geom = "step", ylab = "cumsum")


#Skewness = E(((X-mu)/sigma)^3)
mean(((data-mean(data))/sd(data))^3)

#Kurtosis = E(((X-mu)/sigma)^4)
mean(((data-mean(data))/sd(data))^4)
#Nvm: see Wikipedia... Kurtosis = m4/m2^2 - 3
#fuck it: using package

library(e1071)
kurtosis(data)
skewness(data)

boxplot(data)




#8
x <- c(5,12 ,14,17,23 ,30 ,40 ,47 ,55 ,67 ,72 ,81 ,96 ,112,127)
y <- c(4,10,13,15,15,25,27,46,38,46,53,70,82,99,100)
data <- data.frame(x = x, y = y)

ggplot(data, aes(x,y)) + geom_point()


xhat = mean(x)
yhat = mean(y)
sx = sd(x)
sy = sd(y)
sxy = cov(x,y)
cxy = cor(x,y)

a <- sxy/(sx^2)
b <- yhat - a*xhat

linearf <- function(x)
{
 return(a*x+b)
}

ggplot(data, aes(x,y)) + geom_point() + stat_function(fun = linearf)


error <- sum((y-(a*x+b))^2)
error




#9
data(trees)
ggplot(trees,aes(x = Girth, y = Volume)) + geom_point()+ geom_smooth(method='lm',formula=y~x, color = "red") + geom_smooth(method='lm',formula = y ~ poly(x, 2))

corxy <- cor(x,y)
corxy
