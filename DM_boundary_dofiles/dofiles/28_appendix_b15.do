*******************************************************************************
************** APPENDIX TAB. B15: REGIONAL HETEROGENEITY **********************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2010 == 1 | t2011 == 1 


foreach x in t_4 t_3 t_2 t_1 t1 t2 t3 t4 {
    replace `x' = 0 if t2008 == 1
}

sort id year
gen trend = .
replace trend = year - 2004 

gen trend2 = .
replace trend2 = year - 2008
gen partrend = trend*t2009

drop if uf >= 20 & uf <= 29

*************************SOUTH *******************************
xtreg smoke t_3 t_2 t_1 t1 t2 t3 t4 partrend i.year if uf > 29  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef1 = temp[1,4..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,4..8]
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest  {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
 **Wald/F test 
test t_3 t_2 t_1 
scalar f1 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF1 = r(p)


*****CESSATION
xtset id year
xtreg smoke t_3 t_2 t_1 partrend i.year if index5 == 1 & year <= 2009 & uf > 29  [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & uf > 29 
matrix temp = -e(b)
matrix coef2 =  temp[1,4]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,4]
scalar nobs22 = e(N)
scalar nind22 = e(N_g)
**Wald/F test 
test t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF2 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue2=  r(p)

xtreg smoke2 t1 t2 t3 t4 i.year if index9 == 1 & year >= 2009 & uf > 29  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2 = temp[1,1..4], coef2
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,1..4], var2
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), r(p_4), pvalue2 



*****INITIATION
xtset id year
xtset id year
xtreg smoke t_3 t_2 t_1 partrend i.year if index5 == 0 & year <= 2009 & uf > 29  [aw = weight], fe vce(cluster uf)
local trend5=_b[partrend]
replace smoke2 = smoke2 - `trend5'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & uf > 29 
matrix temp = e(b)
matrix coef3 =  temp[1,4]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,4]
scalar nobs33 = e(N)
scalar nind33 = e(N_g)

**Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF3 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue3=  r(p)


xtreg smoke2 t1 t2 t3 t4 i.year if index9 == 0 & year >= 2009 & uf > 29 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef3 =  temp[1,1..4], coef3
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,1..4], var3
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue3 = r(p_1), r(p_2), r(p_3), r(p_4), pvalue3 


*************************NORTH *******************************
xtreg smoke t_3 t_2 t_1 t1 t2 t3 t4 partrend i.year if uf < 20  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef4 = temp[1,4..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,4..8]
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue4 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
 **Wald/F test 
test t_3 t_2 t_1 
scalar f4 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF4 = r(p)
drop smoke2 

*****CESSATION
xtset id year
xtreg smoke t_3 t_2 t_1 partrend i.year if index5 == 1 & year <= 2009 & uf <20 [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & uf <20
matrix temp = -e(b)
matrix coef5 =  temp[1,4]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5 = A[1,4]
**Wald/F test 
test t_3 t_2 t_1 
scalar f5 = r(F) 
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF5 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue5=  r(p)


xtreg smoke2 t1 t2 t3 t4 i.year if index9 == 1 & year >= 2009 & uf <20 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef5 =  temp[1,1..4], coef5
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5 = A[1,1..4], var5
scalar nobs5 = e(N)
scalar nind5 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue5 = r(p_1), r(p_2), r(p_3), r(p_4), pvalue5 



*****INITIATION
xtset id year
xtreg smoke t_3 t_2 t_1 partrend i.year if index5 == 0 & year <= 2009 & uf <20 [aw = weight], fe vce(cluster uf)
local trend5=_b[partrend]
replace smoke2 = smoke2 - `trend5'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 & uf <20

matrix temp = e(b)
matrix coef6 =  temp[1,4]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = A[1,4]
**Wald/F test 
test t_3 t_2 t_1 
scalar f6 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF6 = r(p) 
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue6=  r(p)

xtreg smoke2 t1 t2 t3 t4 i.year if index9 == 0 & year >= 2009 & uf <29 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef6 =  temp[1,1..4], coef6
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = A[1,1..4], var6
scalar nobs6 = e(N)
scalar nind6 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue6 = r(p_1), r(p_2), r(p_3), r(p_4), pvalue6 

foreach x in coef1 coef2 coef3 coef4 coef5 coef6 var1 var2 var3 var4 var5 var6 ///
pvalue1 pvalue2 pvalue3 pvalue4 pvalue5 pvalue6 {
	matrix colnames `x' = t1 t2 t3 t4 Trends
	estadd matrix `x'
}


foreach j in nobs1 nobs2 nobs3 nobs4 nobs5 nobs6 nind1 nind2 nind3 nind4 nind5 nind6  ///
	f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 {
	estadd scalar `j'
	}
	
	
***Baseline average
gen south = 0
replace south = 1 if  uf > 29 & enforcement_low != 1 

gen north = 0
replace north = 1 if uf <20

bysort year t2009 south north: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009 south north: egen prevalence = sum(smoke_prev)

sum prevalence if t2009 == 1 & year ==2009 & south == 1
scalar mean_prev1 = r(mean)

sum prevalence if t2009 == 0 & year ==2009 & south == 1
scalar mean_prev2 = r(mean)

sum prevalence if t2009 == 1 & year ==2009 & north == 1
scalar mean_prev3 = r(mean)

sum prevalence if t2009 == 0 & year ==2009 & north == 1
scalar mean_prev4 = r(mean)
estadd scalar mean_prev1
estadd scalar mean_prev2
estadd scalar mean_prev3
estadd scalar mean_prev4
 

esttab using "$appendix/tab_b15.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) coef5(fmt(%12.3f)) coef6(fmt(%12.3f))"  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par) var3(fmt(%12.3f) par) var4(fmt(%12.3f) par) var5(fmt(%12.3f) par) var6(fmt(%12.3f) par)" ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue4(fmt(%12.3f) par([ ])) pvalue5(fmt(%12.3f) par([ ])) pvalue6(fmt(%12.3f) par([ ]))")  ///
stats(f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6  mean_prev1 mean_prev3 mean_prev2 mean_prev4 nobs1 nobs2 nobs3 nobs4 nobs5 nobs6  nind1 nind2 nind3 nind4 nind5 nind6, ///
 layout("@ @ @ @ @ @" "@ @ @ @ @ @" "@ @ @ @" "@ @ @ @ @ @" "@ @ @ @ @ @" ) label("F-stat" "P-value" "Average" "N \times T" "N") /// 
 fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.3f %12.3f %12.3f %12.3f %12.3f %12.3f %9.3fc %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trends "\textit{Trends}") collabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  

 clear all