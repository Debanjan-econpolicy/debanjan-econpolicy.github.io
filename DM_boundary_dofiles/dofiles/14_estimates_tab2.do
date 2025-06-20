*******************************************************************************
**************** CESSATION & INITIATION: PLACEBO TAB. 2 ***********************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15 // young adults
drop if t2008 == 1 | t2010 == 1 | t2011 == 1
sort id year
by id: gen trend = _n
gen partrend = trend*t2009
gen age2 = age^2

*** Placebo estimates for pre-treatment period
keep if year <= 2009

****************************INITIATION******************************************* 
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 t0 if index5 == 0 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef1 = temp[1,5..8],.
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,5..8],.
matrix colnames var1 = t_3 t_2 t_1 t0 Trends
matrix colnames coef1 = t_3 t_2 t_1 t0 Trends
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t_3} {t_2} {t_1} {t0}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), .

**Wald/F test 
test t_3 t_2 t_1 t0
scalar f1 = r(F)
boottest t_3 t_2 t_1 t0, noci cluster(uf) seed(982638)
scalar pF1 = r(p)

***with linear trends
xtreg smoke d2006 d2007 d2008 d2009  t_3 t_2 t_1 partrend if index5 == 0 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef2 =temp[1,5..7],., temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,5..7],., A[1,8]
matrix colnames var2 = t_3 t_2 t_1 t0 Trends
matrix colnames coef2 = t_3 t_2 t_1 t0 Trends
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t_3} {t_2} {t_1} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), ., r(p_4)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF2 = r(p)


***with linear trends, no RJ no SP
xtreg smoke d2006 d2007 d2008 d2009  t_3 t_2 t_1 partrend if index5 == 0 & uf != 33 & uf != 35 [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef3 =temp[1,5..7],., temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,5..7],., A[1,8]
matrix colnames var3 = t_3 t_2 t_1 t0 Trends
matrix colnames coef3 = t_3 t_2 t_1 t0 Trends
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t_3} {t_2} {t_1} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue3 = r(p_1), r(p_2), r(p_3), ., r(p_4)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF3 = r(p)



****************************CESSATION******************************************* 
xtset id year

xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 t0 if index5 == 1 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef4 = temp[1,5..8],.
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,5..8],.
matrix colnames var4 = t_3 t_2 t_1 t0 Trends
matrix colnames coef4 = t_3 t_2 t_1 t0 Trends
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t_3} {t_2} {t_1} {t0}, noci cluster(uf) seed(982638)
matrix pvalue4 = r(p_1), r(p_2), r(p_3), r(p_4), .

**Wald/F test 
test t_3 t_2 t_1 t0
scalar f4 = r(F)
boottest t_3 t_2 t_1 t0, noci cluster(uf) seed(982638)
scalar pF4 = r(p)

***with linear trends
xtreg smoke d2006 d2007 d2008 d2009  t_3 t_2 t_1 partrend if index5== 1 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef5 =temp[1,5..7],., temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5 = A[1,5..7],., A[1,8]
matrix colnames var5 = t_3 t_2 t_1 t0 Trends
matrix colnames coef5 = t_3 t_2 t_1 t0 Trends
scalar nobs5 = e(N)
scalar nind5 = e(N_g)
boottest {t_3} {t_2} {t_1} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue5 = r(p_1), r(p_2), r(p_3), ., r(p_4)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f5 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF5 = r(p)


***with linear trends, no RJ no SP
xtreg smoke d2006 d2007 d2008 d2009  t_3 t_2 t_1 partrend  if index5 == 1 & uf != 33 & uf != 35 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef6 =temp[1,5..7],., temp[1,8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = A[1,5..7],., A[1,8]
matrix colnames var6 = t_3 t_2 t_1 t0 Trends
matrix colnames coef6 = t_3 t_2 t_1 t0 Trends
scalar nobs6 = e(N)
scalar nind6 = e(N_g)
boottest {t_3} {t_2} {t_1} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue6 = r(p_1), r(p_2), r(p_3), ., r(p_4)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f6 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF6 = r(p)


foreach x in coef1 coef2 coef3 coef4 coef5 coef6 var1 var2 var3 var4 var5 var6 ///
	pvalue1 pvalue2 pvalue3 pvalue4 pvalue5 pvalue6  {
	matrix colnames `x' =  t_3 t_2 t_1 t0 Trends
	estadd matrix `x'
}


foreach j in nobs1 nobs4 nind1 nind4  ///
	f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 {
	estadd scalar `j'
	}
 
bysort year t2009 index5: egen tot_weight = total(weight)
gen smoke_inc_ces = smoke*(weight/tot_weight)

replace smoke_inc_ces = . if index5 == . 
bysort year t2009 index5: egen ces_inic = sum(smoke_inc_ces)
sum ces_inic if t2009 == 1 & year ==2009 & index5 ==1
scalar mean_ces = r(mean)
sum ces_inic if t2009 == 1 & year ==2009 & index5 ==0
scalar mean_inic = r(mean)
drop ces_inic tot_weight smoke_inc_ces

bysort year t2009 index5: egen tot_weight = total(weight) if uf != 33 & uf != 35
gen smoke_inc_ces = smoke*(weight/tot_weight) if uf != 33 & uf != 35
replace smoke_inc_ces = . if index5 == . 

bysort year t2009 index5: egen ces_inic = sum(smoke_inc_ces) if uf != 33 & uf != 35
sum ces_inic if t2009 == 1 & year ==2009 & index5 ==1 & uf != 33 & uf != 35
scalar mean_ces_nosp = r(mean)

sum ces_inic if t2009 == 1 & year ==2009 & index5 ==0  & uf != 33 & uf != 35
scalar mean_inic_nosp = r(mean)

estadd scalar mean_inic
estadd scalar mean_ces
estadd scalar mean_inic_nosp
estadd scalar mean_ces_nosp

esttab using "$results/tab2_placebo.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) coef5(fmt(%12.3f)) coef6(fmt(%12.3f)) "  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par) var3(fmt(%12.3f) par) var4(fmt(%12.3f) par) var5(fmt(%12.3f) par) var6(fmt(%12.3f) par)  " ///
" pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue4(fmt(%12.3f) par([ ])) pvalue5(fmt(%12.3f) par([ ])) pvalue6(fmt(%12.3f) par([ ])) ")  ///
stats(f1 f2 f3 f4 f5 f6  pF1 pF2 pF3 pF4 pF5 pF6   mean_inic  mean_inic_nosp mean_ces  mean_ces_nosp nobs4 nobs1  nind4 nind1, ///
 layout("@ @ @ @ @ @" "@ @ @ @ @ @" "@ @ @ @" "@ @ @ @") label("F-stat" "P-value" "Average" "N") /// 
 fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.3f %12.3f %12.3f %12.3f %12.3f %12.3f %9.3fc %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename(t_3 "$2006$" t_2 "$2007$" t_1 "$2008$" t0 "$2009$" Trends "\textit{Trends}") collabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers ///
   prefoot(" \hline Trends & No & Yes & Yes & No & Yes & Yes ")
  

  
 clear all