
********************************************************************************
***************** ANALYSIS FOR RESULTS******************************************
********************************************************************************

****PROPORTION OF SMOKERS
use "$data/pns2013_panel.dta", clear
tab age
keep if capital == 1
drop if t2008==1 | t2010 == 1 | t2011 == 1
keep if year == 2009 | year == 2013
replace smoke = smoke*100
gen temp = smoke if year == 2009
bysort t2009: egen smoking2009 = max(temp)
drop temp
gen smoking_diff = smoke - smoking2009

forvalues i = 2009/2013{
sum smoke if age >= 15 & age <= 29 & year == `i' [aw=weight]
matrix proportion`i' = r(mean)
sum smoke if age >= 15 & age <= 29 & year == `i' & t2009 == 0 [aw=weight]
matrix proportion`i' = proportion`i', r(mean)
sum smoke if age >= 15 & age <= 29 & year == `i' & t2009 == 1 [aw=weight]
matrix proportion`i' = proportion`i', r(mean)
sum smoke if age >= 15 & age <= 29 & year == `i' & t2009 == 1 & enforcement_low == 1 [aw=weight]
matrix proportion`i' = proportion`i', r(mean)
sum smoke if age >= 15 & age <= 29 & year == `i' & t2009 == 1 & enforcement_higher== 1 [aw=weight]
matrix proportion`i' = proportion`i', r(mean)
matrix colnames proportion`i' = Prevalence Control Treated LowEnf HighEnf
}

matrix list proportion2013
matrix diff = proportion2013 - proportion2009
matrix RESULTS_PREV = proportion2009\proportion2013\ diff
matrix rownames RESULTS_PREV = 2009 2013 Diff
esttab  matrix(RESULTS_PREV, fmt(2))  using "$desc/descriptive_results", replace


use "$data\pns2013_panel", clear
keep if capital == 1
drop if t2008==1 |  t2010 == 1 | t2011 == 1
keep if age >= 15 & age <= 29
keep if year == 2009
replace smoke = smoke*weight
bysort t2009: egen regular_smoker_tot = total(smoke)
bysort t2009 enforcement_higher: egen regular_smoker_enf = total(smoke)

*** Direct healthcare costs = 39404319956 BRL 2015 
*** Smokers 2015 around 20000000
*** Average exchange rate 2015 = 3.35 BRL per US$
local cost_smoker = (39404319956/20000000)/3.35

sum regular_smoker_tot if t2009 == 1 
matrix A = r(mean)
sum regular_smoker_enf if enforcement_higher==1 & t2009 == 1 
matrix A = A, r(mean)
matrix treat_effect = A*0.18
matrix cost = (`cost_smoker'/1000)*treat_effect

matrix PrevalenceEffect = A\treat_effect\cost
matrix colnames PrevalenceEffect = Treated HighEnf
matrix rownames PrevalenceEffect = Smokers2009 Effect CostThousand
esttab  matrix(PrevalenceEffect)  using "$desc/descriptive_results.txt", append 

use "$data/pns2013_panel.dta", clear
keep if capital == 1
keep if index9 == 1
drop if t2008==1 |  t2010 == 1 | t2011 == 1
keep if age >= 15 & age <= 29
drop stock
sort id year
bysort id: gen stock = sum(smoke)
order stock, after(smoke)
gen temp = stock if year == 2009
bysort id: egen stock2009 = max(temp)

keep if year == 2009
replace smoke = smoke*weight

preserve
bysort t2009: egen regular_smoker_tot = total(smoke)
bysort t2009 enforcement_higher: egen regular_smoker_enf = total(smoke)

sum regular_smoker_tot if t2009 == 1 
matrix A = r(mean)
sum regular_smoker_enf if enforcement_higher==1 & t2009 == 1 
matrix A = A, r(mean)
matrix treat_effect = A*0.11
matrix cost = (`cost_smoker'/1000)*treat_effect

matrix CessationEffect = A\treat_effect\cost
matrix colnames CessationEffect = Treated HighEnf
matrix rownames CessationEffect = Smokers2009 Effect CostThousand
esttab  matrix(CessationEffect)  using "$desc/descriptive_results.txt", append 
restore 

keep if stock2009 <= 3 
bysort t2009: egen regular_smoker_tot = total(smoke)
bysort t2009 enforcement_higher: egen regular_smoker_enf = total(smoke)

sum regular_smoker_tot if t2009 == 1 
matrix A = r(mean)
sum regular_smoker_enf if enforcement_higher==1 & t2009 == 1 
matrix A = A, r(mean)
matrix treat_effect = A*0.275
matrix cost = (`cost_smoker'/1000)*treat_effect

matrix CessationLowAdd = A\treat_effect\cost
matrix colnames CessationLowAdd = Treated HighEnf
matrix rownames CessationLowAdd = Smokers2009 Effect CostThousand
esttab  matrix(CessationLowAdd)  using "$desc/descriptive_results.txt", append 

clear all