/*==============================================================================
                    VARIABLE PREPARATION FOR PDSLASSO
==============================================================================*/

global tables "V:\Projects\TNRTP\MGP\Analysis\Tables"
global scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"


encode BlockCode, gen(BlockCode_num)
label variable BlockCode_num "Block number (numeric)"

global ent_d_contr "ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span brti_count"
global all_controls "$ent_c_contr $ent_d_contr BlockCode_num"

**female_owner ent_nature_* 

/*==============================================================================
           FINAL CONTROL VARIABLE SET FOR PDS LASSO, replacing missing values
==============================================================================*/

global miss_ent_d_contr ""
global dmiss_ent_d_contr ""

foreach var of varlist $ent_d_contr {
    cap drop dmiss_`var'
    gen dmiss_`var' = missing(`var')
    
    cap drop miss_`var'
    gen miss_`var' = `var'
    replace miss_`var' = 0 if missing(`var')
    
    global miss_ent_d_contr "$miss_ent_d_contr miss_`var'"
    global dmiss_ent_d_contr "$dmiss_ent_d_contr dmiss_`var'"
}

global miss_ent_c_contr ""
global dmiss_ent_c_contr ""

foreach var of varlist $ent_c_contr {
    cap drop dmiss_`var'
    gen dmiss_`var' = missing(`var')
    
    cap drop miss_`var'
    gen miss_`var' = `var'
    replace miss_`var' = 0 if missing(`var')
    
    global miss_ent_c_contr "$miss_ent_c_contr miss_`var'"
    global dmiss_ent_c_contr "$dmiss_ent_c_contr dmiss_`var'"
}

global controls "$miss_ent_d_contr $dmiss_ent_d_contr $miss_ent_c_contr $dmiss_ent_c_contr BlockCode_num"


/*==============================================================================
                        PDS-LASSO ANALYSIS OF Innovation
==============================================================================*/

eststo clear
local i=1
local selected_vars_all ""

// Run PDS-LASSO for variable selection and store results
foreach var of varlist any_innovation tot_innovation log_total_innov_invest_w1 innovation_score {
    
    pdslasso `var' treatment_285 ($controls), cluster(BlockCode) partial(BlockCode_num)
 
    test treatment_285==0
    estadd scalar pval1=r(p)
    sum `var' if e(sample) & treatment_285 == 0
    estadd scalar mean=r(mean)
    
    // Set Selected_cov to "Yes" only if variables were selected, otherwise "No"
    if "`e(xselected)'" != "" {
        estadd local Selected_cov "Yes"
    }
    else {
        estadd local Selected_cov "No"
    }
    
    estadd local Block_FE "Yes"
    
    local var_label : var label `var'
    if "`var_label'"=="" local var_label "`var'"
    
    local labeled_selected_vars ""
    foreach sel_var in `e(xselected)' {
        // Map miss_ variables to their original descriptions
        local desc_var = ""
        if "`sel_var'" == "miss_ent_location_1" local desc_var "Located in main marketplace"
        else if "`sel_var'" == "miss_ent_location_2" local desc_var "Located in secondary marketplace"  
        else if "`sel_var'" == "miss_ent_location_3" local desc_var "Located on street with other businesses"
        else if "`sel_var'" == "miss_ent_location_4" local desc_var "Located in residential area"
        else if "`sel_var'" == "miss_e_age" local desc_var "Age of the enterprise (years)"
        else if "`sel_var'" == "miss_age_entrepreneur" local desc_var "Age of the entrepreneur"
        else if "`sel_var'" == "miss_marriage_age" local desc_var "Marriage age if ever married"
        else if "`sel_var'" == "miss_education_yrs" local desc_var "Years of education of enterprise owner"
        else if "`sel_var'" == "miss_std_digit_span" local desc_var "Standardized digit span score"
        else if "`sel_var'" == "miss_brti_count" local desc_var "Business Risk Tolerance Index"
        else if "`sel_var'" == "miss_female_owner" local desc_var "Female entrepreneur"
        else if "`sel_var'" == "miss_ent_nature_1" local desc_var "Manufacturing enterprise"
        else if "`sel_var'" == "miss_ent_nature_2" local desc_var "Trade/Retail/Sales enterprise"
        else if "`sel_var'" == "miss_ent_nature_3" local desc_var "Service enterprise"
        else if "`sel_var'" == "dmiss_std_digit_span" local desc_var "Missing indicator: Standardized digit span score"
        else if "`sel_var'" == "BlockCode_num" local desc_var "Block number"
        else {
            local sel_var_label : var label `sel_var'
            if "`sel_var_label'"=="" local desc_var "`sel_var'"
            else local desc_var "`sel_var_label'"
        }
        
        local labeled_selected_vars "`labeled_selected_vars' `desc_var',"
    }
    
    if strlen("`labeled_selected_vars'") > 0 {
        local labeled_selected_vars = substr("`labeled_selected_vars'", 1, strlen("`labeled_selected_vars'")-1)
    } 
    else {
        local labeled_selected_vars "None"
    }
    
    // Create appropriate column names for each innovation variable
    local outcome_name ""
    if "`var'" == "any_innovation" local outcome_name "Any Innovation"
    else if "`var'" == "tot_innovation" local outcome_name "Total Innovation Count"
    else if "`var'" == "total_innov_invest" local outcome_name "Total Investment (Log)"
    else if "`var'" == "innovation_score" local outcome_name "Innovation Score"
    else local outcome_name "`var'"
    
    local selected_vars_all "`selected_vars_all' Column `i' (`outcome_name'): `labeled_selected_vars';"
    
    eststo model_A_`i'
    local i=`i'+1
}

