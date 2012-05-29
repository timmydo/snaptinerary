#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";



my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $type = $q->param('type');
my $city = $q->param('city');
my $lowprice = $q->param('lp');
my $highprice = $q->param('hp');
my $notags = $q->param('no');
my $badtagstring = '';

if (!defined $type) {
    $type = '200';
}

if (!defined $city) {
    $city = '1';
}

if (!defined $notags) {
    $notags = '';
}

if (!defined $lowprice) {
    $lowprice = '0';
}
if (!defined $highprice) {
    $highprice = '5';
}


if ($type !~ /^\d+$/) {
    $type = '200';
}

if ($lowprice !~ /^\d+$/) {
    $lowprice = '0';
}
if ($highprice !~ /^\d+$/) {
    $highprice = '4';
}


if ($notags =~ /^[a-z]+([,][a-z]+)*$/) {
} else {
    $notags = '';
}

my @badtagarray = split /,/, $notags;
foreach (@badtagarray) {
    $badtagstring .= '\'' . $_ . '\',';
}

$badtagstring = substr($badtagstring, 0, -1);

if ($badtagstring eq '') {
    $badtagstring = '\'notag\'';
}

print $q->header(-type=>'text/html', -charset=>'utf-8');


my $query = "SELECT lid,lat,long,name,address,price,phone,website,description,cityid FROM locations WHERE type = ? AND cityid = ? AND price >= ? and price <= ?
 AND lid NOT IN (SELECT lid FROM tagged INNER JOIN tags ON tags.tid = tagged.tagid WHERE tag IN ($badtagstring))
 ORDER BY random() LIMIT 1";

# allow type=0 to query all places
if ($type eq '0') {
    $query =~ s/type =/type !=/;
}

my $sth = $dbh->prepare($query);
$sth->execute($type, $city, $lowprice, $highprice);

#print "$lowprice,$highprice, badtags = $badtagstring\n";
print "{\n";

while (my @row = $sth->fetchrow_array()) {
    my ($lid,$lat,$long,$name,$address,$price,$phone,$website,$description,$cityid) = @row;
    print "\"lid\": \"$lid\",\n";
    print "\"name\": \"$name\",\n";
    print "\"lat\": \"$lat\",\n";
    print "\"long\": \"$long\",\n";
    print "\"price\": \"$price\",\n";
    print "\"phone\": \"$phone\",\n";
    print "\"website\": \"$website\",\n";
    print "\"description\": \"$description\",\n";
    print "\"cityid\": \"$cityid\",\n";
    print "\"tags\": [";
    my @tags = get_tags($dbh, $lid);
    while (my $idx = shift @tags) {
        my $tid = shift @tags;
        my $tag = shift @tags;
        print "{\"tid\": \"$tid\", \"tag\": \"$tag\"}";
        if (@tags) {
            print ", ";
        }
    }
    print "]\n";
}

print "}\n";

$sth->finish;
$dbh->rollback;
$dbh->disconnect;
