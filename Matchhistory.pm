package Matchhistory;

use strict;
use warnings;
use LWP::UserAgent;
use lib qw(./LWP-Protocol-https-6.06/lib);
use LWP::Protocol::https;
use lib qw(./JSON/lib/perl5/site_perl/5.14.2);
use JSON qw(decode_json);

#matchhistory-v2.2 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
#Table of Contents:
#X. Declarations of URL, Region, API Key
#1. Matchhistory 			[02/18/15]

######
# X. Declarations
######
#Base URL for the Riot API
my $baseURL = "https://na.api.pvp.net/api/lol";
#Set the Region of interest
my $region = "na";
#Set the API Key
my $key = "8cdd8483-d12f-4c16-a623-d603191c3c2f";

#VARIABLE RETURN OVERVIEW
#my $matchStats = {'totalGamesPlayed'    => $numGames,
#			  			 'totalTop'      => $totalTop,
#			  			 'totalJG'       => $totalJG,
#			  	         'totalMid'      => $totalMid,
#			  			 'totalADC'      => $totalADC,
#			  			 'totalSupport'  => $totalSupport,
#			  			 'topWins'       => $totalTop,
#			  			 'jgWins'        => $jgWins,
#			  	         'midWins'       => $midWins,
#			  			 'adcWins'       => $adcWins,
#			  			 'supportWins'   => $supportWins,
#						 'championData'  => $championData => {$numGames-$i} => {'id'        => $id,          
#																			    'kills'     => $kills,
#			  			 	   			   		    						    'deaths'    => $deaths,
#			  			 	   			   									    'assists'   => $assists,
#			  	         	   			   									    'creepScore'=> $creepScore};

sub matchhistory{
	my ($sum_id) = @_;
	#Grabs the last 15 games worth of data
	my $URL = "$baseURL/$region/v2.2/matchhistory/$sum_id?rankedQueues=RANKED_SOLO_5x5&endIndex=15&api_key=$key";
	
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
	
	#Regex out the match data
	my ($matchData) = $json =~ /matches":\[(.*)\]/;
	
	#Figure out how many games are recorded
	my $numGames = () = $json =~ /"matchId"/g;
	
	#Variables to hold game stats, will be put into the  hash ref
	my $totalTop = 0;
	my $topWins = 0;
	my $totalJG = 0;
	my $jgWins = 0;
	my $totalMid = 0;
	my $midWins = 0;
	my $totalADC = 0;
	my $adcWins = 0;
	my $totalSupport = 0;
	my $supportWins = 0;
	
	#Initializing the hash ref
	my $championData;
	
	#This loop can be divided into three parts:
	#1. Champion Data - gets which champion was played in this game
	#2. Stats Data - gets the Kills, Deaths, Assits, CS, and Win/Loss
	#3. Lane Data - gets the role played
	for (my $i = 0; $i < $numGames; $i++){
		#1. Champion Data
		my ($championIdLine) = $json =~ m/("championId":.+?),/;
		$json =~ s/$championIdLine//;
		my ($id) = $championIdLine =~ /([0-9]+)/;
		
		#2. Stats Data
		my ($statsData) = $json =~ m/("stats":.+?\})\,/;
		my ($wonnered) = $statsData =~ m/"winner":(.+?),/;
		my ($kills) = $statsData =~ m/"kills":(.+?),/;
		my ($deaths) = $statsData =~ m/"deaths":(.+?),/;
		my ($assists) = $statsData =~ m/"assists":(.+?),/;
		#creepScore will be the sum of lane minions and neutral minions (jungle)
		my ($minionsKilled) = $statsData =~ m/"minionsKilled":([0-9]+)/;
		my ($neutralMinionsKilled) = $statsData =~ m/"neutralMinionsKilled":([0-9]+)/;
		my $creepScore = $minionsKilled + $neutralMinionsKilled;
		$json =~ s/$statsData//;
	
		#3. Lane Data
		my ($laneData) = $json =~ m/("timeline":.+?"lane".+?\})\,/;
		
		#Regex out the lane and role data
		my ($lane) = $json =~ m/"lane":"(.+?)"/;
		my ($role) = $json =~ m/"role":"(.+?)"/;
		
		#Fix up the role variable to contain the position played by the player
		#If un-editted, Top/Mid/JG list SOLO as their role
		#And ADC/SUPPORT list DUO_CARRY and DUO_SUPPORT as their role
		if ($lane eq "TOP"){
			$role = "TOP";
			$totalTop++;
			if ($wonnered eq "true"){
				$topWins++;
			}
		}elsif ($lane eq "MIDDLE"){
			$role = "MIDDLE";
			$totalMid++;
			if ($wonnered eq "true"){
				$midWins++;
			}
		}elsif ($lane eq "JUNGLE"){
			$role = "JUNGLE";
			$totalJG++;
			if ($wonnered eq "true"){
				$jgWins++;
			}
		}elsif ($role eq "DUO_CARRY"){
			$role = "ADC";
			$totalADC++;
			if ($wonnered eq "true"){
				$adcWins++;
			}
		}elsif ($role eq "DUO_SUPPORT"){
			$role = "SUPPORT";
			$totalSupport++;
			if ($wonnered eq "true"){
				$supportWins++;
			}
		}
		$json =~ s/$laneData//;	
		
		#Creates a hash reference, with the game number as the key
		#-Game number will be calculated as $numGames - $i (total games counted minus the counter)
		#-Because the JSON file stores the games in order of oldest->newest
		$championData -> {$numGames-$i} = {'id'        => $id,
										   'kills'     => $kills,
			  			 	   			   'deaths'    => $deaths,
			  			 	   			   'assists'   => $assists,
			  	         	   			   'creepScore'=> $creepScore,
										   'outcome'   => $wonnered,
										   'role'	   => $role};
	}
	
	#Preparing the hash ref for returning
	my $matchStats = {'totalGamesPlayed' => $numGames,
			  			 'totalTop'      => $totalTop,
			  			 'totalJG'       => $totalJG,
			  	         'totalMid'      => $totalMid,
			  			 'totalADC'      => $totalADC,
			  			 'totalSupport'  => $totalSupport,
			  			 'topWins'       => $topWins,
			  			 'jgWins'        => $jgWins,
			  	         'midWins'       => $midWins,
			  			 'adcWins'       => $adcWins,
			  			 'supportWins'   => $supportWins,
						 'championData'  => $championData};
	return $matchStats;
}

sub matchhistory_example{
	my $example = matchhistory(37155156);
	print "SUMMARY - 37155156\n";
	printf ("Top     - %dG %dW %dL\n",$example->{"totalTop"}, $example->{"topWins"}, $example->{"totalTop"} - $example->{"topWins"});
	printf ("Jungle  - %dG %dW %dL\n",$example->{"totalJG"}, $example->{"jgWins"}, $example->{"totalJG"} - $example->{"jgWins"});
	printf ("Middle  - %dG %dW %dL\n",$example->{"totalMid"}, $example->{"midWins"}, $example->{"totalMid"} - $example->{"midWins"});
	printf ("ADC     - %dG %dW %dL\n",$example->{"totalADC"}, $example->{"adcWins"}, $example->{"totalADC"} - $example->{"adcWins"});
	printf ("Support - %dG %dW %dL\n",$example->{"totalSupport"}, $example->{"supportWins"}, $example->{"totalSupport"} - $example->{"supportWins"});	
}

1;

