/*==============================================================================
File name:      03cr-andata-07ph-diet-com.do
Task:           Creates person-year data from Australia and UK with all information
Project:      	Parenthood and diet
Author(s):		Munschek & Linden
Last update:  	2026-01-14
Run time:		3 min.
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Loads basic time-constant person info from pfad.dta
#2 Merges country-specific diet measures
#3 Generates and recodes variables
	A: Harmonized diet measures, comparable over Australia and UK
	B: Parenthood indicators
	C: Harmonized covariates
#4 Defines sample for analysis
#5 Inspect data
#6 Label & Save
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes:

------------------------------------------------------------------------------*/

version 16.1  						// Stata version control
capture log close					// Closes log files
scalar starttime = c(current_time)	// Tracks running time

/*------------------------------------------------------------------------------
#1 Load basic harmonized person-year data
------------------------------------------------------------------------------*/

use "${wdir}\3_pdta\cpf\01cpf-out\CPF-di.dta", clear

	drop if (country==2) | (country==3) | (country==4) | (country==5)			// Drop all data except aud Australia and UK
	drop if (wavey < 2007 | wavey > 2017) & country == 1						// Drop all data prior 2007 and after 2017 (Australia)
	drop if (wavey < 2011 | wavey > 2018) & country == 6						// Drop all data prior 2011 and after 2018 (UK)
	clonevar year = wavey
	
/*------------------------------------------------------------------------------
#2 Merge country-specific diet and parenthood measures
------------------------------------------------------------------------------*/

*-------*
* HILDA *
*-------*

clonevar xwaveid = orgpid if country==1

sort xwaveid year
merge m:1 xwaveid year using "${pdta}\hilda$ps"  ///
    , keep (1 3) keepusing(ffveg fffrt hh* ffvegs fffrts) nogen
    
	for any ffveg fffrt ffvegs fffrts hh*: rename X X_au

*-------*	
* UKHLS *
*-------*

clonevar pidp = orgpid if country==6

rename year syear

sort pidp syear
merge m:1 pidp syear using "${pdta}\ukhls$ps"  ///
    , keep (1 3) keepusing(wkvege wkfruit fruvege fruitamt vegeamt yrkid1) nogen
    
for any wkvege wkfruit fruvege fruitamt vegeamt yrkid1: rename X X_uk

/*------------------------------------------------------------------------------
#3 Generate and recode variables
------------------------------------------------------------------------------*/

*------------------------------------------------------------------------------*
* Part A: Harmonized diet maesures, comparable over 2 countries
*------------------------------------------------------------------------------*

********************************************************************************
*generate container for dummies:
* 1. no daily fruit and/or vegetable cons. vs. daily fruit and/or vegetable cons.
* 2. no daily vegetable cons. vs. daily vegetable cons.
* 3. no daily fruit cons. vs. daily fruit cons.
********************************************************************************

* Fruit and/or vegetable

gen bi_dietvegfr=.
lab def bi_dietvegfr 0 "No daily fruit and vegetable" 1 "Daily fruit and/or vegetable"
lab val bi_dietvegfr bi_dietvegfr
lab var bi_dietvegfr "Daily vegetable and/or fruit consumption"

* Vegetable.

gen bi_veg=.
lab def bi_veg 0 "Not every day" 1 "Every day"
lab val bi_veg bi_veg
lab var bi_veg "Daily vegetable consumption"

* Fruit.

gen bi_fr=.
lab def bi_fr 0 "Not every day" 1 "Every day"
lab val bi_fr bi_fr
lab var bi_fr "Daily fruit consumption"

*-------*
* HILDA *
*-------*

* Variables for daily vegetable/fruit cons.
recode ffveg_au (-10 -4 -3 =.) (1/6 9 = 0 "Not daily") (7 = 1 "daily"), gen (bi_veg_au)
lab val bi_veg_au bi_veg
lab var bi_veg_au "Daily vegetable consumption (AU)"

recode fffrt_au (-10 -4 -3 =.) (1/6 9 = 0 "Not daily") (7 = 1 "daily"), gen (bi_fr_au)
lab val bi_fr_au bi_fr
lab var bi_fr_au "Daily fruit consumption (AU)"

for any bi_veg: replace X=X_au if country==1
for any bi_fr: replace X=X_au if country==1


* Variable for daily fruit and/or vegetable cons.

