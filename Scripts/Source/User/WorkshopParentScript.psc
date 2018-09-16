Scriptname WorkshopParentScript extends Quest Hidden Conditional
{parent workshop script to hold global data}

import CommonArrayFunctions
import WorkshopDataScript

Group WorkshopRatingsGroup
	WorkshopRatingKeyword[] Property WorkshopRatings Auto Const
	{
		0 = food - base production
		1 = happiness (town's happiness rating)
		2 = population
		3 = safety
		4 = water
		5 = power
		6 = beds
		7 = bonus happiness (output from town, used when calculating actual Happiness rating)
		8 = unassigned population (people not assigned to a specific job)
		9 = radio (for now just 1/0 - maybe later it will be "strength" of station or something)
		10 = current damage (current % damage from raider attacks)
		11 = max damage (max % damage from last attack)
		12 = days since last attack (it will be 0 if just attacked)
		13 = current damage to food - resource points that are damaged
		14 = current damage to water - resource points that are damaged
		15 = current damage to safety - resource points that are damaged
		16 = current damage to power - resource points that are damaged
		17 = extra damage to population - number of wounded people. NOTE: total damage = base population value - current population value + extra population damage
		18 = quest-related happiness modifier
		19 = food - actual production
		20 = happiness target - where is happiness headed
		21 = artillery
		22 = current damage to artillery - resource points that are damaged
		23 = last attacking faction ID (see Followers.GetEncDefinition() for list of factions)
		24 = robot population (so, number of humans = population - robot population)
		25 = base income from vendors
		26 = brahmin population - used for food use plus increasing food production
		27 = MISSING food - amount needed for 0 unhappiness from food
		28 = MISSING water - amount needed for 0 unhappiness from water
		29 = MISSING beds - amount needed for 0 unhappiness from beds
		30 = scavenging - general
		31 = scavenging - building materials
		32 = scavenging - machine parts
		33 = scavenging - rare items
		34 = caravan - greater than 0 means on caravan route
		35 = food type - carrot - so that production can match crops
		36 = food type - corn - so that production can match crops
		37 = food type - gourd - so that production can match crops
		38 = food type - melon - so that production can match crops
		39 = food type - mutfruit - so that production can match crops
		40 = food type - razorgrain - so that production can match crops
		41 = food type - tarberry - so that production can match crops
		42 = food type - tato - so that production can match crops
		43 = synth population (meaning hostile Institute agents): > 0 means there's a hidden synth at the settlement
		44 = MISSING safety - amount needed for minimum risk of attack
	}

	; location data keywords
	ActorValue[] Property WorkshopRatingValues Auto
	{ for now this is created at runtime from the actor values in WorkshopRatings array, so we can use Find to get index with actor values }

	WorkshopActorValue[] Property WorkshopResourceAVs Auto
	{ created at runtime - list of resource actor values used by WorkshopObjects }

	; index "enums" to match the above
	int Property WorkshopRatingFood = 0 autoReadOnly
	int Property WorkshopRatingHappiness = 1 autoReadOnly
	int Property WorkshopRatingPopulation = 2 autoReadOnly
	int Property WorkshopRatingSafety = 3 autoReadOnly
	int Property WorkshopRatingWater = 4 autoReadOnly
	int Property WorkshopRatingPower = 5 autoReadOnly
	int Property WorkshopRatingBeds = 6 autoReadOnly
	int Property WorkshopRatingBonusHappiness = 7 autoReadOnly
	int Property WorkshopRatingPopulationUnassigned = 8 autoReadOnly
	int Property WorkshopRatingRadio = 9 autoReadOnly
	int Property WorkshopRatingDamageCurrent = 10 autoReadOnly
	int Property WorkshopRatingDamageMax = 11 autoReadOnly
	int Property WorkshopRatingLastAttackDaysSince = 12 autoReadOnly
	int Property WorkshopRatingDamageFood = 13 autoReadOnly
	int Property WorkshopRatingDamageWater = 14 autoReadOnly
	int Property WorkshopRatingDamageSafety = 15 autoReadOnly
	int Property WorkshopRatingDamagePower = 16 autoReadOnly
	int Property WorkshopRatingDamagePopulation = 17 autoReadOnly
	int Property WorkshopRatingHappinessModifier = 18 autoReadOnly
	int Property WorkshopRatingFoodActual = 19 autoReadOnly
	int Property WorkshopRatingHappinessTarget = 20 autoReadOnly
	int Property WorkshopRatingArtillery = 21 autoReadOnly
	int Property WorkshopRatingDamageArtillery = 22 autoReadOnly
	int Property WorkshopRatingLastAttackFaction = 23 autoReadOnly
	int Property WorkshopRatingPopulationRobots = 24 autoReadOnly
	int Property WorkshopRatingVendorIncome = 25 autoReadOnly
	int Property WorkshopRatingBrahmin = 26 autoReadOnly
	int Property WorkshopRatingMissingFood = 27 autoReadOnly
	int Property WorkshopRatingMissingWater = 28 autoReadOnly
	int Property WorkshopRatingMissingBeds = 29 autoReadOnly
	int Property WorkshopRatingScavengeGeneral = 30 autoReadOnly
	int Property WorkshopRatingScavengeBuilding = 31 autoReadOnly
	int Property WorkshopRatingScavengeParts = 32 autoReadOnly
	int Property WorkshopRatingScavengeRare = 33 autoReadOnly
	int Property WorkshopRatingCaravan = 34 autoReadOnly
	int Property WorkshopRatingFoodTypeCarrot = 35 autoReadOnly
	int Property WorkshopRatingFoodTypeCorn = 36 autoReadOnly
	int Property WorkshopRatingFoodTypeGourd = 37 autoReadOnly
	int Property WorkshopRatingFoodTypeMelon = 38 autoReadOnly
	int Property WorkshopRatingFoodTypeMutfruit = 39 autoReadOnly
	int Property WorkshopRatingFoodTypeRazorgrain = 40 autoReadOnly
	int Property WorkshopRatingFoodTypeTarberry = 41 autoReadOnly
	int Property WorkshopRatingFoodTypeTato = 42 autoReadOnly
	int Property WorkshopRatingPopulationSynths = 43 autoReadOnly
	int Property WorkshopRatingMissingSafety = 44 autoReadOnly

EndGroup

; array of all workshops - set in the editor
; index is the "workshopID" of that workshop
Group WorkshopMasterList
	RefCollectionAlias Property WorkshopsCollection Auto Const
	{ pointer to ref collection of workshops }

	WorkshopScript[] Property Workshops Auto
	{ Array of all workshops
	  index is the "workshopID" of that workshop
	  initialized at runtime
	}
	Location[] Property WorkshopLocations Auto
	{ associated locations - initialized at runtime }
EndGroup

FormList Property WorkshopCrimeFactions Auto const mandatory
{ used to set crime faction on all workshops that don't have one }

int currentWorkshopID = -1
GlobalVariable Property WorkshopCurrentWorkshopID const auto ; global tracking currentWorkshopID

Group CurrentWorkshopData
	ReferenceAlias Property CurrentWorkshop auto 
	{ current workshop - in this alias }
	ReferenceAlias Property WorkshopCenterMarker Auto
	{center marker of the current workshop, used for packages
	}
	ReferenceAlias Property WorkshopNewSettler Auto const
	{ used for new settler intro scenes }
	ReferenceAlias Property WorkshopSpokesmanAfterRaiderAttack Auto const
	{ used for post raider attack scenes }
EndGroup

Group VendorTypes
	int Property WorkshopTypeMisc = 0 autoReadOnly
	int Property WorkshopTypeArmor = 1 autoReadOnly
	int Property WorkshopTypeWeapons = 2 autoReadOnly
	int Property WorkshopTypeBar = 3 autoReadOnly
	int Property WorkshopTypeClinic = 4 autoReadOnly
	int Property WorkshopTypeClothing = 5 autoReadOnly
	int Property WorkshopTypeChems = 6 autoReadOnly

	WorkshopVendorType[] Property WorkshopVendorTypes Auto Const
	{ array of flags indicating whether the top level vendor is now available }
	int Property VendorTopLevel = 2 auto const
	{ what level makes you a "top level" vendor? Currently there are exactly 3 levels of vendor: 0-2 }
	FormList[] Property WorkshopVendorContainers Auto Const
	{ list of form lists, indexed by VendorType 
		- each form list is indexed by vendor level
	}
EndGroup

Group FarmDiscount 
	Faction Property FarmDiscountFaction const auto mandatory
	{ remove from all settlement NPCs when settlement becomes unallied }
	FarmDiscountVendor[] Property FarmDiscountVendors Auto Const
	{ list of discount vendors }
EndGroup


RefCollectionAlias Property PermanentActorAliases Auto const mandatory
{ref alias collection of non-workshop actors who have been permanently moved to workshops
 the alias gives them a package to keep them at their new workshop "home"
 }

Group TradeCaravans
	RefCollectionAlias Property TradeCaravanWorkshops Auto Const
	{ pointer to ref collection of workshops }
EndGroup

ReferenceAlias Property WorkshopActorApply Auto const mandatory
{used to "stamp" workshop NPCs with alias data (packages, etc.) that they will retain without having to be in the aliases
}

Group Dogmeat
	ReferenceAlias Property DogmeatAlias Auto const mandatory
	{ Dogmeat companion alias - used to check when turning idle scene on and off }
	Scene Property WorkshopDogmeatWhileBuildingScene Auto const mandatory
	{ Dogmeat idle scene }
EndGroup

Group Companion
	ReferenceAlias Property CompanionAlias Auto const mandatory
	{ Companion alias - used to check when turning idle scene on and off }
	Scene Property WorkshopCompanionWhileBuildingScene Auto const mandatory
	{ Companion idle scene }
EndGroup


Group Messages
	ReferenceAlias Property MessageRefAlias Const Auto  mandatory
	{ used for inserting text into messages }
	LocationAlias Property MessageLocationAlias Const Auto mandatory
	{ used for inserting text into messages }
	Message Property WorkshopLosePlayerOwnership const auto mandatory
	Message Property WorkshopGainPlayerOwnership const auto mandatory
	Message Property WorkshopUnhappinessWarning const auto mandatory
	Message Property WorkshopUnownedMessage const auto mandatory
	Message Property WorkshopUnownedHostileMessage const auto mandatory
	Message Property WorkshopUnownedSettlementMessage const auto mandatory
	Message Property WorkshopOwnedMessage const auto mandatory
	Message Property WorkshopTutorialMessageBuild const auto
	Message Property WorkshopResourceAssignedMessage const auto mandatory
	{ message when a resource is successfully assigned }
	Message Property WorkshopResourceNoAssignmentMessage Auto Const mandatory
	{ message that this object can't be assigned to this NPC }
	Message Property WorkshopExitMenuMessage Auto Const mandatory
	{ message the first time you exit workshop mode at each workshop }
EndGroup

Group CaravanActorData
	RefCollectionAlias Property CaravanActorAliases Auto const mandatory
	{ref alias collection of actors assigned to caravans
	 }
	RefCollectionAlias Property CaravanActorRenameAliases Auto const mandatory
	{ref alias collection of actors assigned to caravans - these get renamed "Provisioner"
		(subset of CaravanActorAliases)
	 }
	RefCollectionAlias Property CaravanBrahminAliases Auto const mandatory
	{ref alias collection of brahmins assigned to caravans
	 }
	Keyword Property WorkshopLinkCaravanStart const auto
	{ keyword for linked ref to start marker - used for caravan packages }
	Keyword Property WorkshopLinkCaravanEnd const auto
	{ keyword for linked ref to end marker - used for caravan packages }
	ActorBase Property CaravanBrahmin Auto const mandatory
	{ the pack brahmin that gets autogenerated by caravan actors }
EndGroup
; index to track the highest used index in the CaravanActor array
int caravanActorMaxIndex = 0


Group Keywords
	Keyword Property WorkshopWorkObject Auto Const mandatory
	{ keyword on built object that indicates it is a "work" object for an actor }
	Keyword Property WorkshopAllowCaravan Auto Const mandatory
	{ put this keyword on actors that can be assigned to caravan duty }
	Keyword Property WorkshopAllowCommand Auto Const mandatory
	{ put this keyword on actors that can be commanded to resource objects }
	Keyword Property WorkshopAllowMove Auto Const mandatory
	{ put this keyword on actors that can be moved to different settlements }
	keyword Property WorkshopLinkContainer const auto mandatory
	{ keyword for the linked container that holds workshop resources }
	keyword Property WorkshopLinkSpawn const auto mandatory
	{ keyword for the linked spawn marker for creating new NPCs }
	keyword Property WorkshopLinkCenter const auto mandatory
	{ keyword for the linked center marker }
	keyword Property WorkshopLinkSandbox const auto mandatory
	{ keyword for the linked sandbox primitive }
	keyword Property WorkshopLinkWork const auto mandatory
	{ keyword for actors to editor-set work objects }
	; event keywords:
	Keyword Property WorkshopEventAttack const auto mandatory
	{ keyword for workshop attack radiant quests }
	Keyword Property WorkshopEventRadioBeacon const auto mandatory
	{ keyword for workshop radio beacon quest }
	Keyword Property WorkshopEventInitializeLocation const auto mandatory
	{ keyword for workshop initialization story manager events }
	
	Keyword Property LocTypeWorkshopSettlement const auto mandatory
	{ keyword used to test for workshop locations }
	Keyword Property LocTypeWorkshopRobotsOnly const auto mandatory
	{ keyword used to initialize "robots only" locations (e.g. Graygarden) }
	Keyword Property WorkshopCaravanKeyword const auto mandatory
	{ keyword used for links between workshop locations }
	Keyword Property WorkshopLinkFollow const auto mandatory
	{ keyword used to create dynamic linked refs for follow packages (e.g. caravan brahmin)}
	Keyword Property WorkshopLinkHome const auto mandatory
	{ keyword used to create dynamic linked refs for persistent workshop NPCs - center of their default sandbox package }
	Keyword Property WorkshopItemKeyword Auto Const mandatory
	{ keyword that links all workshop-created items to their workshop }
	FormList Property VendorContainerKeywords Auto Const mandatory
	{ form list of keywords that link vendor containers to the vendor - indexed by vendor level }
	Keyword Property WorkshopAssignCaravan const auto mandatory
	{ keyword sent by interface when assigning an NPC to a caravan destination }
	Keyword Property WorkshopAssignHome const auto mandatory
	{ keyword sent by interface when assigning an NPC to a new home }
	Keyword Property WorkshopAssignHomePermanentActor const auto mandatory
	{ keyword sent by interface when assigning a "permanent" NPC to a new home }
	Keyword Property WorkshopType02 const auto mandatory
	{ default keyword to flag secondary settlement type }
	Keyword Property WorkshopType02Vassal const auto mandatory
	{ default keyword to flag secondary settlement vassals }
	FormList Property WorkshopSettlementMenuExcludeList Auto const mandatory
	{ form list of keywords for secondary settlement types (to exclude them from settlement menu) }
EndGroup

group Globals
	GlobalVariable Property MinutemenRecruitmentAvailable const auto mandatory
	{ number of settlements available for Minutemen recruiting. Updated by UpdateMinutemenRecruitmentAvailable() }
	GlobalVariable Property MinutemenOwnedSettlements const auto mandatory
	{ number of populated settlements owned by Minutemen. Updated by UpdateMinutemenRecruitmentAvailable() }
	GlobalVariable property WorkshopMinRansom auto const mandatory
	GlobalVariable property WorkshopMaxRansom auto const mandatory
	GlobalVariable Property GameHour Auto Const
	GlobalVariable Property PlayerInstitute_Destroyed auto const mandatory
	GlobalVariable Property PlayerInstitute_KickedOut auto const mandatory
	GlobalVariable Property PlayerBeenToInstitute auto const mandatory
	{ used for attack quests - to know if synths can teleport }
EndGroup

group ActorValues
	ActorValue Property Charisma const auto mandatory
	ActorValue Property WorkshopIDActorValue const auto mandatory
	ActorValue Property WorkshopCaravanDestination const auto mandatory
	ActorValue Property WorkshopActorWounded const auto mandatory
	ActorValue Property PowerGenerated const auto mandatory
	ActorValue Property PowerRequired const auto mandatory
	ActorValue Property WorkshopGuardPreference const auto mandatory
	{ base actors with this value will try to guard when first created (instead of farming)}
	ActorValue Property WorkshopActorAssigned const auto mandatory
	{ actors get this value temporarily after being assigned so they will always run their work package }
	ActorValue Property WorkshopFloraHarvestTime const auto mandatory
	{ flora objects get this when harvested, to track when they should "regrow" }
	ActorValue Property WorkshopPlayerOwnership const auto mandatory
	{ actor value used to flag player-owned workshops for use by condition checks }
	ActorValue Property WorkshopPlayerLostControl const auto mandatory
	{ set to 1 on workshops that was friendly to player then became "unfriendly" - set back to 0 when owned status restored
		set to 2 on workshops after first Reset - to indicate that anything that needs to be cleared is taken care of
	 }
	ActorValue Property WorkshopResourceObject Auto Const mandatory
	{ actor value on built object that indicates it is a resource object of some kind
		all objects that the scripted workshop system cares about should have this actor value }
	ActorValue Property WorkshopAttackSAEFaction auto const mandatory
	{ actor value to record the attack faction for WorkshopAttackDialogueFaction
		uses SAE_XXX globals for faction values }
	ActorValue Property WorkshopFastTravel const auto mandatory
	{ actor resource value to prevent building multiple fast travel targets in a single workshop location}
	ActorValue Property WorkshopMaxTriangles auto const
	{ used to set build budget on workshop ref}
	ActorValue Property WorkshopCurrentTriangles auto const
	{ used to set build budget on workshop ref}
	ActorValue Property WorkshopMaxDraws auto const
	{ used to set build budget on workshop ref}
	ActorValue Property WorkshopCurrentDraws auto const
	{ used to set build budget on workshop ref}
	ActorValue Property WorkshopProhibitRename const auto mandatory
	{ actors with this > 0 will not be put in the CaravanActorRenameAliases collection }
EndGroup

Group AchievementData
	globalVariable property AlliedSettlementAchievementCount auto const
	int property AlliedSettlementsForAchievement = 3 auto const
	int property AlliedSettlementAchievementID = 23 auto const
	int property HappinessAchievementValue = 100 auto const
	int property HappinessAchievementID = 24 auto const
endGroup

ReferenceAlias Property PlayerCommentTarget Auto const
{ used for player comment }
Scene Property WorkshopPlayerCommentScene auto const
{ player comment scene }
ReferenceAlias Property WorkshopRecruit Const Auto mandatory
bool Property PlayerOwnsAWorkshop auto Conditional
{ set to true when the player owns ANY workshop - used for dialogue conditions }
int Property CurrentNewSettlerCount auto Conditional
{ how many new settlers at current workshop? }
int Property MaxNewSettlerCount = 4 auto const hidden
{ max number to put into "new settler" collection - don't want massive crowd following player around }
ActorBase Property WorkshopNPC Auto const mandatory
{ the actor that gets created when a settlement makes a successful recruitment roll }
ActorBase Property WorkshopNPCGuard Auto const mandatory
{ sometimes a "guard" NPC gets created instead }
Topic Property WorkshopParentAssignConfirm auto const mandatory hidden
{ OBSOLETE }
Keyword Property WorkshopParentAssignConfirmTopicType auto const mandatory
{ replaces WorkshopParentAssignConfirm topic - shared topic type allows DLC to add new lines more easily }
ActorBase Property WorkshopBrahmin Auto mandatory
{ the workshop brahmin that can be randomly created during recruitment }
Quest Property WorkshopInitializeLocation const auto mandatory
{ quest that initializes workshop locations }
String Property userlogName = "Workshop" Auto Const Hidden
MiscObject Property SynthDeathItem auto const mandatory
{ death item for synths }

Group LeveledItems
	; used when producing resources from workshop objects
	LeveledItem Property WorkshopProduceFood Auto Const mandatory
	LeveledItem Property WorkshopProduceWater Auto Const mandatory
	LeveledItem Property WorkshopProduceScavenge Auto Const mandatory
	LeveledItem Property WorkshopProduceVendorIncome Auto Const mandatory
	LeveledItem Property WorkshopProduceFertilizer Auto Const mandatory

	WorkshopFoodType[] Property WorkshopFoodTypes auto const
	{ array of food types used to produce appropriate food type }
EndGroup

Group Resources
	; used when consuming resources from workshop objects
	Keyword Property WorkshopConsumeFood Auto Const mandatory
	Keyword Property WorkshopConsumeWater Auto Const mandatory
	FormList Property WorkshopConsumeScavenge Auto Const  mandatory			; list of components
EndGroup

Group LocRefTypes
	; used when checking for bosses in order to clear a location
	FormList Property BossLocRefTypeList auto const mandatory
	LocationRefType Property MapMarkerRefType Auto Const mandatory
	LocationRefType Property Boss Auto Const mandatory
	LocationRefType Property WorkshopCaravanRefType Auto Const mandatory
	LocationRefType Property WorkshopSynthRefType Auto Const mandatory
	{ used to flag created synth settlers }
endGroup

Group factions
	Faction Property REIgnoreForCleanup Const Auto mandatory
	{ add actors to this faction to have them ignored during RE cleanup check
	  i.e. quest can clean up even if they are loaded/alive
	}
	Faction Property REDialogueRescued Const Auto mandatory
	{ remove from this faction after RE NPCs are added to workshop }
	Faction Property RaiderFaction const auto mandatory
	{ used for random attacks }
	Faction Property RobotFaction const auto mandatory
	{ used to check for robot actors in daily update etc. }
	Faction Property BrahminFaction const auto mandatory
	{ used to check for brahmin actors in daily update etc. }
	Faction Property PlayerFaction const auto mandatory
	{ assign default ownership to non-assigned workshop objects }
	Faction Property WorkshopAttackDialogueFaction const auto mandatory
	{ used to condition "grateful" dialogue after player helps fight off attackers }
	Faction Property MinRadiantDialogueDisappointed const auto mandatory
	Faction Property MinRadiantDialogueWorried const auto mandatory
	Faction Property MinRadiantDialogueHopeful const auto mandatory
	Faction Property MinRadiantDialogueThankful const auto mandatory
	Faction Property MinRadiantDialogueFailure const auto mandatory
EndGroup

ObjectReference Property WorkshopHoldingCellMarker Const Auto mandatory
{ marker for holding cell - use to place vendor chests }
FollowersScript Property Followers const auto mandatory
{ pointer to Followers quest script for utility functions }


; how large a radius to search for workshop objects/actors? (should be whole loaded area)
int findWorkshopObjectRadius = 5000 const

; how many food points can each NPC work on?
int maxFoodProductionPerFarmer = 10 const ; WSWF Note: Unused

; timer IDs
int dailyUpdateTimerID = 0 const

; update timer
float updateIntervalGameHours = 24.0 const	 ; daily
float dailyUpdateSpreadHours = 12.0 const  	; how many hours to spread out (total) all the daily updates for workshops

float Property dailyUpdateIncrement = 0.0 auto
{ updated during daily update process - how much time in between each workshop's own daily update }


; custom event sent each time an Initialize quest completes, to signal starting the next one
CustomEvent WorkshopInitializeLocation
; custom event sent when DailyUpdate is processed
CustomEvent WorkshopDailyUpdate
; custom event sent when a non-workshop actor is added to a workshop
CustomEvent WorkshopAddActor 
; custom event sent when an actor is assigned to a work object
CustomEvent WorkshopActorAssignedToWork
; custom event sent when an actor is unassigned from a work object
CustomEvent WorkshopActorUnassigned
; custom event sent when a workshop object is built
CustomEvent WorkshopObjectBuilt 
; custom event sent when a workshop object is destroyed (removed from the world)
CustomEvent WorkshopObjectDestroyed
; custom event sent when a workshop object is moved
CustomEvent WorkshopObjectMoved 
; custom event sent when a workshop object is damaged or repaired
CustomEvent WorkshopObjectDestructionStageChanged
; custom event sent when a workshop object is damaged or repaired
CustomEvent WorkshopObjectPowerStageChanged
; custom event sent when a workshop becomes player-owned
CustomEvent WorkshopPlayerOwnershipChanged
; custom event sent when player enters workshop menu
CustomEvent WorkshopEnterMenu 
; custom event sent when a workshop object is repaired
CustomEvent WorkshopObjectRepaired 
; 1.6 custom event sent when an NPC is assigned to a supply line
CustomEvent WorkshopActorCaravanAssign
; 1.6 custom event sent when an NPC is unassigned from a supply line
CustomEvent WorkshopActorCaravanUnassign
; set to true after initializition is complete - so other scripts don't try to use data on this script before then
bool property Initialized = false auto

; set to true while thread-sensitive functions are in progress
bool EditLock = false
; WorkshopScript sets this to true during daily update, other workshops won't do daily updates until this is clear to prevent script overload
bool property DailyUpdateInProgress = false auto hidden

;------------------------------------------------------
;	Added by UFO4P 1.0.3 for Bug #20576:
;------------------------------------------------------

;The game time when the last ResetWorkshop function started running
Float UFO4P_GameTimeOfLastResetStarted = 0.0

;The last workshop location visited by the player
Location UFO4P_PreviousWorkshopLocation = None

;------------------------------------------------------
;	Added by UFO4P 1.0.3 for Bug #20775:
;------------------------------------------------------

;ID for starting a timer on WorkshopScript to handle calls of the DailyUpdate function
int UFO4P_DailyUpdateResetHappinessTimerID = 99
 
;------------------------------------------------------
;	Added by UFO4P 1.0.5 for Bug #21039:
;------------------------------------------------------

;UFO4P 2.0 Bug #21894: With this fix in place, the form list is no longer needed.

;List of all damage helper base objects
;FormList Property UFO4P_WorkshopFloraDamageHelpers auto const

;------------------------------------------------------
;	Added by UFO4P 2.0 for Bug #21895:
;------------------------------------------------------

;Helper bool to delay any daily updates of the workshop scripts while an attack is physically running:
bool Property UFO4P_AttackRunning = false auto hidden

int UFO4P_DelayedResetTimerID = 96

WorkshopScript UFO4P_WorkshopRef_ResetDelayed = none

;------------------------------------------------------


; WSWF - Leaving these as straight variables for backwards compatibility, but moving the functional versions to workshop level variables
Int Property recruitmentGuardChance = 20 auto const hidden
Int Property recruitmentBrahminChance = 20 auto const hidden
Int Property recruitmentSynthChance = 10 auto const hidden
Float Property actorDeathHappinessModifier = -20.0 auto const hidden
Int Property maxAttackStrength = 100 auto const hidden
Int Property maxDefenseStrength = 100 auto const hidden


; ------------------------------------------------------
;
; WSWF - Variables converted into editable properties - Likely will convert all these to have globals as well. By doing them as non-Auto properties we can just edit the Property functions to call and set the global values as opposed to having to edit every call throughout the script.
;
; ------------------------------------------------------

Bool Property bUseGlobalTradeCaravanMinimumPopulation = true Auto Hidden
int WSWF_iTradeCaravanMinimumPopulation = 5  ; min population for rolling for a synth
Int Property TradeCaravanMinimumPopulation ; minimum population for a settlement to count as a valid trade caravan destination
	Int Function Get()
		if(bUseGlobalTradeCaravanMinimumPopulation)
			return WSWF_Setting_TradeCaravanMinimumPopulation.GetValueInt()
		else
			return WSWF_iTradeCaravanMinimumPopulation
		endif
	EndFunction
	
	Function Set(Int aiValue)
		WSWF_iTradeCaravanMinimumPopulation = aiValue
	EndFunction
EndProperty
	
	
Bool Property bUseGlobalrecruitmentMinPopulationForSynth = true Auto Hidden
int WSWF_iRecruitmentMinPopulationForSynth = 4  ; min population for rolling for a synth
Int Property recruitmentMinPopulationForSynth
	Int Function Get()
		if(bUseGlobalrecruitmentMinPopulationForSynth)
			return WSWF_Setting_recruitmentMinPopulationForSynth.GetValueInt()
		else
			return WSWF_iRecruitmentMinPopulationForSynth
		endif
	EndFunction
	
	Function Set(Int aiValue)
		WSWF_iRecruitmentMinPopulationForSynth = aiValue
	EndFunction
EndProperty

Bool Property bUseGlobalstartingHappiness = true Auto Hidden
Float WSWF_fStartingHappiness = 50.0  ; happiness of a new workshop starts here
Float Property startingHappiness
	Float Function Get()
		if(bUseGlobalstartingHappiness)
			return WSWF_Setting_startingHappiness.GetValue()
		else
			return WSWF_fStartingHappiness
		endif
	EndFunction
	
	Function Set(Float afValue)
		WSWF_fStartingHappiness = afValue
	EndFunction
EndProperty

Bool Property bUseGlobalstartingHappinessMin = true Auto Hidden
Float WSWF_fStartingHappinessMin = 20.0  ; when resetting happiness, don't start lower than this
Float Property startingHappinessMin
	Float Function Get()
		if(bUseGlobalstartingHappinessMin)
			return WSWF_Setting_startingHappinessMin.GetValue()
		else
			return WSWF_fStartingHappinessMin
		endif
	EndFunction
	
	Function Set(Float afValue)
		WSWF_fStartingHappinessMin = afValue
	EndFunction
EndProperty
	
Bool Property bUseGlobalstartingHappinessTarget = true Auto Hidden	
Float WSWF_fStartingHappinessTarget = 50.0  ; init happiness target to this
Float Property startingHappinessTarget
	Float Function Get()
		if(bUseGlobalstartingHappinessTarget)
			return WSWF_Setting_startingHappinessTarget.GetValue()
		else
			return WSWF_fStartingHappinessTarget
		endif
	EndFunction
	
	Function Set(Float afValue)
		WSWF_fStartingHappinessTarget = afValue
	EndFunction
EndProperty	

Bool Property bUseGlobalresolveAttackMaxAttackRoll = true Auto Hidden	
Int WSWF_iResolveAttackMaxAttackRoll = 150 ; max allowed attack roll when resolving offscreen
Int Property resolveAttackMaxAttackRoll
	Int Function Get()
		if(bUseGlobalresolveAttackMaxAttackRoll)
			return WSWF_Setting_resolveAttackMaxAttackRoll.GetValueInt()
		else
			return WSWF_iResolveAttackMaxAttackRoll
		endif
	EndFunction
	
	Function Set(Int aValue)
		WSWF_iResolveAttackMaxAttackRoll = aValue
	EndFunction
EndProperty

Bool Property bUseGlobalresolveAttackAllowedDamageMin = true Auto Hidden
Float WSWF_fResolveAttackAllowedDamageMin = 25.0 ; this is as low as allowed damage can go when an attack is resolved offscreen
Float Property resolveAttackAllowedDamageMin
	Float Function Get()
		if(bUseGlobalresolveAttackAllowedDamageMin)
			return WSWF_Setting_resolveAttackAllowedDamageMin.GetValue()
		else
			return WSWF_fResolveAttackAllowedDamageMin
		endif
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fResolveAttackAllowedDamageMin = aValue
	EndFunction
EndProperty


Bool Property bUseGlobalworkshopRadioInnerRadius = true Auto Hidden
Float WSWF_fWorkshopRadioInnerRadius = 9000.0
Float Property workshopRadioInnerRadius
	Float Function Get()
		if(bUseGlobalworkshopRadioInnerRadius)
			return WSWF_Setting_workshopRadioInnerRadius.GetValue()
		else
			return WSWF_fWorkshopRadioInnerRadius
		endif
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fWorkshopRadioInnerRadius = aValue
	EndFunction
EndProperty


Bool Property bUseGlobalworkshopRadioOuterRadius = true Auto Hidden
Float WSWF_fWorkshopRadioOuterRadius = 20000.0
Float Property workshopRadioOuterRadius
	Float Function Get()
		if(bUseGlobalworkshopRadioOuterRadius)
			return WSWF_Setting_workshopRadioOuterRadius.GetValue()
		else
			return WSWF_fWorkshopRadioOuterRadius
		endif
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fWorkshopRadioOuterRadius = aValue
	EndFunction
EndProperty


Bool Property bUseGlobalhappinessModifierMax = true Auto Hidden
Float WSWF_fHappinessModifierMax = 40.0
Float Property happinessModifierMax
	Float Function Get()
		if(bUseGlobalhappinessModifierMax)
			return WSWF_Setting_happinessModifierMax.GetValue()
		else
			return WSWF_fHappinessModifierMax
		endif
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fHappinessModifierMax = aValue
	EndFunction
EndProperty


Bool Property bUseGlobalhappinessModifierMin = true Auto Hidden
Float WSWF_fHappinessModifierMin = -50.0
Float Property happinessModifierMin
	Float Function Get()
		if(bUseGlobalhappinessModifierMin)
			return WSWF_Setting_happinessModifierMin.GetValue()
		else
			return WSWF_fHappinessModifierMin
		endif
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fHappinessModifierMin = aValue
	EndFunction
EndProperty



;
; WSWF - New Properties
;
Bool Property AutoAssignBeds
	Bool Function Get()
		return (WSWF_Setting_AutoAssignBeds.GetValue() == 1)
	EndFunction
	
	Function Set(Bool aValue)
		if(aValue)
			WSWF_Setting_AutoAssignBeds.SetValue(1)
		else
			WSWF_Setting_AutoAssignBeds.SetValue(0)
		endif
	EndFunction
EndProperty		

Bool Property AutoAssignFood
	Bool Function Get()
		return (WSWF_Setting_AutoAssignFood.GetValue() == 1)
	EndFunction
	
	Function Set(Bool aValue)
		if(aValue)
			WSWF_Setting_AutoAssignFood.SetValue(1)
		else
			WSWF_Setting_AutoAssignFood.SetValue(0)
		endif
	EndFunction
EndProperty	

Bool Property AutoAssignDefense
	Bool Function Get()
		return (WSWF_Setting_AutoAssignDefense.GetValue() == 1)
	EndFunction
	
	Function Set(Bool aValue)
		if(aValue)
			WSWF_Setting_AutoAssignDefense.SetValue(1)
		else
			WSWF_Setting_AutoAssignDefense.SetValue(0)
		endif
	EndFunction
EndProperty	

Int Property MaxFoodWorkPerSettler
	Int Function Get()
		return WSWF_Setting_MaxFoodWorkPerSettler.GetValueInt()
	EndFunction
	
	Function Set(Int aValue)
		WSWF_Setting_MaxFoodWorkPerSettler.SetValue(aValue)
	EndFunction
EndProperty	


Int Property MaxDefenseWorkPerSettler
	Int Function Get()
		return WSWF_Setting_MaxDefenseWorkPerSettler.GetValueInt()
	EndFunction
	
	Function Set(Int aValue)
		WSWF_Setting_MaxDefenseWorkPerSettler.SetValue(aValue)
	EndFunction
EndProperty

Float WSWF_fAttackDamageToTheftRatio_Food = 1.0
Float Property AttackDamageToTheftRatio_Food
	Float Function Get()
		return WSWF_fAttackDamageToTheftRatio_Food
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fAttackDamageToTheftRatio_Food = aValue
	EndFunction
EndProperty

Float WSWF_fAttackDamageToTheftRatio_Water = 1.0
Float Property AttackDamageToTheftRatio_Water
	Float Function Get()
		return WSWF_fAttackDamageToTheftRatio_Water
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fAttackDamageToTheftRatio_Water = aValue
	EndFunction
EndProperty

Float WSWF_fAttackDamageToTheftRatio_Scrap = 1.0
Float Property AttackDamageToTheftRatio_Scrap
	Float Function Get()
		return WSWF_fAttackDamageToTheftRatio_Scrap
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fAttackDamageToTheftRatio_Scrap = aValue
	EndFunction
EndProperty


Float WSWF_fAttackDamageToTheftRatio_Caps = 1.0
Float Property AttackDamageToTheftRatio_Caps
	Float Function Get()
		return WSWF_fAttackDamageToTheftRatio_Caps
	EndFunction
	
	Function Set(Float aValue)
		WSWF_fAttackDamageToTheftRatio_Caps = aValue
	EndFunction
EndProperty

Bool WSWF_bExcludeProvisionersFromAssignmentRules = false ; If set to true, caravaneers won't be auto-unassigned when assigned to other things and instead a AssignmentRulesOverriden event will be thrown
Bool Property ExcludeProvisionersFromAssignmentRules
	Bool Function Get()
		return WSWF_bExcludeProvisionersFromAssignmentRules
	EndFunction
	
	Function Set(Bool aValue)
		WSWF_bExcludeProvisionersFromAssignmentRules = aValue
	EndFunction
EndProperty		


; ------------------------------------------------------
;
; WSWF - New Properties 
;
; ------------------------------------------------------

Group WSWF_Properties
	GlobalVariable Property WSWF_Setting_AutoAssignBeds Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_AutoAssignFood Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_AutoAssignDefense Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_MaxFoodWorkPerSettler Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_MaxDefenseWorkPerSettler Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_TradeCaravanMinimumPopulation Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_recruitmentMinPopulationForSynth Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_startingHappiness Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_startingHappinessMin Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_startingHappinessTarget Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_resolveAttackMaxAttackRoll Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_resolveAttackAllowedDamageMin Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_workshopRadioInnerRadius Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_workshopRadioOuterRadius Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_happinessModifierMax Auto Const Mandatory
	GlobalVariable Property WSWF_Setting_happinessModifierMin Auto Const Mandatory
	FormList Property ExcludeFromAssignmentRules Auto Const Mandatory
	{ Items in this list won't be auto-unassigned when a settler is assigned to them. Instead an event will be fired so the mod involved can act on the information. }
	WorkshopFramework:NPCManager Property WSWF_NPCManager Auto Const Mandatory
EndGroup


; ------------------------------------------------------
;
; WSWF - New Events
;
; ------------------------------------------------------

; WorkshopRemoveActor
;
; Event when an actor is removed from a settlement, via death or some other mechanism
; 
; kArgs[0] = actorRef
; kArgs[1] = workshopRef
CustomEvent WorkshopRemoveActor 

; WorkshopActorAssignedToBed
; Event when an actor is assigned to a bed (only fires if this is a new bed for them, as the bed code often runs quite frequently)
; 
; kArgs[0] = actorRef
; kArgs[1] = workshopRef
; kArgs[2] = objectRef
CustomEvent WorkshopActorAssignedToBed

; AssignmentRulesOverriden
;
; Event when an actor would normally be unassigned due to assignment rules, but was overridden because the item was found in the ExcludeFromAssignmentRules formlist
; kArgs[0] = objectRef or None for Caravan
; kArgs[1] = workshopRef
; kArgs[2] = actorRef
CustomEvent AssignmentRulesOverriden

; ------------------------------------------------------
;
; WSWF - New Functions
;
; ------------------------------------------------------


; Send forms you'd like to manage assignment rules for and register for the custom event: AssignmentRulesOverriden
Function ExcludeFromAssignmentRules(Form aFormOrListToExclude)
	FormList asFormlist = aFormOrListToExclude as FormList
	if(asFormlist)
		int i = 0
		int iCount = asFormlist.GetSize()
		while(i < iCount)
			ExcludeFromAssignmentRules.AddForm(asFormlist.GetAt(i))
			
			i += 1
		endWhile
	else
		ExcludeFromAssignmentRules.AddForm(aFormOrListToExclude)
	endif
EndFunction

; WSWF - Internal use
Bool Function IsExcludedFromAssignmentRules(Form aFormToCheck)
	if(aFormToCheck as ObjectReference)
		aFormToCheck = (aFormToCheck as ObjectReference).GetBaseObject()
	endif
	
	return ExcludeFromAssignmentRules.HasForm(aFormToCheck)
EndFunction

; WSWF - Internal use
Function UnassignActor_Private_SkipExclusions(WorkshopNPCScript akActorRef, WorkshopScript akWorkshopRef)
	; Check caravan
	if(ExcludeProvisionersFromAssignmentRules)
		Var[] kargs = new Var[0]
		kargs.Add(None)
		kargs.Add(akWorkshopRef)
		kargs.Add(akActorRef)
		
		SendCustomEvent("AssignmentRulesOverriden", kargs)
	else
		UnassignActorFromCaravan(akActorRef, akWorkshopRef, bRemoveFromWorkshop = false)
	endif
	
	if(UFO4P_IsWorkshopLoaded(akWorkshopRef))
		ObjectReference[] ResourceObjects = akWorkshopRef.GetWorkshopOwnedObjects(akActorRef)
		Bool bShouldTryToAssignResources = false
		int countResourceObjects = ResourceObjects.Length
		int i = 0
		while i < countResourceObjects
			ObjectReference objectRef = ResourceObjects[i]
			WorkshopObjectScript theObject = objectRef as WorkshopObjectScript
			
			if(theObject)
				if(theObject.HasKeyword(WorkshopWorkObject) && theObject.IsBed() == false)
					if(IsExcludedFromAssignmentRules(theObject))
						Var[] kargs = new Var[0]
						kargs.Add(theObject)
						kargs.Add(akWorkshopRef)
						kargs.Add(akActorRef)
						
						SendCustomEvent("AssignmentRulesOverriden", kargs)
					else
						;UFO4P 2.0.4 Bug #24273: calling this function with the new bool passed in as 'true':
						UnassignObject (theObject, bUnassignActorMode = true)
						;If at least one object has been removed, we should run the resource assignment functions to find a new owner:
						bShouldTryToAssignResources = true
						; WSWF Event Edit - Adding actor to the end of event arguments 
						Var[] kargs = new Var[0]
						kargs.Add(theObject)
						kargs.Add(akWorkshopRef)
						kargs.Add(akActorRef)
						
						SendCustomEvent("WorkshopActorUnassigned", kargs)
					endif
				endif
			endif
			
			i += 1
		endWhile
		
		;If not in reset mode, try to find new owners for unassigned objects:
		if(bShouldTryToAssignResources && akWorkshopRef.GetWorkshopID() == currentWorkshopID)
			TryToAssignResourceType(akWorkshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
			TryToAssignResourceType(akWorkshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
		endif
	endif
EndFunction



Event Location.OnLocationCleared(Location akSender)
	WorkshopScript workshopRef = GetWorkshopFromLocation(akSender)

	wsTrace("OnLocationCleared: Sender location = " + akSender)
	if workshopRef && workshopRef.OwnedByPlayer
		UpdateMinutemenRecruitmentAvailable()
	endif

	;UFO4P 1.0.3 Bug #20669: Unregister for remote event from this location (Note: this event fires every time enemies get to the workshop location and the
	;last one of them is killed. As this won't change workshop ownership, running UpdateMinutemenRecruitmentAvailable again is superfluous)
	UnregisterForRemoteEvent(akSender, "OnLocationCleared")
endEvent


; NOTE: changed from OnInit because of timing issues - startup stage will not be set until aliases are filled
Event OnStageSet(int auiStageID, int auiItemID)
	wsTrace(self + " stage=" + auiStageID)
	if auiStageID == 10
		; open workshop log
		debug.OpenUserLog(userlogName)

		; initialize workshop arrays
		WorkshopLocations = new Location[WorkshopsCollection.GetCount()]
		Workshops = new WorkshopScript[WorkshopsCollection.GetCount()]
		WorkshopRatingValues = new ActorValue[WorkshopRatings.Length]

		int index = 0
		int crimeFactionIndex = 0

		wsTrace(" OnInit: initializing workshop arrays...", bNormalTraceAlso = true)
		while index < WorkshopsCollection.GetCount()
			wsTrace(" OnInit: " + index + " of " + WorkshopsCollection.GetCount())
			WorkshopScript workshopRef = WorkshopsCollection.GetAt(index) as WorkshopScript
			wsTrace("	" + workshopRef + ": EnableAutomaticPlayerOwnership=" + workshopRef.EnableAutomaticPlayerOwnership)
			; add workshop to array
			Workshops[index] = workshopRef
			; initialize workshopID on this workshop
			workshopRef.InitWorkshopID(index)
			; initialize location
			WorkshopLocations[index] = workshopRef.GetCurrentLocation()
			workshopRef.myLocation = WorkshopLocations[index]
			; initialize happiness to 50 for safety
			workshopRef.SetValue(WorkshopRatings[WorkshopRatingHappiness].resourceValue, startingHappiness)
			; register for location cleared events
			RegisterForRemoteEvent(WorkshopLocations[index], "OnLocationCleared")

			; set ownership/crime faction if it doesn't have one already
			if workshopRef.SettlementOwnershipFaction == NONE && workshopRef.UseOwnershipFaction && crimeFactionIndex < WorkshopCrimeFactions.GetSize()
				workshopRef.SettlementOwnershipFaction = WorkshopCrimeFactions.GetAt(crimeFactionIndex) as Faction
				crimeFactionIndex += 1
			endif

			wsTrace(" OnInit: location " + index + "=" + WorkshopLocations[index])
			; register for daily update
			Workshops[index].RegisterForCustomEvent(self, "WorkshopDailyUpdate")

			index += 1
		endWhile
		wsTrace(" OnInit: initializing WorkshopLocations... DONE ", bNormalTraceAlso = true)

		index = 0
		wsTrace(" OnInit: initializing workshop keyword array...", bNormalTraceAlso = true)
		int resourceAVCount = 0
		while index < WorkshopRatings.Length
			wsTrace(" OnInit: keyword " + index + "=" + WorkshopRatings[index].resourceValue)
			; add keyword to array
			WorkshopRatingValues[index] = WorkshopRatings[index].resourceValue
			; if this has a resource AV, increment count
			if WorkshopRatings[index].resourceValue
				resourceAVCount += 1
				wsTrace(" OnInit: found resourceValue= " + WorkshopRatings[index].resourceValue + ", resourceAVCount=" + resourceAVCount)
			endif
			index += 1
		endWhile
		wsTrace(" OnInit: initializing WorkshopRatingValues... DONE.", bNormalTraceAlso = true)

		; initialize workshop resource AV array
		wstrace(" OnInit: initializing WorkshopResourceAVs array to " + resourceAVCount)
		WorkshopResourceAVs = new WorkshopActorValue[resourceAVCount]

		index = 0
		int resourceAVIndex = 0
		wsTrace(" OnInit: initializing workshop resource AV array...", bNormalTraceAlso = true)
		while index < WorkshopRatings.Length
			; if this has a resource AV, add to resource AV array and increment index
			if WorkshopRatings[index].resourceValue
				wsTrace(" OnInit: resource AV " + resourceAVIndex + "=" + WorkshopRatings[index].resourceValue, bNormalTraceAlso = true)
				WorkshopResourceAVs[resourceAVIndex] = new WorkshopActorValue
				WorkshopResourceAVs[resourceAVIndex].workshopRatingIndex = index
				WorkshopResourceAVs[resourceAVIndex].resourceValue = WorkshopRatings[index].resourceValue
				wsTrace(" 		WorkshopResourceAVs[" + resourceAVIndex + "].resourceValue=" + WorkshopResourceAVs[resourceAVIndex].resourceValue)

				resourceAVIndex += 1
			endif
			index += 1
		endWhile

		; initialize Minutemen recruitment available
		UpdateMinutemenRecruitmentAvailable()

		; get location change events for player
		RegisterForRemoteEvent(Game.GetPlayer(), "OnLocationChange")
		
		; start daily update timer
		wsTrace(" OnInit: starting workshop daily timer: updateIntervalGameHours=" + updateIntervalGameHours + ", dailyUpdateTimerID=" + dailyUpdateTimerID, bNormalTraceAlso = true)
		StartTimerGameTime(updateIntervalGameHours, dailyUpdateTimerID)

		; start initialize workshop locations process
		RegisterForCustomEvent(self, "WorkshopInitializeLocation")
		SendCustomEvent("WorkshopInitializeLocation")		

		Initialized = true
	endif
endEvent

function InitializeLocation(WorkshopScript workshopRef, RefCollectionAlias SettlementNPCs, ReferenceAlias theLeader, ReferenceAlias theMapMarker)
	wsTrace(" Initializing location START: " + workshopRef.myLocation)
	workshopRef.myMapMarker = theMapMarker.GetRef()

	; force recalc (unloaded workshop)
	workshopRef.RecalculateWorkshopResources(true)
	
	int initPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
	int initPopulationVal = workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
	wsTrace(" 		initPopulation (before)=" + initPopulation)
	wsTrace(" 		initPopulationVal (before)=" + initPopulationVal)
	if SettlementNPCs
		AddCollectionToWorkshopPUBLIC(SettlementNPCs, workshopRef, true)
	endif
	if theLeader && theLeader.GetActorRef()
		AddActorToWorkshopPUBLIC(theLeader.GetActorRef() as WorkshopNPCScript, workshopRef, true)
	endif 

	initPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
	initPopulationVal = workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
	wsTrace(" 		initPopulation (after)=" + initPopulation)
	wsTrace(" 		initPopulationVal (before)=" + initPopulationVal)
	int robotPopulation = 0
	if workshopRef.myLocation.HasKeyword(LocTypeWorkshopRobotsOnly)
		; this means everyone here (at game start) is a robot
		robotPopulation = initPopulation
	endif
	;UFO4P 2.0 Bug #21896: Call ModifyResourceData_Private instead of ModifyResourceData here (see notes on that function for explanation)
	ModifyResourceData_Private(WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue, workshopRef, robotPopulation)

	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData below (see notes on that function for explanation)

	; initialize ratings if it has population
	if initPopulation > 0
		wsTrace(" 		init population = " + initPopulation)
		; happiness
		SetResourceData_Private(WorkshopRatings[WorkshopRatingHappiness].resourceValue, workshopRef, startingHappiness)
		; set food, water, beds equal to population (this will be corrected to reality the first time the player visits the location)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingFood].resourceValue, workshopRef, initPopulation)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingWater].resourceValue, workshopRef, initPopulation)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingBeds].resourceValue, workshopRef, initPopulation - robotPopulation)
		; set "last attacked" to a very large number (so they don't act like they were just attacked)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingLastAttackDaysSince].resourceValue, workshopRef, 99)
	endif

	wsTrace(" Initializing location DONE: " + workshopRef.myLocation + ": population=" + initPopulation, bNormalTraceAlso = true)

	; send "done" event
	Var[] kargs = new Var[1]
	kargs[0] = workshopRef
	wsTrace(" 	sending WorkshopInitializeLocation event")
	SendCustomEvent("WorkshopInitializeLocation", kargs)		
endFunction

int initializationIndex = 0
Event WorkshopParentScript.WorkshopInitializeLocation(WorkshopParentScript akSender, Var[] akArgs)
	wsTrace("WorkshopInitializeLocation event received " + initializationIndex, bNormalTraceAlso = true)
	WorkshopScript nextWorkshopRef = NONE
	if (akArgs.Length > 0)
		WorkshopScript workshopRef = akArgs[0] as WorkshopScript
		if workshopRef
			; this is the location that was just initialized - find the next
			;int newWorkshopIndex = workshopRef.GetWorkshopID() + 1
			; Try just going up through the array
			initializationIndex += 1
			int newWorkshopIndex = initializationIndex
			if newWorkshopIndex >= Workshops.Length
				wsTrace(" WorkshopInitializeLocation: Finished all locations", bNormalTraceAlso = true)

				setStage(20) ; way to easily track when this is done
				
				; initial daily update
				DailyWorkshopUpdate(true)
				; reset daily update timer - failsafe
				wsTrace(" WorkshopInitializeLocation: resetting workshop daily timer: updateIntervalGameHours=" + updateIntervalGameHours + ", dailyUpdateTimerID=" + dailyUpdateTimerID, bNormalTraceAlso = true)
				StartTimerGameTime(updateIntervalGameHours, dailyUpdateTimerID)
			else
				wsTrace(" 	workshop done: " + workshopRef.myLocation + "(" + workshopRef.GetWorkshopID() + ")")
				; send story event for next workshop location
				nextWorkshopRef = workshops[newWorkshopIndex]
			endif

		else
			wsTrace(" WARNING: WorkshopInitializeLocation event received with invalid args", bNormalTraceAlso = true)
		endif
	else
		wsTrace(" 	No parameters- start with workshop 0=" + Workshops[0].myLocation, bNormalTraceAlso = true)
		; if no location sent, start with first
		nextWorkshopRef = Workshops[0]
	endif

	; send event if we found next workshop
	if nextWorkshopRef
		wsTrace(" 	send story event for next workshop: " + nextWorkshopRef.myLocation + "(" + nextWorkshopRef.GetWorkshopID() + ")")
		; wait a bit for quest to finish shutting down
		int maxWait = 5
		int i = 0
		while i < maxWait && WorkshopInitializeLocation.IsStopped() == false
			wsTrace("	waiting for WorkshopInitializeLocation to shut down..." + i)
			utility.wait(1.0)
			i += 1
		endWhile
		bool bSuccess = WorkshopEventInitializeLocation.SendStoryEventAndWait(nextWorkshopRef.myLocation)
		if !bSuccess
			; quest failed to start for this location - skip it and move on
			wstrace("	WARNING: WorkshopInitializeLocation quest failed to start for " + nextWorkshopRef.myLocation)
			; send "done" event
			Var[] kargs = new Var[1]
			kargs[0] = nextWorkshopRef
			wsTrace(" 	sending WorkshopInitializeLocation event")
			SendCustomEvent("WorkshopInitializeLocation", kargs)		
		endif
	endif
EndEvent

; called when new locations are added (e.g. by DLC init quests)
; newWorkshops - array of new workshops to check for
; return value:
;		TRUE = initializeEventHandler needs to handle initialize events for new locations
;		FALSE = no locations need to be initialized (all are already in Workshops array)
bool function ReinitializeLocationsPUBLIC(WorkshopScript[] newWorkshops, Form initializeEventHandler)
	; wait for main initialization process to finish
	while GetStageDone(20) == false
		debug.trace( " ... waiting for primary WorkshopInitializeLocation process to finish...")
		utility.wait(2.0)
	endWhile

	; lock editing
	GetEditLock()

	; make sure to unregister WorkshopParent from this event - DLC will register and handle the event for themselves
	UnregisterForCustomEvent(self, "WorkshopInitializeLocation")

	; save current size of Workshops array - this will be our starting point for the new init loop
	int startingNewWorkshopIndex = Workshops.Length

	; run through newWorkshops to see if they're already in the workshop list
	int i = 0
	while i < newWorkshops.Length
		WorkshopScript workshopRef = newWorkshops[i]
		; is this already in Workshops array?
		int workshopIndex = Workshops.Find(workshopRef)
		if workshopIndex == -1
			; not in list - add me to arrays and initialize
			; NOTE: this basically replicates code in OnStageSet, but safer to duplicate it here than change that to a function call
			; START:
				; add workshop to array
				Workshops.Add(workshopRef)
				int newIndex = Workshops.Length-1
				; initialize workshopID on this workshop to the index
				workshopRef.InitWorkshopID(newIndex)
				; initialize location
				WorkshopLocations.Add(workshopRef.GetCurrentLocation())
				workshopRef.myLocation = WorkshopLocations[newIndex]
				; initialize happiness to 50 for safety
				workshopRef.SetValue(WorkshopRatings[WorkshopRatingHappiness].resourceValue, startingHappiness)
				; register for location cleared events
				RegisterForRemoteEvent(WorkshopLocations[newIndex], "OnLocationCleared")

				; NOTE: ownership/crime faction must be set on new workshops manually

				debug.trace(" OnInit: location " + newIndex + "=" + WorkshopLocations[newIndex])
				; register for daily update
				Workshops[newIndex].RegisterForCustomEvent(self, "WorkshopDailyUpdate")
			; END
		endif
		i += 1
	endWhile

	; if we added any new locations, need to initialize them
	bool bLocationsToInit = (startingNewWorkshopIndex < Workshops.Length)
	if bLocationsToInit
		; whatever was passed in will handle this event
		initializeEventHandler.RegisterForCustomEvent(self, "WorkshopInitializeLocation")

		; start the process by sending the event with the LAST initialized workshop (top of original Workshops array)
		WorkshopScript lastInitializedWorkshop = Workshops[startingNewWorkshopIndex - 1]
		Var[] kargs = new Var[1]
		kargs[0] = lastInitializedWorkshop
		debug.trace(" 	sending WorkshopInitializeLocation event for " + lastInitializedWorkshop)
		SendCustomEvent("WorkshopInitializeLocation", kargs)		
	endif

	debug.trace(" ReinitializeLocationsPUBLIC DONE")

	; unlock editing
	EditLock = false

	return bLocationsToInit
endFunction

; returns the total in all player-owned settlements for the specified rating
float function GetWorkshopRatingTotal(int ratingIndex)
	wsTrace(self + " GetWorkshopRatingTotal:")
	ActorValue resourceValue = GetRatingAV(ratingIndex)

	; go through player-owned workshops
	int index = 0
	float total = 0.0
	while index < Workshops.Length
		if Workshops[index].GetValue(WorkshopPlayerOwnership) > 0
			total += Workshops[index].GetValue(resourceValue)
		endif
		index += 1
	endWhile
	wsTrace(self + "GetWorkshopRatingTotal: " + resourceValue + "=" + total)
	return total
endFunction

; returns the total of player-owned settlements for the specified rating
int function GetWorkshopRatingLocations(int ratingIndex, float ratingMustBeGreaterThan = 0.0)
	actorValue resourceValue = GetRatingAV(ratingIndex)
	wsTrace(self + " GetWorkshopRatingLocations for "  + resourceValue + ":")

	; go through player-owned locations
	int index = 0
	int locationCount = 0
	while index < Workshops.Length
		;debug.trace(self + " index: " + index + ": " + workshops[index])
		if Workshops[index].GetValue(WorkshopPlayerOwnership) > 0 && Workshops[index].GetValue(resourceValue) > ratingMustBeGreaterThan
			wsTrace(self + " 	found valid location " + Workshops[index].myLocation)
			locationCount += 1
		endif
		index += 1
	endWhile
	wsTrace(self + "GetWorkshopRatingLocations: location count = " + locationCount)
	return locationCount
endFunction


; utility function - updates flag used to indicate if there are any settlements available for recruitment
function UpdateMinutemenRecruitmentAvailable()
	wsTrace(self + " UpdateMinutemenRecruitmentAvailable:", bNormalTraceAlso = true)
	; go through locations - looking for:
	; * not player-owned
	; * population > 0
	int index = 0
	int neutralCount = 0	 ; count the number of "neutral" settlements (not owned by player)
	int totalCount = 0		; count total number of populated settlements
	while index < Workshops.Length
		WorkshopScript workshopRef = Workshops[index]
		;wstrace(self + " Workshops[" + index + "]=" + workshopRef)
		If workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) > 0 && workshopRef.HasKeyword(WorkshopType02) == false && workshopRef.HasKeyword(WorkshopType02Vassal) == false
			;wsTrace(self + " 	" + workshopRef + ": valid workshop settlement, population rating = " + workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue), bNormalTraceAlso = true)
			totalCount += 1
			if workshopRef.GetValue(WorkshopPlayerOwnership) == 0
				;wsTrace(self + " 		- not owned by player - add to neutral count", bNormalTraceAlso = true)
				neutralCount += 1
			endif
		endif
		index += 1
	endWhile
	;wsTrace(self + "UpdateMinutemenRecruitmentAvailable: " + neutralCount + " neutral, " + totalCount + " total", bNormalTraceAlso = true)
	; update globals
	MinutemenRecruitmentAvailable.SetValue(neutralCount)
	MinutemenOwnedSettlements.SetValue(totalCount - neutralCount)
	;UFO4P: Added trace
	wsTrace(self + " UpdateMinutemenRecruitmentAvailable: DONE", bNormalTraceAlso = true)
endFunction

Event OnTimerGameTime(int aiTimerID)
	wsTrace(" OnTimerGameTime: timerID=" + aiTimerID)
	if aiTimerID == dailyUpdateTimerID
		DailyWorkshopUpdate()
		; start timer again
		wsTrace(" OnTimerGameTime: restarting workshop daily timer: updateIntervalGameHours=" + updateIntervalGameHours + ", dailyUpdateTimerID=" + dailyUpdateTimerID, bNormalTraceAlso = true)
		StartTimerGameTime(updateIntervalGameHours, dailyUpdateTimerID)
	endif
EndEvent


Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
	;;debug.trace(self + " OnLocationChange: akNewLoc=" + akNewLoc)

	;UFO4P 1.0.3 Bug #20576 - GENERAL NOTES:
	;---------------------------------------
	;While monitoring this script's activities in debug mode, it was found that this event fires when the player activates the workbench (this is handled as a
	;location exit event below) and again when he leaves the menu/workshop mode (handled as a location enter event below). As a result, the reset procedure could
	;be repeated over and over again. This is not a problem at game start when settlements are small and the reset takes less than a minute. Though later on, when
	;the settlements grow, the function draws much performance and may take several minutes to complete. Sine other functions are locked out from editing work-
	;shop-related data while it's rtunning, this could lead to assignment of settlers to newly built objects taking an exceedingly long time or not working at
	;all. To prevent unnecessary resets from being carried out, this event has been modified as follows:
	;
	;(1) When the player apparently leaves from a settlement location, this location is stored in the new tracking variable UFO4P_PreviousWorkshopLocation
	;(2) When the reset function starts running, the game time is stored in the new variable UFO4P_GameTimeOfLastResetStarted
	;
	;When the player apparently enters a settlement location, the event now checks whether this is the same as the one he just left (by comparing akNewLoc
	;to UFO4P_PreviousWorkshopLocation). If this is true AND the last reset started running less than a game day before, it will not be run again. Note that
	;short leaves from the location (with 'valid' change location events), e.g. to check the environment after the turrets started shooting at something, will
	;also not result in repeated resets carried out. Travels to other locations and back only do when the workshop location unloads in the meantime or when they
	;take more than one game day.

	if akNewLoc && akNewLoc.HasKeyword(LocTypeWorkshopSettlement)
		;wsTrace(" OnLocationChange: entered workshop settlement location " + akNewLoc)
		; when player enters a workshop location, recalc the workbench ratings
		; get the workbench
		WorkshopScript workshopRef = GetWorkshopFromLocation(akNewLoc)
		if !workshopRef
			wsTrace(" ERROR - OnLocationChange: failed to find workshop matching " + akNewLoc + " which has the LocTypeWorkshopSettlement keyword", 2)
			return
		else
			;UFO4P 2.0.2 Bug #23016: Moved this line up here from the ResetWorkshop function:
			;This makes sure that all properties holding the current workshop are updated as soon as the player arrives at a workshop location.
			;If a reset is delayed, this would have happened with some delay otherwise because only the reset would have called this function.
			SetCurrentWorkshop (workshopRef)

			;UFO4P 1.0.3 Bug #20576: Check whether the player really entered a new location.
			;If NOT, skip the reset if the last reset of this location ran less than a game day ago.
			;UFO4P 2.0 Bug #21895: Added a check for UFO4P_CurrentlyUnderAttack: always perform a reset (but delay it, see below) if the workshop is
			;currently under attack:
			if workshopRef.UFO4P_CurrentlyUnderAttack == false
				if UFO4P_PreviousWorkshopLocation && UFO4P_PreviousWorkshopLocation.IsSameLocation (akNewLoc)
					;wsTrace(" OnLocationChange: New workshop location is the same as the last workshop location left by the player.")
					Float UFO4P_GameTimeSinceLastReset = Utility.GetCurrentGameTime() - UFO4P_GameTimeOfLastResetStarted
					;wsTrace(" OnLocationChange: Game time since last reset = " + UFO4P_GameTimeSinceLastReset)
					if UFO4P_GameTimeSinceLastReset < 1
						;wsTrace(" OnLocationChange: Skipping reset.")
						Return
					endIf
				endIf
			endIf

			;UFO4P 2.0.4 Bug #24312: also initialize the new helper arrays:
			;As soon as the workshop is loaded, any new actors or assignable obkects created should be put in these arrays (this will save the
			;object and actor assignment functions much time), so they need to be initialized as soon as possible.
			UFO4P_InitCurrentWorkshopArrays()

			;UFO4P 2.0 Bug #21895: Suspend the reset if the workshop is currently under attack. Also set UFO4P_AttackRunning to 'true' to delay
			;any daily updates of the workshop scripts while the attack is physically running:
			if workshopRef.UFO4P_CurrentlyUnderAttack
				UFO4P_AttackRunning = true
				UFO4P_WorkshopRef_ResetDelayed = workshopRef
				wsTrace(" OnLocationChange: Workshop location is under attack right now. Suspending workshop reset.")
			else
				;UFO4P 1.0.3 Bug #20576: Remember the current game time as the time when the last reset started running:
				UFO4P_GameTimeOfLastResetStarted = Utility.GetCurrentGameTime()
				ResetWorkshop(workshopRef)
			endIf
		EndIf
	EndIf


	if akOldLoc && akOldLoc.HasKeyword(LocTypeWorkshopSettlement)		
		;wsTrace(" OnLocationChange: exited workshop location " + akOldLoc)
		; when player leaves a workshop location, recalc the workbench ratings
		; get the workbench
		WorkshopScript workshopRef = GetWorkshopFromLocation(akOldLoc)
		if !workshopRef
			wsTrace(" ERROR - OnLocationChange: failed to find workshop matching " + akOldLoc + " which has the LocTypeWorkshopSettlement keyword", 2)
			return
		else
			;UFO4P 1.0.3 Bug #20576: Remember this location as the last workshop visited by the player
			UFO4P_PreviousWorkshopLocation = akOldLoc
			; reset days since last visit for this workshop
			workshopRef.DaysSinceLastVisit = 0
		endif
	endif