#delimit ;
esttab model_A_* using "$Scratch/innovation_pdslasso.rtf", 
    replace 
    label 
    nonumbers 
    nogaps 
    b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) 
    keep(treatment_285) 
    varlabels(treatment_285 "MGP")
    title("Table: Impact of MGP on Innovation") 
    mtitles("Any Innovation" "Total Number of Innovation" "Total Investment made in Innovation (Log)" "Innovation Score") 
    stats(mean N pval1 Selected_cov Block_FE, 
        fmt(%9.3f %9.0g %9.3f %9s %9s) 
        labels("Mean of Comparison Group" "Observations" "P-value" "Selected Covariates" "Block FE"))
    addnotes("Results from PDS-Lasso model for covariate selection."
	         "Innovation indicators based on survey questions: New/improved products/services,"
             "New/improved technology, New/improved logistics/delivery,"
             "New/improved marketing methods, Business website, Business email)."
             "Variable construction: Any Innovation = 1 if any of the 6 innovation types were introduced;"
             "Total Count = sum of 6 innovation types (product, technology, process, marketing, website, email);"
             "Investment = total investment made in any of the innovations (Rs.);"
             "Innovation Score = average proportion of innovation indicators adopted out of total 6 indicators"
             "Standard errors clustered at block level.") ;
#delimit cr











