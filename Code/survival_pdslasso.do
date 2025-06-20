/*==============================================================================
                    VARIABLE PREPARATION FOR PDSLASSO
==============================================================================*/

global tables "V:\Projects\TNRTP\MGP\Analysis\Tables"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


encode BlockCode, gen(BlockCode_num)
label variable BlockCode_num "Block number (numeric)"

global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span risk_count"
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
VARIABLE PREPARATION FOR PDSLASSO For Business Survial With pre  baseline variable from MIS
==============================================================================*/

global tables "V:\Projects\TNRTP\MGP\Analysis\Tables"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


encode BlockCode, gen(BlockCode_num)
label variable BlockCode_num "Block number (numeric) "

global ent_d_contr "Gender CIBILscore NumberofHouseholdmembers HighestEducation Religion Community MaritalStatus OwnRentedHouse TypeofDwelling CAPBeneficiary Typeofownership Existingbusiness Category_of_enterprise Vehicle Water Equipmentavailability Skilledlaboravailability B2C B2B Riskmitigationplan  LoanCategory"
global ent_c_contr "age_entrepreneur  ECP_Score HouseholdIncome HouseholdConsumption HouseholdSavings OtherSourceofincome ActualWorkingCapital TotalFixedCost Householdassets Jewels Cashatbank Cashathand ent_asset_index CurrentSupplyAnnual PresentDemandAnnual "
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
                            Business Survival
==============================================================================*/
eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for variable selection and store results
foreach var of varlist ent_running {
    
    pdslasso `var' treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
    
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Mean for control group (treatment_285 == 0) only
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean=r(mean)
    estadd scalar control_sd=r(sd)
    
    local sel_vars_`i' "`e(xselected)'"
    
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    local outcome_name: word `i' of "Business Survival"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist ent_running {
    local selected_covs "`sel_vars_`i''"
    
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Control group mean only
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean=r(mean)
    estadd scalar control_sd=r(sd)
    
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    
    eststo model_B_`i'
    local i=`i'+1 
}

#delimit ;
esttab model_A_* using "$scratch/business_survival.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Business Survival") 
    mtitles("Business Survival") 
    stats(control_mean control_sd N pval1, 
        fmt(%9.3f %9.3f %9.0g %9.3f) 
    labels("Control Group Mean" "Control Group SD" "Observations" "P-value"))
    posthead("Panel A: PDS-Lasso")
    addnotes("Panel A displays results from PDS-Lasso model for covariate selection.") ;
#delimit cr

#delimit ;
esttab model_B_* using "$scratch/business_survival.rtf", 
    append 
    nonumbers 
    nomtitles
    label 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    posthead("Panel B: OLS with PDS-Lasso Selected Covariates")
    stats(control_mean control_sd N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s) 
    labels("Control Group Mean" "Control Group SD" "Observations" "P-value" "PDS-Lasso Selected Controls" "Block Fixed Effects")) 
    addnotes("Panel B uses only the covariates selected by PDS-Lasso in Panel A."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Variables selected by PDS-Lasso for each outcome: `selected_vars_all'") ;
#delimit cr












/*==============================================================================
                        BUSINESS SURVIVAL ANALYSIS
                        With coefficient plot comparing methods
==============================================================================*/
global figures "V:\Projects\TNRTP\MGP\Analysis\Figures"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"

est clear

pdslasso ent_running treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
local sel_vars "`e(xselected)'"


est clear
areg ent_running treatment_285 `sel_vars', absorb(BlockCode) cluster(BlockCode)
eststo ols_pdsvars_model

pdslasso ent_running treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
eststo pds_model

#delimit ;
coefplot 
    (pds_model, keep(treatment_285) mcolor(black) ciopts(lcolor(black) recast(rcap) lwidth(thick) lpattern(dash)) 
        msymbol(diamond) msize(medium) offset(-0.2))
    (ols_pdsvars_model, keep(treatment_285) mcolor(black) ciopts(lcolor(black) recast(rcap) lwidth(medthick)) 
        msymbol(square) msize(medium) offset(0.2)),
    
    vertical
    xtitle("")
    
    xscale(range(0.4 1.6))
    xlabel(
        0.8 "PDS-Lasso" 
        1.2 "OLS with PDS Controls", 
        labsize(medium) angle(0)
    )
    
    yline(0, lpattern(dash) lcolor(gs10))
    yscale(range(0.25 0.50))   // Tighter scale around the estimates
    ylabel(0.25(0.05)0.50, format(%9.2f) labsize(small))
    ytitle("Treatment Effect on Business Survival", size(medium))    
    legend(off)
    
    mlabel format(%9.2f)
    mlabsize(medium)          
    mlabposition(3 3)     
    mlabgap(*1.5)             
    mlabcolor(black)          
    
    graphregion(color(white) margin(small))
    bgcolor(white)
    plotregion(color(white))
    name(business_survival_plot, replace);
#delimit cr

graph export "$scratch/business_survival_coefplot.png", replace




















/*==============================================================================
                BUSINESS SURVIVAL WITH GENDER HETEROGENEITY
==============================================================================*/

// Generate binary gender variable (Female = 1, Male = 0)
// Note: Since there's only one transgender respondent (0.03%), we'll focus on male/female comparison
cap drop female
gen female = (Gender == 1) if Gender != 3
label variable female "Female entrepreneur"
tab female

// Create interaction term between treatment and female
cap drop treatment_female
gen treatment_female = treatment_285 * female
label variable treatment_female "MGP × Female"

eststo clear
local i=1
local selected_vars_all ""

// Panel A: Run PDS-LASSO for main effect and store results
foreach var of varlist ent_running {
    
    // First run PDS-LASSO for overall effect
    pdslasso `var' treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
    
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Mean for control group (treatment_285 == 0) only
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean=r(mean)
    estadd scalar control_sd=r(sd)
    
    local sel_vars_`i' "`e(xselected)'"
    
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars "`labeled_selected_vars' `sel_var_label',"
    }
    
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    local outcome_name: word `i' of "Business Survival"
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_`i'a
    
    // Now run PDS-LASSO for heterogeneity analysis (using correct syntax for interactions)
    pdslasso `var' treatment_285 treatment_female ($controls female), cluster(BlockCode) partial(BlockCode_num female)
    
    // Test for overall treatment effect
    test treatment_285 = 0
    estadd scalar pval1 = r(p)
    
    // Test for differential effect by gender
    test treatment_female = 0
    estadd scalar pval_gender = r(p)
    
    // Test for joint significance of treatment and interaction (effect for females)
    test treatment_285 + treatment_female = 0
    estadd scalar pval_sumcoef = r(p)
    
    // Mean for control group (treatment_285 == 0) - overall
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean = r(mean)
    estadd scalar control_sd = r(sd)
    
    // Mean for control group - females only
    sum `var' if e(sample) & treatment_285 == 0 & female == 1
    estadd scalar control_mean_f = r(mean)
    
    // Mean for control group - males only
    sum `var' if e(sample) & treatment_285 == 0 & female == 0
    estadd scalar control_mean_m = r(mean)
    
    local sel_vars_het_`i' "`e(xselected)'"
    
    local labeled_selected_vars_het ""
    foreach sel_var in `e(xselected)' {
        local sel_var_label : var label `sel_var'
        if "`sel_var_label'"=="" local sel_var_label "`sel_var'"
        local labeled_selected_vars_het "`labeled_selected_vars_het' `sel_var_label',"
    }
    
    if strlen("`labeled_selected_vars_het'") > 0 {
        local labeled_selected_vars_het = substr("`labeled_selected_vars_het'", 1, strlen("`labeled_selected_vars_het'")-1)
    } 
    else {
        local labeled_selected_vars_het "None"
    }
    
    local selected_vars_all "`selected_vars_all' Column `i'h (`outcome_name' Heterogeneity): `labeled_selected_vars_het';"
    
    eststo model_`i'b
    
    local i=`i'+1
}

