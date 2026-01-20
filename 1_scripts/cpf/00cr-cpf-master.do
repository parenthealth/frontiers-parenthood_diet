/*==============================================================================
File:         	00cr-cpf-master.do
Task:         	Master do-file for creating a dataset with harmonized variables
				from HILDA & BHPS
Project:      	Parenthood & health behaviour
Author(s):		Munschek & Linden
Last update:  	2026-01-20
Run time:		Approximately 20 min.
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Install needed ado files
#2 Stata Settings
#3 Create working directories & define globals (raw data)
#4 !!! IMPORTANT !!! Insert raw data
#5 Create working directories & define globals (cpf data)
#6 Run country specific do-files, append & label dataset
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes: 

IMPORTANT - RUN DO-FILE TILL STEP #4, THEN INSERT RAW DATA, THEN PROCEED WITH STEP #5

------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
#1 Install needed ado files                                                         
------------------------------------------------------------------------------*/
/*
* blindschemes (additional blind & colorblind optimized schemes for plots)

cap which blindschmes
	if _rc ssc install blindschemes, replace

* estout (formatting and exporting tables)

cap which blindschmes
	if _rc ssc install estout, replace

* coefplot (formatting and exporting output as plots)

cap which blindschmes
	if _rc ssc install coefplot, replace

* isvar, iscogen & psditools (needed to create harmonized file)

foreach ado in isvar iscogen psidtools  {
	cap which `ado'
	if _rc ssc install `ado', replace
}

* renvars (renames variables in varlist instead of single rename)

cap which renvars
	if _rc net install http://www.stata-journal.com/software/sj5-4/dm88_1

	
* svmat (creates matrix from variables)

cap which svmat2
	if _rc	net install  http://www.stata.com/stb/stb56/dm79
*/
/*------------------------------------------------------------------------------
#2 Stata settings
------------------------------------------------------------------------------*/

version 16.1          				// Stata version control
clear all             				// clear memory
macro drop _all       				// delete all macros
set linesize 82       				// result window has room for 82 chars in one line
set more off, perm    				// prevents pause in results window
set scheme plotplain  				// sets color scheme for graphs
set maxvar 32767      				// size of data matrix
scalar starttime = c(current_time)	// Tracks running time

/*------------------------------------------------------------------------------
#3 Create working directories & define globals (raw data)
------------------------------------------------------------------------------*/

* project stamp

global ps "-cpf-data"

* working directory 

* -> Retrieve c(username) by typing disp "`c(username)'" in command line
* -> Set global wdir as path, where repo is saved

if "`c(username)'" == "[YOUR USER NAME]" {
	global wdir "[PATH WHERE REPO IS SAVED]"
}

* create survey-specific folder names for raw data

global hilda 	"01_HILDA"
global ukhls 	"02_UKHLS"
global surv_fold  $hilda $ukhls

* create survey-specific folders for raw data

foreach surv of global surv_fold {
	capture mkdir "${wdir}\2_rdta\\`surv'"
}

* create survey-specific subfolders for raw data

*HILDA*

	* create folder names

	global Fhilda_combined "STATA 190c (Combined)"
	global Fhilda_other "STATA 190c (Other)"
	
	* create path globals
	
	global Ghilda_combined "${wdir}\2_rdta\01_HILDA\\${Fhilda_combined}"
	global Ghilda_other "${wdir}\2_rdta\01_HILDA\\${Fhilda_other}"
	
	* create folders

	capture mkdir "${Ghilda_combined}"
	capture mkdir "${Ghilda_other}"
	
*BHPS*

	* create folder names

	global Fukhls_6614 "UKDA-6614-stata"
	global Fukhls_8473 "UKDA-8473-stata"
	
	* create path globals
	
	global Gukhls_6614 "${wdir}\2_rdta\02_UKHLS\\${Fukhls_6614}"
	global Gukhls_8473 "${wdir}\2_rdta\02_UKHLS\\${Fukhls_8473}"
	
	* create folders

	capture mkdir "${Gukhls_6614}"
	capture mkdir "${Gukhls_8473}"

********************************************************************************
disp "!!! STOP HERE AND INSERT RAW DATA FILES !!!"
********************************************************************************

/*------------------------------------------------------------------------------
#4 !!! IMPORTANT !!! Insert raw data
------------------------------------------------------------------------------*/

