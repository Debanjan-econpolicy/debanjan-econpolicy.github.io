*******************************************************************************
*****************************OTHER POLICIES************************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_cross.dta", clear
keep if capital == 1 
drop if uf == 11 // 2008 "cohort" is not included in the analysis

*** Generating treatment variables
drop if uf == 11 // 2008 cohort is not included as treated in the paper
gen t2009 = 0
replace t2009 = 1 if uf == 13 | uf == 14 | uf == 25 | uf == 35 | uf == 41 | uf == 52 | uf == 15 | uf == 28 | uf == 29 | uf == 12 | uf == 50 | uf == 33
gen t2010 = 0
replace t2010 = 1 if uf == 22
gen t2011 = 0
replace t2011 = 1 if uf == 51
gen treated = 0
replace treated = 1 if t2009 == 1 | t2010 == 1 | t2011 == 1

gen enforcement_high = 0
replace enforcement_high = 1 if uf == 41 | uf == 33 | uf == 35 | uf == 50 | uf == 52 | uf == 22 | uf == 29 | uf == 51

gen enforcement_low = 0
replace enforcement_low = 1 if  uf == 13 | uf == 14 | uf == 25 | uf == 15 | uf == 28 | uf == 12 

egen grupo=group(uf)
gen young = 0
replace young = 1 if 18 <= age & age <= 33 // Individuals from 15 to 29 between 2009 and 2013
drop if age > 65

** Generating dummy variables for other policies
foreach x of varlist advertisement warning_newspaper warning_tv warning_radio package  tried_treatment  {
replace `x' = 0 if `x' == 2 | `x' == 3
}

gen lprice = log(price)

***** REGRESSIONS: TABLE 1 AND APPENDIX TABLE B1
reg advertisement treated [aw = weight], vce(cluster grupo)
matrix treated = e(b)[1,1]
matrix cte  = e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix treated_se = A[1,1]
matrix cte_se = A[2,2]
matrix Nreg = e(N) 
boottest treated, noci cluster(grupo) seed(982638)
matrix pvalue = r(p)

reg advertisement treated if young == 1  [aw = weight], vce(cluster grupo)
matrix treated_youth = e(b)[1,1]
matrix cte_youth  = e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix treated_se_youth = A[1,1]
matrix cte_se_youth = A[2,2]
matrix N_youth = e(N) 
boottest treated, noci cluster(grupo) seed(982638)
matrix pvalue_youth = r(p)

reg advertisement enforcement_high enforcement_low if t2010 == 0 & t2011 == 0 [aw = weight], vce(cluster grupo)
matrix high_2009 = e(b)[1,1]
matrix low_2009 = e(b)[1,2]
matrix cte_2009  = e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se_2009 = A[1,1]
matrix low_se_2009 = A[2,2]
matrix cte_se_2009 = A[3,3]
matrix N_2009 = e(N) 
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_h2009 = r(p_1)
matrix pvalue_l2009 = r(p_2)

reg advertisement enforcement_high enforcement_low if t2010 == 0 & t2011 == 0 & young == 1  [aw = weight], vce(cluster grupo)
matrix high_youth9 = e(b)[1,1]
matrix low_youth9 = e(b)[1,2]
matrix cte_youth9 = e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se_youth9 = A[1,1]
matrix low_se_youth9 = A[2,2]
matrix cte_se_youth9 = A[3,3]
matrix N_youth9 = e(N)
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_h2009y = r(p_1)
matrix pvalue_l2009y = r(p_2)