// Panel B: Run OLS with PDS-LASSO selected variables
local i=1
foreach var of varlist ent_running {
    // Overall effect
    local selected_covs "`sel_vars_`i''"
    
    areg `var' treatment_285 `selected_covs', absorb(BlockCode) cluster(BlockCode)
    
    test treatment_285==0
    estadd scalar pval1=r(p)
    
    // Control group mean only
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean=r(mean)
    estadd scalar control_sd=r(sd)
    
    if "`selected_covs'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    
    eststo model_`i'c
    
    // Heterogeneity by gender
    local selected_covs_het "`sel_vars_het_`i''"
    
    // Include female in the regression directly (not via selected covariates)
    areg `var' treatment_285 treatment_female female `selected_covs_het', absorb(BlockCode) cluster(BlockCode)
    
    // Test for overall treatment effect
    test treatment_285 = 0
    estadd scalar pval1 = r(p)
    
    // Test for differential effect by gender
    test treatment_female = 0
    estadd scalar pval_gender = r(p)
    
    // Test for joint significance of treatment and interaction (effect for females)
    test treatment_285 + treatment_female = 0
    estadd scalar pval_sumcoef = r(p)
    
    // Effect size for females (treatment + interaction)
    lincom treatment_285 + treatment_female
    estadd scalar female_effect = r(estimate)
    estadd scalar female_se = r(se)
    
    // Control group mean - overall
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar control_mean = r(mean)
    estadd scalar control_sd = r(sd)
    
    // Control group mean - females only
    sum `var' if e(sample) & treatment_285 == 0 & female == 1
    estadd scalar control_mean_f = r(mean)
    
    // Control group mean - males only
    sum `var' if e(sample) & treatment_285 == 0 & female == 0
    estadd scalar control_mean_m = r(mean)
    
    if "`selected_covs_het'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    
    eststo model_`i'd
    
    local i=`i'+1 
}



