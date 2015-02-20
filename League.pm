package League;

use strict;
use warnings;
use LWP::UserAgent;
use lib qw(./LWP-Protocol-https-6.06/lib);
use LWP::Protocol::https;
use lib qw(./JSON/lib/perl5/site_perl/5.14.2);
use JSON qw(decode_json);

#league-v2.5 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
#Table of Contents:
#X. Declarations of URL, Region, API Key
#1. League					[INCOMPLETE]
#2. League - Entry			[02/05/15]
#3. TeamIds					[INCOMPLETE]
#4. TeamIds - Entry			[INCOMPLETE]
#5. Challenger				[INCOMPLETE]

######
# X. Declarations
######
#Base URL for the Riot API
my $baseURL = "https://na.api.pvp.net/api/lol";
#Set the Region of interest
my $region = "na";
#Set the API Key
my $key = "8cdd8483-d12f-4c16-a623-d603191c3c2f";

########################################################################
# 2. league/by-summoner/{summonerId}/entry
#INPUT: SUMMONER ID
#OUTPUT: anonymous HASH
#STRUCTURE:
#	my $league = {'name'      => String,
#				  'tier'      => String,
#				  'division'  => String,
#				  'wins'      => int,
#				  'losses'    => int,
#				  'isHotStreak' => Boolean};
#Last modified: January 26, 2015
#NOTE: This does not contain all possible elements from the API, just
# the ones that will be of use in my future application. If you wish to
# know info like isVeteran or miniSeries, you can add them in using the
# same format used to fetch name/tier/division/etc.
########################################################################
sub league{
	#retrieve the summoner name and format it - lc and no white spaces
	my ($sum_id) = @_;

	#Runs web scraping query
	my $URL = "$baseURL/$region/v2.5/league/by-summoner/$sum_id/entry?api_key=$key";
	
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
	
	#Grab only the Ranked Solo data
	my ($grab) = $json =~ m/(^\{.+?"tier":.+?\}),*/;
	$grab = $grab."}}";
	
	#if the player is in a promotion series, the line needs an extra close brace
	if ($grab =~ m/"miniSeries"/){
		$grab = $grab."}";
	}
	
	#remove the square brackets from the JSON format grab variable
	$grab=~ s/\[|\]//g;

	#decode the JSON, and store information in variables
	my $decoded_json = decode_json($grab);
	
	my $name = $decoded_json->{$sum_id}{'name'};
	my $tier = $decoded_json->{$sum_id}{'tier'};
	my $division = $decoded_json->{$sum_id}{'entries'}{'division'};
	my $leaguePoints = $decoded_json->{$sum_id}{'entries'}{'leaguePoints'};
	my $isHotStreak = $decoded_json->{$sum_id}{'entries'}{'isHotStreak'};
	my $wins = $decoded_json->{$sum_id}{'entries'}{'wins'};
	my $losses = $decoded_json->{$sum_id}{'entries'}{'losses'};
	
	my $league = {'name'      => $name,
				  'tier'      => $tier,
				  'division'  => $division,
				  'wins'      => $wins,
				  'losses'    => $losses,
				  'lp'	      => $leaguePoints,
				  'isHotStreak' => $isHotStreak};
	return $league;
}

sub example_entry{
	#call by_name sub, store returned scalar hash into $example
	my $example = league(37555711);
	#print out all of the return values of the Riot API
	printf "Player is ranked at %s %s in the league %s. They have %s wins and %s losses, and it is %s they are on a hot streak.", 
		$example->{'tier'},
		$example->{'division'},
		$example->{'name'},
		$example->{'wins'},
		$example->{'losses'},
		$example->{'isHotStreak'};
}

1;