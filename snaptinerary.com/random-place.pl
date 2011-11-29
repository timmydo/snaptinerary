#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $type = $q->param('type');

if (!defined $type) {
    $type = '200';
}

if ($type =~ /\d+/) {
} else {
    $type = '200';
}

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

print_start($q, "Snaptinerary Random Place Finder");
print_top($uid);

print "<div class='maincontent'>";
print "<ul>";

if ("$type" eq '100') {
    print "<li> Random lodging";
} else {
    print "<li> <a href='random-place.pl?type=100'>Random lodging</a>";
}
if ("$type" eq '200') {
    print "<li> Random restaurant";
} else {
    print "<li> <a href='random-place.pl?type=200'>Random restaurant</a>";
}
if ("$type" eq '300') {
    print "<li> Random activity";
} else {
    print "<li> <a href='random-place.pl?type=300'>Random activity</a>";
}


print "</ul>";

print "</div>";
print "<div class='maincontent'>";
print "";


my $sth = $dbh->prepare("SELECT lid,lat,long,name,address,price,phone,website FROM locations WHERE type = ? ORDER BY random() LIMIT 1");
$sth->execute($type);


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
