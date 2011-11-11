#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "../include.pl";


my $q = CGI->new;


my $email = $q->param('email');
my $password = $q->param('password');

if (!defined $email or !defined $password) {
    print $q->header();
    print $q->start_html('Login');
    print $q->h1("Must enter username and password.");
    print $q->end_html;
    exit;
}
$email = lc($email);
$password = crypt($password, $email);

my $dbh = db_connect();

my $sth = $dbh->prepare("SELECT uid,email,pw,status FROM users WHERE email = ?;");
$sth->execute($email);

my $loginSuccess = 0;
my $uid = -1;
my $status = -1;

if (my $ref = $sth->fetchrow_hashref()) {
    if ($ref->{'pw'} eq $password) {
        $loginSuccess = 1;
        $uid = $ref->{'uid'};
        $status = int($ref->{'status'});
    }
} else {
}



if ($loginSuccess && $status >= 1) {
    my $remoteAddr = $ENV{'REMOTE_ADDR'};
    $remoteAddr =~ /([\w\d:.]+)/;
    $remoteAddr = $1;
    my $cookie = generate_random_string(50);

    my $sth2 = $dbh->prepare('DELETE FROM sessions WHERE uid = ?;');
    $sth2->execute($uid);
    $sth2->finish;

    $sth2 = $dbh->prepare('INSERT INTO sessions(uid,ip,cookie,creation) VALUES (?,?,?,current_date);');
    $sth2->execute($uid, $remoteAddr, $cookie);
    $sth2->finish;
    my $sessionCookie = $q->cookie(-name=>'sid', -value=>$cookie);
    print $q->redirect(-cookie => $sessionCookie, -uri => '/index.pl');
} else {
    print $q->header();
    print $q->start_html('hello world');
    if ($status == 0) {
        print $q->h1("hi, \"$email\". Reply to account creation email first. ");
    } else {
        print $q->h1("hi, \"$email\". Login failed. ");
    }
    print $q->end_html;

}
$sth->finish;


$dbh->commit;
$dbh->disconnect;



