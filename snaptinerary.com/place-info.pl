#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);
my $lid = $q->param('lid');
my $displaywebsite = '';
my @tags = get_tags($dbh, $lid);

print_start($q, "Snaptinerary Place Information");
print_top($uid);

my $sth = $dbh->prepare("SELECT lat,long,name,address,type,price,phone,website,description FROM locations WHERE lid = ?");
$sth->execute($lid);

if (my @row = $sth->fetchrow_array()) {
    my ($lat,$long,$name,$address,$type,$price,$phone,$website,$description) = @row;
    my $nameescaped = encode_entities($name, '"&<>\'');

    print "<script type='text/javascript'
      src='http://maps.googleapis.com/maps/api/js?key=AIzaSyDDILpxDDz6m3lfL6eAtocIPH90B2LXpFU&sensor=false'></script>";

    print "<script type='text/javascript' src='http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0'></script>";

    print "<script type='text/javascript'>//<![CDATA[

var bingmap = null;

function getBingMap() {
       var bingpos = new Microsoft.Maps.Location($lat, $long); 

        bingmap = new Microsoft.Maps.Map(document.getElementById('myBingMap'), {credentials: 'AjJyM22LNY_p9azio12YJAxnIL2wg85psHglwhqucak5rMAvQkyKdu-10KA1NGpY', zoom: 16, center: bingpos});
        var pushpin= new Microsoft.Maps.Pushpin(bingpos, null); 
        bingmap.entities.push(pushpin);
}
      
function setMapStyle() {
        //Microsoft.Maps.MapTypeId.auto: automatic, Microsoft.Maps.MapTypeId.road: road, Microsoft.Maps.MapTypeId.aerial: aerial, Microsoft.Maps.MapTypeId.birdseye: birdeye  
        bingmap.setView({mapTypeId : Microsoft.Maps.MapTypeId.road});
}




\$(document).ready(function() {


var myLatlng = new google.maps.LatLng($lat, $long);

var myOptions = {
  center: myLatlng,
  zoom: 16,
  mapTypeId: google.maps.MapTypeId.ROADMAP
};
var map = new google.maps.Map(document.getElementById('map_canvas'), myOptions);

var marker = new google.maps.Marker({
      position: myLatlng,
      map: map,
      title:'$nameescaped'});

getBingMap();


});


//]]></script>
";

    print "<div class='maincontent'>";
    print "<h1>$name (" . ('$' x $price) . ")</h1>";
    print "<h2>$phone</h2>";
    $displaywebsite = $website;

    if ($website !~ /^http/) {
        $website = 'http://' . $website;
    }
    $displaywebsite =~ s{http[s]?://}{}g;

    print "<h2><a href='$website'>$displaywebsite</a></h2>";
#AIzaSyDDILpxDDz6m3lfL6eAtocIPH90B2LXpFU
    print "<h3>$address</h2>";
    print "<div>Tags: ";
    while (my $idx = shift @tags) {
        my $tid = shift @tags;
        my $tag = shift @tags;
        #
        print "$tag ";        
    }
    print "</div><br/><br/>";

    if ($description ne '') {
#    print "<div style='background-color: #e0e0e0;'>$description</div>";
    print "<div>$description</div><br/><br/>";
    }
 

    print "<div><h2>Google Maps</h2><div id='map_canvas' style='width: 640; height: 480'>map</div></div>";
    print "<div><h2>Bing Maps</h2><div id='myBingMap' style='position:relative; width:640px; height:480px;'>bing map</div></div>";
#    print "<div>
#         <input type='button' value='SetMapStyle' onclick='setMapStyle();' />
#      </div>";

    print "</div>";

} else {
print "<div class='maincontent'>";
print "<h1>Cannot find location</h1>";
print "</div>";
}



$sth->finish;


print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;










