*******************************************************************************
*****************************PREVALENCE AVG. **********************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 | t2010 == 1 | t2011 == 1
sort id year
by id: gen trend = _n
gen partrend = trend*t2009
gen age2 = age^2

*************************REGRESSION COEFFICIENTS*******************************
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 t_4 t_3 t_2 t_1 t1 t2 t3 t4  [pw = weight], fe vce(cluster uf)

matrix temp = e(b)
matrix coef1 = temp[1,9..16], .
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,9..16],. 
matrix colnames var1 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef1 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest {t_4} {t_3} {t_2} {t_1} {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8), .

 **Wald/F test 
test t_4 t_3 t_2 t_1 
scalar f1 = r(F)
boottest t_4 t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF1 = r(p)

***Controlling for age sqr
xtset id year
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 t_4 t_3 t_2 t_1 t1 t2 t3 t4 age2  [pw = weight], fe vce(cluster uf)

matrix temp = e(b)
matrix coef2 = temp[1,9..16], .
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var2 = A[1,9..16],. 
matrix colnames var2 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef2 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs2 = e(N)
scalar nind2 = e(N_g)
boottest {t_4} {t_3} {t_2} {t_1} {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue2 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8), .

 **Wald/F test 
test t_4 t_3 t_2 t_1 
scalar f2 = r(F)
boottest t_4 t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF2 = r(p)

