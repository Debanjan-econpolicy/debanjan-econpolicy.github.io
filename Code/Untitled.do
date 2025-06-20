


/* Complete corrected code for MGP impact graphs with mathematical accuracy */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. ANY LOAN */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.3826433, treatment_285 = 0.6544466 */
replace value = 0.3826 if group == 1 /* Control constant (_cons) */
replace value = 0.3826 + 0.6544 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Any Loan", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.2)1.2, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.654*** (0.021)", size(small)) ///
    name(plot1, replace)

/* 2. NUMBER OF LOANS */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.3662095, treatment_285 = 0.6767524 */
replace value = 0.3662 if group == 1 /* Control constant (_cons) */
replace value = 0.3662 + 0.6768 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Number of Loans", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.2)1.2, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.677*** (0.022)", size(small)) ///
    name(plot2, replace)

/* 3. FORMAL LOAN SOURCE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.8423464, treatment_285 = 0.1589916 */
replace value = 0.8423 if group == 1 /* Control constant (_cons) */
replace value = 0.8423 + 0.1590 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Formal Loan Source", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.2)1.2, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.159*** (0.022)", size(small)) ///
    name(plot3, replace)

/* 4. OUTSTANDING LOAN */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 11.53264, treatment_285 = 0.2739389 */
replace value = 11.53 if group == 1 /* Control constant (_cons) */
replace value = 11.53 + 0.27 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Log Outstanding Loan", size(medium)) ///
    ytitle("Log Value", size(small)) ///
    ylabel(0(2)12, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.274*** (0.097)", size(small)) ///
    name(plot4, replace)

/* 5. INTEREST RATE - MATHEMATICALLY CORRECT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 14.73069, treatment_285 = 2.938748 */
replace value = 14.73 if group == 1 /* Control constant (_cons) */
replace value = 14.73 + 2.94 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Interest Rate (%)", size(medium)) ///
    ytitle("Percent", size(small)) ///
    ylabel(0(5)20, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.1f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 2.94* (1.53)", size(small)) ///
    name(plot5, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3 plot4 plot5, ///
    col(3) ///
    row(2) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Enterprise Financing", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(6) ///
    xsize(12) ///
    scale(1) ///
    name(financing_impact, replace) 

graph export "mgp_financing_impact.png", replace width(3000)


























































/* Code for MGP impact on investment behavior graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. ANY INVESTMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.8638237, treatment_285 = 0.086769 */
replace value = 0.8638 if group == 1 /* Control constant (_cons) */
replace value = 0.8638 + 0.0868 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Any Investment", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.2)1, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.087*** (0.015)", size(small)) ///
    name(plot1, replace)

/* 2. INVESTMENT AMOUNT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 210073.6, treatment_285 = 24745.67 */
replace value = 210074 if group == 1 /* Control constant (_cons) */
replace value = 210074 + 24746 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Investment Amount", size(medium)) ///
    ytitle("Amount (₹)", size(small)) ///
    ylabel(0(100000)250000, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.0fc) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: ₹24,746*** (9,244)", size(small)) ///
    name(plot2, replace)

/* 3. INVESTMENT TYPES COUNT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.8211371, treatment_285 = -0.0180955 (not significant) */
replace value = 0.8211 if group == 1 /* Control constant (_cons) */
replace value = 0.8211 - 0.0181 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Investment Types", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.2)1, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.018 (0.023)", size(small)) ///
    name(plot3, replace)

/* 4. WORKING CAPITAL INVESTMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.9793346, treatment_285 = -0.0238859 */
replace value = 0.9793 if group == 1 /* Control constant (_cons) */
replace value = 0.9793 - 0.0239 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Working Capital Investment", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.2)1, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.024** (0.011)", size(small)) ///
    name(plot4, replace)

