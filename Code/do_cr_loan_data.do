




count if sec6_q1 == 1 & sec6_q3 == 0
replace sec6_q1 = 0 if sec6_q3 == 0



/*==============================================================================
                    Loan Variables on Half-Yearly Basis                       
==============================================================================*/

** Basic loan indicator
gen any_loan = (sec6_q1 == 1) if !missing(sec6_q1)
label var any_loan "Has the enterprise taken any loans in last 5 years"
label define yesno 0 "No" 1 "Yes", replace
label values any_loan yesno

/* Create indicators for any loan in each half-year */
* Initialize half-yearly variables (H1: Jan-Jun, H2: Jul-Dec)
forval year = 2020/2025 {
	cap drop any_loan_`year'_H1 any_loan_`year'_H2
    gen any_loan_`year'_H1 = 0 if !missing(any_loan)
    gen any_loan_`year'_H2 = 0 if !missing(any_loan)
    
    label var any_loan_`year'_H1 "Any loan taken in `year' H1 (Jan-Jun)"
    label var any_loan_`year'_H2 "Any loan taken in `year' H2 (Jul-Dec)"
}
* Populate half-yearly loan indicators
forvalues loannum = 1/3 {
    * 2020
    replace any_loan_2020_H1 = 1 if sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace any_loan_2020_H2 = 1 if sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    * 2021
    replace any_loan_2021_H1 = 1 if sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace any_loan_2021_H2 = 1 if sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    * 2022
    replace any_loan_2022_H1 = 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace any_loan_2022_H2 = 1 if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace any_loan_2023_H1 = 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace any_loan_2023_H2 = 1 if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace any_loan_2024_H1 = 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace any_loan_2024_H2 = 1 if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace any_loan_2025_H1 = 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

forval year = 2020/2025 {
    label values any_loan_`year'_H1 any_loan_`year'_H2 yesno
}
cap drop any_loan_2025_H2



/* Loan count variables */
* Total loan count
clonevar loan_count = sec6_q3
replace loan_count = 0 if loan_count == . & any_loan == 0						//Those who have not applied any loan that means they have 0 loans, so replace them with 0 is justified. 
la var loan_count "Number of loans taken in last 5 years"

* Count loans in each half-year of 2020 - 2025
forval year = 2020/2025 {
	cap drop loan_count_`year'_H1 loan_count_`year'_H2
    gen loan_count_`year'_H1 = 0 if !missing(any_loan)
    gen loan_count_`year'_H2 = 0 if !missing(any_loan)
    
    label var loan_count_`year'_H1 "Number of loans taken in `year' H1 (Jan-Jun)"
    label var loan_count_`year'_H2 "Number of loans taken in `year' H2 (Jul-Dec)"
}

forvalues loannum = 1/3 {
    * 2020
    replace loan_count_2020_H1 = loan_count_2020_H1 + 1 if sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace loan_count_2020_H2 = loan_count_2020_H2 + 1 if sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    * 2021
    replace loan_count_2021_H1 = loan_count_2021_H1 + 1 if sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace loan_count_2021_H2 = loan_count_2021_H2 + 1 if sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    * 2022
    replace loan_count_2022_H1 = loan_count_2022_H1 + 1 if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace loan_count_2022_H2 = loan_count_2022_H2 + 1 if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace loan_count_2023_H1 = loan_count_2023_H1 + 1 if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace loan_count_2023_H2 = loan_count_2023_H2 + 1 if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace loan_count_2024_H1 = loan_count_2024_H1 + 1 if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace loan_count_2024_H2 = loan_count_2024_H2 + 1 if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace loan_count_2025_H1 = loan_count_2025_H1 + 1 if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}
drop loan_count_2025_H2 														//This time period does not exist. 



graph bar (mean) any_loan_2020_H1 any_loan_2020_H2 any_loan_2021_H1 any_loan_2021_H2 ///
    any_loan_2022_H1 any_loan_2022_H2 any_loan_2023_H1 any_loan_2023_H2 ///
    any_loan_2024_H1 any_loan_2024_H2 any_loan_2025_H1, ///
    ytitle("Proportion of Enterprises with Loans") ///
    title("Half-Yearly Loan Penetration (2020-2025)") ///
    note("Source: Enterprise Survey Data") ///
    blabel(bar, format(%9.2f)) ///
    legend(label(1 "2020 H1") label(2 "2020 H2") label(3 "2021 H1") ///
           label(4 "2021 H2") label(5 "2022 H1") label(6 "2022 H2") ///
           label(7 "2023 H1") label(8 "2023 H2") label(9 "2024 H1") ///
           label(10 "2024 H2") label(11 "2025 H1") size(small) rows(2))
           






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

* Formal and informal loan indicators by half-year
forval year = 2020/2025 {
	cap drop formal_loan_`year'_H1 formal_loan_`year'_H2 informal_loan_`year'_H1 informal_loan_`year'_H2
    gen formal_loan_`year'_H1 = 0 if !missing(any_loan)
    gen formal_loan_`year'_H2 = 0 if !missing(any_loan)
    gen informal_loan_`year'_H1 = 0 if !missing(any_loan)
    gen informal_loan_`year'_H2 = 0 if !missing(any_loan)
    
    label var formal_loan_`year'_H1 "Has formal loan in `year' H1 (Jan-Jun)"
    label var formal_loan_`year'_H2 "Has formal loan in `year' H2 (Jul-Dec)"
    label var informal_loan_`year'_H1 "Has informal loan in `year' H1 (Jan-Jun)"
    label var informal_loan_`year'_H2 "Has informal loan in `year' H2 (Jul-Dec)"
}

forvalues loannum = 1/3 {
    * 2020
    replace formal_loan_2020_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace formal_loan_2020_H2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    replace informal_loan_2020_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace informal_loan_2020_H2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    * 2021
    replace formal_loan_2021_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace formal_loan_2021_H2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    replace informal_loan_2021_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace informal_loan_2021_H2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    * 2022
    replace formal_loan_2022_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_2022_H2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_2022_H2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_2023_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace formal_loan_2023_H2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_2023_H2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_2024_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_2024_H2 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_2024_H2 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_2025_H1 = 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_2025_H1 = 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

drop formal_loan_2025_H2 informal_loan_2025_H2

forval year = 2020/2025 {
    cap label values formal_loan_`year'_H1 formal_loan_`year'_H2 informal_loan_`year'_H1 informal_loan_`year'_H2 yesno
}


/* Formal vs informal loan counts */
* Overall formal/informal loan counts
gen formal_loan_count = 0 if any_loan == 1 & !missing(any_loan)
gen informal_loan_count = 0 if any_loan == 1 & !missing(any_loan)

forvalues loannum = 1/3 {
    replace formal_loan_count = formal_loan_count + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum')
    replace informal_loan_count = informal_loan_count + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum')
}

* Those who have not applied the loan thwy will have 0 formal amd informal loans
replace formal_loan_count = 0 if formal_loan_count == . & loan_count == 0
replace informal_loan_count = 0 if informal_loan_count == . & loan_count == 0

label var formal_loan_count "Number of formal loans in last 5 years"
label var informal_loan_count "Number of informal loans in last 5 years"

* Formal and informal loan counts by half-year
forval year = 2020/2025 {
	cap drop formal_loan_count_`year'_H1 formal_loan_count_`year'_H2 informal_loan_count_`year'_H1 informal_loan_count_`year'_H2
    gen formal_loan_count_`year'_H1 = 0 if !missing(any_loan)
    gen formal_loan_count_`year'_H2 = 0 if !missing(any_loan)
    gen informal_loan_count_`year'_H1 = 0 if !missing(any_loan)
    gen informal_loan_count_`year'_H2 = 0 if !missing(any_loan)
    
    label var formal_loan_count_`year'_H1 "Number of formal loans in `year' H1 (Jan-Jun)"
    label var formal_loan_count_`year'_H2 "Number of formal loans in `year' H2 (Jul-Dec)"
    label var informal_loan_count_`year'_H1 "Number of informal loans in `year' H1 (Jan-Jun)"
    label var informal_loan_count_`year'_H2 "Number of informal loans in `year' H2 (Jul-Dec)"
}

* Populate half-yearly formal/informal loan counts
forvalues loannum = 1/3 {
    * 2020
    replace formal_loan_count_2020_H1 = formal_loan_count_2020_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2020_H2 = formal_loan_count_2020_H2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2020_H1 = informal_loan_count_2020_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2020_H2 = informal_loan_count_2020_H2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    * 2021
    replace formal_loan_count_2021_H1 = formal_loan_count_2021_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2021_H2 = formal_loan_count_2021_H2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2021_H1 = informal_loan_count_2021_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2021_H2 = informal_loan_count_2021_H2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    * Continue for 2022-2025 (same pattern)
    * 2022
    replace formal_loan_count_2022_H1 = formal_loan_count_2022_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2022_H2 = formal_loan_count_2022_H2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022_H1 = informal_loan_count_2022_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2022_H2 = informal_loan_count_2022_H2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace formal_loan_count_2023_H1 = formal_loan_count_2023_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
	* 2023 (continued)
    replace formal_loan_count_2023_H2 = formal_loan_count_2023_H2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023_H1 = informal_loan_count_2023_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2023_H2 = informal_loan_count_2023_H2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace formal_loan_count_2024_H1 = formal_loan_count_2024_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace formal_loan_count_2024_H2 = formal_loan_count_2024_H2 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024_H1 = informal_loan_count_2024_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2024_H2 = informal_loan_count_2024_H2 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025
    replace formal_loan_count_2025_H1 = formal_loan_count_2025_H1 + 1 if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    replace informal_loan_count_2025_H1 = informal_loan_count_2025_H1 + 1 if inlist(sec6_q4_`loannum', 1, 3) & !missing(sec6_q4_`loannum') & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}
drop formal_loan_count_2025_H2 informal_loan_count_2025_H2




*Total loan applied
ds sec6_q8_* 
egen total_loan_applied = rowtotal(`r(varlist)') if any_loan != .
la var total_loan_applied "Total loan amount requested in last 5 years (Rs.)"

*total loan recieved
ds sec6_q9_*
egen total_loan_received = rowtotal(`r(varlist)') if any_loan != .
label variable total_loan_received "Total loan amount received in last 5 years (Rs.)"




/* Half-yearly Loan amount variables */
* Create loan amount variables by half-year
forval year = 2020/2025 {
    gen loan_amount_`year'_H1 = 0 if !missing(any_loan)
    gen loan_amount_`year'_H2 = 0 if !missing(any_loan)
    gen formal_amount_`year'_H1 = 0 if !missing(any_loan)
    gen formal_amount_`year'_H2 = 0 if !missing(any_loan)
    gen informal_amount_`year'_H1 = 0 if !missing(any_loan)
    gen informal_amount_`year'_H2 = 0 if !missing(any_loan)
    
    label var loan_amount_`year'_H1 "Total loan amount received in `year' H1 (Jan-Jun)"
    label var loan_amount_`year'_H2 "Total loan amount received in `year' H2 (Jul-Dec)"
    label var formal_amount_`year'_H1 "Formal loan amount received in `year' H1 (Jan-Jun)"
    label var formal_amount_`year'_H2 "Formal loan amount received in `year' H2 (Jul-Dec)"
    label var informal_amount_`year'_H1 "Informal loan amount received in `year' H1 (Jan-Jun)"
    label var informal_amount_`year'_H2 "Informal loan amount received in `year' H2 (Jul-Dec)"
}
drop loan_amount_2025_H2 informal_amount_2025_H2 formal_amount_2025_H2

forvalues loannum = 1/3 {
    * 2020 amounts
    replace loan_amount_2020_H1 = loan_amount_2020_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2020_H2 = loan_amount_2020_H2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2020_H1 = formal_amount_2020_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2020_H2 = formal_amount_2020_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2020_H1 = informal_amount_2020_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2020_H2 = informal_amount_2020_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    
    * 2021 amounts
    replace loan_amount_2021_H1 = loan_amount_2021_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2021_H2 = loan_amount_2021_H2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2021_H1 = formal_amount_2021_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2021_H2 = formal_amount_2021_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2021_H1 = informal_amount_2021_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2021_H2 = informal_amount_2021_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    
    * 2022 amounts
    replace loan_amount_2022_H1 = loan_amount_2022_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2022_H2 = loan_amount_2022_H2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2022_H1 = formal_amount_2022_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2022_H2 = formal_amount_2022_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2022_H1 = informal_amount_2022_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2022_H2 = informal_amount_2022_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    
    * 2023 amounts
    replace loan_amount_2023_H1 = loan_amount_2023_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2023_H2 = loan_amount_2023_H2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2023_H1 = formal_amount_2023_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2023_H2 = formal_amount_2023_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2023_H1 = informal_amount_2023_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2023_H2 = informal_amount_2023_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    

    * 2024 amounts
    replace loan_amount_2024_H1 = loan_amount_2024_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace loan_amount_2024_H2 = loan_amount_2024_H2 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2024_H1 = formal_amount_2024_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace formal_amount_2024_H2 = formal_amount_2024_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2024_H1 = informal_amount_2024_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    replace informal_amount_2024_H2 = informal_amount_2024_H2 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    * 2025 amounts
    replace loan_amount_2025_H1 = loan_amount_2025_H1 + sec6_q9_`loannum' if sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace formal_amount_2025_H1 = formal_amount_2025_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 2, 4, 5, 6, 7) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')
    
    replace informal_amount_2025_H1 = informal_amount_2025_H1 + sec6_q9_`loannum' if inlist(sec6_q4_`loannum', 1, 3) & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum') & !missing(sec6_q9_`loannum')

}


/*
br sec6_q5_1 sec6_q9_1 sec6_q4_1 sec6_q5_2 sec6_q9_2 sec6_q4_2 sec6_q5_3 sec6_q9_3 sec6_q4_3   loan_amount_2020_H1 loan_amount_2020_H2 formal_amount_2020_H1 formal_amount_2020_H2 informal_amount_2020_H1 informal_amount_2020_H2 loan_amount_2021_H1 loan_amount_2021_H2 formal_amount_2021_H1 formal_amount_2021_H2 informal_amount_2021_H1 informal_amount_2021_H2 loan_amount_2022_H1 loan_amount_2022_H2 formal_amount_2022_H1 formal_amount_2022_H2 informal_amount_2022_H1 informal_amount_2022_H2 loan_amount_2023_H1 loan_amount_2023_H2 formal_amount_2023_H1 formal_amount_2023_H2 informal_amount_2023_H1 informal_amount_2023_H2 loan_amount_2024_H1 loan_amount_2024_H2 formal_amount_2024_H1 formal_amount_2024_H2 informal_amount_2024_H1 informal_amount_2024_H2 loan_amount_2025_H1 formal_amount_2025_H1 informal_amount_2025_H1
*/






/* Active loan indicators by half-year */
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

* Create indicators for active loans in each half-year
forval year = 2020/2025 {
    gen active_loan_`year'_H1 = 0 if !missing(any_loan)
    gen active_loan_`year'_H2 = 0 if !missing(any_loan)
    
    label var active_loan_`year'_H1 "Has active loan during `year' H1 (Jan-Jun)"
    label var active_loan_`year'_H2 "Has active loan during `year' H2 (Jul-Dec)"
}

sum loan_count, d
* Populate active loan indicators
forvalues loannum = 1/`max_loan' {
    * 2020 H1: loan is active if start date <= end of H1 AND end date >= start of H1 (or loan is still active)
    replace active_loan_2020_H1 = 1 if sec6_q5_`loannum' <= td(30jun2020) & (loan_end_date_`loannum' >= td(01jan2020) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2020 H2
    replace active_loan_2020_H2 = 1 if sec6_q5_`loannum' <= td(31dec2020) & (loan_end_date_`loannum' >= td(01jul2020) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2021 H1
    replace active_loan_2021_H1 = 1 if sec6_q5_`loannum' <= td(30jun2021) & (loan_end_date_`loannum' >= td(01jan2021) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2021 H2
    replace active_loan_2021_H2 = 1 if sec6_q5_`loannum' <= td(31dec2021) & (loan_end_date_`loannum' >= td(01jul2021) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2022 H1
    replace active_loan_2022_H1 = 1 if sec6_q5_`loannum' <= td(30jun2022) & (loan_end_date_`loannum' >= td(01jan2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2022 H2
    replace active_loan_2022_H2 = 1 if sec6_q5_`loannum' <= td(31dec2022) & (loan_end_date_`loannum' >= td(01jul2022) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 H1
    replace active_loan_2023_H1 = 1 if sec6_q5_`loannum' <= td(30jun2023) & (loan_end_date_`loannum' >= td(01jan2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2023 H2
    replace active_loan_2023_H2 = 1 if sec6_q5_`loannum' <= td(31dec2023) & (loan_end_date_`loannum' >= td(01jul2023) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 H1
    replace active_loan_2024_H1 = 1 if sec6_q5_`loannum' <= td(30jun2024) & (loan_end_date_`loannum' >= td(01jan2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2024 H2
    replace active_loan_2024_H2 = 1 if sec6_q5_`loannum' <= td(31dec2024) & (loan_end_date_`loannum' >= td(01jul2024) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
    
    * 2025 H1
    replace active_loan_2025_H1 = 1 if sec6_q5_`loannum' <= td(30jun2025) & (loan_end_date_`loannum' >= td(01jan2025) | sec6_q6_`loannum' == 1) & !missing(sec6_q5_`loannum')
}

cap drop active_loan_2025_H2

* Apply labels to active loan variables
forval year = 2020/2025 {
    cap label values active_loan_`year'_H1 active_loan_`year'_H2 yesno
}













/* Create total unpaid loan variable */
ds sec6_q7_*
egen total_loan_remaining = rowtotal(`r(varlist)')  if any_loan == 1
label variable total_loan_remaining "Total unpaid principal across active loans (Rs.)"

/* Create log transformation (without winsorizing) */
gen log_total_loan_remaining = log(total_loan_remaining+1) if !missing(total_loan_remaining)
label variable log_total_loan_remaining "Log of Total unpaid loans"

/* Create half-yearly unpaid loan variables */
forval year = 2020/2025 {
	cap drop total_loan_remaining_`year'_H1 total_loan_remaining_`year'_H2
    gen total_loan_remaining_`year'_H1 = 0 if any_loan == 1
    gen total_loan_remaining_`year'_H2 = 0 if any_loan == 1
    
    label var total_loan_remaining_`year'_H1 "Total unpaid loan amount in `year' H1 (Jan-Jun)"
    label var total_loan_remaining_`year'_H2 "Total unpaid loan amount in `year' H2 (Jul-Dec)"
}

drop total_loan_remaining_2025_H2

sum loan_count, d
local max_loan = r(max)
/* For each loan and each half-year, add unpaid amounts if the loan is active in that period */
forvalues loannum = 1/`max_loan' {
    forval year = 2020/2025 {
        /* H1: Jan-Jun */
        /* A loan is active in a period if: 
           1. It started on or before the end of the period AND
           2. Either it's still active (sec6_q6_`loannum' == 1) OR 
              its end date (approximated from start + duration) is after the start of the period */
        
        /* Calculate approximate end date based on loan duration */
        cap gen temp_end_date_`loannum' = sec6_q5_`loannum' + (sec6_q16_`loannum' * 30.44) if !missing(sec6_q5_`loannum') & !missing(sec6_q16_`loannum')
        
        /* Add loan amount to the half-yearly total if it's active in that period */
        replace total_loan_remaining_`year'_H1 = total_loan_remaining_`year'_H1 + sec6_q7_`loannum' ///
            if sec6_q5_`loannum' <= td(30jun`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01jan`year')) ///
            & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        
        /* H2: Jul-Dec */
        if `year' < 2025 {
            replace total_loan_remaining_`year'_H2 = total_loan_remaining_`year'_H2 + sec6_q7_`loannum' ///
                if sec6_q5_`loannum' <= td(31dec`year') & (sec6_q6_`loannum' == 1 | temp_end_date_`loannum' >= td(01jul`year')) ///
                & !missing(sec6_q5_`loannum') & !missing(sec6_q7_`loannum')
        }
    }
    
    cap drop temp_end_date_`loannum'
}

forval year = 2020/2025 {
    /* H1: Jan-Jun */
    gen log_total_loan_remaining_`year'_H1 = log(total_loan_remaining_`year'_H1) ///
        if total_loan_remaining_`year'_H1 > 0 & !missing(total_loan_remaining_`year'_H1)
    
    label var log_total_loan_remaining_`year'_H1 "Log of total unpaid loan in `year' H1"
    
    /* H2: Jul-Dec  */
    if `year' < 2025 {
        gen log_total_loan_remaining_`year'_H2 = log(total_loan_remaining_`year'_H2) ///
            if total_loan_remaining_`year'_H2 > 0 & !missing(total_loan_remaining_`year'_H2)
        
        label var log_total_loan_remaining_`year'_H2 "Log of total unpaid loan in `year' H2"
    }
}









