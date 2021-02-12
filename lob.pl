#!/usr/bin/perl

use Time::Local;
use Text::ParseWords;	# For quotewords

@planets = ('earth','mercury','venus','mars','ceres','jupiter','saturn','uranus','neptune','pluto');

$mostrecent = "";

%points;
%played;
%scores;

$points{'win'} = 1;
$points{'draw'} = 0;
$points{'lose'} = -1;

foreach $p (@planets){
	#$scores{'wins'}{$p} = 0;
	#$scores{'draw'}{$p} = 0;
	$scores{$p}{'wins'} = 0;
	$played{$p} = 0;
}


$table = "";
$temptable = "";
$earth = "";
for($i = 1; $i < @planets; $i++){
	if($key ne "earth"){
		($title,$temptable) = buildTable("earth",$planets[$i]);
		$earth .= $title;
		$table .= "<div class=\"right\">$title</div><h2 id=\"$planets[$i]\">Earth v ".ucfirst($planets[$i])." Match History</h2>\n$temptable";
	}
}


$html = "<!DOCTYPE html>\n<html>\n";
$html .= "<head>\n";
$html .= "\t<!-- Please don't edit this page by hand as it will be over-written by code. -->\n";
$html .= "\t<!-- Instead, please edit the matches.csv file -->\n";
$html .= "\t<title>Interplanetary Lobbing</title>\n";
$html .= "\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
$html .= "\t<meta name=\"twitter:card\" content=\"summary\">\n";
$html .= "\t<meta name=\"twitter:site\" content=\"@astronomyblog\">\n";
$html .= "\t<meta name=\"twitter:url\" property=\"og:url\" content=\"http://www.strudel.org.uk/lob/\">\n";
$html .= "\t<meta name=\"twitter:title\" property=\"og:title\" content=\"Interplanetary Lobbing\">\n";
$html .= "\t<meta name=\"twitter:description\" property=\"og:description\" content=\"Welcome interplanetary sports fans to the Expensive Hardware Lob League. The league covers expensive hardware lob matches held between planets in the Solar System.\">\n";
$html .= "\t<meta name=\"twitter:image\" property=\"og:image\" content=\"https://www.strudel.org.uk/lob/lob.png\">\n";
$html .= "\t<link rel=\"stylesheet\" href=\"media/style.css\" type=\"text/css\">\n";
$html .= "</head>\n";
$html .= "<body>\n";
$html .= "<div id=\"player1\"></div><div id=\"player2\"></div>\n";
$html .= "<div class=\"content\">\n";
$html .= "<time class=\"update\" datetime=\"$mostrecent\">Last update: $mostrecent</time>\n";
$html .= "<h1>Interplanetary Lobbing</h1>\n";
#$html .= "<div class=\"breaking\"><span class=\"breaking\">NEWS</span> <a href=\"#2018-042A\">InSight takes a comfortable 2-0 win. Mars drops to 7th place in the league.</a></div>\n";
$p = 1;
$q = 0;
$prev = "";


# Work out goal differences
$maxgd = 0;
$mingd = 0;
foreach $key (keys %scores) {
	$scores{$key}{'goaldiff'} = $scores{$key}{'goalf'}-$scores{$key}{'goala'};
	if($scores{$key}{'goaldiff'} > $maxgd){ $maxgd = $scores{$key}{'goaldiff'}; }
	if($scores{$key}{'goaldiff'} < $mingd){ $mingd = $scores{$key}{'goaldiff'}; }
}
# Add a scaled GD factor to the total to work out sort order
foreach $key (keys %scores) {
	$scores{$key}{'order'} = $scores{$key}{'total'}+int(100*($scores{$key}{'goaldiff'}-$mingd)/($maxgd-$mingd+1))/100;
}


