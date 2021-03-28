You created an XCOM 2 Mod Project!

Well technically, I created a mod. But this mod is a blantent rip and copy paste of functions from;

https://steamcommunity.com/sharedfiles/filedetails/?id=1499767042 Mechatronic Warfare

and takes the slots to engineering/repair bay as a standalone mod

============================================================================
Steam Desc		https://steamcommunity.com/sharedfiles/filedetails/?id=2165999454
============================================================================
[h1] What is the mod? [/h1]

This mod is a slice of [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1499767042] Mechatronic Warfare [/url]. [i]Made with permission from the original author [/i].
It takes the engineering/repair slots from MW and lets them be used with other SPARK setups.

I made this mainly for myself as I use my own SPARK setup to the one given by MW, and this was one aspect I was missing. I was convinced to share it by [i]MrShadowCX[/i].

The projects should become available in the Proving Ground after: 
[list] [*]ADVENT MEC autopsy AND [i]one of the below[/i]
[*] Mechanised Warfare [b]OR[/b] Narrative Content Complete [b]OR[/b] Integrated DLC.
[/list]

[h1] Configuration [/h1]

Pretty simple Strategy Tuning configuration file for cost and number of slots to allow unlocking.
Default values (per slot) are; [list] [*]SUPPLIES = 25 [*]ALLOYS = 15 [*]ELERIUM = 5 [*]#CORES = 0 [*]#DAYS = 5[/list]
Has options in the XComGame.ini for the total number of slots to add and how many are unlocked by the Mechanised Warfare tech.
Default values are upto 4 slots,  all requiring sequential Proving Ground projects. A new project will unlock once the previous one is complete.

Any mod can add their own 'spark/mec' classes to the slot by placing the following into XComGame.ini;
[code]
[WOTC_MoreEngineeringRepairSlots.X2StrategyElement_StaffSlotsMW_Rusty]

;added here are extra character templates that can go into the spark staff slots for healing
+ExtraSparkSoldierTemplatesForSlot=('xxTEMPLATE_NAMExx')
[/code]
Contains some examples by default of [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2210732936] Kirukas Buildable Units [/url]

[h1] Compatibility [/h1]
The code was taken from [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1499767042] Mechatronic Warfare [/url], however reports suggest it doesn't crash when used together.
I usually play my campaigns non-integrated and without story missions, and this was also the campaign setup for testing. 
I'm not sure how this will work with integrated dlc or narrative content, but it should be fine :)

No other known issues

[h1] Credits and Thanks [/h1]
[b] HUGE [/b] thanks to NotSoLoneWolf for letting me port this stuff out of MW
By extension from the above, RealityMachina for the Staff Slot code
MrShadowCX for convincing me to share this mod
NelVlesis for the shiny new proving ground image

~ Enjoy [b]!![/b] and please [url=https://www.buymeacoffee.com/RustyDios] buy me a Cuppa Tea[/url]

====================================
UPK Paths;

Texture2D'UILibrary_RustySPARKBay.BayExpansion'  == spark next to console
Texture2D'UILibrary_RustySPARKBay.BayExpansion2' == repair arm thing
Texture2D'UILibrary_RustySPARKBay.TECH_Spark'	 == normal spark tech copy