gen bi_dietvegfr_au = 1 if bi_veg_au == 1 | bi_fr_au == 1
replace bi_dietvegfr_au = 0 if bi_veg_au == 0 & bi_fr_au == 0
replace bi_dietvegfr_au = . if bi_veg_au == . | bi_fr_au == .
lab def bi_dietvegfr_au 0 "Not daily" 1 "Daily veg. and/or fr.", replace
lab val bi_dietvegfr_au bi_dietvegfr
lab var bi_dietvegfr_au "Daily vegetable and/or fruit consumption in Australia"

for any bi_dietvegfr: replace X=X_au if country==1

*-------*
* UKHLS *
*-------*

* Variables for daily vegetable cons. + daily fruit cons.
recode wkvege (-1 -2 -7 -9 = .) (1/3 = 0 "Not daily") (4 = 1 "daily"), gen (bi_veg_uk)
lab val bi_veg_uk bi_veg
lab var bi_veg_uk "Daily vegetable consumption (UK)"

recode wkfruit (-1 -2 -7 -9 = .) (1/3 = 0 "Not daily") (4 = 1 "daily"), gen (bi_fr_uk)
lab val bi_fr_uk bi_fr
lab var bi_fr_uk "Daily fruit consumption (UK)"

for any bi_veg: replace X=X_uk if country==6
for any bi_fr: replace X=X_uk if country==6

* Variable for daily fruit and/or vegetable cons.
gen bi_dietvegfr_uk = 1 if bi_veg_uk == 1 | bi_fr_uk == 1
replace bi_dietvegfr_uk = 0 if bi_veg_uk == 0 & bi_fr_uk == 0
replace bi_dietvegfr_uk = . if bi_veg_uk == . | bi_fr_uk == .
lab def bi_dietvegfr_uk 0 "Not daily" 1 "Daily veg. and/or fr.", replace
lab val bi_dietvegfr_uk bi2_dietvegfr_uk
lab var bi_dietvegfr_uk "Daily vegetable and/or fruit consumption in UK"

for any bi_dietvegfr: replace X=X_uk if country==6

*------------------------------------------------------------------------------*
* Part B: Parenthood variables
*------------------------------------------------------------------------------*

* year of first birth (UK)

gen yrkid1=ch1by4_uk if country==6

foreach v in hhmem0_1 hhkid {
    gen `v'=`v'_au if country==1
}

* change in child 0-1 years between wavey while # of all children was 0 in prev. wave

sort pid wavey

*UKHLS
gen chkid=1 if (pid == pid[_n-1] & country==6 & kids_any==1 & kids_any[_n-1]==0) & inrange(wavey, 2010, 2018)

*HILDA
replace chkid=1 if (pid == pid[_n-1] & country==1 & kids_any==1 & kids_any[_n-1]==0) & inrange(wavey, 2007, 2018)

	bysort country female: ta wavey chkid if female >=0

* year of first birth (all countries)

bysort pid: egen aux=min(syear) if chkid==1 & country!=2
bysort pid: egen aux2=max(aux) if country!=2
	replace yrkid1=aux2 if country!=2
	drop aux*
	lab var yrkid1 "Year of first birth (All countries)"
	
	bysort female: tab yrkid1 country if yrkid1==syear & syear>=1999

* age at first birth (all countries)

gen agekid1=yrkid1-yborn
	bysort country female: sum agekid1 if syear==yrkid1, det 
	lab var agekid1 "Age at first birth"

* time-sensitive parenthood variable - years before/after parenthood

gen parent_ba=syear-yrkid1 
	lab var parent_ba "Time before/after first birth"
		
bysort female: ta parent_ba country if yrkid1>1998

* time-varying parenthood indicator (0=no parent/1=parent from here on)

recode parent_ba -50/-1=0 0/120=1, gen(parent_t)
    
* time-constant parenthood indicator - ever parent (0=never/1=parenthood ever observed)

bysort pid: egen aux=max(hhkid)
	
*bysort pid: egen aux2=max(nchhh_uk) if country==6
bysort pid: egen aux2=max(kids_any) if country==6
	replace aux=aux2 if country==6

gen parent_ev=0 if aux==0 & country!=2
	replace parent_ev=1 if yrkid1<. & parent_ev==.
	lab var parent_ev "Time-constant parenthood indicator"
	
