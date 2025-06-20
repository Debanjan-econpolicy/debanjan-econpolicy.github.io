


global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables_Cov"
global cov "e_age age_entrepreneur female_owner marriage_age shg_member i.sec2_q2 education_yrs i.sec3_q5" 

/*==============================================================================
		RESULT TABLE: Impact of MGP Loans on Enterprise Financing
*==============================================================================*/

global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"



global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables"
global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"

eststo clear
local i=1
foreach var of varlist any_loan count_loan formal_loan_source log_w10_total_loan_remaining avg_int_rate {
    
    areg `var' treatment_285 $cov, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    local i=`i'+1
}

local i=1
foreach var of varlist any_loan count_loan formal_loan_source log_w10_total_loan_remaining avg_int_rate {
    
    areg `var' treatment_285 [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}

// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/loan_table.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table 1: Impact of MGP Loans on Enterprise Financing") 
    varlabels(treatment_285 "MGP")
    mtitles("Any Loan" "Number of Loans" "Formal Loan Source" "Log Outstanding Loan" "Interest Rate (%)") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") 
    nonotes ;
#delimit cr

// Append Panel B
#delimit ;
esttab panelB_* using "$tables/loan_table.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Any Loan" "Number of Loans" "Formal Loan Source" "Log Outstanding Loan" "Interest Rate (%)") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") ;
#delimit cr









global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables"
global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"

/*==============================================================================
        TABLE: Impact of MGP on Investment Behavior
==============================================================================*/

eststo clear
local i=1
foreach var of varlist ever_invested w10_invest_2024 count_invest_2024 wc_invest_2024 wc_share_2024 {
    
    // Panel A: With controls, no weights
    areg `var' treatment_285 $cov, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    local i=`i'+1
}

