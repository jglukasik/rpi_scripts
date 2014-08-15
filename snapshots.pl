#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($opt_r) = 0;

# TODO: make more options 
GetOptions 
	( "rotate" => \$opt_r
	);
	
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

# FIXME: make sure i'm grabing a still frame in a sensible way
system("ffmpeg -f video4linux2 -vframes 1 -i /dev/video0 $full_pic_name");
if ($opt_r) {
	system("ffmpeg -i $full_pic_name -vf \"transpose=1, transpose=1\" $full_pic_name");
}

if ($? eq 0){
	print "$date: Captured the picture at $pic_name\n";
	print $full_pic_name;
}
