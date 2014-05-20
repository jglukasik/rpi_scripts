<?php

date_default_timezone_set('America/Chicago');

$date = chop(`date -I`);
$pic_dir = "/home/pi/pi_sync/".$date;

$recent_pic = `ls $pic_dir | grep jpg | tail -1`;
$recent_pic = preg_replace('/.jpg/','',$recent_pic);
$last_pic_time = chop(strtotime($recent_pic));

$current_time = chop(`date +%s`);

if (($last_pic_time + 180) < $current_time){
	print "Timelapse not taking pictures! Last pic taken at: $recent_pic";
} else {
	print "Timelapse pictures ok!";
}

?>

