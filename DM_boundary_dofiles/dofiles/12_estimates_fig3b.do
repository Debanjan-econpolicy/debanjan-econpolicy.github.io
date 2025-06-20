*******************************************************************************
************************ PREVALENCE ENFORCEMENT ********************************
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
local avg_high: di %9.1f `r(mean)' 
scalar mean_prev_high = r(mean)

sum prevalence if year ==2009 & (t2009 == 1)
local avg_low: di %9.1f `r(mean)' 
scalar mean_prev_low = r(mean)
drop tot_weight_prev smoke_prev prevalence

 
*** FIGURE 3B: Prevalence by enforcement level
xtreg smoke i.year t_3_low t_2_low t_1_low t1_low t2_low t3_low t4_low  /// 
t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high  d2006 partrend_low partrend_high  [aw = weight], fe vce(cluster uf)
est sto reg1 
boottest {partrend_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low}  /// 
{partrend_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high}, noci cluster(uf) seed(982638)

 coefplot  (reg1, color(red) msymbol(S) ciopts(lpattern(shortdash) lcolor(red)) offset(-0.1) ///
 keep( d2006 t_3_low t_2_low t_1_low t1_low t2_low t3_low t4_low  2005.year) /// 
rename(d2006 = t_4 t_3_low = t_3 t_2_low = t_2 t_1_low = t_1 t1_low = t1 t2_low = t2 t3_low = t3 t4_low = t4)) ///
(reg1, msymbol(D) color(blue) ciopts(lpattern(dash) lcolor(blue)) offset(0.1) ///
keep(d2006 t_3_higher t_2_higher t_1_higher t1_higher t2_higher t3_higher t4_higher 2005.year) ///
rename(d2006 = t_4 t_3_higher = t_3 t_2_higher = t_2 t_1_higher = t_1 t1_higher = t1 t2_higher = t2 /// 
t3_higher = t3 t4_higher = t4)), ///
order(t_4 t_3 t_2 t_1 2005.year t1 t2 t3 t4 ) baselevels omitted /// 
xlabel(1 "2005" 2 "2006"  3 "2007" 4 "2008" 5 "2009" 6 "2010" 7 "2011" 8 "2012" 9 "2013", labsize(vlarge) angle(45)) ///
			vertical graphregion(color(white)) bgcolor(white) ///
			legend(order(2 "Low enforcement" 4 "High enforcement") rows(1) size(vlarge)) ///
			xline(4.5, lcolor(black) ) ytitle("proportion of smokers", size(large))  xtitle("")  ///
	       yline(0, lwidth(vthin) lpattern(dash) lcolor(black)) ylabel(-0.03(0.01)0.02,labsize(large)) ///
		      text(-0.023 3.2 "{bf:Baseline avg.:}",  size(medlarge)) /// 
		   text(-0.028 2 "`avg_low'%",  size(medlarge) color(red))   text(-0.028 3 "and",  size(large))  /// 
		   text(-0.028 3.6 "`avg_high'%",  size(medlarge) color(blue) )
graph export "$results/fig3b_prevalence.png",replace
 

*******APPENDIX TABLE B6
*** No linear trends
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 t_4_low t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low  t_4_high t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
   [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low1 = temp[1,9..16], .
matrix coef_high1 = temp[1,17..24], .
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low1 = A[1,9..16], .
matrix var_high1 = A[1,17..24],.
boottest {t_4_low} {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low} } /// 
{t_4_high} {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} }, noci cluster(uf) seed(982638)
matrix pvalue_low1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8), .
matrix pvalue_high1 = r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), .

foreach x in coef_low1 coef_high1 var_low1 var_high1 pvalue_low1 pvalue_high1 {
matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trend 
}

scalar nobs1 = e(N)
scalar nind1 = e(N_g)
 **Wald/F test 
test t_4_low t_3_low t_2_low t_1_low 
scalar f_low1 = r(F) 
boottest t_4_low t_3_low t_2_low t_1_low , noci cluster(uf) seed(982638)
scalar pF_low1 = r(p)
test t_4_high t_3_high t_2_high t_1_high
scalar f_high1 = r(F)  
 boottest t_4_high t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high1 = r(p)


