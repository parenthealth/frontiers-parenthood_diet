/*==============================================================================
File:         	02cr-cpf-bhps.do
Task:         	Creates bhps extract to integrate in CPF file
Project:      	Parenthood & health behaviour
Author(s):		Munschek & Linden
Last update:  	2026-01-20
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Info on how to get the data
#2 Append individual wave data
#3 Append household wave data
#4 Merge individual and household data
#5 Generate vars and labels
#6 Clean up
#7 Inspect data
#8 Label and save
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes:


 
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
#1 Info on how to get and install the data (TO-DO):

	a) Download UKDA-6614-stata zipped files from:

	https://www.understandingsociety.ac.uk/

	b) Place folder UKDA-6614-stata in 06_UKHLS\Data

------------------------------------------------------------------------------*/

version 16.1                            // Stata version control
capture log close                       // Closes log files
scalar starttime = c(current_time)      // Tracks running time

/*------------------------------------------------------------------------------
#2 Append individual wave data
------------------------------------------------------------------------------*/

* define globals

global uk_n= ${ukhls_w}+18 										// number of all waves including BHPS
global BHPSwaves "a b c d e f g h i j k l m n o p q r"
global UKHLSwaves_bh = substr(c(alpha), 1, ($ukhls_w *2) )

* rename

	* BHPS

	foreach w of global BHPSwaves {
		local waveno=strpos("abcdefghijklmnopqrstuvwxyz","`w'")
		use "$ukhls_in\bhps_w`waveno'\b`w'_indresp", clear
			rename b`w'_* *
			gen wave=`waveno'
			gen uk_ver = "bhps"
			sort pidp
			order pidp wave, first
		save "${ukhls_out_work}\tmp_b`waveno'_indresp", replace
	}
	
	* UKHLS
	
	foreach w of global UKHLSwaves_bh {
		local waveno=strpos("abcdefghijklmnopqrstuvwxyz","`w'")
		use  "$ukhls_in/ukhls_w`waveno'/`w'_indresp", clear
			rename `w'_* *
			gen wave=`waveno'+18								// generate a variable which records the wave number + 18 
			gen uk_ver = "ukhls"
			local x=`waveno'+18
			sort pidp
			order pidp wave, first
		save "${ukhls_out_work}\tmp_`x'_indresp", replace
}

* append

	* BHPS

	use "${ukhls_out_work}\tmp_b1_indresp", clear
	foreach w of numlist 2/18 {
		display "Appending wave: "`w'
			qui append using "${ukhls_out_work}\tmp_b`w'_indresp"
		display "After append of wave `w' - Vars:" c(k) " N: " _N
		display ""
		}
		
	sort pidp wave
	save "${ukhls_out}\uk_01_bhps.dta", replace

	* UKHLS
	
	local last = ${uk_n}
	foreach w of numlist 19/`last' {
			display "Appending wave: "`w'
				qui append using "${ukhls_out_work}\tmp_`w'_indresp"
			display "After append of wave `w' - Vars:" c(k) " N: " _N
			display ""
	}
	
	sort pidp wave
	rename pid pid_bhps
	rename pidp pid
	save "${ukhls_out}\bhps_hls_ind.dta", replace

* delete temp files
 
foreach w of numlist 1/18 {
	erase "${ukhls_out_work}\tmp_b`w'_indresp.dta"
}
local last = ${uk_n}
foreach w of numlist 19/`last'  {
	erase "${ukhls_out_work}\tmp_`w'_indresp.dta"
}

/*------------------------------------------------------------------------------
#3 Append household wave data
------------------------------------------------------------------------------*/

* rename

	* BHPS

	foreach w of global BHPSwaves {
		local waveno=strpos("abcdefghijklmnopqrstuvwxyz","`w'")
		use "$ukhls_in/bhps_w`waveno'/b`w'_hhresp", clear  
			rename b`w'_* *
			gen wave=`waveno'
			gen uk_ver = "bhps"
			sort hidp
			order hidp wave, first
		save "${ukhls_out_work}\tmp_b`waveno'_hhresp", replace
	}

	* UKHLS

	foreach w of global UKHLSwaves_bh {
		local waveno=strpos("abcdefghijklmnopqrstuvwxyz","`w'")
		use  "$ukhls_in/ukhls_w`waveno'/`w'_hhresp", clear
			rename `w'_* *
			// generate a variable which records the wave number + 18 
			gen wave=`waveno'+18
			gen uk_ver = "ukhls"
			local x=`waveno'+18
			sort hidp
			order hidp wave, first
		save "${ukhls_out_work}\tmp_`x'_hhresp", replace
	}