EndEvent


WorkshopScript function GetWorkshopFromLocation(Location workshopLocation)
	int index = WorkshopLocations.Find(workshopLocation)
	if index < 0
		wsTrace(" ERROR - GetWorkshopFromLocation: workshop location " + workshopLocation + " not found in WorkshopLocations array", 2)
		return NONE	
	else
		return Workshops[index] as WorkshopScript
	endif
endFunction

int tempBuildCounter = 0

; main function called by workshop when new object is built
bool function BuildObjectPUBLIC(ObjectReference newObject, WorkshopScript workshopRef)
	; lock editing
	GetEditLock()

	tempBuildCounter += 1
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" BuildObject: " + tempBuildCounter + " " + newObject + " from " + workshopRef)

	WorkshopObjectScript newWorkshopObject = newObject as WorkshopObjectScript

	; if this is a scripted object, check for input/output data
	if newWorkshopObject
		; tag with workshopID
		newWorkshopObject.workshopID = workshopRef.GetWorkshopID()
		;AssignObjectToWorkshop(newWorkshopObject, workshopRef, true) ; reset mode = true --> don't try to assign work each time; this is handled by a timer on WorkshopScript
		;UFO4P 2.0.4 Bug #24312; replaced the previous line with the following line:
		;Calling this function with bResetMode = false. Assignment procedures are now fast enough to call them directly.
		AssignObjectToWorkshop(newWorkshopObject, workshopRef, false)
		
		; object handles any creation needs
		newWorkshopObject.HandleCreation(true)

		; send custom event for this object
		Var[] kargs = new Var[2]
		kargs[0] = newWorkshopObject
		kargs[1] = workshopRef
		;wsTrace(" 	sending WorkshopObjectBuilt event")
		SendCustomEvent("WorkshopObjectBuilt", kargs)		

	endif

	wsTrace(" BuildObject DONE: " + tempBuildCounter + " (editLockCount=" + editLockCount + ") " + newObject)
	wsTrace("------------------------------------------------------------------------------ ")

	; unlock building
	EditLock = false

	; return true if this is a scripted object
	return ( newWorkshopObject != NONE )
endFunction

; called by WorkshopScript on timer periodically to keep new work objects assigned
function TryToAssignResourceObjectsPUBLIC(WorkshopScript workshopRef)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" TryToAssignResourceObjectsPUBLIC: " + workshopRef)
	; lock editing
	GetEditLock()
	
	TryToAssignResourceType(workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
	TryToAssignResourceType(workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
	TryToAssignBeds(workshopRef)

	wsTrace(" TryToAssignResourceObjectsPUBLIC DONE: " + workshopRef)
	wsTrace("------------------------------------------------------------------------------ ")

	; unlock building
	EditLock = false
endFunction

;UFO4P 2.0 Bug #21898: Edit lock added to the following function. This function is only called by external scripts (from events on WorkshopNPCScript, and
;from WorkshopScript while running daily updates) but could call the ModifyResourceData and UpdateActorsWorkObjects functions directly (i.e. without making
;sure that they are not currently locked by other threads using them). This could lead to interferences since both the ModifyResourceData and UpdateWorkshop
;RatingsForResourceObject functions (the latter may be called from UpdateActorsWorkObjects) modify resource data values and both functions have many users, 
function WoundActor(WorkShopNPCScript woundedActor, bool bWoundMe = true)

	;UFO4P 2.0 Bug #21578:
	;There is a small chance that calls of this function occur in the wrong order (i.e. this function may be called to set an actor as wounded when he is
	;already wounded or to set him as not wounded when he is not wounded). In this case, there will be always a subsequent out-of order call that cancels
	;everything the first call did, so both calls need to be skipped:
	
	;bool UFO4P_AlreadyWounded = woundedActor.IsWounded()
	;if (UFO4P_AlreadyWounded && bWoundMe) || (UFO4P_AlreadyWounded == false && bWoundMe == false)
	
	;UFO4P 2.0.4: simplified this:
	if woundedActor.IsWounded() == bWoundMe
		return
	endif

	;UFO4P 2.0 Bug #21898: lock editing
	GetEditLock()

	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" WoundActor: " + woundedActor + ", bWoundMe=" + bWoundMe)

	; get actor's workshop
	WorkshopScript workshopRef = GetWorkshop(woundedActor.GetWorkshopID())
	; wound/heal actor
	woundedActor.SetWounded(bWoundMe)

	; increase or decrease damage?
	int damageValue = 1
	if !bWoundMe
		damageValue = -1
	endif

	; update damage rating
	; RESOURCE CHANGE:
	; reduce extra pop damage if > 0 ; otherwise, damage is normally tracked within WorkshopRatingPopulation (difference between base value and current value)
	if bWoundMe == false && workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue) > 0
		;UFO4P 2.0 Bug #21896: Call ModifyResourceData_Private instead of ModifyResourceData here (see notes on that function for explanation)
		ModifyResourceData_Private(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue, workshopRef, damageValue)
	endif

	; update my work objects for "can produce"
	;UFO4P 2.0 Bug #21550: Call UpdateActorsWorkObjects_Private instead of UpdateActorsWorkObjects here (see notes on that function for explanation)
	UpdateActorsWorkObjects_Private(woundedActor, workshopRef, true)

	wsTrace(" WoundActor: DONE")
	wsTrace("------------------------------------------------------------------------------ ")

	;UFO4P 2.0 Bug #21898: unlock editing
	EditLock = false
endFunction

;UFO4P 2.0 Bug #21899: Edit lock added to the following function (for the same reasons as explained above for the WoundActor function).
function HandleActorDeath(WorkShopNPCScript deadActor, Actor akKiller)
	;UFO4P 2.0 Bug #21899: lock editing
	GetEditLock()

	; get actor's workshop
	WorkshopScript workshopRef = GetWorkshop(deadActor.GetWorkshopID())

	;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes on that function for explanation)
	UnassignActor_Private(deadActor, bRemoveFromWorkshop = true)
	
		; consequences of death:
	; for people, count this as negative to happiness (blame player since they're all protected)
	if deadActor.bCountsForPopulation
		; WSWF - Using workshop local version
		;ModifyHappinessModifier(workshopRef, actorDeathHappinessModifier)
		ModifyHappinessModifier(workshopRef, workshopRef.actorDeathHappinessModifier)
	endif	

	;UFO4P 2.0 Bug #21899: unlock editing
	EditLock = false
endFunction

;UFO4P 2.0 Bug #21550: Added a public version of the UpdateActorsWorkObjects function (not threading-safe because it calls an external script to fill the
;ResourceObjects array), for use by calls from WorkshopScript (instead of calling the UpdateActors WorkObjects function directly). Since this function touches
;sensitive date (it may modify workshop ratings), it should be used by only one thread at a time. Note that the new public function has been given the name
;of the old (non-public) vanilla function, while the vanilla function itself has been renamed UpdateActorsWorkObjects_Private (and all calls of that function
;from locked threads within this script have been modified to call UpdateActorsWorkObjects_Private now instead of UpdateActorsWorkObjects). Handling it in
;this way has the advantage that all external users will now automatically call a public (locked) function without modifications to the respective scripts.
function UpdateActorsWorkObjects(WorkShopNPCScript theActor, WorkshopScript workshopRef = NONE, bool bRecalculateResources = false)
	GetEditLock()
	UpdateActorsWorkObjects_Private(theActor, workshopRef, bRecalculateResources)
	EditLock = false
endFunction


function UpdateActorsWorkObjects_Private(WorkShopNPCScript theActor, WorkshopScript workshopRef = NONE, bool bRecalculateResources = false)
	;------------------------------------------------------------------------------------------------------------------------------------
	;	UFO4P 2.0.4 Bugs #23948 and #24122:
	;	Further modifications to this function would have made the code almost illegible, so the function has been rewritten and all
	;------------------------------------------------------------------------------------------------------------------------------------

	if workshopRef == none
		;workshopRef = GetWorkshop(theActor.GetWorkshopID())
		;UFO4P 2.0.4 Bug #23948: replaced the previous line with the following code block:
		;This is to bail out if an actor with invalid workshopID is passed in and to log the reference of that actor.	
		int workshopID = theActor.GetWorkshopID()
		if workshopID < 0
			wsTrace(self + " UpdateActorsWorkObjects_Private: Actor " + theActor + " has no valid workshopID. Returning ... ")
			return
		endif
		workshopRef = GetWorkshop (workshopID)		
	endif

	;UFO4P 2.0.4 Bug #24122: If the workshop is not loaded, the ResourceObjects array will be empty.
	;Better bail out here instead of wasting resources by trying it anyway.
	if UFO4P_IsWorkshopLoaded (workshopRef) == false
		wsTrace(" UpdateActorsWorkObjects_Private: " + workshopRef + " is not loaded. Returning ...")
		return
	endif

	wsTrace(self + " UpdateActorsWorkObjects_Private: Actor = " + theActor + ", Workshop = " + workshopRef)

	ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects(theActor)
	int countResourceObjects = ResourceObjects.Length
	int i = 0
	
	while i < countResourceObjects
		WorkshopObjectScript theObject = ResourceObjects[i] as WorkshopObjectScript
		if theObject
			UpdateWorkshopRatingsForResourceObject (theObject, workshopRef, bRecalculateResources = bRecalculateResources)
		endif
		i += 1
	endWhile

	wsTrace(self + " UpdateActorsWorkObjects_Private: DONE")

endFunction