foreach x of varlist warning_newspaper warning_tv warning_radio package tried_treatment lprice  {
reg `x' treated [aw = weight], vce(cluster grupo)
matrix treated = treated, e(b)[1,1]
matrix cte  = cte, e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix treated_se =treated_se, A[1,1]
matrix cte_se = cte_se, A[2,2]
matrix Nreg = Nreg, e(N) 
boottest treated, noci cluster(grupo) seed(982638)
matrix pvalue = pvalue, r(p)

reg `x' treated if young == 1 [aw = weight], vce(cluster grupo)
matrix treated_youth =treated_youth, e(b)[1,1]
matrix cte_youth  = cte_youth, e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix treated_se_youth =treated_se_youth,  A[1,1]
matrix cte_se_youth =cte_se_youth,  A[2,2]
matrix N_youth =N_youth, e(N) 
boottest treated, noci cluster(grupo) seed(982638)
matrix pvalue_youth = pvalue_youth, r(p)


reg `x' enforcement_high enforcement_low if t2010 == 0 & t2011 == 0 [aw = weight], vce(cluster grupo)
matrix high_2009 = high_2009, e(b)[1,1]
matrix low_2009 = low_2009, e(b)[1,2]
matrix cte_2009  =cte_2009, e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se_2009 =high_se_2009, A[1,1]
matrix low_se_2009 =low_se_2009, A[2,2]
matrix cte_se_2009 =cte_se_2009, A[3,3]
matrix N_2009 =N_2009, e(N) 
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_h2009 = pvalue_h2009, r(p_1)
matrix pvalue_l2009 =pvalue_l2009, r(p_2)


reg `x' enforcement_high enforcement_low if t2010 == 0 & t2011 == 0 & young == 1 [aw = weight], vce(cluster grupo)
matrix high_youth9 =high_youth9, e(b)[1,1]
matrix low_youth9 =low_youth9, e(b)[1,2]
matrix cte_youth9 =cte_youth9, e(b)[1,3]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
matrix high_se_youth9 =high_se_youth9, A[1,1]
matrix low_se_youth9 =low_se_youth9, A[2,2]
matrix cte_se_youth9 = cte_se_youth9, A[3,3]
matrix N_youth9 =N_youth9, e(N)
boottest {enforcement_high} {enforcement_low}, noci cluster(grupo) seed(982638)
matrix pvalue_h2009y = pvalue_h2009y, r(p_1)
matrix pvalue_l2009y =pvalue_l2009y, r(p_2)
}


matrix pvalue_cte = ., ., ., ., ., .,.
matrix fill = ., ., ., ., ., .,.

foreach l in treated cte treated_se cte_se Nreg treated_youth cte_youth treated_se_youth cte_se_youth N_youth ///
 high_2009 low_2009 cte_2009 high_se_2009 low_se_2009 cte_se_2009 N_2009 high_youth9 low_youth9 cte_youth9 high_se_youth9 /// 
 low_se_youth9 cte_se_youth9 N_youth9 pvalue_cte pvalue pvalue_youth pvalue_h2009 pvalue_h2009y pvalue_l2009 pvalue_l2009y {
matrix colnames `l' = Advertising Warning_np Warning_tv Warning_radio Warning_package  Ces_program Price
estadd matrix `l', replace
 }

sleep 3000

esttab using "$results/tab1_policies.tex", replace /// 
cells(" cte(fmt(%12.3fc)) treated(fmt(%12.3fc)) Nreg(fmt(%12.0fc))  cte_youth(fmt(%12.3fc)) treated_youth(fmt(%12.3fc)) N_youth(fmt(%12.0fc))"  /// 
 "cte_se(fmt(%12.3fc) par) treated_se(fmt(%12.3fc) par) fill(fmt(%12.0fc)) cte_se_youth(fmt(%12.3fc) par) treated_se_youth(fmt(%12.3fc) par) fill(fmt(%12.0fc)) " /// 
  "pvalue_cte(fmt(%12.0fc)) pvalue(fmt(%12.3fc) par([ ])) fill(fmt(%12.0fc)) pvalue_cte(fmt(%12.0fc)) pvalue_youth(fmt(%12.3fc) par([ ])) fill(fmt(%12.0fc)) ") /// 
