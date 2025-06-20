count if sec6_q1 == 1 & sec6_q3 == 0
replace sec6_q1 = 0 if sec6_q3 == 0

/*==============================================================================
                    Loan Variables on Annual Basis                       
==============================================================================*/

** Basic loan indicator
gen any_loan = (sec6_q1 == 1) if !missing(sec6_q1)
label var any_loan "Has the enterprise taken any loans in last 5 years"
label define yesno 0 "No" 1 "Yes", replace
label values any_loan yesno

/* Create indicators for any loan in each year */
forval year = 2022/2025 {
	cap drop any_loan_`year'
    gen any_loan_`year' = 0 if !missing(any_loan)
    
    label var any_loan_`year' "Any loan taken in `year'"
}

* Populate annual loan indicators
forvalues loannum = 1/3 {    
    * 2022
    replace any_loan_2022 = 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace any_loan_2023 = 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace any_loan_2024 = 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace any_loan_2025 = 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
}

forval year = 2022/2025 {
    label values any_loan_`year' yesno
}

/* Loan count variables */
* Total loan count
clonevar loan_count = sec6_q3
replace loan_count = 0 if loan_count == . & any_loan == 0						//Those who have not applied any loan that means they have 0 loans, so replace them with 0 is justified. 
la var loan_count "Number of loans taken in last 5 years"

forval year = 2022/2025 {
	cap drop loan_count_`year'
    gen loan_count_`year' = 0 if !missing(any_loan)
    
    label var loan_count_`year' "Number of loans taken in `year'"
}

forvalues loannum = 1/3 {
    
    * 2022
    replace loan_count_2022 = loan_count_2022 + 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace loan_count_2023 = loan_count_2023 + 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace loan_count_2024 = loan_count_2024 + 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace loan_count_2025 = loan_count_2025 + 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
}




replace sec6_q4_1 = 4 if inlist(sec6_q4_others_1, "SHG", "SHG Loan", "Nef")
replace sec6_q4_1 = 4 if inlist(sec6_q4_others_1, "Makalir group", "House loan", "10000" )
replace sec6_q4_2 = 4 if inlist(sec6_q4_others_2, "MSG", "SHG", "SHG loan", "Shop")

/* Formal vs informal loan indicators */
* Overall formal/informal loan access indicator
gen formal_loan_source = 0 if any_loan == 1 & !missing(any_loan)
gen informal_loan_source = 0 if any_loan == 1 & !missing(any_loan)

forvalues loannum = 1/3 {
    replace formal_loan_source = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum')
    replace informal_loan_source = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum')
}

label var formal_loan_source "Has formal loan in last 5 years"
label var informal_loan_source "Has informal loan in last 5 years"
label values formal_loan_source informal_loan_source yesno

* Formal and informal loan indicators by year
forval year = 2022/2025 {
	cap drop formal_loan_`year' informal_loan_`year'
    gen formal_loan_`year' = 0 if !missing(any_loan)
    gen informal_loan_`year' = 0 if !missing(any_loan)
    
    label var formal_loan_`year' "Has formal loan in `year'"
    label var informal_loan_`year' "Has informal loan in `year'"
}

forvalues loannum = 1/3 {
    
    * 2022
    replace formal_loan_2022 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_2023 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_2024 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_2025 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_2025 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
}

forval year = 2022/2025 {
    label values formal_loan_`year' informal_loan_`year' yesno
}

/* Formal vs informal loan counts */
* Overall formal/informal loan counts
gen formal_loan_count = 0 if any_loan == 1 & !missing(any_loan)
gen informal_loan_count = 0 if any_loan == 1 & !missing(any_loan)

forvalues loannum = 1/3 {
    replace formal_loan_count = formal_loan_count + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum')
    replace informal_loan_count = informal_loan_count + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum')
}

* Those who have not applied the loan they will have 0 formal and informal loans
replace formal_loan_count = 0 if formal_loan_count == . & loan_count == 0
replace informal_loan_count = 0 if informal_loan_count == . & loan_count == 0

