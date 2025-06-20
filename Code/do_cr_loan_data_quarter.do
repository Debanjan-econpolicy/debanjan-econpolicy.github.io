count if sec6_q1 == 1 & sec6_q3 == 0
replace sec6_q1 = 0 if sec6_q3 == 0


/*==============================================================================
                    Loan Variables on Quarterly Basis (2022-2025)                       
==============================================================================*/

** Basic loan indicator
gen any_loan = (sec6_q1 == 1) if !missing(sec6_q1)
label var any_loan "Has the enterprise taken any loans in last 5 years"
label define yesno 0 "No" 1 "Yes", replace
label values any_loan yesno

/* Create indicators for any loan in each quarter */
* Initialize quarterly variables (Q1: Jan-Mar, Q2: Apr-Jun, Q3: Jul-Sep, Q4: Oct-Dec)
forval year = 2022/2025 {
	cap drop any_loan_`year'_Q1 any_loan_`year'_Q2 any_loan_`year'_Q3 any_loan_`year'_Q4
    gen any_loan_`year'_Q1 = 0 if !missing(any_loan)
    gen any_loan_`year'_Q2 = 0 if !missing(any_loan)
    gen any_loan_`year'_Q3 = 0 if !missing(any_loan)
    gen any_loan_`year'_Q4 = 0 if !missing(any_loan)
    
    label var any_loan_`year'_Q1 "Any loan taken in `year' Q1 (Jan-Mar)"
    label var any_loan_`year'_Q2 "Any loan taken in `year' Q2 (Apr-Jun)"
    label var any_loan_`year'_Q3 "Any loan taken in `year' Q3 (Jul-Sep)"
    label var any_loan_`year'_Q4 "Any loan taken in `year' Q4 (Oct-Dec)"
}


