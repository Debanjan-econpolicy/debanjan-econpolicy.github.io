**********************************************************************************************************************************
**** Replication Files for Anderson and McKenzie 																				**
**** "Improving business practices and the boundary of the entrepreneur: A randomized experiment comparing training,            **
***** consulting, insourcing and outsourcing "																					**
**********************************************************************************************************************************

**********************************************************************************************************************************
*** DATA ANALYSIS: This file takes the constructed data and creates the tables and figures in the paper                          *
**********************************************************************************************************************************

*** Set directory
cd "C:/Users/wb200090/OneDrive - WBG/otherresearch/Nigeria/JohanneMaterials/JPERevision/ReplicationData/"

*** Set Stata version
version 16.0

* Install packages needed
cap ado uninstall mat2txt
ssc install mat2txt
ssc install estout, replace
net install binsreg, from(https://raw.githubusercontent.com/nppackages/binsreg/master/stata) replace
ssc install randcmd 
ssc install pdslasso


************************************************
*   Set Globals for Directories                 *
************************************************
	global constructdata "ConstructedData"
	global rawdata "RawData"
	global figures "output/figures"
	global tables  "output/tables"
	
***********************************************************************************************************
***** Figure 1: Using Application Data to GEM Program to see Patterns in Insourcing and Outsourcing *******
***********************************************************************************************************

use "$constructdata/Figure1data.dta", clear

binscatter ownrecords insourcerecords outsourcerecords employ2, discrete line(qfit) xtitle("Total Employment") ytitle("Proportion of Firms") ///
legend(order(1 "Owner" 2 "Someone else in Firm" 3 "Someone outside Firm")) title("Who Keeps the Firm's Accounts?") saving("$figures/Figure1A.gph", replace)

binscatter ownmarketing insourcemarket outsourcemarket employ2, discrete line(qfit) xtitle("Total Employment") ytitle("Proportion of Firms") ///
legend(order(1 "Owner" 2 "Someone else in Firm" 3 "Someone outside Firm")) title("Who Does the Firm's Marketing?") saving("$figures/Figure1B.gph", replace)

graph combine "$figures/Figure1A.gph" "$figures/Figure1B.gph", 
gr_edit style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit plotregion1.graph1.legend.style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.graph2.legend.style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit plotregion1.graph2.yaxis1.title.DragBy .2189558869574606 -1.642169152180899
gr_edit plotregion1.graph1.yaxis1.title.DragBy -.1094779434787303 -1.751647095659639
gr_edit plotregion1.graph1.legend.plotregion1.label[2].DragBy -.2189558869574567 -6.240242778287468
gr_edit plotregion1.graph1.legend.plotregion1.label[2].DragBy -.2189558869574547 2.736948586968178
gr_edit plotregion1.graph1.legend.plotregion1.label[2].DragBy .4379117739149077 2.627470643489464

graph save "$figures/Figure1.gph", replace
graph export "$figures/Figure1.png", replace

***************************************************************************************************************
***** Figure 2: Take-up and Usage of Insourcing and Outsourcing Treatments ************************************
***************************************************************************************************************

use "$constructdata/Figure2data.dta", clear
sort time
twoway line takeup_I takeup_O time, ytitle("Take-up rate") xtitle("Program Month") yscale(range(0 1)) ylabel(0(0.2)1) xlabel(0(1)9) graphregion(color(white)) 
graph export "$figures/Figure2.png", replace
graph save "$figures/Figure2.gph", replace

****************************************************************************************************************
**** Table 2: Comparison of Human Capital in Different Treatments **********************************************
****************************************************************************************************************
use "$constructdata/IOHumanCapital.dta", clear
append using "$constructdata/TrainersHumanCapital.dta", force
append using "$constructdata/ConsultantsHumanCapital.dta", force

mat y = J(12,4,.)
local j=1
foreach var of varlist workermale workerage yearsexperience postgradeduc workercert workerassoc numdays hours workerpay {
sum `var' if insourcing==1 & firstvisit==1
mat y[`j',1]=r(mean)
sum `var' if outsourcing==1 & firstvisit==1
mat y[`j',2]=r(mean)
sum `var' if training==1
mat y[`j',3]=r(mean)
sum `var' if consulting==1
mat y[`j',4]=r(mean)	
local j=`j'+1
}
sum workerpay if insourcing==1 & firstvisit==1, de
mat y[10,1]=r(p10)
mat y[11,1]=r(p50)
mat y[12,1]=r(p90)
sum workerpay if outsourcing==1 & firstvisit==1, de
mat y[10,2]=r(p10)
mat y[11,2]=r(p50)
mat y[12,2]=r(p90)
sum workerpay if training==1, de
mat y[10,3]=r(p10)
mat y[11,3]=r(p50)
mat y[12,3]=r(p90)
sum workerpay if consulting==1, de
mat y[10,4]=r(p10)
mat y[11,4]=r(p50)
mat y[12,4]=r(p90)

mat rownames y = "Proportion Male" "Age" "Years Experience" "Post-graduate education" "Worker certified" "Professional Association" "Days per Week in Firm" "Hours per week" "Mean monthly pay" "10th percentile pay" "Median pay" "90th percentile pay"
mat colnames y = "Insourcing" "Outsourcing" "Training" "Consulting"
mat2txt, matrix(y) saving("$tables/Table2.xls") replace

*****************************************************************************************************************
**** Table 3: Main Tasks Done in Insourcing and Outsourcing *****************************************************
*****************************************************************************************************************
use "$rawdata/IOtasks.dta", clear
gen counter1=1 if ftreat==0
gen counter2=1 if ftreat==1
collapse (count) counter1 counter2, by(Taskname)
gen proportionfirms1=counter1/134 
gen proportionfirms2=counter2/139 
gen negcounter=-1*counter1
sort negcounter, stable
drop if counter1<=75
format proportionfirms1 proportionfirms2 %9.2f
export excel Taskname proportionfirms1 proportionfirms2 using "$tables/Table3.xls", firstrow(variables) keepcellfmt replace

*****************************************************************************************************************
**** Main Analysis: Tables 1, 4-9, and most Appendix Tables *****************************************************
*****************************************************************************************************************
* Append two follow-up surveys together
use "$constructdata/CleanedFU1.dta", clear
append using "$constructdata/CleanedFU2.dta", force

*** merge in Social Media scores
sort entrep_id
cap drop _merge
merge entrep_id using "$constructdata/SocialMediaScores.dta"
tab _merge
gen HaveSMscore=_merge==3
drop _merge

* Define treatment dummies
gen insourcing=ftreat==0
gen outsourcing=ftreat==1
gen training=ftreat==2
gen consulting=ftreat==3

*** Urban Consumer price index
** Source: Table 3 of Consumer Price Index June 2019 Report, National Bureau of Statistics, Nigeria
** https://www.nigerianstat.gov.ng/download/969
** convert everything to January 2018 Naira. Since profits and sales refer to last month, use last month CPI 
gen cpiindex=1 if surveyround==1 & monthsurvey==2
replace cpiindex=248.4/250.3 if surveyround==1 & monthsurvey==3
replace cpiindex=248.4/252.4 if surveyround==1 & monthsurvey==4
replace cpiindex=248.4/257.3 if surveyround==1 & monthsurvey==5
replace cpiindex=248.4/260.5 if surveyround==1 & monthsurvey==6
replace cpiindex=248.4/276.6 if surveyround==2 & monthsurvey==2
replace cpiindex=248.4/278.6 if surveyround==2 & monthsurvey==3
replace cpiindex=248.4/280.8 if surveyround==2 & monthsurvey==4
replace cpiindex=248.4/286.6 if surveyround==2 & monthsurvey==5
replace cpiindex=248.4/289.7 if surveyround==2 & monthsurvey==6
* replace cpiindex as modal month if monthsurvey is missing
replace cpiindex=248.4/252.4 if surveyround==1 & monthsurvey==.
replace cpiindex=248.4/278.6 if surveyround==2 & monthsurvey==.

* CPI index for asking in second follow-up about July through December CPI
gen cpimonth_6=248.4/274.6
gen cpimonth_5=248.4/272.6
gen cpimonth_4=248.4/270.4
gen cpimonth_3=248.4/268.4
gen cpimonth_2=248.4/266.2
gen cpimonth_1=248.4/263.4

**** describe when surveys were taken
tab b_monthsurvey if surveyround==1
tab monthsurvey if surveyround==1
tab monthsurvey if surveyround==2

* avoid confusion in education variable by recoding
* variable was coded for having completed undergrad but no further, recode so is completed at least undergrad
replace b_undergrad=1 if b_mastersplus==1

***********************************************************
**** Table 1: Baseline Balance Table **********************
***********************************************************
iebaltab b_salesmonthUSD b_salesbestmonthUSD b_worstmonthsalesUSD b_averagemonthsales b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
b_female b_ageyear b_married b_undergrad b_mastersplus b_salariedjob if surveyround==1, ///
grpvar(ftreat) save("$tables/Table1.xls")  rowvarlabels nottest feqtest replace fix(batchno) total order(4 0 1 2 3)
* note: column 6 in output table is first column in table in the paper


*********************************************************************************************
**** Table 4: Impact on Business Practices **************************************************
*********************************************************************************************
eststo clear
local i=1
foreach var of varlist financeindex marketingindex opHRindex verifyBPindex digmarketingindex   overallBPindex {
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableB1_`i'
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableB2_`i'
local i=`i'+1
}

#delimit ;
esttab tableB1_* using "$tables/Table4.csv", replace depvar legend label nonumbers nogaps nonotes
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	posthead(Panel A: Impacts in First Follow-up Survey)  ///
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	mtitles("Finance" "Marketing" "Operations" "Verified Traditional" "Verified Digital" "Overall Index")
	title("Table 4: Impacts on Business Practices") addnotes("""") ;
#delimit cr
#delimit ;
esttab tableB2_* using "$tables/Table4.csv", append depvar legend label nonumbers nomtitles nogaps nonotes
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	posthead(Panel B: Impacts in Second Follow-up Survey)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2"));
#delimit cr

**** Test whether year 1 and year 2 effects are equal
gen round2=surveyround==2
foreach var of varlist insourcing outsourcing training consulting {
gen `var'_round2 = `var'* round2
}
eststo clear
local i=1
foreach var of varlist financeindex marketingindex opHRindex verifyBPindex digmarketingindex   overallBPindex {
areg `var' insourcing outsourcing training consulting insourcing_round2 outsourcing_round2 training_round2 consulting_round2 round2 b_`var' b_`var'_miss, r a(batchno) cluster(entrep_id)
test insourcing_round2==0
estadd scalar pval1=r(p)
test outsourcing_round2==0
estadd scalar pval2=r(p)
test training_round2==0
estadd scalar pval3=r(p)
test consulting_round2==0
estadd scalar pval4=r(p)
test insourcing_round2==outsourcing_round2==training_round2==consulting_round2==0
estadd scalar pval5= r(p)
eststo tableB3_`i'
local i=`i'+1
}

#delimit ;
esttab tableB3_*  using "$tables/Table4.csv", append depvar legend label nonumbers nomtitles noobs
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons insourcing* outsourcing* training* consulting* round2 b_*)
	stats(pval5, fmt(%9.3f) labels("Jointly Zero")) 
	addnotes("""") ;
#delimit cr

*** Get p-values from Table 4 for calculating q-values
mat y = J(48,5,.)
* Populate Table, Column, Treatment, Round
* Table 
forvalues j = 1(1)48 {
mat y[`j',1]=4
}
* Column 
forvalues j=1(1)4 {
mat y[`j',2]=1
mat y[`j'+4,2]=2
mat y[`j'+8,2]=3
mat y[`j'+12,2]=4
mat y[`j'+16,2]=5
mat y[`j'+20,2]=6
mat y[`j'+24,2]=1
mat y[`j'+28,2]=2
mat y[`j'+32,2]=3
mat y[`j'+36,2]=4
mat y[`j'+40,2]=5
mat y[`j'+44,2]=6
}
* Treatment
forvalues j=1(4)45 {
mat y[`j',3]=1
mat y[`j'+1,3]=2
mat y[`j'+2,3]=3
mat y[`j'+3,3]=4
}
* Round
forvalues j=1(1)24 {
mat y[`j',4]=1
mat y[`j'+24,4]=2	
}
local i=1
foreach var of varlist financeindex marketingindex opHRindex verifyBPindex digmarketingindex   overallBPindex {
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1, r a(batchno)
test insourcing=0
mat y[4*`i'-3,5]=r(p)
test outsourcing=0
mat y[4*`i'-2,5]=r(p)
test training=0
mat y[4*`i'-1,5]=r(p)
test consulting=0
mat y[4*`i',5]=r(p)
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2, r a(batchno)
test insourcing=0
mat y[4*`i'+21,5]=r(p)
test outsourcing=0
mat y[4*`i'+22,5]=r(p)
test training=0
mat y[4*`i'+23,5]=r(p)
test consulting=0
mat y[4*`i'+24,5]=r(p)
local i=`i'+1
}
mat colnames y = "Table" "Column" "Treatment" "Round" "p-value" 
mat2txt, matrix(y) saving("$constructdata/Tablep4.xls") replace
preserve
drop _all
svmat double y
rename y1 table
rename y2 column
rename y3 treatment
rename y4 round
rename y5 pval
save "$constructdata/Tablep4.dta", replace
restore

**************** Robustness to PDS Lasso (mentioned in footnote) ***********
** Dummy out missing baseline variables
gen b_salesbestmonthUSD_miss=b_salesbestmonthUSD==.
replace b_salesbestmonthUSD=0 if b_salesbestmonthUSD_miss==1
gen b_worstmonthsalesUSD_miss=b_worstmonthsalesUSD==.
replace b_worstmonthsalesUSD=0 if b_worstmonthsalesUSD_miss==1
gen pdsfemale=b_female
replace pdsfemale=0 if pdsfemale==.
gen pdsaveragemonth=b_averagemonthsales 
replace pdsaveragemonth=0 if b_averagemonthsales==.
eststo clear
local i=1
foreach var of varlist financeindex marketingindex opHRindex verifyBPindex digmarketingindex   overallBPindex  {
xtset batchno
* Round 1
pdslasso `var' insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob b_`var' b_`var'_miss)  if surveyround==1, fe  partial(b_`var' b_`var'_miss)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table4pds1_`i'
* Round 2
pdslasso `var' insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob b_`var' b_`var'_miss)  if surveyround==2, fe  partial(b_`var' b_`var'_miss)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table4pds2_`i'
local i=`i'+1
}

#delimit ;
esttab table4pds1_* table4pds2_* using "$tables/Table4_footnote_pds.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps 
	stats(mean N pval1 pval2 pval3 pval4 pval5, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Insourcing" "Outsourcing" "Training" "Consulting" "Jointly Zero")) 
	title("Robustness to PDS Lasso: Round 2 Impacts on Business Practices") addnotes("""") ;
#delimit cr


***********************************************************************************************
*********** Table 5: Impacts on Firm Growth ***************************************************
***********************************************************************************************
* Generate real sales and profits, IHS of these, and z-score based on real values
* undo scaling to thousands of Naira done in cleaning
replace sales=sales*1000
replace profits=profits*1000
foreach var of varlist sales salesyr profits profitsyr   {
gen real`var'=`var'*cpiindex
gen realinv`var'=ln(real`var'+(((real`var'^2)+1)^(1/2)))
}
foreach var of varlist realinvsales realinvsalesyr realinvprofits realinvprofitsyr { 
		sum `var' if ftreat==4
		local controlmean = r(mean) 
		local controlsd = r(sd) 
		cap drop z1_`var'
		gen z1_`var' = (`var'-`controlmean')/(`controlsd') 
	} 
egen realsalesprofindex = rowmean(z1_realinvsales z1_realinvsalesyr z1_realinvprofits z1_realinvprofitsyr) 
label var realsalesprofindex "Real Sales and Profits Index"

* Inverse Hyperbolic Sine Total Employment
gen inv_emp_7=asinh(emp_7)
gen b_inv_emp_7=asinh(b_emp_7)
gen b_inv_emp_7_miss=b_emp_7_miss
gen realinv_emp_7=inv_emp_7
gen realemp_7=emp_7

eststo clear
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7 {
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5a_`i'
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5b_`i'
local i=`i'+1
}
#delimit ;
esttab table5a_*  using "$tables/Table5.csv", replace depvar legend label nonumbers nogaps
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "P-value" "P-value")) 
	posthead(Panel A: Impacts in First Follow-up Survey)
	title("Table 5: Impact on Firm Growth") addnotes("""") ;
#delimit cr
#delimit ;
esttab  table5b_*  using "$tables/Table5.csv", append depvar legend label nonumbers nogaps
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "P-value" "P-value")) 
	posthead(Panel B: Impacts in Second Follow-up Survey);
#delimit cr

**** Test whether year 1 and year 2 effects are equal
eststo clear
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7 {
areg real`var' insourcing outsourcing training consulting insourcing_round2 outsourcing_round2 training_round2 consulting_round2 round2 b_`var' b_`var'_miss, r a(batchno) cluster(entrep_id)
test insourcing_round2==0
estadd scalar pval1=r(p)
test outsourcing_round2==0
estadd scalar pval2=r(p)
test training_round2==0
estadd scalar pval3=r(p)
test consulting_round2==0
estadd scalar pval4=r(p)
test insourcing_round2==outsourcing_round2==training_round2==consulting_round2==0
estadd scalar pval5= r(p)
eststo table5lastrow_`i'
local i=`i'+1
}

#delimit ;
esttab table5lastrow_*  using "$tables/Table5.csv", append depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons insourcing* outsourcing* training* consulting* round2 b_*)
	stats(pval5, fmt(%9.3f) labels("Jointly Zero"))  ;
#delimit cr

*** Get p-values for calculating adjusted q-values
mat y = J(56,5,.)
* Populate Table, Column, Treatment, Round
* Table 
forvalues j = 1(1)56 {
mat y[`j',1]=5
}
* Column 
forvalues j=1(1)4 {
mat y[`j',2]=1
mat y[`j'+4,2]=2
mat y[`j'+8,2]=3
mat y[`j'+12,2]=4
mat y[`j'+16,2]=5
mat y[`j'+20,2]=6
mat y[`j'+24,2]=7
mat y[`j'+28,2]=1
mat y[`j'+32,2]=2
mat y[`j'+36,2]=3
mat y[`j'+40,2]=4
mat y[`j'+44,2]=5
mat y[`j'+48,2]=6
mat y[`j'+52,2]=7
}
* Treatment
forvalues j=1(4)53 {
mat y[`j',3]=1
mat y[`j'+1,3]=2
mat y[`j'+2,3]=3
mat y[`j'+3,3]=4
}
* Round
forvalues j=1(1)28 {
mat y[`j',4]=1
mat y[`j'+28,4]=2	
}
*p-values
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7 {
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1, r a(batchno)
test insourcing=0
mat y[4*`i'-3,5]=r(p)
test outsourcing=0
mat y[4*`i'-2,5]=r(p)
test training=0
mat y[4*`i'-1,5]=r(p)
test consulting=0
mat y[4*`i',5]=r(p)
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2, r a(batchno)
test insourcing=0
mat y[4*`i'+25,5]=r(p)
test outsourcing=0
mat y[4*`i'+26,5]=r(p)
test training=0
mat y[4*`i'+27,5]=r(p)
test consulting=0
mat y[4*`i'+28,5]=r(p)
local i=`i'+1
}
mat colnames y = "Table" "Column" "Treatment" "Round" "p-value" 
mat2txt, matrix(y) saving("$constructdata/Tablep5.xls") replace

preserve
drop _all
svmat double y
rename y1 table
rename y2 column
rename y3 treatment
rename y4 round
rename y5 pval
save "$constructdata/Tablep5.dta", replace
restore


********************************************************************************
***** Table 6:     Owner Time Use *********************************************
********************************************************************************
**** Note: at only coding owner's hours to 0 if business doesn't survive.
* Other outcomes are conditional on business operating

gen salesandmarketingtime=C3A_6+C3A_7 
gen accountingfinancetime=C3A_4+C3A_5
label var salesandmarketingtime "Percent of time on sales and marketing"
label var accountingfinancetime "Percent of time on accounting and finance"

eststo clear
local i=1
foreach var of varlist ownerhours timeconcentration  growthhours growthcomposite delegation salesandmarketingtime accountingfinancetime {
areg `var' insourcing outsourcing training consulting if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table6a_`i'
areg `var' insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table6b_`i'
local i=`i'+1
}

#delimit ;
esttab table6a_*  using "$tables/Table6.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	posthead(Panel A: Impacts in First Follow-up Survey)
	title("Table 6: Impacts on Owner Time Use") addnotes("""") ;
#delimit cr
#delimit ;
esttab table6b_* using "$tables/Table6.csv", append depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	posthead(Panel B: Impacts in Second Follow-up Survey);
#delimit cr

*** Get p-values for looking at q-values
mat y = J(56,5,.)
* Populate Table, Column, Treatment, Round
* Table 
forvalues j = 1(1)56 {
mat y[`j',1]=6
}
* Column 
forvalues j=1(1)4 {
mat y[`j',2]=1
mat y[`j'+4,2]=2
mat y[`j'+8,2]=3
mat y[`j'+12,2]=4
mat y[`j'+16,2]=5
mat y[`j'+20,2]=6
mat y[`j'+24,2]=7
mat y[`j'+28,2]=1
mat y[`j'+32,2]=2
mat y[`j'+36,2]=3
mat y[`j'+40,2]=4
mat y[`j'+44,2]=5
mat y[`j'+48,2]=6
mat y[`j'+52,2]=7
}
* Treatment
forvalues j=1(4)53 {
mat y[`j',3]=1
mat y[`j'+1,3]=2
mat y[`j'+2,3]=3
mat y[`j'+3,3]=4
}
* Round
forvalues j=1(1)28 {
mat y[`j',4]=1
mat y[`j'+28,4]=2	
}
*p-values
local i=1
foreach var of varlist ownerhours timeconcentration  growthhours growthcomposite delegation salesandmarketingtime accountingfinancetime {
areg `var' insourcing outsourcing training consulting  if surveyround==1, r a(batchno)
test insourcing=0
mat y[4*`i'-3,5]=r(p)
test outsourcing=0
mat y[4*`i'-2,5]=r(p)
test training=0
mat y[4*`i'-1,5]=r(p)
test consulting=0
mat y[4*`i',5]=r(p)
areg `var' insourcing outsourcing training consulting  if surveyround==2, r a(batchno)
test insourcing=0
mat y[4*`i'+25,5]=r(p)
test outsourcing=0
mat y[4*`i'+26,5]=r(p)
test training=0
mat y[4*`i'+27,5]=r(p)
test consulting=0
mat y[4*`i'+28,5]=r(p)
local i=`i'+1
}
mat colnames y = "Table" "Column" "Treatment" "Round" "p-value" 
mat2txt, matrix(y) saving("$constructdata/Tablep6.xls") replace
preserve
drop _all
svmat double y
rename y1 table
rename y2 column
rename y3 treatment
rename y4 round
rename y5 pval
save "$constructdata/Tablep6.dta", replace
restore


************************************************************************************
**** Table 7: Financial Investment, Innovation, and Social Media Quality  **********
************************************************************************************
* Social media variable
* Generate unconditional variable, where zero if no score, since no social media 
gen un_atotalscore=atotalscore
replace un_atotalscore=0 if atotalscore==. & surveyround==2
replace un_atotalscore=. if surveyround==1
label var un_atotalscore "Unconditional Social Media Quality"
* conditional estimate
gen con_atotalscore=un_atotalscore
replace con_atotalscore=. if un_atotalscore==0
label var con_atotalscore "Conditional Social Media Quality"
* Unconditional Values of Components
foreach var of varlist awebsitescore afacebookscore atwitterscore ainstagramscore aoverallquality aoverallquantity {
	* generate unconditional variables - where zero if no score, since no social media of this type
	cap drop un_`var'
	gen un_`var'=`var'
	replace un_`var'=0 if un_`var'==.
}

eststo clear
* Innovation and Investment Indices and Social Media Scores
local i=1
foreach var of varlist investmentindex innovationindex un_awebsitescore un_afacebookscore un_atwitterscore un_ainstagramscore un_aoverallquality un_aoverallquantity un_atotalscore con_atotalscore {
areg `var' insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table7_`i'
local i=`i'+1
}
#delimit ;
esttab table7_* using "$tables/Table7.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Table 7: Impacts on Financial Investment, Product Innovation and Social Media Quality") addnotes("""") ;
#delimit cr

*** Get p-values for calculating sharpened q-values
mat y = J(40,5,.)
* Populate Table, Column, Treatment, Round
* Table 
forvalues j = 1(1)40 {
mat y[`j',1]=7
}
* Column 
forvalues j=1(1)4 {
mat y[`j',2]=1
mat y[`j'+4,2]=2
mat y[`j'+8,2]=3
mat y[`j'+12,2]=4
mat y[`j'+16,2]=5
mat y[`j'+20,2]=6
mat y[`j'+24,2]=7
mat y[`j'+28,2]=8
mat y[`j'+32,2]=9
mat y[`j'+36,2]=10
}
* Treatment
forvalues j=1(4)37 {
mat y[`j',3]=1
mat y[`j'+1,3]=2
mat y[`j'+2,3]=3
mat y[`j'+3,3]=4
}
* Round
forvalues j=1(1)40 {
mat y[`j',4]=2
}
*p-values
local i=1
foreach var of varlist investmentindex innovationindex un_awebsitescore un_afacebookscore un_atwitterscore un_ainstagramscore un_aoverallquality un_aoverallquantity un_atotalscore con_atotalscore {
areg `var' insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing=0
mat y[4*`i'-3,5]=r(p)
test outsourcing=0
mat y[4*`i'-2,5]=r(p)
test training=0
mat y[4*`i'-1,5]=r(p)
test consulting=0
mat y[4*`i',5]=r(p)
local i=`i'+1
}
mat colnames y = "Table" "Column" "Treatment" "Round" "p-value" 
mat2txt, matrix(y) saving("$constructdata/Tablep7.xls") replace
preserve
drop _all
svmat double y
rename y1 table
rename y2 column
rename y3 treatment
rename y4 round
rename y5 pval
save "$constructdata/Tablep7.dta", replace
restore


********************************************************************************************
***** Table 8: Why do more firms not use the market for professional business services? ****
********************************************************************************************
* Why don't they go to the market on their own for marketing services?
foreach var of varlist E13A-E13J {
gen `var'_likely=cond(`var'==4|`var'==5,1,0) if `var'~=. & `var'~=.a
sum `var'_likely if surveyround==1
}

* why don't they go to the market for accounting services?
foreach var of varlist E9A-E9J {
gen `var'_likely=cond(`var'==4|`var'==5,1,0) if `var'~=. & `var'~=.a
sum `var'_likely if surveyround==1
}

* don't use HR specialists
foreach var of varlist E5A-E5J {
gen `var'_likely=cond(`var'==4|`var'==5,1,0) if `var'~=. & `var'~=.a
sum `var'_likely if surveyround==1
}

* any information friction
gen anyinfo_market=E13A_likely
replace anyinfo_market=1 if E13B_likely==1
replace anyinfo_market=1 if E13C_likely==1
replace anyinfo_market=1 if E13F_likely==1
replace anyinfo_market=1 if E13H_likely==1
replace anyinfo_market=1 if E13I_likely==1
gen anycb_market=E13D_likely
replace anycb_market=1 if E13E_likely==1
replace anycb_market=1 if E13G_likely==1

gen anyinfo_acct=E9A_likely
replace anyinfo_acct=1 if E9B_likely==1
replace anyinfo_acct=1 if E9C_likely==1
replace anyinfo_acct=1 if E9F_likely==1
replace anyinfo_acct=1 if E9H_likely==1
replace anyinfo_acct=1 if E9I_likely==1
gen anycb_acct=E9D_likely
replace anycb_acct=1 if E9E_likely==1
replace anycb_acct=1 if E9G_likely==1

gen anyinfo_HR=E5A_likely
replace anyinfo_HR=1 if E5B_likely==1
replace anyinfo_HR=1 if E5C_likely==1
replace anyinfo_HR=1 if E5F_likely==1
replace anyinfo_HR=1 if E5H_likely==1
replace anyinfo_HR=1 if E5I_likely==1
gen anycb_HR=E5D_likely
replace anycb_HR=1 if E5E_likely==1
replace anycb_HR=1 if E5G_likely==1

mat y = J(15,3,.)	
local j=2
foreach var of varlist E13A E13B E13C E13F E13H E13I {
sum `var'_likely if surveyround==1
mat y[`j',1]=r(mean)
local j=`j'+1
}
sum anyinfo_market if surveyround==1
mat y[8,1]=r(mean)
local j=10
foreach var of varlist E13D E13E E13G {
sum `var'_likely if surveyround==1
mat y[`j',1]=r(mean)
local j=`j'+1
}
sum anycb_market if surveyround==1
mat y[13,1]=r(mean)
sum E13J_likely if surveyround==1
mat y[15,1]=r(mean)

local i=2
foreach var of varlist E9A E9B E9C E9F E9H E9I {
sum `var'_likely if surveyround==1
mat y[`i',2]=r(mean)
local i=`i'+1
}
sum anyinfo_acct if surveyround==1
mat y[8,2]=r(mean)
local i=10
foreach var of varlist E9D E9E E9G {
sum `var'_likely if surveyround==1
mat y[`i',2]=r(mean)
local i=`i'+1
}
sum anycb_acct if surveyround==1
mat y[13,2]=r(mean)
sum E9J_likely if surveyround==1
mat y[15,2]=r(mean)

local k=2
foreach var of varlist E5A E5B E5C E5F E5H E5I {
sum `var'_likely if surveyround==1
mat y[`k',3]=r(mean)
local k=`k'+1
}
sum anyinfo_HR if surveyround==1
mat y[8,3]=r(mean)
local k=10
foreach var of varlist E5D E5E E5G {
sum `var'_likely if surveyround==1
mat y[`k',3]=r(mean)
local k=`k'+1
}
sum anycb_HR if surveyround==1
mat y[13,3]=r(mean)
sum E5J_likely if surveyround==1
mat y[15,3]=r(mean)

mat colnames y = "Marketing" "Accounting" "HR Provider"
mat2txt, matrix(y)  format(%9.2f) saving("$tables/Table8.xls") replace


**************************************************************************************
***** Table 9: Use of Market for Professional Business Services *********************
*************************************************************************************
* Generate use of any professional business service
gen anyservice=usehrspecialist
replace anyservice=1 if useoutsideaccount==1
replace anyservice=1 if useoutsidemarket==1
replace anyservice=1 if usebusconsult==1
sum anyservice
gen b_anyservice=b_usehrconsultant
replace b_anyservice=1 if b_useoutsideaccount==1
replace b_anyservice=1 if b_useoutsidemarketing==1
replace b_anyservice=1 if b_usebusconsulting==1

areg anyservice insourcing outsourcing training consulting b_anyservice if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum anyservice if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table9_1
areg anyservice insourcing outsourcing training consulting b_anyservice if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum anyservice if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table9_2

#delimit ;
esttab table9_* using "$tables/Table9.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Table 9: Impacts on Continued Use of the Market for Business Services") addnotes("""") ;
#delimit cr

** pvalues for calculating sharpened q-values
*** Get p-values for calculating sharpened q-values
mat y = J(8,5,.)
* Populate Table, Column, Treatment, Round
* Table 
forvalues j = 1(1)8 {
mat y[`j',1]=9
}
* Column 
forvalues j=1(1)4 {
mat y[`j',2]=1
mat y[`j'+4,2]=2
}
* Treatment
forvalues j=1(4)5 {
mat y[`j',3]=1
mat y[`j'+1,3]=2
mat y[`j'+2,3]=3
mat y[`j'+3,3]=4
}
* Round
forvalues j=1(1)4 {
mat y[`j',4]=1
mat y[`j'+4,4]=2
}
*p-values
areg anyservice insourcing outsourcing training consulting b_anyservice if surveyround==1, r a(batchno)
test insourcing=0
mat y[1,5]=r(p)
test outsourcing=0
mat y[2,5]=r(p)
test training=0
mat y[3,5]=r(p)
test consulting=0
mat y[4,5]=r(p)
areg anyservice insourcing outsourcing training consulting b_anyservice if surveyround==2, r a(batchno)
test insourcing=0
mat y[5,5]=r(p)
test outsourcing=0
mat y[6,5]=r(p)
test training=0
mat y[7,5]=r(p)
test consulting=0
mat y[8,5]=r(p)
mat colnames y = "Table" "Column" "Treatment" "Round" "p-value" 
mat2txt, matrix(y) saving("$constructdata/Tablep9.xls") replace
preserve
drop _all
svmat double y
rename y1 table
rename y2 column
rename y3 treatment
rename y4 round
rename y5 pval
save "$constructdata/Tablep9.dta", replace
restore



************************************************************************
***** Appendix Tables  *************************************************
************************************************************************

*******************************************************************************************
**** Appendix Table 2.3: Choice of Accounting vs Marketing ********************************
*******************************************************************************************
cap drop _merge
sort entrep_id
merge entrep_id using "$rawdata/TypeofIO.dta"
drop _merge

* replace missings
replace gotmarketing=1 if gotmarketing==. & (GR2==2|GR11==2)
replace gotaccounting=0 if gotaccounting==. & (GR2==2|GR11==2) 
replace gotmarketing=0 if gotmarketing==. & (GR2==1|GR11==1)
replace gotaccounting=1 if gotaccounting==. & (GR2==1|GR11==1)

  sum gotmarketing gotaccounting if ftreat==1 & surveyround==2
  * check for insourcing
  sum gotmarketing gotaccounting if ftreat==0 & surveyround==2

replace gotmarketing=0 if ftreat==4
replace gotaccounting=0 if ftreat==4  


**** Choice of accounting vs marketing ****
gen chosemarketing=1 if gotmarketing==1
replace chosemarketing=0 if gotaccounting==1
replace chosemarketing=. if insourcing==0 & outsourcing==0
tab chosemarketing if surveyround==1

eststo clear
* Column 1 full model
probit gotaccounting b_finance b_marketing b_score_10 cashnotfirmspecific customersnotfirmspecific verifyintaccounting verifyintmarketing verifyoutaccounting verifyoutmarketing workertrustability providertrustability b_female b_ageyear  b_mastersplus b_construction b_ICT b_entertainment b_hospitality  b_registeredCAC b_useaccountingmarket b_usemarketingmarket b_fulltimeemp insourcing  if surveyround==2 & (gotaccounting==1|gotmarketing==1) & (insourcing==1|outsourcing==1), r
margins, dydx(*) post
eststo tableA2_4_1

* Column 2 choice based on lasso
lasso probit gotaccounting b_finance b_marketing b_score_10 cashnotfirmspecific customersnotfirmspecific verifyintaccounting verifyintmarketing verifyoutaccounting verifyoutmarketing workertrustability providertrustability b_female b_ageyear  b_mastersplus b_construction b_ICT b_entertainment b_hospitality  b_registeredCAC b_useaccountingmarket b_usemarketingmarket b_fulltimeemp if surveyround==2 & (gotaccounting==1|gotmarketing==1) & (insourcing==1|outsourcing==1), rseed(1234) alllambdas
lassocoef

probit gotaccounting  b_score_10 customersnotfirmspecific  verifyintaccounting  providertrustability b_female b_ageyear  b_construction b_ICT b_entertainment b_hospitality b_fulltimeemp  if surveyround==2 & (gotaccounting==1|gotmarketing==1) & (insourcing==1|outsourcing==1), r
margins, dydx(*) post
eststo tableA2_4_2

#delimit ;
esttab tableA2_4_* using "$tables/TableA2_3.csv", replace depvar legend label nonumbers nogaps
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01)
	stats(N, fmt(%9.0g) labels("Sample Size")) 
	title("Appendix Table 2.3: Correlates of Choice of Accounting over Marketing") addnotes("""") ;
#delimit cr

********** Section 6.2 Text Discussion: keeping on workers and when workers left *****************
* took-up I/O according to admin data
gen tookupIO=gotaccounting==1|gotmarketing==1

****** Insourcing *******
tab GR1 if ftreat==0

* still work for firm?
tab GR3 if GR1==1 & ftreat==0
* lower bound: count those who say they didn't hire worker as no longer having them
gen haveworker=cond(GR3==1,1,0) if surveyround==2 & GR1~=.
sum haveworker if ftreat==0 & tookupIO==1

* when did workers leave?
tab GR4_month GR4_year if ftreat==0

* quit or fired
tab GR5 if ftreat==0

**** Outsourcing *****
tab GR10 if ftreat==1
tab GR10 tookupIO if ftreat==1
* lots that claim they didn't hire when they did - some confusion as to worker or company or consulting
gen saysgotO=cond((GR1==1|GR10==1),1,0) if surveyround==2 & GR1~=. & GR10~=.
tab saysgotO if ftreat==1
tab saysgotO tookupIO if ftreat==1

* says they still have outsourcing
gen stillhaveO=cond((GR3==1|GR12==1),1,0) if saysgotO~=.
tab stillhaveO if ftreat==1
tab stillhaveO if ftreat==1 & saysgotO==1

* when did they leave
gen leave_month=GR13_month
replace leave_month=GR4_month if leave_month==.
gen leave_year=GR13_year
replace leave_year=GR4_year if leave_month==.
tab GR4_month GR4_year if ftreat==1
tab GR13_month GR13_year if ftreat==1
tab leave_month leave_year if ftreat==1

* why left
tab G14a

* Note: also seem to confuse consulting for outsourcing
gen saysgotO2=saysgotO
replace saysgotO2=1 if saysgotO==0 & GR18==1 & ftreat==1
tab saysgotO2 if ftreat==1
tab saysgotO2 tookupIO if ftreat==1

gen stillhaveO2=stillhaveO
replace stillhaveO2=1 if GR21_Year==2019|(GR21_month>=9 & GR21_Year==2018)
* Upper number:
tab stillhaveO2 if ftreat==1 & saysgotO2==1

* Lower number: as fraction who took up
tab stillhaveO2 if ftreat==1 & saysgotO2~=. & tookupIO==1
  

**********************************************************************
*** Appendix Table 3.1: Survey Attrition by Treatment Status *********
**********************************************************************

* don't know survival status
gen itemnr_survival=survival==.
label var itemnr_survival "Don't know operating status"

mat y = J(12,7,.)
local j=2
foreach var of varlist attrited itemnr_survival itemnr_profitsales itemnr_buspractices  {
* PANEL A: FIRST FOLLOW-UP SURVEY
* Column 1: Overall
sum `var' if ftreat~=. & surveyround==1
mat y[`j',1]=r(mean)
* Column 2: Control
sum `var' if ftreat==4 & surveyround==1
mat y[`j',2]=r(mean)
* Column 3: Insourcing
sum `var' if ftreat==0 & surveyround==1
mat y[`j',3]=r(mean)
* Column 4: Outsourcing
sum `var' if ftreat==1 & surveyround==1
mat y[`j',4]=r(mean)
* Column 5: Training
sum `var' if ftreat==2 & surveyround==1
mat y[`j',5]=r(mean)
* Column 6: Consulting
sum `var' if ftreat==3 & surveyround==1
mat y[`j',6]=r(mean)
* Column 7: F-test of equality of means, controlling for randomization strata
areg `var' insourcing outsourcing training consulting if surveyround==1, a(batchno) r
test insourcing==outsourcing==training==consulting==0
mat y[`j',7]=r(p)

* PANEL B: SECOND FOLLOW-UP SURVEY
local k=`j'+5
* Column 1: Overall
sum `var' if ftreat~=. & surveyround==2
mat y[`k',1]=r(mean)
* Column 2: Control
sum `var' if ftreat==4 & surveyround==2
mat y[`k',2]=r(mean)
* Column 3: Insourcing
sum `var' if ftreat==0 & surveyround==2
mat y[`k',3]=r(mean)
* Column 4: Outsourcing
sum `var' if ftreat==1 & surveyround==2
mat y[`k',4]=r(mean)
* Column 5: Training
sum `var' if ftreat==2 & surveyround==2
mat y[`k',5]=r(mean)
* Column 6: Consulting
sum `var' if ftreat==3 & surveyround==2
mat y[`k',6]=r(mean)
* Column 7: F-test of equality of means, controlling for randomization strata
areg `var' insourcing outsourcing training consulting if surveyround==2, a(batchno) r
test insourcing==outsourcing==training==consulting==0
mat y[`k',7]=r(p)
local j=`j'+1
}

* Last row is sample sizes
count if ftreat~=. & surveyround==2
mat y[12, 1] = r(N)
count if ftreat==4 & surveyround==2
mat y[12, 2] = r(N)
count if ftreat==0 & surveyround==2
mat y[12, 3] = r(N)
count if ftreat==1 & surveyround==2
mat y[12, 4] = r(N)
count if ftreat==2 & surveyround==2
mat y[12, 5] = r(N)
count if ftreat==3 & surveyround==2
mat y[12, 6] = r(N)

mat rownames y = "Panel A: First Follow-up" "Survey Attrition" "Survival Attrition" "Profits/Sales Attrition" "Business Practices Attrition" "Panel B: Second Follow-up" "Survey Attrition" "Survival Attrition" "Profits/Sales Attrition" "Business Practices Attrition" " "  "Sample Size"
mat colnames y = "Overall" "Control" "Insourcing" "Outsourcing" "Training" "Consulting" "p-value"
mat2txt, matrix(y) format(%9.3f) saving("$tables/TableA3_1.xls") replace

************************************************************************
**** Appendix Table 3.2: Baseline Balance for Non-Attritors  ***********
************************************************************************ 
iebaltab b_salesmonthUSD b_salesbestmonthUSD b_worstmonthsalesUSD b_averagemonthsales b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
b_female b_ageyear b_married b_undergrad b_mastersplus b_salariedjob if surveyround==2 & attrited==0, ///
grpvar(ftreat) save("$tables/TableA3_2.xls")  rowvarlabels nottest feqtest replace fix(batchno)  order(4 0 1 2 3)

***************************************************************************************************
*** Appendix Table 3.3: Baseline Balance for Round 2 Survivors ************************************
***************************************************************************************************
iebaltab b_salesmonthUSD b_salesbestmonthUSD b_worstmonthsalesUSD b_averagemonthsales b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
b_female b_ageyear b_married b_undergrad b_mastersplus b_salariedjob if surveyround==2 & survival==1, ///
grpvar(ftreat) save("$tables/TableA3_3.xls")  rowvarlabels nottest feqtest replace fix(batchno)  order(4 0 1 2 3)

*****************************************************************************************
*** Appendix Table 3.4: Impacts on Survival *********************************************
*****************************************************************************************
* Imputation
for num 1/2: gen surviveX=survival if surveyround==X
for num 1/2: egen msurviveX=max(surviveX), by(entrep_id)
gen isurvival=survival
* impute that firms that are alive in round 2 were alive in round 1 (but don't know when those who are dead died)
replace isurvival=1 if surveyround==1 & survival==. & msurvive2==1
* impute that firms that are dead in round 1 stay dead for round 2
replace isurvival=0 if surveyround==2 & survival==. & msurvive1==0

**** Round 1
eststo clear
* Pre-specified specification
areg survival insourcing outsourcing training consulting if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum survival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_1
* PDS Lasso
xtset batchno
pdslasso survival insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob)  if surveyround==1, fe
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum survival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_2
* Imputed Survival
areg isurvival insourcing outsourcing training consulting if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum isurvival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_3

*** Round 2
* Pre-specified specification
areg survival insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum survival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_4
* PDS Lasso
xtset batchno
pdslasso survival insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob)  if surveyround==2, fe
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum survival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_5
* Imputed Survival
areg isurvival insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum isurvival if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table3_6

#delimit ;
esttab table3_* using "$tables/TableA3_4.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2 pval3, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Appendix Table 3.4: Impact on Firm Survival") addnotes("""") ;
#delimit cr

***********************************************************************
**** Appendix Table 5.1: Impacts Conditional on Survival **************
***********************************************************************
eststo clear
local i=1
foreach var of varlist financeindex marketingindex opHRindex verifyBPindex digmarketingindex   overallBPindex  {
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1 & survival==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableB1_`i'
areg `var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2 & survival==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableB2_`i'
local i=`i'+1
}

#delimit ;
esttab tableB1_*  using "$tables/TableA5_1.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	posthead(Panel A: Impacts in First Follow-up Survey)
	title("Appendix Table 5.1: Impacts on Business Practices Conditional on Survival") addnotes("""") ;
#delimit cr
#delimit ;
esttab  tableB2_* using "$tables/TableA5_1.csv", append depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	posthead(Panel B: Impacts in Second Follow-up Survey) ;
#delimit cr

***************************************************************************************
******* Appendix Table 5.2: Practice by Practice Impacts on Finance Practices   *******
***************************************************************************************
* First make sure closed firms have practices set to zero
foreach var of varlist finance1-finance10 mktg1-mktg9 digmktg1-digmktg11 ophr1-ophr11 verifyBP1-verifyBP10 {
replace `var'=0 if survival==0
}

eststo clear
local i=1
foreach var of varlist finance1-finance10 {
areg `var' insourcing outsourcing training consulting b_financeindex b_financeindex_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
test insourcing==outsourcing==consulting
estadd scalar pval3=r(p)
test insourcing==outsourcing
estadd scalar pval4=r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableFinance_`i'
local i=`i'+1
}
#delimit ;
esttab tableFinance_*  using "$tables/TableA5_2.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3 pval4, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2" "Pval3" "Pval4")) 
	title("Table A5.2: Impacts on Finance & Accounting Practices") addnotes("""") ;
#delimit cr

************************************************************************************************
****** Appendix Table 5.3: Practice by Practice Impacts on Marketing and Sales Practices  ******
************************************************************************************************
eststo clear
local i=1
foreach var of varlist mktg1-mktg9 {
areg `var' insourcing outsourcing training consulting b_marketingindex b_marketingindex_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
test insourcing==outsourcing==consulting
estadd scalar pval3=r(p)
test insourcing==outsourcing
estadd scalar pval4=r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableMarketing_`i'mat2txt
local i=`i'+1
}
#delimit ;
esttab tableMarketing_*  using "$tables/TableA5_3.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3 pval4, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Table: Impacts on Marketing & Sales Practices") addnotes("""") ;
#delimit cr

**********************************************************************************************
***** Appendix Table 5.4: Practice by Practice Impacts for Digital Marketing Practices   *****
**********************************************************************************************
eststo clear
local i=1
foreach var of varlist digmktg1-digmktg11 {
areg `var' insourcing outsourcing training consulting b_digmarketingindex b_digmarketingindex_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
test insourcing==outsourcing==consulting
estadd scalar pval3=r(p)
test insourcing==outsourcing
estadd scalar pval4=r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tabledigMarketing_`i'
local i=`i'+1
}
#delimit ;
esttab tabledigMarketing_*  using "$tables/TableA5_4.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3 pval4, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Table: Impacts on Digital Marketing Practices") addnotes("""") ;
#delimit cr

***************************************************************************************
**** Appendix Table 5.5: Practice by Practice Impacts on Operations and HR  ***********
***************************************************************************************
eststo clear
local i=1
foreach var of varlist ophr1-ophr11 {
areg `var' insourcing outsourcing training consulting b_opHRindex b_opHRindex_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
test insourcing==outsourcing==consulting
estadd scalar pval3=r(p)
test insourcing==outsourcing
estadd scalar pval4=r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableopsHR_`i'
local i=`i'+1
}
#delimit ;
esttab tableopsHR_*  using "$tables/TableA5_5.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3 pval4, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Table: Impacts on Operations and HR Practices") addnotes("""") ;
#delimit cr

**************************************************************************
****** Appendix Table 5.6: Internal Consistency Check ********************
**************************************************************************
**** Do insourced and outsourced firms that got marketing improve marketing more, and those with accountants 
**** improve accounting more? *********************************************************************************

eststo clear
local i=1
*** Round 1 Effects
foreach var of varlist financeindex marketingindex digmarketingindex {
areg `var' gotmarketing gotaccounting b_`var' b_`var'_miss if surveyround==1 & training==0 & consulting==0, r a(batchno)
test gotmarketing==gotaccounting
estadd scalar pval1=r(p)
sum `var' if e(sample) & ftreat==4
estadd scalar mean=r(mean)
eststo tableA5_6a_`i'
*** Round 2 Effects
areg `var' gotmarketing gotaccounting b_`var' b_`var'_miss if surveyround==2 & training==0 & consulting==0, r a(batchno)
test gotmarketing==gotaccounting
estadd scalar pval1=r(p)
sum `var' if e(sample) & ftreat==4
estadd scalar mean=r(mean)
eststo tableA5_6b_`i'
local i=`i'+1
}
#delimit ;
esttab tableA5_6a_* tableA5_6b_*  using "$tables/TableA5_6.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "P-value")) 
	title("Appendix Table 5.6: Internal Consistency Check") addnotes("""") ;
#delimit cr

*****************************************************************************************
****** Appendix 6.1: Firm Performance Impacts Conditional on Survival *******************
*****************************************************************************************
eststo clear
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7 {
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==1 & survival==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5a_`i'
areg real`var' insourcing outsourcing training consulting b_`var' b_`var'_miss if surveyround==2 & survival==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5b_`i'
local i=`i'+1
}
#delimit ;
esttab table5a_*  using "$tables/TableA6_1.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "P-value" "P-value")) 
	posthead(Panel A: Impacts in First Follow-up Survey)
	title("Appendix Table 6.1: Impact on Firm Growth Conditional on Survival") addnotes("""") ;
#delimit cr
#delimit ;
esttab  table5b_*  using "$tables/TableA6_1.csv", append depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "P-value" "P-value")) 
	posthead(Panel B: Impacts in Second Follow-up Survey) ;
#delimit cr

**********************************************************************************************
******* Appendix Table 6.2: Using PDS Lasso to attempt to improve power **********************
**********************************************************************************************
* Note: Paper only reports round 2, notes round 1 few changes ********************************
eststo clear
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7  {
xtset batchno
* Round 1
pdslasso real`var' insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob b_`var' b_`var'_miss)  if surveyround==1, fe  partial(b_`var' b_`var'_miss)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5pds1_`i'
* Round 2
pdslasso real`var' insourcing outsourcing training consulting (b_salesmonthUSD b_salesbestmonthUSD b_salesbestmonthUSD_miss b_worstmonthsalesUSD b_worstmonthsalesUSD_miss pdsaveragemonth b_fulltimeemp ///
b_finance b_marketing b_hr b_score_10  ///
b_useaccountingmarket b_usemarketingmarket b_usehrconsultant  ///
b_construction b_ICT b_entertainment b_hospitality b_manufacturing b_inLagos b_firmage b_registeredCAC b_samestatesales ///
pdsfemale b_ageyear b_married b_undergrad b_mastersplus b_salariedjob b_`var' b_`var'_miss)  if surveyround==2, fe  partial(b_`var' b_`var'_miss)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo table5pds2_`i'
local i=`i'+1
}

#delimit ;
esttab table5pds2_* using "$tables/TableA6_2.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps 
	stats(mean N pval1 pval2 pval3 pval4 pval5, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Insourcing" "Outsourcing" "Training" "Consulting" "Jointly Zero")) 
	title("Appendix Table 6.2: Robustness of Firm Growth Results to Using PDS Lasso") addnotes("""") ;
#delimit cr
 
**********************************************************************
***** Appendix Table 6.3: Pooling Sales and Profits ******************
**********************************************************************
eststo clear
local i=1
foreach var of varlist invsales invsalesyr invprofits invprofitsyr salesprofindex emp_7 inv_emp_7 {
areg real`var' insourcing outsourcing training consulting  round2 b_`var' b_`var'_miss, r a(batchno) cluster(entrep_id)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum real`var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA_`i'
local i=`i'+1
}

#delimit ;
esttab tableA_*  using "$tables/TableA6_3.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3 pval4 pval5, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Insourcing" "Outsourcing" "Training" "Consulting" "Jointly Zero")) 
	title("Appendix Table 6.3: Pooled Impacts on Firm Growth") addnotes("""") ;
#delimit cr

* last two columns: use recall of additional 3 months profits and additional 6 months sales, asked in round 2
preserve
keep if surveyround==2
for num 1/6: gen realsalemonth_X=salemonth_X*cpimonth_X*1000
for num 4/6: gen realprofmonth_X=profmonth_X*cpimonth_X

foreach var of varlist salemonth_6 salemonth_5 salemonth_4 salemonth_3 salemonth_2 salemonth_1 profmonth_6 profmonth_5 profmonth_4  {
gen realinv`var'=ln(real`var'+(((real`var'^2)+1)^(1/2)))
}

gen invprofmonth_7=invprofits
gen invsalemonth_7=invsales
gen realinvprofmonth_7=realinvprofits
gen realinvsalemonth_7=realinvsales

cap drop round
reshape long invprofmonth_ invsalemonth_  realinvprofmonth_ realinvsalemonth_ ,  i(entrep_id) j(round)
for num 1/7: gen roundX=round==X
eststo clear
areg realinvprofmonth_ insourcing outsourcing training consulting b_invprofits b_invprofits_miss round5 round6 round7, r a(batchno) cluster(entrep_id)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realinvprofmonth_ if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableP_1
areg realinvsalemonth_ insourcing outsourcing training consulting b_invsales b_invsales_miss round2 round3 round4 round5 round6 round7, r a(batchno) cluster(entrep_id)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realinvsalemonth_ if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableP_2

#delimit ;
esttab tableP_*  using "$tables/TableA6_3PartB.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Panel Impacts on Long-Term Outcomes - Sales and Profits") addnotes("""") ;
#delimit cr

restore

************************************************************************
****** Appendix Table 6.4: Other Sales and Profits Measures ************
************************************************************************ 
* pre-specified robustness checks in levels
replace realsales=realsales/1000
replace realprofits=realprofits/1000

eststo clear
* Impact on Reporting Errors
areg totalerrors insourcing outsourcing training consulting if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum totalerrors if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_1
areg totalerrors insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum totalerrors if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_2
* Impact on Levels of Sales in round 1 and 2
areg realsales insourcing outsourcing training consulting b_sales b_sales_miss if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realsales if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_3
areg realsales insourcing outsourcing training consulting b_sales b_sales_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realsales if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_4
* Impact on Levels of Profits in round 1 and 2
areg realprofits insourcing outsourcing training consulting b_profits b_profits_miss if surveyround==1, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realprofits if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_5
areg realprofits insourcing outsourcing training consulting b_profits b_profits_miss if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum realprofits if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableA6_4_6

#delimit ;
esttab tableA6_4_*  using "$tables/TableA6_4.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2" "Pval3")) 
	title("Appendix Table 6.4: Impacts on Other Sales and Profits Measures") addnotes("""") ;
#delimit cr

* Version with rounded values
#delimit ;
esttab tableA6_4_*  using "$tables/TableA6_4rounded.csv", replace depvar legend label nonumbers
	b(%9.0f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons b_*)
	stats(mean N pval1 pval2 pval3, fmt(%9.0f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2" "Pval3")) 
	title("Appendix Table 6.4: Impacts on Other Sales and Profits Measures") addnotes("""") ;
#delimit cr

**********************************************************************************
*** Appendix Table 7.1: Innovation Index Components ******************************
**********************************************************************************
eststo clear
local i=1
foreach var of varlist innovation1-innovation17 {
areg `var' insourcing outsourcing training consulting if surveyround==2, r a(batchno)
test insourcing==outsourcing==training==consulting==0
estadd scalar pval1= r(p)
test insourcing==outsourcing==training==consulting
estadd scalar pval2= r(p)
sum `var' if ftreat==4 & e(sample) 
estadd scalar mean=r(mean)
eststo tableIn_`i'
local i=`i'+1
}

#delimit ;
esttab tableIn_* using "$tables/TableA7_1.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons)
	stats(mean N pval1 pval2, fmt(%9.3f %9.0g %9.3f %9.3f %9.3f) labels("Mean of Control Group" "Sample Size" "Pval1" "Pval2")) 
	title("Appendix Table 7.1: Impacts on Innovation Components") addnotes("""") ;
#delimit cr



*************************************************************************************************************************
**** Young (2019) test of overall significance mentioned in text in Section 3.4 *****************************************
*************************************************************************************************************************

*** Young Omnibus Tests of No Overall Treatment Effect on Tables 4 and 5
* Combining Tables 4 and 5 for round 1
#delimit ;
randcmd ((insourcing outsourcing training consulting) areg financeindex insourcing outsourcing training consulting b_financeindex b_financeindex_miss if surveyround==1, r a(batchno)) ((insourcing outsourcing training consulting) areg  marketingindex insourcing outsourcing training consulting b_marketingindex b_marketingindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg digmarketingindex insourcing outsourcing training consulting b_digmarketingindex b_digmarketingindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg opHRindex insourcing outsourcing training consulting b_opHRindex b_opHRindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg overallBPindex insourcing outsourcing training consulting b_overallBPindex b_overallBPindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg verifyBPindex insourcing outsourcing training consulting b_verifyBPindex b_verifyBPindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg realinvsales insourcing outsourcing training consulting b_invsales b_invsales_miss if surveyround==1, r a(batchno)) ((insourcing outsourcing training consulting) areg realinvsalesyr insourcing outsourcing training consulting b_invsalesyr b_invsalesyr_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg realinvprofits insourcing outsourcing training consulting b_invprofits b_invprofits_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg realinvprofitsyr insourcing outsourcing training consulting b_invprofitsyr b_invprofitsyr_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg salesprofindex insourcing outsourcing training consulting b_salesprofindex b_salesprofindex_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg emp_7 insourcing outsourcing training consulting b_emp_7 b_emp_7_miss if surveyround==1, r a(batchno))
((insourcing outsourcing training consulting) areg inv_emp_7 insourcing outsourcing training consulting b_inv_emp_7 b_inv_emp_7_miss if surveyround==1, r a(batchno))
, strata(batchno) sample treatvars(insourcing outsourcing training consulting) seed(123) reps(2000);

* Combining Tables 4 and 5 for round 2
#delimit ;
randcmd  ((insourcing outsourcing training consulting) areg financeindex insourcing outsourcing training consulting b_financeindex b_financeindex_miss if surveyround==2, r a(batchno)) ((insourcing outsourcing training consulting) areg  marketingindex insourcing outsourcing training consulting b_marketingindex b_marketingindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg digmarketingindex insourcing outsourcing training consulting b_digmarketingindex b_digmarketingindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg opHRindex insourcing outsourcing training consulting b_opHRindex b_opHRindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg overallBPindex insourcing outsourcing training consulting b_overallBPindex b_overallBPindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg verifyBPindex insourcing outsourcing training consulting b_verifyBPindex b_verifyBPindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg realinvsales insourcing outsourcing training consulting b_invsales b_invsales_miss if surveyround==2, r a(batchno)) ((insourcing outsourcing training consulting) areg realinvsalesyr insourcing outsourcing training consulting b_invsalesyr b_invsalesyr_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg realinvprofits insourcing outsourcing training consulting b_invprofits b_invprofits_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg realinvprofitsyr insourcing outsourcing training consulting b_invprofitsyr b_invprofitsyr_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg salesprofindex insourcing outsourcing training consulting b_salesprofindex b_salesprofindex_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg emp_7 insourcing outsourcing training consulting b_emp_7 b_emp_7_miss if surveyround==2, r a(batchno))
((insourcing outsourcing training consulting) areg inv_emp_7 insourcing outsourcing training consulting b_inv_emp_7 b_inv_emp_7_miss if surveyround==2, r a(batchno))
, strata(batchno) sample treatvars(insourcing outsourcing training consulting) seed(123) reps(2000);



***************************************************************************************************************
**** Other Appendix Tables and Figure *************************************************************************
***************************************************************************************************************

*****************************************************************************************************************
**** Table A2.1: Take-up and Usage of Business Training *********************************************************
*****************************************************************************************************************
use "$constructdata/TableA2_1data.dta", clear

mat y = J(11,2,.)
local j=1
foreach var of varlist OnlineComponentFM  OnlineComponentGO OnlineComponentBP OnlineComponentMM  OnlineComponentHR  OnlineComponentEG  OnlineComponentPP   OnlineComponentTH anyOnline numberOnline Completed5OnlineCourses   {
sum y_`var' 
mat y[`j',1]=r(mean)	
local j=`j'+1
}
local k=1
foreach var of varlist  FMAttendanceforcoursescore  AttendanceforcoursescoreGO AttendanceforcoursescoreBP MMAttendanceforcoursescore  HRMAttendanceforcoursescore AttendanceforcoursescoreEG  AttendanceforcoursescorePP  THMAttendanceforcoursescore anyInperson numberInperson Completed12DayInClass  {	
sum y_`var' 
mat y[`k',2]=r(mean)	
local k=`k'+1
}	

mat rownames y = "Financial Management" "General Operations" "Business Plan" "Marketing Management" "Human Resources" "Enterprise Governance" "Personal Productivity" "Tourism/Hospitality" "Any Course" "Number of Courses" "Completed Requirements"
mat colnames y = "Online Courses" "In-person Courses"
mat2txt, matrix(y) format(%9.2f) saving("$tables/tablea2_1.xls") replace

*******************************************************************************************************************
*** Table A2.2: Main Activities done in BDS ***********************************************************************
*******************************************************************************************************************
use "$constructdata/TableA2_2data.dta", clear
collapse (count) counter (max) typeF typeH typeM typeO typeS, by(Firmtasksname)
gen category="Management" if typeM==1
replace category="Sales & Marketing" if typeS==1
replace category="Operations" if typeO==1
replace category="Human Resources" if typeH==1
replace category="Finance" if typeF==1
gen proportionfirms=counter/118
gen negcounter=-1*counter
sort negcounter, stable
export excel Firmtasksname proportionfirms category using "$tables/tablea2_2.xls", firstrow(variables) keepcellfmt  replace

*********************************************************************************************************************
*** Figure A7.1: Consistency of Social Media Scores across Reviewers ************************************************
*********************************************************************************************************************
use "$rawdata/SocialMediaRatings.dta", clear

* Generate Total Scores
egen totalSMscore=rsum(SM1-SM50)
replace totalSMscore=totalSMscore/50

* generate scores for the two reviewers
egen reviewer1=min(reviewerID), by(entrep_id)
egen reviewer2=max(reviewerID), by(entrep_id)
gen tscore1=totalSMscore if reviewerID==reviewer1
gen tscore2=totalSMscore if reviewerID==reviewer2
egen mtscore1=max(tscore1), by(entrep_id)
egen mtscore2=max(tscore2), by(entrep_id)
corr mtscore1 mtscore2 if reviewerID==reviewer1 & dupid==1

label var mtscore1 "First Reviewer Score"
label var mtscore2 "Second Reviewer Score"
twoway (scatter mtscore1 mtscore2 if dupid==1) (line mtscore2 mtscore2 if dupid==1, title("Total Social Media Score") subtitle("Correlation=0.94") scheme(s1mono) ytitle("First Reviewer Score") graphregion(color(white)) legend(off) saving("$figures/FigA7_1.gph", replace)) 
graph export "$figures/FigureA7_1.png", replace

*************************************************************************************************************************
*** Table A8.1: Comparison of GEM and non-GEM Business Service Providers ************************************************
*************************************************************************************************************************
use "$constructdata/TableA8_1data.dta", clear

mat y = J(23,11,.)
local j=1
foreach var of varlist firmage soleprop partnership company multiplebranches  totalemployment sharedegrees numberskillcertified  annualsales numberofcustomersinmonth percentmicro percentsmall percentmed percentlarge  nservices dayrate contractdays minemp minsales moneybackguarantee wordofmouth excesscapacity {
* Column 1: GEM Providers
sum `var' if GEM==1
mat y[`j',1]=r(mean)
* Column 2: non-GEM Providers
sum `var' if GEM==0
mat y[`j',2]=r(mean)
* Column 3: p-value
ttest `var', by(GEM)
mat y[`j',3]=r(p)
* Accountants
* Column 3: GEM
sum `var' if ServiceProviderType==1 & GEM==1
mat y[`j',4]=r(mean)
* Column 4: non-GEM
sum `var' if ServiceProviderType==1 & GEM==0
mat y[`j',5]=r(mean)
* Marketers
* Column 5: GEM
sum `var' if ServiceProviderType==2 & GEM==1
mat y[`j',6]=r(mean)
* Column 6: non-GEM
sum `var' if ServiceProviderType==2 & GEM==0
mat y[`j',7]=r(mean)
* HR Providers
* Column 7: GEM
sum `var' if ServiceProviderType==3 & GEM==1
mat y[`j',8]=r(mean)
* Column 8: non-GEM
sum `var' if ServiceProviderType==3 & GEM==0
mat y[`j',9]=r(mean)
* Consultants
* Column 9: GEM
sum `var' if ServiceProviderType==4 & GEM==1
mat y[`j',10]=r(mean)
* Column 10: non-GEM
sum `var' if ServiceProviderType==4 & GEM==0
mat y[`j',11]=r(mean)
local j=`j'+1
}

* Last row is sample sizes
count if GEM==1
mat y[23, 1] = r(N)
count if GEM==0
mat y[23, 2] = r(N)
count if GEM==1 & ServiceProviderType==1
mat y[23, 4] = r(N)
count if GEM==0 & ServiceProviderType==1
mat y[23, 5] = r(N)
count if GEM==1 & ServiceProviderType==2
mat y[23, 6] = r(N)
count if GEM==0 & ServiceProviderType==2
mat y[23, 7] = r(N)
count if GEM==1 & ServiceProviderType==3
mat y[23, 8] = r(N)
count if GEM==0 & ServiceProviderType==3
mat y[23, 9] = r(N)
count if GEM==1 & ServiceProviderType==4
mat y[23, 10] = r(N)
count if GEM==0 & ServiceProviderType==4
mat y[23, 11] = r(N)
mat rownames y =  firmage soleprop partnership company multiplebranches  totalemployment sharedegrees numberskillcertified  annualsales numberofcustomersinmonth percentmicro percentsmall percentmed percentlarge  nservices dayrate contractdays minemp minsales moneybackguarantee wordofmouthexcesscapacity 
mat colnames y = "GEM" "non-GEM" "p-value" "Accounting-GEM" "Accounting-non-GEM" "Marketing-GEM" "Marketing non-GEM" "HR-GEM" "HR-non-GEM" "Consulting-GEM" "Consulting-non-GEM"
mat2txt, matrix(y) format(%9.2f %9.2f %9.3f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) saving("$tables/TableA8_1.xls") replace




