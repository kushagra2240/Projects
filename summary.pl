#!/usr/local/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/";


my $work_dir = "$FindBin::Bin";
my $corp;
my $numargs = $#ARGV+1;
if ($numargs == 1 )
{
	$corp=$ARGV[0];
}

else {
	$corp= "D0651F";
}

my $corp_dir = "$work_dir/$corp/";
my $corp_file = "sentences11.txt";
my $w_file = "final.txt";
my $temp_file="tt.txt";
my @arr;


#@arr keeps the sentences to be summarized, in a sorted order. these are numbers which map to sentences in sentences.txt file
open (WF,"$work_dir"."/$w_file");
while (<WF>) {
	chomp $_;
	push (@arr,$_);
}
close (WF);
my @sentences;
#one benefit of sorting is that sentences from same documents automatically come in order
@arr = sort {$a <=> $b} @arr;

#f_string will hold the summarized text
my $f_string="";

#we have the list of centroids in @arr, therefore traverse through them one by one and retrieve them to put into final summary f_string
foreach my $t (@arr) {
	open (TF,"$work_dir"."/$corp_file");

#ctr is the line counter of the file sentences.txt
	my $ctr = 1;	
#corp_file is sentences.txt, which is of form sentence no. filename start line end line
	while (<TF>) {
#ignore line numbers lesser than than the centroids, thats why we first sort @arr
		if ($ctr < $t) {
			$ctr++;
			next;
		}
		if ($ctr > $t) {
			last;
		}
		
#found a match for sentence
		elsif ($ctr == $t) {
			$ctr++;
			chomp $_;
			open (FK,">>$work_dir"."/$temp_file");
			print FK "$_\n";
			close (FK);
			my @ar=split /\s/,$_;
#now we have the number file name start and end in ar[0],ar[1],ar[2],ar[3] respectively
#f_name is the name of the file to which the sentence belongs			
			my $f_name="$corp_dir"."$ar[1]";
			#print "$f_name\n";
			open (MF,"$f_name") or die ("can't open");
#fctr is a counter that counts to the start of the sentence
#tstr is a temporary string
			my $fctr=0;
			my $tstr="";
	
			while (<MF>) {

#reach the start of sentence
				if ($fctr < $ar[2]) {
					$fctr=$fctr+1;
					next;
				}
#now we are at start/mid of the sentence
				elsif ($fctr >= $ar[2]) {
					if ($fctr <= $ar[3]) {
						
						chomp $_;
						$_=lc $_;
						$tstr=$tstr.$_;
						$fctr=$fctr+1;
					}
				}
#we are at end of sentence
				if ($fctr > $ar[3]) {
				
					last;
				}
				
			
			}
#close the file			
			close (MF);

			$tstr =~ s/<p>|<\/p>|(-)+|\s+|<text>|<\/text>/ /g;

			$f_string=$f_string.$tstr;
		
			}
	}
	close (TF);
}

print "\n$f_string;\n";


