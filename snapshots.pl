#!/usr/bin/perl

use strict;
use warnings;

my $base_dir = "/home/pi/";
my $pics_path = "pi_sync/";
my $pic_name;
my $full_pic_name;
my $date;

$date = `date -I`;
chomp $date;

if (! -d $base_dir.$pics_path.$date){
	# TODO don't try to make base_dir
	mkdir $base_dir.$pics_path.$date;
}

$pic_name = `date +'%H:%M:%S'`;
chomp $pic_name;
$full_pic_name = $base_dir.$pics_path.$date.'/'.$pic_name.'.jpg';
`ffmpeg -f video4linux2 -vframes 1 -i /dev/video0 $full_pic_name`;

if ($? eq 0){
	print "$date: Captured the picture at $pic_name\n";
	print $full_pic_name;
}
