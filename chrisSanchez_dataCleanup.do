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

/*
=======
Information taken from the survey instrument
=======
*/



clear all
set more off


cd "C:\Users\css7c\OneDrive\Desktop\Grand Challenges-Call for Abstract\Merged"
use "CMPS 2020 contextual full adult sample weighted STATA.dta", clear

tab Q1r11 //Combating climate change and pollution
tab Q96r7 
tab Q98r5 
tab Q99r7 //Addressing climate change regardless of your own participation in such....
tab Q131r8 //congress should support a bold national climate policy
tab Q308r5 
tab Q504r3 //In the past year, which of the following has caused you....????
tab Q793r5


keep county_name county_fips R_st_fips R_st_name date race MedianHHInc Q1r11 Q99r7 Q131r8
//keep if county_name == "Douglas County" & R_st_name == "Wisconsin"

label variable MedianHHInc "Median household income"

drop if R_st_fips == .
drop if missing(county_fips)
  
// R_st_fips is non-numerical so I cast it as a string
gen temp = string(R_st_fips) + county_fips

// Now I re-cast it as a numerical value
gen FIPS = real(temp)


drop R_st_fips county_fips temp
drop if missing(county_name)
drop if FIPS == .
drop if race == .
drop if Q131r8 == .

duplicates report FIPS

save "CMPS_2020_clean.dta", replace

/*
=======
Drought Monitoring data
=======
*/


use "droughtMonitoring.dta", clear
rename D3 DroughtLevel
rename ValidStart SurveyDate
label variable DroughtLevel "Percent of extreme drought level"
label variable SurveyDate "Date CMPS survey was conducted" 

keep FIPS County State DroughtLevel SurveyDate
keep if DroughtLevel != 0
keep if month(SurveyDate) == 11 & day(SurveyDate) == 3 //11/3/2020 was general election day

duplicates report FIPS

save "droughtMonitoring_clean.dta", replace
duplicates report FIPS


//keep if County == "Douglas County" //& State == "WI"

/*
//Keep all observations that have maximum value of a variable in each group
bysort FIPS: egen maxDrought = max(D3)
keep if D3 == maxDrought
*/



/*
=======
Merge the data
=======
*/

//rename county_name County
//keep MedianHHInc GINI County R_zip Total_Pop R_st_name US_Dist_State race
//use "droughtMonitoring.dta", clear



//Merge the two cleaned datasets
clear all
use "CMPS_2020_clean.dta", clear
merge m:1 FIPS using "droughtMonitoring_clean.dta"
drop _merge
save "CMPS_Drought_Master.dta", replace

use "CMPS_Drought_Master.dta", clear
drop if DroughtLevel == .