/*==============================================================================
                       Interest Rate Variables                            
==============================================================================*/
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










/*==============================================================================
                   Half-Yearly and Annual Interest Rate Variables                            
==============================================================================*/

/* Create half-yearly interest rate variables */
forval year = 2020/2025 {
    /* Initialize variables for each half-year */
    gen avg_int_rate_`year'_H1 = . 
    gen avg_int_rate_`year'_H2 = .
    gen formal_int_rate_`year'_H1 = .
    gen formal_int_rate_`year'_H2 = .
    gen informal_int_rate_`year'_H1 = .
    gen informal_int_rate_`year'_H2 = .
    
    /* Label variables */
    label var avg_int_rate_`year'_H1 "Average interest rate in `year' H1 (Jan-Jun)"
    label var avg_int_rate_`year'_H2 "Average interest rate in `year' H2 (Jul-Dec)"
    label var formal_int_rate_`year'_H1 "Formal loan interest rate in `year' H1"
    label var formal_int_rate_`year'_H2 "Formal loan interest rate in `year' H2"
    label var informal_int_rate_`year'_H1 "Informal loan interest rate in `year' H1"
    label var informal_int_rate_`year'_H2 "Informal loan interest rate in `year' H2"
}

/* Drop 2025 H2 variables (these half-years don't exist in data) */
drop avg_int_rate_2025_H2 formal_int_rate_2025_H2 informal_int_rate_2025_H2