/* 5. WORKING CAPITAL SHARE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.975834, treatment_285 = -0.033506 */
replace value = 0.9758 if group == 1 /* Control constant (_cons) */
replace value = 0.9758 - 0.0335 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Working Capital Share", size(medium)) ///
    ytitle("Share", size(small)) ///
    ylabel(0(0.2)1, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.034** (0.013)", size(small)) ///
    name(plot5, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3 plot4 plot5, ///
    col(3) ///
    row(2) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Investment Behavior", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(6) ///
    xsize(12) ///
    scale(1) ///
    name(investment_impact, replace) 

graph export "mgp_investment_impact.png", replace width(3000)


























/* Code for MGP impact on repayment behavior graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. ANY DELAY */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.070044, treatment_285 = 0.0401768 */
replace value = 0.070044 if group == 1 /* Control constant (_cons) */
replace value = 0.070044 + 0.0401768 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Any Delay", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.02)0.12, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.040** (0.019)", size(small)) ///
    name(plot1, replace)

/* 2. FREQUENT DELAYS */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.017526, treatment_285 = 0.0085027 */
replace value = 0.017526 if group == 1 /* Control constant (_cons) */
replace value = 0.017526 + 0.0085027 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Frequent Delays", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.005)0.03, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.009 (0.008)", size(small)) ///
    name(plot2, replace)

/* 3. LONG DELAY */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.0168589, treatment_285 = -0.0008428 */
replace value = 0.0168589 if group == 1 /* Control constant (_cons) */
replace value = 0.0168589 - 0.0008428 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Long Delay", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.005)0.02, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.001 (0.007)", size(small)) ///
    name(plot3, replace)

/* 4. REPAYMENT DIFFICULTY */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.1159502, treatment_285 = 0.0198334 */
replace value = 0.1159502 if group == 1 /* Control constant (_cons) */
replace value = 0.1159502 + 0.0198334 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Repayment Difficulty", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.02)0.14, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.020 (0.023)", size(small)) ///
    name(plot4, replace)

/* 5. TOTAL PAYMENTS */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.1269048, treatment_285 = 0.1112612 */
replace value = 0.1269048 if group == 1 /* Control constant (_cons) */
replace value = 0.1269048 + 0.1112612 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Total Payments", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.05)0.25, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.111* (0.059)", size(small)) ///
    name(plot5, replace)

/* 6. REPAYMENT BEHAVIOR */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.0525433, treatment_285 = 0.0174255 */
replace value = 0.0525433 if group == 1 /* Control constant (_cons) */
replace value = 0.0525433 + 0.0174255 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Repayment Behavior", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.01)0.08, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.017* (0.010)", size(small)) ///
    name(plot6, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3 plot4 plot5 plot6, ///
    col(3) ///
    row(2) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Repayment Behavior", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(6) ///
    xsize(12) ///
    scale(1) ///
    name(repayment_impact, replace) 

graph export "mgp_repayment_impact.png", replace width(3000)

/* OPTIONAL: MAX DELAY LENGTH */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 1.785944, treatment_285 = 0.5071202 */
replace value = 1.785944 if group == 1 /* Control constant (_cons) */
replace value = 1.785944 + 0.5071202 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Max Delay Length", size(medium)) ///
    ytitle("Days", size(small)) ///
    ylabel(0(0.5)2.5, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.507 (0.652)", size(small)) ///
    name(plot7, replace)





	
	
	
	
	
	
	









/* Code for MGP impact on business practices graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. MARKETING SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.4296904, treatment_285 = 0.0196443 */
replace value = 0.4296904 if group == 1 /* Control constant (_cons) */
replace value = 0.4296904 + 0.0196443 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Marketing Practices", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.1)0.5, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.020 (0.016)", size(small)) ///
    name(plot1, replace)

/* 2. STOCK SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.6027646, treatment_285 = 0.0222083 */
replace value = 0.6027646 if group == 1 /* Control constant (_cons) */
replace value = 0.6027646 + 0.0222083 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Stock Control Practices", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.1)0.7, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.022* (0.012)", size(small)) ///
    name(plot2, replace)

