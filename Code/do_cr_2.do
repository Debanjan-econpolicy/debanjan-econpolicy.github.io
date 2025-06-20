clear all

* In your profile.do or a set_environment.do file
global MGP_root "V:\Projects\MGP\Analysis"										///Change only this path and follow this folder structure
global code "${MGP_root}/Code"
global raw "${MGP_root}/Data/raw" 
global derived "${MGP_root}/Data/derived"
global tables "${MGP_root}/Tables"

* Set $root
return clear
if ("${MGP_root}"=="") do `"`c(sysdir_personal)'profile.do"'
* Document data sources
local date_run = c(current_date)
local time_run = c(current_time)
display "Data cleaning script run on `date_run' at `time_run'"


/*==============================================================================
							Variable Creation File
===============================================================================*/
**cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis"
use "$raw\MGP Final.dta", clear 										
la var key "key"
gen submission_date = dofc(submissiondate)
format submission_date %td
la var submission_date "Submission Date"


// Merge with enterprise sample list, Prepare for merge by renaming ID variable
rename entrepreneur_name enterprise_id

**merge m:1 enterprise_id using "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\admin data\Sampling\Enterprise Sample List Detail.dta", gen(admin_merge)
merge m:1 enterprise_id using "$raw\Enterprise Sample List Detail.dta", gen(admin_merge) 
la var admin_merge "Merge result with enterprise sample list"
keep if admin_merge == 3

order key District DistrictCode BlockCode Block  PanchayatCode PanchayatCode enterprise_id ent_des supervisor_id enum_id sec1_q7 sec1_q9 submission_date
duplicates tag enterprise_id, gen(ent_dup)
la var ent_dup "Duplicate enterprise indicator (1=duplicate)"

/* 8 Enterprise are having duplicates 

+-------------------------+
  | Group    Obs   enterp~d |
  |-------------------------|
  |     1    128      e_117 |
  |     1    129      e_117 |
  |     2    480     e_1635 |
  |     2    481     e_1635 |
  |     3   1333     e_3058 |
  |-------------------------|
  |     3   1334     e_3058 |
  |     4   2055     e_4651 |
  |     4   2056     e_4651 |
  |     5   2246     e_5094 |
  |     5   2247     e_5094 |
  |-------------------------|
  |     6   2348     e_5347 |
  |     6   2349     e_5347 |
  |     7   2731     e_6285 |
  |     7   2732     e_6285 |
  |     8   2951      e_928 |
  |-------------------------|
  |     8   2952      e_928 |
  +-------------------------+


 tab ent_dup

    ent_dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,984       99.47       99.47
          1 |         16        0.53      100.00
------------+-----------------------------------
      Total |      3,000      100.00

*/
//Drop the invalid enterprises (We have dropped 8 enterprises). Now we have 2992 distinct enterprises. 
					
drop if inlist(key, "uuid:be7b0fd4-08d9-45c2-9bba-11e7a00dcbd0",				///
                    "uuid:afeaf708-c164-43f1-925f-7f8d895b02d5",				///
                    "uuid:1cf6b353-cd52-49a6-bb21-cbf7b0790f41",				///
                    "uuid:c9fb243b-7229-4f80-acdd-7ce9f6126942",				///
                    "uuid:edb70e30-bfa3-4ea6-ad3a-251f274628d5",				///
                    "uuid:3e548d36-c287-4f0d-9329-35574badd0d1",				///
                    "uuid:16e68c35-6c16-4a86-832c-73ec5956bc50",				///
                    "uuid:baf6c7f9-9a9f-4d9f-a039-493cd87ab298")					

**merge 1:1 enterprise_id using "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\admin data\Sampling\MGP_sample_final.dta", keepusing(Religion Electricity Water B2C B2B Riskmitigationplan Category_of_enterprise TypeofDwelling pscore_lasso ipw _est_logit_lasso_1 _pscore _treated _support _weight _n1 _nn _pdif matched cohort_new Disbursement_Amount) gen(psm_merge)

merge 1:1 enterprise_id using "$raw\MGP_sample_final.dta", keepusing(Religion Electricity Water B2C B2B Riskmitigationplan Category_of_enterprise TypeofDwelling pscore_lasso ipw _est_logit_lasso_1 _pscore _treated _support _weight _n1 _nn _pdif matched app_sub_date quarterly_submission_date disbursement_date quarterly_disbursement_date cohort_new Disbursement_Amount CIBILscore age_entrepreneur Gender CIBILscore ECP_Score HighestEducation Religion Community MaritalStatus NumberofHouseholdmembers  HouseholdIncome HouseholdConsumption HouseholdSavings OwnRentedHouse TypeofDwelling CAPBeneficiary OtherSourceofincome Typeofownership Existingbusiness ActualWorkingCapital TotalFixedCost RequestedLoanAmount Category_of_enterprise Vehicle Householdassets Jewels Cashatbank Cashathand ent_asset_index Water Equipmentavailability Skilledlaboravailability B2C B2B Riskmitigationplan  LoanCategory CurrentSupplyAnnual PresentDemandAnnual rejection_reasons_encode) gen(psm_merge)

keep if (psm_merge==3)

/*==============================================================================
							Business Running Insights
==============================================================================*/
fre sec1_q9
/*
sec1_q9 -- Is this enterprise still running?
--------------------------------------------------------------------------
                             |      Freq.    Percent      Valid       Cum.
-----------------------------+--------------------------------------------
Valid   1 Yes, still running |       2375      79.38      79.75      79.75
        2 No, it is defunct  |        603      20.15      20.25     100.00
        Total                |       2978      99.53     100.00           
Missing .                    |         14       0.47                      
Total                        |       2992     100.00                      
--------------------------------------------------------------------------
*/
//2375 enterprises are running as of first wave survey, 14 values were missing because they have not provided the consent. 

gen ent_running = (sec1_q7 == 1 & sec1_q9 == 1)					///Total 2375 enterprisere are running this is out study sample as of this stage after first wave of the survey.
 				
la var ent_running "Business is running and owner provided consent (1=Yes)"

/*==============================================================================
							Business Operations Monthly Variables
==============================================================================*/

** operational_2022 operational_2023 operational_2024, Whether businesses is operational in 2022, 2023, 2024. It doesn't have any missing value if the business is running (sec1_q9 == 1) , becuase these three are the hook questions based on that we need to calculate Revenue, Cost, Profit etc. 


forval i = 2022/2024 {
	ds num_peak_months_`i' num_usual_months_`i' num_shutdown_months_`i' 
	la var num_peak_months_`i' "Number of peak months in `i'"
	la var num_usual_months_`i' "Number of usual months in `i'"
	la var num_shutdown_months_`i' "Number of shutdown months in `i'"
	destring (`r(varlist)') , replace
}



foreach year in 2022 2023 2024 {
    local q1_months "jan feb mar"
    local q2_months "apr may jun"  
    local q3_months "jul aug sep"
    local q4_months "oct nov dec"
    
    forvalues q = 1/4 {
        
        gen num_peak_months_`year'_q`q' = 0
        gen num_usual_months_`year'_q`q' = 0
        gen num_shutdown_months_`year'_q`q' = 0
        
        foreach month of local q`q'_months {
                replace num_peak_months_`year'_q`q' = num_peak_months_`year'_q`q' + (`month'_`year' == 1) if operational_`year' == 1
                replace num_usual_months_`year'_q`q' = num_usual_months_`year'_q`q' + (`month'_`year' == 2) if operational_`year' == 1
                replace num_shutdown_months_`year'_q`q' = num_shutdown_months_`year'_q`q' + (`month'_`year' == 3) if operational_`year' == 1
            }
        
        label var num_peak_months_`year'_q`q' "Number of peak months in Q`q' `year'"
        label var num_usual_months_`year'_q`q' "Number of usual months in Q`q' `year'"
        label var num_shutdown_months_`year'_q`q' "Number of shutdown months in Q`q' `year'"
    }
}



/*==============================================================================
								Enterprise Age 									
==============================================================================*/
gen e_age = (date("18apr2025", "DMY") - sec3_q1)/365.25
label var e_age "Age of the enterprise (years)"
format e_age %4.2f

/*==============================================================================
								Entrepreneur Age, from the MIS 									
==============================================================================*/

** First convert string date to STATA date format
gen dob = date(Dateofbirth, "YMD") 
format dob %td

** Calculate age of entrepreneur (as of April 18, 2025)
gen age_entrepreneur_s = (date("18apr2025", "DMY") - dob)/365.25
label var age_entrepreneur_s "Age of the entrepreneur (years)"
format age_entrepreneur %4.1f

/*==============================================================================
								Entrepreneur Marriage Age, from the MIS 									
==============================================================================*/
gen marital_status = inlist(sec4_q1, 2, 3, 4 ) if ent_running == 1
la var marital_status "1 = Married (Married, Widowed,  Divorced), 0 = Never married "

clonevar marriage_age = sec4_q1_a if ent_running == 1
sum sec4_q1_a if ent_running == 1, detail
//Replacing two extreme (-27, 220) values with Median 
replace marriage_age = r(p50) if marriage_age == -27 & marriage_age != .
replace marriage_age = r(p50) if marriage_age == 220 & marriage_age != .
la var marriage_age "Marriage age if ever married"

count if sec4_q1 == 1 & marriage_age != . & ent_running == 1  					//Checking that if unmarried respondents have married age. It is not


/*==============================================================================
					Gender of entrepreneur (create dummy variables)								
==============================================================================*/

gen female_owner = (sec2_q3a == 1) if ent_running == 1
gen male_owner = (sec2_q3a == 0) if ent_running == 1
gen other_gender = (sec2_q3a == 2) if ent_running == 1
label var female_owner "Female entrepreneur"
label var male_owner "Male entrepreneur"
label var other_gender "Other gender entrepreneur"
label define yesno 0 "No" 1 "Yes"
label values female_owner male_owner other_gender yesno

/*==============================================================================
								Enterprise characteristics
==============================================================================*/
tab sec2_q2 if ent_running == 1, gen(ent_nature_)
label var ent_nature_1 "Manufacturing enterprise"
label var ent_nature_2 "Trade/Retail/Sales enterprise"
label var ent_nature_3  "Service enterprise"
label values  ent_nature_1 ent_nature_2 ent_nature_3 yesno



/*==============================================================================
Education Years. Recoding the education variable as a continuous variable					
==============================================================================*/

gen education_yrs = sec4_q2
replace education_yrs = 0 if inlist(sec4_q2,17,18) & !missing(sec4_q2)
replace education_yrs = 17 if inlist(sec4_q2,14,15) & !missing(sec4_q2)
replace education_yrs = 15 if sec4_q2==13 & !missing(sec4_q2)
replace education_yrs = 12 if inlist(sec4_q2,12,20) & !missing(sec4_q2)
replace education_yrs = 11 if sec4_q2==11 & !missing(sec4_q2)
replace education_yrs = 10 if sec4_q2==10 & !missing(sec4_q2)
replace education_yrs = 9  if sec4_q2==9 & !missing(sec4_q2)
replace education_yrs = 8  if sec4_q2==8 & !missing(sec4_q2)
replace education_yrs = 7  if sec4_q2==7 & !missing(sec4_q2)
replace education_yrs = 6  if sec4_q2==6 & !missing(sec4_q2)
replace education_yrs = 5  if sec4_q2==5 & !missing(sec4_q2)
replace education_yrs = 4  if sec4_q2==4 & !missing(sec4_q2)
replace education_yrs = 3  if sec4_q2==3 & !missing(sec4_q2)
replace education_yrs = 2  if sec4_q2==2 & !missing(sec4_q2)
replace education_yrs = 1  if sec4_q2==1 & !missing(sec4_q2)
lab var education_yrs "Years of education of the enterprise owner"


/*==============================================================================
			Registation status: sec3_q2 sec3_q2_1 sec3_q2_a
==============================================================================*/
gen registered = (sec3_q2 == 1) if !missing(sec3_q2)
label var registered "Enterprise is formally registered"
label values registered yesno


gen udyam_registration = sec3_q2_1 if !missing(sec3_q2_1)
la var udyam_registration "Whether enterprise is registered with Udyam Aadhar?"


** Type of registration (among registered businesses)
gen sole_prop = (sec3_q2_a == 1) if registered == 1
gen partnership = (sec3_q2_a == 2) if registered == 1
label var sole_prop "Sole proprietorship"
label var partnership "Partnership"
label values sole_prop partnership  yesno


//All of the avobe created variables are skewed. Maybe we don't need to use them. 



/*==============================================================================
						SHG Status, SHG participation 
==============================================================================*/
gen shg = (sec3_q6 == 1|sec3_q6 == 2) if ent_running == 1
la var shg "1 = Either SHG member or SHG HH, 0 = Non-SHG"
label values shg yesno


/*==============================================================================
						Enterprise operation
==============================================================================*/

clonevar business_operation_current = sec3_q4
replace business_operation_current = 4 if inlist(sec3_q4_oth, "Working on twovellar", "Using commercial van", "Auto", "Vending door by door", "Market like sandhai", "Auto rickshaw", "Noshoo" )

* For the remaining "Others (specify)" entries, let's recode them appropriately
* For agricultural settings, recode to Home/Home front (1)
replace business_operation_current = 1 if business_operation_current == 88 & inlist(sec3_q4_oth, "Thottam", "Integrated farm", "Agriculture", "Agriculture Land")

* For "No shop" entries, recode to Home/Home front (1)
replace business_operation_current = 1 if business_operation_current == 88 & inlist(sec3_q4_oth, "No shop", "Noshoo", "No", "No shoo")

* For construction sites, recode to Home/Home front (1) or create a new category
replace business_operation_current = 1 if business_operation_current == 88 & inlist(sec3_q4_oth, "Site", "Centring works")

* For other miscellaneous entries like "Leeds", recode to Home/Home front (1)
replace business_operation_current = 1 if business_operation_current == 88 & sec3_q4_oth == "Leeds"

* Verify that all "Others (specify)" have been recoded
count if business_operation_current == 88


//From where they have startd the buisness (sec3_q4_1) business_operation_start
clonevar business_operation_start = sec3_q4_1
replace business_operation_start = 1 if business_operation_start == 88 & inlist(sec3_q4_1_oth, "No shop", "No use", "2021", "No work", "Market like sandhai", "Thottam", "Leeds", "no use" , "no")

replace business_operation_start = 1 if business_operation_start == 88 & inlist(sec3_q4_1_oth, "No", "Noshop", "Agriculture", "Agriculture Land", "Integrated farm" )
count if business_operation_start == 88


gen business_ops_change = 1 if (business_operation_current != business_operation_start) 
la var business_ops_change "Business operation location change (1 = Yes)"

/*==============================================================================
						Enterprise location characteristics
==============================================================================*/
tab sec3_q5, gen(ent_location_)

label var ent_location_1 "Located in main marketplace"
label var ent_location_2 "Located in secondary marketplace"
label var ent_location_3 "Located on street with other businesses"
label var ent_location_4 "Located in residential area"
label values ent_location_1 ent_location_2 ent_location_3 ent_location_4 yesno







/*==============================================================================
                    Digit-Span Recall Test Variables               
==============================================================================*/

** This variable indicates the maximum number of digits correctly recalled

gen digit_span = 3 if sec12_q1 == 0 & !missing(sec12_q1)  // Failed at 4 digits
replace digit_span = 4 if sec12_q1 == 1 & sec12_q2 == 0 & !missing(sec12_q2)  // Passed 4, failed 5
replace digit_span = 5 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 0 & !missing(sec12_q3)  // Passed 5, failed 6
replace digit_span = 6 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 0 & !missing(sec12_q4)  // Passed 6, failed 7
replace digit_span = 7 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 0 & !missing(sec12_q5)  // Passed 7, failed 8
replace digit_span = 8 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 0 & !missing(sec12_q6)  // Passed 8, failed 9
replace digit_span = 9 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 0 & !missing(sec12_q7)  // Passed 9, failed 10
replace digit_span = 10 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 1 & sec12_q8 == 0 & !missing(sec12_q8)  // Passed 10, failed 11
replace digit_span = 11 if sec12_q1 == 1 & sec12_q2 == 1 & sec12_q3 == 1 & sec12_q4 == 1 & sec12_q5 == 1 & sec12_q6 == 1 & sec12_q7 == 1 & sec12_q8 == 1 & !missing(sec12_q8)  // Passed all 11

label var digit_span "Digit Span recall Maximum"

egen std_digit_span = std(digit_span)
label var std_digit_span "Standardized digit span score"


/*==============================================================================
                Business Risk Tolerance Index (BRTI)              
==============================================================================*/

gen risk_choice1 = (sec13_q1 == 1) if !missing(sec13_q1)
gen risk_choice2 = (sec13_q2 == 1) if !missing(sec13_q2)
gen risk_choice3 = (sec13_q3 == 1) if !missing(sec13_q3)
gen risk_choice4 = (sec13_q4 == 1) if !missing(sec13_q4)
gen risk_choice5 = (sec13_q5 == 1) if !missing(sec13_q5)

label var risk_choice1 "Chose risky option: new product (40% +80%, 60% -20%)"
label var risk_choice2 "Chose risky option: new technology (30% +100%, 70% 0%)"
label var risk_choice3 "Chose risky option: market expansion (50% +100%, 50% 0%)"
label var risk_choice4 "Chose risky option: loan (60% +70%, 40% strain)"
label var risk_choice5 "Chose risky option: new supplier (70% profit, 30% loss)"

alpha risk_choice1 risk_choice2 risk_choice3 risk_choice4 risk_choice5

pca risk_choice1 risk_choice2 risk_choice3 risk_choice4 risk_choice5
predict brti_pca
label var brti_pca "Business Risk Tolerance Index (PCA)"


egen risk_count = rowtotal(risk_choice1 risk_choice2 risk_choice3 risk_choice4 risk_choice5), missing
gen brti_count = risk_count / 5
label var brti_count "Business Risk Tolerance Index (count-based)"


tabstat  brti_count brti_pca, statistics(n mean sd min p25 p50 p75 max) columns(statistics)




/*==============================================================================
							Innovation                             
==============================================================================*/

* Create individual innovation indicator variables
gen product_innovation = (sec11_q1 == 1) if !missing(sec11_q1)
label var product_innovation "Introduced new/improved products or services"

gen technology_innovation = (sec11_q6 == 1) if !missing(sec11_q6)
label var technology_innovation "Introduced new/improved technology"

gen process_innovation = (sec11_q10 == 1) if !missing(sec11_q10)
label var process_innovation "Introduced new/improved logistics/delivery methods"

gen marketing_innovation = (sec11_q14 == 1) if !missing(sec11_q14)
label var marketing_innovation "Introduced new/improved marketing methods"

gen has_website = (sec11_q18 == 1) if !missing(sec11_q19)
label var has_website "Business has Website"

gen has_email = (sec11_q19 == 1) if !missing(sec11_q19)
label var has_email "Business has email"



gen any_innovation = 0 if ent_running == 1
foreach var in product_innovation technology_innovation process_innovation marketing_innovation has_website has_email {
	replace any_innovation = 1 if `var' == 1
}
label var any_innovation "Any innovation introduced (Jan 2024-Feb 2025)"

