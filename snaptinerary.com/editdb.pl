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
    $q->redirect(-uri => "/index.pl");
    exit;
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

print_start($q, "Snaptinerary Database Page");
print_top($uid);

print "<div class='maincontent'>";
print "<h1 class='center'>Edit DB</h1>";

print "
<form name='add-location' class='formclass1' method='post' action='/post/add-location.pl'>
<input type='text' id='name' name='name' />
<button type='submit' name='submit'>Add Location</button>
</form>
";



print "</div>";



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
