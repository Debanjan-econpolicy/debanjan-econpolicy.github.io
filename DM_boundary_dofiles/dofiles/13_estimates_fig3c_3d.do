*******************************************************************************
************************ PREVALENCE LEAVE-ONE-OUT *****************************
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
gen trend = .
replace trend = year - 2004 
gen partrend_high = trend*enforcement_higher
gen partrend_low = trend*enforcement_low
replace t2009 = 2 if enforcement_low == 1

xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef_low = temp[1,12..16]
matrix coef_high = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low = A[1,12..16]
matrix var_high = A[1,20..24]

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci_base = r(CI_16)'
matrix ci_base_trend = r(CI_9)'

*************************REGRESSION COEFFICIENTS*******************************
*** Removing Salvador/Bahia (uf == 29)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 29 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low29 = temp[1,12..16]
matrix coef_high29 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low29 = A[1,12..16]
matrix var_high29 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low29 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high29 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low29 coef_high29 var_low29 var_high29 pvalue_low29 pvalue_high29 {
matrix colnames `x' =  t1 t2 t3 t4 Trend 
}
scalar nobs29 = e(N)
scalar nind29 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f29 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF29 = r(p)

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci29 = r(CI_16)'
matrix ci29_trend = r(CI_9)'

*** Removing Rio de Janeiro (uf == 33)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 33 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low33 = temp[1,12..16]
matrix coef_high33 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low33 = A[1,12..16]
matrix var_high33 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low33 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high33 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low33 coef_high33 var_low33 var_high33 pvalue_low33 pvalue_high33 {
matrix colnames `x' = t1 t2 t3 t4 Trend 
}

scalar nobs33 = e(N)
scalar nind33 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f33 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF33 = r(p)

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci33 = r(CI_16)'
matrix ci33_trend = r(CI_9)'

*** Removing Sao Paulo (uf == 35)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 35 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low35 = temp[1,12..16]
matrix coef_high35 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low35 = A[1,12..16]
matrix var_high35 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low35 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high35 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low35 coef_high35 var_low35 var_high35 pvalue_low35 pvalue_high35 {
matrix colnames `x' = t1 t2 t3 t4 Trend 
}

scalar nobs35 = e(N)
scalar nind35 = e(N_g)
 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f35 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF35 = r(p)
boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci35 = r(CI_16)'
matrix ci35_trend = r(CI_9)'

*** Removing Curitiba (uf == 41)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 41 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low41 = temp[1,12..16]
matrix coef_high41 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low41 = A[1,12..16]
matrix var_high41 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
{t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low41 =  r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high41 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low41 coef_high41 var_low41 var_high41 pvalue_low41 pvalue_high41 {
matrix colnames `x' = t1 t2 t3 t4 Trend 
}

scalar nobs41 = e(N)
scalar nind41 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f41 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF41 = r(p)

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci41 = r(CI_16)'
matrix ci41_trend = r(CI_9)'

*** Removing  (uf == 50)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 50 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low50 = temp[1,12..16]
matrix coef_high50 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low50 = A[1,12..16]
matrix var_high50 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low50 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high50 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low50 coef_high50 var_low50 var_high50 pvalue_low50 pvalue_high50 {
matrix colnames `x' =  t1 t2 t3 t4 Trend 
}

scalar nobs50 = e(N)
scalar nind50 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f50 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF50 = r(p)
boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci50 = r(CI_16)'
matrix ci50_trend = r(CI_9)'

*** Removing  (uf == 52)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 52 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low52 = temp[1,12..16]
matrix coef_high52 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low52 = A[1,12..16]
matrix var_high52 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
  {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low52 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high52 =  r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low52 coef_high52 var_low52 var_high52 pvalue_low52 pvalue_high52 {
matrix colnames `x' =  t1 t2 t3 t4 Trend 
}

scalar nobs52 = e(N)
scalar nind52 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f52 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF52 = r(p)

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci52 = r(CI_16)'
matrix ci52_trend = r(CI_9)'