/*
Heterogeneous treatment effects analysis following author's approach
Creates single comprehensive table with multiple baseline characteristics
*/
cap program drop business_hetero_comprehensive
program define business_hetero_comprehensive
	clear mata
	syntax, ///
		OUTCOMES(varlist) /// Outcomes to analyze
		TREAT(name) /// Treatment variable
		STRATA(name) /// Fixed effects in regression
		[REGRESSORS(varlist)] /// Optional regressors
		FILENAME(string) // Filename to print output

	local number_dep_vars = `:word count `outcomes''
	if `number_dep_vars' > 2 {
		display as error "Only 2 outcomes can be passed to business_hetero_comprehensive"
		exit
	}

	// Define all baseline characteristics to analyze
	local all_dummies "female_owner ent_nature_1 ent_nature_2 ent_nature_3"
	local dummy_labels `""Female entrepreneur" "Manufacturing enterprise" "Trade/Retail/Sales enterprise" "Service enterprise""'
	local number_dummies = `:word count `all_dummies''

	mat control_mean = J(`number_dep_vars',1,.)
	
	mat reg_1 = J(`number_dummies', 6, .)
	mat reg_2 = J(`number_dummies', 6, .)

	mat stars_1 = J(`number_dummies', 6, 0)
	mat stars_2 = J(`number_dummies', 6, 0)

	mat rownames control_mean = `outcomes'
	mat rownames reg_1 = `all_dummies'
	mat rownames reg_2 = `all_dummies'

	mat rownames stars_1 = `all_dummies'
	mat rownames stars_2 = `all_dummies'

	local y_counter = 1
    foreach y in `outcomes'{ 
    	mean `y' if `treat' == 0
    	mat mean_mat = e(b)
    	mat control_mean[`y_counter', 1] = mean_mat[1,1]

        qui xtset `strata'

		local dummy_counter = 1
		foreach dummy in `all_dummies' {

			cap drop _treat_0
			cap drop _treat_1

			gen _treat_0 = `treat'
			gen _treat_1 = `treat' * `dummy'

			qui pdslasso `y' _treat_0 _treat_1 `dummy' (`regressors'), ///
				cluster(BlockCode) partial(`strata') fe r
        
	        mat b = e(b)
			mata st_matrix("se",sqrt(diagonal(st_matrix("e(V)"))))

		    // Effect for dummy = 0 (No)
		    mat reg_`y_counter'[`dummy_counter', 1] = b[1,1]
		    mat reg_`y_counter'[`dummy_counter', 2] = se[1,1]

        	local p = (2 * ttail(e(N), abs(b[1,1]/se[1,1])))
            if (`p' < .1)   mat stars_`y_counter'[`dummy_counter',2] = 1
            if (`p' < .05)  mat stars_`y_counter'[`dummy_counter',2] = 2
            if (`p' < .01)  mat stars_`y_counter'[`dummy_counter',2] = 3

           	// Difference (interaction effect)
		    mat reg_`y_counter'[`dummy_counter', 5] = b[1,2]
		    mat reg_`y_counter'[`dummy_counter', 6] = se[2,1]

        	local p = (2 * ttail(e(N), abs(b[1,2]/se[2,1])))
            if (`p' < .1)   mat stars_`y_counter'[`dummy_counter',6] = 1
            if (`p' < .05)  mat stars_`y_counter'[`dummy_counter',6] = 2
            if (`p' < .01)  mat stars_`y_counter'[`dummy_counter',6] = 3

            // Effect for dummy = 1 (Yes)
		    lincom _treat_0 + _treat_1
		    mat reg_`y_counter'[`dummy_counter', 3] = `r(estimate)'
		    mat reg_`y_counter'[`dummy_counter', 4] = `r(se)'

        	local p = `r(p)'
            if (`p' < .1)   mat stars_`y_counter'[`dummy_counter',4] = 1
            if (`p' < .05)  mat stars_`y_counter'[`dummy_counter',4] = 2
            if (`p' < .01)  mat stars_`y_counter'[`dummy_counter',4] = 3
        	
        	local ++dummy_counter
        }
	    local ++y_counter
    }

    cap drop _treat_0
    cap drop _treat_1

	// Create custom row labels using the descriptive names
	mat rownames reg_1 = `dummy_labels'
	mat rownames reg_2 = `dummy_labels'
	mat rownames stars_1 = `dummy_labels'
	mat rownames stars_2 = `dummy_labels'

	qui frmttable, statmat(reg_1) sdec(3) annotate(stars_1) asymbol(*,**,***) varlabels substat(1) squarebrack 
	
	// Only merge second matrix if we have 2 outcomes
	if `number_dep_vars' == 2 {
		qui frmttable, statmat(reg_2) sdec(3) annotate(stars_2) asymbol(*,**,***) varlabels merge substat(1) squarebrack 
	}

	local y1_lab : variable label `:word 1 of `outcomes''
	if `number_dep_vars' == 2 {
		local y2_lab : variable label `:word 2 of `outcomes''
	}

	// Create output table following author's format
	if `number_dep_vars' == 2 {
		frmttable using "$scratch/temp_table", ///
		ctitle( ///
		"", "`y1_lab'", "", "", "`y2_lab'", "", "" \ ///
		"", "Subgroup Treatment Effects", "", "", "Subgroup Treatment Effects", "", "" \ ///
		"Baseline characteristic", "No", "Yes", "Difference", "No", "Yes", "Difference" ///
		) ///
		multicol(1,2,3;1,5,3;2,2,2;2,5,2) ///
		varlabels ///
		nocenter ///
		title("Table: Treatment-characteristic interactions") ///
		note("Regressions control for randomization strata and additional controls selected by pdslasso." ///
			 "Robust standard errors in parentheses clustered at Block level." ///
			 "*, **, and *** denote significance at the 10, 5, and 1 percent levels respectively.") ///
		replace
	}
	else {
		frmttable using "$scratch/temp_table", ///
		ctitle( ///
		"", "`y1_lab'", "", "" \ ///
		"", "Subgroup Treatment Effects", "", "" \ ///
		"Baseline characteristic", "No", "Yes", "Difference" ///
		) ///
		multicol(1,2,3;2,2,2) ///
		varlabels ///
		nocenter ///
		title("Table: Treatment-characteristic interactions") ///
		note("Controls variable selected by pdslasso." ///
			 "Robust standard errors in parentheses clustered at Block level." ///
			 "*, **, and *** denote significance at the 10, 5, and 1 percent levels respectively.") ///
		replace
	}

	// Convert to Word document and clean up
	copy "$scratch/temp_table.doc" "$scratch/`filename'"
	erase "$scratch/temp_table.doc"
	
	display "================================================================================"
	display "COMPREHENSIVE HETEROGENEOUS TREATMENT EFFECTS ANALYSIS COMPLETED"
	display "================================================================================"
	display "Baseline characteristics analyzed:"
	display "- Female entrepreneur"
	display "- Manufacturing enterprise" 
	display "- Trade/Retail/Sales enterprise"
	display "- Service enterprise"
	display ""
	display "Results saved to: $scratch/`filename'"
	display "================================================================================"

end


business_hetero_comprehensive, ///
    outcomes(any_innovation  innovation_score) ///
    treat(treatment_285) ///
    strata(BlockCode_num) ///
    regressors($controls) ///
    filename("HTE_Innovation.doc")
