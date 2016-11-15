
* This dofile computes the total number of times that each n-gram in the MEDLINE 2016 corpus is mentioned.

**************************************************************************************************
**************************************************************************************************
* User must set the outpath and the inpath.
global inpath1="D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles"
global inpath2="D:\Research\RAWDATA\MEDLINE\2016\Processed"
global outpath="D:\Research\RAWDATA\MEDLINE\2016\Processed"
**************************************************************************************************

clear
gen ngram=""
cd $outpath
save medline16_ngrams_vintage, replace

* Break the files that we work with into multiples of 50. This prevents RAM from being exhausted.
local initialfiles 1 26 51 76 101 126 151 176 201 226 251 276 301 326 351 376 401 426 451 476 501 526 551 576 601 626 651 676 701 726 751 776 801
local terminalfile=812
local fileinc=24

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
	gen ngram=""
	cd $outpath
	save medline16_ngrams_vintage_`startfile'_`endfile', replace

	forvalues i=`startfile'/`endfile' {

		display in red "------ File `i' --------"
		
		cd $inpath2
		use medline16_dates_clean if filenum==`i', clear
		keep pmid version year
		cd $inpath1
		merge 1:m pmid version using medline16_`i'_ngrams
		rename year vintage
		* Keep only first version to avoid double coutning. This affects very few articles.
		*keep if version==1
		* Drop if there was no n-gram
		drop if dim=="null"
		
		if (_N>0) {
		
			collapse (min) vintage, by(ngram) fast
			compress
			cd $outpath
			append using medline16_ngrams_vintage_`startfile'_`endfile'
			collapse (min) vintage, by(ngram) fast
			save medline16_ngrams_vintage_`startfile'_`endfile', replace
		}
	}
	
	cd $outpath
	append using medline16_ngrams_vintage
	collapse (min) vintage, by(ngram) fast
	save medline16_ngrams_vintage, replace
	erase medline16_ngrams_vintage_`startfile'_`endfile'.dta
}

cd $outpath
use medline16_ngrams_vintage, clear
drop if ngram==""
merge 1:1 ngram using medline16_ngrams_id
drop _merge
drop ngram
sort vintage ngramid
compress
save medline16_ngrams_vintage, replace