; main function called by workshop when object is deleted
function RemoveObjectPUBLIC(ObjectReference removedObject, WorkshopScript workshopRef)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" RemoveObject: " + removedObject + " from " + workshopRef)

	; lock editing
	GetEditLock()
	WorkshopObjectScript workObject = removedObject as WorkshopObjectScript

	; if this is a scripted object, check for input/output data
	if workObject
		RemoveObjectFromWorkshop(workObject, workshopRef)

		; send custom event for this object
		Var[] kargs = new Var[2]
		kargs[0] = workObject
		kargs[1] = workshopRef
		SendCustomEvent("WorkshopObjectDestroyed", kargs)		
	endif

	; unlock building
	EditLock = false
endFunction

; called when a workshop object is deleted
function RemoveObjectFromWorkshop(WorkshopObjectScript workObject, WorkshopScript workshopRef)
	;UnassignObject(workObject, true)
	;UFO4P 2.0.4 Bug #24273: replaced the previous line with the following line:
	;Since UnassignObject now has two bool arguments, we need to make sure that 'true' is passed in to the right one.
	UnassignObject(workObject, bRemoveObject = true)

	; clear workshopID
	workObject.workshopID = -1

	; tell object it's being deleted
	workObject.HandleDeletion()

endFunction

;------------------------------------------------------------------
;	UFO4P 1.0.5 Bug #21002 (Regression of UFO4P 1.0.3 Bug #20581)
;------------------------------------------------------------------

;The following edits by UFO4P 1.0.3 have been removed entirely and the vanilla version of the CreateActorPUBLIC function has been restored (see notes on
;WorkshopScript for further information):

; UFO4P 1.0.3 Bug #20581: Modified this function to conform with the (non-public) CreateActor function. The vanilla version of this function is preserved below.
;WorkshopNPCScript function CreateActorPUBLIC(WorkshopScript workshopRef, ObjectReference spawnMarker = NONE, bool bNewSettlerAlias = false, bool bBrahmin = false )
;	 lock editing
	;GetEditLock()
	;WorkshopNPCScript NewActorScript = CreateActor(workshopRef, bBrahmin, spawnMarker, bNewSettlerAlias)
;	 unlock editing
	;EditLock = false
	;Return NewActorScript
;endFunction

;------------------------------------------------------------------

; Create a new actor and assign it to the specified workshop
function CreateActorPUBLIC(WorkshopScript workshopRef, ObjectReference spawnMarker = NONE, bool bNewSettlerAlias = false)
	; lock editing
	GetEditLock()
	CreateActor(workshopRef, false, spawnMarker, bNewSettlerAlias)
	; unlock editing
	EditLock = false
endFunction

;------------------------------------------------------------------
;	UFO4P 1.0.5 Bug #21002 (Regression of UFO4P 1.0.3 Bug #20581)
;------------------------------------------------------------------

;After the regression, there still remained the problem that the DailyUpdate function called the non-public CreateActor function on this script directly
;which it should not be doing (i.e. bug #20581 still required an appropriate solution). To handle this, the following function was created as a new safe
;(public) entry point that will be used by the daily updates on WorkshopScript exclusively:

WorkshopNPCScript function CreateActor_DailyUpdate(WorkshopScript workshopRef, bool bBrahmin = false, ObjectReference spawnMarker = NONE, bool bNewSettlerAlias = false)
	GetEditLock()
	WorkshopNPCScript NewActorScript = CreateActor(workshopRef, bBrahmin, spawnMarker, bNewSettlerAlias)
	EditLock = false
	return NewActorScript
endFunction

;------------------------------------------------------------------


WorkshopNPCScript function CreateActor(WorkshopScript workshopRef, bool bBrahmin = false, ObjectReference spawnMarker = NONE, bool bNewSettlerAlias = false)
	; WSWF - Rerouting to our NPCManager quest
	if(bBrahmin)
		return WSWF_NPCManager.CreateBrahmin(workshopRef, spawnMarker)
	else
		return WSWF_NPCManager.CreateSettler(workshopRef, spawnMarker)
	endif
endFunction


function TryToAutoAssignActor(WorkshopScript workshopRef, WorkshopNPCScript actorToAssign)
	;/	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;
	
	; WSWF - Introduced autoassign controls
	Bool bAutoAssignBeds = AutoAssignBeds
	Bool bAutoAssignFood = AutoAssignFood
	Bool bAutoAssignDefense = AutoAssignDefense
	
	if( ! bAutoAssignBeds && ! bAutoAssignFood && ! bAutoAssignDefense)
		return
	endif
	
	;UFO4P 2.0.4 Bug #24122: This function never succeeds if the workshop is not loaded..
	;Better bail out here instead of wasting resources by trying it anyway.
	if UFO4P_IsWorkshopLoaded (workshopRef) == false
		wsTrace(" TryToAutoAssignActor: " + workshopRef + " is not loaded. Returning ...")
		return
	endif

	int resourceIndex
	if actorToAssign.GetValue (WorkshopGuardPreference) > 0
		resourceIndex = WorkshopRatingSafety		
	else
		resourceIndex = WorkshopRatingFood
	endif

	actorValue resourceValue = WorkshopRatings[resourceIndex].resourceValue
	actorToAssign.SetMultiResource (resourceValue)
	wsTrace(" TryToAutoAssignActor: trying to assign " + actorToAssign + " to resource type " + resourceValue)

	if((resourceIndex == WorkshopRatingSafety && bAutoAssignDefense) || (resourceIndex == WorkshopRatingFood && bAutoAssignFood))
		UFO4P_AddActorToWorkerArray (actorToAssign, resourceIndex)
		TryToAssignResourceType (workshopRef, resourceValue)
	endif

	if actorToAssign.multiResourceProduction == 0.0
		wsTrace(" TryToAutoAssignActor: no objects found to assign to " + actorToAssign)
		actorToAssign.SetMultiResource (none)
		UFO4P_RemoveActorFromWorkerArray (actorToAssign)
	endif

endFunction


; assign specified actor to specified workshop object - PUBLIC version (called by other scripts)
function AssignActorToObjectPUBLIC(WorkshopNPCScript assignedActor, WorkshopObjectScript assignedObject, bool bResetMode = false)
	; bResetMode: true means to ignore TryToAssignFarms call (ResetWorkshop calls it once at the end)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	AssignActorToObjectPUBLIC actor=" + assignedActor + ", object=" + assignedObject)
	; lock editing
	GetEditLock()

	AssignActorToObject(assignedActor, assignedObject, bResetMode = bResetMode)

	EditLock = false
endFunction


; private version - called only by this script
; bResetMode: TRUE means to skip trying to assign other resource objects of this type
; bAddActorCheck: TRUE is default; FALSE means to skip adding the actor - calling function guarantees that the actor is already assigned to this workshop (speed optimization)
function AssignActorToObject(WorkshopNPCScript assignedActor, WorkshopObjectScript assignedObject, bool bResetMode = false, bool bAddActorCheck = true)

	;/
	wsTrace("	AssignActorToObject actor=" + assignedActor + ", object=" + assignedObject + ", resetMode=" + bResetMode)

	WorkshopScript workshopRef
	if assignedObject.workshopID > -1
		workshopRef = GetWorkshop(assignedObject.workshopID)
	endif
	if workshopRef == NONE
		wsTrace(" 		AssignActorToObject: ERROR - " + assignedObject + " has invalid workshopID=" + assignedObject.workshopID + " - returning without assigning actor to object", 2)
		return
	endif

	; make sure I'm added to this workshop
	if bAddActorCheck
		AddActorToWorkshop(assignedActor, workshopRef, bResetMode)
	endif

	; get object's current owner
	WorkshopNPCScript previousOwner = assignedObject.GetAssignedActor()

	; is this a bed or work object?
	if assignedObject.IsBed()
		wsTrace("		Bed - clear ownership of any other bed, then assign")
		; bed
		; find bed that was assigned to this actor and clear ownership

		ObjectReference[] WorkshopBeds = GetBeds(workshopRef)
		int i = 0
		while i < WorkshopBeds.Length
			WorkshopObjectScript theBed = WorkshopBeds[i] as WorkshopObjectScript
			if theBed && theBed.GetActorRefOwner() == assignedActor
				theBed.AssignActor(NONE)
			endif
			i += 1
		endWhile

		; mark assigned object as assigned to this actor
		assignedObject.AssignActor(assignedActor)
		wsTrace("		Bed - assigned " + assignedObject + " to " + assignedActor +": owner=" + assignedObject.GetActorRefOwner())
		
		; WSWF - Add bed event
		if(previousOwner != assignedActor)
			Var[] kargs = new Var[0]
			kargs.Add(assignedObject)
			kargs.Add(workshopRef)
			kargs.Add(assignedActor)
			
			SendCustomEvent("WorkshopActorAssignedToBed", kargs)		
		endif
	elseif assignedObject.HasKeyword(WorkshopWorkObject)
		; work object
		; actor no longer counts as "new"
		assignedActor.bNewSettler = false

		; is object already assigned to this actor?
		bool bAlreadyAssigned = (previousOwner == assignedActor)
		wsTrace("		bAlreadyAssigned=" + bAlreadyAssigned)
		; unassign actor from whatever he was doing
		actorValue multiResourceValue = assignedActor.assignedMultiResource
		; if assigned actor is assigned to multi-resource, AND this has that resource, don't unassign him - can work on multiple resource objects
		wsTrace("		assignedMultiResource=" + multiResourceValue + ", assignedObject.HasResourceValue=" + assignedObject.HasResourceValue(multiResourceValue))
		bool bShouldUnassign = true
		if (multiResourceValue && assignedObject.HasResourceValue(multiResourceValue))
			; same multi resource - may not need to unassign if actor has enough unused resource points left
			float totalProduction = assignedActor.multiResourceProduction + assignedObject.GetResourceRating(multiResourceValue)
			int resourceIndex = GetResourceIndex(multiResourceValue)
			wsTrace("		totalProduction (with new object)=" + totalProduction + ", allowed max production=" + WorkshopRatings[resourceIndex].maxProductionPerNPC)
			if totalProduction <= WorkshopRatings[resourceIndex].maxProductionPerNPC
				bShouldUnassign = false
				; don't unassign - can work on multiple resource objects
				wsTrace("		actor already assigned to this resource type - don't unassign")
			else
				wsTrace("		actor will exceed max production for this resource type - DO unassign")
			endif
		elseif bAlreadyAssigned
			; already assigned
			wsTrace("		actor already assigned to this object - don't unassign")
			bShouldUnassign = false
		endif

		if bShouldUnassign
			wsTrace("		bShouldUnassign = true: unassigning " + assignedActor + " from previous work object")
			; unassign actor from previous work object
			;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes on that function for explanation)
			UnassignActor_Private(assignedActor, bSendUnassignEvent = !bAlreadyAssigned)
		endif

		; unassign current owner, if any (and different from new owner)
		if previousOwner && previousOwner != assignedActor
			wsTrace("		unassign previous owner " + previousOwner)
			UnassignActorFromObject(previousOwner, assignedObject)
		endif

		; mark assigned object as assigned to this actor
		assignedObject.AssignActor(assignedActor)

		; flag actor as a worker
		assignedActor.SetWorker(true)

		; 1.5 - new 24-hour work flag
		if assignedObject.bWork24Hours
			assignedActor.bWork24Hours = true 
		endif

		; if assigned object has scavenge rating, flag worker as scavenger (for packages)
		if assignedObject.HasResourceValue(WorkshopRatings[WorkshopRatingScavengeGeneral].resourceValue)
			assignedActor.SetScavenger(true)
		endif

		; add vendor faction if any
		if assignedObject.VendorType > -1
			SetVendorData(workshopRef, assignedActor, assignedObject)
		endif

		; update workshop ratings for new assignment
		UpdateWorkshopRatingsForResourceObject(assignedObject, workshopRef)

		; remove "unassigned" resource value
		assignedActor.SetValue(WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 0)

		; to save time, in reset mode we ignore this and do it at the end
		if !bResetMode
			; reset unassigned population count
			SetUnassignedPopulationRating(workshopRef)
		endif

		; special cases:
		; is this a multi-resource object?
		if assignedObject.HasMultiResource()
			multiResourceValue = assignedObject.GetMultiResourceValue()
			; flag actor with this keyword
			assignedActor.SetMultiResource(multiResourceValue)
			assignedActor.AddMultiResourceProduction(assignedObject.GetResourceRating(multiResourceValue))
			if !bResetMode
				TryToAssignResourceType(workshopRef, multiResourceValue)				
			endif
		endif

		; reset ai to get him to notice the new markers
		assignedActor.EvaluatePackage()

		wsTrace("	AssignActorToObject actor=" + assignedActor + ", object=" + assignedObject + ", resetMode=" + bResetMode + " DONE: bAlreadyAssigned=" + bAlreadyAssigned)

		; send custom event for this object
		; don't send event in reset mode, or if already assigned to this actor
		if bAlreadyAssigned == false
			; WSWF - Adding Actor Arg
			;Var[] kargs = new Var[2]
			;kargs[0] = assignedObject
			;kargs[1] = workshopRef
			
			Var[] kargs = new Var[0]
			kargs.Add(assignedObject)
			kargs.Add(workshopRef)
			kargs.Add(assignedActor)
			
			wsTrace(" 	sending WorkshopActorAssignedToWork event")
			SendCustomEvent("WorkshopActorAssignedToWork", kargs)		
		endif
	endif
	
	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;

	wsTrace("	AssignActorToObject: actor = " + assignedActor + ", object = " + assignedObject + ", resetMode = " + bResetMode)

	int workshopID = assignedObject.workshopID
	WorkshopScript workshopRef

	if workshopID >= 0
		workshopRef = GetWorkshop (workshopID)
	else
		wsTrace("	AssignActorToObject: ERROR - object " + assignedObject + " has no valid workshop ID. Returning ...", 2)
		return
	endif

	if bAddActorCheck
		AddActorToWorkshop (assignedActor, workshopRef, bResetMode)
	endif
	
	; WSWF - Adding option to avoid unassignment to other objects
	Bool bExcludedFromAssignmentRules = IsExcludedFromAssignmentRules(assignedObject)
	Var[] kExcludedArgs = new Var[0]
	kExcludedArgs.Add(assignedObject)
	kExcludedArgs.Add(workshopRef)
	kExcludedArgs.Add(assignedActor)
	
	WorkshopNPCScript previousOwner = assignedObject.GetAssignedActor()
	bool bAlreadyAssigned = (previousOwner == assignedActor)

	if assignedObject.IsBed()

		bool UFO4P_IsRobot = (assignedActor.GetBaseValue(WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue) > 0)
	
		if bAlreadyAssigned
			wsTrace("		Bed - Already assigned to this actor")
			if UFO4P_IsRobot 
				wsTrace("		  Actor is robot - clearing ownership")
				; WSWF Exclusion from assignment rules
				if(bExcludedFromAssignmentRules)
					SendCustomEvent("AssignmentRulesOverriden", kExcludedArgs)
				else
					assignedObject.AssignActor (none)
					UFO4P_AddUnassignedBedToArray (assignedObject)
				endif
			endif
		;UFo4P 2.0.4 Bug #24408: don't try to assign beds to robots:
		elseif UFO4P_IsRobot
			wsTrace("		Bed - Actor is robot. Ignoring ...")
		else
			wsTrace("		Bed - Clearing ownership of any other bed")
			
			;No need to run this if assignedActor is in the UFO4P_ActorsWithoutBeds array:
			;Note: after a workshop loads, this function will not run until ResetWorkshop starts looping through the resource object
			;arrays, and at this point, the UFO4P_ActorsWithoutBeds array is already up to date.
			if UFO4P_ActorsWithoutBeds && UFO4P_ActorsWithoutBeds.Find (assignedActor) < 0
				ObjectReference[] WorkshopBeds = GetBeds (workshopRef)
				int countBeds = WorkshopBeds.Length
				; WSWF - Removing loopshortcut since we've introduced a possibility where an NPC can have multiple beds
				; bool ExitLoop = false
				int i = 0
				while i < countBeds ; WSWF - Removing Loop Shortcut && ExitLoop == false
					WorkshopObjectScript theBed = WorkshopBeds[i] as WorkshopObjectScript
					if theBed && theBed.GetActorRefOwner() == assignedActor
						; WSWF - Exclusion from assignment rules
						if(IsExcludedFromAssignmentRules(theBed))
							Var[] kBedExcludedArgs = new Var[0]
							kBedExcludedArgs.Add(theBed)
							kBedExcludedArgs.Add(workshopRef)
							kBedExcludedArgs.Add(assignedActor)
							SendCustomEvent("AssignmentRulesOverriden", kBedExcludedArgs)
						else
							theBed.AssignActor (none)
							UFO4P_AddUnassignedBedToArray (theBed)
							 ; WSWF - Removing Loop Shortcut ExitLoop = true
						endif
					endif
					i += 1
				endWhile
			endif
			wsTrace("		Assigning bed " + assignedObject + " to " + assignedActor)
			assignedObject.AssignActor (assignedActor)
		endif

	elseif assignedObject.HasKeyword (WorkshopWorkObject)

		assignedActor.bNewSettler = false
	
		bool bShouldUnassignAllObjects = true
		bool bShouldUnassignSingleObject = false
		bool bShouldTryToAssignResources = false
		actorValue multiResourceValue = assignedActor.assignedMultiResource

		if bAlreadyAssigned
			wsTrace("		Actor already assigned to this object")
			bShouldUnassignAllObjects = false
		endif
	
		;UFO4P 2.0.4 Bug #24311: Multi-resource objects need to be handled separately, even if already assigned: this is to retro-
		;actively correct a bug in the vanilla code that could lead to more objects being assigned to an actor than allowed.
		if multiResourceValue
			if assignedObject.HasResourceValue (multiResourceValue)
				wsTrace("		Actor already assigned to this resource type")
				int resourceIndex = GetResourceIndex (multiResourceValue)
				float maxProduction = WorkshopRatings[resourceIndex].maxProductionPerNPC
				
				; WSWF - Introducing settings to control how much of each value a settler can work
				if(multiResourceValue == WorkshopRatings[WorkshopRatingSafety].resourceValue)
					maxProduction = MaxDefenseWorkPerSettler
				elseif(multiResourceValue == WorkshopRatings[WorkshopRatingFood].resourceValue)
					maxProduction = MaxFoodWorkPerSettler
				endif
				
				float currentProduction = assignedActor.multiResourceProduction
				if !bResetMode && bAlreadyAssigned && currentProduction <= maxProduction
					bShouldUnassignAllObjects = false
				else

					float totalProduction = currentProduction
					if !bResetMode && bAlreadyAssigned
						wsTrace("		 Current production = " + currentProduction + ", allowed max production = " + maxProduction)
					else
						;UFO4P 2.0.4 Bug #24311: adding the base value here instead of the current value (see comment below for further explanation)
						totalProduction = totalProduction + assignedObject.GetBaseValue (multiResourceValue)
						wsTrace("		 Total production (with new object) = " + totalProduction + ", allowed max production = " + maxProduction)
					endif

					if totalProduction <= maxProduction
						bShouldUnassignAllObjects = false
					elseif bAlreadyAssigned
						wsTrace("		 Actor exceeds max production - Unassign this object")
						bShouldUnassignSingleObject = true
					else
						wsTrace("		 Actor will exceed max production - Unassign all previous work objects")
					endif
				endif
			else
				wsTrace("		 Actor is currently assigned to a different resource type - Unassign all previous work objects")
			endif
		endif

		; WSWF - Adding option to have certain items bypass assignment rules
		; if bShouldUnassignSingleObject
		if(bShouldUnassignSingleObject)
			wsTrace("		Unassigning " + assignedActor + " from object " + assignedObject)
			; WSWF Exclusion from assignment rules
			if(bExcludedFromAssignmentRules)
				SendCustomEvent("AssignmentRulesOverriden", kExcludedArgs)
			else
				UnassignActorFromObject (assignedActor, assignedObject)
				bShouldTryToAssignResources = true
			endif
		;Skip this if the actor doesn't owns anything else than a bed. Now that we have all data we need in handy arrays,
		;the IsObjectOwner check is very fast as it won't have to loop through the actor's work objects.
		elseif bShouldUnassignAllObjects && IsObjectOwner (workshopRef, assignedActor)
			wsTrace("		Unassigning " + assignedActor + " from previous work object(s)")
			;/
			; WSWF - Calling our own version of this function. We don't want to change the original function 
			; because there are legitimate reasons to ignore our our exclusion list, for example if the object is
			; scrapped or the NPC is killed.
			/;
			; UnassignActor_Private (assignedActor, bRemoveFromWorkshop = false, bSendUnassignEvent = !bAlreadyAssigned, bResetMode = bResetMode)
			UnassignActor_Private_SkipExclusions(assignedActor, workshopRef)
		endif

		; unassign current owner, if any (and different from new owner)
		if previousOwner && previousOwner != assignedActor
			wsTrace("		Unassigning previous owner " + previousOwner + " from object " + assignedObject)
			; WSWF - This we have to allow because the game engine doesn't support multiple ref owners 
			UnassignActorFromObject (previousOwner, assignedObject)
		endif

		assignedObject.AssignActor (assignedActor)
		assignedActor.SetWorker (true)

		; 1.5 - new 24-hour work flag
		if assignedObject.bWork24Hours
			assignedActor.bWork24Hours = true 
		endif

		; if assigned object has scavenge rating, flag worker as scavenger (for packages)
		if assignedObject.HasResourceValue (WorkshopRatings[WorkshopRatingScavengeGeneral].resourceValue)
			assignedActor.SetScavenger (true)
		endif

		; add vendor faction if any
		if assignedObject.VendorType >= 0
			SetVendorData (workshopRef, assignedActor, assignedObject)
		endif

		UpdateWorkshopRatingsForResourceObject (assignedObject, workshopRef)
		assignedActor.SetValue (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 0)

		if !bResetMode
			SetUnassignedPopulationRating (workshopRef)
		endif

		assignedActor.EvaluatePackage()

		;Update multi resource production values:
		;if in reset mode, this code must always run irrespective of whether bAlreadyAssigned is true or false. This is because Reset
		;Workshop sets the multi-resource production of all actors back to 0.0, so even the production from already assigned objects
		;has to be added back in.
		if assignedObject.HasMultiResource() && (bResetMode || !bAlreadyAssigned)
			multiResourceValue = assignedObject.GetMultiResourceValue()
			assignedActor.SetMultiResource (multiResourceValue)
			;UFO4P 2.0.4 Bug #24311: Using the base values here (i.e. the resource ratings of the undamaged objects):
			;This is because objects that are already assigned to an actor will not get unassigned if they are damaged. Thus, if
			;we would use the actual rating, actors might end up below their allowed maximum production and the scripts would try
			;to assign more work objects to them even though they actually are at the limit already with all objects repaired.
			;Though, if more objects are assigned and the damaged ones subsequently repaired, the actor will inevitably exceed the
			;limit. Also note that objects assigned by this function are usually undamaged. Only the workshop reset may assign
			;damaged objects to an actor, and only if these objects were previously assigned to that actor already.
			assignedActor.AddMultiResourceProduction (assignedObject.GetBaseValue (multiResourceValue))
			;if this is the current workshop, add actor to/remove actor from worker arrays (whatever applies):
			if workshopID == currentWorkshopID
				float currentProduction = assignedActor.multiResourceProduction
				int resourceIndex = GetResourceIndex (multiResourceValue)
				if currentProduction == WorkshopRatings[resourceIndex].maxProductionPerNPC
					UFO4P_RemoveActorFromWorkerArray (assignedActor)
				else
					UFO4P_AddActorToWorkerArray (assignedActor, resourceIndex)
					bShouldTryToAssignResources = true
				endif
			endif
		endif

		if bAlreadyAssigned == false
			; WSWF - Adding actor arg
			;Var[] kargs = new Var[2]
			;kargs[0] = assignedObject
			;kargs[1] = workshopRef
			
			Var[] kargs = new Var[0]
			kargs.Add(assignedObject)
			kargs.Add(workshopRef)
			kargs.Add(assignedActor)
			
			wsTrace(" 	sending WorkshopActorAssignedToWork event")
			SendCustomEvent ("WorkshopActorAssignedToWork", kargs)		
		endif

		;If we're not in reset mode and objects have been unassigned in this process that have not already been taken care of, (e.g. if UnassignActor_Private
		;was called above, those objects will have been re-assigned already), try to find a new owner. Likewise, try to find more work objects for assigned
		;actor if he is below his limit (in all those cases, bShouldTryToAssignResources will be 'true').
		if !bResetMode && bShouldTryToAssignResources && workshopID == currentWorkshopID
			TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
			TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
		endif
		
	endif

	wsTrace("	AssignActorToObject: DONE")

endFunction


;-----------------------------------------------------------------------------------------------------------------------------------
;	UFO4P 2.0.4 Bug #24274:
;	Further modifications to this function would have made the code almost illegible, so the function has been rewritten.
;-----------------------------------------------------------------------------------------------------------------------------------

;UFO4P 2.0.4 Bug #24274: added WorkshopActors as a new argument:
;ResetWorkshop will now pass its own actor array in when it calls this function at the end, enabling it to complete this task even if the
;workshop has unloaded in the meantime. It also saves some time since the array doesn't need to be recreated.
function SetUnassignedPopulationRating (WorkshopScript workshopRef, ObjectReference[] WorkshopActors = none)

	if WorkshopActors == none
		;UFO4P 2.0.4 Bug #24274: Checking this only if no actor array has been passed in:
		if UFO4P_IsWorkshopLoaded (workshopRef) == false
			wsTrace(" SetUnassignedPopulationRating for workshop " + workshopRef + "; workshop is not loaded. Returning ...")
			return
		endif
		WorkshopActors = GetWorkshopActors (workshopRef)
	endif

	;UFO4P 2.0.4; storing the array length in a variable, so we don't have to recalculate it in every loop cycle:
	int countActors = WorkshopActors.Length
	int unassignedPopulation = 0
	int i = 0
	while i < countActors
		WorkshopNPCScript theActor = WorkshopActors[i] as WorkShopNPCScript
		;UFO4P 2.0.4 Bug #24261: Also disregard caravan actors: provisioners should count as jobs
		if theActor && theActor.bIsWorker == false && CaravanActorAliases.Find (theActor) < 0
			unassignedPopulation += 1
		endif
		i += 1
	endWhile

	wsTrace(" SetUnassignedPopulationRating for workshop " + workshopRef + "; unassigned population count = " + unassignedPopulation)
	SetResourceData_Private (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, workshopRef, unassignedPopulation)

endFunction

; utility function for setting/clearing vendor data on an actor
function SetVendorData(WorkshopScript workshopRef, WorkshopNPCScript assignedActor, WorkshopObjectScript assignedObject, bool bSetData = true)
	wsTrace("	SetVendorData actor=" + assignedActor + ", object=" + assignedObject + ", bSetData=" + bSetData)

	if assignedObject.VendorType > -1
		wsTrace("		vendor type " + assignedObject.VendorType)
		WorkshopVendorType vendorData = WorkshopVendorTypes[assignedObject.VendorType]
		if vendorData
			; -- vendor faction
			wsTrace("		vendor faction " + vendorData.VendorFaction)
			if bSetData
				assignedActor.AddToFaction(vendorData.VendorFaction)
				if vendorData.keywordToAdd01
					assignedActor.AddKeyword(vendorData.keywordToAdd01)
				endif
			else
				assignedActor.RemoveFromFaction(vendorData.VendorFaction)
				if vendorData.keywordToAdd01
					assignedActor.RemoveKeyword(vendorData.keywordToAdd01)
				endif
			endif

			; -- assign vendor chests
			ObjectReference[] vendorContainers = workshopRef.GetVendorContainersByType(assignedObject.VendorType)
			int i = 0
			while i <= assignedObject.vendorLevel
				if bSetData
					wsTrace("		linking to " + vendorContainers[i] + " with keyword " + VendorContainerKeywords.GetAt(i) as Keyword)
					assignedActor.SetLinkedRef(vendorContainers[i], VendorContainerKeywords.GetAt(i) as Keyword)
				else
					assignedActor.SetLinkedRef(NONE, VendorContainerKeywords.GetAt(i) as Keyword)
				endif
				i += 1
			endWhile

			; special vendor data
			if bSetData
				if assignedActor.specialVendorType > -1 && assignedActor.specialVendorType == assignedObject.VendorType
					; link to special vendor containers
					if assignedActor.specialVendorContainerBase
						; create the container ref if it doesn't exist yet
						if assignedActor.specialVendorContainerRef == NONE
							assignedActor.specialVendorContainerRef = WorkshopHoldingCellMarker.PlaceAtMe(assignedActor.specialVendorContainerBase)
						endif
						wsTrace("		special vendor matching this type: linking to " + assignedActor.specialVendorContainerRef + " with keyword " + VendorContainerKeywords.GetAt(VendorTopLevel+1) as Keyword)
						; link using 4th keyword
						assignedActor.SetLinkedRef(assignedActor.specialVendorContainerRef, VendorContainerKeywords.GetAt(VendorTopLevel+1) as Keyword)
					endif
					if assignedActor.specialVendorContainerRefUnique
						wsTrace("		special vendor matching this type: linking to " + assignedActor.specialVendorContainerRefUnique + " with keyword " + VendorContainerKeywords.GetAt(VendorTopLevel+2) as Keyword)
						; link using 4th keyword
						assignedActor.SetLinkedRef(assignedActor.specialVendorContainerRefUnique, VendorContainerKeywords.GetAt(VendorTopLevel+2) as Keyword)
					endif
				endif
			else
				; always clear for safety
				if assignedActor.specialVendorContainerRef
					assignedActor.specialVendorContainerRef.Delete()
					assignedActor.specialVendorContainerRef = NONE
					; clear link
					assignedActor.SetLinkedRef(NONE, VendorContainerKeywords.GetAt(VendorTopLevel+1) as Keyword)
				endif
				if assignedActor.specialVendorContainerRefUnique
					; clear link
					assignedActor.SetLinkedRef(NONE, VendorContainerKeywords.GetAt(VendorTopLevel+2) as Keyword)
				endif

			endif

		else
			; ERROR
		endif
	endif

endFunction


function AssignCaravanActorPUBLIC(WorkshopNPCScript assignedActor, Location destinationLocation)
	; NOTE: package on alias uses two actor values to condition travel between the two workshops
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	AssignCaravanActorPUBLIC actor=" + assignedActor + ", destination=" + destinationLocation)
	; lock editing
	GetEditLock()

	; get destination workshop
	WorkshopScript workshopDestination = GetWorkshopFromLocation(destinationLocation)

	; current workshop
	WorkshopScript workshopStart = GetWorkshop(assignedActor.GetWorkshopID())
	; unassign this actor from any current job
	;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes on that function for explanation)
	; WSWF - Using Our Exclusion Check  UnassignActor_Private(assignedActor)
	UnassignActor_Private_SkipExclusions(assignedActor, workshopStart)

	; is this actor already assigned to a caravan?
	int caravanIndex = CaravanActorAliases.Find(assignedActor)
	if caravanIndex < 0
		; add to caravan actor alias collection
		wsTrace("		AssignCaravanActorPUBLIC actor=" + assignedActor + " IsUnique()=" + assignedActor.GetActorBase().IsUnique())
		CaravanActorAliases.AddRef(assignedActor)
		if assignedActor.GetActorBase().IsUnique() == false && assignedActor.GetValue(WorkshopProhibitRename) == 0
			wsTrace("		AssignCaravanActorPUBLIC actor=" + assignedActor + " not unique, putting in rename alias")
			; put in "rename" alias
			CaravanActorRenameAliases.AddRef(assignedActor)
		endif
	else
		; clear current location link
		Location oldDestination = GetWorkshop(assignedActor.GetCaravanDestinationID()).myLocation
		workshopStart.myLocation.RemoveLinkedLocation(oldDestination, WorkshopCaravanKeyword)
	endif
	
	int destinationID = workshopDestination.GetWorkshopID()

	; set destination actor value (used to find destination workshop from actor)
	assignedActor.SetValue(WorkshopCaravanDestination, destinationID)
	wsTrace("		AssignCaravanActorPUBLIC: destination=" + assignedActor.GetValue(WorkshopCaravanDestination) + " start=" + assignedActor.GetWorkshopID())

	; make caravan ref type
	if assignedActor.IsCreated()
		assignedActor.SetLocRefType(workshopStart.myLocation, WorkshopCaravanRefType)
	endif

	; add linked refs to actor (for caravan package)
	assignedActor.SetLinkedRef(workshopStart.GetLinkedRef(WorkshopLinkCenter), WorkshopLinkCaravanStart)
	assignedActor.SetLinkedRef(workshopDestination.GetLinkedRef(WorkshopLinkCenter), WorkshopLinkCaravanEnd)

	; add link between locations
	;debug.trace(self + " AssignCaravanActorPUBLIC: linking " + workshopStart.myLocation + "(" + workshopStart + ") to " + workshopDestination.myLocation + "(" + workshopDestination + ")")
	workshopStart.myLocation.AddLinkedLocation(workshopDestination.myLocation, WorkshopCaravanKeyword)

	;UFO4P 2.0.4 Bug #24261: update workshop rating - provisioners should count as jobs:
	assignedActor.SetValue (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 0)

	; 1.6: send custom event for this actor
	Var[] kargs = new Var[2]
	kargs[0] = assignedActor
	kargs[1] = workshopStart
	wsTrace(" 	sending WorkshopActorCaravanAssign event")
	SendCustomEvent("WorkshopActorCaravanAssign", kargs)

	; stat update
	Game.IncrementStat("Supply Lines Created")

	; unlock editing
	EditLock = false
endFunction

; call this to temporarily turn on/off a caravan actor - remove brahmin and unlink
function TurnOnCaravanActor(WorkshopNPCScript caravanActor, bool bTurnOn, bool bBrahminCheck = true)
	; find linked locations
	WorkshopScript workshopStart = GetWorkshop(caravanActor.GetWorkshopID())

	Location startLocation = workshopStart.myLocation
	Location endLocation = GetWorkshop(caravanActor.GetCaravanDestinationID()).myLocation

	if bTurnOn
		; add link between locations
		startLocation.AddLinkedLocation(endLocation, WorkshopCaravanKeyword)
	else
		; unlink locations
		startLocation.RemoveLinkedLocation(endLocation, WorkshopCaravanKeyword)
	endif

	if bBrahminCheck
		CaravanActorBrahminCheck(caravanActor, bTurnOn)
	endif
endFunction

; check to see if this actor needs a new brahmin, or if current brahmin should be flagged for delete
function CaravanActorBrahminCheck(WorkshopNPCScript actorToCheck, bool bShouldHaveBrahmin = true)
	;wsTrace(" CaravanActorBrahminCheck: caravan actor " + actorToCheck + ", bShouldHaveBrahmin=" + bShouldHaveBrahmin)

	; is my brahmin dead?
	if actorToCheck.myBrahmin && actorToCheck.myBrahmin.IsDead()
		; clear
		CaravanBrahminAliases.RemoveRef(actorToCheck.myBrahmin)
		actorToCheck.myBrahmin = NONE
	endif

	; should I have a brahmin?
	if CaravanActorAliases.Find(actorToCheck) > -1 && bShouldHaveBrahmin && actorToCheck.IsWounded() == false
		; if I don't have a brahmin, make me a new one
		if actorToCheck.myBrahmin == NONE && actorToCheck.IsWounded() == false
			;UFO4P: Added trace
			wsTrace(" CaravanActorBrahminCheck: actor " + actorToCheck + " has no brahmin, creating")
			actorToCheck.myBrahmin = actorToCheck.placeAtMe(CaravanBrahmin) as Actor
			actorToCheck.myBrahmin.SetActorRefOwner(actorToCheck)
			CaravanBrahminAliases.AddRef(actorToCheck.myBrahmin)
			actorToCheck.myBrahmin.SetLinkedRef(actorToCheck, WorkshopLinkFollow)
		endif
	else
		; clear and delete brahmin
		if actorToCheck.myBrahmin
			wsTrace(" CaravanActorBrahminCheck: actor " + actorToCheck + " has brahmin, removing")
			; clear this and mark brahmin for deletion
			Actor deleteBrahmin = actorToCheck.myBrahmin
			CaravanBrahminAliases.RemoveRef(deleteBrahmin)
			actorToCheck.myBrahmin = NONE
			deleteBrahmin.Delete()
			deleteBrahmin.SetLinkedRef(NONE, WorkshopLinkFollow)
		endif
	endif
endFunction

; called when player loses control of a workshop - clears all caravans to/from this workshop
function ClearCaravansFromWorkshopPUBLIC(WorkshopScript workshopRef)
	; NOTE: package on alias uses two actor values to condition travel between the two workshops
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ClearCaravansFromWorkshopPUBLIC workshop=" + workshopRef)
	; lock editing
	GetEditLock()

	; check all caravan actors for either belonging to this workshop, or targeting it - unassign them
	int i = CaravanActorAliases.GetCount() - 1 ; start at top of list since we may be removing things from it

	while i	> -1
		WorkshopNPCScript theActor = CaravanActorAliases.GetAt(i) as WorkShopNPCScript
		if theActor
			; check start and end locations
			int destinationWorkshopID = theActor.GetCaravanDestinationID()
			wstrace("		destinationID=" + destinationWorkshopID)
			wstrace("		destinationworkshop=" + GetWorkshop(destinationWorkshopID))
			WorkshopScript endWorkshop = GetWorkshop(destinationWorkshopID)
			WorkshopScript startWorkshop = GetWorkshop(theActor.GetWorkshopID())
			wsTrace("		" + i + ": " + theActor + ": supply line between " + startWorkshop + " and " + endWorkshop)
			if endWorkshop == workshopRef || startWorkshop == workshopRef
				; unassign this actor
				;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes on that function for explanation)
				; WSWF - Just unassign from Caravan since they might have other assignments
				; UnassignActor_Private(theActor)
				UnassignActorFromCaravan(theActor, workshopRef, false)
			endif
		endif
		i += -1 ; decrement
	endWhile

	; unlock editing
	EditLock = false

