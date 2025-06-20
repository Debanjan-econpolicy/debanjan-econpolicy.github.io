clear all
set maxvar 10000
set matsize 10000

use "$data/raw/pns_2013.dta", clear
drop if V00291 ==. // keeping only residents selected for individual survey
 
*** Checking individual ID using variables from "Chaves_PNS_2013"
tostring V0001 V0024 UPA_PNS V0006_PNS C00301, replace
replace V0006_PNS = "0"+V0006_PNS if length(V0006_PNS) == 1
gen id = V0001 + V0024 + UPA_PNS + V0006_PNS + C00301
duplicates report id // no duplicates
gen dom = V0001 + V0024 + UPA_PNS + V0006_PNS 
duplicates report dom // single resident per household
drop dom 

*** Sociodemographic characteristics
rename (V0001 C00703 C008 V00291 V0029 VDF003) (uf birth age weight weight2 hh_income)
gen male = (C006==1)
gen capital = (V0031==1)
gen rural = (V0026 == 2)
gen hh_income_above = (hh_income>678) //  per capita income above minimum wage

*** Other risky behaviors
gen drink = 0
replace drink = 1 if P028 >=2 & P028 != . // drink alcohol twice or more per week 

gen sport = 0
replace sport = 1 if P035 >= 2 & P035 != . // practice sports twice or more per week 

**Keeping only variables of interest 
keep id uf birth age male capital rural hh_income hh_income_above drink sport weight weight2 P050 P051 P052 P053 ///
P056* P057 P059* P060 P061 P069 P07001 P07002 P07003 P071 P072 P05401
destring uf, replace

************** CREATING SMOKING VARIABLES ***************************************
rename (P050 P051 P052 P053) (smoker former_daily_smoker former_smoker starting_age)
rename (P05901 P05902 P05903) (years_quit months_quit weeks_quit)
rename (P060 P061 P069 P07001 P07002 P07003 P071 P072)  (tried_quit tried_treatment advertisement warning_newspaper warning_tv warning_radio package package_quit)

** REGULAR SMOKER
gen regular_smoker = (smoker == 1 ) // smoking on a daily basis
gen casual_smoker = (smoker == 2)  // smoking, but not on a daily basis
gen former_regular = (smoker == 3 & former_smoker == 1) 
gen former_casual = (smoker == 3 & former_smoker == 2) 
gen casual_former_regular = (smoker == 2 & former_daily_smoker == 1) 
gen not_manufactured = (P05401 == 1)
replace not_manufactured = . if regular_smoker == 0

** STARTING-AGE: available for current daily smokers, and former daily smokers (both non-smokers or casual smokers) 
tab smoker, m // 1- daily smoker; 2- casual smoker; 3 - not a smoker
bysort smoker: sum starting_age // observed for all current daily smokers

tab smoker former_daily_smoker, m // for smoker = 2 (current casual), whether 1- former daily; 2-not daily in past
bysort former_daily_smoker: sum starting_age // observed for current casual smokers that were former daily workers

tab smoker former_smoker, m // for smoker = 3 (non-smoker), whether 1- former daily; 2- former causally; 3 - never smoked
bysort former_smoker: sum starting_age // observed for non-smokers that were former daily workers

** SMOKING TIME
gen smoking_time = .
replace smoking_time = age - starting_age if starting_age != .
sum starting_age age smoking_time /*only individuals from 18 years old on participated in the tobacco survey: 60,202 observations*/						
			
** QUIT-TIME: available for non-smokers that were former smokers (both daily and causal)
tab smoker if years_quit != . /*only to former smokers (smoker == 3) */ 
tab former_daily_smoker if years_quit != . /*no observation for current casual smokers that were former daily smokers */ 
tab former_smoker if years_quit != . /*only to former smokers, both daily and casual*/ 
tab years_quit former_smoker

** Not smoking in the reference year if months_quit > 6 months
gen add_year = .
replace add_year = 0 if months_quit <= 6 & months_quit !=. 
replace add_year = 1 if months_quit > 6 & months_quit != .
gen add_year_rob3 = add_year
replace add_year_rob3 = 1 if months_quit > 3 & months_quit != .