/* 3. RECORD SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.5251813, treatment_285 = 0.0322104 */
replace value = 0.5251813 if group == 1 /* Control constant (_cons) */
replace value = 0.5251813 + 0.0322104 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Record Keeping Practices", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.1)0.6, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.032** (0.013)", size(small)) ///
    name(plot3, replace)

/* 4. PLANNING SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.3290514, treatment_285 = 0.0110027 */
replace value = 0.3290514 if group == 1 /* Control constant (_cons) */
replace value = 0.3290514 + 0.0110027 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Financial Planning Practices", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.1)0.4, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.011 (0.009)", size(small)) ///
    name(plot4, replace)

/* 5. TOTAL SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.4582174, treatment_285 = 0.0204729 */
replace value = 0.4582174 if group == 1 /* Control constant (_cons) */
replace value = 0.4582174 + 0.0204729 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Total Business Practice Score", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.1)0.5, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.020** (0.008)", size(small)) ///
    name(plot5, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3 plot4 plot5, ///
    col(3) ///
    row(2) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Business Practices", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(6) ///
    xsize(12) ///
    scale(1) ///
    name(business_practices_impact, replace) ///
    note("Business practice scores developed using 26 binary indicators across four domains: marketing (7 practices), buying and stock control (3 practices), record-keeping (8 practices),and financial planning (8 practices)." "Each domain score represents the proportion of practices adopted, and the total score is the average of all domains.", size(vsmall))

graph export "mgp_business_practices_impact.png", replace width(3000)
































/* Code for MGP impact on employment graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. ANY EMPLOYMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.4643349, treatment_285 = 0.0637932 */
replace value = 0.4643349 if group == 1 /* Control constant (_cons) */
replace value = 0.4643349 + 0.0637932 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Any Employment", size(medium)) ///
    ytitle("Probability", size(small)) ///
    ylabel(0(0.1)0.6, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.064*** (0.022)", size(small)) ///
    name(plot1, replace)

/* 2. TOTAL EMPLOYMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 1.931474, treatment_285 = 0.3352446 */
replace value = 1.931474 if group == 1 /* Control constant (_cons) */
replace value = 1.931474 + 0.3352446 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Total Employment", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.5)2.5, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.335*** (0.119)", size(small)) ///
    name(plot2, replace)

/* 3. PAID EMPLOYMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 1.06713, treatment_285 = 0.4214496 */
replace value = 1.06713 if group == 1 /* Control constant (_cons) */
replace value = 1.06713 + 0.4214496 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Paid Employment", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.3)1.5, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.421*** (0.139)", size(small)) ///
    name(plot3, replace)