* labeling and missings	
	
replace parent_t=0 if parent_ev==0
	lab var parent_t "Time-varying parenthood indicator"

* adjust years before/after parenthood for nonparents

sum age
	disp round(`r(mean)')

sum age if parent_ba == 0 & female==1, det      // mean age at first pregnancy women
	replace parent_ba = age - round(`r(mean)') if parent_ev==0 & female==1	

sum age if parent_ba == 0 & female==0, det      // mean age at first pregnancy men
	replace parent_ba = age - round(`r(mean)') if parent_ev==0 & female==0

* categorial time-sensitive parenthood variable = dynamic treatment variable

recode parent_ba      ///
      (-100/-3 = 0 "BY-3a+")   ///
      (-2/-1   = 1 "BY-1/2a")   ///	  
      (0/1     = 2 "BY+1a")   ///	  
      (2/3     = 3 "BY+2/3a")   ///	 
      (4/5     = 4 "BY+4/5a")   ///	  
      (6/120   = 5 "BY+6a+")   ///	  	  		  
    , gen(parent_tvc)
replace parent_tvc=0 if parent_ev==0 
 
*------------------------------------------------------------------------------*
* Part C: Harmonized covariates
*------------------------------------------------------------------------------

*birth cohort(s)

recode yborn                    ///
      (1935/1944 = 1 "1935-1944") ///
      (1945/1954 = 2 "1945-1954") ///
      (1955/1964 = 3 "1955-1964") ///
      (1965/1974 = 4 "1965-1974") ///
      (1975/1984 = 5 "1975-1984") ///
      (1985/1997 = 6 "1985-1997") ///
	, gen(bcohort) 
recode bcohort -1 1882/2007 = .	
	lab var bcohort "Birth cohort"
    
recode yborn                   ///
      (1970/1979 = 2 "1970-1979") ///
      (1980/1991 = 3 "1980-1991") ///
	, gen(bcohort2) 
recode bcohort2 -1 1882/2007 = .
	lab var bcohort2 "Birth cohort (dichotomous)"

* year dummies

tab wavey, gen(year)

* sex

recode female -3/-1=.
	clonevar sex = female
	recode sex (0=1) (1=2)
		lab def sex 1 "Male" 2 "Female", replace
		lab val sex sex
		lab var sex "Sex"   
	  
* education

rename edu3 edu3_orig
	recode edu3_orig            ///
		(-3 -2 -1 = .) ///
		, gen(edu3)
	
		lab def edu3 1 "Low" 2 "Middle" 2 "High", replace
		lab val edu3 edu3
		lab var edu3 "Education (3 levels)"
			
gen edu2 = edu3
	recode edu2 (2=1) (3=2)
		lab def edu2 1 "Low/Middle" 2 "High", replace
		lab val edu2 educ2
		lab var edu2 "Education (2 levels)"		
	
* family status (at birth)

recode marstat5				///
      (-8 -3 -2 -1 = .)	///
	  , gen(mar)
	 
	 lab def mar 1 "Living with partner" 2 "Single" 3 "Widowed" 4 "Divorced" 5 "Separated", replace
	 lab val mar mar
	 lab var mar "Marital status (5 levels)"
	 
bys pid (country): gen mar_chg = 0 if mar[_n] == mar[_n+1]
	bys pid (country): replace mar_chg = 1 if mar[_n] != [mar[_n+1]]
	
* dynamic of family status before/after birth
	
bys pid (country): gen mar_chg_ba = 1 if mar[_n] == mar[_n+1] & parent_t == 0
	bys pid (country): replace mar_chg_ba = 2 if mar[_n] != [mar[_n+1]] & parent_t == 0
	bys pid (country): replace mar_chg_ba = 3 if mar[_n] == [mar[_n+1]] & parent_t == 1
	bys pid (country): replace mar_chg_ba = 4 if mar[_n] != mar[_n+1] & parent_t == 1
	
	lab def mar_chg_ba 1 "Before birth, no change" 2 "Before birth, change" 3 "After birth, no change" 4 "After birth, change", replace
	lab val mar_chg_ba mar_chg_ba
	lab var mar_chg_ba "Marital status change before/after birth"

* partner status

clonevar relstat_b = mar														// this is NOT status at birth!!!
	recode relstat_b (1=2) (2 3 4 5 = 1)
		lab def relstat_b 1 "No Partner" 2 "Partner"
		lab val relstat_b relstat_b
		lab var relstat_b "Partner (No/Yes)"

	tab relstat_b, gen(relst)

*------------------------------------------------------------------------------*

save "${pdta}/di_prep$ps", replace

/*------------------------------------------------------------------------------
#4 Define samples for analysis
------------------------------------------------------------------------------*/

use "${pdta}/di_prep$ps", clear

/*------------------------------------------------------------------------------

Sample A: 
	1. born 1970-1991
	2. observed before first pregnancy
	3. aged 18+ at obs.
    4. not recent samples (PSID, SOEP)
    5. truncate observation period before and after birth to -10 to 20
	
Sample B: no missings

Sample C: at least two pre-birth-year observations

Sample D: at least one pre-birth-year observation
------------------------------------------------------------------------------*/

* A: prep 1 - observed before first/second pregnancy

bysort pid: egen parent_tr=min(parent_ba) if parent_ev==1
	recode parent_tr -24/-1 = 1 0/70 = 0
	replace parent_tr=1 if parent_ev==0

* B: prep 2 - number of missing values in given year

egen miss=rowmiss(bi_veg bi_fr edu2 parent_t edu2 age sex relstat bcohort2)
* Version 2 bivegfr
*egen miss=rowmiss(bivegfr edu2 parent_t edu2 age sex relstat bcohort2)

* C: prep 3 - number of valid pre-pregnancy observations

bysort pid: egen abc=count(wavey) if parent_t==0 & miss==0 & age>=18
bysort pid: egen nobs=max(abc)
	drop abc

* D: generate variable that identifies Sample A

gen sampleA = bcohort2<.               /// born 1970-1991
			& age>17                   /// aged 18+
            & (parent_ba>-11 & parent_ba<16 | parent_ev==0) ///
            & parent_tr==1              // obs. before 1st pregnancy
			

* E: generate variable that identifies Sample B

gen sampleB = sampleA==1<.        /// 
            & miss==0              // no missing values          

* F: generate variable that identifies Sample C

gen sampleC = sampleB==1<.        /// 
            & nobs>1 & nobs<.     // at least two pre-pregnancy obs

* G: generate variable that identifies Sample D

gen sampleD = sampleB==1<.        /// 
            & nobs>0 & nobs<.     // at least one pre-pregnancy obs		

* Inspect samples

log using "${text}/di_sample.log", replace			

bysort female: ta parent_t country if sampleC==1, col

bysort female: ta parent_tvc country if sampleC==1
bysort female: ta parent_tvc country if sampleD==1
 
bysort country: tab wavey bi_dietvegfr if sampleA==1, m row nofreq
 
* codebook Sample = C (two pre-pregnancy obs)

codebook pid if sampleC==1 & parent_t==1 & country==1 & female==1
codebook pid if sampleC==1 & parent_t==1 & country==1 & female==0			

codebook pid if sampleC==1 & parent_t==1 & country==6 & female==1				
codebook pid if sampleC==1 & parent_t==1 & country==6 & female==0    			

* codebook Sample = D (one pre-pregnancy obs)

codebook pid if sampleD==1 & parent_t==1 & country==1 & female==1
codebook pid if sampleD==1 & parent_t==1 & country==1 & female==0

codebook pid if sampleD==1 & parent_t==1 & country==6 & female==1				
codebook pid if sampleD==1 & parent_t==1 & country==6 & female==0

capture log close

/*------------------------------------------------------------------------------
#5 Inspect data
------------------------------------------------------------------------------*/				  

log using "${text}/di_inspect.log", replace

* sort data
sort pid wavey

* inspect data
describe                       	// show all variables contained in data
notes                          	// show all notes contained in data
*codebook, problems             // potential problems in dataset
duplicates report pid wavey		// report duplicates
inspect                        	// distributions, #obs , missings

capture log close

/*------------------------------------------------------------------------------
#6 Label & Save
------------------------------------------------------------------------------*/

label data "CPF, andata, diet"

datasignature set, reset

save "${pdta}/andata$ps.dta", replace

/*----------------------------------------------------------------------------*/

* display running time

scalar endtime = c(current_time)

display ((round(clock(endtime, "hms") - clock(starttime, "hms"))) / 60000) " minutes"

*==============================================================================*
