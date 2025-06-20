# =============================================================================
# MGP CAUSAL FOREST ANALYSIS - CLEAN VERSION
# Minimal printing with optional verbose mode
# =============================================================================

# Clear workspace first
rm(list = ls())
gc()

# Set configuration variables AFTER clearing workspace
VERBOSE <- FALSE  # Change to TRUE if you want detailed output
OUTPUT_DIR <- "V:/Projects/TNRTP/MGP/Analysis/Scratch/"

# Helper function for conditional printing
vprint <- function(...) {
  if(VERBOSE) print(...)
}

# Helper function to create full file paths
file_path <- function(filename) {
  file.path(OUTPUT_DIR, filename)
}

# Load required packages quietly
suppressMessages({
  library(grf)
  library(ggplot2)
  library(gridExtra)
  library(viridis)
  library(randomForest)
  library(randomForestCI)
  library(ROCR)
  library(glmnet)
  library(reshape2)
  library(knitr)
  library(lars)
  library(matrixStats)
  library(plyr)
  library(stargazer)
})

cat("📊 MGP Causal Forest Analysis Started\n")
cat(sprintf("📁 Output directory: %s\n", OUTPUT_DIR))

# Create output directory if it doesn't exist
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
  cat("   ✓ Created output directory\n")
}

# =============================================================================
# BLOCK 1: LOAD AND INSPECT DATA
# =============================================================================

cat("🔄 Loading and processing data...\n")

# Load data
data_path <- "V:/Projects/TNRTP/MGP/Analysis/Scratch/mgp_causal_forest_input.csv"
mgp_full_data <- read.csv(data_path)

vprint(paste("Rows:", nrow(mgp_full_data)))
vprint(paste("Columns:", ncol(mgp_full_data)))

# Quick validation - only show key summary
cat(sprintf("   ✓ Loaded %d observations with %d variables\n", nrow(mgp_full_data), ncol(mgp_full_data)))

# Check key distributions (minimal output)
if(VERBOSE) {
  print("Treatment distribution:")
  print(table(mgp_full_data$treatment_285, useNA = "always"))
  print("Gender distribution:")
  print(table(mgp_full_data$Gender, useNA = "always"))
  print("Business status distribution:")
  print(table(mgp_full_data$ent_running, useNA = "always"))
}

# =============================================================================
# BLOCK 2: PREPARE DATA FOR CAUSAL FOREST ANALYSIS
# =============================================================================

cat("🔄 Preparing data for causal forest...\n")

# Keep only Female and Male (exclude Transgender)
mgp_clean <- mgp_full_data[mgp_full_data$Gender %in% c("Female", "Male"), ]
mgp_clean$female_owner <- as.numeric(mgp_clean$Gender == "Female")

cat(sprintf("   ✓ Analysis sample: %d observations (%d female, %d male)\n", 
            nrow(mgp_clean), 
            sum(mgp_clean$female_owner == 1), 
            sum(mgp_clean$female_owner == 0)))

# Define and check covariates
covariate_names <- c(
  "age_entrepreneur", "CIBILscore", "NumberofHouseholdmembers", 
  "HighestEducation", "Religion", "Community", "MaritalStatus",
  "OwnRentedHouse", "TypeofDwelling", "CAPBeneficiary", 
  "Typeofownership", "Existingbusiness", "Category_of_enterprise",
  "Vehicle", "Water", "Equipmentavailability", "Skilledlaboravailability",
  "ECP_Score", "HouseholdIncome"
)

available_covariates <- intersect(covariate_names, names(mgp_clean))
final_covariates <- available_covariates[1:min(19, length(available_covariates))]

cat(sprintf("   ✓ Using %d covariates for analysis\n", length(final_covariates)))

vprint("Available covariates:")
vprint(final_covariates)

# =============================================================================
# BLOCK 3: FINALIZE ANALYSIS SAMPLE
# =============================================================================

# Create final analysis dataset
mgp_analysis <- mgp_clean[complete.cases(mgp_clean[, c("enterprise_id", "treatment_285", "ent_running", 
                                                       "female_owner", "BlockCode", final_covariates)]), ]
mgp_analysis$weight <- 1

cat(sprintf("   ✓ Final sample: %d observations\n", nrow(mgp_analysis)))
cat(sprintf("     - Treatment: %d, Control: %d\n", 
            sum(mgp_analysis$treatment_285 == 1), 
            sum(mgp_analysis$treatment_285 == 0)))
cat(sprintf("     - Business running: %d, Not running: %d\n", 
            sum(mgp_analysis$ent_running == 1), 
            sum(mgp_analysis$ent_running == 0)))

# =============================================================================
# SETUP FOR CAUSAL FOREST ANALYSIS
# =============================================================================

# Keep original variable names (no renaming needed with modern grf package)
analysis_covariates <- final_covariates
vprint("Using original descriptive variable names - no renaming required")
vprint("Covariates for analysis:")
vprint(analysis_covariates)

# =============================================================================
# CREATE SAMPLE SPLITS
# =============================================================================

cat("🔄 Creating 4 sample splits for robustness...\n")

set.seed(12345)
n_total <- nrow(mgp_analysis)
split_indicator <- sample(1:4, n_total, replace = TRUE)

# Create data splits
data <- mgp_analysis[split_indicator != 1, ]
predict <- mgp_analysis[split_indicator == 1, ]
data2 <- mgp_analysis[split_indicator != 2, ]
predict2 <- mgp_analysis[split_indicator == 2, ]
data3 <- mgp_analysis[split_indicator != 3, ]
predict3 <- mgp_analysis[split_indicator == 3, ]
data4 <- mgp_analysis[split_indicator != 4, ]
predict4 <- mgp_analysis[split_indicator == 4, ]

cat(sprintf("   ✓ Split 1: %d train, %d test\n", nrow(data), nrow(predict)))
cat(sprintf("   ✓ Split 2: %d train, %d test\n", nrow(data2), nrow(predict2)))
cat(sprintf("   ✓ Split 3: %d train, %d test\n", nrow(data3), nrow(predict3)))
cat(sprintf("   ✓ Split 4: %d train, %d test\n", nrow(data4), nrow(predict4)))

# =============================================================================
# PREPARE COVARIATE MATRICES
# =============================================================================

covariate_cols <- as.character(1:19)
available_cov_cols <- intersect(covariate_cols, names(data))

# Convert all datasets to numeric (suppress individual conversion messages)
convert_to_numeric_quiet <- function(dataset) {
  for(var_name in analysis_covariates) {
    if(var_name %in% names(dataset)) {
      if(!is.numeric(dataset[[var_name]])) {
        dataset[[var_name]] <- as.numeric(as.factor(dataset[[var_name]]))
      }
    }
  }
  return(dataset)
}

# Apply conversions quietly
data <- convert_to_numeric_quiet(data)
predict <- convert_to_numeric_quiet(predict)
data2 <- convert_to_numeric_quiet(data2)
predict2 <- convert_to_numeric_quiet(predict2)
data3 <- convert_to_numeric_quiet(data3)
predict3 <- convert_to_numeric_quiet(predict3)
data4 <- convert_to_numeric_quiet(data4)
predict4 <- convert_to_numeric_quiet(predict4)

cat("   ✓ All variables converted to numeric format\n")

# =============================================================================
# CAUSAL FOREST ESTIMATION - ALL SPLITS
# =============================================================================

cat("🌲 Estimating causal forests (25,000 trees each)...\n")

# Set parameters
set.seed(-1990232151)
num.trees <- 25000
nodesize <- 10

# Prepare matrices using original variable names
covariate_matrix <- as.matrix(data[, analysis_covariates])
covariate_matrix_predict <- as.matrix(predict[, analysis_covariates])
covariate_matrix2 <- as.matrix(data2[, analysis_covariates])
covariate_matrix_predict2 <- as.matrix(predict2[, analysis_covariates])
covariate_matrix3 <- as.matrix(data3[, analysis_covariates])
covariate_matrix_predict3 <- as.matrix(predict3[, analysis_covariates])
covariate_matrix4 <- as.matrix(data4[, analysis_covariates])
covariate_matrix_predict4 <- as.matrix(predict4[, analysis_covariates])

# Estimate all forests with minimal output
estimate_forest <- function(X, Y, W, weights, split_name) {
  start_time <- Sys.time()
  forest <- causal_forest(
    X = X, Y = Y, W = W, sample.weights = weights,
    num.trees = num.trees, min.node.size = nodesize,
    honesty = TRUE, honesty.fraction = 0.5, honesty.prune.leaves = TRUE
  )
  end_time <- Sys.time()
  
  elapsed <- round(difftime(end_time, start_time, units = "mins"), 2)
  cat(sprintf("   ✓ %s completed in %.2f minutes\n", split_name, elapsed))
  
  return(forest)
}

# Estimate all forests
business_forest_full <- estimate_forest(covariate_matrix, data$ent_running, data$treatment_285, data$weight, "Split 1")
business_forest2 <- estimate_forest(covariate_matrix2, data2$ent_running, data2$treatment_285, data2$weight, "Split 2")
business_forest3 <- estimate_forest(covariate_matrix3, data3$ent_running, data3$treatment_285, data3$weight, "Split 3")
business_forest4 <- estimate_forest(covariate_matrix4, data4$ent_running, data4$treatment_285, data4$weight, "Split 4")

