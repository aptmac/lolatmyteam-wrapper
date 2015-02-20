package Summoner;

use strict;
use warnings;
use LWP::UserAgent;
use lib qw(./LWP-Protocol-https-6.06/lib);
use LWP::Protocol::https;
use lib qw(./JSON/lib/perl5/site_perl/5.14.2);
use JSON qw(decode_json);


#summoner-v1.4 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
#Table of Contents:
#X. Declarations of URL, Region, API Key
#1. By-name   (Input: summonerName) [01/26/15]
#2. Summoner  (Input: summonerId)   [01/26/15]
#3. Masteries (Input: summonerId)	[INCOMPLETE]
#4. Name	  (Input: summonerId)   [01/26/15]
#5. Runes	  (Input: summonerId)	[INCOMPLETE]

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
# 1. summoner/by-name/{summonerNames}
#INPUT: SUMMONER NAME in all lower case and no spaces
#OUTPUT: anonymous HASH
#STRUCTURE:
#%by_name (id   		 => long
#		   name 		 => string
# 		   profileIconId => int
#		   revisionDate  => long 
#		   summonerLevel =>	long);
#
#Last modified: January 26, 2015
########################################################################
sub by_name{
	#retrieve the summoner name and format it - lc and no white spaces
	my ($sum_name) = @_;
	$sum_name = lc($sum_name);
	$sum_name =~ s/ //g;

	#Create a new UserAgent object
	my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
	
	#Runs web scraping query
	my $URL = "$baseURL/$region/v1.4/summoner/by-name/$sum_name?api_key=$key";
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

	#use JSON to decode the output from Riot
	my $decoded_json = decode_json($json);
	
	#store the decoded data into variables
	my $id = $decoded_json -> {$sum_name}{'id'};
	my $name = $decoded_json -> {$sum_name}{'name'};
	my $profileIconId = $decoded_json->{$sum_name}{'profileIconId'};
	my $revisionDate = $decoded_json->{$sum_name}{'revisionDate'};
	my $summonerLevel = $decoded_json-> {$sum_name}{'summonerLevel'};
	
	#structure the anonymous hash for scalar subroutine return
	my $by_name = {'id'   => $id,
				   'name' => $name,
				   'profileIconId' => $profileIconId,
				   'revisionDate'  => $revisionDate,
				   'summonerLevel' => $summonerLevel};
	return $by_name;
}

#a practical example for the by_name subroutine
sub example_by_name{
	#prompt user for input, and format
	print "Enter a summoner name: ";
	my $test = <STDIN>;
	chomp($test);
	#call by_name sub, store returned scalar hash into $example
	my $example = by_name($test);
	#print out all of the return values of the Riot API
	printf "The level %s account %s uses the icon %s and was last revised %s with ID number %s\n", 
		$example->{'summonerLevel'}, 
		$example->{'name'}, 
		$example->{'profileIconId'},
		$example->{'revisionDate'}, 
		$example->{'id'};
}

########################################################################
# 3. summoner/{summonerIds}
#INPUT: SUMMONER ID numbers
#OUTPUT: anonymous HASH
#STRUCTURE:
#%by_name (id   		 => long
#		   name 		 => string
# 		   profileIconId => int
#		   revisionDate  => long 
#		   summonerLevel =>	long);
#
#Last modified: January 26, 2015
########################################################################
sub summoner{
	#retrieve the summoner id
	my ($sum_id) = @_;

	#Runs web scraping query
	my $URL = "$baseURL/$region/v1.4/summoner/by-name/$sum_id?api_key=$key";
	my $json = get($URL);
	
	#For debugging purposes un-comment
	if (defined($json)){
		#print "retrieve summoner id - success!\n";
		#print $json,"\n";
	}else{
		#print "retrieve summoner id - error.\n";
	}
	
	#use JSON to decode the output from Riot
	my $decoded_json = decode_json($json);
	
	#store the decoded data into variables
	my $id = $decoded_json -> {$sum_id}{'id'};
	my $name = $decoded_json -> {$sum_id}{'name'};
	my $profileIconId = $decoded_json->{$sum_id}{'profileIconId'};
	my $revisionDate = $decoded_json->{$sum_id}{'revisionDate'};
	my $summonerLevel = $decoded_json-> {$sum_id}{'summonerLevel'};
	
	#structure the anonymous hash for scalar subroutine return
	my $by_id = {'id'   => $id,
				   'name' => $name,
				   'profileIconId' => $profileIconId,
				   'revisionDate'  => $revisionDate,
				   'summonerLevel' => $summonerLevel};
	return $by_id;
}
#a practical example for the summoner subroutine
sub example_summoner{
	#prompt user for input, and format
	print "Enter a summoner id: ";
	my $test = <STDIN>;
	chomp($test);
	#call by_name sub, store returned scalar hash into $example
	my $example = summoner($test);
	#print out all of the return values of the Riot API
	printf "The level %s account %s uses the icon %s and was last revised %s with ID number %s\n", 
		$example->{'summonerLevel'}, 
		$example->{'name'}, 
		$example->{'profileIconId'},
		$example->{'revisionDate'}, 
		$example->{'id'};
}

########################################################################
# 4. summoner/{summonerIds}/name
#INPUT: SUMMONER ID numbers
#OUTPUT: anonymous HASH
#STRUCTURE:
#%name (id  => name)
#
#Last modified: January 26, 2015
########################################################################
sub name{
	#retrieve the summoner id
	my ($sum_id) = @_;

	#Runs web scraping query
	my $URL = "$baseURL/$region/v1.4/summoner/$sum_id/name?api_key=$key";
	my $json = get($URL);
	
	#For debugging purposes un-comment
	if (defined($json)){
		#print "retrieve summoner id - success!\n";
		#print $json,"\n";
	}else{
		#print "retrieve summoner id - error.\n";
	}
	
	#use JSON to decode the output from Riot
	my $decoded_json = decode_json($json);
	
	#store the decoded data into variables
	my $sum_name = $decoded_json -> {$sum_id};
	
	#structure the anonymous hash for scalar subroutine return
	my $name = {'id'   => $sum_id,
				'name' => $sum_name};
	return $name;
}
sub example_name{
	#prompt user for input, and format
	print "Enter a summoner id: ";
	my $test = <STDIN>;
	chomp($test);
	#call by_name sub, store returned scalar hash into $example
	my $example = name($test);
	#print out all of the return values of the Riot API
	printf "The account %s has a summoner Id value of: %s\n", 
		$example->{'name'}, 
		$example->{'id'};
}
########################################################################
# 5. summoner/{summonerId}/runes
#INPUT: SUMMONER ID
#OUTPUT: anonymous HASH
#STRUCTURE:
#%runes   (TBD => 
#		   TBD => 
# 		   TBD => 
#		   TBD => 
#		   TBD =>	);
#
#Last modified: January 26, 2015
########################################################################
sub runes{
	#retrieve the summoner id
	#my ($sum_id) = @_;
	my $sum_id = 37155156;
	
	#Runs web scraping query
	my $URL = "$baseURL/$region/v1.4/summoner/$sum_id/runes?api_key=$key";
	my $json = get($URL);
	
	#For debugging purposes un-comment
	if (defined($json)){
		print "retrieve summoner id - success!\n";
		print $json,"\n";
	}else{
		print "retrieve summoner id - error.\n";
	}
		
	#structure the anonymous hash for scalar subroutine return
	#my $runes = {'id'   => $id,
	#			   'name' => $name,
	#			   'revisionDate'  => $revisionDate,
	#			   'summonerLevel' => $summonerLevel};
	#return $runes;
}

1;