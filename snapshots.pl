#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($opt_r) = 0;
my $opt_h;

GetOptions 
	( "rotate=i" => \$opt_r
	, "help" => \$opt_h
	);

if ($opt_h) {
	print <<USAGE;
$0 [--rotate='Number of 90 degree clockwise turns']
USAGE
	exit 0;
}
	
my $base_dir = "/home/pi/";
my $pics_path = "pi_sync/";
my ($pic_name, $full_pic_name, $date);

$date = `date -I`;
chomp $date;

if (! -d $base_dir.$pics_path.$date){
	mkdir $base_dir.$pics_path.$date;
}

$pic_name = `date +'%H:%M:%S'`;
chomp $pic_name;
$full_pic_name = $base_dir.$pics_path.$date.'/'.$pic_name.'.jpg';

system("ffmpeg -f video4linux2 -vframes 1 -i /dev/video0 $full_pic_name");

my $transpose;
if ($opt_r) {
	$transpose = 'transpose=1'.(', transpose=1'x($opt_r-1));
	$transpose = '"'.$transpose.'"';
}

if ($opt_r) {
	system("ffmpeg -i $full_pic_name -vf $transpose $full_pic_name");
}

if ($? eq 0){
	print "$date: Captured the picture at $pic_name\n";
	print $full_pic_name;
}
