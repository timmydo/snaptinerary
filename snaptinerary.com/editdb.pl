#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

if ($uid == -1) {
    $dbh->rollback;
    $dbh->disconnect;
    print $q->redirect(-uri => "/index.pl");
    exit;
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    print $q->redirect(-uri => "/index.pl");
    exit;
}

print_start($q, "Snaptinerary Database Page");
print_top($uid);

print "<div class='maincontent'>";
print "<h1 class='center'>Edit DB</h1>";

print "
<form name='add-location' class='formclass1' method='post' action='/post/add-location.pl'>

<table border='1'>
<tr>
<td>Name</td>
<td><input type='text' name='name' /></td>
</tr>

<tr>
<td>Address(optional)</td>
<td><input type='text' name='address' /></td>
</tr>

<tr>
<td>City</td>
<td><select name='city'>
<option value='1'>NYC</option>
<option value='2'>Washington DC</option>
</select>
</td>
</tr>

<tr>
<td>Type</td>
<td><select name='type'>
<option value='100'>Lodging</option>
<option value='200'>Food</option>
<option value='300'>Activity</option>
</select>
</td>
</tr>

<tr>
<td>Price Class</td>
<td><select name='price'>
<option value='1'>Cheap</option>
<option value='2'>Budget</option>
<option value='3'>Pricy</option>
<option value='4'>Exclusive</option>
</select>
</td>
</tr>

<tr>
<td>Latitude</td>
<td><input type='text' name='lat' /></td>
</tr>

<tr>
<td>Longitude</td>
<td><input type='text' name='long' /></td>
</tr>

<tr>
<td>Phone (optional, digits only)</td>
<td><input type='text' name='phone' /></td>
</tr>

<tr>
<td>Website (optional)</td>
<td><input type='text' name='website' /></td>
</tr>

<tr>
<td>Description (optional)</td>
<td><input type='text' name='description' /></td>
</tr>

<tr>
<td>Add Tags (e.g.: brunch,cashonly,chinese,asian,dimsum)</td>
<td><input type='text' name='tags' value=''/></td>
</tr>


</table>
<button type='submit' name='submit'>Add Location</button>
</form>
";

print "</div>";



print "<div class='maincontent'>";
print "<h1 class='center'>DB Contents</h1>";
my $sth = $dbh->prepare("SELECT lid,users.displayname,lat,long,name,address,type,price,phone,website,description FROM locations INNER JOIN users on users.uid = locations.uid ORDER BY lid");
$sth->execute();

print "<table border='1'>";
print "<thead>
<th>Location ID</th><th>User</th><th>Latitude</th><th>Longitude</th><th>Name</th>
<th>Address</th><th>Type</th><th>Price</th><th>Phone</th><th>Website</th><th>Description</th><th>Options</th>
</thead>";
print "<tbody>";
while (my @row = $sth->fetchrow_array()) {
    my ($lid,$displayname,$lat,$long,$name,$address,$type,$price,$phone,$website,$description) = @row;
    print "<tr>
<td>$lid</td><td>$displayname</td><td>$lat</td><td>$long</td><td>$name</td>
<td>$address</td><td>";
    if ("$type" eq "100") {
        print "Lodging";
    } elsif ("$type" eq "200") {
        print "Food";
    } elsif ("$type" eq "300") {
        print "Activity";
    } else {
        print "$type";
    }
    print "</td><td>";
    print ('$' x $price);
    print "</td>
<td>$phone</td><td>$website</td><td>$description</td>
<td><a href='edit-location.pl?lid=$lid'>Edit</a></td>
</tr>";
}

print "</tbody></table>";
print "</div>";


print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