ds product_innovation technology_innovation process_innovation marketing_innovation has_website has_email
egen tot_innovation = rowtotal(`r(varlist)') if ent_running == 1   				//total number of innovation variables that were introduced by the enterprise
label var tot_innovation "Total number of innovation types introduced (0-6)"


foreach var of varlist sec11_q5 sec11_q9 sec11_q13 sec11_q17 {
    replace `var' = 0 if missing(`var') & ent_running == 1
}

egen total_innov_invest = rowtotal(sec11_q5 sec11_q9 sec11_q13 sec11_q17), missing
label var total_innov_invest "Total investment in innovations (Rs.)"

winsor2 total_innov_invest, cuts(1 99) suffix(_w1)								///total_innov_invest_w1

egen innovation_score = rmean(sec11_q1 sec11_q6 sec11_q10 sec11_q14 sec11_q18 sec11_q19)
label var innovation_score "Average of innovation indicators (proportion)"




/*==============================================================================
								Investment                             
==============================================================================*/

/*
The investment data has the following structure:
- sec5_q1: Whether invested in 2024 (Yes/No)
- sec5_q2: Type of investment in 2024 (Working capital/Asset creation/Debt reduction/New enterprise)
- sec5_q3: Amount invested in each type in 2024
- sec5_q4: Source of investment in 2024
- sec5_q5: Mode of investment in 2024

- sec5_q6: Whether invested in 2023 (Yes/No)
- sec5_q7: Type of investment in 2023
- sec5_q8: Amount invested in each type in 2023
- sec5_q9: Source of investment in 2023
- sec5_q10: Mode of investment in 2023

- sec5_q11: Whether invested in 2022 (Yes/No)
- sec5_q12: Type of investment in 2022
- sec5_q13: Amount invested in each type in 2022
- sec5_q14: Source of investment in 2022
- sec5_q15: Mode of investment in 2022
*/


** 1. Basic Investment Indicators by Year

** Investment in 2024 (Yes/No)
gen invested_2024 = (sec5_q1 == 1) if !missing(sec5_q1)
label var invested_2024 "Made any investment in 2024"
label values invested_2024 yesno

** Investment in 2023 (Yes/No) - Year MGP started
gen invested_2023 = (sec5_q6 == 1) if !missing(sec5_q6)
label var invested_2023 "Made any investment in 2023 (MGP started)"
label values invested_2023 yesno

** Investment in 2022 (Yes/No) - Pre-MGP period
gen invested_2022 = (sec5_q11 == 1) if !missing(sec5_q11)
label var invested_2022 "Made any investment in 2022 (pre-MGP)"
label values invested_2022 yesno

** Investment in any year
gen ever_invested = (invested_2022 == 1 | invested_2023 == 1 | invested_2024 == 1) ///
    if !missing(invested_2022) | !missing(invested_2023) | !missing(invested_2024)
label var ever_invested "Made investment in any year (2022-2024)"
label values ever_invested yesno



** 2. Investment Amounts by Year

** Total investment amount in 2024
gen total_invest_2024 = 0 if invested_2024 == 1
forvalues i = 1/10 {
    capture confirm variable sec5_q3_`i'
    if !_rc {
        replace total_invest_2024 = total_invest_2024 + sec5_q3_`i' if !missing(sec5_q3_`i')
    }
}
label var total_invest_2024 "Total amount invested in 2024 (Rs.)"

** Total investment amount in 2023
gen total_invest_2023 = 0 if invested_2023 == 1
forvalues i = 1/10 {
    capture confirm variable sec5_q8_`i'
    if !_rc {
        replace total_invest_2023 = total_invest_2023 + sec5_q8_`i' if !missing(sec5_q8_`i')
    }
}
label var total_invest_2023 "Total amount invested in 2023 (MGP start year) (Rs.)"

** Total investment amount in 2022
gen total_invest_2022 = 0 if invested_2022 == 1
forvalues i = 1/10 {
    capture confirm variable sec5_q13_`i'
    if !_rc {
        replace total_invest_2022 = total_invest_2022 + sec5_q13_`i' if !missing(sec5_q13_`i')
    }
}
label var total_invest_2022 "Total amount invested in 2022 (pre-MGP) (Rs.)"

** 3. Winsorized Investment Amounts

foreach year in 2022 2023 2024 {
    gen w10_total_invest_`year' = total_invest_`year'
    qui sum total_invest_`year' if invested_`year' == 1, detail
    replace w10_total_invest_`year' = r(p10) if total_invest_`year' < r(p10) & !missing(total_invest_`year') & invested_`year' == 1
    replace w10_total_invest_`year' = r(p90) if total_invest_`year' > r(p90) & !missing(total_invest_`year') & invested_`year' == 1
    label var w10_total_invest_`year' "Winsorized (at 10%) investment amount in `year' (Rs.)"
}



** 4. Log Investment Variables
foreach year in 2022 2023 2024 {
    gen log_w10_total_invest_`year' = log(w10_total_invest_`year' + 1) if !missing(w10_total_invest_`year')
    label var log_w10_total_invest_`year' "Log of winsorized investment amount in `year' (Rs.)"
}


** 5. Count of investment types in 2024
gen count_invest_2024 = 0 if ent_running == 1
forvalues i = 1(1)4 {
    capture confirm variable sec5_q2_`i'
    if !_rc {
        replace count_invest_2024 = count_invest_2024 + 1 if sec5_q2_`i' == 1
		replace count_invest_2024 = 0 if invested_2024 == 0
    }
}
label var count_invest_2024 "Number of investment types in 2024"

** Count of investment types in 2023
gen count_invest_2023 = 0 if ent_running == 1
forvalues i = 1(1)4 {
    capture confirm variable sec5_q7_`i'
    if !_rc {
        replace count_invest_2023 = count_invest_2023 + 1 if sec5_q7_`i' == 1
		replace count_invest_2023 = 0 if invested_2023 == 0

    }
}
label var count_invest_2023 "Number of investment types in 2023"

** Count of investment types in 2022
gen count_invest_2022 = 0 if ent_running == 1
forvalues i = 1(1)4 {
    capture confirm variable sec5_q12_`i'
    if !_rc {
        replace count_invest_2022 = count_invest_2022 + 1 if sec5_q12_`i' == 1
		replace count_invest_2022 = 0 if invested_2022 == 0

    }
}
label var count_invest_2022 "Number of investment types in 2022"


** 6. Investment by Type

** Working capital investment dummy variables
gen wc_invest_2024 = 0 if invested_2024 == 1
forvalues i = 1/4 {
      replace wc_invest_2024 = 1 if sec5_q2_1 == 1 & !missing(sec5_q2_1)
    }

label var wc_invest_2024 "Invested in working capital in 2024"
label values wc_invest_2024 yesno

gen wc_invest_2023 = 0 if invested_2023 == 1
forvalues i = 1/4 {
        replace wc_invest_2023 = 1 if sec5_q7_1 == 1 & !missing(sec5_q7_1)
    }

label var wc_invest_2023 "Invested in working capital in 2023"
label values wc_invest_2023 yesno

gen wc_invest_2022 = 0 if invested_2022 == 1
forvalues i = 1/4 {
        replace wc_invest_2022 = 1 if sec5_q12_1 == 1 & !missing(sec5_q12_1)
    }
label var wc_invest_2022 "Invested in working capital in 2022"
label values wc_invest_2022 yesno

** Asset creation investment dummy variables
** Including "starting new enterprise" as asset creation
gen ac_invest_2024 = 0 if invested_2024 == 1
replace ac_invest_2024 = 1 if (sec5_q2_2 == 1 | sec5_q2_4 == 1) & invested_2024 == 1 & (!missing(sec5_q2_2) | !missing(sec5_q2_4))
label var ac_invest_2024 "Invested in asset creation (including new enterprise) in 2024"
label values ac_invest_2024 yesno

gen ac_invest_2023 = 0 if invested_2023 == 1
replace ac_invest_2023 = 1 if (sec5_q7_2 == 1 | sec5_q7_4 == 1) & invested_2023 == 1 & (!missing(sec5_q7_2) | !missing(sec5_q7_4))
label var ac_invest_2023 "Invested in asset creation (including new enterprise) in 2023"
label values ac_invest_2023 yesno

gen ac_invest_2022 = 0 if invested_2022 == 1
replace ac_invest_2022 = 1 if (sec5_q12_2 == 1 | sec5_q12_4 == 1) & invested_2022 == 1 & (!missing(sec5_q12_2) | !missing(sec5_q12_4))
label var ac_invest_2022 "Invested in asset creation (including new enterprise) in 2022"
label values ac_invest_2022 yesno

