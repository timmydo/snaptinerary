#!/usr/bin/perl -wT

use strict;
use CGI;
use DBI;

require "./include.pl";
#require "./include/db.pl";
#require "./include/mainbar.pl";

my $q = CGI->new;
my $dbh = db_connect();
my ($sid, $uid, $displayname, $status) = check_session($q, $dbh);


print_start($q, "Snaptinerary Start Page");
print_top($uid);
print '<script type="text/javascript">
//<![CDATA[
function handleKey(label, input) {
   var mylabel = document.getElementById(label);
   var myinput = document.getElementById(input);
   mylabel.innerHTML = \'\';

}

function describeLodging(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Cheapest room"; break;
        case "2": str = "Budget room"; break;
        case "3": str = "Good room"; break;
        case "4": str = "Luxury room"; break;
      default: break;
    }
    document.getElementById(id).innerHTML=str;
}

function describeFood(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Cheap food"; break;
        case "2": str = "Food on a budget"; break;
        case "3": str = "Eating good"; break;
        case "4": str = "Splurge on food"; break;
      default: break;
    }
    document.getElementById(id).innerHTML=str;
}

function describeEvents(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Cheap sightseeing"; break;
        case "2": str = "Budget sightseeing"; break;
        case "3": str = "Willing to pay for events"; break;
        case "4": str = "Splurge on events"; break;
      default: break;
    }
    document.getElementById(id).innerHTML=str;
}

function describeSchedule(id, value)
{
    str = "error";
    switch (value) {
        case "1": str = "Relax, we have all day!"; break;
        case "2": str = "Regular schedule"; break;
        case "3": str = "Jam-packed! Always moving!"; break;
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

//]]></script>
';


print "<div class='maincontent'>";
print "<h1 class='center'>Plan your trip</h1>
<h5 class='center'>Millions of ideas--just one click away</h5>";


print "



<form name='plan-form' class='formclass1' method='post' action='/plan.pl'>


<div class='center'>
<div class='inputwrap'>
    <label for='location_input' id='location_label'>Destination</label>
<input type='text' id='location_input' name='email'
 onfocus=\"handleKey('location_label', 'location_input')\"/>
</div>
</div>

<div class='center'>

<div class='inputwrap'>
<label for='startdate' id='date_label1'>Check-in</label>
<input type='date' name='startdate' onfocus=\"handleKey('date_label1', 'startdate')\" />
</div>

<div class='inputwrap'>
<label for='enddate' id='date_label2'>Check-out</label>
<input type='date' name='enddate' onfocus=\"handleKey('date_label2', 'enddate')\" />
</div>

</div>


<div class='center'>
<div id='people_detail'>Just me</div>
<input type='range' name='numpeople' min='1' max='8' step='1' value='1' onchange=\"describePeople('people_detail', this.value)\"/>
</div>

<br/><br/>
<div class='center'>
<div id='lodging_detail'>Cheapest room</div>
<input type='range' name='lodging' min='1' max='4' step='1' value='1' onchange=\"describeLodging('lodging_detail', this.value)\"/>
</div>

<br/><br/>
<div class='center'>
<div id='food_detail'>Food on a budget</div>
<input type='range' name='food' min='1' max='4' step='1' value='2' onchange=\"describeFood('food_detail', this.value)\"/>
</div>

<br/><br/>
<div class='center'>
<div id='events_detail'>Willing to pay for events</div>
<input type='range' name='events' min='1' max='4' step='1' value='3' onchange=\"describeEvents('events_detail', this.value)\"/>
</div>

<br/><br/>
<div class='center'>
<div id='schedule_detail'>Regular schedule</div>
<input type='range' name='schedule' min='1' max='3' step='1' value='2' onchange=\"describeSchedule('schedule_detail', this.value)\"/>
</div>

<br/><br/>
<button type='submit' name='submit'>Search</button>
</form>
";



print "</div>";

print '
<script>
$(":range").rangeinput();
$(":date").dateinput();
</script>
';


print_footer($uid, $status);

#like_bar();

print $q->end_html;


$dbh->rollback;
$dbh->disconnect;
