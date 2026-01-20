/*==============================================================================
File:         	00master-ph-diet-com.do
Task:         	Sets up and executes analyses
Project:      	Parenthood and diet
Author(s):		Munschek & Linden
Last update:  	2026-01-14
Run time:		Approximately XXX
==============================================================================*/

/*------------------------------------------------------------------------------ 
Content:

#1 Installs ado files used in the analysis
#2 Stata Settings
#3 Defines globals
#4 Create working directories & define globals (diet data)
#5 Specifies order and task of code files and runs them
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Notes:
 
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
#1 Install ado files                                                         
------------------------------------------------------------------------------*/

*ssc install blindschemes, replace // Color scheme for plots
*ssc install estout, replace       // Formatting and exporting tables
*ssc install coefplot, replace     // Formatting and exporting output as plot

/*------------------------------------------------------------------------------
#2 Stata settings
------------------------------------------------------------------------------*/

version 16.1          // Stata version control
clear all             // clear memory
macro drop _all       // delete all macros
set linesize 82       // result window has room for 82 chars in one line
set more off, perm    // prevents pause in results window
set scheme plotplain  // sets color scheme for graphs
set maxvar 32767      // size of data matrix

/*------------------------------------------------------------------------------
#3 Define globals 
------------------------------------------------------------------------------*/

* project stamp

global ps "-ph-diet-com"

* working directory 

* -> Retrieve c(username) by typing disp "`c(username)'" in command line

if "`c(username)'" == "[YOUR USER NAME]" {
	global wdir "[PATH WHERE REPO IS SAVED]"
}

if "`c(username)'" == "[YOUR USER NAME]" {
	global wdir "[PATH WHERE REPO IS SAVED]\2_rdta"
}

/*------------------------------------------------------------------------------
#4 Create working directories & define globals (diet data)
------------------------------------------------------------------------------*/

* create pa folder name

global di "di"
global di_fold  $di

* create pa folder

foreach di of global di_fold {
	capture mkdir "${wdir}\3_pdta\\`di'"
}

* subdirectories

global pdta  "$wdir/3_pdta/di"      	// processed data
global code  "$wdir/1_scripts/di"       // code files
global plot  "$wdir/4_output/fig"       // figures
global text  "$wdir/4_output/tab"       // logfiles + tables

/*------------------------------------------------------------------------------
#5 Specify name, task and sequence of code files to run
------------------------------------------------------------------------------*/

/// ------ Projekt-Do-Files *

do "$code/01cr-hilda$ps.do"    		// Extracts diet variables from HILDA
do "$code/02cr-ukhls$ps.do"    		// Extracts diet variables from UKHLS
do "$code/03cr-andata$ps.do"    		// Combines single country data sets
do "$code/04cr-desmod$ps.do"   		// Descriptive analysis
do "$code/05cr-effmod$ps.do"    		// Treatment effect analysis

*==============================================================================*