gen add_year_rob9 = add_year
replace add_year_rob9 = 0 if months_quit <= 9 & months_quit !=. 

gen quit_time = years_quit + add_year
gen quit_time_rob3 = years_quit + add_year_rob3
gen quit_time_rob9 = years_quit + add_year_rob9

**** QUIT-TIME AND STARTING-AGE: available only to non-smokers that were former daily smokers
tab smoker if quit_time != . & starting_age != . /*only for non-smokers*/ 
tab former_smoker if quit_time != . & starting_age != . /*only for former daily smokers*/ 

**PRICE: per cigarette pack
sum P05601 P05602 P05603 P05604 P05605

gen price = .
replace price = (P057/P05601)*20 if P05601 != .
replace price = (P057/P05602) if P05602 != .
replace price = (P057/P05604)/10 if P05604 !=.
sum price,d

*Saving cross-section of the tobacco survey 
keep id uf birth age male capital rural hh_income hh_income_above drink sport weight weight2 ///
regular_smoker casual_smoker former_regular former_casual casual_former_regular starting_age quit_time quit_time_rob3 quit_time_rob9 ///
smoking_time price not_manufactured tried_quit tried_treatment advertisement warning_newspaper warning_tv warning_radio package package_quit
 
order id uf birth age male capital rural hh_income hh_income_above drink sport weight weight2 ///
regular_smoker casual_smoker former_regular former_casual casual_former_regular not_manufactured /// 
starting_age quit_time quit_time_rob3 quit_time_rob9 smoking_time price ///
tried_quit tried_treatment advertisement warning_newspaper warning_tv warning_radio package package_quit

label var id "individual id"
label var male "indicator for gender (male=1)"
label var capital "indicator for state capital"
label var rural "indicator for rural area"
label var hh_income "household income per capita"
label var hh_income_above "hh_income above minimum wage (678,00)"
label var drink "drink alcohol twice or more per week"
label var sport "practice sport twice or more per week"
label var regular_smoker "current daily smoker"
label var casual_smoker "current casual smoker"
label var former_regular "current non-smoker, former daily smoker"
label var former_casual "current non-smoker, former casual smoker"
label var casual_former_regular "current casual smoker, former daily smoker"
label var not_manufactured "daily smoker of non-manufactured cigarettes"
label var starting_age "age when started smoking on a daily basis"
label var smoking_time "measures smoking addiction for current smokers (age - smoking_age)"
label var quit_time "number of years since quit smoking"
label var quit_time_rob3 "number of years since quit smoking - robustness adding 3 months"
label var quit_time_rob9 "number of years since quit smoking - robustness adding 9 months"
label var price "price paid for a (manufactured) cigarette pack in last purchase"
label var tried_quit "if smoker tried to quit smoking (1 yes, 2 no)"
label var tried_treatment "if smoker looked for treatment to quit smoking (1 yes, 2 no)"
label var advertisement "saw cigarette advertisement in selling places (1 yes, 2 no, 3 don't remember)"
label var warning_newspaper "saw warnings about smoking risks on newspapers (1 yes, 2 no, 3 don't remember)"
label var warning_tv "saw warnings about smoking risks on TV (1 yes, 2 no, 3 don't remember)"
label var warning_radio "saw warnings about smoking risks on radio (1 yes, 2 no, 3 don't remember)"
label var package "saw warnings about smoking risks on packages (1 yes, 2 no, 3 don't remember)"
label var package_quit "warnings on packages incentive to quit (1 yes, 2 no)"
save "$data/pns2013_cross.dta", replace

*******************************************************************************
*******************************************************************************
*********Generating Panel******************************************************
*******************************************************************************
*smoke13 = individual was smoking in 2013
*smoke12 = individual was smoking in 2012
*smoke11 = individual was smoking in 2011
*smoke10 = individual was smoking in 2010
*smoke9 = individual was smoking in 2009
*smoke8 = individual was smoking in 2008
*smoke7 = individual was smoking in 2007
*smoke6 = individual was smoking in 2006
*smoke5 = individual was smoking in 2005