*** With linear trends
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3_low t_2_low t_1_low /// 
 t1_low t2_low t3_low t4_low partrend_low t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high  [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_low2 = ., temp[1,9..16]
matrix coef_high2 = ., temp[1,17..24]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_low2 = ., A[1,9..16]
matrix var_high2 = ., A[1,17..24]
boottest {t_3_low} {t_2_low} {t_1_low} {t1_low} {t2_low} {t3_low} {t4_low} {partrend_low} /// 
 {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_low2 = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue_high2 = ., r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16)

foreach x in coef_low2 coef_high2 var_low2 var_high2 pvalue_low2 pvalue_high2 {
matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trend 
}

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


*** With linear trends, no low-enfocement
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 t_3_high t_2_high t_1_high t1_high t2_high t3_high t4_high /// 
 partrend_high if enforcement_low == 0 [aw = weight], fe vce(cluster uf)
 
matrix temp = e(b)
matrix coef_high3 = ., temp[1,9..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_high3= ., A[1,9..16]
boottest  {t_3_high} {t_2_high} {t_1_high} {t1_high} {t2_high} {t3_high} {t4_high} {partrend_high}, noci cluster(uf) seed(982638)
matrix pvalue_high3= ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
 **Wald/F test 
test t_3_high t_2_high t_1_high
scalar f_high3 = r(F)  
 boottest t_3_high t_2_high t_1_high , noci cluster(uf) seed(982638)
scalar pF_high3 = r(p)

********************* ADDING RESULTS TO SINGLE TABLE ***************************


foreach x in coef_low1 coef_low2  coef_high1 coef_high2 coef_high3 /// 
var_low1 var_low2 var_high1 var_high2 var_high3 pvalue_low1 pvalue_low2 pvalue_high1 pvalue_high2 pvalue_high3 { 
matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trend 
estadd matrix `x'
}
 
 foreach j in nobs1 nobs2 nobs3 nind1 nind2 nind3  f_low1 f_low2  pF_low1 pF_low2 ///
 f_high1 f_high2 f_high3  pF_high1 pF_high2 pF_high3  {
	estadd scalar `j'
	}
 

estadd scalar mean_prev_high
estadd scalar mean_prev_low


esttab using "$appendix/tab_b6.tex", /// 
cells("coef_high1(fmt(%12.3f)) coef_low1(fmt(%12.3f)) coef_high2(fmt(%12.3f)) coef_low2(fmt(%12.3f)) coef_high3(fmt(%12.3f))"  /// 
"var_high1(fmt(%12.3f) par) var_low1(fmt(%12.3f) par) var_high2(fmt(%12.3f) par) var_low2(fmt(%12.3f) par) var_high3(fmt(%12.3f) par)" ///
"pvalue_high1(fmt(%12.3f) par([ ])) pvalue_low1(fmt(%12.3f) par([ ])) pvalue_high2(fmt(%12.3f) par([ ])) pvalue_low2(fmt(%12.3f) par([ ])) pvalue_high3(fmt(%12.3f) par([ ])) ") ///
stats(f_high1 f_low1 f_high2 f_low2 f_high3 pF_high1 pF_low1 pF_high2 pF_low2 pF_high3 ///
 mean_prev_high mean_prev_low  mean_prev_high mean_prev_low  /// 
nobs1 nobs2 nobs3  nind1 nind2 nind3 , layout("@ @ @ @ @ " "@ @ @ @ @"  "@ @ @ @ " "@ @ @ " "@ @ @") label("F-stat" "P-value" "Average" "N \times T" "N") /// 
fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename(t_4 "$2005$" t_3 "$2006$" t_2 "$2007$" t_1 "$2008$" ///
  t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trend "\textit{Trends}") /// 
  collabels("(1)" "(2)" "(3)" "(4)" "(5)" ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
 
 clear all

 