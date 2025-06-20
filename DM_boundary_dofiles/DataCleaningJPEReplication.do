**********************************************************************************************************************************
**** Replication Files for Anderson and McKenzie 																				**
**** "Improving business practices and the boundary of the entrepreneur: A randomized experiment comparing training,            **
***** consulting, insourcing and outsourcing "																					**
**********************************************************************************************************************************

**********************************************************************************************************************************
*** DATA CLEANING AND VARIABLE CONSTRUCTION: This file takes the raw data and constructs the outcome variables used for analysis *
*** It takes data sets in the Raw Data subfolder, and saves the constructed sets in the ConstructedData subfolder                *
**********************************************************************************************************************************

*** Set directory
cd "C:/Users/wb200090/OneDrive - WBG/otherresearch/Nigeria/JohanneMaterials/JPERevision/ReplicationData/"

*** Set Stata version
version 16.0

************************************************
*   0. Set Globals for Directories                 *
************************************************
	global rawdata "RawData"
	global constructdata "ConstructedData"

	
*************************************************************************
**** Figure 1. Construct Variables used in Descriptive Figure 1 *********
*************************************************************************
use "$rawdata/FullApplicationSample.dta", clear

* Examine distribution of number of employees
sum total_emp, de

* Winsorize employment at 30 (~95th percentile) for graph
gen employ2=total_emp
replace employ2=30 if employ2>30 & employ2~=.
label var employ2 "Total Employment"

*** Who does record-keeping?
gen ownrecords=cond(bp_hr_recordkeeping==2,1,0) if bp_hr_recordkeeping>=2 & bp_hr_recordkeeping<=4
label var ownrecords "Owner does the record-keeping"
gen insourcerecords=cond(bp_hr_recordkeeping==3,1,0) if bp_hr_recordkeeping>=2 & bp_hr_recordkeeping<=4
label var insourcerecords "Insources record-keeping"
gen outsourcerecords=cond(bp_hr_recordkeeping==4,1,0) if bp_hr_recordkeeping>=2 & bp_hr_recordkeeping<=4
label var outsourcerecords "Outsources record-keeping"

* Who does marketing?
gen ownmarketing=cond(bp_hr_marketing==2,1,0) if bp_hr_marketing>=2 & bp_hr_marketing<=4
label var ownmarketing "Owner does the marketing"
gen insourcemarket=cond(bp_hr_marketing==3,1,0) if bp_hr_marketing>=2 & bp_hr_marketing<=4
label var insourcemarket "Insources marketing"
gen outsourcemarket=cond(bp_hr_marketing==4,1,0) if bp_hr_marketing>=2 & bp_hr_marketing<=4
label var outsourcemarket "Outsources marketing"

save "$constructdata/Figure1data.dta", replace

**************************************************************************
*** Figure 2: Reshape usage data for Take-up Figure 2 ********************
**************************************************************************

use "$rawdata/TakeupUsage.dta", replace
collapse (mean) month_1 month_2 month_3 month_4 month_5 month_6 month_7 month_8 month_9, by(insourcing)
reshape long month_, i(insourcing) j(time)
rename month_ takeuprate
label var takeuprate "Take-up rate"
label var time "Month in program"
gen takeup_I=takeuprate if insourcing==1
gen takeup_O=takeuprate if insourcing==0
label var takeup_I "Insourcing"
label var takeup_O "Outsourcing"
save "$constructdata/Figure2data.dta", replace

sort time
twoway line takeup_I takeup_O time, ytitle("Take-up rate") xtitle("Program Month") yscale(range(0 1)) ylabel(0(0.2)1) xlabel(0(1)9) graphregion(color(white)) 
graph export "output\Figure2.png", replace
graph save "output\Figure2.gph", replace

**************************************************************************
**** Table 2: Human Capital Comparisons across treatments ****************
**************************************************************************
use "$rawdata/IOMonitoringData.dta", clear
gen outsourcing=ftreat==1
gen insourcing=ftreat==0
** How often does the worker work?
tab owner_insource_days if firstvisit==1
tab owner_outsource_days if firstvisit==1
gen temp=subinstr(owner_insource_days," ","",.)
gen numdays=strlen(temp)
drop temp
gen temp=subinstr(owner_outsource_days," ","",.)
gen numdays1=strlen(temp)
drop temp
replace numdays=numdays1 if outsourcing==1
label var numdays "Number of days per week in firm"
*********** hours per week worked
gen hours=owner_insource_hours
* some answered hours based on month, not week
replace hours=hours/4 if hours>=160 & hours<=170
replace hours=. if hours==0
sum hours if firstvisit==1 & insourcing==1, de
* winsorize hours at top 5% to get rid of outlier/data error
replace hours=r(p95) if hours>r(p95) & hours~=. & insourcing==1
* number of hours per week
gen hoursoutsource=owner_outsource_hours  
replace hoursoutsource=hoursoutsource/4 if hoursoutsource>=160 & hoursoutsource<=170
replace hoursoutsource=. if hoursoutsource==0
sum hoursoutsource if outsourcing==1 & firstvisit==1, de
replace hoursoutsource=r(p95) if hoursoutsource>r(p95) & hoursoutsource~=. & outsourcing==1
replace hours=hoursoutsource if outsourcing==1
label var hours "Weekly hours worked in firm"
******** Monthly pay
*** monthly pay made by firm
gen monthlypay=owner_insource_monthlypmt
replace monthlypay=. if monthlypay==0
sum monthlypay if firstvisit==1 & insourcing==1, de
* pay to outsourced worker from firm (note this is not their full salary, since also work for other firms)
gen payoutsource=owner_outsource_monthlypmt
replace payoutsource=. if owner_outsource_monthlypmt==0
sum payoutsource if firstvisit==1 & outsourcing==1, de
gen workerpay=worker_insource_monthlypmt if insourcing==1 
replace workerpay=worker_outsource_salary if outsourcing==1
label var workerpay "Worker Pay"
replace workerpay=40000 if workerpay==40
replace workerpay=. if workerpay==0
label var workerpay "Amount worker earns per month"
* winsorize at 95th percentiles
sum workerpay if firstvisit==1 & insourcing==1, de
replace workerpay=r(p95) if workerpay>r(p95) & workerpay~=. & firstvisit==1 & insourcing==1
sum workerpay if firstvisit==1 & outsourcing==1, de
replace workerpay=r(p95) if workerpay>r(p95) & workerpay~=. & firstvisit==1 & outsourcing==1
bysort ftreat: sum workerpay if firstvisit==1, de
***** Characteristics of Workers *****
gen workermale=worker_gender_observe 
tab workermale if firstvisit==1
label var workermale "Worker is male"
gen workerage= worker_age 
label var workerage "Worker's age"
replace workerage=. if workerage==0
sum workermale workerage if insourcing==1 & firstvisit==1, de
sum workermale workerage if outsourcing==1 & firstvisit==1, de
** Education
gen workereduc=worker_education1 
replace workereduc=. if workereduc==999
gen postgradeduc=workereduc>=9 & workereduc<=13
replace postgradeduc=. if workereduc==.
sum postgradeduc if insourcing==1 & firstvisit==1
sum postgradeduc if outsourcing==1 & firstvisit==1
*** Look at work experience etc.
gen workedbefore=worker_career_salaried 
replace workedbefore=0 if workedbefore==999
sum workedbefore if firstvisit==1 & insourcing==1
sum workedbefore if firstvisit==1 & outsourcing==1
* Years experience
gen yearsexperience=0 if workedbefore==0
replace yearsexperience=worker_career_years if worker_career_years<100
sum yearsexperience if firstvisit==1 & insourcing==1, de
sum yearsexperience if firstvisit==1 & outsourcing==1, de
*** worker certification
gen workercert=worker_certification 
replace workercert=. if workercert==999
sum workercert if firstvisit==1 & insourcing==1
sum workercert if firstvisit==1 & outsourcing==1
*** worker association 
gen workerassoc=worker_association
replace workerassoc=0 if workerassoc==999
sum workerassoc if firstvisit==1 & insourcing==1
sum workerassoc if firstvisit==1 & outsourcing==1
keep workermale workerage yearsexperience postgradeduc workercert workerassoc numdays hours workerpay firstvisit insourcing outsourcing 
save "$constructdata/IOHumanCapital.dta", replace

* Trainer's Human Capital
use "$rawdata/TrainerHumanCapital.dta", clear
gen workermale=male
gen workerage=trainerage
gen yearsexperience=trainerworkexp
gen postgradeduc=cond(educationlevel>=9 & educationlevel<=13,1,0)
gen workercert=certified
gen workerassoc=profassoc
gen workerpay=1080750
keep training-workerpay
save "$constructdata/TrainersHumanCapital.dta", replace

