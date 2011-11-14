#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;
use HTML::Entities;


require "../include.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $lid = $q->param('lid');
my $idx = $q->param('idx');


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

if (!defined $idx or !defined $lid) {
    print $q->header();
    print $q->start_html();
    print $q->h1("all fields required");
    print $q->end_html;
    exit;
}

my $sth = $dbh->prepare('DELETE FROM tagged WHERE lid = ? AND index = ?');
$sth->execute($lid, $idx);
$sth->finish;

$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => "/edit-location.pl?lid=$lid");



