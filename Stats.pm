package Stats;

use strict;
use warnings;
use LWP::UserAgent;
use lib qw(./LWP-Protocol-https-6.06/lib);
use LWP::Protocol::https;
use lib qw(./JSON/lib/perl5/site_perl/5.14.2);
use JSON qw(decode_json);

##stats-v1.3 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
#Table of Contents:
#X. Declarations of URL, Region, API Key
#1. Stats 					[02/05/15]

######
# X. Declarations
######
#Base URL for the Riot API
my $baseURL = "https://na.api.pvp.net/api/lol";
#Set the Region of interest
my $region = "na";
#Set the API Key
my $key = "YOUR_API_KEY_HERE";

########################################################################
# 1. stats/by-summoner/{summonerId}/ranked
#INPUT: SUMMONER ID
#OUTPUT: anonymous HASH
#STRUCTURE:
#my $stats = {'id' (int),      
#			  ['totalSessionsPlayed'   => int,
#			   'totalSessionsWon'      => int,
#			   'totalSessionsLost'     => int,
#		       'totalChampionKills'    => int,
#		       'totalDeathsPerSession' => int,
#			   'totalAssists'  		   => int,
#		       'totalMinionKills'  	   => int]};
#Uses the Champion ID as first key, then uses API keys as secondary key
#Note: id number 0 is used by (Riot) default to display total summoner stats
#Last modified: February 5, 2015
#NOTE: This does not contain all possible elements from the API, just
# the ones that will be of use in my future application. If you wish to
# know info like isVeteran or miniSeries, you can add them in using the
# same format used to fetch name/tier/division/etc.
########################################################################
sub stats{
	#retrieve the summoner name and format it - lc and no white spaces
	my ($sum_id) = @_;

	#Runs web scraping query
	#Can switch between seasons by adjusting the year after SEASON, i.e., SEASON2015 corresponds to Season 5
	#Possible values: SEASON2015, SEASON2014, SEASON3
	my $URL = "$baseURL/$region/v1.3/stats/by-summoner/$sum_id/ranked?season=SEASON2015&api_key=$key";
	#Create a new UserAgent object
	my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
	
	#Runs web scraping query
	my $response = $ua->get($URL);
	
	#Decode the UserAgent object by using the content() method
	my $json = $response->content();

	#For debugging purposes un-comment
	if (defined($response)){
		#print "retrieve summoner id - success!\n";
		#print $response,"\n";
	}else{
		#print "retrieve summoner id - error.\n";
	}

	#grab all of the champion data, store in scalar variable
	$json =~ /champions":\[(.*)\]/;
	my $championData = $1;
	
	#append a comma to the end of the JSON, to make it easy to manually splice
	#Reason: It's easier to come up with one REGEX that grabs each character stat individually, but we need to make the input consistent
	#-all but the last character stat string will have a comma, so append a comma to the end of the JSON for overal consistency
	#-put a print statement to show $1 during the for loop, and it will all make sense
	$championData = $championData.",";
	
	#figure out how many times we'll have to loop
	my $numCharacters = () = $json =~ /stats/gi;
	
	#create array to hold all raw ChampionStat reads
	my @championStats;
	
	#Loop as many times as unique characters played
	#Grab each ChampionStat JSON and push into an array
	for (my $i = 0; $i < $numCharacters; $i++){
		#grab stat data one champion at a time
		$championData =~ /(^\{.+?}\,)\{?/;
		my $tempData = $1;
		$championData =~ s/$1//;
		$tempData =~ s/,$//;
		push @championStats, $tempData;
	}
	
	#Declare the hash reference that we'll be returning 
	my $stats;
	
	foreach (@championStats){
		#Regex out the champion id number
		$_ =~ /{"id":(.+?)\,/;
		#Decode the string into JSON format
		my $decoded_json = decode_json($_);		
		
		#Pull only stats necessary for lol@myteam application
		#Follow these declarations to complete the API Wrapper to fit if needed
		my $id = $1;
		my $totalSessionsPlayed = $decoded_json->{'stats'}{'totalSessionsPlayed'};
		my $totalSessionsLost = $decoded_json->{'stats'}{'totalSessionsLost'};
		my $totalSessionsWon = $decoded_json->{'stats'}{'totalSessionsWon'};
		my $totalChampionKills = $decoded_json->{'stats'}{'totalChampionKills'};
		my $totalDeathsPerSession = $decoded_json->{'stats'}{'totalDeathsPerSession'};
		my $totalAssists = $decoded_json->{'stats'}{'totalAssists'};
		my $totalMinionKills = $decoded_json->{'stats'}{'totalMinionKills'};

		#Re-format champion stats into a hash ref
		my $championStats = {'totalSessionsPlayed'   => $totalSessionsPlayed,
				  			 'totalSessionsWon'      => $totalSessionsWon,
				  			 'totalSessionsLost'     => $totalSessionsLost,
				  	         'totalChampionKills'    => $totalChampionKills,
				  			 'totalDeathsPerSession' => $totalDeathsPerSession,
				  			 'totalAssists'  		 => $totalAssists,
				  			 'totalMinionKills'  	 => $totalMinionKills};
			      			 
		#Add to the stats hash ref, using champion id number as the key for easy data pulls	      			 
		$stats -> {$id} = $championStats;
	}
	#return the hash ref when called
	return $stats;
}

sub example_stats{
	#call by_name sub, store returned scalar hash into $example
	my $example = stats(37155156);
	#create a tester champion id, 0 is used for summoner total statistics so we'll use it here
	my $test = 0;
	#print out all of the return values of the Riot API
	printf "Player has played %s games, with a record of %s wins and %s losses. They have totalled %s kills, %s deaths, %s assists, and %s cs.", 
		$example->{$test}{'totalSessionsPlayed'},
		$example->{$test}{'totalSessionsWon'},
		$example->{$test}{'totalSessionsLost'},
		$example->{$test}{'totalChampionKills'},
		$example->{$test}{'totalDeathsPerSession'},
		$example->{$test}{'totalAssists'},
		$example->{$test}{'totalMinionKills'};
}

1;