* Consultant's Human Capital
use "$rawdata/ConsultantHumanCapital.dta", clear
gen workermale=maleworker
gen workerage=consultantage
destring workerage, force replace
gen yearsexperience=yearsexperienced
destring yearsexperience, force replace
gen postgradeduc=cond(educationlevel>=9 & educationlevel<=13,1,0)
gen workercert=certified
replace profassoc="1" if profassoc~="" & profassoc~="0"
gen workerassoc=profassoc
destring workerassoc, force replace
gen workerpay=consultantsalary
destring workerpay, force replace
sum workerpay, de
replace workerpay=r(p95) if workerpay>r(p95) & workerpay~=.
keep consulting-workerpay
save "$constructdata/ConsultantsHumanCapital.dta", replace

	
******************************************************************	
**** 1. Construct Outcome Variables from First Follow-up Round  **
******************************************************************
use	"$rawdata/PublicUseRound1.dta", clear

*** Get Survey dates for describing when survey took place *****
gen monthsurvey=substr(date,6,2)
destring monthsurvey, force replace
label var monthsurvey "Month survey took place in 2018"

************** Variables Needed for attrition table *********************
* Row 1: Attrited from Survey
*** Survey attrition defined as not being interviewed
gen attrited=avail~=1 & mode~=2

************* Group A: Impact on Firm Performance Outcomes **************
* A1: Survival
gen survival=cond(A1==1|Q3==1,1,0) if A1~=.|Q3~=.
replace survival=cond(operate==1,1,0) if operate~=. & survival==.
label var survival "Firm operating at time of follow-up survey"
* A2 and A3: Employment
replace emp_num=. if emp_num==998
* total number observed working in firm by enumerator
gen emp_1=F1
label var emp_1 "employees observed working in firm"
gen emp_2=F4_1
label var emp_2 "number of wage/salaried employees"
gen emp_3=F4_2 
label var emp_3 "number of casual/daily workers"
gen emp_4=F4_3
label var emp_4 "number of partners"
gen emp_5=F4_4
* note: typo in pre-analysis plan, wrong questionnaire number recorded here
* F4_3 was recorded instead of F4_4
label var emp_5 "Number of apprentices/interns"
gen emp_6=F4_5
label var emp_6 "Number of unpaid workers"
gen emp_7=F4_6
replace emp_7=emp_num if F4_6==.
label var emp_7 "Total number of workers"
gen emp_8=E13
replace emp_8=0 if E12==2
label var emp_8 "Spouse's hours of work per week"
*** Replace employment as zero for firms that are closed, and then winsorize
foreach var of varlist emp_1-emp_8 {
replace `var'=0 if survival==0
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
gen emp_9=cond(emp_7>=10,1,0) if emp_7~=.
label var emp_9 "Firm has 10+ workers"
gen emp_10=F7a
replace emp_10=. if emp_10==999
replace emp_10=0 if survival==0
sum emp_10, de
replace emp_10=r(p99) if emp_10>r(p99) & emp_10~=.
label var emp_10 "Number of paid new workers hired in last 6 months"
* Standardized z-score average of 1-8
foreach var of varlist emp_1 emp_2 emp_3 emp_4 emp_5 emp_6 emp_7 emp_8 { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen emp_11 = rowmean(z1_emp_1 z1_emp_2 z1_emp_3 z1_emp_4 z1_emp_5 z1_emp_6 z1_emp_7 z1_emp_8) 
label var emp_11 "Employment Index"
* A4: Employee Wages
gen wage_1=F8
label var wage_1 "Total wage bill"
* rescale total wage bill into 1000s of Naira for display
replace wage_1=wage_1/1000
replace b_wage_1=b_wage_1/1000
gen wage_2=F8/F4_6
replace wage_2=F8/emp_num if F4_6==.
label var wage_2 "Wage per worker"
egen wage_3=rowmean(E11e_1 E11e_2 E11e_3 E11e_4 E11e_5)
label var wage_3 "Average wage of highest paid workers"
* Replace as zero for closed firms, and winsorize
foreach var of varlist wage_1 wage_2 wage_3 {
replace `var'=0 if survival==0
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
* Standardized z-score 
foreach var of varlist wage_1 wage_2 wage_3 { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen wage_4 = rowmean(z1_wage_1 z1_wage_2 z1_wage_3) 
label var wage_4 "Wage Index"

* A5 and A6: Sales and Profits

* Set missing values to missing
foreach var of varlist G16 G17 G23 G24 {
replace `var'=. if `var'==999|`var'==998
}

* sales in last month
gen sales=G16
replace sales=125000 if sales==. & G16_1==1
replace sales=375000 if sales==. & G16_1==2
replace sales=625000 if sales==. & G16_1==3
replace sales=875000 if sales==. & G16_1==4
replace sales=1125000 if sales==. & G16_1==5
replace sales=1375000 if sales==. & G16_1==6
replace sales=1750000 if sales==. & G16_1==7
replace sales=2500000 if sales==. & G16_1==8
replace sales=3500000 if sales==. & G16_1==9
replace sales=4500000 if sales==. & G16_1==10
replace sales=6000000 if sales==. & G16_1==11
replace sales=8750000 if sales==. & G16_1==12
sum sales if G16_1==13, de
replace sales=r(p50) if sales==. & G16_1==13
* sales in last year
gen salesyr=G17
replace salesyr=125000 if salesyr==. & G17_1==1
replace salesyr=375000 if salesyr==. & G17_1==2
replace salesyr=625000 if salesyr==. & G17_1==3
replace salesyr=875000 if salesyr==. & G17_1==4
replace salesyr=1125000 if salesyr==. & G17_1==5
replace salesyr=1375000 if salesyr==. & G17_1==6
replace salesyr=1750000 if salesyr==. & G17_1==7
replace salesyr=2500000 if salesyr==. & G17_1==8
replace salesyr=3500000 if salesyr==. & G17_1==9
replace salesyr=4500000 if salesyr==. & G17_1==10
replace salesyr=6000000 if salesyr==. & G17_1==11
replace salesyr=8750000 if salesyr==. & G17_1==12
sum salesyr if G17_1==13, de
replace salesyr=r(p50) if salesyr==. & G17_1==13
* total profits in past month
gen profits=G23
replace profits=125000 if profits==. & G23_1==1
replace profits=375000 if profits==. & G23_1==2
replace profits=625000 if profits==. & G23_1==3
replace profits=875000 if profits==. & G23_1==4
replace profits=1125000 if profits==. & G23_1==5
replace profits=1375000 if profits==. & G23_1==6
replace profits=1750000 if profits==. & G23_1==7
replace profits=2500000 if profits==. & G23_1==8
replace profits=3500000 if profits==. & G23_1==9
replace profits=4500000 if profits==. & G23_1==10
replace profits=6000000 if profits==. & G23_1==11
replace profits=8750000 if profits==. & G23_1==12
sum profits if G23_1==13, de
replace profits=r(p50) if profits==. & G23_1==13
* profits in last year
gen profitsyr=G24
replace profitsyr=125000 if profitsyr==. & G24_1==1
replace profitsyr=375000 if profitsyr==. & G24_1==2
replace profitsyr=625000 if profitsyr==. & G24_1==3
replace profitsyr=875000 if profitsyr==. & G24_1==4
replace profitsyr=1125000 if profitsyr==. & G24_1==5
replace profitsyr=1375000 if profitsyr==. & G24_1==6
replace profitsyr=1750000 if profitsyr==. & G24_1==7
replace profitsyr=2500000 if profitsyr==. & G24_1==8
replace profitsyr=3500000 if profitsyr==. & G24_1==9
replace profitsyr=4500000 if profitsyr==. & G24_1==10
replace profitsyr=6000000 if profitsyr==. & G24_1==11
replace profitsyr=8750000 if profitsyr==. & G24_1==12
sum profitsyr if G24_1==13, de
replace profitsyr=r(p50) if profitsyr==. & G24_1==13

* replace missing values, set to zero if closed and missing, and winsorize
foreach var of varlist sales salesyr profits profitsyr {
replace `var'=0 if survival==0 & `var'==.
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
* correct errors based on word and range checks
list entrep_id sales G16* if sales>0 & sales<5000 
replace sales=35000 if sales==3500
list entrep_id salesyr G17* if salesyr>0 & salesyr<5000 
list entrep_id profits G23* if profits>0 & profits<5000 
list entrep_id profitsyr G23* if profitsyr>0 & profitsyr<5000 

* Inverse Hyperbolic sine of each
foreach var of varlist sales salesyr profits profitsyr {
gen inv`var'=ln(`var'+(((`var'^2)+1)^(1/2)))
}
foreach var of varlist invsales invsalesyr invprofits invprofitsyr { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen salesprofindex = rowmean(z1_invsales z1_invsalesyr z1_invprofits z1_invprofitsyr) 
label var salesprofindex "Sales and Profits Index"
* no baseline profit data, so baseline index also missing
gen b_salesprofindex=0
gen b_salesprofindex_miss=1

* Pre-specified robustness check on levels - scale in 1000s
replace profits=profits/1000
replace sales=sales/1000
replace b_sales=b_sales/1000

*** Item non-response on profits and sales (includes not answering survey)
gen itemnr_profitsales=cond(salesprofindex==.,1,0)
label var itemnr_profitsales "Item non-response Profits/Sales"

* A7: Reporting Errors Made
gen error1=cond(G23>G16 & G23~=. & G16~=.,1,0)
gen error2=cond(G24>G17 & G24~=. & G17~=.,1,0)
gen error3=cond(G16>G17 & G16~=. & G17~=.,1,0)
gen error4=cond(G23>G24 & G23~=. & G24~=.,1,0)
gen error5=cond(F8>G16 & F8~=. & G16~=.,1,0)
gen totalerrors=error1+error2+error3+error4+error5
replace totalerrors=. if attrited==1
label var totalerrors "Reporting Errors Made"
gen b_totalerrors=0
gen b_totalerrors_miss=1

****** Group B: impact on business practices ************
* B1 and B2: business practices
* Finance and Accounting practices
gen finance1=cond(D1A==1|D1A==2,1,0) if D1A~=.
gen finance2=cond(D2A==1|D2A==2,1,0) if D2A~=.
gen finance3=cond(D3A==1|D3A==2,1,0) if D3A~=.
gen finance4=cond(D4A==1|D4A==2,1,0) if D4A~=.
gen finance5=cond(D5A==1,1,0) if D5A~=.
gen finance6=cond(D6A==1,1,0) if D6A~=.
gen finance7=cond(D7A==1,1,0) if D7A~=.
gen finance8=cond(D8A==1|D8A==2,1,0) if D8A~=.
gen finance9=cond(D9A==1,1,0) if D9A~=.
gen finance10=cond(D10A==1,1,0) if D10A~=.
sum finance1-finance10
egen financeindex=rowmean(finance1-finance10)
label var financeindex "Finance Practices Index"

* Marketing and Sales practices
gen mktg1=cond(D11A==1,1,0) if D11A~=.
gen mktg2=cond(D12A==1,1,0) if D12A~=.
gen mktg3=cond(D13A==1,1,0) if D13A~=.
gen mktg4=cond(D14A==1|D14A==2,1,0) if D14A~=.
gen mktg5=cond(D15A==1,1,0) if D15A~=.
gen mktg6=cond(D16A==1,1,0) if D16A~=.
gen mktg7=cond(D17A==1|D17A==2,1,0) if D17A~=.
gen mktg8=cond(D18A==1|D18A==2,1,0) if D18A~=.
gen mktg9=cond(D19A==1,1,0) if D19A~=.
sum mktg1-mktg9
egen marketingindex=rowmean(mktg1-mktg9)
label var marketingindex "Marketing Practices Index"

* Digital Marketing practices
gen digmktg1=cond(D20A==1,1,0) if D20A~=.
gen digmktg2=cond(D21A==1,1,0) if D21A~=.
replace digmktg2=0 if digmktg1==0
gen digmktg3=cond(D22A==1,1,0) if D22A~=.
gen digmktg4=cond(D24A==1,1,0) if D24A~=.
gen digmktg5=cond(D24C==1,1,0) if D24C~=.
gen digmktg6=cond(D24E==1,1,0) if D24E~=.
gen digmktg7=cond(D24G==1,1,0) if D24G~=.
gen digmktg8=cond(D24I==1,1,0) if D24I~=.
gen digmktg9=cond(D24K==1,1,0) if D24K~=.
gen digmktg10=cond(D24M==1,1,0) if D24M~=.
gen digmktg11=cond(D24S==1,1,0) if D24S~=.
for num 4/11: replace digmktgX=0 if D23==0
sum digmktg1-digmktg11
egen digmarketingindex=rowmean(digmktg1-digmktg11)
label var digmarketingindex "Digital Marketing Practices Index"

* Operations and HR practices
gen ophr1=cond(D25A==1,1,0) if D25A~=.
gen ophr2=cond(D26A==1,1,0) if D26A~=.
gen ophr3=cond(D27A==1,1,0) if D27A~=.
gen ophr4=cond(D28A==1|D28A==2,1,0) if D28A~=.
gen ophr5=cond(D29A==1,1,0) if D29A~=.
gen ophr6=cond(D30A==1,1,0) if D30A~=.
gen ophr7=cond(d5f_b==1,1,0) if d5f_b~=.
gen ophr8=cond(D31A==1|D31A==2,1,0) if D31A~=.
gen ophr9=cond(D32A==1,1,0) if D32A~=.
gen ophr10=cond(D33A==1,1,0) if D33A~=.
gen ophr11=cond(d6c__1==1|d6c__2==1|d6c__3==1,1,0) if d6c__1~=.
sum ophr1-ophr11
egen opHRindex=rowmean(ophr1-ophr11)
label var opHRindex "Operations and HR practices index"

* overall BP index
egen overallBPindex=rowmean(finance1-finance10 mktg1-mktg9 digmktg1-digmktg11 ophr1-ophr11)
label var overallBPindex "Overall business practices index"

* Verified business practices
gen verifyBP1=cond(D1A==1,1,0) if D1A~=.
gen verifyBP2=cond(D2A==1,1,0) if D2A~=.
gen verifyBP3=cond(D3A==1,1,0) if D3A~=.
gen verifyBP4=cond(D4A==1,1,0) if D4A~=.
gen verifyBP5=cond(D8A==1,1,0) if D8A~=.
gen verifyBP6=cond(D14A==1,1,0) if D14A~=.
gen verifyBP7=cond(D17A==1,1,0) if D17A~=.
gen verifyBP8=cond(D18A==1,1,0) if D18A~=.
gen verifyBP9=cond(D28A==1,1,0) if D28A~=.
gen verifyBP10=cond(D31A==1,1,0) if D31A~=.
sum verifyBP1-verifyBP10
egen verifyBPindex=rowmean(verifyBP1-verifyBP10)
label var verifyBPindex "Verified BP index"

* Setting practices to zero for firms which are closed
foreach var of varlist financeindex marketingindex digmarketingindex  opHRindex overallBPindex verifyBPindex {
replace `var'=0 if survival==0
}

* Generate item non-response on business practices
gen itemnr_buspractices=overallBPindex==.
label var itemnr_buspractices "Item non-response on Business Practices" 

* Define pre-specified proxy baseline BP measures
gen b_financeindex=b_finance
gen b_marketingindex=b_marketing
gen b_digmarketingindex=b_score_10
gen b_opHRindex=b_hr
gen b_overallBPindex=b_score_10
gen b_verifyBPindex=b_score_10
foreach var of varlist b_financeindex-b_verifyBPindex {
gen `var'_miss=`var'==.
replace `var'=0 if `var'==.
}

******* Group C: Impact on Owner Time Use ***************
* C1: Owner's own time
gen ownerhours=C1a
replace ownerhours=0 if survival==0
sum ownerhours, de
replace ownerhours=r(p99) if ownerhours>r(p99) & ownerhours~=.
label var ownerhours "Owner hours worked in last week"
* hours not collected at baseline

*C2: time concentration
for num 1/13: gen tX=cond(C3A_X>5,1,0) if C3A_X~=.
sum t1-t13
egen timeconcentration=rowmean(t1-t13)
label var timeconcentration "Time concentration (higher=less)"
cap drop t1-t13
for num 1/13: gen tX=C3A_X^2
egen Ztop=rsum(t1-t13)
egen Tbottom=rsum(C3A_1-C3A_13)
gen GibbsMartin=Ztop/(Tbottom*Tbottom)
label var GibbsMartin "Gibbs Martin homogeneity-heterogeneity measure"

* item non-response on time concentration (note missing for closed businesses)
gen itemnr_timeuse=timeconcentration==.
label var itemnr_timeuse "Item non-response on time use"

* C3: Growth-focus
cap drop t1-t13
for num 1/13: gen tX=cond(C3A_X>5,1,0) if C3A_X~=.
gen growthhours=t6+t7+t8+t9+t10
label var growthhours "Growth-Focused Activities"
gen external1=C3B
gen future1=Q3C
gen growthcomposite=(external1+future1)/2
label var growthcomposite "Percent of time on external and future activities"

*C4: Delegation
egen delegation=rowmean(C11A C11B C11C C11D C11E)
label var delegation "Delegation"

*** Group D: Use of professional business services
gen usehrspecialist=cond(E1__6==1|d6e2==6,1,0) if E1__6~=.|d6e2~=.
label var usehrspecialist "Use a HR specialist"
gen useoutsideaccount=cond(E6==1 & (E8B==4|E8B==5|E8B==6),1,0) if E6~=.
label var useoutsideaccount "Uses outside accounting agency"
* look at other frequency for accounting
 tab E8B_oth
 list entrep_id E8B_oth if E8B==7
 replace useoutsideaccount=1 if entrep_id=="2016005325"|entrep_id=="2016006270"|entrep_id=="2016009269"
gen useoutsidemarketing=cond(E10==4 & (E12B>=4 & E12B<=6),1,0) if E10~=.
label var useoutsidemarketing "Use outside marketing service"
* look at other frequency for marketing
gen usebusconsulting=cond(E14==1 & E16>=8,1,0) if E14~=.
label var usebusconsulting "Use business consulting)
egen useprofessionalservices=rowmean(usehrspecialist useoutsideaccount useoutsidemarket usebusconsult)
label var useprofessionalservices "Uses professional business services"  

* pre-specified that use zero services if business is closed
foreach var of varlist usehrspecialist useoutsideaccount useoutsidemarket usebusconsult useprofessionalservices {
replace `var'=0 if survival==0
}

* generate item non-response on use of professional services
gen itemnr_marketservices=useprofessionalservices==.
label var itemnr_marketservices "Item non-response on market for services"

**** Generate indicator of survey round
gen surveyround=1
label var surveyround "Follow-up survey round"

sort entrep_id
save "$constructdata/CleanedFU1.dta", replace


*********************************************************************************************************
*** Construct Outcomes from Second Follow-up Survey *****************************************************
*********************************************************************************************************
use	"$rawdata/PublicUseRound2.dta", clear

*** Get Survey dates for describing when survey took place *****
gen monthsurvey=substr(date,6,2)
destring monthsurvey, force replace
label var monthsurvey "Month survey took place in 2019"

************** Variables Needed for attrition table ***************************************
* Row 1: Attrited from Survey
*** Survey attrition defined as not being interviewed
gen attrited=avail~=1 

******************************* Group A: Impact on Firm Performance Outcomes ********************************
* A1: Survival
gen survival=cond(A1==1|Q3==1,1,0) if A1~=.|Q3<=2
replace survival=cond(operate==1,1,0) if operate~=. & survival==.
label var survival "Firm operating at time of follow-up survey"
replace survival=1 if operate==. & (Isthisbusinessstilloperatin=="YES"|Isthisbusinessstilloperatin=="yes")
replace survival=0 if operate==. & (Isthisbusinessstilloperatin=="NO"|Isthisbusinessstilloperatin=="no"|Isthisbusinessstilloperatin=="not really")
* firm is not operating for respondent who is deceased
replace survival=0 if entrep_id=="2016017215"

* A2 and A3: Employment
replace emp_num=. if emp_num==998|emp_num==988
* total number observed working in firm by enumerator
gen emp_1=F1
label var emp_1 "employees observed working in firm"
gen emp_2=F4_1
label var emp_2 "number of wage/salaried employees"
gen emp_3=F4_2 
label var emp_3 "number of casual/daily workers"
gen emp_4=F4_3
label var emp_4 "number of partners"
gen emp_5=F4_4
* note: typo in pre-analysis plan, wrong questionnaire number recorded here
* F4_3 was recorded instead of F4_4
label var emp_5 "Number of apprentices/interns"
gen emp_6=F4_5
label var emp_6 "Number of unpaid workers"
gen emp_7=F4_6
replace emp_7=emp_num if F4_6==.
label var emp_7 "Total number of workers"
gen emp_8=E13
replace emp_8=0 if E12==2
label var emp_8 "Spouse's hours of work per week"
*** Replace employment as zero for firms that are closed, and then winsorize
foreach var of varlist emp_1-emp_8 {
replace `var'=0 if survival==0
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
gen emp_9=cond(emp_7>=10,1,0) if emp_7~=.
label var emp_9 "Firm has 10+ workers"
gen emp_10=F7a
replace emp_10=. if emp_10==999
replace emp_10=0 if survival==0
sum emp_10, de
replace emp_10=r(p99) if emp_10>r(p99) & emp_10~=.
label var emp_10 "Number of paid new workers hired in last 6 months"
* Standardized z-score average of 1-8
foreach var of varlist emp_1 emp_2 emp_3 emp_4 emp_5 emp_6 emp_7 emp_8 { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen emp_11 = rowmean(z1_emp_1 z1_emp_2 z1_emp_3 z1_emp_4 z1_emp_5 z1_emp_6 z1_emp_7 z1_emp_8) 
label var emp_11 "Employment Index"

* A4: Employee Wages
gen wage_1=F8
replace wage_1=. if wage_1==999
label var wage_1 "Total wage bill"
* rescale total wage bill into 1000s of Naira for display
replace wage_1=wage_1/1000
replace b_wage_1=b_wage_1/1000
gen wage_2=F8/F4_6
replace wage_2=F8/emp_num if F4_6==.
label var wage_2 "Wage per worker"
egen wage_3=rowmean(E11e_1 E11e_2 E11e_3 E11e_4 E11e_5)
label var wage_3 "Average wage of highest paid workers"
* Replace as zero for closed firms, and winsorize
foreach var of varlist wage_1 wage_2 wage_3 {
replace `var'=0 if survival==0
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
* Standardized z-score 
foreach var of varlist wage_1 wage_2 wage_3 { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen wage_4 = rowmean(z1_wage_1 z1_wage_2 z1_wage_3) 
label var wage_4 "Wage Index"

* A5 and A6: Sales and Profits

* Set missing values to missing
foreach var of varlist G16 G17 G23 G24 {
replace `var'=. if `var'==999|`var'==998
}

* sales in last month
gen sales=G16
replace sales=125000 if sales==. & G16_1==1
replace sales=375000 if sales==. & G16_1==2
replace sales=625000 if sales==. & G16_1==3
replace sales=875000 if sales==. & G16_1==4
replace sales=1125000 if sales==. & G16_1==5
replace sales=1375000 if sales==. & G16_1==6
replace sales=1750000 if sales==. & G16_1==7
replace sales=2500000 if sales==. & G16_1==8
replace sales=3500000 if sales==. & G16_1==9
replace sales=4500000 if sales==. & G16_1==10
replace sales=6000000 if sales==. & G16_1==11
replace sales=8750000 if sales==. & G16_1==12
sum sales if G16_1==13, de
replace sales=r(p50) if sales==. & G16_1==13
* sales in last year
gen salesyr=G17
replace salesyr=125000 if salesyr==. & G17_1==1
replace salesyr=375000 if salesyr==. & G17_1==2
replace salesyr=625000 if salesyr==. & G17_1==3
replace salesyr=875000 if salesyr==. & G17_1==4
replace salesyr=1125000 if salesyr==. & G17_1==5
replace salesyr=1375000 if salesyr==. & G17_1==6
replace salesyr=1750000 if salesyr==. & G17_1==7
replace salesyr=2500000 if salesyr==. & G17_1==8
replace salesyr=3500000 if salesyr==. & G17_1==9
replace salesyr=4500000 if salesyr==. & G17_1==10
replace salesyr=6000000 if salesyr==. & G17_1==11
replace salesyr=8750000 if salesyr==. & G17_1==12
sum salesyr if G17_1==13, de
replace salesyr=r(p50) if salesyr==. & G17_1==13
* total profits in past month
gen profits=G23
replace profits=125000 if profits==. & G23_1==1
replace profits=375000 if profits==. & G23_1==2
replace profits=625000 if profits==. & G23_1==3
replace profits=875000 if profits==. & G23_1==4
replace profits=1125000 if profits==. & G23_1==5
replace profits=1375000 if profits==. & G23_1==6
replace profits=1750000 if profits==. & G23_1==7
replace profits=2500000 if profits==. & G23_1==8
replace profits=3500000 if profits==. & G23_1==9
replace profits=4500000 if profits==. & G23_1==10
replace profits=6000000 if profits==. & G23_1==11
replace profits=8750000 if profits==. & G23_1==12
sum profits if G23_1==13, de
replace profits=r(p50) if profits==. & G23_1==13
* profits in last year
gen profitsyr=G24
rename G24_cat G24_1
replace profitsyr=125000 if profitsyr==. & G24_1==1
replace profitsyr=375000 if profitsyr==. & G24_1==2
replace profitsyr=625000 if profitsyr==. & G24_1==3
replace profitsyr=875000 if profitsyr==. & G24_1==4
replace profitsyr=1125000 if profitsyr==. & G24_1==5
replace profitsyr=1375000 if profitsyr==. & G24_1==6
replace profitsyr=1750000 if profitsyr==. & G24_1==7
replace profitsyr=2500000 if profitsyr==. & G24_1==8
replace profitsyr=3500000 if profitsyr==. & G24_1==9
replace profitsyr=4500000 if profitsyr==. & G24_1==10
replace profitsyr=6000000 if profitsyr==. & G24_1==11
replace profitsyr=8750000 if profitsyr==. & G24_1==12
sum profitsyr if G24_1==13, de
replace profitsyr=r(p50) if profitsyr==. & G24_1==13

* replace missing values, set to zero if closed and missing, and winsorize
foreach var of varlist sales salesyr profits profitsyr {
replace `var'=0 if survival==0 & `var'==.
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}
* correct errors based on word and range checks
list entrep_id sales G16* if sales>0 & sales<5000 
list entrep_id salesyr G17* if salesyr>0 & salesyr<5000 
list entrep_id profits G23* if profits>0 & profits<5000 
replace profits=42000 if entrep_id=="2016023860"
list entrep_id profitsyr G23* if profitsyr>0 & profitsyr<5000 

*** Monthly sales for each month from July 2018 through December 2018
* First check response rate vs that of last month's sales
sum G16 G22a G22b G22c G22d G22e G22f
* code months 
gen salemonth_6=G22a
gen salemonth_5=G22b
gen salemonth_4=G22c
gen salemonth_3=G22d
gen salemonth_2=G22e
gen salemonth_1=G22f
*** Monthly profits for each month of October, November, and December 2018
* Check response rates vs that of last month's profits
sum G23 G17_1a G17_1b G17_1c
* code months
gen profmonth_6=G17_1a
gen profmonth_5=G17_1b
gen profmonth_4=G17_1c

* replace missing values, set to zero if closed and missing, and winsorize
foreach var of varlist salemonth_6 salemonth_5 salemonth_4 salemonth_3 salemonth_2 salemonth_1 profmonth_6 profmonth_5 profmonth_4 {
replace `var'=0 if survival==0 & `var'==.
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}

* Inverse Hyperbolic sine of each
foreach var of varlist sales salesyr profits profitsyr salemonth_6 salemonth_5 salemonth_3 salemonth_2 salemonth_1 profmonth_6 profmonth_5 profmonth_4  {
gen inv`var'=ln(`var'+(((`var'^2)+1)^(1/2)))
}
foreach var of varlist invsales invsalesyr invprofits invprofitsyr { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen salesprofindex = rowmean(z1_invsales z1_invsalesyr z1_invprofits z1_invprofitsyr) 
label var salesprofindex "Sales and Profits Index"
* no baseline profit data, so baseline index also missing
gen b_salesprofindex=0
gen b_salesprofindex_miss=1

* Pre-specified robustness check on levels - scale in 1000s
replace profits=profits/1000
replace sales=sales/1000
replace b_sales=b_sales/1000
for num 1/6: replace salemonth_X=salemonth_X/1000

*** Item non-response on profits and sales (includes not answering survey)
gen itemnr_profitsales=cond(salesprofindex==.,1,0)
label var itemnr_profitsales "Item non-response Profits/Sales"

* A7: Reporting Errors Made
gen error1=cond(G23>G16 & G23~=. & G16~=.,1,0)
gen error2=cond(G24>G17 & G24~=. & G17~=.,1,0)
gen error3=cond(G16>G17 & G16~=. & G17~=.,1,0)
gen error4=cond(G23>G24 & G23~=. & G24~=.,1,0)
gen error5=cond(F8>G16 & F8~=. & G16~=.,1,0)
gen totalerrors=error1+error2+error3+error4+error5
replace totalerrors=. if attrited==1
label var totalerrors "Reporting Errors Made"
gen b_totalerrors=0
gen b_totalerrors_miss=1

******************* Group B: impact on business practices ******************************
* B1 and B2: business practices
* Finance and Accounting practices
gen finance1=cond(D1A==1|D1A==2,1,0) if D1A~=.
gen finance2=cond(D2A==1|D2A==2,1,0) if D2A~=.
gen finance3=cond(D3A==1|D3A==2,1,0) if D3A~=.
gen finance4=cond(D4A==1|D4A==2,1,0) if D4A~=.
gen finance5=cond(D5A==1,1,0) if D5A~=.
gen finance6=cond(D6A==1,1,0) if D6A~=.
gen finance7=cond(D7A==1,1,0) if D7A~=.
gen finance8=cond(D8A==1|D8A==2,1,0) if D8A~=.
gen finance9=cond(D9A==1,1,0) if D9A~=.
gen finance10=cond(D10A==1,1,0) if D10A~=.
sum finance1-finance10
egen financeindex=rowmean(finance1-finance10)
label var financeindex "Finance Practices Index"

* Marketing and Sales practices
gen mktg1=cond(D11A==1,1,0) if D11A~=.
gen mktg2=cond(D12A==1,1,0) if D12A~=.
gen mktg3=cond(D13A==1,1,0) if D13A~=.
gen mktg4=cond(D14A==1|D14A==2,1,0) if D14A~=.
gen mktg5=cond(D15A==1,1,0) if D15A~=.
gen mktg6=cond(D16A==1,1,0) if D16A~=.
gen mktg7=cond(D17A==1|D17A==2,1,0) if D17A~=.
gen mktg8=cond(D18A==1|D18A==2,1,0) if D18A~=.
gen mktg9=cond(D19A==1,1,0) if D19A~=.
sum mktg1-mktg9
egen marketingindex=rowmean(mktg1-mktg9)
label var marketingindex "Marketing Practices Index"

* Digital Marketing practices
gen digmktg1=cond(D20A==1,1,0) if D20A~=.
gen digmktg2=cond(D21A==1,1,0) if D21A~=.
replace digmktg2=0 if digmktg1==0
gen digmktg3=cond(D22A==1,1,0) if D22A~=.
gen digmktg4=cond(D24A==1,1,0) if D24A~=.
gen digmktg5=cond(D24C==1,1,0) if D24C~=.
gen digmktg6=cond(D24E==1,1,0) if D24E~=.
gen digmktg7=cond(D24G==1,1,0) if D24G~=.
gen digmktg8=cond(D24I==1,1,0) if D24I~=.
gen digmktg9=cond(D24K==1,1,0) if D24K~=.
gen digmktg10=cond(D24M==1,1,0) if D24M~=.
gen digmktg11=cond(D24S==1,1,0) if D24S~=.
for num 4/11: replace digmktgX=0 if D23==0
sum digmktg1-digmktg11
egen digmarketingindex=rowmean(digmktg1-digmktg11)
label var digmarketingindex "Digital Marketing Practices Index"

* Operations and HR practices
gen ophr1=cond(D25A==1,1,0) if D25A~=.
gen ophr2=cond(D26A==1,1,0) if D26A~=.
gen ophr3=cond(D27A==1,1,0) if D27A~=.
gen ophr4=cond(D28A==1|D28A==2,1,0) if D28A~=.
gen ophr5=cond(D29A==1,1,0) if D29A~=.
gen ophr6=cond(D30A==1,1,0) if D30A~=.
gen ophr7=cond(d5f_b==1,1,0) if d5f_b~=.
gen ophr8=cond(D31A==1|D31A==2,1,0) if D31A~=.
gen ophr9=cond(D32A==1,1,0) if D32A~=.
gen ophr10=cond(D33A==1,1,0) if D33A~=.
gen ophr11=cond(d6c<=3,1,0) if d6c~=.
sum ophr1-ophr11
egen opHRindex=rowmean(ophr1-ophr11)
label var opHRindex "Operations and HR practices index"

* overall BP index
egen overallBPindex=rowmean(finance1-finance10 mktg1-mktg9 digmktg1-digmktg11 ophr1-ophr11)
label var overallBPindex "Overall business practices index"

* Verified business practices
gen verifyBP1=cond(D1A==1,1,0) if D1A~=.
gen verifyBP2=cond(D2A==1,1,0) if D2A~=.
gen verifyBP3=cond(D3A==1,1,0) if D3A~=.
gen verifyBP4=cond(D4A==1,1,0) if D4A~=.
gen verifyBP5=cond(D8A==1,1,0) if D8A~=.
gen verifyBP6=cond(D14A==1,1,0) if D14A~=.
gen verifyBP7=cond(D17A==1,1,0) if D17A~=.
gen verifyBP8=cond(D18A==1,1,0) if D18A~=.
gen verifyBP9=cond(D28A==1,1,0) if D28A~=.
gen verifyBP10=cond(D31A==1,1,0) if D31A~=.
sum verifyBP1-verifyBP10
egen verifyBPindex=rowmean(verifyBP1-verifyBP10)
label var verifyBPindex "Verified BP index"

* Setting practices to zero for firms which are closed
foreach var of varlist financeindex marketingindex digmarketingindex  opHRindex overallBPindex verifyBPindex {
replace `var'=0 if survival==0
}

* Generate item non-response on business practices
gen itemnr_buspractices=overallBPindex==.
label var itemnr_buspractices "Item non-response on Business Practices" 

* Define pre-specified proxy baseline BP measures
gen b_financeindex=b_finance
gen b_marketingindex=b_marketing
gen b_digmarketingindex=b_score_10
gen b_opHRindex=b_hr
gen b_overallBPindex=b_score_10
gen b_verifyBPindex=b_score_10
foreach var of varlist b_financeindex-b_verifyBPindex {
gen `var'_miss=`var'==.
replace `var'=0 if `var'==.
}


**************** Group C: Impact on Owner Time Use *************************************
* C1: Owner's own time
gen ownerhours=C1a
replace ownerhours=0 if survival==0
sum ownerhours, de
replace ownerhours=r(p99) if ownerhours>r(p99) & ownerhours~=.
label var ownerhours "Owner hours worked in last week"
* hours not collected at baseline

*C2: time concentration
for num 1/13: gen tX=cond(C3A_X>5,1,0) if C3A_X~=.
sum t1-t13
egen timeconcentration=rowmean(t1-t13)
label var timeconcentration "Time concentration (higher=less)"

* number of functional areas that owner has decreased time 
foreach var of varlist C5a-C5j {
gen dec_`var'=cond(`var'<=2,1,0) if `var'~=.
}
egen decreasedtime=rowmean(dec_C5a-dec_C5j)
label var decreasedtime "Number of areas in which time decreased"

* item non-response on time concentration (note missing for closed businesses)
gen itemnr_timeuse=timeconcentration==.
label var itemnr_timeuse "Item non-response on time use"

* C3: Growth-focus
cap drop t1-t13
for num 1/13: gen tX=cond(C3A_X>5,1,0) if C3A_X~=.
gen growthhours=t6+t7+t8+t9+t10
label var growthhours "Growth-Focused Activities"
gen external1=C3B
gen future1=Q3C
gen growthcomposite=(external1+future1)/2
label var growthcomposite "Percent of time on external and future activities"
* number of growth-focused areas in which owner has increased time spent
foreach var of varlist C5a-C5j {
gen inc_`var'=cond(`var'>=4,1,0) if `var'~=.
}
egen increasedgrowthtime=rowmean(inc_C5f inc_C5g inc_C5h inc_C5i inc_C5j)
label var increasedgrowthtime "Number of growth areas in which time increased"

*C4: Delegation
egen delegation=rowmean(C11A C11B C11C C11D C11E)
label var delegation "Delegation"

************** Group D: Use of professional business services  **************************
* use human resource specialist
gen usehrspecialist=cond(E1__6==1|d6e2==6,1,0) if E1__6~=.|d6e2~=.
label var usehrspecialist "Use a HR specialist"
* use outside accounting agency at least monthly
gen useoutsideaccount=cond(E6==4 & (E8B==4|E8B==5|E8B==6),1,0) if E6~=.
label var useoutsideaccount "Uses outside accounting agency"
  * look at other frequency for accounting
 tab E8B_oth
 list entrep_id E8B_oth if E8B==7
 replace useoutsideaccount=1 if entrep_id=="2016052700"
* use outside marketing agency at least monthly 
gen useoutsidemarketing=cond(E10==4 & (E12B>=4 & E12B<=6),1,0) if E10~=.
label var useoutsidemarketing "Use outside marketing service"
* used a business consulting service in the past year
gen usebusconsulting=cond(E14==1 & E15>=8,1,0) if E14~=.
label var usebusconsulting "Use business consulting)
* Professional Services Index
egen useprofessionalservices=rowmean(usehrspecialist useoutsideaccount useoutsidemarket usebusconsult)
label var useprofessionalservices "Uses professional business services"  

* pre-specified that use zero services if business is closed
foreach var of varlist usehrspecialist useoutsideaccount useoutsidemarket usebusconsult useprofessionalservices {
replace `var'=0 if survival==0
}

* generate item non-response on use of professional services
gen itemnr_marketservices=useprofessionalservices==.
label var itemnr_marketservices "Item non-response on market for services"
 
********************* Group E: Innovation, Investment **********************
* Innovation Index
gen innovation1=cond(IN1==1,1,0) if IN1~=.
gen innovation2=cond(IN1==1 & IN3>=2,1,0) if IN1~=.
* note: skip pattern in questionnaire means only asked about innovations 3 and 4 if answered yes to innovation 1
gen innovation3=cond(IN5==1,1,0) if IN1~=.
gen innovation4=cond(IN6==1,1,0) if IN1~=.
gen innovation5=cond(IN8a==1,1,0) if IN8a~=.
gen innovation6=cond(IN8b==1,1,0) if IN8b~=.
gen innovation7=cond(IN8c==1,1,0) if IN8c~=.
gen innovation8=cond(IN8d==1,1,0) if IN8d~=.
gen innovation9=cond(IN8e==1,1,0) if IN8e~=.
gen innovation10=cond(IN8f==1,1,0) if IN8f~=.
gen innovation11=cond(IN8g==1,1,0) if IN8g~=.
gen innovation12=cond(IN9a==1,1,0) if IN9a~=.
gen innovation13=cond(IN9b==1,1,0) if IN9b~=.
gen innovation14=cond(IN9c==1,1,0) if IN9c~=.
gen innovation15=cond(IN9d==1,1,0) if IN9d~=.
gen innovation16=cond(IN9e==1,1,0) if IN9e~=.
gen innovation17=cond(IN9f==1,1,0) if IN9f~=.
egen innovationindex=rowmean(innovation1-innovation17)
label var innovationindex "Innovation Index"
* Firms are not innovating if closed
replace innovationindex=0 if survival==0

* Investment Index
gen newloan=cond(G1==1,1,0) if G1~=.
label var newloan "Obtained new loan financing"
gen newequity=cond(G2==1,1,0) if G2~=.
label var newequity "New Equity Financing"
gen newbiginvestment=cond(G3==1,1,0) if G3~=.
label var newbiginvestment "New big investment"
* firms which are dead are not borrowing or investing
foreach var of varlist newloan newequity newbiginvestment {
replace `var'=0 if survival==0
}
egen investmentindex=rowmean(newloan newequity newbiginvestment)
label var investmentindex "Investment Index"


******************** Group F: Firm Boundaries and Persistence **********************
* Insourcing firm still has worker working for them at time of second follow-up
gen insourceworkerstillthere=cond(GR3==1,1,0) if ftreat==0 & GR1~=.
replace insourceworkerstillthere=0 if survival==0 & ftreat==0
label var insourceworkerstillthere "Insourced worker still working in firm"

* F1: predicted correlates of likelihood of worker sticking around
gen workertrustability=cond(FB4==4|FB4==5,1,0) if FB4~=.
label var workertrustability "Believes marketing and accounting workers can be trusted"
gen verifyintaccounting=cond(FB6==4|FB6==5,1,0) if FB6~=.
label var verifyintaccounting "Believes can verify work of internal accountant"
gen verifyintmarketing=cond(FB8==4|FB8==5,1,0) if FB8~=.
label var verifyintmarketing "Believes can verify work of internal marketing worker"
gen canenforceworkercontract=cond(FB10==4|FB10==5,1,0) if FB10~=.
label var canenforceworkercontract "Believes can enforce contracts with internal workers"

* Outsourced firm still has provider working for them at time of second follow-up
  * note confusion on some firms whether they got worker or provider, so count both
gen outsourceproviderstillthere=cond(GR12==1|GR3==1,1,0) if ftreat==1 & (GR1~=.|GR10~=.)
replace outsourceproviderstillthere=0 if survival==0 & ftreat==1
label var outsourceproviderstillthere "Outsourced provider still working with firm" 

* F2: correlates of likelihood of provider sticking around
gen cashnotfirmspecific=cond(FB1==1,1,0) if FB1~=.
label var cashnotfirmspecific "Way firm spends and generates cash not very firm-specific"
gen customersnotfirmspecific=cond(FB2==1,1,0) if FB2~=.
label var customersnotfirmspecific "Type of customers and customer acquisition strategies not very firm-specific"
gen providertrustability=cond(FB3==4|FB3==5,1,0) if FB3~=.
label var providertrustability "Believes marketing and accounting providers can be trusted"
gen verifyoutaccounting=cond(FB5==4|FB5==5,1,0) if FB5~=.
label var verifyoutaccounting "Believes can verify work of outside accountant"
gen verifyoutmarketing=cond(FB7==4|FB7==5,1,0) if FB7~=.
label var verifyoutmarketing "Believes can verify work of outside marketing firm"
gen canenforcefirmcontract=cond(FB9==4|FB9==5,1,0) if FB9~=.
label var canenforcefirmcontract "Believes can enforce outside business provider contract"

* F3: inside vs outside transactions gap index
gen accountingspecific=cond(FB1==2,1,0) if FB1~=.
gen marketingspecific=cond(FB2==2,1,0) if FB2~=.
gen insideoutsidetrustgap=FB4-FB3
gen insideoutsideverifyaccountgap=FB6-FB5
gen insideoutsideverifymarketgap=FB8-FB7
gen insideoutsideenforcegap=FB10-FB9
foreach var of varlist accountingspecific marketingspecific insideoutsidetrustgap insideoutsideverifyaccountgap insideoutsideverifymarketgap insideoutsideenforcegap { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen insideoutsidetransactionsgap = rowmean(z1_accountingspecific z1_marketingspecific z1_insideoutsidetrustgap z1_insideoutsideverifyaccountgap z1_insideoutsideverifymarketgap z1_insideoutsideenforcegap) 
label var insideoutsidetransactionsgap "Inside-outside transactions gap"

* testing that components of index don't change with treatment
gen insourcing=ftreat==0
gen outsourcing=ftreat==1
foreach var of varlist accountingspecific marketingspecific insideoutsidetrustgap insideoutsideverifyaccountgap insideoutsideverifymarketgap insideoutsideenforcegap { 
areg `var' insourcing outsourcing if (ftreat==0|ftreat==1|ftreat==4), r a(batchno)
}
drop insourcing outsourcing
* insourcing has significant effect on gap in verifying marketing 
* index omitting this variable
egen insideoutsidetransactionsgap1 = rowmean(z1_accountingspecific z1_marketingspecific z1_insideoutsidetrustgap z1_insideoutsideverifyaccountgap z1_insideoutsideenforcegap) 
label var insideoutsidetransactionsgap1 "Inside-outside transactions gap (excluding marketing)"


**** Generate indicator of survey round
gen surveyround=2
label var surveyround "Follow-up survey round"

sort entrep_id
save "$constructdata/CleanedFU2.dta", replace


****************************************************************************************************
*** Construct Social Media Scores ******************************************************************
****************************************************************************************************
use "$rawdata/SocialMediaRatings.dta", clear

* Generate Scores
egen websitescore=rmean(SM1-SM12)
egen facebookscore=rmean(SM13-SM24)
egen twitterscore=rmean(SM25-SM36)
egen instagramscore=rmean(SM37-SM48)
gen overallquantity=SM49
gen overallquality=SM50
egen totalSMscore=rsum(SM1-SM50)
replace totalSMscore=totalSMscore/50

egen reviewer1=min(reviewerID), by(entrep_id)
egen reviewer2=max(reviewerID), by(entrep_id)

*** Generate Scores to Use in Analysis
** If two scores differ and one is zero, use the non-zero one
** Otherwise take average 
* Then build up average of them all from average of components

foreach var of varlist websitescore facebookscore twitterscore instagramscore overallquantity overallquality {
	gen `var'_1=`var' if reviewerID==reviewer1
	gen `var'_2=`var' if reviewerID==reviewer2
	egen m`var'_1=max(`var'_1), by(entrep_id)
	egen m`var'_2=max(`var'_2), by(entrep_id)
}

foreach var of varlist  websitescore facebookscore twitterscore instagramscore overallquantity overallquality {
egen a`var'=mean(`var'), by(entrep_id)
replace a`var'=m`var'_1 if m`var'_2==0 & m`var'_1~=0 & m`var'_1~=.
replace a`var'=m`var'_2 if m`var'_1==0 & m`var'_2~=0 & m`var'_2~=. 
corr a`var' m`var'_1 m`var'_2 if reviewerID==reviewer1 & dupid==1 
}

gen atotalscore=(12*awebsitescore+12*afacebookscore+12*atwitterscore+12*ainstagramscore+aoverallquantity+aoverallquality)/50

keep if reviewerID==reviewer1
keep entrep_id atotalscore awebsitescore afacebookscore atwitterscore ainstagramscore aoverallquality aoverallquantity

label var atotalscore "Total Social Media Score"
label var awebsitescore "Website Score"
label var afacebookscore "Facebook Score"
label var atwitterscore "Twitter Score"
label var ainstagramscore "Instagram Score"
label var aoverallquantity "Overall Social Media Quantity"
label var aoverallquality "Overall Social Media Quality"
sort entrep_id

save "$constructdata/SocialMediaScores.dta", replace


******************************************************************************************************
*** Construct Data on Training Take-up and Usage needed for Appendix Table 2.1 on Training ***********
******************************************************************************************************

use "$rawdata/TrainingUsage.dta", clear

*** For each of the different topics, get proportion who have completed online and in-person, make table
* Financial Management
gen y_OnlineComponentFM=cond(OnlineComponentFM>0 & OnlineComponentFM~=.,1,0)
gen y_FMAttendanceforcoursescore=cond(FMAttendanceforcoursescore>0 & FMAttendanceforcoursescore~=.,1,0)
gen y_StatusCompletedFM=cond(StatusCompletedFM==100,1,0) 
sum y_FMAttendanceforcoursescore y_OnlineComponentFM y_StatusCompletedFM

egen AttendanceforcoursescorePP=rowmax(MCAttendanceforcourse CEAttendanceforcourse MTAttendanceforcourse MPAttendanceforcourse)
* Other topics
foreach var of varlist OnlineComponentGO AttendanceforcoursescoreGO OnlineComponentBP AttendanceforcoursescoreBP OnlineComponentMM MMAttendanceforcoursescore OnlineComponentEG AttendanceforcoursescoreEG OnlineComponentPP AttendanceforcoursescorePP OnlineComponentHR HRMAttendanceforcoursescore OnlineComponentTH THMAttendanceforcoursescore{
gen y_`var'=cond(`var'>0 & `var'~=.,1,0)
}
foreach var of varlist StatusCompletedGO StatusCompletedBP StatusCompletedMM StatusCompletedEG StatusCompletedPP StatusCompletedHR StatusCompletedTH {
gen y_`var'=cond(`var'>0 & `var'~=.,1,0)
}

