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
my $lat = $q->param('lat');
my $lon = $q->param('lon');
my $pageno = $q->param('pageno');

if (!defined $city or $city eq '') {
    $city = '1';
}

if (!defined $type or $type eq '') {
    $type = '200';
}

if (!defined $pageno) {
    $pageno = 1;
}

if ($pageno =~ /\d+/) {
    $pageno = int($pageno);
} else {
    $pageno = 1;
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
function mapServiceProvider(latitude,longitude)
{
    document.nearbyform.lat.value = latitude;
    document.nearbyform.lon.value = longitude;
}

\$(document).ready(function() {
if (navigator.geolocation) {
	navigator.geolocation.getCurrentPosition(function (position) {  
	  mapServiceProvider(position.coords.latitude,position.coords.longitude);
	}, 
	function (error) {alert ('nope');}
        );
}
});
//]]></script>
";


print "<div class='maincontent'>";
print "<h1 class='center'>Nearby Restaurants in $location</h1>";
print "<form name='nearbyform' method='get' action='/find-nearby.pl'>";
print "<input type='hidden' name='city' value='1'>";
print "<input type='hidden' name='type' value='200'>";
print "Latitude: <input type='text' name='lat' value='$lat'/><br/>";
print "Longitude: <input type='text' name='lon' value='$lon'/><br/>";
print "<button type='submit'>Search</button></form>";

print "</div>";

# display a list of places if we have all the data entered
if (defined $lat and defined $lon) {
print "<div class='maincontent'>";
my $sth = $dbh->prepare("
SELECT lid,name,address,price,description,distance FROM
    (SELECT lid,type,cityid,name,address,price,description,cast(sqrt((69.1 * (?-lat))^2 + (53.0 * (?-long))^2) AS int) AS \"distance\" FROM locations) as locs
 WHERE type = ? AND cityid = ?
 ORDER BY distance LIMIT 10");
$sth->execute($lat, $lon, $type, $city);


print "\n<table><tr><th>Distance</th><th>Name</th><th>Address</th><th>Price</th>";

while (my @row = $sth->fetchrow_array()) {
    my ($lid, $name, $address, $price, $desc, $distance) = @row;
    print "<tr><td>$distance miles</td><td><a href='/place-info.pl?lid=$lid'>$name</a></td><td>$address</td><td>";
    print '$' x int($price);
    print "</td>";
    print "</tr>";
}
print "</table>";

$sth->finish;

if ($pageno > 1) {
#fixme
print "<a href='find-nearby?'>Previous fixme</a>";
}


print "</div>";

}


print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