* Populate quarterly loan indicators
forvalues loannum = 1/3 {
    * 2022
    replace any_loan_2022_Q1 = 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace any_loan_2022_Q2 = 1 if sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace any_loan_2022_Q3 = 1 if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace any_loan_2022_Q4 = 1 if sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace any_loan_2023_Q1 = 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace any_loan_2023_Q2 = 1 if sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace any_loan_2023_Q3 = 1 if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace any_loan_2023_Q4 = 1 if sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace any_loan_2024_Q1 = 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace any_loan_2024_Q2 = 1 if sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace any_loan_2024_Q3 = 1 if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace any_loan_2024_Q4 = 1 if sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace any_loan_2025_Q1 = 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace any_loan_2025_Q2 = 1 if sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

forval year = 2022/2025 {
    label values any_loan_`year'_Q1 any_loan_`year'_Q2 any_loan_`year'_Q3 any_loan_`year'_Q4 yesno
}
cap drop any_loan_2025_Q3 any_loan_2025_Q4



/* Loan count variables */
* Total loan count
clonevar loan_count = sec6_q3
la var loan_count "Number of loans taken in last 5 years"

* Count loans in each quarter of 2022 - 2025
forval year = 2022/2025 {
	cap drop loan_count_`year'_Q1 loan_count_`year'_Q2 loan_count_`year'_Q3 loan_count_`year'_Q4
    gen loan_count_`year'_Q1 = 0 if !missing(loan_count)
    gen loan_count_`year'_Q2 = 0 if !missing(loan_count)
    gen loan_count_`year'_Q3 = 0 if !missing(loan_count)
    gen loan_count_`year'_Q4 = 0 if !missing(loan_count)
    
    label var loan_count_`year'_Q1 "Number of loans taken in `year' Q1 (Jan-Mar)"
    label var loan_count_`year'_Q2 "Number of loans taken in `year' Q2 (Apr-Jun)"
    label var loan_count_`year'_Q3 "Number of loans taken in `year' Q3 (Jul-Sep)"
    label var loan_count_`year'_Q4 "Number of loans taken in `year' Q4 (Oct-Dec)"
}

forvalues loannum = 1/3 {
    * 2022
    replace loan_count_2022_Q1 = loan_count_2022_Q1 + 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace loan_count_2022_Q2 = loan_count_2022_Q2 + 1 if sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace loan_count_2022_Q3 = loan_count_2022_Q3 + 1 if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace loan_count_2022_Q4 = loan_count_2022_Q4 + 1 if sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace loan_count_2023_Q1 = loan_count_2023_Q1 + 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace loan_count_2023_Q2 = loan_count_2023_Q2 + 1 if sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace loan_count_2023_Q3 = loan_count_2023_Q3 + 1 if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace loan_count_2023_Q4 = loan_count_2023_Q4 + 1 if sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace loan_count_2024_Q1 = loan_count_2024_Q1 + 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace loan_count_2024_Q2 = loan_count_2024_Q2 + 1 if sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace loan_count_2024_Q3 = loan_count_2024_Q3 + 1 if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace loan_count_2024_Q4 = loan_count_2024_Q4 + 1 if sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace loan_count_2025_Q1 = loan_count_2025_Q1 + 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace loan_count_2025_Q2 = loan_count_2025_Q2 + 1 if sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}
drop loan_count_2025_Q3 loan_count_2025_Q4 													//These time periods do not exist.



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

* Formal and informal loan indicators by quarter
forval year = 2022/2025 {
	cap drop formal_loan_`year'_Q1 formal_loan_`year'_Q2 formal_loan_`year'_Q3 formal_loan_`year'_Q4
	cap drop informal_loan_`year'_Q1 informal_loan_`year'_Q2 informal_loan_`year'_Q3 informal_loan_`year'_Q4
    
    gen formal_loan_`year'_Q1 = 0 if !missing(formal_loan_source)
    gen formal_loan_`year'_Q2 = 0 if !missing(formal_loan_source)
    gen formal_loan_`year'_Q3 = 0 if !missing(formal_loan_source)
    gen formal_loan_`year'_Q4 = 0 if !missing(formal_loan_source)
    gen informal_loan_`year'_Q1 = 0 if !missing(formal_loan_source)
    gen informal_loan_`year'_Q2 = 0 if !missing(formal_loan_source)
    gen informal_loan_`year'_Q3 = 0 if !missing(formal_loan_source)
    gen informal_loan_`year'_Q4 = 0 if !missing(formal_loan_source)
    
    label var formal_loan_`year'_Q1 "Has formal loan in `year' Q1 (Jan-Mar)"
    label var formal_loan_`year'_Q2 "Has formal loan in `year' Q2 (Apr-Jun)"
    label var formal_loan_`year'_Q3 "Has formal loan in `year' Q3 (Jul-Sep)"
    label var formal_loan_`year'_Q4 "Has formal loan in `year' Q4 (Oct-Dec)"
    label var informal_loan_`year'_Q1 "Has informal loan in `year' Q1 (Jan-Mar)"
    label var informal_loan_`year'_Q2 "Has informal loan in `year' Q2 (Apr-Jun)"
    label var informal_loan_`year'_Q3 "Has informal loan in `year' Q3 (Jul-Sep)"
    label var informal_loan_`year'_Q4 "Has informal loan in `year' Q4 (Oct-Dec)"
}

forvalues loannum = 1/3 {
    * 2022
    replace formal_loan_2022_Q1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_2022_Q2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_2022_Q3 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_2022_Q4 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_2022_Q1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022_Q2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022_Q3 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022_Q4 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_2023_Q1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_2023_Q2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_2023_Q3 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_2023_Q4 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_2023_Q1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023_Q2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023_Q3 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023_Q4 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_2024_Q1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_2024_Q2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_2024_Q3 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_2024_Q4 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_2024_Q1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024_Q2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024_Q3 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024_Q4 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_2025_Q1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace formal_loan_2025_Q2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_2025_Q1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_2025_Q2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

drop formal_loan_2025_Q3 formal_loan_2025_Q4 informal_loan_2025_Q3 informal_loan_2025_Q4

forval year = 2022/2025 {
    cap label values formal_loan_`year'_Q1 formal_loan_`year'_Q2 formal_loan_`year'_Q3 formal_loan_`year'_Q4 yesno
    cap label values informal_loan_`year'_Q1 informal_loan_`year'_Q2 informal_loan_`year'_Q3 informal_loan_`year'_Q4 yesno
}



/* Formal vs informal loan counts */
* Overall formal/informal loan counts
gen formal_loan_count = 0 if any_loan == 1 & !missing(any_loan)
gen informal_loan_count = 0 if any_loan == 1 & !missing(any_loan)

forvalues loannum = 1/3 {
    replace formal_loan_count = formal_loan_count + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum')
    replace informal_loan_count = informal_loan_count + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum')
}


label var formal_loan_count "Number of formal loans in last 5 years"
label var informal_loan_count "Number of informal loans in last 5 years"

* Formal and informal loan counts by quarter
forval year = 2022/2025 {
	cap drop formal_loan_count_`year'_Q1 formal_loan_count_`year'_Q2 formal_loan_count_`year'_Q3 formal_loan_count_`year'_Q4
	cap drop informal_loan_count_`year'_Q1 informal_loan_count_`year'_Q2 informal_loan_count_`year'_Q3 informal_loan_count_`year'_Q4
    
    gen formal_loan_count_`year'_Q1 = 0 if !missing(formal_loan_count)
    gen formal_loan_count_`year'_Q2 = 0 if !missing(formal_loan_count)
    gen formal_loan_count_`year'_Q3 = 0 if !missing(formal_loan_count)
    gen formal_loan_count_`year'_Q4 = 0 if !missing(formal_loan_count)
    gen informal_loan_count_`year'_Q1 = 0 if !missing(informal_loan_count)
    gen informal_loan_count_`year'_Q2 = 0 if !missing(informal_loan_count)
    gen informal_loan_count_`year'_Q3 = 0 if !missing(informal_loan_count)
    gen informal_loan_count_`year'_Q4 = 0 if !missing(informal_loan_count)
    
    label var formal_loan_count_`year'_Q1 "Number of formal loans in `year' Q1 (Jan-Mar)"
    label var formal_loan_count_`year'_Q2 "Number of formal loans in `year' Q2 (Apr-Jun)"
    label var formal_loan_count_`year'_Q3 "Number of formal loans in `year' Q3 (Jul-Sep)"
    label var formal_loan_count_`year'_Q4 "Number of formal loans in `year' Q4 (Oct-Dec)"
    label var informal_loan_count_`year'_Q1 "Number of informal loans in `year' Q1 (Jan-Mar)"
    label var informal_loan_count_`year'_Q2 "Number of informal loans in `year' Q2 (Apr-Jun)"
    label var informal_loan_count_`year'_Q3 "Number of informal loans in `year' Q3 (Jul-Sep)"
    label var informal_loan_count_`year'_Q4 "Number of informal loans in `year' Q4 (Oct-Dec)"
}

* Populate quarterly formal/informal loan counts
forvalues loannum = 1/3 {
    * 2022
    replace formal_loan_count_2022_Q1 = formal_loan_count_2022_Q1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2022_Q2 = formal_loan_count_2022_Q2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2022_Q3 = formal_loan_count_2022_Q3 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2022_Q4 = formal_loan_count_2022_Q4 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_count_2022_Q1 = informal_loan_count_2022_Q1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022_Q2 = informal_loan_count_2022_Q2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022_Q3 = informal_loan_count_2022_Q3 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022_Q4 = informal_loan_count_2022_Q4 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_count_2023_Q1 = formal_loan_count_2023_Q1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2023_Q2 = formal_loan_count_2023_Q2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2023_Q3 = formal_loan_count_2023_Q3 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2023_Q4 = formal_loan_count_2023_Q4 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_count_2023_Q1 = informal_loan_count_2023_Q1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023_Q2 = informal_loan_count_2023_Q2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023_Q3 = informal_loan_count_2023_Q3 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023_Q4 = informal_loan_count_2023_Q4 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_count_2024_Q1 = formal_loan_count_2024_Q1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2024_Q2 = formal_loan_count_2024_Q2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2024_Q3 = formal_loan_count_2024_Q3 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2024_Q4 = formal_loan_count_2024_Q4 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_count_2024_Q1 = informal_loan_count_2024_Q1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024_Q2 = informal_loan_count_2024_Q2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024_Q3 = informal_loan_count_2024_Q3 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024_Q4 = informal_loan_count_2024_Q4 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_count_2025_Q1 = formal_loan_count_2025_Q1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2025_Q2 = formal_loan_count_2025_Q2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    
    replace informal_loan_count_2025_Q1 = informal_loan_count_2025_Q1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2025_Q2 = informal_loan_count_2025_Q2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}
drop formal_loan_count_2025_Q3 formal_loan_count_2025_Q4 informal_loan_count_2025_Q3 informal_loan_count_2025_Q4



*Total loan applied
ds sec6_q8_* 
egen total_loan_applied = rowtotal(`r(varlist)') if any_loan != .
la var total_loan_applied "Total loan amount requested in last 5 years (Rs.)"

*total loan received
ds sec6_q9_*
egen total_loan_received = rowtotal(`r(varlist)') if any_loan != .
label variable total_loan_received "Total loan amount received in last 5 years (Rs.)"

/* Quarterly Loan amount variables */
* Create loan amount variables by quarter
forval year = 2022/2025 {
    gen loan_amount_`year'_Q1 = 0 if !missing(loan_count)
    gen loan_amount_`year'_Q2 = 0 if !missing(loan_count)
    gen loan_amount_`year'_Q3 = 0 if !missing(loan_count)
    gen loan_amount_`year'_Q4 = 0 if !missing(loan_count)
    gen formal_amount_`year'_Q1 = 0 if !missing(formal_loan_count)
    gen formal_amount_`year'_Q2 = 0 if !missing(formal_loan_count)
    gen formal_amount_`year'_Q3 = 0 if !missing(formal_loan_count)
    gen formal_amount_`year'_Q4 = 0 if !missing(formal_loan_count)
    gen informal_amount_`year'_Q1 = 0 if !missing(informal_loan_count)
    gen informal_amount_`year'_Q2 = 0 if !missing(informal_loan_count)
    gen informal_amount_`year'_Q3 = 0 if !missing(informal_loan_count)
    gen informal_amount_`year'_Q4 = 0 if !missing(informal_loan_count)
    
    label var loan_amount_`year'_Q1 "Total loan amount received in `year' Q1 (Jan-Mar)"
    label var loan_amount_`year'_Q2 "Total loan amount received in `year' Q2 (Apr-Jun)"
    label var loan_amount_`year'_Q3 "Total loan amount received in `year' Q3 (Jul-Sep)"
    label var loan_amount_`year'_Q4 "Total loan amount received in `year' Q4 (Oct-Dec)"
    label var formal_amount_`year'_Q1 "Formal loan amount received in `year' Q1 (Jan-Mar)"
    label var formal_amount_`year'_Q2 "Formal loan amount received in `year' Q2 (Apr-Jun)"
    label var formal_amount_`year'_Q3 "Formal loan amount received in `year' Q3 (Jul-Sep)"
    label var formal_amount_`year'_Q4 "Formal loan amount received in `year' Q4 (Oct-Dec)"
    label var informal_amount_`year'_Q1 "Informal loan amount received in `year' Q1 (Jan-Mar)"
    label var informal_amount_`year'_Q2 "Informal loan amount received in `year' Q2 (Apr-Jun)"
    label var informal_amount_`year'_Q3 "Informal loan amount received in `year' Q3 (Jul-Sep)"
    label var informal_amount_`year'_Q4 "Informal loan amount received in `year' Q4 (Oct-Dec)"
}
drop loan_amount_2025_Q3 loan_amount_2025_Q4 informal_amount_2025_Q3 informal_amount_2025_Q4 formal_amount_2025_Q3 formal_amount_2025_Q4

forvalues loannum = 1/3 {
    * 2022 amounts
    replace loan_amount_2022_Q1 = loan_amount_2022_Q1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2022_Q2 = loan_amount_2022_Q2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2022_Q3 = loan_amount_2022_Q3 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2022_Q4 = loan_amount_2022_Q4 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2022_Q1 = formal_amount_2022_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2022_Q2 = formal_amount_2022_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2022_Q3 = formal_amount_2022_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2022_Q4 = formal_amount_2022_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2022_Q1 = informal_amount_2022_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2022_Q2 = informal_amount_2022_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2022_Q3 = informal_amount_2022_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2022_Q4 = informal_amount_2022_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2023 amounts
    replace loan_amount_2023_Q1 = loan_amount_2023_Q1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2023_Q2 = loan_amount_2023_Q2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2023_Q3 = loan_amount_2023_Q3 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2023_Q4 = loan_amount_2023_Q4 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2023_Q1 = formal_amount_2023_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2023_Q2 = formal_amount_2023_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2023_Q3 = formal_amount_2023_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2023_Q4 = formal_amount_2023_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2023_Q1 = informal_amount_2023_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2023_Q2 = informal_amount_2023_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2023_Q3 = informal_amount_2023_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2023_Q4 = informal_amount_2023_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2024 amounts
    replace loan_amount_2024_Q1 = loan_amount_2024_Q1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2024_Q2 = loan_amount_2024_Q2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2024_Q3 = loan_amount_2024_Q3 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2024_Q4 = loan_amount_2024_Q4 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2024_Q1 = formal_amount_2024_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2024_Q2 = formal_amount_2024_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2024_Q3 = formal_amount_2024_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2024_Q4 = formal_amount_2024_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2024_Q1 = informal_amount_2024_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2024_Q2 = informal_amount_2024_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2024_Q3 = informal_amount_2024_Q3 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2024_Q4 = informal_amount_2024_Q4 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2025 amounts
    replace loan_amount_2025_Q1 = loan_amount_2025_Q1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2025_Q2 = loan_amount_2025_Q2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2025_Q1 = formal_amount_2025_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2025_Q2 = formal_amount_2025_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2025_Q1 = informal_amount_2025_Q1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2025_Q2 = informal_amount_2025_Q2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
}

/*
br sec6_q5_1 sec6_q9_1 sec6_q4_1 sec6_q5_2 sec6_q9_2 sec6_q4_2 sec6_q5_3 sec6_q9_3 sec6_q4_3 ///
   loan_amount_2022_Q1 loan_amount_2022_Q2 loan_amount_2022_Q3 loan_amount_2022_Q4 ///
   formal_amount_2022_Q1 formal_amount_2022_Q2 formal_amount_2022_Q3 formal_amount_2022_Q4 ///
   informal_amount_2022_Q1 informal_amount_2022_Q2 informal_amount_2022_Q3 informal_amount_2022_Q4 ///
   loan_amount_2023_Q1 loan_amount_2023_Q2 loan_amount_2023_Q3 loan_amount_2023_Q4 ///
   formal_amount_2023_Q1 formal_amount_2023_Q2 formal_amount_2023_Q3 formal_amount_2023_Q4 ///
   informal_amount_2023_Q1 informal_amount_2023_Q2 informal_amount_2023_Q3 informal_amount_2023_Q4 ///
   loan_amount_2024_Q1 loan_amount_2024_Q2 loan_amount_2024_Q3 loan_amount_2024_Q4 ///
   formal_amount_2024_Q1 formal_amount_2024_Q2 formal_amount_2024_Q3 formal_amount_2024_Q4 ///
   informal_amount_2024_Q1 informal_amount_2024_Q2 informal_amount_2024_Q3 informal_amount_2024_Q4 ///
   loan_amount_2025_Q1 loan_amount_2025_Q2 formal_amount_2025_Q1 formal_amount_2025_Q2 ///
   informal_amount_2025_Q1 informal_amount_2025_Q2
*/


/* Active loan indicators by quarter */
* Calculate loan end dates for each loan
sum loan_count, d
local max_loan = r(max)
forvalues loannum = 1/`max_loan' {
    * Generate loan end date based on duration
    gen loan_end_date_`loannum' = .
    
    * Since sec6_q5_`loannum' is already in date format, we can use it directly
    replace loan_end_date_`loannum' = sec6_q5_`loannum' + (sec6_q16_`loannum' * 30.44) if !missing(sec6_q5_`loannum') & !missing(sec6_q16_`loannum')
    format loan_end_date_`loannum' %td
    
    * For loans that are marked as not active, we can use sec6_q6_`loannum' to verify and adjust
    replace loan_end_date_`loannum' = . if sec6_q6_`loannum' == 0 & missing(loan_end_date_`loannum')
}

* Create indicators for active loans in each quarter
forval year = 2022/2025 {
    gen active_loan_`year'_Q1 = 0 if !missing(any_loan)
    gen active_loan_`year'_Q2 = 0 if !missing(any_loan)
    gen active_loan_`year'_Q3 = 0 if !missing(any_loan)
    gen active_loan_`year'_Q4 = 0 if !missing(any_loan)
    
    label var active_loan_`year'_Q1 "Has active loan during `year' Q1 (Jan-Mar)"
    label var active_loan_`year'_Q2 "Has active loan during `year' Q2 (Apr-Jun)"
    label var active_loan_`year'_Q3 "Has active loan during `year' Q3 (Jul-Sep)"
    label var active_loan_`year'_Q4 "Has active loan during `year' Q4 (Oct-Dec)"
}

sum loan_count, d
* Populate active loan indicators
forvalues loannum = 1/`max_loan' {
    * 2022 Q1: loan is active if start date <= end of Q1 AND end date >= start of Q1 (or loan is still active)
    replace active_loan_2022_Q1 = 1 if sec6_q5_`loannum' <= td(31mar2022) & (loan_end_date_`loannum' >= td(01jan2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2022 Q2
    replace active_loan_2022_Q2 = 1 if sec6_q5_`loannum' <= td(30jun2022) & (loan_end_date_`loannum' >= td(01apr2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2022 Q3
    replace active_loan_2022_Q3 = 1 if sec6_q5_`loannum' <= td(30sep2022) & (loan_end_date_`loannum' >= td(01jul2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2022 Q4
    replace active_loan_2022_Q4 = 1 if sec6_q5_`loannum' <= td(31dec2022) & (loan_end_date_`loannum' >= td(01oct2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 Q1
    replace active_loan_2023_Q1 = 1 if sec6_q5_`loannum' <= td(31mar2023) & (loan_end_date_`loannum' >= td(01jan2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 Q2
    replace active_loan_2023_Q2 = 1 if sec6_q5_`loannum' <= td(30jun2023) & (loan_end_date_`loannum' >= td(01apr2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 Q3
    replace active_loan_2023_Q3 = 1 if sec6_q5_`loannum' <= td(30sep2023) & (loan_end_date_`loannum' >= td(01jul2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 Q4
    replace active_loan_2023_Q4 = 1 if sec6_q5_`loannum' <= td(31dec2023) & (loan_end_date_`loannum' >= td(01oct2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 Q1
    replace active_loan_2024_Q1 = 1 if sec6_q5_`loannum' <= td(31mar2024) & (loan_end_date_`loannum' >= td(01jan2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 Q2
    replace active_loan_2024_Q2 = 1 if sec6_q5_`loannum' <= td(30jun2024) & (loan_end_date_`loannum' >= td(01apr2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 Q3
    replace active_loan_2024_Q3 = 1 if sec6_q5_`loannum' <= td(30sep2024) & (loan_end_date_`loannum' >= td(01jul2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 Q4
    replace active_loan_2024_Q4 = 1 if sec6_q5_`loannum' <= td(31dec2024) & (loan_end_date_`loannum' >= td(01oct2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2025 Q1
    replace active_loan_2025_Q1 = 1 if sec6_q5_`loannum' <= td(31mar2025) & (loan_end_date_`loannum' >= td(01jan2025) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2025 Q2
    replace active_loan_2025_Q2 = 1 if sec6_q5_`loannum' <= td(30jun2025) & (loan_end_date_`loannum' >= td(01apr2025) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
}

cap drop active_loan_2025_Q3 active_loan_2025_Q4

* Apply labels to active loan variables
forval year = 2022/2025 {
    cap label values active_loan_`year'_Q1 active_loan_`year'_Q2 active_loan_`year'_Q3 active_loan_`year'_Q4 yesno
}



/* Create total unpaid loan variable */
ds sec6_q7_*
egen total_loan_remaining = rowtotal(`r(varlist)')  if any_loan == 1
label variable total_loan_remaining "Total unpaid principal across active loans (Rs.)"

/* Create log transformation (without winsorizing) */
gen log_total_loan_remaining = log(total_loan_remaining+1) if !missing(total_loan_remaining)
label variable log_total_loan_remaining "Log of Total unpaid loans"

/* Create quarterly unpaid loan variables */
forval year = 2022/2025 {
	cap drop total_loan_remaining_`year'_Q1 total_loan_remaining_`year'_Q2 total_loan_remaining_`year'_Q3 total_loan_remaining_`year'_Q4
    gen total_loan_remaining_`year'_Q1 = 0 if any_loan == 1
    gen total_loan_remaining_`year'_Q2 = 0 if any_loan == 1
    gen total_loan_remaining_`year'_Q3 = 0 if any_loan == 1
    gen total_loan_remaining_`year'_Q4 = 0 if any_loan == 1
    
    label var total_loan_remaining_`year'_Q1 "Total unpaid loan amount in `year' Q1 (Jan-Mar)"
    label var total_loan_remaining_`year'_Q2 "Total unpaid loan amount in `year' Q2 (Apr-Jun)"
    label var total_loan_remaining_`year'_Q3 "Total unpaid loan amount in `year' Q3 (Jul-Sep)"
    label var total_loan_remaining_`year'_Q4 "Total unpaid loan amount in `year' Q4 (Oct-Dec)"
}

sum loan_count, d
local max_loan = r(max)

/* For each loan and each quarter, add unpaid amounts if the loan is active in that period */
forvalues loannum = 1/`max_loan' {
    forval year = 2022/2025 {
        /* Calculate approximate end date based on loan duration */
        cap gen temp_end_date_`loannum' = sec6_q5_`loannum' + (sec6_q16_`loannum' * 30.44) if !missing(sec6_q5_`loannum') & !missing(sec6_q16_`loannum')
        
        /* Q1: Jan-Mar */
        /* A loan is active in a period if: 
           1. It started on or before the end of the period AND
           2. Either it's still active (sec6_q6_`loannum' == 1) OR 
              its end date (approximated from start + duration) is after the start of the period */
        
        replace total_loan_remaining_`year'_Q1 = total_loan_remaining_`year'_Q1 + sec6_q7_`loannum' ///
            if sec6_q5_`loannum' <= td(31mar`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01jan`year')) ///
            & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        
        /* Q2: Apr-Jun */
        replace total_loan_remaining_`year'_Q2 = total_loan_remaining_`year'_Q2 + sec6_q7_`loannum' ///
            if sec6_q5_`loannum' <= td(30jun`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01apr`year')) ///
            & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        
        /* Q3: Jul-Sep */
        if `year' < 2025 | (`year' == 2025) {
            replace total_loan_remaining_`year'_Q3 = total_loan_remaining_`year'_Q3 + sec6_q7_`loannum' ///
                if sec6_q5_`loannum' <= td(30sep`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01jul`year')) ///
                & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum') & `year' < 2025
        }
        
        /* Q4: Oct-Dec */
        if `year' < 2025 {
            replace total_loan_remaining_`year'_Q4 = total_loan_remaining_`year'_Q4 + sec6_q7_`loannum' ///
                if sec6_q5_`loannum' <= td(31dec`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01oct`year')) ///
                & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        }
    }
    
    cap drop temp_end_date_`loannum'
}

/* Create log transformations for quarterly variables */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    gen log_total_loan_remaining_`year'_Q1 = log(total_loan_remaining_`year'_Q1) ///
        if total_loan_remaining_`year'_Q1 > 0 & !missing(total_loan_remaining_`year'_Q1)
    
    label var log_total_loan_remaining_`year'_Q1 "Log of total unpaid loan in `year' Q1"
    
    /* Q2: Apr-Jun */
    gen log_total_loan_remaining_`year'_Q2 = log(total_loan_remaining_`year'_Q2) ///
        if total_loan_remaining_`year'_Q2 > 0 & !missing(total_loan_remaining_`year'_Q2)
    
    label var log_total_loan_remaining_`year'_Q2 "Log of total unpaid loan in `year' Q2"
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        gen log_total_loan_remaining_`year'_Q3 = log(total_loan_remaining_`year'_Q3) ///
            if total_loan_remaining_`year'_Q3 > 0 & !missing(total_loan_remaining_`year'_Q3)
        
        label var log_total_loan_remaining_`year'_Q3 "Log of total unpaid loan in `year' Q3"
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        gen log_total_loan_remaining_`year'_Q4 = log(total_loan_remaining_`year'_Q4) ///
            if total_loan_remaining_`year'_Q4 > 0 & !missing(total_loan_remaining_`year'_Q4)
        
        label var log_total_loan_remaining_`year'_Q4 "Log of total unpaid loan in `year' Q4"
    }
}

