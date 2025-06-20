*******************************************************************************
************** APPENDIX TAB. B14: CAPITAL VS. STATE-LEVEL *********************
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

gen partrend_high_state = trend*enforcement_higher*state_law
gen partrend_high_city = trend*enforcement_higher*city_law
gen partrend_low_state= trend*enforcement_low*state_law
gen partrend_low_city= trend*enforcement_low*city_law

replace t2009 = 2 if enforcement_higher == 1 & state_law == 1
replace t2009 = 3 if enforcement_low ==1 & city_law == 1
replace t2009 = 4 if enforcement_low ==1 & state_law == 1

*************************REGRESSION COEFFICIENTS*******************************

*****PREVALENCE
xtreg smoke 1.d2006#1.t2009 1.d2007#1.t2009 1.d2008#1.t2009  ///
 1.d2010#1.t2009 1.d2011#1.t2009 1.d2012#1.t2009 1.d2013#1.t2009 ///
 1.d2006#2.t2009 1.d2007#2.t2009 1.d2008#2.t2009  ///
 1.d2010#2.t2009 1.d2011#2.t2009 1.d2012#2.t2009 1.d2013#2.t2009 ///
 1.d2006#3.t2009 1.d2007#3.t2009 1.d2008#3.t2009  ///
 1.d2010#3.t2009 1.d2011#3.t2009 1.d2012#3.t2009 1.d2013#3.t2009 ///
 1.d2006#4.t2009 1.d2007#4.t2009 1.d2008#4.t2009  ///
 1.d2010#4.t2009 1.d2011#4.t2009 1.d2012#4.t2009 1.d2013#4.t2009  ///
 partrend_high_city partrend_high_state partrend_low_city partrend_low_state  ///
 d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 [aw = weight], fe vce(cluster uf)

matrix temp = e(b)
matrix coef_high_city =  temp[1,13],temp[1,17], temp[1,21], temp[1,25], temp[1,29]       
matrix coef_high_state =  temp[1,14],temp[1,18], temp[1,22], temp[1,26], temp[1,30] 
matrix coef_low_city = temp[1,15],temp[1,19], temp[1,23], temp[1,27] , temp[1,31]     
matrix coef_low_state =  temp[1,16],temp[1,20], temp[1,24], temp[1,28], temp[1,32]       

boottest  {1.d2010#1.t2009} {1.d2011#1.t2009} {1.d2012#1.t2009} {1.d2013#1.t2009} {partrend_high_city} ///
   {1.d2010#2.t2009} {1.d2011#2.t2009} {1.d2012#2.t2009} {1.d2013#2.t2009} {partrend_high_state} ///
  {1.d2010#3.t2009} {1.d2011#3.t2009} {1.d2012#3.t2009} {1.d2013#3.t2009} {partrend_low_city} ///
 {1.d2010#4.t2009} {1.d2011#4.t2009} {1.d2012#4.t2009} {1.d2013#4.t2009} {partrend_low_state}, noci cluster(uf) seed(982638)
 
matrix pvalue_high_city = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5)
matrix pvalue_high_state =  r(p_6), r(p_7), r(p_8), r(p_9),  r(p_10)
matrix pvalue_low_city = r(p_11), r(p_12), r(p_13), r(p_14), r(p_15)
matrix pvalue_low_state =   r(p_16), r(p_17), r(p_18), r(p_19), r(p_20)


mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix temp = A'

matrix var_high_city =  temp[1,13],temp[1,17], temp[1,21], temp[1,25], temp[1,29] 
matrix var_high_state =  temp[1,14],temp[1,18], temp[1,22], temp[1,26], temp[1,30]
matrix var_low_city =  temp[1,15],temp[1,19], temp[1,23], temp[1,27], temp[1,31]       
matrix var_low_state =  temp[1,16],temp[1,20], temp[1,24], temp[1,28], temp[1,32]      
 
scalar nobs1 = e(N)
scalar nind1 = e(N_g)

 **Wald/F test 
test 1.d2006#1.t2009 1.d2007#1.t2009 1.d2008#1.t2009
scalar f1 = r(F)
 boottest 1.d2006#1.t2009 1.d2007#1.t2009 1.d2008#1.t2009 , noci cluster(uf) seed(982638)
scalar pF_high_city = r(p)

test 1.d2006#2.t2009 1.d2007#2.t2009 1.d2008#2.t2009
scalar f2 = r(F)
 boottest 1.d2006#2.t2009 1.d2007#2.t2009 1.d2008#2.t2009 , noci cluster(uf) seed(982638)
scalar pF_high_state = r(p)

test  1.d2006#3.t2009 1.d2007#3.t2009 1.d2008#3.t2009
scalar f3 = r(F)
 boottest  1.d2006#3.t2009 1.d2007#3.t2009 1.d2008#3.t2009 , noci cluster(uf) seed(982638)
scalar pF_low_city = r(p)

test  1.d2006#4.t2009 1.d2007#4.t2009 1.d2008#4.t2009
scalar f4 = r(F)
 boottest 1.d2006#4.t2009 1.d2007#4.t2009 1.d2008#4.t2009 , noci cluster(uf) seed(982638)
scalar pF_low_state = r(p)


foreach x in pvalue_high_city pvalue_high_state pvalue_low_city pvalue_low_state ///
coef_high_city coef_high_state coef_low_city coef_low_state var_high_city var_high_state /// 
var_low_city var_low_state {
	matrix colnames `x' = t1 t2 t3 t4 Trends
	estadd matrix `x'
}
 
***Baseline average

bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)

sum prevalence if t2009 == 1 & year ==2009
scalar mean_prev1 = r(mean)

sum prevalence if t2009 == 2 & year ==2009
scalar mean_prev2 = r(mean)

sum prevalence if t2009 == 3 & year ==2009
scalar mean_prev3 = r(mean)

sum prevalence if t2009 == 4 & year ==2009
scalar mean_prev4 = r(mean)

foreach j in nobs1 nind1 f1 f2 f3 f4 mean_prev1 mean_prev2 mean_prev3 mean_prev4  /// 
 pF_high_city pF_high_state pF_low_city pF_low_state {
	estadd scalar `j'
	}

esttab using "$appendix/tab_b14.tex", /// 
cells("coef_high_city(fmt(%12.3f)) coef_high_state(fmt(%12.3f)) coef_low_city(fmt(%12.3f)) coef_low_state(fmt(%12.3f))"  /// 
"var_high_city(fmt(%12.3f) par) var_high_state(fmt(%12.3f) par) var_low_city(fmt(%12.3f) par) var_low_state(fmt(%12.3f) par)" ///
"pvalue_high_city(fmt(%12.3f) par([ ])) pvalue_high_state(fmt(%12.3f) par([ ])) pvalue_low_city(fmt(%12.3f) par([ ])) pvalue_low_state(fmt(%12.3f) par([ ]))")  ///
stats(f1 f2 f3 f4 pF_high_city pF_high_state pF_low_city pF_low_state mean_prev1 mean_prev2 mean_prev3 mean_prev4 nobs1 nind1 , ///
 layout("@ @ @ @" "@ @ @ @"  "@ @ @ @ " "@" "@ ") label("F-stat" "P-value" "Average" "N \times T" "N") fmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc ///
  %9.3fc %9.3fc  %9.3fc %9.3fc   %9.3fc %9.3fc  %12.0fc)) /// 
 rename( t1 "$2010$" t2 "$2011$" t3 "$2012$" t4 "$2013$" Trends "\textit{Trends}") /// 
  collabels("City High" "State High" "City Low" "State Low") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers   
  
  
  clear all