label var formal_loan_count "Number of formal loans in last 5 years"
label var informal_loan_count "Number of informal loans in last 5 years"

* Formal and informal loan counts by year
forval year = 2022/2025 {
	cap drop formal_loan_count_`year' informal_loan_count_`year'
    gen formal_loan_count_`year' = 0 if !missing(any_loan)
    gen informal_loan_count_`year' = 0 if !missing(any_loan)
    
    label var formal_loan_count_`year' "Number of formal loans in `year'"
    label var informal_loan_count_`year' "Number of informal loans in `year'"
}

* Populate annual formal/informal loan counts
forvalues loannum = 1/3 {
    
    * 2022
    replace formal_loan_count_2022 = formal_loan_count_2022 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022 = informal_loan_count_2022 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_count_2023 = formal_loan_count_2023 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023 = informal_loan_count_2023 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_count_2024 = formal_loan_count_2024 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024 = informal_loan_count_2024 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_count_2025 = formal_loan_count_2025 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2025 = informal_loan_count_2025 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')

}

*Total loan applied
ds sec6_q8_* 
egen total_loan_applied = rowtotal(`r(varlist)') if any_loan != .
la var total_loan_applied "Total loan amount requested in last 5 years (Rs.)"

*total loan received
ds sec6_q9_*
egen total_loan_received = rowtotal(`r(varlist)') if any_loan != .
label variable total_loan_received "Total loan amount received in last 5 years (Rs.)"

/* Annual Loan amount variables */
* Create loan amount variables by year
forval year = 2022/2025 {
    gen loan_amount_`year' = 0 if !missing(any_loan)
    gen formal_amount_`year' = 0 if !missing(any_loan)
    gen informal_amount_`year' = 0 if !missing(any_loan)
    
    label var loan_amount_`year' "Total loan amount received in `year'"
    label var formal_amount_`year' "Formal loan amount received in `year'"
    label var informal_amount_`year' "Informal loan amount received in `year'"
}

forvalues loannum = 1/3 {
    * 2022 amounts
    replace loan_amount_2022 = loan_amount_2022 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2022 = formal_amount_2022 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2022 = informal_amount_2022 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2023 amounts
    replace loan_amount_2023 = loan_amount_2023 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2023 = formal_amount_2023 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2023 = informal_amount_2023 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')

    * 2024 amounts
    replace loan_amount_2024 = loan_amount_2024 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2024 = formal_amount_2024 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2024 = informal_amount_2024 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2025 amounts
    replace loan_amount_2025 = loan_amount_2025 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2025 = formal_amount_2025 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2025 = informal_amount_2025 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
}






/* Create total unpaid loan variable */
ds sec6_q7_*
egen total_loan_remaining = rowtotal(`r(varlist)')  if any_loan == 1
label variable total_loan_remaining "Total unpaid principal across active loans (Rs.)"

/* Create log transformation (without winsorizing) */
gen log_total_loan_remaining = log(total_loan_remaining+1) if !missing(total_loan_remaining)
label variable log_total_loan_remaining "Log of Total unpaid loans"

/* Create annual unpaid loan variables */
forval year = 2022/2025 {
	cap drop total_loan_remaining_`year'
    gen total_loan_remaining_`year' = 0 if any_loan == 1
    
    label var total_loan_remaining_`year' "Total unpaid loan amount in `year'"
}

sum loan_count, d
local max_loan = r(max)
/* For each loan and each year, add unpaid amounts if the loan is active in that period */
forvalues loannum = 1/`max_loan' {
    forval year = 2022/2025 {
        /* A loan is active in a period if: 
           1. It started on or before the end of the period AND
           2. Either it's still active (sec6_q6_`loannum' == 1) OR 
              its end date (approximated from start + duration) is after the start of the period */
        
        /* Calculate approximate end date based on loan duration */
        cap gen temp_end_date_`loannum' = sec6_q5_`loannum' + (sec6_q16_`loannum' * 30.44) if !missing(sec6_q5_`loannum') & !missing(sec6_q16_`loannum')
        
        /* Add loan amount to the annual total if it's active in that period */
        replace total_loan_remaining_`year' = total_loan_remaining_`year' + sec6_q7_`loannum' ///
            if sec6_q5_`loannum' <= td(31dec`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01jan`year')) ///
            & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        
    }
    
    cap drop temp_end_date_`loannum'
}

