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
my $city = $q->param('city');


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
     or ($lat eq '') or ($long eq '') or ($name eq '') or !defined $city) {
    print $q->header();
    print $q->start_html();
    print $q->h1("all fields required");
    print $q->end_html;
    exit;
}

$name = encode_html($name);

my $sth = $dbh->prepare('INSERT INTO views(lat,long,name,cityid) VALUES (?,?,?,?)');
$sth->execute($lat, $long, $name, $city);
$sth->finish;


$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => '/editdb.pl');



