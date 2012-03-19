#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);
my $lid = $q->param('lid');

if ($uid == -1) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

if (!defined $lid) {
    form_error($q, "location ID not defined");
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

my @tags = get_tags($dbh, $lid);

my $sth = $dbh->prepare("SELECT lat,long,name,address,type,price,phone,website,description FROM locations WHERE lid = ?");
$sth->execute($lid);

if (my @row = $sth->fetchrow_array()) {
    my ($lat,$long,$name,$address,$type,$price,$phone,$website,$description) = @row;
    $sth->finish;
    print_start($q, "Snaptinerary Database Page");
    print_top($uid);



    print "<div class='maincontent'>";
    print "<h1 class='center'>Edit Location</h1>";
    
    print "
<form name='edit-location' class='formclass1' method='post' action='/post/edit-location.pl'>
<input type='hidden' name='lid' value='$lid' />
<table border='1'>
<tr>
<td>Name</td>
<td><input type='text' name='name' value='$name'/></td>
</tr>

<tr>
<td>Address(optional)</td>
<td><input type='text' name='address' value='$address'/></td>
</tr>

<tr>
<td>Type</td>
<td><input type='text' name='type' value='$type' />
</td>
</tr>

<tr>
<td>Price Class</td>
<td><input type='text' name='price' value='$price' />
</td>
</tr>

<tr>
<td>Latitude</td>
<td><input type='text' name='lat' value='$lat'/></td>
</tr>

<tr>
<td>Longitude</td>
<td><input type='text' name='long' value='$long'/></td>
</tr>

<tr>
<td>Phone (optional, digits only)</td>
<td><input type='text' name='phone' value='$phone'/></td>
</tr>

<tr>
<td>Website (optional)</td>
<td><input type='text' name='website' value='$website'/></td>
</tr>

<tr>
<td>Description (optional)</td>
<td><textarea name='description' rows='10' cols='80'>$description</textarea></td>
</tr>




<tr>
<td>Add Tags (e.g.: brunch,cashonly,chinese,asian,dimsum)</td>
<td><input type='text' name='tags' value=''/></td>
</tr>


</table>
<button type='submit' name='submit'>Edit Location</button>
</form>


<table border='1'>

<tr>
<td>Tags</td>
<td>";
    


    while (my $idx = shift @tags) {
        my $tid = shift @tags;
        my $tag = shift @tags;
        #
        print "
<form name='edit-tag' method='post' action='/post/delete-tag.pl'>
<a href='/edit-tag.pl?tid=$tid'>$tag</a>
<input type='hidden' name='idx' value='$idx' />
<input type='hidden' name='lid' value='$lid' />
<button type='submit' name='submit' style='float: none; padding: 0 0 0 0; display: inline; font-size: 12px; height: 22px'>Delete</button>
</form>
";
        
    }

print "</td>
</tr>
</table>
";

    print "</div>";


    print "<div class='maincontent'>";
    print "<table border='1'><thead><th>Value</th><th>Price Class</th></thead>";
    print "<tr><td>1</td><td>Cheap</td></tr>";
    print "<tr><td>2</td><td>Budget</td></tr>";
    print "<tr><td>3</td><td>Pricy</td></tr>";
    print "<tr><td>4</td><td>Exclusive</td></tr>";
    print "</table>";

    print "<table border='1'><thead><th>Value</th><th>Location Type</th></thead>";
    print "<tr><td>100</td><td>Lodging</td></tr>";
    print "<tr><td>200</td><td>Food</td></tr>";
    print "<tr><td>300</td><td>Activity</td></tr>";
    print "</table>";

    print "</div>";

print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;

} else {
    form_error($q, "location ID not found");
}









