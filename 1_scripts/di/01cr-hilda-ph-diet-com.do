/*==============================================================================
File name:    	01cr-hilda-07ph-diet-com.do
Task:         	Extracts diet and parenthood variables from HILDA
Project:      	Parenthood and diet
Author(s):		Munschek & Linden
Last update:  	2026-01-14
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Extract and combine diet info from annual person data 
#2 Merge measure from HILDA-CNEF for comparison
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes:

In HILDA, the diet item is consistent in wave 2007, 2009, 2013, 2017
------------------------------------------------------------------------------*/

version 16.1  						// Stata version control
capture log close					// Closes log files
scalar starttime = c(current_time)	// Tracks running time

/*------------------------------------------------------------------------------
#1 Extract diet info from corresponding person data (and gap data)
------------------------------------------------------------------------------*/

set maxvar 32767
use "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_g190c.dta", clear  // load first wave data
gen year=2007
rename (gffveg gfffrt gffvegs gfffrts) (ffveg fffrt ffvegs fffrts)

local y = 2008
foreach w in h {
	append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	keep xwaveid year ffveg fffrt ffvegs fffrts
	local y = `y' + 1
}

local y = 2009
foreach w in i {
	append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	replace ffveg=`w'ffveg if year==`y'
	replace fffrt= `w'fffrt if year==`y'
	replace ffvegs= `w'ffvegs if year==`y'
	replace fffrts= `w'fffrts if year==`y'
	
	keep xwaveid year ffveg fffrt ffvegs fffrts
	
	local y = `y' + 2
}

local y = 2010
foreach w in j k l {
	append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	keep xwaveid year ffveg fffrt ffvegs fffrts
	local y = `y' + 1
}

local y = 2013
foreach w in m q {
append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	replace ffveg=`w'ffveg if year==`y'
	replace fffrt=`w'fffrt if year==`y'
	replace ffvegs= `w'ffvegs if year==`y'
	replace fffrts= `w'fffrts if year==`y'
	keep xwaveid year ffveg fffrt ffvegs fffrts
	local y = `y' + 4
}

local y = 2014
foreach w in n o p {
	append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	keep xwaveid year ffveg fffrt ffvegs fffrts
	local y = `y' + 1
}

local y = 2018
foreach w in r s {
	append using "${rdta}/01_HILDA/STATA 190c (Combined)/Combined_`w'190c.dta"
	replace year= `y' if year==.
	keep xwaveid year ffveg fffrt ffvegs fffrts
	local y = `y' + 1
}

/*------------------------------------------------------------------------------
#2 Merge measure from HILDA-CNEF for comparison
------------------------------------------------------------------------------*/

sort xwaveid year

merge 1:1 xwaveid year using "${rdta}/01_HILDA/STATA 190c (Other)/CNEF_Long_s190c.dta" ///
        , keep (1 3) keepusing(zzd11107 zzh11103 zzh11104) nogen
		
		
rename (zzd11107 zzh11103 zzh11104) (hhkid hhmem0_1 hhmem2_4)

destring xwaveid , replace
recast float xwaveid
recast float year

* sort data
sort xwaveid year
order xwaveid year ffveg ffvegs fffrt fffrts

* inspect data
describe                        // show all variables contained in data
notes                           // show all notes contained in data
codebook, problems              // potential problems in dataset
duplicates report xwaveid year

*------------------------------------------------------------------------------*

label data "HILDA 190c, 2007, 2009, 2013, 2017, diet, parenthood"

datasignature set, reset

save "${pdta}/hilda$ps", replace

*==============================================================================*
