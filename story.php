#!/usr/bin/php

<?php

include_once '/home/pi/php-snapchat/src/snapchat.php';
include_once '/home/pi/php-snapchat/credentials.php';

# Get the most recent timelapse picture
$date = `date -I`;
$date = chop($date);
$pic_dir = "/home/pi/pi_sync/".$date;
$recent_pic = `ls $pic_dir | grep jpg | tail -1`;
$pic_path = $pic_dir."/".$recent_pic;
$pic_path = chop($pic_path);

$snapchat = new Snapchat($username, $password);

# Get all friend usernames
$friend_usernames = array();
$friends = $snapchat->getFriends();
foreach ($friends as $friend) {
	$username = $friend->name;
	array_push($friend_usernames, $username);
}

$id = $snapchat->upload(
	Snapchat::MEDIA_IMAGE,
	file_get_contents($pic_path)
);

$snapchat->setStory($id, Snapchat::MEDIA_IMAGE, 1);

# For now, sends snap to all friends
#$snapchat->send($id, $friend_usernames, 2);

print "Sent picture $pic_path";

?>

