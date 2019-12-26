namespace eval ::MWAPI {
##############################################################
#       Operator873's MediaWiki API Interaction Script       #
##############################################################
# I hold no rights to the following script and release it to #
# the general public to be used, re-written in part or in    #
# whole, or shared so long as the original header is included#
# as is.                                                     #
#                                                            #
#                   operator873@873gear.com                  #
##############################################################

##############################################################
#                 CONFIGURATION AND SETTINGS                 #
##############################################################

# Domain name
#
# Set the domain name of the MediaWiki install we will be querying
# Ex: "miraheze.org"
variable Domain "example.com"

# Subdomains
#
# MediaWiki routinely uses subdomains to branch out different projects or languages.
# List the subdomains you'd like the bot to be able to query separated with spaces
# Ex: "en es proj1 proj2"
variable Projects "foo bar"

# Default subdomain
#
# If the subdomain isn't specified in the command, what subdomain should be the default?
# Ex: "en"
variable defProject "def"

# API location
#
# MediaWiki generally places the API at https://foo.example.com/wiki/api.php
# If the API is location is differnt for your MediaWiki install, provide the path below.
# Otherwise, leave as the "expected" location
# Ex: "/w/api.php" for https://foo.example.com/w/api.php
variable API "/wiki/api.php"

# User Agent
#
# Most API owners would like to know who's connecting via user agent information.
# This is also considered good form and should be correct in case your bot begins acting up.
variable OwnerEmail "your@email.com"

# Bot commands

bind pub f "@count" ::MWAPI::Count
bind pub f "@user" ::MWAPI::WPUser
bind pub f "@userinfo" ::MWAPI::WPUser
bind pub n "@testapi" ::MWAPI::APITest
bind pub f "@icu" ::MWAPI::ICU
bind pub f "@qd" ::MWAPI::QD
bind pub f "@rfd" ::MWAPI::rfd
bind pub f "@unblocks" ::MWAPI::unblk
bind pub l "@backlog" ::MWAPI::backlog

##############################################################
#              END CONFIGURATION. CODE FOLLOWS               #
##############################################################
variable URL "$::MWAPI::Domain$::MWAPI::API"
}

package require http
package require tls
package require json
global botnick
tls::init -tls1 true -ssl2 false -ssl3 false
::http::register https 443 ::tls::socket
::http::config -useragent "$botnick ($::MWAPI::OwnerEmail) MW_API873/1.0 tcl/8.6"

# Call all other functions in an convient single command
proc ::MWAPI::backlog {nick host hand chan text} {
	global botnick
	if {$botnick eq "CabalBot"} {
		::MWAPI::QD $nick $host $hand $chan $text
		::MWAPI::rfd $nick $host $hand $chan $text
		::MWAPI::unblk $nick $host $hand $chan $text
	}
}

# Query MW API for unblock requests
proc ::MWAPI::unblk {nick host hand chan text} {
	set projchk [lindex [split $text] 0]
	set time [clock format [clock seconds] -format "%D %H:%M:%S CT"]
	if {[lsearch $::MWAPI::Projects $projchk] => 0} {
		set wiki "https://$projchk.$::MWAPI::URL"
	} elseif {$projchk ne ""} {
		putserv "PRIVMSG $chan :I don't know that project."
	} else {
		set wiki "https://$::MWAPI::defProject.$::MWAPI::URL"
	}
	set query [http::formatQuery action query format json list categorymembers cmtitle Category:Requests_for_unblock]
	set Data1 [http::data [http::geturl $wiki -query $query -timeout 5000]]
	set Data1 [::json::json2dict $Data1]
	# debugging log --> set apilog [open scripts/api_log/queries.txt {RDWR APPEND}]
	# debugging log --> puts $apilog "$nick checked unblock requests on $chan at $time with results:"
	catch [set check [dict get $Data1 query categorymembers]] 4
	if {$check ne ""} {
		putserv "PRIVMSG $chan :Current unblock requests on $projchk:"
		lmap item [dict get $Data1 query categorymembers] {
		dict filter $item key title
	}
	foreach item [dict get $Data1 query categorymembers] {
		dict with item {
			set title [string map {{ } {_}} $title]
			putserv "PRIVMSG $chan :https://$projchk.$::MWAPI::Domain/wiki/$title"
			# debugging entry --> puts $apilog "$title"
		}
	}
	} else {
		putserv "PRIVMSG $chan :There are no unblock requests on $projchk at this time."
		# debugging entry --> puts $apilog "None pending."
	}
	# debugging entry --> close $apilog
	http::cleanup $Data1
	unset Data1
}