sum loan_count, d
local max_loan = r(max)
/* Fill in half-yearly interest rate variables based on loan start dates */
forvalues i = 1/`max_loan' {
    forval year = 2020/2025 {
        /* H1: Jan-Jun */
        /* If loan was taken in this half-year, record its interest rate */
        replace avg_int_rate_`year'_H1 = an_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(an_int_`i')
            
        /* Record by source type */
        replace formal_int_rate_`year'_H1 = an_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(an_int_`i') ///
            & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
            
        replace informal_int_rate_`year'_H1 = an_int_`i' ///
            if sec6_q5_`i' >= td(01jan`year') & sec6_q5_`i' <= td(30jun`year') & !missing(sec6_q5_`i') & !missing(an_int_`i') ///
            & inlist(sec6_q4_`i', 1, 3)
        
        /* H2: Jul-Dec (only for years before 2025) */
        if `year' < 2025 {
            replace avg_int_rate_`year'_H2 = an_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(an_int_`i')
                
            replace formal_int_rate_`year'_H2 = an_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(an_int_`i') ///
                & inlist(sec6_q4_`i', 2, 4, 5, 6, 7)
                
            replace informal_int_rate_`year'_H2 = an_int_`i' ///
                if sec6_q5_`i' >= td(01jul`year') & sec6_q5_`i' <= td(31dec`year') & !missing(sec6_q5_`i') & !missing(an_int_`i') ///
                & inlist(sec6_q4_`i', 1, 3)
        }
    }
}




/* Create annual interest rate variables */
forval year = 2020/2025 {
    /* Initialize variables for each year */
    egen temp_int_count_`year' = rownonmiss(avg_int_rate_`year'_H1 avg_int_rate_`year'_H2)
    egen temp_formal_count_`year' = rownonmiss(formal_int_rate_`year'_H1 formal_int_rate_`year'_H2)
    egen temp_informal_count_`year' = rownonmiss(informal_int_rate_`year'_H1 informal_int_rate_`year'_H2)
    
    /* Calculate annual average interest rates */
    egen avg_int_rate_`year' = rowmean(avg_int_rate_`year'_H1 avg_int_rate_`year'_H2) if temp_int_count_`year' > 0
    egen formal_int_rate_`year' = rowmean(formal_int_rate_`year'_H1 formal_int_rate_`year'_H2) if temp_formal_count_`year' > 0
    egen informal_int_rate_`year' = rowmean(informal_int_rate_`year'_H1 informal_int_rate_`year'_H2) if temp_informal_count_`year' > 0
    
    /* Label variables */
    label var avg_int_rate_`year' "Average interest rate in `year'"
    label var formal_int_rate_`year' "Formal loan interest rate in `year'"
    label var informal_int_rate_`year' "Informal loan interest rate in `year'"
    
    /* Clean up temporary count variables */
    drop temp_int_count_`year' temp_formal_count_`year' temp_informal_count_`year'
}








/*==============================================================================
                       Repayment Behavior Variables                             
==============================================================================*/

** Maximum delay length across all loans
gen max_delay_length = 0 if any_loan == 1 & !missing(any_loan)
sum loan_count, d
local max_loan = r(max)

forvalues i = 1/`max_loan' {
    replace max_delay_length = sec6_q12_`i' if sec6_q12_`i' > max_delay_length & !missing(sec6_q12_`i')
}
label var max_delay_length "Maximum length of payment delay in days across all loans"


sum loan_count, d
local max_loan = r(max)
** Total number of payment delays across all loans
gen total_payment_delays = 0 if any_loan == 1 & !missing(any_loan)
forvalues i = 1/`max_loan' {
    replace total_payment_delays = total_payment_delays + sec6_q11_`i' if !missing(sec6_q11_`i')
}
label var total_payment_delays "Total number of payment delays across all loans"



** Any payment delay indicator
gen has_any_delay = 0 if any_loan == 1 & !missing(any_loan)
replace has_any_delay = 1 if total_payment_delays > 0 & !missing(total_payment_delays)
label var has_any_delay "Has any payment delay across all loans"
label values has_any_delay yesno

sum loan_count, d
local max_loan = r(max)
** Frequent delays indicator (more than 3 delays on any loan)
gen has_frequent_delays = 0 if any_loan == 1 & !missing(any_loan)
forvalues i = 1/`max_loan' {
    replace has_frequent_delays = 1 if sec6_q11_`i' >= 3 & !missing(sec6_q11_`i')
}
label var has_frequent_delays "Has frequent payment delays (3+ on any loan)"
label values has_frequent_delays yesno


