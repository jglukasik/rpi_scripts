#!/usr/bin/perl

use strict;
use warnings;

my $path = "/home/pi/pi_sync/";
my $date;
my $time;
my $temp; 
my $temp_file = "/temps.txt";

$date = `date -I`; 
chomp $date;

if (! -d $path.$date){
	mkdir $path.$date;
}

$time = `date +%H:%M:%S`;
chomp $time;

$temp = `/opt/vc/bin/vcgencmd measure_temp`;
$temp =~ s/temp=//g;
$temp =~ s/'C//g;
chomp $temp;

$temp_file = $path.$date.$temp_file;

open (my $fh, '>>', $temp_file) or die "Could not open file '$temp_file' $!";
print $fh $time."\t".$temp."\n";