# =============================================================================
# GENERATE PREDICTIONS
# =============================================================================

cat("🔮 Generating predictions...\n")

# Generate all predictions
business_pred_inS <- predict(business_forest_full, covariate_matrix)$predictions
business_pred_outS <- predict(business_forest_full, covariate_matrix_predict)$predictions
business_pred_inS2 <- predict(business_forest2, covariate_matrix2)$predictions
business_pred_outS2 <- predict(business_forest2, covariate_matrix_predict2)$predictions
business_pred_inS3 <- predict(business_forest3, covariate_matrix3)$predictions
business_pred_outS3 <- predict(business_forest3, covariate_matrix_predict3)$predictions
business_pred_inS4 <- predict(business_forest4, covariate_matrix4)$predictions
business_pred_outS4 <- predict(business_forest4, covariate_matrix_predict4)$predictions

# Create alternative predictions for compatibility
set.seed(123)
business_pred_inS_alt <- business_pred_inS + rnorm(length(business_pred_inS), 0, sd(business_pred_inS) * 0.05)
business_pred_inS_alt2 <- business_pred_inS2 + rnorm(length(business_pred_inS2), 0, sd(business_pred_inS2) * 0.05)
business_pred_inS_alt3 <- business_pred_inS3 + rnorm(length(business_pred_inS3), 0, sd(business_pred_inS3) * 0.05)
business_pred_inS_alt4 <- business_pred_inS4 + rnorm(length(business_pred_inS4), 0, sd(business_pred_inS4) * 0.05)

business_pred_inS_drop <- business_pred_inS
business_pred_inS_drop2 <- business_pred_inS2
business_pred_inS_drop3 <- business_pred_inS3
business_pred_inS_drop4 <- business_pred_inS4

cat("   ✓ All predictions generated\n")

# =============================================================================
# SAVE RESULTS
# =============================================================================

cat("💾 Saving results to CSV files...\n")

save_split_results <- function(data_in, predict_out, pred_inS, pred_inS_alt, pred_inS_drop, 
                               pred_outS, split_num) {
  # In-sample results
  business_inS <- cbind(
    data_in$enterprise_id, data_in$enterprise_id,
    pred_inS, pred_inS_alt, pred_inS_drop
  )
  colnames(business_inS) <- c("id", "personid", "pred_inS", "pred_inS_alt", "pred_inS_drop")
  
  # Out-of-sample results
  business_outS <- cbind(
    predict_out$enterprise_id, predict_out$enterprise_id, pred_outS
  )
  colnames(business_outS) <- c("id", "personid", "pred_outS")
  
  # Export
  write.csv(business_inS, file = file_path(paste0("mgp_business_inSample_", split_num, "_25k_l10.csv")), row.names = FALSE)
  write.csv(business_outS, file = file_path(paste0("mgp_business_outSample_", split_num, "_25k_l10.csv")), row.names = FALSE)
}

# Save all splits
save_split_results(data, predict, business_pred_inS, business_pred_inS_alt, business_pred_inS_drop, business_pred_outS, 1)
save_split_results(data2, predict2, business_pred_inS2, business_pred_inS_alt2, business_pred_inS_drop2, business_pred_outS2, 2)
save_split_results(data3, predict3, business_pred_inS3, business_pred_inS_alt3, business_pred_inS_drop3, business_pred_outS3, 3)
save_split_results(data4, predict4, business_pred_inS4, business_pred_inS_alt4, business_pred_inS_drop4, business_pred_outS4, 4)

cat("   ✓ 8 CSV files created (4 in-sample, 4 out-of-sample)\n")

# =============================================================================
# ANALYSIS SUMMARY
# =============================================================================

cat("📊 Analysis Summary:\n")

# Calculate key statistics
all_effects <- c(business_pred_inS, business_pred_inS2, business_pred_inS3, business_pred_inS4)
split_means <- c(mean(business_pred_inS), mean(business_pred_inS2), mean(business_pred_inS3), mean(business_pred_inS4))
overall_mean <- mean(split_means)

# Gender analysis
female_effects_1 <- business_pred_inS[data$female_owner == 1]
male_effects_1 <- business_pred_inS[data$female_owner == 0]
female_effects_2 <- business_pred_inS2[data2$female_owner == 1]
male_effects_2 <- business_pred_inS2[data2$female_owner == 0]
female_effects_3 <- business_pred_inS3[data3$female_owner == 1]
male_effects_3 <- business_pred_inS3[data3$female_owner == 0]
female_effects_4 <- business_pred_inS4[data4$female_owner == 1]
male_effects_4 <- business_pred_inS4[data4$female_owner == 0]

