
/*==============================================================================
                    VARIABLE PREPARATION FOR PDSLASSO
==============================================================================*/

global tables "V:\Projects\TNRTP\MGP\Analysis\Tables"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


encode BlockCode, gen(BlockCode_num)
label variable BlockCode_num "Block number (numeric)"

global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span brti_count"
global all_controls "$ent_c_contr $ent_d_contr BlockCode_num"



/*==============================================================================
           FINAL CONTROL VARIABLE SET FOR PDS LASSO, replacing missing values
==============================================================================*/

global miss_ent_d_contr ""
global dmiss_ent_d_contr ""

foreach var of varlist $ent_d_contr {
    cap drop dmiss_`var'
    gen dmiss_`var' = missing(`var')
    
    cap drop miss_`var'
    gen miss_`var' = `var'
    replace miss_`var' = 0 if missing(`var')
    
    global miss_ent_d_contr "$miss_ent_d_contr miss_`var'"
    global dmiss_ent_d_contr "$dmiss_ent_d_contr dmiss_`var'"
}

global miss_ent_c_contr ""
global dmiss_ent_c_contr ""

foreach var of varlist $ent_c_contr {
    cap drop dmiss_`var'
    gen dmiss_`var' = missing(`var')
    
    cap drop miss_`var'
    gen miss_`var' = `var'
    replace miss_`var' = 0 if missing(`var')
    
    global miss_ent_c_contr "$miss_ent_c_contr miss_`var'"
    global dmiss_ent_c_contr "$dmiss_ent_c_contr dmiss_`var'"
}

global controls "$miss_ent_d_contr $dmiss_ent_d_contr $miss_ent_c_contr $dmiss_ent_c_contr BlockCode_num"




/*==============================================================================
    COMPREHENSIVE MGP IMPACT ANALYSIS WITH PDS-LASSO
    
    1. Variable preparation and covariates
    2. Enterprise financing analysis
    3. Enterprise performance analysis
    4. Investment behavior analysis
    5. Business practices analysis
    6. Loan repayment behavior analysis
==============================================================================*/

/*==============================================================================
                    VARIABLE PREPARATION 
==============================================================================*/
// Create dummy variables for enterprise characteristics
global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables"
global cov "e_age age_entrepreneur female_owner marriage_age shg_member i.sec2_q2 education_yrs i.sec3_q5" 


encode BlockCode, gen(BlockCode_num)
label variable BlockCode_num "Block number (numeric)"

// Categorical variables entered as dummies
global ent_d_contr "female_owner ent_nature_* ent_location_* "

// Continuous variables
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span risk_count "



// Combined controls
global all_controls "$ent_c_contr $ent_d_contr BlockCode_num"




