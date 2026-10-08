# BUS 497 Term Project
# Predicting SBA loan default (charge-off): logistic regression vs. kNN
# Required packages: readxl, class
library(readxl)
library(class)

# Place "Term project data FULL SET.xlsx" in the same folder as this script
myData <- read_excel("Term project data FULL SET.xlsx",sheet = "SBA_data")
str(myData)
summary(myData)

# ---- Clean ----
myData$MIS_Status <- ifelse(myData$MIS_Status == "CHGOFF", 1, 0)
data <- myData[, !(names(myData) %in% c("LoanNr_ChkDgt", "Name"))]

data$RevLineCr <- ifelse(data$RevLineCr == "Y", 1, 0)
data$LowDoc    <- ifelse(data$LowDoc == "Y", 1, 0)

data$NewExist   <- as.factor(data$NewExist)
data$UrbanRural <- as.factor(data$UrbanRural)

stopifnot(is.numeric(data$DisbursementGross),
          is.numeric(data$GrAppv),
          is.numeric(data$SBA_Appv))

data <- data[, !(names(data) %in% c("ChgOffDate", "ChgOffPrinGr", "BalanceGross"))]

data <- na.omit(data)

cat("\nRows kept:", nrow(data), "\n")
print(table(data$MIS_Status))
print(round(prop.table(table(data$MIS_Status)), 4))
print(summary(data$DisbursementGross)) 

hist(data$DisbursementGross)
boxplot(DisbursementGross ~ MIS_Status, data = data)

set.seed(123)
n <- nrow(data)
train_index <- sample(1:n, size = 0.7 * n)
train <- data[train_index, ]
valid <- data[-train_index, ]
cat("Training rows:", nrow(train), " Validation rows:", nrow(valid), "\n")


report <- function(pred, actual, label) {
  cm <- table(Predicted = factor(pred, levels = 0:1),
              Actual    = factor(actual, levels = 0:1))
  cat("\n---", label, "---\n")
  print(cm)
  acc       <- sum(diag(cm)) / sum(cm)
  baseline  <- max(prop.table(table(actual)))
  recall    <- cm["1", "1"] / sum(cm[, "1"])
  precision <- cm["1", "1"] / sum(cm["1", ])
  cat("Accuracy:  ", round(acc * 100, 2), "%\n")
  cat("Baseline:  ", round(baseline * 100, 2), "% (always guess the majority class)\n")
  cat("Recall:    ", round(recall * 100, 2), "% (share of real defaults caught)\n")
  cat("Precision: ", round(precision * 100, 2), "% (share of flagged loans that defaulted)\n")
  invisible(cm)
}

# ---- Logistic Regression ----
logit_model <- glm(MIS_Status ~ DisbursementGross + NewExist + UrbanRural +
                     RevLineCr + LowDoc + Term + NoEmp + GrAppv + SBA_Appv,
                   data = train, family = "binomial")
summary(logit_model)

# Odds ratios (how each variable changes the odds of default)
print(round(exp(coef(logit_model)), 3))

logit_probs <- predict(logit_model, newdata = valid, type = "response")
logit_pred  <- ifelse(logit_probs > 0.5, 1, 0)
report(logit_pred, valid$MIS_Status, "Logistic Regression (full validation set)")

# ---- k-Nearest Neighbors ----
knn_vars <- c("DisbursementGross", "Term", "NoEmp", "GrAppv", "SBA_Appv",
              "RevLineCr", "LowDoc")

train_knn <- scale(train[, knn_vars])
valid_knn <- scale(valid[, knn_vars],
                   center = attr(train_knn, "scaled:center"),
                   scale  = attr(train_knn, "scaled:scale"))

set.seed(123)
tr_s <- sample(nrow(train_knn), 50000)
va_s <- sample(nrow(valid_knn), 20000)

knn_pred <- knn(train = train_knn[tr_s, ], test = valid_knn[va_s, ],
                cl = train$MIS_Status[tr_s], k = 5, use.all = FALSE)
report(as.numeric(as.character(knn_pred)), valid$MIS_Status[va_s],
       "kNN, k = 5 (50,000 training / 20,000 validation sample)")

# Logistic regression on 20,000 sample
report(logit_pred[va_s], valid$MIS_Status[va_s],
       "Logistic Regression (same 20,000-row sample)")

