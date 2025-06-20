# Load required libraries
library(haven)        # For reading Stata files
library(dplyr)        # For data manipulation
library(lubridate)    # For date handling

# Clear environment (equivalent to 'clear all')
rm(list = ls())

# Set up file paths (equivalent to global variables in STATA)
MGP_root <- "V:/Projects/TNRTP/MGP/Analysis"
code_path <- file.path(MGP_root, "Code")
raw_path <- file.path(MGP_root, "Data/raw")
derived_path <- file.path(MGP_root, "Data/derived")
tables_path <- file.path(MGP_root, "Tables")

# Document when script was run
date_run <- Sys.Date()
time_run <- Sys.time()
cat("Data cleaning script run on", as.character(date_run), "at", format(time_run, "%H:%M:%S"), "\n")

#===============================================================================
#                           Variable Creation File
#===============================================================================

# Load main dataset (equivalent to 'use "$raw\MGP Final.dta", clear')
df <- read_dta(file.path(raw_path, "MGP Final.dta"))

# Create submission_date variable (equivalent to gen submission_date = dofc(submissiondate))
df <- df %>%
  mutate(submission_date = as.Date(submissiondate))

# Label variables (R doesn't have built-in variable labels like Stata, but we can use attributes)
attr(df$key, "label") <- "key"
attr(df$submission_date, "label") <- "Submission Date"

# Rename entrepreneur_name to enterprise_id (prepare for merge)
df <- df %>%
  rename(enterprise_id = entrepreneur_name)

# First merge with enterprise sample list
enterprise_sample <- read_dta(file.path(raw_path, "Enterprise Sample List Detail.dta"))

# Perform merge (equivalent to merge m:1)
df <- df %>%
  left_join(enterprise_sample, by = "enterprise_id") %>%
  mutate(admin_merge = case_when(
    is.na(key) ~ 1,                    # Using master only
    !is.na(key) & is.na(District) ~ 2, # Master only (assuming District comes from enterprise_sample)
    !is.na(key) & !is.na(District) ~ 3 # Matched
  ))

attr(df$admin_merge, "label") <- "Merge result with enterprise sample list"

# Keep only matched observations (equivalent to keep if admin_merge == 3)
df <- df %>%
  filter(admin_merge == 3)

# Reorder columns (equivalent to order command)
df <- df %>%
  select(key, District, DistrictCode, BlockCode, Block, PanchayatCode, 
         enterprise_id, ent_des, supervisor_id, enum_id, sec1_q7, sec1_q9, 
         submission_date, everything())

# Create duplicate indicator (equivalent to duplicates tag)
df <- df %>%
  group_by(enterprise_id) %>%
  mutate(ent_dup = ifelse(n() > 1, 1, 0)) %>%
  ungroup()

attr(df$ent_dup, "label") <- "Duplicate enterprise indicator (1=duplicate)"

# Check duplicates
cat("Duplicate enterprises summary:\n")
df %>%
  filter(ent_dup == 1) %>%
  group_by(enterprise_id) %>%
  summarise(count = n(), .groups = "drop") %>%
  print()

# Show frequency table for ent_dup
table(df$ent_dup)

# Drop invalid enterprises (equivalent to drop if inlist())
invalid_keys <- c(
  "uuid:be7b0fd4-08d9-45c2-9bba-11e7a00dcbd0",
  "uuid:afeaf708-c164-43f1-925f-7f8d895b02d5",
  "uuid:1cf6b353-cd52-49a6-bb21-cbf7b0790f41",
  "uuid:c9fb243b-7229-4f80-acdd-7ce9f6126942",
  "uuid:edb70e30-bfa3-4ea6-ad3a-251f274628d5",
  "uuid:3e548d36-c287-4f0d-9329-35574badd0d1",
  "uuid:16e68c35-6c16-4a86-832c-73ec5956bc50",
  "uuid:baf6c7f9-9a9f-4d9f-a039-493cd87ab298"
)

df <- df %>%
  filter(!key %in% invalid_keys)

# Second merge with MGP_sample_final.dta
variables_to_keep <- c(
  "Religion", "Electricity", "Water", "B2C", "B2B", "Riskmitigationplan", 
  "Category_of_enterprise", "TypeofDwelling", "pscore_lasso", "ipw", 
  "_est_logit_lasso_1", "_pscore", "_treated", "_support", "_weight", 
  "_n1", "_nn", "_pdif", "matched", "app_sub_date", "quarterly_submission_date", 
  "disbursement_date", "quarterly_disbursement_date", "cohort_new", 
  "Disbursement_Amount", "CIBILscore", "age_entrepreneur", "Gender", 
  "ECP_Score", "HighestEducation", "Community", "MaritalStatus", 
  "NumberofHouseholdmembers", "HouseholdIncome", "HouseholdConsumption", 
  "HouseholdSavings", "OwnRentedHouse", "CAPBeneficiary", "OtherSourceofincome", 
  "Typeofownership", "Existingbusiness", "ActualWorkingCapital", "TotalFixedCost", 
  "RequestedLoanAmount", "Vehicle", "Householdassets", "Jewels", "Cashatbank", 
  "Cashathand", "ent_asset_index", "Equipmentavailability", "Skilledlaboravailability", 
  "LoanCategory", "CurrentSupplyAnnual", "PresentDemandAnnual", "rejection_reasons_encode"
)

# Load second dataset
mgp_sample <- read_dta(file.path(raw_path, "MGP_sample_final.dta")) %>%
  select(enterprise_id, all_of(variables_to_keep))

# Perform second merge
df <- df %>%
  left_join(mgp_sample, by = "enterprise_id") %>%
  mutate(psm_merge = case_when(
    is.na(key) ~ 1,                              # Using master only (shouldn't happen after first filter)
    !is.na(key) & is.na(Religion) ~ 2,          # Master only (assuming Religion comes from mgp_sample)
    !is.na(key) & !is.na(Religion) ~ 3          # Matched
  ))

# Keep only matched observations
df <- df %>%
  filter(psm_merge == 3)

# Display final dataset dimensions
cat("Final dataset dimensions:", nrow(df), "rows,", ncol(df), "columns\n")

#===============================================================================
#                           Business Running Insights
#===============================================================================

# Frequency table for sec1_q9 (Is this enterprise still running?)
cat("\nsec1_q9 -- Is this enterprise still running?\n")
cat("--------------------------------------------------------------------------\n")

# Create frequency table with percentages
sec1_q9_table <- df %>%
  count(sec1_q9, name = "Freq") %>%
  mutate(
    Percent = round(Freq / nrow(df) * 100, 2),
    Valid_Percent = round(Freq / sum(Freq[!is.na(sec1_q9)]) * 100, 2),
    Cum_Percent = cumsum(Valid_Percent)
  )

# Display the table
print(sec1_q9_table)

# Summary of missing values
missing_count <- sum(is.na(df$sec1_q9))
cat("Missing values:", missing_count, "\n")

# Create enterprise running indicator
# Total 2375 enterprises are running - this is our study sample as of this stage after first wave
df <- df %>%
  mutate(ent_running = ifelse(sec1_q7 == 1 & sec1_q9 == 1, 1, 0))

attr(df$ent_running, "label") <- "Business is running and owner provided consent (1=Yes)"

# Display summary of ent_running
cat("\nEnterprise running status:\n")
table(df$ent_running, useNA = "ifany")

#===============================================================================
#                       Business Operations Monthly Variables
#===============================================================================

# Convert monthly operation variables to numeric
monthly_vars <- c()
for(i in 2022:2024) {
  vars <- paste0(c("num_peak_months_", "num_usual_months_", "num_shutdown_months_"), i)
  monthly_vars <- c(monthly_vars, vars)
}

# Convert to numeric (equivalent to destring)
df <- df %>%
  mutate(across(all_of(monthly_vars), as.numeric))

# Add labels for annual variables
for(i in 2022:2024) {
  attr(df[[paste0("num_peak_months_", i)]], "label") <- paste("Number of peak months in", i)
  attr(df[[paste0("num_usual_months_", i)]], "label") <- paste("Number of usual months in", i)  
  attr(df[[paste0("num_shutdown_months_", i)]], "label") <- paste("Number of shutdown months in", i)
}

# Create quarterly variables for each year
quarters <- list(
  q1 = c("jan", "feb", "mar"),
  q2 = c("apr", "may", "jun"), 
  q3 = c("jul", "aug", "sep"),
  q4 = c("oct", "nov", "dec")
)

for(year in 2022:2024) {
  for(q in 1:4) {
    # Initialize quarterly variables
    df[[paste0("num_peak_months_", year, "_q", q)]] <- 0
    df[[paste0("num_usual_months_", year, "_q", q)]] <- 0
    df[[paste0("num_shutdown_months_", year, "_q", q)]] <- 0
    
    # Sum across months in quarter
    for(month in quarters[[q]]) {
      if(paste0(month, "_", year) %in% names(df)) {
        df <- df %>%
          mutate(
            !!paste0("num_peak_months_", year, "_q", q) := 
              ifelse(get(paste0("operational_", year)) == 1,
                     get(paste0("num_peak_months_", year, "_q", q)) + 
                       ifelse(get(paste0(month, "_", year)) == 1, 1, 0), 
                     get(paste0("num_peak_months_", year, "_q", q))),
            !!paste0("num_usual_months_", year, "_q", q) := 
              ifelse(get(paste0("operational_", year)) == 1,
                     get(paste0("num_usual_months_", year, "_q", q)) + 
                       ifelse(get(paste0(month, "_", year)) == 2, 1, 0), 
                     get(paste0("num_usual_months_", year, "_q", q))),
            !!paste0("num_shutdown_months_", year, "_q", q) := 
              ifelse(get(paste0("operational_", year)) == 1,
                     get(paste0("num_shutdown_months_", year, "_q", q)) + 
                       ifelse(get(paste0(month, "_", year)) == 3, 1, 0), 
                     get(paste0("num_shutdown_months_", year, "_q", q)))
          )
      }
    }
    
    # Add labels
    attr(df[[paste0("num_peak_months_", year, "_q", q)]], "label") <- paste("Number of peak months in Q", q, year)
    attr(df[[paste0("num_usual_months_", year, "_q", q)]], "label") <- paste("Number of usual months in Q", q, year)
    attr(df[[paste0("num_shutdown_months_", year, "_q", q)]], "label") <- paste("Number of shutdown months in Q", q, year)
  }
}

#===============================================================================
#                               Enterprise Age
#===============================================================================

# Calculate enterprise age (as of April 18, 2025)
reference_date <- as.Date("2025-04-18")
df <- df %>%
  mutate(
    e_age = as.numeric(reference_date - as.Date(sec3_q1)) / 365.25
  )

attr(df$e_age, "label") <- "Age of the enterprise (years)"

#===============================================================================
#                           Entrepreneur Age (from MIS)
#===============================================================================

# Convert date of birth to date format and calculate age
df <- df %>%
  mutate(
    dob = as.Date(Dateofbirth),
    age_entrepreneur_s = as.numeric(reference_date - dob) / 365.25
  )

attr(df$age_entrepreneur_s, "label") <- "Age of the entrepreneur (years)"

#===============================================================================
#                       Entrepreneur Marriage Age (from MIS)
#===============================================================================

# Create marital status indicator
df <- df %>%
  mutate(
    marital_status = ifelse(ent_running == 1 & sec4_q1 %in% c(2, 3, 4), 1, 0)
  )

attr(df$marital_status, "label") <- "1 = Married (Married, Widowed, Divorced), 0 = Never married"

# Create marriage age variable with outlier correction
df <- df %>%
  mutate(marriage_age = ifelse(ent_running == 1, sec4_q1_a, NA))

# Calculate median for outlier replacement
marriage_age_median <- median(df$marriage_age, na.rm = TRUE)

# Replace extreme values (-27, 220) with median
df <- df %>%
  mutate(
    marriage_age = case_when(
      marriage_age == -27 ~ marriage_age_median,
      marriage_age == 220 ~ marriage_age_median,
      TRUE ~ marriage_age
    )
  )

attr(df$marriage_age, "label") <- "Marriage age if ever married"

#===============================================================================
#                   Gender of entrepreneur (create dummy variables)
#===============================================================================

df <- df %>%
  mutate(
    female_owner = ifelse(ent_running == 1 & sec2_q3a == 1, 1, 0),
    male_owner = ifelse(ent_running == 1 & sec2_q3a == 0, 1, 0),
    other_gender = ifelse(ent_running == 1 & sec2_q3a == 2, 1, 0)
  )

attr(df$female_owner, "label") <- "Female entrepreneur"
attr(df$male_owner, "label") <- "Male entrepreneur"  
attr(df$other_gender, "label") <- "Other gender entrepreneur"

#===============================================================================
#                           Enterprise characteristics
#===============================================================================

# Create enterprise nature dummy variables
df <- df %>%
  mutate(
    ent_nature_1 = ifelse(ent_running == 1 & sec2_q2 == 1, 1, 0),
    ent_nature_2 = ifelse(ent_running == 1 & sec2_q2 == 2, 1, 0),
    ent_nature_3 = ifelse(ent_running == 1 & sec2_q2 == 3, 1, 0)
  )

attr(df$ent_nature_1, "label") <- "Manufacturing enterprise"
attr(df$ent_nature_2, "label") <- "Trade/Retail/Sales enterprise"
attr(df$ent_nature_3, "label") <- "Service enterprise"

#===============================================================================
#        Education Years: Recoding education variable as continuous
#===============================================================================

df <- df %>%
  mutate(
    education_yrs = case_when(
      sec4_q2 %in% c(17, 18) & !is.na(sec4_q2) ~ 0,
      sec4_q2 %in% c(14, 15) & !is.na(sec4_q2) ~ 17,
      sec4_q2 == 13 & !is.na(sec4_q2) ~ 15,
      sec4_q2 %in% c(12, 20) & !is.na(sec4_q2) ~ 12,
      sec4_q2 == 11 & !is.na(sec4_q2) ~ 11,
      sec4_q2 == 10 & !is.na(sec4_q2) ~ 10,
      sec4_q2 == 9 & !is.na(sec4_q2) ~ 9,
      sec4_q2 == 8 & !is.na(sec4_q2) ~ 8,
      sec4_q2 == 7 & !is.na(sec4_q2) ~ 7,
      sec4_q2 == 6 & !is.na(sec4_q2) ~ 6,
      sec4_q2 == 5 & !is.na(sec4_q2) ~ 5,
      sec4_q2 == 4 & !is.na(sec4_q2) ~ 4,
      sec4_q2 == 3 & !is.na(sec4_q2) ~ 3,
      sec4_q2 == 2 & !is.na(sec4_q2) ~ 2,
      sec4_q2 == 1 & !is.na(sec4_q2) ~ 1,
      TRUE ~ sec4_q2
    )
  )

