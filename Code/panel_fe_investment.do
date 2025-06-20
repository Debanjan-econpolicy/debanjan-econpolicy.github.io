global derived_data "V:\Projects\TNRTP\MGP\Analysis\Data\derived"
global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


/*==============================================================================
    PANEL DATA PREPARATION AND BASE XTREG ANALYSIS
==============================================================================*/


gen treated_2022 = (quarterly_disbursement_date == tq(2022q4)) if !missing(quarterly_disbursement_date)
replace treated_2022 = 0 if missing(quarterly_disbursement_date)

gen treated_2023 = 0
replace treated_2023 = 1 if inlist(quarterly_disbursement_date, tq(2022q4), tq(2023q1), tq(2023q2), tq(2023q3), tq(2023q4))

gen treated_2024 = 0  
replace treated_2024 = 1 if !missing(quarterly_disbursement_date)

label var treated_2022 "Treated in 2022"
label var treated_2023 "Treated in 2023" 
label var treated_2024 "Treated in 2024"



global cov HouseholdIncome MaritalStatus HouseholdSavings ent_asset_index Cashatbank Cashathand CurrentSupplyAnnual PresentDemandAnnual age_entrepreneur std_digit_span brti_count ECP_Score CIBILscore


/*==============================================================================
					PANEL DATA SETUP 
==============================================================================*/

preserve

keep enterprise_id District DistrictCode Block BlockCode Panchayat PanchayatCode ///
     treatment_285 quarterly_disbursement_date treated_* ///
     invested_* total_invest_* w10_total_invest_* log_w10_total_invest_* count_invest_* ///
     wc_invest_* ac_invest_* dr_invest_* ///
     wc_amount_* asset_amount_* debt_amount_* ///
     wc_share_* asset_share_* debt_share_* ///
     ent_running _weight  female_owner sec2_q2 				
	 
	 
keep if ent_running == 1

encode enterprise_id, gen(enterprise_id_num)
la var enterprise_id_num "Enterprise ID (numeric for panel)"

reshape long invested_ total_invest_ w10_total_invest_ log_w10_total_invest_ count_invest_ ///
            wc_invest_ ac_invest_ dr_invest_ ///
            wc_amount_ asset_amount_ debt_amount_ ///
            wc_share_ asset_share_ debt_share_ treated_, ///
            i(enterprise_id) j(year)
			



xtset enterprise_id_num year
xtdes


rename invested_ invested
rename total_invest_ totalinvest
rename w10_total_invest_ w10_totalinvest
rename log_w10_total_invest_ log_w10_totalinvest
rename count_invest_ count_invest
rename wc_invest_ wc_invest
rename ac_invest_ ac_invest
rename dr_invest_ dr_invest
rename wc_amount_ wc_amount
rename asset_amount_ asset_amount
rename debt_amount_ debt_amount
rename wc_share_ wc_share
rename asset_share_ asset_share
rename debt_share_ debt_share
rename treated_ treated


label var invested "Made any investment in year t (0/1)"
label var totalinvest "Total investment amount in year t (Rs.)"
label var w10_totalinvest "Winsorized total investment amount in year t (Rs.)"
label var log_w10_totalinvest "Log of winsorized total investment amount in year t"
label var count_invest "Number of investment types in year t"

label var wc_invest "Invested in working capital in year t (0/1)"
label var ac_invest "Invested in asset creation in year t (0/1)"
label var dr_invest "Invested in debt reduction in year t (0/1)"

label var wc_amount "Amount invested in working capital in year t (Rs.)"
label var asset_amount "Amount invested in asset creation in year t (Rs.)"
label var debt_amount "Amount invested in debt reduction in year t (Rs.)"

label var wc_share "Share of investment in working capital in year t"
label var asset_share "Share of investment in asset creation in year t"
label var debt_share "Share of investment in debt reduction in year t"

label var treated "Received MGP treatment by year t (0/1)"


