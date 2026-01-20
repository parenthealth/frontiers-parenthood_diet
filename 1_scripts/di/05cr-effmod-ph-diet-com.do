/*==============================================================================
File name:      05cr-effmod-07ph-diet-com
Task:           Creates effect analysis of parenthood on diet
Project:      	Parenthood and diet
Author(s):		Munschek & Linden
Last update:  	2026-01-14
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Load data
#2 Regression models for main analyses for dietary variables across two countries, stratified by sex
#3 Figures & Tables for time-varying-effects, stratified by gender
#4 Regression models for main analyses for dietary variables across two countries, stratified by education
#5 Figures & Tables for time-varying-effects, stratified by education
------------------------------------------------------------------------------*/

version 16.1						// Stata version control
capture log close					// Closes log files

/*------------------------------------------------------------------------------
#1 Load data
------------------------------------------------------------------------------*/

clear all
use "${pdta}/andata$ps.dta"

scalar starttime = c(current_time)	// Tracks running time

* run analysis only for sampleC (at least one pre-pregnancy observation)

drop if sampleD==0

xtset pid syear
sort country pid

* define global for changing av easily

global av1 "bi_dietvegfr"
global av2 "bi_veg"
global av3 "bi_fr"

label define educ2 1 "low/middle" 2 "high", modify

/*--------------------------------------------------------------------------------------------------
#2 Regression models for main analyses for dietary variables across two countries, stratified by sex
--------------------------------------------------------------------------------------------------*/ 

global covars "age i.edu2 i.relstat_b i.syear i.bcohort2"

* generate containers for estimates, lower & higher CI boundaries
	
***Daily vegetable and/or fruit consumption***
	
