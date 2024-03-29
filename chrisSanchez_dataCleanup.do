/*
====================
Author: Christopher Sanchez; Feb. 2024
====================
*/



/*
=======
CMPS 2020 data
=======
*/


clear all
set more off


cd "C:\Users\css7c\OneDrive\Desktop\Grand Challenges-Call for Abstract\Merged"
use "CMPS 2020 contextual full adult sample weighted STATA.dta", clear

keep county_name county_fips R_st_fips R_st_name
//keep if county_name == "Douglas County" & R_st_name == "Wisconsin"


  
// R_st_fips is non-numerical so I cast it as a string
gen temp = string(R_st_fips) + county_fips

// Now I re-cast it as a numerical value
gen FIPS = real(temp)


/*
=======
Drought Monitoring data
=======
*/


use "droughtMonitoring.dta", clear
keep FIPS County State 

//keep if County == "Douglas County" & State == "WI"



/*
=======
Merge the data
=======
*/

//rename county_name County
//keep MedianHHInc GINI County R_zip Total_Pop R_st_name US_Dist_State race
//use "droughtMonitoring.dta", clear


/*
save "CMPS_2020_clean.dta", replace
use "droughtMonitoring.dta", clear
keep County State None D0 D1 D2 D3 D4 ,
if County == "Los Angeles County"
save "droughtMonitoring_clean.dta", replace
*/


/*
=======
Information taken from the survey instrument
=======
*/


/*
tab Q1r11 //Combating climate change and pollution
tab Q96r7 
tab Q98r5 
tab Q99r7 //Addressing climate change regardless of your own participation in such....
tab Q131r8 //congress should support a bold national climate policy
tab Q308r5 
tab Q504r3 //In the past year, which of the following has caused you....????
tab Q793r5
*/


/*
duplicates report County
duplicates report R_zip

drop if Total_Pop == .

clear all
use "CMPS_2020_clean.dta", clear
merge m:1 County using "droughtMonitoring.dta"
drop merge
save "CMPS_Drought.dta", replace
*/