****Panel age
gen age13 = age
gen age12 = age - 1
gen age11 = age - 2
gen age10 = age - 3
gen age9 = age - 4
gen age8 = age - 5
gen age7 = age - 6
gen age6 = age - 7
gen age5 = age - 8
gen age4 = age - 9

gen smoke13 = 0
replace smoke13 = 1 if regular_smoker == 1
replace smoke13 = 1 if former_regular == 1  & quit_time == 0 
gen smokerob313 = (regular_smoker == 1)
replace smokerob313 = 1 if former_regular == 1  & quit_time_rob3 == 0 
gen smokerob913 = (regular_smoker == 1)
replace smokerob913 = 1 if former_regular == 1  & quit_time_rob9 == 0 

forvalues i = 12(-1)4{
local j = 13 - `i'
gen smoke`i' = (regular_smoker == 1 & smoking_time >= `j' & smoking_time != .)
replace smoke`i' = 1 if former_regular == 1 & quit_time <= `j' & smoking_time >= `j'

** For robustness
gen smokerob3`i' = (regular_smoker == 1 & smoking_time >= `j' & smoking_time != .)
gen smokerob9`i' = (regular_smoker == 1 & smoking_time >= `j' & smoking_time != .)
replace smokerob3`i' = 1 if former_regular == 1  & quit_time_rob3 <= `j' & smoking_time >= `j'
replace smokerob9`i' = 1 if former_regular == 1  & quit_time_rob9 <= `j' & smoking_time >= `j'
}

gen stock = smoking_time - quit_time
gen mistake = (stock < 0)
replace mistake = . if quit_time == .
label var stock "addiction time (smoking_time - quit_time)"

preserve
keep id stock mistake
merge 1:1 id using "$data/pns2013_cross.dta", nogenerate 
save "$data/pns2013_cross.dta", replace
restore

drop if mistake == 1
drop mistake age quit_time_rob3 quit_time_rob9

reshape long age smoke smokerob3 smokerob9, i(id) j(year) string
destring year, replace
replace year = year + 2000
rename id code
egen id = group(code)

label var smoke "indicator if regular smoker"
label var smokerob3 "indicator if regular smoker for robustness of threshold=3"
label var smokerob9 "indicator if regular smoker for robustness of threshold=9"
label var age "age"
label var id "encoded individual id"
label var year "year"
 
xtset id year
xtdescribe
save "$data/pns2013_panel.dta", replace

*******************************************************************************
*******************************************************************************
************************Data to check fit**************************************
*******************************************************************************
*******************************************************************************
preserve
keep if year == 2008
gen indicator = 1

bysort smoke: tab former_regular
replace former_regular = 0 if smoke == 1 
bysort smoke: tab former_casual
bysort smoke: tab casual_smoker 
keep if age >= 15

replace smoking_time = smoking_time - 5 if smoking_time != .
replace quit_time = quit_time - 5 if quit_time != .
tab smoke if smoking_time <= 0 & smoking_time != .

replace smoke = 0 if smoking_time <= 0 & smoking_time != .
tab former_regular if smoking_time <= 0 & smoking_time != .
replace former_regular = 0 if smoking_time <= 0 & smoking_time != .
replace smoking_time = . if smoking_time <= 0 & smoking_time != .

tab smoke if quit_time <= 0 & quit_time != .
sum smoking_time if smoke==0 & quit_time <= 0 & quit_time != .
tab former_regular if quit_time <= 0 & quit_time != .
replace quit_time = . if quit_time <= 0
replace quit_time = . if former_regular == 0
replace quit_time = . if smoke == 1

replace starting_age = . if smoke == 0 & former_regular == 0
keep uf indicator male rural weight capital smoke former_regular smoking_time age quit_time starting_age
label var indicator "retrospective data from PNS 2013"
save "$data/pns2013_2008.dta", replace
restore

*******************************************************************************
*******************************************************************************
************Keeping only capitals in the panel*********************************
*******************************************************************************
*******************************************************************************
keep if capital ==1 
tab capital, m
tab year

***Generating treatment variables
gen t2008 = 0
replace t2008 = 1 if uf == 11 // Rondônia

