# Changes in fruit and vegetable consumption during the transition to parenthood: longitudinal evidence from Australia and the United Kingdom

## Abstract

Background: Families are an important context for healthy eating. This longitudinal study investigates how becoming a parent affects the fruit and vegetable consumption of men and women.

Methods: This study uses two harmonized nationally representative longitudinal household surveys for Australia (N = 2,288 women and 2,479 men) and the United Kingdom (N = 5,424 women and 4,275 men) with data collected between 2007 and 2018. Changes in fruit and vegetable consumption are studied from three and more years before the birth of the first child until 6 years and more after birth using a difference-in-difference design.

Results: The transition to parenthood increases the fruit and vegetable consumption in Australia with a significant increase in the proportion of men and women consuming at least one portion of fruit or vegetables per day. While for Australian mothers, this change is visible already 1–2 years before birth, for fathers the change occurs postnatally. The effect extends over several years after birth. For Australian mothers, the increase is due exclusively to an increase in the consumption of fruit, while for men small effects are found for both fruits and vegetables. Additionally, the increase in fruit and vegetable consumption is more pronounced among highly educated parents. There are no significant changes in the daily consumption of fruit and vegetables with parenthood in the United Kingdom.

Conclusion: Individuals’ fruit and vegetable consumption is not strongly affected by becoming a parent. When it is, the effect is positive for both men and women, and greater for those with higher levels of education. Differences between countries indicate the importance of cultural contexts in the influence of parenthood on diet.

----

The paper by Munschek, S.; Linden, P. & Reibling, N. with the DOI: 10.3389/fpubh.2025.1673209 is available [here](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1673209/full). If you have any questions, please send an E-Mail to [Nadine Reibling](mailto:nadine.reibling@gw.hs-fulda.de).

----

### History

`2026-01-20`
:  Setup

---

### Directories

`\1_scripts`
:  scripts for replicating the analysis <br />
- `\cpf` : CPF data  <br />
- `\di` : Diet data
	
`\2_rdta`
: folder for raw data

`\3_pdta`
: processed data

`\4_output`
: output (logs, tables & figures)

---

### Description

This repository contains the code for the analysis in the paper entitled "Changes in fruit and vegetable consumption during the transition to parenthood: longitudinal evidence from Australia and the United Kingdom" which is published under open access in [Frontiers in public health, section public health and nutrition(https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1673209/full).

The data for this analysis comes from harmonized data from two longitudinal household surveys: the Household, Income and Labour Dynamics [HILDA](https://melbourneinstitute.unimelb.edu.au/hilda) for Australia & the British Household Panel Survey [BHPS](https://www.understandingsociety.ac.uk/about/british-household-panel-survey/) for the United Kingdom. Harmonization of covariates was achieved by adapting procedures from [Turek et al. 2021](https://academic.oup.com/esr/article/37/3/505/6168670). Please refer to the [CPF project](https://cpfdata.com/) for details. After harmonization and preparation of the data sets, we were able to analyze a sample of N=34,867 person-years over a time period from 2007-2018 (11 years).

---

### Replication instruction

All analysis were done in Stata 16 and under Windows 11. Please follow the steps listed below to reproduce findings:

1. Fork the repository / Sync fork if necessary
2. Open the file 00cr-cpf-master.do in 1_scripts\cpf to construct the CPF file for harmonized covariates over the four countries. Within the file note that you need to insert the raw data sets (see next step).
3. Since the data sets are not publicly accessible, we cannot provide data files within this repository. To access the data, you must register on the homepage of the data hosting institutions and/or complete a data use agreement. Please note also that the data used in this analysis refers to specific file versions:
	- HILDA: The Household, Income and Labour Dynamics in Australia (HILDA) Survey, GENERAL RELEASE 21 (Waves 1-21) DOI: 10.26193/KXNEBO
	- BHPS: British Household Panel Survey (BHPS), Understanding Society: Waves 1-15, 2009-2024 and Harmonised BHPS: Waves 1-18, 1991-2009 DOI: 10.5255/UKDA-SN-6614-20 
Practical information on accessing the data and storing it on your personal storage device can be found in the Master-Do file under section #4.
4. After setting up the raw data, run the rest of the CPF master do-File. You should now have created a CPF dataset (CPF-di.dta) with harmonized covariates within the folder 3_pdta\cpf\01cpf-out.
5. Run the file 00master-ph-exercise-com in 1_scripts\pa to construct and analyze the harmonized dataset. All log-files, tables and figures should then be available in the output folder.

Please mail to [Linden Research](mailto:research@linden-online.com) if anything is not working properly.

