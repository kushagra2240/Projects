#!/usr/local/bin/perl

use Clair::Document;
my @sentences;

use FindBin;
use lib "$FindBin::Bin/";

my $corp;
my $numargs = $#ARGV+1;
if ($numargs == 1 )
{
	$corp=$ARGV[0];
}

else {
	$corp= "D0651F";
}

my $work_dir = "$FindBin::Bin";
my $train_dir = "$work_dir/$corp/";
#uniqwords is a hash of the uniquewords used for building the sentence term matrix
my %uniqwords;
#wcount is the count of all words
my $wcount = 0;
my @STOP_WORDS=
  (
      '0', '1', '2', '3', '4', '5', '6', '7', '8',
      '9', '000', 'about', 'after', 'all', 'also', 'an', 'and',
      'another', 'any', 'are', 'as', 'at', 'be',
      'because', 'been', 'before', 'being', 'between',
      'both', 'but', 'by', 'came', 'can', 'come',
      'could', 'did', 'do', 'does', 'each', 'else',
      'for', 'from', 'get', 'got', 'has', 'had',
      'he', 'have', 'her', 'here', 'him', 'himself',
      'his', 'how','if', 'in', 'into', 'is', 'it',
      'its', 'just', 'like', 'make', 'many', 'me',
      'might', 'more', 'most', 'much', 'must', 'my',
      'never', 'now', 'of', 'on', 'only', 'or',
      'other', 'our', 'out', 'over', 're', 'said',
      'same', 'see', 'should', 'since', 'so', 'some',
      'still', 'such', 'take', 'than', 'that', 'the',
      'their', 'them', 'then', 'there', 'these',
      'they', 'this', 'those', 'through', 'to', 'too',
      'under', 'up', 'use', 'very', 'want', 'was',
      'way', 'we', 'well', 'were', 'what', 'when',
      'where', 'which', 'while', 'who', 'will',
      'with', 'would', 'you', 'your',
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
      'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
      's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  );

  #array of the first N files in the training directory
my @allfiles;

#getting all the filenames in the train directory
opendir(DIR, $train_dir) or die "can't opendir $train_dir: $!";
while (defined(my $file = readdir(DIR))) 
{
	push (@allfiles,$file);	
}
closedir(DIR);

#remove . and ..
splice (@allfiles,0,2);
my $doid = 1;

foreach my $files(@allfiles) 
{
  open (TEST,"$train_dir"."$files");
  #tflag is a flag for judging if its text part or not

  my $tflag = 0;

  #sentence begining and ending points in a file 
 	my $sen_start=0;
 	my $sen_end=0;
  #txtstring stores the sentences seperated by .
 	my $txtstring="";
  while (<TEST>)
  {
   	$_ = lc $_;
   	chomp $_;

	if ($tflag == 0) {
		$sen_start=$sen_start+1;
		
	}
	
  	if (/<text>/) {
		$tflag = 1;
		$sen_start=$sen_start+1;
		$sen_end=$sen_start;
		next;
	}
	if (/<\/text>/) {
		$tflag = 0;
		last;
	}
	if ($tflag == 1) {
		$_ = punctuate($_);
		$_ =~ s/\n/ /;

  		foreach my $temp (@STOP_WORDS) {
  			$_ =~ s/\s+$temp\s+/ /g;
  			$_ =~ s/^$temp\s+/ /g;
  			$_ =~ s/\s+$temp$/ /g;
  		}

  		$_ =~ s/\s+/ /g;
		$_ =~ s/,|:|;|\'|\"//;
	#now form sentences seperated by . to do this concatenate all and split on .#arr is an array created in each iteration to keep track of sentences
		
		$txtstring = $txtstring.$_;

		my @arr = split /\.\s+/,$txtstring;
		my $temparrsize = scalar @arr;
		
#dirty hack, assuming that the last part is broken remove it, but works. i check for the other case below.
		if ($temparrsize > 1) {
			$txtstring = "";
			$txtstring = pop(@arr);
		}
		
#check if the tempstring ends with a .
		if ($txtstring =~ /\.\s+$/) {
			@arr = split /\./,$txtstring;
			$temparrsize=2;
			$txtstring="";
		}
		
#if temparrsize > 1 it means that there are sentences, so store their positions in the pos array
		if ($temparrsize > 1) {
#initialize the pos array at each step
			my @pos;
#populate the pos array and make sen_start = sen_end for multiple sentences on a line
			for ($i=0;$i<$temparrsize-1;$i++) {
				push (@pos,[$sen_start,$sen_end]);
				$sen_start=$sen_end;
			}
			
			#$ctr is a counter
			my $ctr=0;
			# perform stemming and store
			#print scalar @arr;
			foreach my $tt (@arr) {
				if ($tt eq ""|$tt eq " "){next;}
				my $stem_doc = new Clair::Document(string => $tt, id =>$doid, type =>'text');
				my $text = $stem_doc->stem();
				
				if ($text =~ /[a-z]*/) {
					#print "$arr[$ctr]->[0],$arr[$ctr]->[1]\n";
					my $diff=$sen_start-$sen_end;
					
	#sentences is a data structure of the form text,file name, begining and ending lines in actual file
					push (@sentences,[$text,$files,$pos[$ctr]->[0],$pos[$ctr]->[1]]);

				}
		#my words is the array of words of text used for calcing uniqwords
				my @words = split /\s+/,$text;
				foreach my $tempw (@words) {
					if ($tempw eq "" | $tempw eq "." | $tempw eq "..."|$tempw eq "\("|$tempw eq "_"|$tempw eq "\"") {}
					else {
						if ($uniqwords{$tempw})	{}
						else {
							$wcount=$wcount+1;
							$uniqwords{$tempw} = $wcount;
						}
					}
				}
				$ctr=$ctr+1;

			}

	
		}
	#increment the ending of the sentence
		$sen_end=$sen_end+1;	
	}
  	#end while
  	}
  close TEST;
#end for each  
}

my $size = 0;
open (SEN,">$work_dir/sentences11.txt");
my $c_sen=1;
foreach my $t_sen (@sentences) {
	if ($t_sen->[2] eq "" || $t_sen->[3] eq "") {
		next;
	}
	print SEN "$c_sen $t_sen->[1] $t_sen->[2] $t_sen->[3]\n";
	$c_sen++;
	$size++;
}
close (SEN);

open (MAT,">$work_dir/mat_test.txt");
foreach my $tt1 (@sentences) {
	my @ar = (1,$wcount);
#initialize the array
	for ($i=0;$i<$wcount;$i++) {
		$ar[$i]=0;
	}
	my $str1 = $tt1->[0];
	my @temp = split /\s/,$str1;
	foreach my $tt (@temp) {
		if ($uniqwords{$tt})
		{
			my $t1 = $uniqwords{$tt};
			$t1=$t1-1;
			$ar[$t1]=$ar[$t1]+1;

		}
	}
	my $str101;
	for ($i=0;$i<$wcount;$i++) {
		$str101="$str101"." "."$ar[$i]";
	}
	print MAT "$str101\n";

}
close (MAT);

my $key;
my $value;
open (TST,">$work_dir/test.txt");
while (($key,$value) = each %uniqwords)
{
print  TST "$key\t$value\n";
}
close TST;
sub punctuate {
		
    $_ =~ s/,//g;
    $_ =~ s/\$//g;
	$_ =~ s/[0-9]*//g;
	$_ =~ s/<p>/ /g;
	$_ =~ s/<\/p>/ /g;
	$_ =~ s/<line>/ /g;
	$_ =~ s/<\/line>/ /g;
	$_ =~ s/\'//g;
	$_ =~ s/\`//g;
	$_ =~ s/(-)+/ /g;
	$_ =~ s/\"//g;
	$_ =~ s/\s+[a-z]\.\s+/ /g;
	$_ =~ s/[i]*\s+/ /g;
	$_ =~ s/[i]*[v][i]*\s+/ /g;
	$_ =~ s/\s+&[a-z]*/ /;
	$_ =~ s/\s+p.m.\s+/ pm /g;
	$_ =~ s/\s+a.m.\s+/ am /g;
	$_ =~ s/\s+dr.\s+/ dr /g;
	$_ =~ s/\s+mr.\s+/ mr /g;
	$_ =~ s/\s+mrs.\s+/ mrs /g;
	$_ =~ s/\s+phd.\s+/ phd /g;
	$_ =~ s/\s+ex.\s+/ ex /g;
	$_ =~ s/\s+eg.\s+/ eg /g;
	$_ =~ s/\s+i.e.\s+/ ie /g;
	$_ =~ s/\s+ie.\s+/ ie /g;
	$_ =~ s/\s+c.v.\s+/ cv /g;
	$_ =~ s/\s+rep.\s+/ rep /g;
	$_ =~ s/\s+pres.\s+/ pres /g;
	$_ =~ s/\s+u.s.\s+/ us /g;
	$_ =~ s/\s+u.k.\s+/ uk /g;
	$_ =~ s/\s+jan.\s+/ jan /g;
	$_ =~ s/\s+feb.\s+/ feb /g;
	$_ =~ s/\s+mar.\s+/ mar /g;
	$_ =~ s/\s+apr.\s+/ apr /g;
	$_ =~ s/\s+jun.\s+/ jun /g;
	$_ =~ s/\s+jul.\s+/ jul /g;
	$_ =~ s/\s+aug.\s+/ aug /g;
	$_ =~ s/\s+sep.\s+/ sep /g;
	$_ =~ s/\s+\"oct\".\s+/ \"oct\" /g;
	$_ =~ s/\s+nov.\s+/ nov /g;
	$_ =~ s/\s+dec.\s+/ dec /g;
	$_ =~ s/\s+mon.\s+/ mon /g;
	$_ =~ s/\s+tue.\s+/ tue /g;
	$_ =~ s/\s+wed.\s+/ wed /g;
	$_ =~ s/\s+thurs.\s+/ thurs /g;
	$_ =~ s/\s+fri.\s+/ fri /g;
	$_ =~ s/\s+sat.\s+/ sat /g;
	$_ =~ s/\s+sun.\s+/ sun /g;

	$_ =~ s/\(//g;
	$_ =~ s/\)//g;
	
	return $_;
}
 
