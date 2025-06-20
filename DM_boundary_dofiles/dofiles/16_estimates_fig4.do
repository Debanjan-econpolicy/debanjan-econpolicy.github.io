*******************************************************************************
************************ CESSATION & INITIATION *******************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15 // keep only young adults
drop if t2008 == 1 | t2010 == 1 | t2011 == 1 // keep only main treated group

sort id year
by id: gen trend = year - 2004
gen partrend_high = trend*enforcement_higher
gen partrend_low = trend*enforcement_low
gen partrend = trend*t2009
by id: gen trend2 = year - 2008


****************************PRE-TREATMENT******************************************* 
**** Creating smoking variable that discounts pre-trends
*** Initiation
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1  partrend  if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coefin_trend=_b[partrend]
gen smoke_avg = smoke
replace smoke_avg = smoke_avg - `coefin_trend'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 

xtreg smoke d2006 d2007 d2008 d2009 t_3_low t_2_low t_1_low  partrend_low  /// 
t_3_high t_2_high t_1_high partrend_high if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coefin_low=_b[partrend_low]
local coefin_high=_b[partrend_high]
gen smoke2 = smoke
replace smoke2 = smoke2 - `coefin_low'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & enforcement_low == 1
replace smoke2 = smoke2 - `coefin_high'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & enforcement_higher == 1
matrix temp = e(b)
matrix coef_low1 = temp[1,5..7],0,temp[1,8]
matrix coef_high1 =  temp[1,9..11],0,temp[1,12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low1 = A[1,5..7],0, A[1,8]
matrix var_high1 = A[1,9..11],0,A[1,12]
scalar nobs1 = e(N)
scalar nind1 = e(N_g)

**Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f1_low = r(F)
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF1_low = r(p)

test t_3_high t_2_high t_1_high 
scalar f1_high = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF1_high = r(p)

boottest {t_3_low} {t_2_low} {t_1_low} {partrend_low} {t_3_high} {t_2_high} {t_1_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low1 = r(p_1), r(p_2), r(p_3), 0, r(p_4)
matrix pvalue_high1 =  r(p_5), r(p_6), r(p_7), 0, r(p_8)

*** Cessation
xtreg smoke d2006 d2007 d2008 d2009 t_3_low t_2_low t_1_low  partrend_low  /// 
t_3_high t_2_high t_1_high partrend_high if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coefces_low=_b[partrend_low]
local coefces_high=_b[partrend_high]
replace smoke2 = smoke - `coefces_low'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & enforcement_low == 1
replace smoke2 = smoke - `coefces_high'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & enforcement_higher == 1
matrix temp = -e(b)
matrix coef_low2 = temp[1,5..7],0,temp[1,8]
matrix coef_high2 =temp[1,9..11],0,temp[1,12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low2 = A[1,5..7],0, A[1,8]
matrix var_high2 = A[1,9..11],0,A[1,12]
scalar nobs2 = e(N)
scalar nind2 = e(N_g)

**Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f2_low = r(F)
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF2_low = r(p)

test t_3_high t_2_high t_1_high 
scalar f2_high = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF2_high = r(p)

boottest {t_3_low} {t_2_low} {t_1_low} {partrend_low} {t_3_high} {t_2_high} {t_1_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low2 = r(p_1), r(p_2), r(p_3), 0,r(p_4)
matrix pvalue_high2 =  r(p_5), r(p_6), r(p_7), 0, r(p_8)

xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1  partrend  if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coefces_trend=_b[partrend]
replace smoke_avg = smoke - `coefces_trend'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1


****************************POST-TREATMENT******************************************* 
*** Using the smoking variable that discounts pre-trends (from previous step)
xtreg smoke_avg d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 0 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef_avg_post = 0, temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_avg_post = 0, A[1,5..8]
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)

xtreg smoke_avg d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef_avg_post2 = 0, temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_avg_post2 = 0, A[1,5..8]
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)