forval year = 2022/2025 {
    /* Create log transformation */
    gen log_total_loan_remaining_`year' = log(total_loan_remaining_`year') ///
        if total_loan_remaining_`year' > 0 & !missing(total_loan_remaining_`year')
    
    label var log_total_loan_remaining_`year' "Log of total unpaid loan in `year'"
}

/*==============================================================================
                       Interest Rate Variables                            
==============================================================================*/

destring annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3, replace
sum annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3  //SurveyCTO generated Interest rate variable

/* Calculate annual interest rates for all loans with compounding */
sum loan_count, d
local max_loan = r(max)

forvalues i = 1/`max_loan' {
    gen an_int_`i' = .
    
    // Already annual rate
    replace an_int_`i' = sec6_q17_`i' if sec6_q18_`i' == 1 & !missing(sec6_q17_`i')
    
    // Monthly to annual with compounding: (1 + r/100)^12 - 1) * 100
    replace an_int_`i' = (((1 + sec6_q17_`i'/100)^12) - 1) * 100 if sec6_q18_`i' == 2 & !missing(sec6_q17_`i')
    
    // Weekly to annual with compounding: (1 + r/100)^52 - 1) * 100
    replace an_int_`i' = (((1 + sec6_q17_`i'/100)^52) - 1) * 100 if sec6_q18_`i' == 3 & !missing(sec6_q17_`i')
    
    // Daily to annual with compounding: (1 + r/100)^365 - 1) * 100
    replace an_int_`i' = (((1 + sec6_q17_`i'/100)^365) - 1) * 100 if sec6_q18_`i' == 4 & !missing(sec6_q17_`i')
    
    label var an_int_`i' "Annual interest rate for loan `i' with compounding"
}

/* Create winsorized versions at 5% */
forvalues var = 1/`max_loan' {
    gen w5_an_int_`var' = an_int_`var'
    sum w5_an_int_`var', detail
    replace w5_an_int_`var' = r(p5) if an_int_`var' <= r(p5) & !missing(an_int_`var')
    replace w5_an_int_`var' = r(p95) if an_int_`var' >= r(p95) & !missing(an_int_`var')
    label var w5_an_int_`var' "Wins (at 5%) an_int_`var'"
}

/* Calculate maximum interest rate across all loans */
egen max_int_rate = rowmax(an_int_*)
label var max_int_rate "Maximum annual interest rate across all loans (%)"

/* Create formal and informal interest rate variables for each loan */
forvalues i = 1/`max_loan' {
    /* Create temporary variables for rates by type */
    gen temp_formal_int_`i' = an_int_`i' if inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
    gen temp_informal_int_`i' = an_int_`i' if inlist(sec6_q4_`i', 1, 3)
}

/* Calculate average interest rates by source */
egen avg_formal_int_rate = rowmean(temp_formal_int_*)
egen avg_informal_int_rate = rowmean(temp_informal_int_*)

label var avg_formal_int_rate "Average annual interest rate for formal loans (%)"
label var avg_informal_int_rate "Average annual interest rate for informal loans (%)"

