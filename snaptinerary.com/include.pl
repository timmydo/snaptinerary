#!/usr/bin/perl -wT

use strict;
use DBI;

sub db_connect {
    return DBI->connect("DBI:Pg:dbname=snaptinerary;port=5433", undef, undef, {RaiseError => 1, AutoCommit => 0});
}

sub check_session {
    my ($q, $dbh) = @_;
    my $sid = $q->cookie('sid');
    my $sth = $dbh->prepare("SELECT users.uid,displayname FROM sessions JOIN users ON users.uid = sessions.uid WHERE cookie = ?");
    $sth->execute($sid);
    
    my $uid = -1;
    my $displayname = '';

    if (my @row = $sth->fetchrow_array()) {
        ($uid, $displayname) = @row;
    } 

    $sth->finish;

    return ($sid, $uid, $displayname);
}


sub like_bar {
print "<div class='maincontent'>

<div id=\"fb-root\"></div>
<script type=\"text/javascript\">
//<![CDATA[
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement(s); js.id = id;
  js.src = \"//connect.facebook.net/en_US/all.js#xfbml=1\";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
//]]></script>

<div class=\"fb-like-box\" data-href=\"http://www.facebook.com/pages/Railinator/249175798459521\" data-width=\"292\" data-show-faces=\"false\" data-stream=\"false\" data-header=\"false\"></div>

<div class=\"g-plusone\" data-annotation=\"inline\"></div>
</div>
";
}




sub return_analytics {
return "
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-25864870-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
";
}


sub print_logo {
    print "<div class='snaptinerary'>Snaptinerary</div>";
}

sub print_navbar {
    my ($uid) = @_;
    print "<div class='navbar'><ul>";
    print "<li><a href='/index.pl'>Start</a></li>";
#    print "<li><a href='/features.pl'>Features</a></li>";
    if (defined $uid and "$uid" ne "-1") {
#        print "<li><a href='/logout.pl'>Logout</a></li>";
    } else {
#        print "<li><a href='/'>Login</a></li>";
    }
    print "</ul></div><br />";
}

sub print_top {
    my ($uid) = @_;
    print "<div class='topheader'>";
    print_logo();
    print_navbar($uid);
    print "</div>";
}

sub print_start {
# $html is accumulator for HTML string

    my ($q,$desc) = @_;
    if (!defined $desc) {
        $desc = 'Snaptinerary quick itinerary planner';
    }
    print $q->header(-type=>'text/html', -charset=>'utf-8');
    print "<!DOCTYPE html> 
<html> 
<head> 
<meta charset='UTF-8'> 
<title>Snaptinerary.com: $desc</title> 
<meta name='keywords' content='itinerary, itinerary creator, itinerary maker, trip planner'> 
<meta name='author' content='Timmy Douglas'> 
<meta name='description' content='$desc' /> 
<link rel='stylesheet' type='text/css' href='/css/style.css' /> 
<link rel='stylesheet' type='text/css' href='/css/date.css' /> 
<script src='/jquery-1.6.4.min.js' type='text/javascript'></script>
<script src='/jquery.tools.min.js' type='text/javascript'></script>

<script type='text/javascript'>//<![CDATA[
 
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-26731006-1']);
  _gaq.push(['_trackPageview']);
 
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
 
//]]></script> 
<script type='text/javascript' src='http://apis.google.com/js/plusone.js'></script>
</head>";

}




sub print_footer {

    my ($uid) = @_;
    if ($uid == -1) {
print "
<div class='footerstyle1' style='font-size: 14px;'>
<a href='/index.pl'>Start</a>
<br />
<br />
Copyright&copy; 2011 Snaptinerary. All Rights Reserved.
</div>
";
    } else {
print "
<div class='footerstyle1' style='font-size: 14px;'>
<a href='/index.pl'>Start</a>
<br />
<br />
Copyright&copy; 2011 Snaptinerary. All Rights Reserved.
</div>
";
    }


}

return 1;

