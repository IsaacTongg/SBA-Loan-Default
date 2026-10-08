# SBA Loan Default Prediction

This is the R code I used for my BUS 497 term project, where I predict whether an SBA loan will be repaid or charged off. I compare two classification methods, logistic regression and k-nearest neighbors (kNN), using SBA loan data.

The best model I tested was a kNN classifier with k = 5, which achieved 89.37% accuracy on a sample of 20,000 validation loans. For reference, simply predicting that every loan would be repaid gives about 82.27% accuracy. The kNN model also correctly identified about 60% of the loans that actually defaulted, which was much better than the logistic regression model. I've included comments throughout the code explaining what each section does.

## Models

### Logistic Regression

For the logistic regression model, I used DisbursementGross, GrAppv, SBA_Appv, Term, NoEmp, NewExist, UrbanRural, RevLineCr, and LowDoc as predictors. The model was trained on 70% of the data and tested on the remaining 30%.

The model achieved 84.06% accuracy, compared to a baseline of 82.56%. Since most of the loans in the dataset were repaid, the model only identified about 20% of actual defaults using the standard 0.5 cutoff. Even though its predictive performance was limited, it was useful for understanding how different loan characteristics relate to default risk.

### k-Nearest Neighbors (kNN)

Because kNN takes a long time to run on a dataset this large, I used a random sample of 50,000 loans for training and 20,000 loans for testing. Before fitting the model, I standardized the predictors using the means and standard deviations from the training data.

To keep the comparison fair, I also evaluated the logistic regression model on the same 20,000 validation loans. On this sample, logistic regression achieved 83.78% accuracy with 19.61% recall, while kNN achieved 89.37% accuracy with 60.48% recall. Of the models I tested, kNN performed the best overall.

## Data Preparation

Before building the models, I removed ChgOffDate, ChgOffPrinGr, and BalanceGross because those variables are only filled in after a loan has already defaulted and would essentially give away the outcome. I also removed ID and name columns and dropped rows with missing values.

After cleaning the data, the final dataset contained 886,239 loans out of the original 899,164, with about 17.6% classified as charged off.

## Requirements

This project requires installing the readxl and class packages in R.

## Instructions

The dataset (Term project data FULL SET.xlsx) is not included in this repository because the file is too large for GitHub. Download it from https://github.com/IsaacTongg/SBA-Loan-Default/releases/tag/v1.0 and place it in the same folder as Term Project.R.

To run the project, set that folder as your working directory in RStudio and run Term Project.R from top to bottom. Depending on your computer, the data import and modeling steps may take a few minutes to finish.