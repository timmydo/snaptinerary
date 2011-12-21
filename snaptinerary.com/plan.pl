#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $location = $q->param('location');
my $startdate = $q->param('startdate');
my $enddate = $q->param('enddate');
my $numpeople = $q->param('numpeople');
my $lodging = $q->param('lodging');
my $food = $q->param('food');
my $events = $q->param('events');
my $schedule = $q->param('schedule');


if ($startdate =~ m{(\d\d)/(\d\d)/(\d\d)}) {
}



print_start($q, "Snaptinerary");
print_top($uid);
print '<script type="text/javascript">
//<![CDATA[
function refreshLocation(label, mytype, mylowprice, myhighprice) {
   var mylabel = document.getElementById(label);
   mylabel.innerHTML = \'blah\';
$.get(
  "find-place.pl",
  {type: mytype, lowprice: mylowprice, highprice: myhighprice},
  function(data) {mylabel.innerHTML=data;},
  "text"
);

}


//]]></script>
';




print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip to $location</h1>";
print "$numpeople/$lodging/$food/$schedule";
print "<a href='#' onclick=\"refreshLocation('area1', 100, $lodging, $lodging)\">refresh hotel</a><table border='1'><div id='area1'>hotel area</div></table>";
print "<a href='#' onclick=\"refreshLocation('area2', 200, $food-1, $food)\">refresh food</a><table border='1'><div id='area2'>food area</div></table>";
print "<a href='#' onclick=\"refreshLocation('area3', 300, $events-1, $events)\">refresh event</a><table border='1'><div id='area3'>event area</div></table>";



print "</div>";





print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