xtreg smoke2 d2010 d2011 d2012 d2013 t1_low t2_low t3_low t4_low  /// 
t1_high t2_high t3_high t4_high if index9 == 0 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef_low3 = temp[1,5..8]
matrix coef_high3 =  temp[1,9..12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low3 = A[1,5..8]
matrix var_high3 = A[1,9..12]
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t1_low} {t2_low} {t3_low} {t4_low} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)
matrix pvalue_low3 = r(p_1), r(p_2), r(p_3), r(p_4)
matrix pvalue_high3 =  r(p_5), r(p_6), r(p_7), r(p_8)


xtreg smoke2 d2010 d2011 d2012 d2013 t1_low t2_low t3_low t4_low  /// 
t1_high t2_high t3_high t4_high if index9 == 1 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef_low4 = temp[1,5..8]
matrix coef_high4 = temp[1,9..12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low4 = A[1,5..8]
matrix var_high4 = A[1,9..12]
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t1_low} {t2_low} {t3_low} {t4_low} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)
matrix pvalue_low4 = r(p_1), r(p_2), r(p_3), r(p_4)
matrix pvalue_high4 =  r(p_5), r(p_6), r(p_7), r(p_8)

******************************************************************************
***************************** FIGURE 4  **************************************
****************************************************************************** 

matrix temp1 = 0, coef_low3
matrix temp2 = 0,var_low3
matrix temp3 = 0, coef_high3
matrix temp4 = 0,var_high3
matrix initiation = temp1 \ temp2 \ temp3 \ temp4

matrix temp1 = 0, coef_low4
matrix temp2 = 0,var_low4
matrix temp3 = 0, coef_high4
matrix temp4 = 0,var_high4
matrix cessation = temp1 \ temp2 \ temp3 \ temp4

matrix initiation_avg  = coef_avg_post\var_avg_post
matrix cessation_avg  = coef_avg_post2\var_avg_post2
 	   									
