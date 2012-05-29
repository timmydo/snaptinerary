#!/usr/bin/perl -wT

use strict;
use CGI;

my $q = CGI->new;
print $q->redirect(-uri => "/find-event.pl?type=0");

