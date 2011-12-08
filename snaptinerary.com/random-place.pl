#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";



my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $type = $q->param('type');
my $lowprice = $q->param('lp');
my $highprice = $q->param('hp');
my $notags = $q->param('no');
my $badtagstring = '';

if (!defined $type) {
    $type = '200';
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

if ($uid == -1) {
    $dbh->rollback;
    $dbh->disconnect;
    print $q->redirect(-uri => "/index.pl");
    exit;
}

if ($status < 100) {
    $dbh->rollback;
    $dbh->disconnect;
    print $q->redirect(-uri => "/index.pl");
    exit;
}

print_start($q, "Snaptinerary Random Place Finder");
print_top($uid);

print "<div class='maincontent'>";
print "<ul>";

print "<li> <a href='random-place.pl?type=100'>Random lodging</a>";
print "<li> <a href='random-place.pl?type=200'>Random restaurant</a>";
print "<li> <a href='random-place.pl?type=300'>Random activity</a>";

print "</ul>";

print "</div>";
print "<div class='maincontent'>";
print "";


print "$lowprice,$highprice, badtags = $badtagstring\n";

my $sth = $dbh->prepare("SELECT lid,lat,long,name,address,price,phone,website FROM locations WHERE type = ? AND price >= ? and price <= ?
 AND lid NOT IN (SELECT lid FROM tagged INNER JOIN tags ON tags.tid = tagged.tagid WHERE tag IN ($badtagstring))
 ORDER BY random() LIMIT 1");
$sth->execute($type, $lowprice, $highprice);



while (my @row = $sth->fetchrow_array()) {
    my ($lid,$lat,$long,$name,$address,$price,$phone,$website) = @row;
    print "Place: <a href='http://maps.google.com/maps?q=$lat,$long'>$name</a><br/> 
<a href='http://maps.google.com/maps?q=$address'>$address</a><br/>Price: ";
    print ('$' x $price);
    print "<br/>Phone: $phone<br/>Website: <a href='$website'>$website</a><br/>Tags: ";

    my @tags = get_tags($dbh, $lid);
        while (my $idx = shift @tags) {
        my $tid = shift @tags;
        my $tag = shift @tags;
        print "<a href='/edit-tag.pl?tid=$tid'>$tag</a> ";
        }
    print "<br/><br/>";
    print "<a href='edit-location.pl?lid=$lid'>Edit</a><br/>";
}

print "</div>";
$sth->finish;



print_footer($uid, $status);

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
