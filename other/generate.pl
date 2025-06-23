#!/usr/bin/perl -w
use strict;

my ($sample) = @ARGV;
my $usage = "This script is to generate 100 lines of observed results of flipping coins.Can you guess at which point the coin is chang
ed?
usage: $0 sample
sample.txt is the file to score the flipping results, and this script will generate an additional file as sample.sta to keep the infor
mation where the coin changed.
Of course, you can change the name of \"sample\" to any word you like.
";

die $usage if @ARGV <1;
my $sta=$sample.".sta";
open(OUT,">$sample")||die("Cannot write result to $sample!\n");
open(STA,">$sta")||die("Cannot write result to $sta!\n");
#randomization
my $p_AH = 0.5;
my $p_BH = 0.8;
my $p_A2B = 0.01;
my $p_B2E = 0.05;
#generation
for(my $i=0; $i<100; $i++){
#start from coin 1
    flip_coin($p_AH);
    print STA "1";
#flip coin 1
    while($p_A2B < rand(1)){
        flip_coin($p_AH);
        print STA "1";
    }
#change to coin 2
    flip_coin($p_BH);
    print STA "2";
#flip coin 2
    while($p_B2E < rand(1)){
        flip_coin($p_BH);
        print STA "2";
    }
#change to END
    print OUT "\n";
    print STA "\n";
}
close OUT;

sub flip_coin{
    my ($pH) = @_;
    if($pH>rand(1)){
        print OUT "H";
    }
    else{
        print OUT "T";
    }
}