/* Create winsorized versions of key interest rate variables */
foreach var in max_int_rate avg_formal_int_rate avg_informal_int_rate {
    gen w5_`var' = `var'
    sum w5_`var', detail
    replace w5_`var' = r(p5) if `var' <= r(p5) & !missing(`var')
    replace w5_`var' = r(p95) if `var' >= r(p95) & !missing(`var')
    label var w5_`var' "Winsorized (at 5%) `var'"
}

/* Create log versions for use in regressions */
foreach var in max_int_rate avg_formal_int_rate avg_informal_int_rate {
    gen log_`var' = log(`var') if `var' > 0 & !missing(`var')
    label var log_`var' "Log of `var'"
}

/* Calculate interest rate gap between formal and informal */
gen formal_informal_gap = avg_informal_int_rate - avg_formal_int_rate if !missing(avg_informal_int_rate) & !missing(avg_formal_int_rate)
label var formal_informal_gap "Gap between informal and formal interest rates (%)"

/* Clean up temporary variables */
drop temp_formal_int_* temp_informal_int_*

/* Create winsorized versions of key interest rate variables */
foreach var in annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3 {
    gen w5_`var' = `var'
    sum w5_`var', detail
    replace w5_`var' = r(p5) if `var' <= r(p5) & !missing(`var')
    replace w5_`var' = r(p95) if `var' >= r(p95) & !missing(`var')
    label var w5_`var' "Winsorized (at 5%) `var'"
}


/*==============================================================================
                   Annual Interest Rate Variables                            
==============================================================================*/

/* Create annual interest rate variables */
forval year = 2022/2025 {
    /* Initialize variables for each year */
    gen avg_int_rate_`year' = . 
    gen formal_int_rate_`year' = .
    gen informal_int_rate_`year' = .
    
    /* Label variables */
    label var avg_int_rate_`year' "Average interest rate in `year'"
    label var formal_int_rate_`year' "Formal loan interest rate in `year'"
    label var informal_int_rate_`year' "Informal loan interest rate in `year'"
}

sum loan_count, d
local max_loan = r(max)
/* Fill in annual interest rate variables based on loan start dates */
forvalues i = 1/`max_loan' {
    forval year = 2022/2025 {
        /* If loan was taken in this year, record its interest rate */
        replace avg_int_rate_`year' = annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(annual_interest_rate_`i')
            
        /* Record by source type */
        replace formal_int_rate_`year' = annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        replace informal_int_rate_`year' = annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 1, 3)
    }
}


/*==============================================================================
                           Loan Purpose Variables                           
==============================================================================*/

sum loan_count, d
forval loannum = 1/`r(max)'   {
    ** SurveyCTO stores multiple values (1, 1 3, 2 3) for select_mutiple variables
    gen loan_`loannum'_multi_purpose = (strpos(sec6_q15_`loannum', " ") > 0) if !missing(sec6_q15_`loannum')
    
    * Create binary variables for each purpose type
    gen loan_`loannum'_fixed_capital = (strpos(sec6_q15_`loannum', "1") > 0) if !missing(sec6_q15_`loannum')
    gen loan_`loannum'_working_capital = (strpos(sec6_q15_`loannum', "2") > 0) if !missing(sec6_q15_`loannum')
    gen loan_`loannum'_consumption = (strpos(sec6_q15_`loannum', "3") > 0) if !missing(sec6_q15_`loannum')
    
    label var loan_`loannum'_multi_purpose "Loan `loannum' has multiple purposes"
    label var loan_`loannum'_fixed_capital "Loan `loannum' used for fixed capital"
    label var loan_`loannum'_working_capital "Loan `loannum' used for working capital"
    label var loan_`loannum'_consumption "Loan `loannum' used for consumption"
}

foreach loannum in 1 2 3 {
    label values loan_`loannum'_multi_purpose loan_`loannum'_fixed_capital loan_`loannum'_working_capital loan_`loannum'_consumption yesno
}

gen loan_for_fixed_capital = 0 if any_loan == 1 & !missing(any_loan)
gen loan_for_working_capital = 0 if any_loan == 1 & !missing(any_loan)
gen loan_for_consumption = 0 if any_loan == 1 & !missing(any_loan)

sum loan_count, d
forval loannum = 1/`r(max)' {
    replace loan_for_fixed_capital = 1 if loan_`loannum'_fixed_capital == 1
    replace loan_for_working_capital = 1 if loan_`loannum'_working_capital == 1
    replace loan_for_consumption = 1 if loan_`loannum'_consumption == 1
}

* Label the variables
label var loan_for_fixed_capital "Took loan for fixed capital in last 5 years"
label var loan_for_working_capital "Took loan for working capital in last 5 years"
label var loan_for_consumption "Took loan for consumption in last 5 years"
label values loan_for_fixed_capital loan_for_working_capital loan_for_consumption yesno

/* Annual loan purpose indicators */
forval year = 2022/2025 {
	cap drop fixed_capital_loan_`year' working_capital_loan_`year' consumption_loan_`year' 
    gen fixed_capital_loan_`year' = 0 if !missing(any_loan)
    gen working_capital_loan_`year' = 0 if !missing(any_loan)
    gen consumption_loan_`year' = 0 if !missing(any_loan)
    
    label var fixed_capital_loan_`year' "Took fixed capital loan in `year'"
    label var working_capital_loan_`year' "Took working capital loan in `year'"
    label var consumption_loan_`year' "Took consumption loan in `year'"
}

