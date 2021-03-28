//*******************************************************************************************
//  FILE:   X2StrategyElement_TechsMW_Rusty.uc                                    
//  
//	File created by RustyDios	12/07/20	17:00	
//	LAST UPDATED				14/07/20	11:15
//
//	ADDS SPARK SLOTS AND TECHS TO THE GAME, PRETTY MUCH COPIED FROM 
//		NOTSOLONEWOLF'S MECHATRONIC WARFARE
//
//*******************************************************************************************

class X2StrategyElement_TechsMW_Rusty extends X2StrategyElement config(StrategyTuning);

var config int SPARK_REPAIRBAY_SUPPLIES, SPARK_REPAIRBAY_ALLOYS, SPARK_REPAIRBAY_ELERIUM, SPARK_REPAIRBAY_CORES, SPARK_REPAIRBAY_DAYS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	// ALWAYS add the default slot
	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 1)
	{
		Techs.AddItem(CreateExpandRepairBayTemplate('ExpandRepairBay','SparkStaffSlot1'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 2)
	{
		Techs.AddItem(CreateExpandRepairBayTemplate('ExpandRepairBay2','SparkStaffSlot2','ExpandRepairBay'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 3)
	{
		Techs.AddItem(CreateExpandRepairBayTemplate('ExpandRepairBay3','SparkStaffSlot3','ExpandRepairBay2'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 4)
	{
		Techs.AddItem(CreateExpandRepairBayTemplate('ExpandRepairBay4','SparkStaffSlot4','ExpandRepairBay3'));
	}

	return Techs;
}

static function X2DataTemplate CreateExpandRepairBayTemplate(name TemplateName, name SlotName, optional name RequiredName)
{
	local X2TechTemplate Template;
	local StrategyRequirement AltReq;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, TemplateName);
	Template.PointsToComplete = StafferXDays(1, default.SPARK_REPAIRBAY_DAYS);
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_RustySPARKBay.BayExpansion";

	Template.bProvingGround = true;
	Template.bRepeatable = false;
	Template.ResearchCompletedFn = UnlockRepairSlot;
	
	// Narrative Requirements
	Template.Requirements.SpecialRequirementsFn = class'X2Helpers_DLC_Day90'.static.IsLostTowersNarrativeContentComplete;
	Template.Requirements.RequiredTechs.AddItem('AutopsyAdventMEC');

	if (RequiredName != '')
	{
		Template.Requirements.RequiredTechs.AddItem(RequiredName);
	}

	// Non Narrative Requirements
	AltReq.RequiredTechs.AddItem('MechanizedWarfare');
	AltReq.RequiredTechs.AddItem('AutopsyAdventMEC');
	if (RequiredName != '')
	{
		AltReq.RequiredTechs.AddItem(RequiredName);
	}
	Template.AlternateRequirements.AddItem(AltReq);
	
	// Costs
	if (default.SPARK_REPAIRBAY_SUPPLIES > 0)
	{
		Resources.ItemTemplateName = 'Supplies';
		Resources.Quantity = default.SPARK_REPAIRBAY_SUPPLIES; //25
		Template.Cost.ResourceCosts.AddItem(Resources);
	}

	if (default.SPARK_REPAIRBAY_ALLOYS > 0)
	{
		Resources.ItemTemplateName = 'AlienAlloy';
		Resources.Quantity = default.SPARK_REPAIRBAY_ALLOYS; //15
		Template.Cost.ResourceCosts.AddItem(Resources);
	}

	if (default.SPARK_REPAIRBAY_ELERIUM > 0)
	{
		Resources.ItemTemplateName = 'EleriumDust';
		Resources.Quantity = default.SPARK_REPAIRBAY_ELERIUM; //5
		Template.Cost.ResourceCosts.AddItem(Resources);
	}

	if (default.SPARK_REPAIRBAY_CORES > 0)
	{
		Resources.ItemTemplateName = 'EleriumCore';
		Resources.Quantity = default.SPARK_REPAIRBAY_CORES; //0
		Template.Cost.ResourceCosts.AddItem(Resources);
	}

	return Template;
}

static function UnlockRepairSlot(XComGameState NewGameState, XComGameState_Tech TechState)
{
    local XComGameState_StaffSlot StaffSlotState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom Facility;
    local int i;

    XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	Facility = XComHQ.GetFacilityByName('Storage');

    for (i = 0; i < Facility.StaffSlots.Length; i++)
    {
        StaffSlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(Facility.StaffSlots[i].ObjectID));
        if (StaffSlotState.IsLocked() )
		{
			if (StaffSlotState.GetMyTemplateName() == 'SparkStaffSlot1' && TechState.GetMyTemplateName() == 'ExpandRepairBay')
			{
				StaffSlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Facility.StaffSlots[i].ObjectID));
				StaffSlotState.UnlockSlot();
				`log("SPARK REPAIR SLOT UNLOCKED" @StaffSlotState.GetMyTemplateName() @TechState.GetMyTemplateName(),class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
				return;
			}

			if (StaffSlotState.GetMyTemplateName() == 'SparkStaffSlot2' && TechState.GetMyTemplateName() == 'ExpandRepairBay2')
			{
				StaffSlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Facility.StaffSlots[i].ObjectID));
				StaffSlotState.UnlockSlot();
				`log("SPARK REPAIR SLOT UNLOCKED" @StaffSlotState.GetMyTemplateName() @TechState.GetMyTemplateName(),class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
				return;
			}

			if (StaffSlotState.GetMyTemplateName() == 'SparkStaffSlot3' && TechState.GetMyTemplateName() == 'ExpandRepairBay3')
			{
				StaffSlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Facility.StaffSlots[i].ObjectID));
				StaffSlotState.UnlockSlot();
				`log("SPARK REPAIR SLOT UNLOCKED" @StaffSlotState.GetMyTemplateName() @TechState.GetMyTemplateName(),class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
				return;
			}

			if (StaffSlotState.GetMyTemplateName() == 'SparkStaffSlot4' && TechState.GetMyTemplateName() == 'ExpandRepairBay4')
			{
				StaffSlotState = XComGameState_StaffSlot(NewGameState.ModifyStateObject(class'XComGameState_StaffSlot', Facility.StaffSlots[i].ObjectID));
				StaffSlotState.UnlockSlot();
				`log("SPARK REPAIR SLOT UNLOCKED" @StaffSlotState.GetMyTemplateName() @TechState.GetMyTemplateName(),class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
				return;
			}
		}
    }
}

static function int StafferXDays(int iNumScientists, int iNumDays)
{
	return (iNumScientists * 5) * (24 * iNumDays); // Scientists at base skill level
}


//this function is run on completion of Mechatronic Warfare
static function CreateSparkSetup(XComGameState NewGameState, XComGameState_Tech TechState)
{
	class'X2Helpers_DLC_Day90'.static.CreateSparkEquipment(NewGameState);

	class'X2Helpers_DLC_Day90'.static.CreateSparkSoldier(NewGameState, , TechState);

	//UnlockRepairSlot(NewGameState, TechState);

	//UNLOCK MORE SLOTS BY DEFAULT ?
	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_INITIALSLOTS >= 1)
	{
		InitialSlotUnlock('ExpandRepairBay', NewGameState);
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_INITIALSLOTS >= 2)
	{
		InitialSlotUnlock('ExpandRepairBay2', NewGameState);
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_INITIALSLOTS >= 3)
	{
		InitialSlotUnlock('ExpandRepairBay3', NewGameState);
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_INITIALSLOTS >= 4)
	{
		InitialSlotUnlock('ExpandRepairBay4', NewGameState);
	}

}

static function InitialSlotUnlock(name TechName, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState ThisGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Tech TechState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if(TechState.GetMyTemplateName() == TechName)
		{
			ThisGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Unlock Initial Repair Slots");
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
			TechState = XComGameState_Tech(NewGameState.ModifyStateObject(class'XComGameState_Tech', TechState.ObjectID));
			TechState.TimesResearched++;
			XComHQ.TechsResearched.AddItem(TechState.GetReference());
			TechState.bSeenResearchCompleteScreen = true;

			if(TechState.GetMyTemplate().ResearchCompletedFn != none)
			{
				TechState.GetMyTemplate().ResearchCompletedFn(NewGameState, TechState);
			}

			`XEVENTMGR.TriggerEvent('ResearchCompleted', TechState, TechState, NewGameState);

			if( ThisGameState.GetNumGameStateObjects() > 0 )
			{
				//Commit the state change into the history.
				History.AddGameStateToHistory(ThisGameState);
			}
			else
			{
				History.CleanupPendingGameState(NewGameState);
			}

			`log("INITIAL SPARK REPAIR SLOT UNLOCKED" @TechState.GetMyTemplateName(),class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');

			break;
		}
	}
}
