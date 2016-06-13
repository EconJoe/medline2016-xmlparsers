#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;
use Lingua::Stem;

#$outpath="/disk/homedirs/nber/staudt/bulk/SciLaborSupply/NGrams_2015";
$outpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Abstracts\\OtherAbstracts";

#$inpath="/disk/homedirs/nber/staudt/bulk/Medline2015"
$inpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";


$medlineversion=16;
$startfile=601; $endfile=600;
for ($filenum=$startfile; $filenum<=$endfile; $filenum++) {

    # Create output file (replace if file already exists)
    #open (OUTFILE, ">:utf8", "$outpath/medline16\_$filenum\_ngrams.txt") or die "Can't open subjects file: medline16_$filenum\_ngrams.txt";
    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$filenum\_otherabstracts.txt") or die "Can't open subjects file: medline16\_$filenum\_otherabstracts.txt";

    print OUTFILE "filenum	recordnum	owner	status	versionid	versiondate	pmid	version	";
    print OUTFILE "type	language	truncated	otherabstract\n";

    # Read in MEDLINE XML file
    print "Reading in file: medline160$filenum.xml\n";
    &importfile;

    $recordnum=0;
    foreach $i (@{$data->{MedlineCitation}}) {

            $recordnum++;
            &extract;
    }
    
    # Close output file
    close OUTFILE;

    # this "dumps" the XML file out of memory
    $data=0;
}

#sub importfile {
#
#    if ($filenum<10) { $data = XMLin("$path/Medline2015/medline16n000$filenum.xml", ForceArray => 1);}
#     if($filenum>=10 && $filenum<=99) { $data = XMLin("$path/Medline2016/medline16n00$filenum.xml", ForceArray => 1); }
#     if($filenum>=100 && $filenum<=779) { $data = XMLin("$path/Medline2016/medline16n0$filenum.xml", ForceArray => 1); }
#}

sub importfile {

     if ($filenum<10) { $data = XMLin("$inpath\\medline16n000$filenum.xml", ForceArray => 1);}
     if($filenum>=10 && $filenum<=99) { $data = XMLin("$inpath\\medline16n00$filenum.xml", ForceArray => 1); }
     if($filenum>=100 && $filenum<=812) { $data = XMLin("$inpath\\medline16n0$filenum.xml", ForceArray => 1); }
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

    if ($otherabstractsize==1) {
      
      foreach $k (@otherabstract) {
        @abstracttext = @{$k->{AbstractText}};
        $abstracttextsize=@abstracttext;
    
                # Bring abstract into content string
                $otherabstract=$abstracttext[0];
                # Assign proper values to abstract-only characteristics
                $type = "$k->{Type}";
                $language = "$k->{Language}";
                
                # Test if the abstract is truncated
                $truncated="No";
                if ($content =~/ABSTRACT TRUNCATED/) { $truncated="Yes"; }
                if ($content =~/ABSTRACT TRUNCATED AT 400 WORDS/) { $truncted="Yes: 400"; }
                if ($content =~/ABSTRACT TRUNCATED AT 250 WORDS/) { $truncated="Yes: 250"; }

                print OUTFILE "$filenum	$recordnum	$owner	$status	$versionid	$versiondate	$pmid	$version	";
                print OUTFILE "$type	$language	$truncated	$otherabstract\n";
    }
   }
}

    