* append

	* BHPS

	use "${ukhls_out_work}\tmp_b1_hhresp", clear
	foreach w of numlist 2/18 {
			display "Appending wave: "`w'
				qui append using "${ukhls_out_work}\tmp_b`w'_hhresp"
			display "After appned of wave `w' - Vars:" c(k) " N: " _N
			display ""
	}
		
	sort hidp wave
	save "${ukhls_out}\bhps_hh.dta", replace

	* UKHLS
	
	local last = ${uk_n}
	foreach w of numlist 19/`last' {
			display "Appending wave: "`w'
				qui append using "${ukhls_out_work}\tmp_`w'_hhresp"
			display "After appned of wave `w' - Vars:" c(k) " N: " _N
			display ""
	}

	sort hidp wave
	save "${ukhls_out}\bhps_hls_hh.dta", replace

* delete temp files
 
// erase each temporary file using loops

foreach w of numlist 1/18 {
	erase "${ukhls_out_work}\tmp_b`w'_hhresp.dta"
}

local last = ${uk_n}
foreach w of numlist 19/`last'  {
	erase "${ukhls_out_work}\tmp_`w'_hhresp.dta"
}

/*------------------------------------------------------------------------------
#4 Merge individual and household data
------------------------------------------------------------------------------*/

use "${ukhls_out}\bhps_hls_ind.dta", clear

	rename hhsize hhsize_1_18
	merge m:1 hidp wave using "${ukhls_out}\bhps_hls_hh.dta" , ///
			keep(1 3) nogen ///
			keepusing(nkids015 hhsize nkids_dv nch02_dv nch34_dv nch511_dv nch1215_dv nkids_dv)
			
* reduce dataset size

keep   ///
	istrtdaty intdaty_dv wave istrtdatm intdatm_dv country ivfio pid memorig ///
	sampst age_dv birthy doby_dv ///
	sex hgsex isced qfhigh_dv qfhighoth mlstat marstat marstat_dv mlstat_bh ///
	spinhh livesp livewith lprnt ladopt ///
	mastat nch02_dv nch34_dv nch511_dv nch1215_dv nkids_dv nnatch hhsize lnprnt ch1by4 nkids_dv

/*------------------------------------------------------------------------------
#5 Generate vars and labels
------------------------------------------------------------------------------*/

* define common label

lab def yesno 0 "[0] No" 1 "[1] Yes" ///
        -1 "-1 MV general" -2 "-2 Item non-response" ///
        -3 "-3 Does not apply" -8 "-8 Question not asked in survey", replace

*-----------*
* Technical *
*-----------*

* personal identification number (pid)

* interview year

clonevar intyear=istrtdaty  
replace intyear=intdaty_dv if intdaty_dv>0 & intdaty_dv<.  
replace intyear=1991 if intyear==. & wave==1
	lab var intyear "Interview year"
	
* interview month	

clonevar intmonth=istrtdatm	
replace intmonth=intdatm_dv if intdatm_dv>0 & intdatm_dv<.  
recode intmonth (-9=-1)
	lab var intmonth "Interview month"

* country identifier

rename country country_resid
	gen country=6
	lab var country "Country"
	
* year identifier

bysort wave: egen wavey=min(intyear)
	lab var wavey "Year identifier"
	
* wave identifier

	lab var wave "Wave identifier"

* respondent status

recode ivfio (1=1) (2 3=2), gen(respstat)
	lab def respstat 	1 "Interviewed" 					///
						2 "Not interviewed (has values)" 	///
						3 "Not interviewed (no values)"
	lab val respstat respstat
	lab var respstat "Respondent status"
	
* 1st appearance in dataset	
	
bysort pid: egen wave1st = min(cond(ivfio == 1, wave, .))
	label var wave1st "1st appearence in dataset"
	
* sample identifier

clonevar sampid_ukhls1 = memorig
clonevar sampid_ukhls2 = sampst
	lab var sampid_ukhls1  "Sample identifier: UKHLS - origin"
	lab var sampid_ukhls2  "Sample identifier: UKHLS - status"

* sort	
	
sort pid wave	
	
*----------------------------------------*
* Sociodemographics & Family composition *
*----------------------------------------*

* age

capture gen age=age_dv
replace age=age_dv 
replace age=-1 if age_dv==-9
	lab var age "Age" 

* birth year