*** Indicators of Any Online, Number of Online, Any Attendance, Number of Courses
gen anyOnline=0
gen numberOnline=0
foreach var of varlist OnlineComponentFM  OnlineComponentGO OnlineComponentBP OnlineComponentMM  OnlineComponentHR  OnlineComponentEG  OnlineComponentPP   OnlineComponentTH    {
	replace anyOnline=1 if y_`var'==1
	replace numberOnline=numberOnline+1 if  y_`var'==1
}
gen anyInperson=0
gen numberInperson=0
foreach var of varlist  FMAttendanceforcoursescore  AttendanceforcoursescoreGO AttendanceforcoursescoreBP MMAttendanceforcoursescore  HRMAttendanceforcoursescore AttendanceforcoursescoreEG  AttendanceforcoursescorePP  THMAttendanceforcoursescore   {	
	replace anyInperson=1 if y_`var'==1
	replace numberInperson=numberInperson+1 if  y_`var'==1
}
gen y_anyOnline=anyOnline
gen y_numberOnline=numberOnline
gen y_anyInperson=anyInperson
gen y_numberInperson=numberInperson

gen y_Completed5OnlineCourses=cond(Completed5OnlineCourses=="YES", 1,0)
gen y_Completed12DayInClass=cond(Completed12DayInClass=="YES",1,0)