cap drop total_loan_remaining_2025_Q3 total_loan_remaining_2025_Q4



/*==============================================================================
                       Interest Rate Variables                            
==============================================================================*/

destring annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3, replace
sum annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3  //SurveyCTO generated Interest rate variable



/* Calculate quarterly interest rates for all loans with compounding */
sum loan_count, d
local max_loan = r(max)

forvalues i = 1/`max_loan' {
    gen q_int_`i' = .
    
    // Annual to quarterly with compounding: (1 + r/100)^(1/4) - 1) * 100
    replace q_int_`i' = (((1 + annual_interest_rate_`i'/100)^(1/4)) - 1) * 100 if sec6_q18_`i' == 1 & !missing(sec6_q17_`i')
    
    // Monthly to quarterly with compounding: (1 + r/100)^3 - 1) * 100
    replace q_int_`i' = (((1 + annual_interest_rate_`i'/100)^3) - 1) * 100 if sec6_q18_`i' == 2 & !missing(sec6_q17_`i')
    
    // Weekly to quarterly with compounding: (1 + r/100)^13 - 1) * 100
    replace q_int_`i' = (((1 + annual_interest_rate_`i'/100)^13) - 1) * 100 if sec6_q18_`i' == 3 & !missing(sec6_q17_`i')
    
    // Daily to quarterly with compounding: (1 + r/100)^91.25 - 1) * 100
    replace q_int_`i' = (((1 + annual_interest_rate_`i'/100)^91.25) - 1) * 100 if sec6_q18_`i' == 4 & !missing(sec6_q17_`i')
    
    label var q_int_`i' "Quarterly interest rate for loan `i' with compounding"
}

/* Convert annual interest rates to quarterly rates with compounding */

// Create quarterly interest rate variables
gen q_annual_interest_rate_1 = .
gen q_annual_interest_rate_2 = .
gen q_annual_interest_rate_3 = .

// Convert annual to quarterly: (1 + annual_rate/100)^(1/4) - 1) * 100
replace q_annual_interest_rate_1 = (((1 + annual_interest_rate_1/100)^(1/4)) - 1) * 100 if !missing(annual_interest_rate_1)
replace q_annual_interest_rate_2 = (((1 + annual_interest_rate_2/100)^(1/4)) - 1) * 100 if !missing(annual_interest_rate_2)
replace q_annual_interest_rate_3 = (((1 + annual_interest_rate_3/100)^(1/4)) - 1) * 100 if !missing(annual_interest_rate_3)

// Add labels
label var q_annual_interest_rate_1 "Quarterly interest rate 1 (converted from annual with compounding)"
label var q_annual_interest_rate_2 "Quarterly interest rate 2 (converted from annual with compounding)"
label var q_annual_interest_rate_3 "Quarterly interest rate 3 (converted from annual with compounding)"