collabels("Untreated" "Diff.Treated" "N" "Untreated" "Diff.Treated"  "N")  /// 
mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines substitute(\_ _) eqlabels(none) title(none) nonumbers 

sleep 3000

 
 esttab using "$appendix/tab_b1.tex", replace /// 
cells(" cte_2009(fmt(%12.3fc)) high_2009(fmt(%12.3fc)) low_2009(fmt(%12.3fc)) N_2009(fmt(%12.0fc))  cte_youth9(fmt(%12.3fc)) high_youth9(fmt(%12.3fc)) low_youth9(fmt(%12.3fc)) N_youth9(fmt(%12.0fc))"  /// 
 "cte_se_2009(fmt(%12.3fc) par) high_se_2009(fmt(%12.3fc) par) low_se_2009(fmt(%12.3fc) par) fill(fmt(%12.0fc)) cte_se_youth9(fmt(%12.3fc) par) high_se_youth9(fmt(%12.3fc) par) low_se_youth9(fmt(%12.3fc) par) fill(fmt(%12.0fc)) " /// 
 "pvalue_cte(fmt(%12.0fc)) pvalue_h2009(fmt(%12.3fc) par([ ])) pvalue_l2009(fmt(%12.3fc) par([ ])) fill(fmt(%12.0fc)) pvalue_cte(fmt(%12.0fc)) pvalue_h2009y(fmt(%12.3fc) par([ ])) pvalue_l2009y(fmt(%12.3fc) par([ ])) fill(fmt(%12.0fc))") ///  
collabels("Untreated" "High" "Low" "N" "Untreated" "High" "Low" "N")  /// 
mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines substitute(\_ _) eqlabels(none) title(none) nonumbers 


**** PRICE DISTRIBUTION: REPORTED 2013 PNS - APPENDIX FIGURE B1
set scheme sj
kdensity price if young == 1, nograph generate(x fx)
. kdensity price if treated==0 & young == 1, nograph generate(fx0) at(x)
. kdensity price if treated==1 & young == 1, nograph generate(fx1) at(x)
. kdensity price if treated==1 & young == 1 & t2010 == 0 & t2011==0, nograph generate(fx2) at(x)
. label var fx0 "No smoking ban"
. label var fx1 "Local smoking bans"
. label var fx2 "Local smoking bans since 2009"

line fx0 fx1 fx2 x, sort ytitle(Density, size(medsmall) margin(medsmall)) /// 
 xtitle(Price paid for a pack of cigarette, size(medsmall)) xline(3.5, lcolor(gs10)) /// 
 legend(size(medsmall) row(2)) graphregion(color("white"))
graph export "$appendix/fig_b1_prices.png", replace 


*** PRICE INDEX FROM IPCA - APPENDIX FIGURE B2
import delimited "$data/raw/ipca_cigarro.csv", varnames(1) encoding(UTF-8) clear delimiter(";")
drop if v10 == ""
destring v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13, dpcomma replace
drop if v1 == ""
forvalues i = 2(1)13{
	local j = 2004 + `i'
rename v`i' ipca`j'
}

drop ipca2014-ipca2017
drop if v1 == "Brasil"
replace v1 = substr(v1, -3, 2)
rename v1 uf
drop if uf == "MS" | uf == "ES" // no data

reshape long ipca, i(uf) j(year)
gen treated = 0
replace treated = 1 if uf == "SP" | uf == "PA" | uf == "PR" | uf == "BA" | uf == "GO" | uf == "RJ"
collapse (mean) ipca, by (treated year)
 
xtset treated year
xtline ipca, overlay ylabel (0(5)30) xlabel(2006(1)2013) xtitle("") ytitle(Cigarette price index, size(medsmall) margin(medsmall) ) /// 
 graphregion(color("white")) legend(lab(1 "No smoking ban") lab(2 "Local smoking bans") size(medsmall) ) 
graph export "$appendix/fig_b2_prices.png", replace 

clear all