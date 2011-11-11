#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;
#use Captcha::reCAPTCHA;
use HTML::Entities;


require "../include.pl";


#my $c = Captcha::reCAPTCHA->new;
my $q = CGI->new;


my $email = $q->param('email');
my $password = $q->param('password');
my $verifypassword = $q->param('verifypassword');
my $displayname = $q->param('displayname');

#my $challenge = $q->param('recaptcha_challenge_field');
#my $response = $q->param('recaptcha_response_field');


if (!defined $email or !defined $password or !defined $displayname or !defined $verifypassword) {
    print $q->header();
    print $q->start_html();
    print $q->h1("email,password and display name required");
    print $q->end_html;
    exit;
}


if ($verifypassword ne $password) {
    print $q->header();
    print $q->start_html();
    print $q->h1("passwords didn't match");
    print $q->end_html;
    exit;
}

#private key
#my $captchaResult = $c->check_answer("6Lfig8ISAAAAAG7DiGJPFt0Ckhg-n1f8ibig09HM", $ENV{'REMOTE_ADDR'},
#                                     $challenge, $response);

$email = lc($email);
$password = crypt($password, $email);

my $dbh = db_connect();

my $sth = $dbh->prepare("SELECT uid FROM users WHERE email = ?;");
$sth->execute($email);
if (my $ref = $sth->fetchrow_hashref()) {
    print $q->header();
    print $q->start_html();
    print $q->h1("email already registered");
    print $q->end_html;
    $sth->finish;
    $dbh->rollback;
    $dbh->disconnect;
    exit;
}
$sth->finish;

encode_html($displayname);
# create account
my $sth2 = $dbh->prepare('INSERT INTO users(email,pw,displayname,status,creation) VALUES (?,?,?,1,current_timestamp);');
$sth2->execute($email, $password, $displayname);
$sth2->finish;


# find uid of new account
$sth2 = $dbh->prepare("SELECT uid FROM users WHERE email = ?;");
$sth2->execute($email);
my $uid = -1;
if (my $ref = $sth2->fetchrow_hashref()) {
    $uid = $ref->{'uid'};
}
$sth2->finish;

# create activation code
my $cookie = generate_random_string(30);
my $remoteAddr = $ENV{'REMOTE_ADDR'};
$remoteAddr =~ /([\w\d:.]+)/;
$remoteAddr = $1;

if ($uid != -1) {
#    $sth2 = $dbh->prepare('INSERT INTO activations(uid,cookie,ip,creation) VALUES (?,?,?,current_date);');
#    $sth2->execute($uid, $cookie, $remoteAddr);
#    $sth2->finish;

}
$dbh->commit;
$dbh->disconnect;

print $q->redirect(-uri => '/loginform.pl');



