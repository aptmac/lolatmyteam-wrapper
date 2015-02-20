# lolatmyteam-wrapper
Perl wrapper for the Riot Games Inc. API [02.2015]

These Perl modules were designed to wrap the Riot API to retrieve information regarding League of Legends player data.

The wrapper is not 100% complete, as it only fetches the information required to power my web application - lolatmyteam.

I decided to use the LWP::UserAgent module to scrape web pages, and the JSON module to decode the JSON format. Each module returns one hash reference, and a detailed breakdown of the hash can be found as a comment in the corresponding file.