/*==============================================================================
                    PDS-LASSO ANALYSIS OF LOAN IMPACT
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist any_loan count_loan formal_loan_source log_w10_total_loan_remaining avg_int_rate {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($all_controls), cluster(BlockCode) partial(BlockCode_num)
    
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Any Loan" "Number of Loans" "Formal Loan Source" "Log Outstanding Loan" "Interest Rate"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist any_loan count_loan formal_loan_source log_w10_total_loan_remaining avg_int_rate {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$tables/loan_impact_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP Loans on Enterprise Financing") 
    mtitles("Any Loan" "Number of Loans" "Formal Loan Source" "Log Outstanding Loan" "Interest Rate (%)") 
    stats(mean sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$tables/loan_impact_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr

















/*==============================================================================
                PDS-LASSO ANALYSIS OF INVESTMENT BEHAVIOR
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist ever_invested w10_invest_2024 count_invest_2024 wc_invest_2024 wc_share_2024 {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($all_controls), cluster(BlockCode) partial(BlockCode_num)
    
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Any Investment" "Investment Amount" "Investment Types" "Working Capital" "WC Share"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist ever_invested w10_invest_2024 count_invest_2024 wc_invest_2024 wc_share_2024 {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$tables/investment_behavior_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Enterprise Investment Behavior") 
    mtitles("Any Investment" "Investment Amount" "Investment Types" "Working Capital" "WC Share") 
    stats(mean sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$tables/investment_behavior_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "All investment variables measured for 2024."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr



















/*==============================================================================
        PDS-LASSO ANALYSIS OF LOAN REPAYMENT BEHAVIOR
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist has_any_delay has_frequent_delays has_long_delay repayment_difficult total_payment_delays max_delay_length repay_behavior_score {
    
    // Run PDS-LASSO with clustering by BlockCode - sample restricted to those with loans
    pdslasso `var' treatment_285 ($all_controls) if any_loan==1, cluster(BlockCode) partial(BlockCode_num)
    
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Any Delay" "Frequent Delays" "Long Delay" "Repayment Difficult" "Total Delays" "Max Delay Length" "Behavior Score"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist has_any_delay has_frequent_delays has_long_delay repayment_difficult total_payment_delays max_delay_length repay_behavior_score {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates - sample restricted to those with loans
    areg `var' treatment_285 `selected_covs' if any_loan==1, absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$tables/repayment_behavior_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Loan Repayment Behavior") 
    mtitles("Any Delay" "Frequent Delays" "Long Delay" "Repayment Difficult" "Total Delays" "Max Delay Length" "Behavior Score") 
    stats(mean sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection."
             "Sample restricted to enterprises with at least one loan.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$tables/repayment_behavior_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "Sample restricted to enterprises with at least one loan."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Variable definitions: Any Delay = any payment delay across loans; Frequent Delays = 3+ delays on any loan;"
             "Long Delay = any delay >30 days; Repayment Difficult = self-reported difficulty with repayment;"
             "Total Delays = count of payment delays; Max Delay Length = maximum length of delay in days;"
             "Behavior Score = average of four binary indicators (higher score indicates more repayment problems)."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr













/*==============================================================================
        PDS-LASSO ANALYSIS OF BUSINESS PRACTICES
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
 
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar mean=r(mean)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar mean=r(mean)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$Scratch/business_practices_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Business Practices") 
    mtitles("Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score") 
    stats(mean N pval1, 
        fmt(%9.3f %9.0g %9.3f) 
    labels("Mean of Comparison Group" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection."
             "All scores represent the proportion of good business practices adopted in each category.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$Scratch/business_practices_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Comparison Group" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Business practice scores developed using 26 binary indicators across four domains: marketing (7 practices),"
             "buying and stock control (3 practices), record-keeping (8 practices), and financial planning (8 practices)."
             "Each domain score represents the proportion of practices adopted, and the total score is the average of all domains."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr







/*==============================================================================
        PDS-LASSO ANALYSIS OF BUSINESS PRACTICES
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
 
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar mean=r(mean)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes with proper descriptions
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        // Map miss_ variables to their original descriptions
        local desc_var = ""
        if "`sel_var'" == "miss_ent_location_1" local desc_var "Located in main marketplace"
        else if "`sel_var'" == "miss_ent_location_2" local desc_var "Located in secondary marketplace"  
        else if "`sel_var'" == "miss_ent_location_3" local desc_var "Located on street with other businesses"
        else if "`sel_var'" == "miss_ent_location_4" local desc_var "Located in residential area"
        else if "`sel_var'" == "miss_e_age" local desc_var "Age of the enterprise (years)"
        else if "`sel_var'" == "miss_age_entrepreneur" local desc_var "Age of the entrepreneur"
        else if "`sel_var'" == "miss_marriage_age" local desc_var "Marriage age if ever married"
        else if "`sel_var'" == "miss_education_yrs" local desc_var "Years of education of enterprise owner"
        else if "`sel_var'" == "miss_std_digit_span" local desc_var "Standardized digit span score"
        else if "`sel_var'" == "miss_brti_count" local desc_var "Business Risk Tolerance Index"
        else if "`sel_var'" == "miss_female_owner" local desc_var "Female entrepreneur"
        else if "`sel_var'" == "miss_ent_nature_1" local desc_var "Manufacturing enterprise"
        else if "`sel_var'" == "miss_ent_nature_2" local desc_var "Trade/Retail/Sales enterprise"
        else if "`sel_var'" == "miss_ent_nature_3" local desc_var "Service enterprise"
        else if "`sel_var'" == "dmiss_std_digit_span" local desc_var "Missing indicator: Standardized digit span score"
        else if "`sel_var'" == "BlockCode_num" local desc_var "Block number"
        else {
            local sel_var_label : var label `sel_var'
            if "`sel_var_label'"=="" local desc_var "`sel_var'"
            else local desc_var "`sel_var_label'"
        }
        
        local labeled_selected_vars "`labeled_selected_vars' `desc_var',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar mean=r(mean)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$Scratch/business_practices_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Business Practices") 
    mtitles("Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score") 
    stats(mean N pval1, 
        fmt(%9.3f %9.0g %9.3f) 
    labels("Mean of Comparison Group" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection."
             "All scores represent the proportion of good business practices adopted in each category.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$Scratch/business_practices_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Comparison Group" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Business practice scores developed using 26 binary indicators across four domains: marketing (7 practices),"
             "buying and stock control (3 practices), record-keeping (8 practices), and financial planning (8 practices)."
             "Each domain score represents the proportion of practices adopted, and the total score is the average of all domains."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr








/*==============================================================================
        PDS-LASSO ANALYSIS OF LABOR OUTCOMES
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist employed_any_year total_emp_with_owner_2024 paid_employment_2024 unpaid_employment_2024 paid_emp_share_2024 unpaid_emp_share_2024 {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($all_controls), cluster(BlockCode) partial(BlockCode_num)
    
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Any Employment" "Total Employment" "Paid Employment" "Unpaid Employment" "Paid Employment Share" "Unpaid Employment Share"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist employed_any_year total_emp_with_owner_2024 paid_employment_2024 unpaid_employment_2024 paid_emp_share_2024 unpaid_emp_share_2024 {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$tables/labour_outcome_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Labor Outcomes") 
    mtitles("Any Employment" "Total Employment" "Paid Employment" "Unpaid Employment" "Paid Employment Share" "Unpaid Employment Share") 
    stats(mean sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$tables/labour_outcome_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Labor outcomes include: any worker employment (2022-2024), total employment in 2024 (including owner),"
             "paid employment (2024), unpaid employment (2024, including owner and family workers),"
             "and the shares of paid and unpaid workers in total employment (2024)."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr


















/*==============================================================================
        PDS-LASSO ANALYSIS OF BUSINESS OUTCOMES
==============================================================================*/