$html .= "<table class=\"leaderboard\">\n";
$html .= "<thead><tr><th class=\"position\" title=\"Position\">Pos</th><th class=\"team\" title=\"Team\">Team</th><th class=\"played\" title=\"Matches played\">P</th><th class=\"win\" title=\"Matches won\">W</th><th class=\"draw\" title=\"Matches drawn\">D</th><th class=\"loss\" title=\"Matches lost\">L</th><th class=\"goalfor\" title=\"Goals for\">F</th><th class=\"goalagainst\" title=\"Goals Against\">A</th><th class=\"goaldiff\" title=\"Goal difference\">GD</th><th class=\"total\" title=\"Points\">PTS</th></tr></thead><tbody>\n";
@sorted = sort { $scores{$b}{'order'} <=> $scores{$a}{'order'} } keys %scores;
foreach $key (@sorted) {
	$eq = "";
	if($scores{$key}{'order'} == $prev){ $q = $q; }
	else{ $q = $p; }
	$html .= "<tr><td class=\"position\">".($sorted[$p] && ($scores{$sorted[$p]}{'order'}==$scores{$sorted[$p-1]}{'order'} || $scores{$sorted[$p-1]}{'order'}==$prev) ? "=" : "")."$q</td><td class=\"team\">".($key ne "earth" ? "<a href=\"#$key\">" : "").ucfirst($key).($key ne "earth" ? "</a>":"")."</td><td class=\"played\">$played{$key}</td><td class=\"win\">$scores{$key}{'wins'}</td><td class=\"draw\">$scores{$key}{'draw'}</td><td class=\"loss\">$scores{$key}{'loss'}</td><td class=\"goalfor\">$scores{$key}{'goalf'}</td><td class=\"goalagainst\">$scores{$key}{'goala'}</td><td class=\"goaldiff\">".($scores{$key}{'goaldiff'} > 0 ? "+" : ($scores{$key}{'goaldiff'}==0 ? "" : "&minus;")).abs($scores{$key}{'goaldiff'})."</td><td class=\"score\">".($scores{$key}{'total'} > 0 ? "+" : ($scores{$key}{'total'}==0 ? "" : "&minus;")).abs($scores{$key}{'total'})."</td></tr>\n";
	$p++;
	$prev = $scores{$key}{'order'};
}
$html .= "</tbody></table>";
$html .= "<p>Welcome to the <a href=\"http://www.bio.aps.anl.gov/~dgore/fun/PSL/index.html\">Expensive Hardware Lob League</a>. The league covers expensive hardware lob matches held between planets in the Solar System. Two dwarf planets have recently been admitted to the league and lost their first matches against league champions Team Earth.</p>";
$html .= "<p>After a string of recent successes, <strong>Team Earth</strong> is currently at the top of the leaderboard. Team Earth continues to grow with <strong>6</strong> different space agencies now in the game. There are currently ".numberInPlay()." matches in play.</p>";
$html .= "<h3>Rules</h3>";
$html .= "<p>For each orbiter/lander that successfully returns data the Lobber scores a goal. For each orbiter/lander thwarted (secret agent LGMs, IPBMs, \"lasers\", blowing sand in the lens, etc...), the Lobbee gains a goal. At the end of the match $points{'win'} point".($points{'win'} == 1 ? " is" : "s are")." awarded to the winner, $points{'draw'} point".($points{'draw'} == 1 ? "" : "s")." for a draw and ".($points{'lose'} < 0 ? "&minus;" : "").abs($points{'lose'})." point".($points{'lose'} == 1 ? "" : "s")." to the loser. This points system attempts to account for some teams (ahem, Earth) playing far more matches than others.</p>";
$html .= "<h3>Credits</h3>";
$html .= "<p>This is heavily derived from <a href=\"http://www.bio.aps.anl.gov/~dgore/fun/PSL/index.html\">an original idea by David Gore</a>. Brought up-to-date by <a href=\"http://twitter.com/astronomyblog\">\@astronomyblog</a>.</p>";
$html .= "<br style=\"clear:both;\" />";
$html .= $table;
$html .= "</div>\n";
$html .= "</body>\n";
$html .= "</html>\n";

open(FILE,">","index.html");
print FILE $html;
close(FILE);