foreach c in _au _uk {
    
	if "`c'"=="_au" {
		local cc = "AU"
	}

	if "`c'"=="_uk" {
		local cc = "UK"
	}
	
		foreach s in 1 2 {
			for any estgd`s'a`c' estdd`s'a`c' estdt`s'a`c' ///
					logd`s'a`c' lodd`s'a`c' lodt`s'a`c'    ///
					higd`s'a`c' hidd`s'a`c' hidt`s'a`c': gen X=.
					
		* estimates models:
					
		local m=1
		foreach x in parent_t i.parent_tvc {
			reg $av1`c' `x' $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MPOLS`m'`s'a`c'

				forval n=1/5 {
					capture replace estgd`s'a`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace logd`s'a`c'=estgd`s'a`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace higd`s'a`c'=estgd`s'a`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}

			reg $av1`c' `x' parent_ev $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MDID`m'`s'a`c'
		
				forval n=1/5 {
					capture replace estdd`s'a`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace lodd`s'a`c'=estdd`s'a`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace hidd`s'a`c'=estdd`s'a`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}


		local m=`m'+1	  
		}
	}	
}

***Daily vegetable consumption***

foreach c in _au _uk {
    
	if "`c'"=="_au" {
		local cc = "AU"
	}

	if "`c'"=="_uk" {
		local cc = "UK"
	}
	
		foreach s in 1 2 {
			for any estgd`s'b`c' estdd`s'b`c' estdt`s'b`c' ///
					logd`s'b`c' lodd`s'b`c' lodt`s'b`c'    ///
					higd`s'b`c' hidd`s'b`c' hidt`s'b`c': gen X=.
					
		* estimates models:
					
		local m=1
		foreach x in parent_t i.parent_tvc {
			reg $av2`c' `x' $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MPOLS`m'`s'b`c'

				forval n=1/5 {
					capture replace estgd`s'b`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace logd`s'b`c'=estgd`s'b`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace higd`s'b`c'=estgd`s'b`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}

			reg $av2`c' `x' parent_ev $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MDID`m'`s'b`c'
		
				forval n=1/5 {
					capture replace estdd`s'b`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace lodd`s'b`c'=estdd`s'b`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace hidd`s'b`c'=estdd`s'b`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}


		local m=`m'+1	  
		}
	}	
}

***Daily fruit consumption***

foreach c in _au _uk {
    
	if "`c'"=="_au" {
		local cc = "AU"
	}

	if "`c'"=="_uk" {
		local cc = "UK"
	}
	
		foreach s in 1 2 {
			for any estgd`s'c`c' estdd`s'c`c' estdt`s'c`c' ///
					logd`s'c`c' lodd`s'c`c' lodt`s'c`c'    ///
					higd`s'c`c' hidd`s'c`c' hidt`s'c`c': gen X=.
					
		* estimates models:
					
		local m=1
		foreach x in parent_t i.parent_tvc {
			reg $av3`c' `x' $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MPOLS`m'`s'c`c'

				forval n=1/5 {
					capture replace estgd`s'c`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace logd`s'c`c'=estgd`s'c`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace higd`s'c`c'=estgd`s'c`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}

			reg $av3`c' `x' parent_ev $covars if sex==`s' & sampleD==1, cluster(pid)
			est store MDID`m'`s'c`c'
		
				forval n=1/5 {
					capture replace estdd`s'c`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace lodd`s'c`c'=estdd`s'c`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
					capture replace hidd`s'c`c'=estdd`s'c`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
				}


		local m=`m'+1	  
		}
	}	
}

/*------------------------------------------------------------------------------
#3 Figures & Tables for time-varying-effects, stratified by gender
------------------------------------------------------------------------------*/

* Figure 1-3: Daily fruit and/or vegetable consumption: parents vs. childless individuals across time/countries stratified by gender

gen model=_n if _n<6
label val model parent_tvc

graph set window fontface "Arial"

foreach c in _au _uk {	  
    
    if "`c'"=="_au" {
        local cc = "AU"
    }   
    
    if "`c'"=="_uk" {
        local cc = "UK"
    }  
	
	    * Iterate over a to d for h
    foreach h in a b c {

        * Define the "ytitle" depending on the value of h
        if "`h'" == "a" {
            local ytitle "Difference in the proportion of daily" ///
                 "vegetable and/or fruit consumption"
        }
        if "`h'" == "b" {
            local ytitle "Difference in the proportion of daily" ///
                 "vegetable consumption"
        }
        if "`h'" == "c" {
            local ytitle "Difference in the proportion of daily" ///
                 "fruit consumption"
        }
		
	* figures for men

	twoway (rspike lodd1`h'`c' hidd1`h'`c' model, color(gs9) lw(vvthick)) ///
	   (connected estdd1`h'`c' model, ms(O) mc(black) mfc(gs2) lc(black) msize(large) lp(dash) lw(.65)) ///
	 , legend(order(2) label(2 "POLS-GFE") ring(0) bplace(11) fc(none))  ///
	   ytitle("`ytitle'", size(3.6))  ///
	   xtitle("Timepoints", size(3.6))  ///
	   xlabel(1(1)5, val labsiz(3.6) angle(45) nogrid) ylabel(-.2 (.1).25, labsiz(3.5) nogrid format(%2.1f)) ///
       xline(1(1)5, lcolor(white) lw(thin)) ///
	   xline(1.5 2.5 3.5 4.5 5.5, lcolor(white) lw(vthin)) ///
	   yline(.05 -.05 .15 .20 .25 .30 .35 .40 -.15, lcolor(white) lw(vthin)) ///
       yline(0, lcolor(gs6) lw(thin)) ///
       yline(.1 -.1 -.2 -.3 -.4, lcolor(white) lw(thin)) ///
	   title("Men, `cc'", color(black) size(3.6)) ///
	   plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) xsize(4) ysize(3.7) graphregion(fcolor(white)) name(t_vary_mal`c'_`h', replace)	

	* figures for women

	twoway (rspike lodd2`h'`c' hidd2`h'`c' model, color(gs9) lw(vvthick)) ///
	   (connected estdd2`h'`c' model, ms(O) mc(black) mfc(gs2) lc(black) msize(large) lp(dash) lw(.65)) ///
	 , legend(order(2) label(2 "POLS-GFE") ring(0) bplace(11) fc(none))  ///
	   ytitle("`ytitle'", size(3.6))  ///
	   xtitle("Timepoints", size(3.6))  ///
	   xlabel(1(1)5, val labsiz(3.6) angle(45) nogrid) ylabel(-.2 (.1).25, labsiz(3.5) nogrid format(%2.1f)) ///
       xline(1(1)5, lcolor(white) lw(thin)) ///
	   xline(1.5 2.5 3.5 4.5 5.5, lcolor(white) lw(vthin)) ///
	   yline(.05 -.05 .15 .20 .25 .30 .35 .40 -.15, lcolor(white) lw(vthin)) ///
       yline(0, lcolor(gs6) lw(thin)) ///
       yline(.1 -.1 -.2 -.3 -.4, lcolor(white) lw(thin)) ///
	   title("Women, `cc'", color(black) size(3.6)) ///
	   plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) xsize(4) ysize(3.7) graphregion(fcolor(white)) name(t_vary_fem`c'_`h', replace)

	   }
}

* combined

	grc1leg2 ///
		t_vary_fem_au_a ///
		t_vary_fem_uk_a ///
		t_vary_mal_au_a ///
		t_vary_mal_uk_a ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig1.eps", replace	

	grc1leg2 ///
		t_vary_fem_au_b ///
		t_vary_fem_uk_b ///
		t_vary_mal_au_b ///
		t_vary_mal_uk_b ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig2.eps", replace	
	
	grc1leg2 ///
		t_vary_fem_au_c ///
		t_vary_fem_uk_c ///
		t_vary_mal_au_c ///
		t_vary_mal_uk_c ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig3.eps", replace

*------------------------------------------------------------------------------*

* Regression tables - Appendix Table A2
	
rename syear syear_aux
egen syear= group(syear_aux)
labmask syear, values(syear_aux)
lab var syear "Wave"

* FPH tables for men

esttab ///
    MDID21a_au MDID21b_au MDID21c_au MDID21a_uk MDID21b_uk MDID21c_uk ///
    using "${text}/tableA2.rtf", append ///
    title("Appendix - Dietary Models for Men") ///
    stats(N aic bic ll r2_a, fmt(%9.0g) labels("Observations" "AIC" "BIC" "Log-likelihood" "R²")) ///
    cells(b(fmt(3) star) se(par)) ///
    se star(* 0.10 ** 0.05 *** 0.01) b(3) ///
    mlabels("AU-Veg.-Fr." "UK-Veg.-Fr." "AU-Veg." "UK-Veg." "AU-Fr." "UK-Fr.") ///
    eqlabels(none) label ///
   varlabels( ///
        parent_tvc "Time before/since birth (Ref.: BY-3a+)" ///
        edu2 "Education (Ref.: Low)" ///
        relstat_b "Partner (Ref.: No partner)" ///
        bcohort2 "Birth cohort (Ref.: 1970-1979)" ///
        parent_ev "Ever parent (DID)" ///
        _cons "Constant" ///
    ) ///
	drop(0.parent_tvc 1.edu2 1.relstat_b 2.bcohort2) ///
    order(parent_tvc *.parent_tvc edu2 2.edu2 age relstat_b 2.relstat_b ///
          bcohort2 3.bcohort2 ///
          syear 2007.syear 2009.syear 2011.syear 2013.syear 2014.syear 2016.syear 2017.syear 2018.syear ///
          parent_ev)

* FPH tables for women

esttab ///
    MDID22a_au MDID22b_au MDID22c_au MDID22a_uk MDID22b_uk MDID22c_uk ///
    using "${text}/tableA2.rtf", replace ///
    title("Appendix - Dietary Models for Women") ///
    stats(N aic bic ll r2_a, fmt(%9.0g) labels("Observations" "AIC" "BIC" "Log-likelihood" "R²")) ///
    cells(b(fmt(3) star) se(par)) ///
    se star(* 0.10 ** 0.05 *** 0.01) b(3) ///
    mlabels("AU-Veg.-Fr." "UK-Veg.-Fr." "AU-Veg." "UK-Veg." "AU-Fr." "UK-Fr.") ///
    eqlabels(none) label ///
   varlabels( ///
        parent_tvc "Time before/since birth (Ref.: BY-3a+)" ///
        edu2 "Education (Ref.: Low)" ///
        relstat_b "Partner (Ref.: No partner)" ///
        bcohort2 "Birth cohort (Ref.: 1970-1979)" ///
        parent_ev "Ever parent (DID)" ///
        _cons "Constant" ///
    ) ///
	drop(0.parent_tvc 1.edu2 1.relstat_b 2.bcohort2) ///
    order(parent_tvc *.parent_tvc edu2 2.edu2 age relstat_b 2.relstat_b ///
          bcohort2 3.bcohort2 ///
          syear 2007.syear 2009.syear 2011.syear 2013.syear 2014.syear 2016.syear 2017.syear 2018.syear ///
          parent_ev)
		  
* drop created estimates

drop estgd1a_au-_est_MDID22c_uk
est drop MPOLS* MDID*		  

/*--------------------------------------------------------------------------------------------------------
#4 Regression models for main analyses for dietary variables across two countries, stratified by education
--------------------------------------------------------------------------------------------------------*/
	
**Daily Vegetable and/or Fruit

global covars "age i.sex i.relstat_b i.syear i.bcohort2"
    
foreach c in _au _uk {
        
        if "`c'"=="_au" {
            local cc = "AU"
        }   
        
        if "`c'"=="_uk" {
            local cc = "UK"
        }

        forval e=1/2 {
            for any estgde`e'a`c' estdde`e'a`c' estdte`e'a`c' ///
                    logde`e'a`c' lodde`e'a`c' lodt`e'a`c'    ///
                    higde`e'a`c' hidde`e'a`c' hidt`e'a`c': gen X=.

                local m=1
                foreach x in parent_t i.parent_tvc i.parent_tv {
                    reg $av1`c' `x' $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MPOLS`m'`e'a`c'

                    forval n=1/6 {
                        capture replace estgde`e'a`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace logde`e'a`c'=estgde`e'a`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace higde`e'a`c'=estgde`e'a`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                    reg $av1`c' `x' parent_ev $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MDID`m'`e'a`c'
                    
                    forval n=1/6 {
                        capture replace estdde`e'a`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace lodde`e'a`c'=estdde`e'a`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace hidde`e'a`c'=estdde`e'a`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                local m=`m'+1      
                }
            }    
			}	
	

**Daily Vegetable

foreach c in _au _uk {
        
        if "`c'"=="_au" {
            local cc = "AU"
        }   
        
        if "`c'"=="_uk" {
            local cc = "UK"
        }

        forval e=1/2 {
            for any estgde`e'b`c' estdde`e'b`c' estdte`e'b`c' ///
                    logde`e'b`c' lodde`e'b`c' lodt`e'b`c'    ///
                    higde`e'b`c' hidde`e'b`c' hidt`e'b`c': gen X=.

                local m=1
                foreach x in parent_t i.parent_tvc i.parent_tv {
                    reg $av2`c' `x' $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MPOLS`m'`e'b`c'

                    forval n=1/6 {
                        capture replace estgde`e'b`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace logde`e'b`c'=estgde`e'b`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace higde`e'b`c'=estgde`e'b`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                    reg $av2`c' `x' parent_ev $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MDID`m'`e'b`c'
                    
                    forval n=1/6 {
                        capture replace estdde`e'b`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace lodde`e'b`c'=estdde`e'b`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace hidde`e'b`c'=estdde`e'b`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                local m=`m'+1      
                }
            }    
			}	
			
			
**Daily Fruit
  
foreach c in _au _uk {
        
        if "`c'"=="_au" {
            local cc = "AU"
        }   
        
        if "`c'"=="_uk" {
            local cc = "UK"
        }

        forval e=1/2 {
            for any estgde`e'c`c' estdde`e'c`c' estdte`e'c`c' ///
                    logde`e'c`c' lodde`e'c`c' lodt`e'c`c'    ///
                    higde`e'c`c' hidde`e'c`c' hidt`e'c`c': gen X=.

                local m=1
                foreach x in parent_t i.parent_tvc i.parent_tv {
                    reg $av3`c' `x' $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MPOLS`m'`e'c`c'

                    forval n=1/6 {
                        capture replace estgde`e'c`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace logde`e'c`c'=estgde`e'`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace higde`e'c`c'=estgde`e'`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                    reg $av3`c' `x' parent_ev $covars if edu2==`e' & sampleD==1, cluster(pid)
                    est store MDID`m'`e'c`c'
                    
                    forval n=1/6 {
                        capture replace estdde`e'c`c'=_b[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace lodde`e'c`c'=estdde`e'c`c'-1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                        capture replace hidde`e'c`c'=estdde`e'c`c'+1.96*_se[`n'.parent_tvc] if _n==`n' & `m'==2
                    }

                local m=`m'+1      
                }
            }    
		}				

/*------------------------------------------------------------------------------
#3 Figures & Tables for time-varying-effects, stratified by education
------------------------------------------------------------------------------*/	
	
* Figure 4-6: Daily fruit and/or vegetable consumption: parents vs. childless individuals across time/countries stratified by education
	
foreach c in _au _uk {	  
    
    if "`c'"=="_au" {
        local cc = "AU"
    }   
    
    if "`c'"=="_uk" {
        local cc = "UK"
    }  
	
	    * Iterate over a to d for h
    foreach h in a b c {

        * Define the "ytitle" depending on the value of h
        if "`h'" == "a" {
            local ytitle "Difference in the proportion of daily" ///
                 "vegetable and/or fruit consumption"
        }
        if "`h'" == "b" {
            local ytitle "Difference in the proportion of daily" ///
                 "vegetable consumption"
        }
        if "`h'" == "c" {
            local ytitle "Difference in the proportion of daily" ///
                 "fruit consumption"
        }

	
	* low/middle edu
	
		twoway (rspike lodde1`h'`c' hidde1`h'`c' model, color(gs9) lw(vvthick)) ///	   
			   (connected estdde1`h'`c' model, ms(O) mc(black) lc(black) mfc(gs2) msize(large) lp(dash) lw(.65))  ///
			 , legend(order(3) label(3 "Education: Low/Middle") ring(0) bplace(7)) ///
			   xtitle("Timepoints", size(3.6)) ytitle("`ytitle'", size(3.6)) ///
			   xlabel(1(1)5, val labsiz(3.5) angle(45) nogrid) ylabel(-.2(.1).25, labsiz(3.5) nogrid format(%2.1f)) ///
			   xline(1(1)5, lcolor(white) lw(thin) lp(solid)) ///
				xline(1.5 2.5 3.5 4.5 5.5, lcolor(white) lw(vthin)) ///
				yline(.05 -.05 .15 .20 .25 .30 .35 .40 -.15, lcolor(white) lw(vthin)) ///
				yline(0, lcolor(gs6) lw(thin)) ///
				yline(.1 -.1 -.2 -.3, lcolor(white) lw(thin)) ///
			   title("Women and Men, `cc'", size(3.6)) ///
			   plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) xsize(4) ysize(3.7) graphregion(fcolor(white)) name(t_vary_edu_low`c'_`h', replace)
		
		
		* high edu
		
		twoway (rspike lodde2`h'`c' hidde2`h'`c' model, color(gs9) lw(vvthick)) ///
			   (connected estdde2`h'`c' model, ms(O) mc(black) lc(black) mfc(white) msize(large) lp(dash) lw(.65))  ///
			 , legend(order(4) label(4 "Education: High") ring(0) bplace(7)) ///
			   xtitle("Timepoints", size(3.6)) ytitle("`ytitle'", size(3.6)) ///
			   xlabel(1(1)5, val labsiz(3.5) angle(45) nogrid) ylabel(-.2(.1).25, labsiz(3.5) nogrid format(%2.1f)) ///
				xline(1(1)5, lcolor(white) lw(thin)) ///
				xline(1.5 2.5 3.5 4.5 5.5, lcolor(white) lw(vthin)) ///
				yline(.05 -.05 .15 .20 .25 .30 .35 .40 -.15, lcolor(white) lw(vthin)) ///
				yline(0, lcolor(gs6) lw(thin)) ///
				yline(.1 -.1 -.2 -.3, lcolor(white) lw(thin)) ///
			   title("Women and Men, `cc'", size(3.6)) ///
			   plotregion(lcolor(gs6) fc(gs14) margin(medium) lw(medthick)) xsize(4) ysize(3.7) graphregion(fcolor(white)) name(t_vary_edu_high`c'_`h', replace)

		   }
}

* combined

	grc1leg2 ///
		t_vary_edu_low_au_a ///
		t_vary_edu_high_au_a ///
		t_vary_edu_low_uk_a ///
		t_vary_edu_high_uk_a ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) lrow(1) ring(12) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig4.eps", replace	
	
	
	grc1leg2 ///
		t_vary_edu_low_au_b ///
		t_vary_edu_high_au_b ///
		t_vary_edu_low_uk_b ///
		t_vary_edu_high_uk_b ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig5.eps", replace	
	
	
	grc1leg2 ///
		t_vary_edu_low_au_c ///
		t_vary_edu_high_au_c ///
		t_vary_edu_low_uk_c ///
		t_vary_edu_high_uk_c ///
			,ytol xtob ytsize(3.3) xtsize(3.3) xsize(7.08) ysize(3.82) loff iscale(0.6) row(2) graphregion(fcolor(white) margin(5 5 5 5)) graphon
	graph export "${plot}/fig6.eps", replace

graph drop *

/*----------------------------------------------------------------------------*/

* Regression tables - Appendix Table A3

* Tab. Veg. and/or Fr.
esttab /// 
    MDID21a_au MDID22a_au MDID21a_uk MDID22a_uk ///
    using "${text}/tableA3.rtf", replace ///
    title("Appendix - Dietary Models: Daily Veg+Fruit, stratified by education") ///
    stats(N, fmt(%9.0g) labels("Observations" "AIC" "BIC" "Log-likelihood" "R²")) ///
    cells(b(fmt(3) star) se(par)) ///
    se star(* 0.10 ** 0.05 *** 0.01) b(3) ///
    mlabels("AU-Edu. low/middle" "UK-Edu. low/middle" "AU-Edu. high" "UK-Edu. high") ///
    eqlabels(none) label ///
    varlabels( ///
        parent_tvc "Time before/since birth (Ref.: BY-3a+)" ///
		sex "Sex (Ref. Men)" ///
        relstat_b "Partner status (Ref.: No partner)" ///
        bcohort2 "Birth cohort (Ref.: 1970-1979)" ///
        parent_ev "Ever parent (DID)" ///
        _cons "Constant" ///
    ) ///
    drop(0.parent_tvc 1.relstat_b 2.bcohort2 1.sex) ///
    order(parent_tvc *.parent_tvc 2.sex age relstat_b 2.relstat_b ///
          bcohort2 3.bcohort2 ///
          syear 2007.syear 2009.syear 2011.syear 2013.syear 2014.syear 2016.syear 2017.syear 2018.syear ///
          parent_ev)	  

* Tab. Veg.
esttab /// 
    MDID21b_au MDID22b_au MDID21b_uk MDID22b_uk ///
    using "${text}/tableA3.rtf", append ///
    title("Appendix - Dietary Models: Daily Veg., stratified by education") ///
    stats(N, fmt(%9.0g) labels("Observations" "AIC" "BIC" "Log-likelihood" "R²")) ///
    cells(b(fmt(3) star) se(par)) ///
    se star(* 0.10 ** 0.05 *** 0.01) b(3) ///
    mlabels("AU-Edu. low/middle" "UK-Edu. low/middle" "AU-Edu. high" "UK-Edu. high") ///
    eqlabels(none) label ///
    varlabels( ///
        parent_tvc "Time before/since birth (Ref.: BY-3a+)" ///
		sex "Sex (Ref. Men)" ///
        relstat_b "Partner status (Ref.: No partner)" ///
        bcohort2 "Birth cohort (Ref.: 1970-1979)" ///
        parent_ev "Ever parent (DID)" ///
        _cons "Constant" ///
    ) ///
    drop(0.parent_tvc 1.relstat_b 2.bcohort2 1.sex) ///
    order(parent_tvc *.parent_tvc 2.sex age relstat_b 2.relstat_b ///
          bcohort2 3.bcohort2 ///
          syear 2007.syear 2009.syear 2011.syear 2013.syear 2014.syear 2016.syear 2017.syear 2018.syear ///
          parent_ev)
	  
* Tab. Fr.
esttab /// 
    MDID21c_au MDID22c_au MDID21c_uk MDID22c_uk ///
    using "${text}/tableA3.rtf", append ///
    title("Appendix - Dietary Models: Daily Fruit, stratified by education") ///
    stats(N aic bic ll r2_a, fmt(%9.0g) labels("Observations" "AIC" "BIC" "Log-likelihood" "R²")) ///
    cells(b(fmt(3) star) se(par)) ///
    se star(* 0.10 ** 0.05 *** 0.01) b(3) ///
    mlabels("AU-Edu. low/middle" "UK-Edu. low/middle" "AU-Edu. high" "UK-Edu. high") ///
    eqlabels(none) label ///
    varlabels( ///
        parent_tvc "Time before/since birth (Ref.: BY-3a+)" ///
		sex "Sex (Ref. Men)" ///
        relstat_b "Partner status (Ref.: No partner)" ///
        bcohort2 "Birth cohort (Ref.: 1970-1979)" ///
        parent_ev "Ever parent (DID)" ///
        _cons "Constant" ///
    ) ///
    drop(0.parent_tvc 1.relstat_b 2.bcohort2 1.sex) ///
    order(parent_tvc *.parent_tvc 2.sex age relstat_b 2.relstat_b ///
          bcohort2 3.bcohort2 ///
          syear 2007.syear 2009.syear 2011.syear 2013.syear 2014.syear 2016.syear 2017.syear 2018.syear ///
          parent_ev)

*==============================================================================*
