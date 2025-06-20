clear all
set maxvar 10000
set matsize 10000

***************************************************************************************
**CLEANING 2008 PNAD AND APPENDING WITH CROSS-SECTION OF PNS 2013 RETROSPECTIVE TO 2008
***************************************************************************************
use "$data/raw/pnad2008pes.dta", clear
destring uf, replace

*Keeping only individuals that answered to the tobacco survey at PNAD
keep if SELEC ==1
rename (PESPET v8005) (weight age)
gen indicator = 0
gen male = (v0302==2)
gen rural = ( v4728 == 4 | v4728 == 5 | v4728 == 6 | v4728 == 7 | v4728 == 8)

/*
*** PNAD 2008 is not representative to state's capital. We created a proxy based on variables v4727 and v4728:
** v4727=1: identifies metropolitan region for states 15, 23, 26, 29, 31, 33, 35, 41, 43, 53 
** v4728=1: urban city for remaining states
*/

gen capital = 0
replace capital = 1 if (uf==11 & v4728==1) | (uf==12 & v4728==1) | (uf==13 & v4728==1) | /// 
(uf==14 & v4728==1) | (uf==15 & v4727==1) | (uf==16 & v4728==1) | (uf==17 & v4728==1) | /// 
(uf==21 & v4728==1) | (uf==22 & v4728==1) | (uf==23 & v4727==1) | (uf==24 & v4728==1) | /// 
(uf==25 & v4728==1) | (uf==26 & v4727==1) | (uf==27 & v4728==1) | (uf==28 & v4728==1) | /// 
(uf==29 & v4727==1) | (uf==31 & v4727==1) | (uf==32 & v4728==1) | (uf==33 & v4727==1) | /// 
(uf==35 & v4727==1) | (uf==41 & v4727==1) | (uf==42 & v4728==1) | (uf==43 & v4727==1) | /// 
(uf==50 & v4728==1) | (uf==51 & v4728==1) | (uf==52 & v4728==1) | (uf==53 & v4727==1) 

*** Smoking variables
gen smoke = (v2701 == 1)
gen former_regular = (v2703 == 1)

gen starting_age = .
replace starting_age = v2705 if v2701 == 1 & v2705 != .  //current daily smoke starting age 
replace starting_age = v2707 if v2701 == 1 & v2707 != . //current daily smoke starting age 
replace starting_age = age - v2708 if v2701 == 1 & v2708 != . &  starting_age == .
replace starting_age = age - v2706 if v2701 == 1 & v2706 != . & starting_age == .
replace starting_age = v2712 if v2701 == 3 & v2702 == 2 & v2712 != . //current causal smoker, former daily smoker starting age 
replace starting_age = v2714 if v2701 == 3 & v2702 == 2 & v2714 != . //current causal smoker, former daily smoker starting age 
replace starting_age = age - v2715 if v2701 == 3 & v2702 == 2  & v2715 != . & starting_age == .
replace starting_age = age - v2713 if v2701 == 3 & v2702 == 2  & v2713 != . & starting_age == .
replace starting_age = v2717 if v2703 == 1 & v2717 != .  // former daily smoker starting age 
replace starting_age = v2719 if v2703 == 1 & v2719 != . // former daily smoker starting age 
replace starting_age = age - v2720 if v2703 == 1  & v2720 != . & starting_age == .
replace starting_age = age - v2718 if v2703 == 1  & v2718 != . & starting_age == .

** Dropping individuals that didn't remember starting age
drop if starting_age == . & former_regular == 1 & (v27171 == 1 | v27191 == 2)
drop if starting_age == . & smoke ==1 & (v27051 == 1 | v27061 == 2 | v27071 == 1 | v27121 == 2)

**Correcting mistakes
replace starting_age = age - starting_age if starting_age != . & starting_age < 6
bysort smoke: sum starting_age age
bysort former_regular: sum starting_age age

gen smoking_time = .
replace smoking_time = age - starting_age if starting_age != .

