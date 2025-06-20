
*******************************************************************************
*********************** APPENDIX TAB. B4: STAGGERED ***************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022


use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 
sort id year
drop t2008 event_time

// time_treated is a variable for unit-specific treatment years (never-treated: time_treated == missing)
***** Generating event time variable

gen time_treated = cond(t2009 == 1, 2010, .) 
replace time_treated = 2011 if t2010 == 1 
replace time_treated = 2012 if t2011 == 1 
gen event_time = (year - time_treated)
drop if (event_time < -5 | event_time >3)  & event_time != . 

by id: gen trend = _n if event_time== .
replace trend = event_time + 5 if event_time != .
gen partrend2009 = trend*t2009
gen partrend2010 = trend*t2010
gen partrend2011 = trend*t2011

// eventstudyinteract of Sun and Abraham (2020)

	// dummy for never-treated cohort
	gen never_treated = missing(time_treated)

	forvalues l = 0(1)3 {
		gen L`l'event = event_time ==`l'
	}
	forvalues l = 1(1)5 {
		gen F`l'event = event_time == -`l'
	}
	drop F1event 

	****PREVALENCE
	eventstudyinteract smoke L*event F*event [aw=weight], vce(cluster uf) absorb(id year) cohort(time_treated) control_cohort(never_treated)
	matrix C = e(b_iw)
	mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
	matrix C = C \ A
	matrix B4 = C[1..2,8]
	matrix B3 = C[1..2,7]
	matrix B2 = C[1..2,6]
	matrix B1 = C[1..2,5]
	matrix D = C[1..2,1..4]
	matrix SA = B4,B3,B2,B1, D
	matrix coef1 = SA[1,1..8]
	matrix var1 = SA[2,1..8]
	scalar obs1 = e(N)
	
	**Weight 
	matrix list e(ff_w)  

	eventstudyinteract smoke L*event F2event F3event F4event   [aw=weight], vce(cluster uf) absorb(id year) /// 
	cohort(time_treated) control_cohort(never_treated) covariates( partrend2009 partrend2010 partrend2011)
	matrix C = e(b_iw)
	mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
	matrix C = C \ A
	matrix B4 = 0\0
	matrix B3 = C[1..2,7]
	matrix B2 = C[1..2,6]
	matrix B1 = C[1..2,5]
	matrix D = C[1..2,1..4]
	matrix SA = B4,B3,B2,B1, D
	matrix coef2 = SA[1,1..8]
	matrix var2 = SA[2,1..8]
	scalar obs2 = e(N)
	**Weight 
	matrix list e(ff_w)  
*******************************************************************************
**** MOVING TWO UNITS TREATED IN THE BEGINNING OF 2010 TO 2010 COHORT
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022

use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 
sort id year
drop t2008 event_time t2010
gen t2010 = (uf == 12 | uf == 50 | uf == 22)
replace t2009 = 0 if t2010== 1 | t2011 == 1	

***** Generating event time variable
gen time_treated = cond(t2009 == 1, 2010, .) 
replace time_treated = 2011 if t2010 == 1 
replace time_treated = 2012 if t2011 == 1 
gen event_time = (year - time_treated)
drop if (event_time < -5 | event_time >3)  & event_time != . 

by id: gen trend = _n if event_time== .
replace trend = event_time + 5 if event_time != .
gen partrend2009 = trend*t2009
gen partrend2010 = trend*t2010
gen partrend2011 = trend*t2011

// eventstudyinteract of Sun and Abraham (2020)

	// dummy for never-treated cohort
	gen never_treated = missing(time_treated)

	forvalues l = 0(1)3 {
		gen L`l'event = event_time ==`l'
	}
	forvalues l = 1(1)5 {
		gen F`l'event = event_time == -`l'
	}
	drop F1event 

	****PREVALENCE
	eventstudyinteract smoke L*event F*event [aw=weight], vce(cluster uf) absorb(id year) cohort(time_treated) control_cohort(never_treated)
	matrix C = e(b_iw)
	mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
	matrix C = C \ A
	matrix B4 = C[1..2,8]
	matrix B3 = C[1..2,7]
	matrix B2 = C[1..2,6]
	matrix B1 = C[1..2,5]
	matrix D = C[1..2,1..4]
	matrix SA = B4,B3,B2,B1, D
	matrix coef3 = SA[1,1..8]
	matrix var3 = SA[2,1..8]
	scalar obs3 = e(N)

	eventstudyinteract smoke L*event F2event F3event F4event   [aw=weight], vce(cluster uf) absorb(id year) /// 
	cohort(time_treated) control_cohort(never_treated) covariates( partrend2009 partrend2010 partrend2011)
	matrix C = e(b_iw)
	mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
	matrix C = C \ A
	matrix B4 = 0\0
	matrix B3 = C[1..2,7]
	matrix B2 = C[1..2,6]
	matrix B1 = C[1..2,5]
	matrix D = C[1..2,1..4]
	matrix SA = B4,B3,B2,B1, D
	matrix coef4 = SA[1,1..8]
	matrix var4 = SA[2,1..8]
	scalar obs4 = e(N)

	
***Baseline average
gen treated = 0
replace treated = 1 if t2009 == 1 | t2010 == 1 | t2011 == 1 
bysort year treated: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year treated: egen prevalence = sum(smoke_prev)

sum prevalence if treated == 1 & year ==2009
scalar mean_prev = r(mean)


foreach x in coef1 coef2 coef3 coef4 var1 var2 var3 var4  {
	matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4
	estadd matrix `x', replace
}

foreach j in obs1 obs2 obs3 obs4 mean_prev  {
	estadd scalar `j'
	}
 

 esttab using "$appendix/tab_b4.tex", /// 
cells("coef1(fmt(%12.3f)) coef2(fmt(%12.3f)) coef3(fmt(%12.3f)) coef4(fmt(%12.3f))" ///
 "var1(fmt(%12.3f) par) var2(fmt(%12.3f) par) var3(fmt(%12.3f) par) var4(fmt(%12.3f) par)")  ///
stats(mean_prev  obs1 obs2 obs3 obs4, ///
 layout("@"  "@ @ @ @" ) label("Average" "N \times T") fmt(%9.3fc  %12.0fc)) /// 
 rename(  t_4 "$\hat{\beta}_{-4}$" t_3 "$\hat{\beta}_{-3}$" t_2 "$\hat{\beta}_{-2}$" t_1 "$\hat{\beta}_{-1}$" ///
  t1 "$\hat{\beta}_1$" t2 "$\hat{\beta}_2$" t3 "$\hat{\beta}_3$" t4 "$\hat{\beta}_4$" ) collabels("(1) Standard" "(2) Standard"  "(3) Alt.2010" "(4) Alt.2010") ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers ///
   prefoot("\hline Trends & No & Yes & No & Yes \\") star(* 0.10 ** 0.05 *** 0.01)
   
  
 clear all
 