** Debt reduction investment dummy variables
gen dr_invest_2024 = 0 if invested_2024 == 1
replace dr_invest_2024 = 1 if sec5_q2_3 == 1 & invested_2024 == 1 & !missing(sec5_q2_3)
label var dr_invest_2024 "Invested in debt reduction in 2024"
label values dr_invest_2024 yesno

gen dr_invest_2023 = 0 if invested_2023 == 1
replace dr_invest_2023 = 1 if sec5_q7_3 == 1 & invested_2023 == 1 & !missing(sec5_q7_3)
label var dr_invest_2023 "Invested in debt reduction in 2023"
label values dr_invest_2023 yesno

gen dr_invest_2022 = 0 if invested_2022 == 1
replace dr_invest_2022 = 1 if sec5_q12_3 == 1 & invested_2022 == 1 & !missing(sec5_q12_3)
label var dr_invest_2022 "Invested in debt reduction in 2022"
label values dr_invest_2022 yesno

** Ever invested in working capital
gen ever_wc_invest = (wc_invest_2022 == 1 | wc_invest_2023 == 1 | wc_invest_2024 == 1) ///
    if !missing(wc_invest_2022) | !missing(wc_invest_2023) | !missing(wc_invest_2024)
label var ever_wc_invest "Ever invested in working capital (2022-2024)"
label values ever_wc_invest yesno

** Ever invested in asset creation
gen ever_ac_invest = (ac_invest_2022 == 1 | ac_invest_2023 == 1 | ac_invest_2024 == 1) ///
    if !missing(ac_invest_2022) | !missing(ac_invest_2023) | !missing(ac_invest_2024)
label var ever_ac_invest "Ever invested in asset creation (2022-2024)"
label values ever_ac_invest yesno

** Ever invested in debt reduction
gen ever_dr_invest = (dr_invest_2022 == 1 | dr_invest_2023 == 1 | dr_invest_2024 == 1) ///
    if !missing(dr_invest_2022) | !missing(dr_invest_2023) | !missing(dr_invest_2024)
label var ever_dr_invest "Ever invested in debt reduction (2022-2024)"
label values ever_dr_invest yesno



** Investment Amount Variables - Correct Mapping Based on Selection Order. 

** Working capital investment amounts - 2024
gen wc_amount_2024 = 0 if invested_2024 == 1

** Only working capital selected ("1")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1" & !missing(sec5_q3_1)

** Case 2: Working capital + asset creation ("1 2") 
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 2" & !missing(sec5_q3_1)

** Case 3: Working capital + debt reduction ("1 3")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 3" & !missing(sec5_q3_1)

** Case 4: Working capital + new enterprise ("1 4")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 4" & !missing(sec5_q3_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 2 3" & !missing(sec5_q3_1)

** Case 6: Working capital + asset creation + new enterprise ("1 2 4")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 2 4" & !missing(sec5_q3_1)

** Case 7: Working capital + debt reduction + new enterprise ("1 3 4")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 3 4" & !missing(sec5_q3_1)

** Case 8: All four types ("1 2 3 4")
replace wc_amount_2024 = sec5_q3_1 if sec5_q2 == "1 2 3 4" & !missing(sec5_q3_1)

label var wc_amount_2024 "Amount invested in working capital in 2024 (Rs.)"



** Asset creation investment amounts - 2024 (including new enterprise)
gen asset_amount_2024 = 0 if invested_2024 == 1

** Case 1: Only asset creation selected ("2")
capture replace asset_amount_2024 = sec5_q3_1 if sec5_q2 == "2" & !missing(sec5_q3_1)

** Case 2: Only new enterprise selected ("4") 
capture replace asset_amount_2024 = sec5_q3_1 if sec5_q2 == "4" & !missing(sec5_q3_1)

** Case 3: Working capital + asset creation ("1 2") - asset creation is 2nd
capture replace asset_amount_2024 = sec5_q3_2 if sec5_q2 == "1 2" & !missing(sec5_q3_2)

** Case 4: Working capital + new enterprise ("1 4") - new enterprise is 2nd
capture replace asset_amount_2024 = sec5_q3_2 if sec5_q2 == "1 4" & !missing(sec5_q3_2)

** Case 5: Asset creation + debt reduction ("2 3") - asset creation is 1st
capture replace asset_amount_2024 = sec5_q3_1 if sec5_q2 == "2 3" & !missing(sec5_q3_1)

** Case 6: Asset creation + new enterprise ("2 4") - asset creation is 1st, new enterprise is 2nd
capture replace asset_amount_2024 = sec5_q3_1 + sec5_q3_2 if sec5_q2 == "2 4" & !missing(sec5_q3_1) & !missing(sec5_q3_2)

** Case 7: Debt reduction + new enterprise ("3 4") - new enterprise is 2nd
capture replace asset_amount_2024 = sec5_q3_2 if sec5_q2 == "3 4" & !missing(sec5_q3_2)

** Case 8: Working capital + asset creation + debt reduction ("1 2 3") - asset creation is 2nd
capture replace asset_amount_2024 = sec5_q3_2 if sec5_q2 == "1 2 3" & !missing(sec5_q3_2)

** Case 9: Working capital + asset creation + new enterprise ("1 2 4") - asset creation is 2nd, new enterprise is 3rd
capture replace asset_amount_2024 = sec5_q3_2 + sec5_q3_3 if sec5_q2 == "1 2 4" & !missing(sec5_q3_2) & !missing(sec5_q3_3)

** Case 10: Working capital + debt reduction + new enterprise ("1 3 4") - new enterprise is 3rd
capture replace asset_amount_2024 = sec5_q3_3 if sec5_q2 == "1 3 4" & !missing(sec5_q3_3)

** Case 11: Asset creation + debt reduction + new enterprise ("2 3 4") - asset creation is 1st, new enterprise is 3rd
capture replace asset_amount_2024 = sec5_q3_1 + sec5_q3_3 if sec5_q2 == "2 3 4" & !missing(sec5_q3_1) & !missing(sec5_q3_3)

** Case 12: All four types ("1 2 3 4") - asset creation is 2nd, new enterprise is 4th
capture replace asset_amount_2024 = sec5_q3_2 + sec5_q3_4 if sec5_q2 == "1 2 3 4" & !missing(sec5_q3_2) & !missing(sec5_q3_4)

label var asset_amount_2024 "Amount invested in asset creation (including new enterprise) in 2024 (Rs.)"




** Debt reduction investment amounts - 2024
gen debt_amount_2024 = 0 if invested_2024 == 1

** Case 1: Only debt reduction selected ("3")
capture replace debt_amount_2024 = sec5_q3_1 if sec5_q2 == "3" & !missing(sec5_q3_1)

** Case 2: Working capital + debt reduction ("1 3") - debt reduction is 2nd
capture replace debt_amount_2024 = sec5_q3_2 if sec5_q2 == "1 3" & !missing(sec5_q3_2)

** Case 3: Asset creation + debt reduction ("2 3") - debt reduction is 2nd
capture replace debt_amount_2024 = sec5_q3_2 if sec5_q2 == "2 3" & !missing(sec5_q3_2)

