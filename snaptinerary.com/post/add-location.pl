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
my $address = $q->param('address');
my $type = $q->param('type');
my $price = $q->param('price');
my $lat = $q->param('lat');
my $long = $q->param('long');
my $phone = $q->param('phone');
my $website = $q->param('website');
my $description = $q->param('description');
my $tags = $q->param('tags');


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

if (!defined $name or !defined $address or !defined $type or !defined $price or !defined $lat or !defined $lat
    or !defined $phone or !defined $website or !defined $tags or !defined $description
    or ($lat eq '') or ($long eq '') or ($name eq '')) {
    print $q->header();
    print $q->start_html();
    print $q->h1("all fields required");
    print $q->end_html;
    exit;
}

$address = encode_html($address);
$name = encode_html($name);
$phone = encode_html($phone);
$website = encode_html($website);
$description = encode_html($description);
$tags = encode_html($tags);


my $sth = $dbh->prepare('INSERT INTO locations(uid,lat,long,name,address,creation,type,price,phone,website,description) VALUES (?,?,?,?,?,current_timestamp,?,?,?,?,?)');
$sth->execute($uid, $lat, $long, $name, $address, $type, $price, $phone, $website, $description);
$sth->finish;


$sth = $dbh->prepare('SELECT lid FROM locations ORDER BY lid DESC LIMIT 1');
$sth->execute();
my $lid = -1;
if (my $ref = $sth->fetchrow_hashref()) {
    $lid = $ref->{'lid'};
}
$sth->finish;


$tags =~ s/\s+//g;
$tags = lc($tags);
my @newtags = split(/,/, $tags);
while (my $newtag = shift @newtags) {
    my $tagid = add_tag($dbh, $newtag);
    $sth = $dbh->prepare('INSERT INTO tagged(tagid,lid) VALUES (?,?)');
    $sth->execute($tagid, $lid);
    $sth->finish;

}


$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => '/editdb.pl');



