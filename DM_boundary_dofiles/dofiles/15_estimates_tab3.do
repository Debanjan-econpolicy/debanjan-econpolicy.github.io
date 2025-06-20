*******************************************************************************
***************************** RISKY BEHAVIOR **********************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_cross.dta", clear
keep if capital == 1 
egen grupo=group(uf)

*** Keeping only main treatment group vs. control
drop if uf == 11 | uf == 22 | uf == 51  // 2008, 2010 and 2011 "TREATED" 

gen treated = 0
replace treated = 1 if uf == 13 | uf == 14 | uf == 25 | uf == 35 | uf == 41 | ///
 uf == 52 | uf == 15 | uf == 28 | uf == 29 | uf == 12 | uf == 50 | uf == 33

gen enforcement_high = 0
replace enforcement_high = 1 if uf == 41 | uf == 33 | uf == 35 | uf == 50 | uf == 52 |  uf == 29 

gen enforcement_low = 0
replace enforcement_low = 1 if uf == 13 | uf == 14 | uf == 25 | uf == 15 | uf == 28 | uf == 12 

** Generating dummy variables of interest
gen smuggling = .
replace smuggling = 0 if price != . & price >= 3.5
replace smuggling = 1 if price != . & price != 0 & price< 3.5

replace package_quit = 0 if package_quit == 2
replace tried_quit = 0 if tried_quit == 2

gen smoke = 0
replace smoke = 1 if regular_smoker == 1 | casual_smoker == 1

*** REGRESSIONS
reg smoke enforcement_high enforcement_low if age <= 29 [aw = weight], vce(cluster grupo)
matrix high = e(b)[1,1]
matrix low = e(b)[1,2]
matrix cte  = e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se =A[1,1]
matrix low_se =A[2,2]
matrix cte_se =A[3,3]
matrix Nreg =  e(N) 
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_high = r(p_1)
matrix pvalue_low = r(p_2)

foreach x of varlist  smuggling tried_quit starting_age    {
reg `x' enforcement_high enforcement_low if age <= 29 & smoke == 1 [aw = weight], vce(cluster grupo)
matrix high = high,e(b)[1,1]
matrix low = low,e(b)[1,2]
matrix cte  =cte, e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se =high_se,A[1,1]
matrix low_se =low_se,A[2,2]
matrix cte_se =cte_se,A[3,3]
matrix Nreg = Nreg, e(N) 
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_high = pvalue_high, r(p_1)
matrix pvalue_low = pvalue_low, r(p_2)
}

foreach x of varlist sport drink  {
reg `x' enforcement_high enforcement_low if age <= 29 [aw = weight], vce(cluster grupo)
matrix high = high,e(b)[1,1]
matrix low = low,e(b)[1,2]
matrix cte  =cte, e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se =high_se,A[1,1]
matrix low_se =low_se,A[2,2]
matrix cte_se =cte_se,A[3,3]
matrix Nreg = Nreg, e(N) 
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_high = pvalue_high, r(p_1)
matrix pvalue_low = pvalue_low, r(p_2)
}



foreach l in high low high_se low_se cte cte_se pvalue_high pvalue_low Nreg {
matrix colnames `l' = Smoke Smuggling Tried_quit Age_inic Sport Alcohol
estadd matrix `l', replace
 }

 esttab using "$results/tab3_behavior.tex", replace cells("cte(fmt(%12.3fc)) high(fmt(%12.3fc)) low(fmt(%12.3fc)) "  /// 
 "cte_se(fmt(%12.3fc) par) high_se(fmt(%12.3fc) par)low_se(fmt(%12.3fc) par)" /// 
 "Nreg(fmt(%12.0fc)) pvalue_high(fmt(%12.3fc) par([ ])) pvalue_low(fmt(%12.3fc) par([ ]))" ) /// 
collabels( "Average Control" "Difference High" "Diff. Low")  /// 
mgroups(none) mlabels(none) nogaps noobs noeqlines compress nolines substitute(\_ _) eqlabels(none) title(none) nonumbers 


clear all

