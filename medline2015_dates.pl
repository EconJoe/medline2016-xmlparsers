#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "B:\\Research\\Medline2015\\zip";
$outpath = "D:\\Research\\BreakOut\\BO4\\Data\\Parsed\\Medline2015\\Dates";


$startfile=691; $endfile=779;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline15\_$fileindex\_dates.txt") or die "Can't open subjects file: medline15\_$fileindex\_dates.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version	";
    print OUTFILE "pubyear	articyear	pubmonth	articmonth	pubday	articday	medlinedate\n";

    print "Reading in file: medline15n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline15n0$fileindex.xml\n";
    &date;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {

     if ($fileindex<10) { $data = XMLin("$inpath\\medline15n000$fileindex.xml");}
     if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline15n00$fileindex.xml"); }
     if($fileindex>=100 && $fileindex<=779) { $data = XMLin("$inpath\\medline15n0$fileindex.xml"); }
}

sub date {

    # access <MedlineCitation> array
    foreach $e (@{$data->{MedlineCitation}}) {

            $owner = $e->{Owner};
            $status = $e->{Status};
            $versionid = $e->{VersionID};
            $versiondate = $e->{VersionDate};

            $pmid = $e->{PMID}->{content};
            $version = $e->{PMID}->{Version};

            $pubyear = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Year};
            $pubmonth = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Month};
            $pubday = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Day};

            $articyear = $e->{Article}->{ArticleDate}->{Year};
            $articmonth = $e->{Article}->{ArticleDate}->{Month};
            $articday = $e->{Article}->{ArticleDate}->{Day};
            
            $medlinedate = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{MedlineDate};

            if ($owner eq "") { $owner="null"; }
            if ($status eq "") { $status="null"; }
            if ($versionid eq "") { $versionid="null"; }
            if ($versiondate eq "") { $versiondate="null"; }

            if ($pmid eq "") { $pmid="null"; }
            if ($version eq "") { $version="null"; }

            if ($pubyear eq "") { $pubyear="null"; }
            if ($pubmonth eq "") { $pubmonth="null"; }
            if ($pubday eq "") { $pubday="null"; }
            
            if ( $articyear eq "") { $articyear="null"; }
            if ( $articmonth eq "") { $articmonth="null"; }
            if ( $articday eq "") { $articday="null"; }

            if ($medlinedate eq "") { $medlinedate="null"; }

            print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	";
            print OUTFILE "$pubyear	$articyear	$pubmonth	$articmonth	$pubday	$articday	$medlinedate\n";
    }
}