// Check the results
sum q_annual_interest_rate_1 q_annual_interest_rate_2 q_annual_interest_rate_3






/* Calculate maximum quarterly interest rate across all loans */
egen max_qtr_int_rate = rowmax(q_annual_interest_rate_*)
label var max_qtr_int_rate "Maximum quarterly interest rate across all loans (%)"

sum loan_count, d
local max_loan = r(max)
/* Create formal and informal quarterly interest rate variables for each loan */
forvalues i = 1/`max_loan' {
    /* Create temporary variables for rates by type */
    gen temp_formal_qtr_int_`i' = q_annual_interest_rate_`i' if inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
    gen temp_informal_qtr_int_`i' = q_annual_interest_rate_`i' if inlist(sec6_q4_`i', 1, 3)
}

/* Calculate average quarterly interest rates by source */
egen avg_formal_qtr_int_rate = rowmean(temp_formal_qtr_int_*)
egen avg_informal_qtr_int_rate = rowmean(temp_informal_qtr_int_*)

label var avg_formal_qtr_int_rate "Average quarterly interest rate for formal loans (%)"
label var avg_informal_qtr_int_rate "Average quarterly interest rate for informal loans (%)"




cap drop temp_formal_qtr_int_* temp_informal_qtr_int_*

/*==============================================================================
                   Quarterly Interest Rate Variables by Time Period (2022-2025)                            
==============================================================================*/

/* Create quarterly interest rate variables by time period */
forval year = 2022/2025 {
    /* Initialize variables for each quarter */
    gen avg_qtr_int_rate_`year'_Q1 = . 
    gen avg_qtr_int_rate_`year'_Q2 = .
    gen avg_qtr_int_rate_`year'_Q3 = .
    gen avg_qtr_int_rate_`year'_Q4 = .
    gen formal_qtr_int_rate_`year'_Q1 = .
    gen formal_qtr_int_rate_`year'_Q2 = .
    gen formal_qtr_int_rate_`year'_Q3 = .
    gen formal_qtr_int_rate_`year'_Q4 = .
    gen informal_qtr_int_rate_`year'_Q1 = .
    gen informal_qtr_int_rate_`year'_Q2 = .
    gen informal_qtr_int_rate_`year'_Q3 = .
    gen informal_qtr_int_rate_`year'_Q4 = .
    
    /* Label variables */
    label var avg_qtr_int_rate_`year'_Q1 "Average quarterly interest rate in `year' Q1 (Jan-Mar)"
    label var avg_qtr_int_rate_`year'_Q2 "Average quarterly interest rate in `year' Q2 (Apr-Jun)"
    label var avg_qtr_int_rate_`year'_Q3 "Average quarterly interest rate in `year' Q3 (Jul-Sep)"
    label var avg_qtr_int_rate_`year'_Q4 "Average quarterly interest rate in `year' Q4 (Oct-Dec)"
    label var formal_qtr_int_rate_`year'_Q1 "Formal loan quarterly interest rate in `year' Q1"
    label var formal_qtr_int_rate_`year'_Q2 "Formal loan quarterly interest rate in `year' Q2"
    label var formal_qtr_int_rate_`year'_Q3 "Formal loan quarterly interest rate in `year' Q3"
    label var formal_qtr_int_rate_`year'_Q4 "Formal loan quarterly interest rate in `year' Q4"
    label var informal_qtr_int_rate_`year'_Q1 "Informal loan quarterly interest rate in `year' Q1"
    label var informal_qtr_int_rate_`year'_Q2 "Informal loan quarterly interest rate in `year' Q2"
    label var informal_qtr_int_rate_`year'_Q3 "Informal loan quarterly interest rate in `year' Q3"
    label var informal_qtr_int_rate_`year'_Q4 "Informal loan quarterly interest rate in `year' Q4"
}


sum loan_count, d
local max_loan = r(max)

/* Fill in quarterly interest rate variables based on loan start dates */
forvalues i = 1/`max_loan' {
    forval year = 2022/2025 {
        /* Q1: Jan-Mar */
        /* If loan was taken in this quarter, record its QUARTERLY interest rate */
        replace avg_qtr_int_rate_`year'_Q1 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i')
            
        /* Record by source type */
        replace formal_qtr_int_rate_`year'_Q1 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        replace informal_qtr_int_rate_`year'_Q1 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 1, 3)
        
        /* Q2: Apr-Jun */
        replace avg_qtr_int_rate_`year'_Q2 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i')
            
        replace formal_qtr_int_rate_`year'_Q2 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        replace informal_qtr_int_rate_`year'_Q2 = q_annual_interest_rate_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
            & inlist(sec6_q4_`i', 1, 3)
        
        /* Q3: Jul-Sep (only for years before 2025) */
        if `year' < 2025 {
            replace avg_qtr_int_rate_`year'_Q3 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i')
                
            replace formal_qtr_int_rate_`year'_Q3 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
                & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
                
            replace informal_qtr_int_rate_`year'_Q3 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
                & inlist(sec6_q4_`i', 1, 3)
        }
        
        /* Q4: Oct-Dec (only for years before 2025) */
        if `year' < 2025 {
            replace avg_qtr_int_rate_`year'_Q4 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i')
                
            replace formal_qtr_int_rate_`year'_Q4 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
                & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
                
            replace informal_qtr_int_rate_`year'_Q4 = q_annual_interest_rate_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(q_annual_interest_rate_`i') ///
                & inlist(sec6_q4_`i', 1, 3)
        }
    }
}



/*==============================================================================
                   Active Loan Quarterly Interest Burden Variables                            
==============================================================================*/

/* Create quarterly interest burden for active loans */
forval year = 2022/2025 {
    gen active_qtr_int_burden_`year'_Q1 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q2 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q3 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q4 = 0 if !missing(any_loan)
    
    label var active_qtr_int_burden_`year'_Q1 "Quarterly interest burden for active loans in `year' Q1"
    label var active_qtr_int_burden_`year'_Q2 "Quarterly interest burden for active loans in `year' Q2"
    label var active_qtr_int_burden_`year'_Q3 "Quarterly interest burden for active loans in `year' Q3"
    label var active_qtr_int_burden_`year'_Q4 "Quarterly interest burden for active loans in `year' Q4"
}
drop active_qtr_int_burden_2025_Q3 active_qtr_int_burden_2025_Q4

/* For each active loan in each quarter, add its quarterly interest rate burden */
sum loan_count, d
local max_loan = r(max)

forvalues loannum = 1/`max_loan' {
    forval year = 2022/2025 {
        /* Q1: Jan-Mar */
        replace active_qtr_int_burden_`year'_Q1 = active_qtr_int_burden_`year'_Q1 + q_annual_interest_rate_`loannum' ///
            if sec6_q5_`loannum' <= td(31mar`year') & (loan_end_date_`loannum' >= td(01jan`year') | sec6_q6_`loannum' == 1) ///
            & !missing(sec6_q5_`loannum') & !missing(q_annual_interest_rate_`loannum')
        
        /* Q2: Apr-Jun */
        replace active_qtr_int_burden_`year'_Q2 = active_qtr_int_burden_`year'_Q2 + q_annual_interest_rate_`loannum' ///
            if sec6_q5_`loannum' <= td(30jun`year') & (loan_end_date_`loannum' >= td(01apr`year') | sec6_q6_`loannum' == 1) ///
            & !missing(sec6_q5_`loannum') & !missing(q_annual_interest_rate_`loannum')
        
        /* Q3: Jul-Sep */
        if `year' < 2025 {
            replace active_qtr_int_burden_`year'_Q3 = active_qtr_int_burden_`year'_Q3 + q_annual_interest_rate_`loannum' ///
                if sec6_q5_`loannum' <= td(30sep`year') & (loan_end_date_`loannum' >= td(01jul`year') | sec6_q6_`loannum' == 1) ///
                & !missing(sec6_q5_`loannum') & !missing(q_annual_interest_rate_`loannum')
        }
        
        /* Q4: Oct-Dec */
        if `year' < 2025 {
            replace active_qtr_int_burden_`year'_Q4 = active_qtr_int_burden_`year'_Q4 + q_annual_interest_rate_`loannum' ///
                if sec6_q5_`loannum' <= td(31dec`year') & (loan_end_date_`loannum' >= td(01oct`year') | sec6_q6_`loannum' == 1) ///
                & !missing(sec6_q5_`loannum') & !missing(q_annual_interest_rate_`loannum')
        }
    }
}




















/*==============================================================================
                       Interest Rate Variables - CLEAN AVERAGING                          
==============================================================================*/

destring annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3, replace
sum annual_interest_rate_1 annual_interest_rate_2 annual_interest_rate_3

/* Calculate quarterly interest rates for all loans */
sum loan_count, d
local max_loan = r(max)

forvalues i = 1/`max_loan' {
    gen q_int_`i' = .
    
    // Convert annual to quarterly: (1 + annual_rate/100)^(1/4) - 1) * 100
    replace q_int_`i' = (((1 + annual_interest_rate_`i'/100)^(1/4)) - 1) * 100 ///
        if !missing(annual_interest_rate_`i')
    
    label var q_int_`i' "Quarterly interest rate for loan `i' with compounding"
}

/* Calculate maximum quarterly interest rate across all loans */
egen max_qtr_int_rate = rowmax(q_int_*)
label var max_qtr_int_rate "Maximum quarterly interest rate across all loans (%)"

/* Create formal and informal quarterly interest rate variables */
forvalues i = 1/`max_loan' {
    gen temp_formal_qtr_int_`i' = q_int_`i' if inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
    gen temp_informal_qtr_int_`i' = q_int_`i' if inlist(sec6_q4_`i', 1, 3)
}

egen avg_formal_qtr_int_rate = rowmean(temp_formal_qtr_int_*)
egen avg_informal_qtr_int_rate = rowmean(temp_informal_qtr_int_*)

label var avg_formal_qtr_int_rate "Average quarterly interest rate for formal loans (%)"
label var avg_informal_qtr_int_rate "Average quarterly interest rate for informal loans (%)"

