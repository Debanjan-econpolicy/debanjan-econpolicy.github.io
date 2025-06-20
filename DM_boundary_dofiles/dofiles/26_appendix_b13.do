*******************************************************************************
************************ APPENDIX TABLE B13 ***********************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
set more off
xtset id year
xtdescribe
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 | t2010 == 1 | t2011 == 1

sort id year
by id: gen trend = year - 2004
gen partrend = trend*t2009
gen partrend_high = trend*enforcement_higher
gen partrend_low = trend*enforcement_low
replace t2009 = 2 if enforcement_higher == 1

** Baseline averages
bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = 100*smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)

sum prevalence if year ==2009 & (t2009 == 2)
scalar mean_prev_high = r(mean)

sum prevalence if year ==2009 & (t2009 == 1)
scalar mean_prev_low = r(mean)
drop tot_weight_prev smoke_prev prevalence

gen lincome = log(hh_income + 1)

*** Controlling for log of HH Income Per Capita and linear trends
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high i.year#c.lincome [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low1 = temp[1,12..16]
matrix coef_high1 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low1 =  A[1,12..16]
matrix var_high1 = A[1,20..24]
boottest {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low1 =  r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue_high1 = r(p_12), r(p_13), r(p_14), r(p_15), r(p_16)
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
 **Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f_low1 = r(F) 
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low1 = r(p)
test t_3_high t_2_high t_1_high
scalar f_high1 = r(F)  
 boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high1 = r(p)


*** Controlling for linear trends: heterogeneity by socioeconomic status -

*Averages
bysort year t2009 hh_income_above: egen tot_weight_prev = total(weight)
gen smoke_prev = 100*smoke*(weight/tot_weight_prev)
bysort year t2009 hh_income_above: egen prevalence = sum(smoke_prev)

sum prevalence if year ==2009 & (t2009 == 2) & hh_income_above == 1
scalar mean_prev_high_above = r(mean)

sum prevalence if year ==2009 & (t2009 == 2) & hh_income_above == 0
scalar mean_prev_high_below = r(mean)

sum prevalence if year ==2009 & (t2009 == 1) & hh_income_above == 1
scalar mean_prev_low_above = r(mean)

sum prevalence if year ==2009 & (t2009 == 1) & hh_income_above == 0
scalar mean_prev_low_below = r(mean)
drop tot_weight_prev smoke_prev prevalence

*Regressions

*** Below MW
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high if hh_income_above == 0 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low2 = temp[1,12..16]
matrix coef_high2 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low2 = A[1,12..16]
matrix var_high2 = A[1,20..24]
boottest {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low2 = r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue_high2 =  r(p_12), r(p_13), r(p_14), r(p_15), r(p_16)
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
 **Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f_low2 = r(F) 
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low2 = r(p)
test t_3_high t_2_high t_1_high
scalar f_high2 = r(F)  
 boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high2 = r(p)



** Above MW
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high if hh_income_above == 1 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low3 = temp[1,12..16]
matrix coef_high3 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low3 = A[1,12..16]
matrix var_high3 = A[1,20..24]
boottest {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low3 =  r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue_high3 = r(p_12), r(p_13), r(p_14), r(p_15), r(p_16)
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
 **Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f_low3 = r(F) 
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low3 = r(p)
test t_3_high t_2_high t_1_high
scalar f_high3 = r(F)  
 boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high3 = r(p)

********************* ADDING RESULTS TO SINGLE TABLE ***************************

forvalues i = 1(1)3{
foreach x in coef_low coef_high var_low var_high pvalue_low pvalue_high { 
matrix colnames `x'`i' =  t1 t2 t3 t4 Trend 
estadd matrix `x'`i'
}
foreach j in nobs nind f_low f_high pF_low pF_high{
	estadd scalar `j'`i'	
}
}
 
estadd scalar mean_prev_high
estadd scalar mean_prev_low
estadd scalar mean_prev_high_above
estadd scalar mean_prev_low_above
estadd scalar mean_prev_high_below
estadd scalar mean_prev_low_below

esttab using "$appendix/tab_b13.tex", /// 
cells("coef_high1(fmt(%12.3f)) coef_low1(fmt(%12.3f)) coef_high2(fmt(%12.3f)) coef_low2(fmt(%12.3f)) coef_high3(fmt(%12.3f)) coef_low3(fmt(%12.3f)) "  /// 
"var_high1(fmt(%12.3f) par) var_low1(fmt(%12.3f) par) var_high2(fmt(%12.3f) par) var_low2(fmt(%12.3f) par) var_high3(fmt(%12.3f) par) var_low3(fmt(%12.3f) par)" ///
"pvalue_high1(fmt(%12.3f) par([ ])) pvalue_low1(fmt(%12.3f) par([ ])) pvalue_high2(fmt(%12.3f) par([ ])) pvalue_low2(fmt(%12.3f) par([ ])) pvalue_high3(fmt(%12.3f) par([ ])) pvalue_low3(fmt(%12.3f) par([ ]))") ///
stats(f_high1 f_low1 f_high2 f_low2 f_high3 f_low3 pF_high1 pF_low1 pF_high2 pF_low2 pF_high3 pF_low3 ///
 mean_prev_high mean_prev_low   mean_prev_high_above mean_prev_low_above mean_prev_high_below mean_prev_low_below /// 
nobs1 nobs2 nobs3   nind1 nind2 nind3  , layout("@ @ @ @ @ @ " "@ @ @ @ @ @ "  "@ @ @ @ @  @ " "@ @ @  " "@ @ @") /// 
label("F-stat" "P-value" "Average" "N \times T" "N") /// 
fmt( %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc  %9.3fc %9.3fc  %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename( t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trend "\textit{Trends}") /// 
  collabels("High" "Low" "High - Below MW" "Low - Below MW" "High - Above MW" "Low - Above MW" ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
 
 clear all

 