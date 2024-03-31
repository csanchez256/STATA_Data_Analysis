/*
============================
Author: Christopher Sanchez
Feb, 2024
============================
*/



/*
==============
CMPS 2020 data
==============
*/


clear all
set more off


cd "C:\Users\css7c\OneDrive\Desktop\Grand Challenges-Call for Abstract\Merged"
use "CMPS 2020 contextual full adult sample weighted STATA.dta", clear

/*
=======
Information taken from the survey instrument
=======
*/

tab Q1r11 //Combating climate change and pollution
tab Q96r7 
tab Q98r5 
tab Q99r7 //Addressing climate change regardless of your own participation in such....
tab Q131r8 //congress should support a bold national climate policy
tab Q308r5 
tab Q504r3 //In the past year, which of the following has caused you....????
tab Q793r5


keep county_name county_fips R_st_fips R_st_name date race MedianHHInc Q1r11 Q99r7 Q131r8

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
=======================
Drought Monitoring data
=======================
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

/*
"label list" allows you to check the value labels assigned to the variables. The variable
'race' is stored as a numeric type "double" in the dataset.
*/

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
asdoc mlogit Q131r8 DroughtLevel MedianHHInc race_black race_white race_latino /// 
race_aapi, baseoutcome(1)
outreg2 using myreg.doc, replace



/*
=========
RESULTS:

-------------------------------------------------------------------------------------------
                   Q131r8 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
--------------------------+----------------------------------------------------------------
Strongly_support          |  (base outcome)
--------------------------+----------------------------------------------------------------
Somewhat_support          |
             DroughtLevel |  -.0031286   .0036169    -0.86   0.387    -.0102176    .0039604
              MedianHHInc |   3.88e-06   3.65e-06     1.06   0.288    -3.28e-06     .000011
               race_black |   .1262774   .3602414     0.35   0.726    -.5797828    .8323376
               race_white |   .3529701   .3029593     1.17   0.244    -.2408191    .9467593
              race_latino |  -.0700564   .2982773    -0.23   0.814    -.6546691    .5145563
                race_aapi |          0  (omitted)
                    _cons |   -.581573    .399039    -1.46   0.145    -1.363675    .2005292
--------------------------+----------------------------------------------------------------
Neither_support_or_oppose |
             DroughtLevel |   .0020606   .0041157     0.50   0.617    -.0060061    .0101273
              MedianHHInc |  -4.94e-06   4.43e-06    -1.12   0.265    -.0000136    3.74e-06
               race_black |  -.2870281   .4166942    -0.69   0.491    -1.103734    .5296774
               race_white |   .1129297   .3368181     0.34   0.737    -.5472216    .7730811
              race_latino |  -.2999203   .3307855    -0.91   0.365     -.948248    .3484073
                race_aapi |          0  (omitted)
                    _cons |  -.4049424   .4562011    -0.89   0.375     -1.29908    .4891954
--------------------------+----------------------------------------------------------------
Somewhat_oppose           |
             DroughtLevel |  -.0056695   .0066313    -0.85   0.393    -.0186666    .0073275
              MedianHHInc |   6.58e-06   6.56e-06     1.00   0.316    -6.28e-06    .0000194
               race_black |   .2089322   .9019988     0.23   0.817    -1.558953    1.976817
               race_white |   1.458601   .6234606     2.34   0.019     .2366406    2.680561
              race_latino |   1.044044   .6309769     1.65   0.098    -.1926476    2.280736
                race_aapi |          0  (omitted)
                    _cons |  -3.020275   .8205175    -3.68   0.000     -4.62846    -1.41209
--------------------------+----------------------------------------------------------------
Strongly_oppose           |
             DroughtLevel |   .0017777   .0050843     0.35   0.727    -.0081873    .0117427
              MedianHHInc |   4.68e-06   5.13e-06     0.91   0.362    -5.39e-06    .0000147
               race_black |  -1.819695   1.062988    -1.71   0.087    -3.903113    .2637234
               race_white |   .9682952   .3923325     2.47   0.014     .1993377    1.737253
              race_latino |  -.0618432   .4355442    -0.14   0.887    -.9154941    .7918076
                race_aapi |          0  (omitted)
                    _cons |  -1.976286   .5841844    -3.38   0.001    -3.121266   -.8313053
-------------------------------------------------------------------------------------------

*/