sum loan_count, d
local max_loan = r(max)
** Long delay indicator (any delay longer than 30 days)
gen has_long_delay = 0 if any_loan == 1 & !missing(any_loan)
forvalues i = 1/`max_loan' {
    replace has_long_delay = 1 if sec6_q12_`i' > 30 & !missing(sec6_q12_`i')
}
label var has_long_delay "Has any payment delay longer than 30 days"
label values has_long_delay yesno




gen repayment_difficult = 0 if any_loan == 1 & !missing(any_loan)
sum loan_count, d
local max_loan = r(max)
forvalues i = 1/`max_loan' {
    replace repayment_difficult = 1 if sec6_q14_`i' >= 2 & !missing(sec6_q14_`i')
}



egen repay_behavior_score = rowmean(has_any_delay has_frequent_delays has_long_delay repayment_difficult)
la var repay_behavior_score "Repayment Behaviour Score"











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



/* Half-yearly loan purpose indicators */
forval year = 2020/2025 {
	cap drop fixed_capital_loan_`year'_H1 fixed_capital_loan_`year'_H2 working_capital_loan_`year'_H1 working_capital_loan_`year'_H2 consumption_loan_`year'_H1 consumption_loan_`year'_H2 
    gen fixed_capital_loan_`year'_H1 = 0 if !missing(any_loan)
    gen fixed_capital_loan_`year'_H2 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_H1 = 0 if !missing(any_loan)
    gen working_capital_loan_`year'_H2 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_H1 = 0 if !missing(any_loan)
    gen consumption_loan_`year'_H2 = 0 if !missing(any_loan)
    
    label var fixed_capital_loan_`year'_H1 "Took fixed capital loan in `year' H1 (Jan-Jun)"
    label var fixed_capital_loan_`year'_H2 "Took fixed capital loan in `year' H2 (Jul-Dec)"
    label var working_capital_loan_`year'_H1 "Took working capital loan in `year' H1 (Jan-Jun)"
    label var working_capital_loan_`year'_H2 "Took working capital loan in `year' H2 (Jul-Dec)"
    label var consumption_loan_`year'_H1 "Took consumption loan in `year' H1 (Jan-Jun)"
    label var consumption_loan_`year'_H2 "Took consumption loan in `year' H2 (Jul-Dec)"
}

