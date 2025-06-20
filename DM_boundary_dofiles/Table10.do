**********************************************************************************************************************************
**** Replication Files for Anderson and McKenzie 																				**
**** "Improving business practices and the boundary of the entrepreneur: A randomized experiment comparing training,            **
***** consulting, insourcing and outsourcing "																					**
**********************************************************************************************************************************

**********************************************************************************************************************************
**** Replication of Table 10 *****************************************************************************************************
**********************************************************************************************************************************

**** Set directory
cd "C:/Users/wb200090/OneDrive - WBG/otherresearch/Nigeria/JohanneMaterials/JPERevision/ReplicationData/"

*** Set Stata version
version 16.0

* Install packages needed
ssc install estout, replace

************************************************
*   Set Globals for Directories                 *
************************************************
	global constructdata "ConstructedData"
	global rawdata "RawData"
	global figures "output/figures"
	global tables  "output/tables"
	

use "$rawdata/InformationBaseline", clear
sort biz_id
merge biz_id using "$rawdata/InformationFollowup", sort

keep if _merge==3

**** Generate treatment indicators
gen infotreatment=cond(treatgroup>=2,1,0)
label var infotreatment "Assigned to Information Treatment"
gen infoonly=treatgroup==2
label var infoonly "Information only"
gen peeronly=treatgroup==3
label var peeronly "Peer ratings"
gen proneg=treatgroup==4
label var proneg "Negative Comments"
gen proall=treatgroup==5
label var proall "All Comments"

**** Generate State indicator and outcomes 
gen lagos=stat==1
label var lagos "Located in Lagos"

gen fu_contactHR=cond(fu_F10==1,1,0) if fu_F10~=.
label var fu_contactHR "Contacted an HR firm"
gen fu_contactAM=cond(fu_G15==1,1,0) if fu_G15~=.
label var fu_contactAM "Contacted an AM firm"

gen fu_usedHR=1 if fu_F4==1
replace fu_usedHR=0 if fu_usedHR==. 
label var fu_usedHR "Used an HR firm"
gen fu_usedAM=1 if fu_G4==1|fu_G10==1
replace fu_usedAM=0 if fu_usedAM==. 
label var fu_usedAM "Used an AM firm"
gen fu_usedany=fu_usedHR
replace fu_usedany=1 if fu_usedAM==1
label var fu_usedany "Used any type of provider"



eststo clear
local i=1 
foreach var in contactHR contactAM usedHR usedAM usedany {
    reg fu_`var' infotreatment lagos, r
	eststo Table10a_`i'
	reg fu_`var' infoonly peeronly proneg proall lagos, r
	test infoonly==peeronly==proneg==proall==0
	estadd scalar pval=r(p)
	sum fu_`var' if infotreatment==0 
	estadd scalar mean=r(mean)
	eststo Table10b_`i'
local i=`i'+1
}

#delimit ;
esttab Table10a_*   using "$tables/Table10.csv", replace depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons lagos)
	title("Table 10: Impacts of Information on Business Service Provider Usage") addnotes("""") 
	posthead("Panel A: Pooled Information Treatment");
#delimit cr
#delimit ;
esttab Table10b_*   using "$tables/Table10.csv", append depvar legend label nonumbers
	b(%9.3f) se star(* 0.10 ** 0.05 *** 0.01) nogaps drop(_cons lagos)
	stats(N mean pval, fmt(%9.0g %9.2f %9.3f) labels("Sample Size" "Control Mean" "P-value: test all jointly zero")) 
	addnotes("""") 
	posthead("Panel B: By Type of Information Treatment");
#delimit cr


