#!/usr/bin/perl -wT

use strict;
use CGI;

require "./include.pl";

my $q = CGI->new;
my $uid = -1;


print_start($q, "Snaptinerary Create User Page");
print_top($uid);

print $q->h1("Create Account");
print "<form name='create-account-form' method='post' action='/post/create.pl'>
Display Name: <input type='text' name='displayname' /> <br />
Email: <input type='text' name='email' /> <br />
Password: <input type='password' name='password' /> <br />
Verify Password: <input type='password' name='verifypassword' /> <br />";

print "<button type='submit' name='submit-create'>Create</button></form>";
print "</div>";

print $q->end_html;



