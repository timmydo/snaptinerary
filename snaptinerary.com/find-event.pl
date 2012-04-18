#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $city = $q->param('city');
my $type = $q->param('type');

if (!defined $city or $city eq '') {
    $city = '1';
}

if (!defined $type or $type eq '') {
    $type = '200';
}
if ($type =~ /[123]00/) {
    # good
} else {
    $type = '200';
}

my $location = cityName($city);


print_start($q, "Snaptinerary");
print_top($uid);
print "<script type=\"text/javascript\">
//<![CDATA[

cityid = '$city';
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
            {type: mytype, lowprice: mylowprice, highprice: myhighprice, no: notags,city: cityid},
            function(data) {
              var taghtml = '';
              \$.each(data.tags, function(i, item) {
                                taghtml += \" <a href='#' onclick=\\\"addTag('\"+ label + \"_no', '\"+ tagname +\"', '\"+item.tag+\"'); return false;\\\">\" + item.tag + \"</a>\";
                                });
              mylabel.innerHTML = \"<a href='/place-info.pl?lid=\" + data.lid + \"'>\" + data.name + \"</a><br/>\" + data.description + \"<br/>\" + taghtml;
            });

}


\$(document).ready(function() {
sttags = {};
});

//]]></script>
";


print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip to $location</h1>";
print "<span id='place'>food area</span> (<a href='#' onclick=\"refreshLocation('place', $type, 0, 4, 'place_tags'); return false;\">Change</a>)";
print " (None with the tags: <span id='place_no'></span>)";
print "<br/><br/>";


print "</div>";


print "<script type='text/javascript'>
//<![CDATA[
\$(document).ready(function() {

sttags['place_tags'] = [];
refreshLocation('place', $type, 0, 4, 'place_tags');
});
//]]></script>
";



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
