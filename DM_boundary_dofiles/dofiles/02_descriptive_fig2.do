
*******************************************************************************
*****************************DESCRIPTIVE STATS*********************************
*******************************************************************************

******************SAMPLE SIZE AND UNBALANCED PANEL******************************
use "$data/pns2013_panel.dta", clear
drop if t2008 == 1
keep if age >= 15 & age <= 29
keep if year >= 2005
xtset id year
xtdescribe, patterns(50)
matrix A = r(p5), r(p10), r(p25), r(p50), r(p75), r(mean), r(N), r(sum)
matrix colnames A = p5 p10 p25 p50 p75 mean N obs
esttab  matrix(A) using "$desc/panel_size.txt", replace

*** For the cohorts considered in the main analysis:
drop if t2010 == 1 | t2011 == 1
xtdescribe, patterns(50)
matrix B = r(p5), r(p10), r(p25), r(p50), r(p75), r(mean), r(N), r(sum)
matrix colnames B = p5 p10 p25 p50 p75 mean N obs
esttab  matrix(B) using "$desc/panel_size.txt", append

********************SAMPLE RESTRICTION: DATA SECTION ***************************
use "$data/pns2013_cross.dta", clear

*** Proportion of residents capital with and without weights
sum capital // 45% of the survey
scalar mean_capital = r(mean)
svyset [weight = weight]
svy: proportion capital  // but represents 25% of Brazilian population
scalar mean_weight = e(b)[1,2]


**** Overall Smoking Prevlance
gen prevalence = regular_smoker + casual_smoker
svy: proportion prevalence  // overall smoking prevalence 
matrix prevalence = e(b)[1,2]
svy: proportion regular_smoker  // overall smoking prevalence 
matrix prevalence =prevalence, e(b)[1,2]
svy: proportion casual_smoker  // overall smoking prevalence 
matrix prevalence =prevalence, e(b)[1,2]
matrix colnames prevalence  = overall regular casual
matrix rownames prevalence  = 2013All

*** Generating treatment variables
drop if uf == 11 // 2008 cohort is not included as treated in the paper
gen t2009 = 0
replace t2009 = 1 if uf == 13 | uf == 14 | uf == 25 | uf == 35 | uf == 41 | uf == 52 | uf == 15 | uf == 28 | uf == 29 | uf == 12 | uf == 50 | uf == 33
gen t2010 = 0
replace t2010 = 1 if uf == 22
gen t2011 = 0
replace t2011 = 1 if uf == 51
gen treated = 0
replace treated = 1 if t2009 == 1 | t2010 == 1 | t2011 == 1

egen grupo=group(uf)
gen young = 0
replace young = 1 if 18 <= age & age <= 29 // 2013 data restricted to 18+

*** Share of capital by treatment
reg capital t2009 if t2010 == 0 & t2011 == 0 [aw = weight], vce(cluster grupo)
eststo reg_cap
estadd scalar mean_weight

*** Share of young by treatment
reg young t2009 if capital == 1 & t2010 == 0 & t2011 == 0 [aw = weight], vce(cluster grupo)
eststo reg_youth
estadd scalar mean_capital

esttab reg_cap reg_youth using "$desc/sample_restrictions.txt", replace /// 
stats(mean_weight mean_capital , layout("@" "@") label("Prop.Capital" "No weight") fmt(%9.2fc))

*** Relation between weight and treatment 
reg weight 1.t2009##1.regular_smoker if young == 1 & capital == 1
eststo weight 
esttab weight using "$desc/sample_restrictions.txt", append  


*** Proportion of treatment with and without weight
sum t2009  if young == 1 & capital == 1
sum t2009  if young == 1 & capital == 1 [aw = weight]


***************************SMOKING STATS****************************************
** Quantity of smokers
use "$data/pns2013_cross.dta", clear
gen regular_smoker_abs = regular_smoker*weight

gen young = 0
replace young = 1 if age >= 18 & age < 30
bysort young: egen regular_smoker_tot = total(regular_smoker_abs)
egen smokers = total(regular_smoker_abs)

replace smokers = smokers/1000
replace regular_smoker_tot = regular_smoker_tot/1000

sum smokers 
matrix A = r(mean)
sum regular_smoker_tot if young == 1
matrix A = r(mean),A
matrix colnames A = Young Total
matrix rownames A = "2013Regular"
matrix ThousandSmokers = A
esttab  matrix(ThousandSmokers)  using "$desc/number_smokers.txt", replace 
esttab  matrix(prevalence)  using "$desc/number_smokers.txt", append 

*** Regular smoking prevalence in Brazilian Capital: Adults
use "$data/pns2013_panel.dta", clear
keep if age >= 15 
keep if year >= 2005
replace smoke = smoke*100

sum smoke [aw=weight] if year == 2005 & age >= 18
matrix A = r(mean)

sum smoke [aw=weight] if year == 2013 & age >= 18
matrix A = A, r(mean)

sum smoke [aw=weight] if year == 2005 & age <= 29
matrix B = r(mean)

sum smoke [aw=weight] if year == 2013  & age <= 29
matrix B = B, r(mean)

