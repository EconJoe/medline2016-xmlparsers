
* This dofile identifies the top n-grams in terms of lifetime mentions within each vintage
* It also identifies all of the PMIDs that use these top n-grams

**************************************************************************************************
**************************************************************************************************
* User must set the outpath and the inpath.
global inpath1="D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles"
global inpath2="D:\Research\RAWDATA\MEDLINE\2016\Processed"
global outpath="D:\Research\RAWDATA\MEDLINE\2016\Processed"
**************************************************************************************************

clear
cd $inpath2
use medline16_ngrams_rank, clear

cd $inpath2
merge 1:1 ngramid using medline16_ngrams_id
drop _merge
keep if top_001==1

* Give each ngram a numeric identifier. This dramatically decreases storage requirements
sort vintage ngram
order ngramid ngram

compress
cd $outpath
save medline16_ngrams_top, replace
************************************************************************************
*************************************************************************************

************************************************************************************
*************************************************************************************
clear
gen filenum=.
cd $outpath
save medline16_ngrams_top_pmids_001, replace

local initialfiles 1 101 201 301 401 501 601 701 801
local terminalfile=812
local fileinc=99

clear
set more off
foreach h in `initialfiles' {

	local startfile=`h'
	local endfile=`startfile'+`fileinc'
	if (`endfile'>`terminalfile') {
		local endfile=`terminalfile'
	}
	
	clear
	set more off
	gen ngramid=.
	cd $outpath
	save medline16_ngrams_top_pmids_001_`startfile'_`endfile', replace

	forvalues i=`startfile'/`endfile' {

		display in red "------ File `i' --------"

		cd $inpath1
		use medline16_`i'_ngrams, clear
		keep filenum pmid version ngram
		cd $outpath
		merge m:1 ngram using medline16_ngrams_top
		keep if _merge==3
		keep filenum pmid version ngramid vintage
		
		if (_N>0) {
			compress
			duplicates drop

			cd $outpath
			append using medline16_ngrams_top_pmids_001_`startfile'_`endfile'
			save medline16_ngrams_top_pmids_001_`startfile'_`endfile', replace
		}
	}
	
	cd $outpath
	use medline16_ngrams_top_pmids_001, clear
	append using medline16_ngrams_top_pmids_001_`startfile'_`endfile'
	compress
	sort ngram
	save medline16_ngrams_top_pmids_001, replace
	erase medline16_ngrams_top_pmids_001_`startfile'_`endfile'.dta
}