sort entrep_id
save "$constructdata/TableA2_1data.dta", replace

******************************************************************************************************************
*** Construct main activities used in BDS ************************************************************************
******************************************************************************************************************
use "$rawdata/BDSActivities.dta", replace
gen cat1=substr(SN,1,1)
tab cat1
gen typeF=cat1=="F"
gen typeH=cat1=="H"
gen typeM=cat1=="M"
gen typeO=cat1=="O"
gen typeS=cat1=="S"
gen counter=1
save "$constructdata/TableA2_2data.dta", replace


******************************************************************************************************************
*** Type of Worker Hired - used for Table A5.6 *******************************************************************
******************************************************************************************************************
use "$rawdata/IOMonitoringData.dta", clear
gen outsourcing=ftreat==1
gen insourcing=ftreat==0

gen marketingworker=cond(owner_insource_type==1,1,0) if firstvisit==1 & insourcing==1
label var marketingworker "Insourcing firm chose marketing worker"

*******************************************************************************************************************
**** Comparison of Business Service Providers - used for Table A8.1 ***********************************************
*******************************************************************************************************************
use "$rawdata/GEMProviderSurveys.dta", clear

** City
gen Lagos=admin_city==2
label var Lagos "Located in Lagos"

* Firm age
gen firmage=2018-bc_info_year_founded
label var firmage "Age of Firm (years)"