* Populate annual loan purpose indicators
sum loan_count, d
forval loannum = 1/`r(max)' {
    
    * 2022
    replace fixed_capital_loan_2022 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2022 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2022 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace fixed_capital_loan_2023 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2023 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2023 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace fixed_capital_loan_2024 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2024 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2024 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace fixed_capital_loan_2025 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2025 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2025 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31dec2025) & !missing(sec6_q5_`loannum')
}

forval year = 2022/2025 {
    label values fixed_capital_loan_`year' working_capital_loan_`year' consumption_loan_`year' yesno
}

/* Loan amount by purpose variables */
gen fixed_capital_amount = 0 if any_loan == 1 & !missing(any_loan)
gen working_capital_amount = 0 if any_loan == 1 & !missing(any_loan)
gen consumption_amount = 0 if any_loan == 1 & !missing(any_loan)

/* For loan 1 - direct mapping for specific cases */
/* For cases with only one purpose selected */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1)
replace consumption_amount = consumption_amount + sec6_q15a_1_1 if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1)

/* For cases with multiple purposes selected */
/* Fixed capital + Working capital (1 2) */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_1_2 if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2)

/* Fixed capital + Consumption (1 3) */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1)
replace consumption_amount = consumption_amount + sec6_q15a_1_2 if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2)

/* Working capital + Consumption (2 3) */
replace working_capital_amount = working_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1)
replace consumption_amount = consumption_amount + sec6_q15a_1_2 if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2)

/* All three purposes (1 2 3) */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_1_1 if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_1_2 if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2)
replace consumption_amount = consumption_amount + sec6_q15a_1_3 if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3)

/* For loan 2 - same pattern */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1)
replace consumption_amount = consumption_amount + sec6_q15a_2_1 if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1)

/* For cases with multiple purposes selected */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_2_2 if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2)

replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1)
replace consumption_amount = consumption_amount + sec6_q15a_2_2 if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2)

replace working_capital_amount = working_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1)
replace consumption_amount = consumption_amount + sec6_q15a_2_2 if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2)

replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_2_1 if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_2_2 if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2)
replace consumption_amount = consumption_amount + sec6_q15a_2_3 if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3)

/* For loan 3 - same pattern */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1)
replace consumption_amount = consumption_amount + sec6_q15a_3_1 if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1)

/* For cases with multiple purposes selected */
replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_3_2 if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2)

replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1)
replace consumption_amount = consumption_amount + sec6_q15a_3_2 if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2)

replace working_capital_amount = working_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1)
replace consumption_amount = consumption_amount + sec6_q15a_3_2 if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2)

replace fixed_capital_amount = fixed_capital_amount + sec6_q15a_3_1 if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1)
replace working_capital_amount = working_capital_amount + sec6_q15a_3_2 if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2)
replace consumption_amount = consumption_amount + sec6_q15a_3_3 if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3)

label var fixed_capital_amount "Total amount spent on fixed capital from loans (Rs.)"
label var working_capital_amount "Total amount spent on working capital from loans (Rs.)"
label var consumption_amount "Total amount spent on consumption from loans (Rs.)"

sum fixed_capital_amount working_capital_amount consumption_amount, detail

