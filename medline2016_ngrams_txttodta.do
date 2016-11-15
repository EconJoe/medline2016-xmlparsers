
local startfile=1
local endfile=812

clear
set more off
forvalues i=`startfile'/`endfile' {

	display in red "------ File `i' --------"

	cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams
	import delimited "medline16_`i'_ngrams.txt", clear delimiter(tab) varnames(1) bindquotes(nobind)
	
	compress
	cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles
	save medline16_`i'_ngrams.dta, replace
}