gen t2009 = 0
replace t2009 = 1 if uf == 13 | uf == 14 | uf == 25 | uf == 35 | uf == 41 | uf == 52 | uf == 15 | uf == 28 | uf == 29 | uf == 12 | uf == 50 | uf == 33

gen t2010 = 0
replace t2010 = 1 if uf == 22 //Piauí

gen t2011 = 0
replace t2011 = 1 if  uf == 51 //  Mato Grosso

gen state_law = 0
replace state_law = 1 if uf == 11 | uf == 14 | uf == 13| uf == 33 | uf == 35 | uf == 25 | uf == 41|  uf == 52 | uf == 51

gen city_law = 0
replace city_law = 1 if uf == 15 | uf == 28 |  uf == 29 |  uf == 12 |  uf == 50 |  uf == 22 

gen enforcement_higher = 0
replace enforcement_higher = 1 if uf == 41 | uf == 33 | uf == 35 | uf == 50 | uf == 52 | uf == 22 | uf == 29 | uf == 51 

gen enforcement_low = 0
replace enforcement_low = 1 if  uf == 14 | uf == 25 | uf == 15 | uf == 28 | uf == 12 | uf == 13 

*** Event-time
gen event_time = year - 2009 if t2009 == 1 
replace event_time = year - 2008 if t2008 == 1 
replace event_time = year - 2010 if t2010 == 1 
replace event_time = year - 2011 if t2011 == 1 

*** Treatment indicators 
forvalues i = 4(-1)1{
gen t_`i' = (event_time == -`i')
gen t_`i'_state = t_`i'*(state_law)
gen t_`i'_city = t_`i'*(city_law)
gen t_`i'_higher = t_`i'*(enforcement_higher)
gen t_`i'_low = t_`i'*(enforcement_low)	
}

forvalues i = 0(1)4{ 
gen t`i' = (event_time == `i')
gen t`i'_state = t`i'*(state_law)
gen t`i'_higher = t`i'*(enforcement_higher)
gen t`i'_low = t`i'*(enforcement_low)
gen t`i'_city = t`i'*(city_law)
}

** Year dummies 
forvalues i = 2004(1)2013{
gen d`i' = (year == `i')	
}

label var t2008 "cohort treated in 2008" 
label var t2009 "cohort treated in 2008" 
label var t2010 "cohort treated in 2008" 
label var t2011 "cohort treated in 2008" 
label var state_law "smoking ban introduced by state" 
label var city_law "smoking ban introduced only by city" 
label var enforcement_higher "strongly enforced smoking ban" 
label var enforcement_low "weakly enforced smoking ban" 
label var event_time "years relative to introduction of ban" 
save "$data/pns2013_panel", replace


**********SMOKING DYNAMICS
preserve
keep if year ==2005 & (age >= 15 & age <= 29)
gen index = (smoke == 1) 
keep id index
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
sort id year
bysort id: gen status_smoke = sum(smoke)
order status_smoke, after(smoke)
gen smoke_initiation = 0 if index == 0 
replace smoke_initiation = 1 if index == 0 & status_smoke > 0 & status_smoke != .
drop status_smoke
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2009 
gen index9 = (smoke==1)
gen index9_never = index9
replace index9_never = . if quit_time >= 5 & quit_time !=.
keep id index9 index9_never
tab index9 index9_never, m
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2005
gen index5 = (smoke==1)
keep id index5
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
sort id year
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2005
gen index5 = (smoke==1)
keep id index5
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
sort id year
save "$data/pns2013_panel.dta", replace
restore

*** Robustness for threshold
preserve
keep if year == 2009 
gen index9_rob3 = (smokerob3==1)
keep id index9_rob3 
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2009 
gen index9_rob9 = (smokerob9==1)
keep id index9_rob9 
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2005
gen index5_rob3 = (smokerob3==1)
keep id index5_rob3
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
sort id year
save "$data/pns2013_panel.dta", replace
restore

preserve
keep if year == 2005
gen index5_rob9 = (smokerob9==1)
keep id index5_rob9
merge 1:m id using "$data/pns2013_panel.dta", nogenerate
sort id year
save "$data/pns2013_panel.dta", replace
restore

clear all