endFunction


function AddToWorkshopRecruitAlias(Actor assignableActor)
	wsTrace(" AddToWorkshopRecruitAlias " + assignableActor)
	if assignableActor
		WorkshopRecruit.ForceRefTo(assignableActor)
	else
		WorkshopRecruit.Clear()
	endif
endFunction

; called by dialogue/quests to add non-persistent actor (not already in a dialogue quest alias) to workshop system using workshop settlement menu
; actorToAssign: if NONE, use the actor in WorkshopRecruit alias
location function AddActorToWorkshopPlayerChoice(Actor actorToAssign = NONE, bool bWaitForActorToBeAdded = true, bool bPermanentActor = false)
	if actorToAssign == NONE
		actorToAssign = WorkshopRecruit.GetActorRef()
	endif

	wsTrace(" AddActorToWorkshopPlayerChoice " + actorToAssign, bNormalTraceAlso = true)
	; this only works on actors with the workshop script
	WorkShopNPCScript workshopActorToAssign = actorToAssign as WorkShopNPCScript
	if !workshopActorToAssign
		wsTrace(" WARNING: AddActorToWorkshopPlayerChoice: invalid actor " + actorToAssign + " - NOT assigned", 2)
		return None
	endif

	keyword keywordToUse = WorkshopAssignHome
	if bPermanentActor
		keywordToUse = WorkshopAssignHomePermanentActor
	endif

	;UFO4P 1.0.5 Bug #20810: Added the following four lines to replace the commented out vanilla line below
	int previousWorkshopID = workshopActorToAssign.GetWorkshopID()
	WorkshopScript previousWorkshop = NONE
	if previousWorkshopID >= 0
		previousWorkshop = GetWorkshop(previousWorkshopID)
	endIf

	;WorkshopScript previousWorkshop = GetWorkshop(workshopActorToAssign.GetWorkshopID())

	Location previousLocation = NONE
	if previousWorkshop
		previousLocation = previousWorkshop.myLocation
	endif

	; 102314: allow non-population actors to be assigned to any workshop
	FormList excludeKeywordList
	if workshopActorToAssign.bCountsForPopulation
		excludeKeywordList = WorkshopSettlementMenuExcludeList
	endif 
	Location newLocation = workshopActorToAssign.OpenWorkshopSettlementMenuEx(akActionKW=keywordToUse, aLocToHighlight=previousLocation, akExcludeKeywordList=excludeKeywordList)

	if bWaitForActorToBeAdded && newLocation
		; wait for menu to resolve (when called in scenes)
		int failsafeCount = 0
		while failsafeCount < 5 && workshopActorToAssign.GetWorkshopID() == -1
			wsTrace("...waiting...")
			failsafeCount += 1
			utility.wait(0.5)
		endWhile
	endif
	wsTrace("AddActorToWorkshopPlayerChoice DONE")

	return newLocation	
endFunction

; called by dialogue/quests to add an existing actor to a workshop by bringing up workshop settlement menu
; actorToAssign: if NONE, use the actor in WorkshopRecruit alias
location function AddPermanentActorToWorkshopPlayerChoice(Actor actorToAssign = NONE, bool bWaitForActorToBeAdded = true)
	return AddActorToWorkshopPlayerChoice(actorToAssign, bWaitForActorToBeAdded, true)
endFunction

; called by dialogue/quests to add an existing actor to a workshop
; actorToAssign: if NONE, use the actor in WorkshopRecruit alias
; newWorkshopID: if -1, bring up message box to pick the workshop (TEMP)
function AddPermanentActorToWorkshopPUBLIC(Actor actorToAssign = NONE, int newWorkshopID = -1, bool bAutoAssign = true)
	if actorToAssign == NONE
		actorToAssign = WorkshopRecruit.GetActorRef()
	;UFO4P 2.0.1 Bug #22246: added check for dead actors:
	elseif actorToAssign.IsDead()
		return
	endif
	
	wsTrace(" AddPermanentActorToWorkshopPUBLIC " + actorToAssign, bNormalTraceAlso = true)
	; this only works on actors with the workshop script
	WorkShopNPCScript workshopActorToAssign = actorToAssign as WorkShopNPCScript
	if !workshopActorToAssign
		wsTrace(" WARNING: AddPermanentActorToWorkshopPUBLIC: invalid actor " + actorToAssign + " - NOT assigned", 2)
		return
	endif


	if newWorkshopID < 0
		actorToAssign.OpenWorkshopSettlementMenu(WorkshopAssignHomePermanentActor)
		; NOTE: event from menu is handled by WorkshopNPCScript
	else
		GetEditLock()

		WorkshopScript newWorkshop = GetWorkshop(newWorkshopID)
		wstrace("	assigning " + actorToAssign+ " to " + newWorkshop)
		; put in "ignore for cleanup" faction so that RE quests can shut down
		actorToAssign.AddToFaction(REIgnoreForCleanup)
		; remove from rescued faction to stop those hellos
		actorToAssign.RemoveFromFaction(REDialogueRescued)

		; make Boss loc ref type for this location
		if workshopActorToAssign.IsCreated()
			workshopActorToAssign.SetAsBoss(newWorkshop.myLocation)
		endif
		; add to alias collection for existing actors - gives them packages to stay at new "home"
		PermanentActorAliases.AddRef(workshopActorToAssign)
		; add to the workshop
		AddActorToWorkshop(workshopActorToAssign, newWorkshop)

		; try to automatically assign to do something:
		;UFO4P 2.0.5 Bug #yyyyy: added check: don't run this on Dogmeat:
		if bAutoAssign && actorToAssign != DogmeatAlias.GetActorReference()
			TryToAutoAssignActor(newWorkshop, workshopActorToAssign)
		endif

		; send custom event for this actor
		Var[] kargs = new Var[2]
		kargs[0] = actorToAssign
		kargs[1] = newWorkshopID
		SendCustomEvent("WorkshopAddActor", kargs)		

		; unlock editing
		EditLock = false
	endif

endFunction

; utility function used to assign home marker to workshop actor
function AssignHomeMarkerToActor(Actor actorToAssign, WorkshopScript workshopRef)
	; if sandbox link exists, use that - otherwise use center marker
	ObjectReference homeMarker = workshopRef.GetLinkedRef(WorkshopLinkSandbox)
	if homeMarker == NONE
		homeMarker = workshopRef.GetLinkedRef(WorkshopLinkCenter)
	endif
	actorToAssign.SetLinkedRef(homeMarker, WorkshopLinkHome)
endFunction


function AddCollectionToWorkshopPUBLIC(RefCollectionAlias thecollection, WorkshopScript workshopRef, bool bResetMode = false)
	GetEditLock()
	int i = 0
	while i < theCollection.GetCount()
		WorkshopNPCScript theActor = theCollection.GetAt(i) as WorkshopNPCScript
		if theActor
			AddActorToWorkshop(theActor, workshopRef, bResetMode)
		endif
		i += 1
	endWhile

	; unlock editing
	EditLock = false
endFunction

; called by external scripts to assign or reassign a workshop actor to a new workshop location
function AddActorToWorkshopPUBLIC(WorkshopNPCScript assignedActor, WorkshopScript workshopRef, bool bResetMode = false)
	GetEditLock()

	AddActorToWorkshop(assignedActor, workshopRef, bResetMode)

	; unlock editing
	EditLock = false
endFunction


function AddActorToWorkshop(WorkshopNPCScript assignedActor, WorkshopScript workshopRef, bool bResetMode = false, ObjectReference[] WorkshopActors = NONE)
	;/
	; bResetMode: true means to ignore TryToAssignFarms/Beds calls (ResetWorkshop calls it once at the end)
	; WorkshopActors: if NONE, get new list, otherwise use passed in list (to save time)

	; As called from ResetWorkshop:
	; AddActorToWorkshop(actorRef, workshopRef, true, WorkshopActors)
	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. 
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;
	
	wsTrace("	AddActorToWorkshop: actor = " + assignedActor + ", workshop = " + workshopRef + ", resetMode = " + bResetMode)

	bool bResetHappiness = false

	if WorkshopActors == NONE
		WorkshopActors = GetWorkshopActors(workshopRef)
	endif

	bool bAlreadyAssigned = false
	bool UFO4P_RecalcResourcesForOldWorkshop = false
	int oldWorkshopID = assignedActor.GetWorkshopID()
	int newWorkshopID = workshopRef.GetWorkshopID()

	wsTrace("	AddActorToWorkshop: step 1")
	if WorkshopActors.Find (assignedActor) > -1 && oldWorkshopID == newWorkshopID
		wsTrace("	AddActorToWorkshop: actor " + assignedActor + " already assigned to this workshop")
		; if already in the list and not in reset mode, return
		if !bResetMode
			return
		endif
		bAlreadyAssigned = true
	else
		if oldWorkshopID > -1 && oldWorkshopID != newWorkshopID
			wsTrace("	AddActorToWorkshop: oldWorkshopID = " + oldWorkshopID)
			; 89671: no need to remove actor from workshop completely when assigning to different workshop
			UnassignActor_Private (assignedActor, false, bResetMode = bResetMode)
			assignedActor.bNewSettler = false
			; remember this, so we don't have to check the workshopIDs again
			UFO4P_RecalcResourcesForOldWorkshop = true
		endif
	endif

	if bAlreadyAssigned == false

		wsTrace("	AddActorToWorkshop: step 2")
		assignedActor.SetWorkshopID (newWorkshopID)

		if workshopRef.SettlementOwnershipFaction && workshopRef.UseOwnershipFaction && assignedActor.bApplyWorkshopOwnerFaction
			if assignedActor.bCountsForPopulation
				assignedActor.SetCrimeFaction(workshopRef.SettlementOwnershipFaction)
			else
				assignedActor.SetFactionOwner(workshopRef.SettlementOwnershipFaction)
			endif
		endif

		assignedActor.SetLinkedRef( workshopRef, WorkshopItemKeyword)
		AssignHomeMarkerToActor (assignedActor, workshopRef)
		ApplyWorkshopAliasData (assignedActor)

		wsTrace("	AddActorToWorkshop: step 3")
		assignedActor.UpdatePlayerOwnership (workshopRef)

		; 98730: Recalc workshop ratings on old workshop (if there is one) now that actor is linked to new workshop
		if UFO4P_RecalcResourcesForOldWorkshop
			WorkshopScript oldWorkshopRef = GetWorkshop (oldWorkshopID)		
			if oldWorkshopRef
				oldWorkshopRef.RecalculateWorkshopResources()
			endif
		endif

		if assignedActor.bCountsForPopulation
			int totalPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
			float currentHappiness = workshopRef.GetValue(WorkshopRatings[WorkshopRatingHappiness].resourceValue)
			wsTrace("	AddActorToWorkshop: step 4: current population (without new actor) = " + totalPopulation)
			if totalPopulation == 0
				wsTrace("	AddActorToWorkshop: current population was ZERO, resetting happiness")
				SetResourceData_Private (WorkshopRatings[WorkshopRatingHappinessModifier].resourceValue, workshopRef, 0)
				if bResetMode
					SetResourceData_Private (WorkshopRatings[WorkshopRatingHappiness].resourceValue, workshopRef, startingHappiness)
					SetResourceData_Private (WorkshopRatings[WorkshopRatingHappinessTarget].resourceValue, workshopRef, startingHappiness)
				else
					bResetHappiness = true
				endif
				SetResourceData_Private (WorkshopRatings[WorkshopRatingLastAttackDaysSince].resourceValue, workshopRef, 99)
			endif
			assignedActor.SetValue (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 1)
			UpdateVendorFlagsAll (workshopRef)
		endif

		if assignedActor.IsCreated()
			assignedActor.SetPersistLoc (workshopRef.myLocation)
			if assignedActor.bIsSynth
				wstrace(" 	" + assignedActor + " is a SYNTH - adding synth ref type")
				assignedActor.SetLocRefType (workshopRef.myLocation, WorkshopSynthRefType)
				;wstrace(" 	" + assignedActor + " GetLocRefType = " + assignedActor.GetLocRefTypes())
				;assignedActor.ClearFromOldLocations() ; 101931: make sure location data is correct
			elseif assignedActor.bCountsForPopulation
				assignedActor.SetAsBoss (workshopRef.myLocation)
			endif
			;UFO4P 2.0.4 Bug #24262: moved these lines down here from above:
			;ClearFromOldLocations() should run on all in-game created actors, not only on those tagged as synths.
			wstrace(" 	" + assignedActor + " GetLocRefType = " + assignedActor.GetLocRefTypes())
			assignedActor.ClearFromOldLocations() ; 101931: make sure location data is correct
		endif

		if workshopRef.PlayerHasVisited
			wsTrace("	AddActorToWorkshop: clearing worker flag")
			assignedActor.SetWorker(false)
		endif

		;If workshop is currently loaded, also save all new actors that are not robots in the UFO4P_ActorsWithoutBeds array.
		;Otherwise, the new version of the TryToAssignBeds function won't find them.
		if assignedActor.GetBaseValue (WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue) == 0 && newWorkshopID == currentWorkshopID
			UFO4P_ActorsWithoutBeds.Add (assignedActor)
		endif
		
	endif

	if bResetMode
		wsTrace("	AddActorToWorkshop: clearing multiResourceProduction")
		assignedActor.multiResourceProduction = 0.0
		;In reset mode, fill workers assigned to food or safety in worker arrays, so we won't have to loop through the actors array again kater on:
		ActorValue multiResourceValue = assignedActor.assignedMultiResource
		if multiResourceValue
			UFO4P_AddActorToWorkerArray (assignedActor, GetResourceIndex (multiResourceValue))
		endif
	endif

	;Eveb if not in reset mode, this should not run if the workshop is not loaded:
	if !bResetMode && newWorkshopID == currentWorkshopID 
		wsTrace("	AddActorToWorkshop: step 5 - try to assign a bed, maybe")
		TryToAssignBeds (workshopRef)
	endif

	assignedActor.EvaluatePackage()

	if !workshopRef.RecalculateWorkshopResources()
		wsTrace(" 	RecalculateWorkshopResources returned false - add population manually")
		ModifyResourceData_Private (WorkshopRatings[WorkshopRatingPopulation].resourceValue, workshopRef, 1)
	endif

	if !bResetMode && bResetHappiness
		ResetHappiness (workshopRef)
	endif

	wsTrace("	AddActorToWorkshop: DONE")

endFunction


;UFO4P 1.0.3 Bug #20775: The ResetHappiness function had to be split in two parts (the vanilla code is preserved below):

;(1) The first part starts a timer on WorkshopScript to call the DailyUpdate function. The function cannot be called directly (as in the vanilla version),
;because this thread is locked and the DailyUpdate function may call other functions on this script that are locked as well. This would result in a dead
;lock (as a result of previous edits in order to minimize threading issues - thanks to MageKing17 for spotting this). When started from a timer event on
;WorkshopScript though, the DailyUpdate function runs from a new thread, preventing a dead lock situation from occurring. Note that this part of the func-
;tion could not be included in the AddActorToWorkshop function (this is the only function on this script that calls the ResetHappiness function), because
;there is a quest script calling this function too [NB: since the vanilla ResetHappiness function was a non-public function (i.e. it allowed for modifica-
;tion of resource data values without passing a lock), this call from QF_MM01Misc was a potential issue itself. With the new ResetHappiness function, this
;risk is now eliminated as well.]
;
;The calculations carried out by the ResetHappiness function suggest that the DailyUpdate function must be run before continuing with the actual happiness
;reset. This means however that this function call has to be handled in a specific manner (unlike all other calls of DailyUpdate with bRealUpdate = false:
;they will be skipped by WorkshopScript entirely at times of high script activity). To realize this, a new bool argument was added to the DailyUpdate func-
;tion (default value is false; see WorkshopScript for further details). The timerID allows the timer event to discern calls from this script, and it will
;call the DailyUpdate function with the new bool set to true. This will have two effects: (a) the call will not be skipped, and (b) when the function fini-
;shes running, it will call the second part of the ResetHappiness function (see below) to continue with the actual reset.

function ResetHappiness(WorkshopScript workshopRef)
	wsTrace(" ResetHappiness for " + workshopRef)
	workshopRef.StartTimer(3.0, UFO4P_DailyUpdateResetHappinessTimerID)	
endFunction

;UFO4P 1.0.3 Bug #20775 (continued from above)::
;(2) The second part contains the actual code of the vanilla ResetHappiness function. This must not be carried out until the DailyUpdate has run, so this
;function will now be called from WorkshopScript when the DailyUpdate function has finished running. Since it is the only user (i.e. the call always comes
;from an external script), this new function has been made public (i.e. an edit lock was added).

function ResetHappinessPUBLIC(WorkshopScript workshopRef)
	;UFO4P 1.0.3 Bug #20775: added lock
	GetEditLock()

	;UFO4P 1.0.3 Bug #20775: Added trace:
	wsTrace(" ResetHappinessPUBLIC for " + workshopRef)
	
	float happinessTarget = workshopRef.GetValue(WorkshopRatings[WorkshopRatingHappinessTarget].resourceValue)
	; if current target below min, set target to min
	if happinessTarget < startingHappinessMin
		happinessTarget = startingHappinessMin
		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingHappinessTarget].resourceValue, workshopRef, happinessTarget)
	endif
	; set happiness to target
	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
	SetResourceData_Private(WorkshopRatings[WorkshopRatingHappiness].resourceValue, workshopRef, happinessTarget)
	
	;UFO4P 1.0.3 Bug #20775: unlock editing
	EditLock = false

	;UFO4P 1.0.3 Bug #20775: Added trace:
	wsTrace(" ResetHappinessPUBLIC - DONE")
endFunction;

;--------------------------------------------------------------------------------------------------------------------
;	Replaced vanilla code
;--------------------------------------------------------------------------------------------------------------------

; reset happiness to happiness target - used when first adding population to a workshop location
;function ResetHappiness(WorkshopScript workshopRef)
	;wsTrace(" ResetHappiness for " + workshopRef)
; 	 recalc happiness, then set happiness to current happiness target
	;workshopRef.DailyUpdate(bRealUpdate = false)
	;float happinessTarget = workshopRef.GetValue(WorkshopRatings[WorkshopRatingHappinessTarget].resourceValue)
; 	 if current target below min, set target to min
	;if happinessTarget < startingHappinessMin
		;happinessTarget = startingHappinessMin
		;SetResourceData(WorkshopRatings[WorkshopRatingHappinessTarget].resourceValue, workshopRef, happinessTarget)
	;endif
;	  set happiness to target
	;SetResourceData(WorkshopRatings[WorkshopRatingHappiness].resourceValue, workshopRef, happinessTarget)
;endFunction

;--------------------------------------------------------------------------------------------------------------------

; call to stamp actor with WorkshopActorApply alias data
function ApplyWorkshopAliasData(actor theActor)
	WorkshopActorApply.ApplyToRef(theActor)
endFunction


; specialized function to unassign actor from one object - called during AssignActor process on former owner of newly assigned object
function UnassignActorFromObject(WorkshopNPCScript theActor, WorkshopObjectScript theObject, bool bSendUnassignEvent = true)
	wsTrace("	UnassignActorFromObject " + theActor + " from " + theObject)

	WorkshopScript workshopRef = GetWorkshop(theActor.GetWorkshopID())

	; do I currently own this object?
	if theObject.GetActorRefOwner() == theActor
		wsTrace("		unassigning " + theObject)
		; this will also add the actor to the unassigned actor list (when it unassigns the last object)
		UnassignObject(theObject)
		if bSendUnassignEvent
			; WSWF Event Edit - Adding actor to the end of event arguments 
			;/
			Var[] kargs = new Var[2]
			kargs[0] = theObject
			kargs[1] = workshopRef
			/;
				
			Var[] kargs = new Var[0]
			kargs.Add(theObject)
			kargs.Add(workshopRef)
			kargs.Add(theActor)
			wsTrace(" 	sending WorkshopActorUnassigned event")
			SendCustomEvent("WorkshopActorUnassigned", kargs)
		endif

		;UFO4P 2.0.4 Bug '24264: removed this code block:
		;Everything that needs to be updated on an actor if his last work object is removed is done by the UnassignObject function.
		;There is no need to run this again.
		
		;/
		; do I still have any work objects?

		; work object?
		ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
		int foundIndex = WorkshopActors.Find(theActor)
		if foundIndex > -1
			; unassign ownership of all work objects
			;UFO4P 1.0.3 Bug #20599: the following line is not needed here (this is now part of the IsObjectOwner function, see below)
			;ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects(theActor)
			
			;UFO4P 1.0.3 Bug #20599: replaced condition check (checking for ResourceObjects.Length = 0 is inadequate, because this would result in the actor
			;being considered as unassigned ONLY if he has no bed assigned either). The new function IsObjectOwner will return true only if the passed in
			;actor owns anything else than a bed.
			
			;if ResourceObjects.Length == 0 (vanilla code)
			if IsObjectOwner(workshopRef, theActor) == false
				; clear actor work flags
				theActor.SetMultiResource(NONE)
				theActor.SetWorker(false)
				;UFO4P 1.0.3 Bug #20599: also reset the bool added in patch 1.5
				theActor.bWork24Hours = false
			endif
		endif
		/;
	endif
endFunction


function RemoveActorFromWorkshopPUBLIC(WorkshopNPCScript theActor)
	; lock editing
	GetEditLock()

	;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes below for explanation)
	;UFO4P 2.0.4 Bug #24312: added a value for the new bool argument (always false here because ResetWorkshop never calls this function).
	UnassignActor_Private(theActor, true, true, bResetMode = false)

	; unlock editing
	EditLock = false
endFunction

;UFO4P 2.0 Bug #21900: Created new UnassignActor function and renamed the vanilla UnassignActor function (see below) to UnassignActor_Private. This function
;and the functions called by it change ownership of workshop obkects and also modify resource data values, potentially creating interferences with many other
;threads that use this function or its sub-functions at the same time. Nonetheless, many external scripts (WorkshopNPCScript, WorkshopChildScript and several
;quest scripts) were calling the non-public function directly, without making sure that editing was not currently locked on this script. All of these scripts
;will still be calling UnassignActor, but this is now a public function that checks the edit lock before calling the private version of that function. All
;calls of UnassignActor from within this script have been modified to call UnassignActor_Private instead, so they will still be calling the non-public version.
function UnassignActor(WorkshopNPCScript theActor, bool bRemoveFromWorkshop = false, bool bSendUnassignEvent = true)
	GetEditLock()
	;UFO4P 2.0.4 Bug #24312: added a value for the new bool argument (always false here because ResetWorkshop does not call the public version).
	UnassignActor_Private(theActor, bRemoveFromWorkshop, bSendUnassignEvent, bResetMode = false)
	EditLock = false
EndFunction

; call this function to unassign this actor from any job
; (always called as part of assignment process)
; bRemoveFromWorkshop - use TRUE when you want to completely remove the actor from the workshop (e.g. when the actor dies)
;UFO4P 2.0 Bug #21900: Renamed this function to UnassignActor_Private (for explantion see the comment on the UnassignActor function above).
;UFO4P 2.0.4 Bug #24312: Added the new bool argument bResetMode, to let this function know whether it was called by ResetWorkshop.
function UnassignActor_Private(WorkshopNPCScript theActor, bool bRemoveFromWorkshop = false, bool bSendUnassignEvent = true, bool bResetMode = false)
	;/
	wsTrace("	UnassignActor_Private " + theActor + " bRemoveFromWorkshop=" + bRemoveFromWorkshop)

	WorkshopScript workshopRef = GetWorkshop(theActor.GetWorkshopID())

	; am I currently assigned to something?
	int foundIndex = -1

	; caravan?
	foundIndex = CaravanActorAliases.Find(theActor)
	if foundIndex > -1
		; remove me from the caravan alias collection
		CaravanActorAliases.RemoveRef(theActor)
		CaravanActorRenameAliases.RemoveRef(theActor)

		Location startLocation = workshopRef.myLocation
		Location endLocation = GetWorkshop(theActor.GetCaravanDestinationID()).myLocation
		; unlink locations
		startLocation.RemoveLinkedLocation(endLocation, WorkshopCaravanKeyword)

		; set back to Boss
		if theActor.IsCreated()
			; Patch 1.4: allow custom loc ref type on workshop NPC
			theActor.SetAsBoss(startLocation)
		endif

		; update workshop rating - increment unassigned actors total
		theActor.SetValue(WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 1)

		; clear caravan brahmin
		CaravanActorBrahminCheck(theActor)

		; 1.6: send custom event for this actor
		Var[] kargs = new Var[2]
		kargs[0] = theActor
		kargs[1] = workshopRef
		wsTrace(" 	sending WorkshopActorCaravanUnassign event")
		SendCustomEvent("WorkshopActorCaravanUnassign", kargs)
	endif

	; work object?
	ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
	foundIndex = WorkshopActors.Find(theActor)
	if foundIndex > -1

	if theActor.GetWorkshopID() == workshopRef.GetWorkshopID()
		; unassign ownership of all work objects
		ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects(theActor)
		int i = 0
		while i < ResourceObjects.Length
			; TEMP
			wsTrace("		owned ref " + i + ": " + ResourceObjects[i])
			; end TEMP
			WorkshopObjectScript theObject = ResourceObjects[i] as WorkshopObjectScript
			wsTrace("		owned workshop object " + i + ": " + theObject)
			;UFO4P: Added sanity check and trace to spot items with missing scripts:
			if theObject == none
				wsTrace("		owned workshop object " + ResourceObjects[i] + " has no WorkshopObjectScript")
			elseIf theObject.RequiresActor()
				wsTrace("		unassigning " + theObject)
				; this will also add the actor to the unassigned actor list (when it unassigns the last object)
				UnassignObject(theObject)
				if bSendUnassignEvent
					; send custom event for this object
					; WSWF Event Edit - Adding actor to the end of event arguments 
					;Var[] kargs = new Var[2]
					;kargs[0] = theObject
					;kargs[1] = workshopRef
					
					Var[] kargs = new Var[0]
					kargs.Add(theObject)
					kargs.Add(akWorkshopRef)
					kargs.Add(theActor)
					wsTrace(" 	sending WorkshopActorUnassigned event")
					SendCustomEvent("WorkshopActorUnassigned", kargs)
				endif
			endif
			i += 1
		endWhile

		;UFO4P 2.0.4 Bug '24264: removed these lines:
		;If UnassignObject removes an actor's last work object, it will update these flags. Thus, if it needs to be done it will have
		;been done already once the script gets to this point. There's no need to run this again.

		; clear actor work flags
		;theActor.SetMultiResource(NONE)
		;theActor.SetWorker(false)

	else
		wsTrace("		UnassignActor_Private: NOTE - " + theActor + " is owned by workshop " + theActor.GetWorkshopID() + ", current workshop=" + currentWorkshopID + " - can't unassign ownership of work objects.")
	endif

	if bRemoveFromWorkshop
		wsTrace("	UnassignActor_Private " + theActor + ": removing from workshop")
		; completely remove from workshop

		; clear workshop linked ref
		theActor.SetLinkedRef(NONE, WorkshopItemKeyword)

		; clear applied alias data
		WorkshopActorApply.RemoveFromRef(theActor)

		; remove from permanent actor collection alias
		PermanentActorAliases.RemoveRef(theActor)
		
		; remove ownership flag to prevent trading
		theActor.SetValue(WorkshopPlayerOwnership, 0)	

		; PATCH - remove workshop ID as well
		theActor.SetWorkshopID(-1)

		; update population rating on workshop's location
		if workshopRef.RecalculateWorkshopResources() == false
			; decrement population manually if couldn't recalc
			;UFO4P 2.0 Bug #21896: Call ModifyResourceData_Private instead of ModifyResourceData here (see notes on that function for explanation)
			ModifyResourceData_Private(WorkshopRatings[WorkshopRatingPopulation].resourceValue, workshopRef, -1)
		endif

		;UFO4P 2.0.1: Added trace:
		wsTrace("	UnassignActor_Private: " + theActor + " has been removed from workshop")
	endif

	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function. 
	-----------------------------------------------------------------------------------------------------------------------------------------
	/;

	wsTrace("	UnassignActor_Private: Unassigning " + theActor + "; bRemoveFromWorkshop = " + bRemoveFromWorkshop)

	int workshopID = theActor.GetWorkshopID()
	if workshopID < 0
		wsTrace("	UnassignActor_Private: " + theActor + " is not assigned to any workshop. Returning ... ")
		return
	endif

	WorkshopScript workshopRef = GetWorkshop (workshopID)
	bool bShouldTryToAssignResources = false
	
	int caravanActorIndex = CaravanActorAliases.Find (theActor)
	if caravanActorIndex >= 0
		; WSWF - Moved Caravan Unassignment to its own function
		UnassignActorFromCaravan(theActor, workshopRef, bRemoveFromWorkshop)
	else
		;This won't work if the workshop is not loaded because we need to loop through the actor's work objects:
		if UFO4P_IsWorkshopLoaded (workshopRef)
			ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects (theActor)
			int countResourceObjects = ResourceObjects.Length
			int i = 0
			while i < countResourceObjects
				ObjectReference objectRef = ResourceObjects[i]
				WorkshopObjectScript theObject = objectRef as WorkshopObjectScript
				
				
				if theObject == none
					wsTrace("		owned workshop object " + i + ": " + objectRef + " has no WorkshopObjectScript")
				else
					wsTrace("		owned workshop object " + i + ": " + theObject)
					;don't remove the bed if the actor is not removed from the workshop:
					if theObject.HasKeyword (WorkshopWorkObject) && (theObject.IsBed() == false || bRemoveFromWorkshop)
						wsTrace("		unassigning " + theObject)
						;UFO4P 2.0.4 Bug #24273: calling this function with the new bool passed in as 'true':
						UnassignObject (theObject, bUnassignActorMode = true)
						;If at least one object has beeen removed, we should run the resource assignment functions to find a new owner:
						bShouldTryToAssignResources = true
						if bSendUnassignEvent
							; WSWF Event Edit - Adding actor to the end of event arguments 
							;/
							Var[] kargs = new Var[2]
							kargs[0] = theObject
							kargs[1] = workshopRef
							/;
								
							Var[] kargs = new Var[0]
							kargs.Add(theObject)
							kargs.Add(workshopRef)
							kargs.Add(theActor)
							
							wsTrace(" 	sending WorkshopActorUnassigned event")
							SendCustomEvent("WorkshopActorUnassigned", kargs)
						endif
					endif
				endif
				
				i += 1
			endWhile
		else
			wsTrace("   UnassignActor_Private: Workshop is currently not loaded. Can't unassign ownership of work objects.")
			;UFO4P 2.0.4 Note: If this didn't work now, the work objects will be unassigned by the next workshop reset
		endif

	endif

	if bRemoveFromWorkshop
		wsTrace("   UnassignActor_Private: Removing " + theActor + " from workshop " + workshopRef)

		theActor.SetLinkedRef (NONE, WorkshopItemKeyword)
		WorkshopActorApply.RemoveFromRef (theActor)
		PermanentActorAliases.RemoveRef (theActor)
		theActor.SetValue (WorkshopPlayerOwnership, 0)	

		; PATCH - remove workshop ID as well
		theActor.SetWorkshopID (-1)

		; update population rating on workshop's location
		if workshopRef.RecalculateWorkshopResources() == false
			ModifyResourceData_Private (WorkshopRatings[WorkshopRatingPopulation].resourceValue, workshopRef, -1)
		endif
		
		; WSWF New Event
		Var[] kArgs = new Var[0]
		kArgs.Add(theActor)
		kArgs.Add(workshopRef)
		SendCustomEvent("WorkshopRemoveActor", kArgs)
	endif
	;If not in reset mode, try to find new owners for unassigned objects:
	if !bResetMode && bShouldTryToAssignResources && workshopID == currentWorkshopID
		TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
		TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
		if bRemoveFromWorkshop
			TryToAssignBeds (workshopRef)
		endif
	endif

	wsTrace("	UnassignActor_Private: DONE")

endFunction

; WSWF - Refactoring caravan unassignment to its own function
Function UnassignActorFromCaravan(WorkshopNPCScript theActor, WorkshopScript workshopRef, Bool bRemoveFromWorkshop = false)
	CaravanActorAliases.RemoveRef (theActor)
	CaravanActorRenameAliases.RemoveRef (theActor)
	; unlink locations
	Location startLocation = workshopRef.myLocation
	Location endLocation = GetWorkshop (theActor.GetCaravanDestinationID()).myLocation
	startLocation.RemoveLinkedLocation (endLocation, WorkshopCaravanKeyword)
	; clear caravan brahmin
	CaravanActorBrahminCheck (theActor)

	; set back to Boss - UFO4P 2.0.4 Bug #24263: but only if we don't remove him from the workshop:
	if theActor.IsCreated() && !bRemoveFromWorkshop
		; Patch 1.4: allow custom loc ref type on workshop NPC
		theActor.SetAsBoss (startLocation)
	endif

	; WSWF - Since we introduced the possibility of caravan owners having other jobs, we don't want to automatically assume this leaves them unassigned
	if( !bRemoveFromWorkshop && ! IsObjectOwner(workshopRef, theActor))
		; update workshop rating - increment unassigned actors total
		theActor.SetValue (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 1)
	endif

	; 1.6: send custom event for this actor
	Var[] kargs = new Var[2]
	kargs[0] = theActor
	kargs[1] = workshopRef
	wsTrace(" 	sending WorkshopActorCaravanUnassign event")
	SendCustomEvent("WorkshopActorCaravanUnassign", kargs)
EndFunction