// Generate year-specific treatment effects
gen treat_2022 = treated  * (year == 2022)
gen treat_2023 = treated  * (year == 2023)  
gen treat_2024 = treated  * (year == 2024)

label var treat_2022 "Treatment effect in 2022 (treated*2022)"
label var treat_2023 "Treatment effect in 2023 (treated*2023)"
label var treat_2024 "Treatment effect in 2024 (treated*2024)"

xtreg invested treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)




foreach var in wc_amount asset_amount debt_amount {
	gen w5_`var' = `var'
	sum `var', d
	replace w5_`var' = r(p5) if `var' <= r(p5) & `var' != .
	replace w5_`var' = r(p95) if `var' >= r(p95) & `var' != .
	local label: variable label `var'
	la var w5_`var' "w10 `label'"

}



foreach var in wc_amount asset_amount debt_amount {
    gen log_`var' = log(`var')
	local label: variable label `var'
	la var log_`var' "Log of `label'"	
}


foreach var in invested log_w10_totalinvest count_invest wc_invest ac_invest log_wc_amount log_asset_amount wc_share asset_share {
	xtreg `var' treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)

}





eststo clear
local i=1
foreach var in invested log_w10_totalinvest count_invest wc_invest ac_invest log_wc_amount log_asset_amount wc_share asset_share {
    xtreg `var' treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)
    
    * Test joint significance of treatment effects
    test treat_2022 treat_2023 treat_2024
    estadd scalar pval_joint=r(p)
    
    estadd local enterprise_fe "YES"
    estadd local year_fe "YES"
    estadd local clustering "Block"
    estadd local covariates "NO"
    
    sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0
    estadd scalar mean_control=r(mean)
    
    eststo investment_table_`i'
    local i=`i'+1
}