matrix Prevalence = A\B
matrix colnames Prevalence = 2005 2013
matrix rownames Prevalence = Adults YoungAdults
esttab  matrix(Prevalence)  using "$desc/number_smokers.txt", append 

** Quantity of young adults smokinh in 2009 
use "$data/pns2013_panel.dta", clear
keep if age >= 15 & age < 30
keep if year == 2009
gen regular_smoker_abs = smoke*weight
egen smokers = total(regular_smoker_abs)
replace smokers = smokers/1000

sum smokers 
matrix ThousandSmokers = r(mean)
matrix colnames ThousandSmokers = YoungCapitaL 
matrix rownames ThousandSmokers = "2009Regular"
esttab  matrix(ThousandSmokers)  using "$desc/number_smokers.txt", append 

*************************** DYNAMICS ****************************************

***Initiation
use "$data/pns2013_panel.dta", clear
keep if age >= 15 & age <= 29
keep if capital == 1
keep if year == 2013
replace smoke = smoke*100
sum smoke [aw=weight] if index9 == 0
matrix dynamics = r(mean)
sum smoke [aw=weight] if index9 == 1
matrix dynamics = dynamics, r(mean)
matrix colnames dynamics = Initiation Cessation 
matrix rownames dynamics = "by2013Young"
esttab  matrix(dynamics)  using "$desc/number_smokers.txt", append 


********************************************************************************
*********************** FIGURE 2 ***********************************************
********************************************************************************

******* All adults
use "$data/pns2013_cross.dta", clear
set scheme sj
drop if age > 65
keep if capital == 1 
cumul starting_age, gen(cum)
sort cum
replace cum = cum*100
label variable starting_age "Smoking Initiation Age"
line cum starting_age, ylab(, grid) ytitle("Density (%)", margin(medsmall)) xlab(5(10)65) ylab(0(25)100) /// 
graphregion(color("white")) xline(29, lcolor(gray) lpattern(-)) xtitle("Smoking Initiation Age", margin(medsmall))
graph export "$results/fig2a.png", replace

sum cum if starting_age == 15 
matrix A = r(min)
sum cum if starting_age == 18
matrix A = A, r(min)
sum cum if starting_age == 29
matrix A = A, r(max)
matrix rownames A = density
matrix colnames A = "Less than 15" "Less than 18" "By 29"
matrix ALL = A
esttab  matrix(ALL, fmt(2)) using "$desc/number_smokers.txt", append


******* Young adults
use "$data/pns2013_panel.dta", clear
set scheme sj
keep if capital == 1 
keep if age >=15 & age <30
keep if year == 2013
cumul starting_age, gen(cum)
sort cum
replace cum = cum*100
label variable starting_age "Initiation age for regular smokers"
line cum starting_age, ylab(, grid) ytitle("Density (%)",margin(medsmall)) xlab(5(3)30) ylab(0(25)100) /// 
graphregion(color("white")) xline(18, lcolor(gray) lpattern(-)) xtitle("Smoking Initiation Age", margin(medsmall))
graph export "$results/fig2b.png", replace
sum cum if starting_age == 15 
matrix A = r(min)
sum cum if starting_age == 18
matrix A = A, r(min)
sum cum if starting_age == 29
matrix A = A, r(max)
matrix rownames A = density
matrix colnames A = "Less than 15" "Less than 18" "By 29"
matrix YOUTHS = A
esttab  matrix(YOUTHS, fmt(2))  using "$desc/number_smokers.txt", append




*** Regular smoking prevalence in Brazilian Capital: Young Adults with and without weights
use "$data/pns2013_panel.dta", clear
keep if age >= 15 
keep if year >= 2005
replace smoke = smoke*100

keep if age >= 15 & age <= 29
preserve
collapse (mean) smoke [weight=weight], by (year)
save "$desc/smoke_prev.dta", replace
restore 

gen smoke_nw = smoke
collapse (mean) smoke_nw, by (year)
merge 1:1 year using "$desc/smoke_prev.dta"
drop _merge

gen temp = smoke if year == 2005
egen smoking2005 = max(temp)
drop temp
gen smoking_diff = smoke - smoking2005
gen temp = smoke_nw if year == 2005
egen smoking2005_nw = max(temp)
drop temp
gen smoking_diff_nw = smoke_nw - smoking2005_nw
sum smoking_diff smoking_diff_nw if year == 2013

sum smoke if year == 2005 
matrix A = r(mean)
sum smoke if year == 2013 
matrix A = A, r(mean)
sum smoking_diff if year == 2013
matrix A = A, r(mean)
matrix colnames A = 2005 2013 Difference
matrix rownames A = "prevalence"

sum smoke_nw if year == 2005 
matrix B = r(mean)
sum smoke_nw if year == 2013 
matrix B = B, r(mean)
sum smoking_diff_nw if year == 2013
matrix B = B, r(mean)
matrix colnames B = 2005 2013 Difference
matrix rownames B = "no weight"

matrix A = A\B
matrix PREVALENCE = A
esttab  matrix(PREVALENCE, fmt(2))  using "$desc/sample_restrictions", append

clear all
erase "$desc/smoke_prev.dta"

