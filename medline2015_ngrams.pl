#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;
use Lingua::Stem;

#$outpath="/disk/homedirs/nber/staudt/bulk/SciLaborSupply/NGrams_2015";
$outpath="B:\\Research\\SLS2\\Processed\\Medline2015\\NGrams_2015_3";

#$inpath="/disk/homedirs/nber/staudt/bulk/Medline2015"
$inpath="B:\\Research\\Medline2015\\zip";

#665-720
  #707-713***
  #714-720
#721-779
   #745-760
   #761-779

$medlineversion=15;
$startfile=714; $endfile=720;
for ($filenum=$startfile; $filenum<=$endfile; $filenum++) {

    # Create output file (replace if file already exists)
    #open (OUTFILE, ">:utf8", "$outpath/medline15\_$filenum\_ngrams.txt") or die "Can't open subjects file: medline15\_$filenum\_ngrams.txt";
    open (OUTFILE, ">:utf8", "$outpath\\medline15\_$filenum\_ngrams.txt") or die "Can't open subjects file: medline15\_$filenum\_ngrams.txt";

    # Print basic article-level elements
    print OUTFILE "filenum	recordnum	owner	status	versionid	versiondate	pmid	version	";

    # Print elements common to both titles and abstracts
    print OUTFILE "ngram	dim	source	ngramnum	wordcount	";

    # Print elements only belonging to titles
    print OUTFILE "translated	inprocess	";

    # Print elements only belonging to abstracts
    print OUTFILE "form	label	nlmcategory	type	language	truncated\n";

    # Read in MEDLINE XML file
    print "Reading in file: medline15n0$filenum.xml\n";
    &importfile;

    $recordnum=0;
    foreach $i (@{$data->{MedlineCitation}}) {

            $recordnum++;
            print "Processing record $recordnum in file medline15n0$filenum.xml\n";

            &extract;
            &processtitle;
            &processabstract;
    }
    
    # Close output file
    close OUTFILE;

    # this "dumps" the XML file out of memory
    $data=0;
}

#sub importfile {
#
#    if ($filenum<10) { $data = XMLin("$path/Medline2015/medline15n000$filenum.xml", ForceArray => 1);}
#     if($filenum>=10 && $filenum<=99) { $data = XMLin("$path/Medline2015/medline15n00$filenum.xml", ForceArray => 1); }
#     if($filenum>=100 && $filenum<=779) { $data = XMLin("$path/Medline2015/medline15n0$filenum.xml", ForceArray => 1); }
#}

sub importfile {

     if ($filenum<10) { $data = XMLin("$inpath\\medline15n000$filenum.xml", ForceArray => 1);}
     if($filenum>=10 && $filenum<=99) { $data = XMLin("$inpath\\medline15n00$filenum.xml", ForceArray => 1); }
     if($filenum>=100 && $filenum<=779) { $data = XMLin("$inpath\\medline15n0$filenum.xml", ForceArray => 1); }
}

sub extract {

    # Access the four elements of <MedlineCitation>: <Owner>, <Status>, <VersionID>, and <VersionDate>
    $owner = "$i->{Owner}";
    $status = "$i->{Status}";
    $versionid = "$i->{VersionID}";
    $versiondate = "$i->{VersionDate}";
    # Assign the value "null" to any missing element
    if ($owner eq "") { $owner = "null"; }
    if ($status eq "") { $status = "null"; }
    if ($versionid eq "") { $versionid = "null"; }
    if ($versiondate eq "") { $versiondate = "null"; }
    
    # Accesss the PubMed ID and the version
    @pmid = @{$i->{PMID}};
    foreach $j (@pmid) { $pmid = "$j->{content}"; $version = "$j->{Version}"; }
    
    # Assign the value "null" to any missing element
    if ($pmid eq "") { $pmid = "null"; }
    if ($version eq "") { $version = "null"; }
    
    # Accesss OtherAbstract element (if it exists)
    @otherabstract = @{$i->{OtherAbstract}};
    $otherabstractsize=@otherabstract;
    
    # Accesss Abstract and Article Title elements (if they exist) using the Article element
    @article = @{$i->{Article}};
    foreach $j (@article) { @abstract = @{$j->{Abstract}}; $abstractsize=@abstract; }
    foreach $j (@article) { @title = @{$j->{ArticleTitle}}; $titlesize=@title; }

}

