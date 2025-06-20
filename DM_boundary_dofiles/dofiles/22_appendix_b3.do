*******************************************************************************
************** APPENDIX TAB. B3: ESTIMATES BY COHORT **************************
*******************************************************************************
set seed 982638 // based on a 50 Euro bill in the wallet in July 28, 2022


use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 
drop t2008 
sort id year
drop event_time

gen time_treated = cond(t2009 == 1, 2009, .) 
replace time_treated = 2010 if t2010 == 1
replace time_treated = 2011 if t2011 == 1
gen event_time = (year - time_treated)
drop if event_time < -4  & event_time != . 

sort id year
by id: gen trend = _n if event_time== .
replace trend = event_time + 5 if event_time != .

gen partrend2009 = trend*t2009
gen partrend2010 = trend*t2010
gen partrend2011 = trend*t2011

gen t_4_2009 = t2009*d2005
gen t_3_2009 = t2009*d2006
gen t_2_2009 = t2009*d2007
gen t_1_2009 = t2009*d2008

gen t1_2009 = t2009*d2010
gen t2_2009 = t2009*d2011
gen t3_2009 = t2009*d2012
gen t4_2009 = t2009*d2013

gen t_4_2010 = t2010*d2006
gen t_3_2010 = t2010*d2007
gen t_2_2010 = t2010*d2008
gen t_1_2010 = t2010*d2009

gen t1_2010 = t2010*d2011
gen t2_2010 = t2010*d2012
gen t3_2010 = t2010*d2013

gen t_4_2011 = t2011*d2007
gen t_3_2011 = t2011*d2008
gen t_2_2011 = t2011*d2009
gen t_1_2011 = t2011*d2010

gen t1_2011 = t2011*d2012
gen t2_2011 = t2011*d2013

xtreg smoke t_4_2009 t_3_2009 t_2_2009 t_1_2009 t1_2009 t2_2009 t3_2009 t4_2009 /// 
t_4_2010 t_3_2010 t_2_2010 t_1_2010 t1_2010 t2_2010 t3_2010 ///
t_4_2011 t_3_2011 t_2_2011 t_1_2011 t1_2011 t2_2011  i.year [aw = weight], fe vce(cluster uf)
 
sca nobs_trend = e(N)
matrix betas = e(b)

matrix betas2009 = betas[1, 1..8],.
matrix betas2010 = betas[1, 9..15], .,.
matrix betas2011 = betas[1, 16..21],., ., .

mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'

matrix vars2009 = A[1, 1..8],.
matrix vars2010 = A[1, 9..15], .,.
matrix vars2011 = A[1, 16..21],., .,.

boottest {t_4_2009} {t_3_2009} {t_2_2009} {t_1_2009} {t1_2009} {t2_2009} {t3_2009} {t4_2009} /// 
{t_4_2010} {t_3_2010} {t_2_2010} {t_1_2010} {t1_2010} {t2_2010} {t3_2010} ///
{t_4_2011} {t_3_2011} {t_2_2011} {t_1_2011} {t1_2011} {t2_2011}, noci cluster(uf) seed(982638)
matrix pvalue2009 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8), .
matrix pvalue2010 =  r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), . , .
matrix pvalue2011 = r(p_16), r(p_17), r(p_18), r(p_19), r(p_20), r(p_21),  ., . , .

 **Wald/F test 
test t_4_2009 t_3_2009 t_2_2009 t_1_2009
scalar f2009 = r(F)
scalar f2009p = r(p)

test t_4_2010 t_3_2010 t_2_2010 t_1_2010
scalar f2010 = r(F)
scalar f2010p = r(p)

test t_4_2011 t_3_2011 t_2_2011 t_1_2011
scalar f2011 = r(F)
scalar f2011p = r(p)


**** Cohort specific linear trends
xtreg smoke  t_3_2009 t_2_2009 t_1_2009 t1_2009 t2_2009 t3_2009 t4_2009 partrend2009 /// 
 t_3_2010 t_2_2010 t_1_2010 t1_2010 t2_2010 t3_2010 partrend2010 ///
 t_3_2011 t_2_2011 t_1_2011 t1_2011 t2_2011  partrend2011 /// 
 i.year [aw = weight], fe vce(cluster uf)
 
sca nobs_trend = e(N)
matrix betas = e(b)

matrix betas2009_trend = ., betas[1, 1..8]
matrix betas2010_trend = ., betas[1, 9..14],.,betas[1, 15]
matrix betas2011_trend = ., betas[1, 16..20], ., ., betas[1, 21]

mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'

matrix vars2009_trend = .,A[1, 1..8]
matrix vars2010_trend = .,A[1, 9..14],., A[1, 15]
matrix vars2011_trend = .,A[1, 16..20], ., ., A[1, 21]


boottest  {t_3_2009} {t_2_2009} {t_1_2009} {t1_2009} {t2_2009} {t3_2009} {t4_2009} {partrend2009}  /// 
 {t_3_2010} {t_2_2010} {t_1_2010} {t1_2010} {t2_2010} {t3_2010} {partrend2010}  ///
 {t_3_2011} {t_2_2011} {t_1_2011} {t1_2011} {t2_2011} {partrend2011}, noci cluster(uf) seed(982638)
