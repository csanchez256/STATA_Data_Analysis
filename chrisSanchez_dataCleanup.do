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
gen fips = real(temp)


drop R_st_fips county_fips temp
drop if missing(county_name)
drop if fips == .
drop if race == .
drop if Q131r8 == .

duplicates report fips

save "CMPS_2020_clean.dta", replace

/*
=======================
Drought Monitoring data
=======================
*/



clear all
import delimited "C:\Users\css7c\OneDrive\Desktop\Grand Challenges-Call for Abstract\dm_export_20161108_20201103.csv"

*This will provide the number of days of drought from Nov. 2016 - Nov. 2020
gen drought = 0
replace drought = 1 if D0 > 0 //Note: this includes all drought levels no matter the severity
collapse(sum) drought, by(fips)
save "November16_November20.dta", replace


*now you can merge


/*
=======
Merge the data
=======
*/


//Merge the two cleaned datasets
use "CMPS_2020_clean.dta", clear
merge m:1 fips using "November16_November20.dta"
drop _merge
save "CMPS_Drought_Master.dta", replace


use "CMPS_Drought_Master.dta", clear
drop if MedianHHInc == .
drop if drought == .

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


/* 
Create dummy variables for race
This reads "each observation will have a value of 1 if the corresponding 
observation in the "race" variable is coded as 1, and 0 otherwise. 
*/
 
gen race_white = (race==1)
gen race_latino = (race==2)
gen race_black = (race==3)
gen race_aapi = (race==4)
gen race_AmIndian = (race==5)


// Run multinomial logistic regression
asdoc mlogit Q131r8 drought MedianHHInc race_black race_white race_latino /// 
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
                  drought |   .0006455   .0008063     0.80   0.423    -.0009348    .0022258
              MedianHHInc |   3.93e-07   8.99e-07     0.44   0.662    -1.37e-06    2.16e-06
               race_black |  -.0936459   .0935507    -1.00   0.317    -.2770019    .0897101
               race_white |   .1675677   .0990385     1.69   0.091    -.0265441    .3616795
              race_latino |  -.1238497   .0931869    -1.33   0.184    -.3064927    .0587932
                race_aapi |          0  (omitted)
                    _cons |  -.5696713   .1309597    -4.35   0.000    -.8263476   -.3129949
--------------------------+----------------------------------------------------------------
Neither_support_or_oppose |
                  drought |   .0002803   .0008574     0.33   0.744    -.0014003    .0019608
              MedianHHInc |  -2.21e-06   9.99e-07    -2.21   0.027    -4.16e-06   -2.48e-07
               race_black |  -.2945077   .1037407    -2.84   0.005    -.4978357   -.0911798
               race_white |   .3858439   .1027952     3.75   0.000     .1843689    .5873188
              race_latino |  -.0409416   .0992039    -0.41   0.680    -.2353776    .1534944
                race_aapi |          0  (omitted)
                    _cons |   -.553075   .1404934    -3.94   0.000    -.8284371    -.277713
--------------------------+----------------------------------------------------------------
Somewhat_oppose           |
                  drought |    .003186    .001555     2.05   0.040     .0001383    .0062336
              MedianHHInc |  -4.35e-07   1.82e-06    -0.24   0.811    -4.00e-06    3.13e-06
               race_black |  -.1806024   .2100215    -0.86   0.390     -.592237    .2310322
               race_white |   .9776818   .1815512     5.39   0.000     .6218479    1.333516
              race_latino |   .0731724     .19532     0.37   0.708    -.3096478    .4559925
                race_aapi |          0  (omitted)
                    _cons |  -2.720646   .2688255   -10.12   0.000    -3.247535   -2.193758
--------------------------+----------------------------------------------------------------
Strongly_oppose           |
                  drought |   .0038968    .001197     3.26   0.001     .0015508    .0062429
              MedianHHInc |   1.07e-06   1.38e-06     0.77   0.439    -1.63e-06    3.76e-06
               race_black |  -.8113566   .2022994    -4.01   0.000    -1.207856    -.414857
               race_white |   1.480955   .1394511    10.62   0.000     1.207636    1.754274
              race_latino |   .2224431   .1539998     1.44   0.149     -.079391    .5242772
                race_aapi |          0  (omitted)
                    _cons |  -2.466162   .2109388   -11.69   0.000    -2.879594   -2.052729
-------------------------------------------------------------------------------------------


*/
