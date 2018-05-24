
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_issn.txt", clear delimiter(tab) varnames(1)
keep pmid version issn issnl
tempfile hold
save `hold', replace

use `hold', clear
drop issn
rename issnl issn
append using `hold'
drop issnl
duplicates drop
sort pmid version issn
compress
tempfile hold
save `hold', replace

cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
merge 1:m pmid version using `hold'
drop _merge

keep nlmid issn
duplicates drop
drop if issn=="null"

sort nlmid
compress
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
save medline16_nlmid_issn_xwalk, replace
