package require http
package require tls
package require json
namespace eval ::MWCheck {
##################################################
#           Operator873's WikiCheck              #
##################################################
# I hold no rights to the following script and   #
# release it to the general public to be used,   #
# re-written in part or in whole, or shared so   #
# long as this original header is included as is.#
#                                                #
#           operator873@873gear.com              #
#                                                #
##################################################

##################################################
#                 User Guide                     #
##################################################
# This script depends on having access to the db #
# built for the script called wikicheckdb.json.  #
# If your script isn't working, please make sure #
# the .json file is located in the same place    #
# the script itself is in. The .json file must   #
# be manually edited at this time due to tcl &   #
# json not getting along very well. There is a   #
# example entry included to make editing easier. #
#                                                #
# To check a wiki for CSD cats, use:             #
#     !csd project                               #
#                                                #
# The script will connect to the wiki in and     #
# look for items listed in that category.        #
##################################################

# Bot Nick
#
# For configuring your user agent...
variable botCheckNick "Bot873"

# Website
#
# For configuring your user agent...
variable botWebsite "www.example.com"

# Email
#
# For the owner of the API to reach you if your bot is misbehaving.
variable botEmail "bob@example.com"

# Domain
#
# The main domain of the community you plan to use
# example wikimedia.org, miraheze.org, etc
variable domain "miraheze.org"

bind pub - "!csd" ::MWCheck::CSD

}


tls::init -tls1 true -ssl2 false -ssl3 false
::http::register https 443 ::tls::socket
::http::config -useragent "$::MWCheck::botCheckNick ($::MWCheck::botWebsite; $::MWCheck::botEmail) tcl/8.6"

set readFile [open scripts/wikicheckdb.json {RDONLY CREAT}]
set dataFile [::json::json2dict [read $readFile]]
close $readFile

proc ::MWCheck::CSD {nick host hand chan text} {
	global dataFile
	set time [clock format [clock seconds] -format "%D %H:%M:%S CT"]
	set project [lindex [split $text] 0]
	set wiki [dict get $dataFile $project apiurl]
	set category [dict get $dataFile $project csdcat]
	set query [http::formatQuery action query format json list categorymembers cmtitle $category]
	set Data1 [http::data [http::geturl $wiki -query $query -timeout 5000]]
	set Data1 [::json::json2dict $Data1]
	putlog "$nick checked QD requests on $chan at $time with results:"
	catch [set check [dict get $Data1 query categorymembers]] 4
	if {$check ne ""} {
	   putserv "PRIVMSG $chan :Current CSDe requests on $project:"
	   lmap item [dict get $Data1 query categorymembers] {
		   dict filter $item key title
	   }
	   foreach item [dict get $Data1 query categorymembers] {
		   dict with item {
			   set title [string map {{ } {_}} $title]
			   putserv "PRIVMSG $chan :https://$project.$::MWCheck::domain/wiki/$title"
		   }
	   }
	} else {
		putserv "PRIVMSG $chan :There are no CSD requests on $project at this time."
	}
	http::cleanup $Data1
	unset Data1
}
