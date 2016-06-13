

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\MeSH";

# Declare which MEDLINE files to parse
$startfile=779; $endfile=779;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Create the output file, and print the variable names
    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_mesh.txt") or die "Can't open subjects file: medline16\_$fileindex\_mesh.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version	";
    print OUTFILE "mesh	ui	majortopic	type	meshgroup\n";

    # Read in XML file
    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    # Parse MEDLINE XML file
    print "Parsing file: medline16n0$fileindex.xml\n";
    &mesh;

    # "Dump" the XML file out of memory
    $data=0;
}

sub importfile {

    # Read in MELDINE XML files based on the number of leading zeros in the file name
    if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml", ForceArray => 1);}
    if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml", ForceArray => 1); }
    if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml", ForceArray => 1); }
}

sub mesh {
    
    # <MedlineCitation> is the top level element in MedlineCitationSet and contains one entire record
    # Access <MedlineCitation> array
    foreach $i (@{$data->{MedlineCitation}}) {

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

            @pmid = @{$i->{PMID}};
            @medlinejournalinfo = @{$i->{MedlineJournalInfo}};
            @meshheadinglist = @{$i->{MeshHeadingList}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            $meshheadinglistsize=@meshheadinglist;

            if ($meshheadinglistsize==0) {
               print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	";
               print OUTFILE "null	null	null	null	\n";
            }

            foreach $j (@meshheadinglist) {
                    @meshheading = @{$j->{MeshHeading}};

                    $meshgroup=0;
                    foreach $k (@meshheading) {
                            @descriptorname=@{$k->{DescriptorName}};
                            @qualifiername=@{$k->{QualifierName}};

                            $meshgroup++;

                            foreach $l (@descriptorname) {
                                    $mesh="$l->{content}";
                                    $majortopic="$l->{MajorTopicYN}";
                                    $ui="$l->{UI}";
                                    $type="Descriptor";

                                    print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	";
                                    print OUTFILE "$mesh	$ui	$majortopic	$type	$meshgroup\n";
                            }
                            
                            foreach $l (@qualifiername) {
                                    $mesh="$l->{content}";
                                    $majortopic="$l->{MajorTopicYN}";
                                    $ui="$l->{UI}";
                                    $type="Qualifier";
                                    
                                    print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	";
                                    print OUTFILE "$mesh	$ui	$majortopic	$type	$meshgroup\n";
                            }
                    }
            }
    }
}