* Ownership status
gen soleprop=bc_info_ownership_status==1
gen partnership=bc_info_ownership_status==2
gen company=bc_info_ownership_status>=3 & bc_info_ownership_status<=6
label var soleprop "Sole Proprietorship"
label var partnership "Partnership"
label var company "Registered Company"

* Multiple branches
gen multiplebranches=cond(bc_info_no_branches_nigeria>1,1,0) if bc_info_no_branches_nigeria~=.
label var multiplebranches "Has more than one branch"
gen abujabranch=bc_info_branches_abuja==1
gen lagosbranch=bc_info_branches_lagos==1
label var abujabranch "Branch in Abuja"
label var lagosbranch "Branch in Lagos"

* Full-time employees
gen managers=bc_info_emp_mangers_ft
gen accountants=bc_info_emp_accountants_ft
gen marketers=bc_info_emp_marketers_ft
gen hrworkers=bc_info_emp_hr_ft
gen consultants=bc_info_emp_gen_consultants_ft
label var managers "Full-time managers"
label var accountants "Full-time accountants"
label var marketers "Full-time marketers"
label var hrworkers "Full-time HR workers"
label var consultants "Full-time consultants"

gen fulltimepros=managers+accountants+marketers+hrworkers+consultants
label var fulltimepros "Full-time professional workers"

