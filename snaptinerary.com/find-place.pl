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

print $q->header(-type=>'text/html', -charset=>'utf-8');



my $sth = $dbh->prepare("SELECT lid,lat,long,name,address,price,phone,website FROM locations WHERE type = ? AND price >= ? and price <= ?
 AND lid NOT IN (SELECT lid FROM tagged INNER JOIN tags ON tags.tid = tagged.tagid WHERE tag IN ($badtagstring))
 ORDER BY random() LIMIT 1");
$sth->execute($type, $lowprice, $highprice);

print "$lowprice,$highprice, badtags = $badtagstring\n";


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


}




$sth->finish;





$dbh->rollback;
$dbh->disconnect;
