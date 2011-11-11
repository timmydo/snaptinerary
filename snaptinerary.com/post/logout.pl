#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "../include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname) = check_session($q, $dbh);

if ($uid != -1) {
    my $sth = $dbh->prepare("DELETE FROM sessions WHERE uid = ?;");
    $sth->execute($uid);
    $sth->finish;
}

print $q->redirect('/');
$dbh->commit;
$dbh->disconnect;



