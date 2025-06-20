employed_any_2022 employed_any_2023 employed_any_2024
total_employment_2022 total_employment_2023 total_employment_2024
perm_workers_2022 perm_workers_2023 perm_workers_2024 
temp_workers_2022 temp_workers_2023 temp_workers_2024
perm_share_2022 perm_share_2023 perm_share_2024 
temp_share_2022 temp_share_2023 temp_share_2024
perm_workdays_2022  perm_workdays_2023 perm_workdays_2024
temp_workdays_2022 temp_workdays_2023  temp_workdays_2024   
perm_workdays_peak_2022  perm_workdays_peak_2023 perm_workdays_peak_2024
perm_workdays_usual_2022 perm_workdays_usual_2023 perm_workdays_usual_2024
temp_workdays_peak_2022 temp_workdays_peak_2023 temp_workdays_peak_2024
temp_workdays_usual_2022 temp_workdays_usual_2023 temp_workdays_usual_2024
total_labor_cost_2022 total_labor_cost_2023 total_labor_cost_2024






global derived_data "V:\Projects\TNRTP\MGP\Analysis\Data\derived"
global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


/*==============================================================================
    PANEL DATA PREPARATION FOR EMPLOYMENT ANALYSIS
==============================================================================*/

// Treatment variables (same as investment analysis)
gen treated_2022 = (quarterly_disbursement_date == tq(2022q4)) if !missing(quarterly_disbursement_date)
replace treated_2022 = 0 if missing(quarterly_disbursement_date)

gen treated_2023 = 0
replace treated_2023 = 1 if inlist(quarterly_disbursement_date, tq(2022q4), tq(2023q1), tq(2023q2), tq(2023q3), tq(2023q4))

gen treated_2024 = 0  
replace treated_2024 = 1 if !missing(quarterly_disbursement_date)

label var treated_2022 "Treated in 2022"
label var treated_2023 "Treated in 2023" 
label var treated_2024 "Treated in 2024"

// Covariates (same as investment analysis)
global cov HouseholdIncome MaritalStatus HouseholdSavings ent_asset_index Cashatbank Cashathand CurrentSupplyAnnual PresentDemandAnnual age_entrepreneur std_digit_span brti_count ECP_Score CIBILscore

/*==============================================================================
					EMPLOYMENT PANEL DATA SETUP 
==============================================================================*/

preserve

keeporder enterprise_id District DistrictCode Block BlockCode Panchayat PanchayatCode ///
     treatment_285 quarterly_disbursement_date treated_* ///
     employed_any_* total_employment_* perm_workers_* temp_workers_* ///
     perm_share_* temp_share_* perm_workdays_* temp_workdays_* ///
     perm_workdays_peak_* perm_workdays_usual_* temp_workdays_peak_* temp_workdays_usual_* ///
     total_labor_cost_* ///
     ent_running _weight female_owner sec2_q2

// Keep only running enterprises	 
keep if ent_running == 1

// Create numeric enterprise ID for panel
encode enterprise_id, gen(enterprise_id_num)
la var enterprise_id_num "Enterprise ID (numeric for panel)"

// Reshape from wide to long format
reshape long employed_any_ total_employment_ perm_workers_ temp_workers_ ///
            perm_share_ temp_share_ perm_workdays_ temp_workdays_ ///
            perm_workdays_peak_ perm_workdays_usual_ temp_workdays_peak_ temp_workdays_usual_ ///
            total_labor_cost_ treated_, ///
            i(enterprise_id) j(year)

// Set panel structure			
xtset enterprise_id_num year
xtdes

// Rename variables (remove trailing underscore)
rename employed_any_ employed_any
rename total_employment_ total_employment
rename perm_workers_ perm_workers
rename temp_workers_ temp_workers
rename perm_share_ perm_share
rename temp_share_ temp_share
rename perm_workdays_ perm_workdays
rename temp_workdays_ temp_workdays
rename perm_workdays_peak_ perm_workdays_peak
rename perm_workdays_usual_ perm_workdays_usual
rename temp_workdays_peak_ temp_workdays_peak
rename temp_workdays_usual_ temp_workdays_usual
rename total_labor_cost_ total_labor_cost
rename treated_ treated

