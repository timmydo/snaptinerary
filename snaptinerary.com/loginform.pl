#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";


my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);

if ($uid != -1) {
    $q->redirect(-uri => "/index.pl");
    exit;
}

print_start($q, "Snaptinerary Login Page");
print_top($uid);

print "<div class='maincontent'>";
print "<h1 class='center'>Login</h1>";
print '<script type="text/javascript">
//<![CDATA[
function handleKey(label, input) {
   var mylabel = document.getElementById(label);
   var myinput = document.getElementById(input);
   mylabel.innerHTML = \'\';

}
function formLoad() {
var fo = document.forms["login-form"];
var fee = fo.elements["email"];
var fep = fo.elements["password"];

if (fee.value != "") {
  document.getElementById("email_label").innerHTML = "";
}
if (fep.value != "") {
  document.getElementById("password_label").innerHTML = "";
}

}
//]]></script>
';



print "
<form name='login-form' class='formclass1' method='post' action='/post/login.pl' onload='formLoad()'>
<div class='center'>
<div class='inputwrap'>
    <label for='email_input' id='email_label'>Email</label>
<input type='text' id='email_input' name='email'
 onfocus=\"handleKey('email_label', 'email_input')\"
/>
</div>
</div>

<div class='center'>
<div class='inputwrap'>
    <label for='password_input' id='password_label'>Password</label>
<input type='password' id='password_input' name='password'
 onfocus=\"handleKey('password_label', 'password_input')\"
/>
</div>
</div>

<button type='submit' name='submit'>Login</button>
</form>
";



print "</div>";



print_footer($uid, $status);

#like_bar();

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