foreach x in initiation	cessation initiation_avg cessation_avg{
	matrix colnames `x' = t0 t1 t2 t3 t4
} 								
										
 coefplot (matrix(initiation_avg[1]), se(initiation_avg[2])   color(black) ciopts( lcolor(black) ) offset(-0.2)) ///
 (matrix(initiation[1]), se(initiation[2]) msymbol(T)  color(red) ciopts( lcolor(red) lpattern(dash)) offset(0))   ///
(matrix(initiation[3]), se(initiation[4]) msymbol(S) color(blue) ciopts(lcolor(blue) ) offset(0.2)), ///
 baselevels omitted ///
xlabel(1 "2009" 2 "2010" 3 "2011" 4 "2012" 5 "2013" , labsize(large) ) vertical graphregion(color(white)) bgcolor(white) ///
legend(order(2 "Average" 4 "Low enforcement" 6 "High enforcement") rows(1)  size( large ) )  xscale(titlegap(2)) ///
	yline(0, lwidth(vvthin) lpattern(dash) lcolor(black)) ylabel(, labsize(large) ) name(post_inic, replace) 
graph export "$results/fig4a_initiation.png",replace	

coefplot (matrix(cessation_avg[1]), se(cessation_avg[2])   color(black) ciopts( lcolor(black) ) offset(-0.2)) ///
(matrix(cessation[1]), se(cessation[2])   color(red) ciopts( lcolor(red) lpattern(dash)) offset(0))   ///
(matrix(cessation[3]), se(cessation[4]) msymbol(S) color(blue) ciopts(lcolor(blue) ) offset(0.2)), ///
 baselevels omitted /// 
xlabel(1 "2009" 2 "2010" 3 "2011" 4 "2012" 5 "2013" , labsize(large) ) vertical graphregion(color(white)) bgcolor(white) ///
legend(order(2 "Average" 4 "Low enforcement" 6 "High enforcement") rows(1) size( large ) )  xscale(titlegap(2)) ///
	yline(0, lwidth(vvthin) lpattern(dash) lcolor(black))  ylabel(, labsize(large) ) name(post_ces, replace) 
graph export "$results/fig4b_cessation.png",replace	



******************************************************************************
************************* APPENDIX TABLE B8 **********************************
****************************************************************************** 

drop smoke2 smoke_avg
/*
****************** REMOVING SP AND RJ 
xtreg smoke d2006 d2007 d2008 d2009  t_3_low t_2_low t_1_low partrend_low  /// 
t_3_high t_2_high t_1_high partrend_high if index5 == 0 & year <= 2009 & uf != 35 & uf != 33 [aw = weight], fe vce(cluster uf)
local coefin_low=_b[partrend_low]
local coefin_high=_b[partrend_high]
gen smoke2 = smoke
replace smoke2 = smoke2 - `coefin_low'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & enforcement_low == 1 & uf != 35 & uf != 33
replace smoke2 = smoke2 - `coefin_high'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & enforcement_higher == 1 & uf != 35 & uf != 33
matrix temp = e(b)
matrix coef_low_rob = temp[1,5..7],0,temp[1,8]
matrix coef_high_rob =  temp[1,9..11],0,temp[1,12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low_rob = A[1,5..7],0,A[1,8]
matrix var_high_rob = A[1,9..11],0, A[1,12]
boottest {t_3_low} {t_2_low} {t_1_low} {partrend_low} {t_3_high} {t_2_high} {t_1_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low_rob = r(p_1), r(p_2), r(p_3), 0, r(p_4)
matrix pvalue_high_rob =  r(p_5), r(p_6), r(p_7), 0, r(p_8)
**Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f_low_rob = r(F)
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low_rob = r(p)
test t_3_high t_2_high t_1_high 
scalar f_high_rob = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high_rob = r(p)


xtreg smoke d2006 d2007 d2008 d2009  t_3_low t_2_low t_1_low partrend_low  /// 
t_3_high t_2_high t_1_high partrend_high if index5 == 1 & year <= 2009 & uf != 35 & uf != 33 [aw = weight], fe vce(cluster uf)
local coefces_low=_b[partrend_low]
local coefces_high=_b[partrend_high]
replace smoke2 = smoke - `coefces_low'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & enforcement_low == 1 & uf != 35 & uf != 33
replace smoke2 = smoke - `coefces_high'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & enforcement_higher == 1 & uf != 35 & uf != 33
matrix temp = -e(b)
matrix coef_low_rob2 = temp[1,5..7],0,temp[1,8]
matrix coef_high_rob2 =   temp[1,9..11],0,temp[1,12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low_rob2 = A[1,5..7],0,A[1,8]
matrix var_high_rob2 =A[1,9..11],0, A[1,12]
boottest {t_3_low} {t_2_low} {t_1_low} {partrend_low} {t_3_high} {t_2_high} {t_1_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low_rob2 = r(p_1), r(p_2), r(p_3), 0, r(p_4)
matrix pvalue_high_rob2 =  r(p_5), r(p_6), r(p_7), 0, r(p_8)
**Wald/F test 
test t_3_low t_2_low t_1_low 
scalar f_low_rob2 = r(F)
boottest t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low_rob2 = r(p)
test t_3_high t_2_high t_1_high 
scalar f_high_rob2 = r(F)
boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high_rob2 = r(p)


drop smoke2 

****************** WITHOUT LINEAR TRENDS, REMOVING SP AND RJ 

xtreg smoke  d2010 d2011 d2012 d2013 t1_low t2_low t3_low t4_low  /// 
t1_high t2_high t3_high t4_high if index9 == 0 & year >= 2009 & uf != 35 & uf != 33 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef_low_rob3 =  temp[1,5..8]
matrix coef_high_rob3 =  temp[1,9..12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low_rob3 = A[1,5..8]
matrix var_high_rob3 = A[1,9..12]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)
matrix pvalue_low_rob3 = r(p_1), r(p_2), r(p_3), r(p_4)
matrix pvalue_high_rob3 =  r(p_5), r(p_6), r(p_7), r(p_8)


xtreg smoke  d2010 d2011 d2012 d2013 t1_low t2_low t3_low t4_low  /// 
t1_high t2_high t3_high t4_high if index9 == 1 & year >= 2009 & uf != 35 & uf != 33 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef_low_rob4 = temp[1,5..8]
matrix coef_high_rob4 =temp[1,9..12]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low_rob4 == A[1,5..8]
matrix var_high_rob4 = A[1,9..12]
boottest {t1_low} {t2_low} {t3_low} {t4_low} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)
matrix pvalue_low_rob4 = r(p_1), r(p_2), r(p_3), r(p_4)
matrix pvalue_high_rob4 =  r(p_5), r(p_6), r(p_7), r(p_8)

*/

** Pre-treatment coefficients
foreach x in coef_low1 coef_low2 coef_high1 coef_high2  /// 
var_low1 var_low2 var_high1 var_high2  ///
 pvalue_low1 pvalue_low2 pvalue_high1 pvalue_high2  {
matrix colnames `x' = t_3 t_2 t_1 t0 Trend 
estadd matrix `x'
}

** Post-treatment coefficients
foreach x in coef_low3 coef_low4 coef_high3 coef_high4  ///
 var_low3 var_low4 var_high3 var_high4  /// 
 pvalue_low3 pvalue_low4 pvalue_high3 pvalue_high4  {
matrix colnames `x' = t1 t2 t3 t4 
estadd matrix `x'
}

 foreach j in nobs1 nobs2 nobs3 nobs4 nind1 nind2 nind3 nind4    ///
 f1_low f1_high f2_low f2_high pF1_low pF1_high pF2_low pF2_high    {
	estadd scalar `j'
 }
 
