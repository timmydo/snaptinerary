#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;
use HTML::Entities;


require "../include.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

my $tid = $q->param('tid');
my $tag = $q->param('tagname');
my $description = $q->param('description');


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

if (!defined $tag or !defined $description or !defined $tid) {
    print $q->header();
    print $q->start_html();
    print $q->h1("all fields required");
    print $q->end_html;
    exit;
}

my $sth = $dbh->prepare('UPDATE tags SET tag = ?, description = ? WHERE tid = ?');
$sth->execute($tag, $description, $tid);
$sth->finish;

$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => "/edit-tag.pl?tid=$tid");



