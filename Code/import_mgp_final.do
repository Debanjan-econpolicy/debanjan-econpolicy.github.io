* import_mgp_final.do
*
* 	Imports and aggregates "MGP Final" (ID: mgp_final) data.
*
*	Inputs:  "C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final_WIDE.csv"
*	Outputs: "C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final.dta"
*
*	Output by SurveyCTO April 17, 2025 1:10 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final_WIDE.csv"
local dtafile "C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final.dta"
local corrfile "C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid devicephonenum username device_info duration caseid district block panchayat entrepreneur_name pull_mgp_ent sec1_q8 sec2_q1 sec2_q3 sec2_q4 sec2_q5_ifnot sec2_q6 defunct_reasons"
local text_fields2 "nonrepayment_reasons support_sought assistance_type assistance_other future_plan_others sec3_q2_a_oth sec3_q7_a sec3_q3 sec3_q4_oth sec3_q4_1_oth sec3_q4_2_oth sec3_q4_3a sec3_q4_3a_oth"
local text_fields3 "num_peak_months_2022 num_usual_months_2022 num_shutdown_months_2022 num_peak_months_2023 num_usual_months_2023 num_shutdown_months_2023 num_peak_months_2024 num_usual_months_2024"
local text_fields4 "num_shutdown_months_2024 sec5_q2 rep_investment_2024 investment_roster_2024_count investment_id_2024_* investment2024_* sec5_q4_* sec5_q5_* total_investment_2024 num_investment_types_2024 sec5_q7"
local text_fields5 "rep_investment_2023 investment_roster_2023_count investment_id_2023_* investment2023_* sec5_q9_* sec5_q10_* total_investment_2023 num_investment_types_2023 sec5_q12 rep_investment_2022"
local text_fields6 "investment_roster_2022_count investment_id_2022_* investment2022_* sec5_q14_* sec5_q15_* total_investment_2022 num_investment_types_2022 rep_loan_count loan_roster_count loan_id_* loan_*"
local text_fields7 "sec6_q4_others_* sec6_q13_* sec6_q15_* rep_loan_usage_count_* loan_usage_amount_count_* loan_usage_id_* loan_usage_spent_* total_usage_amount_* sec6_q17a_* annual_interest_rate_* sec6_q20_*"
local text_fields8 "sec6_q21_loan_pledge_other_* total_peak_revenue_2024 total_usual_revenue_2024 expected_annual_revenue profit_margin_manufacturing profit_margin_trading profit_margin_service total_peak_revenue_2023"
local text_fields9 "total_usual_revenue_2023 expected_annual_revenue_2023 total_peak_revenue_2022 total_usual_revenue_2022 expected_annual_revenue_2022 sec8_q2 sec8_q2_oth perm_labour_daily_peak perm_labour_daily_usual"
local text_fields10 "perm_labour_monthly_total perm_labour_peak_hours_year perm_labour_usual_hours_year perm_labour_total_hours_year perm_labour_peak_salary perm_labour_usual_salary perm_labour_avg_hourly_wage"
local text_fields11 "temp_labour_monthly_total temp_labour_daily_peak temp_labour_daily_usual temp_labour_peak_hours_year temp_labour_usual_hours_year temp_labour_total_hours_year temp_labour_peak_salary"
local text_fields12 "temp_labour_usual_salary temp_labour_avg_hourly_wage total_workers_2022 total_salary_2022 total_labour_hours_2022 avg_labour_cost_per_hour_2022 labour_cost_per_month_2022 peak_month_labour_cost_2022"
local text_fields13 "usual_month_labour_cost_2022 labour_intensity_ratio sec8_q19 sec8_q19_oth perm_labour_daily_peak_2023 perm_labour_daily_usual_2023 perm_labour_monthly_total_2023 perm_labour_peak_hours_year_2023"
local text_fields14 "perm_labour_usual_hours_year_202 perm_labour_total_hours_year_202 perm_labour_peak_salary_2023 perm_labour_usual_salary_2023 perm_labour_avg_hourly_wage_2023 temp_labour_monthly_total_2023"
local text_fields15 "temp_labour_daily_peak_2023 temp_labour_daily_usual_2023 temp_labour_peak_hours_year_2023 temp_labour_usual_hours_year_202 temp_labour_total_hours_year_202 temp_labour_peak_salary_2023"
local text_fields16 "temp_labour_usual_salary_2023 temp_labour_avg_hourly_wage_2023 total_workers_2023 total_salary_2023 total_labour_hours_2023 avg_labour_cost_per_hour_2023 labour_cost_per_month_2023"
local text_fields17 "peak_month_labour_cost_2023 usual_month_labour_cost_2023 labour_intensity_ratio_2023 sec8_q36 sec8_q36_oth perm_labour_daily_peak_2024 perm_labour_daily_usual_2024 perm_labour_monthly_total_2024"
local text_fields18 "perm_labour_peak_hours_year_2024 perm_labour_usual_hours_year_202 perm_labour_total_hours_year_202 perm_labour_peak_salary_2024 perm_labour_usual_salary_2024 perm_labour_avg_hourly_wage_2024"
local text_fields19 "temp_labour_monthly_total_2024 temp_labour_daily_peak_2024 temp_labour_daily_usual_2024 temp_labour_peak_hours_year_2024 temp_labour_usual_hours_year_202 temp_labour_total_hours_year_202"
local text_fields20 "temp_labour_peak_salary_2024 temp_labour_usual_salary_2024 temp_labour_avg_hourly_wage_2024 total_workers_2024 total_salary_2024 total_labour_hours_2024 avg_labour_cost_per_hour_2024"
local text_fields21 "labour_cost_per_month_2024 peak_month_labour_cost_2024 usual_month_labour_cost_2024 labour_intensity_ratio_2024 sec9_q1 rep_cost_2024 cost_table_2024_count cost_index_2024_* cost2024_* peak_total_2024"
local text_fields22 "usual_total_2024 expected_annual_cost_2024 monthly_avg_cost_2024 peak_month_avg_2024 usual_month_avg_2024 sec9_q8 rep_cost_2023 cost_table_2023_count cost_index_2023_* cost2023_* peak_total_2023"
local text_fields23 "usual_total_2023 expected_annual_cost_2023 monthly_avg_cost_2023 peak_month_avg_2023 usual_month_avg_2023 sec9_q14 rep_cost_2022 cost_table_2022_count cost_index_2022_* cost2022_* peak_total_2022"
local text_fields24 "usual_total_2022 expected_annual_cost_2022 monthly_avg_cost_2022 peak_month_avg_2022 usual_month_avg_2022 sec10_q1 rep_asset_2024 asset_2024_count assets_id_2024_* assets_item_2024_* sec10_q8"
local text_fields25 "rep_asset_2023 asset_2023_count assets_id_2023_* assets_item_2023_* sec10_q15 rep_asset_2022 asset_2022_count assets_id_2022_* assets_item_2022_* sec11_q1_des sec11_q4_oth sec11_q6_des sec11_q10_des"
local text_fields26 "sec11_q14_des risk_score sec16_q4 sec16_q4_other sec16_q9_other sec16_q15_a sec16_q15_a_other sec16_q16 sec16_q16_other sec16_q17_b sec16_q17_c sec16_q19 sec16_q19_other sec16_q21_a sec16_q21_a_other"
local text_fields27 "sec16_q23_b sec16_q23_b_other sec16_q24_b sec16_q24_b_other sec16_q25_a sec16_q25_a_other sec16_q29 sec17_q4 sec17_q4_other sec17_q6_other sec17_q8 rep_mgp_loan_count mgp_loan_utilisation_count"
local text_fields28 "mgp_loan_id_* mgp_utlisation_* sec17_q11 sec17_q11_other sec17_q14_other sec17_q20_other sec17_q25 sec17_q25_other sec17_q27 sec18_q3 sec18_q3_other sec18_q5_other sec18_q8_other sec18_q10"
local text_fields29 "sec18_q10_other rep_contact_count social_contacts_repeat_count contact_index_* sec19_q2_1_* sec19_q2_10a_* sec19_q2_10b_* sec19_q2_10c_* mem_name1 mem_name2 mem_name3 mem_name4 mem_name5 instanceid"
local date_fields1 "defunct_date sec3_q1 sec6_q5_*"
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable supervisor_id "Select Supervisors"
	note supervisor_id: "Select Supervisors"
	label define supervisor_id 1 "Mathiyazhagan K" 2 "Sudhakar R" 3 "Baskar" 4 "Ramaraj"
	label values supervisor_id supervisor_id

	label variable enum_id "Select Enumerators"
	note enum_id: "Select Enumerators"
	label define enum_id 1 "Mathiyazhagan K" 2 "Barath Ganesh" 3 "THAVAMANI M" 4 "M. Sivasathya" 5 "Sumithra" 6 "Mahendran" 7 "Sudhakar R" 8 "Murali M" 9 "Vasanthakumar" 10 "K. Santhoshkumar" 11 "S. NAVANEETHAKRISHNAN" 12 "B. Karthi" 13 "GOWTHAM.S" 14 "Baskar" 15 "Ramesh R" 16 "Azhakarsamy R" 17 "K. RETHINAVEL" 18 "V.BALRAJ" 19 "Arumugam" 20 "SAKTHIVEL M" 21 "Ramaraj" 22 "M VISHNUPRIYAN" 23 "A. Parkavi" 24 "Selvalakahmi" 25 "V.C.Surendiran" 26 "VISHALATCHI"
	label values enum_id enum_id

	label variable district "Select district name"
	note district: "Select district name"

	label variable block "Select block name"
	note block: "Select block name"

	label variable panchayat "Select village panchayat name"
	note panchayat: "Select village panchayat name"

	label variable entrepreneur_name "Select entrepreneur name"
	note entrepreneur_name: "Select entrepreneur name"

	label variable mgp_ben "Are you MGP beneficiary?"
	note mgp_ben: "Are you MGP beneficiary?"
	label define mgp_ben 1 "Yes" 0 "No"
	label values mgp_ben mgp_ben

	label variable sec1_q7 "Does the entrepreneur give consent to give the survey?"
	note sec1_q7: "Does the entrepreneur give consent to give the survey?"
	label define sec1_q7 1 "Yes" 0 "No"
	label values sec1_q7 sec1_q7

	label variable sec1_q8 "What is the reason for not giving consent?"
	note sec1_q8: "What is the reason for not giving consent?"

	label variable sec1_q9 "Is this enterprise still running?"
	note sec1_q9: "Is this enterprise still running?"
	label define sec1_q9 1 "Yes, still running" 2 "No, it is defunct"
	label values sec1_q9 sec1_q9

	label variable survey_mode "Is this survey Telephonic or In-person?"
	note survey_mode: "Is this survey Telephonic or In-person?"
	label define survey_mode 1 "In-person" 2 "Telephone"
	label values survey_mode survey_mode

	label variable sec2_q1 "What is your enterprise name?"
	note sec2_q1: "What is your enterprise name?"

	label variable sec2_q2 "Nature of the enterprise"
	note sec2_q2: "Nature of the enterprise"
	label define sec2_q2 1 "Manufacturing (E.g. Making food products, textiles, furniture, handicrafts, proc" 2 "Trade/Retail/Sales (E.g. Shop keeping, wholesale trading, selling goods without " 3 "Services (E.g.: Repairs, transportation, beauty parlours, tailoring, professiona"
	label values sec2_q2 sec2_q2

	label variable sec2_q3 "Name of enterprise Owner (legal name)"
	note sec2_q3: "Name of enterprise Owner (legal name)"

	label variable sec2_q3a "Gener of the enterprise owner"
	note sec2_q3a: "Gener of the enterprise owner"
	label define sec2_q3a 0 "Male" 1 "Female" 2 "Others"
	label values sec2_q3a sec2_q3a

	label variable sec2_q4 "Enterprise Address"
	note sec2_q4: "Enterprise Address"

	label variable sec2_q5 "Home Address"
	note sec2_q5: "Home Address"
	label define sec2_q5 1 "Same as enterprise address" 2 "Different than enterprise address"
	label values sec2_q5 sec2_q5

	label variable sec2_q5_ifnot "Please specify the home address"
	note sec2_q5_ifnot: "Please specify the home address"

	label variable sec2_q6 "Primary phone number of the entrepreneur"
	note sec2_q6: "Primary phone number of the entrepreneur"

	label variable start_business "Did you start the business?"
	note start_business: "Did you start the business?"
	label define start_business 1 "Yes" 0 "No"
	label values start_business start_business

	label variable defunct_date "When did the enterprise stop operating?"
	note defunct_date: "When did the enterprise stop operating?"

	label variable defunct_stage "At what stage did the enterprise become defunct?"
	note defunct_stage: "At what stage did the enterprise become defunct?"
	label define defunct_stage 1 "Before receiving MGP/bank loan" 2 "After applying but before loan sanctioning" 3 "After loan sanctioning but before disbursement" 4 "Within 6 months of loan disbursement" 5 "Between 6-12 months of loan disbursement" 6 "Between 12-18 months of loan disbursement" 7 "After 18 months of loan disbursement" 8 "Before rejecting MGP application" 9 "After rejecting MGP application"
	label values defunct_stage defunct_stage

	label variable defunct_reasons "What were the primary reasons for the enterprise becoming defunct?"
	note defunct_reasons: "What were the primary reasons for the enterprise becoming defunct?"

	label variable defunct_loan_status "What was the status of MGP loan repayment when the enterprise became defunct?"
	note defunct_loan_status: "What was the status of MGP loan repayment when the enterprise became defunct?"
	label define defunct_loan_status 1 "Fully repaid" 2 "Partially repaid" 3 "No repayment made"
	label values defunct_loan_status defunct_loan_status

	label variable defunct_loan_repayment_percent "Specify percentage repaid og MGP loan"
	note defunct_loan_repayment_percent: "Specify percentage repaid og MGP loan"

	label variable nonrepayment_reasons "What were the reasons for partial or no repayment?"
	note nonrepayment_reasons: "What were the reasons for partial or no repayment?"

	label variable support_sought "Did you seek any support before closing the enterprise?"
	note support_sought: "Did you seek any support before closing the enterprise?"

	label variable assistance_type "What kind of assistance was requested?"
	note assistance_type: "What kind of assistance was requested?"

	label variable assistance_other "Specify other assistance"
	note assistance_other: "Specify other assistance"

	label variable future_plans "What are your current/future business plans?"
	note future_plans: "What are your current/future business plans?"
	label define future_plans 1 "Planning to restart same business." 2 "Planning to start different business." 3 "Already started new business" 4 "Working as employed" 5 "No business plans." 88 "Others (specify) _______"
	label values future_plans future_plans

	label variable future_plan_others "Specify other future plans"
	note future_plan_others: "Specify other future plans"

	label variable sec3_q1 "Year of establishment of the enterprise?"
	note sec3_q1: "Year of establishment of the enterprise?"

	label variable sec3_q2 "Whether the enterprise is registered?"
	note sec3_q2: "Whether the enterprise is registered?"
	label define sec3_q2 1 "Yes" 0 "No"
	label values sec3_q2 sec3_q2

	label variable sec3_q2_1 "Whether enterprise is registered with Udyam Aadhar?"
	note sec3_q2_1: "Whether enterprise is registered with Udyam Aadhar?"
	label define sec3_q2_1 1 "Yes" 0 "No"
	label values sec3_q2_1 sec3_q2_1

	label variable sec3_q2_a "What is the type of registration?"
	note sec3_q2_a: "What is the type of registration?"
	label define sec3_q2_a 1 "Individual/Sole proprietorship" 2 "Partnership" 3 "Private company" 88 "Other (specify)" 99 "Don’t know/Can’t say/reject"
	label values sec3_q2_a sec3_q2_a

	label variable sec3_q2_a_oth "Please specify the type of registration"
	note sec3_q2_a_oth: "Please specify the type of registration"

	label variable sec3_q2_a_1 "Then the number of partners"
	note sec3_q2_a_1: "Then the number of partners"

	label variable sec3_q2_a_2 "How much did you invest to start the business? (in Rs.)"
	note sec3_q2_a_2: "How much did you invest to start the business? (in Rs.)"

	label variable sec3_q7 "Are you working with other member of SHG (Self Help Group) as part of group ente"
	note sec3_q7: "Are you working with other member of SHG (Self Help Group) as part of group enterprise?"
	label define sec3_q7 1 "Yes" 0 "No"
	label values sec3_q7 sec3_q7

	label variable sec3_q7_a "Please describe the activity (in 2-3 words)"
	note sec3_q7_a: "Please describe the activity (in 2-3 words)"

	label variable sec3_q3 "Describe the enterprise activities (in 2-4 words)"
	note sec3_q3: "Describe the enterprise activities (in 2-4 words)"

	label variable sec3_q4 "Where is the enterprise currently operating from?"
	note sec3_q4: "Where is the enterprise currently operating from?"
	label define sec3_q4 1 "Home/Home front" 2 "Standalone shop (own)" 3 "Rented shop" 4 "Street vendor" 88 "Others (specify)"
	label values sec3_q4 sec3_q4

	label variable sec3_q4_oth "Please specify from where enterprise is operated"
	note sec3_q4_oth: "Please specify from where enterprise is operated"

	label variable sec3_q4_1 "When you started your business, where were you operating from?"
	note sec3_q4_1: "When you started your business, where were you operating from?"
	label define sec3_q4_1 1 "Home/Home front" 2 "Standalone shop (own)" 3 "Rented shop" 4 "Street vendor (stationary)" 5 "No fixed location" 88 "Others (specify)"
	label values sec3_q4_1 sec3_q4_1

	label variable sec3_q4_1_oth "Please specify from where enterprise is operated when is started"
	note sec3_q4_1_oth: "Please specify from where enterprise is operated when is started"

	label variable sec3_q4_2 "Primary reason for changing location"
	note sec3_q4_2: "Primary reason for changing location"
	label define sec3_q4_2 1 "Business expansion" 2 "Better market access" 3 "More space needed" 4 "Separate business identity" 5 "Family/personal reasons" 6 "Loan enabled the shift" 88 "Others (specify)_______"
	label values sec3_q4_2 sec3_q4_2

	label variable sec3_q4_2_oth "Please specify other reasons"
	note sec3_q4_2_oth: "Please specify other reasons"

	label variable sec3_q4_3a "How did you fund the change in the enterprise location?"
	note sec3_q4_3a: "How did you fund the change in the enterprise location?"

	label variable sec3_q4_3a_oth "Please specify how did you fund the change for enterprise location"
	note sec3_q4_3a_oth: "Please specify how did you fund the change for enterprise location"

	label variable sec3_q5 "Which of the following describes the location of the enterprise?"
	note sec3_q5: "Which of the following describes the location of the enterprise?"
	label define sec3_q5 1 "Located in a main marketplace" 2 "Located in a secondary marketplace" 3 "Located on a quiet street with other businesses around" 4 "Located in a residential area"
	label values sec3_q5 sec3_q5

	label variable sec3_q6 "Which category do you belong to?"
	note sec3_q6: "Which category do you belong to?"
	label define sec3_q6 1 "SHG member (Entrepreneur is personally a member of an SHG)" 2 "SHG Household (Any family member is part of SHG, but entrepreneur is not a membe" 3 "Non-SHG woman (Neither entrepreneur nor any family members are part of a any SHG"
	label values sec3_q6 sec3_q6

	label variable sec4_q1 "Marital Status of the enterprise owner"
	note sec4_q1: "Marital Status of the enterprise owner"
	label define sec4_q1 1 "Single/Never Married" 2 "Married" 3 "Widowed" 4 "Divorced/Seperated"
	label values sec4_q1 sec4_q1

	label variable sec4_q1_a "What was your age at the time of your marriage? (If married more than once, reco"
	note sec4_q1_a: "What was your age at the time of your marriage? (If married more than once, record the age of the first marriage)"

	label variable sec4_q2 "Highest education completed by entrepreneur"
	note sec4_q2: "Highest education completed by entrepreneur"
	label define sec4_q2 1 "Class 1" 2 "Class 2" 3 "Class 3" 4 "Class 4" 5 "Class 5" 6 "Class 6" 7 "Class 7" 8 "Class 8" 9 "Class 9" 10 "Class 10" 11 "Class 11" 12 "Class 12" 13 "Graduation" 14 "Post-Graduation" 15 "Professional (such as CA/CS/ICWA/LLB/MBA/MCA, etc.)" 16 "Literate but No formal Education" 17 "Illiterate" 18 "Preschooling" 19 "Infant/kid" 20 "Vocational training (polytechnic/ITI/Diploma)"
	label values sec4_q2 sec4_q2

	label variable sec4_q3 "How many household members (excluding yourself) have worked in the enterprise ov"
	note sec4_q3: "How many household members (excluding yourself) have worked in the enterprise over the past 12 months? (As on today)?"

	label variable sec4_q3_a "How many of these household members have been working for the enterprise with pa"
	note sec4_q3_a: "How many of these household members have been working for the enterprise with pay?"

	label variable sec4_q3_b "How many of these household members are/were working without pay?"
	note sec4_q3_b: "How many of these household members are/were working without pay?"

	label variable operational_2022 "Was your business operational at any point during the year 2022?"
	note operational_2022: "Was your business operational at any point during the year 2022?"
	label define operational_2022 1 "Yes" 0 "No"
	label values operational_2022 operational_2022

	label variable ops_2022 "Please indicate whether each month was a peak, usual, or shut down period for yo"
	note ops_2022: "Please indicate whether each month was a peak, usual, or shut down period for your business."
	label define ops_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values ops_2022 ops_2022

	label variable jan_2022 "January 2022"
	note jan_2022: "January 2022"
	label define jan_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jan_2022 jan_2022

	label variable feb_2022 "February 2022"
	note feb_2022: "February 2022"
	label define feb_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values feb_2022 feb_2022

	label variable mar_2022 "March-2022"
	note mar_2022: "March-2022"
	label define mar_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values mar_2022 mar_2022

	label variable apr_2022 "April-2022"
	note apr_2022: "April-2022"
	label define apr_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values apr_2022 apr_2022

	label variable may_2022 "May-2022"
	note may_2022: "May-2022"
	label define may_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values may_2022 may_2022

	label variable jun_2022 "June-2022"
	note jun_2022: "June-2022"
	label define jun_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jun_2022 jun_2022

	label variable jul_2022 "July-2022"
	note jul_2022: "July-2022"
	label define jul_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jul_2022 jul_2022

	label variable aug_2022 "August-2022"
	note aug_2022: "August-2022"
	label define aug_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values aug_2022 aug_2022

	label variable sep_2022 "September-2022"
	note sep_2022: "September-2022"
	label define sep_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values sep_2022 sep_2022

	label variable oct_2022 "October-2022"
	note oct_2022: "October-2022"
	label define oct_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values oct_2022 oct_2022

	label variable nov_2022 "November-2022"
	note nov_2022: "November-2022"
	label define nov_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values nov_2022 nov_2022

	label variable dec_2022 "December-2022"
	note dec_2022: "December-2022"
	label define dec_2022 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values dec_2022 dec_2022

	label variable shutdown_cost_2022 "Cost incurred during shutdown periods in 2022"
	note shutdown_cost_2022: "Cost incurred during shutdown periods in 2022"

	label variable operational_2023 "Was your business operational at any point during the year 2023?"
	note operational_2023: "Was your business operational at any point during the year 2023?"
	label define operational_2023 1 "Yes" 0 "No"
	label values operational_2023 operational_2023

	label variable ops_2023 "Please indicate whether each month was a peak, usual, or shut down period for yo"
	note ops_2023: "Please indicate whether each month was a peak, usual, or shut down period for your business in 2023."
	label define ops_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values ops_2023 ops_2023

	label variable jan_2023 "January-2023"
	note jan_2023: "January-2023"
	label define jan_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jan_2023 jan_2023

	label variable feb_2023 "February-2023"
	note feb_2023: "February-2023"
	label define feb_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values feb_2023 feb_2023

	label variable mar_2023 "March-2023"
	note mar_2023: "March-2023"
	label define mar_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values mar_2023 mar_2023

	label variable apr_2023 "April-2023"
	note apr_2023: "April-2023"
	label define apr_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values apr_2023 apr_2023

	label variable may_2023 "May-2023"
	note may_2023: "May-2023"
	label define may_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values may_2023 may_2023

	label variable jun_2023 "June-2023"
	note jun_2023: "June-2023"
	label define jun_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jun_2023 jun_2023

	label variable jul_2023 "July-2023"
	note jul_2023: "July-2023"
	label define jul_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jul_2023 jul_2023

	label variable aug_2023 "August-2023"
	note aug_2023: "August-2023"
	label define aug_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values aug_2023 aug_2023

	label variable sep_2023 "September-2023"
	note sep_2023: "September-2023"
	label define sep_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values sep_2023 sep_2023

	label variable oct_2023 "October-2023"
	note oct_2023: "October-2023"
	label define oct_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values oct_2023 oct_2023

	label variable nov_2023 "November-2023"
	note nov_2023: "November-2023"
	label define nov_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values nov_2023 nov_2023

	label variable dec_2023 "December-2023"
	note dec_2023: "December-2023"
	label define dec_2023 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values dec_2023 dec_2023

	label variable shutdown_cost_2023 "Cost incurred during shutdown periods in 2023"
	note shutdown_cost_2023: "Cost incurred during shutdown periods in 2023"

	label variable operational_2024 "Was your business operational at any point during the year 2024?"
	note operational_2024: "Was your business operational at any point during the year 2024?"
	label define operational_2024 1 "Yes" 0 "No"
	label values operational_2024 operational_2024

	label variable ops_2024 "Please indicate whether each month is/will be a peak, usual, or shut down period"
	note ops_2024: "Please indicate whether each month is/will be a peak, usual, or shut down period for your business in 2024."
	label define ops_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values ops_2024 ops_2024

	label variable jan_2024 "January-2024"
	note jan_2024: "January-2024"
	label define jan_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jan_2024 jan_2024

	label variable feb_2024 "February-2024"
	note feb_2024: "February-2024"
	label define feb_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values feb_2024 feb_2024

	label variable mar_2024 "March-2024"
	note mar_2024: "March-2024"
	label define mar_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values mar_2024 mar_2024

	label variable apr_2024 "April-2024"
	note apr_2024: "April-2024"
	label define apr_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values apr_2024 apr_2024

	label variable may_2024 "May-2024"
	note may_2024: "May-2024"
	label define may_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values may_2024 may_2024

	label variable jun_2024 "June-2024"
	note jun_2024: "June-2024"
	label define jun_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jun_2024 jun_2024

	label variable jul_2024 "July-2024"
	note jul_2024: "July-2024"
	label define jul_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values jul_2024 jul_2024

	label variable aug_2024 "August-2024"
	note aug_2024: "August-2024"
	label define aug_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values aug_2024 aug_2024

	label variable sep_2024 "September-2024"
	note sep_2024: "September-2024"
	label define sep_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values sep_2024 sep_2024

	label variable oct_2024 "October-2024"
	note oct_2024: "October-2024"
	label define oct_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values oct_2024 oct_2024

	label variable nov_2024 "November-2024"
	note nov_2024: "November-2024"
	label define nov_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values nov_2024 nov_2024

	label variable dec_2024 "December-2024"
	note dec_2024: "December-2024"
	label define dec_2024 1 "Peak" 2 "Usual (including off-peak)" 3 "No operation/ Shut down period"
	label values dec_2024 dec_2024

	label variable shutdown_cost_2024 "Cost incurred during shutdown periods in 2024"
	note shutdown_cost_2024: "Cost incurred during shutdown periods in 2024"

	label variable ent_facility_internet "Does the enterprise have access to an internet connection dedicated for business"
	note ent_facility_internet: "Does the enterprise have access to an internet connection dedicated for business use (e.g., broadband, Wi-Fi)?"
	label define ent_facility_internet 1 "Yes" 0 "No"
	label values ent_facility_internet ent_facility_internet

	label variable ent_facility_storage "Does the enterprise have storage space/warehouse?"
	note ent_facility_storage: "Does the enterprise have storage space/warehouse?"
	label define ent_facility_storage 1 "Yes" 0 "No"
	label values ent_facility_storage ent_facility_storage

	label variable sec4_q6_1 "In a typical week, how many days do you spend working in your business?"
	note sec4_q6_1: "In a typical week, how many days do you spend working in your business?"

	label variable sec4_q6_2 "On those typical days, how many hours do you actively work on business activitie"
	note sec4_q6_2: "On those typical days, how many hours do you actively work on business activities?"

	label variable sec4_q6_3 "During your peak week, how many days do you work?"
	note sec4_q6_3: "During your peak week, how many days do you work?"

	label variable sec4_q6_4 "During those peak days, how many hours do you work?"
	note sec4_q6_4: "During those peak days, how many hours do you work?"

	label variable sec4_q6_5 "In the last week, how many days did you work on your business?"
	note sec4_q6_5: "In the last week, how many days did you work on your business?"

	label variable sec4_q6_6 "In the last week, how many total hours did you spend on business activities?"
	note sec4_q6_6: "In the last week, how many total hours did you spend on business activities?"

	label variable sec4_q6_7 "In the last week, how many hours did you spend on immediately required tasks?"
	note sec4_q6_7: "In the last week, how many hours did you spend on immediately required tasks?"

	label variable sec4_q6_8 "In the last week, how many hours did you spend on tasks beyond immediate require"
	note sec4_q6_8: "In the last week, how many hours did you spend on tasks beyond immediate requirements?"

	label variable sec5_q1 "Whether any amount invested during January 2024 - December 2024?"
	note sec5_q1: "Whether any amount invested during January 2024 - December 2024?"
	label define sec5_q1 1 "Yes" 0 "No"
	label values sec5_q1 sec5_q1

	label variable sec5_q2 "Type(s) of investment made during January 2024 - December 2024?"
	note sec5_q2: "Type(s) of investment made during January 2024 - December 2024?"

	label variable confirm_total_2024 "Is this total correct?"
	note confirm_total_2024: "Is this total correct?"
	label define confirm_total_2024 1 "Yes" 0 "No"
	label values confirm_total_2024 confirm_total_2024

	label variable sec5_q6 "Whether any amount invested during January 2023- December 2023?"
	note sec5_q6: "Whether any amount invested during January 2023- December 2023?"
	label define sec5_q6 1 "Yes" 0 "No"
	label values sec5_q6 sec5_q6

	label variable sec5_q7 "Type(s) of investment made during January 2023- December 2023?"
	note sec5_q7: "Type(s) of investment made during January 2023- December 2023?"

	label variable confirm_total_2023 "Is this total correct?"
	note confirm_total_2023: "Is this total correct?"
	label define confirm_total_2023 1 "Yes" 0 "No"
	label values confirm_total_2023 confirm_total_2023

	label variable sec5_q11 "Whether any amount invested during January 2022- December 2022?"
	note sec5_q11: "Whether any amount invested during January 2022- December 2022?"
	label define sec5_q11 1 "Yes" 0 "No"
	label values sec5_q11 sec5_q11

	label variable sec5_q12 "Type of investment made during January 2022- December 2022?"
	note sec5_q12: "Type of investment made during January 2022- December 2022?"

	label variable confirm_total_2022 "Is this total correct?"
	note confirm_total_2022: "Is this total correct?"
	label define confirm_total_2022 1 "Yes" 0 "No"
	label values confirm_total_2022 confirm_total_2022

	label variable sec6_q1 "Has the enterprise taken any loans from any source in the last five years?"
	note sec6_q1: "Has the enterprise taken any loans from any source in the last five years?"
	label define sec6_q1 1 "Yes" 0 "No"
	label values sec6_q1 sec6_q1

	label variable sec6_q2 "What are the reasons for not taking the loan?"
	note sec6_q2: "What are the reasons for not taking the loan?"
	label define sec6_q2 1 "No requirement" 2 "High-interest rate" 3 "Collateral required" 4 "Complicated process" 5 "Loan averse" 6 "Low repayment capacity" 7 "Social structure"
	label values sec6_q2 sec6_q2

	label variable sec6_q3 "Total numbers of loans have been taken by the enterprise in the last five years?"
	note sec6_q3: "Total numbers of loans have been taken by the enterprise in the last five years? (Consider all loans taken by the enterprise in the last 5 years, including both active and fully repaid loans)"

	label variable sec7_q3 "What was your total annual revenue from January to December 2024? (total revenue"
	note sec7_q3: "What was your total annual revenue from January to December 2024? (total revenue during 12 months)"

	label variable sec7_q1 "What was your average monthly revenue during peak months between January 2024 an"
	note sec7_q1: "What was your average monthly revenue during peak months between January 2024 and December 2024? (in Rs.)"

	label variable sec7_q2 "What was your average monthly revenue during usual months between January 2024 a"
	note sec7_q2: "What was your average monthly revenue during usual months between January 2024 and December 2024? (in Rs.)"

	label variable rev_verify_2024_confirm "Is this correct? If not, you can go back and adjust the amounts."
	note rev_verify_2024_confirm: "Is this correct? If not, you can go back and adjust the amounts."
	label define rev_verify_2024_confirm 1 "Yes" 0 "No"
	label values rev_verify_2024_confirm rev_verify_2024_confirm

	label variable sec7_q4 "Please tell me the total monthly sales of your enterprise in January 2025 (i.e. "
	note sec7_q4: "Please tell me the total monthly sales of your enterprise in January 2025 (i.e. last month) from all sources? (in Rs.)"

	label variable sec7_q5 "During peak months in 2024, what percentage of sales came from electronic source"
	note sec7_q5: "During peak months in 2024, what percentage of sales came from electronic sources (UPI, debit, credit cards)?"

	label variable sec7_q6 "During usual months in 2024, what percentage of sales came from electronic sourc"
	note sec7_q6: "During usual months in 2024, what percentage of sales came from electronic sources (UPI, debit, credit cards)?"

	label variable sec7_q7 "What were the profits of your enterprise during last month. (It is basically tot"
	note sec7_q7: "What were the profits of your enterprise during last month. (It is basically total income enterprise earned during last month after paying all the expenses including wages of employees, but not including any income you paid yourself. If you paid yourself a salary, add that back into your profits)"

	label variable sec7_q8 "If you buy Rs. 1000 worth of materials today, how much of revenue will you recei"
	note sec7_q8: "If you buy Rs. 1000 worth of materials today, how much of revenue will you receive from the sale of the products that you manufacture from these materials? (In Rs)"

	label variable confirm_manufacturing_margin "Is it correct?"
	note confirm_manufacturing_margin: "Is it correct?"
	label define confirm_manufacturing_margin 1 "Yes" 0 "No"
	label values confirm_manufacturing_margin confirm_manufacturing_margin

	label variable sec7_q9 "If you buy Rs. 1000 worth of products today, how much of revenue will you receiv"
	note sec7_q9: "If you buy Rs. 1000 worth of products today, how much of revenue will you receive from the sale of the products that you trade?"

	label variable confirm_trading_margin "Is it correct?"
	note confirm_trading_margin: "Is it correct?"
	label define confirm_trading_margin 1 "Yes" 0 "No"
	label values confirm_trading_margin confirm_trading_margin

	label variable sec7_q10 "If you spend Rs. 1000 and buy of products to give a service today, how much of r"
	note sec7_q10: "If you spend Rs. 1000 and buy of products to give a service today, how much of revenue will you receive from the sale of service?"

	label variable confirm_service_margin "Is it correct?"
	note confirm_service_margin: "Is it correct?"
	label define confirm_service_margin 1 "Yes" 0 "No"
	label values confirm_service_margin confirm_service_margin

	label variable sec7_q13 "What was your total annual revenue from January to December 2023? (total revenue"
	note sec7_q13: "What was your total annual revenue from January to December 2023? (total revenue during 12 months)"

	label variable sec7_q11 "What was your average monthly revenue during peak months between January 2023 to"
	note sec7_q11: "What was your average monthly revenue during peak months between January 2023 to December,2023? (in Rs.)"

	label variable sec7_q12 "What was your average monthly revenue during usual months between January 2023 t"
	note sec7_q12: "What was your average monthly revenue during usual months between January 2023 to December,2023? (in Rs.)"

	label variable rev_verify_2023_confirm "Is this correct? If not, you can go back and adjust the amounts."
	note rev_verify_2023_confirm: "Is this correct? If not, you can go back and adjust the amounts."
	label define rev_verify_2023_confirm 1 "Yes" 0 "No"
	label values rev_verify_2023_confirm rev_verify_2023_confirm

	label variable sec7_q14 "During peak months in 2023, what percentage of sales came from electronic source"
	note sec7_q14: "During peak months in 2023, what percentage of sales came from electronic sources such as UPI, debit, or credit cards? (Enter a percentage between 0 and 100)"

	label variable sec7_q15 "During usual months in 2023, what percentage of sales came from electronic sourc"
	note sec7_q15: "During usual months in 2023, what percentage of sales came from electronic sources such as UPI, debit, or credit cards? (Enter a percentage between 0 and 100)"

	label variable sec7_q18 "What was your total annual revenue from January to December 2022? (total revenue"
	note sec7_q18: "What was your total annual revenue from January to December 2022? (total revenue during 12 months)"

	label variable sec7_q16 "What was your average monthly revenue during peak months between January 2022 to"
	note sec7_q16: "What was your average monthly revenue during peak months between January 2022 to December 2022 ? (in Rs.)"

	label variable sec7_q17 "What was your average monthly revenue during usual months between January 2022 t"
	note sec7_q17: "What was your average monthly revenue during usual months between January 2022 to December 2022? (in Rs.)"

	label variable rev_verify_2022_confirm "Is this correct? If not, you can go back and adjust the amounts."
	note rev_verify_2022_confirm: "Is this correct? If not, you can go back and adjust the amounts."
	label define rev_verify_2022_confirm 1 "Yes" 0 "No"
	label values rev_verify_2022_confirm rev_verify_2022_confirm

	label variable sec7_q19 "During peak months in 2022, what percentage of sales came from electronic source"
	note sec7_q19: "During peak months in 2022, what percentage of sales came from electronic sources such as UPI, debit, or credit cards? (Enter a percentage between 0 and 100)"

	label variable sec7_q20 "During usual months in 2022, what percentage of sales came from electronic sourc"
	note sec7_q20: "During usual months in 2022, what percentage of sales came from electronic sources such as UPI, debit, or credit cards? (Enter a percentage between 0 and 100)"

	label variable sec8_q1 "Did your enterprise employ any workers between January 2022 and December 2022? ("
	note sec8_q1: "Did your enterprise employ any workers between January 2022 and December 2022? (Include all types of workers—family members, permanent employees, and temporary workers)"
	label define sec8_q1 1 "Yes" 0 "No"
	label values sec8_q1 sec8_q1

	label variable sec8_q2 "What was the reason for not hiring? (Select all that apply)"
	note sec8_q2: "What was the reason for not hiring? (Select all that apply)"

	label variable sec8_q2_oth "Please specify why have you not hired"
	note sec8_q2_oth: "Please specify why have you not hired"

	label variable sec8_q3 "How many permanent labourers (family and non-family) did you employ during 2022?"
	note sec8_q3: "How many permanent labourers (family and non-family) did you employ during 2022? (Permanent labourers are those who worked regularly throughout the year)"

	label variable sec8_q4 "What was the average monthly salary per permanent Labourer (in Rs.)? (If each pe"
	note sec8_q4: "What was the average monthly salary per permanent Labourer (in Rs.)? (If each permanent worker received an average of 12,000 Rs. per month, enter '12,000'')"

	label variable sec8_q5 "What were the average working hours per day on peak days for permanent labourers"
	note sec8_q5: "What were the average working hours per day on peak days for permanent labourers?"

	label variable sec8_q6 "What were the average working hours per day on usual days for permanent labourer"
	note sec8_q6: "What were the average working hours per day on usual days for permanent labourers?"

	label variable sec8_q7 "What were the average working days per month in peak months for permanent labour"
	note sec8_q7: "What were the average working days per month in peak months for permanent labourers?"

	label variable sec8_q8 "What were the average working days per month in usual months for permanent labou"
	note sec8_q8: "What were the average working days per month in usual months for permanent labourers?"

	label variable sec8_q9 "What was the total salary paid to permanent labourers (in Rs.) during 2022"
	note sec8_q9: "What was the total salary paid to permanent labourers (in Rs.) during 2022"

	label variable sec8_q10 "How many temporary labourers (family and non-family) did you employ during 2022?"
	note sec8_q10: "How many temporary labourers (family and non-family) did you employ during 2022? (Temporary labourers are those who work for short periods or seasonally)"

	label variable sec8_q11 "What was the average daily wage paid to a temporary Labourer during 2022 on peak"
	note sec8_q11: "What was the average daily wage paid to a temporary Labourer during 2022 on peak days (Days when business activity is at its highest)? (in Rs.)"

	label variable sec8_q12 "What was the average daily wage paid to a temporary Labourer during 2022 on usua"
	note sec8_q12: "What was the average daily wage paid to a temporary Labourer during 2022 on usual days (Regular working days)? (in Rs.)"

	label variable sec8_q13 "On peak days during 2022, what was the average number of working hours per day f"
	note sec8_q13: "On peak days during 2022, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q14 "On usual days during 2022, what was the average number of working hours per day "
	note sec8_q14: "On usual days during 2022, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q15 "In peak months during 2022, what was the average number of working days per mont"
	note sec8_q15: "In peak months during 2022, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q16 "In usual months during 2022, what was the average number of working days per mon"
	note sec8_q16: "In usual months during 2022, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q17 "What was the total salary paid to temporary labourers (in Rs.) during 2022"
	note sec8_q17: "What was the total salary paid to temporary labourers (in Rs.) during 2022"

	label variable sec8_q18 "Did your enterprise employ any workers between January 2023 and December 2023? ("
	note sec8_q18: "Did your enterprise employ any workers between January 2023 and December 2023? (Include all types of workers—family members, permanent employees, and temporary workers)"
	label define sec8_q18 1 "Yes" 0 "No"
	label values sec8_q18 sec8_q18

	label variable sec8_q19 "What was the reason for not hiring? (Select all that apply)"
	note sec8_q19: "What was the reason for not hiring? (Select all that apply)"

	label variable sec8_q19_oth "Please specify why have you not hired"
	note sec8_q19_oth: "Please specify why have you not hired"

	label variable sec8_q20 "How many permanent labourers (family and non-family) did you employ during 2023?"
	note sec8_q20: "How many permanent labourers (family and non-family) did you employ during 2023?"

	label variable sec8_q21 "What was the average monthly salary per permanent labourer (in Rs.)?"
	note sec8_q21: "What was the average monthly salary per permanent labourer (in Rs.)?"

	label variable sec8_q22 "What were the average working hours per day on peak days for permanent labourer?"
	note sec8_q22: "What were the average working hours per day on peak days for permanent labourer?"

	label variable sec8_q23 "What were the average working hours per day on usual days for permanent labourer"
	note sec8_q23: "What were the average working hours per day on usual days for permanent labourer?"

	label variable sec8_q24 "What were the average working days per month in peak months for permanent labour"
	note sec8_q24: "What were the average working days per month in peak months for permanent labourer?"

	label variable sec8_q25 "What were the average working days per month in usual months for permanent labou"
	note sec8_q25: "What were the average working days per month in usual months for permanent labourer?"

	label variable sec8_q26 "What was the total salary paid to permanent labourer (in Rs.) during 2023"
	note sec8_q26: "What was the total salary paid to permanent labourer (in Rs.) during 2023"

	label variable sec8_q27 "How many temporary labourers (family and non-family) did you employ during 2023?"
	note sec8_q27: "How many temporary labourers (family and non-family) did you employ during 2023?"

	label variable sec8_q28 "What was the average daily wage paid to a temporary Labourer during 2023 on peak"
	note sec8_q28: "What was the average daily wage paid to a temporary Labourer during 2023 on peak days (days when business activity is at its highest)? (in Rs.)"

	label variable sec8_q29 "What was the average daily wage paid to a temporary Labourer during 2023 on usua"
	note sec8_q29: "What was the average daily wage paid to a temporary Labourer during 2023 on usual days (regular working days)? (in Rs.)"

	label variable sec8_q30 "On peak days during 2023, what was the average number of working hours per day f"
	note sec8_q30: "On peak days during 2023, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q31 "On usual days during 2023, what was the average number of working hours per day "
	note sec8_q31: "On usual days during 2023, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q32 "In peak months during 2023, what was the average number of working days per mont"
	note sec8_q32: "In peak months during 2023, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q33 "In usual months during 2023, what was the average number of working days per mon"
	note sec8_q33: "In usual months during 2023, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q34 "What was the total salary paid to temporary labourers (in Rs.) during 2023"
	note sec8_q34: "What was the total salary paid to temporary labourers (in Rs.) during 2023"

	label variable sec8_q35 "Did your enterprise employ any workers between January 2024 and December 2024? ("
	note sec8_q35: "Did your enterprise employ any workers between January 2024 and December 2024? (Include all types of workers—family members, permanent employees, and temporary workers)"
	label define sec8_q35 1 "Yes" 0 "No"
	label values sec8_q35 sec8_q35

	label variable sec8_q36 "What was the reason for not hiring? (Select all that apply)"
	note sec8_q36: "What was the reason for not hiring? (Select all that apply)"

	label variable sec8_q36_oth "Please specify why have you not hired"
	note sec8_q36_oth: "Please specify why have you not hired"

	label variable sec8_q37 "How many permanent labourers (family and non-family) did you employ between Janu"
	note sec8_q37: "How many permanent labourers (family and non-family) did you employ between January 2024 and December 2024?"

	label variable sec8_q38 "What was the average monthly salary per permanent Labourer (in Rs.)? (Include ca"
	note sec8_q38: "What was the average monthly salary per permanent Labourer (in Rs.)? (Include cash and estimated value of in-kind payments)"

	label variable sec8_q39 "What were the average working hours per day on peak days for permanent labourers"
	note sec8_q39: "What were the average working hours per day on peak days for permanent labourers?"

	label variable sec8_q40 "What were the average working hours per day on usual days for permanent labourer"
	note sec8_q40: "What were the average working hours per day on usual days for permanent labourers?"

	label variable sec8_q41 "What were the average working days per month in peak months for permanent labour"
	note sec8_q41: "What were the average working days per month in peak months for permanent labourers?"

	label variable sec8_q42 "What were the average working days per month in usual months for permanent labou"
	note sec8_q42: "What were the average working days per month in usual months for permanent labourers?"

	label variable sec8_q43 "What was the total salary paid to permanent labourers (in Rs.) during 2024"
	note sec8_q43: "What was the total salary paid to permanent labourers (in Rs.) during 2024"

	label variable sec8_q44 "How many temporary labourers (family and non-family) did you employ between Janu"
	note sec8_q44: "How many temporary labourers (family and non-family) did you employ between January 2024 and December 2024?"

	label variable sec8_q45 "What was the average daily wage paid to a temporary Labourer during 2024 on peak"
	note sec8_q45: "What was the average daily wage paid to a temporary Labourer during 2024 on peak days (days when business activity is at its highest)? (in Rs.)"

	label variable sec8_q46 "What was the average daily wage paid to a temporary Labourer during 2024 on usua"
	note sec8_q46: "What was the average daily wage paid to a temporary Labourer during 2024 on usual days (regular working days)? (in Rs.)"

	label variable sec8_q47 "On peak days during 2024, what was the average number of working hours per day f"
	note sec8_q47: "On peak days during 2024, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q48 "On usual days during 2024, what was the average number of working hours per day "
	note sec8_q48: "On usual days during 2024, what was the average number of working hours per day for a temporary Labourer?"

	label variable sec8_q49 "In peak months during 2024, what was the average number of working days per mont"
	note sec8_q49: "In peak months during 2024, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q50 "In usual months during 2024, what was the average number of working days per mon"
	note sec8_q50: "In usual months during 2024, what was the average number of working days per month for a temporary Labourer?"

	label variable sec8_q51 "What was the total salary paid to temporary labourers (in Rs.) during 2024"
	note sec8_q51: "What was the total salary paid to temporary labourers (in Rs.) during 2024"

	label variable sec9_q1 "Please select all cost categories your enterprise incurred in 2024 (Select all t"
	note sec9_q1: "Please select all cost categories your enterprise incurred in 2024 (Select all that apply. Consider all business expenses from January 2024 onwards.)"

	label variable sec9_q8 "Please select all cost categories your enterprise incurred in 2023"
	note sec9_q8: "Please select all cost categories your enterprise incurred in 2023"

	label variable sec9_q14 "Please select all cost categories your enterprise incurred in 2022"
	note sec9_q14: "Please select all cost categories your enterprise incurred in 2022"

	label variable sec10_q1 "Out of the following, what assets are you currently using? (Select all assets th"
	note sec10_q1: "Out of the following, what assets are you currently using? (Select all assets that apply to your business)"

	label variable sec10_q8 "Out of the following what assets were you using in 2023?"
	note sec10_q8: "Out of the following what assets were you using in 2023?"

	label variable sec10_q15 "Out of the following what assets were you using in 2022?"
	note sec10_q15: "Out of the following what assets were you using in 2022?"

	label variable sec11_q1 "Has this establishment introduced new or significantly improved products or serv"
	note sec11_q1: "Has this establishment introduced new or significantly improved products or services during January 2024 – February 2025?"
	label define sec11_q1 1 "Yes" 0 "No"
	label values sec11_q1 sec11_q1

	label variable sec11_q1_des "Description of innovation (1-6 words)"
	note sec11_q1_des: "Description of innovation (1-6 words)"

	label variable sec11_q2 "What type of product/service innovation is this?"
	note sec11_q2: "What type of product/service innovation is this?"
	label define sec11_q2 1 "New product/service" 2 "Significant improvement to existing product/service" 3 "Both new and improved products/services"
	label values sec11_q2 sec11_q2

	label variable sec11_q3 "What is the scope of this innovation?"
	note sec11_q3: "What is the scope of this innovation?"
	label define sec11_q3 1 "New for my firm" 2 "New for Village" 3 "New for the establishment's main market"
	label values sec11_q3 sec11_q3

	label variable sec11_q4 "What was the main reason for this innovation?"
	note sec11_q4: "What was the main reason for this innovation?"
	label define sec11_q4 1 "Cost minimization" 2 "Expansion" 3 "Diversification" 4 "Labour replacement" 5 "Value (Revenue) addition" 88 "Others (Please specify)"
	label values sec11_q4 sec11_q4

	label variable sec11_q4_oth "Please specify the other reason"
	note sec11_q4_oth: "Please specify the other reason"

	label variable sec11_q5 "Approximately how much did you invest in this innovation?"
	note sec11_q5: "Approximately how much did you invest in this innovation?"

	label variable sec11_q6 "Has the establishment introduced any new or significantly improved technology du"
	note sec11_q6: "Has the establishment introduced any new or significantly improved technology during January 2024 – February 2025?"
	label define sec11_q6 1 "Yes" 0 "No"
	label values sec11_q6 sec11_q6

	label variable sec11_q6_des "Description of innovation (1-6 words)"
	note sec11_q6_des: "Description of innovation (1-6 words)"

	label variable sec11_q7 "What type of technology innovation is this?"
	note sec11_q7: "What type of technology innovation is this?"
	label define sec11_q7 1 "Production technology" 2 "Digital technology" 3 "Other technology"
	label values sec11_q7 sec11_q7

	label variable sec11_q8 "What was the main reason for this innovation?"
	note sec11_q8: "What was the main reason for this innovation?"
	label define sec11_q8 1 "Cost minimization" 2 "Expansion" 3 "Diversification" 4 "Labour replacement" 5 "Value (Revenue) addition" 88 "Others (Please specify)"
	label values sec11_q8 sec11_q8

	label variable sec11_q9 "Approximately how much did you invest in this technology? (in Rs.)"
	note sec11_q9: "Approximately how much did you invest in this technology? (in Rs.)"

	label variable sec11_q10 "Has this establishment introduced any new or significantly improved logistics, d"
	note sec11_q10: "Has this establishment introduced any new or significantly improved logistics, delivery, or distribution methods for inputs, products, or services during January 2024 – February 2025?"
	label define sec11_q10 1 "Yes" 0 "No"
	label values sec11_q10 sec11_q10

	label variable sec11_q10_des "Description of innovation (1-6 words)"
	note sec11_q10_des: "Description of innovation (1-6 words)"

	label variable sec11_q11 "What type of process innovation is this?"
	note sec11_q11: "What type of process innovation is this?"
	label define sec11_q11 1 "Manufacturing methods" 2 "Logistics/delivery methods" 3 "Quality control processes" 4 "Inventory management" 5 "Administrative processes"
	label values sec11_q11 sec11_q11

	label variable sec11_q12 "What was the main reason for this innovation?"
	note sec11_q12: "What was the main reason for this innovation?"
	label define sec11_q12 1 "Cost minimization" 2 "Expansion" 3 "Diversification" 4 "Labour replacement" 5 "Value (Revenue) addition" 88 "Others (Please specify)"
	label values sec11_q12 sec11_q12

	label variable sec11_q13 "Approximately how much did you invest in this process improvement? (in Rs.)"
	note sec11_q13: "Approximately how much did you invest in this process improvement? (in Rs.)"

	label variable sec11_q14 "Has this establishment introduced new or significantly improved marketing method"
	note sec11_q14: "Has this establishment introduced new or significantly improved marketing methods during January 2024 – February 2025?"
	label define sec11_q14 1 "Yes" 0 "No"
	label values sec11_q14 sec11_q14

	label variable sec11_q14_des "Description of innovation (1-6 words)"
	note sec11_q14_des: "Description of innovation (1-6 words)"

	label variable sec11_q15 "What type of marketing innovation is this?"
	note sec11_q15: "What type of marketing innovation is this?"
	label define sec11_q15 1 "New marketing method" 2 "New packaging" 3 "New pricing method" 4 "New distribution channel" 5 "New promotion method"
	label values sec11_q15 sec11_q15

	label variable sec11_q16 "What was the main reason for this innovation?"
	note sec11_q16: "What was the main reason for this innovation?"
	label define sec11_q16 1 "Cost minimization" 2 "Expansion" 3 "Diversification" 4 "Labour replacement" 5 "Value (Revenue) addition" 88 "Others (Please specify)"
	label values sec11_q16 sec11_q16

	label variable sec11_q17 "Approximately how much did you invest in this marketing innovation? (in Rs.)"
	note sec11_q17: "Approximately how much did you invest in this marketing innovation? (in Rs.)"

	label variable sec11_q18 "Does your business have website?"
	note sec11_q18: "Does your business have website?"
	label define sec11_q18 1 "Yes" 0 "No"
	label values sec11_q18 sec11_q18

	label variable sec11_q19 "Does your business have email address?"
	note sec11_q19: "Does your business have email address?"
	label define sec11_q19 1 "Yes" 0 "No"
	label values sec11_q19 sec11_q19

	label variable sec12_q1 "Did the respondent recall all numbers correctly? (5,9,4,1)"
	note sec12_q1: "Did the respondent recall all numbers correctly? (5,9,4,1)"
	label define sec12_q1 1 "Yes" 0 "No"
	label values sec12_q1 sec12_q1

	label variable sec12_q2 "Did the respondent recall all numbers correctly? (9,3,8,7,2)"
	note sec12_q2: "Did the respondent recall all numbers correctly? (9,3,8,7,2)"
	label define sec12_q2 1 "Yes" 0 "No"
	label values sec12_q2 sec12_q2

	label variable sec12_q3 "Did the respondent recall all numbers correctly? (1,5,2,6,4,9)"
	note sec12_q3: "Did the respondent recall all numbers correctly? (1,5,2,6,4,9)"
	label define sec12_q3 1 "Yes" 0 "No"
	label values sec12_q3 sec12_q3

	label variable sec12_q4 "Did the respondent recall all numbers correctly? (3,7,4,5,2,6,1)"
	note sec12_q4: "Did the respondent recall all numbers correctly? (3,7,4,5,2,6,1)"
	label define sec12_q4 1 "Yes" 0 "No"
	label values sec12_q4 sec12_q4

	label variable sec12_q5 "Did the respondent recall all numbers correctly? (8,2,9,7,3,5,4,6)"
	note sec12_q5: "Did the respondent recall all numbers correctly? (8,2,9,7,3,5,4,6)"
	label define sec12_q5 1 "Yes" 0 "No"
	label values sec12_q5 sec12_q5

	label variable sec12_q6 "Did the respondent recall all numbers correctly? (2,4,6,9,3,7,1,8,5)"
	note sec12_q6: "Did the respondent recall all numbers correctly? (2,4,6,9,3,7,1,8,5)"
	label define sec12_q6 1 "Yes" 0 "No"
	label values sec12_q6 sec12_q6

	label variable sec12_q7 "Did the respondent recall all numbers correctly? (7,3,1,5,8,6,2,9,4,5)"
	note sec12_q7: "Did the respondent recall all numbers correctly? (7,3,1,5,8,6,2,9,4,5)"
	label define sec12_q7 1 "Yes" 0 "No"
	label values sec12_q7 sec12_q7

	label variable sec12_q8 "Did the respondent recall all numbers correctly? (4,9,1,5,3,7,6,2,8,3,9)"
	note sec12_q8: "Did the respondent recall all numbers correctly? (4,9,1,5,3,7,6,2,8,3,9)"
	label define sec12_q8 1 "Yes" 0 "No"
	label values sec12_q8 sec12_q8

	label variable sec13_q1 "You have the opportunity to expand your business by launching a new product. How"
	note sec13_q1: "You have the opportunity to expand your business by launching a new product. However, the outcome is uncertain. Which option would you choose?"
	label define sec13_q1 1 "There is a 40% chance that the new product will significantly increase your prof" 2 "You stick to your current product line, which is stable but provides no addition"
	label values sec13_q1 sec13_q1

	label variable sec13_q2 "You are considering investing in a new technology that could improve efficiency."
	note sec13_q2: "You are considering investing in a new technology that could improve efficiency. Which option would you choose?"
	label define sec13_q2 1 "There is a 30% chance that the technology will improve efficiency and increase p" 2 "Keep your current technology, which works reliably but provides steady, moderate"
	label values sec13_q2 sec13_q2

	label variable sec13_q3 "A new market has opened up, and you have the opportunity to expand your business"
	note sec13_q3: "A new market has opened up, and you have the opportunity to expand your business there. Which option would you choose?"
	label define sec13_q3 1 "There is a 50% chance that the expansion will double your sales, but also a 50% " 2 "Continue operating only in your current market, which has stable but slow growth"
	label values sec13_q3 sec13_q3

	label variable sec13_q4 "You have an opportunity to take a loan to expand your business. Which option wou"
	note sec13_q4: "You have an opportunity to take a loan to expand your business. Which option would you choose?"
	label define sec13_q4 1 "There is a 60% chance that the expansion will increase your revenue by 70%, but " 2 "No loan is taken, and your business continues to grow slowly but steadily."
	label values sec13_q4 sec13_q4

	label variable sec13_q5 "You are thinking of partnering with a new supplier who offers lower prices but w"
	note sec13_q5: "You are thinking of partnering with a new supplier who offers lower prices but whose reliability is uncertain. Which option would you choose?"
	label define sec13_q5 1 "There is a 70% chance that the new supplier will reduce your costs and increase " 2 "Stick with your current supplier, who is reliable but does not offer lower price"
	label values sec13_q5 sec13_q5

	label variable sec14_q1 "Do you proactively take steps to improve the functioning of the business?"
	note sec14_q1: "Do you proactively take steps to improve the functioning of the business?"
	label define sec14_q1 1 "Yes" 0 "No"
	label values sec14_q1 sec14_q1

	label variable sec14_q2 "Which response do you agree with?"
	note sec14_q2: "Which response do you agree with?"
	label define sec14_q2 1 "Murugan owns an agro-pesticide shop in the village, where the farmers have been " 2 "Murugan owns an agro-pesticide shop in the village, where the farmers have been "
	label values sec14_q2 sec14_q2

	label variable sec14_q3 "Do you take opinions/suggestions from your associates/partners when managing you"
	note sec14_q3: "Do you take opinions/suggestions from your associates/partners when managing your business?"
	label define sec14_q3 1 "Yes" 0 "No"
	label values sec14_q3 sec14_q3

	label variable sec14_q4 "Which response do you agree with?"
	note sec14_q4: "Which response do you agree with?"
	label define sec14_q4 1 "Siva owns a small mechanic workshop in the village. He has hired two experienced" 2 "Siva owns a small mechanic workshop in the village. He has hired two experienced"
	label values sec14_q4 sec14_q4

	label variable sec15_q1 "I have professional goals."
	note sec15_q1: "I have professional goals."
	label define sec15_q1 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q1 sec15_q1

	label variable sec15_q2 "I revise my goals periodically"
	note sec15_q2: "I revise my goals periodically"
	label define sec15_q2 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q2 sec15_q2

	label variable sec15_q3 "If I don’t reach a goal in the way I wanted to I try again"
	note sec15_q3: "If I don’t reach a goal in the way I wanted to I try again"
	label define sec15_q3 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q3 sec15_q3

	label variable sec15_q4 "I can’t motivate my business partners"
	note sec15_q4: "I can’t motivate my business partners"
	label define sec15_q4 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q4 sec15_q4

	label variable sec15_q5 "Everything I need for success lies in myself"
	note sec15_q5: "Everything I need for success lies in myself"
	label define sec15_q5 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q5 sec15_q5

	label variable sec15_q6 "I prefer to do routine tasks instead of doing something new in my work."
	note sec15_q6: "I prefer to do routine tasks instead of doing something new in my work."
	label define sec15_q6 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q6 sec15_q6

	label variable sec15_q7 "I think the government should give me opportunities"
	note sec15_q7: "I think the government should give me opportunities"
	label define sec15_q7 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q7 sec15_q7

	label variable sec15_q8 "I have to reach some goals every day to feel satisfied."
	note sec15_q8: "I have to reach some goals every day to feel satisfied."
	label define sec15_q8 1 "Strongly Disagree" 2 "Disagree" 3 "Neutral" 4 "Agree" 5 "Strongly agree"
	label values sec15_q8 sec15_q8

	label variable sec16_q1_a "Have you visited one of your competitor's businesses to see what prices they are"
	note sec16_q1_a: "Have you visited one of your competitor's businesses to see what prices they are charging?"
	label define sec16_q1_a 1 "Yes" 0 "No"
	label values sec16_q1_a sec16_q1_a

	label variable sec16_q1_b "Have you visited one of your competitor's businesses to see what products they h"
	note sec16_q1_b: "Have you visited one of your competitor's businesses to see what products they have available for sale?"
	label define sec16_q1_b 1 "Yes" 0 "No"
	label values sec16_q1_b sec16_q1_b

	label variable sec16_q1_c "Have you asked your existing customers whether there are any other products they"
	note sec16_q1_c: "Have you asked your existing customers whether there are any other products they would like you to sell or produce?"
	label define sec16_q1_c 1 "Yes" 0 "No"
	label values sec16_q1_c sec16_q1_c

	label variable sec16_q1_d "Have you Inquired with a former customer to find out why they have stopped buyin"
	note sec16_q1_d: "Have you Inquired with a former customer to find out why they have stopped buying from your business?"
	label define sec16_q1_d 1 "Yes" 0 "No"
	label values sec16_q1_d sec16_q1_d

	label variable sec16_q1_e "Have you asked a supplier about which products are selling well in your industry"
	note sec16_q1_e: "Have you asked a supplier about which products are selling well in your industry?"
	label define sec16_q1_e 1 "Yes" 0 "No"
	label values sec16_q1_e sec16_q1_e

	label variable sec16_q2 "In the last three months have you used any special offer to attract customers?"
	note sec16_q2: "In the last three months have you used any special offer to attract customers?"
	label define sec16_q2 1 "Yes" 0 "No"
	label values sec16_q2 sec16_q2

	label variable sec16_q3 "In the last six months, have you done any form of advertising?"
	note sec16_q3: "In the last six months, have you done any form of advertising?"
	label define sec16_q3 1 "Yes" 0 "No"
	label values sec16_q3 sec16_q3

	label variable sec16_q4 "Which of the following types of advertising have you done?"
	note sec16_q4: "Which of the following types of advertising have you done?"

	label variable sec16_q4_other "Specify other advertising type"
	note sec16_q4_other: "Specify other advertising type"

	label variable sec16_q5 "Have you used any method to measure the effectiveness of the advertising?"
	note sec16_q5: "Have you used any method to measure the effectiveness of the advertising?"
	label define sec16_q5 1 "Yes" 0 "No"
	label values sec16_q5 sec16_q5

	label variable sec16_q6 "In the last three months have you attempted to negotiate with a supplier for a l"
	note sec16_q6: "In the last three months have you attempted to negotiate with a supplier for a lower price?"
	label define sec16_q6 1 "Yes" 0 "No"
	label values sec16_q6 sec16_q6

	label variable sec16_q6a "Were you successful in obtaining a lower price?"
	note sec16_q6a: "Were you successful in obtaining a lower price?"
	label define sec16_q6a 1 "Yes" 0 "No"
	label values sec16_q6a sec16_q6a

	label variable sec16_q7 "In the last three months, have you compared prices or quality offered by alterna"
	note sec16_q7: "In the last three months, have you compared prices or quality offered by alternate suppliers?"
	label define sec16_q7 1 "Yes" 0 "No"
	label values sec16_q7 sec16_q7

	label variable sec16_q8 "Do you keep goods to sell, or raw materials to use in providing a service?"
	note sec16_q8: "Do you keep goods to sell, or raw materials to use in providing a service?"
	label define sec16_q8 1 "Yes" 0 "No"
	label values sec16_q8 sec16_q8

	label variable sec16_q9 "What is the most common way you purchase inputs / inventories?"
	note sec16_q9: "What is the most common way you purchase inputs / inventories?"
	label define sec16_q9 1 "A distributor comes to your store on a fixed schedule" 2 "A distributor who comes whenever you place an order" 3 "You go to the supplier's store/warehouse to purchase the goods" 4 "A distributor comes to your store but with no fixed schedule" 88 "Other"
	label values sec16_q9 sec16_q9

	label variable sec16_q9_other "Specify other purchase method"
	note sec16_q9_other: "Specify other purchase method"

	label variable sec16_q10 "How frequently do you run out of stock?"
	note sec16_q10: "How frequently do you run out of stock?"
	label define sec16_q10 1 "Never, I always have enough on hand" 2 "Not very frequent, once every 6 months" 3 "Once every three months or so" 4 "Once a month or more frequent"
	label values sec16_q10 sec16_q10

	label variable sec16_q11 "How long does it take to obtain goods for which you have run out of stock?"
	note sec16_q11: "How long does it take to obtain goods for which you have run out of stock?"
	label define sec16_q11 1 "A Day or less" 2 "More than a day, less than a week" 3 "A week" 4 "More than a week, less than a month" 5 "A month or more"
	label values sec16_q11 sec16_q11

	label variable sec16_q12_a "What percentage of perishable inventory purchases did you have to throw out due "
	note sec16_q12_a: "What percentage of perishable inventory purchases did you have to throw out due to spoilage in the in a typical month?"

	label variable sec16_q12_b "What percentage of goods do you discount as bulk sales?"
	note sec16_q12_b: "What percentage of goods do you discount as bulk sales?"

	label variable sec16_q12_c "Apart from bulk sales, what percentage of inventory purchases do you discount by"
	note sec16_q12_c: "Apart from bulk sales, what percentage of inventory purchases do you discount by 20% or more in order to sell?"

	label variable sec16_q12_d "What percentage of products in your store sell fewer than one unit per month (i."
	note sec16_q12_d: "What percentage of products in your store sell fewer than one unit per month (i.e., sold rarely or not at all)?"

	label variable sec16_q12_e "What percentage of raw material inventory is lost due to spoilage/expiration mon"
	note sec16_q12_e: "What percentage of raw material inventory is lost due to spoilage/expiration monthly?"

	label variable sec16_q12_f "What percentage of raw material inventory is lost due to production waste/scrap?"
	note sec16_q12_f: "What percentage of raw material inventory is lost due to production waste/scrap?"

	label variable sec16_q12_g "What percentage of raw material inventory is lost due to damage during storage?"
	note sec16_q12_g: "What percentage of raw material inventory is lost due to damage during storage?"

	label variable sec16_q12_h "What percentage of finished goods inventory gets damaged during storage monthly?"
	note sec16_q12_h: "What percentage of finished goods inventory gets damaged during storage monthly?"

	label variable sec16_q12_i "What percentage of finished goods inventory is sold at discount due to quality i"
	note sec16_q12_i: "What percentage of finished goods inventory is sold at discount due to quality issues?"

	label variable sec16_q12_j "What percentage of finished goods inventory remains unsold for more than 3 month"
	note sec16_q12_j: "What percentage of finished goods inventory remains unsold for more than 3 months?"

	label variable sec16_q12_l "What percentage of service-related supplies/materials get damaged during storage"
	note sec16_q12_l: "What percentage of service-related supplies/materials get damaged during storage?"

	label variable sec16_q12_m "What percentage of service-related supplies/materials become obsolete?"
	note sec16_q12_m: "What percentage of service-related supplies/materials become obsolete?"

	label variable sec16_q13 "Do you have a record-keeping system to know how much stock you have on hand?"
	note sec16_q13: "Do you have a record-keeping system to know how much stock you have on hand?"
	label define sec16_q13 1 "Yes" 0 "No"
	label values sec16_q13 sec16_q13

	label variable sec16_q13_a "What type of system is it?"
	note sec16_q13_a: "What type of system is it?"
	label define sec16_q13_a 1 "Formal, written?" 2 "Informal, unwritten?"
	label values sec16_q13_a sec16_q13_a

	label variable sec16_q14 "How often do you inspect/update the information on inventory levels?"
	note sec16_q14: "How often do you inspect/update the information on inventory levels?"
	label define sec16_q14 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Less often" 5 "Do not inspect/update"
	label values sec16_q14 sec16_q14

	label variable sec16_q15 "Do you maintain business records regularly?"
	note sec16_q15: "Do you maintain business records regularly?"
	label define sec16_q15 1 "Yes" 0 "No"
	label values sec16_q15 sec16_q15

	label variable sec16_q15_a "What are the reason for not maintaining business records?"
	note sec16_q15_a: "What are the reason for not maintaining business records?"

	label variable sec16_q15_a_other "Specify other reason"
	note sec16_q15_a_other: "Specify other reason"

	label variable sec16_q16 "How do you maintain your business records? (Select all the methods that apply)"
	note sec16_q16: "How do you maintain your business records? (Select all the methods that apply)"

	label variable sec16_q16_other "Specify other method"
	note sec16_q16_other: "Specify other method"

	label variable sec16_q17 "Do you record every purchase and sale made by the business?"
	note sec16_q17: "Do you record every purchase and sale made by the business?"
	label define sec16_q17 1 "Yes" 0 "No"
	label values sec16_q17 sec16_q17

	label variable sec16_q17_a "Can you show me your most recent transaction entries?"
	note sec16_q17_a: "Can you show me your most recent transaction entries?"
	label define sec16_q17_a 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q17_a sec16_q17_a

	label variable sec16_q17_b "What information do you record for each transaction?"
	note sec16_q17_b: "What information do you record for each transaction?"

	label variable sec16_q17_c "Why don't you record every transaction? (Select all that apply)"
	note sec16_q17_c: "Why don't you record every transaction? (Select all that apply)"

	label variable sec16_q18 "Are you able to use your records to see how much cash your business has on hand "
	note sec16_q18: "Are you able to use your records to see how much cash your business has on hand at any point in time?"
	label define sec16_q18 1 "Yes" 0 "No"
	label values sec16_q18 sec16_q18

	label variable sec16_q19 "How do you track your cash?"
	note sec16_q19: "How do you track your cash?"

	label variable sec16_q19_other "Specify other method"
	note sec16_q19_other: "Specify other method"

	label variable sec16_q20 "Do you regularly use your records to know whether sales of a particular product "
	note sec16_q20: "Do you regularly use your records to know whether sales of a particular product are increasing or decreasing from one month to another?"
	label define sec16_q20 1 "Yes" 0 "No"
	label values sec16_q20 sec16_q20

	label variable sec16_q20_a "Can you show me sales trends for your top 3 products over the last 3 months?"
	note sec16_q20_a: "Can you show me sales trends for your top 3 products over the last 3 months?"
	label define sec16_q20_a 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q20_a sec16_q20_a

	label variable sec16_q21 "Have you worked out the cost to you of each main product you sell?"
	note sec16_q21: "Have you worked out the cost to you of each main product you sell?"
	label define sec16_q21 1 "Yes" 0 "No"
	label values sec16_q21 sec16_q21

	label variable sec16_q21_a "What costs do you include in calculating product cost? (Select all that apply)"
	note sec16_q21_a: "What costs do you include in calculating product cost? (Select all that apply)"

	label variable sec16_q21_a_other "Specify other costs"
	note sec16_q21_a_other: "Specify other costs"

	label variable sec16_q21_b "Can you break down the cost of your best-selling product?"
	note sec16_q21_b: "Can you break down the cost of your best-selling product?"
	label define sec16_q21_b 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q21_b sec16_q21_b

	label variable sec16_q22 "Do you know which goods you make the most profit per item selling?"
	note sec16_q22: "Do you know which goods you make the most profit per item selling?"
	label define sec16_q22 1 "Yes" 0 "No"
	label values sec16_q22 sec16_q22

	label variable sec16_q23 "Do you have a written budget for monthly expenses?"
	note sec16_q23: "Do you have a written budget for monthly expenses?"
	label define sec16_q23 1 "Yes" 0 "No"
	label values sec16_q23 sec16_q23

	label variable sec16_q23_a "Can you show me your current month's budget?"
	note sec16_q23_a: "Can you show me your current month's budget?"
	label define sec16_q23_a 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q23_a sec16_q23_a

	label variable sec16_q23_b "What expenses are included in your budget?"
	note sec16_q23_b: "What expenses are included in your budget?"

	label variable sec16_q23_b_other "Specify other expenses"
	note sec16_q23_b_other: "Specify other expenses"

	label variable sec16_q24 "Do you sell any goods on credit to customers?"
	note sec16_q24: "Do you sell any goods on credit to customers?"
	label define sec16_q24 1 "Yes" 0 "No"
	label values sec16_q24 sec16_q24

	label variable sec16_q24_a "Do you have a written record of how much each customer owes you?"
	note sec16_q24_a: "Do you have a written record of how much each customer owes you?"
	label define sec16_q24_a 1 "Yes" 0 "No"
	label values sec16_q24_a sec16_q24_a

	label variable sec16_q24_b "How do you track credit sales?"
	note sec16_q24_b: "How do you track credit sales?"

	label variable sec16_q24_b_other "Specify other tracking method"
	note sec16_q24_b_other: "Specify other tracking method"

	label variable sec16_q24_c "Can you show me your current accounts receivable record?"
	note sec16_q24_c: "Can you show me your current accounts receivable record?"
	label define sec16_q24_c 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q24_c sec16_q24_c

	label variable sec16_q25 "If you wanted to apply for a bank loan, and were asked to provide records to sho"
	note sec16_q25: "If you wanted to apply for a bank loan, and were asked to provide records to show that you have enough money left each month after paying business expenses to repay a loan, would your records allow you to document this to the bank?"
	label define sec16_q25 1 "Yes" 0 "No"
	label values sec16_q25 sec16_q25

	label variable sec16_q25_a "What financial documents can you provide?"
	note sec16_q25_a: "What financial documents can you provide?"

	label variable sec16_q25_a_other "Specify other documents"
	note sec16_q25_a_other: "Specify other documents"

	label variable sec16_q25_b "Can you show me your monthly cash flow calculation?"
	note sec16_q25_b: "Can you show me your monthly cash flow calculation?"
	label define sec16_q25_b 1 "Complete records available" 2 "Partial records available" 3 "No records available"
	label values sec16_q25_b sec16_q25_b

	label variable sec16_q26 "How frequently do you review the financial strength/performance of your business"
	note sec16_q26: "How frequently do you review the financial strength/performance of your business and analyze/identify areas for improvement?"
	label define sec16_q26 1 "Never" 2 "Once a year or less frequent" 3 "Two or three times a year" 4 "Monthly or more often"
	label values sec16_q26 sec16_q26

	label variable sec16_q27 "Do you have a target set for sales over the next year?"
	note sec16_q27: "Do you have a target set for sales over the next year?"
	label define sec16_q27 1 "Yes" 0 "No"
	label values sec16_q27 sec16_q27

	label variable sec16_q27_a "How frequently do you compare actual performance to your target?"
	note sec16_q27_a: "How frequently do you compare actual performance to your target?"
	label define sec16_q27_a 1 "Never" 2 "Once a year or less frequent" 3 "Two or three times a year" 4 "Monthly or more often"
	label values sec16_q27_a sec16_q27_a

	label variable sec16_q28 "Have you made a budget of what costs facing your business are likely to be over "
	note sec16_q28: "Have you made a budget of what costs facing your business are likely to be over the next year?"
	label define sec16_q28 1 "Yes" 0 "No"
	label values sec16_q28 sec16_q28

	label variable sec16_q29 "Which of the following do you or your accountant prepare at least annually? (sel"
	note sec16_q29: "Which of the following do you or your accountant prepare at least annually? (select all that apply)"

	label variable sec16_q30 "Have you ever received any business development or advisory services training?"
	note sec16_q30: "Have you ever received any business development or advisory services training?"
	label define sec16_q30 1 "Yes" 0 "No"
	label values sec16_q30 sec16_q30

	label variable sec17_q1 "Did you or any household member receive the MGP loan after applying?"
	note sec17_q1: "Did you or any household member receive the MGP loan after applying?"
	label define sec17_q1 1 "Yes" 0 "No"
	label values sec17_q1 sec17_q1

	label variable sec17_q2 "How many times have you applied for the MGP loan?"
	note sec17_q2: "How many times have you applied for the MGP loan?"

	label variable sec17_q3 "Why was your loan request rejected at the first attempt?"
	note sec17_q3: "Why was your loan request rejected at the first attempt?"
	label define sec17_q3 1 "Documentation Errors" 2 "Financial Criteria mismatch" 3 "Lack of Interest and Commitment" 4 "Procedural Errors" 5 "Scrutinized and Rejection" 6 "Technical Issues"
	label values sec17_q3 sec17_q3

	label variable sec17_q4 "What assistance did you receive during the MGP application process? (Select all "
	note sec17_q4: "What assistance did you receive during the MGP application process? (Select all that apply)"

	label variable sec17_q4_other "Please specify the other assistance"
	note sec17_q4_other: "Please specify the other assistance"

	label variable sec17_q5 "Did you face any challenges during the application process?"
	note sec17_q5: "Did you face any challenges during the application process?"
	label define sec17_q5 1 "Yes" 0 "No"
	label values sec17_q5 sec17_q5

	label variable sec17_q6 "What challenges did you face?"
	note sec17_q6: "What challenges did you face?"
	label define sec17_q6 1 "Lack of proper documentation" 2 "Delays in processing" 3 "Confusion regarding eligibility" 4 "Difficulty understanding loan terms" 5 "Complex process" 88 "Other (Specify)"
	label values sec17_q6 sec17_q6

	label variable sec17_q6_other "Please specify the other challenges that you have faced"
	note sec17_q6_other: "Please specify the other challenges that you have faced"

	label variable sec17_q7 "What was the amount received under the MGP loan? (in INR)"
	note sec17_q7: "What was the amount received under the MGP loan? (in INR)"

	label variable sec17_q8 "How did you utilise the MGP loan? (Loan utilisation is applicable on the amount "
	note sec17_q8: "How did you utilise the MGP loan? (Loan utilisation is applicable on the amount received as MGP loan. It does not concern with activities realised due to the MGP loan (for example, increase in profits))"

	label variable sec17_q10 "How are you planning to use the unspent amount of MGP loan (identify the most si"
	note sec17_q10: "How are you planning to use the unspent amount of MGP loan (identify the most significant category)?"
	label define sec17_q10 1 "Working capital" 2 "Asset creation (Including expansion)" 3 "Debt reduction" 4 "Starting new enterprise (Other than surveyed enterprise)"
	label values sec17_q10 sec17_q10

	label variable sec17_q11 "How has the MGP loan benefited your business?"
	note sec17_q11: "How has the MGP loan benefited your business?"

	label variable sec17_q11_other "Please specify the other benefits"
	note sec17_q11_other: "Please specify the other benefits"

	label variable sec17_q12 "How many new employees did you hire after receiving the MGP loan?"
	note sec17_q12: "How many new employees did you hire after receiving the MGP loan?"

	label variable sec17_q13 "Have you started repaying the MGP loan?"
	note sec17_q13: "Have you started repaying the MGP loan?"
	label define sec17_q13 1 "Yes" 0 "No"
	label values sec17_q13 sec17_q13

	label variable sec17_q14 "Why have you not started repaying the loan?"
	note sec17_q14: "Why have you not started repaying the loan?"
	label define sec17_q14 1 "Business losses" 2 "Used funds for emergency personal needs" 3 "Other debt obligations" 4 "Natural disasters/COVID-19 impact" 5 "Insufficient business revenue" 6 "Loan used for non-business purposes" 88 "Others (specify) _______"
	label values sec17_q14 sec17_q14

	label variable sec17_q14_other "Please specify the other reason"
	note sec17_q14_other: "Please specify the other reason"

	label variable sec17_q15 "what is your current repayment status?"
	note sec17_q15: "what is your current repayment status?"
	label define sec17_q15 1 "Fully repaid" 2 "On track with repayment" 3 "Behind on repayment" 4 "Struggling to repay"
	label values sec17_q15 sec17_q15

	label variable sec17_q16 "How much of the MGP loan have you repaid so far? (in INR)"
	note sec17_q16: "How much of the MGP loan have you repaid so far? (in INR)"

	label variable sec17_q17 "What is your monthly MGP repayment amount?"
	note sec17_q17: "What is your monthly MGP repayment amount?"

	label variable sec17_q19 "Have you applied for any additional loans after receiving the MGP loan?"
	note sec17_q19: "Have you applied for any additional loans after receiving the MGP loan?"
	label define sec17_q19 1 "Yes" 0 "No"
	label values sec17_q19 sec17_q19

	label variable sec17_q20 "Where did you apply for the additional loan?"
	note sec17_q20: "Where did you apply for the additional loan?"
	label define sec17_q20 1 "Financial Institution (FI)" 2 "Relatives/friends" 3 "Moneylenders/shopkeepers/contractors/middlemen" 4 "Microfinance institution" 5 "TNSRLM" 88 "Other (Specify)"
	label values sec17_q20 sec17_q20

	label variable sec17_q20_other "Please specify other sources"
	note sec17_q20_other: "Please specify other sources"

	label variable sec17_q21 "Did the MGP experience increase your confidence in approaching financial institu"
	note sec17_q21: "Did the MGP experience increase your confidence in approaching financial institutions independently for loans?"
	label define sec17_q21 1 "Not at all" 2 "Slightly increased" 3 "Moderately increased" 4 "Significantly increased"
	label values sec17_q21 sec17_q21

	label variable sec17_q22 "Are you currently tracking your credit (e.g., CIBIL score) more frequently since"
	note sec17_q22: "Are you currently tracking your credit (e.g., CIBIL score) more frequently since the MGP loan?"
	label define sec17_q22 1 "Yes" 0 "No"
	label values sec17_q22 sec17_q22

	label variable sec17_q23 "What is the CIBIL score?"
	note sec17_q23: "What is the CIBIL score?"

	label variable sec17_q24 "Have you interacted with OSF or Enterprise Community Professionals (ECPs) since "
	note sec17_q24: "Have you interacted with OSF or Enterprise Community Professionals (ECPs) since receiving the MGP loan?"
	label define sec17_q24 1 "Yes" 0 "No"
	label values sec17_q24 sec17_q24

	label variable sec17_q25 "What kind of assistance have you received?"
	note sec17_q25: "What kind of assistance have you received?"

	label variable sec17_q25_other "Please sepify other assistance"
	note sec17_q25_other: "Please sepify other assistance"

	label variable sec17_q26 "What was the main motivating factor for applying for MGP?"
	note sec17_q26: "What was the main motivating factor for applying for MGP?"
	label define sec17_q26 1 "Matching grant subsidy" 2 "Knowledge and skills gained" 3 "Both are equally important"
	label values sec17_q26 sec17_q26

	label variable sec17_q27 "How do you plan to use the banking know-how gained through the MGP?"
	note sec17_q27: "How do you plan to use the banking know-how gained through the MGP?"

	label variable sec17_q28 "Would you recommend MGP to other entrepreneurs?"
	note sec17_q28: "Would you recommend MGP to other entrepreneurs?"
	label define sec17_q28 1 "Yes" 0 "No"
	label values sec17_q28 sec17_q28

	label variable sec18_q1 "How many times have you applied for the MGP loan?"
	note sec18_q1: "How many times have you applied for the MGP loan?"

	label variable sec18_q2 "Why was your loan request rejected at the first attempt?"
	note sec18_q2: "Why was your loan request rejected at the first attempt?"
	label define sec18_q2 1 "Documentation Errors" 2 "Financial Criteria mismatch" 3 "Lack of Interest and Commitment" 4 "Procedural Errors" 5 "Scrutinized and Rejection" 6 "Technical Issues"
	label values sec18_q2 sec18_q2

	label variable sec18_q3 "What assistance did you receive during the MGP application process?"
	note sec18_q3: "What assistance did you receive during the MGP application process?"

	label variable sec18_q3_other "Please specify the other assistance"
	note sec18_q3_other: "Please specify the other assistance"

	label variable sec18_q4 "Did you face any challenges during the application process?"
	note sec18_q4: "Did you face any challenges during the application process?"
	label define sec18_q4 1 "Yes" 0 "No"
	label values sec18_q4 sec18_q4

	label variable sec18_q5 "What challenges did you face?"
	note sec18_q5: "What challenges did you face?"
	label define sec18_q5 1 "Lack of proper documentation" 2 "Delays in processing" 3 "Confusion regarding eligibility" 4 "Difficulty understanding loan terms" 5 "Complex process" 88 "Other (Specify)"
	label values sec18_q5 sec18_q5

	label variable sec18_q5_other "Please specify other challenges"
	note sec18_q5_other: "Please specify other challenges"

	label variable sec18_q6 "What was the amount requested in your MGP loan application? (in INR)"
	note sec18_q6: "What was the amount requested in your MGP loan application? (in INR)"

	label variable sec18_q7 "After MGP rejection, have you taken any other business loans?"
	note sec18_q7: "After MGP rejection, have you taken any other business loans?"
	label define sec18_q7 1 "Yes" 0 "No"
	label values sec18_q7 sec18_q7

	label variable sec18_q8 "Where did you get the loan from?"
	note sec18_q8: "Where did you get the loan from?"
	label define sec18_q8 1 "Financial Institution (FI)" 2 "Relatives/friends" 3 "Moneylenders/shopkeepers/contractors/middlemen" 4 "Microfinance institution" 5 "TNSRLM" 88 "Other (Specify)"
	label values sec18_q8 sec18_q8

	label variable sec18_q8_other "Please specify other loan source"
	note sec18_q8_other: "Please specify other loan source"

	label variable sec18_q9 "What was the amount received in this alternative loan? (in INR)"
	note sec18_q9: "What was the amount received in this alternative loan? (in INR)"

	label variable sec18_q10 "How has this alternative loan benefited your business?"
	note sec18_q10: "How has this alternative loan benefited your business?"

	label variable sec18_q10_other "Please specify other benefits"
	note sec18_q10_other: "Please specify other benefits"

	label variable sec18_q11 "Are you currently tracking your credit (e.g., CIBIL score)?"
	note sec18_q11: "Are you currently tracking your credit (e.g., CIBIL score)?"
	label define sec18_q11 1 "Yes" 0 "No"
	label values sec18_q11 sec18_q11

	label variable sec18_q12 "What is your CIBIL score?"
	note sec18_q12: "What is your CIBIL score?"

	label variable sec18_q13 "Did the MGP application process increase your understanding of formal loan proce"
	note sec18_q13: "Did the MGP application process increase your understanding of formal loan procedures?"
	label define sec18_q13 1 "Not at all" 2 "Slightly increased" 3 "Moderately increased" 4 "Significantly increased"
	label values sec18_q13 sec18_q13

	label variable sec19_q1 "Are you able to list at least one external contact for business advice?"
	note sec19_q1: "Are you able to list at least one external contact for business advice?"
	label define sec19_q1 1 "Yes" 0 "No"
	label values sec19_q1 sec19_q1

	label variable sec19_q2 "How many people (outside your household) have you consulted for BUSINESS ADVICE "
	note sec19_q2: "How many people (outside your household) have you consulted for BUSINESS ADVICE in the past 12 months? (Enter 0 if none, up to 5 if more.)"

	label variable sec19_q3 "Compared to one year ago, do you feel the number of people you can go to for bus"
	note sec19_q3: "Compared to one year ago, do you feel the number of people you can go to for business advice has changed?"
	label define sec19_q3 1 "Increased" 2 "Decreased" 3 "About the same" 4 "Don’t know"
	label values sec19_q3 sec19_q3

	label variable sec19_q4 "In the past year, how many entrepreneurs approached you for business-related ser"
	note sec19_q4: "In the past year, how many entrepreneurs approached you for business-related services?"

	label variable sec19_q5 "In the past year, do you feel other entrepreneurs approach you more often, less "
	note sec19_q5: "In the past year, do you feel other entrepreneurs approach you more often, less often, or about the same as before?"
	label define sec19_q5 1 "A lot more often" 2 "Slightly more often" 3 "No change" 4 "Less often" 5 "Don’t know"
	label values sec19_q5 sec19_q5

	label variable sec19_q5_1 "Would you say receiving MGP contributed to this increase?"
	note sec19_q5_1: "Would you say receiving MGP contributed to this increase?"
	label define sec19_q5_1 1 "Definitely yes" 2 "Possibly" 3 "No" 4 "Not sure"
	label values sec19_q5_1 sec19_q5_1

	label variable sec19_q6 "If you had a major business challenge or needed a larger loan, how confident are"
	note sec19_q6: "If you had a major business challenge or needed a larger loan, how confident are you that you have enough people (outside your household) to ask for advice?"
	label define sec19_q6 1 "Very confident" 2 "Somewhat confident" 3 "Not confident" 4 "Don’t know"
	label values sec19_q6 sec19_q6



	capture {
		foreach rgvar of varlist sec5_q3_* {
			label variable `rgvar' "Amount invested in \${investment2024} during January 2024 - December 2024?"
			note `rgvar': "Amount invested in \${investment2024} during January 2024 - December 2024?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q4_* {
			label variable `rgvar' "Source of investment for \${investment2024} during January 2024 - December 2024?"
			note `rgvar': "Source of investment for \${investment2024} during January 2024 - December 2024?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q5_* {
			label variable `rgvar' "Mode of investment for \${investment2024} during January 2024 - December 2024?"
			note `rgvar': "Mode of investment for \${investment2024} during January 2024 - December 2024?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q8_* {
			label variable `rgvar' "Amount invested in \${investment2023} during January 2023- December 2023?"
			note `rgvar': "Amount invested in \${investment2023} during January 2023- December 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q9_* {
			label variable `rgvar' "Source of investment for \${investment2023} during January 2023- December 2023?"
			note `rgvar': "Source of investment for \${investment2023} during January 2023- December 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q10_* {
			label variable `rgvar' "Mode of investment for \${investment2023} during January 2023- December 2023?"
			note `rgvar': "Mode of investment for \${investment2023} during January 2023- December 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q13_* {
			label variable `rgvar' "Then the amount invested in \${investment2022} during January 2022- December 202"
			note `rgvar': "Then the amount invested in \${investment2022} during January 2022- December 2022 (in Rs.)?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q14_* {
			label variable `rgvar' "Source of investment for \${investment2022} during January 2022- December 2022?"
			note `rgvar': "Source of investment for \${investment2022} during January 2022- December 2022?"
		}
	}

	capture {
		foreach rgvar of varlist sec5_q15_* {
			label variable `rgvar' "Mode of investment for \${investment2022} during January 2022- December 2022?"
			note `rgvar': "Mode of investment for \${investment2022} during January 2022- December 2022?"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q4_* {
			label variable `rgvar' "Source of the \${loan} loan"
			note `rgvar': "Source of the \${loan} loan"
			label define `rgvar' 1 "Relatives/friends" 2 "Banks" 3 "Moneylenders/shopkeepers/contractors/middleman" 4 "TNSRLM (Tamil Nadu State Rural Livelihoods Mission)" 5 "MFI (Micro Finance Institution)" 6 "NBFC (Non-Banking Financial Company)" 7 "MGP (Matching Grant Program)" 88 "Other(Please specify)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q4_others_* {
			label variable `rgvar' "Please specify the loan source"
			note `rgvar': "Please specify the loan source"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q5_* {
			label variable `rgvar' "When was the loan taken?"
			note `rgvar': "When was the loan taken?"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q6_* {
			label variable `rgvar' "Whether the \${loan} loan is active? (Active means entrepreneurs are still repay"
			note `rgvar': "Whether the \${loan} loan is active? (Active means entrepreneurs are still repaying the loans)"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q8_* {
			label variable `rgvar' "Total amount requested from the source (in Rs.)"
			note `rgvar': "Total amount requested from the source (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q9_* {
			label variable `rgvar' "Total amount received from the source (In Rs.)"
			note `rgvar': "Total amount received from the source (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q7_* {
			label variable `rgvar' "Amount of loan left to be repaid (Of the principal amount)"
			note `rgvar': "Amount of loan left to be repaid (Of the principal amount)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q16_* {
			label variable `rgvar' "Duration of the loan (in months)"
			note `rgvar': "Duration of the loan (in months)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q10_* {
			label variable `rgvar' "How often did you make loan repayments?"
			note `rgvar': "How often did you make loan repayments?"
			label define `rgvar' 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Quarterly"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q11_* {
			label variable `rgvar' "Number of times payment was delayed"
			note `rgvar': "Number of times payment was delayed"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q12_* {
			label variable `rgvar' "Length of the longest delay (in days)"
			note `rgvar': "Length of the longest delay (in days)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q13_* {
			label variable `rgvar' "Reason(s) for delays (if any)"
			note `rgvar': "Reason(s) for delays (if any)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q14_* {
			label variable `rgvar' "How difficult is it for the entrepreneur to adhere to the repayment schedule for"
			note `rgvar': "How difficult is it for the entrepreneur to adhere to the repayment schedule for this loan?"
			label define `rgvar' 1 "Not difficult" 2 "Somewhat difficult" 3 "Very difficult"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q15_* {
			label variable `rgvar' "Please specify the use of this \${loan} loan"
			note `rgvar': "Please specify the use of this \${loan} loan"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q15a_* {
			label variable `rgvar' "Total amount spent on \${loan_usage_spent} in \${loan} loan (in Rs.)"
			note `rgvar': "Total amount spent on \${loan_usage_spent} in \${loan} loan (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q17_* {
			label variable `rgvar' "Rate of interest (in %)"
			note `rgvar': "Rate of interest (in %)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q17a_* {
			label variable `rgvar' "Write Rate of interest in words"
			note `rgvar': "Write Rate of interest in words"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q18_* {
			label variable `rgvar' "Relevant interest cycle (How is the interest calculated - yearly, monthly, etc.)"
			note `rgvar': "Relevant interest cycle (How is the interest calculated - yearly, monthly, etc.)"
			label define `rgvar' 1 "Year" 2 "Months" 3 "Weeks" 4 "Days"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist interest_rate_confirmed_* {
			label variable `rgvar' "Have you verified this interest rate with the respondent? (If it is wrong then c"
			note `rgvar': "Have you verified this interest rate with the respondent? (If it is wrong then correct it)"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist interest_rate_explanation_* {
			label variable `rgvar' "Please explain why this interest rate is correct (Provide specific details about"
			note `rgvar': "Please explain why this interest rate is correct (Provide specific details about why this rate is correct (e.g., short-term emergency loan, , etc.))"
			label define `rgvar' 1 "short-term emergency loan" 2 "special program rate" 3 "Moneylenders"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q19_* {
			label variable `rgvar' "What is the moratorium period of the loan (in months) (Period during which you d"
			note `rgvar': "What is the moratorium period of the loan (in months) (Period during which you don't have to make principal repayments)"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q20_* {
			label variable `rgvar' "Reason for applying to this source"
			note `rgvar': "Reason for applying to this source"
		}
	}

	capture {
		foreach rgvar of varlist sec6_q21_* {
			label variable `rgvar' "What did you pledge to get the loan?"
			note `rgvar': "What did you pledge to get the loan?"
			label define `rgvar' 1 "Not required" 2 "Land" 3 "Livestock" 4 "House" 5 "Non-farm asset" 6 "Valuable durable goods" 7 "Hypothecation" 8 "Pledged farm labour services" 9 "Pledged non-farm labour services" 10 "Pledged gold/silver jewellery" 88 "Other (Please specify)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec6_q21_loan_pledge_other_* {
			label variable `rgvar' "Please specify what did you pledge to get loan"
			note `rgvar': "Please specify what did you pledge to get loan"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q2_* {
			label variable `rgvar' "Did this enterprise ever own \${cost2024}? (This question is only for physical a"
			note `rgvar': "Did this enterprise ever own \${cost2024}? (This question is only for physical assets like space, machinery, or vehicles)"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q3_* {
			label variable `rgvar' "For the enterprise operation, what is the ownership of this \${cost2024}? (Consi"
			note `rgvar': "For the enterprise operation, what is the ownership of this \${cost2024}? (Consider the current ownership status)"
			label define `rgvar' 1 "Own" 2 "Rented" 3 "Both"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q6_* {
			label variable `rgvar' "What was the total amount spent on \${cost2024} in 2024? (in Rs.)"
			note `rgvar': "What was the total amount spent on \${cost2024} in 2024? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q4_* {
			label variable `rgvar' "During January 2024 to December 2024, how much did you spend on \${cost2024} in "
			note `rgvar': "During January 2024 to December 2024, how much did you spend on \${cost2024} in peak months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q5_* {
			label variable `rgvar' "During January 2024 to December 2024, how much did you spend on \${cost2024} in "
			note `rgvar': "During January 2024 to December 2024, how much did you spend on \${cost2024} in usual months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q4_a_* {
			label variable `rgvar' "What was the average monthly interest paid on loans in 2024? (in Rs.) 2024"
			note `rgvar': "What was the average monthly interest paid on loans in 2024? (in Rs.) 2024"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q7_* {
			label variable `rgvar' "In the last month, how much did your enterprise spend on \${cost2024}? (Please e"
			note `rgvar': "In the last month, how much did your enterprise spend on \${cost2024}? (Please exclude any personal or household expenses)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q9_* {
			label variable `rgvar' "Did this enterprise ever own \${cost2023}?"
			note `rgvar': "Did this enterprise ever own \${cost2023}?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q10_* {
			label variable `rgvar' "For the enterprise operation, what is the ownership of this \${cost2023}?"
			note `rgvar': "For the enterprise operation, what is the ownership of this \${cost2023}?"
			label define `rgvar' 1 "Own" 2 "Rented" 3 "Both"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q13_* {
			label variable `rgvar' "What was the total amount spent on \${cost2023} in 2023? (in Rs.)"
			note `rgvar': "What was the total amount spent on \${cost2023} in 2023? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q11_* {
			label variable `rgvar' "During January 2023 to December 2023, how much did you spend on \${cost2023} in "
			note `rgvar': "During January 2023 to December 2023, how much did you spend on \${cost2023} in peak months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q12_* {
			label variable `rgvar' "During January 2023 to December 2023, how much did you spend on \${cost2023} in "
			note `rgvar': "During January 2023 to December 2023, how much did you spend on \${cost2023} in usual months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q11_a_* {
			label variable `rgvar' "What was the average monthly interest paid on loans in 2023?"
			note `rgvar': "What was the average monthly interest paid on loans in 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q15_* {
			label variable `rgvar' "Did this enterprise ever own \${cost2022}?"
			note `rgvar': "Did this enterprise ever own \${cost2022}?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q16_* {
			label variable `rgvar' "For the enterprise operation, what is the ownership of this \${cost2022}?"
			note `rgvar': "For the enterprise operation, what is the ownership of this \${cost2022}?"
			label define `rgvar' 1 "Own" 2 "Rented" 3 "Both"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec9_q19_* {
			label variable `rgvar' "What was the total amount spent on \${cost2022} in 2022? (in Rs.)"
			note `rgvar': "What was the total amount spent on \${cost2022} in 2022? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q17_* {
			label variable `rgvar' "During January 2022 to December 2022, how much did you spend on \${cost2022} in "
			note `rgvar': "During January 2022 to December 2022, how much did you spend on \${cost2022} in peak months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q18_* {
			label variable `rgvar' "During January 2022 to December 2022, how much did you spend on \${cost2022} in "
			note `rgvar': "During January 2022 to December 2022, how much did you spend on \${cost2022} in usual months? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec9_q17_a_* {
			label variable `rgvar' "What was the average monthly interest paid on loans in 2022? (in Rs.)"
			note `rgvar': "What was the average monthly interest paid on loans in 2022? (in Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q2_* {
			label variable `rgvar' "Does your enterprise currently own \${assets_item_2024}?"
			note `rgvar': "Does your enterprise currently own \${assets_item_2024}?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q3_* {
			label variable `rgvar' "What is the unit of measurement for \${assets_item_2024}?"
			note `rgvar': "What is the unit of measurement for \${assets_item_2024}?"
			label define `rgvar' 1 "Acres" 2 "Sq. Feet" 3 "Sq. meter" 4 "Number" 5 "Cent"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q4_* {
			label variable `rgvar' "How many units of \${assets_item_2024} do you own as of December 2024?"
			note `rgvar': "How many units of \${assets_item_2024} do you own as of December 2024?"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q5_* {
			label variable `rgvar' "What is the current market value of your \${assets_item_2024} units? (In Rs.)"
			note `rgvar': "What is the current market value of your \${assets_item_2024} units? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q6_* {
			label variable `rgvar' "If you had not owned \${assets_item_2024}, what would be your monthly rent payme"
			note `rgvar': "If you had not owned \${assets_item_2024}, what would be your monthly rent payment in 2024? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q7_* {
			label variable `rgvar' "What is your current monthly rental payment for \${assets_item_2024} in 2024? (I"
			note `rgvar': "What is your current monthly rental payment for \${assets_item_2024} in 2024? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q9_* {
			label variable `rgvar' "Did this enterprise own \${assets_item_2023} in 2023?"
			note `rgvar': "Did this enterprise own \${assets_item_2023} in 2023?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q10_* {
			label variable `rgvar' "What is the Units of measurement of \${assets_item_2023}?"
			note `rgvar': "What is the Units of measurement of \${assets_item_2023}?"
			label define `rgvar' 1 "Acres" 2 "Sq. Feet" 3 "Sq. meter" 4 "Number" 5 "Cent"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q11_* {
			label variable `rgvar' "How many units of \${assets_item_2023} did this enterprise own in December 2023?"
			note `rgvar': "How many units of \${assets_item_2023} did this enterprise own in December 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q12_* {
			label variable `rgvar' "What was the market value of your \${assets_item_2023} units? (In Rs.)"
			note `rgvar': "What was the market value of your \${assets_item_2023} units? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q13_* {
			label variable `rgvar' "If you had not owned \${assets_item_2023}, what would be your monthly rent payme"
			note `rgvar': "If you had not owned \${assets_item_2023}, what would be your monthly rent payment in 2023? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q14_* {
			label variable `rgvar' "What was the monthly rental value of \${assets_item_2023} paid in 2023?"
			note `rgvar': "What was the monthly rental value of \${assets_item_2023} paid in 2023?"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q16_* {
			label variable `rgvar' "Did this enterprise own \${assets_item_2022} in 2022?"
			note `rgvar': "Did this enterprise own \${assets_item_2022} in 2022?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q17_* {
			label variable `rgvar' "Units of measurement of \${assets_item_2022}"
			note `rgvar': "Units of measurement of \${assets_item_2022}"
			label define `rgvar' 1 "Acres" 2 "Sq. Feet" 3 "Sq. meter" 4 "Number" 5 "Cent"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec10_q18_* {
			label variable `rgvar' "How many units of \${assets_item_2022} did this enterprise own in December 2022?"
			note `rgvar': "How many units of \${assets_item_2022} did this enterprise own in December 2022?"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q19_* {
			label variable `rgvar' "What was the market value of your \${assets_item_2022} units? (In Rs.)"
			note `rgvar': "What was the market value of your \${assets_item_2022} units? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q20_* {
			label variable `rgvar' "If you had not owned \${assets_item_2022}, what would be your monthly rent payme"
			note `rgvar': "If you had not owned \${assets_item_2022}, what would be your monthly rent payment in 2022? (In Rs.)"
		}
	}

	capture {
		foreach rgvar of varlist sec10_q21_* {
			label variable `rgvar' "What was the monthly rental value of \${assets_item_2022} paid in 2022?"
			note `rgvar': "What was the monthly rental value of \${assets_item_2022} paid in 2022?"
		}
	}

	capture {
		foreach rgvar of varlist sec17_q9_* {
			label variable `rgvar' "Number of Beans Used in \${MGP_utlisation} (out of 10)"
			note `rgvar': "Number of Beans Used in \${MGP_utlisation} (out of 10)"
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_1_* {
			label variable `rgvar' "Name of the contact"
			note `rgvar': "Name of the contact"
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_2_* {
			label variable `rgvar' "How would you describe your relationship with \${sec19_q2_1}?"
			note `rgvar': "How would you describe your relationship with \${sec19_q2_1}?"
			label define `rgvar' 1 "Friend/neighbor (not family)" 2 "Business peer / fellow entrepreneur (not family)" 3 "Supplier / buyer / customer" 4 "Bank/financial officer / microfinance staff" 5 "NGO worker / OSF/ECP staff (including MGP official)" 6 "Extended family relative (not in your household)" 7 "Other (specify)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_3_* {
			label variable `rgvar' "Where does this contact primarily live or operate their business?"
			note `rgvar': "Where does this contact primarily live or operate their business?"
			label define `rgvar' 1 "Same village/town" 2 "Same block, different village/town" 3 "Same district, different block" 4 "Outside this district" 5 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_4_* {
			label variable `rgvar' "Gender of \${sec19_q2_1}?"
			note `rgvar': "Gender of \${sec19_q2_1}?"
			label define `rgvar' 0 "Male" 1 "Female" 2 "Others"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_5_* {
			label variable `rgvar' "Approximate age of this \${sec19_q2_1}?"
			note `rgvar': "Approximate age of this \${sec19_q2_1}?"
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_6_* {
			label variable `rgvar' "\${sec19_q2_1} belongs to which caste?"
			note `rgvar': "\${sec19_q2_1} belongs to which caste?"
			label define `rgvar' 1 "Scheduled Caste" 2 "Scheduled Tribe" 3 "Backward Class" 4 "Most Backward Class" 5 "General" 6 "No Caste/category/Tribe"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_7_* {
			label variable `rgvar' "To your knowledge, has \${sec19_q2_1} received the Matching Grant Program (MGP) "
			note `rgvar': "To your knowledge, has \${sec19_q2_1} received the Matching Grant Program (MGP) loan?"
			label define `rgvar' 1 "Yes, they received MGP" 2 "No, they did not receive MGP" 3 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_8_* {
			label variable `rgvar' "How often do you TAKE ADVICE from \${sec19_q2_1}?"
			note `rgvar': "How often do you TAKE ADVICE from \${sec19_q2_1}?"
			label define `rgvar' 1 "Daily or almost daily" 2 "Weekly" 3 "Monthly" 4 "Less than once a month" 5 "Rarely / almost never"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_9_* {
			label variable `rgvar' "On a scale of 1 (very weak) to 5 (very strong), how would you rate your relation"
			note `rgvar': "On a scale of 1 (very weak) to 5 (very strong), how would you rate your relationship with \${sec19_q2_1}?"
			label define `rgvar' 1 "Very weak" 2 "Weak" 3 "Moderate" 4 "Strong" 5 "Very strong"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_10a_* {
			label variable `rgvar' "What kind(s) of BUSINESS ADVICE do you receive from \${sec19_q2_1}?"
			note `rgvar': "What kind(s) of BUSINESS ADVICE do you receive from \${sec19_q2_1}?"
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_10b_* {
			label variable `rgvar' "What kind(s) of BUSINESS INFORMATION do you exchange with \${sec19_q2_1}?"
			note `rgvar': "What kind(s) of BUSINESS INFORMATION do you exchange with \${sec19_q2_1}?"
		}
	}

	capture {
		foreach rgvar of varlist sec19_q2_10c_* {
			label variable `rgvar' "What kind(s) of PRACTICAL HELP do you receive from \${sec19_q2_1}?"
			note `rgvar': "What kind(s) of PRACTICAL HELP do you receive from \${sec19_q2_1}?"
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  C:/Users/Debanjan Das/Desktop/TNRTP/MGP/Analysis/MGP Final_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