***with linear trends
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend  [pw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef3 = .,temp[1,9..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var3 = .,A[1,9..16]
matrix colnames var3 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef3 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs3 = e(N)
scalar nind3 = e(N_g)
boottest {t_3} {t_2} {t_1} {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue3 = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f3 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF3 = r(p)


***with linear trends and age swr
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t_3 t_2 t_1 t1 t2 t3 t4 partrend age2  [pw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef4 = .,temp[1,9..16]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var4 = ., A[1,9..16]
matrix colnames var4 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef4 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs4 = e(N)
scalar nind4 = e(N_g)
boottest {t_3} {t_2} {t_1} {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue4 = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)

 **Wald/F test 
test t_3 t_2 t_1 
scalar f4 = r(F)
boottest t_3 t_2 t_1, noci cluster(uf) seed(982638)
scalar pF4 = r(p)


***with linear trends and without pre-estimates
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t1 t2 t3 t4 partrend  [pw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef5 = ., ., ., ., temp[1,9..13]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var5 = ., ., ., ., A[1,9..13]
matrix colnames var5 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef5 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs5 = e(N)
scalar nind5 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend}, noci cluster(uf) seed(982638)
matrix pvalue5 = ., ., ., ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
scalar f5 = 0
scalar pF5 = 0

***with linear trends, age sqr and without pre-estimates
xtreg smoke d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013  t1 t2 t3 t4 partrend age2 [pw = weight], fe vce(cluster uf)
matrix temp = e(b)
matrix coef6 = ., ., ., ., temp[1,9..13]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var6 = ., ., ., ., A[1,9..13]
matrix colnames var6 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
matrix colnames coef6 = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
scalar nobs6 = e(N)
scalar nind6 = e(N_g)
boottest {t1} {t2} {t3} {t4} {partrend} , noci cluster(uf) seed(982638)
matrix pvalue6 = ., ., ., ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)

 **Wald/F test 
scalar f6 = 0
scalar pF6 = 0

foreach x in coef1 coef2 coef3 coef4 coef5 coef6 var1 var2 var3 var4 var5 var6 ///
	pvalue1 pvalue2 pvalue3 pvalue4 pvalue5 pvalue6 {
	matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
	estadd matrix `x'
}

foreach j in nobs1 nobs2 nobs3 nobs4 nobs5 nobs6 nind1 nind2 nind3 nind4 nind5 nind6 ///
	f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 {
	estadd scalar `j'
	}
 
***Baseline average

bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = 100*smoke*(weight/tot_weight_prev)


bysort year t2009: egen prevalence = sum(smoke_prev)
sum prevalence if year ==2009 & (t2009 == 0)
local avg_control: di %9.1f `r(mean)' 
sum prevalence if year ==2009 & (t2009 == 1)
local avg_treated: di %9.1f `r(mean)' 
scalar mean_prev = r(mean)
estadd scalar mean_prev


esttab using "$appendix/tab_b5.tex", /// 
cells(" coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f)) coef5(fmt(%12.3f)) coef6(fmt(%12.3f))  "  /// 
"var1(fmt(%12.3f) par) var2(fmt(%12.3f) par)  var3(fmt(%12.3f) par)  var4(fmt(%12.3f) par) var5(fmt(%12.3f) par) var6(fmt(%12.3f) par) " ///
"pvalue1(fmt(%12.3f) par([ ])) pvalue2(fmt(%12.3f) par([ ])) pvalue3(fmt(%12.3f) par([ ]))   pvalue4(fmt(%12.3f) par([ ])) pvalue5(fmt(%12.3f) par([ ])) pvalue6(fmt(%12.3f) par([ ])) ")  ///
stats(f1 f2 f3 f4 f5 f6 pF1 pF2 pF3 pF4 pF5 pF6 mean_prev  nobs1 nobs2 nobs3  nobs4 nobs5 nobs6 nind1 nind2 nind3 nind4 nind5 nind6 , ///
 layout("@ @ @ @ @ @" "@ @ @ @ @ @" "@" "@ @ @ @ @ @" "@ @ @ @ @ @") label("F-stat" "P-value" "Average" "N \times T" "N") /// 
 fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %12.3f %12.3f %12.3f %12.3f %12.3f %12.3f %9.3fc %9.3fc %9.3fc %12.0fc)) /// 
 rename(t_4 "$2005$" t_3 "$2006$" t_2 "$2007$" t_1 "$2008$" ///
  t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trends "\textit{Trends}") collabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers ///
   prefoot(" \hline Age$^2$ & No & Yes & No & Yes & No & Yes \\")
  
 matrix coef1 = coef1[1,1..4],0, coef1[1,5..8]
 matrix var1 = var1[1,1..4],0, var1[1,5..8]
 
 matrix coef3 = 0, coef3[1,2..4],0, coef3[1,5..8]
 matrix var3 = 0, var3[1,2..4],0, var3[1,5..8]
  
matrix estimates = coef1 \ var1 \ coef3 \ var3  
matrix colnames estimates = t_4 t_3 t_2 t_1 t0  t1 t2 t3 t4 


coefplot (matrix(estimates[1]), se(estimates[2]) color(black)   ciopts(lpattern(shortdash) lcolor(black))  offset(-0.1) ) ///
(matrix(estimates[3]), se(estimates[4]) color(black) msymbol(T)  ciopts( lcolor(black)) offset(0.1) ), ///
 baselevels omitted /// 
xlabel(1 "2005" 2 "2006" 3 "2007" 4 "2008" 5 "2009" 6 "2010" 7 "2011" 8 "2012" 9 "2013", labsize(vlarge) angle(45) ) ///
			vertical graphregion(color(white)) bgcolor(white) ///
legend(order(2 "Without controls" 4 "With linear trends" ) rows(1)   size(vlarge)) ///
			xline(5.5, lcolor(gray)) ytitle("proportion of smokers", size(large))  xtitle("")  ///
	       yline(0, lwidth(vvvthin) lpattern(dash) lcolor(black)) ylabel(-0.03(0.01)0.02,labsize(large)) /// 
		   text(-0.021 3.4 "{bf:Baseline avg.:}",  size(medlarge)) /// 
		   text(-0.025 3.4 "`avg_treated'% treated",  size(medlarge) ) /// 
		   text(-0.029 3.4 "`avg_control'% untreated",  size(medlarge) )
graph export "$results/fig3a_prevalence.png", replace
 
 
 
 clear all 
   
 
  
  
   
  