**Quit time only for former regular smokers (current not smokers) 
gen quit_time = .
replace quit_time = v7217 if former_regular == 1 // measured in years
replace quit_time = 0 if former_regular == 1 & (v2721 == 5 | v2721 == 7) // measured in weeks or days (less than 3 months)
** Measure in months:
replace quit_time = 0 if former_regular == 1 & v2721 == 3 & v7218 < 6 & v7218 != . 
replace quit_time = 1 if former_regular == 1 & v2721 == 3 & v7218 >= 6 & v7218 < 18 & v7218 != . 
replace quit_time = 2 if former_regular == 1 & v2721 == 3 & v7218 >= 18 & v7218 < 30 & v7218 != . 
replace quit_time = 3 if former_regular == 1 & v2721 == 3 & v7218 >= 30 & v7218 < 42 & v7218 != . 
replace quit_time = 4 if former_regular == 1 & v2721 == 3 & v7218 >= 42 & v7218 < 54 & v7218 != . 
replace quit_time = 5 if former_regular == 1 & v2721 == 3 & v7218 >= 54 & v7218 < 66 & v7218 != . 
replace quit_time = 6 if former_regular == 1 & v2721 == 3 & v7218 >= 66 & v7218 < 78 & v7218 != . 

replace smoke = 1 if former_regular ==1 & quit_time == 0
replace former_regular = 0 if smoke==1


keep uf indicator male rural weight age capital smoke former_regular smoking_time quit_time starting_age
**Appending with PNS retrospective to 2008
append using "$data/pns2013_2008.dta"
sort indicator

gen t2009 = (uf == 13 | uf == 14 | uf == 25 | uf == 35 | uf == 41 | uf == 52 | uf == 15 | uf == 28 | uf == 29 | uf == 12 | uf == 50 | uf == 33)
gen treated = (t2009 == 1 | uf == 22 |  uf == 51 )

label var indicator "retrospective data from PNS 2013"
label var uf "federal state" 
label var male "indicator for gender (male=1)"
label var capital "indicator for state capital"
label var rural "indicator for rural area"
label var smoke "indicator if regular smoker"
label var former_regular "current non-smoker, former daily smoker"
label var starting_age "age when started smoking on a daily basis"
label var smoking_time "measures smoking addiction for current smokers (age - smoking_age)"
label var quit_time "number of years since quit smoking"
label var t2009 "cohort treated in 2009" 
label var treated "cohorts treated in 2009, 2010, or 2011" 
save "$data/pns2013_2008.dta", replace


***************************************************************************************
******************************* DATA FIT **********************************************
***************************************************************************************
use "$data/pns2013_2008.dta", clear
egen group=group(uf)
gen smokers_age = .
replace smokers_age = age if smoke == 1
svyset [pweight = weight]
gen youth = 0
replace youth = 1 if age >=15 & age <= 29
replace quit_time = . if quit_time == 0
rename (indicator starting_age) (PNS initiation_age)

***Sample size: Appendix Table A3
eststo s1: estpost tab PNS 
eststo s2: estpost tab PNS if age <=65
eststo s3: estpost tab PNS if age <=29

esttab s1 s2 s3 using "$appendix/tab_a3_sample.tex", replace main(b %12.0f) ///
 mtitles("All sample" "Age 15 to 65" "Age 15 to 29")  noparentheses nostar nogaps compress


****Overall mean difference tests: Appendix Tables A4 and A5
keep if age <= 65

foreach x in age male capital rural smoke former_regular initiation_age smokers_age quit_time {
reg `x' PNS if age < 30 [aw = weight], vce(cluster group)
est sto `x'_y

reg `x' PNS [aw = weight], vce(cluster group)
est sto `x'    
}

reg youth PNS [aw = weight], vce(cluster group)
est sto youth

esttab age male capital rural smoke former_regular initiation_age smokers_age quit_time using "$appendix/tab_a4.tex", /// 
replace  cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) keep(PNS)  starlevels(* 0.10 ** 0.05 *** 0.01)