#delimit ;
esttab investment_table_1 investment_table_2 investment_table_3 investment_table_4 investment_table_5 investment_table_6 investment_table_7 investment_table_8 investment_table_9 using "$Scratch/investment_analysis.rtf", replace depvar legend label nonumbers nogaps nonotes ///
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps ///
    keep(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    order(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    stats(N mean_control pval_joint enterprise_fe year_fe covariates clustering, 
          fmt(%9.0g %9.3f %9.3f %s %s %s %s) 
          labels("Observations" "Comparison Group Mean" "Joint Test P-value" "Enterprise FE" "Year FE" "Covariates" "SE Clustering")) ///
    mtitles("Whether Invested" "Log Total Invest" "Count Invest" "WC Invest" "AC Invest" "Log WC Amount" "Log Asset Amount" "WC Share" "Asset Share") ///
    title("Table X: Impact of MGP on Investment") ///
    addnotes("Standard errors clustered at the block level" 
			"WC Share implies a ratio of Working Capital and Total Investment"
			"Asset Share implies a ratio of Fixed Capital and Total Investment") ;
#delimit cr






















* =================================================================
* BASE MODEL (TO BE REPORTED SEPARATELY)
* =================================================================
* This will be part of your main investment analysis table

* =================================================================
* HETEROGENEITY ANALYSIS
* =================================================================

* Clear previous estimates
eststo clear

* =================================================================
* 1. HETEROGENEITY BY FEMALE ENTREPRENEUR
* =================================================================

* Model for Male entrepreneurs (female_owner = 0)
xtreg invested treat_2022 treat_2023 treat_2024 i.year if female_owner==0, fe vce(cluster BlockCode)

* Test joint significance
test treat_2022 treat_2023 treat_2024
estadd scalar pval_joint=r(p)

* Add model specifications
estadd local enterprise_fe "YES"
estadd local year_fe "YES"
estadd local clustering "Block"
estadd local covariates "NO"
estadd local sample "Male Entrepreneurs"

* Control group mean for male entrepreneurs
sum invested if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==0
estadd scalar mean_control=r(mean)

* Store results
eststo male_entrepreneurs

* Model for Female entrepreneurs (female_owner = 1)
xtreg invested treat_2022 treat_2023 treat_2024 i.year if female_owner==1, fe vce(cluster BlockCode)

* Test joint significance
test treat_2022 treat_2023 treat_2024
estadd scalar pval_joint=r(p)

* Add model specifications
estadd local enterprise_fe "YES"
estadd local year_fe "YES"
estadd local clustering "Block"
estadd local covariates "NO"
estadd local sample "Female Entrepreneurs"

* Control group mean for female entrepreneurs
sum invested if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==1
estadd scalar mean_control=r(mean)

* Store results
eststo female_entrepreneurs

* =================================================================
* TEST EQUALITY OF TREATMENT EFFECTS BETWEEN MALE AND FEMALE
* =================================================================

* Run interaction model to test differences
xtreg invested treat_2022 treat_2023 treat_2024 ///
    c.treat_2022#i.female_owner c.treat_2023#i.female_owner c.treat_2024#i.female_owner ///
    i.year, fe vce(cluster BlockCode)

* Test if treatment effects are equal between male and female entrepreneurs
* H0: treat_2022 effect same for male and female
test 1.female_owner#c.treat_2022
local pval_2022_diff = r(p)

* H0: treat_2023 effect same for male and female  
test 1.female_owner#c.treat_2023
local pval_2023_diff = r(p)

* H0: treat_2024 effect same for male and female
test 1.female_owner#c.treat_2024
local pval_2024_diff = r(p)

* Joint test: all treatment effects equal between male and female
test (1.female_owner#c.treat_2022) (1.female_owner#c.treat_2023) (1.female_owner#c.treat_2024)
local pval_joint_diff = r(p)

* Add difference test results to stored estimates
estimates restore male_entrepreneurs
estadd scalar pval_2022_diff = `pval_2022_diff'
estadd scalar pval_2023_diff = `pval_2023_diff'
estadd scalar pval_2024_diff = `pval_2024_diff'
estadd scalar pval_joint_diff = `pval_joint_diff'
eststo male_entrepreneurs_final

estimates restore female_entrepreneurs
estadd scalar pval_2022_diff = `pval_2022_diff'
estadd scalar pval_2023_diff = `pval_2023_diff'
estadd scalar pval_2024_diff = `pval_2024_diff'
estadd scalar pval_joint_diff = `pval_joint_diff'
eststo female_entrepreneurs_final

* =================================================================
* 2. HETEROGENEITY BY ENTERPRISE TYPE
* =================================================================

* Model for Manufacturing enterprises (sec2_q2 = 1)
xtreg invested treat_2022 treat_2023 treat_2024 i.year if sec2_q2==1, fe vce(cluster BlockCode)

* Test joint significance
test treat_2022 treat_2023 treat_2024
estadd scalar pval_joint=r(p)

* Add model specifications
estadd local enterprise_fe "YES"
estadd local year_fe "YES"
estadd local clustering "Block"
estadd local covariates "NO"
estadd local sample "Manufacturing"

* Control group mean for manufacturing
sum invested if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==1
estadd scalar mean_control=r(mean)

* Store results
eststo manufacturing

* Model for Trade/Retail enterprises (sec2_q2 = 2)
xtreg invested treat_2022 treat_2023 treat_2024 i.year if sec2_q2==2, fe vce(cluster BlockCode)

* Test joint significance
test treat_2022 treat_2023 treat_2024
estadd scalar pval_joint=r(p)

* Add model specifications
estadd local enterprise_fe "YES"
estadd local year_fe "YES"
estadd local clustering "Block"
estadd local covariates "NO"
estadd local sample "Trade/Retail"

* Control group mean for trade/retail
sum invested if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==2
estadd scalar mean_control=r(mean)

* Store results
eststo trade_retail

* Model for Services enterprises (sec2_q2 = 3)
xtreg invested treat_2022 treat_2023 treat_2024 i.year if sec2_q2==3, fe vce(cluster BlockCode)

* Test joint significance
test treat_2022 treat_2023 treat_2024
estadd scalar pval_joint=r(p)

* Add model specifications
estadd local enterprise_fe "YES"
estadd local year_fe "YES"
estadd local clustering "Block"
estadd local covariates "NO"
estadd local sample "Services"

* Control group mean for services
sum invested if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==3
estadd scalar mean_control=r(mean)

* Store results
eststo services

* =================================================================
* TEST EQUALITY OF TREATMENT EFFECTS ACROSS ENTERPRISE TYPES
* =================================================================

* Run interaction model to test differences across enterprise types
xtreg invested treat_2022 treat_2023 treat_2024 ///
    c.treat_2022#i.sec2_q2 c.treat_2023#i.sec2_q2 c.treat_2024#i.sec2_q2 ///
    i.year, fe vce(cluster BlockCode)

* Test if treatment effects differ across enterprise types
* Manufacturing vs Trade/Retail
test (2.sec2_q2#c.treat_2022) (2.sec2_q2#c.treat_2023) (2.sec2_q2#c.treat_2024)
local pval_manuf_vs_trade = r(p)

* Manufacturing vs Services  
test (3.sec2_q2#c.treat_2022) (3.sec2_q2#c.treat_2023) (3.sec2_q2#c.treat_2024)
local pval_manuf_vs_services = r(p)

* Joint test: all treatment effects equal across all enterprise types
test (2.sec2_q2#c.treat_2022) (2.sec2_q2#c.treat_2023) (2.sec2_q2#c.treat_2024) ///
     (3.sec2_q2#c.treat_2022) (3.sec2_q2#c.treat_2023) (3.sec2_q2#c.treat_2024)
local pval_enterprise_diff = r(p)

* Add test results to stored estimates
estimates restore manufacturing
estadd scalar pval_enterprise_diff = `pval_enterprise_diff'
estadd scalar pval_manuf_vs_trade = `pval_manuf_vs_trade'
estadd scalar pval_manuf_vs_services = `pval_manuf_vs_services'
eststo manufacturing_final

estimates restore trade_retail
estadd scalar pval_enterprise_diff = `pval_enterprise_diff'
estadd scalar pval_manuf_vs_trade = `pval_manuf_vs_trade'
eststo trade_retail_final

estimates restore services
estadd scalar pval_enterprise_diff = `pval_enterprise_diff'
estadd scalar pval_manuf_vs_services = `pval_manuf_vs_services'
eststo services_final

* =================================================================
* 3. GENERATE HETEROGENEITY TABLES
* =================================================================

* Table 1: Heterogeneity by Gender
#delimit ;
esttab male_entrepreneurs_final female_entrepreneurs_final using "$Scratch/heterogeneity_gender.rtf", replace depvar legend label nonumbers nogaps nonotes ///
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps ///
    keep(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    order(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    stats(N mean_control pval_joint pval_joint_diff enterprise_fe year_fe covariates clustering sample, 
          fmt(%9.0g %9.3f %9.3f %9.3f %s %s %s %s %s) 
          labels("Observations" "Comparison Group Mean" "Joint Test P-value" "Test: Male=Female P-value" "Enterprise FE" "Year FE" "Covariates" "SE Clustering" "Sample")) ///
    mtitles("Male Entrepreneurs" "Female Entrepreneurs") ///
    title("Table Y: Heterogeneity Analysis by Gender - Impact of MGP on Investment") ///
    addnotes("Standard errors clustered at the block level" 
             "Comparison group mean shows baseline investment rate for untreated enterprises"
             "Test: Male=Female P-value tests whether treatment effects differ significantly between genders") ;
#delimit cr

* Table 2: Heterogeneity by Enterprise Type
#delimit ;
esttab manufacturing_final trade_retail_final services_final using "$Scratch/heterogeneity_enterprise_type.rtf", replace depvar legend label nonumbers nogaps nonotes ///
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps ///
    keep(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    order(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    stats(N mean_control pval_joint pval_enterprise_diff enterprise_fe year_fe covariates clustering sample, 
          fmt(%9.0g %9.3f %9.3f %9.3f %s %s %s %s %s) 
          labels("Observations" "Comparison Group Mean" "Joint Test P-value" "Test: Equal Effects P-value" "Enterprise FE" "Year FE" "Covariates" "SE Clustering" "Sample")) ///
    mtitles("Manufacturing" "Trade/Retail" "Services") ///
    title("Table Z: Heterogeneity Analysis by Enterprise Type - Impact of MGP on Investment") ///
    addnotes("Standard errors clustered at the block level" 
             "Manufacturing: Making food products, textiles, furniture, handicrafts, etc."
             "Trade/Retail: Shop keeping, wholesale trading, selling goods, etc."
             "Services: Repairs, transportation, beauty parlours, tailoring, etc."
             "Test: Equal Effects P-value tests whether treatment effects differ significantly across enterprise types") ;
#delimit cr





























* =================================================================
* HETEROGENEITY ANALYSIS - OUTCOMES IN ROWS, TREATMENTS IN COLUMNS
* =================================================================

* Clear all estimates
eststo clear

* Define outcome variables and labels
local outcomes "invested log_w10_totalinvest count_invest wc_invest ac_invest log_wc_amount log_asset_amount wc_share asset_share"
local outcome_labels `""Whether Invested" "Log Total Investment" "Count of Investments" "Working Capital Investment" "Asset Capital Investment" "Log WC Amount" "Log Asset Amount" "WC Share" "Asset Share""'

* =================================================================
* 1. GENDER HETEROGENEITY TABLE (OUTCOMES IN ROWS)
* =================================================================

* Loop through each outcome and store estimates for gender analysis
local i = 1
foreach var in `outcomes' {
    local label : word `i' of `outcome_labels'
    
    * Check sufficient observations
    quietly count if !missing(`var') & female_owner==0 & !missing(treat_2022, treat_2023, treat_2024)
    local n_male = r(N)
    quietly count if !missing(`var') & female_owner==1 & !missing(treat_2022, treat_2023, treat_2024)
    local n_female = r(N)
    
    if `n_male' > 50 & `n_female' > 50 {
        * Male entrepreneurs
        eststo male_`i': quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if female_owner==0, fe vce(cluster BlockCode)
        estadd local outcome_var "`label'"
        estadd local sample_group "Male"
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==0
        estadd scalar control_mean=r(mean)
        
        * Female entrepreneurs
        eststo female_`i': quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if female_owner==1, fe vce(cluster BlockCode)
        estadd local outcome_var "`label'"
        estadd local sample_group "Female"
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==1
        estadd scalar control_mean=r(mean)
        
        * Test for differences between male and female
        quietly xtreg `var' treat_2022 treat_2023 treat_2024 ///
            c.treat_2022#i.female_owner c.treat_2023#i.female_owner c.treat_2024#i.female_owner ///
            i.year, fe vce(cluster BlockCode)
        quietly test (1.female_owner#c.treat_2022) (1.female_owner#c.treat_2023) (1.female_owner#c.treat_2024)
        local pval_diff_`i' = r(p)
        
        * Add difference test to estimates (restore and add, then store with new name)
        estimates restore male_`i'
        estadd scalar diff_pval = `pval_diff_`i''
        eststo male_final_`i'
        
        estimates restore female_`i'
        estadd scalar diff_pval = `pval_diff_`i''
        eststo female_final_`i'
        
        display "Processed outcome `i': `label' (Male N=`n_male', Female N=`n_female', Diff P-val=`pval_diff_`i'')"
    }
    else {
        display "Skipping outcome `i': `label' - insufficient observations (Male N=`n_male', Female N=`n_female')"
    }
    
    local i = `i' + 1
}

* Generate gender heterogeneity table with outcomes in rows
#delimit ;
esttab male_* female_* using "$Scratch/gender_heterogeneity_rows.rtf", replace ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) nogaps nonumbers ///
    keep(treat_2022 treat_2023 treat_2024) ///
    order(treat_2022 treat_2023 treat_2024) ///
    stats(N control_mean diff_pval outcome_var sample_group, 
          fmt(%9.0g %9.3f %9.3f %s %s) 
          labels("Observations" "Control Group Mean" "Test: Male=Female P-value" "Outcome" "Sample")) ///
    title("Table A: Gender Heterogeneity Analysis - Treatment Effects on Investment Outcomes") ///
    addnotes("Standard errors clustered at block level in parentheses" 
             "Each column shows results for one outcome-gender combination"
             "Test: Male=Female P-value tests whether treatment effects differ significantly between genders"
             "Control Group Mean shows baseline values for untreated enterprises") ///
    label legend ;
#delimit cr

* =================================================================
* 2. ENTERPRISE TYPE HETEROGENEITY TABLE (OUTCOMES IN ROWS)
* =================================================================

* Clear estimates for enterprise type analysis
eststo clear

local i = 1
foreach var in `outcomes' {
    local label : word `i' of `outcome_labels'
    
    * Check sufficient observations for each enterprise type
    quietly count if !missing(`var') & sec2_q2==1 & !missing(treat_2022, treat_2023, treat_2024)
    local n_manuf = r(N)
    quietly count if !missing(`var') & sec2_q2==2 & !missing(treat_2022, treat_2023, treat_2024)
    local n_trade = r(N)
    quietly count if !missing(`var') & sec2_q2==3 & !missing(treat_2022, treat_2023, treat_2024)
    local n_services = r(N)
    
    if `n_manuf' > 50 & `n_trade' > 50 & `n_services' > 50 {
        * Manufacturing
        eststo manuf_`i': quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if sec2_q2==1, fe vce(cluster BlockCode)
        estadd local outcome_var "`label'"
        estadd local sample_group "Manufacturing"
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==1
        estadd scalar control_mean=r(mean)
        
        * Trade/Retail
        eststo trade_`i': quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if sec2_q2==2, fe vce(cluster BlockCode)
        estadd local outcome_var "`label'"
        estadd local sample_group "Trade/Retail"
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==2
        estadd scalar control_mean=r(mean)
        
        * Services
        eststo services_`i': quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if sec2_q2==3, fe vce(cluster BlockCode)
        estadd local outcome_var "`label'"
        estadd local sample_group "Services"
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & sec2_q2==3
        estadd scalar control_mean=r(mean)
        
        * Test for differences across enterprise types
        quietly xtreg `var' treat_2022 treat_2023 treat_2024 ///
            c.treat_2022#i.sec2_q2 c.treat_2023#i.sec2_q2 c.treat_2024#i.sec2_q2 ///
            i.year, fe vce(cluster BlockCode)
        quietly test (2.sec2_q2#c.treat_2022) (2.sec2_q2#c.treat_2023) (2.sec2_q2#c.treat_2024) ///
                     (3.sec2_q2#c.treat_2022) (3.sec2_q2#c.treat_2023) (3.sec2_q2#c.treat_2024)
        local pval_enterprise_diff_`i' = r(p)
        
        * Add difference test to all three estimates
        estimates restore manuf_`i'
        estadd scalar diff_pval = `pval_enterprise_diff_`i''
        eststo manuf_final_`i'
        
        estimates restore trade_`i'
        estadd scalar diff_pval = `pval_enterprise_diff_`i''
        eststo trade_final_`i'
        
        estimates restore services_`i'
        estadd scalar diff_pval = `pval_enterprise_diff_`i''
        eststo services_final_`i'
        
        display "Processed outcome `i': `label' (Manuf N=`n_manuf', Trade N=`n_trade', Services N=`n_services')"
    }
    else {
        display "Skipping outcome `i': `label' - insufficient observations (Manuf N=`n_manuf', Trade N=`n_trade', Services N=`n_services')"
    }
    
    local i = `i' + 1
}

* Generate enterprise type heterogeneity table
#delimit ;
esttab manuf_* trade_* services_* using "$Scratch/enterprise_heterogeneity_rows.rtf", replace ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) nogaps nonumbers ///
    keep(treat_2022 treat_2023 treat_2024) ///
    order(treat_2022 treat_2023 treat_2024) ///
    stats(N control_mean diff_pval outcome_var sample_group, 
          fmt(%9.0g %9.3f %9.3f %s %s) 
          labels("Observations" "Control Group Mean" "Test: Equal Effects P-value" "Outcome" "Sample")) ///
    title("Table B: Enterprise Type Heterogeneity Analysis - Treatment Effects on Investment Outcomes") ///
    addnotes("Standard errors clustered at block level in parentheses" 
             "Each column shows results for one outcome-enterprise type combination"
             "Test: Equal Effects P-value tests whether treatment effects differ significantly across enterprise types"
             "Manufacturing: Making food products, textiles, furniture, handicrafts, etc."
             "Trade/Retail: Shop keeping, wholesale trading, selling goods, etc."
             "Services: Repairs, transportation, beauty parlours, tailoring, etc.") ///
    label legend ;
#delimit cr

* =================================================================
* 3. ALTERNATIVE FORMAT: GROUPED BY OUTCOME WITH SUBGROUPS SIDE-BY-SIDE
* =================================================================

* This creates a more compact table with better readability
eststo clear

* Store all estimates in order: outcome1_male, outcome1_female, outcome2_male, outcome2_female, etc.
local i = 1
foreach var in `outcomes' {
    local label : word `i' of `outcome_labels'
    
    * Check sufficient observations
    quietly count if !missing(`var') & female_owner==0 & !missing(treat_2022, treat_2023, treat_2024)
    local n_male = r(N)
    quietly count if !missing(`var') & female_owner==1 & !missing(treat_2022, treat_2023, treat_2024)
    local n_female = r(N)
    
    if `n_male' > 50 & `n_female' > 50 {
        * Store with pattern: outcome_group_subgroup
        eststo `i'_male: quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if female_owner==0, fe vce(cluster BlockCode)
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==0
        estadd scalar control_mean=r(mean)
        
        eststo `i'_female: quietly xtreg `var' treat_2022 treat_2023 treat_2024 i.year if female_owner==1, fe vce(cluster BlockCode)
        quietly sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0 & female_owner==1
        estadd scalar control_mean=r(mean)
        
        local stored_outcomes "`stored_outcomes' `i'"
    }
    
    local i = `i' + 1
}

* Build dynamic esttab command for compact grouped format
local esttab_list ""
local title_list ""
local group_list ""
local pattern_list ""

foreach outcome_num in `stored_outcomes' {
    local outcome_label : word `outcome_num' of `outcome_labels'
    local esttab_list "`esttab_list' `outcome_num'_male `outcome_num'_female"
    local title_list `"`title_list' "Male" "Female""'
    local group_list `"`group_list' "`outcome_label'""'
    if "`pattern_list'" == "" {
        local pattern_list "1 0"
    }
    else {
        local pattern_list "`pattern_list' 1 0"
    }
}

* Generate compact grouped table
#delimit ;
esttab `esttab_list' using "$Scratch/gender_heterogeneity_compact_grouped.rtf", replace ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) nogaps nonumbers ///
    keep(treat_2022 treat_2023 treat_2024) ///
    order(treat_2022 treat_2023 treat_2024) ///
    stats(N control_mean, 
          fmt(%9.0g %9.3f) 
          labels("Observations" "Control Group Mean")) ///
    mtitles(`title_list') ///
    mgroups(`group_list', 
            pattern(`pattern_list') 
            prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    title("Table C: Gender Heterogeneity Analysis - Compact Format") ///
    addnotes("Standard errors clustered at block level in parentheses" 
             "Each outcome shows Male and Female entrepreneurs side-by-side"
             "Only outcomes with sufficient observations included") ///
    label legend ;
#delimit cr







