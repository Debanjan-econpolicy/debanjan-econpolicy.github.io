*******************************************************************************
****************************** FOOTNOTES  *************************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel", clear
xtset id year
drop if year < 2005
drop if t2008 == 1 | t2010 == 1 | t2011 == 1
sort id year
by id: gen trend = year-2004
gen partrend = trend*t2009
gen trend2 = .
replace trend2 = year - 2008
gen age2 = age^2
keep if age >= 15 
xtset id year

*******************************************************************************
************************* RESULTS FOR ADULTS **********************************
*******************************************************************************
** Prevalence: young adults
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend if age < 30  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef1 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,12..16]
matrix colnames var1= t1 t2 t3 t4 Trends
matrix colnames coef1 = t1 t2 t3 t4 Trends
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f1 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF1 = r(p)

** Prevalence: adults
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend if age >= 30  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef2 = temp[1,12..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2= A[1,12..16]
matrix colnames var2 = t1 t2 t3 t4 Trends
matrix colnames coef2 = t1 t2 t3 t4 Trends
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF2 = r(p)


*****CESSATION: young adults
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009 & age < 30  [aw = weight], fe vce(cluster uf)
local trend3=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend3'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & age < 30

matrix temp = -e(b)
matrix coef3 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,8..8]
**Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F) 
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF3 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue3=  r(p)

xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 & age < 30 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef3 =  temp[1,5..8], coef3
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,5..8], var3
matrix colnames var3 =  t1 t2 t3 t4 Trends
matrix colnames coef3 =t1 t2 t3 t4 Trends
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue3 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue3


*****CESSATION:  adults
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009 & age >= 30 [aw = weight], fe vce(cluster uf)
local trend4=_b[partrend]
gen smoke3 = smoke
replace smoke3 = smoke - `trend4'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1 & age >= 30

matrix temp = -e(b)
matrix coef4 =  temp[1,8..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,8..8]
**Wald/F test 
test t_3 t_2 t_1 
scalar f4 = r(F) 
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638) weighttype(webb)
scalar pF4 = r(p)
boottest {partrend} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue4=  r(p)

xtreg smoke3 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009 & age >= 30 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef4 =  temp[1,5..8], coef4
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,5..8], var4
matrix colnames var4 =  t1 t2 t3 t4 Trends
matrix colnames coef4 =t1 t2 t3 t4 Trends
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue4 =  r(p_1), r(p_2), r(p_3), r(p_4), pvalue4

foreach x in coef1 coef2 coef3 coef4 var1 var2 var3 var4  ///
	pvalue1 pvalue2 pvalue3 pvalue4   {
	matrix colnames `x' =  t1 t2 t3 t4 Trends
	estadd matrix `x'
}


foreach j in nobs1 nobs2 nobs3 nobs4 nind1 nind2 nind3 nind4 ///
	f1 f2 f3 f4 pF1 pF2 pF3 pF4  {
	estadd scalar `j'
	}
	
	
***Baseline average
gen adult = (age>=30) 

bysort year t2009 adult: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009 adult: egen prevalence = sum(smoke_prev)


sum prevalence if t2009 == 1 & year ==2009 & adult == 1
scalar mean_prev_adult1 = r(mean)

sum prevalence if t2009 == 0 & year ==2009 & adult == 1
scalar mean_prev_adult0 = r(mean)

sum prevalence if t2009 == 1 & year ==2009 & adult == 0
scalar mean_prev1 = r(mean)

sum prevalence if t2009 == 0 & year ==2009 & adult == 0
sum prevalence if t2009 == 0 & year ==2009 
scalar mean_prev0 = r(mean)


estadd scalar mean_prev_adult1
estadd scalar mean_prev_adult0
estadd scalar mean_prev1
estadd scalar mean_prev0
 
esttab using "$appendix/footnote_adults.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) "  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par) var3(fmt(%12.3f) par) var4(fmt(%12.3f) par) " ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue4(fmt(%12.3f) par([ ])) ")  ///
stats(f1 f2 f3 f4 pF1 pF2 pF3 pF4  mean_prev1 mean_prev_adult1  mean_prev0 mean_prev_adult0   nobs1 nobs2 nobs3 nobs4 nind1 nind2 nind3 nind4, ///
 layout("@ @ @ @" "@ @ @ @" "@ @ @ @" "@ @ @ @" "@ @ @ @" ) label("F-stat" "P-value" "Average" "N \times T" "N") /// 
 fmt(%9.3fc %9.3fc %9.3fc %9.3fc  %12.3f %12.3f %12.3f %12.3f %9.3fc %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trends "\textit{Trends}") collabels("Young" "Adults" "Young" "Adults") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  
*******************************************************************************
************************* CESSATION MEASURES **********************************
*******************************************************************************  
drop smoke2 
drop if age >29 | age<15

***** STANDARD MEASURE: CESSATION = - EFFECT ON PREVALENCE AMONG SMOKERS
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend3=_b[partrend]
gen smoke2 = smoke
replace smoke2 = smoke2 - `trend3'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef1 =  temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,5..8]
matrix colnames var1 =  t1 t2 t3 t4 
matrix colnames coef1 =t1 t2 t3 t4 
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue1 =  r(p_1), r(p_2), r(p_3), r(p_4)

***** CESSATION = 0 IF SMOKE, 1 IF QUIT
drop smoke2 
gen smoke_ces=(smoke==0)
  
xtset id year
xtreg smoke_ces d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local trend3=_b[partrend]
gen smoke2 = smoke_ces
replace smoke2 = smoke2 - `trend3'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1
  
xtreg smoke2 d2010 d2011 d2012 d2013 t1 t2 t3 t4 if index9 == 1 & year >= 2009  [aw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef2 =  temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,5..8]
matrix colnames var2 =  t1 t2 t3 t4 
matrix colnames coef2 =t1 t2 t3 t4 
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4} , noci cluster(uf) seed(982638) weighttype(webb)
matrix pvalue2 =  r(p_1), r(p_2), r(p_3), r(p_4)  
  
 foreach x in coef1 coef2 var1 var2 pvalue1 pvalue2    {
	matrix colnames `x' =  t1 t2 t3 t4 
	estadd matrix `x'
}

foreach j in nobs1 nobs2 nind1 nind2 {
	estadd scalar `j'
	}
	
	 
  
  esttab using "$appendix/foonote_cessation.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f))  "  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par)  " ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ]))  ")  ///
stats(nobs1 nobs2 nind1 nind2 , layout("@ @" "@ @" ) label("N \times T" "N") fmt( %12.0fc)) /// 
 rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$") collabels("Standard" "Alternative") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  
  
 clear all 
   
 
  
  
   
 