esttab youth age_y male_y capital_y rural_y smoke_y former_regular_y initiation_age_y smokers_age_y quit_time_y using "$appendix/tab_a5.tex", /// 
replace  cells(b(star fmt(%9.3f)) se(par fmt(%9.3f))) keep(PNS)  starlevels(* 0.10 ** 0.05 *** 0.01)

********************************************************************************
****************************DISTRIBUTIONS***************************************
********************************************************************************
set scheme s1mono
***GOLDMAN AND KAPLAN DISTRIBUTION 
distcomp smokers_age if age<30, by(PNS) pvalue alpha(0.1)
graph export "$appendix/fig_a3a.png", replace	
matrix A =  r(rej_gof10),  r(p_gof)
mat coln A = "Reject" "P-value"
mat rown A = "smokers age" 
esttab matrix(A, fmt(%9.1f)) using "$appendix/fig_a3_distcomp_global.tex", replace 

distcomp initiation_age if age<30, by(PNS) pvalue alpha(0.1)
graph export "$appendix/fig_a3b.png", replace	
matrix A =  r(rej_gof10),  r(p_gof)
mat coln A = "Reject" "P-value"
mat rown A = "initiation age" 
esttab matrix(A, fmt(%9.1f)) using "$appendix/fig_a3_distcomp_global.tex", append 

distcomp quit_time if age<30, by(PNS) pvalue alpha(0.1)
graph export "$appendix/fig_a3c.png", replace	
matrix A =  r(rej_gof10),  r(p_gof)
mat coln A = "Reject" "P-value"
mat rown A = "quit time" 
esttab matrix(A, fmt(%9.1f)) using "$appendix/fig_a3_distcomp_global.tex", append 


