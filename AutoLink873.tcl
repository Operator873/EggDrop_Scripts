namespace eval ::MWAutoLink {
##################################################
#           Operator873's AutoLink               #
##################################################
#I hold no rights to the following script and    #
# release it to the general public to be used,   #
# re-written in part or in whole, or shared so   #
# long as this original header is included as is.#
#                                                #
#           operator873@873gear.com              #
#                                                #
##################################################

##################################################
#         CONFIGURATION AND SETTINGS             #
##################################################

# Set language
#
# Set the subdomain or 'lanugage' in MediaWiki installs
variable lang "en"

# Set project
#
# Set the main domain or 'project' in MediaWiki installs
variable proj "wikipedia.org"

##################################################
#       END OF CONFIGURATION AND SETTINGS        #
#     Code follows. Edit at your own risks.      #
##################################################

bind pubm - "*\[\[*\]\]*" ::MWAutoLink::AutoLink
bind pub - "!setlink" ::MWAutoLink::AutoLinkSwitch

variable url "https://$::MWAutoLink::lang.$::MWAutoLink::proj/wiki/"
}


bind pubm - "*\[\[*\]\]*" Oper:AutoLink
bind pub l "!setlink" Oper:AutoLinkSwitch

proc ::MWAutoLink::AutoLinkSwitch {nick host hand chan text} {
	set flip [lindex [split $text] 0]
	switch $flip {
		"on" {
			setudef flag AutoLink
			channel set $chan +AutoLink
			putserv "PRIVMSG $chan :\002\00312AutoLink873\002\00312 \00303ENABLED!\00303"
			}
		"off" {
			setudef flag AutoLink
			channel set $chan -AutoLink
			putserv "PRIVMSG $chan :\002\00312AutoLink873\002\00312 \00304DISABLED!\00304"
			}
		default {
			putserv "PRIVMSG $chan :\002\00304ERROR!\002\00304 \003AutoLink command not recognized. Aborting...\003"
			}
		}
	}

proc ::MWAutoLink::AutoLink {nick host hand chan text} {
	if {[channel get $chan AutoLink]} {
		set linkString "$text"
		regsub {.*\[\[} $linkString {} linkString
		regsub {\|.*\]\].*} $linkString {} linkString
		regsub {\]\].*} $linkString {} linkString
		regsub {.*\{\{} $linkString {Template:} linkString
		regsub {\|.*\}\}.*} $linkString {} linkString
		regsub {\}\}.*} $linkString {} linkString
		set linkString [string map {{ } {_}} $linkString]
		set linkString [join $linkString]
		if {$linkString ne ""} {
			putserv "PRIVMSG $chan: $::MWAutoLink::url$linkString"
		}
	}
}