; call to unassign specified object from any actor
;UFO4P 2.0.4 Bug #24273: added the bool argument bUnassignActorMode:
;If true, the function knows that it was called by UnassignActor_Private and skips some code that doesn't need to run if all work objects
;are unassigned from an actor (this is what UnassignActor_Private does: it loops through an actor's work objects and removes them all).
;NOTE: This will not cause API issues because this is a private function that is only called from other functions on this script. External
;scripts call public versions of this function and these remain unaltered.
function UnassignObject(WorkshopObjectScript theObject, bool bRemoveObject = false, bool bUnassignActorMode = false)

	;/
	; bRemoveObject = true  - means object is being completely removed from the workshop system
	wsTrace("	UnassignObject " + theObject)
	if bRemoveObject
		wsTrace("		REMOVING...")
	endif

	;WorkshopScript workshopRef = GetWorkshop(theObject.workshopID)
	
	;UFO4P 2.0 Bug #20520: Replaced the previous line with the following code to avoid errors if the object has no valid workshopID. Also added a trace
	;to log the references of the respective objects.
	WorkshopScript workshopRef = none
	int UFO4P_WorkshopID = theObject.workshopID
	if UFO4P_WorkshopID >= 0
		workshopRef = GetWorkshop(UFO4P_WorkshopID)
	else
		wsTrace("	UnassignObject: Object " + theObject + " is not assigned to any workshop.")
	endIf
		
	; get my owner (if any)
	WorkshopNPCScript assignedActor = theObject.GetAssignedActor()

	if assignedActor
		; clear my ownership
		theObject.AssignActor(none)

		; 1.5 - new 24-hour work flag
		;UFO4P 1.0.3 Bug #20599: Removed the following three lines: the flag should only be set to 'false' if this was the actor's only work object of
		;this type, but whether this is true or not is not known at this point. The new code added below will handle this appropriately though.
		;if theObject.bWork24Hours
			;assignedActor.bWork24Hours = false 
		;endif

		; clear link if it exists
		if theObject.AssignedActorLinkKeyword
			assignedActor.SetLinkedRef(NONE, theObject.AssignedActorLinkKeyword)
		endif

		;UFO4P 2.0 Bug #20520: Added check to skip the code that requires a valid workshopRef
		;(if the object has no valid workshopID, workshopRef will be none)
		if UFO4P_WorkshopID >= 0
		
			;  clear vendor faction from actor
			if theObject.VendorType > -1
				SetVendorData(workshopRef, assignedActor, theObject, false)
			endif

			; is does my owner own anything else?
			;UFO4P 1.0.3 Bug #20599: Removed the following lines: This job is now done by the new function IsObjectOwner.
			;ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects(assignedActor)
			;int i = 0
			;bool ownedObject = false
			;while i < ResourceObjects.Length && ownedObject == false
				;WorkshopObjectScript resourceObject = ResourceObjects[i] as WorkshopObjectScript
				;if resourceObject && resourceObject.IsBed() == 0
					; exit loop
					;ownedObject = true
				;endif
				;i += 1
			;endWhile

			;UFO4P 1.0.3 Bug #20599: replaced the following line. The new function IsObjectOwner checks whether the passed in actor owns anything else than a bed
			;if ownedObject = false
			if IsObjectOwner (workshopRef, assignedActor) == false
				; this was the only thing I owned - add owner back to unassigned actor list
				assignedActor.SetValue(WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 1)
				;UFO4P 1.0.3 Bug #20599: clear guard, worker and scavenger flags and reset the bool added in patch 1.5
				assignedActor.SetMultiResource(NONE)
				assignedActor.SetWorker(false)
				assignedActor.bWork24Hours = false			
			endif
			
		endIf

	endif

	;UFO4P 1.0.x Bug #20520: Added a check for UFO4P_WorkshopID (see above) to skip this if the object has no valid workshopID:
	if UFO4P_WorkshopID >= 0 && (assignedActor || bRemoveObject)
		; update ratings
		UpdateWorkshopRatingsForResourceObject(theObject, workshopRef, bRemoveObject)
	endif

	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;
	
	if bRemoveObject
		wsTrace("   UnassignObject: REMOVING " + theObject)
	else
		wsTrace("   UnassignObject: Unassigning " + theObject)
	endif

	WorkshopScript workshopRef = none
	int UFO4P_WorkshopID = theObject.workshopID
	if UFO4P_WorkshopID >= 0
		workshopRef = GetWorkshop(UFO4P_WorkshopID)
	else
		wsTrace("	UnassignObject: " + theObject + " is not assigned to any workshop.")
	endIf

	WorkshopNPCScript assignedActor = theObject.GetAssignedActor()

	if assignedActor

		theObject.AssignActor(none)

		keyword actorLinkKeyword = theObject.AssignedActorLinkKeyword
		if actorLinkKeyword
			assignedActor.SetLinkedRef (NONE, actorLinkKeyword)
		endif

		if UFO4P_WorkshopID >= 0

			if theObject.VendorType > -1
				SetVendorData (workshopRef, assignedActor, theObject, false)
			endif

			bool bIsBed = theObject.IsBed()

			;if workshop is currently loaded and object is a bed or multi-resource object, add it to the respective object array:
			;NOTE: Not going to reassign them here. This will be handled by the functions that called this function.
			if UFO4P_WorkshopID == currentWorkshopID
				if bRemoveObject && bIsBed
					;If a bed is removed from the workshop, add the previous owner to the UFO4P_ActorsWithoutBeds array, so he can get a new one assigned.
					;Note: if this  function is called by UnassignActrr_Private, bRemoveObject is never true, so there is no risk here to add an actor to
					;the array who is subsequently removed from the workshop.
					UFO4P_ActorsWithoutBeds.Add (assignedActor)
				elseif !bRemoveObject
					if bIsBed
						UFO4P_AddUnassignedBedToArray (theObject)
					elseif theObject.HasMultiResource()
						UFO4P_AddObjectToObjectArray (theObject)
					endif
				endif
			endif

			;If object is a bed, this code can be skipped: removal of a bed has no impact on an actor's worker status
			if bIsBed == false

				if IsObjectOwner (workshopRef, assignedActor) == false
					assignedActor.SetValue (WorkshopRatings[WorkshopRatingPopulationUnassigned].resourceValue, 1)
					assignedActor.SetMultiResource (none)
					assignedActor.SetWorker(false)
					assignedActor.bWork24Hours = false
					;if workshop is currently loaded, also make sure that the actor gets removed from the worker arrays:
					if UFO4P_WorkshopID == currentWorkshopID
						UFO4P_RemoveActorFromWorkerArray (assignedActor)
					endif

				;UFO4P 2.0.4 Bug #24273: added a new branch:
				;If the actor still owns other objects, he's either assigned to food or safety and his multi-resource production value
				;needs to be updated. This doesn't need to run however if this function was called by UnassignActor_Private: that function
				;will remove all work objects (there will be subsequent calls of this function) and it is sufficient tu update the values
				;once the last object has been removed (which is handled above).
				elseif !bUnassignActorMode
					actorValue multiResourceValue = assignedActor.assignedMultiResource
					if multiResourceValue && theObject.HasResourceValue (multiResourceValue)
						float previousProduction = assignedActor.multiResourceProduction
						;UFO4P 2.0.4 Bug #24311: subtracting the base value here instead of the current value:
						;(see the comment in AssignActorToObject for further explanation)
						assignedActor.multiResourceProduction = previousProduction - theObject.GetBaseValue (multiResourceValue)
						;if workshop is currently loaded, add actors who are below their production limit to the worker arrays:
						if UFO4P_WorkshopID == currentWorkshopID
							UFO4P_AddActorToWorkerArray (assignedActor, GetResourceIndex (multiResourceValue))
						endif
					endif
				endif

			endif

		endif
	
	else
		wsTrace("	UnassignObject: " + theObject + " is not assigned to any actor.")
	endif

	if UFO4P_WorkshopID >= 0 && (assignedActor || bRemoveObject)
		UpdateWorkshopRatingsForResourceObject (theObject, workshopRef, bRemoveObject)
	endif

	wsTrace("	UnassignObject: DONE")

endFunction


function AssignObjectToWorkshop(WorkshopObjectScript workObject, WorkshopScript workshopRef, bool bResetMode = false)
	; bResetMode: true means to ignore TryToAssignFarms/Beds calls (ResetWorkshop calls it once at the end)

	;/
	wsTrace("	AssignObjectToWorkshop: " + workObject)

	; is this a bed? if so, add to unassigned bed list
	if workObject.IsBed()
		wsTrace("		bed - check for ownership")

		; am I owned?
		if workObject.IsActorAssigned() && workObject.GetAssignedActor()
			WorkShopNPCScript owner = workObject.GetAssignedActor()
			; is this actor in our actor list?
			ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
			int actorIndex = WorkshopActors.Find(owner)
			wsTrace("		check actors list: index=" + actorIndex)
			if actorIndex == -1
				; clear ownership - this actor has gone missing somehow
				wsTrace("    " + workObject + " assigned actor not found - clearing assignment")
				workObject.AssignActor(None)
			endif
		endif

		if !bResetMode
			TryToAssignBeds(workshopRef)
		endif
	; work object?
	else
		wsTrace("		work object - check for ownership")
		if workObject.HasKeyword(WorkshopWorkObject)
			; is this already owned by an actor?
			WorkShopNPCScript owner = workObject.GetAssignedActor()
			wsTrace("		GetAssignedActor=" + owner)
			if workObject.IsActorAssigned() && owner
				; is this actor in our actor list?
				ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
				int actorIndex = WorkshopActors.Find(owner)
				wsTrace("		owner index=" + actorIndex)
				if actorIndex > -1
					; found the actor
					; assign actor
					AssignActorToObject(owner, workObject, bResetMode = bResetMode, bAddActorCheck = false)
					; NOTE don't need to call UpdateWorkshopRatingsForResourceObject - this is called in AssignActorToObject
				else
					; clear ownership - this actor has gone missing somehow
					wsTrace("    " + workObject + " assigned actor not found - clearing assignment")
					workObject.AssignActor(None)
				endif
			endif
		endif
		; update ratings
		UpdateWorkshopRatingsForResourceObject(workObject, workshopRef)
	endif

	if workObject.HasMultiResource()
		if !bResetMode
			TryToAssignResourceType(workshopRef, workObject.GetMultiResourceValue())
		endif
	endif

	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:
		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function.
	-----------------------------------------------------------------------------------------------------------------------------------------
	/;

	wsTrace("	AssignObjectToWorkshop: " + workObject)

	if workObject.IsBed()

		wsTrace("		Bed - check for ownership")
		bool UFO4P_Owned = false
		if workObject.IsActorAssigned()
			WorkShopNPCScript owner = workObject.GetAssignedActor()
			if owner
				;UFO4P 2.0.4 Bug #24408: unassign any berds that are currently assigned to robots:
				if owner.GetBaseValue(WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue) > 0
					wsTrace("		assigned actor is robot - clearing assignment")
					workObject.AssignActor(None)
				else
					ObjectReference[] WorkshopActors = GetWorkshopActors (workshopRef)
					int actorIndex = WorkshopActors.Find (owner)
					wsTrace("		check actor list: index = " + actorIndex)
					if actorIndex == -1
						wsTrace("		assigned actor not found - clearing assignment")
						workObject.AssignActor(None)
					else
						UFO4P_Owned = true
					endif
				endif
			endif
		endif

		;if workshop is the current workshop, add all unowned beds to the UFO4P_UnassignedBeds array:
		if UFO4P_Owned == false && workshopRef.GetWorkshopID() == currentWorkshopID
			UFO4P_AddUnassignedBedToArray (workObject)
			if !bResetMode
				TryToAssignBeds (workshopRef)
			endif
		endif

	else

		bool UFO4P_ShouldUpdateRatings = true

		if workObject.HasKeyword (WorkshopWorkObject) && workObject.IsActorAssigned()
			wsTrace("		Work object - check for ownership")
			WorkShopNPCScript owner = workObject.GetAssignedActor()
			wsTrace("		Assigned actor = " + owner)
			if owner
				ObjectReference[] WorkshopActors = GetWorkshopActors (workshopRef)
				int actorIndex = WorkshopActors.Find (owner)
				wsTrace("		Owner index = " + actorIndex)
				;Failsafe: also check for caravan actors here, in case UnassignActor_Private failed to unassign the actor's work
				;objects when he was assigned to the caravan:
				if actorIndex > -1 && CaravanActorAliases.Find (owner) < 0
					AssignActorToObject (owner, workObject, bResetMode = bResetMode, bAddActorCheck = false)
					; NOTE don't need to call UpdateWorkshopRatingsForResourceObject - this is called in AssignActorToObject
					UFO4P_ShouldUpdateRatings = false
				else
					wsTrace("		" + workObject + ": Assigned actor not found - clearing assignment")
					workObject.AssignActor(None)
				endif
			endif
		endif
		
		if UFO4P_ShouldUpdateRatings
			UpdateWorkshopRatingsForResourceObject (workObject, workshopRef)
		endif

		if workObject.HasMultiResource() && workObject.HasKeyword (WorkshopWorkObject) && workObject.IsActorAssigned() == false
			actorValue multiResourceValue = workObject.GetMultiResourceValue()
			;Don't try to assign damaged objects:
			if workObject.GetBaseValue (multiResourceValue) == workObject.GetValue (multiResourceValue)
				UFO4P_AddObjectToObjectArray (workObject)
				if !bResetMode
					TryToAssignResourceType (workshopRef, multiResourceValue)
				endif
			endif
		endif

	endif

endFunction

; turn on/off radio
function UpdateRadioObject(WorkshopObjectScript radioObject)
	wsTrace("	UpdateRadioObject for " + radioObject)
	WorkshopScript workshopRef = GetWorkshop(radioObject.workshopID)
	; radio
	if radioObject.bRadioOn && radioObject.IsPowered()
		wsTrace("	 starting radio station")
		; make me a transmitter and start radio scene
		; 1.6: allow workshop-specific override
		if workshopRef.WorkshopRadioRef
			workshopRef.WorkshopRadioRef.Enable() ; enable in case this is a unique station
			radioObject.MakeTransmitterRepeater(workshopRef.WorkshopRadioRef, workshopRef.workshopRadioInnerRadius, workshopRef.workshopRadioOuterRadius)
			if workshopRef.WorkshopRadioScene.IsPlaying() == false
				workshopRef.WorkshopRadioScene.Start()
			endif
		else 
			radioObject.MakeTransmitterRepeater(WorkshopRadioRef, workshopRadioInnerRadius, workshopRadioOuterRadius)
			if WorkshopRadioScene01.IsPlaying() == false
				WorkshopRadioScene01.Start()
			endif
		endif
		if workshopRef.RadioBeaconFirstRecruit == false
			WorkshopEventRadioBeacon.SendStoryEvent(akRef1 = workshopRef)
		endif
	else
		wsTrace("	 stopping radio station")
		radioObject.MakeTransmitterRepeater(NONE, 0, 0)
		; if unique radio, turn it off completely
		if workshopRef.WorkshopRadioRef && workshopRef.bWorkshopRadioRefIsUnique
			wsTrace("	 custom station: disabling transmitter")
			workshopRef.WorkshopRadioRef.Disable()
			; stop custom scene if unique
			workshopRef.WorkshopRadioScene.Stop()
		endif
	endif
	; send power change event so quests can react to this
	workshopRef.RecalculateWorkshopResources()
	SendPowerStateChangedEvent(radioObject, workshopRef)
endFunction

; call any time an object's status changes
; adds/removes this object's ratings to the workshop's ratings
; also updates the object's production flag
function UpdateWorkshopRatingsForResourceObject(WorkshopObjectScript workshopObject, WorkshopScript workshopRef, bool bRemoveObject = false, bool bRecalculateResources = true)

	;UFO4P 2.0.4; removed trace:
	;wsTrace("	UpdateWorkshopRatingsForObject " + workshopObject + " bRemoveObject=" + bRemoveObject)

	; do we need to add/remove this from the workshop ratings?
	;int ratingMult = 0
	;if bRemoveObject
	;	UpdateVendorFlags(workshopObject, workshopRef)
	;else
	;	UpdateVendorFlags(workshopObject, workshopRef)
	;endif

	;UFO4P 2.0.4: Simplified the code block above:
	UpdateVendorFlags (workshopObject, workshopRef)
	
	; should we recalculate everything?
	if bRecalculateResources
		workshopRef.RecalculateWorkshopResources()
	endif

	; special case
	if workshopObject.HasKeyword(WorkshopRadioObject)
		UpdateRadioObject(workshopObject)
	endif

	;UFO4P 2.0.4; modified trace:
	wsTrace("	UpdateWorkshopRatingsForObject " + workshopObject + ": DONE")

endFunction

; possibly temp - helper function to recalculate total resource damage when an object is destroyed

;UFO4P 1.0.5 Bug #20972: Edit lock added to the following function. The only user of this function is WorkshopObjectScript, but the RecalculateResourceDamage
;ForResource function called from it may modify resource data values, potentially creating interferences with other threads modifying resource data values at
;the same time. While this function is actually threading safe (it only calls functions on the same script), the RecalculateResourceDamageForResource is not, 
;because it calls an external script to calculate the totalDamage float. Thus, there would still be interferences of calls from this function with direct calls
;of the RecalculateResourceDamageForResource function from WorkshopObjectScript. Threading issues of this kind are likely to occur during workshop attacks
;when any number of damaged workshop objects may be calling one of the two functions at the same time. Note that the RecalculateResourceDamageForResource func-
;tion cannot be locked as it may be called from locked threads.
function RecalculateResourceDamage(WorkshopScript workshopRef)
	GetEditLock()
	RecalculateResourceDamageForResource(workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
	RecalculateResourceDamageForResource(workshopRef, WorkshopRatings[WorkshopRatingWater].resourceValue)
	RecalculateResourceDamageForResource(workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
	RecalculateResourceDamageForResource(workshopRef, WorkshopRatings[WorkshopRatingPower].resourceValue)
	RecalculateResourceDamageForResource(workshopRef, WorkshopRatings[WorkshopRatingPopulation].resourceValue)
	EditLock = false
endFunction


function RecalculateResourceDamageForResource(WorkshopScript workshopRef, actorValue akResource)
	wstrace(" RecalculateResourceDamageForResource " + workshopRef + " for " + akResource)
	ActorValue damageRatingValue = GetDamageRatingValue(akResource)
	; if not a resource with a damage rating, don't need to do anything
	if damageRatingValue
		float totalDamage = workshopRef.GetWorkshopResourceDamage(akResource)
		; set new damage total
		wstrace(" 	total damage= " + totalDamage)
		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
		SetResourceData_Private(damageRatingValue, workshopRef, totalDamage)
	endif
endFunction

; call to update vendor flags on all stores (e.g. for when adding population)
function UpdateVendorFlagsAll(WorkshopScript workshopRef)
	; get stores
	ObjectReference[] stores = GetResourceObjects(workshopRef, WorkshopRatings[WorkshopRatingVendorIncome].resourceValue)			
	; update vendor data for all of them (might trigger top level vendor for increase in population)
	int i = 0
	while i < stores.Length
		WorkshopObjectScript theStore = stores[i] as WorkshopObjectScript
		if theStore
			UpdateVendorFlags(theStore, workshopRef)
		endif
		i += 1
	endWhile
endFunction

; helper function for UpdateWorkshopRatingsForResourceObject
; update vendor flags based on this object's production state
function UpdateVendorFlags(WorkshopObjectScript workshopObject, WorkshopScript workshopRef)
	; set this to true if we are going to change state
	bool bShouldVendorFlagBeSet = false
	if workshopObject.VendorType > -1
		WorkshopVendorType vendorType = WorkshopVendorTypes[workshopObject.VendorType]

		if vendorType
			; if a vendor object, increment global if necessary
			if workshopObject.VendorType > -1 && workshopObject.vendorLevel >= VendorTopLevel
				; check for minimum connected population
				int linkedPopulation = GetLinkedPopulation(workshopRef, false) as int
				int totalPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
				int vendorPopulation = linkedPopulation + totalPopulation

				; NOTE: known issue - we're not checking for population dropping below minimum to invalidate top vendor flag. Acceptable.
				
				if vendorType
					wsTrace("		vendor population=" + vendorPopulation + ", vendorType.minPopulationForTopVendor=" + vendorType.minPopulationForTopVendor)
					if vendorPopulation >= vendorType.minPopulationForTopVendor && workshopRef.OwnedByPlayer
						bShouldVendorFlagBeSet = true
					endif
				endif
			endif
			if bShouldVendorFlagBeSet
				if workshopObject.bVendorTopLevelValid == false
					; change state:
					; increment top vendor global
					vendorType.topVendorFlag.Mod(1.0)
					workshopObject.bVendorTopLevelValid = true
				endif
			else
				if workshopObject.bVendorTopLevelValid == true
					; change state:
					; increment top vendor global
					vendorType.topVendorFlag.Mod(-1.0)
					workshopObject.bVendorTopLevelValid = false
				endif
			endif
		endif
	endif
endFunction


; assign spare beds to any NPCs that don't have one
function TryToAssignBeds(WorkshopScript workshopRef)
	; WSWF - Skip based on autoassign settings
	if( ! AutoAssignBeds)
		return
	endif
	
	;/
	wsTrace(" 	TryToAssignBeds for " + workshopRef.GetWorkshopID() + " (currentworkshop=" + currentWorkshopID + ")")

	;UFO4P 2.0.2 Bug #23016: Also check whether the workshop location is still loaded:
	;If not, UFO4P_IsWorkshopLoaded resets the current workshop properties and returns false. If the location is not loaded, the WorkshopActors array
	;(and the Beds array in the TryToAssignBedToActor function) would be empty or, in the worst case, incomplete, and running this code anyway would
	;result in an invalid assignment or no assignment at all.	
	if workshopRef.GetWorkshopID() == currentWorkshopID && UFO4P_IsWorkshopLoaded (workshopRef)
		; go through actors, see if any of them need beds
		ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
		wsTrace("		" + WorkshopActors.Length + " NPCs to check:")
		int i = 0
		while i < WorkshopActors.Length
			WorkshopNPCScript theActor = WorkshopActors[i] as WorkShopNPCScript
			TryToAssignBedToActor(workshopRef, theActor)
			i += 1
		endWhile
	endif

	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:

		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function.

		In this process, the function TryToAssignBedToActor became obsolete. That function ran zhe loop through the bed array while the
		vanilla TryToAssignBeds function ran the loop through the actor array. The new code does not need to loop through any of these
		arrays but does the assignment from a single loop through both of the helper arrays at the same time.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;
	
	wsTrace("TryToAssignBeds for " + workshopRef)
	wsTrace("	Found " + UFO4P_ActorsWithoutBeds.Length + " actors without beds")
	wsTrace("	Found " + UFO4P_UnassignedBeds.Length + " unassigned beds")
	;Note: array lengths are going to change since we remove actors and beds once they have been assigned
	while UFO4P_ActorsWithoutBeds.Length > 0 && UFO4P_UnassignedBeds.Length > 0
		WorkshopNPCScript theActor = UFO4P_ActorsWithoutBeds[0]
		if theActor
			wsTrace("	TryToAssignBeds: " + theActor + " has no bed")
			WorkshopObjectScript bedToAssign = UFO4P_UnassignedBeds[0]
			UFO4P_UnassignedBeds.Remove(0)
			if bedToAssign
				bedToAssign.AssignActor (theActor)
				wsTrace("	TryToAssignBeds: assigned bed " + bedToAssign + " to " + theActor)
			endif
		endif
		UFO4P_ActorsWithoutBeds.Remove(0)
	endWhile

endFunction

; assign a spare bed to the specified actor if he needs one
function TryToAssignBedToActor(WorkshopScript workshopRef, WorkshopNPCScript theActor)
	; WSWF - Skip based on autoassign settings
	if( ! AutoAssignBeds)
		return
	endif
	
	;/
	wsTrace("	TryToAssignBedToActor: " + theActor)
;	wsTrace("		WorkshopCurrentBeds.IsOwnedObjectInList(theActor)=" + WorkshopCurrentBeds.IsOwnedObjectInList(theActor))
	if theActor
;		ObjectReference myBed = WorkshopCurrentBeds.GetFirstOwnedObject(theActor)
		if ActorOwnsBed(workshopRef, theActor) == false
			wsTrace("		TryToAssignBedToActor: " + theActor + " has no bed ")
			ObjectReference[] beds = GetBeds(workshopRef)
			; loop through beds until we find an unassigned one
			int i = 0
			while i < beds.Length
				WorkshopObjectScript bedToAssign = beds[i] as WorkshopObjectScript
				if bedToAssign && bedToAssign.IsActorAssigned() == false
					; assign actor to bed
					bedToAssign.AssignActor(theActor)
					; break out of loop
					i = beds.Length
				endif
				i += 1
			endWhile
		endif
	endif
	/;
	
	;UFO4P 2.0.4 Bug #24312: this function is obsolete now:
	;The only users were TryToAssignBeds and AddActorToWorkshop. TryToAssignBeds does not need to loop through the beds array to get the
	;assignment done and therefore doesn't need to call this function. AddActorToWorkshop now calls TryToAssignBeds instead.

endFunction

;UFO4P 2.0.4 Note: this function is obsolete now:
;The vanilla TryToAssignResourceType function was the only user; the new version of that function does not use iz anymore.
int function GetNextIndex(int currentIndex, int maxIndex)
	if currentIndex < maxIndex
		return currentIndex + 1
	else
		return 0
	endif
endFunction

; try to assign all objects of the specified resource types
function TryToAssignResourceType(WorkshopScript workshopRef, ActorValue resourceValue)
	; WSWF - Override based on autoassign settings
	if((resourceValue == WorkshopRatings[WorkshopRatingSafety].resourceValue &&  ! AutoAssignDefense) || (resourceValue == WorkshopRatings[WorkshopRatingFood].resourceValue && ! AutoAssignFood))
		return
	endif
	
	
	;/
	;UFO4P 2.0.2 Bug #23016:
	;Also return if the workshop this function is supposed to run on is not loaded. Otherwise, the WorkshopActors array will be empty even if there are
	;actors at this workshop (this also makes sure that the message below only prints zero actors on the log if there really are no actors).
	if !resourceValue || UFO4P_IsWorkshopLoaded (workshopRef) == false
		return
	endif

	ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
	wsTrace("		Total actors: " + WorkshopActors.length)

	; if no actors, exit
	if WorkshopActors.Length == 0
		return
	endif

	int resourceIndex = GetResourceIndex(resourceValue)

	; first, make array of workers who are assigned to this resource type
	WorkshopNPCScript[] workers = new WorkShopNPCScript[WorkshopActors.Length]
	int maxWorkerIndex = -1
	
	; go through actor list, find workers
	int actorIndex = 0
	while actorIndex < WorkshopActors.Length
		WorkshopNPCScript theActor = WorkshopActors[actorIndex] as WorkshopNPCScript
		;UFO4P 2.0.3 Bug #23271: moved sanity check for 'theActor' before the trace becuase the trace runs assignedMultiResource on it and this will fail
		;with an error if theActor = none:
		if theActor
			wsTrace("		actor " + theActor + " assigned to " + resourceValue + "? " + (theActor.assignedMultiResource == resourceValue) )
			;if theActor && theActor.assignedMultiResource == resourceValue && theActor.multiResourceProduction < WorkshopRatings[resourceIndex].maxProductionPerNPC
			;UFO4P 2.0.3 Bug #23271: replaced the previous line with the following line (removed check for 'theActor' as this is now done before the trace):
			if theActor.assignedMultiResource == resourceValue && theActor.multiResourceProduction < WorkshopRatings[resourceIndex].maxProductionPerNPC
				maxWorkerIndex += 1
				workers[maxWorkerIndex] = theActor
			endif
		endif
		actorIndex += 1
	endWhile

	;UFO4P: Modified wording of trace since the value displayed here is NOT the number of actors assigned to the respective resource:
	wsTrace("		Found " + (maxWorkerIndex + 1) + " actors to assign to " + resourceValue)

	; shortcut - if no workers, we're done
	if maxWorkerIndex < 0	
		return
	endif

	; we now have an array of workers - loop through object list until we can't assign any more workers (or run out of farms)
	int objectIndex = 0
	bool availableworkers = true 	; this gets set to false if we ever loop through the actor list and find no workers left with available production slots
	int currentWorkerIndex = 0

	; get resources of specified type, undamaged only (no point in auto-assigning damaged objects)
	ObjectReference[] ResourceObjects = GetResourceObjects(workshopRef, resourceValue, 2)
	wsTrace("		Found " + ResourceObjects.Length + " undamaged " + resourceValue + " objects")

	while (objectIndex < ResourceObjects.Length) && availableworkers
		WorkshopObjectScript workshopObject = ResourceObjects[objectIndex] as WorkshopObjectScript
		; this produces the resource - is it owned?

		;UFO4P: Added sanity check and trace to spot items with missing scripts:
		if workshopObject == none
			wsTrace("		WorkshopObject " + ResourceObjects[objectIndex] + " has no WorkshopObjectScript")
		elseIf workshopObject.RequiresActor() && !workshopObject.IsActorAssigned()
			float resourceRating = workshopObject.GetResourceRating(resourceValue)
			; loop through actors looking for available workers
			bool assignedResource = false
			; save starting index so we only loop once
			int startingIndex = currentWorkerIndex
			bool exitLoop = false
			while !assignedResource && !exitLoop
				; get the next Worker
				WorkshopNPCScript theActor = workers[currentWorkerIndex]
				float resourceTotal = theActor.multiResourceProduction
				wsTrace("   	found Worker " + currentWorkerIndex + ": " + theActor + " at " + resourceTotal + " production")
				if (resourceTotal + resourceRating <= WorkshopRatings[resourceIndex].maxProductionPerNPC)
					wsTrace("   	found available Worker, resource rating=" + resourceRating + " - assign")
					assignedResource = true
					; I can produce this, so assign me to it
					; NOTE: resetMode = TRUE (so it skips calling this function again); addActorCheck = FALSE (since we already know this actor is assigned to this workshop)
					AssignActorToObject(theActor, workshopObject, bResetMode = true, bAddActorCheck = false) 
					; add to total
					resourceTotal += resourceRating
					; save out new resource total on me
					theActor.multiResourceProduction = resourceTotal
				endif
				; get next Worker index
				currentWorkerIndex = GetNextIndex(currentWorkerIndex, maxWorkerIndex)
				; if we're back to start, exit Worker loop
				if currentWorkerIndex == startingIndex
					exitLoop = true
				endif
			endWhile

			; if we didn't assign anything, AND the foodRating was 1 (minimum), then no workers left - we can stop looking
			if !assignedResource && resourceRating == 1
				wsTrace("	No more workers with spare production - stop looking")
				availableWorkers = false
			endif
		endif

		objectIndex += 1
	endwhile

	-----------------------------------------------------------------------------------------------------------------------------------------
		UFO4P 2.0.4 Bug #24312:

		Performance optimizations required substantial modifications to this function. In order to maintain legibility, the code has been
		rewritten. Any comments on modifications prior to UFO4P 2.0.4 (except for official patch notes) have been left out (they are still
		preserved in the commented out code above though). A summary of the modifications is included in the comment on the ResetWorkshop
		function.
	;-----------------------------------------------------------------------------------------------------------------------------------------
	/;

	if resourceValue

		wsTrace("	TryToAssignResourceType " + resourceValue)

		int resourceIndex = GetResourceIndex (resourceValue)

		;The new ResetWorkshop function makes sure that all actors available to assign to food or safety (i.e. any actors assigned to
		;those resources who currently are below their allowed production limit) are stored in the helper arrays when this function runs
		;after a new workshop has loaded. This saves us a loop through the workshop's actor array.
		WorkshopNPCScript[] workers 
		if resourceIndex == WorkshopRatingFood
			workers = UFO4P_FoodWorkers
		elseif resourceIndex == WorkshopRatingSafety
			workers = UFO4P_SafetyWorkers
		else
			wsTrace("	TryToAssignResourceType: Invalid resource value passed in. Returning ...")
			return
		endif

		ObjectReference[] ResourceObjects
		bool bInitialized = UFO4P_ObjectArrayInitialized (resourceIndex)
		if bInitialized
			ResourceObjects = UFO4P_GetObjectArray (resourceIndex)
		else
			;Creating the ResourceObjects array won't work if the workshop is not loaded. Only the first call of this function after a workshop has loaded
			;will find the helper array uninitialized, and this is always the call from the ResetWorkshop function. If the workshop is not loaded at this
			;point, we must reset currentWorkshopID because the reset that called this function is obviously unable to complete its tasks (which do not only
			;include the resource assignment itself but also the creation of the helper array).
			if UFO4P_IsWorkshopLoaded (workshopRef, bResetIfUnloaded = true) == false
				wsTrace("	TryToAssignResourceType: Workshop is not loaded. Returning ...")
				return
			endif
			; get resources of specified type, undamaged only (no point in auto-assigning damaged objects)
			ResourceObjects = GetResourceObjects (workshopRef, resourceValue, 2)
			; save this in the respective helper array, so we have an array now to work with even if there are currently no actors or objects to assign:
			UFO4P_SaveObjectArray (ResourceObjects, resourceIndex)
		endif

		int countWorkers = workers.Length
		wsTrace("		Found " + countWorkers + " actors to assign to " + resourceValue)
		int countResourceObjects = ResourceObjects.Length
		wsTrace("		Found " + countResourceObjects + " undamaged " + resourceValue + " objects")		
		if countResourceObjects <= 0 || countWorkers <= 0
			return
		endif

		float maxProduction = WorkshopRatings[resourceIndex].maxProductionPerNPC
		; WSWF - Introducing edits to max production
		if(resourceValue == WorkshopRatings[WorkshopRatingSafety].resourceValue)
			maxProduction = MaxDefenseWorkPerSettler
		elseif(resourceValue == WorkshopRatings[WorkshopRatingFood].resourceValue)
			maxProduction = MaxFoodWorkPerSettler
		endif
	
		int workerIndex = 0
		
		;Note: the array length is going to change since we remove actors that have been assigned their allowed maximum of resources
		while workerIndex < workers.Length

			WorkshopNPCScript theWorker = workers[workerIndex]
			if theWorker == none
				workers.Remove (workerIndex)
			else
				float resourceTotal = theWorker.multiResourceProduction
				wsTrace("		Found Worker " + theWorker + " at " + resourceTotal + " current production")
				bool actorAssigned = false
				int objectIndex = 0

				;Note: the array length is going to change since we remove objects that are invalid or have been assigned
				while objectIndex < ResourceObjects.Length && actorAssigned == false
					ObjectReference theObjectRef = ResourceObjects [objectIndex]
					WorkshopObjectScript theObject = theObjectRef as WorkshopObjectScript
					if theObject == none
						wsTrace("	TryToAssignResourceType: Resource object " + theObjectRef + " has no WorkshopObjectScript")
						ResourceObjects.Remove (objectIndex)
					elseif theObject.IsActorAssigned() || theObject.HasKeyword (WorkshopWorkObject) == false
						;Object is already assigned or doesn't require an actor -> remove
						ResourceObjects.Remove (objectIndex)
					elseif theObject.GetBaseValue (resourceValue) > theObject.GetValue (resourceValue)
						;Unassigned damaged objects: the array that was initially created per GetResourceObjects won't contain any damaged
						;objects, but it is possible that an object gets damaged after it has been stored in an UFO4P object array.
						ResourceObjects.Remove (objectIndex)
					else
						float resourceRating = theObject.GetResourceRating (resourceValue)
						if resourceTotal + resourceRating <= maxProduction
							wsTrace("		 Found object " + theObject + ", resource rating = " + resourceRating + " - assign")
							; NOTE: resetMode = TRUE (so it skips calling this function again); addActorCheck = FALSE (since we know this actor is assigned to this workshop)
							AssignActorToObject (theWorker, theObject, bResetMode = true, bAddActorCheck = false)
							;object has been assigned -> remove:
							ResourceObjects.Remove (objectIndex)
							;update worker's production:
							resourceTotal += resourceRating
							theWorker.multiResourceProduction = resourceTotal
							if resourceTotal == maxProduction
								actorAssigned = true
							endif
						else
							objectIndex += 1
						endif
					endif
				endWhile

				;At this point, we're done with the actor, either because he got a maximum number of resources assigend (in this case, 
				;actorAssigned will be true and AssignActorToObject will have removed him from the worker arrays already) or because we
				;ran out of assignable objects. In that case, we keep the actor in the array, so he can be considered again if the player
				;builds new resource objects.
				if actorAssigned == false
					workerIndex += 1
				endif
			endif

		endWhile

		; make sure the helper array is up to date (i.e. won't contain any invalid objects):
		UFO4P_SaveObjectArray (ResourceObjects, resourceIndex)

	endif

endFunction

; called by each workshop on the timer update loop
function DailyWorkshopUpdate(bool bInitialize = false)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" DAILY WORKSHOP UPDATE", bNormalTraceAlso = true)
	wsTrace("------------------------------------------------------------------------------ ")
	
	; produce for all workshops
	int workshopIndex = 0

	; calculate time interval between each workshop update
	if bInitialize
		dailyUpdateIncrement = 0.0 ; short increment on initialization - FOR NOW just keep it at 0 so it happens as fast as possible
	else
	 	dailyUpdateIncrement = dailyUpdateSpreadHours/Workshops.Length
	endif

	SendCustomEvent("WorkshopDailyUpdate")		
endFunction

; used by test terminal to automatically calculate and force an attack
function TestForceAttack()
	GetWorkshop(currentWorkshopID).CheckForAttack(true)
endFunction

; trigger story manager attack
function TriggerAttack(WorkshopScript workshopRef, int attackStrength)
	wsTrace("   TriggerAttack on " + workshopRef)
	;#102677 - Don't throw workshop attacks for vassal locations
	if workshopRef.HasKeyword(WorkshopType02Vassal) == false
		if !WorkshopEventAttack.SendStoryEventAndWait(akLoc = workshopRef.myLocation, aiValue1 = attackStrength, akRef1 = workshopRef)
			; Removed - now that we have an attack message, don't do fake attacks
			;/
			wsTrace(" 	no attack quest started - resolve if player is not nearby")
			; no quest started - resolve if player is not at this location
			if workshopRef.Is3DLoaded() == false && Game.Getplayer().GetDistance(workshopRef) > 4000
				ResolveAttack(workshopRef, attackStrength, RaiderFaction)
			endif
			/;
		endif
	endif
	wsTrace("   TriggerAttack DONE")
endFunction


int function CalculateAttackStrength(int foodRating, int waterRating)
	; attack strength: based on "juiciness" of target
	int attackStrength = math.min(foodRating + waterRating, maxAttackStrength) as int
	int attackStrengthMin = attackStrength/2 * -1
	int attackStrengthMax = attackStrength/2
	wsTrace("		Base attackStrength=" + attackStrength)
	wsTrace("		  attack strength variation=" + attackStrengthMin + " to " + attackStrengthMax)

	attackStrength = math.min(attackStrength + utility.randomInt(attackStrengthMin, attackStrengthMax), maxAttackStrength) as int
	wsTrace("		attackStrength=" + attackStrength)
	return attackStrength
endFunction

int function CalculateDefenseStrength(int safety, int totalPopulation)
	int defenseStrength = math.min(safety + totalPopulation, maxDefenseStrength) as int
	wsTrace("		defenseStrength=" + defenseStrength)
	return defenseStrength
endFunction

; called to set lastAttack, lastAttack faction
function RecordAttack(WorkshopScript workshopRef, Faction attackingFaction)
	; only reset last attack days if we can find the attacking faction
	FollowersScript:EncDefinition encDef = Followers.GetEncDefinition(factionToCheck = attackingFaction)
	if encDef

		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData below (see notes on that function for explanation)

		; set days since last attack to 0
		SetResourceData_Private(WorkshopRatings[WorkshopRatingLastAttackDaysSince].resourceValue, workshopRef, 0)
		; set attacking faction ID
		SetResourceData_Private(WorkshopRatings[WorkshopRatingLastAttackFaction].resourceValue, workshopRef, encDef.LocEncGlobal.GetValue())
	endif
endFunction


; called by attack quests if they need to be resolved "off stage"
; return value: TRUE = attackers won, FALSE = defenders won (to match CheckResolveAttackk on WorkshopAttackScript)
bool function ResolveAttack(WorkshopScript workshopRef, int attackStrength, Faction attackFaction)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("   ResolveAttack on " + workshopRef + " attack strength=" + attackStrength)
	ObjectReference containerRef = workshopRef.GetContainer()
	if !containerRef
		wsTrace(self + " ERROR - no container linked to workshop " + workshopRef + " with " + WorkshopLinkContainer, 2)
		return false
	endif

	;UFO4P 2.0.1 Bug #22271: Clear attack bool on workshop. If this workshop was registered for a delayed reset (this means that the player left
	;during the attack), also clear UFO4P_WorkshopRef_ResetDelayed and reset UFO4P_AttackRunning:
	workshopRef.UFO4P_CurrentlyUnderAttack = false
	if UFO4P_WorkshopRef_ResetDelayed && workshopRef == UFO4P_WorkshopRef_ResetDelayed
		UFO4P_WorkshopRef_ResetDelayed = none
		UFO4P_AttackRunning = false
	endif

	bool attackersWin = false

	int totalPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
	int safety = workshopRef.GetValue(WorkshopRatings[WorkshopRatingSafety].resourceValue) as int

	; record attack in location data
	RecordAttack(workshopRef, attackFaction)

	; defense strength: safety + totalPopulation 
	int defenseStrength = workshopRef.CalculateDefenseStrength(safety, totalPopulation)
	wsTrace("   ResolveAttack on " + workshopRef + ":		attack strength=" + attackStrength)
	wsTrace("   ResolveAttack on " + workshopRef + ":		defenseStrength=" + defenseStrength)

	; "combat resolution" - each roll 1d100 + strength, if attack > defense that's the damage done.
	int attackRoll = utility.randomInt() + attackStrength
	wsTrace("   ResolveAttack on " + workshopRef + ":		original attack roll=" + attackRoll)
	; don't let attack roll exceed 150 - makes high defense more likely to win
	attackRoll = math.min(attackRoll, resolveAttackMaxAttackRoll) as int

	int defenseRoll = utility.randomInt() + defenseStrength
	wsTrace("   ResolveAttack on " + workshopRef + ":		attack roll=" + attackRoll)
	wsTrace("   ResolveAttack on " + workshopRef + ":		defense roll=" + defenseRoll)

	if attackRoll > defenseRoll
		attackersWin = true

		; limit max damage based on defense - but max can't go below 25
		float maxAllowedDamage = math.max(resolveAttackAllowedDamageMin, 100-defenseStrength)
		wsTrace("   ResolveAttack on " + workshopRef + ":		maxAllowedDamage=" + maxAllowedDamage)
		float damage = math.min(attackRoll - defenseRoll, maxAllowedDamage)

		; get current damage - ignore if already more than this attack
		float currentDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageCurrent].resourceValue)
		if currentDamage < damage
			wsTrace("   ResolveAttack on " + workshopRef + ":	New damage=" + damage)
			float totalDamagePoints = 0.0
			; now set damage to all the resources
			totalDamagePoints += SetRandomDamage(workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue, damage)	; use total rating for food, water, safety, power
			totalDamagePoints += SetRandomDamage(workshopRef, WorkshopRatings[WorkshopRatingWater].resourceValue, damage)
			totalDamagePoints += SetRandomDamage(workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue, damage)
			totalDamagePoints += SetRandomDamage(workshopRef, WorkshopRatings[WorkshopRatingPower].resourceValue, damage)
			totalDamagePoints += SetRandomDamage(workshopRef, WorkshopRatings[WorkshopRatingPopulation].resourceValue, damage)
			; now calc total points to get "real" max damage
			float totalResourcePoints = GetTotalResourcePoints(workshopRef)
			float maxDamage = 0.0
			if totalResourcePoints > 0
				maxDamage = totalDamagePoints/totalResourcePoints * 100
			endif

			wsTrace("   ResolveAttack on " + workshopRef + ":	Actual max damage=" + maxDamage + "=" + totalDamagePoints + "/" + totalResourcePoints)

			;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData below (see notes on that function for explanation)

			; max damage = starting "maximum" damage inflicted by the attack
			SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageMax].resourceValue, workshopRef, maxDamage)
			; current damage starts out at the max, then goes down as repairs are made during the daily update
			SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageCurrent].resourceValue, workshopRef, maxDamage)
		else
			wsTrace("   ResolveAttack on " + workshopRef + ":	Current damage=" + currentDamage + ", ignore new damage=" + damage)
		endif

		; in any case, remove resources from container based on current damage
		if containerRef
			int stolenFood = math.ceiling(containerRef.GetItemCount(WorkshopConsumeFood) * damage * AttackDamageToTheftRatio_Food/100)
			int stolenWater = math.ceiling(containerRef.GetItemCount(WorkshopConsumeWater) * damage * AttackDamageToTheftRatio_Water/100)
			int stolenScrap = math.ceiling(containerRef.GetItemCount(WorkshopConsumeScavenge) * damage * AttackDamageToTheftRatio_Scrap/100)
			int stolenCaps = math.ceiling(containerRef.GetItemCount(Game.GetCaps()) * damage * AttackDamageToTheftRatio_Caps/100)
			
			wsTrace("   ResolveAttack on " + workshopRef + ":	Destroy stored resources: " + stolenFood + " food, " + stolenWater + " water, " + stolenScrap + " scrap, " + stolenCaps + " caps")
			containerRef.RemoveItem(WorkshopConsumeFood, stolenFood)
			containerRef.RemoveItem(WorkshopConsumeWater, stolenWater)
			containerRef.RemoveItemByComponent(WorkshopConsumeScavenge, stolenScrap)
			containerRef.RemoveItem(Game.GetCaps(), stolenCaps)
		endif
	endif

	return attackersWin