/* 4. UNPAID EMPLOYMENT */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 1.715761, treatment_285 = -0.035219 */
replace value = 1.715761 if group == 1 /* Control constant (_cons) */
replace value = 1.715761 - 0.035219 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Unpaid Employment", size(medium)) ///
    ytitle("Count", size(small)) ///
    ylabel(0(0.5)2, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.035 (0.037)", size(small)) ///
    name(plot4, replace)

/* 5. PAID EMPLOYMENT SHARE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.2305496, treatment_285 = 0.0434503 */
replace value = 0.2305496 if group == 1 /* Control constant (_cons) */
replace value = 0.2305496 + 0.0434503 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Paid Employment Share", size(medium)) ///
    ytitle("Share", size(small)) ///
    ylabel(0(0.05)0.3, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.043*** (0.014)", size(small)) ///
    name(plot5, replace)

/* 6. UNPAID EMPLOYMENT SHARE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.7694231, treatment_285 = -0.0434334 */
replace value = 0.7694231 if group == 1 /* Control constant (_cons) */
replace value = 0.7694231 - 0.0434334 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Unpaid Employment Share", size(medium)) ///
    ytitle("Share", size(small)) ///
    ylabel(0(0.1)0.8, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: -0.043*** (0.014)", size(small)) ///
    name(plot6, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3 plot4 plot5 plot6, ///
    col(3) ///
    row(2) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Employment", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(6) ///
    xsize(12) ///
    scale(1) ///
    name(employment_impact, replace) ///
    note("Paid employees are workers who receive wages or salary.Unpaid employees include family members or others working without formal compensation.", size(vsmall))

graph export "mgp_employment_impact.png", replace width(3000)





















/* Code for MGP impact on business performance graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. MONTHLY PROFIT (LOG) */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 9.611433, treatment_285 = 0.0179963 */
replace value = 9.611433 if group == 1 /* Control constant (_cons) */
replace value = 9.611433 + 0.0179963 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Log Monthly Profit", size(medium)) ///
    ytitle("Log Value", size(small)) ///
    ylabel(0(2)10, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.018 (0.054)", size(small)) ///
    name(plot1, replace)

/* 2. MONTHLY SALES (LOG) */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 10.34035, treatment_285 = 0.0618001 */
replace value = 10.34035 if group == 1 /* Control constant (_cons) */
replace value = 10.34035 + 0.0618001 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Log Monthly Sales", size(medium)) ///
    ytitle("Log Value", size(small)) ///
    ylabel(0(2)12, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.2f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.062 (0.043)", size(small)) ///
    name(plot2, replace)

/* 3. INNOVATION SCORE */
clear
set obs 2
gen group = _n
label define grouplab 1 "Control" 2 "Treatment"
label values group grouplab
gen value = .
/* From regression: _cons = 0.0541401, treatment_285 = 0.0102344 */
replace value = 0.0541401 if group == 1 /* Control constant (_cons) */
replace value = 0.0541401 + 0.0102344 if group == 2 /* Treatment = Control + coefficient */

/* Create the bar graph */
graph bar value, over(group) ///
    title("Innovation Score", size(medium)) ///
    ytitle("Score", size(small)) ///
    ylabel(0(0.01)0.07, labsize(small)) ///
    asyvars ///
    bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, format(%9.3f) size(small)) ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    plotregion(color(white)) ///
    note("Coef: 0.010* (0.006)", size(small)) ///
    name(plot3, replace)

/* Combine all graphs into a single figure */
graph combine plot1 plot2 plot3, ///
    col(3) ///
    row(1) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    title("Impact of MGP on Business Performance", size(medium) color(black)) ///
    subtitle("PDS-Lasso Treatment Effects with Block Fixed Effects", size(small) color(black)) ///
    ysize(4) ///
    xsize(12) ///
    scale(1) ///
    name(business_performance_impact, replace) ///
    note("All specifications include Block fixed effects with standard errors clustered at the Block level." "* p < 0.10, ** p < 0.05, *** p < 0.01", size(vsmall))

graph export "mgp_business_performance_impact.png", replace width(3000)





































/* Code for DiD line graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. PROFIT DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 10.70112 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 10.70112 + 0 if time==1 & group==1 /* Control After */
replace value = 10.70112 + 0.0456155 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Profit", size(medium)) ///
       ytitle("Log Profit", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(10.5(0.2)11.5, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(11.5 0.5 "DiD Estimate: 0.046", size(small)) ///
       text(11.45 0.5 "p = 0.118", size(small)) ///
       name(did_profit, replace)

/* 2. REVENUE DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 11.12023 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 11.12023 + 0 if time==1 & group==1 /* Control After */
replace value = 11.12023 + 0.0736198 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Revenue", size(medium)) ///
       ytitle("Log Revenue", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(11.0(0.2)11.8, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(11.7 0.5 "DiD Estimate: 0.074***", size(small)) ///
       text(11.65 0.5 "p = 0.000", size(small)) ///
       name(did_revenue, replace)

/* 3. COSTS DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 10.09892 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 10.09892 + 0 if time==1 & group==1 /* Control After */
replace value = 10.09892 + 0.1965208 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Costs", size(medium)) ///
       ytitle("Log Costs", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(10.0(0.2)10.8, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(10.7 0.5 "DiD Estimate: 0.197***", size(small)) ///
       text(10.65 0.5 "p = 0.000", size(small)) ///
       name(did_costs, replace)

/* Combine all graphs into a single figure */
graph combine did_profit did_revenue did_costs, ///
    col(3) ///
    row(1) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    ysize(4) ///
    xsize(12) ///
    scale(1) ///
    note("Panel fixed effects regression with standard errors clustered at block level. Time period fixed effects included." "* p < 0.10, ** p < 0.05, *** p < 0.01", size(vsmall)) ///
    name(did_combined, replace)

graph export "mgp_did_impact.png", replace width(3000)























/* Code for DiD line graphs with accurate values */

cd "C:\Users\Debanjan Das\Desktop\TNRTP\MGP\Analysis\Graph"

/* 1. PROFIT DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 10.70112 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 10.70112 + 0 if time==1 & group==1 /* Control After */
replace value = 10.70112 + 0.0456155 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Profit", size(medium)) ///
       ytitle("Log Profit", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(10.5(0.2)11.5, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(11.5 0.5 "DiD Estimate: 0.046", size(small)) ///
       text(11.45 0.5 "p = 0.118", size(small)) ///
       name(did_profit, replace)

/* 2. REVENUE DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 11.12023 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 11.12023 + 0 if time==1 & group==1 /* Control After */
replace value = 11.12023 + 0.0736198 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Revenue", size(medium)) ///
       ytitle("Log Revenue", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(11.0(0.2)11.8, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(11.7 0.5 "DiD Estimate: 0.074***", size(small)) ///
       text(11.65 0.5 "p = 0.000", size(small)) ///
       name(did_revenue, replace)

/* 3. COSTS DiD GRAPH */
clear
set obs 4
gen group = ceil(_n/2)
gen time = mod(_n-1,2)
label define grouplab 1 "Control" 2 "Treatment (MGP)"
label values group grouplab
label define timelab 0 "Before" 1 "After"
label values time timelab
gen value = .

/* Assume "Before" values are the same for control and treatment (from _cons value) */
replace value = 10.09892 if time==0 /* Both groups start at same value (from _cons) */
/* For "After" values, use coefficient to calculate the difference */
replace value = 10.09892 + 0 if time==1 & group==1 /* Control After */
replace value = 10.09892 + 0.1965208 if time==1 & group==2 /* Treatment After = Control + did_effect */

/* Create the line graph */
twoway (connected value time if group==1, lcolor(navy) mcolor(navy) msymbol(circle)) ///
       (connected value time if group==2, lcolor(forest_green) mcolor(forest_green) msymbol(square)), ///
       title("Difference-in-Differences: MGP Impact on Costs", size(medium)) ///
       ytitle("Log Costs", size(small)) ///
       xtitle("") ///
       xlabel(0 "Before" 1 "After", labsize(small)) ///
       ylabel(10.0(0.2)10.8, labsize(small)) ///
       legend(order(1 "Control" 2 "Treatment (MGP)") size(small)) ///
       graphregion(color(white)) ///
       bgcolor(white) ///
       plotregion(color(white)) ///
       text(10.7 0.5 "DiD Estimate: 0.197***", size(small)) ///
       text(10.65 0.5 "p = 0.000", size(small)) ///
       name(did_costs, replace)

/* Combine all graphs into a single figure */
graph combine did_profit did_revenue did_costs, ///
    col(3) ///
    row(1) ///
    imargin(small) ///
    graphregion(color(white) margin(small)) ///
    ysize(4) ///
    xsize(12) ///
    scale(1) ///
    note("Panel fixed effects regression with standard errors clustered at block level. Time period fixed effects included." "* p < 0.10, ** p < 0.05, *** p < 0.01", size(vsmall)) ///
    name(did_combined, replace)

graph export "mgp_did_impact.png", replace width(3000)




