package Champion;

use strict;
use warnings;
use lib qw(./JSON/lib/perl5/site_perl/5.14.2);
use JSON qw(decode_json);

#LAST EDIT ON [02/18/15]

#CHAMPION SUBROUTINE
#Input: An integer containing the champion Id of interest
#Output: A string containing the name of the selected champion
#-This subroutine uses a text file as JSON input instead of connecting to the Riot API
#-This was partially so I could work on it offline, and partially to decrease the amount of traffic to Riot servers
#-The downside is that the text file must be updated every time a champion is released

sub champion{
	#stores championId from input
	my $championId = $_[0];
	
	#read champion data from .json file
	open my $fh, "<", "champion.json" or die $!;
	my @file = <$fh>;
	close $fh;
	
	my $json = join('', @file);
	
	#decode the json file stored in variable, extract champion name using the id as a key
	my $decoded_json = decode_json($json);
	my $championName = $decoded_json->{"keys"}->{$championId};	
	return $championName;
}

sub example_champion{
	print "Enter a champion ID number: ";
	my $championId = <STDIN>;
	chomp($championId);
	print "Your champion is: ", champion($championId),"\n";
}

1;