matrix pvalue2009_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue2010_trend = ., r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), .,r(p_15)
matrix pvalue2011_trend = .,r(p_16), r(p_17), r(p_18), r(p_19), r(p_20), ., . , r(p_21)


 **Wald/F test 
test  t_3_2009 t_2_2009 t_1_2009
scalar f2009_trend = r(F)
scalar f2009p_trend = r(p)

test  t_3_2010 t_2_2010 t_1_2010
scalar f2010_trend = r(F)
scalar f2010p_trend = r(p)

test  t_3_2011 t_2_2011 t_1_2011
scalar f2011_trend = r(F)
scalar f2011p_trend = r(p)
 

replace t2009 = 2 if t2010 ==1
replace t2009 = 3 if t2011 ==1
  
bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)

sum prevalence if t2009 == 1 & year ==2009
scalar mean2009 = r(mean)
sum prevalence if t2009 == 2 & year ==2009
scalar mean2010 = r(mean)
sum prevalence if t2009 == 3 & year ==2009
scalar mean2011 = r(mean)


**************** 2 units moved to 2010 cohort *********************************
use "$data/pns2013_panel.dta", clear
xtset id year
drop if year < 2005
drop if age >29 | age<15
drop if t2008 == 1 
drop t2008  t2011 t2010 event_time
sort id year 

gen t2010 = (uf == 12 | uf == 50 | uf == 22)
gen t2011 = (uf == 51) 
replace t2009 = 0 if t2010 == 1 | t2011 == 1

gen time_treated = cond(t2009 == 1, 2009, .) 
replace time_treated = 2010 if t2010 ==1 
replace time_treated = 2011 if t2011 ==1 
gen event_time = (year - time_treated)
drop if event_time < -4  & event_time != . 

sort id year
by id: gen trend = _n if event_time== .
replace trend = event_time + 5 if event_time != .

gen partrend2009 = trend*t2009
gen partrend2010 = trend*t2010
gen partrend2011 = trend*t2011

gen t_4_2009 = t2009*d2005
gen t_3_2009 = t2009*d2006
gen t_2_2009 = t2009*d2007
gen t_1_2009 = t2009*d2008

gen t1_2009 = t2009*d2010
gen t2_2009 = t2009*d2011
gen t3_2009 = t2009*d2012
gen t4_2009 = t2009*d2013

gen t_4_2010 = t2010*d2006
gen t_3_2010 = t2010*d2007
gen t_2_2010 = t2010*d2008
gen t_1_2010 = t2010*d2009

gen t1_2010 = t2010*d2011
gen t2_2010 = t2010*d2012
gen t3_2010 = t2010*d2013

gen t_4_2011 = t2011*d2007
gen t_3_2011 = t2011*d2008
gen t_2_2011 = t2011*d2009
gen t_1_2011 = t2011*d2010

gen t1_2011 = t2011*d2012
gen t2_2011 = t2011*d2013


**** Cohort specific linear trends
xtreg smoke  t_3_2009 t_2_2009 t_1_2009 t1_2009 t2_2009 t3_2009 t4_2009 partrend2009 /// 
 t_3_2010 t_2_2010 t_1_2010 t1_2010 t2_2010 t3_2010 partrend2010 ///
 t_3_2011 t_2_2011 t_1_2011 t1_2011 t2_2011  partrend2011 /// 
 i.year [aw = weight], fe vce(cluster uf)
sca nobs_trend2 = e(N)
matrix betas = e(b)

matrix betas2009_trend2 = ., betas[1, 1..8]
matrix betas2010_trend2 = ., betas[1, 9..14],.,betas[1, 15]
matrix betas2011_trend2 = ., betas[1, 16..20], ., ., betas[1, 21]

mata st_matrix("A",sqrt(st_matrix("e(V)")))
mata st_matrix("A",diagonal(st_matrix("A")))
matrix A = A'

matrix vars2009_trend2 = .,A[1, 1..8]
matrix vars2010_trend2 = .,A[1, 9..14],., A[1, 15]
matrix vars2011_trend2 = .,A[1, 16..20], ., ., A[1, 21]


boottest  {t_3_2009} {t_2_2009} {t_1_2009} {t1_2009} {t2_2009} {t3_2009} {t4_2009} {partrend2009}  /// 
 {t_3_2010} {t_2_2010} {t_1_2010} {t1_2010} {t2_2010} {t3_2010} {partrend2010}  ///
 {t_3_2011} {t_2_2011} {t_1_2011} {t1_2011} {t2_2011} {partrend2011}, noci cluster(uf) seed(982638)
matrix pvalue2009_trend2 = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), r(p_8)
matrix pvalue2010_trend2 = ., r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), .,r(p_15)
matrix pvalue2011_trend2 = .,r(p_16), r(p_17), r(p_18), r(p_19), r(p_20), ., . , r(p_21)

 **Wald/F test 
test  t_3_2009 t_2_2009 t_1_2009
scalar f2009_trend2 = r(F)
scalar f2009p_trend2 = r(p)