local i=1
foreach var of varlist ever_invested w10_invest_2024 count_invest_2024 wc_invest_2024 wc_share_2024 {
    
    // Panel B: No controls, with weights
    areg `var' treatment_285 [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}

// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/investment_behavior_table.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table 2: Impact of MGP on Enterprise Investment Behavior") 
    varlabels(treatment_285 "MGP")
    mtitles("Any Investment" "Investment Amount" "Investment Types" "Working Capital" "WC Share") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") 
    nonotes ;
#delimit cr

// Append Panel B
#delimit ;
esttab panelB_* using "$tables/investment_behavior_table.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Any Investment" "Investment Amount" "Investment Types" "Working Capital" "WC Share") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "All investment variables measured for 2024.") ;
#delimit cr
























/*==============================================================================
		RESULT TABLE: Impact of MGP Loans on Enterprise Performance
*==============================================================================*/
// Table 2: Revenue, Costs and Profits
eststo clear
local i=1
foreach var of varlist w10_total_costs_2024 w10_total_revenue_2024 w10_profit_2024 profit_to_revenue_2024 {
    
    areg `var' treatment_285 $cov [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo perf_table_`i'
    
    local i=`i'+1
}

#delimit ;
esttab perf_table_1 perf_table_2 perf_table_3 perf_table_4
    using "$tables/mgp_performance_impact.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table: Impact of MGP Loans on Enterprise Performance") 
    mtitles("Total Costs (2024)" "Total Revenue (2024)" "Profit (2024)" "Profit Margin") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Notes: All variables measured for 2024 and winsorized at 10% to address outliers."
             "All specifications include propensity score weights from matching algorithm."
             "Controls include enterprise age, entrepreneur age, gender, marriage age, SHG membership,"
             "household composition, education years, and enterprise characteristics.") ;
#delimit cr

/*==============================================================================
		RESULT TABLE: Robustness Check - Alternative Measures of Enterprise Performance
*==============================================================================*/
// Table 3: Alternative Measures (calculated vs. reported)
eststo clear
local i=1
foreach var of varlist w10_calc_total_costs_2024 w10_calc_total_revenue_2024 w10_calc_profit_2024 {
    
    areg `var' treatment_285 $cov [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo rob_table_`i'
    
    local i=`i'+1
}

#delimit ;
esttab rob_table_1 rob_table_2 rob_table_3
    using "$tables/mgp_robustness_impact.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table: Robustness Check - Alternative Measures of Enterprise Performance") 
    mtitles("Calculated Costs (2024)" "Calculated Revenue (2024)" "Calculated Profit (2024)") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Notes: All variables are calculated measures (as opposed to directly reported) for 2024."
             "All values are winsorized at 10% to address outliers."
             "All specifications include propensity score weights from matching algorithm."
             "Controls include enterprise age, entrepreneur age, gender, marriage age, SHG membership,"
             "household composition, education years, and enterprise characteristics.") ;
#delimit cr































































global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables"
global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"

/*==============================================================================
        TABLE: Impact of MGP on Loan Repayment Behavior
==============================================================================*/

eststo clear
local i=1
foreach var of varlist has_any_delay has_frequent_delays has_long_delay repayment_difficult total_payment_delays max_delay_length repay_behavior_score {
    
    // Panel A: With controls, no weights
    areg `var' treatment_285 $cov if any_loan==1, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    // Panel B: No controls, with weights
    areg `var' treatment_285 [pweight=_weight] if any_loan==1, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}

// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/repayment_behavior_impact.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table: Impact of MGP on Loan Repayment Behavior") 
    varlabels(treatment_285 "MGP")
    mtitles("Any Delay" "Frequent Delays" "Long Delay" "Repayment Difficult" "Total Delays" "Max Delay Length" "Behavior Score") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Sample restricted to enterprises with at least one loan."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Stars indicate significance levels: * p<0.10, ** p<0.05, *** p<0.01.") 
    nonotes ;
#delimit cr

// Append Panel B
#delimit ;
esttab panelB_* using "$tables/repayment_behavior_impact.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Any Delay" "Frequent Delays" "Long Delay" "Repayment Difficult" "Total Delays" "Max Delay Length" "Behavior Score") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "Sample restricted to enterprises with at least one loan."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Stars indicate significance levels: * p<0.10, ** p<0.05, *** p<0.01."
             "Variable definitions: Any Delay = any payment delay across loans; Frequent Delays = 3+ delays on any loan;"
             "Long Delay = any delay >30 days; Repayment Difficult = self-reported difficulty with repayment;"
             "Total Delays = count of payment delays; Max Delay Length = maximum length of delay in days;"
             "Behavior Score = average of four binary indicators (higher score indicates more repayment problems).") ;
#delimit cr












global tables "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Tables"
global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"

/*==============================================================================
        TABLE: Impact of MGP on Business Practices
==============================================================================*/

eststo clear
local i=1
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Panel A: With controls, no weights
    areg `var' treatment_285 $cov, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    local i=`i'+1
}

local i=1
foreach var of varlist marketingscore stockscore recordscore planningscore totalscore1 {
    
    // Panel B: No controls, with weights
    areg `var' treatment_285 [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}

// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/business_practices_table.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table 3: Impact of MGP on Business Practices") 
    varlabels(treatment_285 "MGP")
    mtitles("Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "All scores represent the proportion of good business practices adopted in each category.") 
    nonotes ;
#delimit cr

// Append Panel B
#delimit ;
esttab panelB_* using "$tables/business_practices_table.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Marketing" "Stock Control" "Record Keeping" "Financial Planning" "Total Score") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Business practice scores developed using 26 binary indicators across four domains: marketing (7 practices),"
             "buying and stock control (3 practices), record-keeping (8 practices), and financial planning (8 practices)."
             "Each domain score represents the proportion of practices adopted, and the total score is the average of all domains.") ;
#delimit cr







/*==============================================================================
        TABLE: Impact of MGP on Labor Outcomes
==============================================================================*/
eststo clear
local i=1
foreach var of varlist employed_any_year total_emp_with_owner_2024 paid_employment_2024 unpaid_employment_2024 paid_emp_share_2024 unpaid_emp_share_2024 {
    
    // Panel A: With controls, no weights
    areg `var' treatment_285 $cov, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    local i=`i'+1
}

