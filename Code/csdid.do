global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"
global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span risk_count"
global age_vars "e_age age_entrepreneur"




keeporder enterprise_id DistrictCode District BlockCode BlockCode PanchayatCode Panchayat treatment_285 cohort_new ///
     total_costs_2022_q* total_costs_2023_q* total_costs_2024_q* ///
     total_revenue_2022_q* total_revenue_2023_q* total_revenue_2024_q* ///
     profit_2022_q* profit_2023_q* profit_2024_q* sec1_q9 quarterly_disbursement_date ipw ipw_new ent_running $ent_d_contr $ent_c_contr $age_vars 

* Create baseline age variables BEFORE reshape
bysort enterprise_id: egen baseline_e_age = min(e_age)
bysort enterprise_id: egen baseline_age_entrepreneur = min(age_entrepreneur)	 

* Define final controls with baseline ages
global controls "$ent_d_contr $ent_c_contr baseline_e_age baseline_age_entrepreneur"	
 
	 
* First, create a consistent naming pattern
forvalues y = 2022/2024 {
    forvalues q = 1/4 {
        capture rename total_costs_`y'_q`q' costs_`y'q`q'
        capture rename total_revenue_`y'_q`q' revenue_`y'q`q'
        capture rename profit_`y'_q`q' profit_`y'q`q'
    }
}

reshape long costs_ revenue_ profit_, i(enterprise_id) j(time_str) string



gen year = real(substr(time_str, 1, 4)), after(time_str)
gen quarter = real(substr(time_str, 6, 1)), after(year)
gen time = yq(year, quarter), after(quarter)
format time %tq
drop time_str year quarter

rename costs_ costs
rename revenue_ revenue
rename profit_ profit

encode enterprise_id, gen(enterprise_id_num)

xtset enterprise_id_num time

* Create first_treat variable (directly use quarterly_disbursement_date since it's already in quarterly format)
gen first_treat = quarterly_disbursement_date, after(time)
format first_treat %tq
* Create treatment indicator
gen treated = !missing(first_treat), after(first_treat)
* Create relative time variable
gen rel_time = time - first_treat if treated == 1, after(treated)
replace rel_time = 0 if treated == 0
* Create post-treatment indicator
gen post = (time >= first_treat) & treated == 1, after(rel_time)
* Create gvar for csdid (0 for never-treated)
gen gvar = first_treat, after(post)
recode gvar (. = 0)
format gvar %tq




* Create never-treated indicator
gen never_treat = (first_treat == .), after(gvar)

* Create last_cohort for Sun-Abraham estimator
sum first_treat
gen last_cohort = (first_treat == r(max)) | never_treat, after(never_treat)


encode BlockCode, gen(BlockCode_num)



zscore profit revenue costs

* Callaway and Sant'Anna estimator
csdid z_profit if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet 
estat all
estat event, window(-4 8) estore(cs_profit)



csdid z_revenue if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet 
estat all
estat event, window(-4 8) estore(cs_revenue)
csdid z_revenue,ivar(enterprise_id_num) time(time) gvar(gvar) notyet method(dripw)


csdid z_costs if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_costs)


* Plot for profit
event_plot cs_profit, default_look graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on profit") ///
	title("Effect of Matching Grant on Profit") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together 

graph export "profit_event_study.png", replace

estat event, window(-4 8)
csdid_plot, style(rarea) title("Effect of Matching Grant on Profit") ///
    xtitle("Quarters relative to treatment") ytitle("Effect on profit") 

	
	
* Plot for revenue
event_plot cs_revenue, default_look graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on revenue") ///
	title("Effect of Matching Grant on Revenue") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together

graph export "revenue_event_study.png", replace

* Plot for costs
event_plot cs_costs, default_look graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on costs") ///
	title("Effect of Matching Grant on Costs") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together

graph export "costs_event_study.png", replace




	
	
/*==============================================================================
							STAGGERED DID 
==============================================================================*/
eststo clear

foreach Y in z_profit z_revenue z_costs {
    csdid `Y' if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet method(dripw)
    local n_obs = e(N)
    estat event, window(-4 8) estore(`Y'_event)
    estat group, estore(`Y'_group)
    estat calendar, estore(`Y'_calendar)
    estat simple, post
    
    // Manually add the sample size (since post might not preserve it)
    estadd scalar N = `n_obs' 
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    eststo `Y'_att
}

/*==============================================================================
               MAIN RESULTS TABLE S (Panel A: ATT + Panel B: Groups)
==============================================================================*/

// Panel A: Simple ATT Effects
#delimit ;
esttab z_profit_att z_revenue_att z_costs_att using "$Scratch/Simple_Group.rtf", 
    replace 
    label 
    nonumbers
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table: Effects of Matching Grant Program on Enterprise Performance") 
    mtitles("Profit" "Revenue" "Costs") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    posthead("Panel A: Average Treatment Effects")
    addnotes("Panel A shows overall Average Treatment Effects (ATT).") ;
#delimit cr



// Panel B: Group-Specific Effects
#delimit ;
esttab z_profit_group z_revenue_group z_costs_group using "$Scratch/Simple_Group.rtf", 
    append 
    label 
    nonumbers 
    nomtitles
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    posthead("Panel B: Treatment Effects by Cohort")
    stats(N, fmt(%9.0g) labels("Observations"))
    addnotes("Panel B shows treatment effects by first treatment quarter." 
             "Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
             "Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. All outcomes are standardized (z-scores).") ;
#delimit cr



/*==============================================================================
                    TABLE 2: Simple ATT Effects Table (Individual)
==============================================================================*/
#delimit ;
esttab z_profit_att z_revenue_att z_costs_att using "$Scratch/Simple_ATT.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 2: Average Treatment Effects") 
    mtitles("Profit" "Revenue" "Costs") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. All outcomes are standardized (z-scores).") ;
#delimit cr

/*==============================================================================
                    TABLE 3: GROUP-SPECIFIC EFFECTS TABLE (Individual)
==============================================================================*/
#delimit ;
esttab z_profit_group z_revenue_group z_costs_group using "$Scratch/group_effects.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 3: Treatment Effects by Cohort") 
    mtitles("Profit" "Revenue" "Costs") 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    stats(N, fmt(%9.0g) labels("Observations"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Each cohort represents enterprises first treated in that quarter." 
             "Quarter codes: 251=2022Q3, 252=2022Q4, 253=2023Q1, 254=2023Q2, 255=2023Q3, 256=2023Q4, 257=2024Q1") ;
#delimit cr

/*==============================================================================
                    TABLE 4: EVENT STUDY TABLE 
==============================================================================*/
#delimit ;
esttab z_profit_event z_revenue_event z_costs_event using "$Scratch/event_study.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 4: Dynamic Treatment Effects - Event Study") 
    mtitles("Profit" "Revenue" "Costs") 
    keep(Pre_avg Post_avg Tm* Tp*)
    order(Pre_avg Post_avg Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4 Tp5 Tp6 Tp7 Tp8)
    stats(N, fmt(%9.0g) labels("Observations"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Pre_avg and Post_avg show average effects before and after treatment." 
             "Tm# = # quarters before treatment; Tp# = # quarters after treatment." 
             "Sample includes enterprises that were running during the study period.") ;
#delimit cr














/*==============================================================================
							STAGGERED DID 
==============================================================================*/
eststo clear

foreach Y in z_profit z_revenue z_costs {
    // Run csdid once and save RIF file
    csdid `Y' if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet method(dripw) saverif(_temp_`Y') replace
    local n_obs = e(N)
    
    // Store event study results
    estat event, window(-4 8) post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    eststo `Y'_event
    
    // Store group-specific results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats group, post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    eststo `Y'_group
    restore
    
    // Store calendar results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats calendar, post
    estadd scalar N = `n_obs'
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    eststo `Y'_calendar
    restore
    
    // Store simple ATT results (using saved RIF file)
    preserve
    use _temp_`Y', clear
    csdid_stats simple, post
    estadd scalar N = `n_obs' 
    estadd local Controls "No"
    estadd local Enterprise_FE "Yes" 
    estadd local Time_FE "Yes"
    eststo `Y'_att
    restore
    
    // Clean up temporary RIF file
    erase _temp_`Y'.dta
}

/*==============================================================================
               MAIN RESULTS TABLE S (Panel A: ATT + Panel B: Groups)
==============================================================================*/

// Panel A: Simple ATT Effects
#delimit ;
esttab z_profit_att z_revenue_att z_costs_att using "$Scratch/Simple_Group.rtf", 
    replace 
    label 
    nonumbers
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table: Impact of Matching Grant Program on Enterprise Performance") 
    mtitles("Profit" "Revenue" "Costs") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    posthead("Panel A: Average Treatment Effects")
    addnotes("Panel A shows overall Average Treatment Effects (ATT).") ;
#delimit cr

// Panel B: Group-Specific Effects
#delimit ;
esttab z_profit_group z_revenue_group z_costs_group using "$Scratch/Simple_Group.rtf", 
    append 
    label 
    nonumbers 
    nomtitles
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    posthead("Panel B: Treatment Effects by Cohort")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Panel B shows treatment effects by first treatment quarter." 
             "Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
             "Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. All outcomes are standardized (z-scores).") ;
#delimit cr

/*==============================================================================
                    TABLE 2: Simple ATT Effects Table (Individual)
==============================================================================*/
#delimit ;
esttab z_profit_att z_revenue_att z_costs_att using "$Scratch/Simple_ATT.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 2: Average Treatment Effects") 
    mtitles("Profit" "Revenue" "Costs") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator" 
             "with not-yet-treated control units. All outcomes are standardized (z-scores).") ;