sub processtitle {
  
    # Test whether there is more than one title element. If so, terminate.
    if ($titlesize>1) {
       die "There is more than one title for record with PMID: $pmid !!!\n";
    }

    # Test whether a title exists for the record
    if ($titlesize==0) {
      
       # Assign all "null" values to characteristics common to titles and abstracts
       $ngram="null"; $dim="null"; $source="title"; $ngramnum="null"; $wordcount="null";

       # Assign all "null" values to title-only characteristics
       $translated="null"; $inprocess="null";
       
       # Assign all "na" values to abstract-only characteristics
       $form="na"; $label="na"; $nlmcategory="na"; $type="na"; $language="na"; $truncated="na";
       
       # Print output
       print OUTFILE "$filenum	$recordnum	$owner	$status	$versionid	$versiondate	$pmid	$version	";
       print OUTFILE "$ngram	$dim	$source	$ngramnum	$wordcount	";
       print OUTFILE "$translated	$inprocess	";
       print OUTFILE "$form	$label	$nlmcategory	$type	$language	$truncated\n";
    }
    
    # If a title does exist and is unique, continue on!!
    if ($titlesize==1) {

       # Bring title into content string
       $content=$title[0];

       # Determine if the title was translated.
       $translated="N";
       if ($content=~/^\[(.*)/) { $translated="Y"; }
       
       # Determine if the title is in the process of being translated.
       $inprocess="N";
       if ($content=~/^\[In Process Citation\]\.$/) { $inprocess="Y"; }
       
       $source="title";
       
       # Assign all "na" values to abstract-only characteristics
       $form="na"; $label="na"; $nlmcategory="na"; $type="na"; $language="na"; $truncated="na";

       &cleanandoutput;
}


sub processabstract {

    # Test whether an abstract exists for the record
    if ($abstractsize==0 & $otherabstractsize==0) {

       # Assign all "null" values to characteristics common to titles and abstracts
       $ngram="null"; $dim="null"; $source="abstract"; $ngramnum="null"; $wordcount="null";
       
       # Assign all "na" values to title-only characteristics
       $translated="na"; $inprocess="na";
       
       # Assign all "null" values to abstract-only characteristics
       $form="null"; $label="null"; $nlmcategory="null"; $type="null"; $language="null"; $truncated="null";

       # Print output
       print OUTFILE "$filenum	$recordnum	$owner	$status	$versionid	$versiondate	$pmid	$version	";
       print OUTFILE "$ngram	$dim	$source	$ngramnum	$wordcount	";
       print OUTFILE "$translated	$inprocess	";
       print OUTFILE "$form	$label	$nlmcategory	$type	$language	$truncated\n";
    }

    # If an abstract does exist, continue on!!
    else {

         if ($otherabstractsize>0) {

            foreach $k (@otherabstract) {
                    @abstracttext = @{$k->{AbstractText}};
                    $abstracttextsize=@abstracttext;

                            # Bring abstract into content string
                            $content=$abstracttext[0];
                            
                            $source="abstract";

                            # Assign all "na" values to title-only characteristics
                            $translated="na"; $inprocess="na";

                            # Assign proper values to abstract-only characteristics
                            $form = "Other";
                            $label="null";
                            $nlmcategory="null";
                            $type = "$k->{Type}";
                            $language = "$k->{Language}";
                            
                            # Test if the abstract is truncated
                            $truncated="No";
                            if ($content =~/ABSTRACT TRUNCATED/) { $truncated="Yes"; }
                            if ($content =~/ABSTRACT TRUNCATED AT 400 WORDS/) { $truncted="Yes: 400"; }
                            if ($content =~/ABSTRACT TRUNCATED AT 250 WORDS/) { $truncated="Yes: 250"; }

                            &cleanandoutput;
           }
         }

         if ($abstractsize>0) {

            foreach $k (@abstract) {
                    @abstracttext = @{$k->{AbstractText}};
                    $abstracttextsize=@abstracttext;
                    
                     $source="abstract";

                    # Assign all "na" values to title-only characteristics
                    $translated="na"; $inprocess="na";

                           if ($abstracttextsize>0) {

                              foreach $l (@abstracttext) {

                                       $label = "$l->{Label}";
                                       $nlmcategory = "$l->{NlmCategory}";
                                       $type = "null";
                                       $language = "null";
                                       
                                       if ($label eq "" & $nlmcategory eq "") {
                                         $form = "Normal";
                                         $label = "null";
                                         $nlmcategory = "null";
                                         $type = "null";
                                         $language = "null";
                                         $content = $abstracttext[0];

                                         # Test if the abstract is truncated
                                         $truncated="No";
                                         if ($content =~/ABSTRACT TRUNCATED/) { $truncated="Yes"; }
                                         if ($content =~/ABSTRACT TRUNCATED AT 400 WORDS/) { $truncted="Yes: 400"; }
                                         if ($content =~/ABSTRACT TRUNCATED AT 250 WORDS/) { $truncated="Yes: 250"; }

                                         &cleanandoutput;
                                       }
                                       
                                       if ($label ne "" | $nlmcategory ne "") {
                                         $form = "Structured";
                                         $type = "null";
                                         $language = "null";
                                         $content = "$l->{content}";
                                         
                                         # Test if the abstract is truncated
                                         $truncated="No";
                                         if ($content =~/ABSTRACT TRUNCATED/) { $truncated="Yes"; }
                                         if ($content =~/ABSTRACT TRUNCATED AT 400 WORDS/) { $truncted="Yes: 400"; }
                                         if ($content =~/ABSTRACT TRUNCATED AT 250 WORDS/) { $truncated="Yes: 250"; }

                                         &cleanandoutput;
                                       }
                               }
                            }
                       }
                    }
            }
    }
}


sub cleanandoutput {

     @content = $content =~ /(.*?) /g;
     if ($content=~/(.*) (.*)/) { $contentlast=$2; }
     push (@content, $contentlast); $contentsize=@content;
     $wordcount=$contentsize;

     # Extract 1-grams
     @dim=(1, 2, 3);
     foreach $m (@dim) {
             for($n=0; $n<=$contentsize-$m; $n++) {
                       $dim="$m\d";
                       &clean;
                       $ngramnum=$n+1;
    
                       if ($ngram ne "DROPTHISNGRAM") {
                         print OUTFILE "$filenum	$recordnum	$owner	$status	$versionid	$versiondate	$pmid	$version	";
                         print OUTFILE "$ngram	$dim	$source	$ngramnum	$wordcount	";
                         print OUTFILE "$translated	$inprocess	";
                         print OUTFILE "$form	$label	$nlmcategory	$type	$language	$truncated\n";
                       }
            }
     }
}


sub clean {

    if ($dim=="1d") { $ngram="$content[$n]"; }
    if ($dim=="2d") { $ngram="$content[$n] $content[$n+1]"; }
    if ($dim=="3d") { $ngram="$content[$n] $content[$n+1] $content[$n+2]"; }

    # Replace with lower-case
    $ngram=lc($ngram);

    #Delete observations that cross commas, periods, etc.
    if ($ngram =~ /(.*)\, (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\. (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\? (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\! (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\; (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\: (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\) (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*) \((.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\} (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*) \{(.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)\] (.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*) \[(.*)/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram =~ /(.*)(--+)(.*)/) { $ngram="DROPTHISNGRAM"; }

    #  Keep only alpha-numeric characters and spaces
    $ngram =~ tr/0-9a-zA-Z //dc;

    # Drop n-grams with the following stop words: http://mbr.nlm.nih.gov/Download/2009/WordCounts/wrd_stop
    &stopwords;

    # Stem and tokenize
    if ($ngram ne "DROPTHISNGRAM") {
      @tokens = split(/ /,$ngram);
      $stemmer = Lingua::Stem->new();
      $stems = $stemmer->stem(@tokens);
      @ngram=(@$stems);

      if ($dim=="1d") { $ngram="$ngram[0]"; }
      if ($dim=="2d") { $ngram="$ngram[0] $ngram[1]"; }
      if ($dim=="3d") { $ngram="$ngram[0] $ngram[1] $ngram[2]"; }
    }

    # Drop n-grams with the following stop words: http://mbr.nlm.nih.gov/Download/2009/WordCounts/wrd_stop
    &stopwords;

    # Drop all n-grams with the following character sequences
    if ($ngram=~/^web$/ | $ngram=~/^web / | $ngram=~/ web$/ | $ngram=~/ web /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/www/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/http/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/pubmed/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/medline/) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/clinicaltrialsgov/) { $ngram="DROPTHISNGRAM"; }

    # Drop all observations with two or more consecutive numbers
    if ($ngram =~ /[0-9][0-9]+/) { $ngram="DROPTHISNGRAM"; }

    # Impose length restrictions
    $ngramlength=length($ngram);
    if ($ngramlength<3) { $ngram="DROPTHISNGRAM"; }
    if (($ngramlength<3 | $ngramlength>29) & $dim=="1d" ) { $ngram="DROPTHISNGRAM"; }
    if (($ngramlength<7 | $ngramlength>59) & $dim=="2d") { $ngram="DROPTHISNGRAM"; }
    if (($ngramlength<11 | $ngramlength>89) & $dim=="3d") { $ngram="DROPTHISNGRAM"; }

    # Remove white space from both ends of a string
    $ngram =~ s/^\s+|\s+$//g;
}

sub stopwords {
  
    # Drop n-grams with the following stop words: http://mbr.nlm.nih.gov/Download/2009/WordCounts/wrd_stop
    if ($ngram=~/^a$/ | $ngram=~/^a / | $ngram=~/ a$/ | $ngram=~/ a /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^about$/ | $ngram=~/^about / | $ngram=~/ about$/ | $ngram=~/ about /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^above$/ | $ngram=~/^above / | $ngram=~/ above$/ | $ngram=~/ above /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^across$/ | $ngram=~/^across / | $ngram=~/ across$/ | $ngram=~/ across /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^after$/ | $ngram=~/^after / | $ngram=~/ after$/ | $ngram=~/ after /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^afterwards$/ | $ngram=~/^afterwards / | $ngram=~/ afterwards$/ | $ngram=~/ afterwards /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^again$/ | $ngram=~/^again / | $ngram=~/ again$/ | $ngram=~/ again /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^against$/ | $ngram=~/^against / | $ngram=~/ against$/ | $ngram=~/ against /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^al $/ | $ngram=~/^al / | $ngram=~/ al$/ | $ngram=~/ al /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^all$/ | $ngram=~/^all / | $ngram=~/ all$/ | $ngram=~/ all /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^almost$/ | $ngram=~/^almost / | $ngram=~/ almost$/ | $ngram=~/ almost /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^alone$/ | $ngram=~/^alone / | $ngram=~/ alone$/ | $ngram=~/ alone /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^along$/ | $ngram=~/^along / | $ngram=~/ along$/ | $ngram=~/ along /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^already$/ | $ngram=~/^already / | $ngram=~/ already$/ | $ngram=~/ already /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^also$/ | $ngram=~/^also / | $ngram=~/ also$/ | $ngram=~/ also /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^although$/ | $ngram=~/^although / | $ngram=~/ although$/ | $ngram=~/ although /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^always$/ | $ngram=~/^always / | $ngram=~/ always$/ | $ngram=~/ always /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^am$/ | $ngram=~/^am / | $ngram=~/ am$/ | $ngram=~/ am /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^among$/ | $ngram=~/^among / | $ngram=~/ among$/ | $ngram=~/ among /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^amongst$/ | $ngram=~/^amongst / | $ngram=~/ amongst$/ | $ngram=~/ amongst /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^an$/ | $ngram=~/^an / | $ngram=~/ an$/ | $ngram=~/ an /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^analyze$/ | $ngram=~/^analyze / | $ngram=~/ analyze$/ | $ngram=~/ analyze /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^and$/ | $ngram=~/^and / | $ngram=~/ and$/ | $ngram=~/ and /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^another$/ | $ngram=~/^another / | $ngram=~/ another$/ | $ngram=~/ another /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^any$/ | $ngram=~/^any / | $ngram=~/ any$/ | $ngram=~/ any /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^anyhow$/ | $ngram=~/^anyhow / | $ngram=~/ anyhow$/ | $ngram=~/ anyhow /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^anyone$/ | $ngram=~/^anyone / | $ngram=~/ anyone$/ | $ngram=~/ anyone /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^anything$/ | $ngram=~/^anything / | $ngram=~/ anything$/ | $ngram=~/ anything /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^anywhere$/ | $ngram=~/^anywhere / | $ngram=~/ anywhere$/ | $ngram=~/ anywhere /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^applicable$/ | $ngram=~/^applicable / | $ngram=~/ applicable$/ | $ngram=~/ applicable /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^apply$/ | $ngram=~/^apply / | $ngram=~/ apply$/ | $ngram=~/ apply /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^are$/ | $ngram=~/^are / | $ngram=~/ are$/ | $ngram=~/ are /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^around$/ | $ngram=~/^around / | $ngram=~/ around$/ | $ngram=~/ around /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^as$/ | $ngram=~/^as / | $ngram=~/ as$/ | $ngram=~/ as /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^assume$/ | $ngram=~/^assume / | $ngram=~/ assume$/ | $ngram=~/ assume /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^at$/ | $ngram=~/^at / | $ngram=~/ at$/ | $ngram=~/ at /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^be$/ | $ngram=~/^be / | $ngram=~/ be$/ | $ngram=~/ be /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^became$/ | $ngram=~/^became / | $ngram=~/ became$/ | $ngram=~/ became /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^because$/ | $ngram=~/^because / | $ngram=~/ because$/ | $ngram=~/ because /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^become$/ | $ngram=~/^become / | $ngram=~/ become$/ | $ngram=~/ become /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^becomes$/ | $ngram=~/^becomes / | $ngram=~/ becomes$/ | $ngram=~/ becomes /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^becoming$/ | $ngram=~/^becoming / | $ngram=~/ becoming$/ | $ngram=~/ becoming /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^been$/ | $ngram=~/^been / | $ngram=~/ been$/ | $ngram=~/ been /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^before$/ | $ngram=~/^before / | $ngram=~/ before$/ | $ngram=~/ before /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^beforehand$/ | $ngram=~/^beforehand / | $ngram=~/ beforehand$/ | $ngram=~/ beforehand /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^being$/ | $ngram=~/^being / | $ngram=~/ being$/ | $ngram=~/ being /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^below$/ | $ngram=~/^below / | $ngram=~/ below$/ | $ngram=~/ below /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^beside$/ | $ngram=~/^beside / | $ngram=~/ beside$/ | $ngram=~/ beside /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^besides$/ | $ngram=~/^besides / | $ngram=~/ besides$/ | $ngram=~/ besides /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^between$/ | $ngram=~/^between / | $ngram=~/ between$/ | $ngram=~/ between /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^beyond$/ | $ngram=~/^beyond / | $ngram=~/ beyond$/ | $ngram=~/ beyond /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^both$/ | $ngram=~/^both / | $ngram=~/ both$/ | $ngram=~/ both /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^but$/ | $ngram=~/^but / | $ngram=~/ but$/ | $ngram=~/ but /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^by$/ | $ngram=~/^by / | $ngram=~/ by$/ | $ngram=~/ by /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^came$/ | $ngram=~/^came / | $ngram=~/ came$/ | $ngram=~/ came /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^cannot$/ | $ngram=~/^cannot / | $ngram=~/ cannot$/ | $ngram=~/ cannot /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^cc$/ | $ngram=~/^cc / | $ngram=~/ cc$/ | $ngram=~/ cc /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^cm$/ | $ngram=~/^cm / | $ngram=~/ cm$/ | $ngram=~/ cm /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^come$/ | $ngram=~/^come / | $ngram=~/ come$/ | $ngram=~/ come /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^compare$/ | $ngram=~/^compare / | $ngram=~/ compare$/ | $ngram=~/ compare /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^could$/ | $ngram=~/^could / | $ngram=~/ could$/ | $ngram=~/ could /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^de$/ | $ngram=~/^de / | $ngram=~/ de$/ | $ngram=~/ de /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^dealing$/ | $ngram=~/^dealing / | $ngram=~/ dealing$/ | $ngram=~/ dealing /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^department$/ | $ngram=~/^department / | $ngram=~/ department$/ | $ngram=~/ department /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^depend$/ | $ngram=~/^depend / | $ngram=~/ depend$/ | $ngram=~/ depend /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^did$/ | $ngram=~/^did / | $ngram=~/ did$/ | $ngram=~/ did /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^discover$/ | $ngram=~/^discover / | $ngram=~/ discover$/ | $ngram=~/ discover /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^dl$/ | $ngram=~/^dl / | $ngram=~/ dl$/ | $ngram=~/ dl /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^do$/ | $ngram=~/^do / | $ngram=~/ do$/ | $ngram=~/ do /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^does$/ | $ngram=~/^does / | $ngram=~/ does$/ | $ngram=~/ does /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^during$/ | $ngram=~/^during / | $ngram=~/ during$/ | $ngram=~/ during /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^each$/ | $ngram=~/^each / | $ngram=~/ each$/ | $ngram=~/ each /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ec$/ | $ngram=~/^ec / | $ngram=~/ ec$/ | $ngram=~/ ec /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ed$/ | $ngram=~/^ed / | $ngram=~/ ed$/ | $ngram=~/ ed /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^effected$/ | $ngram=~/^effected / | $ngram=~/ effected$/ | $ngram=~/ effected /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^eg$/ | $ngram=~/^eg / | $ngram=~/ eg$/ | $ngram=~/ eg /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^either$/ | $ngram=~/^either / | $ngram=~/ either$/ | $ngram=~/ either /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^else$/ | $ngram=~/^else / | $ngram=~/ else$/ | $ngram=~/ else /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^elsewhere$/ | $ngram=~/^elsewhere / | $ngram=~/ elsewhere$/ | $ngram=~/ elsewhere /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^enough$/ | $ngram=~/^enough / | $ngram=~/ enough$/ | $ngram=~/ enough /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^et$/ | $ngram=~/^et / | $ngram=~/ et$/ | $ngram=~/ et /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^etc$/ | $ngram=~/^etc / | $ngram=~/ etc$/ | $ngram=~/ etc /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ever$/ | $ngram=~/^ever / | $ngram=~/ ever$/ | $ngram=~/ ever /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^every$/ | $ngram=~/^every / | $ngram=~/ every$/ | $ngram=~/ every /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^everyone$/ | $ngram=~/^everyone / | $ngram=~/ everyone$/ | $ngram=~/ everyone /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^everything$/ | $ngram=~/^everything / | $ngram=~/ everything$/ | $ngram=~/ everything /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^everywhere$/ | $ngram=~/^everywhere / | $ngram=~/ everywhere$/ | $ngram=~/ everywhere /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^except$/ | $ngram=~/^except / | $ngram=~/ except$/ | $ngram=~/ except /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^find$/ | $ngram=~/^find / | $ngram=~/ find$/ | $ngram=~/ find /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^for$/ | $ngram=~/^for / | $ngram=~/ for$/ | $ngram=~/ for /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^found$/ | $ngram=~/^found / | $ngram=~/ found$/ | $ngram=~/ found /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^from$/ | $ngram=~/^from / | $ngram=~/ from$/ | $ngram=~/ from /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^further$/ | $ngram=~/^further / | $ngram=~/ further$/ | $ngram=~/ further /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^get$/ | $ngram=~/^get / | $ngram=~/ get$/ | $ngram=~/ get /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^give$/ | $ngram=~/^give / | $ngram=~/ give$/ | $ngram=~/ give /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^go$/ | $ngram=~/^go / | $ngram=~/ go$/ | $ngram=~/ go /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^gov$/ | $ngram=~/^gov / | $ngram=~/ gov$/ | $ngram=~/ gov /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^had$/ | $ngram=~/^had / | $ngram=~/ had$/ | $ngram=~/ had /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^has$/ | $ngram=~/^has / | $ngram=~/ has$/ | $ngram=~/ has /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^have$/ | $ngram=~/^have / | $ngram=~/ have$/ | $ngram=~/ have /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^he$/ | $ngram=~/^he / | $ngram=~/ he$/ | $ngram=~/ he /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hence$/ | $ngram=~/^hence / | $ngram=~/ hence$/ | $ngram=~/ hence /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^her$/ | $ngram=~/^her / | $ngram=~/ her$/ | $ngram=~/ her /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^here$/ | $ngram=~/^here / | $ngram=~/ here$/ | $ngram=~/ here /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hereafter$/ | $ngram=~/^hereafter / | $ngram=~/ hereafter$/ | $ngram=~/ hereafter /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hereby$/ | $ngram=~/^hereby / | $ngram=~/ hereby$/ | $ngram=~/ hereby /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^herein$/ | $ngram=~/^herein / | $ngram=~/ herein$/ | $ngram=~/ herein /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hereupon$/ | $ngram=~/^hereupon / | $ngram=~/ hereupon$/ | $ngram=~/ hereupon /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hers$/ | $ngram=~/^hers / | $ngram=~/ hers$/ | $ngram=~/ hers /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^herself$/ | $ngram=~/^herself / | $ngram=~/ herself$/ | $ngram=~/ herself /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^him$/ | $ngram=~/^him / | $ngram=~/ him$/ | $ngram=~/ him /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^himself$/ | $ngram=~/^himself / | $ngram=~/ himself$/ | $ngram=~/ himself /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^his$/ | $ngram=~/^his / | $ngram=~/ his$/ | $ngram=~/ his /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^how$/ | $ngram=~/^how / | $ngram=~/ how$/ | $ngram=~/ how /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^however$/ | $ngram=~/^however / | $ngram=~/ however$/ | $ngram=~/ however /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^hr$/ | $ngram=~/^hr / | $ngram=~/ hr $/ | $ngram=~/ hr /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ie$/ | $ngram=~/^ie / | $ngram=~/ ie$/ | $ngram=~/ ie /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^if$/ | $ngram=~/^if / | $ngram=~/ if$/ | $ngram=~/ if /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ii$/ | $ngram=~/^ii / | $ngram=~/ ii$/ | $ngram=~/ ii /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^iii$/ | $ngram=~/^iii / | $ngram=~/ iii$/ | $ngram=~/ iii /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^in$/ | $ngram=~/^in / | $ngram=~/ in$/ | $ngram=~/ in /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^inc$/ | $ngram=~/^inc / | $ngram=~/ inc$/ | $ngram=~/ inc /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^incl$/ | $ngram=~/^incl / | $ngram=~/ incl$/ | $ngram=~/ incl /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^indeed$/ | $ngram=~/^indeed / | $ngram=~/ indeed$/ | $ngram=~/ indeed /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^into$/ | $ngram=~/^into / | $ngram=~/ into$/ | $ngram=~/ into /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^investigate$/ | $ngram=~/^investigate / | $ngram=~/ investigate$/ | $ngram=~/ investigate /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^is$/ | $ngram=~/^is / | $ngram=~/ is$/ | $ngram=~/ is /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^it$/ | $ngram=~/^it / | $ngram=~/ it$/ | $ngram=~/ it /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^its$/ | $ngram=~/^its / | $ngram=~/ its$/ | $ngram=~/ its /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^itself$/ | $ngram=~/^itself / | $ngram=~/ itself$/ | $ngram=~/ itself /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^j$/ | $ngram=~/^j / | $ngram=~/ j$/ | $ngram=~/ j /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^jour$/ | $ngram=~/^jour / | $ngram=~/ jour$/ | $ngram=~/ jour /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^journal$/ | $ngram=~/^journal / | $ngram=~/ journal$/ | $ngram=~/ journal /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^just$/ | $ngram=~/^just / | $ngram=~/ just$/ | $ngram=~/ just /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^kg$/ | $ngram=~/^kg / | $ngram=~/ kg$/ | $ngram=~/ kg /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^last$/ | $ngram=~/^last / | $ngram=~/ last$/ | $ngram=~/ last /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^latter$/ | $ngram=~/^latter / | $ngram=~/ latter$/ | $ngram=~/ latter /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^latterly$/ | $ngram=~/^latterly / | $ngram=~/ latterly$/ | $ngram=~/ latterly /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^lb$/ | $ngram=~/^lb / | $ngram=~/ lb$/ | $ngram=~/ lb /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ld$/ | $ngram=~/^ld / | $ngram=~/ ld$/ | $ngram=~/ ld /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^letter$/ | $ngram=~/^letter / | $ngram=~/ letter$/ | $ngram=~/ letter /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^like$/ | $ngram=~/^like / | $ngram=~/ like$/ | $ngram=~/ like /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ltd$/ | $ngram=~/^ltd / | $ngram=~/ ltd$/ | $ngram=~/ ltd /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^made$/ | $ngram=~/^made / | $ngram=~/ made$/ | $ngram=~/ made /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^make$/ | $ngram=~/^make / | $ngram=~/ make$/ | $ngram=~/ make /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^many$/ | $ngram=~/^many / | $ngram=~/ many$/ | $ngram=~/ many /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^may$/ | $ngram=~/^may / | $ngram=~/ may$/ | $ngram=~/ may /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^me$/ | $ngram=~/^me / | $ngram=~/ me$/ | $ngram=~/ me /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^meanwhile$/ | $ngram=~/^meanwhile / | $ngram=~/ meanwhile$/ | $ngram=~/ meanwhile /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^mg$/ | $ngram=~/^mg / | $ngram=~/ mg$/ | $ngram=~/ mg /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^might$/ | $ngram=~/^might / | $ngram=~/ might$/ | $ngram=~/ might /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ml$/ | $ngram=~/^ml / | $ngram=~/ ml$/ | $ngram=~/ ml /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^mm$/ | $ngram=~/^mm / | $ngram=~/ mm$/ | $ngram=~/ mm /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^mo$/ | $ngram=~/^mo / | $ngram=~/ mo$/ | $ngram=~/ mo /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^more$/ | $ngram=~/^more / | $ngram=~/ more$/ | $ngram=~/ more /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^moreover$/ | $ngram=~/^moreover / | $ngram=~/ moreover$/ | $ngram=~/ moreover /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^most$/ | $ngram=~/^most / | $ngram=~/ most$/ | $ngram=~/ most /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^mostly$/ | $ngram=~/^mostly / | $ngram=~/ mostly$/ | $ngram=~/ mostly /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^mr$/ | $ngram=~/^mr / | $ngram=~/ mr$/ | $ngram=~/ mr /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^much$/ | $ngram=~/^much / | $ngram=~/ much$/ | $ngram=~/ much /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^must$/ | $ngram=~/^must / | $ngram=~/ must$/ | $ngram=~/ must /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^my$/ | $ngram=~/^my / | $ngram=~/ my$/ | $ngram=~/ my /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^myself$/ | $ngram=~/^myself / | $ngram=~/ myself$/ | $ngram=~/ myself /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^namely$/ | $ngram=~/^namely / | $ngram=~/ namely$/ | $ngram=~/ namely /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^neither$/ | $ngram=~/^neither / | $ngram=~/ neither$/ | $ngram=~/ neither /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^never$/ | $ngram=~/^never / | $ngram=~/ never$/ | $ngram=~/ never /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^nevertheless$/ | $ngram=~/^nevertheless / | $ngram=~/ nevertheless$/ | $ngram=~/ nevertheless /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^next$/ | $ngram=~/^next / | $ngram=~/ next$/ | $ngram=~/ next /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^no$/ | $ngram=~/^no / | $ngram=~/ no$/ | $ngram=~/ no /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^nobody$/ | $ngram=~/^nobody / | $ngram=~/ nobody$/ | $ngram=~/ nobody /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^no one$/ | $ngram=~/^no one / | $ngram=~/ no one$/ | $ngram=~/ no one /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^nor$/ | $ngram=~/^nor / | $ngram=~/ nor$/ | $ngram=~/ nor /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^not$/ | $ngram=~/^not / | $ngram=~/ not$/ | $ngram=~/ not /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^nothing$/ | $ngram=~/^nothing / | $ngram=~/ nothing$/ | $ngram=~/ nothing /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^now$/ | $ngram=~/^now / | $ngram=~/ now$/ | $ngram=~/ now /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^nowhere$/ | $ngram=~/^nowhere / | $ngram=~/ nowhere$/ | $ngram=~/ nowhere /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^of$/ | $ngram=~/^of / | $ngram=~/ of$/ | $ngram=~/ of /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^off$/ | $ngram=~/^off / | $ngram=~/ off$/ | $ngram=~/ off /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^often$/ | $ngram=~/^often / | $ngram=~/ often$/ | $ngram=~/ often /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^on$/ | $ngram=~/^on / | $ngram=~/ on$/ | $ngram=~/ on /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^only$/ | $ngram=~/^only / | $ngram=~/ only$/ | $ngram=~/ only /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^onto$/ | $ngram=~/^onto / | $ngram=~/ onto$/ | $ngram=~/ onto /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^or$/ | $ngram=~/^or / | $ngram=~/ or$/ | $ngram=~/ or /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^other$/ | $ngram=~/^other / | $ngram=~/ other$/ | $ngram=~/ other /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^others$/ | $ngram=~/^others / | $ngram=~/ others$/ | $ngram=~/ others /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^otherwise$/ | $ngram=~/^otherwise / | $ngram=~/ otherwise$/ | $ngram=~/ otherwise /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^our$/ | $ngram=~/^our / | $ngram=~/ our$/ | $ngram=~/ our /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ours$/ | $ngram=~/^ours / | $ngram=~/ ours$/ | $ngram=~/ ours /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ourselves$/ | $ngram=~/^ourselves / | $ngram=~/ ourselves$/ | $ngram=~/ ourselves /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^out$/ | $ngram=~/^out / | $ngram=~/ out$/ | $ngram=~/ out /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^over$/ | $ngram=~/^over / | $ngram=~/ over$/ | $ngram=~/ over /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^own$/ | $ngram=~/^own / | $ngram=~/ own$/ | $ngram=~/ own /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^oz$/ | $ngram=~/^oz / | $ngram=~/ oz$/ | $ngram=~/ oz /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^per$/ | $ngram=~/^per / | $ngram=~/ per$/ | $ngram=~/ per /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^perhaps$/ | $ngram=~/^perhaps / | $ngram=~/ perhaps$/ | $ngram=~/ perhaps /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^pm$/ | $ngram=~/^pm / | $ngram=~/ pm$/ | $ngram=~/ pm /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^precede$/ | $ngram=~/^precede / | $ngram=~/ precede$/ | $ngram=~/ precede /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^presently$/ | $ngram=~/^presently / | $ngram=~/ presently$/ | $ngram=~/ presently /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^previously$/ | $ngram=~/^previously / | $ngram=~/ previously$/ | $ngram=~/ previously /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^pt$/ | $ngram=~/^pt / | $ngram=~/ pt$/ | $ngram=~/ pt /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^rather$/ | $ngram=~/^rather / | $ngram=~/ rather$/ | $ngram=~/ rather /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^regarding$/ | $ngram=~/^regarding / | $ngram=~/ regarding$/ | $ngram=~/ regarding /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^relate$/ | $ngram=~/^relate / | $ngram=~/ relate$/ | $ngram=~/ relate /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^said$/ | $ngram=~/^said / | $ngram=~/ said$/ | $ngram=~/ said /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^same$/ | $ngram=~/^same / | $ngram=~/ same$/ | $ngram=~/ same /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^seem$/ | $ngram=~/^seem / | $ngram=~/ seem$/ | $ngram=~/ seem /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^seemed$/ | $ngram=~/^seemed / | $ngram=~/ seemed$/ | $ngram=~/ seemed /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^seeming$/ | $ngram=~/^seeming / | $ngram=~/ seeming$/ | $ngram=~/ seeming /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^seems$/ | $ngram=~/^seems / | $ngram=~/ seems$/ | $ngram=~/ seems /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^seriously$/ | $ngram=~/^seriously / | $ngram=~/ seriously$/ | $ngram=~/ seriously /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^several$/ | $ngram=~/^several / | $ngram=~/ several$/ | $ngram=~/ several /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^she$/ | $ngram=~/^she / | $ngram=~/ she$/ | $ngram=~/ she /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^should$/ | $ngram=~/^should / | $ngram=~/ should$/ | $ngram=~/ should /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^show$/ | $ngram=~/^show / | $ngram=~/ show$/ | $ngram=~/ show /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^showed$/ | $ngram=~/^showed / | $ngram=~/ showed$/ | $ngram=~/ showed /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^shown$/ | $ngram=~/^shown / | $ngram=~/ shown$/ | $ngram=~/ shown /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^since$/ | $ngram=~/^since / | $ngram=~/ since$/ | $ngram=~/ since /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^so$/ | $ngram=~/^so / | $ngram=~/ so$/ | $ngram=~/ so /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^some$/ | $ngram=~/^some / | $ngram=~/ some$/ | $ngram=~/ some /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^somehow$/ | $ngram=~/^somehow / | $ngram=~/ somehow$/ | $ngram=~/ somehow /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^someone$/ | $ngram=~/^someone / | $ngram=~/ someone$/ | $ngram=~/ someone /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^something$/ | $ngram=~/^something / | $ngram=~/ something$/ | $ngram=~/ something /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^sometime$/ | $ngram=~/^sometime / | $ngram=~/ sometime$/ | $ngram=~/ sometime /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^sometimes$/ | $ngram=~/^sometimes / | $ngram=~/ sometimes$/ | $ngram=~/ sometimes /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^somewhere$/ | $ngram=~/^somewhere / | $ngram=~/ somewhere$/ | $ngram=~/ somewhere /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^still$/ | $ngram=~/^still / | $ngram=~/ still$/ | $ngram=~/ still /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^studied$/ | $ngram=~/^studied / | $ngram=~/ studied$/ | $ngram=~/ studied /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^sub $/ | $ngram=~/^sub  / | $ngram=~/ sub $/ | $ngram=~/ sub  /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^such$/ | $ngram=~/^such / | $ngram=~/ such$/ | $ngram=~/ such /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^take$/ | $ngram=~/^take / | $ngram=~/ take$/ | $ngram=~/ take /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^tell$/ | $ngram=~/^tell / | $ngram=~/ tell$/ | $ngram=~/ tell /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^th$/ | $ngram=~/^th / | $ngram=~/ th$/ | $ngram=~/ th /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^than$/ | $ngram=~/^than / | $ngram=~/ than$/ | $ngram=~/ than /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^that$/ | $ngram=~/^that / | $ngram=~/ that$/ | $ngram=~/ that /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^the$/ | $ngram=~/^the / | $ngram=~/ the$/ | $ngram=~/ the /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^their$/ | $ngram=~/^their / | $ngram=~/ their$/ | $ngram=~/ their /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^them$/ | $ngram=~/^them / | $ngram=~/ them$/ | $ngram=~/ them /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^themselves$/ | $ngram=~/^themselves / | $ngram=~/ themselves$/ | $ngram=~/ themselves /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^then$/ | $ngram=~/^then / | $ngram=~/ then$/ | $ngram=~/ then /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thence$/ | $ngram=~/^thence / | $ngram=~/ thence$/ | $ngram=~/ thence /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^there$/ | $ngram=~/^there / | $ngram=~/ there$/ | $ngram=~/ there /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thereafter$/ | $ngram=~/^thereafter / | $ngram=~/ thereafter$/ | $ngram=~/ thereafter /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thereby$/ | $ngram=~/^thereby / | $ngram=~/ thereby$/ | $ngram=~/ thereby /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^therefore$/ | $ngram=~/^therefore / | $ngram=~/ therefore$/ | $ngram=~/ therefore /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^therein$/ | $ngram=~/^therein / | $ngram=~/ therein$/ | $ngram=~/ therein /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thereupon$/ | $ngram=~/^thereupon / | $ngram=~/ thereupon$/ | $ngram=~/ thereupon /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^these$/ | $ngram=~/^these / | $ngram=~/ these$/ | $ngram=~/ these /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^they$/ | $ngram=~/^they / | $ngram=~/ they$/ | $ngram=~/ they /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^this$/ | $ngram=~/^this / | $ngram=~/ this$/ | $ngram=~/ this /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thorough$/ | $ngram=~/^thorough / | $ngram=~/ thorough$/ | $ngram=~/ thorough /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^those$/ | $ngram=~/^those / | $ngram=~/ those$/ | $ngram=~/ those /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^though$/ | $ngram=~/^though / | $ngram=~/ though$/ | $ngram=~/ though /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^through$/ | $ngram=~/^through / | $ngram=~/ through$/ | $ngram=~/ through /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^throughout$/ | $ngram=~/^throughout / | $ngram=~/ throughout$/ | $ngram=~/ throughout /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thru$/ | $ngram=~/^thru / | $ngram=~/ thru$/ | $ngram=~/ thru /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^thus$/ | $ngram=~/^thus / | $ngram=~/ thus$/ | $ngram=~/ thus /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^to$/ | $ngram=~/^to / | $ngram=~/ to$/ | $ngram=~/ to /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^together$/ | $ngram=~/^together / | $ngram=~/ together$/ | $ngram=~/ together /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^too$/ | $ngram=~/^too / | $ngram=~/ too$/ | $ngram=~/ too /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^toward$/ | $ngram=~/^toward / | $ngram=~/ toward$/ | $ngram=~/ toward /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^towards$/ | $ngram=~/^towards / | $ngram=~/ towards$/ | $ngram=~/ towards /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^try$/ | $ngram=~/^try / | $ngram=~/ try$/ | $ngram=~/ try /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^type$/ | $ngram=~/^type / | $ngram=~/ type$/ | $ngram=~/ type /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^ug$/ | $ngram=~/^ug / | $ngram=~/ ug$/ | $ngram=~/ ug /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^under$/ | $ngram=~/^under / | $ngram=~/ under$/ | $ngram=~/ under /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^unless$/ | $ngram=~/^unless / | $ngram=~/ unless$/ | $ngram=~/ unless /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^until$/ | $ngram=~/^until / | $ngram=~/ until$/ | $ngram=~/ until /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^up$/ | $ngram=~/^up / | $ngram=~/ up$/ | $ngram=~/ up /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^upon$/ | $ngram=~/^upon / | $ngram=~/ upon$/ | $ngram=~/ upon /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^us$/ | $ngram=~/^us / | $ngram=~/ us$/ | $ngram=~/ us /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^used$/ | $ngram=~/^used / | $ngram=~/ used$/ | $ngram=~/ used /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^using$/ | $ngram=~/^using / | $ngram=~/ using$/ | $ngram=~/ using /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^various$/ | $ngram=~/^various / | $ngram=~/ various$/ | $ngram=~/ various /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^very$/ | $ngram=~/^very / | $ngram=~/ very$/ | $ngram=~/ very /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^via$/ | $ngram=~/^via / | $ngram=~/ via$/ | $ngram=~/ via /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^was$/ | $ngram=~/^was / | $ngram=~/ was$/ | $ngram=~/ was /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^we$/ | $ngram=~/^we / | $ngram=~/ we$/ | $ngram=~/ we /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^were$/ | $ngram=~/^were / | $ngram=~/ were$/ | $ngram=~/ were /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^what$/ | $ngram=~/^what / | $ngram=~/ what$/ | $ngram=~/ what /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whatever$/ | $ngram=~/^whatever / | $ngram=~/ whatever$/ | $ngram=~/ whatever /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^when$/ | $ngram=~/^when / | $ngram=~/ when$/ | $ngram=~/ when /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whence$/ | $ngram=~/^whence / | $ngram=~/ whence$/ | $ngram=~/ whence /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whenever$/ | $ngram=~/^whenever / | $ngram=~/ whenever$/ | $ngram=~/ whenever /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^where$/ | $ngram=~/^where / | $ngram=~/ where$/ | $ngram=~/ where /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whereafter$/ | $ngram=~/^whereafter / | $ngram=~/ whereafter$/ | $ngram=~/ whereafter /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whereas$/ | $ngram=~/^whereas / | $ngram=~/ whereas$/ | $ngram=~/ whereas /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whereby$/ | $ngram=~/^whereby / | $ngram=~/ whereby$/ | $ngram=~/ whereby /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^wherein$/ | $ngram=~/^wherein / | $ngram=~/ wherein$/ | $ngram=~/ wherein /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whereupon$/ | $ngram=~/^whereupon / | $ngram=~/ whereupon$/ | $ngram=~/ whereupon /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^wherever$/ | $ngram=~/^wherever / | $ngram=~/ wherever$/ | $ngram=~/ wherever /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whether$/ | $ngram=~/^whether / | $ngram=~/ whether$/ | $ngram=~/ whether /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^which$/ | $ngram=~/^which / | $ngram=~/ which$/ | $ngram=~/ which /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^while$/ | $ngram=~/^while / | $ngram=~/ while$/ | $ngram=~/ while /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whither$/ | $ngram=~/^whither / | $ngram=~/ whither$/ | $ngram=~/ whither /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^who$/ | $ngram=~/^who / | $ngram=~/ who$/ | $ngram=~/ who /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whoever$/ | $ngram=~/^whoever / | $ngram=~/ whoever$/ | $ngram=~/ whoever /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whom$/ | $ngram=~/^whom / | $ngram=~/ whom$/ | $ngram=~/ whom /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^whose$/ | $ngram=~/^whose / | $ngram=~/ whose$/ | $ngram=~/ whose /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^why$/ | $ngram=~/^why / | $ngram=~/ why$/ | $ngram=~/ why /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^will$/ | $ngram=~/^will / | $ngram=~/ will$/ | $ngram=~/ will /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^with$/ | $ngram=~/^with / | $ngram=~/ with$/ | $ngram=~/ with /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^within$/ | $ngram=~/^within / | $ngram=~/ within$/ | $ngram=~/ within /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^without$/ | $ngram=~/^without / | $ngram=~/ without$/ | $ngram=~/ without /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^wk$/ | $ngram=~/^wk / | $ngram=~/ wk$/ | $ngram=~/ wk /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^would$/ | $ngram=~/^would / | $ngram=~/ would$/ | $ngram=~/ would /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^wt$/ | $ngram=~/^wt / | $ngram=~/ wt$/ | $ngram=~/ wt /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^yet$/ | $ngram=~/^yet / | $ngram=~/ yet$/ | $ngram=~/ yet /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^you$/ | $ngram=~/^you / | $ngram=~/ you$/ | $ngram=~/ you /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^your$/ | $ngram=~/^your / | $ngram=~/ your$/ | $ngram=~/ your /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^yours$/ | $ngram=~/^yours / | $ngram=~/ yours$/ | $ngram=~/ yours /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^yourself$/ | $ngram=~/^yourself / | $ngram=~/ yourself$/ | $ngram=~/ yourself /) { $ngram="DROPTHISNGRAM"; }
    if ($ngram=~/^yourselves$/ | $ngram=~/^yourselves / | $ngram=~/ yourselves$/ | $ngram=~/ yourselves /) { $ngram="DROPTHISNGRAM"; }
}