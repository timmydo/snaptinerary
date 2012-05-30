#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);
my $vid = $q->param('vid');

if ($uid == -1) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

if (!defined $vid) {
    form_error($q, "vid ID not defined");
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}


my $sth = $dbh->prepare("SELECT lat,long,name FROM views WHERE vid = ?");
$sth->execute($vid);

if (my @row = $sth->fetchrow_array()) {
    my ($lat,$long,$name,$address,$type,$price,$phone,$website,$description) = @row;
    $sth->finish;
    print_start($q, "Snaptinerary Database Page");
    print_top($uid);



    print "<div class='maincontent'>";
    print "<h1 class='center'>Edit View</h1>";
    
    print "
<form name='edit-view' class='formclass1' method='post' action='/post/edit-view.pl'>
<input type='hidden' name='vid' value='$vid' />
<table border='1'>
<tr>
<td>Name</td>
<td><input type='text' name='name' value='$name'/></td>
</tr>

<tr>
<td>Latitude</td>
<td><input type='text' name='lat' value='$lat'/></td>
</tr>

<tr>
<td>Longitude</td>
<td><input type='text' name='long' value='$long'/></td>
</tr>


</table>
<button type='submit' name='submit'>Edit View</button>
</form>
";

    print "</div>";


print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;

} else {
    form_error($q, "location ID not found");
}