// Initialize variable to store selected variables for each outcome
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist log_monthly_profit log_monthly_sale innovation_score {
    
    // Run PDS-LASSO with clustering by BlockCode
    pdslasso `var' treatment_285 ($all_controls), cluster(BlockCode) partial(BlockCode_num)
    
    // Store PDS-LASSO estimation results
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    // Store selected variables for each outcome - use variable counter to avoid long names
    local sel_vars_`i' "`e(xselected)'"
    
    // Format selected variables for notes
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    // Remove trailing comma if present
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Add to accumulated note for table footnote
    local outcome_name: word `i' of "Log Monthly Profit" "Log Monthly Sales" "Innovation Score"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist log_monthly_profit log_monthly_sale innovation_score {
    
    // Use the selected variables from PDS-LASSO (using counter to avoid long names)
    local selected_covs "`sel_vars_`i''"
    
    // Run areg with only selected covariates
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    // Store results
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo model_B_`i'
    local i=`i'+1 
}

// Output results table - Panel A: PDS-LASSO
#delimit ;
esttab model_A_* using "$tables/business_outcomes_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Business Outcomes") 
    mtitles("Log Monthly Profit" "Log Monthly Sales" "Innovation Score") 
    stats(mean sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection.") ;
#delimit cr

// Output results table - Panel B: OLS with LASSO-selected variables
#delimit ;
esttab model_B_* using "$tables/business_outcomes_pdslasso.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(mean sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr




