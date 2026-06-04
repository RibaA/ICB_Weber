library(stringr)
library(tibble)

args <- commandArgs(trailingOnly = TRUE)
#input_dir <- args[1]
#output_dir <- args[2]
#annot_dir <- args[3]

input_dir <- "data/input"
output_dir <- "data/output"
annot_dir <- "data/annot"

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , header=TRUE )
cols <- c('Sample_ID', 'Age', "Sex", 'Responder', "ICI_Target", "Platform")

sub.clin <- cbind(clin[, cols], "Melanoma", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)
colnames(sub.clin ) <- c("patient", 'age', "sex", "response.other.info", "drug_type", "rna", "primary", "stage",
                         "recist", "os", "t.os", "pfs", "t.pfs", "rna_info", "histo", 
                         "response", "dna", "dna_info")

clin <- cbind(sub.clin , clin[, colnames(clin)[!colnames(clin) %in% colnames(sub.clin)]])

clin$sex <- ifelse(clin$sex == 'male', 'M', 'F')
clin$rna <- 'rnaseq'
clin$rna_info <- 'normalized'
clin$drug_type <- 'IO+combo'
clin$response.other.info <- ifelse(clin$response.other.info == TRUE, 1, 0)

# Define "response" based on values in "response.other.info"
clin$response <- Get_Response(data = clin) 

# Annotating Tissue Data
annotation_tissue <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv")
clin <- annotate_tissue(clin=clin, study='Weber', annotation_tissue= annotation_tissue, check_histo=FALSE)

# Set treatmentid based on curation_drug.csv file.
annotation_drug <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_drug.csv")
clin <- add_column(clin, treatmentid=clin$drug_type, .after='tissueid')

rownames(clin) <- clin$patient
write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