recode birthy (-9/-1=-1), gen(yborn)
replace yborn=doby_dv if (birthy==. | birthy<0) & doby_dv!=.
	lab var yborn "Birth year"
	
	* Fill yborn if missing	(cross-filling)
	
		replace yborn=intyear-age if (yborn<0|yborn==.) & age>0 & age<.
		
	* Correct yborn if not consistent values of yborn across weaves
	
		bysort pid: egen temp_min=min(yborn)
		bysort pid: egen temp_max=max(yborn)
		gen temp_check=temp_max-temp_min if temp_max>0 & temp_max<. & temp_min>0 & temp_min<.
			replace temp_check=999 if temp_min==-1 & temp_max>0 
		bysort pid: egen temp_yborn=mode(yborn) if temp_check>0 & temp_check<., maxmode
		bysort pid: egen temp_yborn_max=max(yborn) if temp_check>0 & temp_check<. 
			replace temp_yborn=temp_yborn_max if temp_yborn==-1 & temp_yborn_max>0 & temp_yborn_max<.	
			replace yborn=temp_yborn if temp_yborn<. & temp_yborn>0
		
		* Correct age based on corrected yborn
		
		replace age=intyear-yborn  if temp_yborn>0 & temp_yborn<.
		
		* Fill age based on yborn if missing
		
		replace age=intyear-yborn  if yborn>0 & yborn<. & (age<0 | age==.)	
		
		* Correct age if values inconsistent with yborn (only if difference more than +/-1)
		
		gen temp_age_yborn=intyear-yborn if yborn>1000 & yborn<. 
		gen temp_age_err=age-temp_age_yborn if temp_age_yborn>0 & temp_age_yborn<120 & age>0 & age<120
			replace age=temp_age_yborn if (temp_age_err>1 | temp_age_err<-1) & temp_age_err!=.

		drop temp*		
		
* gender

recode sex (-9/-1=-1) (1=0) (2=1), gen(female)
	replace female=0 if sex<0 & hgsex==1
	replace female=1 if sex<0 & hgsex==2

	* correct for inconsistent entrys
	
	bys pid: egen temp=sd(female) if pid>=0 & pid<. // searching gender within-changes
	bys pid: egen temp2=mode(female) if temp>0 & temp<., missing maxmode // take within-mode
	replace female=temp2 if temp2==0 | temp2==1	// correct 
		drop temp*
		
	lab def female 0 "Male" 1 "Female" 
	lab val female female 
	lab var female "Gender" 