# Return the number of matches that are currently "in-play"
sub numberInPlay(){

	local(@output,$html,%wins,%loss,$draw,@days,$o,$n,$launch,$name,$id,$endmission,$flybydate,$insertiondate,$atmosdate,$landdate,$player1,$player2,$score,$launched,$leftorbit,$flyby,$orbit,$atmos,$land,$rover,$link,$report,$reporter,$notes,$ymd,$t,$y,$m,$d,$hh,$mm,$ss);

	@output = getByOpponent();
	$playing = 0;
	
	if(@output > 0){
		foreach $o (@output){
			$o =~ s/[\n\r]//g;
			if($o ne ""){
				($launch,$name,$id,$endmission,$flybydate,$insertiondate,$atmosdate,$landdate,$player1,$player2,$inplayscore,$score,$launched,$leftorbit,$flyby,$orbit,$atmos,$land,$rover,$link,$report,$reporter,$notes) = split(/\t/,$o);
				$t = "";
				($ymd,$t) = split(/T/,$launch);
				($y,$m,$d) = split(/-/,$ymd);
				($hh,$mm,$ss) = split(/:/,$t);
				if(!$score && getDate($y,$m,$d,$hh,$mm,$ss) < time){ $playing++; }
			}
		}
	}
	return $playing;
}