** Case 4: Debt reduction + new enterprise ("3 4") - debt reduction is 1st
capture replace debt_amount_2024 = sec5_q3_1 if sec5_q2 == "3 4" & !missing(sec5_q3_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3") - debt reduction is 3rd
capture replace debt_amount_2024 = sec5_q3_3 if sec5_q2 == "1 2 3" & !missing(sec5_q3_3)

** Case 6: Working capital + debt reduction + new enterprise ("1 3 4") - debt reduction is 2nd
capture replace debt_amount_2024 = sec5_q3_2 if sec5_q2 == "1 3 4" & !missing(sec5_q3_2)

** Case 7: Asset creation + debt reduction + new enterprise ("2 3 4") - debt reduction is 2nd
capture replace debt_amount_2024 = sec5_q3_2 if sec5_q2 == "2 3 4" & !missing(sec5_q3_2)

** Case 8: All four types ("1 2 3 4") - debt reduction is 3rd
capture replace debt_amount_2024 = sec5_q3_3 if sec5_q2 == "1 2 3 4" & !missing(sec5_q3_3)

label var debt_amount_2024 "Amount invested in debt reduction in 2024 (Rs.)"


** Investment Amount Variables - 2023 and 2022 - Complete with Capture

/*==============================================================================
				2023 INVESTMENT AMOUNT VARIABLES
===============================================================================*/

** Working capital investment amounts - 2023
gen wc_amount_2023 = 0 if invested_2023 == 1

** Only working capital selected ("1")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1" & !missing(sec5_q8_1)

** Case 2: Working capital + asset creation ("1 2") 
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 2" & !missing(sec5_q8_1)

** Case 3: Working capital + debt reduction ("1 3")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 3" & !missing(sec5_q8_1)

** Case 4: Working capital + new enterprise ("1 4")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 4" & !missing(sec5_q8_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 2 3" & !missing(sec5_q8_1)

** Case 6: Working capital + asset creation + new enterprise ("1 2 4")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 2 4" & !missing(sec5_q8_1)

** Case 7: Working capital + debt reduction + new enterprise ("1 3 4")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 3 4" & !missing(sec5_q8_1)

** Case 8: All four types ("1 2 3 4")
capture replace wc_amount_2023 = sec5_q8_1 if sec5_q7 == "1 2 3 4" & !missing(sec5_q8_1)

label var wc_amount_2023 "Amount invested in working capital in 2023 (Rs.)"

** Asset creation investment amounts - 2023 (including new enterprise)
gen asset_amount_2023 = 0 if invested_2023 == 1

** Case 1: Only asset creation selected ("2")
capture replace asset_amount_2023 = sec5_q8_1 if sec5_q7 == "2" & !missing(sec5_q8_1)

** Case 2: Only new enterprise selected ("4") 
capture replace asset_amount_2023 = sec5_q8_1 if sec5_q7 == "4" & !missing(sec5_q8_1)

** Case 3: Working capital + asset creation ("1 2") - asset creation is 2nd
capture replace asset_amount_2023 = sec5_q8_2 if sec5_q7 == "1 2" & !missing(sec5_q8_2)

** Case 4: Working capital + new enterprise ("1 4") - new enterprise is 2nd
capture replace asset_amount_2023 = sec5_q8_2 if sec5_q7 == "1 4" & !missing(sec5_q8_2)

** Case 5: Asset creation + debt reduction ("2 3") - asset creation is 1st
capture replace asset_amount_2023 = sec5_q8_1 if sec5_q7 == "2 3" & !missing(sec5_q8_1)

** Case 6: Asset creation + new enterprise ("2 4") - asset creation is 1st, new enterprise is 2nd
capture replace asset_amount_2023 = sec5_q8_1 + sec5_q8_2 if sec5_q7 == "2 4" & !missing(sec5_q8_1) & !missing(sec5_q8_2)

** Case 7: Debt reduction + new enterprise ("3 4") - new enterprise is 2nd
capture replace asset_amount_2023 = sec5_q8_2 if sec5_q7 == "3 4" & !missing(sec5_q8_2)

** Case 8: Working capital + asset creation + debt reduction ("1 2 3") - asset creation is 2nd
capture replace asset_amount_2023 = sec5_q8_2 if sec5_q7 == "1 2 3" & !missing(sec5_q8_2)

** Case 9: Working capital + asset creation + new enterprise ("1 2 4") - asset creation is 2nd, new enterprise is 3rd
capture replace asset_amount_2023 = sec5_q8_2 + sec5_q8_3 if sec5_q7 == "1 2 4" & !missing(sec5_q8_2) & !missing(sec5_q8_3)

** Case 10: Working capital + debt reduction + new enterprise ("1 3 4") - new enterprise is 3rd
capture replace asset_amount_2023 = sec5_q8_3 if sec5_q7 == "1 3 4" & !missing(sec5_q8_3)

** Case 11: Asset creation + debt reduction + new enterprise ("2 3 4") - asset creation is 1st, new enterprise is 3rd
capture replace asset_amount_2023 = sec5_q8_1 + sec5_q8_3 if sec5_q7 == "2 3 4" & !missing(sec5_q8_1) & !missing(sec5_q8_3)

** Case 12: All four types ("1 2 3 4") - asset creation is 2nd, new enterprise is 4th
capture replace asset_amount_2023 = sec5_q8_2 + sec5_q8_4 if sec5_q7 == "1 2 3 4" & !missing(sec5_q8_2) & !missing(sec5_q8_4)

label var asset_amount_2023 "Amount invested in asset creation (including new enterprise) in 2023 (Rs.)"

** Debt reduction investment amounts - 2023
gen debt_amount_2023 = 0 if invested_2023 == 1

** Case 1: Only debt reduction selected ("3")
capture replace debt_amount_2023 = sec5_q8_1 if sec5_q7 == "3" & !missing(sec5_q8_1)

** Case 2: Working capital + debt reduction ("1 3") - debt reduction is 2nd
capture replace debt_amount_2023 = sec5_q8_2 if sec5_q7 == "1 3" & !missing(sec5_q8_2)

** Case 3: Asset creation + debt reduction ("2 3") - debt reduction is 2nd
capture replace debt_amount_2023 = sec5_q8_2 if sec5_q7 == "2 3" & !missing(sec5_q8_2)

** Case 4: Debt reduction + new enterprise ("3 4") - debt reduction is 1st
capture replace debt_amount_2023 = sec5_q8_1 if sec5_q7 == "3 4" & !missing(sec5_q8_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3") - debt reduction is 3rd
capture replace debt_amount_2023 = sec5_q8_3 if sec5_q7 == "1 2 3" & !missing(sec5_q8_3)

** Case 6: Working capital + debt reduction + new enterprise ("1 3 4") - debt reduction is 2nd
capture replace debt_amount_2023 = sec5_q8_2 if sec5_q7 == "1 3 4" & !missing(sec5_q8_2)

** Case 7: Asset creation + debt reduction + new enterprise ("2 3 4") - debt reduction is 2nd
capture replace debt_amount_2023 = sec5_q8_2 if sec5_q7 == "2 3 4" & !missing(sec5_q8_2)

** Case 8: All four types ("1 2 3 4") - debt reduction is 3rd
capture replace debt_amount_2023 = sec5_q8_3 if sec5_q7 == "1 2 3 4" & !missing(sec5_q8_3)

label var debt_amount_2023 "Amount invested in debt reduction in 2023 (Rs.)"

/*==============================================================================
				2022 INVESTMENT AMOUNT VARIABLES
===============================================================================*/


** Working capital investment amounts - 2022
gen wc_amount_2022 = 0 if invested_2022 == 1

** Only working capital selected ("1")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1" & !missing(sec5_q13_1)

** Case 2: Working capital + asset creation ("1 2") 
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 2" & !missing(sec5_q13_1)

** Case 3: Working capital + debt reduction ("1 3")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 3" & !missing(sec5_q13_1)

** Case 4: Working capital + new enterprise ("1 4")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 4" & !missing(sec5_q13_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 2 3" & !missing(sec5_q13_1)

** Case 6: Working capital + asset creation + new enterprise ("1 2 4")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 2 4" & !missing(sec5_q13_1)

** Case 7: Working capital + debt reduction + new enterprise ("1 3 4")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 3 4" & !missing(sec5_q13_1)

** Case 8: All four types ("1 2 3 4")
capture replace wc_amount_2022 = sec5_q13_1 if sec5_q12 == "1 2 3 4" & !missing(sec5_q13_1)

label var wc_amount_2022 "Amount invested in working capital in 2022 (Rs.)"

** Asset creation investment amounts - 2022 (including new enterprise)
gen asset_amount_2022 = 0 if invested_2022 == 1

** Case 1: Only asset creation selected ("2")
capture replace asset_amount_2022 = sec5_q13_1 if sec5_q12 == "2" & !missing(sec5_q13_1)

** Case 2: Only new enterprise selected ("4") 
capture replace asset_amount_2022 = sec5_q13_1 if sec5_q12 == "4" & !missing(sec5_q13_1)

** Case 3: Working capital + asset creation ("1 2") - asset creation is 2nd
capture replace asset_amount_2022 = sec5_q13_2 if sec5_q12 == "1 2" & !missing(sec5_q13_2)

** Case 4: Working capital + new enterprise ("1 4") - new enterprise is 2nd
capture replace asset_amount_2022 = sec5_q13_2 if sec5_q12 == "1 4" & !missing(sec5_q13_2)

** Case 5: Asset creation + debt reduction ("2 3") - asset creation is 1st
capture replace asset_amount_2022 = sec5_q13_1 if sec5_q12 == "2 3" & !missing(sec5_q13_1)

** Case 6: Asset creation + new enterprise ("2 4") - asset creation is 1st, new enterprise is 2nd
capture replace asset_amount_2022 = sec5_q13_1 + sec5_q13_2 if sec5_q12 == "2 4" & !missing(sec5_q13_1) & !missing(sec5_q13_2)

** Case 7: Debt reduction + new enterprise ("3 4") - new enterprise is 2nd
capture replace asset_amount_2022 = sec5_q13_2 if sec5_q12 == "3 4" & !missing(sec5_q13_2)

** Case 8: Working capital + asset creation + debt reduction ("1 2 3") - asset creation is 2nd
capture replace asset_amount_2022 = sec5_q13_2 if sec5_q12 == "1 2 3" & !missing(sec5_q13_2)

** Case 9: Working capital + asset creation + new enterprise ("1 2 4") - asset creation is 2nd, new enterprise is 3rd
capture replace asset_amount_2022 = sec5_q13_2 + sec5_q13_3 if sec5_q12 == "1 2 4" & !missing(sec5_q13_2) & !missing(sec5_q13_3)

** Case 10: Working capital + debt reduction + new enterprise ("1 3 4") - new enterprise is 3rd
capture replace asset_amount_2022 = sec5_q13_3 if sec5_q12 == "1 3 4" & !missing(sec5_q13_3)

** Case 11: Asset creation + debt reduction + new enterprise ("2 3 4") - asset creation is 1st, new enterprise is 3rd
capture replace asset_amount_2022 = sec5_q13_1 + sec5_q13_3 if sec5_q12 == "2 3 4" & !missing(sec5_q13_1) & !missing(sec5_q13_3)

** Case 12: All four types ("1 2 3 4") - asset creation is 2nd, new enterprise is 4th
capture replace asset_amount_2022 = sec5_q13_2 + sec5_q13_4 if sec5_q12 == "1 2 3 4" & !missing(sec5_q13_2) & !missing(sec5_q13_4)

label var asset_amount_2022 "Amount invested in asset creation (including new enterprise) in 2022 (Rs.)"

** Debt reduction investment amounts - 2022
gen debt_amount_2022 = 0 if invested_2022 == 1

** Case 1: Only debt reduction selected ("3")
capture replace debt_amount_2022 = sec5_q13_1 if sec5_q12 == "3" & !missing(sec5_q13_1)

** Case 2: Working capital + debt reduction ("1 3") - debt reduction is 2nd
capture replace debt_amount_2022 = sec5_q13_2 if sec5_q12 == "1 3" & !missing(sec5_q13_2)

** Case 3: Asset creation + debt reduction ("2 3") - debt reduction is 2nd
capture replace debt_amount_2022 = sec5_q13_2 if sec5_q12 == "2 3" & !missing(sec5_q13_2)

** Case 4: Debt reduction + new enterprise ("3 4") - debt reduction is 1st
capture replace debt_amount_2022 = sec5_q13_1 if sec5_q12 == "3 4" & !missing(sec5_q13_1)

** Case 5: Working capital + asset creation + debt reduction ("1 2 3") - debt reduction is 3rd
capture replace debt_amount_2022 = sec5_q13_3 if sec5_q12 == "1 2 3" & !missing(sec5_q13_3)

** Case 6: Working capital + debt reduction + new enterprise ("1 3 4") - debt reduction is 2nd
capture replace debt_amount_2022 = sec5_q13_2 if sec5_q12 == "1 3 4" & !missing(sec5_q13_2)

** Case 7: Asset creation + debt reduction + new enterprise ("2 3 4") - debt reduction is 2nd
capture replace debt_amount_2022 = sec5_q13_2 if sec5_q12 == "2 3 4" & !missing(sec5_q13_2)

** Case 8: All four types ("1 2 3 4") - debt reduction is 3rd
capture replace debt_amount_2022 = sec5_q13_3 if sec5_q12 == "1 2 3 4" & !missing(sec5_q13_3)

label var debt_amount_2022 "Amount invested in debt reduction in 2022 (Rs.)"





** Share of Investment by Type



** Working capital share by year
gen wc_share_2024 = wc_amount_2024 / total_invest_2024 if total_invest_2024 > 0 & !missing(total_invest_2024)
label var wc_share_2024 "Share of investment in working capital in 2024"

gen wc_share_2023 = wc_amount_2023 / total_invest_2023 if total_invest_2023 > 0 & !missing(total_invest_2023)
label var wc_share_2023 "Share of investment in working capital in 2023"

gen wc_share_2022 = wc_amount_2022 / total_invest_2022 if total_invest_2022 > 0 & !missing(total_invest_2022)
label var wc_share_2022 "Share of investment in working capital in 2022"

** Asset creation share by year (including new enterprise)
gen asset_share_2024 = asset_amount_2024 / total_invest_2024 if total_invest_2024 > 0 & !missing(total_invest_2024)
label var asset_share_2024 "Share of investment in asset creation (including new enterprise) in 2024"

gen asset_share_2023 = asset_amount_2023 / total_invest_2023 if total_invest_2023 > 0 & !missing(total_invest_2023)
label var asset_share_2023 "Share of investment in asset creation (including new enterprise) in 2023"

gen asset_share_2022 = asset_amount_2022 / total_invest_2022 if total_invest_2022 > 0 & !missing(total_invest_2022)
label var asset_share_2022 "Share of investment in asset creation (including new enterprise) in 2022"

** Debt reduction share by year
gen debt_share_2024 = debt_amount_2024 / total_invest_2024 if total_invest_2024 > 0 & !missing(total_invest_2024)
label var debt_share_2024 "Share of investment in debt reduction in 2024"

gen debt_share_2023 = debt_amount_2023 / total_invest_2023 if total_invest_2023 > 0 & !missing(total_invest_2023)
label var debt_share_2023 "Share of investment in debt reduction in 2023"

gen debt_share_2022 = debt_amount_2022 / total_invest_2022 if total_invest_2022 > 0 & !missing(total_invest_2022)
label var debt_share_2022 "Share of investment in debt reduction in 2022"





** Combined Investment Variables for Analysis

** Total investment across all years
egen total_invest_all = rowtotal(total_invest_2022 total_invest_2023 total_invest_2024), missing
label var total_invest_all "Total investment across all years (2022-2024)"

** Winsorized total investment across all years
gen w10_invest_all = total_invest_all
qui sum w10_invest_all, detail
replace w10_invest_all = r(p10) if total_invest_all <= r(p10) & !missing(total_invest_all)
replace w10_invest_all = r(p90) if total_invest_all >= r(p90) & !missing(total_invest_all)
label var w10_invest_all "Winsorized (at 10%) total investment across all years"






/*==============================================================================
                        Enterprise Cost Variables                              
==============================================================================*/

** 1. Basic Cost Indicators by Year

** Costs in 2024 (Yes/No)
gen has_costs_2024 = 0 if operational_2024 == 1
foreach i of numlist 1/9 {
    replace has_costs_2024 = 1 if strpos(sec9_q1, "`i'") > 0 & !missing(sec9_q1)
}
label var has_costs_2024 "Incurred any business costs in 2024"
label values has_costs_2024 yesno

** Costs in 2023 (Yes/No)
gen has_costs_2023 = 0 if operational_2023 == 1
foreach i of numlist 1/9 {
    replace has_costs_2023 = 1 if strpos(sec9_q8, "`i'") > 0 & !missing(sec9_q8)
}
label var has_costs_2023 "Incurred any business costs in 2023"
label values has_costs_2023 yesno

** Costs in 2022 (Yes/No) 
gen has_costs_2022 = 0 if operational_2022 == 1
foreach i of numlist 1/9 {
    replace has_costs_2022 = 1 if strpos(sec9_q14, "`i'") > 0 & !missing(sec9_q14)
}
label var has_costs_2022 "Incurred any business costs in 2022"
label values has_costs_2022 yesno

** 2. Total Annual Costs by Year

** Generate total costs for 2024 by summing across all cost categories
gen total_costs_2024 = 0 if operational_2024 == 1
label var total_costs_2024 "Total enterprise costs in 2024 (Rs.)"

forvalues i = 1/9 {
        replace total_costs_2024 = total_costs_2024 + sec9_q6_`i' if !missing(sec9_q6_`i')
    }


** Generate total costs for 2023 by summing across all cost categories
gen total_costs_2023 = 0 if operational_2023 == 1
label var total_costs_2023 "Total enterprise costs in 2023 (Rs.)"

forvalues i = 1/5 {
        replace total_costs_2023 = total_costs_2023 + sec9_q13_`i' if !missing(sec9_q13_`i')
    }


** Generate total costs for 2022 by summing across all cost categories
gen total_costs_2022 = 0 if operational_2022 == 1
label var total_costs_2022 "Total enterprise costs in 2022 (Rs.)"

forvalues i = 1/5 {
        replace total_costs_2022 = total_costs_2022 + sec9_q19_`i' if !missing(sec9_q19_`i')
    }
	

	
	
** 5. Winsorized Cost Variables (at 1%)


* Winsorized total costs in 2024
gen w5_total_costs_2024 = total_costs_2024
qui sum w5_total_costs_2024, detail
replace w5_total_costs_2024 = r(p5) if total_costs_2024 <= r(p5) & !missing(total_costs_2024)
replace w5_total_costs_2024 = r(p95) if total_costs_2024 >= r(p95) & !missing(total_costs_2024)
label var w5_total_costs_2024 "Winsorized (at 5%) total costs in 2024 (Rs.)"

* Winsorized total costs in 2023
gen w5_total_costs_2023 = total_costs_2023
qui sum w5_total_costs_2023, detail
replace w5_total_costs_2023 = r(p1) if total_costs_2023 <= r(p1) & !missing(total_costs_2023)
replace w5_total_costs_2023 = r(p99) if total_costs_2023 >= r(p99) & !missing(total_costs_2023)
label var w5_total_costs_2023 "Winsorized (at 5%) total costs in 2023 (Rs.)"

* Winsorized total costs in 2022
gen w5_total_costs_2022 = total_costs_2022
qui sum w5_total_costs_2022, detail
replace w5_total_costs_2022 = r(p1) if total_costs_2022 <= r(p1) & !missing(total_costs_2022)
replace w5_total_costs_2022 = r(p99) if total_costs_2022 >= r(p99) & !missing(total_costs_2022)
label var w5_total_costs_2022 "Winsorized (at 5%) total costs in 2022 (Rs.)"
	
	
	
	

	

	
forval i = 1(1)9 {
    gen w5_sec9_q4_`i' = sec9_q4_`i'
    qui sum w5_sec9_q4_`i', detail
    replace w5_sec9_q4_`i' = r(p5) if sec9_q4_`i' <= r(p5) & !missing(sec9_q4_`i')
    replace w5_sec9_q4_`i' = r(p95) if sec9_q4_`i' >= r(p95) & !missing(sec9_q4_`i')
}
   
 forval i = 1(1)5 {
        gen w5_sec9_q11_`i' = sec9_q11_`i'
        qui sum w5_sec9_q11_`i', detail
        replace w5_sec9_q11_`i' = r(p5) if sec9_q11_`i' <= r(p5) & !missing(sec9_q11_`i')
        replace w5_sec9_q11_`i' = r(p95) if sec9_q11_`i' >= r(p95) & !missing(sec9_q11_`i')
    }
    
 forval i = 1(1)5{
        gen w5_sec9_q17_`i' = sec9_q17_`i'
        qui sum w5_sec9_q17_`i', detail
        replace w5_sec9_q17_`i' = r(p5) if sec9_q17_`i' <= r(p5) & !missing(sec9_q17_`i')
        replace w5_sec9_q17_`i' = r(p95) if sec9_q17_`i' >= r(p95) & !missing(sec9_q17_`i')
    }


* Now add specific labels based on the cost categories
label var w5_sec9_q4_1 "Winsorized (at 5%) peak month costs 2024 - Raw materials/resale items"
label var w5_sec9_q4_2 "Winsorized (at 5%) peak month costs 2024 - Space (shop/storage/workshop)"
label var w5_sec9_q4_3 "Winsorized (at 5%) peak month costs 2024 - Repair & maintenance of workspace"
label var w5_sec9_q4_4 "Winsorized (at 5%) peak month costs 2024 - Machinery/Equipment"
label var w5_sec9_q4_5 "Winsorized (at 5%) peak month costs 2024 - Repair & maintenance of machinery"
label var w5_sec9_q4_6 "Winsorized (at 5%) peak month costs 2024 - Vehicles/transportation"
label var w5_sec9_q4_7 "Winsorized (at 5%) peak month costs 2024 - Electricity/water/gas/fuel"
label var w5_sec9_q4_8 "Winsorized (at 5%) peak month costs 2024 - Interest on loans"
label var w5_sec9_q4_9 "Winsorized (at 5%) peak month costs 2024 - Taxes"

forval i = 1(1)5 {
        local label_text : variable label w5_sec9_q4_`i'
        label var w5_sec9_q11_`i' "`=subinstr("`label_text'", "2024", "2023", 1)'"
    }

forval i = 1(1)5 {
        local label_text : variable label w5_sec9_q4_`i'
        label var w5_sec9_q17_`i' "`=subinstr("`label_text'", "2024", "2022", 1)'"
    }

	

	
	
	




* Winsorize usual month costs for 2024 (all 9 categories)
forval i = 1(1)9 {
    gen w5_sec9_q5_`i' = sec9_q5_`i'
    qui sum w5_sec9_q5_`i', detail
    replace w5_sec9_q5_`i' = r(p5) if sec9_q5_`i' <= r(p5) & !missing(sec9_q5_`i')
    replace w5_sec9_q5_`i' = r(p95) if sec9_q5_`i' >= r(p95) & !missing(sec9_q5_`i')
}

* Winsorize usual month costs for 2023 (5 categories)
forval i = 1(1)5 {
    gen w5_sec9_q12_`i' = sec9_q12_`i'
    qui sum w5_sec9_q12_`i', detail
    replace w5_sec9_q12_`i' = r(p5) if sec9_q12_`i' <= r(p5) & !missing(sec9_q12_`i')
    replace w5_sec9_q12_`i' = r(p95) if sec9_q12_`i' >= r(p95) & !missing(sec9_q12_`i')
}

* Winsorize usual month costs for 2022 (5 categories)
forval i = 1(1)5 {
    gen w5_sec9_q18_`i' = sec9_q18_`i'
    qui sum w5_sec9_q18_`i', detail
    replace w5_sec9_q18_`i' = r(p5) if sec9_q18_`i' <= r(p5) & !missing(sec9_q18_`i')
    replace w5_sec9_q18_`i' = r(p95) if sec9_q18_`i' >= r(p95) & !missing(sec9_q18_`i')
}

* Add specific labels for 2024 usual month costs
label var w5_sec9_q5_1 "Winsorized (at 1%) usual month costs 2024 - Raw materials/resale items"
label var w5_sec9_q5_2 "Winsorized (at 1%) usual month costs 2024 - Space (shop/storage/workshop)"
label var w5_sec9_q5_3 "Winsorized (at 1%) usual month costs 2024 - Repair & maintenance of workspace"
label var w5_sec9_q5_4 "Winsorized (at 1%) usual month costs 2024 - Machinery/Equipment"
label var w5_sec9_q5_5 "Winsorized (at 1%) usual month costs 2024 - Repair & maintenance of machinery"
label var w5_sec9_q5_6 "Winsorized (at 1%) usual month costs 2024 - Vehicles/transportation"
label var w5_sec9_q5_7 "Winsorized (at 1%) usual month costs 2024 - Electricity/water/gas/fuel"
label var w5_sec9_q5_8 "Winsorized (at 1%) usual month costs 2024 - Interest on loans"
label var w5_sec9_q5_9 "Winsorized (at 1%) usual month costs 2024 - Taxes"

* Add labels for 2023 usual month costs (first 5 categories)
forval i = 1(1)5 {
    local label_text : variable label w5_sec9_q5_`i'
    label var w5_sec9_q12_`i' "`=subinstr("`label_text'", "2024", "2023", 1)'"
}

* Add labels for 2022 usual month costs (first 5 categories)
forval i = 1(1)5 {
    local label_text : variable label w5_sec9_q5_`i'
    label var w5_sec9_q18_`i' "`=subinstr("`label_text'", "2024", "2022", 1)'"
}




** 2. Peak and Usual Month Costs by Year

** Peak months costs in 2024
gen peak_costs_2024 = 0 if operational_2024 == 1 & num_peak_months_2024 > 0
label var peak_costs_2024 "Total costs during peak months in 2024 (Rs.)"

forvalues i = 1/9 {
        replace peak_costs_2024 = peak_costs_2024 + (w5_sec9_q4_`i' * num_peak_months_2024) if !missing(w5_sec9_q4_`i') & !missing(num_peak_months_2024)
		
    }

	
** Usual months costs in 2024
gen usual_costs_2024 = 0 if operational_2024 == 1 & num_usual_months_2024 > 0
label var usual_costs_2024 "Total costs during usual months in 2024 (Rs.)"

forvalues i = 1/9 {
        replace usual_costs_2024 = usual_costs_2024 + (w5_sec9_q5_`i' * num_usual_months_2024) if !missing(w5_sec9_q5_`i') & !missing(num_usual_months_2024)
}



** Peak months costs in 2023
gen peak_costs_2023 = 0 if operational_2023 == 1 & num_peak_months_2023 > 0
label var peak_costs_2023 "Total costs during peak months in 2023 (Rs.)"

forvalues i = 1/5 {
        replace peak_costs_2023 = peak_costs_2023 + (w5_sec9_q11_`i' * num_peak_months_2023) if !missing(w5_sec9_q11_`i') & !missing(num_peak_months_2023)
    
	}


** Usual months costs in 2023
gen usual_costs_2023 = 0 if operational_2023 == 1 & num_usual_months_2023 > 0
label var usual_costs_2023 "Total costs during usual months in 2023 (Rs.)"

forvalues i = 1/5 {
        replace usual_costs_2023 = usual_costs_2023 + (w5_sec9_q12_`i' * num_usual_months_2023) if !missing(w5_sec9_q12_`i') & !missing(num_usual_months_2023)
    }

	
	
	
	

** Peak months costs in 2022
gen peak_costs_2022 = 0 if operational_2022 == 1 & num_peak_months_2022 > 0
label var peak_costs_2022 "Total costs during peak months in 2022 (Rs.)"

forvalues i = 1/5 {
        replace peak_costs_2022 = peak_costs_2022 + (w5_sec9_q17_`i' * num_peak_months_2022) if !missing(w5_sec9_q17_`i') & !missing(num_peak_months_2022)
    
	}


** Usual months costs in 2022
gen usual_costs_2022 = 0 if operational_2022 == 1 & num_usual_months_2022 > 0
label var usual_costs_2022 "Total costs during usual months in 2022 (Rs.)"

forvalues i = 1/5 {
        replace usual_costs_2022 = usual_costs_2022 + (w5_sec9_q18_`i' * num_usual_months_2022) if !missing(w5_sec9_q18_`i') & !missing(num_usual_months_2022)
    
	}


** 3. Interest Costs (treated separately)

** Total annual interest cost in 2024
gen interest_cost_2024 = 0 if operational_2024 == 1
forvalues i = 1/9 {
        ** Multiply monthly interest by 12 to get annual cost
        replace interest_cost_2024 = interest_cost_2024 + (sec9_q4_a_`i' * 12) if !missing(sec9_q4_a_`i')
    }

label var interest_cost_2024 "Annual interest cost in 2024 (Rs.)"




** Total annual interest cost in 2023
gen interest_cost_2023 = 0 if operational_2023 == 1
forvalues i = 1/5 {
        ** Multiply monthly interest by 12 to get annual cost
        replace interest_cost_2023 = interest_cost_2023 + (sec9_q11_a_`i' * 12) if !missing(sec9_q11_a_`i')
    }

label var interest_cost_2023 "Annual interest cost in 2023 (Rs.)"




** Total annual interest cost in 2022
gen interest_cost_2022 = 0 if operational_2022 == 1
forvalues i = 1/5 {
        ** Multiply monthly interest by 12 to get annual cost
        replace interest_cost_2022 = interest_cost_2022 + (sec9_q17_a_`i' * 12) if !missing(sec9_q17_a_`i')
    }

label var interest_cost_2022 "Annual interest cost in 2022 (Rs.)"




** 4. Calculate Total Costs Including Shutdown and Interest Costs

** Total costs for 2024 (peak + usual + shutdown + interest)
egen calc_total_costs_2024 = rowtotal(peak_costs_2024 usual_costs_2024 shutdown_cost_2024 interest_cost_2024) if operational_2024 == 1 
label var calc_total_costs_2024 "Calculated total costs in 2024 (Rs.)"

** Total costs for 2023 (peak + usual + shutdown + interest)	
egen calc_total_costs_2023 = rowtotal(peak_costs_2023 usual_costs_2023 shutdown_cost_2023 interest_cost_2023) if operational_2023 == 1 
label var calc_total_costs_2023 "Calculated total costs in 2023 (Rs.)"

** Total costs for 2022 (peak + usual + shutdown + interest)	
egen calc_total_costs_2022 = rowtotal(peak_costs_2022 usual_costs_2022 shutdown_cost_2022 interest_cost_2022) if operational_2022 == 1 
label var calc_total_costs_2022 "Calculated total costs in 2022 (Rs.)"





** 7. Combined Costs Across All Years

** Total costs across all years
egen total_costs_all_years = rowtotal(total_costs_2022 total_costs_2023 total_costs_2024), missing
label var total_costs_all_years "Total costs across all years (2022-2024) (Rs.)"

** Winsorized total costs across all years
gen w10_total_costs_all_years = total_costs_all_years
qui sum w10_total_costs_all_years, detail
replace w10_total_costs_all_years = r(p10) if total_costs_all_years <= r(p10) & !missing(total_costs_all_years)
replace w10_total_costs_all_years = r(p90) if total_costs_all_years >= r(p90) & !missing(total_costs_all_years)
label var w10_total_costs_all_years "Winsorized (at 10%) total costs across all years (Rs.)"








** Calculate quarterly costs for 2024
forvalues q = 1/4 {
    ** Peak costs by quarter
    gen peak_costs_2024_q`q' = 0 if operational_2024 == 1 & num_peak_months_2024_q`q' > 0
    forvalues i = 1/9 {
        replace peak_costs_2024_q`q' = peak_costs_2024_q`q' + (w5_sec9_q4_`i' * num_peak_months_2024_q`q') if !missing(w5_sec9_q4_`i') & !missing(num_peak_months_2024_q`q')
    }
    label var peak_costs_2024_q`q' "Peak costs in Q`q' 2024 (Rs.)"
    
    ** Usual costs by quarter
    gen usual_costs_2024_q`q' = 0 if operational_2024 == 1 & num_usual_months_2024_q`q' > 0
    forvalues i = 1/9 {
        replace usual_costs_2024_q`q' = usual_costs_2024_q`q' + (w5_sec9_q5_`i' * num_usual_months_2024_q`q') if !missing(w5_sec9_q5_`i') & !missing(num_usual_months_2024_q`q')
    }
    label var usual_costs_2024_q`q' "Usual costs in Q`q' 2024 (Rs.)"
    
    ** Total costs by quarter (peak + usual)
    egen total_costs_2024_q`q' = rowtotal(peak_costs_2024_q`q' usual_costs_2024_q`q'), missing
    label var total_costs_2024_q`q' "Total costs in Q`q' 2024 (Rs.)"
}




** Calculate quarterly costs for 2023
forvalues q = 1/4 {
    ** Peak costs by quarter
    gen peak_costs_2023_q`q' = 0 if operational_2023 == 1 & num_peak_months_2023_q`q' > 0
    forvalues i = 1/5 {
        replace peak_costs_2023_q`q' = peak_costs_2023_q`q' + (w5_sec9_q11_`i' * num_peak_months_2023_q`q') if !missing(w5_sec9_q11_`i') & !missing(num_peak_months_2023_q`q')
    }
    label var peak_costs_2023_q`q' "Peak costs in Q`q' 2023 (Rs.)"
    
    ** Usual costs by quarter
    gen usual_costs_2023_q`q' = 0 if operational_2023 == 1 & num_usual_months_2023_q`q' > 0
    forvalues i = 1/5 {
        replace usual_costs_2023_q`q' = usual_costs_2023_q`q' + (w5_sec9_q12_`i' * num_usual_months_2023_q`q') if !missing(w5_sec9_q12_`i') & !missing(num_usual_months_2023_q`q')
    }
    label var usual_costs_2023_q`q' "Usual costs in Q`q' 2023 (Rs.)"
    
    ** Total costs by quarter (peak + usual)
    egen total_costs_2023_q`q' = rowtotal(peak_costs_2023_q`q' usual_costs_2023_q`q'), missing
    label var total_costs_2023_q`q' "Total costs in Q`q' 2023 (Rs.)"
}

** Calculate quarterly costs for 2022
forvalues q = 1/4 {
    ** Peak costs by quarter
    gen peak_costs_2022_q`q' = 0 if operational_2022 == 1 & num_peak_months_2022_q`q' > 0
    forvalues i = 1/5 {
        replace peak_costs_2022_q`q' = peak_costs_2022_q`q' + (w5_sec9_q17_`i' * num_peak_months_2022_q`q') if !missing(w5_sec9_q17_`i') & !missing(num_peak_months_2022_q`q')
    }
    label var peak_costs_2022_q`q' "Peak costs in Q`q' 2022 (Rs.)"
    
    ** Usual costs by quarter
    gen usual_costs_2022_q`q' = 0 if operational_2022 == 1 & num_usual_months_2022_q`q' > 0
    forvalues i = 1/5 {
        replace usual_costs_2022_q`q' = usual_costs_2022_q`q' + (w5_sec9_q18_`i' * num_usual_months_2022_q`q') if !missing(w5_sec9_q18_`i') & !missing(num_usual_months_2022_q`q')
    }
    label var usual_costs_2022_q`q' "Usual costs in Q`q' 2022 (Rs.)"
    
    ** Total costs by quarter (peak + usual)
    egen total_costs_2022_q`q' = rowtotal(peak_costs_2022_q`q' usual_costs_2022_q`q'), missing
    label var total_costs_2022_q`q' "Total costs in Q`q' 2022 (Rs.)"
}






/*==============================================================================
                        Enterprise Revenue Variables                              
==============================================================================*/

** 1. Basic Revenue Indicators by Year

** Revenue in 2024 (Yes/No)
gen has_revenue_2024 = 0 if operational_2024 == 1
replace has_revenue_2024 = 1 if sec7_q3 > 0 & !missing(sec7_q3)
label var has_revenue_2024 "Generated any business revenue in 2024"
label values has_revenue_2024 yesno

** Revenue in 2023 (Yes/No)
gen has_revenue_2023 = 0 if operational_2023 == 1
replace has_revenue_2023 = 1 if sec7_q13 > 0 & !missing(sec7_q13)
label var has_revenue_2023 "Generated any business revenue in 2023"
label values has_revenue_2023 yesno

** Revenue in 2022 (Yes/No)
gen has_revenue_2022 = 0 if operational_2022 == 1
replace has_revenue_2022 = 1 if sec7_q18 > 0 & !missing(sec7_q18)
label var has_revenue_2022 "Generated any business revenue in 2022"
label values has_revenue_2022 yesno

** 2. Total Annual Revenue by Year

** Generate total revenue for 2024 directly from survey response
gen total_revenue_2024 = sec7_q3 if operational_2024 == 1
label var total_revenue_2024 "Total enterprise revenue in 2024 (Rs.)"

** Generate total revenue for 2023 directly from survey response
gen total_revenue_2023 = sec7_q13 if operational_2023 == 1
label var total_revenue_2023 "Total enterprise revenue in 2023 (Rs.)"

** Generate total revenue for 2022 directly from survey response
gen total_revenue_2022 = sec7_q18 if operational_2022 == 1
label var total_revenue_2022 "Total enterprise revenue in 2022 (Rs.)"

** 5. Winsorized Revenue Variables (at 10%)

** Winsorized total revenue in 2024
gen w5_total_revenue_2024 = total_revenue_2024
qui sum w5_total_revenue_2024, detail
replace w5_total_revenue_2024 = r(p5) if total_revenue_2024 <= r(p5) & !missing(total_revenue_2024)
replace w5_total_revenue_2024 = r(p95) if total_revenue_2024 >= r(p95) & !missing(total_revenue_2024)
label var w5_total_revenue_2024 "Winsorized (at 5%) total revenue in 2024 (Rs.)"

** Winsorized total revenue in 2023
gen w5_total_revenue_2023 = total_revenue_2023
qui sum w5_total_revenue_2023, detail
replace w5_total_revenue_2023 = r(p5) if total_revenue_2023 <= r(p5) & !missing(total_revenue_2023)
replace w5_total_revenue_2023 = r(p95) if total_revenue_2023 >= r(p95) & !missing(total_revenue_2023)
label var w5_total_revenue_2023 "Winsorized (at 5%) total revenue in 2023 (Rs.)"

** Winsorized total revenue in 2022
gen w5_total_revenue_2022 = total_revenue_2022
qui sum w5_total_revenue_2022, detail
replace w5_total_revenue_2022 = r(p5) if total_revenue_2022 <= r(p5) & !missing(total_revenue_2022)
replace w5_total_revenue_2022 = r(p95) if total_revenue_2022 >= r(p95) & !missing(total_revenue_2022)
label var w5_total_revenue_2022 "Winsorized (at 5%) total revenue in 2022 (Rs.)"





** First, create winsorized monthly revenue variables for peak and usual months
* 2024 Peak and Usual Revenue (winsorized at 5%)
gen w5_sec7_q1 = sec7_q1
qui sum w5_sec7_q1, detail
replace w5_sec7_q1 = r(p5) if sec7_q1 <= r(p5) & !missing(sec7_q1)
replace w5_sec7_q1 = r(p95) if sec7_q1 >= r(p95) & !missing(sec7_q1)
label var w5_sec7_q1 "Winsorized (at 5%) peak month revenue 2024"

gen w5_sec7_q2 = sec7_q2
qui sum w5_sec7_q2, detail
replace w5_sec7_q2 = r(p5) if sec7_q2 <= r(p5) & !missing(sec7_q2)
replace w5_sec7_q2 = r(p95) if sec7_q2 >= r(p95) & !missing(sec7_q2)
label var w5_sec7_q2 "Winsorized (at 5%) usual month revenue 2024"

* 2023 Peak and Usual Revenue (winsorized at 5%)
gen w5_sec7_q11 = sec7_q11
qui sum w5_sec7_q11, detail
replace w5_sec7_q11 = r(p5) if sec7_q11 <= r(p5) & !missing(sec7_q11)
replace w5_sec7_q11 = r(p95) if sec7_q11 >= r(p95) & !missing(sec7_q11)
label var w5_sec7_q11 "Winsorized (at 5%) peak month revenue 2023"

gen w5_sec7_q12 = sec7_q12
qui sum w5_sec7_q12, detail
replace w5_sec7_q12 = r(p5) if sec7_q12 <= r(p5) & !missing(sec7_q12)
replace w5_sec7_q12 = r(p95) if sec7_q12 >= r(p95) & !missing(sec7_q12)
label var w5_sec7_q12 "Winsorized (at 5%) usual month revenue 2023"

* 2022 Peak and Usual Revenue (winsorized at 5%)
gen w5_sec7_q16 = sec7_q16
qui sum w5_sec7_q16, detail
replace w5_sec7_q16 = r(p5) if sec7_q16 <= r(p5) & !missing(sec7_q16)
replace w5_sec7_q16 = r(p95) if sec7_q16 >= r(p95) & !missing(sec7_q16)
label var w5_sec7_q16 "Winsorized (at 5%) peak month revenue 2022"

gen w5_sec7_q17 = sec7_q17
qui sum w5_sec7_q17, detail
replace w5_sec7_q17 = r(p5) if sec7_q17 <= r(p5) & !missing(sec7_q17)
replace w5_sec7_q17 = r(p95) if sec7_q17 >= r(p95) & !missing(sec7_q17)
label var w5_sec7_q17 "Winsorized (at 5%) usual month revenue 2022"




** 3. Peak and Usual Month Revenue by Year

** Peak months revenue in 2024
gen peak_revenue_2024 = 0 if operational_2024 == 1 & num_peak_months_2024 > 0
replace peak_revenue_2024 = w5_sec7_q1 * num_peak_months_2024 if !missing(w5_sec7_q1) & !missing(num_peak_months_2024)
label var peak_revenue_2024 "Total revenue during peak months in 2024 (Rs.)"

** Usual months revenue in 2024
gen usual_revenue_2024 = 0 if operational_2024 == 1 & num_usual_months_2024 > 0
replace usual_revenue_2024 = w5_sec7_q2 * num_usual_months_2024 if !missing(w5_sec7_q2) & !missing(num_usual_months_2024)
label var usual_revenue_2024 "Total revenue during usual months in 2024 (Rs.)"




** Peak months revenue in 2023
gen peak_revenue_2023 = 0 if operational_2023 == 1 & num_peak_months_2023 > 0
replace peak_revenue_2023 = w5_sec7_q11 * num_peak_months_2023 if !missing(w5_sec7_q11) & !missing(num_peak_months_2023)
label var peak_revenue_2023 "Total revenue during peak months in 2023 (Rs.)"

** Usual months revenue in 2023
gen usual_revenue_2023 = 0 if operational_2023 == 1 & num_usual_months_2023 > 0
replace usual_revenue_2023 = w5_sec7_q12 * num_usual_months_2023 if !missing(w5_sec7_q12) & !missing(num_usual_months_2023)
label var usual_revenue_2023 "Total revenue during usual months in 2023 (Rs.)"






** Peak months revenue in 2022
gen peak_revenue_2022 = 0 if operational_2022 == 1 & num_peak_months_2022 > 0
replace peak_revenue_2022 = w5_sec7_q16 * num_peak_months_2022 if !missing(w5_sec7_q16) & !missing(num_peak_months_2022)
label var peak_revenue_2022 "Total revenue during peak months in 2022 (Rs.)"

** Usual months revenue in 2022
gen usual_revenue_2022 = 0 if operational_2022 == 1 & num_usual_months_2022 > 0
replace usual_revenue_2022 = w5_sec7_q17 * num_usual_months_2022 if !missing(w5_sec7_q17) & !missing(num_usual_months_2022)
label var usual_revenue_2022 "Total revenue during usual months in 2022 (Rs.)"


** Alternative total revenue for 2024 (peak + usual)
egen calc_total_revenue_2024 = rowtotal(peak_revenue_2024 peak_revenue_2024) if operational_2024 == 1 
label var calc_total_revenue_2024 "Calculated total revenue in 2024 (Rs.)"

** Alternative total revenue for 2023 (peak + usual)
egen calc_total_revenue_2023 = rowtotal(peak_revenue_2023 usual_revenue_2023) if operational_2023 == 1 
label var calc_total_revenue_2023 "Calculated total revenue in 2023 (Rs.)"

** Alternative total revenue for 2022 (peak + usual)	
egen calc_total_revenue_2022 = rowtotal(peak_revenue_2022 usual_revenue_2022) if operational_2022 == 1 
label var calc_total_revenue_2022 "Calculated total revenue in 2022 (Rs.)"




** Calculate quarterly revenues for 2024
forvalues q = 1/4 {
    ** Peak revenue by quarter
    gen peak_revenue_2024_q`q' = 0 if operational_2024 == 1 & num_peak_months_2024_q`q' > 0
    replace peak_revenue_2024_q`q' = w5_sec7_q1 * num_peak_months_2024_q`q' if !missing(w5_sec7_q1) & !missing(num_peak_months_2024_q`q')
    label var peak_revenue_2024_q`q' "Peak revenue in Q`q' 2024 (Rs.)"
    
    ** Usual revenue by quarter
    gen usual_revenue_2024_q`q' = 0 if operational_2024 == 1 & num_usual_months_2024_q`q' > 0
    replace usual_revenue_2024_q`q' = w5_sec7_q2 * num_usual_months_2024_q`q' if !missing(w5_sec7_q2) & !missing(num_usual_months_2024_q`q')
    label var usual_revenue_2024_q`q' "Usual revenue in Q`q' 2024 (Rs.)"
    
    ** Total revenue by quarter (peak + usual)
    egen total_revenue_2024_q`q' = rowtotal(peak_revenue_2024_q`q' usual_revenue_2024_q`q'), missing
    label var total_revenue_2024_q`q' "Total revenue in Q`q' 2024 (Rs.)"
}

** Calculate quarterly revenues for 2023
forvalues q = 1/4 {
    ** Peak revenue by quarter
    gen peak_revenue_2023_q`q' = 0 if operational_2023 == 1 & num_peak_months_2023_q`q' > 0
    replace peak_revenue_2023_q`q' = w5_sec7_q11 * num_peak_months_2023_q`q' if !missing(w5_sec7_q11) & !missing(num_peak_months_2023_q`q')
    label var peak_revenue_2023_q`q' "Peak revenue in Q`q' 2023 (Rs.)"
    
    ** Usual revenue by quarter
    gen usual_revenue_2023_q`q' = 0 if operational_2023 == 1 & num_usual_months_2023_q`q' > 0
    replace usual_revenue_2023_q`q' = w5_sec7_q12 * num_usual_months_2023_q`q' if !missing(w5_sec7_q12) & !missing(num_usual_months_2023_q`q')
    label var usual_revenue_2023_q`q' "Usual revenue in Q`q' 2023 (Rs.)"
    
    ** Total revenue by quarter (peak + usual)
    egen total_revenue_2023_q`q' = rowtotal(peak_revenue_2023_q`q' usual_revenue_2023_q`q'), missing
    label var total_revenue_2023_q`q' "Total revenue in Q`q' 2023 (Rs.)"
}

** Calculate quarterly revenues for 2022
forvalues q = 1/4 {
    ** Peak revenue by quarter
    gen peak_revenue_2022_q`q' = 0 if operational_2022 == 1 & num_peak_months_2022_q`q' > 0
    replace peak_revenue_2022_q`q' = w5_sec7_q16 * num_peak_months_2022_q`q' if !missing(w5_sec7_q16) & !missing(num_peak_months_2022_q`q')
    label var peak_revenue_2022_q`q' "Peak revenue in Q`q' 2022 (Rs.)"
    
    ** Usual revenue by quarter
    gen usual_revenue_2022_q`q' = 0 if operational_2022 == 1 & num_usual_months_2022_q`q' > 0
    replace usual_revenue_2022_q`q' = w5_sec7_q17 * num_usual_months_2022_q`q' if !missing(w5_sec7_q17) & !missing(num_usual_months_2022_q`q')
    label var usual_revenue_2022_q`q' "Usual revenue in Q`q' 2022 (Rs.)"
    
    ** Total revenue by quarter (peak + usual)
    egen total_revenue_2022_q`q' = rowtotal(peak_revenue_2022_q`q' usual_revenue_2022_q`q'), missing
    label var total_revenue_2022_q`q' "Total revenue in Q`q' 2022 (Rs.)"
}





** Monthly profit (from most recent month)
gen monthly_profit = sec7_q7 if !missing(sec7_q7)
label var monthly_profit "Monthly profit in January 2025 (Rs.)"

gen log_monthly_profit = log(monthly_profit) if !missing(monthly_profit)
la var log_monthly_profit "Log of Monthly profit in January 2025 (Rs.)"



foreach var in profit_margin_manufacturing profit_margin_trading profit_margin_service {
	destring `var', replace
}

label var profit_margin_manufacturing "Profit margin for manufacturing enterprises (%)"
label var profit_margin_trading "Profit margin for trading enterprises (%)"
label var profit_margin_service "Profit margin for service enterprises (%)"

** Overall profit margin (combining all types)
gen profit_margin = .
replace profit_margin = profit_margin_manufacturing if sec2_q2 == 1
replace profit_margin = profit_margin_trading if sec2_q2 == 2
replace profit_margin = profit_margin_service if sec2_q2 == 3
label var profit_margin "Profit margin (%)"

** Winsorized profit margin
gen w5_profit_margin = profit_margin
qui sum w5_profit_margin, detail
replace w5_profit_margin = r(p5) if profit_margin <= r(p5) & !missing(profit_margin)
replace w5_profit_margin = r(p95) if profit_margin >= r(p95) & !missing(profit_margin)
label var w5_profit_margin "Winsorized (at 10%) profit margin (%)"






/*==============================================================================
                        Enterprise Profit Variables                              
==============================================================================*/

** 1. Calculate annual profits (Revenue - Costs)

** Annual profits for 2024
gen profit_2024 = total_revenue_2024 - total_costs_2024
label var profit_2024 "Profit in 2024 (January to December) (Rs.)"

** Annual profits for 2023
gen profit_2023 = total_revenue_2023 - total_costs_2023
label var profit_2023 "Profit in 2023 (January to December) (Rs.)"

** Annual profits for 2022
gen profit_2022 = total_revenue_2022 - total_costs_2022
label var profit_2022 "Profit in 2022 (January to December) (Rs.)"


** Update annual profit variables to use 5% winsorization to match the quarterly data
** Winsorized profits for 2024 at 5%
gen w5_profit_2024 = w5_total_revenue_2024 - w5_total_costs_2024
label var w5_profit_2024 "Winsorized (at 5%) profit in 2024 (Rs.)"

** Winsorized profits for 2023 at 5%
gen w5_profit_2023 = w5_total_revenue_2023 - w5_total_costs_2023
label var w5_profit_2023 "Winsorized (at 5%) profit in 2023 (Rs.)"

** Winsorized profits for 2022 at 5%
gen w5_profit_2022 = w5_total_revenue_2022 - w5_total_costs_2022
label var w5_profit_2022 "Winsorized (at 5%) profit in 2022 (Rs.)"



** 2. Calculated profits (based on calculated revenue and costs)

** Calculated profits for 2024
gen calc_profit_2024 = calc_total_revenue_2024 - calc_total_costs_2024
label var calc_profit_2024 "Calculated profit in 2024 (from calculated revenue and costs) (Rs.)"

** Calculated profits for 2023
gen calc_profit_2023 = calc_total_revenue_2023 - calc_total_costs_2023
label var calc_profit_2023 "Calculated profit in 2023 (from calculated revenue and costs) (Rs.)"

** Calculated profits for 2022
gen calc_profit_2022 = calc_total_revenue_2022 - calc_total_costs_2022
label var calc_profit_2022 "Calculated profit in 2022 (from calculated revenue and costs) (Rs.)"








** Calculate quarterly profits for 2024
forvalues q = 1/4 {
    ** Quarterly profit (revenue - costs)
    gen profit_2024_q`q' = total_revenue_2024_q`q' - total_costs_2024_q`q'
    label var profit_2024_q`q' "Profit in Q`q' 2024 (Rs.)"
    
}

** Calculate quarterly profits for 2023
forvalues q = 1/4 {
    ** Quarterly profit (revenue - costs)
    gen profit_2023_q`q' = total_revenue_2023_q`q' - total_costs_2023_q`q'
    label var profit_2023_q`q' "Profit in Q`q' 2023 (Rs.)"
    
}

** Calculate quarterly profits for 2022
forvalues q = 1/4 {
    ** Quarterly profit (revenue - costs)
    gen profit_2022_q`q' = total_revenue_2022_q`q' - total_costs_2022_q`q'
    label var profit_2022_q`q' "Profit in Q`q' 2022 (Rs.)"
    
}









/*==============================================================================
                        Monthly Sales                             
==============================================================================*/


clonevar monthly_sale = sec7_q4
la var sec7_q4 "Last Month Sales"


* log-transformed version of monthly sales
gen log_monthly_sale = log(monthly_sale) if monthly_sale > 0
la var log_monthly_sale "Log of Last Month Sales"






/*==============================================================================
                        Business Practices Score                              
==============================================================================*/


* Code to create Business Practices Score using only the exact survey variables
* Based on David McKenzie's approach without any temporary variables



la var sec16_q1_a "Marketing 1: Visited competitor's business to see prices"
la var sec16_q1_b "Marketing 2: Visited competitor's business to see products"
la var sec16_q1_c "Marketing 3: Asked existing customers what other products they should offer"
la var sec16_q1_d "Marketing 4: Talked with former customer to see why stopped buying"
la var sec16_q1_e "Marketing 5: Asked supplier whatproducts selling well"
la var sec16_q2 "Marketing 6: Used a special offer to attract customers"
la var sec16_q3 "Marketing 7: Have done advertising in last 6 months"

clonevar bp_m1 = sec16_q1_a
clonevar bp_m2 = sec16_q1_b
clonevar bp_m3 = sec16_q1_c
clonevar bp_m4 = sec16_q1_d
clonevar bp_m5 = sec16_q1_e
clonevar bp_m6 = sec16_q2
clonevar bp_m7 = sec16_q3

clonevar bp_b1 = sec16_q6
clonevar bp_b2 = sec16_q7
gen bp_b3=0 if sec16_q10 == 4
replace bp_b3=1 if sec16_q10 <= 3
replace bp_b3=1 if sec16_q8 == 0

												
la var bp_b1 "Buying & Stock Control 1: negotiate for lower price"
la var bp_b2 "Buying & Stock Control 2: compare alternate suppliers"
la var bp_b3 "Buying & Stock Control 3: Don't run out of stock frequently"



gen bp_r1=sec16_q15
gen bp_r2=sec16_q17
gen bp_r3=sec16_q18
gen bp_r4=sec16_q20
gen bp_r5=sec16_q21
gen bp_r6=sec16_q22
gen bp_r7=sec16_q23
gen bp_r8=sec16_q25

label var bp_r1 "Costing & Record Keeping 1: Keep written records"
label var bp_r2 "Costing & Record Keeping 2: record every purchase and sale"
label var bp_r3 "Costing & Record Keeping 3: can use records to know cash on hand"
label var bp_r4 "Costing & Record Keeping 4: use records to know whether sales of product increase or decrease"
label var bp_r5 "Costing & Record Keeping 5: worked out cost of each main product"
label var bp_r6 "Costing & Record Keeping 6: know which goods make most profit per item"
label var bp_r7 "Costing & Record Keeping 7: have a written budget for monthly expenses"
label var bp_r8 "Costing & Record Keeping 8: have records that could document ability to pay to bank"



gen bp_f1 = sec16_q26 == 4
gen bp_f2 = sec16_q27
gen bp_f3 = 1 if sec16_q27_a == 4
replace bp_f3=0 if sec16_q27_a <=3 |sec16_q27_a == 0
gen bp_f4 = sec16_q28
foreach x of varlist sec16_q29_1 - sec16_q29_4  { 
replace `x' = 0 if sec16_q29_5 ==1|`x'==.
}

gen bp_f5 = sec16_q29_1
gen bp_f6 = sec16_q29_2
gen bp_f7 = sec16_q29_3
gen bp_f8 = sec16_q29_4


label var bp_f1 "Financial Planning 1: review financial performance monthly"
label var bp_f2 "Financial Planning 2: have sales target for next year"
label var bp_f3 "Financial Planning 3: compare sales goal to target monthly"
label var bp_f4 "Financial Planning 4: have a budget of costs for next year"
label var bp_f5 "Financial Planning 5: prepare profit and loss statement"
label var bp_f6 "Financial Planning 6: prepare cashflow statement"
label var bp_f7 "Financial Planning 7: prepare balance sheet"
label var bp_f8 "Financial Planning 8: prepare income and expenditure statement"


* replace missings that were zeroes
egen tscore=rmean(bp_m1-bp_f8)

foreach var of varlist bp_f1 bp_f5 bp_f6 bp_f7 bp_f8 {
replace `var'=. if tscore==0 & bp_m1==.
}

** Create Indices of Business Practices
egen marketingscore=rmean(bp_m1 bp_m2 bp_m3 bp_m4 bp_m5 bp_m6 bp_m7)
label var marketingscore "Proportion of marketing practices used"

egen stockscore=rmean(bp_b1 bp_b2 bp_b3)
label var stockscore "Proportion of buying and stock control practices used"

egen recordscore=rmean(bp_r1 bp_r2 bp_r3 bp_r4 bp_r5 bp_r6 bp_r7 bp_r8)
label var recordscore "Proportion of record-keeping practices used"

egen planningscore=rmean(bp_f1-bp_f8)
label var planningscore "Proportion of financial planning practices used"

egen totalscore=rmean(bp_m1-bp_f8)
label var totalscore "Business Practices Score"


*** round totalscore to nearest 0.05 to help deal visually with missing data
gen totalscore1=round(totalscore,0.05)


****** Wide Variation in Business Practices within Districts
histogram totalscore1, discrete by(District)




/*
**************************
* Cross-sectional correlations between business practices and sales and profitability
gen logsales=log(monthlysales)
gen logprofit=log(monthlyprofit)

**** Figure 4: Sales
lpoly logsales totalscore if round==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_overall.gph 
lpoly logsales totalscore if round==1 & kenya==1, noscatter ci degree(1) bwidth(0.05)
* edit in graph editor using Figure2recorder.grec, saved as Figure2_kenya.gph 
lpoly logsales totalscore if round==1 & srilanka==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_srilanka.gph 
lpoly logsales totalscore if round==1 & bangladesh==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_bangladesh.gph 
lpoly logsales totalscore if round==1 & ghana==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_ghana.gph 
lpoly logsales totalscore if round==1 & mexico==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_mexico.gph 
lpoly logsales totalscore if round==1 & nigeria==1, noscatter ci degree(1) bwidth(0.05) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_nigeria.gph 
* chile sample small, so use a bigger bandwidth
lpoly logsales totalscore if round==1 & chile==1, noscatter ci degree(1) bwidth(0.1) 
* edit in graph editor using Figure2recorder.grec, saved as Figure2_chile.gph 
*/


**** Robustness to Different Ways of Aggregating
* Principal component
pca bp_m1-bp_f8 
predict scorefactor
* note this has the issue of being missing if one of the variables is missing
* Sum of standardized z-scores
foreach var of varlist bp_m1-bp_f8 {
sum `var' 
gen z_`var'= (`var'-r(mean))/r(sd)
}
egen zscore=rmean(z_bp_m1-z_bp_f8)
* correlations of index with these alternatives
corr totalscore scorefactor zscore 







/*==============================================================================
						Labor Section Variable Creation                            
==============================================================================*/

/*==============================================================================
			Employment Variables: Create basic indicators for each year                        
==============================================================================*/


** Basic employment indicators for 2022
gen employed_any_2022 = (sec8_q1 == 1) if operational_2022 == 1 & !missing(sec8_q1)
label var employed_any_2022 "Employed any workers in 2022"
label define yesno 0 "No" 1 "Yes", replace
label values employed_any_2022 yesno

** Basic employment indicators for 2023
gen employed_any_2023 = (sec8_q18 == 1) if operational_2023 == 1 & !missing(sec8_q18)
label var employed_any_2023 "Employed any workers in 2023"
label values employed_any_2023 yesno

** Basic employment indicators for 2024
gen employed_any_2024 = (sec8_q35 == 1) if operational_2024 == 1 & !missing(sec8_q35)
label var employed_any_2024 "Employed any workers in 2024"
label values employed_any_2024 yesno

** Create an indicator for having employed workers in any of the three years
gen employed_any_year = (employed_any_2022 == 1 | employed_any_2023 == 1 | employed_any_2024 == 1) ///
    if !missing(employed_any_2022) | !missing(employed_any_2023) | !missing(employed_any_2024)
label var employed_any_year "Employed any workers in any year (2022-2024)"
label values employed_any_year yesno

/*==============================================================================
			Total Employment: Permanent + Temporary Workers                     
==============================================================================*/


** 2022 Employment numbers
* Clean/fix missing permanent and temporary workers variables
* For enterprises that didn't employ any workers, set workforce counts to 0
foreach var of varlist sec8_q3 sec8_q10 {
    replace `var' = 0 if employed_any_2022 == 0 & !missing(employed_any_2022)
	replace `var' = 1 if `var' >= 35 & !missing(employed_any_2022)
}

* Generate total employment variable for 2022
gen total_employment_2022 = sec8_q3 + sec8_q10 if operational_2022 == 1 & !missing(employed_any_2022)
label var total_employment_2022 "Total number of workers employed in 2022"
replace total_employment_2022 = 1 if total_costs_2022 >= 35

** 2023 Employment numbers
* Clean/fix missing permanent and temporary workers variables
* For enterprises that didn't employ any workers, set workforce counts to 0
foreach var of varlist sec8_q20 sec8_q27 {
    replace `var' = 0 if employed_any_2023 == 0 & !missing(employed_any_2023)
	replace `var' = 1 if `var' >= 35 & !missing(employed_any_2023)
}

* Generate total employment variable for 2023
gen total_employment_2023 = sec8_q20 + sec8_q27 if operational_2023 == 1 & !missing(employed_any_2023)
label var total_employment_2023 "Total number of workers employed in 2023"

** 2024 Employment numbers
* Clean/fix missing permanent and temporary workers variables
* For enterprises that didn't employ any workers, set workforce counts to 0
foreach var of varlist sec8_q37 sec8_q44 {
    replace `var' = 0 if employed_any_2024 == 0 & !missing(employed_any_2024)
	replace `var' = 1 if `var' >= 35 & !missing(employed_any_2024)
}

* Generate total employment variable for 2024
gen total_employment_2024 = sec8_q37 + sec8_q44 if operational_2024 == 1 & !missing(employed_any_2024)
label var total_employment_2024 "Total number of workers employed in 2024"


/*==============================================================================
			Permanent vs. Temporary Employment                   
==============================================================================*/


** 2022 Permanent and Temporary Workforce
gen perm_workers_2022 = sec8_q3 if operational_2022 == 1 & !missing(employed_any_2022)
replace perm_workers_2022 = 0 if employed_any_2022 == 0
label var perm_workers_2022 "Number of permanent workers in 2022"

gen temp_workers_2022 = sec8_q10 if operational_2022 == 1 & !missing(employed_any_2022)
replace temp_workers_2022 = 0 if employed_any_2022 == 0
label var temp_workers_2022 "Number of temporary workers in 2022"




** 2023 Permanent and Temporary Workforce
gen perm_workers_2023 = sec8_q20 if operational_2023 == 1 & !missing(employed_any_2023)
replace perm_workers_2023 = 0 if employed_any_2023 == 0
label var perm_workers_2023 "Number of permanent workers in 2023"

gen temp_workers_2023 = sec8_q27 if operational_2023 == 1 & !missing(employed_any_2023)
replace temp_workers_2023 = 0 if employed_any_2023 == 0
label var temp_workers_2023 "Number of temporary workers in 2023"




** 2024 Permanent and Temporary Workforce
gen perm_workers_2024 = sec8_q37 if operational_2024 == 1 & !missing(employed_any_2024)
replace perm_workers_2024 = 0 if employed_any_2024 == 0
label var perm_workers_2024 "Number of permanent workers in 2024"

gen temp_workers_2024 = sec8_q44 if operational_2024 == 1 & !missing(employed_any_2024)
replace temp_workers_2024 = 0 if employed_any_2024 == 0
label var temp_workers_2024 "Number of temporary workers in 2024"

/*==============================================================================
			Share of Permanent vs. Temporary Workers              
==============================================================================*/



** Share of permanent workers in total employment
foreach year in 2022 2023 2024 {
    gen perm_share_`year' = perm_workers_`year' / total_employment_`year' ///
        if total_employment_`year' > 0 & !missing(total_employment_`year')
    label var perm_share_`year' "Share of permanent workers in total workforce in `year'"
    
    gen temp_share_`year' = temp_workers_`year' / total_employment_`year' ///
        if total_employment_`year' > 0 & !missing(total_employment_`year')
    label var temp_share_`year' "Share of temporary workers in total workforce in `year'"
}


/*==============================================================================
			Days Worked Variables             
==============================================================================*/



** Total worker-days in 2022 for permanent workers
gen perm_workdays_peak_2022 = sec8_q7 * num_peak_months_2022 * perm_workers_2022 ///
    if perm_workers_2022 > 0 & !missing(sec8_q7) & !missing(num_peak_months_2022)
label var perm_workdays_peak_2022 "Total worker-days for permanent workers in peak months 2022"

gen perm_workdays_usual_2022 = sec8_q8 * num_usual_months_2022 * perm_workers_2022 ///
    if perm_workers_2022 > 0 & !missing(sec8_q8) & !missing(num_usual_months_2022)
label var perm_workdays_usual_2022 "Total worker-days for permanent workers in usual months 2022"

egen perm_workdays_2022 = rowtotal(perm_workdays_peak_2022 perm_workdays_usual_2022), missing
label var perm_workdays_2022 "Total worker-days for permanent workers in 2022"

** Total worker-days in 2022 for temporary workers
gen temp_workdays_peak_2022 = sec8_q15 * num_peak_months_2022 * temp_workers_2022 ///
    if temp_workers_2022 > 0 & !missing(sec8_q15) & !missing(num_peak_months_2022)
label var temp_workdays_peak_2022 "Total worker-days for temporary workers in peak months 2022"

gen temp_workdays_usual_2022 = sec8_q16 * num_usual_months_2022 * temp_workers_2022 ///
    if temp_workers_2022 > 0 & !missing(sec8_q16) & !missing(num_usual_months_2022)
label var temp_workdays_usual_2022 "Total worker-days for temporary workers in usual months 2022"

egen temp_workdays_2022 = rowtotal(temp_workdays_peak_2022 temp_workdays_usual_2022), missing
label var temp_workdays_2022 "Total worker-days for temporary workers in 2022"

** Total worker-days in 2023 for permanent workers
gen perm_workdays_peak_2023 = sec8_q24 * num_peak_months_2023 * perm_workers_2023 ///
    if perm_workers_2023 > 0 & !missing(sec8_q24) & !missing(num_peak_months_2023)
label var perm_workdays_peak_2023 "Total worker-days for permanent workers in peak months 2023"

gen perm_workdays_usual_2023 = sec8_q25 * num_usual_months_2023 * perm_workers_2023 ///
    if perm_workers_2023 > 0 & !missing(sec8_q25) & !missing(num_usual_months_2023)
label var perm_workdays_usual_2023 "Total worker-days for permanent workers in usual months 2023"

egen perm_workdays_2023 = rowtotal(perm_workdays_peak_2023 perm_workdays_usual_2023), missing
label var perm_workdays_2023 "Total worker-days for permanent workers in 2023"

** Total worker-days in 2023 for temporary workers
gen temp_workdays_peak_2023 = sec8_q32 * num_peak_months_2023 * temp_workers_2023 ///
    if temp_workers_2023 > 0 & !missing(sec8_q32) & !missing(num_peak_months_2023)
label var temp_workdays_peak_2023 "Total worker-days for temporary workers in peak months 2023"

gen temp_workdays_usual_2023 = sec8_q33 * num_usual_months_2023 * temp_workers_2023 ///
    if temp_workers_2023 > 0 & !missing(sec8_q33) & !missing(num_usual_months_2023)
label var temp_workdays_usual_2023 "Total worker-days for temporary workers in usual months 2023"

egen temp_workdays_2023 = rowtotal(temp_workdays_peak_2023 temp_workdays_usual_2023), missing
label var temp_workdays_2023 "Total worker-days for temporary workers in 2023"

** Total worker-days in 2024 for permanent workers
gen perm_workdays_peak_2024 = sec8_q41 * num_peak_months_2024 * perm_workers_2024 ///
    if perm_workers_2024 > 0 & !missing(sec8_q41) & !missing(num_peak_months_2024)
label var perm_workdays_peak_2024 "Total worker-days for permanent workers in peak months 2024"

gen perm_workdays_usual_2024 = sec8_q42 * num_usual_months_2024 * perm_workers_2024 ///
    if perm_workers_2024 > 0 & !missing(sec8_q42) & !missing(num_usual_months_2024)
label var perm_workdays_usual_2024 "Total worker-days for permanent workers in usual months 2024"

egen perm_workdays_2024 = rowtotal(perm_workdays_peak_2024 perm_workdays_usual_2024), missing
label var perm_workdays_2024 "Total worker-days for permanent workers in 2024"

** Total worker-days in 2024 for temporary workers
gen temp_workdays_peak_2024 = sec8_q49 * num_peak_months_2024 * temp_workers_2024 ///
    if temp_workers_2024 > 0 & !missing(sec8_q49) & !missing(num_peak_months_2024)
label var temp_workdays_peak_2024 "Total worker-days for temporary workers in peak months 2024"

gen temp_workdays_usual_2024 = sec8_q50 * num_usual_months_2024 * temp_workers_2024 ///
    if temp_workers_2024 > 0 & !missing(sec8_q50) & !missing(num_usual_months_2024)
label var temp_workdays_usual_2024 "Total worker-days for temporary workers in usual months 2024"

egen temp_workdays_2024 = rowtotal(temp_workdays_peak_2024 temp_workdays_usual_2024), missing
label var temp_workdays_2024 "Total worker-days for temporary workers in 2024"

/*==============================================================================
			Labor Costs and Wage Variables          
==============================================================================*/


** Total labor costs
gen total_labor_cost_2022 = sec8_q9 + sec8_q17 if operational_2022 == 1
replace total_labor_cost_2022 = 0 if employed_any_2022 == 0 & !missing(employed_any_2022)
label var total_labor_cost_2022 "Total labor costs in 2022 (Rs.)"

gen total_labor_cost_2023 = sec8_q26 + sec8_q34 if operational_2023 == 1
replace total_labor_cost_2023 = 0 if employed_any_2023 == 0 & !missing(employed_any_2023)
label var total_labor_cost_2023 "Total labor costs in 2023 (Rs.)"

gen total_labor_cost_2024 = sec8_q43 + sec8_q51 if operational_2024 == 1
replace total_labor_cost_2024 = 0 if employed_any_2024 == 0 & !missing(employed_any_2024)
label var total_labor_cost_2024 "Total labor costs in 2024 (Rs.)"


/*==============================================================================
			Family Labor Variables (based on sec4_q3 series)    
==============================================================================*/



** Total family members working in the enterprise (excluding owner)
clonevar family_workers = sec4_q3
label var family_workers "Number of household members working in enterprise (excl. owner)"

** Paid family workers
clonevar paid_family_workers = sec4_q3_a 
label var paid_family_workers "Number of household members working with pay"

** Unpaid family workers
clonevar unpaid_family_workers = sec4_q3_b
label var unpaid_family_workers "Number of household members working without pay"

** Fix any inconsistencies in the data
* Ensure these variables are not missing when the total is 0
foreach var in paid_family_workers unpaid_family_workers {
    replace `var' = 0 if family_workers == 0 & missing(`var')
}

********************************************************************************
** 10. Combined Employment Variables for 2024 (most recent data)
********************************************************************************

** Total employment including owner and all workers (2024 as most recent)
gen total_emp_with_owner_2024 = 1 + total_employment_2024 if !missing(total_employment_2024)
label var total_emp_with_owner_2024 "Total employment in 2024 including owner"

** Paid employment: hired workers + paid family members (2024)
gen paid_employment_2024 = total_employment_2024 if !missing(total_employment_2024)
replace paid_employment_2024 = paid_employment_2024 + paid_family_workers if !missing(paid_family_workers)
label var paid_employment_2024 "Total paid employment in 2024"

** Unpaid employment: owner + unpaid family members (2024)
gen unpaid_employment_2024 = 1 if !missing(total_employment_2024)
replace unpaid_employment_2024 = unpaid_employment_2024 + unpaid_family_workers if !missing(unpaid_family_workers)
label var unpaid_employment_2024 "Total unpaid employment in 2024 (owner + family)"

** Share of paid employment in total employment (2024)
gen paid_emp_share_2024 = paid_employment_2024 / (total_emp_with_owner_2024 + family_workers) ///
    if !missing(paid_employment_2024) & !missing(total_emp_with_owner_2024) & !missing(family_workers)
label var paid_emp_share_2024 "Share of paid employment in total employment (2024)"

** Share of unpaid employment in total employment (2024)
gen unpaid_emp_share_2024 = unpaid_employment_2024 / (total_emp_with_owner_2024 + family_workers) ///
    if !missing(unpaid_employment_2024) & !missing(total_emp_with_owner_2024) & !missing(family_workers)
label var unpaid_emp_share_2024 "Share of unpaid employment in total employment (2024)"








/*==============================================================================
	PDS LASSO-BASED INVERSE PROBABILITY WEIGHTING FOR DIFFERENTIAL ATTRITION                           
==============================================================================*/


global ent_d_contr_ipw "i.Gender i.CIBILscore i.HighestEducation i.Religion i.Community i.MaritalStatus i.OwnRentedHouse i.TypeofDwelling i.CAPBeneficiary i.Typeofownership i.Existingbusiness i.Category_of_enterprise i.Water i.Equipmentavailability i.Skilledlaboravailability i.B2C i.B2B i.Riskmitigationplan i.LoanCategory"

global ent_c_contr_ipw "age_entrepreneur ECP_Score NumberofHouseholdmembers HouseholdIncome HouseholdConsumption HouseholdSavings OtherSourceofincome ActualWorkingCapital TotalFixedCost RequestedLoanAmount Vehicle Householdassets Jewels Cashatbank Cashathand ent_asset_index CurrentSupplyAnnual PresentDemandAnnual"

global controls_ipw "$ent_c_contr_ipw $ent_d_contr_ipw"

pdslasso ent_running treatment_285 ($controls_ipw), cluster(BlockCode)

local selected_vars "`e(xselected)'"
di "Selected variables: `selected_vars'"

logit ent_running `selected_vars' if treatment_285 == 0, cluster(BlockCode)

predict p_survive_control if treatment_285 == 0
**predict p_survive_control, pr if treatment_285==0


sum p_survive_control, detail
histogram p_survive_control, bin(20) title("Distribution of Survival Probabilities") 

gen ipw_new = .
replace ipw_new = 1/p_survive_control if treatment_285 == 0 & ent_running == 1
replace ipw_new = 1 if treatment_285 == 1 & ent_running == 1

histogram ipw if treatment_285 == 0, title("Distribution of Final IPW Weights (Control Group)")





* Annual
gen annual_disbursement_date = yofd(disbursement_date)
format annual_disbursement_date %ty

* Half-yearly (semi-annual)
gen halfyearly_disbursement_date = hofd(disbursement_date)
format halfyearly_disbursement_date %th

variable creation end


surv pr rev bps overall utna nhi before we scale up, piolot run in experiment setup, strategy, segment , invest improve not only size and struture of investment wich is important for firm expansion , working captal not much change, innovation beccuase market linked activity is not strong, BP one item add about market linkage, major high- mployment improve (expansion) not temp which seasonal, but perm increase , MGP long term growth