gen totalemployment=bc_total_employees
label var totalemployment "Total number of employees"

gen sharedegrees=bc_info_emp_degrees/bc_total_employees
sum sharedegrees, de
label var sharedegrees "Share of staff with university degrees"

gen numberskillcertified=bc_info_emp_skill_certificates
label var numberskillcertified "Number of Staff with Skill Certification"
sum numberskillcertified, de
replace numberskillcertified=r(p99) if numberskillcertified>r(p99) & numberskillcertified~=.

* Professional Memberships
gen account_orgs=bc_info_assc_anan==1|bc_info_assc_ican==1|bc_info_assc_citn==1
gen marketing_orgs=bc_info_assc_nimn==1|bc_info_assc_advan==1
gen hr_orgs= bc_info_assc_cipm==1|bc_info_assc_ahrp==1
label var account_orgs "Belongs to Professional Accounting Organization"
label var marketing_orgs "Belongs to Professional Marketing Organization"
label var hr_orgs "Belongs to Professional HR Organization"

* Annual Sales
gen annualsales=bc_info_sales_yearly/365
label var annualsales "Annual Sales in USD"
sum annualsales, de
replace annualsales=r(p99) if annualsales>r(p99) & annualsales~=.

* Firm has a website
gen haswebsite= bc_info_website
label var haswebsite "Business has a website"

