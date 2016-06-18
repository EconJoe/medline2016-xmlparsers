

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Authors";

# Declare which MEDLINE files to parse
$startfile=811; $endfile=811;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Create the output file, and print the variable names
    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_authors.txt") or die "Can't open subjects file: medline16\_$fileindex\_author.txt";
    print OUTFILE "filenum	owner	status	versionid	versiondate	pmid	version	authorlistcomplete	authorvalid	";
    print OUTFILE "lastname	forename	inititals	identifier	source	collectivename	authororder	authortotal	affiliation\n";

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
            @article = @{$i->{Article}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            foreach $j (@article) {
              @authorlist = @{$j->{AuthorList}};
              $authorlistsize=@authorlist;
  
              if ($authorlistsize==0) {
                 print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	null	null	";
                 print OUTFILE "null	null	null	null	null	null	null	null	null\n";
              }
              
              else {
                foreach $k (@authorlist) {
                        $complete = "$k->{CompleteYN}";
                        @author = @{$k->{Author}};
                        
                        $authortotal=@author;
                        $authororder=0;

                        foreach $l (@author) {
                                $valid = "$l->{ValidYN}";
                                @lastname = @{$l->{LastName}};
                                @forename = @{$l->{ForeName}};
                                @initials = @{$l->{Initials}};
                                @identifier = @{$l->{Identifier}};
                                @collectivename = @{$l->{CollectiveName}};
                                @affiliationinfo = @{$l->{AffiliationInfo}};
                                $affiliationinfosize=@affiliationinfo;
                                $authororder++;
                                
                                $identifier="null";
                                $source="null";
                                foreach $m (@identifier) {
                                    $identifier="$m->{content}";
                                    $source="$m->{Source}";
                                }

                                if ($affiliationinfosize==0) {
                                        print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	$complete	$valid	";
                                        print OUTFILE "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	null\n";
                                }

                                else {
                                  foreach $m (@affiliationinfo) {
                                          @affiliation = @{$m->{Affiliation}};

                                          foreach $n (@affiliation) {

                                            #$lastnamesize=@lastname;
                                            #$forenamesize=@forename;
                                            #$initisalssize=@initials;
                                            #$collectivenamesize=@collectivename;

                                            print OUTFILE "$fileindex	$owner	$status	$versionid	$versiondate	$pmid	$version	$complete	$valid	";
                                            print OUTFILE "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	$n\n";
                                          }
                                  }
                                }
                        }
                }
              }
            }
    }
}