/*
To run the do-files from here properly, you need to insert the raw datasets 
BEFORE continuing with #5. Insert the raw data as follows:

*HILDA* 
	
	Apply for the data via the National Centre for Longitudinal 
	Data Dataverse (Australian Government Department of Social Services): 
	
	https://dataverse.ada.edu.au/dataverse/ncld. 
	
	Unpack downloaded files, 
	such as STATA 190c (1-Combined Data Files) and STATA 190c 
	(2-Other Data Files), to subfolders indicated as “Combined” and “Other” 
	in the “Data” folder. The final structure should look as follows:
	
	2_rdta\01_HILDA\STATA 190c (Combined)\[the data] &
	2_rdta\01_HILDA\STATA 190c (Other)\[the data]	
	
*UKHLS/BHPS*
	
	Data are available via the UK Data Service after granting access: 
	
	www.ukdataservice.ac.uk.
	
	Please note that the analysis carried out in this article is based on BHPS
	data. However, due to data structure and the change from UKHLS to BHPS
	UKHLS data is also required to create the variables. Therefore, all 
	cross-references are labeled with the synonym UKHLS.
	
	Data should be unpacked into the specific folder with keeping additionally
	the specific subfolders’ path (e.g. UKDA-6614-stata\stata\stata11_se), 
	which contains then all the wave-specific folders. The final 
	structure should look as follows:
	
	2_rdta\02_UKHLS\UKDA-6614-stata\[the data] &
	2_rdta\02_UKHLS\UKDA-8473-stata\[the data]	
	
	These folders (e.g. bhps_w1, ukhls_w1) 
	contain the data files for each wave. v

*/

/*------------------------------------------------------------------------------
#5 Create working directories & define globals (cpf data)
------------------------------------------------------------------------------*/

* create cpf folder name

global cpf 	"cpf"
global cpf_fold  $cpf

* create cpf folder

foreach cpf of global cpf_fold {
	capture mkdir "${wdir}\3_pdta\\`cpf'"
}

* create cpf output folder names

global Fcpf_out "01cpf-out" 	// 	name processed data folder
global Flog 	"02cpf-log"	//	name log folder
	
* create cpf output folder paths
 
global Gcpf_out 	"${wdir}\3_pdta\cpf\\${Fcpf_out}"  	// create processed data folder	
global Gcpf_log 	"${wdir}\3_pdta\cpf\\${Flog}" 		// name log folder
	
* create cpf output folders

capture mkdir   "${Gcpf_out}"	
capture mkdir   "${Gcpf_log}"

* create survey-specific subfolder names for cpf

global hilda_cpf 	"01_HILDA_cpf"
global ukhls_cpf 	"02_UKHLS_cpf"
global surv_fold_cpf  $hilda_cpf $ukhls_cpf

* create survey specific subfolder for cpf temp data

foreach surv of global surv_fold_cpf {
	capture mkdir "${Gcpf_out}\\`surv'"
	capture mkdir "${Gcpf_out}\\`surv'\temp"  	//working files
}

* define global working macros

	* global for path to syntax files

	global cpf_in 	"${wdir}\1_scripts\cpf\"
	global logs		"${wdir}\3_pdta\cpf\02cpf-log"
	
	* globals identifying last wave in surveys

	global surveys "hilda ukhls"
	global hilda_w 		"19"		// version of HILDA, number of waves
	global ukhls_w		"10"		// version, number of UKHLS waves
	
	* globals for accessing specific parts of data
	
	global ukhls_data 	"UKDA-6614-stata\stata\stata13_se"
	
* define survey specific input and output macros

	* input folders
	
		* HILDA
		
		global hilda_in 	"${wdir}\2_rdta\\${hilda}"		

		* BHPS
		
		global ukhls_in 	"${wdir}\2_rdta\\${ukhls}\\${ukhls_data}"	  

	* output folders
	
		* for CPF-country data
		
		foreach surv in hilda ukhls {
			global `surv'_out "${Gcpf_out}\\${`surv'}_cpf"		 
			global `surv'_out_work "${`surv'_out}\temp"
		}

/*------------------------------------------------------------------------------
#6 Run country specific do-files, append & label dataset
------------------------------------------------------------------------------*/

/// ------ Project-Do-Files *

do "$cpf_in/01cr-cpf-hilda.do"   // Creates hilda extract to integrate in CPF file
do "$cpf_in/02cr-cpf-bhps.do"    // Creates bhps extract to integrate in CPF file
do "$cpf_in/03cr-cpf-andata.do"	// Appends all countries and labels data

*==============================================================================*

* display running time

scalar endtime = c(current_time)

display ((round(clock(endtime, "hms") - clock(starttime, "hms"))) / 60000) " minutes"

*==============================================================================*