endFunction

; utility function - get current population damage
float function GetPopulationDamage(WorkshopScript workshopRef)
	; difference between base value and current value
	float populationDamage = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) - workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue)
	; add in any extra damage (recorded but not yet processed into wounded actors)
	populationDamage += workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue)

	return populationDamage
endFunction

; utility function - return total resource rating (potential), used for damage % calculation
float function GetTotalResourcePoints(WorkshopScript workshopRef)
	; total resource points = sum of all potential resource points + total population
	float totalPopulation = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) ; total population is base value
	float foodTotal = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingFood].resourceValue)
	float waterTotal = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingWater].resourceValue)
	float safetyTotal = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingSafety].resourceValue)
	float powerTotal = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPower].resourceValue)
	wstrace("GetTotalResourcePoints for " + workshopRef + ": ")
	wstrace("	" + totalPopulation + " population")
	wstrace("	" + foodTotal + " food")
	wstrace("	" + waterTotal + " water")
	wstrace("	" + safetyTotal + " safety")
	wstrace("	" + powerTotal + " power")
	return (totalPopulation + foodTotal + waterTotal + safetyTotal + powerTotal)

endFunction

; return total damage points
float function GetTotalDamagePoints(WorkshopScript workshopRef)
	; RESOURCE CHANGE: population damage is recorded in difference between base and current population value
	float populationDamage = GetPopulationDamage(workshopRef)
	float foodDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageFood].resourceValue)
	float waterDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageWater].resourceValue)
	float safetyDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageSafety].resourceValue)
	float powerDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamagePower].resourceValue)

	wstrace("GetTotalDamagePoints for " + workshopRef + ": ")
	wstrace("	" + populationDamage + " population")
	wstrace("	" + foodDamage + " food")
	wstrace("	" + waterDamage + " water")
	wstrace("	" + safetyDamage + " safety")
	wstrace("	" + powerDamage + " power")

	return (populationDamage + foodDamage + waterDamage + safetyDamage + powerDamage)
endFunction


function ProduceFood(WorkshopScript workshopref, int totalFoodToProduce)
	; WSWF - This is handled by our WorkshopProductionManager script now
	return
	;-----------------------------------------------------------------------------------------------------------------------------
	;
	;	UFO4P 2.0.1 Bug #22245:
	;	
	;	The vanilla version of this function calculated erroneous chance values, because it divided the individual resources for
	;	each food type by totalFoodToPriude, instead of by the total food resources of the workshop. While fixing this, a few
	;	minor flaws have been corrected as well:
	;
	;	!) WorkshopFoodTypes.Length should be stored in a local variable instead of evaluating it in each loop cycle
	;	2) The cumulated chance values (this is the CurrentChance variable in the vanilla script) should be calculated
	;	   once, before running the actual production loop, instead of calculating them in each loop cycle.
	;
	;	To keep this legible, the vanilla code has been removed, and the new code added below.
	;
	;-----------------------------------------------------------------------------------------------------------------------------

	if totalFoodToProduce <= 0
		return
	endif

	;UFO4P 2.0.4 Bug #23996: added the following block of code:
	;If the workshop is not player-owned (and never was before, hence checking WorkshopPlayerLostControl), there are no player-assigned food resources
	;and the production would be zero. Moreover though, the game does not calculate resource values for individual food types until a workshop is player-
	;owned: both GetValue() and GetBaseValue() return zero for all food type actor values of unowned workshops. Without the latter values, we cannot
	;calculate production chance values, and we also have no way to know which crop types exist at a workshop. The only thing we can do is to produce
	;random food items (taken from the leveled list WorkshopProduceFood).

	if workshopRef.OwnedByPlayer == false && workshopRef.GetValue(WorkshopPlayerLostControl) == 0

		wsTrace ("ProduceFood: producing " + totalFoodToProduce + " random food items for unowned workshop " + workshopRef)

		ObjectReference containerRef = workshopRef.GetContainer()
		int FoodProduced = 0
		while FoodProduced < totalFoodToProduce
			containerRef.AddItem (WorkshopProduceFood)
			foodProduced += 1
		endWhile

		wsTrace ("ProduceFood: DONE")
		return

	endif
	
	;Get the total food resource of this workshop:
	;UFO4P 2.0.2 Bug #22841: 'GetValue()' instead of 'GetBaseValue()': we only consider assigned food resources (unassigned crops do not produce anything):
	float totalFoodResources = workshopRef.GetValue(WorkshopRatings[WorkshopRatingFood].resourceValue)
	
	wsTrace ("ProduceFood for " + workshopRef + ":  Total food resources = " + totalFoodResources)

	int FoodTypeCount = WorkshopFoodTypes.Length
	float[] foodTypeChance = New float[FoodTypeCount]

	;UFO4P 2.0.2 Bug #22844: To make sure that the failsafe only selects from food types that do exist at this workshop, the indices (in the WorkshopFoodTypes array)
	;of all food types with a production chance value > 0 will be stored in this array:
	int[] FoodTypeIndex_CurrentWorkshop = New int[0]

	;UFO4P 2.0.4 Bug #23996: added this line:
	;We need to calculate the total chance value as this will not be 1 (i.e. 100%) if the total food resource value is not equal to the sum of the individual
	;food resourec values. Note that this is a result of resource damage handling: in case of damage, the total food resource value is updated immediately
	;but the individual food resource values (i.e. the food type specific values) cannot be updated if a workshop is not loaded.
	float ChanceTotal = 0
	
	int i = 0
	while i < FoodTypeCount
		ActorValue foodType = WorkshopFoodTypes[i].resourceValue
		foodTypeChance[i] = workshopRef.GetValue(foodType) / totalFoodResources
		
		;UFO4P 2.0.4 Bug #23996: added this line:
		ChanceTotal += foodTypeChance[i]
		
		;UFO4P 2.0.2 Bug #22844: added the following three lines:
		if foodTypeChance[i] > 0
			FoodTypeIndex_CurrentWorkshop.Add(i)
		endif

		wsTrace("    Food type " + i + ":  Chance = " + foodTypeChance[i])
		i += 1
	endWhile
	
	;UFO4P 2.0.4 Bug #23996: added trace:
	wsTrace("    Sum of individual chance values = " + ChanceTotal)
	
	;Calculate cumulated chance values (so we don't have to do it in every loop cycle, as tha vanilla code does):
	;After this procedure, the foodTypeChance at array position i will hold the sum of the chance values for the food types 0 to i.
	i = 1
	while i < FoodTypeCount
		foodTypeChance[i] = foodTypeChance[i] + foodTypeChance[i - 1]
		i += 1
	endWhile

	;UFO4P 2.0.2 Bug #22844: Added the following two lines:
	int FoodTypeCount_CurrentWorkshop = FoodTypeIndex_CurrentWorkshop.Length
	wsTrace ("ProduceFood for " + workshopRef + ": number of producing (assigned) food types at this workshop: " + FoodTypeCount_CurrentWorkshop)

	;UFO4P 2.0.2 Bug #22844: Added failsafe check: no food types found, no production
	if FoodTypeCount_CurrentWorkshop > 0

		wsTrace ("ProduceFood for " + workshopRef + ": Producing ... ")

		;Now to the actual production:
		ObjectReference containerRef = workshopRef.GetContainer()
		
		;UFO4P 2.0.4 Bug #23996: Added a check for FoodTypeCount_CurrentWorkshop == 1 and some code to handle this case:
		;If there is only one type of food at a workshop, trying to randomize the food production is pointless and there is no need to run the full
		;production code below (this would only return the same food item in every loop cycle). Thus, we can save a fair bit of work by simply adding
		;the required number of that food item to the workshop container.
		if FoodTypeCount_CurrentWorkshop == 1

			int foodTypeIndex = FoodTypeIndex_CurrentWorkshop[0]
			containerRef.AddItem(WorkshopFoodTypes[foodTypeIndex].foodObject, aiCount = totalFoodToProduce)
			wsTrace ("       Produced " + totalFoodToProduce + " " + WorkshopFoodTypes[foodTypeIndex].foodObject)

		else

			int foodProduced = 0
			while foodProduced < totalFoodToProduce
				;float randomRoll = Utility.RandomFloat()
				;UFO4P 2.0.4 Bug #23996 replaced the previous line with the following line:
				;In case the chance total is larger than one, we spread the range of random floats. This operation is mathematically
				;equivalent to normalizing all individual chance values to the total but saves us the time to recalculate them.
				float randomRoll = Utility.RandomFloat (0.0, ChanceTotal)
				int foodTypeIndex = -1
				i = 0
				while i < FoodTypeCount && foodTypeIndex < 0
					if randomRoll <= foodTypeChance[i]
						foodTypeIndex = i
					endif
					i += 1
				endWhile

				;UFO4P 2.0.2 Bug #22841: corrected the following trace: print 'foodProduced + 1' instead of 'i':
				wsTrace ("    Round " + (foodProduced + 1) + ": Rendom roll = " + randomRoll + "; Index = " + foodTypeIndex)

				;Failsafe: if no food was found, take a random one:
				if foodTypeIndex < 0
		
					;UFO4P 2.0.2 Bug #22514: corrected the following line: 'foodTypeCount - 1' instead of 'foodTypeCount':
					;foodTypeIndex = Utility.RandomInt(0, FoodTypeCount - 1)

					;UFO4P 2.0.2 Bug #22844: replaced the previous line with the following two lines:
					int randomFoodIndex = Utility.RandomInt(0, FoodTypeCount_CurrentWorkshop - 1)
					foodTypeIndex = FoodTypeIndex_CurrentWorkshop[randomFoodIndex]
					;This makes sure that random items are selected only from food types that do exist at the current workshop:
			
				endif

				containerRef.AddItem(WorkshopFoodTypes[foodTypeIndex].foodObject)
				wsTrace ("       Produced " + WorkshopFoodTypes[foodTypeIndex].foodObject)

				foodProduced += 1

			endWhile			
		endif
	endif

	wsTrace ("ProduceFood for " + workshopRef + ": DONE")

endFunction


float function SetRandomDamage(WorkshopScript workshopRef, ActorValue resourceValue, float baseDamage)
	; get current rating

	; always use base value = total max production (ignoring things that are out of production/wounded/etc.)
	float rating = workshopRef.GetBaseValue(resourceValue)

	; randomize baseDamage a bit
	float realDamageMult = (baseDamage + utility.RandomFloat(baseDamage/2.0 * -1, baseDamage/2.0))/100
	realDamageMult = math.min(realDamageMult, 1.0)
	realDamageMult = math.max(realDamageMult, 0.0)
	wsTrace("		SetRandomDamage for " + resourceValue + ": " + rating + " * " + realDamageMult)

	int damage = math.Ceiling(rating * realDamageMult)
	; figure out damage rating:
	actorValue damageRatingValue = GetDamageRatingValue(resourceValue)
	if damageRatingValue
		wsTrace("			setting damage " + damage + " for " + damageRatingValue)
		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
		SetResourceData_Private(damageRatingValue, workshopRef, damage)
		; adjust resource value down for this damage - except for population (since we display the base value in the interface)
		if resourceValue != WorkshopRatings[WorkshopRatingPopulation].resourceValue
			;UFO4P 2.0 Bug #21896: Call ModifyResourceData_Private instead of ModifyResourceData here (see notes on that function for explanation)
			ModifyResourceData_Private(resourceValue, workshopRef, damage*-1)
		endif
		return damage
	else
		wsTrace("		ERROR - no damage rating found for actor value " + resourceValue)
		return 0
	endif
endFunction

; return population from linked workshops
;  if bIncludeProductivityMult = true, return the population * productivityMult for each linked workshop
float function GetLinkedPopulation(WorkshopScript workshopRef, bool bIncludeProductivityMult = false)
	int workshopID = workshopRef.GetWorkshopID()
	float totalLinkedPopulation = 0

	; get all linked workshop locations
	Location[] linkedLocations = workshopRef.myLocation.GetAllLinkedLocations(WorkshopCaravanKeyword)
	int index = 0
	while (index < linkedLocations.Length)
		; NOTE: wounded caravan actors "unlink" their location, then relink it when healed (so we don't have to worry about that here)
		; get linked workshop from location
		int linkedWorkshopID = WorkshopLocations.Find(linkedLocations[index])
		;UFO4P 1.0.5 Bug #21014: '>= 0' instead of '> 0'
		if linkedWorkshopID >= 0
			; get the linked workshop
			WorkshopScript linkedWorkshop = GetWorkshop(linkedWorkshopID)
			;UFO4P: removed the following trace:
			;wsTrace(workshopRef + " found linked workshop " + linkedWorkshop)
			; for this, we will use only unwounded population
			float population = Math.max(linkedWorkshop.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) - GetPopulationDamage(workshopRef), 0.0)
			if bIncludeProductivityMult
				float productivity = linkedWorkshop.GetProductivityMultiplier(WorkshopRatings)
				;UFO4P: removed the following trace:
				;wsTrace(workshopRef + " productivity=" + productivity)
				population = population * productivity
			endif
			; add linked population to total
			totalLinkedPopulation += population
		else
			wsTrace("GetLinkedPopulation: ERROR - workshop location " + linkedLocations[index] + " not found in workshop location array", 2)
		endif
		index += 1
	endwhile

	wsTrace(workshopRef + " total linked population=" + totalLinkedPopulation)

	return totalLinkedPopulation
endFunction


function TransferResourcesFromLinkedWorkshops(WorkshopScript workshopRef, int neededFood, int neededWater)

	int workshopID = workshopRef.GetWorkshopID()
	ObjectReference containerRef = workshopRef.GetContainer()

	;--------------------------------------------------------------------------------------------------------------------------------
	;
	;	UFO4P 2.0.1 Bug #22251:
	;
	;	This function did not track the number of items transferred and instead removed the needed resources from all linked work-.
	;	shops. As a result, resources were permanently swapped forth and back without any need if there was more than one workshop
	;	with low resources within the linked network.
	;
	;	To keep this legible, the vanilla code has been commented out entriely, and the new code added below.
	;
	;--------------------------------------------------------------------------------------------------------------------------------

	wsTrace("TransferResourcesFromLinkedWorkshops: Transferring ...")

	bool UFO4P_TransferComplete = false
	
	Location[] linkedLocations = workshopRef.myLocation.GetAllLinkedLocations(WorkshopCaravanKeyword)

	int LinkedLocationCount = linkedLocations.Length
	int index = 0
	while index < LinkedLocationCount && UFO4P_TransferComplete == false
		int linkedWorkshopID = WorkshopLocations.Find(linkedLocations[index])
		if linkedWorkshopID >= 0
			WorkshopScript linkedWorkshopRef = GetWorkshop(linkedWorkshopID)
			objectReference linkedContainerRef = linkedWorkshopRef.GetContainer()
			if linkedContainerRef
				if neededFood > 0
					int availableFood_LinkedWorkshop = linkedContainerRef.GetItemCount(WorkshopConsumeFood)
					if availableFood_LinkedWorkshop > 0
						int FoodToRemove = Math.Min (availableFood_LinkedWorkshop, neededFood) as int
						linkedContainerRef.RemoveItem(WorkshopConsumeFood, FoodToRemove, true, containerRef)
						neededFood -= FoodToRemove
						wsTrace("   Transferred " + FoodToRemove + " food from linked workshop " + linkedWorkshopRef + " to " + workshopRef)
						wsTrace("      Remaining food to transfer = " + neededFood)
					endif
				endif
				if neededWater > 0
					int availableWater_LinkedWorkshop = linkedContainerRef.GetItemCount(WorkshopConsumeWater)
					if availableWater_LinkedWorkshop > 0
						int WaterToRemove = Math.Min (availableWater_LinkedWorkshop, neededWater) as int
						linkedContainerRef.RemoveItem(WorkshopConsumeWater, WaterToRemove, true, containerRef)
						neededWater -= WaterToRemove
						wsTrace("   Transferred " + WaterToRemove + " water from linked workshop " + linkedWorkshopRef + " to " + workshopRef)
						wsTrace("      Remaining water to transfer = " + neededWater)
					endif
				endif
			endif
		else
			wsTrace("TransferResourcesFromLinkedWorkshops: ERROR - workshop location " + linkedLocations[index] + " not found in workshop location array", 2)
		endif

		if (neededFood <= 0) && (neededWater <= 0)
			UFO4P_TransferComplete = true
		endif
		index += 1
	endWhile

endFunction

; called by ResetWorkshop
; also called when activating workshop
function SetCurrentWorkshop(WorkshopScript workshopRef)

	CurrentWorkshop.ForceRefTo(workshopRef)
	currentWorkshopID = workshopRef.GetWorkshopID()
	WorkshopCurrentWorkshopID.SetValue(currentWorkshopID)

	;UFO4P 2.0.4 Bug #24122: added trace:
	wsTrace("---------------------------------------------------------------------------------")
	wsTrace ("	SetCurrentWorkshop: new value = " + currentWorkshopID)
	wsTrace("---------------------------------------------------------------------------------")	

endFunction


; clear and recalculate workshop ratings
function ResetWorkshop(WorkshopScript workshopRef)

	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" RESET WORKSHOP", bNormalTraceAlso = true)
	wsTrace("    Begin reset for " + workshopRef)
	wsTrace("------------------------------------------------------------------------------ ")

	;/
	GetEditLock()

	;UFO4P 2.0 Bug #21895: clear UFO4P_WorkshopRef_ResetDelayed and reset the attack bool:
	;In case a reset was delayed because there was an attack running at this location, there will also be daily updates pending (they are delayed as lomg
	;as UFO4P_AttackRunning is 'true'). Resetting this bool to 'false' within this function makes sure that the delayed reset gets priority over pending
	;daily updates. If there was no reset delayed, this bool should be 'false' anyway.
	UFO4P_WorkshopRef_ResetDelayed = none
	UFO4P_AttackRunning = false
	
	wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))

;	Debug.StartStackProfiling()

	; set current workshopID to this workshop
	int workshopID = workshopRef.GetWorkshopID()

	; set current workshopID to this workshop (can be reset when player interacts with a workshop)
	;UFO4P 2.0.2 Bug #23016: removed the following line: This is now called by the OnLocationChange event as soon as the player arrives at a workshop.
	;SetCurrentWorkshop(workshopref)

	; clear parent alias collections
	WorkshopNewSettler.Clear()
	WorkshopSpokesmanAfterRaiderAttack.Clear()

	; get resources and actors
	; NOTE: this HAS to be done after the aliases are cleared - otherwise things flagged for deletion will still be persisting and we'll still find them
	ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
	ObjectReference[] ResourceObjectsDamaged = GetResourceObjects(workshopRef, NONE, 1)
	ObjectReference[] ResourceObjectsUndamaged = GetResourceObjects(workshopRef, NONE, 2)

	; if automatic ownership turned on, clear the location if there aren't any live bosses - this will allow the player to "own" the workshop by activating it
	if workshopRef.EnableAutomaticPlayerOwnership && !workshopRef.OwnedByPlayer
		int bossIndex = 0
		int bossCount = 0
		while bossIndex < BossLocRefTypeList.GetSize()
			LocationRefType bossRefType = BossLocRefTypeList.GetAt(bossIndex) as LocationRefType
			bossCount += WorkshopLocations[workshopID].GetRefTypeAliveCount(bossRefType)
			bossIndex += 1
		endWhile

		wsTrace("	ResetWorkshop: " + workshopRef + " Checking for automatic player ownership... bossCount=" + bossCount)
		if bossCount == 0
			wsTrace("	ResetWorkshop: " + workshopRef + " 	Clearing location " + WorkshopLocations[workshopID])
			WorkshopLocations[workshopID].SetCleared(true)
		endif
	endif

	; make sure to clear FarmDiscountFaction from NPCs in unowned farm
	bool bFirstResetAfterLostControl = false
	if !workshopRef.OwnedByPlayer && workshopRef.GetValue(WorkshopPlayerLostControl) == 1
		workshopRef.SetValue(WorkshopPlayerLostControl, 2)
		bFirstResetAfterLostControl = true
	endif

	; DAMAGE - how many NPCs/objects to damage?
	; get current damage rating - so we can damage/wound things as they come in
	float currentDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageCurrent].resourceValue)/100
	wsTrace("	ResetWorkshop: " + workshopRef + "   Current damage %=" + currentDamage)
	; get current food & water ratings (before we clear them) - use this to damage resource objects as they come in
	float foodToDamage = math.Ceiling(workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageFood].resourceValue))
	float waterToDamage = math.Ceiling(workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageWater].resourceValue))
	float safetyToDamage = math.Ceiling(workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageSafety].resourceValue))
	float powerToDamage = math.Ceiling(workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamagePower].resourceValue))
	; RESOURCE CHANGE: population damage rating is now EXTRA population damage, on top of difference between base and current population rating
	;  -- used to track damage to population when location isn't loaded
	float populationDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue) + workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue) - workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue)
	int populationToDamage = math.Ceiling(populationDamage)
	
	wsTrace("	ResetWorkshop: " + workshopRef + "   food to damage=" + foodToDamage)
	wsTrace("	ResetWorkshop: " + workshopRef + "   water to damage=" + waterToDamage)
	wsTrace("	ResetWorkshop: " + workshopRef + "   safety to damage=" + safetyToDamage)
	wsTrace("	ResetWorkshop: " + workshopRef + "   power to damage=" + powerToDamage)
	wsTrace("	ResetWorkshop: " + workshopRef + "   population to damage=" + populationToDamage)

	; recalculate workshop ratings for this workbench
	workshopRef.RecalculateWorkshopResources(false)

	; get center marker
	WorkshopCenterMarker.ForceRefTo(workshopRef.GetLinkedRef(WorkshopLinkCenter))
	
	; add the actors
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ResetWorkshop: " + workshopRef + "  ACTORS: " + WorkshopActors.length + " in area", bNormalTraceAlso = true)

	; first pass - check for already wounded actors
	int i = 0
	while i < WorkshopActors.length
		WorkshopNPCScript actorRef = WorkshopActors[i] as WorkshopNPCScript
		if actorRef && (actorRef.GetWorkshopID() == workshopID || actorRef.GetWorkshopID() < 0)

			wsTrace("	------------------------------------------------------------------------------ ")
			wsTrace("	" + i + ": " + actorRef, bNormalTraceAlso = true)
			wsTrace("	------------------------------------------------------------------------------ ")

			if actorRef.IsDead()
				; failsafe - remove them
				;UFO4P 2.0 Bug #21900: Call UnassignActor_Private instead of UnassignActor here (see notes on that function for explanation)
				UnassignActor_Private(actorRef, bRemoveFromWorkshop = true, bSendUnassignEvent = false)
			else
				; on first reset after losing control, clear discount factions from NPCs
				if bFirstResetAfterLostControl
					actorRef.RemoveFromFaction(FarmDiscountFaction)
				endif

				; make sure actor value ownership is set
				actorRef.UpdatePlayerOwnership(workshopRef)			

				; clear any remaining assignment actor values
				actorRef.StartAssignmentTimer(false)

				if workshopRef.DaysSinceLastVisit > 3
					; clear Minutemen radiant quest factions from NPCs
					actorRef.RemoveFromFaction(MinRadiantDialogueThankful)
					actorRef.RemoveFromFaction(MinRadiantDialogueDisappointed)
					actorRef.RemoveFromFaction(MinRadiantDialogueFailure)
				endif

				if actorRef.IsWounded() && actorRef.IsDead() == false
					wsTrace("	ResetWorkshop: " + workshopRef + "   found WOUNDED actor " + actorRef)
					; make sure not a caravan actor - if so, don't add to unassigned actors list
					if CaravanActorAliases.Find(actorRef) < 0
						AddActorToWorkshop(actorRef, workshopRef, true, WorkshopActors)
						; set reset flag
						actorRef.bResetDone = true
						if populationToDamage > 0
							populationToDamage += -1
						else
							; heal me
							wsTrace("	ResetWorkshop: " + workshopRef + "   HEALING actor " + actorRef)
							actorRef.SetWounded(false)
						endif
					else
						wsTrace("	ResetWorkshop: " + workshopRef + "     assigned to caravan - ignore")
					endif
				endif
			endif
		endif
		i += 1
	endWhile

	; second pass - remaining actors
	i = 0
	while i < WorkshopActors.length
		WorkshopNPCScript actorRef = WorkshopActors[i] as WorkshopNPCScript
		if actorRef && actorRef.IsDead() == false && (actorRef.GetWorkshopID() == workshopID || actorRef.GetWorkshopID() < 0) && actorRef.bResetDone == false
			wsTrace("	ResetWorkshop: " + workshopRef + "   found actor " + actorRef)
			; make sure not a caravan actor - if so, don't add to unassigned actors list
			if CaravanActorAliases.Find(actorRef) < 0
				AddActorToWorkshop(actorRef, workshopRef, true, WorkshopActors)
				; DAMAGE - clear "wounded value"
				actorRef.SetWounded(false)
				if populationToDamage > 0
					wsTrace("	ResetWorkshop: " + workshopRef + "   WOUNDING actor " + actorRef)
					actorRef.SetWounded(true)
					populationToDamage += -1
				endif
			else
				wsTrace("	ResetWorkshop: " + workshopRef + "     assigned to caravan - ignore")
			endif
		endif
		;UFO4P 2.0.3 Bug #23271: added sanity check:
		if actorRef
			; clear reset flag on all actors as we go
			actorRef.bResetDone = false
		endif
		i += 1
	endWhile

	;UFO4P 1.0.5 Bug #21039: Get bool from workshop, for faster access:
	bool bCleanupDamageHelpers_WorkObjects = workshopRef.UFO4P_CleanupDamageHelpers_WorkObjects

	; clear damaged population rating - it should have all been resolved now
	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
	SetResourceData_Private(WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue, workshopRef, 0)

	wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))

	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ResetWorkshop: " + workshopRef + "  RESOURCE OBJECTS: " + (ResourceObjectsDamaged.length + ResourceObjectsUndamaged.length) + " in area", bNormalTraceAlso = true)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	Check damaged objects:" + ResourceObjectsDamaged.length)
	; FIRST - loop through looking for objects already flagged as damage - decrement damage totals from them first (so we don't change which objects are damaged if when you leave and return)
	i = 0
	while i < ResourceObjectsDamaged.length
		WorkshopObjectScript resourceRef = ResourceObjectsDamaged[i] as WorkshopObjectScript
		if resourceRef
			;UFO4P: removed the following trace:
			;wsTrace("	" + i + ": " + resourceRef)
			if resourceRef.workshopID == -1
				; no workshop assigned = initially placed item (not player-created)
				; so assign this to the current workshop
				resourceRef.workshopID = workshopID
				; initialize any scripted creation stuff
				resourceRef.HandleCreation(false)
			endif
				
			; if damaged, apply damage
			wsTrace("	------------------------------------------------------------------------------ ")
			;UFO4P: Modified traces to print the base object ID (instead of a useless FFxxxxxx reference only)
			wsTrace("	" + i + ": Resource type: " + ResourceObjectsDamaged[i].GetBaseObject(), bNormalTraceAlso = true)
			wsTrace("	Resource ref=" + resourceRef + ", owner=" + resourceRef.GetAssignedActor() + " damaged? " + resourceRef.HasResourceDamage(), bNormalTraceAlso = true)
			wsTrace("	------------------------------------------------------------------------------ ")

			; damaged - what kind of resource(s) does this produce?
			foodToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingFood].resourceValue, foodToDamage)
			waterToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingWater].resourceValue, waterToDamage)
			safetyToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingSafety].resourceValue, safetyToDamage)
			powerToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingPower].resourceValue, powerToDamage)

			; flag this object as "done" so we ignore it on next pass
			resourceRef.bResetDone = true
			AssignObjectToWorkshop(resourceRef, workshopRef, true)

			; any reset stuff the object needs to do
			resourceRef.HandleWorkshopReset()

			;UFO4P 1.0.5 Bug #21039: if damage helpers need to be cleaned up at this workshop and resourceRef is a crop, do this now:
			if bCleanupDamageHelpers_WorkObjects && resourceRef.GetBaseObject() as Flora
				;resourceRef.UFO4P_CleanupDamageHelpersAtWorkObject(UFO4P_WorkshopFloraDamageHelpers)
				;UFO4P 2.0 Bug #21894: Removed the previous line. With this fix in place, the UFO4P_CleanupDamageHelpersAtWorkObject became obsolete and was removed.
				;To perform a cleanup, the UFO4P_ValidateDamageHelperRef function is now called instead:
				resourceRef.UFO4P_ValidateDamageHelperRef()
			endif

		endif
		i += 1
	endWhile


	; now we do another pass, looking at the rest of the objects in the list
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	Check undamaged objects: " + ResourceObjectsUndamaged.Length)
	i = 0
	while i < ResourceObjectsUndamaged.length
		WorkshopObjectScript resourceRef = ResourceObjectsUndamaged[i] as WorkshopObjectScript
		if resourceRef
			if resourceRef.workshopID == -1
				; no workshop assigned = initially placed item (not player-created)
				; so assign this to the current workshop
				resourceRef.workshopID = workshopID
				; initialize any scripted creation stuff
				resourceRef.HandleCreation(false)
			endif
				

			wsTrace("	------------------------------------------------------------------------------ ")
			;UFO4P: Modified traces to print the base object ID (instead of a useless FFxxxxxx reference only)
			wsTrace("	" + i + ": Resource type: " + ResourceObjectsUndamaged[i].GetBaseObject(), bNormalTraceAlso = true)
			wsTrace("	Resource ref=" + resourceRef + ", owner=" + resourceRef.GetAssignedActor() + " damaged? " + resourceRef.HasResourceDamage(), bNormalTraceAlso = true)
			wsTrace("	------------------------------------------------------------------------------ ")

			; before assigning, see if should damage
			foodToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingFood].resourceValue, foodToDamage)
			waterToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingWater].resourceValue, waterToDamage)
			safetyToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingSafety].resourceValue, safetyToDamage)
			powerToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingPower].resourceValue, powerToDamage)

			AssignObjectToWorkshop(resourceRef, workshopRef, true)

			; any reset stuff the object needs to do
			resourceRef.HandleWorkshopReset()

			;UFO4P 1.0.5 Bug #21039: if damage helpers need to be cleaned up at this workshop and resourceRef is a crop, do this now:
			if bCleanupDamageHelpers_WorkObjects && resourceRef.GetBaseObject() as Flora
				;resourceRef.UFO4P_CleanupDamageHelpersAtWorkObject(UFO4P_WorkshopFloraDamageHelpers)
				;UFO4P 2.0 Bug #21894: Removed the previous line. With this fix in place, the UFO4P_CleanupDamageHelpersAtWorkObject became obsolete and was removed.
				;To perform a cleanup, the UFO4P_ValidateDamageHelperRef function is now called instead:
				resourceRef.UFO4P_ValidateDamageHelperRef()
			endif

			; clear the object's reset flag since we don't have any more passes
			resourceRef.bResetDone = false
		endif
		i += 1
	endWhile

	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData below (see notes on that function for explanation)

	wstrace("	Damage pass done: foodToDamage=" + foodToDamage + ", waterToDamage=" + waterToDamage + ", safetyToDamage=" + safetyToDamage + ", powerToDamage=" + powerToDamage)
	; remaining damage is invalid - clear it
;	if foodToDamage > 0
		wstrace("		Removing " + foodToDamage + " extraneous food damage")
		SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageFood].resourceValue, workshopRef, 0)
;	endif
;	if waterToDamage > 0
		wstrace("		Removing " + waterToDamage + " extraneous water damage")
		SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageWater].resourceValue, workshopRef, 0)
;	endif
;	if safetyToDamage > 0
		wstrace("		Removing " + safetyToDamage + " extraneous safety damage")
		SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageSafety].resourceValue, workshopRef, 0)
;	endif
;	if powerToDamage > 0
		wstrace("		Removing " + powerToDamage + " extraneous power damage")
		SetResourceData_Private(WorkshopRatings[WorkshopRatingDamagePower].resourceValue, workshopRef, 0)
;	endif

	;UFO4P 2.0.2 Bug #23016: 
	;Skip the following operations if the workshop location has unloaded in the meantime. All other operations in this function are safe because it runs on
	;workshop resource object arrays that have been filled right at the start (i.e. when the location was still loaded). The functions called hereinafter
	;however fill new WorkshopActor arrays when they start running, and if the workshop has unloaded, those arrays will be empty.
	;UFO4P 2.0.4 Bug #24122:
	;Removed this check because all of these functions now check individually whether the workshop is still loaded.
	;if UFO4P_IsWorkshopLoaded (workshopRef)
	; assign beds, farms, safety objects
	TryToAssignBeds(workshopRef)
	TryToAssignResourceType(workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
	TryToAssignResourceType(workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
	; reset unassigned population count
	SetUnassignedPopulationRating (workshopRef)
	;else
	;	wstrace(" ResetWorkshop: Workshop has unloaded. Skipping bed and food/safety resource object assignment.")
	;endif

	; set "visited" flag
	workshopRef.PlayerHasVisited = true

	;UFO4P 2.0.2: removed the following trace: no need to log this twice (it's also logged in line 3898 below and won't change in the meantime)
	;wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))

	; check for new settlers
	CurrentNewSettlerCount = 0
	if WorkshopActors.Length > 0
		i = 0
		while i <  WorkshopActors.Length
			workshopNPCScript theActor = WorkshopActors[i] as workshopNPCScript
			if theActor && theActor.bIsWorker == false && theActor.bNewSettler == true
				; put first into the new settler alias so he'll forcegreet
				if CurrentNewSettlerCount == 0
					WorkshopNewSettler.ForceRefTo(theActor)
				endif
				if i >= MaxNewSettlerCount
					theActor.bNewSettler = false
					theActor.EvaluatePackage()
				endif
				CurrentNewSettlerCount += 1
			endif
			i += 1
		endWhile
	endif

	wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))

	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" RESET WORKSHOP for " + workshopRef + "   - DONE", bNormalTraceAlso = true)
	wsTrace("------------------------------------------------------------------------------ ")

	;UFO4P 1.0.5 Bug #21039: If damage helpers had to be cleaned up for the crops at this workshop, this will have been done now. Thus set the respective
	;bool on WorkshopScript to 'false':
	if bCleanupDamageHelpers_WorkObjects
		workshopRef.UFO4P_CleanupDamageHelpers_WorkObjects = false
	endIf

	EditLock = false