local i=1
foreach var of varlist employed_any_year total_emp_with_owner_2024 paid_employment_2024 unpaid_employment_2024 paid_emp_share_2024 unpaid_emp_share_2024 {
    
    // Panel B: No controls, with weights
    areg `var' treatment_285 [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}

// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/labour_outcome_table.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table: Impact of MGP on Labor Outcomes") 
    varlabels(treatment_285 "MGP")
    mtitles("Any Employment" "Total Employment" "Paid Employment" "Unpaid Employment" "Paid Employment Share" "Unpaid Employment Share") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") 
    nonotes ;
#delimit cr

// Append Panel B
#delimit ;
esttab panelB_* using "$tables/labour_outcome_table.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Any Employment" "Total Employment" "Paid Employment" "Unpaid Employment" "Paid Employment Share" "Unpaid Employment Share") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "All specifications include Block fixed effects with standard errors clustered at the Block level."
             "Labor outcomes include: any worker employment (2022-2024), total employment in 2024 (including owner),"
             "paid employment (2024), unpaid employment (2024, including owner and family workers),"
             "and the shares of paid and unpaid workers in total employment (2024).") ;
#delimit cr

























global cov "age_entrepreneur e_age female_owner education_yrs i.sec2_q2 i.sec3_q5 i.Religion"
/*==============================================================================
        TABLE: Impact of MGP on Business Outcomes
==============================================================================*/
eststo clear
local i=1
foreach var of varlist log_monthly_profit log_monthly_sale innovation_score {
    
    // Panel A: With controls, no weights
    areg `var' treatment_285 $cov, absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "Yes"
    estadd local Block_FE "Yes"
    estadd local PSWeights "No"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelA_`i'
    
    local i=`i'+1
}
local i=1
foreach var of varlist log_monthly_profit log_monthly_sale innovation_score {
    
    // Panel B: No controls, with weights
    areg `var' treatment_285 [pweight=_weight], absorb(BlockCode) cluster(BlockCode)
    test treatment_285==0
    estadd scalar pval1=r(p)
    estadd local Covariates "No"
    estadd local Block_FE "Yes"
    estadd local PSWeights "Yes"
    sum `var' if e(sample)
    estadd scalar mean=r(mean)
    estadd scalar sd=r(sd)
    
    eststo panelB_`i'
    
    local i=`i'+1
}
// Output the combined results table
#delimit ;
esttab panelA_* using "$tables/Sale_profit_innovation.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("Table: Impact of MGP on Business Outcomes") 
    varlabels(treatment_285 "MGP")
    mtitles("Log Monthly Profit" "Log Monthly Sales" "Innovation Score") 
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel A: With controls, without propensity score weights."
             "Controls include entrepreneur age, enterprise age, gender, education years, business sector, location and religion."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") 
    nonotes ;
#delimit cr
// Append Panel B
#delimit ;
esttab panelB_* using "$tables/Sale_profit_innovation.rtf", 
    append 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    title("") 
    mtitles("Log Monthly Profit" "Log Monthly Sales" "Innovation Score") 
    varlabels(treatment_285 "MGP")
    stats(mean sd N pval1 Covariates Block_FE PSWeights, 
        fmt(%9.3f %9.3f %9.0g %9.3f %s %s %s) 
    labels("Mean of Dependent Variable" "SD of Dependent Variable" "Observations" "P-value" "Entrepreneur Controls" "Block Fixed Effects" "PS Weights")) 
    addnotes("Panel B: Without controls, with propensity score weights."
             "All specifications include Block fixed effects with standard errors clustered at the Block level.") ;
#delimit cr







