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
} else {
    print $q->redirect(-uri => "/index.pl");
    exit;
}

if ($enddate =~ m{(\d\d)/(\d\d)/(\d\d)}) {
} else {
    print $q->redirect(-uri => "/index.pl");
    exit;
}



print_start($q, "Snaptinerary");
print_top($uid);
print "<script type=\"text/javascript\">
//<![CDATA[
function refreshLocation(label, mytype, mylowprice, myhighprice) {
  var mylabel = document.getElementById(label);
  mylabel.innerHTML = \'loading...\';
  \$.getJSON(\"find-place.pl\", 
            {type: mytype, lowprice: mylowprice, highprice: myhighprice},
            function(data) {
              \$.each(data.tags, function(i, item) {
                                });
              mylabel.innerHTML=data.name;
            });

}


\$(document).ready(function() {
refreshLocation(\'hotelarea\', 100, $lodging, $lodging);

});

//]]></script>
";


my $numdays = 2;
if ($location eq '') {
    $location = 'New York City';
}
print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip to $location</h1>";
print "<!-- $numpeople/$lodging/$food/$schedule -->";
print "Staying in hotel: ";
print "<span id='hotelarea'>hotel area</span> (<a href='#' onclick=\"refreshLocation('hotelarea', 100, $lodging, $lodging)\">change hotel</a>)";
print "</div>";

for (my $i = 1; $i < $numdays+1; $i++) {
    print "<div class='maincontent'>";
    print "<h1 class='center'>Day $i</h1>";
    print "Lunch at <span id='day_$i-lunch'>food area</span> (<a href='#' onclick=\"refreshLocation('day_$i-lunch', 200, $food-1, $food)\">Change</a>)";
    print "<br/><br/>";
    print "Afternoon event: <span id='day_$i-afternoon'>event area</span> (<a href='#' onclick=\"refreshLocation('day_$i-afternoon', 300, $events-1, $events)\">Change</a>)";
    print "<br/><br/>";
    print "Dinner at <span id='day_$i-dinner'>food area</span> (<a href='#' onclick=\"refreshLocation('day_$i-dinner', 200, $food-1, $food)\">Change</a>)";
    print "<br/><br/>";
    print "Night event: <span id='day_$i-night'>event area</span> (<a href='#' onclick=\"refreshLocation('day_$i-night', 300, $events-1, $events)\">Change</a>)";
    print "</div>";
    print "<script type='text/javascript'>
//<![CDATA[
\$(document).ready(function() {
refreshLocation('day_$i-lunch', 200, $food-1, $food);
refreshLocation('day_$i-afternoon', 300, $events-1, $events);
refreshLocation('day_$i-dinner', 200, $food-1, $food);
refreshLocation('day_$i-night', 300, $events-1, $events);
});
//]]></script>
";


}








print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
