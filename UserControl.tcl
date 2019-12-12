namespace eval ::MWUser {
##################################################
#       Operator873's EggDrop User Control       #
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
#             READ ME CAREFULLY!                 #
#    This script uses EggDrop user flags in a    #
# manner not originally intended by Eggdrop. You #
# should ensure you have the bot's ability to    #
# give ops, voice, etc using the user levels in  #
# the user file turned off. Once done, this      #
# script lays the ground work for quite powerful #
# access level based command and control. Access #
# levels are customizable and can be whatever    #
# you want them to be. However, do use caution   #
# as some user flags that are used by this       #
# script grant EggDrop access.                   #
#                                                #
# I strongly recommend setting a password for    #
# any users with advanced access flags so they   #
# are not able to gain control of the bot in     #
# ways you do not expect.                        #
#                                                #
# EX: .chpass User A_Pass_They_Don't_Know        #
#                                                #
# You also need to know the difference between   #
# a Nick and a Handle in the EggDrop bot to know #
# how the bot can still find a user, even if     #
# their nick is currently different. For best    #
# results, set VERY specific hostmasks in your   #
# userfile.                                      #
#                                                #
#       nick!ident@host or *!ident@host          #
#                                                #
# Additionally, as a general security precaution #
# for your bot and for your server, I recommend  #
# disabling port 23 (telnet) and fully closing   #
# your WAN facing ports the bot uses for party-  #
# line access. This will require users have SSH  #
# access to your server then use the loopback    #
# adapter to gain access to the partyline.       #
##################################################

##################################################
#         CONFIGURATION AND SETTINGS             #
##################################################

# Functions
#
# .user DumNick add -- add user to the EggDrop user file with their current hostmask
# .user DumNick level -- queries the EggDrop user file and returns information regarding the user's current level
# .user DumNick identify -- queries the EggDrop user file and returns the Handle of the nick given.
# .user DumNick give 1 -- Gives the user access level 1. Access levels do not compound. it is possible to give 1 & 3 but not 2.
# .user DumNick remove 1 -- Removes user access level 1.
# .user DumNick ban -- Removes all access levels and the bot will kick/ban the nick from channels the bot as Op access to.
# .user DumNick del -- Deletes the target nick from the user file. (Access levels are lost)

# Levels
#


# Bot Owner
#
# Set the *HANDLE* of the bot's owner. The Handle is the nick in the EggDrop userfile.
# Since you're editing the config file, I assume this is probably you. Join the bot's partyline
# and type .match YourNick to verify the bot knows you as your main nick.
variable owner "YourNick"

# User Add behavior
#
# When a user is added using '.user Nick add' should they be given level 1 immediately?
# Default is false.
# true=yes / false=no
variable newlevel "false"

# Owner Protection
#
# Should the bot kick any user trying to revoke acccess to the owner?
# Default is false
variable protowner "false"

# Levels
#
# Level = user flag
# 1 = f
# 2 = v
# 3 = l
# 4 = o
# 5 = x
# banned = k
#
# Provide custom names for the 5 levels available. The Level 4 flag is the EggDrop channel operator flag.
# Therefore, Level 4 is predisposed to being left as your "Channel Operator" access level. Changing this could result in
# odd bot behavior. You can, of course, call your ChanOps anything you want. Just beaware the bot will think they have
# ChanOp access.
# L5 should be left as your "SuperUsers" as user flag x provides access to the EggDrop party line via telnet.
# BU is what the bot should call the level for those nicks who are "ban on site"
variable L1 "Level1"
variable L2 "Level2"
variable L3 "Level3"
variable L4 "ChanOp"
variable L5 "SuperUser"
variable BU "Banned User level"

# "x" limits access to this script to your SuperUsers/owners
# You can change the trigger command ".user" to anything you like.
bind pub x ".user" ::MWUser::Control

##################################################
#       END OF CONFIGURATION AND SETTINGS        #
#     Code follows. Edit at your own risks.      #
##################################################
}

proc ::MWUser::Add {userTarget userMask nick chan} {
  if {[validuser $userTarget]} {
		putserv "PRIVMSG $chan :\002\00304Error!\002\00304 $nick, $userTarget already exists on userfile."
	} else {
		adduser $userTarget $userMask
		putlog "$nick added $userTarget to userfile."
		putserv "PRIVMSG $chan :\002\00303Success!\002\00303 \003$userTarget was added to userfile as handle: $userTarget using hostmask: $userMask"
    if {$::MWUser::newlevel = "false"} {
		  putserv "PRIVMSG $chan :\002\00304$nick,\002 I recommend you use .user <nick> give <accesslevel> immediately."
    } else {
      chattr $userTarget -h+f
      putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L1 access."
    }
  }
}