esttab using "$appendix/tab_b8_panelA.tex", /// 
cells("coef_high1(fmt(%12.3f)) coef_low1(fmt(%12.3f)) coef_high2(fmt(%12.3f)) coef_low2(fmt(%12.3f))"  /// 
"var_high1(fmt(%12.3f) par) var_low1(fmt(%12.3f) par) var_high2(fmt(%12.3f) par) var_low2(fmt(%12.3f) par)" ///
"pvalue_high1(fmt(%12.3f) par([ ])) pvalue_low1(fmt(%12.3f) par([ ])) pvalue_high2(fmt(%12.3f) par([ ])) pvalue_low2(fmt(%12.3f) par([ ])) ") ///
stats(f1_high f1_low f2_high f2_low  pF1_high pF1_low pF2_high pF2_low    ///
nobs1 nobs2  nind1 nind2 , layout("@ @ @ @ " "@ @ @ @   "  "@ @" "@ @" ) ///
 label("F-stat" "P-value" "N \times T" "N") /// 
fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc  %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc  %12.0fc)) /// 
 rename(t_4 "$2006$" t_3 "$2007$" t_1 "$2008$" t0 "$2009$" Trend "\textit{Trends}") /// 
  collabels("Initiation High" "Initiation Low" "Cessation High" "Cessation Low"  ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  

esttab using "$appendix/tab_b8_panelB.tex", /// 
cells("coef_high3(fmt(%12.3f)) coef_low3(fmt(%12.3f)) coef_high4(fmt(%12.3f)) coef_low4(fmt(%12.3f))  "  /// 
"var_high3(fmt(%12.3f) par) var_low3(fmt(%12.3f) par) var_high4(fmt(%12.3f) par) var_low4(fmt(%12.3f) par)  " ///
"pvalue_high3(fmt(%12.3f) par([ ])) pvalue_low3(fmt(%12.3f) par([ ])) pvalue_high4(fmt(%12.3f) par([ ])) pvalue_low4(fmt(%12.3f) par([ ])) ") ///
stats(nobs3 nobs4  nind3 nind4 , layout( "@ @" "@ @" ) label("N \times T" "N") fmt( %12.0fc)) /// 
 rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "2013") /// 
  collabels("Initiation High" "Initiation Low" "Cessation High" "Cessation Low"  ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  

clear all 