test  t_3_2010 t_2_2010 t_1_2010
scalar f2010_trend2 = r(F)
scalar f2010p_trend2 = r(p)

test  t_3_2011 t_2_2011 t_1_2011
scalar f2011_trend2 = r(F)
scalar f2011p_trend2 = r(p)
 
replace t2009 = 2 if t2010 ==1
replace t2009 = 3 if t2011 ==1
  
bysort year t2009: egen tot_weight_prev = total(weight)
gen smoke_prev = smoke*(weight/tot_weight_prev)
bysort year t2009: egen prevalence = sum(smoke_prev)

sum prevalence if t2009 == 1 & year ==2009
scalar mean20092 = r(mean)
sum prevalence if t2009 == 2 & year ==2009
scalar mean20102 = r(mean)
sum prevalence if t2009 == 3 & year ==2009
scalar mean20112 = r(mean)



 foreach j in f2009 f2009_trend f2009_trend2 f2010 f2010_trend f2010_trend2 f2011 f2011_trend f2011_trend2  ///
f2009p f2009p_trend f2009p_trend2  f2010p f2010p_trend f2010p_trend2 f2011p f2011p_trend f2011p_trend2 ///
 mean2009 mean2010 mean2011 mean20092 mean20102 mean20112 {
	estadd scalar `j'
	}
 
 foreach x in  betas2009 betas2009_trend betas2009_trend2  betas2010 betas2010_trend betas2010_trend2 ///
 betas2011 betas2011_trend betas2011_trend2 ///
 vars2009 vars2009_trend vars2009_trend2 vars2010 vars2010_trend vars2010_trend2  vars2011 vars2011_trend vars2011_trend2 /// 
 pvalue2009 pvalue2009_trend pvalue2009_trend2  pvalue2010 pvalue2010_trend pvalue2010_trend2 ///
 pvalue2011 pvalue2011_trend pvalue2011_trend2   {
	matrix colnames `x' = t_4 t_3 t_2 t_1 t1 t2 t3 t4 Trends
	estadd matrix `x'
}

 
 
 esttab using "$appendix/tab_b3.tex", /// 
cells("betas2009(fmt(%12.3f))  betas2010(fmt(%12.3f))  betas2011(fmt(%12.3f)) betas2009_trend(fmt(%12.3f)) betas2010_trend(fmt(%12.3f)) betas2011_trend(fmt(%12.3f)) betas2009_trend2(fmt(%12.3f)) betas2010_trend2(fmt(%12.3f)) betas2011_trend2(fmt(%12.3f))"  /// 
"vars2009(fmt(%12.3f) par) vars2010(fmt(%12.3f) par) vars2011(fmt(%12.3f) par) vars2009_trend(fmt(%12.3f) par) vars2010_trend(fmt(%12.3f) par) vars2011_trend(fmt(%12.3f) par) vars2009_trend2(fmt(%12.3f) par) vars2010_trend2(fmt(%12.3f) par) vars2011_trend2(fmt(%12.3f) par)  " /// 
"pvalue2009(fmt(%12.3f) par([ ])) pvalue2010(fmt(%12.3f) par([ ])) pvalue2011(fmt(%12.3f) par([ ])) pvalue2009_trend(fmt(%12.3f) par([ ])) pvalue2010_trend(fmt(%12.3f) par([ ])) pvalue2011_trend(fmt(%12.3f) par([ ])) pvalue2009_trend2(fmt(%12.3f) par([ ])) pvalue2010_trend2(fmt(%12.3f) par([ ])) pvalue2011_trend2(fmt(%12.3f) par([ ]))  ")  ///
stats( f2009 f2010 f2011 f2009_trend f2010_trend f2011_trend f2009_trend2 f2010_trend2 f2011_trend2  f2009p f2010p f2011p f2009p_trend f2010p_trend f2011p_trend /// 
f2009p_trend2 f2010p_trend2 f2011p_trend2 mean2009 mean2010 mean2011 mean2009 mean2010 mean2011 mean20092 mean20102 mean20112, /// 
 layout("@ @ @ @ @ @ @ @ @" "@ @ @ @ @ @ @ @ @" "@ @ @ @ @ @ @ @ @" ) label("F-stat" "p-value" "Average") fmt(%9.3fc)) /// 
 rename(t_4 "$\hat{\beta}_{-4}$" t_3 "$\hat{\beta}_{-3}$" t_2 "$\hat{\beta}_{-2}$" t_1 "$\hat{\beta}_{-1}$" ///
  t1 "$\hat{\beta}_1$" t2 "$\hat{\beta}_2$" t3 "$\hat{\beta}_3$" t4 "$\hat{\beta}_4$" t5 "$\hat{\beta}_5$") /// 
  collabels("(2009)" "(2010)" "(2011)" "(2009)" "(2010)" "(2011)" "(2009)" "(2010)" "(2011)"  ) ///
  mgroups(none) mlabels(none) noobs nogaps noeqlines compress nolines replace substitute(\_ _) eqlabels(none) title(none) nonumbers   
  

clear all