*** Type of Service Provider
gen ServiceProviderType=1 if gem_service_offered==1|nongem_service_offered==1
replace ServiceProviderType=2 if gem_service_offered==2|nongem_service_offered==2
replace ServiceProviderType=3 if gem_service_offered==3|nongem_service_offered==3
replace ServiceProviderType=4 if gem_service_offered==4|nongem_service_offered==4
label define providertype 1 "Accounting" 2 "Marketing" 3 "HR" 4 "Consulting"
label values ServiceProviderType providertype
tab ServiceProviderType GEM

* Number of accounting services they will implement for firms
gen naccountingservices=0
foreach var of varlist sp_acct_services_record_keeping-sp_acct_services_biz_registratio {
    replace naccountingservices=naccountingservices+1 if `var'==1
}
bysort ServiceProviderType: sum naccountingservices

* Cost of accounting services
gen accountingdayrate= sp_acct_msme_charge_day
gen accountingannualrate=sp_acct_msme_typical_charge
label var accountingdayrate "Day rate for accounting"
label var accountingannualrate "Annual rate for accounting"

*** Contractual period
gen accountingcontractdays=sp_acct_msme_contract_length

* Minimum size they think firm should be
gen accountingminemp=sp_acct_min_size_employees
gen accountingminsales=sp_acct_min_size_revenue


* Number of marketing services they will implement for firms
gen nmarketingservices=0
foreach var of varlist sp_mrkt_research- sp_mrkt_digital_marketing {
    replace nmarketingservices=nmarketingservices+1 if `var'==1
}
* Cost of marketing services
gen marketingdayrate= sp_mrkt_msme_charge_day
gen marketingannualrate=sp_mrkt_msme_typical_charge
label var marketingdayrate "Day rate for marketing"
label var marketingannualrate "Annual rate for marketing"

