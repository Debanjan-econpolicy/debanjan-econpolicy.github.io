*******************************************************************************
******************** CESSATION BY ADDICTION LEVEL  ****************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if age >29 | age<15
drop if t2008 == 1 | t2010 == 1 | t2011 == 1
drop stock
sort id year
bysort id: gen stock = sum(smoke)
order stock, after(smoke)
gen temp = stock if year == 2009
bysort id: egen stock2009 = max(temp)

drop if year < 2005
sort id year
by id: gen trend = year-2004
gen partrend = trend*t2009
gen trend2 = .
replace trend2 = year - 2008
gen age2 = age^2


******************************************************************************
***************************** TABLE 5  **************************************
****************************************************************************** 

**Adjusting smoking variable for trends
xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coef2=_b[partrend]
di `coef2'
replace smoke = smoke - `coef2'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1

keep if index9 == 1
drop if year <= 2008

** Post-treatment estimates by level of addiction
xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef1 = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,5..8]
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4)

xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 age2 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef1a = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1a = A[1,5..8]
scalar nobs1a = e(N)
scalar nind1a = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue1a = r(p_1), r(p_2), r(p_3), r(p_4)

xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 if stock2009 <= 3 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2 = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,5..8]
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), r(p_4)


xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 age2 if stock2009 <= 3 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2a = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2a = A[1,5..8]
scalar nobs2a = e(N)
scalar nind2a = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue2a = r(p_1), r(p_2), r(p_3), r(p_4)

xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 if stock2009 == 4  | stock2009 == 5 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef3 = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = A[1,5..8]
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue3 = r(p_1), r(p_2), r(p_3), r(p_4)

xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 age2 if stock2009 == 4  | stock2009 == 5 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef3a = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3a = A[1,5..8]
scalar nobs3a = e(N)
scalar nind3a = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue3a = r(p_1), r(p_2), r(p_3), r(p_4)

xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 if stock2009 >= 6  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef4 = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = A[1,5..8]
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue4 = r(p_1), r(p_2), r(p_3), r(p_4)