proc ::MWUser::Level {userTgtHand userTarget nick chan} {
  if {![validuser $userTgtHand]} {
		putserv "PRIVMSG $chan :\002\00304Error!\002\00304 \003$nick, you must first add $userTarget to the userfile.\003"
	} else {
		if {[matchattr $userTgtHand n]} {
		  putserv "PRIVMSG $chan :\002\00304$userTarget\002 is owner of this bot.\00304"
		} elseif {[matchattr $userTgtHand x]} {
		  putserv "PRIVMSG $chan :\002\00304$userTarget\002 \003is a SuperUser of this bot."
		} elseif {[matchattr $userTgtHand o]} {
		  putserv "PRIVMSG $chan :\002\00304$userTarget\002 \003has WMF admin and Channel Operator access."
		} elseif {[matchattr $userTgtHand l]} {
		  putserv "PRIVMSG $chan :\002\00303$userTarget\002 \003has WMF admin access."
		} elseif {[matchattr $userTgtHand f]} {
		  putserv "PRIVMSG $chan :\002\00303$userTarget\002 \003has Wikipedian access."
		} elseif {[matchattr $userTgtHand h]} {
		  putserv "PRIVMSG $chan :$userTarget has been added to the userfile, but has no flags set."
		} elseif {[matchattr $userTgtHand k]} {
		  putserv "PRIVMSG $chan :\002\00304WARNING!\002 $userTarget has been banned from this bot."
		} else {
      putserv "PRIVMSG $chan :\002\00304Error!\002 \003$userTarget flags not found. Pinging $::MWUser::Owner.\003"
    }
	}
}

proc ::MWUser::Identify {userTgtHand userTarget chan} {
  if {$userTgtHand ne ""} {
		putserv "PRIVMSG $chan :I recognize $userTarget as $userTgtHand."
	} else {
		putserv "PRIVMSG $chan :I don't recognize $userTarget for some reason."
	}
}

proc ::MWUser::Give {userAction userLevel userTarget userOpChannel userTgtHand nickHand nick chan} {
  if {$userLevel == "1"} {
		chattr $userTarget -h+f
		putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L1 access."
	} elseif {$userLevel == "2"} {
		chattr $userTarget +fv
		putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L2 access."
  } elseif {$userLevel == "3"} {
    chattr $userTarget +l
    putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L3 access."
	} elseif {$userLevel == "4"} {
		if {$userOpChannel ne "global"} {
			chattr $userTgtHand -o|+o $chan
			putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L4 access for $chan."
		} else {
			if {[matchattr $nickHand x]} {
				chattr $userTgtHand +o
				putserv "PRIVMSG $chan :$userTarget granted global $::MWUser::L4 access."
			}
		}
	} elseif {$userLevel == "5"} {
		if {$nick == $::MWUser::Owner} {
			chattr $userTarget +x
			putserv "PRIVMSG $chan :$userTarget granted $::MWUser::L5 access."
		} else {
      putserv "PRIVMSG $chan :$::MWUser::L5 access can only be given by $::MWUser::Owner."
	  }
	} else {
    putserv "PRIVMSG $chan :\002\00304Error!\002\00304 $nick, you're unable to award that access level."
  }
}

