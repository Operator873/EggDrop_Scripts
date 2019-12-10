namespace eval ::MW {
##################################################
#     Operator873's MediaWiki Link Generator     #
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
#         CONFIGURATION AND SETTINGS             #
##################################################

# Example link: https://subdomain.example.com/Article
# Example link: https://subdomain.example.com/Project:Page

# Example command: !link <projecet> <article name>
# Example command: !link <article name>

# Set your domain name
#
# Set the main domain of your MediaWiki install.
# This script will assume https is always used.
# (Ex: "example.com")
variable domain "example.com"

# Set your "Languages"
#
# MediaWiki installs typically utilize subdomains to separate projects or languages.
# (ex: en.wikipedia.org, es.wikipedia.org, etc)
# List the language abreviations separated by spaces. If included after !link, the
# script will override the default 'language' (set below) and replace it with this one.
# Instead of https://default.example.com, the link would be https://lang.example.com
# (from above examples: "en es")
variable lang "subdomain1 subdomain2 subdomain3"

# Set your default "Language"
#
# If no "language" is specified or language is not detected,
# what "language" should be used as the default?
# !link Some Artile --> https://default.example.com
variable def "default"

# Excluded channels
#
# List any channels here that the bot should never answer in commands
# Separate channels with spaces
# variable exchan "#thisChannel #thatChannel"
variable exchan ""

#########################
#     Bot Commands      #
#########################

# Anatomy of below commands
#
# bind - assigns the command. Don't change.
# pub/pubm/msg
#     pub indicates the command is the first word. EX: !link Some Page
#     pubm indicates the command can occur anywhere in a message. EX: Hey! read this: !link Some Page
#     msg indicates the command will be sent to the bot via /msg botnick !link Some Page. Problematic if used.
# -/f/l/o/n - can be global or global | channel (Ex: f|o)
#     - No restriction on who can use the command
#     f Bot will only respond to nicks that are added to the Eggdrop user file with .chattr <Nick> +f
#     l Bot will only respond to nicks that are added to the Eggdrop user file with .chattr <Nick> +l
#     o Bot will only respond to nicks that are added to the Eggdrop user file with .chattr <Nick> +o
#     n Bot will only respond to the nick that is the owner of the bot.
#     f|o will match anyone in the user file with +f OR a channel op in the channel the command occurs in
# "command"
#     The exact command that will trigger the bot's function. It's strongly recommended to use a special character      # Procedure
#     This is the procedure call for the bind. Generally, you should NOT change them.

bind pub - "'link" ::MW::Link
bind pub f "'contribs" ::MW::Contribs
bind pub l "'block" ::MW::Block
bind pub f "'ipintel" ::MW::ipintel
bind pub f "'urban" ::MW::udc
bind pub f "'google" ::MW::Google
bind pub f "'log" ::MW::Log

}

proc ::MW::Link {nick host hand chan text} {
        set text [split $text]
        set project [lindex $text 0]
        if {[lsearch -nocase $::MW::lang $project] >= "0" && [lsearch -nocase $::MW::exchan $chan] < 0} {
                set linkstring [string map {{ } {_}} [lrange $text 1 end]]
                putserv "PRIVMSG $chan :https://$project.$::MW::domain/wiki/$linkstring"
        } elseif {[lsearch -nocase $::MW::exchan $chan] < 0} {
                set linkstring [string map {{ } {_}} [lrange $text 0 end]]
                putserv "PRIVMSG $chan :https://$::MW::def.$::MW::domain/wiki/$linkstring"
        }
}

proc ::MW::Contribs {nick host hand chan text} {
        set text [split $text]
        set project [lindex $text 0]
        if {[lsearch -nocase $::MW::lang $project] >= "0" && ![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 1 end]]
                putserv "PRIVMSG $chan :https://$project.$::MW::domain/wiki/Special:Contributions/$target"
        } elseif {![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 0 end]]
                putserv "PRIVMSG $chan :https://$::MW::def.$::MW::domain/wiki/Special:Contributions/$target"
        }
}

proc ::MW::Block {nick host hand chan text} {
        set text [split $text]
        set project [lindex $text 0]
        if {[lsearch -nocase $::MW::lang $project] >= 0 && ![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 1 end]]
                putserv "PRIVMSG $chan :https://$project.$::MW::domain/wiki/Special:Block/$target"
        } elseif {![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 0 end]]
                putserv "PRIVMSG $chan :https://$::MW::def.$::MW::domain/wiki/Special:Block/$target"
        }
}

proc ::MW::Log {nick host hand chan text} {
        set text [split $text]
        set project [lindex $text 0]
        if {[lsearch -nocase $::MW::lang $project] >= 0 && ![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 1 end]]
                putserv "PRIVMSG $chan :User logs: https://$project.$::MW::domain/wiki/Special:Log/$target"
        } elseif {![lsearch -nocase $::MW::exchan $chan]} {
                set target [string map {{ } {_}} [lrange $text 0 end]]
                putserv "PRIVMSG $chan :User logs: https://$::MW::def.$::MW::domain/wiki/Special:Log/$target"
        }
}

proc ::MW::ipintel {nick host hand chan text} {
        set target [string map {{ } {_}} [lrange [split $text] 0 end]]
        if {![lsearch $::MW::exchan $chan]} {
                putserv "PRIVMSG $chan :WHOIS Lookup https://tools.wmflabs.org/whois/gateway.py?lookup=true&ip=$target"         }
}

proc ::MW::udc {nick host hand chan text} {
        set target [string map {{ } {+}} [lrange [join [split $text]] 0 end]]
        if {![lsearch $::MW::exchan $chan]} {
                putserv "PRIVMSG $chan :Urban Dictionary lookup: https://www.urbandictionary.com/define.php?term=$target"
        }
}

proc ::MW::Google {nick host hand chan text} {
        set search [string map {{ } {+}} [lrange [join [split $text]] 0 end]]
        if {![lsearch $::MW::exchan $chan]} {
                putserv "PRIVMSG $chan :Google results: https://www.google.com/search?q=$search"
        }
}

if {$::MW::domain == "example.com" || $::MW::lang == "subdomain1 subdomain2 subdomain3" || $::MW::def == "default"} {           putlog "You didn't configure MediaWiki Link Generator..."
        die "You didn't configure MediaWiki Link Generator..."
}

putlog "Operator873's MediaWiki Link Generator loaded."