****Smokers age
twoway (histogram smokers_age if PNS==1, start(15) width(5) color(black%30)) ///
       (histogram smokers_age if PNS==0, start(15) width(5) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smokers' age") graphregion(fcolor("white")) xlabel(15(5)65)
graph export "$appendix/fig_a2a.png", replace	   
   
	  	   
preserve
keep if age < 30
twoway (histogram smokers_age if PNS==1, start(15) width(2) color(black%30)) ///
       (histogram smokers_age if PNS==0, start(15) width(2) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smokers' age") graphregion(fcolor("white")) xlabel(15(2)30)
graph export "$appendix/fig_a2b.png", replace	   
restore


****Initiation age
twoway (histogram initiation_age if PNS==1, start(5) width(5) color(black%30)) ///
       (histogram initiation_age if PNS==0, start(5) width(5) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smoking initiation age") graphregion(fcolor("white")) xlabel(5(5)60)
graph export "$appendix/fig_a2c.png", replace	   
	   
preserve
keep if age < 30
twoway (histogram initiation_age if PNS==1, start(5) width(2) color(black%30)) ///
       (histogram initiation_age if PNS==0, start(5) width(2) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smoking initiation age") graphregion(fcolor("white")) xlabel(5(5)30)
graph export "$appendix/fig_a2d.png", replace	   
restore


****Quit time
twoway (histogram quit_time if PNS==1, start(0) width(5) color(black%30)) ///
       (histogram quit_time if PNS==0, start(0) width(5) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smoking cessation time") graphregion(fcolor("white")) xlabel(0(5)60)
graph export "$appendix/fig_a2e.png", replace	   
	   
preserve
keep if age < 30 & quit_time <= 15
twoway (histogram quit_time if PNS==1, start(0) width(2) color(black%30)) ///
       (histogram quit_time if PNS==0, start(0) width(2) ///
	   fcolor(none) lcolor(black)), legend(order(1 "PNS" 2 "PNAD" )) /// 
	   xtitle("Smoking cessation time") graphregion(fcolor("white")) xlabel(0(5)15)
graph export "$appendix/fig_a2f.png", replace	   
restore

********************************************************************************
***************** APPENDIX TABLE A6: GOODNESS OF FIT TEST **********************
********************************************************************************
estimates drop _all 

svy: tab smokers_age PNS, pearson
matrix stat_pearson = e(F_Pear) 
matrix pvalue_pearson  = e(p_Pear) 

svy: tab smokers_age PNS if age<30, pearson
matrix stat_pearson_y = e(F_Pear) 
matrix pvalue_pearson_y =  e(p_Pear) 

ksmirnov smokers_age, by(PNS)
matrix stat_ks = r(D) 
matrix pvalue_ks  = r(p) 

ksmirnov smokers_age if age<30, by(PNS)
matrix stat_ks_y = r(D) 
matrix pvalue_ks_y  == r(p) 

foreach x in initiation_age quit_time {
svy: tab `x' PNS, pearson
matrix stat_pearson =stat_pearson, e(F_Pear) 
matrix pvalue_pearson  =pvalue_pearson, e(p_Pear) 

svy: tab `x' PNS if age<30, pearson
matrix stat_pearson_y =stat_pearson_y, e(F_Pear) 
matrix pvalue_pearson_y  =pvalue_pearson_y, e(p_Pear) 

ksmirnov `x', by(PNS)
matrix stat_ks = stat_ks, r(D) 
matrix pvalue_ks  =pvalue_ks, r(p) 

ksmirnov `x' if age<30, by(PNS)
matrix stat_ks_y =stat_ks_y, r(D) 
matrix pvalue_ks_y  =pvalue_ks_y, r(p)     	
}

foreach x in stat_pearson pvalue_pearson stat_ks pvalue_ks { 
matrix colnames `x' = SmokersAge InitiationAge QuitTime
matrix colnames `x'_y = SmokersAge InitiationAge QuitTime
estadd matrix `x'
estadd matrix `x'_y
}

esttab using "$appendix/tab_a6.tex", /// 
cells("stat_pearson(fmt(%12.3f)) stat_pearson_y(fmt(%12.3f)) stat_ks(fmt(%12.3f)) stat_ks_y(fmt(%12.3f))" ///
 "pvalue_pearson(fmt(%12.3f) par([ ])) pvalue_pearson_y(fmt(%12.3f) par([ ])) pvalue_ks(fmt(%12.3f) par([ ])) pvalue_ks_y(fmt(%12.3f) par([ ]))") /// 
  collabels("Pearson Adults" "Pearson Young Adults"  "K-S Adults" "K-S Young Adults") /// 
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  

  
********************************************************************************
*************APP. TABLE A7: DISTRIBUTIONS TREATED/ CONTROL**********************
********************************************************************************
estimates drop _all 
drop if uf == 11

svy: tab smokers_age treated if age<30 & PNS==1, pearson
matrix stat_pearson_all = e(F_Pear) 
matrix pvalue_pearson_all =  e(p_Pear) 

ksmirnov smokers_age if age<30 & PNS==1, by(treated)
matrix stat_ks_all = r(D) 
matrix pvalue_ks_all  == r(p) 

foreach x in initiation_age quit_time {
svy: tab `x' treated if age<30 & PNS==1, pearson
matrix stat_pearson_all =stat_pearson_all, e(F_Pear) 
matrix pvalue_pearson_all  =pvalue_pearson_all, e(p_Pear) 

ksmirnov `x' if age<30 & PNS==1, by(treated)
matrix stat_ks_all = stat_ks_all, r(D) 
matrix pvalue_ks_all  ==pvalue_ks_all, r(p) 
}

preserve
drop if treated == 1 & t2009 == 0
svy: tab smokers_age t2009 if age<30 & PNS==1, pearson
matrix stat_pearson_2009 = e(F_Pear) 
matrix pvalue_pearson_2009 =  e(p_Pear) 

ksmirnov smokers_age if age<30 & PNS==1, by(t2009)
matrix stat_ks_2009 = r(D) 
matrix pvalue_ks_2009  == r(p) 

foreach x in initiation_age quit_time {
svy: tab `x' t2009 if age<30 & PNS==1, pearson
matrix stat_pearson_2009 =stat_pearson_2009, e(F_Pear) 
matrix pvalue_pearson_2009  =pvalue_pearson_2009, e(p_Pear) 

ksmirnov `x' if age<30 & PNS==1, by(t2009)
matrix stat_ks_2009 = stat_ks_2009, r(D) 
matrix pvalue_ks_2009  ==pvalue_ks_2009, r(p) 
}
restore

foreach x in stat_pearson pvalue_pearson stat_ks pvalue_ks { 
matrix colnames `x'_all = SmokersAge InitiationAge QuitTime
matrix colnames `x'_2009 = SmokersAge InitiationAge QuitTime
estadd matrix `x'_all
estadd matrix `x'_2009
}

esttab using "$appendix/tab_a7.tex", /// 
cells("stat_pearson_all(fmt(%12.3f)) stat_pearson_2009(fmt(%12.3f)) stat_ks_all(fmt(%12.3f)) stat_ks_2009(fmt(%12.3f))" ///
 "pvalue_pearson_all(fmt(%12.3f) par([ ])) pvalue_pearson_2009(fmt(%12.3f) par([ ])) pvalue_ks_all(fmt(%12.3f) par([ ])) pvalue_ks_2009(fmt(%12.3f) par([ ]))") /// 
  collabels("Pearson All Treated" "Pearson 2009 Treated"  "K-S All treated" "K-S 2009 Treated") /// 
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  


estimates drop _all 
**********************************************************************************
************** APPENDIX TABLE B2: PREVALENCE IN 2008 PNAD ************************
**********************************************************************************
keep if PNS == 0 

reg smoke treated [aw = weight], vce(cluster uf)
matrix treated_adults = e(b)[1,1]
scalar cte_adults = e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix se_adults = A[1,1]
boottest treated, noci cluster(uf) seed(982638)
matrix p_adults = r(p)

reg smoke treated if age <30 [aw = weight], vce(cluster uf)
matrix treated_y = e(b)[1,1]
scalar cte_y = e(b)[1,2]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix se_y = A[1,1]
boottest treated, noci cluster(uf) seed(982638)
matrix p_y = r(p)

drop if treated == 1 & t2009 == 0

reg smoke t2009 [aw = weight], vce(cluster uf)
matrix treated_adults = treated_adults, e(b)[1,1]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix se_adults =se_adults, A[1,1]
boottest t2009, noci cluster(uf) seed(982638)
matrix p_adults =p_adults, r(p)
scalar nobs = e(N)

reg smoke t2009 if age <30 [aw = weight], vce(cluster uf)
matrix treated_y = treated_y, e(b)[1,1]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix se_y =se_y, A[1,1]
boottest t2009, noci cluster(uf) seed(982638)
matrix p_y =p_y, r(p)
scalar nobs_y = e(N)

foreach x in treated se p { 
matrix colnames `x'_adults = All 2009Cohort
matrix colnames `x'_y = All 2009Cohort
estadd matrix `x'_adults
estadd matrix `x'_y
}


 foreach j in nobs nobs_y cte_adults cte_y  {
	estadd scalar `j'
 }
 

esttab using "$appendix/tab_b2.tex", /// 
cells("treated_adults(fmt(%12.3f)) treated_y(fmt(%12.3f))"  "se_adults(fmt(%12.3f) par) se_y(fmt(%12.3f) par)" ///
 "p_adults(fmt(%12.3f) par([ ])) p_y(fmt(%12.3f) par([ ]))") /// 
stats(cte_adults cte_y  nobs nobs_y, layout("@ @ " "@ @  "  ) label("Average" "N") fmt(%9.3fc %9.3fc %12.0fc)) /// 
 collabels("Adults" "Young Adults") mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
clear all

erase "$data/pns2013_2008.dta"