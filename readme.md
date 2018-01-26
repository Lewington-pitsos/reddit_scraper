#Simple Reddit Scraper

Basically it does what it says on the tin: Scrapes reddit (in particular /r/cryptocurrencies) for mentions of cryptocurrencies (operationalized via an online list of 1000 odd cryptocurrencies).

These are then logged in a Postgres database.

Scrapings have to occur around once every 6 hours since reddit never stores more than 1000 threads per subreddit on their public servers.

###languages:

*ruby
*sql
