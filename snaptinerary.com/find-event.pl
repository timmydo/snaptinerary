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
if ($type =~ /\d+/) {
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
my $query = "SELECT lid,lat,long,name,address,price,phone,website FROM locations WHERE type = ? AND cityid = ? ORDER BY price ASC";

# allow type=0 to query all places
if ($type eq '0') {
    $query =~ s/type =/type !=/;
}

my $sth = $dbh->prepare($query);

my $locationList = '';

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

    $locationList .= "<li><a href='#' onclick='setMapCenterLatLong($lat,$long); displayPinDetailsById($lid); return false;'>$name</a> ($pricestring)</li>";

}
$sth->finish;
print "];";


print "
function getBingMap() {

        bingmap = new Microsoft.Maps.Map(document.getElementById('myBingMap'), {credentials: 'AjJyM22LNY_p9azio12YJAxnIL2wg85psHglwhqucak5rMAvQkyKdu-10KA1NGpY', zoom: 16});
        
}

function displayPinDetails(item) {
\$('#locationDetails').html('<h1>' 
+ '<a href=\"/place-info.pl?lid='+ item.lid + '\">' + item.name + '</a> (' + item.price + ') </h1>'
+ '<h2>'+ item.phone + '</h2>'
+ '<h2><a href=\"' + item.website + '\">'+ item.displaywebsite + '</a></h2>'
+ '<h3>' + item.address + '</h3>'
);


}

function displayPinDetailsById(id) {
  jQuery.each(pushpins, function(index, item) {
      if (item.lid == id) displayPinDetails(item);
    });

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


function setMapCenterLatLong(lat, long) {
    setMapCenter(new Microsoft.Maps.Location(lat, long));
}

function setMapCenter(myloc) {
    var options = bingmap.getOptions();
    options.center = myloc;
    bingmap.setView(options);
}

mylocation = new Microsoft.Maps.Location(40.7697, -73.9735);

function getMyLocation() {
setMapCenter(mylocation);
if (navigator.geolocation) {
	navigator.geolocation.getCurrentPosition(function (position) {
            mylocation = new Microsoft.Maps.Location(position.coords.latitude, position.coords.longitude);
            var pin = new Microsoft.Maps.Pushpin(mylocation, {text: 'Me', typeName: 'pushpinStyleMe'});
            bingmap.entities.push(pin);
	}, 
	function (error) {
          // fixme hardcoded cityid coordinates

          }
        );
}
}


\$(document).ready(function() {
getBingMap();
addPins();
getMyLocation();
});
//]]></script>

";


# the view table

$sth = $dbh->prepare("SELECT lat,long,name FROM views WHERE cityid = ? ORDER BY name");
$sth->execute($city);
print "<div class='maincontent' id='viewList'>";
print "<h3><a href='#' onclick='setMapCenter(mylocation); return false;'>My Location</a></h3>";
print "<ul>";
while (my @row = $sth->fetchrow_array()) {
    my ($lat,$long,$name) = @row;
    print "<li><a href='#' onclick='setMapCenterLatLong($lat,$long);return false;'>$name</a></li>";
}
$sth->finish;

print "</ul></div>";



# the map

print "<div class='maincontent' style='height: 500px;'>";

print "<div id='myBingMap' style='position:relative; width:100%; height:100%;'>bing map</div>";

print "</div>";

# the location detail pane

print "<div class='maincontent' id='locationDetails'></div>";

# the location list pane

print "<div class='maincontent' id='locationList'><ul>$locationList</ul></div>";



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
