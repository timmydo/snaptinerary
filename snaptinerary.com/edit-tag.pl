#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);
my $tid = $q->param('tid');

if ($uid == -1) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

if (!defined $tid) {
    form_error($q, "location ID not defined");
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    $q->redirect(-uri => "/index.pl");
    exit;
}

my $tag = 'error';
my $description = 'error';

print_start($q, "Snaptinerary Database Page");
print_top($uid);

print "<div class='maincontent'>";
print "<h1 class='center'>Edit Tag</h1>";


my $sth = $dbh->prepare("SELECT tag,description FROM tags WHERE tid = ?");
$sth->execute($tid);
if (my @row = $sth->fetchrow_array()) {
    ($tag,$description) = @row;
    if (!defined $description) {
        $description = '';
    }
    print "<form name='edit-tag' class='formclass1' method='post' action='/post/edit-tag.pl'>
<input type='hidden' name='tid' value='$tid' />
<table border='1'>
<tr>
<td>Name</td>
<td><input type='text' name='tagname' value='$tag'/></td>
</tr>

<tr>
<td>Description</td>
<td><input type='text' name='description' value='$description'/></td>
</tr>
</table>
<button type='submit' name='submit'>Edit Tag</button>
</form>
";
}
$sth->finish;
print "</div>";



print "<div class='maincontent'>";
print "<h1 class='center'>Tagged Locations</h1>";

$sth = $dbh->prepare("SELECT tagged.lid,locations.name FROM tagged INNER JOIN locations ON locations.lid = tagged.lid WHERE tagged.tagid = ?");
$sth->execute($tid);

while (my @row = $sth->fetchrow_array()) {
    my ($lid, $locname) = @row;
    print "<a href='/edit-location.pl?lid=$lid'>$locname</a> <br/>";
}
$sth->finish;

print "</div>";



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;