#delimit cr

/*==============================================================================
                    TABLE 3: GROUP-SPECIFIC EFFECTS TABLE (Individual)
==============================================================================*/
#delimit ;
esttab z_profit_group z_revenue_group z_costs_group using "$Scratch/group_effects.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 3: Treatment Effects by Cohort") 
    mtitles("Profit" "Revenue" "Costs") 
    varlabels(GAverage "Overall Group Average"
              G251 "2022Q3 Cohort" 
              G252 "2022Q4 Cohort"
              G253 "2023Q1 Cohort"
              G254 "2023Q2 Cohort" 
              G255 "2023Q3 Cohort"
              G256 "2023Q4 Cohort"
              G257 "2024Q1 Cohort")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Each cohort represents enterprises first treated in that quarter." 
             "Quarter codes: 251=2022Q3, 252=2022Q4, 253=2023Q1, 254=2023Q2, 255=2023Q3, 256=2023Q4, 257=2024Q1") ;
#delimit cr

/*==============================================================================
                    TABLE 4: EVENT STUDY TABLE 
==============================================================================*/
#delimit ;
esttab z_profit_event z_revenue_event z_costs_event using "$Scratch/event_study.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Dynamic Treatment Effects of Matching Grant Program") 
    mtitles("(1) Profit" "(2) Revenue" "(3) Costs") 
    keep(Pre_avg Post_avg Tm* Tp*)
    order(Pre_avg Post_avg Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4 Tp5 Tp6 Tp7 Tp8)
    varlabels(Pre_avg "Pre-treatment average"
              Post_avg "Post-treatment average"
              Tm4 "t-4"
              Tm3 "t-3" 
              Tm2 "t-2"
              Tm1 "t-1"
              Tp0 "t=0"
              Tp1 "t+1"
              Tp2 "t+2"
              Tp3 "t+3"
              Tp4 "t+4"
              Tp5 "t+5"
              Tp6 "t+6"
              Tp7 "t+7"
              Tp8 "t+8")
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Controls" "Enterprise FE" "Time FE"))
    addnotes("Notes: Event study coefficients from Callaway and Sant'Anna (2021) estimator."
             "t=0 is the quarter of first grant receipt. All outcomes standardized."
             "Standard errors clustered by enterprise. *** p<0.01, ** p<0.05, * p<0.1") ;