/* Create total loan usage variable */
gen total_loan_usage = fixed_capital_amount + working_capital_amount + consumption_amount
label var total_loan_usage "Total loan amount used across all purposes (Rs.)"

/* Create winsorized versions of amount variables */
foreach var in fixed_capital_amount working_capital_amount consumption_amount total_loan_usage {
    gen w10_`var' = `var'
    qui sum w10_`var', detail
    replace w10_`var' = r(p10) if `var' <= r(p10) & !missing(`var')
    replace w10_`var' = r(p90) if `var' >= r(p90) & !missing(`var')
    label var w10_`var' "Winsorized (at 10%) `var' (Rs.)"
}

/* Create annual loan amount by purpose variables */
forval year = 2022/2025 {
    gen fixed_capital_amount_`year' = 0 if !missing(any_loan)
    gen working_capital_amount_`year' = 0 if !missing(any_loan)
    gen consumption_amount_`year' = 0 if !missing(any_loan)
    
    label var fixed_capital_amount_`year' "Fixed capital loan amount in `year'"
    label var working_capital_amount_`year' "Working capital loan amount in `year'"
    label var consumption_amount_`year' "Consumption loan amount in `year'"
}

/* Process all loans by year for annual amounts */
sum loan_count, d
forval loannum = 1/`r(max)' {
    forval year = 2022/2025 {
        /* Only one purpose selected */
        replace fixed_capital_amount_`year' = fixed_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "1" & loan_`loannum'_fixed_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace working_capital_amount_`year' = working_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "2" & loan_`loannum'_working_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace consumption_amount_`year' = consumption_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "3" & loan_`loannum'_consumption == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        /* Multiple purposes selected */
        /* Fixed capital + Working capital (1 2) */
        replace fixed_capital_amount_`year' = fixed_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "1 2" & loan_`loannum'_fixed_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace working_capital_amount_`year' = working_capital_amount_`year' + sec6_q15a_`loannum'_2 ///
            if sec6_q15_`loannum' == "1 2" & loan_`loannum'_working_capital == 1 & !missing(sec6_q15a_`loannum'_2) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        /* Fixed capital + Consumption (1 3) */
        replace fixed_capital_amount_`year' = fixed_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "1 3" & loan_`loannum'_fixed_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace consumption_amount_`year' = consumption_amount_`year' + sec6_q15a_`loannum'_2 ///
            if sec6_q15_`loannum' == "1 3" & loan_`loannum'_consumption == 1 & !missing(sec6_q15a_`loannum'_2) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        /* Working capital + Consumption (2 3) */
        replace working_capital_amount_`year' = working_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "2 3" & loan_`loannum'_working_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace consumption_amount_`year' = consumption_amount_`year' + sec6_q15a_`loannum'_2 ///
            if sec6_q15_`loannum' == "2 3" & loan_`loannum'_consumption == 1 & !missing(sec6_q15a_`loannum'_2) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        /* All three purposes (1 2 3) */
        replace fixed_capital_amount_`year' = fixed_capital_amount_`year' + sec6_q15a_`loannum'_1 ///
            if sec6_q15_`loannum' == "1 2 3" & loan_`loannum'_fixed_capital == 1 & !missing(sec6_q15a_`loannum'_1) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace working_capital_amount_`year' = working_capital_amount_`year' + sec6_q15a_`loannum'_2 ///
            if sec6_q15_`loannum' == "1 2 3" & loan_`loannum'_working_capital == 1 & !missing(sec6_q15a_`loannum'_2) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
        
        replace consumption_amount_`year' = consumption_amount_`year' + sec6_q15a_`loannum'_3 ///
            if sec6_q15_`loannum' == "1 2 3" & loan_`loannum'_consumption == 1 & !missing(sec6_q15a_`loannum'_3) ///
            & sec6_q5_`loannum' >= td(01jan`year') & sec6_q5_`loannum' <= td(31dec`year') & !missing(sec6_q5_`loannum')
    }
}



