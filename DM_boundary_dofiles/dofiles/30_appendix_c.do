*******************************************************************************
************** APPENDIX C: PRE-TRENDS ASYMMETRICAL OUTCOMES *******************
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

gen trend2 = .
replace trend2 = year - 2008

gen partrend = trend*t2009
gen post = (year >= 2009)

*******************************************************************************
*****LINEAR TREND INITIATION
xtset id year
xtreg smoke i.year d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coef_ini = _b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `coef_ini'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 
matrix coef_ini1= e(b)[1,11]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ini1 = A[1,11]
boottest  {partrend}, noci cluster(uf) seed(982638)
matrix pvalue_ini1= r(p)

***** LINEAR TREND CESSATION
xtreg smoke i.year d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coef_ces = _b[partrend]
replace smoke2 = smoke2 - `coef_ces'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 
matrix coef_ces1= -e(b)[1,11]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ces1 = A[1,11]
boottest  {partrend}, noci cluster(uf) seed(982638)
matrix pvalue_ces1= r(p)


*** ADJUSTED INITIATION
xtreg smoke2 i.year d2010 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix coef_ini1 = e(b)[1,7..10], coef_ini1
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ini1 = A[1,7..10], var_ini1
boottest  {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue_ini1= r(p_1), r(p_2), r(p_3), r(p_4), pvalue_ini1

*** INITIATION WITHOUT TRENDS
xtreg smoke i.year d2010 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix coef_ini2= e(b)[1,7..10], .
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ini2 = A[1,7..10], .
boottest  {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue_ini2= r(p_1), r(p_2), r(p_3), r(p_4), .

*** BIASED INITIATION
xtreg smoke i.year t_3 t_2 t_1 t1 t2 t3 t4 partrend if index9 == 0  [aw = weight], fe vce(cluster uf)
matrix coef_ini3= e(b)[1,13..17]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ini3 = A[1,13..17]
boottest  {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue_ini3= r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)


*** ADJUSTED CESSATION
xtreg smoke2 i.year d2010 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix coef_ces1 = -e(b)[1,7..10], coef_ces1
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ces1 = A[1,7..10], var_ces1
boottest  {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue_ces1= r(p_1), r(p_2), r(p_3), r(p_4), pvalue_ces1

*** CESSATION WITHOUT TRENDS
xtreg smoke i.year d2010 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix coef_ces2= -e(b)[1,7..10], .
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ces2 = A[1,7..10], .
boottest  {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue_ces2= r(p_1), r(p_2), r(p_3), r(p_4), .

*** BIASED CESSATION
xtreg smoke i.year t_3 t_2 t_1 t1 t2 t3 t4 partrend if index9 == 1  [aw = weight], fe vce(cluster uf)
matrix coef_ces3= -e(b)[1,13..17]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var_ces3 = A[1,13..17]
boottest  {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue_ces3= r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)


foreach x in coef_ini1 coef_ini2 coef_ini3 coef_ces1 coef_ces2 coef_ces3 ///
var_ini1 var_ces1 var_ini2 var_ces2  var_ini3 var_ces3 ///
 pvalue_ini1 pvalue_ini2 pvalue_ini3 pvalue_ces1 pvalue_ces2 pvalue_ces3 {
	matrix colnames `x' = t1 t2 t3 t4 Trend
	estadd matrix `x'
}


esttab using "$appendix/tab_c1.tex", /// 
cells(" coef_ini1(fmt(%12.3f))  coef_ini3(fmt(%12.3f)) coef_ini2(fmt(%12.3f)) coef_ces1(fmt(%12.3f)) coef_ces3(fmt(%12.3f)) coef_ces2(fmt(%12.3f)) "  /// 
"var_ini1(fmt(%12.3f) par) var_ini3(fmt(%12.3f) par) var_ini2(fmt(%12.3f) par)   var_ces1(fmt(%12.3f) par) var_ces3(fmt(%12.3f) par) var_ces2(fmt(%12.3f) par) " ///
"pvalue_ini1(fmt(%12.3f) par([ ]))  pvalue_ini3(fmt(%12.3f) par([ ])) pvalue_ini2(fmt(%12.3f) par([ ])) pvalue_ces1(fmt(%12.3f) par([ ])) pvalue_ces3(fmt(%12.3f) par([ ])) pvalue_ces2(fmt(%12.3f) par([ ])) ")  ///
 rename( t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trend "\textit{Trends}") /// 
 collabels("Adjusted Initiation" "Biased Initiation" "Initiation no trend"  "Adjusted Cessation"  "Biased Cessation" "Cessation no trend" ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers   


matrix coef_ini1 = 0, coef_ini1[1,1..4]  
matrix coef_ini3 = 0, coef_ini3[1,1..4]
matrix var_ini1 = 0, var_ini1[1,1..4]  
matrix var_ini3 = 0, var_ini3[1,1..4]  
matrix coef_ces1 = 0, coef_ces1[1,1..4]  
matrix coef_ces3 = 0, coef_ces3[1,1..4]
matrix var_ces1 = 0, var_ces1[1,1..4]  
matrix var_ces3 = 0, var_ces3[1,1..4]  
    
  
matrix initiation = coef_ini1 \ var_ini1 \ coef_ini3 \ var_ini3
matrix cessation = coef_ces1 \ var_ces1 \ coef_ces3 \ var_ces3


 coefplot (matrix(initiation[1]), se(initiation[2]) color(red) ciopts(lpattern(dash) lcolor(red)) offset(-0.1)) ///
(matrix(initiation[3]), se(initiation[4]) msymbol(D) color(black) ciopts(lpattern(shortdash) lcolor(black)) offset(0.1)), ///
 baselevels omitted /// 
xlabel(1 "0" 2 "1" 3 "2" 4 "3" 5 "4", labsize(medsmall)) ///
			vertical graphregion(color(white)) bgcolor(white) ///
			legend(order(2 "Adjusted linear trends" 4 "Biased linear trends") rows(1)) ///
			 ytitle("proportion of smokers", size(medsmall))  xtitle("")  ///
	       yline(0, lwidth(vthin) lpattern(dash) lcolor(black)) ylabel(-0.02(0.01)0.02)
graph export "$appendix/fig_c1a.png",replace

   coefplot (matrix(cessation[1]), se(cessation[2]) color(blue) ciopts(lpattern(dash) lcolor(blue)) offset(-0.1)) ///
(matrix(cessation[3]), se(cessation[4]) msymbol(S) color(black) ciopts(lpattern(shortdash) lcolor(black)) offset(0.1)), ///
 baselevels omitted /// 
xlabel(1 "0" 2 "1" 3 "2" 4 "3" 5 "4", labsize(medsmall)) ///
			vertical graphregion(color(white)) bgcolor(white) ///
			legend(order(2 "Adjusted linear trends" 4 "Biased linear trends") rows(1)) ///
			 ytitle("proportion of smokers", size(medsmall))  xtitle("")  ///
	       yline(0, lwidth(vthin) lpattern(dash) lcolor(black))
graph export "$appendix/fig_c1b.png",replace
 
clear all

  
  