#delimit cr
/*==============================================================================
                    TABLE 5: CALENDAR EFFECTS TABLE (Optional)
==============================================================================*/
#delimit ;
esttab z_profit_calendar z_revenue_calendar z_costs_calendar using "$Scratch/calendar_effects.rtf", 
    replace 
    label 
    nogaps
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) 
    title("Table 5: Calendar Time Effects") 
    mtitles("Profit" "Revenue" "Costs") 
    stats(N Controls Enterprise_FE Time_FE, 
        fmt(%9.0g %s %s %s) 
        labels("Observations" "Control Variables" "Enterprise Fixed Effects" "Time Fixed Effects"))
    addnotes("Standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." 
             "Calendar time effects show treatment effects by calendar period." 
             "Estimation uses Callaway and Sant'Anna (2021) doubly robust difference-in-differences estimator.") ;
#delimit cr


























/*==============================================================================
                    Event Study Plot usinf csdid plot 
==============================================================================*/
foreach Y in z_profit z_revenue z_costs {
	csdid `Y' if ent_running == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet method(dripw)
	estat event, window(-4 8)
	csdid_plot, style(rarea) ///
    title("Effect of Matching Grant on `Y'") ///
    xtitle("Quarters relative to treatment") ///
    ytitle("Effect on `Y' (standardized)") ///
    name(`Y'_plot, replace)
	graph export "$Scratch/`Y'_event_study.png", replace
	
}

// Create a combined graph showing all three outcomes
graph combine profit_plot revenue_plot costs_plot, ///
    rows(1) cols(2) ///
    name(combined_plots, replace)
graph export "$Scratch/combined_event_study.png", replace











/*==============================================================================
                    EVENT STUDY PLOTS 
==============================================================================*/

// Plot for profit
event_plot z_profit_event, default_look ///
    graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on profit (Z-Score)") ///
    title("Effect of Matching Grant on Profit", size(medlarge)) ///
    xlabel(-4(1)8) ylabel(, angle(horizontal) format(%9.2f)) ///
    xline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    yline(0, lcolor(gs10) lpattern(solid) lwidth(thin)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    legend(order(1 "Pre-treatment" 3 "Post-treatment") position(6) rows(1) size(medium)) ///
    name(profit_plot, replace)) ///
    stub_lag(Tp#) stub_lead(Tm#) ///
    lead_opt(color(maroon) lwidth(thick) msymbol(triangle) msize(medium)) ///
    lead_ci_opt(color(maroon%30) lwidth(none)) ///
    lag_opt(color(forest_green) lwidth(thick) msymbol(circle) msize(medium)) ///
    lag_ci_opt(color(forest_green%30) lwidth(none)) ///
    alpha(0.05)
graph export "$Scratch/profit_event_study.png", replace

// Plot for revenue
event_plot z_revenue_event, default_look ///
    graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on revenue (Z-Score)") ///
    title("Effect of Matching Grant on Revenue", size(medlarge)) ///
    xlabel(-4(1)8) ylabel(, angle(horizontal) format(%9.2f)) ///
    xline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    yline(0, lcolor(gs10) lpattern(solid) lwidth(thin)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    legend(order(1 "Pre-treatment" 3 "Post-treatment") position(6) rows(1) size(medium)) ///
    name(revenue_plot, replace)) ///
    stub_lag(Tp#) stub_lead(Tm#) ///
    lead_opt(color(maroon) lwidth(thick) msymbol(triangle) msize(medium)) ///
    lead_ci_opt(color(maroon%30) lwidth(none)) ///
    lag_opt(color(forest_green) lwidth(thick) msymbol(circle) msize(medium)) ///
    lag_ci_opt(color(forest_green%30) lwidth(none)) ///
    alpha(0.05)
graph export "$Scratch/revenue_event_study.png", replace

// Plot for costs
event_plot z_costs_event, default_look ///
    graph_opt(xtitle("Quarters relative to treatment") ytitle("Effect on costs (Z-Score)") ///
    title("Effect of Matching Grant on Costs", size(medlarge)) ///
    xlabel(-4(1)8) ylabel(, angle(horizontal) format(%9.2f)) ///
    xline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    yline(0, lcolor(gs10) lpattern(solid) lwidth(thin)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    legend(order(1 "Pre-treatment" 3 "Post-treatment") position(6) rows(1) size(medium)) ///
    name(costs_plot, replace)) ///
    stub_lag(Tp#) stub_lead(Tm#) ///
    lead_opt(color(maroon) lwidth(thick) msymbol(triangle) msize(small)) ///
    lead_ci_opt(color(maroon%30) lwidth(none)) ///
    lag_opt(color(forest_green) lwidth(thick) msymbol(circle) msize(small)) ///
    lag_ci_opt(color(forest_green%30) lwidth(none)) ///
    alpha(0.05)
graph export "$Scratch/costs_event_study.png", replace

/*==============================================================================
                    COMBINED PLOT
==============================================================================*/

// Combined horizontal layout
graph combine profit_plot revenue_plot costs_plot, ///
    cols(2) rows(1) ///
    graphregion(color(white) margin(medium)) ///
    name(combined_horizontal, replace) ///
    imargin(small) iscale(0.8)
graph export "$Scratch/combined_event_study_horizontal.png", replace width(1200) height(400)






































* 3.3 Generate leads and lags for additional analyses
* Calculate the range of relative time
summ rel_time
local relmin = abs(r(min))
local relmax = abs(r(max))

* Generate leads (pre-treatment dummies)
cap drop F_*
forval x = 2/`relmin' {  // drop the first lead (F_1) for reference
    gen F_`x' = (rel_time == -`x')
}

* Generate lags (post-treatment dummies)
cap drop L_*
forval x = 0/`relmax' {
    gen L_`x' = (rel_time == `x')
}

* 3.4 Traditional TWFE regression with leads and lags (for comparison)
* Note: This might be biased with staggered treatment
reghdfe profit F_* L_*, absorb(enterprise_id_num time) vce(cluster enterprise_id_num)

* 3.5 Summary statistics and balance tests
* Pre-treatment balance check
preserve
keep if time == yq(2022, 2)  // Pre-treatment period
ttest profit, by(treated)
ttest revenue, by(treated)
ttest costs, by(treated)
restore

table quarterly_disbursement_date, statistic(mean profit revenue costs) statistic(count profit)

* 3.6 Heterogeneity analysis by cohort
* Early vs late adopters
gen early_adopter = (first_treat <= yq(2023, 2)) if treated == 1

csdid profit if early_adopter != ., ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all

csdid profit if early_adopter == 0 & treated == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all

* Create a results table
eststo clear
eststo: csdid profit, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
eststo: csdid revenue, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
eststo: csdid costs, ivar(enterprise_id_num) time(time) gvar(gvar) notyet

esttab using "staggered_did_results.rtf", replace csv se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N N_clust, labels("Observations" "Enterprises")) ///
    title("Staggered DiD Results: Effect of Matching Grant Program")

* 3.8 Robustness checks
* Exclude 2022q4 cohort (very early adopters)
csdid profit if first_treat != yq(2022, 4) | never_treat == 1, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all

csdid profit, ivar(enterprise_id_num) time(time) gvar(gvar) anticipation(1) notyet
estat all