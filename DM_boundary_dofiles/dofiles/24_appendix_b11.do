*******************************************************************************
**************** APPENDIX TAB. B11: ALTERNATIVE GROUPS ************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if  t2010 == 1 | t2011 == 1

sort id year
gen trend = .
replace trend = year - 2004 
gen trend2 = .
replace trend2 = year - 2008
gen partrend = trend*t2009

********************INCLUDING PORTO VELHO IN THE CONTROL GROUP******************
foreach var of varlist t_4 t_3 t_2 t_1 t1 t2 t3 t4 {
    replace `var' = 0 if t2008 ==1
}

xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef4 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,12..16]
matrix colnames var4 =  t1 t2 t3 t4 Trends
matrix colnames coef4 = t1 t2 t3 t4 Trends
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue4 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
 **Wald/F test 
test t_3 t_2 t_1  
scalar f4 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF4 = r(p)


*****CESSATION
xtset id year

xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend1=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend1'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

matrix temp = -e(b)
matrix coef5 =  temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5 = A[1,8]

**Wald/F test 
test t_3 t_2 t_1 
scalar f5 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF5 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue5 =  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef5 =  temp[1,5..8], coef5
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5= A[1,5..8], var5
matrix colnames var5 =  t1 t2 t3 t4 Trends
matrix colnames coef5 =t1 t2 t3 t4 Trends
scalar nobs5 = e(N)
scalar nind5 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue5 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue5


*****INITIATION
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend3=_b[partrend]
replace smoke2 = smoke2 - `trend3'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0

matrix temp = e(b)
matrix coef6 =  temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = A[1,8]

**Wald/F test 
test t_3 t_2 t_1 
scalar f6 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF6 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue6=  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef6 =  temp[1,5..8], coef6
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = A[1,5..8], var6
matrix colnames var6 =  t1 t2 t3 t4 Trends
matrix colnames coef6 =t1 t2 t3 t4 Trends
scalar nobs6 = e(N)
scalar nind6 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue6 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue6


*******************************************************************************
********************EXCLUDING  TWO CAPITALS TREATED IN 2010********************
*******************************************************************************

drop if uf == 12 | uf == 50
drop if t2008 == 1 // Removing Porto Velho from the analysis, as in the baseline

xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef1 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,12..16]
matrix colnames var1 =  t1 t2 t3 t4 Trends
matrix colnames coef1 = t1 t2 t3 t4 Trends
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
 **Wald/F test 
test t_3 t_2 t_1  
scalar f1 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF1 = r(p)

drop smoke2 

*****CESSATION
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

matrix temp = -e(b)
matrix coef2 =  temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,8]

**Wald/F test 
test t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF2 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue2=  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2 =  temp[1,5..8], coef2
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,5..8], var2
matrix colnames var2 =  t1 t2 t3 t4 Trends
matrix colnames coef2 =t1 t2 t3 t4 Trends
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue2 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue2


*****INITIATION
xtset id year
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend5=_b[partrend]
replace smoke2 = smoke2 - `trend5'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0

matrix temp = e(b)
matrix coef3 =  temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,8]

**Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF3 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638)
matrix pvalue3=  r(p)


xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef3 =  temp[1,5..8], coef3
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,5..8], var3
matrix colnames var3 =  t1 t2 t3 t4 Trends
matrix colnames coef3 =t1 t2 t3 t4 Trends
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638)
matrix pvalue3 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue3


foreach x in coef1 coef2 coef3 coef4 coef5 coef6 var1 var2 var3 var4 var5 var6 ///
	pvalue1 pvalue2 pvalue3 pvalue4 pvalue5 pvalue6 {
	matrix colnames `x' = t1 t2 t3 t4 Trends
	estadd matrix `x'
}

foreach j in nobs1 nobs2 nobs3 nobs4 nobs5 nobs6 nind1 nind2 nind3 nind4 nind5 nind6 ///
	f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 {
	estadd scalar `j'
	}
 
***Baseline average

bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)

sum prevalence if t2009 == 1 & year ==2009
scalar mean_prev = r(mean)

estadd scalar mean_prev


esttab using "$appendix/tab_b11.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) coef5(fmt(%12.3f)) coef6(fmt(%12.3f))"  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par) var3(fmt(%12.3f) par) var4(fmt(%12.3f) par) var5(fmt(%12.3f) par) var6(fmt(%12.3f) par)" ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue4(fmt(%12.3f) par([ ])) pvalue5(fmt(%12.3f) par([ ])) pvalue6(fmt(%12.3f) par([ ]))")  ///
stats(f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 mean_prev  nobs1 nobs2 nobs3 nobs4 nobs5 nobs6 nind1 nind2 nind3 nind4 nind5 nind6, ///
 layout("@ @ @ @ @ @" "@ @ @ @ @ @" "@ " "@ @ @ @ @ @" "@ @ @ @ @ @") label("F-stat" "P-value" "Average" "N \times T" "N") /// 
 fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.3f %12.3f %12.3f %12.3f %12.3f %12.3f %9.3fc %12.0fc)) /// 
 rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trends "\textit{Trends}") /// 
 collabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers 
  
  clear all