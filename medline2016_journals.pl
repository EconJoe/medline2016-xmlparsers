#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Journals";

# Declare which MEDLINE files to parse
$startfile=701; $endfile=701;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_journals.txt") or die "Can't open subjects file: medline16\_$fileindex\_journals.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version	nlmid	";
    print OUTFILE "issn	issnl	volume	issue	pubmodel	";
    print OUTFILE "artictype	issntype	citedmed	medlineta	isoabbrev	";
    print OUTFILE "journtitle	country	language\n";

    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline16n0$fileindex.xml\n";
    &journal;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {
  
  # Read in MELDINE XML files based on the number of leading zeros in the file name
  if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml");}
  if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml"); }
     if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml"); }
}

sub journal {

    # access <MedlineCitation> array
    foreach $e (@{$data->{MedlineCitation}}) {
      
            $owner = $e->{Owner};
            $status = $e->{Status};
            $versionid = $e->{VersionID};
            $versiondate = $e->{VersionDate};

            $pmid = $e->{PMID}->{content};
            $version = $e->{PMID}->{Version};

            $volume = $e->{Article}->{Journal}->{JournalIssue}->{Volume};
            $issue = $e->{Article}->{Journal}->{JournalIssue}->{Issue};
            $pubmodel = $e->{Article}->{PubModel};
            $artictype = $e->{Article}->{ArticleDate}->{DateType};
            $issntype = $e->{Article}->{Journal}->{ISSN}->{IssnType};
            $citedmed = $e->{Article}->{Journal}->{JournalIssue}->{CitedMedium};
            $nlmuniqueid = $e->{MedlineJournalInfo}->{NlmUniqueID};
            $issn = $e->{Article}->{Journal}->{ISSN}->{content};
            $issnl = $e->{MedlineJournalInfo}->{ISSNLinking};
            $medlineta = $e->{MedlineJournalInfo}->{MedlineTA};
            $isoabbrev= $e->{Article}->{Journal}->{ISOAbbreviation};
            $journtitle = $e->{Article}->{Journal}->{Title};
            $country = $e->{MedlineJournalInfo}->{Country};
            $language = $e->{Article}->{Language};
            
            if ($owner eq "") { $owner="null"; }
            if ($status eq "") { $status="null"; }
            if ($versionid eq "") { $versionid="null"; }
            if ($versiondate eq "") { $versiondate="null"; }

            if ( $pmid eq "") { $pmid="null"; }
            if ( $version eq "") { $version="null"; }

            if ( $volume eq "") { $volume="null"; }
            if ( $issue eq "") { $issue="null"; }
            if ( $pubmodel eq "") { $pubmodel="null"; }
            if ( $artictype eq "") { $artictype="null"; }
            if ( $issntype eq "") { $issntype="null"; }
            if ( $citedmed eq "") { $citedmed="null"; }
            if ( $nlmuniqueid eq "") { $nlmuniqueid="null"; }
            if ( $issn eq "") { $issn="null"; }
            if ( $issnl eq "") { $issnl="null"; }
            if ( $medlineta eq "") { $medlineta="null"; }
            if ( $isoabbrev eq "") { $isoabbrev="null"; }
            if ( $journtitle eq "") { $journtitle="null"; }
            if ( $country eq "") { $country="null"; }
            if ( $language eq "") { $language="null"; }
            
            $journtitle =~ tr/"//d;

            print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	$nlmuniqueid	$issn	$issnl	$volume	$issue	$pubmodel	";
            print OUTFILE "$artictype	$issntype	$citedmed	$medlineta	$isoabbrev	";
            print OUTFILE "$journtitle	$country	$language\n";
    }
}