global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"
global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span risk_count"
global age_vars "e_age age_entrepreneur"




keeporder enterprise_id DistrictCode District BlockCode Block PanchayatCode Panchayat treatment_285 cohort_new  ///
    any_loan_* ///
	loan_count_* ///
    formal_loan_20*  ///
    informal_loan_20*  ///
    formal_loan_count_*  ///
    informal_loan_count_* ///
	loan_amount_20* 		///
	formal_amount_*			///
	informal_amount_*			///
    total_loan_remaining_*		///
    log_total_loan_remaining_* ///
	avg_int_rate_*	///
	formal_int_rate_* 	///
	informal_int_rate_*		///
	avg_int_rate_*		///
	fixed_capital_loan_* 		///
	fixed_capital_amount_* 		///
	working_capital_* 			///
	consumption_loan_* 			///
	consumption_amount_*		///
    annual_disbursement_date sec1_q9 ent_running ipw $ent_d_contr $ent_c_contr $age_vars

forvalues y = 2022/2025 {
    rename any_loan_`y' any_loan_`y'
    rename formal_loan_`y' formal_loan_`y'
    rename informal_loan_`y' informal_loan_`y'
    rename loan_count_`y' loan_count_`y'
    rename formal_loan_count_`y' formal_count_`y'
    rename informal_loan_count_`y' informal_count_`y'
    rename total_loan_remaining_`y' loan_remain_`y'
    rename log_total_loan_remaining_`y' log_loan_remain_`y'
}



// Reshape the data to long format
reshape long ///
    any_loan_ ///
    loan_count_ ///
    formal_loan_ ///
    informal_loan_ ///
    formal_loan_count_ ///
    informal_loan_count_ ///
    loan_amount_ ///
    formal_amount_ ///
    informal_amount_ ///
    total_loan_remaining_ ///
    log_total_loan_remaining_ ///
    avg_int_rate_ ///
    formal_int_rate_ ///
    informal_int_rate_ ///
    fixed_capital_loan_ ///
    fixed_capital_amount_ ///
    working_capital_loan_ ///
    working_capital_amount_ ///
    consumption_loan_ ///
    consumption_amount_ ///
    , i(enterprise_id) j(year)


// Create time variable
gen time = year, after(year)

// Rename outcome variables for easier handling
rename any_loan_ any_loan
rename loan_count_ loan_count
rename formal_loan_ formal_loan
rename informal_loan_ informal_loan
rename formal_loan_count_ formal_count
rename informal_loan_count_ informal_count
rename loan_amount_ loan_amount
rename formal_amount_ formal_amount
rename informal_amount_ informal_amount
rename total_loan_remaining_ loan_remain
rename log_total_loan_remaining_ log_loan_remain
rename avg_int_rate_ avg_int_rate
rename formal_int_rate_ formal_int_rate
rename informal_int_rate_ informal_int_rate
rename fixed_capital_loan_ fixed_capital_loan
rename fixed_capital_amount_ fixed_capital_amount
rename working_capital_loan_ working_capital_loan
rename consumption_loan_ consumption_loan
rename consumption_amount_ consumption_amount



// Create standardized outcome variables
foreach var in  loan_count formal_count informal_count loan_amount formal_amount informal_amount loan_remain log_loan_remain avg_int_rate formal_int_rate informal_int_rate fixed_capital_amount  working_capital_amount  consumption_amount {
    zscore `var'
}

// Set up panel structure
encode enterprise_id, gen(enterprise_id_num)
xtset enterprise_id_num time

// Create treatment variables
gen first_treat = annual_disbursement_date, after(time)
gen treated = !missing(first_treat), after(first_treat)
gen rel_time = time - first_treat if treated == 1, after(treated)
replace rel_time = 0 if treated == 0
gen post = (time >= first_treat) & treated == 1, after(rel_time)
gen gvar = first_treat, after(post)
recode gvar (. = 0)
gen never_treat = (first_treat == .), after(gvar)
sum first_treat
gen last_cohort = (first_treat == r(max)) | never_treat, after(never_treat)


