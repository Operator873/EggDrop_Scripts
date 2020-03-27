# EggDrop_Scripts
These are all original tcl scripts written for EggDrop IRC Bots.

## AutoLink873.tcl
Monitors all channels for wiki-styled links [[Like this]] and responds with a hyperlink for that wikitext.

## MediaWikiLinks.tcl
!link <project (opt)> <target>
This provides hyperlinks for the wiki articles provided. This script allows for languages (subdomain portions of the wiki domain) to be preconfigured so users only have to use !link en This page to get: https://en.wikipedia.org/wiki/This_page

## UserControl.tcl
This script equips the bot with a custom theme for user access levels. Utilizing the chattr funciton, users can be assigned access levels which permit or restrict access to commands on other 873scripts. Can also be set for the bot to kick/ban the user on site.

## wikicheck.tcl
This script interacts with the API of a MediaWiki install to obtain certain data like number of articles, accounts, etc as well as reporting members of a category. This scripts requires wikicheckdb.json, a JSON file used as a databse for API information.
