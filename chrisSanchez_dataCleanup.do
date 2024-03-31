/*
============================
Author: Christopher Sanchez
Feb, 2024
============================
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



/*
=======
Merge the data
=======
*/


//Merge the two cleaned datasets
clear all
use "CMPS_2020_clean.dta", clear
merge m:1 FIPS using "droughtMonitoring_clean.dta"
drop _merge
save "CMPS_Drought_Master.dta", replace

use "CMPS_Drought_Master.dta", clear
drop if DroughtLevel == .
drop if race == .


/*
=======
Analysis
=======


. label list
Q1r11:
           0 NO TO: Combating climate change and pollution
           1 Combating climate change and pollution
Q99r7:
           1 Very effective
           2 Somewhat effective
           3 Neither effective nor ineffective
           4 Somewhat ineffective
           5 Very ineffective
Q131r8:
           1 Strongly support
           2 Somewhat support
           3 Neither support or oppose
           4 Somewhat oppose
           5 Strongly oppose
race:
           1 White
           2 Latino
           3 Black
           4 AAPI
           5 Am Ind
*/



tab race
label list


// Create dummy variables for Race

/*
gen race_black = (race=="Black")
gen race_white = (race=="White")
gen race_latino = (race=="Latino")
gen race_aapi = (race=="AAPI")
*/

/* 
This reads "each observation will have a value of 1 if the corresponding 
observation in the "race" variable is coded as 1, and 0 otherwise. 
*/
 
 gen race_white = (race==1)
gen race_latino = (race==2)
gen race_black = (race==3)
gen race_aapi = (race==4)
gen race_AmIndian = (race==5)

// Run multinomial logistic regression
mlogit Q131r8 DroughtLevel MedianHHInc race_black race_white race_latino /// 
race_aapi, baseoutcome(1)







