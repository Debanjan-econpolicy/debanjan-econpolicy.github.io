
*******************************************************************************
*****************************MAP: FIGURE 1 ************************************
*******************************************************************************
global shape "$data/raw/shapefiles"


**** MUNICIPALITY-LEVEL COORDINATES FOR LOCATION OF STATE'S CAPITALS
shp2dta using "$shape/BR_Municipios_2020.shp", database("$shape/brmap.dta") coordinates("$shape/brcoord.dta") /// 
gencentroids(cent)  genid(id) replace

use "$shape/brmap.dta", clear
rename CD_MUN cod
destring cod, replace

***Keeping only the capitals: indicator for unit that implemented the local smoking ban (state and/or capital)
keep if cod == 1200401 | cod == 2704302 | cod == 1600303 | cod == 1302603 | cod == 2927408 ///
| cod == 2304400 | cod == 3205309 | cod == 5208707 | cod == 2111300 | ///
cod == 5103403 | cod == 5002704 | cod == 3106200 | cod == 1501402 | cod == 2507507 | ///
cod == 4106902 | cod == 2611606 | cod == 2211001 | cod == 3304557 | cod == 2408102 | ///
cod == 4314902 | cod == 1100205 | cod == 4205407 | cod == 3550308 | cod == 2800308 | ///
 cod == 1721000 | cod == 1400100

gen label = NM_MUN +"/"+ SIGLA_UF
rename SIGLA_UF uf

gen state = 0
replace state = 1 if uf == "RO" | uf == "SP" | uf == "RR" | uf == "RJ" | uf == "MT" 
replace state = 2 if uf == "PB" | uf == "PR" | uf == "AM" | uf == "GO"
replace state = 3 if uf == "PA" | uf == "SE" | uf == "BA" | uf == "AC" | uf == "MS" | uf == "PI"

replace x_cent = -40.4 if uf == "ES"

label define unity 0 "None" 1 "State" 2 "State & Capital" 3 "Capital" 
label values state unity
save "$shape/capitals.dta", replace
erase "$shape/brmap.dta"
erase "$shape/brcoord.dta"


**** STATE-LEVEL MAP
shp2dta using "$shape/BR_UF_2021.shp", database("$shape/brmap.dta") coordinates("$shape/brcoord.dta") genid(id) replace

use "$shape/brmap.dta", clear
rename CD_UF uf
destring uf, replace

** Year of treatment
gen year = .
replace year = 2008 if uf == 11 
replace year = 2009 if uf == 35 | uf == 14 | uf == 25 | uf == 33 | uf == 41 | uf == 13 | uf == 15 | uf == 28 | uf == 29 | uf == 52 
replace year = 2010 if uf == 12 | uf == 50 | uf == 22
replace year = 2011 if uf == 51

label define yearof 2008 "2008" 2009 "2009"  2010 "2010"  2011 "2011"  
label values year yearof

** Level of enforcement
gen enforcement = .
replace enforcement = 0 if uf == 11
replace enforcement = 1 if uf == 13 | uf == 12 | uf == 14 | uf == 15|  uf == 24 | uf == 28 | uf == 25
replace enforcement = 2 if uf == 35 | uf == 41 | uf == 33 | uf == 50 | uf == 51 | uf == 52 | uf == 22 | uf == 29

gen group = 0
replace group = 1 if (year == 2009 | (year == 2010 & uf != 22)) & enforcement == 1
replace group = 2 if (year == 2009 | (year == 2010 & uf != 22)) & enforcement == 2
replace group = 3 if uf == 22 |  uf == 51 
replace group = 4 if  uf == 11
label define cohort 0 "No Smoking Bans" 1 "2009 Weakly Enforced" 2 "2009 Highly Enforced" 3 "Late Treated (2010/2011)" 4 "Dropped"
label values group cohort 


graph set window fontface "Arial"
spmap group using "$shape/brcoord.dta", id(id) fcolor(white eltblue green sand gs14) ocolor(navy ..) osize(vthin ..) /// 
 legstyle(2)  legtitle(" ") legend(size(small) ) clmethod(unique) ///
point(data("$shape/capitals.dta") xcoord(x_cent) ycoord(y_cent) size(medsmall small small small) by(state) ///
shape(X smsquare smcircle triangle)  legenda(on) legtitle("Unit of implementation")) 
graph export "$results/fig1_map.png", replace 

erase "$shape/capitals.dta"
erase "$shape/brmap.dta"
erase "$shape/brcoord.dta"

clear all