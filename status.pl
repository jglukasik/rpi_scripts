#!/usr/bin/perl
#
# Status monitoring script for my Rasperry Pi

use warnings;
use strict;
use Data::Dumper;

my $out_file = "/var/www/index.html";
open(my $fh, '>', $out_file) or die "Could not open file '$out_file' $!";

# Get uptime and load averages
my $uptime_result = `uptime`;
$uptime_result =~ s/^ +//;
my @uptime_data = split / +/, $uptime_result;
print Dumper \@uptime_data;
my $uptime = join(' ', $uptime_data[2], $uptime_data[3], $uptime_data[4]);
$uptime =~ s/,$//;
my $load_avgs = join(' ', $uptime_data[9], $uptime_data[10], $uptime_data[11]);
chomp($load_avgs);

# Find if nginx is running
my $nginx_up = (`service nginx status` !~ /failed/) ? 1 : 0;

# Find if ssh is running
my $ssh_up = (`service ssh status` !~ /failed/) ? 1 : 0;

# Find if nginx is running
my $cron_up = (`service cron status` !~ /failed/) ? 1 : 0;

# See if BitTorrent sync is running
my $btsync_up = `pgrep btsync` ? 1 : 0;

# Find number of processes
my $processes = `ps aux | wc -l` - 1;

# Find number of tmux sessions
my $tmux_num = `tmux ls | wc -l`;
chomp($tmux_num);

# Find cpu temp
my $cpu_temp = `cat /sys/class/thermal/thermal_zone0/temp`/1000;
$cpu_temp = $cpu_temp * 9/5 + 32; # Convert to F
$cpu_temp = sprintf "%.1f &deg;F", $cpu_temp; # Round to one decimal

# Find the gpu temp
my $gpu_temp = `/opt/vc/bin/vcgencmd measure_temp`;
chomp($gpu_temp);
$gpu_temp =~ s/temp=//;
$gpu_temp =~ s/'C//;
$gpu_temp = $gpu_temp * 9/5 + 32; # Convert to F
$gpu_temp = sprintf "%.1f &deg;F", $gpu_temp; # Round to one decimal

# Get memory usage
my $used_ram = `free -m | grep "buffers/cache" | awk '{print \$3}'`;
my $total_ram = `free -m | grep Mem | awk '{print \$2}'`;
chomp($total_ram);
my $percent_ram = $used_ram/$total_ram*100;
$percent_ram = sprintf "%.1f", $percent_ram;

# Get SD card usage
my @sd_data = split(' ', `df -h | grep rootfs`);
my $size_sd = $sd_data[1];
my $used_sd = $sd_data[2];
my $percent_sd = $sd_data[4];

# Get USB card usage
my @usb_data = split(' ', `df -h | grep usb`);
my $size_usb = $usb_data[1];
my $used_usb = $usb_data[2];
my $percent_usb = $usb_data[4];

# Get the last picture taken
my $pic_dir = "/home/pi/pi_sync/";
my $date = `date -I`;
chomp($date);
my $last_pic = `ls $pic_dir$date | grep jpg | tail -1`;
$last_pic =~ s/\.jpg\n//;

sub proc_style {
	return $_[0] ? 'class="success"' : 'class="danger"';
}

sub proc_status {
	return $_[0] ? "online" : "offline";
}

print $fh <<HTML;
<!DOCTYPE html>

<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>jgL Raspberry Pi</title>
   <link rel="stylesheet" href="static/css/bootstrap.css" type="text/css"/>
  </head>

<body>

<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
  <div class="container">

    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#">jgLukasik</a>
    </div>

    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li><a href="http://www.jglukasik.com">Home</a></li>
        <li><a href="http://tv.jglukasik.com">TV</a></li>
        <li><a href="http://blog.jglukasik.com">Blog</a></li>
        <li class="active"><a href="http://pi.jglukasik.com">Pi</a></li>
      </ul>
    </div>

  </div>
</div>

<div class="panel panel-default col-md-6 col-md-offset-3">
  <table class="table">
    <tr>
      <td> Uptime </td>
      <td> $uptime </td>
    </tr>
    <tr>
      <td> Load Averages </td>
      <td> $load_avgs </td>
    </tr>
  </table>
</div>
<p>
<div class="panel panel-default col-md-6 col-md-offset-3">
  <table class="table">
    <tr>
      <td> CPU Temp</td>
      <td> $cpu_temp </td>
    </tr>
    <tr>
      <td> GPU Temp </td>
      <td> $gpu_temp </td>
    </tr>
  </table>
</div>
<p>
<div class="panel panel-default col-md-6 col-md-offset-3">
<table class="table">
    <tr>
      <td> Last picture taken at: </td>
      <td> $last_pic </td>
    </tr>
  </table>
</div>
<p>

<div class="col-md-6 col-md-offset-3">
<table class="table">
    <thead>
    <tr ${\proc_style($ssh_up)}>
      <td> SSH: </td>
      <td> ${\proc_status($ssh_up)} </td>
    </tr>
    <tr ${\proc_style($nginx_up)}>
      <td> Nginx: </td>
      <td> ${\proc_status($nginx_up)} </td>
    </tr>
    <tr ${\proc_style($cron_up)}>
      <td> Cron: </td>
      <td> ${\proc_status($cron_up)} </td>
    </tr>
    <tr ${\proc_style($btsync_up)}>
      <td> BitTorrent Sync: </td>
      <td> ${\proc_status($btsync_up)} </td>
    </tr>
  </tbody> 
  </table>
</div>



<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
<script src="static/js/bootstrap.js"></script>

</body>

HTML