// Calculate the share of observations for each gender
count if female == 1 & e(sample)
local num_female = r(N)
count if female == 0 & e(sample)
local num_male = r(N)
local total_sample = `num_female' + `num_male'
local pct_female = string(round(`num_female' / `total_sample' * 100, 0.1))
local pct_male = string(round(`num_male' / `total_sample' * 100, 0.1))

// Table 1: Combined Table with Overall Effect and Heterogeneity
#delimit ;
esttab model_1a model_1b model_1c model_1d using "$scratch/business_survival_combined.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285 treatment_female female) 
    mtitles("Overall" "By Gender" "Overall" "By Gender")
    title("Table: Impact of MGP on Business Survival - Overall and By Gender") 
    posthead("Panel A: PDS-Lasso" "~" "Panel B: OLS with PDS-Lasso Selected Covariates" "~")
    varlabels(
        treatment_285 "MGP (Overall/Males)"
        treatment_female "MGP × Female"
        female "Female"
    )
    stats(
        female_effect female_se control_mean control_mean_m control_mean_f N pval1 pval_gender pval_sumcoef Selected_cov Block_FE, 
        fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.0g %9.3f %9.3f %9.3f %s %s) 
        labels(
            "MGP Effect for Females" 
            "SE" 
            "Control Mean (Overall)" 
            "Control Mean (Males)" 
            "Control Mean (Females)" 
            "Observations" 
            "P-value (MGP)" 
            "P-value (MGP × Female)" 
            "P-value (MGP Effect for Females)"
            "PDS-Lasso Selected Controls" 
            "Block Fixed Effects"
        )
    ) 
    addnotes(
        "The sample contains `num_female' female entrepreneurs (`pct_female'%) and `num_male' male entrepreneurs (`pct_male'%)."
        "Panel A displays results from PDS-Lasso models for covariate selection."
        "Panel B uses the covariates selected by PDS-Lasso in Panel A."
        "All specifications include Block fixed effects with standard errors clustered at the Block level."
        "MGP Effect for Females represents the linear combination of MGP + (MGP × Female)."
        "Variables selected by PDS-Lasso: `selected_vars_all'"
    );
#delimit cr


















export delimited enterprise_id treatment_285 ent_running Gender BlockCode ///
    _weight age_entrepreneur CIBILscore NumberofHouseholdmembers ///
    HighestEducation Religion Community MaritalStatus OwnRentedHouse ///
    TypeofDwelling CAPBeneficiary Typeofownership Existingbusiness ///
    Category_of_enterprise Vehicle Water Equipmentavailability ///
    Skilledlaboravailability ECP_Score HouseholdIncome ///
    using "$scratch\mgp_causal_forest_input.csv", replace
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*==============================================================================
                        COMPLETE BUSINESS SURVIVAL ANALYSIS WITH GENDER HETEROGENEITY
==============================================================================*/

global figures "V:\Projects\TNRTP\MGP\Analysis\Figures"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"

// Clear previous estimates
est clear

// Create female dummy and interaction term
gen female = (Gender == 1) if !missing(Gender)
label variable female "Female (=1)"
gen treatment_female = treatment_285 * female
label variable treatment_female "MGP × Female"

/*------------------------------------------------------------------------------
                        Method 1: Including Female Interaction in PDS-Lasso
------------------------------------------------------------------------------*/

// PDS-Lasso with gender interaction
pdslasso ent_running treatment_285 treatment_female ($controls female), ///
    cluster(BlockCode) partial(BlockCode_num female)
local sel_vars "`e(xselected)'"
eststo pds_gender_interaction

// OLS with PDS-selected variables including gender terms
areg ent_running treatment_285 treatment_female female `sel_vars', ///
    absorb(BlockCode) cluster(BlockCode)
eststo ols_gender_interaction

/*------------------------------------------------------------------------------
                        Method 2: Separate Analysis by Gender Subsamples
------------------------------------------------------------------------------*/

// Female subsample
preserve
keep if female == 1
pdslasso ent_running treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
local sel_vars_female "`e(xselected)'"
areg ent_running treatment_285 `sel_vars_female', absorb(BlockCode) cluster(BlockCode)
eststo ols_female_only
restore

// Male subsample  
preserve
keep if female == 0 & Gender == 2  // Exclude transgender for clean comparison
pdslasso ent_running treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
local sel_vars_male "`e(xselected)'"
areg ent_running treatment_285 `sel_vars_male', absorb(BlockCode) cluster(BlockCode)
eststo ols_male_only
restore

/*------------------------------------------------------------------------------
                        Coefficient Plot: Gender Heterogeneity
------------------------------------------------------------------------------*/

#delimit ;
coefplot 
    (ols_gender_interaction, keep(treatment_285) mcolor(blue) 
        ciopts(lcolor(blue) recast(rcap) lwidth(medthick)) 
        msymbol(circle) msize(medium) offset(-0.3)
        mlabel format(%9.3f) mlabposition(12))
    (ols_gender_interaction, keep(treatment_female) mcolor(red) 
        ciopts(lcolor(red) recast(rcap) lwidth(medthick)) 
        msymbol(triangle) msize(medium) offset(-0.1)
        mlabel format(%9.3f) mlabposition(12))
    (ols_female_only, keep(treatment_285) mcolor(red) 
        ciopts(lcolor(red) recast(rcap) lwidth(medthick) lpattern(dash)) 
        msymbol(square) msize(medium) offset(0.1)
        mlabel format(%9.3f) mlabposition(12))
    (ols_male_only, keep(treatment_285) mcolor(blue) 
        ciopts(lcolor(blue) recast(rcap) lwidth(medthick) lpattern(dash)) 
        msymbol(diamond) msize(medium) offset(0.3)
        mlabel format(%9.3f) mlabposition(12)),
    
    vertical
    xtitle("")
    
    xscale(range(0.4 2.6))
    xlabel(
        0.7 "Main Effect" 
        0.9 "Female Interaction"
        1.1 "Female Subsample"
        1.3 "Male Subsample", 
        labsize(medium) angle(45)
    )
    
    yline(0, lpattern(dash) lcolor(gs10))
    ylabel(, format(%9.3f) labsize(small))
    ytitle("Treatment Effect on Business Survival", size(medium))
    title("MGP Treatment Effects by Gender", size(medsmall) color(black))
    subtitle("Comparison of estimation approaches", size(small) color(gs6))
    
    legend(order(2 "Main Treatment Effect" 4 "Female × Treatment" 6 "Female Subsample" 8 "Male Subsample")
           position(6) cols(2) size(small))
    
    mlabsize(vsmall)          
    mlabgap(*1.2)             
    mlabcolor(black)          
    
    graphregion(color(white) margin(medium))
    bgcolor(white)
    plotregion(color(white))
    name(gender_heterogeneity_plot, replace);
#delimit cr

/*------------------------------------------------------------------------------
                        Coefficient Plot: Gender Heterogeneity (CORRECTED)
------------------------------------------------------------------------------*/

#delimit ;
coefplot 
    (ols_gender_interaction, keep(treatment_285) mcolor(blue) 
        ciopts(lcolor(blue) recast(rcap) lwidth(medthick)) 
        msymbol(circle) msize(medium) offset(-0.3))
    (ols_gender_interaction, keep(treatment_female) mcolor(red) 
        ciopts(lcolor(red) recast(rcap) lwidth(medthick)) 
        msymbol(triangle) msize(medium) offset(-0.1))
    (ols_female_only, keep(treatment_285) mcolor(red) 
        ciopts(lcolor(red) recast(rcap) lwidth(medthick) lpattern(dash)) 
        msymbol(square) msize(medium) offset(0.1))
    (ols_male_only, keep(treatment_285) mcolor(blue) 
        ciopts(lcolor(blue) recast(rcap) lwidth(medthick) lpattern(dash)) 
        msymbol(diamond) msize(medium) offset(0.3)),
    
    vertical
    xtitle("")
    
    xscale(range(0.4 2.6))
    xlabel(
        0.7 "Main Effect" 
        0.9 "Female Interaction"
        1.1 "Female Subsample"
        1.3 "Male Subsample", 
        labsize(medium) angle(45)
    )
    
    yline(0, lpattern(dash) lcolor(gs10))
    ylabel(, format(%9.3f) labsize(small))
    ytitle("Treatment Effect on Business Survival", size(medium))
    title("MGP Treatment Effects by Gender", size(medsmall) color(black))
    subtitle("Comparison of estimation approaches", size(small) color(gs6))
    
    legend(order(2 "Main Treatment Effect" 4 "Female × Treatment" 6 "Female Subsample" 8 "Male Subsample")
           position(6) cols(2) size(small))
    
    mlabel
    mlabformat(%9.3f)
    mlabsize(vsmall)          
    mlabgap(*1.2)             
    mlabcolor(black)          
    mlabposition(12)
    
    graphregion(color(white) margin(medium))
    bgcolor(white)
    plotregion(color(white))
    name(gender_heterogeneity_plot, replace);
#delimit cr

graph export "$figures/business_survival_gender_heterogeneity.png", replace width(800) height(600)