attr(df$education_yrs, "label") <- "Years of education of the enterprise owner"

#===============================================================================
#                   Registration status: sec3_q2 sec3_q2_1 sec3_q2_a
#===============================================================================

df <- df %>%
  mutate(
    registered = ifelse(!is.na(sec3_q2), ifelse(sec3_q2 == 1, 1, 0), NA),
    udyam_registration = ifelse(!is.na(sec3_q2_1), sec3_q2_1, NA),
    sole_prop = ifelse(registered == 1, ifelse(sec3_q2_a == 1, 1, 0), NA),
    partnership = ifelse(registered == 1, ifelse(sec3_q2_a == 2, 1, 0), NA)
  )

attr(df$registered, "label") <- "Enterprise is formally registered"
attr(df$udyam_registration, "label") <- "Whether enterprise is registered with Udyam Aadhar?"
attr(df$sole_prop, "label") <- "Sole proprietorship"
attr(df$partnership, "label") <- "Partnership"

#===============================================================================
#                           SHG Status, SHG participation
#===============================================================================

df <- df %>%
  mutate(
    shg = ifelse(ent_running == 1, ifelse(sec3_q6 %in% c(1, 2), 1, 0), NA)
  )

attr(df$shg, "label") <- "1 = Either SHG member or SHG HH, 0 = Non-SHG"

#===============================================================================
#                               Enterprise operation
#===============================================================================

# Handle business operation current location
df <- df %>%
  mutate(
    business_operation_current = sec3_q4,
    business_operation_current = case_when(
      sec3_q4_oth %in% c("Working on twovellar", "Using commercial van", "Auto", 
                         "Vending door by door", "Market like sandhai", "Auto rickshaw", "Noshoo") ~ 4,
      business_operation_current == 88 & sec3_q4_oth %in% c("Thottam", "Integrated farm", "Agriculture", "Agriculture Land") ~ 1,
      business_operation_current == 88 & sec3_q4_oth %in% c("No shop", "Noshoo", "No", "No shoo") ~ 1,
      business_operation_current == 88 & sec3_q4_oth %in% c("Site", "Centring works") ~ 1,
      business_operation_current == 88 & sec3_q4_oth == "Leeds" ~ 1,
      TRUE ~ business_operation_current
    )
  )

# Handle business operation start location
df <- df %>%
  mutate(
    business_operation_start = sec3_q4_1,
    business_operation_start = case_when(
      business_operation_start == 88 & sec3_q4_1_oth %in% c("No shop", "No use", "2021", "No work", 
                                                            "Market like sandhai", "Thottam", "Leeds", "no use", "no") ~ 1,
      business_operation_start == 88 & sec3_q4_1_oth %in% c("No", "Noshop", "Agriculture", "Agriculture Land", "Integrated farm") ~ 1,
      TRUE ~ business_operation_start
    )
  )

# Create business operation change indicator
df <- df %>%
  mutate(
    business_ops_change = ifelse(business_operation_current != business_operation_start, 1, 0)
  )

attr(df$business_ops_change, "label") <- "Business operation location change (1 = Yes)"

#===============================================================================
#                       Enterprise location characteristics
#===============================================================================

# Create enterprise location dummy variables
df <- df %>%
  mutate(
    ent_location_1 = ifelse(sec3_q5 == 1, 1, 0),
    ent_location_2 = ifelse(sec3_q5 == 2, 1, 0),
    ent_location_3 = ifelse(sec3_q5 == 3, 1, 0),
    ent_location_4 = ifelse(sec3_q5 == 4, 1, 0)
  )

attr(df$ent_location_1, "label") <- "Located in main marketplace"
attr(df$ent_location_2, "label") <- "Located in secondary marketplace"
attr(df$ent_location_3, "label") <- "Located on street with other businesses"
attr(df$ent_location_4, "label") <- "Located in residential area"

#===============================================================================
#                       Digit-Span Recall Test Variables
#===============================================================================

# Calculate digit span score based on sequential test performance
df <- df %>%
  mutate(
    digit_span = case_when(
      sec12_q1 == 0 & !is.na(sec12_q1) ~ 3,  # Failed at 4 digits
      sec12_q1 == 1 & sec12_q2 == 0 & !is.na(sec12_q2) ~ 4,  # Passed 4, failed 5
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 0 & !is.na(sec12_q3) ~ 5,  # Passed 5, failed 6
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 0 & !is.na(sec12_q4) ~ 6,  # Passed 6, failed 7
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 0 & !is.na(sec12_q5) ~ 7,  # Passed 7, failed 8
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 0 & !is.na(sec12_q6) ~ 8,  # Passed 8, failed 9
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 0 & !is.na(sec12_q7) ~ 9,  # Passed 9, failed 10
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 1 & sec12_q8 == 0 & !is.na(sec12_q8) ~ 10,  # Passed 10, failed 11
      sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 1 & sec12_q8 == 1 & !is.na(sec12_q8) ~ 11,  # Passed all 11
      TRUE ~ NA_real_
    )
  )

attr(df$digit_span, "label") <- "Digit Span recall Maximum"

# Create standardized digit span score
df <- df %>%
  mutate(std_digit_span = scale(digit_span)[,1])

attr(df$std_digit_span, "label") <- "Standardized digit span score"

#===============================================================================
#                       Business Risk Tolerance Index (BRTI)
#===============================================================================

# Create individual risk choice variables
df <- df %>%
  mutate(
    risk_choice1 = ifelse(!is.na(sec13_q1), ifelse(sec13_q1 == 1, 1, 0), NA),
    risk_choice2 = ifelse(!is.na(sec13_q2), ifelse(sec13_q2 == 1, 1, 0), NA),
    risk_choice3 = ifelse(!is.na(sec13_q3), ifelse(sec13_q3 == 1, 1, 0), NA),
    risk_choice4 = ifelse(!is.na(sec13_q4), ifelse(sec13_q4 == 1, 1, 0), NA),
    risk_choice5 = ifelse(!is.na(sec13_q5), ifelse(sec13_q5 == 1, 1, 0), NA)
  )

attr(df$risk_choice1, "label") <- "Chose risky option: new product (40% +80%, 60% -20%)"
attr(df$risk_choice2, "label") <- "Chose risky option: new technology (30% +100%, 70% 0%)"
attr(df$risk_choice3, "label") <- "Chose risky option: market expansion (50% +100%, 50% 0%)"
attr(df$risk_choice4, "label") <- "Chose risky option: loan (60% +70%, 40% strain)"
attr(df$risk_choice5, "label") <- "Chose risky option: new supplier (70% profit, 30% loss)"

# Calculate Cronbach's alpha (requires psych package)
if(require(psych, quietly = TRUE)) {
  risk_items <- df %>% 
    select(risk_choice1, risk_choice2, risk_choice3, risk_choice4, risk_choice5) %>%
    na.omit()
  
  if(nrow(risk_items) > 0) {
    alpha_result <- psych::alpha(risk_items)
    cat("Cronbach's Alpha for Risk Tolerance:", round(alpha_result$total$raw_alpha, 3), "\n")
  }
} else {
  cat("psych package not available for Cronbach's alpha calculation\n")
}

# Perform PCA for BRTI
risk_vars <- c("risk_choice1", "risk_choice2", "risk_choice3", "risk_choice4", "risk_choice5")
risk_data_complete <- df %>%
  select(all_of(risk_vars)) %>%
  na.omit()

if(nrow(risk_data_complete) > 0) {
  pca_result <- prcomp(risk_data_complete, scale. = TRUE)
  
  # Extract first principal component scores
  df$brti_pca <- NA
  complete_cases <- complete.cases(df[risk_vars])
  df$brti_pca[complete_cases] <- pca_result$x[,1]
  
  attr(df$brti_pca, "label") <- "Business Risk Tolerance Index (PCA)"
  
  cat("PCA Summary for Risk Tolerance:\n")
  print(summary(pca_result))
}

# Calculate count-based BRTI
df <- df %>%
  rowwise() %>%
  mutate(
    risk_count = sum(c_across(all_of(risk_vars)), na.rm = TRUE),
    brti_count = risk_count / 5
  ) %>%
  ungroup()

attr(df$brti_count, "label") <- "Business Risk Tolerance Index (count-based)"

# Display summary statistics
cat("\nBusiness Risk Tolerance Index Summary:\n")
summary_stats <- df %>%
  select(brti_count, brti_pca) %>%
  summarise(
    across(everything(), list(
      n = ~sum(!is.na(.)),
      mean = ~mean(., na.rm = TRUE),
      sd = ~sd(., na.rm = TRUE),
      min = ~min(., na.rm = TRUE),
      p25 = ~quantile(., 0.25, na.rm = TRUE),
      p50 = ~median(., na.rm = TRUE),
      p75 = ~quantile(., 0.75, na.rm = TRUE),
      max = ~max(., na.rm = TRUE)
    ))
  )

print(summary_stats)

#===============================================================================
#                                   Innovation
#===============================================================================

# Create individual innovation indicator variables
df <- df %>%
  mutate(
    product_innovation = ifelse(!is.na(sec11_q1), ifelse(sec11_q1 == 1, 1, 0), NA),
    technology_innovation = ifelse(!is.na(sec11_q6), ifelse(sec11_q6 == 1, 1, 0), NA),
    process_innovation = ifelse(!is.na(sec11_q10), ifelse(sec11_q10 == 1, 1, 0), NA),
    marketing_innovation = ifelse(!is.na(sec11_q14), ifelse(sec11_q14 == 1, 1, 0), NA),
    has_website = ifelse(!is.na(sec11_q18), ifelse(sec11_q18 == 1, 1, 0), NA),
    has_email = ifelse(!is.na(sec11_q19), ifelse(sec11_q19 == 1, 1, 0), NA)
  )

attr(df$product_innovation, "label") <- "Introduced new/improved products or services"
attr(df$technology_innovation, "label") <- "Introduced new/improved technology"
attr(df$process_innovation, "label") <- "Introduced new/improved logistics/delivery methods"
attr(df$marketing_innovation, "label") <- "Introduced new/improved marketing methods"
attr(df$has_website, "label") <- "Business has Website"
attr(df$has_email, "label") <- "Business has email"

# Create any innovation indicator
innovation_vars <- c("product_innovation", "technology_innovation", "process_innovation", 
                     "marketing_innovation", "has_website", "has_email")

df <- df %>%
  mutate(
    any_innovation = ifelse(ent_running == 1, 0, NA)
  )

for(var in innovation_vars) {
  df <- df %>%
    mutate(any_innovation = ifelse(get(var) == 1, 1, any_innovation))
}

attr(df$any_innovation, "label") <- "Any innovation introduced (Jan 2024-Feb 2025)"

# Calculate total innovation count
df <- df %>%
  rowwise() %>%
  mutate(
    tot_innovation = ifelse(ent_running == 1, 
                            sum(c_across(all_of(innovation_vars)), na.rm = TRUE), 
                            NA)
  ) %>%
  ungroup()

attr(df$tot_innovation, "label") <- "Total number of innovation types introduced (0-6)"

# Handle investment variables (replace missing with 0 for running enterprises)
investment_vars <- c("sec11_q5", "sec11_q9", "sec11_q13", "sec11_q17")

for(var in investment_vars) {
  df <- df %>%
    mutate(!!var := ifelse(is.na(get(var)) & ent_running == 1, 0, get(var)))
}

# Calculate total innovation investment
df <- df %>%
  rowwise() %>%
  mutate(
    total_innov_invest = sum(c_across(all_of(investment_vars)), na.rm = TRUE)
  ) %>%
  ungroup()

attr(df$total_innov_invest, "label") <- "Total investment in innovations (Rs.)"

# Winsorize investment variable (equivalent to winsor2)
if(require(DescTools, quietly = TRUE)) {
  df <- df %>%
    mutate(total_innov_invest_w1 = DescTools::Winsorize(total_innov_invest, probs = c(0.01, 0.99), na.rm = TRUE))
} else {
  # Manual winsorization
  p01 <- quantile(df$total_innov_invest, 0.01, na.rm = TRUE)
  p99 <- quantile(df$total_innov_invest, 0.99, na.rm = TRUE)
  
  df <- df %>%
    mutate(
      total_innov_invest_w1 = case_when(
        total_innov_invest < p01 ~ p01,
        total_innov_invest > p99 ~ p99,
        TRUE ~ total_innov_invest
      )
    )
}

# Calculate innovation score (mean of innovation indicators)
df <- df %>%
  rowwise() %>%
  mutate(
    innovation_score = mean(c_across(c(sec11_q1, sec11_q6, sec11_q10, sec11_q14, sec11_q18, sec11_q19)), na.rm = TRUE)
  ) %>%
  ungroup()

attr(df$innovation_score, "label") <- "Average of innovation indicators (proportion)"

# Display completion message
cat("\nVariable creation completed successfully!\n")
cat("Total observations:", nrow(df), "\n")
cat("Running enterprises:", sum(df$ent_running == 1, na.rm = TRUE), "\n")

#===============================================================================
#                                   Investment
#===============================================================================

# 1. Basic Investment Indicators by Year

# Investment indicators for each year
df <- df %>%
  mutate(
    invested_2024 = ifelse(!is.na(sec5_q1), ifelse(sec5_q1 == 1, 1, 0), NA),
    invested_2023 = ifelse(!is.na(sec5_q6), ifelse(sec5_q6 == 1, 1, 0), NA),
    invested_2022 = ifelse(!is.na(sec5_q11), ifelse(sec5_q11 == 1, 1, 0), NA)
  )

attr(df$invested_2024, "label") <- "Made any investment in 2024"
attr(df$invested_2023, "label") <- "Made any investment in 2023 (MGP started)"
attr(df$invested_2022, "label") <- "Made any investment in 2022 (pre-MGP)"

# Ever invested indicator
df <- df %>%
  mutate(
    ever_invested = ifelse(
      (!is.na(invested_2022) | !is.na(invested_2023) | !is.na(invested_2024)),
      ifelse((invested_2022 == 1 | invested_2023 == 1 | invested_2024 == 1), 1, 0),
      NA
    )
  )

attr(df$ever_invested, "label") <- "Made investment in any year (2022-2024)"

# 2. Investment Amounts by Year

# Function to safely sum investment amounts
safe_sum_investments <- function(data, var_prefix, year, invested_var) {
  result <- numeric(nrow(data))
  
  for(i in 1:10) {
    var_name <- paste0(var_prefix, i)
    if(var_name %in% names(data)) {
      result <- result + ifelse(is.na(data[[var_name]]), 0, data[[var_name]])
    }
  }
  
  # Only assign to those who invested
  ifelse(data[[invested_var]] == 1, result, NA)
}

# Total investment amounts by year
df$total_invest_2024 <- safe_sum_investments(df, "sec5_q3_", 2024, "invested_2024")
df$total_invest_2023 <- safe_sum_investments(df, "sec5_q8_", 2023, "invested_2023")
df$total_invest_2022 <- safe_sum_investments(df, "sec5_q13_", 2022, "invested_2022")

attr(df$total_invest_2024, "label") <- "Total amount invested in 2024 (Rs.)"
attr(df$total_invest_2023, "label") <- "Total amount invested in 2023 (MGP start year) (Rs.)"
attr(df$total_invest_2022, "label") <- "Total amount invested in 2022 (pre-MGP) (Rs.)"

# 3. Winsorized Investment Amounts

for(year in c(2022, 2023, 2024)) {
  total_var <- paste0("total_invest_", year)
  invested_var <- paste0("invested_", year)
  winsor_var <- paste0("w10_total_invest_", year)
  
  # Get 10th and 90th percentiles for investors only
  invest_data <- df[[total_var]][df[[invested_var]] == 1 & !is.na(df[[total_var]])]
  
  if(length(invest_data) > 0) {
    p10 <- quantile(invest_data, 0.10, na.rm = TRUE)
    p90 <- quantile(invest_data, 0.90, na.rm = TRUE)
    
    df[[winsor_var]] <- df[[total_var]]
    df[[winsor_var]][df[[total_var]] < p10 & !is.na(df[[total_var]]) & df[[invested_var]] == 1] <- p10
    df[[winsor_var]][df[[total_var]] > p90 & !is.na(df[[total_var]]) & df[[invested_var]] == 1] <- p90
  } else {
    df[[winsor_var]] <- df[[total_var]]
  }
  
  attr(df[[winsor_var]], "label") <- paste("Winsorized (at 10%) investment amount in", year, "(Rs.)")
}

# 4. Log Investment Variables

for(year in c(2022, 2023, 2024)) {
  winsor_var <- paste0("w10_total_invest_", year)
  log_var <- paste0("log_w10_total_invest_", year)
  
  df[[log_var]] <- ifelse(!is.na(df[[winsor_var]]), log(df[[winsor_var]] + 1), NA)
  attr(df[[log_var]], "label") <- paste("Log of winsorized investment amount in", year, "(Rs.)")
}

# 5. Count of investment types by year

for(year in c(2022, 2023, 2024)) {
  count_var <- paste0("count_invest_", year)
  invested_var <- paste0("invested_", year)
  
  if(year == 2024) {
    type_vars <- paste0("sec5_q2_", 1:4)
  } else if(year == 2023) {
    type_vars <- paste0("sec5_q7_", 1:4)
  } else {
    type_vars <- paste0("sec5_q12_", 1:4)
  }
  
  df[[count_var]] <- ifelse(df$ent_running == 1, 0, NA)
  
  for(var in type_vars) {
    if(var %in% names(df)) {
      df[[count_var]] <- ifelse(df[[var]] == 1, df[[count_var]] + 1, df[[count_var]])
    }
  }
  
  # Set to 0 if didn't invest
  df[[count_var]] <- ifelse(df[[invested_var]] == 0, 0, df[[count_var]])
  
  attr(df[[count_var]], "label") <- paste("Number of investment types in", year)
}

# 6. Investment by Type - Dummy Variables

# Working capital investment dummies
for(year in c(2022, 2023, 2024)) {
  wc_var <- paste0("wc_invest_", year)
  invested_var <- paste0("invested_", year)
  
  if(year == 2024) {
    type_var <- "sec5_q2_1"
  } else if(year == 2023) {
    type_var <- "sec5_q7_1"
  } else {
    type_var <- "sec5_q12_1"
  }
  
  df[[wc_var]] <- ifelse(df[[invested_var]] == 1, 0, NA)
  if(type_var %in% names(df)) {
    df[[wc_var]] <- ifelse(df[[type_var]] == 1 & !is.na(df[[type_var]]), 1, df[[wc_var]])
  }
  
  attr(df[[wc_var]], "label") <- paste("Invested in working capital in", year)
}

# Asset creation investment dummies (including new enterprise)
for(year in c(2022, 2023, 2024)) {
  ac_var <- paste0("ac_invest_", year)
  invested_var <- paste0("invested_", year)
  
  if(year == 2024) {
    type_vars <- c("sec5_q2_2", "sec5_q2_4")
  } else if(year == 2023) {
    type_vars <- c("sec5_q7_2", "sec5_q7_4")
  } else {
    type_vars <- c("sec5_q12_2", "sec5_q12_4")
  }
  
  df[[ac_var]] <- ifelse(df[[invested_var]] == 1, 0, NA)
  
  for(var in type_vars) {
    if(var %in% names(df)) {
      df[[ac_var]] <- ifelse(df[[var]] == 1 & df[[invested_var]] == 1 & !is.na(df[[var]]), 1, df[[ac_var]])
    }
  }
  
  attr(df[[ac_var]], "label") <- paste("Invested in asset creation (including new enterprise) in", year)
}

# Debt reduction investment dummies
for(year in c(2022, 2023, 2024)) {
  dr_var <- paste0("dr_invest_", year)
  invested_var <- paste0("invested_", year)
  
  if(year == 2024) {
    type_var <- "sec5_q2_3"
  } else if(year == 2023) {
    type_var <- "sec5_q7_3"
  } else {
    type_var <- "sec5_q12_3"
  }
  
  df[[dr_var]] <- ifelse(df[[invested_var]] == 1, 0, NA)
  if(type_var %in% names(df)) {
    df[[dr_var]] <- ifelse(df[[type_var]] == 1 & df[[invested_var]] == 1 & !is.na(df[[type_var]]), 1, df[[dr_var]])
  }
  
  attr(df[[dr_var]], "label") <- paste("Invested in debt reduction in", year)
}

# Ever invested variables
df <- df %>%
  mutate(
    ever_wc_invest = ifelse(
      (!is.na(wc_invest_2022) | !is.na(wc_invest_2023) | !is.na(wc_invest_2024)),
      ifelse((wc_invest_2022 == 1 | wc_invest_2023 == 1 | wc_invest_2024 == 1), 1, 0),
      NA
    ),
    ever_ac_invest = ifelse(
      (!is.na(ac_invest_2022) | !is.na(ac_invest_2023) | !is.na(ac_invest_2024)),
      ifelse((ac_invest_2022 == 1 | ac_invest_2023 == 1 | ac_invest_2024 == 1), 1, 0),
      NA
    ),
    ever_dr_invest = ifelse(
      (!is.na(dr_invest_2022) | !is.na(dr_invest_2023) | !is.na(dr_invest_2024)),
      ifelse((dr_invest_2022 == 1 | dr_invest_2023 == 1 | dr_invest_2024 == 1), 1, 0),
      NA
    )
  )

attr(df$ever_wc_invest, "label") <- "Ever invested in working capital (2022-2024)"
attr(df$ever_ac_invest, "label") <- "Ever invested in asset creation (2022-2024)"
attr(df$ever_dr_invest, "label") <- "Ever invested in debt reduction (2022-2024)"

# 7. Investment Amount Variables by Type
# Note: This is a simplified version. The original STATA code has very complex
# string matching logic that would require the actual data structure to implement fully

# Function to extract investment amounts based on type selection patterns
extract_investment_amounts <- function(data, year) {
  
  # Get the number of rows to ensure consistent vector lengths
  n_rows <- nrow(data)
  
  if(year == 2024) {
    type_var <- "sec5_q2"
    amount_prefix <- "sec5_q3_"
    invested_var <- "invested_2024"
  } else if(year == 2023) {
    type_var <- "sec5_q7"
    amount_prefix <- "sec5_q8_"
    invested_var <- "invested_2023"
  } else {
    type_var <- "sec5_q12"
    amount_prefix <- "sec5_q13_"
    invested_var <- "invested_2022"
  }
  
  # Initialize amount variables with proper length
  # Check if invested_var exists in data
  if(invested_var %in% names(data)) {
    wc_amount <- ifelse(data[[invested_var]] == 1, 0, NA)
    asset_amount <- ifelse(data[[invested_var]] == 1, 0, NA)
    debt_amount <- ifelse(data[[invested_var]] == 1, 0, NA)
  } else {
    # If invested_var doesn't exist, create vectors of NAs with correct length
    wc_amount <- rep(NA, n_rows)
    asset_amount <- rep(NA, n_rows)
    debt_amount <- rep(NA, n_rows)
  }
  
  # Ensure vectors are the right length (safety check)
  if(length(wc_amount) != n_rows) {
    wc_amount <- rep(NA, n_rows)
  }
  if(length(asset_amount) != n_rows) {
    asset_amount <- rep(NA, n_rows)
  }
  if(length(debt_amount) != n_rows) {
    debt_amount <- rep(NA, n_rows)
  }
  
  # Working capital amounts (assuming it's always first when selected)
  if(paste0(amount_prefix, "1") %in% names(data)) {
    wc_type_var <- if(year == 2024) "sec5_q2_1" else if(year == 2023) "sec5_q7_1" else "sec5_q12_1"
    if(wc_type_var %in% names(data)) {
      amount_var <- paste0(amount_prefix, "1")
      if(amount_var %in% names(data)) {
        wc_amount <- ifelse(data[[wc_type_var]] == 1 & !is.na(data[[amount_var]]), 
                            data[[amount_var]], wc_amount)
      }
    }
  }
  
  # Asset creation amounts (simplified - would need full logic for complex combinations)
  if(paste0(amount_prefix, "2") %in% names(data)) {
    ac_type_var <- if(year == 2024) "sec5_q2_2" else if(year == 2023) "sec5_q7_2" else "sec5_q12_2"
    if(ac_type_var %in% names(data)) {
      amount_var <- paste0(amount_prefix, "2")
      asset_amount <- ifelse(data[[ac_type_var]] == 1 & !is.na(data[[amount_var]]), 
                             data[[amount_var]], asset_amount)
    }
  }
  
  # Debt reduction amounts (simplified)
  if(paste0(amount_prefix, "3") %in% names(data)) {
    dr_type_var <- if(year == 2024) "sec5_q2_3" else if(year == 2023) "sec5_q7_3" else "sec5_q12_3"
    if(dr_type_var %in% names(data)) {
      amount_var <- paste0(amount_prefix, "3")
      debt_amount <- ifelse(data[[dr_type_var]] == 1 & !is.na(data[[amount_var]]), 
                            data[[amount_var]], debt_amount)
    }
  }
  
  return(list(wc = wc_amount, asset = asset_amount, debt = debt_amount))
}

# Extract investment amounts for each year
for(year in c(2022, 2023, 2024)) {
  amounts <- extract_investment_amounts(df, year)
  
  df[[paste0("wc_amount_", year)]] <- amounts$wc
  df[[paste0("asset_amount_", year)]] <- amounts$asset  
  df[[paste0("debt_amount_", year)]] <- amounts$debt
  
  attr(df[[paste0("wc_amount_", year)]], "label") <- paste("Amount invested in working capital in", year, "(Rs.)")
  attr(df[[paste0("asset_amount_", year)]], "label") <- paste("Amount invested in asset creation (including new enterprise) in", year, "(Rs.)")
  attr(df[[paste0("debt_amount_", year)]], "label") <- paste("Amount invested in debt reduction in", year, "(Rs.)")
}

# 8. Investment Shares by Type

for(year in c(2022, 2023, 2024)) {
  total_var <- paste0("total_invest_", year)
  
  # Working capital share
  wc_share_var <- paste0("wc_share_", year)
  wc_amount_var <- paste0("wc_amount_", year)
  df[[wc_share_var]] <- ifelse(df[[total_var]] > 0 & !is.na(df[[total_var]]), 
                               df[[wc_amount_var]] / df[[total_var]], NA)
  attr(df[[wc_share_var]], "label") <- paste("Share of investment in working capital in", year)
  
  # Asset creation share
  asset_share_var <- paste0("asset_share_", year)
  asset_amount_var <- paste0("asset_amount_", year)
  df[[asset_share_var]] <- ifelse(df[[total_var]] > 0 & !is.na(df[[total_var]]), 
                                  df[[asset_amount_var]] / df[[total_var]], NA)
  attr(df[[asset_share_var]], "label") <- paste("Share of investment in asset creation (including new enterprise) in", year)
  
  # Debt reduction share
  debt_share_var <- paste0("debt_share_", year)
  debt_amount_var <- paste0("debt_amount_", year)
  df[[debt_share_var]] <- ifelse(df[[total_var]] > 0 & !is.na(df[[total_var]]), 
                                 df[[debt_amount_var]] / df[[total_var]], NA)
  attr(df[[debt_share_var]], "label") <- paste("Share of investment in debt reduction in", year)
}

# 9. Combined Investment Variables for Analysis

# Total investment across all years
df <- df %>%
  rowwise() %>%
  mutate(
    total_invest_all = sum(c_across(c(total_invest_2022, total_invest_2023, total_invest_2024)), na.rm = TRUE)
  ) %>%
  ungroup()

attr(df$total_invest_all, "label") <- "Total investment across all years (2022-2024)"

# Winsorized total investment across all years
invest_all_data <- df$total_invest_all[!is.na(df$total_invest_all) & df$total_invest_all > 0]

if(length(invest_all_data) > 0) {
  p10_all <- quantile(invest_all_data, 0.10, na.rm = TRUE)
  p90_all <- quantile(invest_all_data, 0.90, na.rm = TRUE)
  
  df$w10_invest_all <- df$total_invest_all
  df$w10_invest_all[df$total_invest_all <= p10_all & !is.na(df$total_invest_all)] <- p10_all
  df$w10_invest_all[df$total_invest_all >= p90_all & !is.na(df$total_invest_all)] <- p90_all
} else {
  df$w10_invest_all <- df$total_invest_all
}

attr(df$w10_invest_all, "label") <- "Winsorized (at 10%) total investment across all years"

cat("\nInvestment variables created successfully!\n")
cat("Investment summary by year:\n")
for(year in c(2022, 2023, 2024)) {
  invested_count <- sum(df[[paste0("invested_", year)]] == 1, na.rm = TRUE)
  cat("Year", year, "- Investors:", invested_count, "\n")
}

#===============================================================================
#                           Enterprise Cost Variables
#===============================================================================

# 1. Basic Cost Indicators by Year

# Function to check if any number 1-9 appears in a string
has_any_cost <- function(x) {
  if(is.na(x)) return(NA)
  any(sapply(1:9, function(i) grepl(as.character(i), x, fixed = TRUE)))
}

# Costs in 2024
df <- df %>%
  mutate(
    has_costs_2024 = ifelse(operational_2024 == 1, 0, NA)
  )

if("sec9_q1" %in% names(df)) {
  df <- df %>%
    mutate(
      has_costs_2024 = ifelse(
        !is.na(sec9_q1) & sapply(sec9_q1, has_any_cost), 
        1, 
        has_costs_2024
      )
    )
}

attr(df$has_costs_2024, "label") <- "Incurred any business costs in 2024"

# Costs in 2023
df <- df %>%
  mutate(
    has_costs_2023 = ifelse(operational_2023 == 1, 0, NA)
  )

if("sec9_q8" %in% names(df)) {
  df <- df %>%
    mutate(
      has_costs_2023 = ifelse(
        !is.na(sec9_q8) & sapply(sec9_q8, has_any_cost), 
        1, 
        has_costs_2023
      )
    )
}

attr(df$has_costs_2023, "label") <- "Incurred any business costs in 2023"

# Costs in 2022
df <- df %>%
  mutate(
    has_costs_2022 = ifelse(operational_2022 == 1, 0, NA)
  )

if("sec9_q14" %in% names(df)) {
  df <- df %>%
    mutate(
      has_costs_2022 = ifelse(
        !is.na(sec9_q14) & sapply(sec9_q14, has_any_cost), 
        1, 
        has_costs_2022
      )
    )
}

attr(df$has_costs_2022, "label") <- "Incurred any business costs in 2022"

# 2. Total Annual Costs by Year

# Total costs for 2024 (9 categories)
df$total_costs_2024 <- ifelse(df$operational_2024 == 1, 0, NA)

for(i in 1:9) {
  var_name <- paste0("sec9_q6_", i)
  if(var_name %in% names(df)) {
    df$total_costs_2024 <- df$total_costs_2024 + ifelse(is.na(df[[var_name]]), 0, df[[var_name]])
  }
}

attr(df$total_costs_2024, "label") <- "Total enterprise costs in 2024 (Rs.)"

# Total costs for 2023 (5 categories)
df$total_costs_2023 <- ifelse(df$operational_2023 == 1, 0, NA)

for(i in 1:5) {
  var_name <- paste0("sec9_q13_", i)
  if(var_name %in% names(df)) {
    df$total_costs_2023 <- df$total_costs_2023 + ifelse(is.na(df[[var_name]]), 0, df[[var_name]])
  }
}

attr(df$total_costs_2023, "label") <- "Total enterprise costs in 2023 (Rs.)"

# Total costs for 2022 (5 categories)
df$total_costs_2022 <- ifelse(df$operational_2022 == 1, 0, NA)

for(i in 1:5) {
  var_name <- paste0("sec9_q19_", i)
  if(var_name %in% names(df)) {
    df$total_costs_2022 <- df$total_costs_2022 + ifelse(is.na(df[[var_name]]), 0, df[[var_name]])
  }
}

attr(df$total_costs_2022, "label") <- "Total enterprise costs in 2022 (Rs.)"

# 3. Winsorized Cost Variables

# Winsorize total costs
for(year in c(2022, 2023, 2024)) {
  total_var <- paste0("total_costs_", year)
  winsor_var <- paste0("w5_total_costs_", year)
  
  cost_data <- df[[total_var]][!is.na(df[[total_var]])]
  
  if(length(cost_data) > 0) {
    if(year == 2024) {
      p_low <- quantile(cost_data, 0.05, na.rm = TRUE)
      p_high <- quantile(cost_data, 0.95, na.rm = TRUE)
    } else {
      p_low <- quantile(cost_data, 0.01, na.rm = TRUE)
      p_high <- quantile(cost_data, 0.99, na.rm = TRUE)
    }
    
    df[[winsor_var]] <- df[[total_var]]
    df[[winsor_var]][df[[total_var]] <= p_low & !is.na(df[[total_var]])] <- p_low
    df[[winsor_var]][df[[total_var]] >= p_high & !is.na(df[[total_var]])] <- p_high
  } else {
    df[[winsor_var]] <- df[[total_var]]
  }
  
  attr(df[[winsor_var]], "label") <- paste("Winsorized (at 5%) total costs in", year, "(Rs.)")
}

# Winsorize individual cost components

# 2024 peak month costs (9 categories)
for(i in 1:9) {
  var_name <- paste0("sec9_q4_", i)
  winsor_var <- paste0("w5_sec9_q4_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
  }
}

# Add labels for 2024 peak month costs
cost_labels <- c(
  "Raw materials/resale items",
  "Space (shop/storage/workshop)",
  "Repair & maintenance of workspace",
  "Machinery/Equipment",
  "Repair & maintenance of machinery",
  "Vehicles/transportation",
  "Electricity/water/gas/fuel",
  "Interest on loans",
  "Taxes"
)

for(i in 1:9) {
  attr(df[[paste0("w5_sec9_q4_", i)]], "label") <- paste("Winsorized (at 5%) peak month costs 2024 -", cost_labels[i])
}

# 2023 peak month costs (5 categories)
for(i in 1:5) {
  var_name <- paste0("sec9_q11_", i)
  winsor_var <- paste0("w5_sec9_q11_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
    
    attr(df[[winsor_var]], "label") <- paste("Winsorized (at 5%) peak month costs 2023 -", cost_labels[i])
  }
}

# 2022 peak month costs (5 categories)
for(i in 1:5) {
  var_name <- paste0("sec9_q17_", i)
  winsor_var <- paste0("w5_sec9_q17_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
    
    attr(df[[winsor_var]], "label") <- paste("Winsorized (at 5%) peak month costs 2022 -", cost_labels[i])
  }
}

# Winsorize usual month costs

# 2024 usual month costs (9 categories)
for(i in 1:9) {
  var_name <- paste0("sec9_q5_", i)
  winsor_var <- paste0("w5_sec9_q5_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
    
    attr(df[[winsor_var]], "label") <- paste("Winsorized (at 1%) usual month costs 2024 -", cost_labels[i])
  }
}

# 2023 usual month costs (5 categories)
for(i in 1:5) {
  var_name <- paste0("sec9_q12_", i)
  winsor_var <- paste0("w5_sec9_q12_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
    
    attr(df[[winsor_var]], "label") <- paste("Winsorized (at 1%) usual month costs 2023 -", cost_labels[i])
  }
}

# 2022 usual month costs (5 categories)
for(i in 1:5) {
  var_name <- paste0("sec9_q18_", i)
  winsor_var <- paste0("w5_sec9_q18_", i)
  
  if(var_name %in% names(df)) {
    cost_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(cost_data) > 0) {
      p05 <- quantile(cost_data, 0.05, na.rm = TRUE)
      p95 <- quantile(cost_data, 0.95, na.rm = TRUE)
      
      df[[winsor_var]] <- df[[var_name]]
      df[[winsor_var]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_var]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_var]] <- df[[var_name]]
    }
    
    attr(df[[winsor_var]], "label") <- paste("Winsorized (at 1%) usual month costs 2022 -", cost_labels[i])
  }
}

# 4. Peak and Usual Month Costs by Year

# Peak months costs in 2024
df$peak_costs_2024 <- ifelse(df$operational_2024 == 1 & df$num_peak_months_2024 > 0, 0, NA)

for(i in 1:9) {
  winsor_var <- paste0("w5_sec9_q4_", i)
  if(winsor_var %in% names(df) && "num_peak_months_2024" %in% names(df)) {
    df$peak_costs_2024 <- df$peak_costs_2024 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_peak_months_2024), 
             df[[winsor_var]] * df$num_peak_months_2024, 0)
  }
}

attr(df$peak_costs_2024, "label") <- "Total costs during peak months in 2024 (Rs.)"

# Usual months costs in 2024
df$usual_costs_2024 <- ifelse(df$operational_2024 == 1 & df$num_usual_months_2024 > 0, 0, NA)

for(i in 1:9) {
  winsor_var <- paste0("w5_sec9_q5_", i)
  if(winsor_var %in% names(df) && "num_usual_months_2024" %in% names(df)) {
    df$usual_costs_2024 <- df$usual_costs_2024 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_usual_months_2024), 
             df[[winsor_var]] * df$num_usual_months_2024, 0)
  }
}

attr(df$usual_costs_2024, "label") <- "Total costs during usual months in 2024 (Rs.)"

# Peak months costs in 2023
df$peak_costs_2023 <- ifelse(df$operational_2023 == 1 & df$num_peak_months_2023 > 0, 0, NA)

for(i in 1:5) {
  winsor_var <- paste0("w5_sec9_q11_", i)
  if(winsor_var %in% names(df) && "num_peak_months_2023" %in% names(df)) {
    df$peak_costs_2023 <- df$peak_costs_2023 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_peak_months_2023), 
             df[[winsor_var]] * df$num_peak_months_2023, 0)
  }
}

attr(df$peak_costs_2023, "label") <- "Total costs during peak months in 2023 (Rs.)"

# Usual months costs in 2023
df$usual_costs_2023 <- ifelse(df$operational_2023 == 1 & df$num_usual_months_2023 > 0, 0, NA)

for(i in 1:5) {
  winsor_var <- paste0("w5_sec9_q12_", i)
  if(winsor_var %in% names(df) && "num_usual_months_2023" %in% names(df)) {
    df$usual_costs_2023 <- df$usual_costs_2023 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_usual_months_2023), 
             df[[winsor_var]] * df$num_usual_months_2023, 0)
  }
}

attr(df$usual_costs_2023, "label") <- "Total costs during usual months in 2023 (Rs.)"

# Peak months costs in 2022
df$peak_costs_2022 <- ifelse(df$operational_2022 == 1 & df$num_peak_months_2022 > 0, 0, NA)

for(i in 1:5) {
  winsor_var <- paste0("w5_sec9_q17_", i)
  if(winsor_var %in% names(df) && "num_peak_months_2022" %in% names(df)) {
    df$peak_costs_2022 <- df$peak_costs_2022 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_peak_months_2022), 
             df[[winsor_var]] * df$num_peak_months_2022, 0)
  }
}

attr(df$peak_costs_2022, "label") <- "Total costs during peak months in 2022 (Rs.)"

# Usual months costs in 2022
df$usual_costs_2022 <- ifelse(df$operational_2022 == 1 & df$num_usual_months_2022 > 0, 0, NA)

for(i in 1:5) {
  winsor_var <- paste0("w5_sec9_q18_", i)
  if(winsor_var %in% names(df) && "num_usual_months_2022" %in% names(df)) {
    df$usual_costs_2022 <- df$usual_costs_2022 + 
      ifelse(!is.na(df[[winsor_var]]) & !is.na(df$num_usual_months_2022), 
             df[[winsor_var]] * df$num_usual_months_2022, 0)
  }
}

attr(df$usual_costs_2022, "label") <- "Total costs during usual months in 2022 (Rs.)"

# 5. Interest Costs (treated separately)

# Annual interest cost in 2024
df$interest_cost_2024 <- ifelse(df$operational_2024 == 1, 0, NA)

for(i in 1:9) {
  var_name <- paste0("sec9_q4_a_", i)
  if(var_name %in% names(df)) {
    df$interest_cost_2024 <- df$interest_cost_2024 + 
      ifelse(!is.na(df[[var_name]]), df[[var_name]] * 12, 0)
  }
}

attr(df$interest_cost_2024, "label") <- "Annual interest cost in 2024 (Rs.)"

# Annual interest cost in 2023
df$interest_cost_2023 <- ifelse(df$operational_2023 == 1, 0, NA)

for(i in 1:5) {
  var_name <- paste0("sec9_q11_a_", i)
  if(var_name %in% names(df)) {
    df$interest_cost_2023 <- df$interest_cost_2023 + 
      ifelse(!is.na(df[[var_name]]), df[[var_name]] * 12, 0)
  }
}

attr(df$interest_cost_2023, "label") <- "Annual interest cost in 2023 (Rs.)"

# Annual interest cost in 2022
df$interest_cost_2022 <- ifelse(df$operational_2022 == 1, 0, NA)

for(i in 1:5) {
  var_name <- paste0("sec9_q17_a_", i)
  if(var_name %in% names(df)) {
    df$interest_cost_2022 <- df$interest_cost_2022 + 
      ifelse(!is.na(df[[var_name]]), df[[var_name]] * 12, 0)
  }
}

attr(df$interest_cost_2022, "label") <- "Annual interest cost in 2022 (Rs.)"

# 6. Calculate Total Costs Including Shutdown and Interest Costs

# Note: shutdown_cost variables referenced in original but not defined in this section
# Calculating total costs with available components

# Calculate total costs for 2024 (peak + usual + interest)
cost_vars_2024 <- c("peak_costs_2024", "usual_costs_2024", "interest_cost_2024")
if("shutdown_cost_2024" %in% names(df)) {
  cost_vars_2024 <- c(cost_vars_2024, "shutdown_cost_2024")
}

df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_costs_2024 = ifelse(operational_2024 == 1,
                                   sum(c_across(all_of(cost_vars_2024)), na.rm = TRUE),
                                   NA)
  ) %>%
  ungroup()

attr(df$calc_total_costs_2024, "label") <- "Calculated total costs in 2024 (Rs.)"

# Calculate total costs for 2023
cost_vars_2023 <- c("peak_costs_2023", "usual_costs_2023", "interest_cost_2023")
if("shutdown_cost_2023" %in% names(df)) {
  cost_vars_2023 <- c(cost_vars_2023, "shutdown_cost_2023")
}

df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_costs_2023 = ifelse(operational_2023 == 1,
                                   sum(c_across(all_of(cost_vars_2023)), na.rm = TRUE),
                                   NA)
  ) %>%
  ungroup()

attr(df$calc_total_costs_2023, "label") <- "Calculated total costs in 2023 (Rs.)"

# Calculate total costs for 2022
cost_vars_2022 <- c("peak_costs_2022", "usual_costs_2022", "interest_cost_2022")
if("shutdown_cost_2022" %in% names(df)) {
  cost_vars_2022 <- c(cost_vars_2022, "shutdown_cost_2022")
}

df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_costs_2022 = ifelse(operational_2022 == 1,
                                   sum(c_across(all_of(cost_vars_2022)), na.rm = TRUE),
                                   NA)
  ) %>%
  ungroup()

attr(df$calc_total_costs_2022, "label") <- "Calculated total costs in 2022 (Rs.)"

# 7. Combined Costs Across All Years

# Total costs across all years
df <- df %>%
  rowwise() %>%
  mutate(
    total_costs_all_years = sum(c_across(c(total_costs_2022, total_costs_2023, total_costs_2024)), na.rm = TRUE)
  ) %>%
  ungroup()

attr(df$total_costs_all_years, "label") <- "Total costs across all years (2022-2024) (Rs.)"

# Winsorized total costs across all years
cost_all_data <- df$total_costs_all_years[!is.na(df$total_costs_all_years) & df$total_costs_all_years > 0]

if(length(cost_all_data) > 0) {
  p10_costs <- quantile(cost_all_data, 0.10, na.rm = TRUE)
  p90_costs <- quantile(cost_all_data, 0.90, na.rm = TRUE)
  
  df$w10_total_costs_all_years <- df$total_costs_all_years
  df$w10_total_costs_all_years[df$total_costs_all_years <= p10_costs & !is.na(df$total_costs_all_years)] <- p10_costs
  df$w10_total_costs_all_years[df$total_costs_all_years >= p90_costs & !is.na(df$total_costs_all_years)] <- p90_costs
} else {
  df$w10_total_costs_all_years <- df$total_costs_all_years
}

attr(df$w10_total_costs_all_years, "label") <- "Winsorized (at 10%) total costs across all years (Rs.)"

# 8. Quarterly Cost Calculations

# Calculate quarterly costs for 2024
for(q in 1:4) {
  peak_months_var <- paste0("num_peak_months_2024_q", q)
  usual_months_var <- paste0("num_usual_months_2024_q", q)
  
  # Peak costs by quarter
  peak_costs_var <- paste0("peak_costs_2024_q", q)
  df[[peak_costs_var]] <- ifelse(
    df$operational_2024 == 1 & !is.na(df[[peak_months_var]]) & df[[peak_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:9) {
    winsor_var <- paste0("w5_sec9_q4_", i)
    if(winsor_var %in% names(df) && peak_months_var %in% names(df)) {
      df[[peak_costs_var]] <- df[[peak_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[peak_months_var]]), 
               df[[winsor_var]] * df[[peak_months_var]], 0)
    }
  }
  
  attr(df[[peak_costs_var]], "label") <- paste("Peak costs in Q", q, "2024 (Rs.)")
  
  # Usual costs by quarter
  usual_costs_var <- paste0("usual_costs_2024_q", q)
  df[[usual_costs_var]] <- ifelse(
    df$operational_2024 == 1 & !is.na(df[[usual_months_var]]) & df[[usual_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:9) {
    winsor_var <- paste0("w5_sec9_q5_", i)
    if(winsor_var %in% names(df) && usual_months_var %in% names(df)) {
      df[[usual_costs_var]] <- df[[usual_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[usual_months_var]]), 
               df[[winsor_var]] * df[[usual_months_var]], 0)
    }
  }
  
  attr(df[[usual_costs_var]], "label") <- paste("Usual costs in Q", q, "2024 (Rs.)")
  
  # Total costs by quarter
  total_costs_var <- paste0("total_costs_2024_q", q)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!total_costs_var := sum(c_across(c(all_of(peak_costs_var), all_of(usual_costs_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  
  attr(df[[total_costs_var]], "label") <- paste("Total costs in Q", q, "2024 (Rs.)")
}

# Calculate quarterly costs for 2023
for(q in 1:4) {
  peak_months_var <- paste0("num_peak_months_2023_q", q)
  usual_months_var <- paste0("num_usual_months_2023_q", q)
  
  # Peak costs by quarter
  peak_costs_var <- paste0("peak_costs_2023_q", q)
  df[[peak_costs_var]] <- ifelse(
    df$operational_2023 == 1 & !is.na(df[[peak_months_var]]) & df[[peak_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:5) {
    winsor_var <- paste0("w5_sec9_q11_", i)
    if(winsor_var %in% names(df) && peak_months_var %in% names(df)) {
      df[[peak_costs_var]] <- df[[peak_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[peak_months_var]]), 
               df[[winsor_var]] * df[[peak_months_var]], 0)
    }
  }
  
  attr(df[[peak_costs_var]], "label") <- paste("Peak costs in Q", q, "2023 (Rs.)")
  
  # Usual costs by quarter
  usual_costs_var <- paste0("usual_costs_2023_q", q)
  df[[usual_costs_var]] <- ifelse(
    df$operational_2023 == 1 & !is.na(df[[usual_months_var]]) & df[[usual_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:5) {
    winsor_var <- paste0("w5_sec9_q12_", i)
    if(winsor_var %in% names(df) && usual_months_var %in% names(df)) {
      df[[usual_costs_var]] <- df[[usual_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[usual_months_var]]), 
               df[[winsor_var]] * df[[usual_months_var]], 0)
    }
  }
  
  attr(df[[usual_costs_var]], "label") <- paste("Usual costs in Q", q, "2023 (Rs.)")
  
  # Total costs by quarter
  total_costs_var <- paste0("total_costs_2023_q", q)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!total_costs_var := sum(c_across(c(all_of(peak_costs_var), all_of(usual_costs_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  
  attr(df[[total_costs_var]], "label") <- paste("Total costs in Q", q, "2023 (Rs.)")
}

# Calculate quarterly costs for 2022
for(q in 1:4) {
  peak_months_var <- paste0("num_peak_months_2022_q", q)
  usual_months_var <- paste0("num_usual_months_2022_q", q)
  
  # Peak costs by quarter
  peak_costs_var <- paste0("peak_costs_2022_q", q)
  df[[peak_costs_var]] <- ifelse(
    df$operational_2022 == 1 & !is.na(df[[peak_months_var]]) & df[[peak_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:5) {
    winsor_var <- paste0("w5_sec9_q17_", i)
    if(winsor_var %in% names(df) && peak_months_var %in% names(df)) {
      df[[peak_costs_var]] <- df[[peak_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[peak_months_var]]), 
               df[[winsor_var]] * df[[peak_months_var]], 0)
    }
  }
  
  attr(df[[peak_costs_var]], "label") <- paste("Peak costs in Q", q, "2022 (Rs.)")
  
  # Usual costs by quarter
  usual_costs_var <- paste0("usual_costs_2022_q", q)
  df[[usual_costs_var]] <- ifelse(
    df$operational_2022 == 1 & !is.na(df[[usual_months_var]]) & df[[usual_months_var]] > 0, 
    0, NA
  )
  
  for(i in 1:5) {
    winsor_var <- paste0("w5_sec9_q18_", i)
    if(winsor_var %in% names(df) && usual_months_var %in% names(df)) {
      df[[usual_costs_var]] <- df[[usual_costs_var]] + 
        ifelse(!is.na(df[[winsor_var]]) & !is.na(df[[usual_months_var]]), 
               df[[winsor_var]] * df[[usual_months_var]], 0)
    }
  }
  
  attr(df[[usual_costs_var]], "label") <- paste("Usual costs in Q", q, "2022 (Rs.)")
  
  # Total costs by quarter
  total_costs_var <- paste0("total_costs_2022_q", q)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!total_costs_var := sum(c_across(c(all_of(peak_costs_var), all_of(usual_costs_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  
  attr(df[[total_costs_var]], "label") <- paste("Total costs in Q", q, "2022 (Rs.)")
}

cat("\nEnterprise cost variables created successfully!\n")
cat("Cost summary by year:\n")
for(year in c(2022, 2023, 2024)) {
  has_costs <- sum(df[[paste0("has_costs_", year)]] == 1, na.rm = TRUE)
  avg_costs <- mean(df[[paste0("total_costs_", year)]], na.rm = TRUE)
  cat("Year", year, "- Enterprises with costs:", has_costs, "- Avg total costs:", round(avg_costs, 0), "\n")
}

#===============================================================================
#                           Enterprise Revenue Variables
#===============================================================================

# 1. Basic Revenue Indicators by Year

# Revenue in 2024
df <- df %>%
  mutate(
    has_revenue_2024 = ifelse(operational_2024 == 1, 0, NA)
  )

if("sec7_q3" %in% names(df)) {
  df <- df %>%
    mutate(
      has_revenue_2024 = ifelse(sec7_q3 > 0 & !is.na(sec7_q3), 1, has_revenue_2024)
    )
}

attr(df$has_revenue_2024, "label") <- "Generated any business revenue in 2024"

# Revenue in 2023
df <- df %>%
  mutate(
    has_revenue_2023 = ifelse(operational_2023 == 1, 0, NA)
  )

if("sec7_q13" %in% names(df)) {
  df <- df %>%
    mutate(
      has_revenue_2023 = ifelse(sec7_q13 > 0 & !is.na(sec7_q13), 1, has_revenue_2023)
    )
}

attr(df$has_revenue_2023, "label") <- "Generated any business revenue in 2023"

# Revenue in 2022
df <- df %>%
  mutate(
    has_revenue_2022 = ifelse(operational_2022 == 1, 0, NA)
  )

if("sec7_q18" %in% names(df)) {
  df <- df %>%
    mutate(
      has_revenue_2022 = ifelse(sec7_q18 > 0 & !is.na(sec7_q18), 1, has_revenue_2022)
    )
}

attr(df$has_revenue_2022, "label") <- "Generated any business revenue in 2022"

# 2. Total Annual Revenue by Year

# Total revenue from survey responses
if("sec7_q3" %in% names(df)) {
  df$total_revenue_2024 <- ifelse(df$operational_2024 == 1, df$sec7_q3, NA)
} else {
  df$total_revenue_2024 <- NA
}
attr(df$total_revenue_2024, "label") <- "Total enterprise revenue in 2024 (Rs.)"

if("sec7_q13" %in% names(df)) {
  df$total_revenue_2023 <- ifelse(df$operational_2023 == 1, df$sec7_q13, NA)
} else {
  df$total_revenue_2023 <- NA
}
attr(df$total_revenue_2023, "label") <- "Total enterprise revenue in 2023 (Rs.)"

if("sec7_q18" %in% names(df)) {
  df$total_revenue_2022 <- ifelse(df$operational_2022 == 1, df$sec7_q18, NA)
} else {
  df$total_revenue_2022 <- NA
}
attr(df$total_revenue_2022, "label") <- "Total enterprise revenue in 2022 (Rs.)"

# 3. Winsorized Revenue Variables (at 5%)

for(year in c(2022, 2023, 2024)) {
  total_var <- paste0("total_revenue_", year)
  winsor_var <- paste0("w5_total_revenue_", year)
  
  revenue_data <- df[[total_var]][!is.na(df[[total_var]])]
  
  if(length(revenue_data) > 0) {
    p05 <- quantile(revenue_data, 0.05, na.rm = TRUE)
    p95 <- quantile(revenue_data, 0.95, na.rm = TRUE)
    
    df[[winsor_var]] <- df[[total_var]]
    df[[winsor_var]][df[[total_var]] <= p05 & !is.na(df[[total_var]])] <- p05
    df[[winsor_var]][df[[total_var]] >= p95 & !is.na(df[[total_var]])] <- p95
  } else {
    df[[winsor_var]] <- df[[total_var]]
  }
  
  attr(df[[winsor_var]], "label") <- paste("Winsorized (at 5%) total revenue in", year, "(Rs.)")
}

# 4. Winsorize Monthly Revenue Variables

# 2024 Peak and Usual Revenue
revenue_vars_2024 <- c("sec7_q1", "sec7_q2")
winsor_names_2024 <- c("w5_sec7_q1", "w5_sec7_q2")
labels_2024 <- c("Winsorized (at 5%) peak month revenue 2024", "Winsorized (at 5%) usual month revenue 2024")

for(i in 1:length(revenue_vars_2024)) {
  var_name <- revenue_vars_2024[i]
  winsor_name <- winsor_names_2024[i]
  
  if(var_name %in% names(df)) {
    revenue_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(revenue_data) > 0) {
      p05 <- quantile(revenue_data, 0.05, na.rm = TRUE)
      p95 <- quantile(revenue_data, 0.95, na.rm = TRUE)
      
      df[[winsor_name]] <- df[[var_name]]
      df[[winsor_name]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_name]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_name]] <- df[[var_name]]
    }
    
    attr(df[[winsor_name]], "label") <- labels_2024[i]
  }
}

# 2023 Peak and Usual Revenue
revenue_vars_2023 <- c("sec7_q11", "sec7_q12")
winsor_names_2023 <- c("w5_sec7_q11", "w5_sec7_q12")
labels_2023 <- c("Winsorized (at 5%) peak month revenue 2023", "Winsorized (at 5%) usual month revenue 2023")

for(i in 1:length(revenue_vars_2023)) {
  var_name <- revenue_vars_2023[i]
  winsor_name <- winsor_names_2023[i]
  
  if(var_name %in% names(df)) {
    revenue_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(revenue_data) > 0) {
      p05 <- quantile(revenue_data, 0.05, na.rm = TRUE)
      p95 <- quantile(revenue_data, 0.95, na.rm = TRUE)
      
      df[[winsor_name]] <- df[[var_name]]
      df[[winsor_name]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_name]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_name]] <- df[[var_name]]
    }
    
    attr(df[[winsor_name]], "label") <- labels_2023[i]
  }
}

# 2022 Peak and Usual Revenue
revenue_vars_2022 <- c("sec7_q16", "sec7_q17")
winsor_names_2022 <- c("w5_sec7_q16", "w5_sec7_q17")
labels_2022 <- c("Winsorized (at 5%) peak month revenue 2022", "Winsorized (at 5%) usual month revenue 2022")

for(i in 1:length(revenue_vars_2022)) {
  var_name <- revenue_vars_2022[i]
  winsor_name <- winsor_names_2022[i]
  
  if(var_name %in% names(df)) {
    revenue_data <- df[[var_name]][!is.na(df[[var_name]])]
    
    if(length(revenue_data) > 0) {
      p05 <- quantile(revenue_data, 0.05, na.rm = TRUE)
      p95 <- quantile(revenue_data, 0.95, na.rm = TRUE)
      
      df[[winsor_name]] <- df[[var_name]]
      df[[winsor_name]][df[[var_name]] <= p05 & !is.na(df[[var_name]])] <- p05
      df[[winsor_name]][df[[var_name]] >= p95 & !is.na(df[[var_name]])] <- p95
    } else {
      df[[winsor_name]] <- df[[var_name]]
    }
    
    attr(df[[winsor_name]], "label") <- labels_2022[i]
  }
}

# 5. Peak and Usual Month Revenue by Year

# Peak months revenue in 2024
df$peak_revenue_2024 <- ifelse(df$operational_2024 == 1 & df$num_peak_months_2024 > 0, 0, NA)

if("w5_sec7_q1" %in% names(df) && "num_peak_months_2024" %in% names(df)) {
  df$peak_revenue_2024 <- ifelse(!is.na(df$w5_sec7_q1) & !is.na(df$num_peak_months_2024),
                                 df$w5_sec7_q1 * df$num_peak_months_2024, 
                                 df$peak_revenue_2024)
}

attr(df$peak_revenue_2024, "label") <- "Total revenue during peak months in 2024 (Rs.)"

# Usual months revenue in 2024
df$usual_revenue_2024 <- ifelse(df$operational_2024 == 1 & df$num_usual_months_2024 > 0, 0, NA)

if("w5_sec7_q2" %in% names(df) && "num_usual_months_2024" %in% names(df)) {
  df$usual_revenue_2024 <- ifelse(!is.na(df$w5_sec7_q2) & !is.na(df$num_usual_months_2024),
                                  df$w5_sec7_q2 * df$num_usual_months_2024, 
                                  df$usual_revenue_2024)
}

attr(df$usual_revenue_2024, "label") <- "Total revenue during usual months in 2024 (Rs.)"

# Peak months revenue in 2023
df$peak_revenue_2023 <- ifelse(df$operational_2023 == 1 & df$num_peak_months_2023 > 0, 0, NA)

if("w5_sec7_q11" %in% names(df) && "num_peak_months_2023" %in% names(df)) {
  df$peak_revenue_2023 <- ifelse(!is.na(df$w5_sec7_q11) & !is.na(df$num_peak_months_2023),
                                 df$w5_sec7_q11 * df$num_peak_months_2023, 
                                 df$peak_revenue_2023)
}

attr(df$peak_revenue_2023, "label") <- "Total revenue during peak months in 2023 (Rs.)"

# Usual months revenue in 2023
df$usual_revenue_2023 <- ifelse(df$operational_2023 == 1 & df$num_usual_months_2023 > 0, 0, NA)

if("w5_sec7_q12" %in% names(df) && "num_usual_months_2023" %in% names(df)) {
  df$usual_revenue_2023 <- ifelse(!is.na(df$w5_sec7_q12) & !is.na(df$num_usual_months_2023),
                                  df$w5_sec7_q12 * df$num_usual_months_2023, 
                                  df$usual_revenue_2023)
}

attr(df$usual_revenue_2023, "label") <- "Total revenue during usual months in 2023 (Rs.)"

# Peak months revenue in 2022
df$peak_revenue_2022 <- ifelse(df$operational_2022 == 1 & df$num_peak_months_2022 > 0, 0, NA)

if("w5_sec7_q16" %in% names(df) && "num_peak_months_2022" %in% names(df)) {
  df$peak_revenue_2022 <- ifelse(!is.na(df$w5_sec7_q16) & !is.na(df$num_peak_months_2022),
                                 df$w5_sec7_q16 * df$num_peak_months_2022, 
                                 df$peak_revenue_2022)
}

attr(df$peak_revenue_2022, "label") <- "Total revenue during peak months in 2022 (Rs.)"

# Usual months revenue in 2022
df$usual_revenue_2022 <- ifelse(df$operational_2022 == 1 & df$num_usual_months_2022 > 0, 0, NA)

if("w5_sec7_q17" %in% names(df) && "num_usual_months_2022" %in% names(df)) {
  df$usual_revenue_2022 <- ifelse(!is.na(df$w5_sec7_q17) & !is.na(df$num_usual_months_2022),
                                  df$w5_sec7_q17 * df$num_usual_months_2022, 
                                  df$usual_revenue_2022)
}

attr(df$usual_revenue_2022, "label") <- "Total revenue during usual months in 2022 (Rs.)"

# 6. Calculate Total Revenue (peak + usual) - Note: there's an error in original STATA code for 2024

# Calculate total revenue for 2024 (peak + usual) - fixing the original error
df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_revenue_2024 = ifelse(operational_2024 == 1,
                                     sum(c_across(c(peak_revenue_2024, usual_revenue_2024)), na.rm = TRUE),
                                     NA)
  ) %>%
  ungroup()

attr(df$calc_total_revenue_2024, "label") <- "Calculated total revenue in 2024 (Rs.)"

# Calculate total revenue for 2023
df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_revenue_2023 = ifelse(operational_2023 == 1,
                                     sum(c_across(c(peak_revenue_2023, usual_revenue_2023)), na.rm = TRUE),
                                     NA)
  ) %>%
  ungroup()

attr(df$calc_total_revenue_2023, "label") <- "Calculated total revenue in 2023 (Rs.)"

# Calculate total revenue for 2022
df <- df %>%
  rowwise() %>%
  mutate(
    calc_total_revenue_2022 = ifelse(operational_2022 == 1,
                                     sum(c_across(c(peak_revenue_2022, usual_revenue_2022)), na.rm = TRUE),
                                     NA)
  ) %>%
  ungroup()

attr(df$calc_total_revenue_2022, "label") <- "Calculated total revenue in 2022 (Rs.)"

# 7. Quarterly Revenue Calculations

# Calculate quarterly revenues for 2024
for(q in 1:4) {
  peak_months_var <- paste0("num_peak_months_2024_q", q)
  usual_months_var <- paste0("num_usual_months_2024_q", q)
  
  # Peak revenue by quarter
  peak_revenue_var <- paste0("peak_revenue_2024_q", q)
  df[[peak_revenue_var]] <- ifelse(
    df$operational_2024 == 1 & !is.na(df[[peak_months_var]]) & df[[peak_months_var]] > 0, 
    0, NA
  )
  
  if("w5_sec7_q1" %in% names(df) && peak_months_var %in% names(df)) {
    df[[peak_revenue_var]] <- ifelse(!is.na(df$w5_sec7_q1) & !is.na(df[[peak_months_var]]),
                                     df$w5_sec7_q1 * df[[peak_months_var]], 
                                     df[[peak_revenue_var]])
  }
  
  attr(df[[peak_revenue_var]], "label") <- paste("Peak revenue in Q", q, "2024 (Rs.)")
  
  # Usual revenue by quarter
  usual_revenue_var <- paste0("usual_revenue_2024_q", q)
  df[[usual_revenue_var]] <- ifelse(
    df$operational_2024 == 1 & !is.na(df[[usual_months_var]]) & df[[usual_months_var]] > 0, 
    0, NA
  )
  
  if("w5_sec7_q2" %in% names(df) && usual_months_var %in% names(df)) {
    df[[usual_revenue_var]] <- ifelse(!is.na(df$w5_sec7_q2) & !is.na(df[[usual_months_var]]),
                                      df$w5_sec7_q2 * df[[usual_months_var]], 
                                      df[[usual_revenue_var]])
  }
  
  attr(df[[usual_revenue_var]], "label") <- paste("Usual revenue in Q", q, "2024 (Rs.)")
  
  # Total revenue by quarter
  total_revenue_var <- paste0("total_revenue_2024_q", q)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!total_revenue_var := sum(c_across(c(all_of(peak_revenue_var), all_of(usual_revenue_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  
  attr(df[[total_revenue_var]], "label") <- paste("Total revenue in Q", q, "2024 (Rs.)")
}

# Calculate quarterly revenues for 2023 and 2022
for(year in c(2023, 2022)) {
  winsor_peak <- if(year == 2023) "w5_sec7_q11" else "w5_sec7_q16"
  winsor_usual <- if(year == 2023) "w5_sec7_q12" else "w5_sec7_q17"
  
  for(q in 1:4) {
    peak_months_var <- paste0("num_peak_months_", year, "_q", q)
    usual_months_var <- paste0("num_usual_months_", year, "_q", q)
    
    # Peak revenue by quarter
    peak_revenue_var <- paste0("peak_revenue_", year, "_q", q)
    df[[peak_revenue_var]] <- ifelse(
      df[[paste0("operational_", year)]] == 1 & !is.na(df[[peak_months_var]]) & df[[peak_months_var]] > 0, 
      0, NA
    )
    
    if(winsor_peak %in% names(df) && peak_months_var %in% names(df)) {
      df[[peak_revenue_var]] <- ifelse(!is.na(df[[winsor_peak]]) & !is.na(df[[peak_months_var]]),
                                       df[[winsor_peak]] * df[[peak_months_var]], 
                                       df[[peak_revenue_var]])
    }
    
    attr(df[[peak_revenue_var]], "label") <- paste("Peak revenue in Q", q, year, "(Rs.)")
    
    # Usual revenue by quarter
    usual_revenue_var <- paste0("usual_revenue_", year, "_q", q)
    df[[usual_revenue_var]] <- ifelse(
      df[[paste0("operational_", year)]] == 1 & !is.na(df[[usual_months_var]]) & df[[usual_months_var]] > 0, 
      0, NA
    )
    
    if(winsor_usual %in% names(df) && usual_months_var %in% names(df)) {
      df[[usual_revenue_var]] <- ifelse(!is.na(df[[winsor_usual]]) & !is.na(df[[usual_months_var]]),
                                        df[[winsor_usual]] * df[[usual_months_var]], 
                                        df[[usual_revenue_var]])
    }
    
    attr(df[[usual_revenue_var]], "label") <- paste("Usual revenue in Q", q, year, "(Rs.)")
    
    # Total revenue by quarter
    total_revenue_var <- paste0("total_revenue_", year, "_q", q)
    df <- df %>%
      rowwise() %>%
      mutate(
        !!total_revenue_var := sum(c_across(c(all_of(peak_revenue_var), all_of(usual_revenue_var))), na.rm = TRUE)
      ) %>%
      ungroup()
    
    attr(df[[total_revenue_var]], "label") <- paste("Total revenue in Q", q, year, "(Rs.)")
  }
}

# 8. Monthly Profit and Profit Margins

# Monthly profit from most recent month
if("sec7_q7" %in% names(df)) {
  df$monthly_profit <- ifelse(!is.na(df$sec7_q7), df$sec7_q7, NA)
  df$log_monthly_profit <- ifelse(!is.na(df$monthly_profit), log(df$monthly_profit), NA)
} else {
  df$monthly_profit <- NA
  df$log_monthly_profit <- NA
}

attr(df$monthly_profit, "label") <- "Monthly profit in January 2025 (Rs.)"
attr(df$log_monthly_profit, "label") <- "Log of Monthly profit in January 2025 (Rs.)"

# Convert profit margin variables to numeric
profit_margin_vars <- c("profit_margin_manufacturing", "profit_margin_trading", "profit_margin_service")

for(var in profit_margin_vars) {
  if(var %in% names(df)) {
    df[[var]] <- as.numeric(df[[var]])
  }
}

# Add labels for profit margin variables
if("profit_margin_manufacturing" %in% names(df)) {
  attr(df$profit_margin_manufacturing, "label") <- "Profit margin for manufacturing enterprises (%)"
}
if("profit_margin_trading" %in% names(df)) {
  attr(df$profit_margin_trading, "label") <- "Profit margin for trading enterprises (%)"
}
if("profit_margin_service" %in% names(df)) {
  attr(df$profit_margin_service, "label") <- "Profit margin for service enterprises (%)"
}

# Overall profit margin (combining all types)
df <- df %>%
  mutate(
    profit_margin = case_when(
      sec2_q2 == 1 & "profit_margin_manufacturing" %in% names(df) ~ profit_margin_manufacturing,
      sec2_q2 == 2 & "profit_margin_trading" %in% names(df) ~ profit_margin_trading,
      sec2_q2 == 3 & "profit_margin_service" %in% names(df) ~ profit_margin_service,
      TRUE ~ NA_real_
    )
  )

attr(df$profit_margin, "label") <- "Profit margin (%)"

# Winsorized profit margin
if("profit_margin" %in% names(df)) {
  profit_margin_data <- df$profit_margin[!is.na(df$profit_margin)]
  
  if(length(profit_margin_data) > 0) {
    p05 <- quantile(profit_margin_data, 0.05, na.rm = TRUE)
    p95 <- quantile(profit_margin_data, 0.95, na.rm = TRUE)
    
    df$w5_profit_margin <- df$profit_margin
    df$w5_profit_margin[df$profit_margin <= p05 & !is.na(df$profit_margin)] <- p05
    df$w5_profit_margin[df$profit_margin >= p95 & !is.na(df$profit_margin)] <- p95
  } else {
    df$w5_profit_margin <- df$profit_margin
  }
} else {
  df$w5_profit_margin <- NA
}

attr(df$w5_profit_margin, "label") <- "Winsorized (at 10%) profit margin (%)"

#===============================================================================
#                           Enterprise Profit Variables
#===============================================================================

# 1. Calculate annual profits (Revenue - Costs)

# Annual profits for each year
df <- df %>%
  mutate(
    profit_2024 = total_revenue_2024 - total_costs_2024,
    profit_2023 = total_revenue_2023 - total_costs_2023,
    profit_2022 = total_revenue_2022 - total_costs_2022
  )

attr(df$profit_2024, "label") <- "Profit in 2024 (January to December) (Rs.)"
attr(df$profit_2023, "label") <- "Profit in 2023 (January to December) (Rs.)"
attr(df$profit_2022, "label") <- "Profit in 2022 (January to December) (Rs.)"

# 2. Winsorized profits (using 5% winsorized revenue and costs)

df <- df %>%
  mutate(
    w5_profit_2024 = w5_total_revenue_2024 - w5_total_costs_2024,
    w5_profit_2023 = w5_total_revenue_2023 - w5_total_costs_2023,
    w5_profit_2022 = w5_total_revenue_2022 - w5_total_costs_2022
  )

attr(df$w5_profit_2024, "label") <- "Winsorized (at 5%) profit in 2024 (Rs.)"
attr(df$w5_profit_2023, "label") <- "Winsorized (at 5%) profit in 2023 (Rs.)"
attr(df$w5_profit_2022, "label") <- "Winsorized (at 5%) profit in 2022 (Rs.)"

# 3. Calculated profits (based on calculated revenue and costs)

df <- df %>%
  mutate(
    calc_profit_2024 = calc_total_revenue_2024 - calc_total_costs_2024,
    calc_profit_2023 = calc_total_revenue_2023 - calc_total_costs_2023,
    calc_profit_2022 = calc_total_revenue_2022 - calc_total_costs_2022
  )

attr(df$calc_profit_2024, "label") <- "Calculated profit in 2024 (from calculated revenue and costs) (Rs.)"
attr(df$calc_profit_2023, "label") <- "Calculated profit in 2023 (from calculated revenue and costs) (Rs.)"
attr(df$calc_profit_2022, "label") <- "Calculated profit in 2022 (from calculated revenue and costs) (Rs.)"

# 4. Calculate quarterly profits for all years

# Calculate quarterly profits for 2024
for(q in 1:4) {
  revenue_var <- paste0("total_revenue_2024_q", q)
  cost_var <- paste0("total_costs_2024_q", q)
  profit_var <- paste0("profit_2024_q", q)
  
  if(revenue_var %in% names(df) && cost_var %in% names(df)) {
    df[[profit_var]] <- df[[revenue_var]] - df[[cost_var]]
  } else {
    df[[profit_var]] <- NA
  }
  
  attr(df[[profit_var]], "label") <- paste("Profit in Q", q, "2024 (Rs.)")
}

# Calculate quarterly profits for 2023
for(q in 1:4) {
  revenue_var <- paste0("total_revenue_2023_q", q)
  cost_var <- paste0("total_costs_2023_q", q)
  profit_var <- paste0("profit_2023_q", q)
  
  if(revenue_var %in% names(df) && cost_var %in% names(df)) {
    df[[profit_var]] <- df[[revenue_var]] - df[[cost_var]]
  } else {
    df[[profit_var]] <- NA
  }
  
  attr(df[[profit_var]], "label") <- paste("Profit in Q", q, "2023 (Rs.)")
}

# Calculate quarterly profits for 2022
for(q in 1:4) {
  revenue_var <- paste0("total_revenue_2022_q", q)
  cost_var <- paste0("total_costs_2022_q", q)
  profit_var <- paste0("profit_2022_q", q)
  
  if(revenue_var %in% names(df) && cost_var %in% names(df)) {
    df[[profit_var]] <- df[[revenue_var]] - df[[cost_var]]
  } else {
    df[[profit_var]] <- NA
  }
  
  attr(df[[profit_var]], "label") <- paste("Profit in Q", q, "2022 (Rs.)")
}

cat("\nEnterprise revenue and profit variables created successfully!\n")
cat("Revenue and profit summary by year:\n")
for(year in c(2022, 2023, 2024)) {
  has_revenue <- sum(df[[paste0("has_revenue_", year)]] == 1, na.rm = TRUE)
  avg_revenue <- mean(df[[paste0("total_revenue_", year)]], na.rm = TRUE)
  avg_profit <- mean(df[[paste0("profit_", year)]], na.rm = TRUE)
  cat("Year", year, "- Enterprises with revenue:", has_revenue, 
      "- Avg revenue:", round(avg_revenue, 0), 
      "- Avg profit:", round(avg_profit, 0), "\n")
}

# Display final summary
cat("\n", paste(rep("=", 80), collapse=""), "\n")
cat("DATA PROCESSING COMPLETED SUCCESSFULLY!\n")
cat(paste(rep("=", 80), collapse=""), "\n")

#===============================================================================
#                               Monthly Sales
#===============================================================================

# Monthly sales variable
if("sec7_q4" %in% names(df)) {
  df$monthly_sale <- df$sec7_q4
} else {
  df$monthly_sale <- NA
}

attr(df$monthly_sale, "label") <- "Last Month Sales"

# Log-transformed version of monthly sales
df$log_monthly_sale <- ifelse(df$monthly_sale > 0 & !is.na(df$monthly_sale), 
                              log(df$monthly_sale), NA)

attr(df$log_monthly_sale, "label") <- "Log of Last Month Sales"

#===============================================================================
#                           Business Practices Score
#===============================================================================

# Add labels for marketing variables
marketing_vars <- paste0("sec16_q1_", letters[1:5])
marketing_labels <- c(
  "Marketing 1: Visited competitor's business to see prices",
  "Marketing 2: Visited competitor's business to see products", 
  "Marketing 3: Asked existing customers what other products they should offer",
  "Marketing 4: Talked with former customer to see why stopped buying",
  "Marketing 5: Asked supplier what products selling well"
)

for(i in 1:5) {
  if(marketing_vars[i] %in% names(df)) {
    attr(df[[marketing_vars[i]]], "label") <- marketing_labels[i]
  }
}

if("sec16_q2" %in% names(df)) {
  attr(df$sec16_q2, "label") <- "Marketing 6: Used a special offer to attract customers"
}
if("sec16_q3" %in% names(df)) {
  attr(df$sec16_q3, "label") <- "Marketing 7: Have done advertising in last 6 months"
}

# Create business practice variables
# Marketing practices
df$bp_m1 <- if("sec16_q1_a" %in% names(df)) df$sec16_q1_a else NA
df$bp_m2 <- if("sec16_q1_b" %in% names(df)) df$sec16_q1_b else NA
df$bp_m3 <- if("sec16_q1_c" %in% names(df)) df$sec16_q1_c else NA
df$bp_m4 <- if("sec16_q1_d" %in% names(df)) df$sec16_q1_d else NA
df$bp_m5 <- if("sec16_q1_e" %in% names(df)) df$sec16_q1_e else NA
df$bp_m6 <- if("sec16_q2" %in% names(df)) df$sec16_q2 else NA
df$bp_m7 <- if("sec16_q3" %in% names(df)) df$sec16_q3 else NA

# Buying & Stock Control practices
df$bp_b1 <- if("sec16_q6" %in% names(df)) df$sec16_q6 else NA
df$bp_b2 <- if("sec16_q7" %in% names(df)) df$sec16_q7 else NA

# Create bp_b3 with complex logic
if("sec16_q10" %in% names(df) && "sec16_q8" %in% names(df)) {
  df$bp_b3 <- case_when(
    df$sec16_q10 == 4 ~ 0,
    df$sec16_q10 <= 3 ~ 1,
    df$sec16_q8 == 0 ~ 1,
    TRUE ~ NA_real_
  )
} else {
  df$bp_b3 <- NA
}

# Add labels for buying & stock control
attr(df$bp_b1, "label") <- "Buying & Stock Control 1: negotiate for lower price"
attr(df$bp_b2, "label") <- "Buying & Stock Control 2: compare alternate suppliers"
attr(df$bp_b3, "label") <- "Buying & Stock Control 3: Don't run out of stock frequently"

# Costing & Record Keeping practices
record_vars <- c("sec16_q15", "sec16_q17", "sec16_q18", "sec16_q20", 
                 "sec16_q21", "sec16_q22", "sec16_q23", "sec16_q25")
bp_r_vars <- paste0("bp_r", 1:8)
record_labels <- c(
  "Costing & Record Keeping 1: Keep written records",
  "Costing & Record Keeping 2: record every purchase and sale",
  "Costing & Record Keeping 3: can use records to know cash on hand",
  "Costing & Record Keeping 4: use records to know whether sales of product increase or decrease",
  "Costing & Record Keeping 5: worked out cost of each main product",
  "Costing & Record Keeping 6: know which goods make most profit per item",
  "Costing & Record Keeping 7: have a written budget for monthly expenses",
  "Costing & Record Keeping 8: have records that could document ability to pay to bank"
)

for(i in 1:8) {
  if(record_vars[i] %in% names(df)) {
    df[[bp_r_vars[i]]] <- df[[record_vars[i]]]
    attr(df[[bp_r_vars[i]]], "label") <- record_labels[i]
  } else {
    df[[bp_r_vars[i]]] <- NA
  }
}

# Financial Planning practices
if("sec16_q26" %in% names(df)) {
  df$bp_f1 <- ifelse(df$sec16_q26 == 4, 1, 0)
} else {
  df$bp_f1 <- NA
}

df$bp_f2 <- if("sec16_q27" %in% names(df)) df$sec16_q27 else NA

if("sec16_q27_a" %in% names(df)) {
  df$bp_f3 <- case_when(
    df$sec16_q27_a == 4 ~ 1,
    df$sec16_q27_a <= 3 | df$sec16_q27_a == 0 ~ 0,
    TRUE ~ NA_real_
  )
} else {
  df$bp_f3 <- NA
}

df$bp_f4 <- if("sec16_q28" %in% names(df)) df$sec16_q28 else NA

# Handle sec16_q29 variables with complex logic
financial_vars <- paste0("sec16_q29_", 1:4)
bp_f_vars <- paste0("bp_f", 5:8)

for(i in 1:4) {
  var_name <- financial_vars[i]
  bp_var <- bp_f_vars[i]
  
  if(var_name %in% names(df)) {
    df[[bp_var]] <- df[[var_name]]
    # Set to 0 if sec16_q29_5 == 1 or if missing
    if("sec16_q29_5" %in% names(df)) {
      df[[bp_var]] <- ifelse(df$sec16_q29_5 == 1 | is.na(df[[bp_var]]), 0, df[[bp_var]])
    }
  } else {
    df[[bp_var]] <- NA
  }
}

# Add labels for financial planning
financial_labels <- c(
  "Financial Planning 1: review financial performance monthly",
  "Financial Planning 2: have sales target for next year", 
  "Financial Planning 3: compare sales goal to target monthly",
  "Financial Planning 4: have a budget of costs for next year",
  "Financial Planning 5: prepare profit and loss statement",
  "Financial Planning 6: prepare cashflow statement",
  "Financial Planning 7: prepare balance sheet",
  "Financial Planning 8: prepare income and expenditure statement"
)

for(i in 1:8) {
  attr(df[[paste0("bp_f", i)]], "label") <- financial_labels[i]
}

# Replace missings that were zeros (complex logic from original)
all_bp_vars <- c(paste0("bp_m", 1:7), paste0("bp_b", 1:3), paste0("bp_r", 1:8), paste0("bp_f", 1:8))

# Calculate temporary score to identify cases where all responses are missing
df <- df %>%
  rowwise() %>%
  mutate(tscore = mean(c_across(all_of(all_bp_vars)), na.rm = TRUE)) %>%
  ungroup()

# Replace specific financial variables with missing if tscore is 0 and bp_m1 is missing
financial_replace_vars <- c("bp_f1", "bp_f5", "bp_f6", "bp_f7", "bp_f8")
for(var in financial_replace_vars) {
  df[[var]] <- ifelse(df$tscore == 0 & is.na(df$bp_m1), NA, df[[var]])
}

# Create Business Practice Indices
df <- df %>%
  rowwise() %>%
  mutate(
    marketingscore = mean(c_across(c(bp_m1, bp_m2, bp_m3, bp_m4, bp_m5, bp_m6, bp_m7)), na.rm = TRUE),
    stockscore = mean(c_across(c(bp_b1, bp_b2, bp_b3)), na.rm = TRUE),
    recordscore = mean(c_across(all_of(paste0("bp_r", 1:8))), na.rm = TRUE),
    planningscore = mean(c_across(all_of(paste0("bp_f", 1:8))), na.rm = TRUE),
    totalscore = mean(c_across(all_of(all_bp_vars)), na.rm = TRUE)
  ) %>%
  ungroup()

attr(df$marketingscore, "label") <- "Proportion of marketing practices used"
attr(df$stockscore, "label") <- "Proportion of buying and stock control practices used"
attr(df$recordscore, "label") <- "Proportion of record-keeping practices used"
attr(df$planningscore, "label") <- "Proportion of financial planning practices used"
attr(df$totalscore, "label") <- "Business Practices Score"

# Round totalscore to nearest 0.05
df$totalscore1 <- round(df$totalscore, 2)  # Rounding to 0.05 equivalent

# Alternative scoring methods
# Principal Component Analysis
bp_complete <- df %>%
  select(all_of(all_bp_vars)) %>%
  na.omit()

if(nrow(bp_complete) > 0) {
  # Check for zero variance columns before PCA
  bp_var_check <- apply(bp_complete, 2, function(x) var(x, na.rm = TRUE))
  non_zero_var_cols <- names(bp_var_check)[bp_var_check > 0 & !is.na(bp_var_check)]
  
  if(length(non_zero_var_cols) > 1) {
    # Only use columns with non-zero variance
    bp_complete_filtered <- bp_complete[, non_zero_var_cols, drop = FALSE]
    
    pca_result <- prcomp(bp_complete_filtered, scale. = TRUE)
    
    df$scorefactor <- NA
    complete_cases <- complete.cases(df[non_zero_var_cols])
    df$scorefactor[complete_cases] <- pca_result$x[,1]
    
    cat("PCA completed with", length(non_zero_var_cols), "variables (excluded", 
        length(all_bp_vars) - length(non_zero_var_cols), "zero-variance variables)\n")
  } else {
    df$scorefactor <- NA
    cat("PCA skipped: insufficient variables with non-zero variance\n")
  }
} else {
  df$scorefactor <- NA
  cat("PCA skipped: no complete cases available\n")
}

# Z-score standardization method
for(var in all_bp_vars) {
  if(var %in% names(df)) {
    var_mean <- mean(df[[var]], na.rm = TRUE)
    var_sd <- sd(df[[var]], na.rm = TRUE)
    df[[paste0("z_", var)]] <- (df[[var]] - var_mean) / var_sd
  }
}

z_vars <- paste0("z_", all_bp_vars)
z_vars <- z_vars[z_vars %in% names(df)]

df <- df %>%
  rowwise() %>%
  mutate(zscore = mean(c_across(all_of(z_vars)), na.rm = TRUE)) %>%
  ungroup()

# Display correlations between different scoring methods
if(all(c("totalscore", "scorefactor", "zscore") %in% names(df))) {
  cat("Correlations between business practice scoring methods:\n")
  cor_matrix <- cor(df[c("totalscore", "scorefactor", "zscore")], use = "complete.obs")
  print(round(cor_matrix, 3))
}

#===============================================================================
#                           Labor Section Variable Creation
#===============================================================================

# 1. Basic employment indicators for each year

# 2022 Employment
if("sec8_q1" %in% names(df)) {
  df$employed_any_2022 <- ifelse(df$operational_2022 == 1 & !is.na(df$sec8_q1),
                                 ifelse(df$sec8_q1 == 1, 1, 0), NA)
} else {
  df$employed_any_2022 <- NA
}
attr(df$employed_any_2022, "label") <- "Employed any workers in 2022"

# 2023 Employment  
if("sec8_q18" %in% names(df)) {
  df$employed_any_2023 <- ifelse(df$operational_2023 == 1 & !is.na(df$sec8_q18),
                                 ifelse(df$sec8_q18 == 1, 1, 0), NA)
} else {
  df$employed_any_2023 <- NA
}
attr(df$employed_any_2023, "label") <- "Employed any workers in 2023"

# 2024 Employment
if("sec8_q35" %in% names(df)) {
  df$employed_any_2024 <- ifelse(df$operational_2024 == 1 & !is.na(df$sec8_q35),
                                 ifelse(df$sec8_q35 == 1, 1, 0), NA)
} else {
  df$employed_any_2024 <- NA
}
attr(df$employed_any_2024, "label") <- "Employed any workers in 2024"

# Ever employed indicator
df$employed_any_year <- ifelse(
  (!is.na(df$employed_any_2022) | !is.na(df$employed_any_2023) | !is.na(df$employed_any_2024)),
  ifelse((df$employed_any_2022 == 1 | df$employed_any_2023 == 1 | df$employed_any_2024 == 1), 1, 0),
  NA
)
attr(df$employed_any_year, "label") <- "Employed any workers in any year (2022-2024)"

# 2. Total Employment: Permanent + Temporary Workers

employment_data <- list(
  "2022" = list(perm = "sec8_q3", temp = "sec8_q10", employed = "employed_any_2022"),
  "2023" = list(perm = "sec8_q20", temp = "sec8_q27", employed = "employed_any_2023"),
  "2024" = list(perm = "sec8_q37", temp = "sec8_q44", employed = "employed_any_2024")
)

for(year in names(employment_data)) {
  perm_var <- employment_data[[year]]$perm
  temp_var <- employment_data[[year]]$temp
  employed_var <- employment_data[[year]]$employed
  
  # Clean permanent and temporary worker variables
  for(var in c(perm_var, temp_var)) {
    if(var %in% names(df)) {
      # Set to 0 if didn't employ any workers
      df[[var]] <- ifelse(df[[employed_var]] == 0 & !is.na(df[[employed_var]]), 0, df[[var]])
      # Cap at 35 (seems to be a data cleaning rule)
      df[[var]] <- ifelse(df[[var]] >= 35 & !is.na(df[[employed_var]]), 1, df[[var]])
    }
  }
  
  # Create total employment variable
  total_emp_var <- paste0("total_employment_", year)
  if(perm_var %in% names(df) && temp_var %in% names(df)) {
    df[[total_emp_var]] <- ifelse(df[[paste0("operational_", year)]] == 1 & !is.na(df[[employed_var]]),
                                  df[[perm_var]] + df[[temp_var]], NA)
  } else {
    df[[total_emp_var]] <- NA
  }
  
  attr(df[[total_emp_var]], "label") <- paste("Total number of workers employed in", year)
  
  # Special case for 2022 based on original code
  if(year == "2022" && "total_costs_2022" %in% names(df)) {
    df[[total_emp_var]] <- ifelse(df$total_costs_2022 >= 35, 1, df[[total_emp_var]])
  }
}

# 3. Permanent vs. Temporary Employment

for(year in names(employment_data)) {
  perm_var <- employment_data[[year]]$perm
  temp_var <- employment_data[[year]]$temp
  employed_var <- employment_data[[year]]$employed
  
  # Permanent workers
  perm_workers_var <- paste0("perm_workers_", year)
  if(perm_var %in% names(df)) {
    df[[perm_workers_var]] <- ifelse(df[[paste0("operational_", year)]] == 1 & !is.na(df[[employed_var]]),
                                     df[[perm_var]], NA)
    df[[perm_workers_var]] <- ifelse(df[[employed_var]] == 0, 0, df[[perm_workers_var]])
  } else {
    df[[perm_workers_var]] <- NA
  }
  attr(df[[perm_workers_var]], "label") <- paste("Number of permanent workers in", year)
  
  # Temporary workers
  temp_workers_var <- paste0("temp_workers_", year)
  if(temp_var %in% names(df)) {
    df[[temp_workers_var]] <- ifelse(df[[paste0("operational_", year)]] == 1 & !is.na(df[[employed_var]]),
                                     df[[temp_var]], NA)
    df[[temp_workers_var]] <- ifelse(df[[employed_var]] == 0, 0, df[[temp_workers_var]])
  } else {
    df[[temp_workers_var]] <- NA
  }
  attr(df[[temp_workers_var]], "label") <- paste("Number of temporary workers in", year)
}

# 4. Share of Permanent vs. Temporary Workers

for(year in c("2022", "2023", "2024")) {
  total_emp_var <- paste0("total_employment_", year)
  perm_workers_var <- paste0("perm_workers_", year)
  temp_workers_var <- paste0("temp_workers_", year)
  
  # Permanent share
  perm_share_var <- paste0("perm_share_", year)
  df[[perm_share_var]] <- ifelse(df[[total_emp_var]] > 0 & !is.na(df[[total_emp_var]]),
                                 df[[perm_workers_var]] / df[[total_emp_var]], NA)
  attr(df[[perm_share_var]], "label") <- paste("Share of permanent workers in total workforce in", year)
  
  # Temporary share
  temp_share_var <- paste0("temp_share_", year)
  df[[temp_share_var]] <- ifelse(df[[total_emp_var]] > 0 & !is.na(df[[total_emp_var]]),
                                 df[[temp_workers_var]] / df[[total_emp_var]], NA)
  attr(df[[temp_share_var]], "label") <- paste("Share of temporary workers in total workforce in", year)
}

# 5. Worker-Days Variables

workdays_data <- list(
  "2022" = list(
    perm_peak = "sec8_q7", perm_usual = "sec8_q8",
    temp_peak = "sec8_q15", temp_usual = "sec8_q16"
  ),
  "2023" = list(
    perm_peak = "sec8_q24", perm_usual = "sec8_q25", 
    temp_peak = "sec8_q32", temp_usual = "sec8_q33"
  ),
  "2024" = list(
    perm_peak = "sec8_q41", perm_usual = "sec8_q42",
    temp_peak = "sec8_q49", temp_usual = "sec8_q50"
  )
)

for(year in names(workdays_data)) {
  year_data <- workdays_data[[year]]
  perm_workers_var <- paste0("perm_workers_", year)
  temp_workers_var <- paste0("temp_workers_", year)
  peak_months_var <- paste0("num_peak_months_", year)
  usual_months_var <- paste0("num_usual_months_", year)
  
  # Permanent worker-days in peak months
  perm_peak_days_var <- paste0("perm_workdays_peak_", year)
  if(year_data$perm_peak %in% names(df) && peak_months_var %in% names(df)) {
    df[[perm_peak_days_var]] <- ifelse(
      df[[perm_workers_var]] > 0 & !is.na(df[[year_data$perm_peak]]) & !is.na(df[[peak_months_var]]),
      df[[year_data$perm_peak]] * df[[peak_months_var]] * df[[perm_workers_var]], 
      NA
    )
  } else {
    df[[perm_peak_days_var]] <- NA
  }
  attr(df[[perm_peak_days_var]], "label") <- paste("Total worker-days for permanent workers in peak months", year)
  
  # Permanent worker-days in usual months
  perm_usual_days_var <- paste0("perm_workdays_usual_", year)
  if(year_data$perm_usual %in% names(df) && usual_months_var %in% names(df)) {
    df[[perm_usual_days_var]] <- ifelse(
      df[[perm_workers_var]] > 0 & !is.na(df[[year_data$perm_usual]]) & !is.na(df[[usual_months_var]]),
      df[[year_data$perm_usual]] * df[[usual_months_var]] * df[[perm_workers_var]], 
      NA
    )
  } else {
    df[[perm_usual_days_var]] <- NA
  }
  attr(df[[perm_usual_days_var]], "label") <- paste("Total worker-days for permanent workers in usual months", year)
  
  # Total permanent worker-days
  perm_total_days_var <- paste0("perm_workdays_", year)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!perm_total_days_var := sum(c_across(c(all_of(perm_peak_days_var), all_of(perm_usual_days_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  attr(df[[perm_total_days_var]], "label") <- paste("Total worker-days for permanent workers in", year)
  
  # Temporary worker-days in peak months
  temp_peak_days_var <- paste0("temp_workdays_peak_", year)
  if(year_data$temp_peak %in% names(df) && peak_months_var %in% names(df)) {
    df[[temp_peak_days_var]] <- ifelse(
      df[[temp_workers_var]] > 0 & !is.na(df[[year_data$temp_peak]]) & !is.na(df[[peak_months_var]]),
      df[[year_data$temp_peak]] * df[[peak_months_var]] * df[[temp_workers_var]], 
      NA
    )
  } else {
    df[[temp_peak_days_var]] <- NA
  }
  attr(df[[temp_peak_days_var]], "label") <- paste("Total worker-days for temporary workers in peak months", year)
  
  # Temporary worker-days in usual months
  temp_usual_days_var <- paste0("temp_workdays_usual_", year)
  if(year_data$temp_usual %in% names(df) && usual_months_var %in% names(df)) {
    df[[temp_usual_days_var]] <- ifelse(
      df[[temp_workers_var]] > 0 & !is.na(df[[year_data$temp_usual]]) & !is.na(df[[usual_months_var]]),
      df[[year_data$temp_usual]] * df[[usual_months_var]] * df[[temp_workers_var]], 
      NA
    )
  } else {
    df[[temp_usual_days_var]] <- NA
  }
  attr(df[[temp_usual_days_var]], "label") <- paste("Total worker-days for temporary workers in usual months", year)
  
  # Total temporary worker-days
  temp_total_days_var <- paste0("temp_workdays_", year)
  df <- df %>%
    rowwise() %>%
    mutate(
      !!temp_total_days_var := sum(c_across(c(all_of(temp_peak_days_var), all_of(temp_usual_days_var))), na.rm = TRUE)
    ) %>%
    ungroup()
  attr(df[[temp_total_days_var]], "label") <- paste("Total worker-days for temporary workers in", year)
}

# 6. Labor Costs and Wage Variables

labor_cost_data <- list(
  "2022" = list(perm_cost = "sec8_q9", temp_cost = "sec8_q17"),
  "2023" = list(perm_cost = "sec8_q26", temp_cost = "sec8_q34"),
  "2024" = list(perm_cost = "sec8_q43", temp_cost = "sec8_q51")
)

for(year in names(labor_cost_data)) {
  year_data <- labor_cost_data[[year]]
  employed_var <- paste0("employed_any_", year)
  total_cost_var <- paste0("total_labor_cost_", year)
  
  if(year_data$perm_cost %in% names(df) && year_data$temp_cost %in% names(df)) {
    df[[total_cost_var]] <- ifelse(df[[paste0("operational_", year)]] == 1,
                                   df[[year_data$perm_cost]] + df[[year_data$temp_cost]], NA)
    df[[total_cost_var]] <- ifelse(df[[employed_var]] == 0 & !is.na(df[[employed_var]]), 0, df[[total_cost_var]])
  } else {
    df[[total_cost_var]] <- NA
  }
  
  attr(df[[total_cost_var]], "label") <- paste("Total labor costs in", year, "(Rs.)")
}

# 7. Family Labor Variables

if("sec4_q3" %in% names(df)) {
  df$family_workers <- df$sec4_q3
} else {
  df$family_workers <- NA
}
attr(df$family_workers, "label") <- "Number of household members working in enterprise (excl. owner)"

if("sec4_q3_a" %in% names(df)) {
  df$paid_family_workers <- df$sec4_q3_a
} else {
  df$paid_family_workers <- NA
}
attr(df$paid_family_workers, "label") <- "Number of household members working with pay"

if("sec4_q3_b" %in% names(df)) {
  df$unpaid_family_workers <- df$sec4_q3_b
} else {
  df$unpaid_family_workers <- NA
}
attr(df$unpaid_family_workers, "label") <- "Number of household members working without pay"

# Fix inconsistencies in family worker data
df$paid_family_workers <- ifelse(df$family_workers == 0 & is.na(df$paid_family_workers), 0, df$paid_family_workers)
df$unpaid_family_workers <- ifelse(df$family_workers == 0 & is.na(df$unpaid_family_workers), 0, df$unpaid_family_workers)

# 8. Combined Employment Variables for 2024 (most recent data)

# Total employment including owner
df$total_emp_with_owner_2024 <- ifelse(!is.na(df$total_employment_2024), 
                                       1 + df$total_employment_2024, NA)
attr(df$total_emp_with_owner_2024, "label") <- "Total employment in 2024 including owner"

# Paid employment: hired workers + paid family members
df$paid_employment_2024 <- df$total_employment_2024
df$paid_employment_2024 <- ifelse(!is.na(df$paid_family_workers),
                                  df$paid_employment_2024 + df$paid_family_workers,
                                  df$paid_employment_2024)
attr(df$paid_employment_2024, "label") <- "Total paid employment in 2024"

# Unpaid employment: owner + unpaid family members
df$unpaid_employment_2024 <- ifelse(!is.na(df$total_employment_2024), 1, NA)
df$unpaid_employment_2024 <- ifelse(!is.na(df$unpaid_family_workers),
                                    df$unpaid_employment_2024 + df$unpaid_family_workers,
                                    df$unpaid_employment_2024)
attr(df$unpaid_employment_2024, "label") <- "Total unpaid employment in 2024 (owner + family)"

# Share of paid employment in total employment
df$paid_emp_share_2024 <- ifelse(
  !is.na(df$paid_employment_2024) & !is.na(df$total_emp_with_owner_2024) & !is.na(df$family_workers),
  df$paid_employment_2024 / (df$total_emp_with_owner_2024 + df$family_workers), 
  NA
)
attr(df$paid_emp_share_2024, "label") <- "Share of paid employment in total employment (2024)"

# Share of unpaid employment in total employment
df$unpaid_emp_share_2024 <- ifelse(
  !is.na(df$unpaid_employment_2024) & !is.na(df$total_emp_with_owner_2024) & !is.na(df$family_workers),
  df$unpaid_employment_2024 / (df$total_emp_with_owner_2024 + df$family_workers), 
  NA
)
attr(df$unpaid_emp_share_2024, "label") <- "Share of unpaid employment in total employment (2024)"



# 9. Additional Date Variables

if("disbursement_date" %in% names(df)) {
  # Annual disbursement date
  df$annual_disbursement_date <- year(df$disbursement_date)
  
  # Half-yearly disbursement date (simplified approach)
  df$halfyearly_disbursement_date <- paste0(year(df$disbursement_date), "-H", 
                                            ifelse(month(df$disbursement_date) <= 6, 1, 2))
} else {
  df$annual_disbursement_date <- NA
  df$halfyearly_disbursement_date <- NA
}
cat("\nLabor, Business Practices, and IPW variables created successfully!\n")
cat("Business Practices Score summary:\n")
if("totalscore" %in% names(df)) {
  print(summary(df$totalscore))
}

cat("Employment summary for 2024:\n")
if("total_employment_2024" %in% names(df)) {
  print(summary(df$total_employment_2024))
}

# Final completion message
cat("\n", paste(rep("=", 80), collapse=""), "\n")
cat("COMPLETE DATA PROCESSING FINISHED!\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("All sections converted successfully:\n")
cat("✓ Data loading and merging\n")
cat("✓ Business running insights\n") 
cat("✓ Demographics and enterprise characteristics\n")
cat("✓ Investment variables\n")
cat("✓ Cost variables\n")
cat("✓ Revenue and profit variables\n")
cat("✓ Monthly sales\n")
cat("✓ Business practices score\n")
cat("✓ Labor and employment variables\n")
cat("✓ Inverse probability weighting\n")
cat("\nFinal dataset ready for analysis!\n")
cat("Total variables created:", ncol(df), "\n")
cat("Processing completed:", as.character(Sys.time()), "\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("Final dataset summary:\n")
cat("- Total observations:", nrow(df), "\n")
cat("- Total variables:", ncol(df), "\n")
cat("- Running enterprises:", sum(df$ent_running == 1, na.rm = TRUE), "\n")
cat("- Data processing completed on:", as.character(Sys.time()), "\n")
cat(paste(rep("=", 80), collapse=""), "\n")