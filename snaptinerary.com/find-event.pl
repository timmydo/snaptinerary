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

print "<script type='text/javascript' src='http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0'></script>";


    print "<script type='text/javascript'>//<![CDATA[

var bingmap = null;

var pushpins = [";


# output all the restaurant stuff

my $sth = $dbh->prepare("SELECT lid,lat,long,name,address,price,phone,website FROM locations WHERE type = ? AND cityid = ?");
$sth->execute($type, $city);
while (my @row = $sth->fetchrow_array()) {
    my ($lid,$lat,$long,$name,$address,$price,$phone,$website) = @row;
    my $displaywebsite = $website;
    if ($website !~ /^http/) {
        $website = 'http://' . $website;
    }
    $displaywebsite =~ s{http[s]?://}{}g;
    my $pricestring = '$' x int($price);

    print "{";
    print "\"lid\": \"$lid\",\n";
    print "\"name\": \"$name\",\n";
    print "\"lat\": \"$lat\",\n";
    print "\"long\": \"$long\",\n";
    print "\"price\": \"$pricestring\",\n";
    print "\"phone\": \"$phone\",\n";
    print "\"address\": \"$address\",\n";
    print "\"website\": \"$website\",\n";
    print "\"displaywebsite\": \"$displaywebsite\",\n";
    print "},";
}
$sth->finish;
print "];";


print "
function getBingMap() {
      // fixme hardcoded cityid coordinates
       var bingpos = new Microsoft.Maps.Location(40.7697, -73.9735); 

        bingmap = new Microsoft.Maps.Map(document.getElementById('myBingMap'), {credentials: 'AjJyM22LNY_p9azio12YJAxnIL2wg85psHglwhqucak5rMAvQkyKdu-10KA1NGpY', zoom: 12, center: bingpos});
        
}

function displayPinDetails(item) {
\$('#locationDetails').html('<h1>' 
+ '<a href=\"/place-info.pl?lid='+ item.lid + '\">' + item.name + '</a> (' + item.price + ') </h1>'
+ '<h2>'+ item.phone + '</h2>'
+ '<h2><a href=\"' + item.website + '\">'+ item.displaywebsite + '</a></h2>'
+ '<h3>' + item.address + '</h3>'
);


}

function addPins() {
  
  jQuery.each(pushpins, function(index, item) {
      var pin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(item.lat, item.long), {text: item.name.replace('&amp;','&'), typeName: 'pushpinStyle'});
      Microsoft.Maps.Events.addHandler(pin, 'click', function(e) {displayPinDetails(item)});
      bingmap.entities.push(pin);
    });
}
      
function setMapStyle() {
        //Microsoft.Maps.MapTypeId.auto: automatic, Microsoft.Maps.MapTypeId.road: road, Microsoft.Maps.MapTypeId.aerial: aerial, Microsoft.Maps.MapTypeId.birdseye: birdeye  
        bingmap.setView({mapTypeId : Microsoft.Maps.MapTypeId.road});
}


\$(document).ready(function() {
getBingMap();
addPins();
});
//]]></script>

";




print "<div class='maincontent' style='height: 500px;'>";

print "<div id='myBingMap' style='position:relative; width:100%; height:100%;'>bing map</div>";

print "</div>";

print "<div class='maincontent' id='locationDetails'></div>";



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