;	Debug.StopStackProfiling()

	-----------------------------------------------------------------------------------------------------------------------------------------

		UFO4P 2.0.4 Bug #24312:
		To optimize performance, this function has been completely rewritten. The modifications are summarized below.

		1. Loops through the actor arrays:
		----------------------------------
		The vanilla code was running three loops through the actor array:
		- Loop1 only handled wounded actors
		- Loop2 handled the remaining actors
		- Loop3 checked for new actors
		
		- Loop1 has been modified to run all operations that need to be done on all actors (such as calling AddActorToWorkshop). It also
		  still includes the special handling of wounded actors from loop1 of the vanilla script.
		- Loop2 has been modified to only handle the wounding of as yet unwounded actors. This only needs to run if there's a population
		  damage to apply, so a bool has been added to skip that loop if appropriate (which applies to > 95% of the cases where this
		  function runs!).
		- Loop3 has been removed and the check for new actors added to Loop1 instead.
		
		Thus, we're running only one loop most of the time now instead of three. This saves a fair bit of performance. In addition, loop1
		does not only unassign dead actors from the workshop now, but also removes them from the array. It can then pass the array to the
		SetUnassignedPopulationRating function which it calls at the end. This saves that function the time to create a new actor array.
		
		2. Loops through the resource object arrays:
		--------------------------------------------
		Some modifications were made to the damage passes that are called by these loops on all resource objects. If there's no damage
		left to apply after the first loop has run, the damage passes in the second loop can be skipped entirely. For that purpose,
		another bool has been added.
		
		3. Resource assignment procedures:
		----------------------------------
		The most substantial modifications were made to the resource assignment functions TryToAssignBeds and tryToAssignResourceType 
		which are called once by this function when it has finished looping through the resource object arrays. While the workshop is
		loaded, those functions are subsequently called in regular intervals from WorkhopScript (they run very often !).
		
		To get the assignment done, the vanilla functions did first loop through the actor array to identify the actors to assign to
		the respective resource type (i.e. beds, food objects or safety objects). Subsequently, they did create an array of those ob-
		jects and looped through it to identify those that were unassigned. If the function was called again, the whole procedure was
		repeated. Since most of the objects in the resource object arrays are already assigned or cannot be assigned at all (the safety
		objects array also contains all of the turrets) the vanilla functions spent most of their time with filtering out invalid ob-
		jects, and this time was wasted again every time one of the functions was called.
		
		To improve this, the actors to assign to the individual resource types and all unassigned objects are now stored in arrays,
		and the assignment functions do operate on these arrays now. Since they usually have only a tenth or less of the size of the
		full object arrays, they are much faster to process and assignment of beds, food and safety objects can be accomplished in
		less than a second, even on large workshops where the vanilla functions could easily run 10 seconds or longer to get the job
		done.

		The helper arrays created for this purpose are declared in a section that has been added at the end of this script. That
		section also includes a number of helper functions to handle them. These arrays are initialized by the OnLocationChange
		event before this function is called, and they are cleared again when the workshop unloads. This does not only avoid per-
		sistence but also keeps the volume of additional data that may be stored in a save game as low as possible. Though, even
		if the arrays are filled (i.e while the workshop is loaded), they rarely contain more than 1-2 items.

		To make this system work, the arrays need to be kept updated while the workshop is loaded: assigned actors and objects have to be
		removed (this is handled by the functions TryToAssignBeds and TryToAssignResourceType) and new objects (either built by the player
		or unassigned from other actors) and actors (either newly created or after having been assigned by the player) have to be added.
		This required additional minor modifications to the functions AddActorToWorkshop, AssignActorToObject, AssignObjectToWorkshop,
		UnassignActor_Private and UnassignObject. In this process, most of these functions have been rewritten too, and a number of minor
		bugs that were discovered while doing this have been fixed as well.

		Finally, a number of frequently used helper functions such as ActorOwnsBed() and IsObjectOwner() could be substantially simplified,
		so they are running now much faster too.

	-----------------------------------------------------------------------------------------------------------------------------------------
	/;

	;UFO4P 2.0.4 Bug #24411:
	;Before anything else, check whether the passed in workshop is still the current workshop. If the player quickly fast ravels between
	;workshops and/or other locations, there may be reset calls piling up in a queue, and if they eventually start to get processed, the
	;passed in workshop may not be the player's current location. In that case, the reset has to be be skipped as it should not run on
	;unloaded workshops. While this function is running, this check is repeated in regular intervals (after each code block and in every
	;loop cycle while processing the resource objects array), to bail out if the player left the area.
	
	int workshopID = workshopRef.GetWorkshopID()

	if workshopID != currentWorkshopID
		wsTrace("	ResetWorkshop: workshop " + workshopRef + " is not the current workshop. Returning ... ")
		return
	endif

	
	GetEditLock()

	UFO4P_WorkshopRef_ResetDelayed = none
	UFO4P_AttackRunning = false
	UFO4P_ClearBedArrays = false

	wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))
	
	WorkshopNewSettler.Clear()
	WorkshopSpokesmanAfterRaiderAttack.Clear()

	CurrentNewSettlerCount = 0

	ObjectReference[] WorkshopActors = GetWorkshopActors(workshopRef)
	ObjectReference[] ResourceObjectsDamaged = GetResourceObjects(workshopRef, NONE, 1)
	ObjectReference[] ResourceObjectsUndamaged = GetResourceObjects(workshopRef, NONE, 2)

	if workshopRef.EnableAutomaticPlayerOwnership && !workshopRef.OwnedByPlayer
		int bossIndex = 0
		int bossCount = 0
		while bossIndex < BossLocRefTypeList.GetSize()
			LocationRefType bossRefType = BossLocRefTypeList.GetAt(bossIndex) as LocationRefType
			bossCount += WorkshopLocations[workshopID].GetRefTypeAliveCount(bossRefType)
			bossIndex += 1
		endWhile

		wsTrace("	ResetWorkshop: " + workshopRef + " Checking for automatic player ownership ... bossCount = " + bossCount)
		if bossCount == 0
			wsTrace("	ResetWorkshop: " + workshopRef + " 	Clearing location " + WorkshopLocations[workshopID])
			WorkshopLocations[workshopID].SetCleared(true)
		endif
	endif

	bool bFirstResetAfterLostControl = false
	if !workshopRef.OwnedByPlayer && workshopRef.GetValue(WorkshopPlayerLostControl) == 1
		workshopRef.SetValue(WorkshopPlayerLostControl, 2)
		bFirstResetAfterLostControl = true
	endif

	float currentDamage = workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamageCurrent].resourceValue) / 100
	wsTrace("	ResetWorkshop: " + workshopRef + "   Current damage % = " + currentDamage * 100)
	float foodToDamage = math.Ceiling (workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamageFood].resourceValue))
	float waterToDamage = math.Ceiling (workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamageWater].resourceValue))
	float safetyToDamage = math.Ceiling (workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamageSafety].resourceValue))
	float powerToDamage = math.Ceiling (workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamagePower].resourceValue))
	int populationToDamage = math.Ceiling (workshopRef.GetValue (WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue)) as int

	wsTrace("	 Food to damage = " + foodToDamage)
	wsTrace("	 Water to damage = " + waterToDamage)
	wsTrace("	 Safety to damage = " + safetyToDamage)
	wsTrace("	 Power to damage = " + powerToDamage)
	wsTrace("	 Population to damage = " + populationToDamage)
	
	;If false, we can skip the second loop through the actor array.
	;Getting this here because the damage value will be counted down, so we can't check it later on.
	bool UFO4P_ApplyPopulationDamage = (populationToDamage > 0)

	workshopRef.RecalculateWorkshopResources(false)
	WorkshopCenterMarker.ForceRefTo(workshopRef.GetLinkedRef(WorkshopLinkCenter))

	;ADD THE ACTORS:
	int maxIndex = WorkshopActors.length
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ResetWorkshop: " + workshopRef + "  ACTORS: " + maxIndex + " in area", bNormalTraceAlso = true)

	int i = 0
	while i < maxIndex
		WorkshopNPCScript actorRef = WorkshopActors[i] as WorkshopNPCScript
		if actorRef && (actorRef.GetWorkshopID() == workshopID || actorRef.GetWorkshopID() < 0)

			wsTrace("   ------------------------------------------------------------------------------ ")
			wsTrace("    " + i + ": " + actorRef, bNormalTraceAlso = true)
			wsTrace("   ------------------------------------------------------------------------------ ")

			if actorRef.IsDead()
				UnassignActor_Private(actorRef, bRemoveFromWorkshop = true, bSendUnassignEvent = false, bResetMode = true)
				;UFO4P 2.0.4 Bug #24274: Removing dead actors from the array, because this function does now pass the actor
				;array when it calls SetUnassignedPopulationRating at the end. That function will calculate wrong results
				;if the array contains actors that are no longer assigned to the workshop.
				;Note: This also saves time, since we don't need to handle them again if we run a second loop, and it also
				;makes the check for dead actors in the second loop superfluous.
				WorkshopActors.Remove(i)
				maxIndex -= 1
				;Also need to update the loop index variable: with an actor removed, we need to check the same position again:
				i -= 1
			else
				if bFirstResetAfterLostControl
					actorRef.RemoveFromFaction (FarmDiscountFaction)
				endif

				actorRef.UpdatePlayerOwnership(workshopRef)			
				actorRef.StartAssignmentTimer(false)

				if workshopRef.DaysSinceLastVisit > 3
					actorRef.RemoveFromFaction(MinRadiantDialogueThankful)
					actorRef.RemoveFromFaction(MinRadiantDialogueDisappointed)
					actorRef.RemoveFromFaction(MinRadiantDialogueFailure)
				endif

				;As we go, fill all actors that are not robots in the UFO4P_ActorsWithoutBeds array. When we're done with the loops through
				;the actor array, we'll run a single loop through the beds array to remove all actors that are registered as bed owners. This
				;makes sure that this array is up to date when we start adding the work objects.
				if actorRef.GetBaseValue (WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue) == 0
					UFO4P_ActorsWithoutBeds.Add (actorRef)
				endif

				if CaravanActorAliases.Find(actorRef) < 0
					AddActorToWorkshop (actorRef, workshopRef, true, WorkshopActors)
					if actorRef.IsWounded()
						wsTrace("   " + actorRef + " is WOUNDED")
						if populationToDamage > 0
							populationToDamage -= 1
						else
							wsTrace("	HEALING actor " + actorRef)
							actorRef.SetWounded (false)
						endif
						;If no damage had to be applied to the population, there will be no second pass, so we don't need to set this flag
						if UFO4P_ApplyPopulationDamage
							actorRef.bResetDone = true
						endif
					endif
				else
					wsTrace("   " + actorRef + " assigned to caravan - ignore")
				endif

				;Moved this block in here from an extra loop at the end of the vanilla ResetWorkshop function:
				if actorRef.bNewSettler == true && actorRef.bIsWorker == false
					if CurrentNewSettlerCount == 0
						WorkshopNewSettler.ForceRefTo (actorRef)
					else
						actorRef.bNewSettler = false
						actorRef.EvaluatePackage()
					endif
					CurrentNewSettlerCount += 1
				endif

			endif
		
		;No actorRef (e.g. actors without WorkshopNPCScript) or actor is assigned to a different workshop -> remove from array
		else
			WorkshopActors.Remove(i)
			maxIndex -= 1
			i -= 1
		endif

		i += 1

	endWhile

	;No need to run this if no damage had to be applied to the population
	if UFO4P_ApplyPopulationDamage && workshopID == currentWorkshopID
	
		if PopulationToDamage > 0
			wsTrace("   ------------------------------------------------------------------------------ ")
			wsTrace("    Remaining damage to apply to population = " + PopulationToDamage)
			wsTrace("   ------------------------------------------------------------------------------ ")
		endif

		i = 0
		while i < maxIndex
			WorkshopNPCScript actorRef = WorkshopActors[i] as WorkshopNPCScript
			if actorRef
				;Note: saving a few checks here: (1) no need to check for dead actors because the first loop has removed them from the
				;array; (2) no need to run checks on the workshopID because AddActorToWorkshop did update it already.
				if PopulationToDamage > 0 && actorRef.bResetDone == false && CaravanActorAliases.Find (actorRef) < 0
					wsTrace("	WOUNDING actor " + actorRef)
					actorRef.SetWounded (true)
					populationToDamage -= 1
				endif
				actorRef.bResetDone = false
			endif
			i += 1
		endWhile

	endif

	if workshopID != currentWorkshopID
		UFO4P_StopWorkshopReset()
		EditLock = false
		return
	endif

	SetResourceData_Private (WorkshopRatings[WorkshopRatingDamagePopulation].resourceValue, workshopRef, 0)

	;Now run this function to make sure that the UFO4P_ActorsWithoutBeds array is up to date before we start adding the work objects.
	UFO4P_UpdateActorsWithoutBedsArray (workshopRef)

	;Get this once from the workshop, for faster access:
	bool bCleanupDamageHelpers_WorkObjects = workshopRef.UFO4P_CleanupDamageHelpers_WorkObjects

	;ADD THE WORK OBJECTS:
	maxIndex = ResourceObjectsDamaged.length
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ResetWorkshop: " + workshopRef + "  RESOURCE OBJECTS: " + (maxIndex + ResourceObjectsUndamaged.length) + " in area", bNormalTraceAlso = true)
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	Check " + maxIndex + " damaged objects:")

	i = 0
	while i < maxIndex && workshopID == currentWorkshopID
		WorkshopObjectScript resourceRef = ResourceObjectsDamaged[i] as WorkshopObjectScript
		if resourceRef

			;pre-placed objects:
			if resourceRef.workshopID == -1
				resourceRef.workshopID = workshopID
				resourceRef.HandleCreation (false)
			endif

			wsTrace("	------------------------------------------------------------------------------ ")
			wsTrace("	" + i + ": Resource type: " + ResourceObjectsDamaged[i].GetBaseObject(), bNormalTraceAlso = true)
			wsTrace("	Resource ref = " + resourceRef + ", owner = " + resourceRef.GetAssignedActor() + " damaged ? " + resourceRef.HasResourceDamage(), bNormalTraceAlso = true)
			wsTrace("	------------------------------------------------------------------------------ ")

			;Still faster to check whether resourceRef has a resource type that matches the resource damage instead of running all
			;four damage passes on every object (three of these calls were always superfluous, because an object can only have one
			;of these resource types). To save as many checks as possible, we perform the checks in the order of decreasing abundance
			;of the respective object types:		
			if resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingFood].resourceValue)
				foodToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingFood].resourceValue, foodToDamage)
			elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingSafety].resourceValue)
				safetyToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingSafety].resourceValue, safetyToDamage)
			elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingWater].resourceValue)
				waterToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingWater].resourceValue, waterToDamage)
			elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingPower].resourceValue)
				powerToDamage = UpdateResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingPower].resourceValue, powerToDamage)
			
			;if we got no mtach, the object is not a food, water, safety or power object. If it also does not have the WorkshopWork
			;Object keyword (i.e. does not requires an actor, so is no vendor stand or a scavenging station either) or is a bed, the
			;scripts will never repair it and the player cannot repair it either, so it should not be damaged at all (logging has shown
			;that damaged beds may pile up at workshops over time). In that case, repair it (otherwise, it does waste resources because
			;all damage passes will run on it again on every workshop reset).
			elseif resourceRef.HasKeyword (WorkshopWorkObject) == false || resourceRef.IsBed()
				;calling Repair() here instead of RecalculateResourceDamage() since the object does obviously not contribute to the
				;resources that require separate handling
				wsTrace("	Repairing " + resourceRef)
				resourceRef.Repair()
				;also remove visible signs of destruction, if any:
				resourceRef.ClearDestruction()
			endif
			
			AssignObjectToWorkshop (resourceRef, workshopRef, true)
			resourceRef.HandleWorkshopReset()

			if bCleanupDamageHelpers_WorkObjects && resourceRef.GetBaseObject() as Flora
				resourceRef.UFO4P_ValidateDamageHelperRef()
			endif

		endif
		i += 1
	endWhile

	if workshopID != currentWorkshopID
		UFO4P_StopWorkshopReset()
		EditLock = false
		return
	endif

	;If this is false, we can skip the damage pass on all undamaged objects entirely:
	;Getting this here because the value may change while looping through the damaged objects.
	bool UFO4P_ApplyDamageToResourceObjects = (foodToDamage + waterToDamage + safetyToDamage + powerToDamage > 0)
	
	; now we do another pass, looking at the rest of the objects in the list
	maxIndex = ResourceObjectsUndamaged.Length
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	Check " + maxIndex + " undamaged objects: ")

	i = 0
	while i < maxIndex && workshopID == currentWorkshopID
		WorkshopObjectScript resourceRef = ResourceObjectsUndamaged[i] as WorkshopObjectScript
		if resourceRef

			;pre-placed objects
			if resourceRef.workshopID == -1
				resourceRef.workshopID = workshopID
				resourceRef.HandleCreation (false)
			endif

			wsTrace("	------------------------------------------------------------------------------ ")
			wsTrace("	" + i + ": Resource type: " + ResourceObjectsUndamaged[i].GetBaseObject(), bNormalTraceAlso = true)
			wsTrace("	Resource ref = " + resourceRef + ", owner = " + resourceRef.GetAssignedActor() + " damaged ? " + resourceRef.HasResourceDamage(), bNormalTraceAlso = true)
			wsTrace("	------------------------------------------------------------------------------ ")

			;No need to run this if there's no damage to apply:
			if UFO4P_ApplyDamageToResourceObjects
				;Still faster to check whether resourceRef has a resource type that matches the resource damage instead of running all
				;four damage passes on every object (three of these calls were always superfluous, because an object can only have one
				;of these resource type). To save as many checks as possible, we perform the checks in the order of decreasing abundance
				;of the respective object types:
				if resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingFood].resourceValue)
					foodToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingFood].resourceValue, foodToDamage)
				elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingSafety].resourceValue)
					safetyToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingSafety].resourceValue, safetyToDamage)
				elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingWater].resourceValue)
					waterToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingWater].resourceValue, waterToDamage)
				elseif resourceRef.HasResourceValue (WorkshopRatings[WorkshopRatingPower].resourceValue)
					powerToDamage = ApplyResourceDamage(resourceRef, WorkshopRatings[WorkshopRatingPower].resourceValue, powerToDamage)
				endif
			endif

			AssignObjectToWorkshop (resourceRef, workshopRef, true)
			resourceRef.HandleWorkshopReset()

			if bCleanupDamageHelpers_WorkObjects && resourceRef.GetBaseObject() as Flora
				resourceRef.UFO4P_ValidateDamageHelperRef()
			endif

		endif
		i += 1
	endWhile

	if workshopID != currentWorkshopID
		UFO4P_StopWorkshopReset()
		EditLock = false
		return
	endif

	wsTrace("------------------------------------------------------------------------------")
	wstrace("	Damage pass done.")	
	wstrace("		Removing " + foodToDamage + " extraneous food damage")
	wstrace("		Removing " + waterToDamage + " extraneous water damage")
	wstrace("		Removing " + safetyToDamage + " extraneous safety damage")
	wstrace("		Removing " + powerToDamage + " extraneous power damage")
	wsTrace("------------------------------------------------------------------------------")
	
	;WorkshopRatingDamageFood = 13
	;WorkshopRatingDamageWater = 14
	;WorkshopRatingDamageSafety = 15
	;WorkshopRatingDamagePower = 16
	;Thus, run this from a loop:
	i = 13
	while i < 17
		SetResourceData_Private (WorkshopRatings[i].resourceValue, workshopRef, 0)
		i += 1
	endWhile

	if workshopID != currentWorkshopID
		UFO4P_StopWorkshopReset()
		EditLock = false
		return
	endif

	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace("	ResetWorkshop: " + workshopRef + "  ASSIGNING RESOURCES:")
	wsTrace("------------------------------------------------------------------------------ ")
	
	TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingFood].resourceValue)
	TryToAssignResourceType (workshopRef, WorkshopRatings[WorkshopRatingSafety].resourceValue)
	;Put this at the end since this is now still safe to do if the workshop has unloaded (because we have all the data we need
	;to run this stored in arrays):
	TryToAssignBeds (workshopRef)
	;UFO4P 2.0.4 Bug #24274: modified the following line to pass the actor array to SetUnassignedPopulationRating:
	SetUnassignedPopulationRating (workshopRef, workshopActors)

	;Check whether workshop is still loaded, and if not, clear the bed arrays. Otherwise set UFO4P_ClearBedArrays to 'true'
	;for UFO4P_ResetCurrentWorkshop to clear them if it resets the current workshop:
	if workshopID == currentWorkshopID
		UFO4P_ClearBedArrays = true
	else
		UFO4P_UnassignedBeds = none
		UFO4P_ActorsWithoutBeds = none
	endif

	workshopRef.PlayerHasVisited = true

	wsTrace("	ResetWorkshop: " + workshopRef + " Total population: " + workshopRef.GetValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue))
	wsTrace("------------------------------------------------------------------------------ ")
	wsTrace(" RESET WORKSHOP for " + workshopRef + "   - DONE", bNormalTraceAlso = true)
	wsTrace("------------------------------------------------------------------------------ ")

	if bCleanupDamageHelpers_WorkObjects
		workshopRef.UFO4P_CleanupDamageHelpers_WorkObjects = false
	endIf

	EditLock = false

endFunction

; utility function to send custom destruction state change event (because it has to be sent from the defining script)
function SendDestructionStateChangedEvent(WorkshopObjectScript workObject, WorkshopScript workshopRef)
	wsTrace(" SendDestructionStateChangedEvent " + workshopRef)
	; send custom event for this object
	Var[] kargs = new Var[2]
	kargs[0] = workObject
	kargs[1] = workshopRef
	SendCustomEvent("WorkshopObjectDestructionStageChanged", kargs)		
endFunction

; utility function to send custom ownership state change event (because it has to be sent from the defining script)
function SendPlayerOwnershipChangedEvent(WorkshopScript workshopRef)
	wsTrace(" SendPlayerOwnershipChangedEvent " + workshopRef)
	; send custom event for this object
	Var[] kargs = new Var[2]
	kargs[0] = workshopRef.OwnedByPlayer
	kargs[1] = workshopRef
	SendCustomEvent("WorkshopPlayerOwnershipChanged", kargs)		
endFunction

; utility function to send custom destruction state change event (because it has to be sent from the defining script)
function SendPowerStateChangedEvent(WorkshopObjectScript workObject, WorkshopScript workshopRef)
	wsTrace(" SendPowerStateChangedEvent " + workshopRef)
	; send custom event for this object
	Var[] kargs = new Var[2]
	kargs[0] = workObject
	kargs[1] = workshopRef
	SendCustomEvent("WorkshopObjectPowerStageChanged", kargs)		
endFunction

; helper function for ResetWorkshop
; pass in resourceRef, keyword, current damage
; return new damage (after applying damage to this resource)
float function ApplyResourceDamage(WorkshopObjectScript resourceRef, ActorValue resourceValue, float currentDamage)
	if currentDamage > 0
		float damageAmount = math.min(resourceRef.GetResourceRating(resourceValue), currentDamage)
		if damageAmount > 0
			wsTrace("		DAMAGING: " + resourceValue + " production -" + damageAmount)
			if resourceRef.ModifyResourceDamage(resourceValue, damageAmount)
				currentDamage = currentDamage - damageAmount
			endif
		endif
	endif
	return currentDamage
endFunction

; helper function for ResetWorkshop
; pass in resourceRef, keyword, current damage
; if resourceRef already damaged, either reduce current damage by that amount or repair excess
; return new damage
float function UpdateResourceDamage(WorkshopObjectScript resourceRef, ActorValue resourceValue, float currentDamage)
	float damageAmount = resourceRef.GetResourceDamage(resourceValue)
	if damageAmount > 0
		wsTrace("		ALREADY DAMAGED: " + resourceValue + " production -" + damageAmount)
		currentDamage = currentDamage - damageAmount
		if currentDamage < 0
			; excess damage - repair this object the excess amount
			resourceRef.ModifyResourceDamage(resourceValue, currentDamage)
			currentDamage = 0
		endif
	endif
	return currentDamage
endFunction


function ClearWorkshopRatings(WorkshopScript workshopRef)
	wsTrace(" ClearWorkshopRatings")
	int i = 0
	while i < WorkshopRatings.Length
		if WorkshopRatings[i].clearOnReset
			;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
			SetResourceData_Private(WorkshopRatings[i].resourceValue, workshopRef, 0.0)
		endif
		wsTrace("   keyword=" + WorkshopRatings[i].resourceValue + ", current value=" + workshopRef.GetValue(WorkshopRatings[i].resourceValue))
		i += 1
	endWhile
endFunction

; test function to print current workshop ratings to the log
function OutputWorkshopRatings(WorkshopScript workshopRef)
	if workshopRef == NONE
		workshopRef = GetWorkshopFromLocation(Game.GetPlayer().GetCurrentLocation())
	endif
	
	wsTrace("------------------------------------------------------------------------------ ", bNormalTraceAlso = true)
	wsTrace(" OutputWorkshopRatings " + workshopRef, bNormalTraceAlso = true)
	int i = 0
	while i < WorkshopRatings.Length
		wsTrace("   " + WorkshopRatings[i].resourceValue + ": " + workshopRef.GetValue(WorkshopRatings[i].resourceValue) + " (" + workshopRef.GetBaseValue(WorkshopRatings[i].resourceValue) + ")", bNormalTraceAlso = true)
		i += 1
	endWhile
	wsTrace("------------------------------------------------------------------------------ ", bNormalTraceAlso = true)
endFunction


; *****************************************************************************************************
; HELPER FUNCTIONS
; *****************************************************************************************************

; returns the workshopID for the supplied workshop ref
WorkshopScript function GetWorkshop(int workshopID)
	;UFO4P 2.0.4 Bug #23803: added this check to return 'none' if an invalid workshopID is passed in (e.g. if this function is called for an unassigned
	;workshop NPC or object):
	if workshopID < 0 || workshopID >= workshops.length
		return none
	endif
	return Workshops[workshopID]
endFunction


int function GetWorkshopID(WorkshopScript workshopRef)
	int workshopIndex = Workshops.Find(workshopRef)
	if workshopIndex < 0
		wsTrace(" ERROR - workshop " + workshopRef + " not found in workshop array", 2)
	endif
	return workshopIndex
endfunction

;UFO4P 1.0.3 Bug #20581: added public version of ModifyResourceData function, to be called by external scripts.
;UFO4P 2.0 Bug #21896 (update to the UFO4P 1.0.3 edits for bug #20581): renamed this function to ModifyResourceData. That is, the function now has the same name
;as the old vanilla function, but is a publc function (i.e. locked) while the vanilla function was not. Any external users will now automatically call the public
;function, without needing to modify the respective scripts.
function ModifyResourceData(ActorValue pValue, WorkshopScript pWorkshopRef, float modValue)
	GetEditLock()
	;UFO4P 2.0 Bug #21896: Call ModifyResourceData_Private instead of ModifyResourceData here (see note on that function below)
	ModifyResourceData_Private (pValue, pWorkshopRef, modValue)
	EditLock = false
endFunction

; helper function to modify keyword data on the specified workshop
;UFO4P 2.0 Bug #21896 (update to the UFO4P 1.0.3 edits for bug #20581): renamed this function to ModifyResourceData_Private (since ModifyResourceData is now
;the public version, see notes above).
function ModifyResourceData_Private(ActorValue pValue, WorkshopScript pWorkshopRef, float modValue)
	;wsTrace(" ModifyResourceData_Private on " + pWorkshopRef + ": actor value " + pValue + ", modValue=" + modValue)
	if pWorkshopRef == NONE || pValue == NONE
		return
	endif
	float currentValue = pWorkshopRef.GetValue(pValue)
	; don't mod value below 0
	float newValue = math.Max(modValue + currentValue, 0)
	;wsTrace(" ModifyResourceData_Private on " + pWorkshopRef + ": actor value " + pValue + ", newValue=" + newValue)

	; NOTE: we don't want to actually call ModValue since ModValue changes the actor value "modifier" pool and SetValue changes the base value
	;  so instead we always use SetValue
	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes above)
	SetResourceData_Private(pValue, pWorkshopRef, newValue)
	newValue = pWorkshopRef.GetValue(pValue)
	;wsTrace(" ModifyResourceData_Private on " + pWorkshopRef + ": actor value " + pValue + ", starting value=" + currentValue + ", final value=" + newValue)
endFunction

;UFO4P 1.0.3 Bug #20581: added public version of SetResourceData function, to be called by external scripts.
;UFO4P 2.0 Bug #21896 (update to the UFO4P 1.0.3 edits for bug #20581): renamed this function to SetResourceData. That is, the function now has the same name
;as the old vanilla function, but is a publc function (i.e. locked) while the vanilla function was not. Any external users will now automatically call the public
;function, without needing to modify the respective scripts.
function SetResourceData (ActorValue pValue, WorkshopScript pWorkshopRef, float newValue)
	GetEditLock()
	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see note on that function below)
	SetResourceData_Private (pValue, pWorkshopRef, newValue)
	EditLock = false
endFunction

;UFO4P 2.0 Bug #21896 (update to the UFO4P 1.0.3 edits for bug #20581): renamed this function to SetResourceData_Private (since SetResourceData is now
;the public version, see notes above).
function SetResourceData_Private (ActorValue pValue, WorkshopScript pWorkshopRef, float newValue)
	if pValue == NONE
		return
	endif
	;wsTrace(" SetResourceData_Private: " + pWorkshopRef + ": actor value " + pValue + ", new value " + newValue)
	float oldBaseValue = pWorkshopRef.GetBaseValue(pValue)
	float oldValue = pWorkshopRef.GetValue(pValue)
	; restore any damage first, then set
	if oldValue < oldBaseValue
		pWorkshopRef.RestoreValue(pValue, oldBaseValue-oldValue)
	endif
	; now set the value
	pWorkshopRef.SetValue(pValue, newValue)
	;wsTrace(" SetResourceData_Private: " + pWorkshopRef + ":   " + pValue + " was set to new value=" + newValue + ", old value=" + oldValue + ", current value (should match new value)=" + pWorkshopRef.GetValue(pValue))
endFunction

; update current damage rating for this workshop
function UpdateCurrentDamage(WorkshopScript workshopRef)
	float totalResourcePoints = GetTotalResourcePoints(workshopRef)
	float totalDamagePoints = GetTotalDamagePoints(workshopRef)
	float currentDamage = totalDamagePoints/totalResourcePoints * 100
	wsTrace("	UpdateCurrentDamage: " + totalDamagePoints + "/" + totalResourcePoints + "=" + currentDamage)
	;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
	SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageCurrent].resourceValue, workshopRef, currentDamage)
	; update max damage if current damage is bigger
	float maxDamage = workshopRef.GetValue(WorkshopRatings[WorkshopRatingDamageMax].resourceValue)
	if currentDamage > maxDamage
		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
		SetResourceData_Private(WorkshopRatings[WorkshopRatingDamageMax].resourceValue, workshopRef, currentDamage)
	endif		
endFunction


int function GetResourceIndex(ActorValue pValue)
	return WorkshopRatingValues.Find(pValue)
endFunction


ActorValue function GetRatingAV(int ratingIndex)
	if ratingIndex >= 0 && ratingIndex < WorkshopRatings.Length
		return WorkshopRatings[ratingIndex].resourceValue
	else
		return NONE
	endif
endFunction

; specialized helper function - pass in rating index to WorkshopRatingValues (food, water, etc.), get back index to corresponding damage rating 
; returns -1 if not a valid rating index
ActorValue function GetDamageRatingValue(ActorValue resourceValue)
	int damageIndex = -1
	int ratingIndex = WorkshopRatingValues.Find(resourceValue)
	if ratingIndex == WorkshopRatingFood
		damageIndex = WorkshopRatingDamageFood
	elseif ratingIndex == WorkshopRatingWater
		damageIndex = WorkshopRatingDamageWater
	elseif ratingIndex == WorkshopRatingSafety
		damageIndex = WorkshopRatingDamageSafety
	elseif ratingIndex == WorkshopRatingPower
		damageIndex = WorkshopRatingDamagePower
	elseif ratingIndex == WorkshopRatingPopulation
		damageIndex = WorkshopRatingDamagePopulation
	endif
	if damageIndex > -1
		return WorkshopRatings[damageIndex].resourceValue
	else
		return NONE
	endif
endFunction


ObjectReference[] Function GetWorkshopActors(WorkshopScript workshopRef)
	return workshopRef.GetWorkshopResourceObjects(WorkshopRatings[WorkshopRatingPopulation].resourceValue)
endFunction

; aiDamageOption:
;	0 = return all objects
;	1 = return only damaged objects (at least 1 damaged resource value)
;	2 = return only undamaged objects (NO damaged resource values)
ObjectReference[] Function GetResourceObjects(WorkshopScript workshopRef, ActorValue resourceValue = NONE, int aiDamageOption = 0)
;/
	if resourceValue == NONE
		resourceValue = WorkshopResourceObject
	endif
/;
	return workshopRef.GetWorkshopResourceObjects(resourceValue, aiDamageOption)
endFunction


ObjectReference[] Function GetBeds(WorkshopScript workshopRef)
	return workshopRef.GetWorkshopResourceObjects(WorkshopRatings[WorkshopRatingBeds].resourceValue)
endFunction

; return true if actor owns a bed on this workshop
bool Function ActorOwnsBed(WorkshopScript workshopRef, WorkshopNPCScript actorRef)
	
	;/
	ObjectReference[] beds = GetBeds(workshopRef)
	int i = 0
	while i < beds.Length
		WorkshopObjectScript theBed = beds[i] as WorkshopObjectScript
		; if bed has faction owner, count that if I'm in that faction
		;UFO4P: added sanity check and trace to spot items with missing scripts:
		if theBed == none
			wsTrace(self + " ActorOwnsBed: " + beds[i] + " has no WorkshopObjectScript")
		elseIf theBed.IsFactionOwner(actorRef) || (theBed.IsActorAssigned() && theBed.GetAssignedActor() == actorRef)
			return true
		endif
		i += 1
	endWhile
	return false
	/;

	;UFO4P 2.0.4 Bug #24312:
	;Simplified this: With the new helper arrays implemented (see comment added to ResetWorkshop), we only have to look for the
	;actor in the UFO4P_ActorsWithoutBeds array to find out whether he owns a bed or not. This is significantly faster than looping
	;through the actor's work objects.
	if workshopRef.GetWorkshopID() == currentWorkshopID
		return (UFO4P_ActorsWithoutBeds.Find (actorRef) < 0)
	else
		wsTrace("	ActorOwnsBed: workshop " + workshopRef + " is not loaded. Can't check bed ownership for actor " + actorRef)
	endif
	return false
	
endFunction


; RESOURCE CHANGE: OBSOLETE - each resource actor value now stores both total and current value
;/
; specialized helper function - pass in rating index to WorkshopRatingValues (food, water, etc.), get back index to corresponding TOTAL rating 
; returns -1 if not a valid rating index
ActorValue function GetTotalRatingValue(ActorValue resourceValue)
	int totalIndex = -1
	int ratingIndex = WorkshopRatingValues.Find(resourceValue)
	if ratingIndex == WorkshopRatingFood
		totalIndex = WorkshopRatingTotalFood
	elseif ratingIndex == WorkshopRatingWater
		totalIndex = WorkshopRatingTotalWater
	elseif ratingIndex == WorkshopRatingSafety
		totalIndex = WorkshopRatingTotalSafety
	elseif ratingIndex == WorkshopRatingPower
		totalIndex = WorkshopRatingTotalPower
	elseif ratingIndex == WorkshopRatingBonusHappiness
		totalIndex = WorkshopRatingTotalBonusHappiness
	endif
	if totalIndex > -1
		return WorkshopRatings[totalIndex].resourceValue
	else
		return NONE
	endif
endFunction
/;

; utility function for all Workshop traces
function wsTrace(string traceString, int severity = 0, bool bNormalTraceAlso = false) DebugOnly
	;UFO4P: Added line to re-open the log:
	debug.OpenUserLog(UserLogName)
	debug.traceUser(userlogName, " " + traceString, severity)
;	if bNormalTraceAlso
;		;debug.Trace(self + " " + traceString, severity)
;	endif
endFunction