# Build the table for PLANET1 vs PLANET2
sub buildTable(){

	local(@output,$html,%wins,%loss,$draw,@days,$o,$n,$launch,$name,$id,$endmission,$flybydate,$insertiondate,$atmosdate,$landdate,$player1,$player2,$inplayscore,$score,$launched,$leftorbit,$flyby,$orbit,$atmos,$land,$rover,$link,$report,$reporter,$notes,$p1,$p2,$ymd,$t,$kickoffdate,$fulltimedate,$y,$m,$d,$hh,$mm,$ss);
	$planet1 = $_[0];
	$planet2 = $_[1];

	$wins{$planet1} = 0;
	$wins{$planet2} = 0;
	$loss{$planet1} = 0;
	$loss{$planet2} = 0;
	$draw{$planet1} = 0;
	$draw{$planet2} = 0;

	@output = getByOpponent($planet2);
	
	$html = "\t<table class=\"versus\">\n";
	$html .= "\t<thead><tr><th>Wins</th><th class=\"mission\">Mission</th><th class=\"agency\">Lobber</th><th>Score</th><th class=\"report\">Match Report</th></tr></thead>\n\t<tbody>\n";
	$p1wins = 0;
	$p2wins = 0;
	@days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	foreach $o (@output){
		$o =~ s/[\n\r]//g;
		($launch,$name,$id,$endmission,$flybydate,$insertiondate,$atmosdate,$landdate,$player1,$player2,$inplayscore,$score,$launched,$leftorbit,$flyby,$orbit,$atmos,$land,$rover,$link,$report,$reporter,$notes) = split(/\t/,$o);
		($p1,$p2) = split(/-/,$score);
		$scores{$planet1}{'goalf'} += $p1+0;
		$scores{$planet2}{'goalf'} += $p2+0;
		$scores{$planet1}{'goala'} += $p2+0;
		$scores{$planet2}{'goala'} += $p1+0;
		if($p1 > $p2){
			if($player1 =~ $planet1){ $wins{$planet1}++; $loss{$planet2}++; }
			if($player1 =~ $planet2){ $wins{$planet2}++; $loss{$planet1}++; }
		}elsif($p2 > $p1){
			if($player2 =~ $planet1){ $wins{$planet1}++; $loss{$planet2}++; }
			if($player2 =~ $planet2){ $wins{$planet2}++; $loss{$planet1}++; }
		}elsif($score && $p2 == $p1){
			$draw{$planet1}++;
			$draw{$planet2}++;
		}

		$t = "";
		$hh = 0;
		$mm = 0;
		$ss = 0;
		$ended = $endmission;
		if(!$ended && $flybydate){ $ended = $flybydate; }
		if(!$ended && $landdate){ $ended = $landdate; }
		if($ended){
			($ymd,$t) = split(/T/,$ended);
			($y,$m,$d) = split(/-/,$ymd);
			($hh,$mm,$ss) = split(/:/,$t);
			$fulltimedate = "<time datetime=\"".getDate($y,$m,$d,$hh,$mm,$ss,"%Y-%m-%dT%T")."\">".getDate($y,$m,$d,$hh,$mm,$ss,"%a %M %d %Y %t")."</time>";
		}else{
			$fulltimedate = "";
		}

		$t = "";
		$y = 0;
		$m = 0;
		$d = 0;
		$hh = 0;
		$mm = 0;
		$ss = 0;
		($ymd,$t) = split(/T/,$launch);
		($y,$m,$d) = split(/-/,$ymd);
		($hh,$mm,$ss) = split(/:/,$t);

		$kickoffdate = "<time datetime=\"".getDate($y,$m,$d,$hh,$mm,$ss,"%Y-%m-%dT%T")."\">".getDate($y,$m,$d,$hh,$mm,$ss,"%a %M %d %Y %t")."</time>";
		$inplay = (getDate($y,$m,$d,$hh,$mm,$ss) < time ? 1 : 0);
		if(!$score && $inplayscore){ $inplay = 1; }


		$html .= "\t<tr".($score ? "" : ($inplay ? " class=\"inplay\"" : " class=\"upcoming\"")).">\n";
		$html .= "\t\t<td class=\"total\">".($id ne "" && $id ne " " ? "<span id=\"$id\">" : "").($score ? $wins{$planet1}.":".$wins{$planet2} : "").($id ne "" && $id ne " " ? "</span>" : "")."</td>\n";
		$html .= "\t\t<td class=\"mission\"><a href=\"".($link ne "" ? $link : "http://nssdc.gsfc.nasa.gov/nmc/masterCatalog.do?sc=".$id)."\" class=\"mission\">$name</a><br />Kick off: $kickoffdate</td>\n";
		$t1 = $player1;
		$t1 =~ s/\-.*$//g;
		$t2 = $player2;
		$t2 =~ s/\-.*$//g;
		$icon = "";
		foreach $player1bit (split(/\;/,$player1)){
			$a = "";
			if($player1 =~ /-/){
				$a = $player1bit;
				$a =~ s/^[^\-]*\-//g;
			}
			if($icon){ $icon .= "<br />"; }
			$icon .= "<img src=\"".getPlayerIcon($player1bit)."\" class=\"player\" alt=\"$a\" title=\"".uc($a)."\" />";
		}
		$html .= "\t\t<td class=\"agency\">$icon</td>\n";
		#$html .= "\t\t<td class=\"name\"><a href=\"".($link ne " " ? $link : "http://nssdc.gsfc.nasa.gov/nmc/masterCatalog.do?sc=".$id)."\">$name</a></td>\n";
		$html .= "\t\t<td class=\"between\"><div class=\"players\"><div class=\"player player1\">".ucfirst($t1)."</div><div class=\"v\">v</div><div class=\"player player2\">".ucfirst($t2)."</div></div><div class=\"score\">".($score ? "$p1 - $p2" : ($inplay ? ($inplayscore ? $inplayscore : "IN PLAY") : "UPCOMING"))."</div></td>\n";
		$html .= "\t\t<td class=\"report\">$report".($reporter ? " (<strong>Reporter".($reporter =~ / \& / ? "s" : "").":</strong> $reporter)": "")."</td>\n";
		$html .= "\t</tr>\n";
		if($score){
			$played{$planet1}++;
			$played{$planet2}++;
		}
	}
	$html .= "\t</tbody></table>\n";

	$scores{$planet1}{'wins'} += $wins{$planet1};
	$scores{$planet2}{'wins'} += $wins{$planet2};
	$scores{$planet1}{'draw'} += $draw{$planet1};
	$scores{$planet2}{'draw'} += $draw{$planet2};
	$scores{$planet1}{'loss'} += $loss{$planet1};
	$scores{$planet2}{'loss'} += $loss{$planet2};

	$scores{$planet1}{'total'} += $points{'win'}*$wins{$planet1} + $points{'draw'}*$draw{$planet1} + $points{'lose'}*$loss{$planet1};
	$scores{$planet2}{'total'} += $points{'win'}*$wins{$planet2} + $points{'draw'}*$draw{$planet2} + $points{'lose'}*$loss{$planet2};

	$title = "<div class=\"result\"><span class=\"result ".lc($planet1)."\" title=\"$planet1\">".uc(substr($planet1,0,3))."</span><span class=\"vs\">$wins{$planet1} - $wins{$planet2}</span><span class=\"result ".lc($planet2)."\" title=\"$planet2\">".uc(substr($planet2,0,3))."</span></div>";

	return ($title,$html);
	

}


