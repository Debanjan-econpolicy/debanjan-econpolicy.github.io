***********************Directory************************************************
global main "C:/Users/Camila Steffens/Dropbox/JDE_Steffens_Pereda"

*global main "C:/Users/csf/Dropbox/JDE_Steffens_Pereda"
global do "$main/dofiles"
global data "$main/data"
global results "$main/results"
global desc "$results/descriptive"
global appendix "$results/appendix"
********************************************************************************


**************************** DATA **********************************************
** Generating individual-level smoking trajectories from PNS 2013
do "$do/0_data.do"

**************************** DESCRIPTIVE ***************************************

*** Fig. 1: map
do "$do/01_map_fig1.do"

*** Fig. 2 + smoking prevalence & sample characteristics for analysis 
do "$do/02_descriptive_fig2.do"

*** Tab. 1, Appendix Tab B1, Appendix Fig. B1 & B2: other policies
do "$do/03_policies_tab1.do"

**************************** MAIN RESULTS **************************************

**** Fig. 3a & Appendix Tab. B5: average effects on prevalence
do "$do/11_estimates_fig3a.do"

**** Fig. 3b & Appendix Tab. B6: effects on prevalence by enforcement
do "$do/12_estimates_fig3b.do"

**** Fig. 3c, 3d & Appendix Tab. B7: effects on prevalence - leave-one-out
do "$do/13_estimates_fig3c_3d.do"

**** Tab. 2: placebo estimates cessation and initiation
do "$do/14_estimates_tab2.do"

**** Tab. 3: other risky behaviors
do "$do/15_estimates_tab3.do"

**** Fig. 4 & Appendix Tab. B8: effects on initiation and cessation
do "$do/16_estimates_fig4.do"

**** Tab. 4: decomposition of smoking prevalence
do "$do/17_estimates_tab4.do"

**** Tab. 5 & Appendix Tab. B9, B10: cessation by addiction level
do "$do/18_estimates_tab5.do"

*** Size of the effects and cost-saving analysis
do "$do/19_cost_saving.do"

*** Footnote: results for adults & equivalence of cessation measures
do "$do/20_footnote_adults.do"


************************ APPENDIX A (Data/Fit) ********************************
*** Tables and Figures Appendix A + Appendix Table B2 
do "$do/21_appendix_a.do"

********** APPENDIX B: Staggered and Identifying Assumptions ******************
*** Tab B3: heterogeneous effects by cohorts
do "$do/22_appendix_b3.do"

*** Tab B4: staggered adoption (Sun and Abrahan, 2001)
do "$do/23_appendix_b4.do"

*Appendix Tables B1 and B5 - B10 complement the main results and are generated from the main dofiles above 

***************** APPENDIX B: Additional Robustnes ****************************

*** Table B11: alternative treatment and control groups
do "$do/24_appendix_b11.do"

*** Table B12: balanced sample of individuals (sample restriction by birth cohort instead of age)
do "$do/25_appendix_b12.do"

*** Table B13: heterogeneity by HH income per capita 
do "$do/26_appendix_b13.do"

*** Table B14: heterogeneity by unit of implementation (state or state's capital only)
do "$do/27_appendix_b14.do"

*** Table B15: enforcement by region: central-south and northern regions
do "$do/28_appendix_b15.do"

*** Table B16: alternative thresholds for smoking cessation
do "$do/29_appendix_b16.do"

************* APPENDIX C: Pre-trends with Asymmetrical Outcomes ****************
do "$do/30_appendix_c.do"