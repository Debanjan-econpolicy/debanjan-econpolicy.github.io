*******************************************************************************
********************** DECOMPOSITION OF PREVALENCE ****************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
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

xtset id year

***Program for Bootstrap
program define two_stages_inic, rclass
sum smoke if t2009 == 1 & year == 2009 [aw=weight]
local share_inic = 1-`r(mean)'
local share_ces = `r(mean)'
cap drop smoke2
qui xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 0 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coef1=_b[partrend]
qui gen smoke2 = smoke
qui replace smoke2 = smoke2 - `coef1'*trend2 if year >= 2009 & t2009 == 1 & index9 == 0 
qui xtreg smoke2 i.year d2010 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf) 
lincom `share_inic'*t1 
return scalar t1_inic = `r(estimate)'
lincom `share_inic'*t2
return scalar t2_inic = `r(estimate)'
lincom `share_inic'*t3
return scalar t3_inic = `r(estimate)'
lincom `share_inic'*t4
return scalar t4_inic = `r(estimate)'
cap drop smoke_ces
qui xtreg smoke d2006 d2007 d2008 d2009 t_3 t_2 t_1 partrend if index5 == 1 & year <= 2009  [aw = weight], fe vce(cluster uf)
local coef2=_b[partrend]
qui gen smoke_ces = smoke
qui replace smoke_ces = smoke_ces - `coef2'*trend2 if year >= 2009 & t2009 == 1 & index9 == 1
qui xtreg smoke_ces i.year d2010 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
lincom -`share_ces'*t1 
return scalar t1_ces = `r(estimate)'
lincom -`share_ces'*t2
return scalar t2_ces = `r(estimate)'
lincom -`share_ces'*t3
return scalar t3_ces = `r(estimate)'
lincom -`share_ces'*t4
return scalar t4_ces = `r(estimate)'
cap drop res_inic
qui reghdfe smoke2 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], absorb(id year) residuals(res_inic)  
eststo inic
cap drop res_ces
qui reghdfe smoke_ces t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], absorb(id year) residuals(res_ces)  
eststo cess
suest inic cess, vce(cluster uf)
lincom `share_ces'*[cess]t1 + `share_inic'*[inic]t1 
return scalar t1_all = `r(estimate)'
lincom `share_ces'*[cess]t2 + `share_inic'*[inic]t2 
return scalar t2_all = `r(estimate)'
lincom `share_ces'*[cess]t3 + `share_inic'*[inic]t3
return scalar t3_all = `r(estimate)'
lincom `share_ces'*[cess]t4 + `share_inic'*[inic]t4
return scalar t4_all = `r(estimate)'
end


bootstrap (r(t1_inic))  (r(t2_inic)) (r(t3_inic)) (r(t4_inic)) (r(t1_ces))  (r(t2_ces)) (r(t3_ces)) (r(t4_ces))   /// 
 (r(t1_all))  (r(t2_all)) (r(t3_all)) (r(t4_all)), cluster(uf) idcluster(uf_id) group(id) reps(100) seed(982638): two_stages_inic
  
matrix coef_inic = r(table)[1,1..4]
matrix se_inic = r(table)[2,1..4]
matrix p_inic = r(table)[4,1..4]

matrix coef_ces = r(table)[1,5..8]
matrix se_ces = r(table)[2,5..8]
matrix p_ces = r(table)[4,5..8]

matrix coef_decomp = r(table)[1,9..12]
matrix se_decomp = r(table)[2,9..12]
matrix p_decomp = r(table)[4,9..12]


qui xtreg smoke_ces i.year d2010 t1 t2 t3 t4 if index9 == 1 & year >= 2009 [aw = weight], fe vce(cluster uf)
scalar nobs_ces = e(N)
scalar nind_ces = e(N_g)

qui xtreg smoke2 i.year d2010 t1 t2 t3 t4 if index9 == 0 & year >= 2009 [aw = weight], fe vce(cluster uf)
scalar nobs_ini = e(N)
scalar nind_ini = e(N_g)

*************************REGRESSION COEFFICIENTS*******************************
estimates drop _all
xtreg smoke i.year d2008 d2009  t_3 t_2 t_1 t1 t2 t3 t4 partrend  [aw = weight], fe vce(cluster uf)
matrix coef1 = e(b)[1,15..18]
mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'
matrix var1 = A[1,15..18]
scalar nobs1 = e(N)
scalar nind1 = e(N_g)
boottest  {t1} {t2} {t3} {t4}, noci cluster(uf) seed(982638)
matrix pvalue1 = r(p_1), r(p_2), r(p_3), r(p_4)


foreach x in coef_inic coef_ces coef_decomp se_inic se_ces se_decomp p_inic p_ces p_decomp coef1 var1 pvalue1 {
	matrix colnames `x' = t1 t2 t3 t4 
	estadd matrix `x', replace
	matrix rownames `x' = b
}

	foreach j in nobs1 nobs_ini nobs_ces nind1 nind_ini nind_ces {
	estadd scalar `j', replace
	}
	

esttab using "$results/tab4_decomp.tex", /// 
cells("coef_inic(fmt(%12.3f)) coef_ces(fmt(%12.3f)) coef_decomp(fmt(%12.3f)) coef1(fmt(%12.3f))   "  /// 
" se_inic(fmt(%12.3f) par) se_ces(fmt(%12.3f) par) se_decomp(fmt(%12.3f) par) var1(fmt(%12.3f) par)  " ///
" p_inic(fmt(%12.3f) par({ }))  p_ces(fmt(%12.3f) par({ }))  p_decomp(fmt(%12.3f) par({ })) pvalue1(fmt(%12.3f) par([ ])) " )  ///
stats(nobs_ini nobs_ces nobs1 nind_ini nind_ces nind1, layout("@ @ @ " "@ @ @") label("N \times T" "N") fmt( %12.0fc)) /// 
 rename( t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$") /// 
 collabels("Initiationx`share_inic'" "Cessationx``share_ces''" "Decomposition" "Prevalence" ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace  substitute({ \{ } \})  eqlabels(none) title(none) nonumbers   


 clear all