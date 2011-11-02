#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";
#require "./include/db.pl";
#require "./include/mainbar.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname) = check_session($q, $dbh);


print_start($q, "Snaptinerary Start Page");
print_top($uid);


print "<div class='maincontent'>";
print "<h1 class='center'>Snaptinerary home</h1><br />Hello";
print "</div>";

print_footer($uid);

#like_bar();

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
