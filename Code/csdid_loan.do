
gen half_yearly_disbursement = hofd(dofq(quarterly_disbursement_date))
format half_yearly_disbursement %th
label var half_yearly_disbursement "Half-yearly period of disbursement"



keeporder enterprise_id DistrictCode District BlockCode BlockCode PanchayatCode Panchayat treatment_285 cohort_new half_yearly_disbursement any_loan_*




forvalues y = 2020/2025 {
    forvalues h = 1/2 {
        if !(`y' == 2025 & `h' == 2) {
            capture rename any_loan_`y'_H`h' any_loan_`y'h`h'
        }
    }
}

reshape long any_loan_, i(enterprise_id) j(time_str) string

gen year = real(substr(time_str, 1, 4)), after(time_str)
gen half = real(substr(time_str, -1, 1)), after(year)

gen time = yh(year, half), after(half)
format time %th

drop time_str year half

rename any_loan_ any_loan

encode enterprise_id, gen(enterprise_id_num)
xtset enterprise_id_num time

gen first_treat = half_yearly_disbursement, after(time)
format first_treat %th


gen treated = !missing(first_treat), after(first_treat)


gen rel_time = time - first_treat if treated == 1, after(treated)
replace rel_time = 0 if treated == 0


gen post = (time >= first_treat) & treated == 1, after(rel_time)



gen gvar = first_treat, after(post)
recode gvar (. = 0)

gen never_treat = (first_treat == .), after(gvar)


sum first_treat
gen last_cohort = (first_treat == r(max)) | never_treat, after(never_treat)



csdid z_any_loan, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_any_loan)

event_plot cs_any_loan, default_look graph_opt(xtitle("half relative to treatment") ytitle("Effect on loan taken") ///
	title("Effect of Matching Grant on Profit") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together



	
	
	
gen half_yearly_disbursement = hofd(dofq(quarterly_disbursement_date))
format half_yearly_disbursement %th
label var half_yearly_disbursement "Half-yearly period of disbursement"



global Scratch "V:\Projects\TNRTP\MGP\Analysis\Scratch"
global ent_d_contr "female_owner ent_nature_* ent_location_*"
global ent_c_contr "e_age age_entrepreneur marriage_age education_yrs std_digit_span risk_count"
global age_vars "e_age age_entrepreneur"




keeporder enterprise_id DistrictCode District BlockCode Block PanchayatCode Panchayat treatment_285 cohort_new half_yearly_disbursement ///
    any_loan_* ///
	loan_count_* ///
    formal_loan_20*  ///
    informal_loan_20*  ///
    formal_loan_count_*  ///
    informal_loan_count_* ///
	loan_amount_20* 		///
	formal_amount_*			///
	informal_amount_*			///
    total_loan_remaining_*		///
    log_total_loan_remaining_* ///
	avg_int_rate_*	///
	formal_int_rate_* 	///
	informal_int_rate_*		///
	avg_int_rate_*		///
	fixed_capital_loan_* 		///
	fixed_capital_amount_* 		///
	working_capital_* 			///
	consumption_loan_* 			///
	consumption_amount_*		///
    quarterly_disbursement_date sec1_q9 ipw $ent_d_contr $ent_c_contr $age_vars
	
	

	
forvalues y = 2020/2025 {
    forvalues h = 1/2 {
        if !(`y' == 2025 & `h' == 2) {
            capture rename any_loan_`y'_H`h' any_loan_`y'h`h'
            capture rename formal_loan_`y'_H`h' formal_loan_`y'h`h'
            capture rename informal_loan_`y'_H`h' informal_loan_`y'h`h'
            capture rename loan_count_`y'_H`h' loan_count_`y'h`h'
            capture rename formal_loan_count_`y'_H`h' formal_count_`y'h`h'
            capture rename informal_loan_count_`y'_H`h' informal_count_`y'h`h'
            capture rename total_loan_remaining_`y'_H`h' loan_remain_`y'h`h'
            capture rename log_total_loan_remaining_`y'_H`h' log_loan_remain_`y'h`h'
        }
    }
}

reshape long any_loan_ formal_loan_ informal_loan_ loan_count_ formal_count_ informal_count_ loan_remain_ log_loan_remain_, i(enterprise_id) j(time_str) string

* Extract year and half from time_str
gen year = real(substr(time_str, 1, 4)), after(time_str)
gen half = real(substr(time_str, -1, 1)), after(year)

* Create time variable
gen time = yh(year, half), after(half)
format time %th

* Drop intermediary variables
drop time_str year half

