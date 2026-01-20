/*==============================================================================
File name:		04cr-desmod-07ph-diet-com.do
Task:			Creates descriptive analyses of parenthood on diet
Project:		Parenthood and diet 
Author(s):		Munschek & Linden
Last update:  	2026-01-14
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Load data
#2 Sample descriptives
#3 Sample descriptives in comparison
#4 Fraction of daily veg. and fr. cons. before first birth by time (adjusted for covariates)
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes:
------------------------------------------------------------------------------*/

version 16.1  						// Stata version control
capture log close					// Closes log files
scalar starttime = c(current_time)	// Tracks running time

/*------------------------------------------------------------------------------
#1 Load data
------------------------------------------------------------------------------*/

clear all
use "${pdta}/andata$ps.dta"

scalar starttime = c(current_time)	// Tracks running time

* run analysis only for sampleD (at least one pre-pregnancy observations)

drop if sampleD==0

xtset pid syear
sort country pid

/*------------------------------------------------------------------------------
#2 Sample descriptives
------------------------------------------------------------------------------*/

* Table 1 - Person-years descriptives

	* N of observed women and men

	bys country sex: xtdescribe, pattern(1)

	* observational period

	tab syear country

	* observational years women and men

	tab sex country

	* transitions to motherhood/fatherhood

	tab sex country if parent_ba == 0 & parent_t == 1

	* mean age of parents

	mean age if parent_ev == 1, over(country sex)
	
/*------------------------------------------------------------------------------
#3 Sample descriptives in comparison
------------------------------------------------------------------------------*/	

