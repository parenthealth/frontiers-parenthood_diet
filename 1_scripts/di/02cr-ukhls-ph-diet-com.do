/*==============================================================================
File name:    	02cr-ukhls-07ph-diet-com.do
Task:         	Extracts diet variables from UKHLS
Project:      	Parenthood and diet
Author(s):		Munschek & Linden
Last update:  	2026-01-14                           
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Extracts diet info from UKHLS
#2 Combines this information in one data set
#3 Extract parenthood info from annual person data (and gap data)
#4 Merge diet and parenthood info together
------------------------------------------------------------------------------*/

version 16.1  						// Stata version control
capture log close					// Closes log files
scalar starttime = c(current_time)	// Tracks running time

/*------------------------------------------------------------------------------
#1 Extract diet info from corresponding person data (2011, 2014, 2016, 2018)
------------------------------------------------------------------------------*/



local year = 2011
local c = 2
foreach wave in b e {
    use "${rdta}\02_UKHLS\UKDA-6614-stata\stata\stata13_se\ukhls_w`c'/`wave'_indresp.dta", clear
	
	rename (`wave'_wkvege `wave'_wkfruit `wave'_fruvege) (wkvege wkfruit fruvege)
	
	
	gen syear = `year'
      keep pidp syear wkvege wkfruit fruvege
      save "${pdta}/ukhls-`year'diet$ps.dta", replace
      local year = `year'+3
      local c = `c' + 3 
}

local year = 2016
local c = 7
foreach wave in g i {
    use "${rdta}\02_UKHLS\UKDA-6614-stata\stata\stata13_se\ukhls_w`c'/`wave'_indresp.dta", clear
	
	rename (`wave'_fruitamt `wave'_vegeamt `wave'_wkvege `wave'_wkfruit) (fruitamt vegeamt wkvege wkfruit)
	
	gen syear = `year'
      keep pidp syear fruitamt vegeamt wkvege wkfruit
      save "${pdta}/ukhls-`year'diet$ps.dta", replace
	local year = `year'+2
	local c = `c' +2
}

/*------------------------------------------------------------------------------
#2 Combine in one data set (and delete auxiliary data)
------------------------------------------------------------------------------*/

use "${pdta}/ukhls-2011diet$ps.dta", clear
forval year=2014(2)2018{ 
	append using "${pdta}/ukhls-`year'diet$ps.dta"
}

* delete aux. data
forval year=2010/2018 {
	capture erase "${pdta}/ukhls-`year'diet$ps.dta"
}

save "${pdta}/ukhls-di-aux$ps.dta", replace

/*------------------------------------------------------------------------------
#3 Extract parenthood info from annual person data (and gap data)
------------------------------------------------------------------------------*/

* for childrens birth year (UKHLS: since 2011 annually)

local year = 2011
local c = 1
foreach wave in a b c d e f g h i j {
      use "${rdta}\02_UKHLS\UKDA-6614-stata\stata\stata13_se\ukhls_w`c'/`wave'_child.dta", clear
	  
	  rename (`wave'_birthy) (yrkid1_ukhls)
     
      gen syear = `year'
      keep pidp syear yrkid1_ukhls
      save "${pdta}/ukhls-`year'birthchild$ps.dta", replace
      local year = `year'+1
      local c = `c' + 1 
}

use "${pdta}/ukhls-2011birthchild$ps.dta", clear
	forval year=2011(1)2020 { 
		append using "${pdta}/ukhls-`year'birthchild$ps.dta"	
	}
	
* delete aux. data
forval year=2011/2020 {
	capture erase "${pdta}/ukhls-`year'birthchild$ps.dta"
}	

save "${pdta}/ukhls-birthchild$ps.dta", replace

order pidp syear yrkid1_ukhls
sort pidp syear

* clean and harmonize dataset

gen yrkid1 = yrkid1_ukhls

replace yrkid1 = yrkid1_ukhls if yrkid1 == .									// replace birth year missings with information from UKHLS
recode yrkid1 (-9/-1 = .)
drop yrkid1_ukhls

sort pidp syear yrkid1															// drop siblings information
bys pidp: gen idkids = _n if yrkid1 != .
drop if idkids != 1
drop idkids

save "${pdta}/ukhls-kids-aux$ps.dta", replace	
	erase "${pdta}/ukhls-birthchild$ps.dta"

/*------------------------------------------------------------------------------
#4 Merge diet and parenthood info together
------------------------------------------------------------------------------*/

use "${pdta}/ukhls-di-aux$ps.dta", clear
	sort pidp syear
	merge m:1 pidp using "${pdta}/ukhls-kids-aux$ps.dta", ///
		keep (1 3) nogen

* inspect data
describe                        // show all variables contained in data
notes                           // show all notes contained in data
codebook, problems              // potential problems in dataset
duplicates report pidp syear

*order
order pidp syear wkvege wkfruit yrkid1

*label vars
lab var syear "Year of survey"
lab var yrkid1 "Year of birth first kid"
*------------------------------------------------------------------------------*

label data "UKHLS, 2011, 2014, 2016, 2018, diet, parenthood"

datasignature set, reset

save "${pdta}/ukhls$ps", replace
	erase "${pdta}/ukhls-di-aux$ps.dta"
	erase "${pdta}/ukhls-kids-aux$ps.dta"

*==============================================================================*