* Rename outcomes for easier handling
rename any_loan_ any_loan
rename formal_loan_ formal_loan
rename informal_loan_ informal_loan
rename loan_count_ loan_count
rename formal_count_ formal_count
rename informal_count_ informal_count
rename loan_remain_ loan_remain
rename log_loan_remain_ log_loan_remain

foreach var in any_loan formal_loan informal_loan loan_count formal_count informal_count loan_remain log_loan_remain {
    egen z_`var' = std(`var')
}

encode enterprise_id, gen(enterprise_id_num)
xtset enterprise_id_num time

gen first_treat = half_yearly_disbursement, after(time)
format first_treat %th

gen treated = !missing(first_treat), after(first_treat)

gen rel_time = time - first_treat if treated == 1, after(treated)
replace rel_time = 0 if treated == 0

gen post = (time >= first_treat) & treated == 1, after(rel_time)

gen gvar = first_treat, after(post)
recode gvar (. = 0)

gen never_treat = (first_treat == .), after(gvar)

sum first_treat
gen last_cohort = (first_treat == r(max)) | never_treat, after(never_treat)


* Any loan indicator
csdid z_any_loan, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-6 5) estore(cs_any_loan)

* Formal loan access
csdid z_formal_loan, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_formal_loan)

* Informal loan access
csdid z_informal_loan, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_informal_loan)

* Total loan count
csdid z_loan_count, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_loan_count)

* Formal loan count
csdid z_formal_count, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_formal_count)

* Informal loan count
csdid z_informal_count, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_informal_count)

* Outstanding loan amount
csdid z_loan_remain, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_loan_remain)

* Log outstanding loan amount
csdid z_log_loan_remain, ivar(enterprise_id_num) time(time) gvar(gvar) notyet
estat all
estat event, window(-4 8) estore(cs_log_loan_remain)

* 3.2 Create event study plots
* Plot for any loan indicator
event_plot cs_any_loan, default_look graph_opt(xtitle("Half-years relative to treatment") ytitle("Effect on loan probability (std)") ///
    title("Effect of Matching Grant on Loan Take-up") xlabel(-6(1)5)) stub_lag(Tp#) stub_lead(Tm#) together
graph export "any_loan_event_study.png", replace

* Plot comparing formal vs informal loan access
event_plot cs_formal_loan cs_informal_loan, stub_lag(Tp#) stub_lead(Tm#) ///
    plottype(scatter) ciplottype(rcap) ///
    together graph_opt(xtitle("Half-years relative to treatment") ///
    ytitle("Effect on probability (std)") title("Effect on Formal vs. Informal Loan Access") ///
    xlabel(-4(1)8) legend(order(1 "Formal loan access" 2 "Informal loan access")) ///
    graphregion(color(white)) plotregion(color(white)))
graph export "formal_vs_informal_access_event_study.png", replace

* Plot for loan count
event_plot cs_loan_count, default_look graph_opt(xtitle("Half-years relative to treatment") ytitle("Effect on loan count (std)") ///
    title("Effect of Matching Grant on Number of Loans") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together
graph export "loan_count_event_study.png", replace

* Plot comparing formal vs informal loan counts
event_plot cs_formal_count cs_informal_count, stub_lag(Tp#) stub_lead(Tm#) ///
    plottype(scatter) ciplottype(rcap) ///
    together graph_opt(xtitle("Half-years relative to treatment") ///
    ytitle("Effect on loan count (std)") title("Effect on Formal vs. Informal Loan Count") ///
    xlabel(-4(1)8) legend(order(1 "Formal loans" 2 "Informal loans")) ///
    graphregion(color(white)) plotregion(color(white)))
graph export "formal_vs_informal_count_event_study.png", replace

* Plot for outstanding loan amount (log)
event_plot cs_log_loan_remain, default_look graph_opt(xtitle("Half-years relative to treatment") ytitle("Effect on log loan amount (std)") ///
    title("Effect of Matching Grant on Outstanding Loan Amount") xlabel(-4(1)8)) stub_lag(Tp#) stub_lead(Tm#) together
graph export "log_loan_remain_event_study.png", replace

* Plot comparing all loan outcomes (key metrics)
event_plot cs_any_loan cs_loan_count cs_log_loan_remain, stub_lag(Tp#) stub_lead(Tm#) ///
    plottype(scatter) ciplottype(rcap) ///
    together graph_opt(xtitle("Half-years relative to treatment") ///
    ytitle("Standardized effect size") title("Effect of Matching Grant on Loan Outcomes") ///
    xlabel(-4(1)8) legend(order(1 "Loan probability" 2 "Loan count" 3 "Log loan amount")) ///
    graphregion(color(white)) plotregion(color(white)))
graph export "combined_loan_outcomes_event_study.png", replace






