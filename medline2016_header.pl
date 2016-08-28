#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

####################################################################################
####################################################################################
# User must set the outpath and the inpath.
# The outpath should point to Data_Replication-->Parsed-->Dates
# The inpath should point to Data_Replication-->ReplicationSample-->ReplicationXML-->MEDLINE

# Set path names
$outpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Header";
$inpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
####################################################################################

open (OUTFILE_ALL, ">:utf8", "$outpath\\medline16_header.txt") or die "Can't open subjects file: medline16_header.txt";
print OUTFILE_ALL "filenum	owner	status	versionid	versiondate	pmid	version\n";

$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_header.txt") or die "Can't open subjects file:medline16\_$fileindex\_header.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version\n";

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

            if ($owner eq "") { $owner="null"; }
            if ($status eq "") { $status="null"; }
            if ($versionid eq "") { $versionid="null"; }
            if ($versiondate eq "") { $versiondate="null"; }

            if ($pmid eq "") { $pmid="null"; }
            if ($version eq "") { $version="null"; }

            if ($medlinedate eq "") { $medlinedate="null"; }

            print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version\n";
            print OUTFILE_ALL "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version\n";
    }
}