; utility function to wait for edit lock
; increase wait time while more threads are in here
int editLockCount = 1
function GetEditLock()
	;UFO4P: Added trace
	;wsTrace(self + " Edit Lock Count = " + editLockCount)

	editLockCount += 1
	
	;UFO4P 2.0.2: Added the following check:
	;This sends a warning message to the log (even if this script is not compiled in debug mode) if the number of threads in the lock gets unusually high:
	;if editLockCount > 4
	;	UFO4P_ThreadWarning (editLockCount)
	;endif
	
	;UFO4P 2.0.4: replaced the previous check with the following one:
	if editLockCount > 4 && UFO4P_ThreadMonitorStarted == false
		StartTimer (1.0, UFO4P_ThreadMonitorTimerID)
		UFO4P_ThreadMonitorStarted = true
	endif
	
	while EditLock
		utility.wait(0.1 * editLockCount)
	endWhile
	EditLock = true
	editLockCount -= 1
endFunction


bool function IsEditLocked()
	return EditLock
endFunction


Group WorkshopRadioData
	Scene Property WorkshopRadioScene01 Auto Const
	ObjectReference Property WorkshopRadioRef Auto Const
	Keyword Property WorkshopRadioObject Auto Const
endGroup



function RegisterForWorkshopEvents(Quest questToRegister, bool bRegister = true)
	; register for build events from workshop
	if bRegister
		wsTrace(self + " RegisterForWorkshopEvents " + questToRegister + " = " + bRegister)
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectBuilt")
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectMoved")
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectDestroyed")
		questToRegister.RegisterForCustomEvent(self, "WorkshopActorAssignedToWork")
		questToRegister.RegisterForCustomEvent(self, "WorkshopActorUnassigned")
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectDestructionStageChanged")
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectPowerStageChanged")
		questToRegister.RegisterForCustomEvent(self, "WorkshopPlayerOwnershipChanged")
		questToRegister.RegisterForCustomEvent(self, "WorkshopEnterMenu")
		questToRegister.RegisterForCustomEvent(self, "WorkshopObjectRepaired")
	else
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectBuilt")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectMoved")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectDestroyed")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopActorAssignedToWork")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopActorUnassigned")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectDestructionStageChanged")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectPowerStageChanged")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopPlayerOwnershipChanged")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopObjectRepaired")
		questToRegister.UnregisterForCustomEvent(self, "WorkshopEnterMenu")
	endif
endFunction


Struct WorkshopObjective
	int index	;{ objective number }
	int startStage	;{ stage which started the objective }
	int doneStage	;{ stage to set when objective complete }
	int ratingIndex	;{ WorkshopParent.WorkshopRatingKeyword index}
	Keyword requiredKeyword ; optional - a keyword to check on the new built object
	GlobalVariable currentCount	; global holding current count - if filled, use ModObjectiveGlobal when new object is created
	GlobalVariable maxCount	; global holding max we're looking for - needs to be filled if currentCount is filled
	GlobalVariable percentComplete ; global holding % complete (for objective display)
	int startingCount ; this is subtracted from currentCount and maxCount when displaying the percentage (if 0, will just use real totals)
	bool useBaseValue = false ; if true, check base value instead of current value (e.g. for beds)
	bool rollbackObjective = false ; if true, can uncomplete objectives if they are now below the target value
EndStruct

; call this if you don't care which workshop the event came from
function UpdateWorkshopObjectivesAny(Quest theQuest, WorkshopObjective[] workshopObjectives, Var[] akArgs)
	if (akArgs.Length > 0)
		WorkshopScript workshopRef = akArgs[1] as WorkshopScript
		UpdateWorkshopObjectives(theQuest, workshopObjectives, workshopRef, akArgs)
	endif
endFunction

;UFO4P 2.0.4: removed all traces from this function:
;This works as intended. Logging it anyway makes the workshop logs confusing, especially when a lenghty function such as ResetWorkshop or
;a daily update is running because plenty of messages from this and the subsequent function may get inserted at any time.
function UpdateWorkshopObjectives(Quest theQuest, WorkshopObjective[] workshopObjectives, WorkshopScript theWorkshop, Var[] akArgs)
	;UFO4P: Modified trace to print message on workshop-specific user log
	;debug.trace(" UpdateWorkshopObjectives from " + theWorkshop)
	;wsTrace(" UpdateWorkshopObjectives for " + theWorkshop)
	
	if (akArgs.Length > 0)
		WorkshopObjectScript newObject = akArgs[0] as WorkshopObjectScript
		WorkshopScript workshopRef = akArgs[1] as WorkshopScript

		if workshopRef && workshopRef == theWorkshop
			UpdateWorkshopObjectivesSpecific(theQuest, workshopObjectives, theWorkshop)
		endif
	endif
	;UFO4P: Added trace
	;wsTrace(" UpdateWorkshopObjectives for " + theWorkshop + " - DONE")
endFunction

; call this function if you've already checked the event data or just want to initialize/update the objectives directly
;UFO4P 2.0.4: removed all traces from this function:
;This works as intended. Logging it anyway makes the workshop logs confusing, especially when a lenghty function such as ResetWorkshop or
;a daily update is running because plenty of messages from this function may get inserted at any time.
function UpdateWorkshopObjectivesSpecific(Quest theQuest, WorkshopObjective[] workshopObjectives, WorkshopScript theWorkshop)
	;debug.trace(" UpdateWorkshopObjectivesSpecific from " + theWorkshop)
	; wait for recalc to finish
	theWorkshop.WaitForWorkshopResourceRecalc()
	
	; check for objectives being completed
	int i = 0
	while (i < WorkshopObjectives.Length)
		WorkshopObjective theObjective = WorkshopObjectives[i]
		if theQuest.GetStageDone(theObjective.startStage) && (!theQuest.GetStageDone(theObjective.doneStage) || theObjective.rollbackObjective)
			;debug.trace(theQuest + " valid objective: " + theObjective)
			float currentRating = 0
			if theObjective.useBaseValue
				currentRating = theWorkshop.GetBaseValue(WorkshopRatings[theObjective.ratingIndex].resourceValue)
			else
				currentRating = theWorkshop.GetValue(WorkshopRatings[theObjective.ratingIndex].resourceValue)
			endif
			;debug.trace(theQuest + " rating " + WorkshopRatings[theObjective.ratingIndex].resourceValue + ": currentRating=" + currentRating)
			if theObjective.currentCount
				; update objective count if the current rating has increased by at least 1
				float objectiveCount = theObjective.currentCount.GetValue()
				int diff = Math.Floor(currentRating - objectiveCount)
				if diff != 0
					; get % complete - if there's a startingCount, reduce both current and max by that amount
					float percentComplete = ((currentRating  - theObjective.startingCount)/(theObjective.maxCount.GetValue() - theObjective.startingCount)) * 100
					percentComplete = math.min(percentComplete, 100)
					;debug.trace(self + " currentRating=" + currentRating + ", maxCount=" + theObjective.maxCount.GetValue() + ", percentComplete=" + percentComplete)
					theObjective.percentComplete.SetValue(percentComplete)
					theQuest.UpdateCurrentInstanceGlobal(theObjective.percentComplete)
					if theQuest.ModObjectiveGlobal(afModValue = diff, aModGlobal = theObjective.currentCount, aiObjectiveID = theObjective.index, afTargetValue = theObjective.maxCount.GetValue(), abAllowRollbackObjective = theObjective.rollbackObjective)
						theQuest.setStage(theObjective.doneStage)
					endif
				endif
			else
				; just check if rating is positive
				if currentRating > 0
					theQuest.setStage(theObjective.doneStage)
				endif
			endif
		endif
		i += 1
	endwhile
endFunction

; returns rating for specified workshop and ratingIndex
float function GetRating(WorkshopScript workshopRef, int ratingIndex)
	float rating = workshopRef.GetValue(WorkshopRatings[ratingIndex].resourceValue)
	return rating
endFunction

; call this to randomize ransom value
function RandomizeRansom(GlobalVariable randomGlobal)
	int randomRansom = utility.randomInt(WorkshopMinRansom.GetValueInt(), WorkshopMaxRansom.GetValueInt())
	wsTrace(self + " RandomizeRansom: " + randomRansom)
	; round to closest 50
	float randomRounded = randomRansom/50 + 0.5
	randomRansom = math.floor(randomRounded) * 50
	wsTrace(self + " 	rounded to: " + randomRansom)
	randomGlobal.SetValue(randomRansom)
endFunction

; returns true if the passed in reference is in a "friendly" location (meaning the buildable area of a friendly settlement)
; * population > 0
; * workshop settlement
; * 1.5 not type02 settlement
bool function IsFriendlyLocation(ObjectReference targetRef)
	Location locationToCheck = targetRef.GetCurrentLocation()
	;debug.trace(self + " IsFriendlyLocation: targetRef=" + targetRef + ", locationToCheck=" + locationToCheck)
	if locationToCheck == NONE
		;debug.trace(self + " IsFriendlyLocation: FALSE")
		return false
	else
		WorkshopScript workshopRef = GetWorkshopFromLocation(locationToCheck)
		if workshopRef && workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) > 0 && targetRef.IsWithinBuildableArea(workshopRef) && ( workshopRef.HasKeyword(WorkshopType02) == false || workshopRef.OwnedByPlayer )
			;debug.trace(self + " IsFriendlyLocation: TRUE")
			return true
		else
			;debug.trace(self + " IsFriendlyLocation: FALSE")
			return false
		endif
	endif
endFunction

; utility functions to change the happiness modifier
; special handling: these all check for change in player ownership
; TODO - if we end up with multiple ownership, need to clear that here

function ModifyHappinessModifierAllWorkshops(float modValue, bool bPlayerOwnedOnly = true)
	; go through all workshops
	int index = 0
	while index < Workshops.Length
		WorkshopScript workshopRef = Workshops[index]
		; only ones with population matter
		if workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) > 0
			; player owned if specified
			if (!bPlayerOwnedOnly || (bPlayerOwnedOnly && workshopRef.GetValue(WorkshopPlayerOwnership) > 0))
				ModifyHappinessModifier(workshopRef, modValue)
			endif
		endif
		index += 1
	endWhile

endFunction


function ModifyHappinessModifier(WorkshopScript workshopRef, float modValue)
	if workshopRef
		wsTrace(self + "ModifyHappinessModifier " + modValue)
		float currentValue = workshopRef.GetValue(WorkshopRatingValues[WorkshopRatingHappinessModifier])
		float targetHappiness = workshopRef.GetValue(WorkshopRatingValues[WorkshopRatingHappinessTarget])
		float newValue = currentValue + modValue
		
		; don't modify past max/min limits so this doesn't overwhelm the base happiness value
		newValue = Math.Min(newValue, happinessModifierMax)
		newValue = Math.Max(newValue, happinessModifierMin)

		wsTrace(self + "	currentValue=" + currentValue + ", newValue=" + newValue + ", targetHappiness=" + targetHappiness)

		;UFO4P 2.0 Bug #21896: Call SetResourceData_Private instead of SetResourceData here (see notes on that function for explanation)
		SetResourceData_Private(WorkshopRatingValues[WorkshopRatingHappinessModifier], workshopRef, newValue)

		; recalc mod value to get the actual delta
		modValue = newValue - currentValue
		; if delta would reduce target to <= 0, end player ownership if it exists (and population is > 0)
		int population = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulation].resourceValue) as int
		int robots = workshopRef.GetBaseValue(WorkshopRatings[WorkshopRatingPopulationRobots].resourceValue) as int
		wsTrace("	ModifyHappinessModifier " + workshopRef + " population=" + (population - robots))

		if ( targetHappiness + modValue ) <= 0 && workshopRef.OwnedByPlayer && (population - robots) > 0 && workshopRef.AllowUnownedFromLowHappiness
			workshopRef.SetOwnedByPlayer(false)
		endif
	endif
endFunction


function SetHappinessModifier(WorkshopScript workshopRef, float newValue)
	if workshopRef
		wsTrace(self + "SetHappinessModifier " + newValue)
		float currentValue = workshopRef.GetValue(WorkshopRatingValues[WorkshopRatingHappinessModifier])
		float modValue = newValue - currentValue
		wsTrace(self + "	currentValue=" + currentValue + ", modValue=" + modValue)
		ModifyHappinessModifier(workshopRef, modValue)
	endif
endFunction

; utility function to display a message with text replacement from an object reference name
function DisplayMessage(Message messageToDisplay, ObjectReference refToInsert = NONE, Location locationToInsert = NONE)
	wsTrace("DisplayMessage " + refToInsert + ", " + locationToInsert)
	; insert ref into message alias - TODO - add more params as needed
	if refToInsert
		MessageRefAlias.ForceRefTo(refToInsert)
	endif

	if locationToInsert
		MessageLocationAlias.ForceLocationTo(locationToInsert)
	endif
	; display message
	messageToDisplay.Show()

	; clear aliases
	MessageRefAlias.Clear()
	MessageLocationAlias.Clear()
endFunction


function PlayerComment(WorkshopObjectScript targetObject)

	;UFO4P 1.0.3 Bug #20567: Return if targetObject is not at a workshop location:
	If targetObject.workshopID < 0
		Return
	EndIf
	
	;wstrace("PlayerComment " + targetObject)
	; only if at owned workshop
	WorkshopScript workshopRef = GetWorkshop(targetObject.workshopID)
	if workshopRef && workshopRef.OwnedByPlayer
		if WorkshopPlayerCommentScene.IsPlaying() == false
			PlayerCommentTarget.ForceRefTo(targetObject)
			WorkshopPlayerCommentScene.Start()
		endif
	endif

endFunction

;added by jduvall
function ToggleOnAllWorkshops()
	int i = 0
	while (i < WorkshopsCollection.GetCount() - 1)
		(WorkshopsCollection.GetAt(i) as WorkshopScript).SetOwnedByPlayer(true)
		i += 1
	endwhile
	PlayerOwnsAWorkshop = true
endFunction


bool Function PermanentActorsAliveAndPresent(WorkshopScript workshopRef)
	int i = 0
	int iCount = PermanentActorAliases.GetCount()

	;If there are permanent actors...
	if iCount > 0

		int iClearedWorkshopID = workshopRef.GetWorkshopID()

		;Then loop through all the permanent actors and get their workshop ID...
		while i < iCount
			Actor act = (PermanentActorAliases.GetAt(i) as Actor)
			wsTrace("PermanentActorsAliveAndPresent: Checking permanent actor: " + act)
			int iActorWorkshopID = (act as WorkshopNPCScript).GetWorkshopID()

			;If the selected Permanent Actor is assigned to a workshop location and isn't dead...
			if iActorWorkshopID > -1 && !act.IsDead()
				wsTrace("PermanentActorsAliveAndPresent: Comparing actor's workshop ID: " + iActorWorkshopID + "  and cleared workshop ID: " + iClearedWorkshopID)

				;And they're assigned to the cleared location, return true
				if iActorWorkshopID == iClearedWorkshopID
					return true
				endif

			endif

			i += 1
		endwhile
	endif

	return false
EndFunction

;-----------------------------------------------------------
;	Added by UFO4P 1.0.3 for Bug #20581
;-----------------------------------------------------------

;helper function to check whether the passed in actor owns anything else than a bed

;/
bool function IsObjectOwner (WorkshopScript workshopRef, WorkshopNPCScript theActor)
	ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects(theActor)
	int objectCount = ResourceObjects.Length
	int i = 0
	while i < objectCount
		WorkshopObjectScript resourceObject = ResourceObjects[i] as WorkshopObjectScript
		if resourceObject && resourceObject.IsBed() == 0
			return true
		endif
		i += 1
	endWhile
	return false
endFunction
/;

;UFO4P 2.0.4 Bug #24312: simplified this function:
;Since all actors withouz beds are stored in an array now, we only have to count the number of the actor's owned objects (i.e. to check
;the array length): if the actor owns a bed, we should find at least 2 owned objects, otherwise one.
bool function IsObjectOwner (WorkshopScript workshopRef, WorkshopNPCScript theActor)
	int minObjectCount = 1
	if ActorOwnsBed (workshopRef, theActor)
		minObjectCount += 1
	endif
	ObjectReference[] ResourceObjects = workshopRef.GetWorkshopOwnedObjects (theActor)
	if ResourceObjects.Length >= minObjectCount
		return true
	endif
	return false
endFunction

;-----------------------------------------------------------
;	Added by UFO4P 2.0 for Bug #21895
;-----------------------------------------------------------

;This will be called by WorkshopAttackScript when the attack quest starts running (usually when the attack message pops up on the screen):
function UFO4P_StartAttack (WorkshopScript workshopRef)
	;Failsafe: Don't do anything here if the player is currently at the workshop that is getting attacked:
	;If the player is already at the workshop location, a reset will already have run (or is still running), so there's nothing to delay. 
	;if Game.GetPlayer().GetCurrentLocation() != workshopRef.myLocation
	;UFO4P 2.0.4 Bug #24312: replaced the previous line with the following line:
	if workshopRef.GetWorkshopID() != currentWorkshopID
		workshopRef.UFO4P_CurrentlyUnderAttack = true
		wsTrace(self + "UFO4P_StartAttack: " + workshopRef + " marked as currently under attack")
	endIf
	wsTrace(self + "UFO4P_StartAttack: DONE")
endFunction

;This will be called by WorkshopAttackScript when all attackers are dead or when the attack quest shuts down (in case the player failed to kill all
;enemies or was not even present at the location and the attack is resolved off screen):
function UFO4P_ResolveAttack (WorkshopScript workshopRef)
	;No need to do anything here if workshopRef was not marked as under attack for whatever reason (this is mainly to prevent things from going wrong
	;when UFO4P is upgraded while an attack is under way and UFO4P_StartAttack did never run):
	if workshopRef.UFO4P_CurrentlyUnderAttack
		;Clear the attack bool on workshopRef:
		workshopRef.UFO4P_CurrentlyUnderAttack = false
		if UFO4P_WorkshopRef_ResetDelayed && workshopRef == UFO4P_WorkshopRef_ResetDelayed
			;Start reset via timer to prevent delays on WorkshopAttackScript:
			StartTimer(0.1, UFO4P_DelayedResetTimerID)
			wsTrace(self + "UFO4P_ResolveAttack: Started timer for reset of workshop " + workshopRef)
		endIf
	endIf
	wsTrace(self + "UFO4P_ResolveAttack: DONE")
endFunction


event OnTimer(int aiTimerID)
	if aiTimerID == UFO4P_DelayedResetTimerID
		;Make sure that the workshop location is still loaded before starting the reset:
		;if UFO4P_WorkshopRef_ResetDelayed.myLocation.IsLoaded()
		;UFO4P 2.0.2 Bug #23016: replaced the previous line with the following line:
		;Calling the new function UFO4P_IsWorkshopLoaded here:
		if UFO4P_IsWorkshopLoaded (UFO4P_WorkshopRef_ResetDelayed)
			UFO4P_GameTimeOfLastResetStarted = Utility.GetCurrentGameTime()
			ResetWorkshop(UFO4P_WorkshopRef_ResetDelayed)
		else
			UFO4P_WorkshopRef_ResetDelayed = none
			;reset the attack bool if no reset is started, so workshop scripts can resume their daily updates (otherwise, the bool will be reset by the Reset
			;Workshop function, to make sure that the delayed reset has priority over pending daily updates):
			UFO4P_AttackRunning = false
		endIf
	;UFO4P 2.0.4 Bug #24312: added this branch:
	;If the player is at a workshop when UFO4P is upgraded to version 2.0.4, we must run another reset
	elseif aiTimerID == UFO4P_ForcedResetTimerID
		if currentWorkshopID >= 0 && UFO4P_AttackRunning == false
			workshopScript workshopRef = Workshops[currentWorkshopID]
			UFO4P_PreviousWorkshopLocation = workshopRef.myLocation
			UFO4P_GameTimeOfLastResetStarted = Utility.GetCurrentGameTime()
			UFO4P_InitCurrentWorkshopArrays()
			ResetWorkshop(workshopRef)
		endif
	;UFO4P 2.0.4: also added this branch: this is to start an external helper script for debugging if the thread count on this script gets unusually high
	elseif aiTimerID == UFO4P_ThreadMonitorTimerID && UFO4P_ThreadMonitor != none
		UFO4P_ThreadMonitor.StartMonitoring()
	endIf
endEvent

;-----------------------------------------------------------
;	Added by UFO4P 2.0.0:
;-----------------------------------------------------------

;This function has been added to provide quick access to the damage helper cleanup procedures implemented in UFO4P 1.0.5. It may be called by external scripts
;to reset the cleanup bool on the passed-in workshop (or on all workshops, if no workshopID is passed in) to 'true'. The next reset running on that workshop will
;then call a cleanup function on all crops of that workshop to check the configuration of their damage helpers and to correct it if necessary.

function UFO4P_ResetCropMarkerCleanupBool (int workshopID = -1)
	if workshopID >= 0
		GetWorkshop(workshopID).UFO4P_CleanupDamageHelpers_WorkObjects = true
	else
		int workshopCount = workshops.Length
		workshopID = 0
		while workshopID < workshopCount
			GetWorkshop(workshopID).UFO4P_CleanupDamageHelpers_WorkObjects = true
			workshopID += 1
		endWhile
	endif
endFunction

;-----------------------------------------------------------
;	Added by UFO4P 2.0.2:
;-----------------------------------------------------------

;Added for debugging purposes: this will print a warning on the log (even if the script is not compiled in debug mode) if the count of threads hanging in the
;lock at the same time gets exceedingly high. Since printing the message requires calling an external script (the Game script), this had to be handled via a
;function call since it would otherwise release the natural thread lock on any function that is calling it.

;/
function UFO4P_ThreadWarning (int ThreadsInLock)
	game.warning("----- WorkshopParentScript: WARNING: Threads in lock = " + ThreadsInLock + " -----")
endFunction

----------------------------------------------------------------------------------------------------------------------------------------------------
	UFO4P 2.0.4:
	Removed this because warnings sent by the game script are sacked too if the script is compiled in 'release final' mode. Instead, this script
	now calls a script ona n external quest if the number of threads increases beyond a critical value. That script has been compiled in debug
	mode and will print warning messages on the papyrus log.
----------------------------------------------------------------------------------------------------------------------------------------------------
/;

UFO4P:UFO4P_ThreadMonitorScript Property UFO4P_ThreadMonitor = none auto hidden
;This will be filled by the thread monitor quest when it starts running, so we don't have to set it in the editor.
;Doing it that way makes sure that it still works with mods that modify properties on this script (these would be inevtiably missing this property
;until they are updated).

bool UFO4P_ThreadMonitorStarted = false
int UFO4P_ThreadMonitorTimerID = 37 const

int function UFO4P_GetThreadCount()
	return editLockCount
endFunction

function UFO4P_ThreadMonitorStopped()
	UFO4P_ThreadMonitorStarted = false
endFunction

;recovery function: not nrmally used !!!
;call by external scripts to release the lock once (use with great care !!!)
function UFO4P_ReleaseLock()
	EditLock = false
endFunction

;/
--------------------------------------------------------------------------------------------------------------------------------------------------------------
	Added by UFO4P 2.0.2 for Bug #23016:

	UFO4P_ResetCurrentWorkshop was added to reset the current workshop properties that are updated by the vanilla function SetCurrentWorkshop to their
	default values. The currentWorkshopID is supposed to be the ID of the workshop the player is currently staying at, and certain functions on this script
	and WorkshopScript that run operations relying on the workshop location being loaded are checking whether currentWorkshopID is the same as the ID of the
	workshop they run on before proceeding.

	However, the vanilla script did never reset currentWorkshopID if a location unloaded. It was updated to the new workshop location when the ResetWorkshop
	function started running, and in the meantime, it was holding the ID of the workshop last visited by the player. That workshop could have unloaded at any
	time and therefore, checking currentWorkshopID was not a safe way to determine whether a workshop was loaded.

	Unfortunately though, there is no easy way to tell whether the player left a workshop location because the OnLocationChange event records bogus leave
	events if the player enters menu mode or workshop mode (see the comments on bug #20576) that are indiscernible from valid leave events, so we had to
	conceive a workaround:

	 (1) All workbenches call this function from their OnUnload events, and if their workshopID is matching currentWorkshopID, the properties are reset.
	 (2) All operations relying on a workshop being loaded (this affects functions on this script and on WorkshopScript) are now checking whether the
		 respective workshop location is actually loaded, and if not, skip any unsafe operations and call this function instead to reset the properties.
	     For this purpose, they call UFO4P_IsWorkshopLoaded which performs the check and the subsequent reset, if needed.
	 (3) Checks were added to several functions that should not run on unloaded workshops, but did not have any checks in place to avoid this.

--------------------------------------------------------------------------------------------------------------------------------------------------------------
/;

function UFO4P_ResetCurrentWorkshop (int workshopID)

	;UFO4P 2.0.4 Bug #24122: This needs to be checked here again (even though UFO4P_IsWorkshopLoaded already checked the ID it's passing
	;in) because this function may also be called by WorkshopScript if a workbench unloads, and this may be an unrelated workbench (e.g.
	;the Red Rocket Station workbench may load and unlaod while the player is at Sanctuary).
	if workshopID != currentWorkshopID
		return
	endif

	;UFO4P 2.0.4 Bug #24503: moved this block of code here from the OnLocationChange event:
	;Clearing the attack bools as soon as the player leaves the area (if it is still flagged as under attack at this point) is faster than waiting
	;until the player has moved to another workshop. This makes sure that any activities of the workshop sctripts that were suspended because of
	;the attack will be resumed as soon as possible.
	if UFO4P_AttackRunning && Workshops[workshopID] == UFO4P_WorkshopRef_ResetDelayed
		UFO4P_WorkshopRef_ResetDelayed.UFO4P_CurrentlyUnderAttack = false
		UFO4P_WorkshopRef_ResetDelayed = none
	endif

	;This bool indicates whether a reset has been delayed at the workshop the player is currently staying at. Therefore, it should be set to false
	;whenever the player leaves a workshop. If the player returns, the OnLocationChange event will re-evaluate the situation and reset it to true
	;if necessary.
	UFO4P_AttackRunning = false

	;UFO4P 2.0.4: Improved logging, so this message is more easily identifiable on the workshop logs:
	wsTrace("---------------------------------------------------------------------------------")
	wsTrace ("	UFO4P_ResetCurrentWorkshop: previous currentWorkshopID = " + currentWorkshopID + "; new value = -1")
	wsTrace("---------------------------------------------------------------------------------")

	CurrentWorkshop.Clear()
	currentWorkshopID = -1
	WorkshopCurrentWorkshopID.SetValue(currentWorkshopID)

	;UFO4P 2.0.4 Bug #24312: added this line:
	UFO4P_ClearCurrentWorkshopArrays()

	;UFO4P 2.0.4 Bug #24122: added this line:
	;If a workshop unloads, we always must run another reset if the player returns.
	UFO4P_PreviousWorkshopLocation = none

endFunction


;bool function UFO4P_IsWorkshopLoaded (Location LocationToCheck)
;	if LocationToCheck && LocationToCheck.IsLoaded()
;		return true
;	else
;		UFO4P_ResetCurrentWorkshop()
;		return false
;	endif
;endFunction 


;UFO4P 2.0.4 Bug #24122: Replaced this function with the following version:
;(1) The 'IsLoaded' check is not reliable as it returns 'true' if only one cell of a location is still loaded.
;(2) We must check whether the passed-in workshop is the current workshop. If not, the check would always return false (a different
;    workshop cannot be loaded at the same time) and we might inadvertently reset the current workshop while it is still loaded.
;(3) added a bool argument to skip the call of UFO4P_ResetCurrentWorkshop() if appropriate.
bool function UFO4P_IsWorkshopLoaded (WorkshopScript workshopRef, bool bResetIfUnloaded = false)
	if workshopRef
		int workshopID = workshopRef.GetWorkshopID()
		if workshopID == currentWorkshopID
			if Game.GetPlayer().GetCurrentLocation() == workshopRef.myLocation || workshopRef.UFO4P_InWorkshopMode == true
				return true
			elseif bResetIfUnloaded
				UFO4P_ResetCurrentWorkshop (workshopID)
			endif
		endif
	endif
	return false
endFunction 

;--------------------------------------------------------------------------------------------------------------------------------------------
;	Added by UFO4P 2.0.4 for Bug #24411:
;--------------------------------------------------------------------------------------------------------------------------------------------

;This bundles some operations to be carried out if a workshop reset is stopped prematurely
function UFO4P_StopWorkshopReset()
	wsTrace("	ResetWorkshop: player left workshop. Aborting reset ... ")
	UFO4P_UnassignedBeds = none
	UFO4P_ActorsWithoutBeds = none
endFunction

;--------------------------------------------------------------------------------------------------------------------------------------------
;	Added by UFO4P 2.0.4 for Bug #24312:
;--------------------------------------------------------------------------------------------------------------------------------------------
;	Helper arrays and variables:
;--------------------------------------------------------------------------------------------------------------------------------------------

bool UFO4P_ClearBedArrays
bool UFO4P_FoodObjectArrayInitialized
bool UFO4P_SafetyObjectArrayInitialized

objectReference[] UFO4P_UnassignedFoodObjects
objectReference[] UFO4P_UnassignedSafetyObjects

WorkshopObjectScript[] UFO4P_UnassignedBeds
WorkshopNPCScript[] Property UFO4P_ActorsWithoutBeds Auto Hidden ; WSWF - Made into a property
WorkshopNPCScript[] UFO4P_FoodWorkers
WorkshopNPCScript[] UFO4P_SafetyWorkers

;--------------------------------------------------------------------------------------------------------------------------------------------
;	Functions to manage the new helper arrays
;--------------------------------------------------------------------------------------------------------------------------------------------

;called by the OnLocationChange event before a workshop reset is started
function UFO4P_InitCurrentWorkshopArrays()
	UFO4P_ActorsWithoutBeds = New WorkshopNPCScript[0]
	UFO4P_FoodWorkers = New WorkshopNPCScript[0]
	UFO4P_SafetyWorkers = New WorkshopNPCScript[0]
	UFO4P_UnassignedBeds = New WorkshopObjectScript[0]
	UFO4P_UnassignedFoodObjects = New ObjectReference[0]
	UFO4P_UnassignedSafetyObjects = New ObjectReference[0]
	UFO4P_FoodObjectArrayInitialized = false
	UFO4P_SafetyObjectArrayInitialized = false
endFunction

;called by UFO4P_ResetCurrentWorkshop when the current workshop has unloaded
function UFO4P_ClearCurrentWorkshopArrays()

	UFO4P_FoodWorkers = none
	UFO4P_SafetyWorkers = none
	UFO4P_UnassignedFoodObjects = none
	UFO4P_UnassignedSafetyObjects = none
	UFO4P_FoodObjectArrayInitialized = false
	UFO4P_SafetyObjectArrayInitialized = false

	if UFO4P_ClearBedArrays
		UFO4P_UnassignedBeds = none
		UFO4P_ActorsWithoutBeds = none
	endif

endFunction


function UFO4P_AddActorToWorkerArray (WorkshopNPCScript actorRef, int resourceIndex)
	if actorRef
		if resourceIndex == WorkshopRatingFood
			if UFO4P_FoodWorkers.Find (actorRef) < 0
				UFO4P_FoodWorkers.Add (actorRef)
				wsTrace("	UFO4P_AddActorToWorkerArray: added " + actorRef + " to food worker array.")
			endif
		elseif resourceIndex == WorkshopRatingSafety
			if UFO4P_SafetyWorkers.Find (actorRef) < 0
				UFO4P_SafetyWorkers.Add (actorRef)
				wsTrace("	UFO4P_AddActorToWorkerArray: added " + actorRef + " to safety worker array.")
			endif
		endif
	endif
endFunction


function UFO4P_RemoveActorFromWorkerArray (WorkshopNPCScript actorRef)
	if actorRef
		int workerIndex = UFO4P_FoodWorkers.Find (actorRef)
		if workerIndex >= 0
			UFO4P_FoodWorkers.Remove (workerIndex)
			wsTrace("	UFO4P_RemoveActorFromWorkerArray: removed " + actorRef + " from food worker array.")
		else
			workerIndex = UFO4P_SafetyWorkers.Find (actorRef)
			if workerIndex >= 0
				UFO4P_SafetyWorkers.Remove (workerIndex)
				wsTrace("	UFO4P_RemoveActorFromWorkerArray: removed " + actorRef + " from safety worker array.")
			endif
		endif
	endif
endFunction

			
function UFO4P_AddObjectToObjectArray (WorkshopObjectScript objectRef)
	if objectRef
		actorValue multiResourceValue = objectRef.GetMultiResourceValue()
		if multiResourceValue
			int resourceIndex = GetResourceIndex (multiResourceValue)
			if resourceIndex == WorkshopRatingFood && UFO4P_FoodObjectArrayInitialized
				;Zero length obkectreference arrays may turn into 'none' arrays on reload. As long as UFO4P_FoodObjectArrayInitialized is 'true' however,
				;the array was empty on purpose, so we can circumvent that issue by re-initializing it:
				if UFO4P_UnassignedFoodObjects == none
					UFO4P_UnassignedFoodObjects = New ObjectReference[0]
				endif
				if UFO4P_UnassignedFoodObjects.Find (objectRef) < 0
					UFO4P_UnassignedFoodObjects.Add (objectRef)
					wsTrace("	UFO4P_AddObjectToObjectArray: added " + objectRef + " to unassigned food objects array.")
				endif
			elseif resourceIndex == WorkshopRatingSafety && UFO4P_SafetyObjectArrayInitialized
				;Zero length obkectreference arrays may turn into 'none' arrays on reload. As long as UFO4P_SafetyObjectArrayInitialized is 'true' however,
				;the array was empty on purpose, so we can circumvent that issue by re-initializing it:
				if UFO4P_UnassignedSafetyObjects == none
					UFO4P_UnassignedSafetyObjects = New ObjectReference[0]
				endif
				if UFO4P_UnassignedSafetyObjects.Find (objectRef) < 0
					UFO4P_UnassignedSafetyObjects.Add (objectRef)
					wsTrace("	UFO4P_AddObjectToObjectArray: added " + objectRef + " to unassigned safety objects array.")
				endif
			endif
		endif
	endif
endFunction

;Called once from the ResetWorkshop function after it has looped through the actor array
function UFO4P_UpdateActorsWithoutBedsArray (WorkshopScript workshopRef)
	ObjectReference[] WorkshopBeds = GetBeds (workshopRef)
	int workshopID = workshopRef.GetWorkshopID()
	int countBeds = WorkshopBeds.Length
	int i = 0
	while i < countBeds
		WorkshopObjectScript theBed = WorkshopBeds[i] as WorkshopObjectScript
		if theBed
			WorkshopNPCScript theOwner = theBed.GetActorRefOwner() as WorkshopNPCScript
			if theOwner && theOwner.GetWorkshopID() == workshopID
				int actorIndex = UFO4P_ActorsWithoutBeds.Find (theOwner)
				if actorIndex >= 0
					UFO4P_ActorsWithoutBeds.Remove (actorIndex)
				endif
			endif
		endif
		i += 1
	endWhile
	wsTrace("	UFO4P_UpdateActorsWithoutBedsArray: found " + UFO4P_ActorsWithoutBeds.Length + " actors without beds.")			
endFunction


function UFO4P_AddUnassignedBedToArray (WorkshopObjectScript objectRef)
	if objectRef && UFO4P_UnassignedBeds.Find (objectRef) < 0
		UFO4P_UnassignedBeds.Add (objectRef)
		wsTrace("	UFO4P_AddUnassignedBedToArray: added " + objectRef + " to unassigned beds array.")
	endif
endFunction


bool function UFO4P_ObjectArrayInitialized (int resourceIndex)
	if resourceIndex == WorkshopRatingFood
		return UFO4P_FoodObjectArrayInitialized
	else
		return UFO4P_SafetyObjectArrayInitialized
	endif
endFunction


ObjectReference[] function UFO4P_GetObjectArray (int resourceIndex)
	if resourceIndex == WorkshopRatingFood
		return UFO4P_UnassignedFoodObjects
	else
		return UFO4P_UnassignedSafetyObjects
	endif
endFunction


function UFO4P_SaveObjectArray (objectReference[] ResourceObjects, int resourceIndex)
	if resourceIndex == WorkshopRatingFood
		UFO4P_UnassignedFoodObjects = ResourceObjects
		UFO4P_FoodObjectArrayInitialized = true
		wsTrace("	UFO4P_SaveObjectArray: new unassigned food objects array contains " + UFO4P_UnassignedFoodObjects.Length + " items")
	else
		UFO4P_UnassignedSafetyObjects = ResourceObjects
		UFO4P_SafetyObjectArrayInitialized = true
		wsTrace("	UFO4P_SaveObjectArray: new unassigned safety objects array contains " + UFO4P_UnassignedSafetyObjects.Length + " items")
	endif
endFunction

;--------------------------------------------------------------------------------------------------------------------------------------------
;	Helper function for UFO4P 2.0.4 retro script:
;--------------------------------------------------------------------------------------------------------------------------------------------

int UFO4P_ForcedResetTimerID = 52

function UFO4P_ForceWorkshopReset()
	if currentWorkshopID >= 0
		workshopScript workshopRef = Workshops[currentWorkshopID]
		;Make sure that the workshop is still loaded and reset currentWorkshopID if it's not. This will force a reset on next location change
		;without having to use the timer.
		if UFO4P_IsWorkshopLoaded (workshopRef, bResetIfUnloaded = true)
			;Start the reset from a timer, so the UFO4P 2.0.4 retro quest can shut down immediately and doesn't have to wait
			;until the reset has finished running:
			StartTimer(0.1, UFO4P_ForcedResetTimerID)
		endif
	endif
endFunction