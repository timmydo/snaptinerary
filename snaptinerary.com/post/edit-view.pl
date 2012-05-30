#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;
use HTML::Entities;


require "../include.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $name = $q->param('name');
my $lat = $q->param('lat');
my $long = $q->param('long');
my $vid = $q->param('vid');


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

if (!defined $name or !defined $lat or !defined $lat
    or !defined $vid
    or ($lat eq '') or ($long eq '') or ($name eq '')) {
    print $q->header();
    print $q->start_html();
    print $q->h1("all fields required");
    print $q->end_html;
    exit;
}

$name = encode_html($name);

my $sth = $dbh->prepare('UPDATE views SET lat=?,long=?,name=? WHERE vid = ?');
$sth->execute($lat, $long, $name, $vid);
$sth->finish;



$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => '/editdb.pl');



