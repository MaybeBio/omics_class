#!/usr/bin/perl -w
use strict;

my ($blast_out) = @ARGV;
my $usage = "This script is to get the best hit from blast output file with 1 input sequence.
usage: $0 <blast_output_file>
";
die $usage if @ARGV<1;

open(BLASTOUT,$blast_out)||die("open $blast_out error!\n");

my $query = "";
my $score = "";
my $p_value = "";
my $hit = "";
my $flag = 0;
while(<BLASTOUT>){
    chomp;
    if($flag == 0){
	if(/^Query=\s*(\w+)/){
	    $query = $1;
	}
	elsif(/^Sequences producing High-scoring Segment Pairs:/){
	    $flag = 1;
	}
	else{
	    next;
	}
    }
    else{
	if(/^([\w\.\-]+)\s+.+\s+([0-9]+)\s+([0-9e\-\.]+)\s+[0-9]+$/){
	    $hit = $1;
	    $score = $2;
	    $p_value = $3;
	    last;
	}
	else{
	    next;
	}
    }
}

close BLASTOUT;

print "Best hit to $query is: $hit, with score $score, P-value $p_value.\n";

exit;
