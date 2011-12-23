#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $location = $q->param('location');
my $numdays = $q->param('time');
my $numpeople = $q->param('numpeople');
my $lodging = $q->param('lodging');
my $food = $q->param('food');
my $events = $q->param('events');
my $schedule = $q->param('schedule');


print_start($q, "Snaptinerary");
print_top($uid);
print "<script type=\"text/javascript\">
//<![CDATA[

Array.prototype.removeItems = function(itemsToRemove) {

    if (!/Array/.test(itemsToRemove.constructor)) {
        itemsToRemove = [ itemsToRemove ];
    }

    var j;
    for (var i = 0; i < itemsToRemove.length; i++) {
        j = 0;
        while (j < this.length) {
            if (this[j] == itemsToRemove[i]) {
                this.splice(j, 1);
            } else {
                j++;
            }
        }
    }
}


function refreshTagListing(label, location, tag) {
  var mylabel = document.getElementById(label);
  var taghtml = '';

  \$.each(sttags[location], function(i, item) {
    taghtml += \" <a href='#' onclick=\\\"removeTag('\"+ label + \"', '\"+ location +\"', '\" + item + \"'); return false;\\\">\" + item + \"</a>\";
  });

  mylabel.innerHTML = taghtml;
}

function addTag(label, location, tag) {
  sttags[location].removeItems([tag]);
  sttags[location].push(tag);
  refreshTagListing(label, location, tag);
}

function removeTag(label, location, tag) {
  sttags[location].removeItems([tag]);
  refreshTagListing(label, location, tag);
}


function refreshLocation(label, mytype, mylowprice, myhighprice, tagname) {
  var mylabel = document.getElementById(label);
  var notags = sttags[tagname].join(',');
  mylabel.innerHTML = 'loading...';
  \$.getJSON(\"find-place.pl\", 
            {type: mytype, lowprice: mylowprice, highprice: myhighprice, no: notags},
            function(data) {
              var taghtml = '';
              \$.each(data.tags, function(i, item) {
                                taghtml += \" <a href='#' onclick=\\\"addTag('\"+ label + \"_no', '\"+ tagname +\"', '\"+item.tag+\"'); return false;\\\">\" + item.tag + \"</a>\";
                                });
              mylabel.innerHTML = data.name + taghtml;
            });

}


\$(document).ready(function() {
sttags = {};
sttags['hotel'] = [];
refreshLocation(\'hotelarea\', 100, $lodging, $lodging, 'hotel');

});

//]]></script>
";


if ($location eq '') {
    $location = 'New York City';
}
print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip to $location</h1>";
print "<!-- $numpeople/$lodging/$food/$schedule -->";
print "Staying in hotel: ";
print "<span id='hotelarea'>hotel area</span> (<a href='#' onclick=\"refreshLocation('hotelarea', 100, $lodging, $lodging, 'hotel'); return false;\">Change</a>)";
print " (None with the tags: <span id='hotelarea_no'></span>)";
print "</div>";

for (my $i = 1; $i < $numdays+1; $i++) {
    print "<div class='maincontent'>";
    print "<h1 class='center'>Day $i</h1>";

    print "Lunch at <span id='day_$i-lunch'>food area</span> (<a href='#' onclick=\"refreshLocation('day_$i-lunch', 200, $food-1, $food, 'lunch_tags_$i'); return false;\">Change</a>)";
    print " (None with the tags: <span id='day_$i-lunch_no'></span>)";
    print "<br/><br/>";

    print "Afternoon event: <span id='day_$i-afternoon'>event area</span> (<a href='#' onclick=\"refreshLocation('day_$i-afternoon', 300, $events-1, $events, 'afternoon_tags_$i'); return false;\">Change</a>)";
    print " (None with the tags: <span id='day_$i-afternoon_no'></span>)";
    print "<br/><br/>";

    print "Dinner at <span id='day_$i-dinner'>food area</span> (<a href='#' onclick=\"refreshLocation('day_$i-dinner', 200, $food-1, $food, 'dinner_tags_$i'); return false;\">Change</a>)";
    print " (None with the tags: <span id='day_$i-dinner_no'></span>)";
    print "<br/><br/>";

    print "Night event: <span id='day_$i-night'>event area</span> (<a href='#' onclick=\"refreshLocation('day_$i-night', 300, $events-1, $events, 'night_tags_$i'); return false;\">Change</a>)";
    print " (None with the tags: <span id='day_$i-night_no'></span>)";

    print "</div>";
    print "<script type='text/javascript'>
//<![CDATA[
\$(document).ready(function() {

sttags['lunch_tags_$i'] = [];
sttags['afternoon_tags_$i'] = [];
sttags['dinner_tags_$i'] = [];
sttags['night_tags_$i'] = [];

refreshLocation('day_$i-lunch', 200, $food-1, $food, 'lunch_tags_$i');
refreshLocation('day_$i-afternoon', 300, $events-1, $events, 'afternoon_tags_$i');
refreshLocation('day_$i-dinner', 200, $food-1, $food, 'dinner_tags_$i');
refreshLocation('day_$i-night', 300, $events-1, $events, 'night_tags_$i');
});
//]]></script>
";


}








print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