# Return the location of the space agency icon
sub getPlayerIcon {
	local($player,$planet,$agency);
	$player = $_[0];
	if(-e "media/logo_$player.png"){
		return "media/logo_$player.png";
	}
	if($player =~ /-/){
		($planet,$agency) = split(/-/,$player);
		if(-e "media/logo_$agency.png"){
			return "media/logo_$agency.png";
		}
	}
	return "media/blank.png";	
}


# Get the day of the week for the input year/month/day
sub getDayOfWeek{
	return (localtime(timelocal(0, 0, 0, $_[2], $_[1]-1, $_[0])))[6];
}


# A function to parse the line into a tab-delimited format
sub parseLine {
	my @f;
	my $line = $_[0];
	$line =~ s/[\n\r]//g;	# Remove end of lines
	(@f) = split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/,$line);
	$line = join "\t" => @f;
	return $line;
}


# Return all matches that are valid for the input planet
sub getByOpponent{

	local(@lines,$line,$n,$junk,$p1,$p2,$score,$report,$planet,@output,$launch,$edate,$flyby,$orbit,$atmos,$landing);
	$planet = $_[0];	# Input planet

	# Open and read in the contents of the matches file
	open(FILE,"matches.csv");
	@lines = <FILE>;
	close(FILE);

	# Create an empty array to hold the matched matches
	@output = ();
	
	# Loop over each line in the matches file
	foreach $line (@lines){

		# Parse the line into a tab-delimited format
		$line = parseLine($line);

		# Split the line into the separate fields - we only need the player 1 and player 2 fields
		# Launch date,Name,COSPAR ID,End date,Flyby date,Orbit insertion,Enter atmosphere,Landing date,Space Agency,Objective,In-play score,Final score,Successfully reached orbit,Successfully left orbit,Successful flyby?,Successful orbiter?,Successful atmosphere probe?,Successful lander?,Successful rover?,Link,Report,Reporter,Notes
		($launch,$junk,$junk,$edate,$flyby,$orbit,$atmos,$landing,$p1,$p2,$junk,$junk,$junk,$junk,$junk,$junk,$junk,$junk) = split(/\t/,$line);

		if($launch !~ /^#/){
			# Update most recent date
			if($launch gt $mostrecent){ $mostrecent = $launch; }
			if($edate gt $mostrecent){ $mostrecent = $edate; }
			if($flyby gt $mostrecent){ $mostrecent = $flyby; }
			if($orbit gt $mostrecent){ $mostrecent = $orbit; }
			if($atmos gt $mostrecent){ $mostrecent = $atmos; }
			if($landing gt $mostrecent){ $mostrecent = $landing; }
		}

		# Does the line match our required planet?
		if($planet){
			if($p1 =~ /$planet/ || $p2 =~ /$planet/){ push(@output,$line); }
		}else{
			# Ignore commented lines
			if($line !~ /^\#/){ push(@output,$line); }
		}
	}

	# Return the matched lines
	return @output;
}


# Get the date string given y/m/d/hr/mn/sc/format
sub getDate {
	my $format = $_[6];
	my $tz;
	my $sec = $_[5]+0;
	my $min = $_[4]+0;
	my $hour = $_[3]+0;
	my $mday = $_[2]+0;
	my $mon = $_[1]+0;
	my $year = $_[0]+0;
	my $wday;
	my $ext;
	my $date;
	my $newtz;
	my $clock;
	local ($shorttime,$longtime);

	my @days   = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	my @longdays   = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
	my @months = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	my @monthslong = ('January','February','March','April','May','June','July','August','September','October','November','December');

	$clock = timegm($sec+0,$min+0,$hour+0,$mday+0,$mon-1,$year);
	if(!$format){ return $clock; }

	($sec,$min,$hour,$mday,$mon,$year,$wday,$tz) = (gmtime($clock))[0,1,2,3,4,5,6,7];
	$mon++;
	if(!$tz){ $tz = "UT"; }

	# Format the time.
	$shorttime = sprintf("%02d:%02d",$hour,$min);
	$longtime = $shorttime.":".sprintf("%02d",$sec);

	# Add th,st,nd,rd
	if($mday%10 == 1 && $mday != 11){ $ext = "st"; }
	elsif($mday%10 == 2 && $mday != 12){ $ext = "nd"; }
	elsif($mday%10 == 3 && $mday != 13){ $ext = "rd"; }
	else{ $ext = "th"; }
	if($year < 1900){ $year += 1900; }

	$mon = sprintf("%02d",$mon);
	$mday = sprintf("%02d",$mday);
	# Format the date.
	if($format){
		$date = $format;
		$date =~ s/\%D/$longdays[$wday]/g;
		$date =~ s/\%a/$days[$wday]/g;
		$date =~ s/\%d/$mday/g;
		$date =~ s/\%Y/$year/g;
		$date =~ s/\%M/$months[$mon-1]/g;
		$date =~ s/\%m/$mon/g;
		$date =~ s/\%T/$longtime/g;
		$date =~ s/\%t/$shorttime/g;
		$date =~ s/\%e/$ext/g;
		$date =~ s/\%Z/$tz/g;
		$newtz = getTimeZones("RFC-822",$tz);
		$date =~ s/\%z/$newtz/g;
	}else{	$date = "$days[$wday] $mday$ext $months[$mon-1] $year ($shorttime)"; }
	return $date;
}

# Get the time zone
sub getTimeZones {

	my $type = $_[0];
	my $tz = $_[1];
	my $tz_m;
	my $output = "";
	my %tzs = ("A",1,"ACDT",10.5,"ACST",9.5,"ADT",-3,"AEDT",11,"AEST",10,"AKDT",-8,"AKST",-9,"AST",-4,"AWST",8,"B",2,"BST",1,"C",3,"CDT",-5,"CEDT",2,"CEST",2,"CET",1,"CST",-6,"CXT",7,"D",4,"E",5,"EDT",-4,"EEDT",3,"EEST",3,"EET",2,"EST",-5,"F",6,"G",7,"GMT",0,"H",8,"HAA",-3,"HAC",-5,"HADT",-9,"HAE",-4,"HAP",-7,"HAR",-6,"HAST",-10,"HAT",-2.5,"HAY",-8,"HNA",-4,"HNC",-6,"HNE",-5,"HNP",-8,"HNR",-7,"HNT",-3.5,"HNY",-9,"I",9,"IST",9,"IST",1,"JST",9,"K",10,"L",11,"M",12,"MDT",-6,"MESZ",2,"MEZ",1,"MST",-7,"N",-1,"NDT",-2.5,"NFT",11.5,"NST",-3.5,"O",-2,"P",-3,"PDT",-7,"PST",-8,"Q",-4,"R",-5,"S",-6,"T",-7,"U",-8,"UTC",0,"UT",0,"V",-9,"W",-10,"WEDT",1,"WEST",1,"WET",0,"WST",8,"X",-11,"Y",-12,"Z",0);

	if($type eq "options"){
		if(!$data{'timezone'}){ $data{'timezone'} = $user{$data{'blog'}}{'timezone'} }
		foreach $tz (sort(keys(%tzs))){
			if($data{'timezone'} eq $tz){ $output .= "<option value=\"$tz\" selected>$tz\n"; }
			else{ $output .= "<option value=\"$tz\">$tz\n"; }
		}
	}elsif($type eq "RFC-822"){
		$tz = $tzs{$tz};
		$output = roundInt($tz);
		$tz_m = ($tz-int($tz))*60;
		$output = sprintf("%+03d%02d",$tz,$tz_m);
	}else{
		if($tzs{$type}){ $output = $tzs{$type}; }
		else{ $output = 0; }
	}
	return $output;
}

# A function to round a floating point number
sub roundInt {
	if($_[0] < 0){ return int($_[0] - .5); }
	else{ return int($_[0] + .5); }
}

