#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Titles";

$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_titles.txt") or die "Can't open subjects file: medline16\_$fileindex\_titles.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version	translated	inprocess	articletitle\n";

    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline16n0$fileindex.xml\n";
    &date;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {

     if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml");}
     if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml"); }
     if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml"); }
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

            $articletitle = $e->{Article}->{ArticleTitle};
            # Determine if the title was translated.
           $translated="N";
           if ($articletitle=~/^\[(.*)/) { $translated="Y"; }
           # Determine if the title is in the process of being translated.
           $inprocess="N";
           if ($articletitle=~/^\[In Process Citation\]\.$/) { $inprocess="Y"; }

            if ($owner eq "") { $owner="null"; }
            if ($status eq "") { $status="null"; }
            if ($versionid eq "") { $versionid="null"; }
            if ($versiondate eq "") { $versiondate="null"; }

            if ($pmid eq "") { $pmid="null"; }
            if ($version eq "") { $version="null"; }

            if ($articletitle eq "") { $articletitle="null"; }
            if ($articletitle eq "") { $translated="null"; }
            if ($articletitle eq "") { $inprocess="null"; }

            print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	$translated	$inprocess	$articletitle\n";
    }
}