/* Create log versions for regressions */
foreach var in max_qtr_int_rate avg_formal_qtr_int_rate avg_informal_qtr_int_rate {
    gen log_`var' = log(`var') if `var' > 0 & !missing(`var')
    label var log_`var' "Log of `var'"
}

cap drop temp_formal_qtr_int_* temp_informal_qtr_int_*

/*==============================================================================
           Average Quarterly Interest Rates by Time Period (2022-2025)                          
==============================================================================*/

/* Create temporary sum and count variables with shorter names */
forval year = 2022/2025 {
    /* Sum variables */
    gen s_all_`year'_q1 = 0
    gen s_all_`year'_q2 = 0  
    gen s_form_`year'_q1 = 0
    gen s_form_`year'_q2 = 0
    gen s_inf_`year'_q1 = 0
    gen s_inf_`year'_q2 = 0
    
    /* Count variables */
    gen c_all_`year'_q1 = 0
    gen c_all_`year'_q2 = 0
    gen c_form_`year'_q1 = 0
    gen c_form_`year'_q2 = 0
    gen c_inf_`year'_q1 = 0
    gen c_inf_`year'_q2 = 0
    
    if `year' < 2025 {
        gen s_all_`year'_q3 = 0
        gen s_all_`year'_q4 = 0
        gen s_form_`year'_q3 = 0
        gen s_form_`year'_q4 = 0
        gen s_inf_`year'_q3 = 0
        gen s_inf_`year'_q4 = 0
        gen c_all_`year'_q3 = 0
        gen c_all_`year'_q4 = 0
        gen c_form_`year'_q3 = 0
        gen c_form_`year'_q4 = 0
        gen c_inf_`year'_q3 = 0
        gen c_inf_`year'_q4 = 0
    }
}

/* Fill in sums and counts for each loan */
sum loan_count, d
local max_loan = r(max)

forvalues i = 1/`max_loan' {
    forval year = 2022/2025 {
        /* Q1: Jan-Mar */
        /* All loans */
        replace s_all_`year'_q1 = s_all_`year'_q1 + q_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i')
        replace c_all_`year'_q1 = c_all_`year'_q1 + 1 ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i')
            
        /* Formal loans */
        replace s_form_`year'_q1 = s_form_`year'_q1 + q_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
        replace c_form_`year'_q1 = c_form_`year'_q1 + 1 ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        /* Informal loans */
        replace s_inf_`year'_q1 = s_inf_`year'_q1 + q_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
        replace c_inf_`year'_q1 = c_inf_`year'_q1 + 1 ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(31mar`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
        
        /* Q2: Apr-Jun */
        replace s_all_`year'_q2 = s_all_`year'_q2 + q_int_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i')
        replace c_all_`year'_q2 = c_all_`year'_q2 + 1 ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i')
            
        replace s_form_`year'_q2 = s_form_`year'_q2 + q_int_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
        replace c_form_`year'_q2 = c_form_`year'_q2 + 1 ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        replace s_inf_`year'_q2 = s_inf_`year'_q2 + q_int_`i' ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
        replace c_inf_`year'_q2 = c_inf_`year'_q2 + 1 ///
            if sec6_q5_`i' >= td(01apr`year') & sec6_q5_`i' <= td(30jun`year') ///
            & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
        
        /* Q3 and Q4 for years before 2025 */
        if `year' < 2025 {
            /* Q3: Jul-Sep */
            replace s_all_`year'_q3 = s_all_`year'_q3 + q_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i')
            replace c_all_`year'_q3 = c_all_`year'_q3 + 1 ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i')
                
            replace s_form_`year'_q3 = s_form_`year'_q3 + q_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            replace c_form_`year'_q3 = c_form_`year'_q3 + 1 ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
                
            replace s_inf_`year'_q3 = s_inf_`year'_q3 + q_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
            replace c_inf_`year'_q3 = c_inf_`year'_q3 + 1 ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(30sep`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
            
            /* Q4: Oct-Dec */
            replace s_all_`year'_q4 = s_all_`year'_q4 + q_int_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i')
            replace c_all_`year'_q4 = c_all_`year'_q4 + 1 ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i')
                
            replace s_form_`year'_q4 = s_form_`year'_q4 + q_int_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            replace c_form_`year'_q4 = c_form_`year'_q4 + 1 ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
                
            replace s_inf_`year'_q4 = s_inf_`year'_q4 + q_int_`i' ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
            replace c_inf_`year'_q4 = c_inf_`year'_q4 + 1 ///
                if sec6_q5_`i' >= td(01oct`year') & sec6_q5_`i' <= td(31dec`year') ///
                & !missing(sec6_q5_`i') & !missing(q_int_`i') & inlist(sec6_q4_`i', 1, 3)
        }
    }
}

/* Create final average quarterly interest rate variables */
forval year = 2022/2025 {
    /* Q1 and Q2 for all years */
    gen avg_qtr_int_rate_`year'_Q1 = s_all_`year'_q1 / c_all_`year'_q1 if c_all_`year'_q1 > 0
    gen avg_qtr_int_rate_`year'_Q2 = s_all_`year'_q2 / c_all_`year'_q2 if c_all_`year'_q2 > 0
    gen formal_qtr_int_rate_`year'_Q1 = s_form_`year'_q1 / c_form_`year'_q1 if c_form_`year'_q1 > 0
    gen formal_qtr_int_rate_`year'_Q2 = s_form_`year'_q2 / c_form_`year'_q2 if c_form_`year'_q2 > 0
    gen informal_qtr_int_rate_`year'_Q1 = s_inf_`year'_q1 / c_inf_`year'_q1 if c_inf_`year'_q1 > 0
    gen informal_qtr_int_rate_`year'_Q2 = s_inf_`year'_q2 / c_inf_`year'_q2 if c_inf_`year'_q2 > 0
    
    /* Q3 and Q4 for years before 2025 */
    if `year' < 2025 {
        gen avg_qtr_int_rate_`year'_Q3 = s_all_`year'_q3 / c_all_`year'_q3 if c_all_`year'_q3 > 0
        gen avg_qtr_int_rate_`year'_Q4 = s_all_`year'_q4 / c_all_`year'_q4 if c_all_`year'_q4 > 0
        gen formal_qtr_int_rate_`year'_Q3 = s_form_`year'_q3 / c_form_`year'_q3 if c_form_`year'_q3 > 0
        gen formal_qtr_int_rate_`year'_Q4 = s_form_`year'_q4 / c_form_`year'_q4 if c_form_`year'_q4 > 0
        gen informal_qtr_int_rate_`year'_Q3 = s_inf_`year'_q3 / c_inf_`year'_q3 if c_inf_`year'_q3 > 0
        gen informal_qtr_int_rate_`year'_Q4 = s_inf_`year'_q4 / c_inf_`year'_q4 if c_inf_`year'_q4 > 0
    }
    
    /* Label variables */
    label var avg_qtr_int_rate_`year'_Q1 "Average quarterly interest rate in `year' Q1 (Jan-Mar)"
    label var avg_qtr_int_rate_`year'_Q2 "Average quarterly interest rate in `year' Q2 (Apr-Jun)"
    label var formal_qtr_int_rate_`year'_Q1 "Average formal loan quarterly rate in `year' Q1"
    label var formal_qtr_int_rate_`year'_Q2 "Average formal loan quarterly rate in `year' Q2"
    label var informal_qtr_int_rate_`year'_Q1 "Average informal loan quarterly rate in `year' Q1"
    label var informal_qtr_int_rate_`year'_Q2 "Average informal loan quarterly rate in `year' Q2"
    
    if `year' < 2025 {
        label var avg_qtr_int_rate_`year'_Q3 "Average quarterly interest rate in `year' Q3 (Jul-Sep)"
        label var avg_qtr_int_rate_`year'_Q4 "Average quarterly interest rate in `year' Q4 (Oct-Dec)"
        label var formal_qtr_int_rate_`year'_Q3 "Average formal loan quarterly rate in `year' Q3"
        label var formal_qtr_int_rate_`year'_Q4 "Average formal loan quarterly rate in `year' Q4"
        label var informal_qtr_int_rate_`year'_Q3 "Average informal loan quarterly rate in `year' Q3"
        label var informal_qtr_int_rate_`year'_Q4 "Average informal loan quarterly rate in `year' Q4"
    }
}

/* Clean up temporary variables */
drop s_* c_*

/*==============================================================================
                   Active Loan Quarterly Interest Burden Variables                            
==============================================================================*/

/* Keep your burden calculation - this one correctly sums across active loans */
forval year = 2022/2025 {
    gen active_qtr_int_burden_`year'_Q1 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q2 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q3 = 0 if !missing(any_loan)
    gen active_qtr_int_burden_`year'_Q4 = 0 if !missing(any_loan)
    
    label var active_qtr_int_burden_`year'_Q1 "Quarterly interest burden for active loans in `year' Q1"
    label var active_qtr_int_burden_`year'_Q2 "Quarterly interest burden for active loans in `year' Q2"
    label var active_qtr_int_burden_`year'_Q3 "Quarterly interest burden for active loans in `year' Q3"
    label var active_qtr_int_burden_`year'_Q4 "Quarterly interest burden for active loans in `year' Q4"
}
drop active_qtr_int_burden_2025_Q3 active_qtr_int_burden_2025_Q4

sum loan_count, d
local max_loan = r(max)

