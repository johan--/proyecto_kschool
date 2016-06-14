# datos brutos 
day <- read.csv2("datos_insultos_total.csv", header = T, sep = ",")

#convertir en data table, para ver si es más rápido
library(data.table)
train <- fread("datos_insultos_total_sintextos.csv")
train<-as.data.frame(train)

colnames(train)[98] <- "hashtags"
colnames(train)[3] <- "query_name"


# inspección rápida
boxplot(day$adjetivos)
str(train$adjetivos)
boxplot(Impact ~ adjetivos ,data=train)
scatterplotMatrix(day) 
scatterplotMatrix(train)

# modelos
library(party)


fitR <- lm(Reach ~ adjetivos, data=train)
summary(fitR)

fitI <- lm(Impressions ~ query_name, data=train)
summary(fitI)



fit <- lm(Impressions ~   County + query_name + hashtags + Gender + adjetivos, data=train)
summary(fit)


fit5 <- ctree(Reach ~ adjetivos ,  data=day)
plot(fit5, main="Conditional Inference Tree",xlab="X values")



AIC(fitI, fit)

anova(fitI, fit)