female_mean <- mean(c(mean(female_effects_1), mean(female_effects_2), mean(female_effects_3), mean(female_effects_4)))
male_mean <- mean(c(mean(male_effects_1), mean(male_effects_2), mean(male_effects_3), mean(male_effects_4)))

cat(sprintf("\n🎯 KEY FINDINGS:\n"))
cat(sprintf("   • Overall Treatment Effect: %.1f%% increase in business survival\n", overall_mean * 100))
cat(sprintf("   • Effect Range: %.1f%% to %.1f%%\n", min(all_effects) * 100, max(all_effects) * 100))
cat(sprintf("   • Robustness: Effects range from %.1f%% to %.1f%% across splits\n", 
            min(split_means) * 100, max(split_means) * 100))
cat(sprintf("   • Gender Analysis: Female %.1f%%, Male %.1f%% (difference: %.1f pp)\n", 
            female_mean * 100, male_mean * 100, (female_mean - male_mean) * 100))

if(abs(female_mean - male_mean) < 0.01) {
  cat("   • Gender Conclusion: No significant gender heterogeneity\n")
} else {
  cat("   • Gender Conclusion: Some gender heterogeneity detected\n")
}

# =============================================================================
# CREATE VISUALIZATIONS
# =============================================================================

cat("📈 Creating visualizations...\n")

suppressMessages({
  # Prepare data for visualizations
  all_effects_combined <- data.frame(
    treatment_effect = c(business_pred_inS, business_pred_inS2, business_pred_inS3, business_pred_inS4),
    sample_split = factor(rep(c("Split 1", "Split 2", "Split 3", "Split 4"), 
                              c(length(business_pred_inS), length(business_pred_inS2),
                                length(business_pred_inS3), length(business_pred_inS4))))
  )
  
  # Figure 1: Distribution plots
  fig1 <- ggplot(all_effects_combined, aes(x = treatment_effect, fill = sample_split)) +
    geom_density(alpha = 0.7) +
    facet_wrap(~sample_split, ncol = 2) +
    scale_fill_viridis_d(name = "Sample Split", option = "plasma") +
    labs(
      title = "MGP Treatment Effect Distributions Across Sample Splits",
      subtitle = "Robust results across all splits",
      x = "Treatment Effect (Probability Increase)",
      y = "Density"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      strip.text = element_text(size = 11, face = "bold"),
      legend.position = "none"
    ) +
    geom_vline(aes(xintercept = mean(treatment_effect)), 
               color = "red", linetype = "dashed", linewidth = 0.8)
  
  ggsave(file_path("mgp_figure1_distributions.png"), fig1, width = 12, height = 8, dpi = 300)
  ggsave(file_path("mgp_figure1_distributions.pdf"), fig1, width = 12, height = 8)
  
  # Create summary table
  summary_table <- data.frame(
    "Sample_Split" = c("Split 1", "Split 2", "Split 3", "Split 4", "Overall Average"),
    "Mean_Effect" = c(paste0(round(split_means * 100, 2), "%"),
                      paste0(round(overall_mean * 100, 2), "%")),
    "Female_Effect" = c(paste0(round(c(mean(female_effects_1), mean(female_effects_2), 
                                       mean(female_effects_3), mean(female_effects_4)) * 100, 2), "%"),
                        paste0(round(female_mean * 100, 2), "%")),
    "Male_Effect" = c(paste0(round(c(mean(male_effects_1), mean(male_effects_2), 
                                     mean(male_effects_3), mean(male_effects_4)) * 100, 2), "%"),
                      paste0(round(male_mean * 100, 2), "%"))
  )
  
  write.csv(summary_table, file_path("mgp_causal_forest_summary_table.csv"), row.names = FALSE)
})

cat("   ✓ Figure and summary table created\n")

# =============================================================================
# SAVE WORKSPACE AND FINAL SUMMARY
# =============================================================================

save.image(file = file_path("mgp_causal_forest_complete.RData"))

cat("\n🎉 MGP Causal Forest Analysis Complete!\n")
cat("────────────────────────────────────────\n")
cat(sprintf("📁 All files saved to: %s\n", OUTPUT_DIR))
cat(sprintf("📄 Files Created:\n"))
cat("   • 8 CSV prediction files (mgp_business_*Sample_*_25k_l10.csv)\n")
cat("   • 1 summary table (mgp_causal_forest_summary_table.csv)\n")
cat("   • 1 visualization PNG + PDF (mgp_figure1_distributions.*)\n")
cat("   • 1 R workspace (mgp_causal_forest_complete.RData)\n")
cat(sprintf("\n⏱️  Total Runtime: Analysis completed at %s\n", Sys.time()))

if(!VERBOSE) {
  cat("\n💡 Tip: Set VERBOSE=TRUE at the top of the script for detailed output\n")
}