* Drop 2025 H2 variables for consistency
drop fixed_capital_loan_2025_H2 working_capital_loan_2025_H2 consumption_loan_2025_H2

* Populate half-yearly loan purpose indicators
sum loan_count, d
forval loannum = 1/`r(max)' {
    * 2020
    replace fixed_capital_loan_2020_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2020_H2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2020_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2020_H2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2020_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2020) & sec6_q5_`loannum' <= td(30jun2020) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2020_H2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2020) & sec6_q5_`loannum' <= td(31dec2020) & !missing(sec6_q5_`loannum')
    
    * 2021
    replace fixed_capital_loan_2021_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2021_H2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2021_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2021_H2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2021_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2021) & sec6_q5_`loannum' <= td(30jun2021) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2021_H2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2021) & sec6_q5_`loannum' <= td(31dec2021) & !missing(sec6_q5_`loannum')
    
    * 2022
    replace fixed_capital_loan_2022_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2022_H2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2022_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2022_H2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2022_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2022) & sec6_q5_`loannum' <= td(30jun2022) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2022_H2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2022) & sec6_q5_`loannum' <= td(31dec2022) & !missing(sec6_q5_`loannum')
    
    * 2023
    replace fixed_capital_loan_2023_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2023_H2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2023_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2023_H2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2023_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2023) & sec6_q5_`loannum' <= td(30jun2023) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2023_H2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2023) & sec6_q5_`loannum' <= td(31dec2023) & !missing(sec6_q5_`loannum')
    
    * 2024
    replace fixed_capital_loan_2024_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace fixed_capital_loan_2024_H2 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace working_capital_loan_2024_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2024_H2 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    replace consumption_loan_2024_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2024) & sec6_q5_`loannum' <= td(30jun2024) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2024_H2 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jul2024) & sec6_q5_`loannum' <= td(31dec2024) & !missing(sec6_q5_`loannum')
    
    * 2025 H1
    replace fixed_capital_loan_2025_H1 = 1 if loan_`loannum'_fixed_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    replace working_capital_loan_2025_H1 = 1 if loan_`loannum'_working_capital == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
    replace consumption_loan_2025_H1 = 1 if loan_`loannum'_consumption == 1 & sec6_q5_`loannum' >= td(01jan2025) & sec6_q5_`loannum' <= td(30jun2025) & !missing(sec6_q5_`loannum')
}

forval year = 2020/2025 {
    cap label values fixed_capital_loan_`year'_H1 fixed_capital_loan_`year'_H2 working_capital_loan_`year'_H1 working_capital_loan_`year'_H2 consumption_loan_`year'_H1 consumption_loan_`year'_H2 yesno
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





/* Create half-yearly loan amount by purpose variables */
forval year = 2020/2025 {
    gen fixed_capital_amount_`year'_H1 = 0 if !missing(any_loan)
    gen fixed_capital_amount_`year'_H2 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_H1 = 0 if !missing(any_loan)
    gen working_capital_amount_`year'_H2 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_H1 = 0 if !missing(any_loan)
    gen consumption_amount_`year'_H2 = 0 if !missing(any_loan)
    
    label var fixed_capital_amount_`year'_H1 "Fixed capital loan amount in `year' H1 (Jan-Jun)"
    label var fixed_capital_amount_`year'_H2 "Fixed capital loan amount in `year' H2 (Jul-Dec)"
    label var working_capital_amount_`year'_H1 "Working capital loan amount in `year' H1 (Jan-Jun)"
    label var working_capital_amount_`year'_H2 "Working capital loan amount in `year' H2 (Jul-Dec)"
    label var consumption_amount_`year'_H1 "Consumption loan amount in `year' H1 (Jan-Jun)"
    label var consumption_amount_`year'_H2 "Consumption loan amount in `year' H2 (Jul-Dec)"
}

drop fixed_capital_amount_2025_H2 working_capital_amount_2025_H2 consumption_amount_2025_H2

/* Process loan 1 by half-year */
/* Only one purpose selected */
/* Fixed capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Working capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Consumption*/
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Multiple purposes selected */
/* Fixed capital + Working capital (1 2) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Fixed capital + Consumption (1 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Working capital + Consumption (2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* All three purposes (1 2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_1_1 ///
        if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_1_2 ///
        if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_1_3 ///
        if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
        & sec6_q5_1 >= td(01jan`year') & sec6_q5_1 <= td(30jun`year') & !missing(sec6_q5_1)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_1_1 ///
            if sec6_q15_1 == "1 2 3" & loan_1_fixed_capital == 1 & !missing(sec6_q15a_1_1) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_1_2 ///
            if sec6_q15_1 == "1 2 3" & loan_1_working_capital == 1 & !missing(sec6_q15a_1_2) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_1_3 ///
            if sec6_q15_1 == "1 2 3" & loan_1_consumption == 1 & !missing(sec6_q15a_1_3) ///
            & sec6_q5_1 >= td(01jul`year') & sec6_q5_1 <= td(31dec`year') & !missing(sec6_q5_1)
    }
}

/* Now repeat the same pattern for loan 2 */
/* Only one purpose selected */
/* Fixed capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Working capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Consumption */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Multiple purposes for loan 2 - following the same pattern as loan 1 */
/* Fixed capital + Working capital (1 2) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Fixed capital + Consumption (1 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* Working capital + Consumption (2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}

/* All three purposes (1 2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_2_1 ///
        if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_2_2 ///
        if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_2_3 ///
        if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
        & sec6_q5_2 >= td(01jan`year') & sec6_q5_2 <= td(30jun`year') & !missing(sec6_q5_2)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_2_1 ///
            if sec6_q15_2 == "1 2 3" & loan_2_fixed_capital == 1 & !missing(sec6_q15a_2_1) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_2_2 ///
            if sec6_q15_2 == "1 2 3" & loan_2_working_capital == 1 & !missing(sec6_q15a_2_2) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_2_3 ///
            if sec6_q15_2 == "1 2 3" & loan_2_consumption == 1 & !missing(sec6_q15a_2_3) ///
            & sec6_q5_2 >= td(01jul`year') & sec6_q5_2 <= td(31dec`year') & !missing(sec6_q5_2)
    }
}


/*Repeat for loan 3 */
/* Only one purpose selected */
/* Fixed capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Working capital */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Consumption */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
        
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Multiple purposes for loan 3 */
/* Fixed capital + Working capital (1 2) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Fixed capital + Consumption (1 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* Working capital + Consumption (2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
}

/* All three purposes (1 2 3) */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    replace fixed_capital_amount_`year'_H1 = fixed_capital_amount_`year'_H1 + sec6_q15a_3_1 ///
        if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace working_capital_amount_`year'_H1 = working_capital_amount_`year'_H1 + sec6_q15a_3_2 ///
        if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    replace consumption_amount_`year'_H1 = consumption_amount_`year'_H1 + sec6_q15a_3_3 ///
        if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
        & sec6_q5_3 >= td(01jan`year') & sec6_q5_3 <= td(30jun`year') & !missing(sec6_q5_3)
    
    /* H2: Jul-Dec */
    if `year' < 2025 {
        replace fixed_capital_amount_`year'_H2 = fixed_capital_amount_`year'_H2 + sec6_q15a_3_1 ///
            if sec6_q15_3 == "1 2 3" & loan_3_fixed_capital == 1 & !missing(sec6_q15a_3_1) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace working_capital_amount_`year'_H2 = working_capital_amount_`year'_H2 + sec6_q15a_3_2 ///
            if sec6_q15_3 == "1 2 3" & loan_3_working_capital == 1 & !missing(sec6_q15a_3_2) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
        
        replace consumption_amount_`year'_H2 = consumption_amount_`year'_H2 + sec6_q15a_3_3 ///
            if sec6_q15_3 == "1 2 3" & loan_3_consumption == 1 & !missing(sec6_q15a_3_3) ///
            & sec6_q5_3 >= td(01jul`year') & sec6_q5_3 <= td(31dec`year') & !missing(sec6_q5_3)
    }
	
}
	
	/* Now, create combined half-yearly loan amount variables that sum all types of loans */
forval year = 2020/2025 {
    /* H1: Jan-Jun */
    gen loan_amount_by_purpose_`year'_H1 = fixed_capital_amount_`year'_H1 + working_capital_amount_`year'_H1 + consumption_amount_`year'_H1
    label var loan_amount_by_purpose_`year'_H1 "Total loan amount by purpose in `year' H1 (Jan-Jun)"
    
    if `year' < 2025 {
        /* H2: Jul-Dec */
        gen loan_amount_by_purpose_`year'_H2 = fixed_capital_amount_`year'_H2 + working_capital_amount_`year'_H2 + consumption_amount_`year'_H2
        label var loan_amount_by_purpose_`year'_H2 "Total loan amount by purpose in `year' H2 (Jul-Dec)"
    }
}












