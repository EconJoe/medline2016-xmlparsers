
* This dofile computes the total number of times that each n-gram in the MEDLINE 2016 corpus is mentioned.

**************************************************************************************************
**************************************************************************************************
* User must set the outpath and the inpath.
global inpath="D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles"
global outpath="D:\Research\RAWDATA\MEDLINE\2016\Processed"
**************************************************************************************************

clear
gen ngram=""
cd $outpath
save medline16_ngrams_mentions, replace

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
	save medline16_ngrams_mentions_`startfile'_`endfile', replace

	forvalues i=`startfile'/`endfile' {

		display in red "------ File `i' --------"
		
		cd $inpath
		use medline16_`i'_ngrams, clear
		drop if dim=="null"
		
		if (_N>0) {
		
			* Compute the number of "within" mentions. These are mentions that include multiple mentions within the same article.
			gen mentions_wi=1
			collapse (sum) mentions_wi, by(pmid ngram) fast
			
			* Compute the number of "between" mentions. These are mentions that only count at most one mention per article.
			gen mentions_bt=1
			collapse (sum) mentions_wi mentions_bt, by(ngram) fast
			
			cd $outpath
			append using medline16_ngrams_mentions_`startfile'_`endfile'
			collapse (sum) mentions_wi mentions_bt, by(ngram) fast
			save medline16_ngrams_mentions_`startfile'_`endfile', replace
		}
	}
	cd $outpath
	append using medline16_ngrams_mentions
	collapse (sum) mentions_wi mentions_bt, by(ngram) fast
	save medline16_ngrams_mentions, replace
	erase medline16_ngrams_mentions_`startfile'_`endfile'.dta
}

merge 1:1 ngram using medline16_ngrams_id
drop _merge
drop ngram
order ngramid
sort ngramid
compress
save medline16_ngrams_mentions, replace
