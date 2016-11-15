* This dofile identifies the top n-grams in terms of lifetime mentions within each vintage
* It also identifies all of the PMIDs that use these top n-grams

**************************************************************************************************
**************************************************************************************************
* User must set the outpath and the inpath.
global inpath="D:\Research\RAWDATA\MEDLINE\2016\Processed"
global outpath="D:\Research\RAWDATA\MEDLINE\2016\Processed"
**************************************************************************************************

clear
cd $inpath
use medline16_ngrams_mentions, replace

cd $inpath
merge 1:1 ngramid using medline16_ngrams_vintage
drop _merge

* Sort the top ngrams within each vintage
gsort vintage -mentions_bt ngram
by vintage, sort: gen rank_=_n
by vintage mentions_bt, sort: egen rank=min(rank_)
by vintage, sort: gen total=_N
gen pct=rank/total
gen top_001 = (pct<0.001)
gen top_0001 = (pct<0.0001)

sort vintage ngramid
order ngramid vintage

compress
cd $outpath
save medline16_ngrams_rank, replace
************************************************************************************
*************************************************************************************
