

cap program drop make_qreg_graph
program define make_qreg_graph
	syntax, ///
		OUTCOME(varname) ///
		TREAT(varname) ///
		NUMQUANTILES(integer) ///
		CONTROLS(varlist) ///
		STRATA(varname) ///
		FILENAME(string) ///
		[CLUSTER(varname)]

	// Set color scheme like the author
	set scheme s1mono 

	// Initialize matrices - EXACTLY like author
	mat quantiles = J(`numquantiles'+1, 1, .)
	mat lasso = J(`numquantiles'+1, 1, .)
	mat betas = J(`numquantiles'+1, 1, .)
	mat ses = J(`numquantiles'+1, 1, .)
	mat cilower = J(`numquantiles'+1, 1, .)
	mat cihigher = J(`numquantiles'+1, 1, .)

	local q_counter = 1

	// Set panel structure - EXACTLY like author
	xtset `strata'

	local y `outcome'

	// Step 1: Run PDSLASSO to select controls - EXACTLY like author
	disp "=== Running PDSLASSO for variable selection ==="
	
	if "`cluster'" != "" {
		pdslasso `y' `treat' (`controls'), cluster(`cluster') partial(`strata')
	}
	else {
		pdslasso `y' `treat' (`controls'), partial(`strata') fe r
	}
	
	// Store LASSO coefficient - EXACTLY like author
	local lasso_coef = e(b)[1,1]
	disp "LASSO treatment coefficient: " `lasso_coef'
	
	// Get selected controls from PDSLASSO
	local selected_controls "`e(xselected)'"
	disp "Selected controls: `selected_controls'"
	
	// Step 2: Calculate quantile spacing - EXACTLY like author
	local diff = (.95 - .05) / (`numquantiles')
	disp "Quantile spacing: `diff'"

	// Step 3: Run quantile regressions across quantiles - Author's approach with robustness
	forvalues q = .05(`diff').95 {
		disp "*******"
		disp "q: `q'"
		disp "q_counter: `q_counter'"

		// Store LASSO coefficient for each quantile - EXACTLY like author
		mat lasso[`q_counter', 1] = `lasso_coef'
		
		// Run quantile regression with selected controls
		local converged = 0
		
		if "`selected_controls'" != "" {
			// Try with selected controls first
			cap qui qreg `y' `treat' `selected_controls', quantile(`q') vce(robust) iterate(2000)
			if _rc == 0 {
				local converged = 1
				local method "qreg with controls"
			}
		}
		else {
			// No controls selected by LASSO
			cap qui qreg `y' `treat', quantile(`q') vce(robust) iterate(2000)
			if _rc == 0 {
				local converged = 1
				local method "qreg no controls"
			}
		}
		
		// Store results if converged
		if `converged' == 1 {
			mat quantiles[`q_counter', 1] = `q'
			mat betas[`q_counter', 1] = _b[`treat']
			mat ses[`q_counter', 1] = _se[`treat']
			mat cilower[`q_counter', 1] = _b[`treat'] - 1.96 * _se[`treat']
			mat cihigher[`q_counter', 1] = _b[`treat'] + 1.96 * _se[`treat']
			
			disp "Converged using `method': beta = " %8.2f _b[`treat'] ", se = " %8.2f _se[`treat']
		}
		else {
			disp "Failed to converge at quantile `q'"
			
			// Store missing values
			mat quantiles[`q_counter', 1] = `q'
			mat betas[`q_counter', 1] = .
			mat ses[`q_counter', 1] = .
			mat cilower[`q_counter', 1] = .
			mat cihigher[`q_counter', 1] = .
		}

		local ++q_counter
	}

	// Step 4: Create matrices and variables - EXACTLY like author
	mat all = quantiles, lasso, betas, ses, cilower, cihigher
	mat colnames all = "quantile" "lasso" "beta" "se" "cilower" "cihigher"

	// Clean up existing variables
	cap drop quantile lasso beta se cilower cihigher

	// Create variables from matrices
	svmat all, names(col)

	// Step 5: Create the plot - EXACTLY like author's style
	local ylab `:variable label `y''
	if "`ylab'" == "" {
		local ylab "`y'"
	}
	
	twoway ///
		(line beta quantile if !missing(beta), lcolor(blue) lwidth(medium)) ///
		(line cilower quantile if !missing(cilower), color(grey%30)) ///
		(line cihigher quantile if !missing(cihigher), color(grey%30)) ///
		(line lasso quantile if !missing(lasso), color(red)), ///
		yline(0) ///
		legend(order(1 "Quantile treatment" 2 "Lower CI" 3 "Upper CI" 4 "Lasso treatment")) ///
		title("`ylab'") ///
		graphregion(color(white)) plotregion(color(white))

	// Step 6: Export graphs - EXACTLY like author
	graph export "`filename'.png", replace as(png)
	graph save "`filename'.gph", replace

	// Step 7: Display results summary
	disp ""
	disp "=== PDSLASSO and Quantile Regression Results ==="
	disp "LASSO selected controls: `selected_controls'"
	disp "LASSO treatment effect: " %8.2f `lasso_coef'
	
	// Count successful quantiles
	qui count if !missing(beta)
	local n_converged = r(N)
	disp "Quantiles converged: `n_converged'/`numquantiles'"
		
	// Clean up
	cap drop quantile lasso beta se cilower cihigher
end

global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"
la var monthly_sale "Last Month Sales (January, 2025)"
la var log_monthly_sale "Log of Last Month Sales (January, 2025)"

global NUM_QUANTILES 20

make_qreg_graph, ///
    outcome(log_monthly_sale) ///
    treat(treatment_285) ///
    numquantiles($NUM_QUANTILES) ///
    controls($controls) ///
    strata(BlockCode_num) ///
    filename("$Scratch/quantile_reg_log_monthly_sales")




make_qreg_graph, ///
    outcome(log_monthly_profit) ///
    treat(treatment_285) ///
    numquantiles($NUM_QUANTILES) ///
    controls($controls) ///
    strata(BlockCode_num) ///
    filename("$Scratch/quantile_reg_log_monthly_profit")

	
	