proc ::MWUser::Remove {userAction userLevel userTarget userOpChannel userTgtHand nickHand nick chan} {
  if {$userTarget == $::MWUser::Owner} {
		putserv "PRIVMSG $chan :\002\00304$nick\002\00304, \00304that's a great way to get yourself banned.\00304"
		putserv "PRIVMSG $chan :Request denied."
		putserv "PRIVMSG $::MWUser::Owner :$nick attempted to ban you from the bot."
		putlog "$nick attempted to ban $::MWUser::Owner from the bot."
	} elseif {$userLevel == "5"} {
		if {[matchattr $nickHand n]} {
			chattr $userTgtHand -x
			putserv "PRIVMSG $chan :$::MWUser::L5 access removed from $userTarget."
		} else {
			putserv "PRIVMSG $chan :$::MWUser::L5 access can only be removed by $::MWUser::Owner."
		}
	} elseif {$userLevel == "4"} {
		if {$userOpChannel ne "global"} {
			chattr $userTgtHand |-lo $chan
			putserv "PRIVMSG $chan :$::MWUser::L4 access for $chan removed from $userTarget."
		} else {
			if {[matchattr $nickHand x]} {
	  		chattr $userTgtHand -o
				putserv "PRIVMSG $chan :Global $::MWUser::L4 access removed from $userTarget."
			}
		}
  } elseif {$userLevel == "3"} {
    chattr $userTarget -l
    putserv "PRIVMSG $chan :$::MWUser::L3 access removed from $userTarget."
	} elseif {$userLevel == "2"} {
		chattr $userTarget -v
		putserv "PRIVMSG $chan :$::MWUser::L2 access removed from $userTarget."
	} elseif {$userLevel == "1"} {
		chattr $userTarget -f
		putserv "PRIVMSG $chan :$::MWUser::L1 access removed from $userTarget."
	} else {
    putserv "PRIVMSG $chan :\002\00304Error!\002\00304 $nick, unable to comply. Ping $::MWUser::Owner."
  }
}

proc ::MWUser::Ban {userAction userTarget userMask nick chan} {
  if {$userTarget == $::MWUser::Owner} {
		putserv "PRIVMSG $chan :\002\00304$nick\002\00304, \00304that's a great way to get yourself banned.\00304"
		putserv "PRIVMSG $chan :Request denied."
		putserv "PRIVMSG $::MWUser::Owner :$nick attempted to ban you from the bot."
		putlog "$nick attempted to ban $::MWUser::Owner from the bot."
	} elseif {[validuser $userTarget]} {
		chattr $userTarget -flovx+k
		putserv "PRIVMSG $chan :\002\00304$userTarget has had all bot access revoked and will be banned from channels on site.\002\00304"
	} else {
		adduser $userTarget $userMask
		chattr $userTarget -h+k
		putserv "PRIVMSG $chan :\002\00304$userTarget will be banned from all channels on site.\002\00304"
	}
}

proc ::MWUser::Delete {userAction userTarget nick chan} {
  if {$userTarget == $::MWUser::Owner} {
		putserv "PRIVMSG $chan :\002\00304$nick\002\00304, \00304that's a great way to get yourself banned.\00304"
		putserv "PRIVMSG $chan :Request denied."
		putserv "PRIVMSG $::MWUser::Owner :$nick attempted to ban you from the bot."
		putlog "$nick attempted to ban $::MWUser::Owner from the bot."
	} elseif {[validuser $userTarget]} {
		deluser $userTarget
		putserv "PRIVMSG $chan :$userTarget was successfully removed from the userfile."
	} else {
    putserv "PRIVMSG $chan :$userTarget is not on the userfile."
  }
}

proc ::MWUser::Control {nick host hand chan text} {
  set userTarget [lindex [split $text] 0]
	set userTgtHand [nick2hand $userTarget]
	set userHost [getchanhost $userTarget]
	set userMask [format {%s!%s} $userTarget $userHost]
	set userAction [lindex [split $text] 1]
	set userLevel [lindex [split $text] 2]
	set userOpChannel [lindex [split $text] 3]
	set nickHand [nick2hand $nick]
  switch $userAction {
    "add" {
      [::MWUser::Add $userTarget $userMask $nick $chan]
    }
    
    "level" {
      [::MWUser::Level $userTgtHand $userTarget $nick $chan]
    }
    
    "identify" {
      [::MWUser::Identify $userTgtHand $userTarget $chan]
    }
    
    "give" {
      [::MWUser::Give $userAction $userLevel $userTarget $userOpChannel $userTgtHand $nickHand $nick $chan]
    }
    
    "remove" {
      [::MWUser::Remove $userAction $userLevel $userTarget $userOpChannel $userTgtHand $nickHand $nick $chan]
    }
    
    "ban" {
      [::MWUser::Ban $userAction $userTarget $userMask $nick $chan]
    }
    
    "delete" {
      [::MWUser::Delete $userAction $userTarget $nick $chan]
    }
 }
 
 
 if {$::MWUser::Owner == "YourNick" && $::MWUser::L1 == "Level1"} {
    die "You did not configure EggDrop User Control"
 }
 
 putlog "Operator873's EggDrop User Control loaded."