* education

	* education (3 levels)
	
	recode isced (1 2 =1) (3 4=2) (5/7=3) (0 -7=-1) , gen(edu3a) // for waves 1-18
	recode qfhigh_dv (14 15 96=1) (7/13 16=2) (1/6=3) (-9=-1) (-8=-3), gen(edu3b) // for waves 19+ 
	recode qfhighoth (10 96=1) (5/9=2) (1/4=3), gen(edu3c) // special sample w 24, 27

	gen edu3=edu3a
		replace edu3=edu3b if wave>=19
		replace edu3=edu3c if  (edu3<0 | edu3==.) & edu3c>0 & edu3c<.

		drop edu3a edu3b edu3c

		lab def edu3  1 "[0-2] Low" 2 "[3-4] Medium" 3 "[5-8] High" // 2 incl Vocational
		lab val edu3 edu3
		lab var edu3 "Education: 3 levels"

	* education (4 levels)
	
	recode isced (1=1) (2=2) (3 4=3) (5/7=4)  (0 -7=-1), gen(edu4a) // for waves 1-18
	recode qfhigh_dv (15 96=1) (14=2) (7/13 16=3) (1/6=4) (-9=-1) (-8=-3), gen(edu4b) // for waves 19+ 
	recode qfhighoth (10 96=1)   (5/9=3) (1/4=4), gen(edu4c) // special sample w 24, 27

	gen edu4=edu4a
	replace edu4=edu4b if wave>=19
	replace edu4=edu4c if  (edu4<0 | edu4==.) & edu4c>0 & edu4c<.

		drop edu4a edu4b edu4c

		lab def edu4  1 "[0-1] Primary" 2 "[2] Secondary lower" ///
					  3 "[3-4] Secondary upper" 4 "[5-8] Tertiary" 
		lab val edu4 edu4
		lab var edu4 "Education: 4 levels"
	
	* education (5 levels)
	
	recode isced (1=1) (2=2) (3 4=3) (5 6=4) (7=5) (0 -7=-1), gen(edu5a) // for waves 1-18
	recode qfhigh_dv (15 96=1) (14=2) (7/13 16=3) (4/6=4) (1 2=5) (-9=-1) (-8=-3), gen(edu5b) // for waves 19+ 
	recode qfhighoth (10 96=1)   (5/9=3) (3 4=4) (1 2=5), gen(edu5c) // special sample w 24, 27

	gen edu5=edu5a
	replace edu5=edu5b if wave>=19
	replace edu5=edu5c if  (edu5<0 | edu5==.) & edu5c>0 & edu5c<.

		drop edu5a edu5b edu5c
		
		lab def edu5  1 "[0-1] Primary" 2 "[2] Secondary lower" ///
					  3 "[3-4] Secondary upper" ///
					  4 "[5-6] Tertiary lower(bachelore)"  ///
					  5 "[7-8] Tertiary upper (master/doctoral)"
					  
		lab val edu5 edu5
		lab var edu5 "Education: 5 levels"

	* Fill MV if info avaliable in previous waves (if age>30)

	sort pid wave
	foreach n in 3 4 5 {
		gen temp_edu`n'=edu`n'
		gen temp1=1 if edu`n'==-3
		by pid: egen temp2=min(temp1)
				// 	bro pid wave age edu3 qfhigh_dv   if temp2==1
		bysort pid (wave): replace  temp_edu`n'=temp_edu`n'[_n-1] if temp_edu`n'==-3 /// fill only when -3 
						& temp_edu`n'[_n-1]>0 & temp_edu`n'[_n-1]<. 				/// if has values
						& age>30 & age[_n-1]>=30				// only for individuals who have most likely finished education  		
		gen imp_edu`n'=1 if temp_edu`n'!=edu`n'
		by pid: egen temp4=max(imp_edu`n')
		// bro pid wave age qfhigh_dv edu3 temp_ed1 temp3 temp4 if temp4==1
		replace edu`n'=temp_edu`n' if temp_edu`n'!=edu`n' & temp_edu`n'>0
		lab var imp_edu`n' "Edu imputed based on previous waves"
		drop temp*
	}
	drop imp_edu4 imp_edu5
	rename imp_edu3 imp_edu
		
* formal marital status
	
recode mlstat 	(1=2)(2 3=1)(4 8=5)(6 9=3)(5 7=4) ///
				(-8=-3) (-9 -2 -1 -7=-1), gen(mlstat5)

	* Fill MV using other vars
	recode marstat  (1=2) (2 3=1) (4 7=5)(5 8=4)(6 9=3) (-8=-3)(-9 -2 -1 -7=-1), gen(mlstat_a)
	recode marstat_dv (1=1) (2=2) (6=2)(3=3)(4=4)(5=5) (0=-3)(-9=-1), gen(mlstat_a2)
		replace mlstat_a=mlstat_a2 if mlstat_a<0
		replace mlstat_a=mlstat_a2 if mlstat_a==2 & mlstat_a2==1
		replace mlstat_a=mlstat_a2 if mlstat_a==5 & mlstat_a2==1
		replace mlstat_a=mlstat_a2 if mlstat_a==4 & mlstat_a2==1
		replace mlstat_a=mlstat_a2 if mlstat_a==3 & mlstat_a2==1
	
	recode mlstat_bh (1=1)(2=5)(3=4) (4=3)(5=2) (-8=-3)(-9 -2 -1 6 7=-1), gen(mlstat_b)
	recode mastat (1=1) (2=2) (6=2)(3=3)(4=4)(5=5) (0=-3)(-9 -2 -1 7/10=-1), gen(mlstat_b2)
		replace mlstat_b=mlstat_b2 if mlstat_b<0
		replace mlstat_b=mlstat_b2 if mlstat_b==2 & (mlstat_b2==1|(mlstat_b2>3 & mlstat_b2<.))

	gen mlstat_fill=mlstat_b
	replace mlstat_fill=mlstat_a if wave>=19
	replace mlstat5=mlstat_fill if (mlstat5<=0|mlstat5==.) & (mlstat_fill>0 & mlstat_fill<.)
		drop mlstat_a mlstat_a2 mlstat_b mlstat_b2 mlstat_fill
	
	* correct MV
	
	lab var mlstat5 "Formal marital status [5]"
	lab def mlstat5				///
	1	"Married/registered"	///
	2	"Never married" 		///
	3	"Widowed" 				///
	4	"Divorced" 				///
	5	"Separated" 			///
	-1 "-1 MV general" -2 "-2 Item non-response" ///
	-3 "-3 Does not apply" -8 "-8 Question not asked in survey"
	lab val mlstat5 mlstat5

* primary martial status

recode marstat_dv (1 2=1)   (6=2) (3=3) (4=4) (5=5) (0=-3) (-9=-1), gen(marstat5a)
recode mastat (1 2=1)   (6=2) (3=3) (4=4) (5=5) (0=-3) (-9 -2 -1 7/10=-1), gen(marstat5b)
gen marstat5=marstat5b
replace marstat5=marstat5a if wave>=19
	drop marstat5a marstat5b
	
	* Replace MV with mlstat5 values
	
	replace marstat5=1 if marstat5<0 & mlstat5==1
	replace marstat5=2 if marstat5<0 & mlstat5==2
	replace marstat5=3 if marstat5<0 & mlstat5==3
	replace marstat5=4 if marstat5<0 & mlstat5==4
	replace marstat5=5 if marstat5<0 & mlstat5==5
	
	lab var marstat5 "Primary partnership status [5]"
	lab def marstat5				///
	1	"Married or Living with partner"	///
	2	"Single" 				///
	3	"Widowed" 				///
	4	"Divorced" 				///
	5	"Separated" 			///
	-1 "-1 MV general" -2 "-2 Item non-response" ///
	-3 "-3 Does not apply" -8 "-8 Question not asked in survey"
	lab val marstat5 marstat5

* children

	*supporting var based on age ranges 
	
	mvdecode nch02_dv nch34_dv nch511_dv nch1215_dv, mv(-9 =.a)
		egen kidsn_15 = rowtotal(nch02_dv nch34_dv nch511_dv nch1215_dv) 
	mvencode nch02_dv nch34_dv nch511_dv nch1215_dv, mv(.a=-9)
			
	recode nkids_dv (-9=-1), gen(kidsn_hh15)
	replace kidsn_hh15=kidsn_15 if (kidsn_hh15==.|kidsn_hh15<0) & kidsn_15<. & kidsn_15>=0
	
	recode nnatch (1/max=1), gen(kids_any)
	
	* correct with info on nr. of kids aged 0-2 in hh, being natural parent & adoptions
	
	replace kids_any=1 if nch02_dv==1 & nch02_dv[_n-1]==0
		replace kids_any=0 if nch02_dv==0
	replace kids_any=1 if lprnt==1	
	replace kids_any=1 if ladopt==1
 	
	* forward filling 1
	
	sort pid wave
	bysort pid (wave): replace  kids_any=1 if 				///
							(kids_any==. | kids_any<=0)	&	/// MV or 0
							kids_any[_n-1]==1   			//  has values 1
							
	* forward filling 0
	
	sort pid wave
	bysort pid (wave): replace  kids_any=0 if 				///
							(kids_any==. | kids_any<0)	&	/// MV
							kids_any[_n-1]==0   			//  has values	0						
							
	recode 	kids_any	(-7=-1)			
							 
	
	lab var kids_any  "Has children"
	lab val kids_any   yesno 
 	lab var kidsn_hh15   "Number of Children in HH<15" 
	 
* household size

clonevar nphh=hhsize
	lab var nphh "Number of People in HH"
	
/*------------------------------------------------------------------------------
#6 Clean up
------------------------------------------------------------------------------*/	

* keep

keep ///
	pid intyear intmonth wave wavey country wave1st respstat sampid_ukhls1 sampid_ukhls2 ivfio ///
	age female yborn edu3 edu4 edu5 marstat5 ///
	kids_any kidsn_hh15 nphh yborn nnatch nch02_dv lnprnt lprnt ch1by4 nkids_dv
	
* order

order ///
	pid intyear intmonth wave wavey country wave1st respstat sampid_ukhls1 sampid_ukhls2 ivfio ///
	age female yborn edu3 edu4 edu5 marstat5 ///
	kids_any kidsn_hh15 nphh yborn nnatch nch02_dv lnprnt lprnt ch1by4 nkids_dv

* sample selection

	* age
	
	keep if age>=18
	
	* MV in age and gender
	
	keep if female~=.
	keep if age~=.
	
/*------------------------------------------------------------------------------
#7 Inspect data
------------------------------------------------------------------------------*/				  

log using "${logs}/02ukhls_cpf_inspect$ps.log", replace

* sort data

sort pid wavey

* inspect data

describe                       	// show all variables contained in data
notes                          	// show all notes contained in data
codebook, problems             	// potential problems in dataset
duplicates report pid wavey		// report duplicates
inspect                        	// distributions, #obs , missings

capture log close
	
/*------------------------------------------------------------------------------
#6 Label & save
------------------------------------------------------------------------------*/

* label data
 
label data "CPF_UK, parenthood"
     datasignature set, reset
	 
* save

save "${ukhls_out}\ukhls$ps.dta" , replace
	erase "${ukhls_out}\bhps_hh.dta"
	erase "${ukhls_out}\bhps_hls_hh.dta"
	erase "${ukhls_out}\bhps_hls_ind.dta"

*==============================================================================*