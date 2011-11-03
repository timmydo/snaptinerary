#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";
#require "./include/db.pl";
#require "./include/mainbar.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname) = check_session($q, $dbh);


print_start($q, "Snaptinerary Start Page");
print_top($uid);
print '<script type="text/javascript">
//<![CDATA[
function handleKey(label, input) {
   var mylabel = document.getElementById(label);
   var myinput = document.getElementById(input);
   mylabel.innerHTML = \'\';

}

function describeValue(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Cheapest option"; break;
        case "2": str = "Budget option"; break;
        case "3": str = "Good option"; break;
        case "4": str = "Luxury option"; break;
      default: break;
    }
    document.getElementById(id).innerHTML=str;
}

function describePeople(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Just me"; break;
      default: str = value + " people"; break;

    }
    document.getElementById(id).innerHTML=str;
}

</script>
';


print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip</h1>
<h5 class='center'>Millions of ideas--just one click away</h5>";


print "<form name='plan-form' class='formclass1' method='post' action='/plan.pl'>
<div style='overflow: auto'>
<div class='inputwrap'>
    <label for='location_input' id='location_label'>Destination</label>

<input type='text' id='location_input' name='email'
 onfocus=\"handleKey('location_label', 'location_input')\"/></div>
<br />

<div class='inputwrap'>
    <label for='date_input' id='date_label'>11/20 to 11/25</label>
 <input type='text' id='date_input' name='dates'
onfocus=\"handleKey('date_label', 'date_input')\" />
</div>
</div>


<div class='center'>
Guests: <input type='range' name='numpeople' min='1' max='8' step='1' value='1' onchange=\"describePeople('people_detail', this.value)\"/><span id='people_detail' style='position: absolute'>Just me</span>
</div>


<div class='center'>
Lodging: <input type='range' name='lodging' min='1' max='4' step='1' value='2' onchange=\"describeValue('lodging_detail', this.value)\"/><span id='lodging_detail' style='position: absolute'>Budget option</span>
</div>

<div class='center'>
Food: <input type='range' name='food' min='1' max='4' step='1' value='2' onchange=\"describeValue('food_detail', this.value)\"/><span id='food_detail' style='position: absolute'>Budget option</span>
</div>

<div class='center'>
Sightseeing/Events: <input type='range' name='events' min='1' max='4' step='1' value='3' onchange=\"describeValue('events_detail', this.value)\"/><span id='events_detail' style='position: absolute'>Good option</span>
</div>

<button type='submit' name='submit'>Search</button>
</form>
";


print "</div>";

print_footer($uid);

#like_bar();

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
