library(data.table)
library(readxl)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
#work_dir <- args[1]
work_dir <- "data"

# CLIN.txt
# load clinical metadata from https://precog.stanford.edu/
clin <- readRDS(file.path('C:/Insight/data/PRECOG', 'ici_precog_all_datasets_clinical.rds'))
datasetID <-  "CheckMate_064"
clin <- clin[clin$Dataset == datasetID, ]

write.table(clin, file=file.path(work_dir, 'CLIN.txt'), sep = "\t" , quote = FALSE , row.names = FALSE)

# EXP_TPM.tsv
expr <- readRDS(file.path('C:/Insight/data/PRECOG', 'ici_precog_all_datasets_expression.rds'))
expr <- expr[grepl("_rna_064$", rownames(expr)), ]
expr <- expr[, colSums(!is.na(expr)) > 0]
expr <- t(expr)

write.table(expr, file=file.path(work_dir, 'EXP_TPM.tsv'), sep = "\t" , quote = FALSE , row.names = TRUE, col.names=TRUE)