* Table 3

	* Generate dummy variables for parental status: "before birth", "after birth" and "childless"	
		
	gen ever_birth = parent_ev == 0
	gen before_birth = parent_t == 0 & parent_ev == 1
	gen after_birth  = parent_t == 1 & parent_ev == 1

	* Recode demographic variables into binary format (0-1 coding)

	recode sex (1 = 0 "Male") (2=1 "Female"), gen (aux_sex)
	recode edu2 (1 = 0 "Low/Middle") (2=1 "High"), gen (aux_edu)
	recode relstat (1 = 0 "No Partner") (2=1 "Partner"), gen (aux_relstat)
	recode bcohort2 (2 = 0 "1970-1979") (3=1 "1980-1991"), gen (aux_bcohort2)

	* Examine the year of observation distribution by parental status and country

	* Childless, ever
	tab country syear if parent_ev==0 & sampleD==1, row

	* Parents before birth
	tab country syear if parent_ev==1 & parent_t == 0 & sampleD==1, row

	* Parents after birth	
	tab country syear if parent_ev==1 & parent_t == 1 & sampleD==1, row

	* Create mean values for demographic and dietary variables per individual.
	
	/*
	For each variable (e.g., age, aux_sex, aux_edu, aux_relstat, aux_bcohort2, bi_veg,
	bi_fr, bi2_dietvegfr, bi_dietvegfr), calculate the within-person mean
	over all available observations, separately for the three groups: childless, before birth
	and after birth
	*/

	tab country aux_bcohort2 if parent_ev==1 & parent_t == 1 & sampleD==1, row

	foreach var in age aux_sex aux_edu aux_relstat aux_bcohort2 bi_veg bi_fr bi_dietvegfr {
		// childless
		cap drop `var'_mean_ever
		egen `var'_mean_ever = mean(`var') if ever_birth, by(pid)

		// before birth
		cap drop `var'_mean_before
		egen `var'_mean_before = mean(`var') if before_birth, by(pid)

		// after birth
		cap drop `var'_mean_after
		egen `var'_mean_after = mean(`var') if after_birth, by(pid)
	}

	
	*Create a filter variable to select a single observation per individual per parental phase:
	
	/*
	- filter_var == 1 for childless individuals (first observation per person)
	- filter_var == 2 for parents before birth (first observation where parent_ev==1 and parent_t==0)
	- filter_var == 3 for parents after birth (the observation where the cumulative sum equals 1)
	*/

	gen condition = parent_t == 1 & parent_ev == 1
	bysort pid (wavey): gen cum_condition = sum(condition)

	gen filter_var = .
	bysort pid (wavey): replace filter_var = 1 if _n == 1 & parent_ev == 0
	bysort pid (wavey): replace filter_var = 2 if _n == 1 & parent_ev == 1 & parent_t == 0
	bysort pid (wavey): replace filter_var = 3 if cum_condition == 1

	drop if filter_var != 1 & filter_var != 2 & filter_var != 3

	* Summarize the mean values by country and parental status

	foreach var in age aux_sex aux_edu aux_relstat aux_bcohort2 bi_veg bi_fr bi_dietvegfr {
		
		// childless
		bysort country: summarize `var'_mean_ever if parent_ev == 0 & sampleD == 1, detail
		
		// before birth
		bysort country: summarize `var'_mean_before if parent_ev == 1 & parent_t == 0 & sampleD == 1, detail
		
		// after birth
		bysort country: summarize `var'_mean_after if parent_ev == 1 & parent_t == 1 & sampleD == 1, detail
	}

	* Conduct t-tests to compare the combined mean values across the three groups

	foreach var in age aux_sex aux_edu aux_relstat aux_bcohort2 bi_veg bi_fr bi_dietvegfr {
		// Fehlende Werte in den drei Gruppen auf 0 setzen
		recode `var'_mean_ever (.=0)
		recode `var'_mean_before (.=0)
		recode `var'_mean_after (.=0)
		
		// Combined variables
		gen `var'_combined = `var'_mean_ever + `var'_mean_before + `var'_mean_after

		// t-Test for AU
		ttest `var'_combined if parent_ev == 1 & country == 1, by(filter_var)

		// t-Test for UK
		ttest `var'_combined if parent_ev == 1 & country == 6, by(filter_var)
	}

	drop aux* *mean_ever *mean_before *mean_after before_birth after_birth condition cum_condition *_combined

/*----------------------------------------------------------------------------------------------------------
#4 Fraction of daily veg. and fr. cons. before first birth by time (adjusted for covariates)
----------------------------------------------------------------------------------------------------------*/

use "${pdta}/andata$ps.dta", clear 

drop if sampleD==0

xtset pid syear
sort country pid

rename parent_ba parent_ba_orig
gen parent_ba=parent_ba_orig + 25

* --- Define outcomes, tags, and y-axis titles ---
local outcomes  bi_veg bi_fr bi_dietvegfr
local tags      veg    fr     vegfr
local ytitles  `" "Proportion – Daily vegetable consumption (corrected for Z)"  "Proportion – Daily fruit consumption (corrected for Z)"  "Proportion – Daily veg. and/or fruit cons. (corrected for Z)" "'

* Loop over countries

foreach c in _au _uk {
    if "`c'"=="_au" local cc = "AU"
    if "`c'"=="_uk" local cc = "UK"

    * Generate time variable (years before first birth) only once per country
    capture confirm variable bftime`c'
    if _rc gen bftime`c' = -8 + _n if inrange(_n, 1, 7)

	* Loop over dependent variables (outcomes)
	
    forvalues oi = 1/3 {
        local y     : word `oi' of `outcomes'
        local tag   : word `oi' of `tags'
        local ylab  : word `oi' of `ytitles'

		* Loop over gender (1 = men, 2 = women)
		
        foreach s in 1 2 {
			* Run regression
            reg `y'`c' i.parent_ba##i.parent_ev i.edu2 age i.relstat i.bcohort2 i.syear ///
                if parent_t==0 & sampleD==1 & parent_ba>=18 & parent_ba<=24 & sex==`s', cluster(pid)

				* Calculate t degrees of freedom for confidence intervals
            local t = e(N_clust) - 1 - e(df_m)
            di as txt "df (t): " `t'

			* Marginal effects for parenthood event (0 = childless, 1 = expectant)
            margins, at(parent_ev=(0 1) parent_ba=(18(1)24))
            matrix result = r(table)

			 * Store predicted margins and standard errors
            local a = 14
            forval b = 1(2)13 {
                matrix p0`a'`c'  = result[1, "`b'._at"]
                matrix se0`a'`c' = result[2, "`b'._at"]
                local d = `b' + 1
                matrix p1`a'`c'  = result[1, "`d'._at"]
                matrix se1`a'`c' = result[2, "`d'._at"]
                local a = `a' + 1
            }

			* Combine results into single matrices and save as variables
            foreach m in p0 p1 se0 se1 {
                matrix `m' = `m'14`c'
                forval a = 15/20 {
                    matrix `m' = `m' \ `m'`a'`c'
                }
                
                svmat `m', names(`m'`s'`tag'`c')
            }

            * Create confidence interval bounds
            gen lo0`s'1`tag'`c' = p0`s'`tag'`c'1 - se0`s'`tag'`c'1*invttail(`t',0.025)
            gen hi0`s'1`tag'`c' = p0`s'`tag'`c'1 + se0`s'`tag'`c'1*invttail(`t',0.025)
            gen lo1`s'1`tag'`c' = p1`s'`tag'`c'1 - se1`s'`tag'`c'1*invttail(`t',0.025)
            gen hi1`s'1`tag'`c' = p1`s'`tag'`c'1 + se1`s'`tag'`c'1*invttail(`t',0.025)
        }

        * Plot for women (sex == 2)
        twoway (line p12`tag'`c'1 bftime`c', color(black%70) lw(thick)) ///
               (line p02`tag'`c'1 bftime`c', color(gray%70)  lw(thick) lp(solid)) ///
               (rarea lo121`tag'`c' hi121`tag'`c' bftime`c', color(black%15)) ///
               (rarea lo021`tag'`c' hi021`tag'`c' bftime`c', color(gray%15)) ///
               , legend(off) ///
               xtitle("Time before first birth in years", size(3.5)) xscale(titlegap(*10)) ///
               ytitle("`ylab'", size(3.5)) ///
               xlabel(-7(2)-1, val labsiz(3.6) nogr) ///
               ylabel(0(.2)1, labsiz(3) format(%2.1f) nogr) ///
               xline(-7(2)-1, lcolor(white) lw(vthin) lp(solid)) ///
               xline(-8(2)-1, lcolor(white) lw(medium) lp(solid)) ///
               yline(.1(.2).9, lcolor(white) lw(vthin) lp(solid)) ///
               yline(0(.2)1,  lcolor(white) lw(medium) lp(solid)) ///
               text(.15 -7 "Expectant mothers", size(4) c(black%90) place(e)) ///
               text(.05 -7 "Always childless",  size(4) c(gray%90)  place(e)) ///
               plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) graphregion(fcolor(white)) ///
               title("Women, `cc'", siz(4)) xsize(4) ysize(4.3) name("exp2_`tag'_fem`c'", replace)
        

       * Plot for men (sex == 1)
        twoway (line p11`tag'`c'1 bftime`c', color(black%90) lw(thick)) ///
               (line p01`tag'`c'1 bftime`c', color(gray%90)  lw(thick) lp(solid)) ///
               (rarea lo111`tag'`c' hi111`tag'`c' bftime`c', color(black%15)) ///
               (rarea lo011`tag'`c' hi011`tag'`c' bftime`c', color(black%15)) ///
               , legend(off) ///
               xtitle("Time before first birth in years", size(3.5)) xscale(titlegap(*10)) ///
               ytitle("`ylab'", size(3.5)) ///
               xlabel(-7(2)-1, val labsiz(3.6) nogr) ///
               ylabel(0(.2)1, labsiz(3) format(%2.1f) nogr) ///
               xline(-7(2)-1, lcolor(white) lw(vthin) lp(solid)) ///
               xline(-8(2)-1, lcolor(white) lw(medium) lp(solid)) ///
               yline(.1(.2).9, lcolor(white) lw(vthin) lp(solid)) ///
               yline(0(.2)1,  lcolor(white) lw(medium) lp(solid)) ///
               text(.15 -7 "Expectant fathers", size(4) c(black%90) place(e)) ///
               text(.05 -7 "Always childless",  size(4) c(gray%90)  place(e)) ///
               plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) graphregion(fcolor(white)) ///
               title("Men, `cc'", siz(4)) xsize(4) ysize(4.3) name("exp2_`tag'_mal`c'", replace)
        
    }
}

*combined (Appendix figures A1-A3)

	grc1leg2 ///
		exp2_vegfr_fem_au ///
		exp2_vegfr_fem_uk ///
		exp2_vegfr_mal_au ///
		exp2_vegfr_mal_uk, ///
				ytol xtob ytsize(2.5) xtsize(2.5) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
		graph export "${plot}/figA1.emf", replace

		
	grc1leg2 ///
		exp2_fr_fem_au ///
		exp2_fr_fem_uk ///
		exp2_fr_mal_au ///
		exp2_fr_mal_uk, ///
				ytol xtob ytsize(2.5) xtsize(2.5) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
		graph export "${plot}/figA2_fr_komb.emf", replace

		
	grc1leg2 ///
		exp2_veg_fem_au ///
		exp2_veg_fem_uk ///
		exp2_veg_mal_au ///
		exp2_veg_mal_uk, ///
				ytol xtob ytsize(2.5) xtsize(2.5) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
		graph export "${plot}/figA3_veg_komb.emf", replace

*==============================================================================*
