*******************************************************************************
******************** APPENDIX TAB. B12: COHORTS ********************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
replace birth = 2013 - birth if birth <= 1000
keep if birth >= 1975 & birth <= 1995
drop if t2008 == 1 | t2010 == 1 | t2011 == 1
sort id year
gen trend = .
replace trend = year - 2004 
gen trend2 = .
replace trend2 = year - 2008
gen partrend = trend*t2009


*************************REGRESSION COEFFICIENTS*******************************
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef1 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,12..16]
matrix colnames var1= t1 t2 t3 t4 Trends
matrix colnames coef1 = t1 t2 t3 t4 Trends
scalar nind1 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f1 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF1 = r(p)


xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend if birth >= 1980  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef11 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var11 = A[1,12..16]
matrix colnames var11= t1 t2 t3 t4 Trends
matrix colnames coef11 = t1 t2 t3 t4 Trends
scalar nind11 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue11 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f11 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF11 = r(p)


*****CESSATION
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009 & birth <= 1990 [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

matrix temp = -e(b)
matrix coef2 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,8..8]
scalar nobs2 = e(N_g)

**Wald/F test 
test t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF2 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue2=  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 & birth >= 1980 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2 =  temp[1,5..8], coef2
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,5..8], var2
matrix colnames var2 =  t1 t2 t3 t4 Trends
matrix colnames coef2 =t1 t2 t3 t4 Trends
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue2 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue2

*** Cohort 1980 - 1990
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009 & birth >= 1980 & birth <= 1990 [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke3 = smoke
replace smoke3 = smoke3 - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

matrix temp = -e(b)
matrix coef22 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var22 = A[1,8..8]
scalar nobs22 = e(N_g)

**Wald/F test 
test t_3 t_2 t_1 
scalar f22 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF22 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue22=  r(p)


xtreg smoke3 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 & birth >= 1985 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef22 =  temp[1,5..8], coef22
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var22 = A[1,5..8], var22
matrix colnames var22 =  t1 t2 t3 t4 Trends
matrix colnames coef22 =t1 t2 t3 t4 Trends
scalar nind22 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue22 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue22


*****INITIATION
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009 &  birth <= 1990 [aw = weight], fe vce(cluster uf)
local trend5=_b[partrend]
replace smoke2 = smoke2 - `trend5'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0

matrix temp = e(b)
matrix coef3 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,8..8]
scalar nobs3 = e(N_g)

**Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF3 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue3=  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 0 & year >= 2009 & birth >= 1980 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef3 =  temp[1,5..8], coef3
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,5..8], var3
matrix colnames var3 =  t1 t2 t3 t4 Trends
matrix colnames coef3 =t1 t2 t3 t4 Trends
scalar nind3 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue3 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue3


xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009 & birth >= 1980 &  birth <= 1990 [aw = weight], fe vce(cluster uf)
local trend5=_b[partrend]
replace smoke3 = smoke3 - `trend5'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0

matrix temp = e(b)
matrix coef33 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var33 = A[1,8..8]
scalar nobs33 = e(N_g)

**Wald/F test 
test t_3 t_2 t_1 
scalar f33 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF33 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue33=  r(p)



xtreg smoke3 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 0 & year >= 2009 & birth >= 1985 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef33 =  temp[1,5..8], coef33
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var33 = A[1,5..8], var33
matrix colnames var33 =  t1 t2 t3 t4 Trends
matrix colnames coef33 =t1 t2 t3 t4 Trends
scalar nind33 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue33 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue33



foreach x in coef1 coef11 coef2 coef22 coef3 coef33 var1 var11 var2 var22 var3 var33  ///
	pvalue1 pvalue11 pvalue2 pvalue22 pvalue3 pvalue33  {
	matrix colnames `x' =  t1 t2 t3 t4 Trend
	estadd matrix `x'
}

foreach j in nobs2 nobs22 nobs3 nobs33  nind1 nind11 nind2 nind3 nind22 nind33  ///
	f1 f11 f2 f22 f3 f33  pF1 pF11 pF2 pF22 pF3 pF33  {
	estadd scalar `j'
	}
 
***Baseline average

bysort year t2009: egen tot_weight_prev = total(weight)
bysort year t2009: egen tot_weight_prev2 = total(weight) if birth >= 1980

gen smoke_prev = smoke*(weight/tot_weight_prev)
gen smoke_prev2 = smoke*(weight/tot_weight_prev2)

bysort year t2009: egen prevalence1 = sum(smoke_prev)
bysort year t2009: egen prevalence2 = sum(smoke_prev2) if birth >= 1980

sum prevalence1 if t2009 == 1 & year ==2009
scalar mean_prev1 = r(mean)

sum prevalence2 if t2009 == 1 & year ==2009 & birth >= 1980
scalar mean_prev2 = r(mean)


estadd scalar mean_prev1
estadd scalar mean_prev2



esttab using "$appendix/tab_b12.tex", /// 
cells("coef1(fmt(%12.3f)) coef11(fmt(%12.3f)) coef2(fmt(%12.3f)) coef22(fmt(%12.3f)) coef3(fmt(%12.3f)) coef33(fmt(%12.3f))"  /// 
"var1(fmt(%12.3f) par) var11(fmt(%12.3f) par) var2(fmt(%12.3f) par) var22(fmt(%12.3f) par) var3(fmt(%12.3f) par) var33(fmt(%12.3f) par)" ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue11(fmt(%12.3f) par([ ]))  pvalue2(fmt(%12.3f) par([ ])) pvalue22(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue33(fmt(%12.3f) par([ ]))")  ///
stats(f1 f11 f2 f22 f3 f33 pF1 pF11 pF2 pF22 pF3 pF33  mean_prev1 mean_prev2  nobs2 nobs22 nobs3 nobs33  nind1 nind11 nind2 nind22 nind3 nind33, ///
 layout("@ @ @ @ @ @" "@ @ @ @ @ @" "@ @ @ @ @ @  " "@ @ @ @ @ @ ") label("F-stat" "P-value" "Average" "N \times T" "N") ///
 fmt(%9.3fc %9.3fc  %9.3fc  %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc  %12.0fc)) /// 
 rename(  t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trend "\textit{Trends}")  ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  clear all
