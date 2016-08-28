

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Authors";

####################################################################################
open (OUTFILE_ALL, ">:utf8", "$outpath\\medline16_authors.txt") or die "Can't open subjects file: medline16_authors.txt";
print OUTFILE_ALL "filenum	pmid	version	authorlistcomplete	authorvalid	";
print OUTFILE_ALL "lastname	forename	inititals	identifier	source	collectivename	authororder	authortotal	affiliation\n";
####################################################################################

# Declare which MEDLINE files to parse
$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Create the output file, and print the variable names
    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_authors.txt") or die "Can't open subjects file: medline16\_$fileindex\_author.txt";
    print OUTFILE "filenum	pmid	version	authorlistcomplete	authorvalid	";
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
                 print OUTFILE "$fileindex	$pmid	$version	null	null	";
                 print OUTFILE "null	null	null	null	null	null	null	null	null\n";

                 print OUTFILE_ALL "$fileindex	$pmid	$version	null	null	";
                 print OUTFILE_ALL "null	null	null	null	null	null	null	null	null\n";
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
                                        print OUTFILE "$fileindex	$pmid	$version	$complete	$valid	";
                                        print OUTFILE "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	null\n";
                                        
                                        print OUTFILE_ALL "$fileindex	$pmid	$version	$complete	$valid	";
                                        print OUTFILE_ALL "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	null\n";
                                }

                                else {
                                  foreach $m (@affiliationinfo) {
                                          @affiliation = @{$m->{Affiliation}};

                                          foreach $n (@affiliation) {

                                            #$lastnamesize=@lastname;
                                            #$forenamesize=@forename;
                                            #$initisalssize=@initials;
                                            #$collectivenamesize=@collectivename;

                                            print OUTFILE "$fileindex	$pmid	$version	$complete	$valid	";
                                            print OUTFILE "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	$n\n";
                                            
                                            print OUTFILE_ALL "$fileindex	$pmid	$version	$complete	$valid	";
                                            print OUTFILE_ALL "$lastname[0]	$forename[0]	$initials[0]	$identifier	$source	$collectivename[0]	$authororder	$authortotal	$n\n";
                                          }
                                  }
                                }
                        }
                }
              }
            }
    }
}