forvalues loannum = 1/`max_loan' {
    forval year = 2022/2025 {
        /* Q1: Jan-Mar */
        replace active_qtr_int_burden_`year'_Q1 = active_qtr_int_burden_`year'_Q1 + q_int_`loannum' ///
            if sec6_q5_`loannum' <= td(31mar`year') & (loan_end_date_`loannum' >= td(01jan`year') | sec6_q6_`loannum' == 1) ///
            & !missing(sec6_q5_`loannum') & !missing(q_int_`loannum')
        
        /* Q2: Apr-Jun */
        replace active_qtr_int_burden_`year'_Q2 = active_qtr_int_burden_`year'_Q2 + q_int_`loannum' ///
            if sec6_q5_`loannum' <= td(30jun`year') & (loan_end_date_`loannum' >= td(01apr`year') | sec6_q6_`loannum' == 1) ///
            & !missing(sec6_q5_`loannum') & !missing(q_int_`loannum')
        
        /* Q3: Jul-Sep */
        if `year' < 2025 {
            replace active_qtr_int_burden_`year'_Q3 = active_qtr_int_burden_`year'_Q3 + q_int_`loannum' ///
                if sec6_q5_`loannum' <= td(30sep`year') & (loan_end_date_`loannum' >= td(01jul`year') | sec6_q6_`loannum' == 1) ///
                & !missing(sec6_q5_`loannum') & !missing(q_int_`loannum')
        }
        
        /* Q4: Oct-Dec */
        if `year' < 2025 {
            replace active_qtr_int_burden_`year'_Q4 = active_qtr_int_burden_`year'_Q4 + q_int_`loannum' ///
                if sec6_q5_`loannum' <= td(31dec`year') & (loan_end_date_`loannum' >= td(01oct`year') | sec6_q6_`loannum' == 1) ///
                & !missing(sec6_q5_`loannum') & !missing(q_int_`loannum')
        }
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

/* Quarterly loan purpose indicators from 2022-2025 */
forval year = 2022/2025 {
    cap drop fixed_capital_loan_`year'_Q1 fixed_capital_loan_`year'_Q2 fixed_capital_loan_`year'_Q3 fixed_capital_loan_`year'_Q4
    cap drop working_capital_loan_`year'_Q1 working_capital_loan_`year'_Q2 working_capital_loan_`year'_Q3 working_capital_loan_`year'_Q4
    cap drop consumption_loan_`year'_Q1 consumption_loan_`year'_Q2 consumption_loan_`year'_Q3 consumption_loan_`year'_Q4
    
    gen fixed_capital_loan_`year'_Q1 = 0 if !missing(any_loan)
    gen fixed_capital_loan_`year'_Q2 = 0 if !missing(any_loan)
    gen fixed_capital_loan_`year'_Q3 = 0 if !missing(any_loan)
    gen fixed_capital_loan_`year'_Q4 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_Q1 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_Q2 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_Q3 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_Q4 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_Q1 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_Q2 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_Q3 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_Q4 = 0 if !missing(any_loan)
    
    label var fixed_capital_loan_`year'_Q1 "Took fixed capital loan in `year' Q1 (Jan-Mar)"
    label var fixed_capital_loan_`year'_Q2 "Took fixed capital loan in `year' Q2 (Apr-Jun)"
    label var fixed_capital_loan_`year'_Q3 "Took fixed capital loan in `year' Q3 (Jul-Sep)"
    label var fixed_capital_loan_`year'_Q4 "Took fixed capital loan in `year' Q4 (Oct-Dec)"
    label var working_capital_loan_`year'_Q1 "Took working capital loan in `year' Q1 (Jan-Mar)"
    label var working_capital_loan_`year'_Q2 "Took working capital loan in `year' Q2 (Apr-Jun)"
    label var working_capital_loan_`year'_Q3 "Took working capital loan in `year' Q3 (Jul-Sep)"
    label var working_capital_loan_`year'_Q4 "Took working capital loan in `year' Q4 (Oct-Dec)"
    label var consumption_loan_`year'_Q1 "Took consumption loan in `year' Q1 (Jan-Mar)"
    label var consumption_loan_`year'_Q2 "Took consumption loan in `year' Q2 (Apr-Jun)"
    label var consumption_loan_`year'_Q3 "Took consumption loan in `year' Q3 (Jul-Sep)"
    label var consumption_loan_`year'_Q4 "Took consumption loan in `year' Q4 (Oct-Dec)"
}

* Drop 2025 Q3 and Q4 variables for consistency (assuming we're in 2025 H1)
drop fixed_capital_loan_2025_Q3 fixed_capital_loan_2025_Q4 working_capital_loan_2025_Q3 working_capital_loan_2025_Q4 consumption_loan_2025_Q3 consumption_loan_2025_Q4

* Populate quarterly loan purpose indicators
sum loan_count, d
forval loannum = 1/`r(max)' {
    * 2022
    replace fixed_capital_loan_2022_Q1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2022_Q2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2022_Q3 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2022_Q4 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2022_Q1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2022_Q2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2022_Q3 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2022_Q4 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2022_Q1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(31mar2022) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2022_Q2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01apr2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2022_Q3 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(30sep2022) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2022_Q4 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01oct2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace fixed_capital_loan_2023_Q1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2023_Q2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2023_Q3 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2023_Q4 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2023_Q1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2023_Q2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2023_Q3 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2023_Q4 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2023_Q1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(31mar2023) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2023_Q2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01apr2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2023_Q3 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(30sep2023) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2023_Q4 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01oct2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace fixed_capital_loan_2024_Q1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2024_Q2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2024_Q3 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2024_Q4 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2024_Q1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2024_Q2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2024_Q3 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2024_Q4 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2024_Q1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(31mar2024) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2024_Q2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01apr2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2024_Q3 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(30sep2024) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2024_Q4 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01oct2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025 Q1 and Q2 (assuming we're in H1 2025)
    replace fixed_capital_loan_2025_Q1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2025_Q2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2025_Q1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2025_Q2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2025_Q1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(31mar2025) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2025_Q2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01apr2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

* Apply value labels to all quarterly variables
forval year = 2022/2025 {
    if `year' < 2025 {
        label values fixed_capital_loan_`year'_Q1 fixed_capital_loan_`year'_Q2 fixed_capital_loan_`year'_Q3 fixed_capital_loan_`year'_Q4 yesno
        label values working_capital_loan_`year'_Q1 working_capital_loan_`year'_Q2 working_capital_loan_`year'_Q3 working_capital_loan_`year'_Q4 yesno
        label values consumption_loan_`year'_Q1 consumption_loan_`year'_Q2 consumption_loan_`year'_Q3 consumption_loan_`year'_Q4 yesno
    }
    else {
        label values fixed_capital_loan_`year'_Q1 fixed_capital_loan_`year'_Q2 yesno
        label values working_capital_loan_`year'_Q1 working_capital_loan_`year'_Q2 yesno
        label values consumption_loan_`year'_Q1 consumption_loan_`year'_Q2 yesno
    }
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





/* Create quarterly loan amount by purpose variables from 2022-2025 */
forval year = 2022/2025 {
    gen fixed_capital_amount_`year'_Q1 = 0 if !missing(any_loan)
    gen fixed_capital_amount_`year'_Q2 = 0 if !missing(any_loan)
    gen fixed_capital_amount_`year'_Q3 = 0 if !missing(any_loan)
    gen fixed_capital_amount_`year'_Q4 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_Q1 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_Q2 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_Q3 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_Q4 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_Q1 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_Q2 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_Q3 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_Q4 = 0 if !missing(any_loan)
    
    label var fixed_capital_amount_`year'_Q1 "Fixed capital loan amount in `year' Q1 (Jan-Mar)"
    label var fixed_capital_amount_`year'_Q2 "Fixed capital loan amount in `year' Q2 (Apr-Jun)"
    label var fixed_capital_amount_`year'_Q3 "Fixed capital loan amount in `year' Q3 (Jul-Sep)"
    label var fixed_capital_amount_`year'_Q4 "Fixed capital loan amount in `year' Q4 (Oct-Dec)"
    label var working_capital_amount_`year'_Q1 "Working capital loan amount in `year' Q1 (Jan-Mar)"
    label var working_capital_amount_`year'_Q2 "Working capital loan amount in `year' Q2 (Apr-Jun)"
    label var working_capital_amount_`year'_Q3 "Working capital loan amount in `year' Q3 (Jul-Sep)"
    label var working_capital_amount_`year'_Q4 "Working capital loan amount in `year' Q4 (Oct-Dec)"
    label var consumption_amount_`year'_Q1 "Consumption loan amount in `year' Q1 (Jan-Mar)"
    label var consumption_amount_`year'_Q2 "Consumption loan amount in `year' Q2 (Apr-Jun)"
    label var consumption_amount_`year'_Q3 "Consumption loan amount in `year' Q3 (Jul-Sep)"
    label var consumption_amount_`year'_Q4 "Consumption loan amount in `year' Q4 (Oct-Dec)"
}

* Drop 2025 Q3 and Q4 variables for consistency (assuming we're in 2025 H1)
drop fixed_capital_amount_2025_Q3 fixed_capital_amount_2025_Q4 working_capital_amount_2025_Q3 working_capital_amount_2025_Q4 consumption_amount_2025_Q3 consumption_amount_2025_Q4

/* Process loan 1 by quarter */
/* Only one purpose selected */

/* Fixed capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
        
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Working capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
        
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Consumption */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
        
    /* Q2: Apr-Jun */
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Multiple purposes selected */
/* Fixed capital + Working capital (1 2) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Fixed capital + Consumption (1 3) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Working capital + Consumption (2 3) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* All three purposes (1 2 3) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_1_3 ///
        if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(31mar`year') & !missing(sec6_q5_1)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_1_3 ///
        if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
        & sec6_q5_1 >= td(01apr`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_1_3 ///
            if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(30sep`year') & !missing(sec6_q5_1)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_1_3 ///
            if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
            & sec6_q5_1 >= td(01oct`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Note: This code only covers Loan 1. For complete implementation, you would need to add similar 
   quarterly breakdown sections for Loan 2 and Loan 3, following the same pattern but using:
   - sec6_q15_2, sec6_q15a_2_*, sec6_q5_2, loan_2_* variables for Loan 2
   - sec6_q15_3, sec6_q15a_3_*, sec6_q5_3, loan_3_* variables for Loan 3
   
   The structure would be identical to Loan 1, just changing the variable suffixes from _1 to _2 and _3 respectively.
*/
/* Process loan 2 by quarter - same pattern as loan 1 */
/* Only one purpose selected */

/* Fixed capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
        
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Working capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
        
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Consumption */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
        
    /* Q2: Apr-Jun */
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Multiple purposes for loan 2 */
/* Fixed capital + Working capital (1 2) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Fixed capital + Consumption (1 3) for loan 2 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Working capital + Consumption (2 3) for loan 2 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* All three purposes (1 2 3) for loan 2 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_2_3 ///
        if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(31mar`year') & !missing(sec6_q5_2)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_2_3 ///
        if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
        & sec6_q5_2 >= td(01apr`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_2_3 ///
            if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(30sep`year') & !missing(sec6_q5_2)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_2_3 ///
            if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
            & sec6_q5_2 >= td(01oct`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}


/* Process loan 3 by quarter - same pattern as loans 1 and 2 */
/* Only one purpose selected */

/* Fixed capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
        
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Working capital */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
        
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Consumption */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
        
    /* Q2: Apr-Jun */
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Multiple purposes for loan 3 */
/* Fixed capital + Working capital (1 2) */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Fixed capital + Consumption (1 3) for loan 3 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Working capital + Consumption (2 3) for loan 3 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    /* Q2: Apr-Jun */
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* All three purposes (1 2 3) for loan 3 */
forval year = 2022/2025 {
    /* Q1: Jan-Mar */
    replace fixed_capital_amount_`year'_Q1 = fixed_capital_amount_`year'_Q1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_Q1 = working_capital_amount_`year'_Q1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q1 = consumption_amount_`year'_Q1 + sec6_q15a_3_3 ///
        if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(31mar`year') & !missing(sec6_q5_3)
    
    /* Q2: Apr-Jun */
    replace fixed_capital_amount_`year'_Q2 = fixed_capital_amount_`year'_Q2 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_Q2 = working_capital_amount_`year'_Q2 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_Q2 = consumption_amount_`year'_Q2 + sec6_q15a_3_3 ///
        if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
        & sec6_q5_3 >= td(01apr`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* Q3: Jul-Sep */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q3 = fixed_capital_amount_`year'_Q3 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_Q3 = working_capital_amount_`year'_Q3 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q3 = consumption_amount_`year'_Q3 + sec6_q15a_3_3 ///
            if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(30sep`year') & !missing(sec6_q5_3)
    }
    
    /* Q4: Oct-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_Q4 = fixed_capital_amount_`year'_Q4 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_Q4 = working_capital_amount_`year'_Q4 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_Q4 = consumption_amount_`year'_Q4 + sec6_q15a_3_3 ///
            if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
            & sec6_q5_3 >= td(01oct`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}





















global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"
global age_vars "e_age age_entrepreneur"


// Create baseline age variables before reshape
bysort enterprise_id: egen baseline_e_age = min(e_age)
bysort enterprise_id: egen baseline_age_entrepreneur = min(age_entrepreneur)

// Define control variable globals
global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "baseline_e_age baseline_age_entrepreneur marriage_age education_yrs std_digit_span risk_count"
global controls "$ent_d_contr $ent_c_contr"




keeporder enterprise_id DistrictCode District BlockCode Block PanchayatCode Panchayat treatment_285 cohort_new ///
	any_loan_* 	///
	loan_count_* 	///
	formal_loan_20* 	///
	informal_loan_20* 		///
	formal_loan_count_* 	///
	informal_loan_count_* 		///
	loan_amount_* 			///
	formal_amount_* 		///
	informal_amount_* 		///
	active_loan_* 			///
	total_loan_remaining_* 		///
	log_total_loan_remaining_* 		///
	avg_qtr_int_rate_* 				///	
	formal_qtr_int_rate_* 			///
	informal_qtr_int_rate_*			///
	active_qtr_int_burden* 			///
	fixed_capital_loan_20* 			///
	working_capital_loan_20* 		///
	consumption_loan_20* 			///
	fixed_capital_amount_20* 		///
	working_capital_amount_20* 		///
	consumption_amount_20*			///
	quarterly_disbursement_date sec1_q9 ent_running ipw _weight  $ent_d_contr $ent_c_contr $age_vars




// Create a consistent naming pattern: variablename_YYYYqQ format
forvalues y = 2022/2025 {
    forvalues q = 1/4 {
        
        // Handle any_loan variables (multiple possible formats)
        capture rename any_loan_`y'~`q' any_loan_`y'q`q'
        capture rename any_loan_`y'_Q`q' any_loan_`y'q`q'
        capture rename any_loan_`y'_q`q' any_loan_`y'q`q'
        
        // Handle loan_count variables
        capture rename loan_count_`y'~`q' loan_count_`y'q`q'
        capture rename loan_count_`y'_Q`q' loan_count_`y'q`q'
        capture rename loan_count_`y'_q`q' loan_count_`y'q`q'
        
        // Handle formal_loan variables
        capture rename formal_loan_`y'~`q' formal_loan_`y'q`q'
        capture rename formal_loan_`y'_Q`q' formal_loan_`y'q`q'
        capture rename formal_loan_`y'_q`q' formal_loan_`y'q`q'
        
        // Handle informal_loan variables
        capture rename informal_loan_`y'~`q' informal_loan_`y'q`q'
        capture rename informal_loan_`y'_Q`q' informal_loan_`y'q`q'
        capture rename informal_loan_`y'_q`q' informal_loan_`y'q`q'
        
        // Handle formal_loan_count variables
        capture rename formal_loan_count_`y'~`q' formal_loan_count_`y'q`q'
        capture rename formal_loan_count_`y'_Q`q' formal_loan_count_`y'q`q'
        capture rename formal_loan_count_`y'_q`q' formal_loan_count_`y'q`q'
        
        // Handle informal_loan_count variables
        capture rename informal_loan_count_`y'~`q' informal_loan_count_`y'q`q'
        capture rename informal_loan_count_`y'_Q`q' informal_loan_count_`y'q`q'
        capture rename informal_loan_count_`y'_q`q' informal_loan_count_`y'q`q'
        
        // Handle loan_amount variables
        capture rename loan_amount_`y'~`q' loan_amount_`y'q`q'
        capture rename loan_amount_`y'_Q`q' loan_amount_`y'q`q'
        capture rename loan_amount_`y'_q`q' loan_amount_`y'q`q'
        
        // Handle formal_amount variables
        capture rename formal_amount_`y'~`q' formal_amount_`y'q`q'
        capture rename formal_amount_`y'_Q`q' formal_amount_`y'q`q'
        capture rename formal_amount_`y'_q`q' formal_amount_`y'q`q'
        
        // Handle informal_amount variables
        capture rename informal_amount_`y'~`q' informal_amount_`y'q`q'
        capture rename informal_amount_`y'_Q`q' informal_amount_`y'q`q'
        capture rename informal_amount_`y'_q`q' informal_amount_`y'q`q'
        
        // Handle active_loan variables
        capture rename active_loan_`y'~`q' active_loan_`y'q`q'
        capture rename active_loan_`y'_Q`q' active_loan_`y'q`q'
        capture rename active_loan_`y'_q`q' active_loan_`y'q`q'
        
        // Handle total_loan_remaining variables
        capture rename total_loan_remaining_`y'~`q' total_loan_remaining_`y'q`q'
        capture rename total_loan_remaining_`y'_Q`q' total_loan_remaining_`y'q`q'
        capture rename total_loan_remaining_`y'_q`q' total_loan_remaining_`y'q`q'
        
        // Handle log_total_loan_remaining variables
        capture rename log_total_loan_remaining_`y'~`q' log_total_loan_remaining_`y'q`q'
        capture rename log_total_loan_remaining_`y'_Q`q' log_total_loan_remaining_`y'q`q'
        capture rename log_total_loan_remaining_`y'_q`q' log_total_loan_remaining_`y'q`q'
        
        // Handle avg_qtr_int_rate variables
        capture rename avg_qtr_int_rate_`y'~`q' avg_qtr_int_rate_`y'q`q'
        capture rename avg_qtr_int_rate_`y'_Q`q' avg_qtr_int_rate_`y'q`q'
        capture rename avg_qtr_int_rate_`y'_q`q' avg_qtr_int_rate_`y'q`q'
        
        // Handle formal_qtr_int_rate variables
        capture rename formal_qtr_int_rate_`y'~`q' formal_qtr_int_rate_`y'q`q'
        capture rename formal_qtr_int_rate_`y'_Q`q' formal_qtr_int_rate_`y'q`q'
        capture rename formal_qtr_int_rate_`y'_q`q' formal_qtr_int_rate_`y'q`q'
        
        // Handle informal_qtr_int_rate variables
        capture rename informal_qtr_int_rate_`y'~`q' informal_qtr_int_rate_`y'q`q'
        capture rename informal_qtr_int_rate_`y'_Q`q' informal_qtr_int_rate_`y'q`q'
        capture rename informal_qtr_int_rate_`y'_q`q' informal_qtr_int_rate_`y'q`q'
        
        // Handle active_qtr_int_burden variables
        capture rename active_qtr_int_burden_`y'~`q' active_qtr_int_burden_`y'q`q'
        capture rename active_qtr_int_burden_`y'_Q`q' active_qtr_int_burden_`y'q`q'
        capture rename active_qtr_int_burden_`y'_q`q' active_qtr_int_burden_`y'q`q'
        
        // Handle fixed_capital_loan variables
        capture rename fixed_capital_loan_`y'~`q' fixed_capital_loan_`y'q`q'
        capture rename fixed_capital_loan_`y'_Q`q' fixed_capital_loan_`y'q`q'
        capture rename fixed_capital_loan_`y'_q`q' fixed_capital_loan_`y'q`q'
        
        // Handle working_capital_loan variables
        capture rename working_capital_loan_`y'~`q' working_capital_loan_`y'q`q'
        capture rename working_capital_loan_`y'_Q`q' working_capital_loan_`y'q`q'
        capture rename working_capital_loan_`y'_q`q' working_capital_loan_`y'q`q'
        
        // Handle consumption_loan variables
        capture rename consumption_loan_`y'~`q' consumption_loan_`y'q`q'
        capture rename consumption_loan_`y'_Q`q' consumption_loan_`y'q`q'
        capture rename consumption_loan_`y'_q`q' consumption_loan_`y'q`q'
        
        // Handle fixed_capital_amount variables
        capture rename fixed_capital_amount_`y'~`q' fixed_capital_amount_`y'q`q'
        capture rename fixed_capital_amount_`y'_Q`q' fixed_capital_amount_`y'q`q'
        capture rename fixed_capital_amount_`y'_q`q' fixed_capital_amount_`y'q`q'
        
        // Handle working_capital_amount variables
        capture rename working_capital_amount_`y'~`q' working_capital_amount_`y'q`q'
        capture rename working_capital_amount_`y'_Q`q' working_capital_amount_`y'q`q'
        capture rename working_capital_amount_`y'_q`q' working_capital_amount_`y'q`q'
        
        // Handle consumption_amount variables
        capture rename consumption_amount_`y'~`q' consumption_amount_`y'q`q'
        capture rename consumption_amount_`y'_Q`q' consumption_amount_`y'q`q'
        capture rename consumption_amount_`y'_q`q' consumption_amount_`y'q`q'
    }
}


keep if ent_running == 1



// Reshape the quarterly data to long format using standardized naming
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
    active_loan_ ///
    total_loan_remaining_ ///
    log_total_loan_remaining_ ///
    avg_qtr_int_rate_ ///
    formal_qtr_int_rate_ ///
    informal_qtr_int_rate_ ///
    active_qtr_int_burden_ ///
    fixed_capital_loan_ ///
    fixed_capital_amount_ ///
    working_capital_loan_ ///
    working_capital_amount_ ///
    consumption_loan_ ///
    consumption_amount_ ///
    , i(enterprise_id) j(time_period) string


// Extract year and quarter from time_period string (format: YYYYqQ)
gen year = real(substr(time_period, 1, 4))
gen quarter = real(substr(time_period, 6, 1))

// Create quarterly time variable
gen time = yq(year, quarter)
format time %tq

// Clean up
drop time_period year quarter


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
rename active_loan_ active_loan
rename total_loan_remaining_ loan_remain
rename log_total_loan_remaining_ log_loan_remain
rename avg_qtr_int_rate_ avg_int_rate
rename formal_qtr_int_rate_ formal_int_rate
rename informal_qtr_int_rate_ informal_int_rate
rename active_qtr_int_burden_ active_int_burden
rename fixed_capital_loan_ fixed_capital_loan
rename fixed_capital_amount_ fixed_capital_amount
rename working_capital_loan_ working_capital_loan
rename working_capital_amount_ working_capital_amount
rename consumption_loan_ consumption_loan
rename consumption_amount_ consumption_amount


// Encode enterprise ID for xtset
encode enterprise_id, gen(enterprise_id_num)

// Set panel data structure
xtset enterprise_id_num time



// Create first treatment time (convert to quarterly if needed)
gen first_treat = quarterly_disbursement_date
format first_treat %tq

// Create treatment indicator
gen treated = !missing(first_treat)

// Create relative time variable (time relative to treatment)
gen rel_time = time - first_treat if treated == 1
replace rel_time = 0 if treated == 0

// Create post-treatment indicator
gen post = (time >= first_treat) & treated == 1

// Create group variable for csdid command (0 for never-treated)
gen gvar = first_treat
recode gvar (. = 0)
format gvar %tq

// Create never-treated indicator
gen never_treat = (first_treat == .)

// Create last cohort indicator for Sun-Abraham estimator
sum first_treat
gen last_cohort = (first_treat == r(max)) | never_treat

// ============================================================================
// STEP 9: CREATE ADDITIONAL USEFUL VARIABLES
// ============================================================================

// Create block-level identifier for clustering
encode BlockCode, gen(block_id)

// Create time-varying indicators
gen year_from_time = year(dofq(time))
gen quarter_from_time = quarter(dofq(time))

// Create lead/lag indicators for event study
forvalues i = 1/8 {
    gen lead`i' = (rel_time == `i') if treated == 1
    gen lag`i' = (rel_time == -`i') if treated == 1
}

// Create treatment event indicator (period of treatment)
gen treat_event = (rel_time == 0) if treated == 1


label variable time "Quarter (quarterly time variable)"
label variable treated "Treatment indicator (1=ever treated)"
label variable first_treat "First treatment quarter"
label variable rel_time "Quarters relative to treatment"
label variable post "Post-treatment indicator"
label variable gvar "Treatment group (0=never treated)"
label variable never_treat "Never treated indicator"
label variable last_cohort "Last cohort indicator"
label variable block_id "Block identifier"
label variable baseline_e_age "Baseline enterprise age"
label variable baseline_age_entrepreneur "Baseline entrepreneur age"


bysort enterprise_id_num : drop if time == tq(2025q3) | time == tq(2025q4)
bysort enterprise_id_num : replace active_int_burden = . if active_loan == 0



gen asi_active_int_burden = asinh(active_int_burden)
zscore active_int_burden
gen log_active_int_burden = log(active_int_burden)


foreach var in loan_count formal_loan informal_loan formal_count informal_count loan_amount formal_amount informal_amount fixed_capital_amount working_capital_amount consumption_amount {
	gen log_`var' = log(`var'+1)
}



csdid log_active_int_burden, ivar(enterprise_id_num) time(time) gvar(gvar) notyet 
estat all
estat event, window(-4 8) estore(cs_log_active_int_burden)


csdid log_loan_remain, ivar(enterprise_id_num) time(time) gvar(gvar) notyet 
estat all
estat event, window(-4 8) estore(cs_log_loan_remain)


















/*==============================================================================
                    STAGGERED DID - FINANCIAL OUTCOMES
==============================================================================*/
eststo clear

foreach Y in log_active_int_burden log_loan_remain {
    // Run csdid once and save RIF file
    csdid `Y' if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet method(dripw) saverif(_temp_`Y') replace
    local n_obs = e(N)
    
    // Store event study results
    estat event, window(-4 8) post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    if "`Y'" == "log_active_int_burden" {
        eststo int_event
    }
    else if "`Y'" == "log_loan_remain" {
        eststo loan_event  
    }
    
    // Store group-specific results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats group, post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    if "`Y'" == "log_active_int_burden" {
        eststo int_group
    }
    else if "`Y'" == "log_loan_remain" {
        eststo loan_group  
    }
    restore
    
    // Store calendar results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats calendar, post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    if "`Y'" == "log_active_int_burden" {
        eststo int_cal
    }
    else if "`Y'" == "log_loan_remain" {
        eststo loan_cal  
    }
    restore
    
    // Store simple ATT results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats simple, post
    estadd scalar N = `n_obs' 
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    if "`Y'" == "log_active_int_burden" {
        eststo int_att
    }
    else if "`Y'" == "log_loan_remain" {
        eststo loan_att  
    }
    restore
    
    // Clean up temporary RIF file
    erase _temp_`Y'.dta
}

/*==============================================================================
           MAIN RESULTS TABLE (Panel A: ATT + Panel B: Groups)
==============================================================================*/

// Panel A: Simple ATT Effects
#delimit ;
esttab int_att loan_att using "$Scratch/Loan_DiD.rtf", 
    replace 
    label 
    nonumbers
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table: Impact of Matching Grant Program on Financial Outcomes") 
    mtitles("Interest Burden (Log)" "Indebtedness (Log)") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    posthead("Panel A: Average Treatment Effects")
    addnotes("Panel A shows overall Average Treatment Effects (ATT).") ;
#delimit cr

// Panel B: Group-Specific Effects
#delimit ;
esttab int_group loan_group using "$Scratch/Loan_DiD.rtf", 
    append 
    label 
    nonumbers 
    nomtitles
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    posthead("Panel B: Treatment Effects by Cohort")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Panel B shows treatment effects by first treatment quarter." 
             "Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
             "Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. Outcomes are in log form.") ;
#delimit cr

/*==============================================================================
                    TABLE: Simple ATT Effects (Individual)
==============================================================================*/
#delimit ;
esttab int_att loan_att using "$Scratch/Financial_ATT.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Average Treatment Effects on Financial Outcomes") 
    mtitles("Interest Burden (Log)" "Indebtedness (Log)") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. Outcomes are in log form.") ;
#delimit cr

/*==============================================================================
                    TABLE: GROUP-SPECIFIC EFFECTS (Individual)
==============================================================================*/
#delimit ;
esttab int_group loan_group using "$Scratch/Financial_Group_Effects.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Treatment Effects on Financial Outcomes by Cohort") 
    mtitles("Interest Burden (Log)" "Indebtedness (Log)") 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Each cohort represents enterprises first treated in that quarter." 
             "Quarter codes: 251=2022Q3, 252=2022Q4, 253=2023Q1, 254=2023Q2, 255=2023Q3, 256=2023Q4, 257=2024Q1") ;
#delimit cr

/*==============================================================================
                    TABLE: EVENT STUDY TABLE 
==============================================================================*/
#delimit ;
esttab int_event loan_event using "$Scratch/Loan_Event_Study.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Dynamic Treatment Effects on Financial Outcomes") 
    mtitles("(1) Interest Burden (Log)" "(2) Indebtedness (Log)") 
    keep(Pre_avg Post_avg Tm* Tp*)
    order(Pre_avg Post_avg Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4 Tp5 Tp6 Tp7 Tp8)
    varlabels(Pre_avg "Pre-treatment average"
              Post_avg "Post-treatment average"
              Tm4 "t-4"
              Tm3 "t-3" 
              Tm2 "t-2"
              Tm1 "t-1"
              Tp0 "t=0"
              Tp1 "t+1"
              Tp2 "t+2"
              Tp3 "t+3"
              Tp4 "t+4"
              Tp5 "t+5"
              Tp6 "t+6"
              Tp7 "t+7"
              Tp8 "t+8")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Controls" "Enterprise FE" "Time FE"))
    addnotes("Notes: Event study coefficients from Callaway and Sant'Anna (2021) estimator."
             "t=0 is the quarter of first grant receipt. Outcomes are in log form."
             "Standard errors clustered by enterprise. *** p<0.01, ** p<0.05, * p<0.1") ;
#delimit cr

/*==============================================================================
                    TABLE: CALENDAR EFFECTS TABLE (Optional)
==============================================================================*/
#delimit ;
esttab int_cal loan_cal using "$Scratch/Financial_Calendar_Effects.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Calendar Time Effects on Financial Outcomes") 
    mtitles("Interest Burden (Log)" "Indebtedness (Log)") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Calendar time effects show treatment effects by calendar period." 
             "Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator.") ;
#delimit cr


/*==============================================================================
                    EVENT STUDY PLOTS
==============================================================================*/

// Plot for Interest Burden
estimates restore int_event
event_plot, default_look ///
    graph_opt(xtitle("Quarters relative to treatment") ytitle("Interest Burden (Log)") ///
    title("Effect of Matching Grant on Interest Burden", size(medlarge)) ///
    xlabel(-4(1)8) ylabel(, angle(horizontal) format(%9.2f)) ///
    xline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    yline(0, lcolor(gs10) lpattern(solid) lwidth(thin)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    legend(order(1 "Pre-treatment" 3 "Post-treatment") position(6) rows(1) size(medium)) ///
    name(interest_burden_plot, replace)) ///
    stub_lag(Tp#) stub_lead(Tm#) ///
    lead_opt(color(maroon) lwidth(thick) msymbol(triangle) msize(medium)) ///
    lead_ci_opt(color(maroon%30) lwidth(none)) ///
    lag_opt(color(forest_green) lwidth(thick) msymbol(circle) msize(medium)) ///
    lag_ci_opt(color(forest_green%30) lwidth(none)) ///
    alpha(0.05)
graph export "$Scratch/interest_burden_event_study.png", replace



// Plot for Indebtedness
estimates restore loan_event
event_plot, default_look ///
    graph_opt(xtitle("Quarters relative to treatment") ytitle("Indebtedness (Log)") ///
    title("Effect of Matching Grant on Indebtedness", size(medlarge)) ///
    xlabel(-4(1)8) ylabel(, angle(horizontal) format(%9.2f)) ///
    xline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    yline(0, lcolor(gs10) lpattern(solid) lwidth(thin)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    legend(order(1 "Pre-treatment" 3 "Post-treatment") position(6) rows(1) size(medium)) ///
    name(indebtedness_plot, replace)) ///
    stub_lag(Tp#) stub_lead(Tm#) ///
    lead_opt(color(maroon) lwidth(thick) msymbol(triangle) msize(medium)) ///
    lead_ci_opt(color(maroon%30) lwidth(none)) ///
    lag_opt(color(forest_green) lwidth(thick) msymbol(circle) msize(medium)) ///
    lag_ci_opt(color(forest_green%30) lwidth(none)) ///
    alpha(0.05)
graph export "$Scratch/indebtedness_event_study.png", replace