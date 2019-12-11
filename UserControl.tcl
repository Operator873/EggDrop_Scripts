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

bind pub x ".user" Oper_User

}