xtreg smoke d2010 d2011 d2012 d2013 t1 t2 t3 t4 age2 if stock2009 >= 6  [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef4a = temp[1,5..8]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4a = A[1,5..8]
scalar nobs4a = e(N)
scalar nind4a = e(N_g)
boottest {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue4a = r(p_1), r(p_2), r(p_3), r(p_4)


foreach x in coef1 coef1a coef2 coef2a coef3 coef3a coef4 coef4a var1 var2 var3 var4 ///
var1a var2a var3a var4a	pvalue1 pvalue2 pvalue3 pvalue4 pvalue1a pvalue2a pvalue3a pvalue4a  {
	matrix colnames `x' =  t1 t2 t3 t4 
	estadd matrix `x'
}


estadd scalar nobs1
estadd scalar nobs2
estadd scalar nobs3
estadd scalar nobs4

estadd scalar nind1
estadd scalar nind2
estadd scalar nind3
estadd scalar nind4

esttab using "$results/tab5_cessation.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) "  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par)  var3(fmt(%12.3f) par)  var4(fmt(%12.3f) par) " ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ])) pvalue4(fmt(%12.3f) par([ ])) ") /// 
  collabels("2009 smokers" "$\leq$ 3 years"  "\{4,5\} years" "$\geq$ 6 years") /// 
  stats(nobs1 nobs2 nobs3 nobs4 nind1 nind2 nind3 nind4, ///
 layout("@ @ @ @" "@ @ @ @") label("N \times T" "N") fmt(%12.0fc)) /// 
  rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$") /// 
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  
******************************************************************************
*********************** Appendix Tab. B9  ************************************
******************************************************************************   
esttab using "$appendix/tab_b9.tex", /// 
cells("coef1a(fmt(%12.3f)) coef2a(fmt(%12.3f)) coef3a(fmt(%12.3f))  coef4a(fmt(%12.3f))"  /// 
"var1a(fmt(%12.3f) par)  var2a(fmt(%12.3f) par) var3a(fmt(%12.3f) par) var4a(fmt(%12.3f) par)" ///
"pvalue1a(fmt(%12.3f) par([ ]))  pvalue2a(fmt(%12.3f) par([ ])) pvalue3a(fmt(%12.3f) par([ ]))  pvalue4a(fmt(%12.3f) par([ ]))") /// 
  collabels("2009 smokers" "$\leq$ 3 years"  "\{4,5\} years" "$\geq$ 6 years" ) /// 
  stats(nobs1 nobs2 nobs3 nobs4 nind1 nind2 nind3 nind4, ///
 layout("@ @ @ @" "@ @ @ @") label("N \times T" "N") fmt(%12.0fc)) /// 
  rename(t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$") /// 
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  
 
******************************************************************************
*********************** Appendix Tab. B10  ***********************************
****************************************************************************** 
xtreg smoke d2013 t4 if year == 2009 | year == 2013 [aw = weight], fe vce(cluster uf)
 boottest t4, noci cluster(uf) seed(982638)


xtreg smoke d2013 1.t4#i.stock2009 if year == 2009 | year == 2013 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef = temp[1,2..7]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix sterror = A[1,2..7]
matrix colnames sterror = 1 2 3 4 5 6 
matrix colnames coef = 1 2 3 4 5 6 
boottest {1.t4#1.stock2009} {1.t4#2.stock2009} {1.t4#3.stock2009} {1.t4#4.stock2009} {1.t4#5.stock2009} {1.t4#6.stock2009}, noci cluster(uf) seed(982638)
matrix pvalue = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6)
matrix colnames pvalue = 1 2 3 4 5 6

test 1.t4#1.stock2009 = 1.t4#2.stock2009 = 1.t4#3.stock2009 = 1.t4#4.stock2009 = 1.t4#5.stock2009 = 1.t4#6.stock2009
scalar FF = r(F)
scalar FFp = r(p)

test 1.t4#1.stock2009 1.t4#2.stock2009 1.t4#3.stock2009 1.t4#4.stock2009 1.t4#5.stock2009 1.t4#6.stock2009
scalar FF1 = r(F)
scalar FFp1 = r(p)


xtreg smoke d2013 1.t4#i.stock2009 age2 if year == 2009 | year == 2013 [aw = weight], fe vce(cluster uf)
matrix temp = -e(b)
matrix coef2 = temp[1,2..7]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix sterror2 = A[1,2..7]
matrix colnames sterror2 = 1 2 3 4 5 6 
matrix colnames coef2 = 1 2 3 4 5 6 

boottest {1.t4#1.stock2009} {1.t4#2.stock2009} {1.t4#3.stock2009} {1.t4#4.stock2009} {1.t4#5.stock2009} {1.t4#6.stock2009}, noci cluster(uf) seed(982638)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6)
matrix colnames pvalue2 = 1 2 3 4 5 6

forvalues i = 1(1)6{
    forvalues j = 1(1)6{
test 1.t4#`i'.stock2009 = 1.t4#`j'.stock2009    
matrix F`i'`j' = r(F) 
matrix F`i'`j'_p = r(p) 	
	}
matrix F`i' = F`i'1, F`i'2, F`i'3, F`i'4, F`i'5, F`i'6
matrix F`i'p = F`i'1_p, F`i'2_p, F`i'3_p, F`i'4_p, F`i'5_p, F`i'6_p
matrix colnames F`i' = 1 2 3 4 5 6 
matrix colnames F`i'p = 1 2 3 4 5 6 
estadd matrix F`i'p
}

test 1.t4#1.stock2009 = 1.t4#2.stock2009 = 1.t4#3.stock2009 = 1.t4#4.stock2009 = 1.t4#5.stock2009 = 1.t4#6.stock2009
scalar FF2 = r(F)
scalar FFp2 = r(p)

test 1.t4#1.stock2009 1.t4#2.stock2009 1.t4#3.stock2009 1.t4#4.stock2009 1.t4#5.stock2009 1.t4#6.stock2009
scalar FF22= r(F)
scalar FFp22 = r(p)

estadd matrix pvalue2
estadd matrix coef2
estadd matrix sterror2
estadd matrix pvalue
estadd matrix coef
estadd matrix sterror

estadd scalar FF
estadd scalar FFp
estadd scalar FF1
estadd scalar FFp1
estadd scalar FF2
estadd scalar FFp2
estadd scalar FF22
estadd scalar FFp22


esttab using "$appendix/tab_b10.tex", /// 
cells("coef(fmt(%12.3f)) coef2(fmt(%12.3f)) F1p(fmt(%12.3f)) F2p(fmt(%12.3f)) F3p(fmt(%12.3f)) F4p(fmt(%12.4f)) F5p(fmt(%12.3f)) F6p(fmt(%12.3f))" ///
 "sterror(fmt(%12.3f) par) sterror2(fmt(%12.3f) par)" "pvalue(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ]))") /// 
  collabels("Effects" "Effects controlling"  "F-stat 1" "F-stat 2" "F-stat 3" "F-stat 4" "F-stat 5" "F-stat 6") /// 
  stats(N_g FF FF2 FFp FFp2 FF1 FF22 FFp1 FFp22,  layout("@" "@ @" "@ @" "@ @" "@ @") ///
  label("N" "F-stat" "p" "F_stat joint" "P_joint") fmt(%12.0fc %12.3fc %12.3fc %12.2e %12.2e %12.3fc %12.3fc %12.2e %12.2e)) /// 
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers
  
  
  clear all
