//*******************************************************************************************
//  FILE:   X2StrategyElement_StaffSlotsMW_Rusty.uc                                    
//  
//	File created by RustyDios	12/07/20	17:00	
//	LAST UPDATED				02/09/20	21:30
//
//	ADDS SPARK SLOTS AND TECHS TO THE GAME, PRETTY MUCH COPIED FROM 
//		NOTSOLONEWOLF'S MECHATRONIC WARFARE
//
//*******************************************************************************************

class X2StrategyElement_StaffSlotsMW_Rusty extends X2StrategyElement config (Game);

var config array<name> ExtraSparkSoldierTemplatesForSlot;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	// OVERRIDE default slot added by the dlc
	StaffSlots.AddItem(CreateSparkStaffSlotTemplate('SparkStaffSlot'));

	//ADDITIONAL SLOTS FROM THIS MOD
	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 0)
	{
		StaffSlots.AddItem(CreateSparkStaffSlotTemplate('SparkStaffSlot1'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 2)
	{
		StaffSlots.AddItem(CreateSparkStaffSlotTemplate('SparkStaffSlot2'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 3)
	{
		StaffSlots.AddItem(CreateSparkStaffSlotTemplate('SparkStaffSlot3'));
	}

	if (class'X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots'.default.SPARK_REPAIRBAY_NUMSLOTS >= 4)
	{
		StaffSlots.AddItem(CreateSparkStaffSlotTemplate('SparkStaffSlot4'));
	}

	return StaffSlots;
}

static function X2DataTemplate CreateSparkStaffSlotTemplate(name TemplateName)
{
	local X2StaffSlotTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, TemplateName);
	Template = class'X2StrategyElement_DefaultStaffSlots'.static.CreateStaffSlotTemplate(TemplateName);
	Template.bHideStaffSlot = false;
	Template.bPreventFilledPopup = true;
	Template.bSoldierSlot = true;
	Template.AssociatedProjectClass = class'XComGameState_HeadquartersProjectHealSpark';
	Template.FillFn = class'X2StrategyElement_DLC_Day90StaffSlots'.static.FillSparkSlot;
	Template.EmptyFn = class'X2StrategyElement_DLC_Day90StaffSlots'.static.EmptySparkSlot;
	Template.ShouldDisplayToDoWarningFn = class'X2StrategyElement_DLC_Day90StaffSlots'.static.ShouldDisplaySparkToDoWarning;
	Template.GetSkillDisplayStringFn = class'X2StrategyElement_DLC_Day90StaffSlots'.static.GetSparkSkillDisplayString;
	Template.GetBonusDisplayStringFn = class'X2StrategyElement_DLC_Day90StaffSlots'.static.GetSparkBonusDisplayString;
	Template.IsUnitValidForSlotFn = IsUnitValidForSparkSlot_Extra; //class'X2StrategyElement_DLC_Day90StaffSlots'.static.IsUnitValidForSparkSlot;
	Template.MatineeSlotName = "Spark";

	return Template;
}


static function bool IsUnitValidForSparkSlot_Extra(XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	// Ensure that the unit is not already in this slot, and is an injured Spark soldier
	if (Unit.IsAlive()
		&& Unit.GetMyTemplate().bStaffingAllowed
		&& Unit.GetReference().ObjectID != SlotState.GetAssignedStaffRef().ObjectID
		&& Unit.IsSoldier()
		&& Unit.IsInjured()
		&& (Unit.GetMyTemplateName() == 'SparkSoldier' || default.ExtraSparkSoldierTemplatesForSlot.Find(Unit.GetMyTemplateName() ) != INDEX_NONE  ) )
		//	|| Unit.GetMyTemplateName() == 'BU_JunkSpark'   || Unit.GetMyTemplateName() == 'BU_ResistanceMec' || Unit.GetMyTemplateName() == 'BU_MecArcher' || Unit.GetMyTemplateName() == 'BU_MecPyroclast'
		//	|| Unit.GetMyTemplateName() == 'BU_AdventDrone' || Unit.GetMyTemplateName() == 'BU_HunterDrone'   || Unit.GetMyTemplateName() == 'BU_EnigmaDrone' 
		//	|| Unit.GetMyTemplateName() == 'BioMecSoldier'  || Unit.GetMyTemplateName() == 'RiotMecSoldier'
		//)	)	 // Only injured SPARKs can be staffed here to heal	... as well as buildable units from kiruka and mr shadow cx
		{
			return true;
		}

	return false;
}