*** Contractual period
gen marketingcontractdays=sp_mrkt_msme_contract_length

* Minimum size they think firm should be
gen marketingminemp=sp_mrkt_min_size_employees
gen marketingminsales=sp_mrkt_min_size_revenue

* Number of hr services they will implement for firms
gen nhrservices=0
foreach var of varlist sp_hr_growth_plan_writing- sp_hr_staff_training {
    replace nhrservices=nhrservices+1 if `var'==1
}
* Cost of hrservices
gen hrdayrate= sp_hr_msme_charge_day
gen hrannualrate=sp_hr_msme_typical_charge
label var hrdayrate "Day rate for hr"
label var hrannualrate "Annual rate for hr"

*** Contractual period
gen hrcontractdays=sp_hr_msme_contract_length

* Minimum size they think firm should be
gen hrminemp=sp_hr_min_size_employees
gen hrminsales=sp_hr_min_size_revenue

* HR Quality Guarantee
gen hrqualityguarantee=sp_hr_candidates_replacement ==1
label var hrqualityguarantee "Will replace candidate for free if bad fit"

* Number of consulting services they will implement for firms
gen nconsultingservices=0
foreach var of varlist sp_gen_business_plan- sp_gen_e_payments {
    replace nconsultingservices=nconsultingservices+1 if `var'==1
}
* Cost of consultingservices
gen consultingdayrate= sp_gen_msme_charge_day
gen consultingannualrate=sp_gen_msme_typical_charge
label var consultingdayrate "Day rate for consulting"
label var consultingannualrate "Annual rate for consulting"

*** Contractual period
gen consultingcontractdays=sp_gen_msme_contract_length

* Minimum size they think firm should be
gen consultingminemp=sp_gen_min_size_employees
gen consultingminsales=sp_gen_min_size_revenue

* Winsorize rates
foreach var of varlist accountingdayrate accountingannualrate marketingdayrate marketingannualrate  hrdayrate hrannualrate consultingdayrate consultingannualrate {
sum `var', de
replace `var'=r(p99) if `var'>r(p99) & `var'~=.
}

*** Consolidated measures
gen nservices=naccountingservices
replace nservices=nmarketingservices if ServiceProviderType==2
replace nservices=nhrservices if ServiceProviderType==3
replace nservices=nconsultingservices if ServiceProviderType==4
gen dayrate=accountingdayrate
replace dayrate=marketingdayrate if ServiceProviderType==2
replace dayrate=hrdayrate if ServiceProviderType==3
replace dayrate=consultingdayrate if ServiceProviderType==4
gen annualrate=accountingannualrate
replace annualrate=marketingannualrate if ServiceProviderType==2
replace annualrate=hrannualrate if ServiceProviderType==3
replace annualrate=consultingannualrate if ServiceProviderType==4
gen contractdays=accountingcontractdays
replace contractdays=marketingcontractdays if ServiceProviderType==2
replace contractdays=hrcontractdays if ServiceProviderType==3
replace contractdays=consultingcontractdays if ServiceProviderType==4
gen minemp=accountingminemp
replace minemp=marketingminemp if ServiceProviderType==2
replace minemp=hrminemp if ServiceProviderType==3
replace minemp=consultingminemp if ServiceProviderType==4
gen minsales=accountingminsales
replace minsales=marketingminsales if ServiceProviderType==2
replace minsales=hrminsales if ServiceProviderType==3
replace minsales=consultingminsales if ServiceProviderType==4


* Number of customers in average month
gen numberofcustomersinmonth=cust_number_clients_Nigeria
sum cust_number_clients_Nigeria, de
replace numberofcustomersinmonth=r(p99) if numberofcustomersinmonth>r(p99) & numberofcustomersinmonth~=.
label var numberofcustomersinmonth "Number of customers in average month"

* Percent of customer from firms of different sizes
gen percentmicro=cust_type_micro_firms*10
gen percentsmall=cust_type_small_firms*10
gen percentmed=cust_type_medium_firms*10
gen percentlarge=cust_type_large_firms*10
label var percentmicro "Percent of customers with less than 5 employees"
label var percentsmall "Percent of customers with 5-20 employees"
label var percentmed "Percent of customers with 21-99 employees"
label var percentlarge "Percent of customers with 100+ employees"

* Quality guarantees offered
gen offerqualguarantee=cust_gurantee_offer
label var offerqualguarantee "Offers a quality guarantee"
gen willredoifnotsatisfied=cust_gurantee_offer_type==2
label var willredoifnotsatisfied "Will redo work if customer not satisfied"

* Capacity constrained
gen excesscapacity= cust_more_business==3
label var excesscapacity "Has excess capacity"

* Quality guarantees offered
gen moneybackguarantee=cond(cust_gurantee_offer_type==1,1,0) if cust_gurantee_offer_type~=.
label var moneybackguarantee "Offers a money back guarantee"

** Main way of getting customers
gen wordofmouth=cond(cust_aquisition_word_mouth==1,1,0) if cust_aquisition_word_mouth~=.
label var wordofmouth "Main way of getting business is word of mouth"
gen custadvertising=cond((cust_aquisition_online==1|cust_aquisition_radio_tv==1),1,0) if cust_aquisition_online~=.
label var custadvertising "Main way of getting business is advertising online, tv or radio"
gen walkins=cond( cust_aquisition_walk_in==1,1,0) if  cust_aquisition_walk_in~=.
label var walkins "Main way of getting business is customer walk-ins"

replace minsales=minsales/365

save "$constructdata/TableA8_1data.dta", replace