*** Removing Rio de Janeiro and SP (uf == 33)
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  if uf != 33 & uf != 35 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low335 = temp[1,12..16]
matrix coef_high335 = temp[1,20..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low335 = A[1,12..16]
matrix var_high335 = A[1,20..24]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low335 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high335 = r(p_6), r(p_7), r(p_8), r(p_9), r(p_10)

foreach x in coef_low335 coef_high335 var_low335 var_high335 pvalue_low335 pvalue_high335 {
matrix colnames `x' = t1 t2 t3 t4 Trend 
}

scalar nobs335 = e(N)
scalar nind335 = e(N_g)

 **Wald/F test 
test t_3_high t_2_high t_1_high 
scalar f335 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638) 
scalar pF335 = r(p)

boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci335 = r(CI_16)'
matrix ci335_trend = r(CI_9)'

*** Removing Rio de Janeiro and SP , no linear trends
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 t_4_low t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low t_4_high t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high  if uf != 33 & uf != 35  /// 
 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low335_not = temp[1,13..16],.
matrix coef_high335_not = temp[1,21..24],.
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low335_not = A[1,13..16],.
matrix var_high335_not = A[1,21..24],.
boottest {t1_low} {t2_low} {t3_low} {t4_low}  /// 
 {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)
matrix pvalue_low335_not = r(p_1), r(p_2), r(p_3), r(p_4), .
matrix pvalue_high335_not = r(p_5), r(p_6), r(p_7), r(p_8), .

foreach x in coef_low335_not coef_high335_not var_low335_not var_high335_not pvalue_low335_not pvalue_high335_not {
matrix colnames `x' = t1 t2 t3 t4 Trend 
estadd matrix `x'
}

scalar nobs335_not = e(N)
scalar nind335_not = e(N_g)

 **Wald/F test 
test t_4_high t_3_high t_2_high t_1_high 
scalar f335_not = r(F)
boottest t_4_high t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638) 
scalar pF335_not = r(p)

boottest {t_4_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{t_4_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high},  cluster(uf) seed(982638) nograph
matrix ci335_not = r(CI_16)'

********************* APPENDIX TABLE B7 ***************************
 
foreach i in  coef_low29 coef_high29 coef_low33 coef_high33 coef_low35 coef_high35  ///
coef_low41 coef_high41 coef_low50 coef_high50 coef_low52 coef_high52 ///
var_low29 var_high29 var_low33 var_high33 var_low35 var_high35  ///
var_low41 var_high41 var_low50 var_high50 var_low52 var_high52 ///
pvalue_low29 pvalue_high29 pvalue_low33 pvalue_high33 pvalue_low35 pvalue_high35  ///
pvalue_low41 pvalue_high41 pvalue_low50 pvalue_high50 pvalue_low52 pvalue_high52 ///
coef_low335_not coef_high335_not var_low335_not var_high335_not pvalue_low335_not pvalue_high335_not /// 
coef_low335 coef_high335 var_low335 var_high335 pvalue_low335 pvalue_high335 /// 
ci29 ci33 ci35 ci41 ci50 ci52 ci335 ci335_not {
	estadd matrix `i', replace
 }

 foreach j in nobs29 nobs33 nobs35 nobs41 nobs50 nobs52 nind29 nind33 nind35 nind41 nind50 nind52  /// 
 f29 f33 f35 f41 f50 f52 pF29 pF33 pF35 pF41 pF50 pF52 nobs335 nind335 f335 pF335 nobs335_not nind335_not f335_not pF335_not {
	estadd scalar `j', replace
 }
 
***Baseline average

bysort year t2009: egen tot_weight_prev29 = total(weight) if uf != 29
bysort year t2009: egen tot_weight_prev33 = total(weight) if uf != 33
bysort year t2009: egen tot_weight_prev35 = total(weight) if uf != 35
bysort year t2009: egen tot_weight_prev335 = total(weight) if uf != 35 & uf != 33
bysort year t2009: egen tot_weight_prev41 = total(weight) if uf != 41
bysort year t2009: egen tot_weight_prev50 = total(weight) if uf != 50
bysort year t2009: egen tot_weight_prev52 = total(weight) if uf != 52

gen smoke_prev29 = smoke*(weight/tot_weight_prev29) if uf != 29
gen smoke_prev33 = smoke*(weight/tot_weight_prev33) if uf != 33
gen smoke_prev35 = smoke*(weight/tot_weight_prev35) if uf != 35
gen smoke_prev335 = smoke*(weight/tot_weight_prev335) if uf != 33 & uf != 35
gen smoke_prev41 = smoke*(weight/tot_weight_prev41) if uf != 41
gen smoke_prev50 = smoke*(weight/tot_weight_prev50) if uf != 50
gen smoke_prev52 = smoke*(weight/tot_weight_prev52) if uf != 52


bysort year t2009: egen prevalence29 = sum(smoke_prev29) if uf != 29
bysort year t2009: egen prevalence33 = sum(smoke_prev33) if uf != 33
bysort year t2009: egen prevalence335 = sum(smoke_prev335) if uf != 33 & uf != 35
bysort year t2009: egen prevalence35 = sum(smoke_prev35) if uf != 35
bysort year t2009: egen prevalence41 = sum(smoke_prev41) if uf != 41
bysort year t2009: egen prevalence50 = sum(smoke_prev50) if uf != 50
bysort year t2009: egen prevalence52 = sum(smoke_prev52) if uf != 52

sum prevalence29 if t2009 == 1 & year ==2009 & uf != 29
scalar mean_prev_high29 = r(mean)

sum prevalence33 if t2009 == 1 & year ==2009 & uf != 33
scalar mean_prev_high33 = r(mean)

sum prevalence335 if t2009 == 1 & year ==2009 & uf != 33 & uf != 35
scalar mean_prev_high335 = r(mean)

sum prevalence35 if t2009 == 1 & year ==2009 & uf != 35
scalar mean_prev_high35 = r(mean)

sum prevalence41 if t2009 == 1 & year ==2009 & uf != 41
scalar mean_prev_high41 = r(mean)

sum prevalence50 if t2009 == 1 & year ==2009 & uf != 50
scalar mean_prev_high50 = r(mean)

sum prevalence52 if t2009 == 1 & year ==2009 & uf != 52
scalar mean_prev_high52 = r(mean)

foreach k in mean_prev_high29 mean_prev_high33 mean_prev_high335 mean_prev_high35 mean_prev_high41 mean_prev_high50 mean_prev_high52  {
	estadd scalar `k'
}

 
esttab using "$appendix/tab_b7.tex", /// 
cells("coef_high29(fmt(%12.3f)) coef_high41(fmt(%12.3f)) coef_high50(fmt(%12.3f)) coef_high52(fmt(%12.3f)) coef_high33(fmt(%12.3f)) coef_high35(fmt(%12.3f))  coef_high335(fmt(%12.3f)) coef_high335_not(fmt(%12.3f))"  /// 
"var_high29(fmt(%12.3f) par) var_high41(fmt(%12.3f) par)  var_high50(fmt(%12.3f) par) var_high52(fmt(%12.3f) par) var_high33(fmt(%12.3f) par) var_high35(fmt(%12.3f) par)   var_high335(fmt(%12.3f) par) var_high335_not(fmt(%12.3f) par) " ///
"pvalue_high29(fmt(%12.3f) par([ ])) pvalue_high41(fmt(%12.3f) par([ ])) pvalue_high50(fmt(%12.3f) par([ ]))  pvalue_high52(fmt(%12.3f) par([ ])) pvalue_high33(fmt(%12.3f) par([ ])) pvalue_high35(fmt(%12.3f) par([ ]))  pvalue_high335(fmt(%12.3f) par([ ]))  pvalue_high335_not(fmt(%12.3f) par([ ]))") ///
stats(f29 f41 f50 f52 f33 f35 f335 f335_not pF29 pF41 pF50 pF52 pF33 pF35 pF335 pF335_not  /// 
mean_prev_high29 mean_prev_high41  mean_prev_high50 mean_prev_high52 mean_prev_high33 mean_prev_high35 mean_prev_high335 mean_prev_high335 /// 
nobs29 nobs41 nobs50 nobs52  nobs33 nobs35 nobs335 nobs335_not nind29 nind41 nind50 nind52  nind33 nind35 nind335 nind335_not, ///
 layout("@ @ @ @ @ @ @ @" "@ @ @ @ @ @ @ @" "@ @ @ @ @ @ @ @" "@ @ @ @ @ @ @ @"  "@ @ @ @ @ @ @ @") label("F-stat" "P-value" "Average" "N \times T" "N") ///
fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc  %9.3fc  %9.3fc  %9.3fc %12.0fc)) /// 
 rename( t1 "2010" t2 "2011" t3 "2012" t4 "2013" Trend "\textit{Trends}") /// 
  collabels("(29)"  "(41)" "(50)"  "(52)" "(33)" "(35)"  "(33/35)" "(33/35)"  ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
 
 
 ************** FIGURE 3C: LEAVE-ONE-OUT
matrix coef2013 = coef_high[1,4], coef_high41[1,4], coef_high35[1,4], coef_high33[1,4], coef_high50[1,4], coef_high52[1,4],  coef_high29[1,4], coef_high335[1,4],coef_high335_not[1,4]
matrix var2013 = var_high[1,4], var_high41[1,4],  var_high35[1,4], var_high33[1,4],var_high50[1,4], var_high52[1,4], var_high29[1,4], var_high335[1,4], var_high335_not[1,4]

matrix coef_trend = coef_high[1,5], coef_high41[1,5], coef_high35[1,5], coef_high33[1,5], coef_high50[1,5], coef_high52[1,5],  coef_high29[1,5], coef_high335[1,5], 0
matrix var_trend = var_high[1,5], var_high41[1,5],  var_high35[1,5], var_high33[1,5],var_high50[1,5], var_high52[1,5], var_high29[1,5], var_high335[1,5],0

matrix temp = 0\0
matrix ci_trend = ci_base_trend, ci41_trend, ci35_trend, ci33_trend, ci50_trend, ci52_trend, ci29_trend, ci335_trend, temp
matrix colnames ci_trend = c1 c2 c3 c4 c5 c6 c7 c8 c9
 

coefplot (matrix(coef2013[1]), se(var2013[1]) drop(c1) label(Effect by 2013) color(blue)  ciopts( lcolor(blue))  ) ///
(matrix(coef2013[1]), se(var2013[1])  keep(c1) nokey color(blue)  ciopts( lcolor(blue) lpattern(dash)) ) ///
(matrix(coef_trend[1]), se(var_trend[1]) drop(c1) label(Linear Trend Coefficient) color(black) msymbol(S)  ciopts( lcolor(black)) offset(-0.1) ) ///
(matrix(coef_trend[1]), se(var_trend[1]) keep(c1) nokey color(black) msymbol(S)  ciopts( lcolor(black) lpattern(dash))  ), ///
 baselevels omitted order(c1 c2 c3 c4 c5 c6 c7 c8 c9)  graphregion(color(white)) bgcolor(white) ///
 ylabel(1 "Baseline" 2 "PR" 3 "SP" 4 "RJ" 5 "MS" 6 "GO" 7 "BA" 8 "SP+RJ" 9 "SP+RJ", labsize(large) ) ///
xline(0, lcolor(gray)) ytitle("State capital dropped", size(vlarge))  xtitle("") xlabel(, labsize(vlarge)) legend(size(large))
graph export "$results/fig3c_prevalence.png", replace



 **************** Fig. 3D -- Without RJ and SP, no Linear Trends
 xtreg smoke i.year t_4_low t_3_low t_2_low t_1_low t1_low t2_low t3_low t4_low  /// 
t_4_high t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high if uf != 33 & uf != 35   [aw = weight], fe vce(cluster uf)
est sto reg2
boottest {t_4_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{t_4_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)


 drop if uf == 33 | uf == 35
bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = 100*smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)
sum prevalence if year ==2009 & (t2009 == 1)
local avg_high: di %9.1fc `r(mean)' 
sum prevalence if year ==2009 & (t2009 == 2)
local avg_low: di %9.1fc `r(mean)' 

 coefplot  (reg2, color(red) msymbol(S) ciopts(lpattern(shortdash) lcolor(red)) offset(-0.1) ///
  keep( t_4_low t_3_low t_2_low t_1_low t1_low t2_low t3_low t4_low  2005.year) /// 
  rename(t_4_low = t_4 t_3_low = t_3 t_2_low = t_2 t_1_low = t_1 t1_low = t1 t2_low = t2 /// 
  t3_low = t3 t4_low = t4)) ///
(reg2, msymbol(D) color(blue) ciopts(lpattern(dash) lcolor(blue)) offset(0.1) ///
keep(t_4_higher t_3_higher t_2_higher t_1_higher t1_higher t2_higher t3_higher t4_higher 2005.year) ///
rename(t_4_higher = t_4 t_3_higher = t_3 t_2_higher = t_2 t_1_higher = t_1 t1_higher = t1 t2_higher = t2 /// 
t3_higher = t3 t4_higher = t4)), ///
order(t_4 t_3 t_2 t_1 2005.year t1 t2 t3 t4 ) baselevels omitted /// 
xlabel(1 "2005" 2 "2006"  3 "2007" 4 "2008" 5 "2009" 6 "2010" 7 "2011" 8 "2012" 9 "2013", labsize(vlarge) angle(45)) ///
			vertical graphregion(color(white)) bgcolor(white) ///
			legend(order(2 "Low enforcement " 4 "High enforcement ") rows(1) size(vlarge)) ///
			xline(5.5, lcolor(black) ) ytitle("proportion of smokers", size(large))  xtitle("")  ///
	       yline(0, lwidth(vthin) lpattern(dash) lcolor(black)) ylabel(-0.03(0.01)0.02,labsize(large)) ///
		      text(-0.023 3.2 "{bf:Baseline avg.:}",  size(medlarge)) /// 
		   text(-0.028 2 "`avg_low'%",  size(medlarge) color(red))   text(-0.028 3 "and",  size(large))  /// 
		   text(-0.028 3.6 "`avg_high'%",  size(medlarge) color(blue) )
graph export "$results/fig3d_prevalence.png",replace
 

clear all
