# Universal-XML-Scraper
Rom Scraper Forked from Universal-Rom-Tools/Universal-XML-Scraper and just improved a bit.

I just needed to improve Universal-XML-Scraper for Amiga ROMs.
I have a collection of WHDLoad ROMs, but almost every ROM is compacted in ZIP format, which is not supported by Amiberry.
Thus I converted ZIP to LHA (with a batch on Windows).
Amiberry works with LHA, but Scrapers don't work anymore !
The only one I managed to use was Universal XML Scraper because it could search by filename only, and we can configure it so "see" .LHA files.
But it only found around 10% games. So I needed another solution.

I contacted Lars Muljord for his excellent SkyCraper to ask for LHA support. 
I believed that CRCs were computed in his scraper from files inside archives.
It is in fact intended that LHA Archive CRCs are known in scrapers databases. 
But as soon as I archived to LHA myself, nothing was found.

I saw that LHA support was already requested in Amiberry comments section.

So I decided to try to add LHA support for Universal XML Scraper, and it is now done ! :-)

We could improve it to find more games : 
I noticed that sometimes game is not found because the complete name with "MyGame_V2.555_45454" was requested and not found, 
so I manually tried without this part, only "MyGame", then the game was found. 
So I'd like to perform a first try with full name, and if not found, perform a second one without version and other data part.