// Add variable labels
label var employed_any "Employed any workers in year t (0/1)"
label var total_employment "Total number of workers employed in year t"
label var perm_workers "Number of permanent workers in year t"
label var temp_workers "Number of temporary workers in year t"

label var perm_share "Share of permanent workers in total workforce in year t"
label var temp_share "Share of temporary workers in total workforce in year t"

label var perm_workdays "Total worker-days for permanent workers in year t"
label var temp_workdays "Total worker-days for temporary workers in year t"
label var perm_workdays_peak "Total worker-days for permanent workers in peak months year t"
label var perm_workdays_usual "Total worker-days for permanent workers in usual months year t"
label var temp_workdays_peak "Total worker-days for temporary workers in peak months year t"
label var temp_workdays_usual "Total worker-days for temporary workers in usual months year t"

label var total_labor_cost "Total labor costs in year t (Rs.)"

label var treated "Received MGP treatment by year t (0/1)"

// Generate year-specific treatment effects
gen treat_2022 = treated * (year == 2022)
gen treat_2023 = treated * (year == 2023)  
gen treat_2024 = treated * (year == 2024)

label var treat_2022 "Treatment effect in 2022 (treated*2022)"
label var treat_2023 "Treatment effect in 2023 (treated*2023)"
label var treat_2024 "Treatment effect in 2024 (treated*2024)"

// Test basic model
xtreg employed_any treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)


zscore 	total_employment perm_workers temp_workers perm_share temp_share perm_workdays	///
		temp_workdays perm_workdays_peak perm_workdays_usual temp_workdays_peak 		///
		temp_workdays_usual total_labor_cost

// Run employment analysis on z-score variables
foreach var in employed_any z_total_employment z_perm_workers z_temp_workers z_perm_workdays z_temp_workdays z_total_labor_cost z_perm_share z_temp_share {
	xtreg `var' treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)
}





// Store results for employment table generation
eststo clear
local i=1
foreach var in employed_any z_total_employment z_perm_workers z_temp_workers z_perm_workdays {
    xtreg `var' treat_2022 treat_2023 treat_2024 i.year, fe vce(cluster BlockCode)
    
    * Test joint significance of treatment effects
    test treat_2022 treat_2023 treat_2024
    estadd scalar pval_joint=r(p)
    
    estadd local enterprise_fe "YES"
    estadd local year_fe "YES"
    estadd local clustering "Block"
    estadd local covariates "NO"
    
    sum `var' if e(sample) & treat_2022==0 & treat_2023==0 & treat_2024==0
    estadd scalar mean_control=r(mean)
    
    eststo employment_table_`i'
    local i=`i'+1
}

// Generate employment analysis table
#delimit ;
esttab employment_table_1 employment_table_2 employment_table_3 employment_table_4 employment_table_5 using "$Scratch/employment_analysis.rtf", replace depvar legend label nonumbers nogaps nonotes ///
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps ///
    keep(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    order(treat_2022 treat_2023 treat_2024 2023.year 2024.year) ///
    stats(N mean_control pval_joint enterprise_fe year_fe covariates clustering, 
          fmt(%9.0g %9.3f %9.3f %s %s %s %s) 
          labels("Observations" "Comparison Group Mean" "Joint Test P-value" "Enterprise FE" "Year FE" "Covariates" "SE Clustering")) ///
    mtitles("Any Employment" "Total Employment (z)" "Permanent Workers (z)" "Temporary Workers (z)" "Permanent Workdays (z)") ///
    title("Table X: Impact of MGP on Employment") ///
    addnotes("Standard errors clustered at the block level" 
			"Z-score variables are standardized with mean 0 and standard deviation 1"
			"Permanent and temporary workers refer to employment contract types"
			"Workdays measure work intensity beyond headcount effects") ;
#delimit cr

restore	


























