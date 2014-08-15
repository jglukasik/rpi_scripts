#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;

my $pic_dir = '/home/pi/pi_sync/';
my $usb_dir = '/mnt/usb/pi/daily_pics/';

my $yesterday = DateTime->now( time_zone => 'America/Chicago' )->subtract( days => 1 )->ymd;

`cd $pic_dir && tar czf $yesterday.tar.gz $yesterday && mv $yesterday.tar.gz /mnt/usb/pi/daily_pics/`;
