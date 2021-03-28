//*******************************************************************************************
//  FILE:   XComDownloadableContentInfo_WOTC_MoreEngineeringRepairSlots.uc                                    
//  
//	File created by RustyDios	12/07/20	17:00	
//	LAST UPDATED				14/07/20	11:15
//
//	ADDS SPARK SLOTS AND TECHS TO THE GAME, PRETTY MUCH COPIED FROM 
//		NOTSOLONEWOLF'S MECHATRONIC WARFARE
//
//*******************************************************************************************

class X2DownloadableContentInfo_WOTC_MoreEngineeringRepairSlots extends X2DownloadableContentInfo;

var config int SPARK_REPAIRBAY_NUMSLOTS;
var config int SPARK_REPAIRBAY_INITIALSLOTS;

var config bool bENABLE_SPARK_REPAIRBAY_LOG;

static event OnLoadedSavedGame()
{
	PatchSparkTechs();
	PatchSparkSlots();
}

static event OnLoadedSavedGameToStrategy()
{
	PatchSparkTechs();
	PatchSparkSlots();
}

static event OnPostTemplatesCreated()
{
	PatchRepairFacility();
	PatchMechWar();
}

//================================================================================================================
// TECHNOLOGIES
//================================================================================================================

static function PatchSparkTechs()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local X2TechTemplate TechTemplate;
	local X2StrategyElementTemplateManager	StratMgr;

	//This adds the techs to games that installed the mod in the middle of a campaign.
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	History = `XCOMHISTORY;	

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Expand SPARK Bay Templates");

	//Find tech templates
	if ( !IsResearchInHistory('ExpandRepairBay') && default.SPARK_REPAIRBAY_NUMSLOTS >= 1)
	{
		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('ExpandRepairBay'));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('ExpandRepairBay2') && default.SPARK_REPAIRBAY_NUMSLOTS >= 2)
	{
		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('ExpandRepairBay2'));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('ExpandRepairBay3') && default.SPARK_REPAIRBAY_NUMSLOTS >= 3)
	{
		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('ExpandRepairBay3'));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('ExpandRepairBay4') && default.SPARK_REPAIRBAY_NUMSLOTS >= 4)
	{
		TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('ExpandRepairBay4'));
		NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if( NewGameState.GetNumGameStateObjects() > 0 )
	{
		//Commit the state change into the history.
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static function bool IsResearchInHistory(name ResearchName)
{
	// Check if we've already injected the tech templates
	local XComGameState_Tech	TechState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplateName() == ResearchName )
		{
			return true;
		}
	}
	return false;
}

//================================================================================================================
// STAFF SLOTS
//================================================================================================================

// Thanks to RealityMachina for figuring out how to add new repair slots
static function PatchSparkSlots()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local X2FacilityTemplate FacilityTemplate;
	local XComGameState_StaffSlot StaffSlotState, ExistingStaffSlot, LinkedStaffSlotState;
	local X2StaffSlotTemplate StaffSlotTemplate;
	local StaffSlotDefinition SlotDef;
	local int i, j;
	local bool bReplaceSlot, DidChange;
	local X2StrategyElementTemplateManager StratMgr;
	local array<int> SkipIndices;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rusty SPARK Slots -- Adding New Slots");

	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	
	FacilityState = XComHQ.GetFacilityByName('Storage');
	if (FacilityState != none)
	{
		FacilityState = XComGameState_FacilityXCom(NewGameState.ModifyStateObject(class'XComGameState_FacilityXCom', FacilityState.ObjectID));
		FacilityTemplate = FacilityState.GetMyTemplate();

		for (i = 0; i < FacilityTemplate.StaffSlotDefs.Length; i++)
		{
			if(SkipIndices.Find(i) == INDEX_NONE)
			{
				SlotDef = FacilityTemplate.StaffSlotDefs[i];
				// Check to see if the existing staff slot at this index no longer matches the template and needs to be replaced
				bReplaceSlot = false;
				if(i < FacilityState.StaffSlots.Length && FacilityState.StaffSlots[i].ObjectID != 0)
				{
					ExistingStaffSlot = FacilityState.GetStaffSlot(i);
					if(ExistingStaffSlot.GetMyTemplateName() != SlotDef.StaffSlotTemplateName)
					{
						bReplaceSlot = true;
					}
				}
				
				if(i >= FacilityState.StaffSlots.Length || bReplaceSlot) // Only add a new staff slot if it doesn't already exist or needs to be replaced
				{
					StaffSlotTemplate = X2StaffSlotTemplate(StratMgr.FindStrategyElementTemplate(SlotDef.StaffSlotTemplateName));
					DidChange = true;
					
					if(StaffSlotTemplate != none)
					{
						// Create slot state and link to this facility
						StaffSlotState = StaffSlotTemplate.CreateInstanceFromTemplate(NewGameState);
						StaffSlotState.Facility = FacilityState.GetReference();

						// Check for starting the slot locked
						if(SlotDef.bStartsLocked)
						{
							StaffSlotState.LockSlot();
						}

						if(bReplaceSlot)
						{
							FacilityState.StaffSlots[i] = StaffSlotState.GetReference();
						}
						else
						{
							FacilityState.StaffSlots.AddItem(StaffSlotState.GetReference());
						}
						
						// Check rest of list for partner slot
						if(SlotDef.LinkedStaffSlotTemplateName != '')
						{
							StaffSlotTemplate = X2StaffSlotTemplate(StratMgr.FindStrategyElementTemplate(SlotDef.LinkedStaffSlotTemplateName));

							if(StaffSlotTemplate != none)
							{
								for(j = (i + 1); j < FacilityTemplate.StaffSlotDefs.Length; j++)
								{
									SlotDef = FacilityTemplate.StaffSlotDefs[j];

									if(SkipIndices.Find(j) == INDEX_NONE && SlotDef.StaffSlotTemplateName == StaffSlotTemplate.DataName)
									{
										// Check to see if the existing staff slot at this index no longer matches the template and needs to be replaced
										bReplaceSlot = false;
										if(j < FacilityState.StaffSlots.Length && FacilityState.StaffSlots[j].ObjectID != 0)
										{
											ExistingStaffSlot = FacilityState.GetStaffSlot(j);
											if(ExistingStaffSlot.GetMyTemplateName() != SlotDef.StaffSlotTemplateName)
											{
												bReplaceSlot = true;
											}
										}

										if(j >= FacilityState.StaffSlots.Length || bReplaceSlot) // Only add a new staff slot if it doesn't already exist or needs to be replaced
										{
											// Create slot state and link to this facility
											LinkedStaffSlotState = StaffSlotTemplate.CreateInstanceFromTemplate(NewGameState);
											LinkedStaffSlotState.Facility = FacilityState.GetReference();

											// Check for starting the slot locked
											if(SlotDef.bStartsLocked)
											{
												LinkedStaffSlotState.LockSlot();
											}

											// Link the slots
											StaffSlotState.LinkedStaffSlot = LinkedStaffSlotState.GetReference();
											LinkedStaffSlotState.LinkedStaffSlot = StaffSlotState.GetReference();

											if(bReplaceSlot)
											{
												FacilityState.StaffSlots[j] = LinkedStaffSlotState.GetReference();
											}
											else
											{
												FacilityState.StaffSlots.AddItem(LinkedStaffSlotState.GetReference());
											}

											// Add index to list to be skipped since we already added it
											SkipIndices.AddItem(j);
											break;
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if (NewGameState.GetNumGameStateObjects() > 0 && DidChange)
	{
		XComGameInfo(class'Engine'.static.GetCurrentWorldInfo().Game).GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHistory.CleanupPendingGameState(NewGameState);
	}

}

static function PatchRepairFacility()
{
	local X2FacilityTemplate FacilityTemplate;
	local array<X2FacilityTemplate> FacilityTemplates;
	local StaffSlotDefinition StaffSlotDef,StaffSlotDef1, StaffSlotDef2, StaffSlotDef3, StaffSlotDef4;

	FindFacilityTemplateAllDifficulties('Storage', FacilityTemplates);

	foreach FacilityTemplates(FacilityTemplate)
	{
		//remove and replace the original 2 slots
		FacilityTemplate.StaffSlotDefs.length = 0;

		StaffSlotDef.StaffSlotTemplateName = 'SparkStaffSlot';
		StaffSlotDef.bStartsLocked = false;
		FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef);
		FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef);

		`log("REPAIR FACILITY PATCHED ORIGINAL SLOT",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');

		//add additional slots per the config
		if (default.SPARK_REPAIRBAY_NUMSLOTS >= 1)
		{
			StaffSlotDef1.StaffSlotTemplateName = 'SparkStaffSlot1';
			StaffSlotDef1.bStartsLocked = true;

			FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef1);
			`log("REPAIR FACILITY PATCHED WITH 1ST SLOT",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');

		}

		if (default.SPARK_REPAIRBAY_NUMSLOTS >= 2)
		{
			StaffSlotDef2.StaffSlotTemplateName = 'SparkStaffSlot2';
			StaffSlotDef2.bStartsLocked = true;

			FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef2);
			`log("REPAIR FACILITY PATCHED WITH 2ND SLOT",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');

		}
		
		if (default.SPARK_REPAIRBAY_NUMSLOTS >= 3)
		{
			StaffSlotDef3.StaffSlotTemplateName = 'SparkStaffSlot3';
			StaffSlotDef3.bStartsLocked = true;

			FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef3);
			`log("REPAIR FACILITY PATCHED WITH 3RD SLOT",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');

		}

		if (default.SPARK_REPAIRBAY_NUMSLOTS >= 4)
		{
			StaffSlotDef4.StaffSlotTemplateName = 'SparkStaffSlot4';
			StaffSlotDef4.bStartsLocked = true;

			FacilityTemplate.StaffSlotDefs.AddItem(StaffSlotDef4);
			`log("REPAIR FACILITY PATCHED WITH 4TH SLOT",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
		}

		`log("REPAIR FACILITY DIFF TEMPLATE PATCHED" @FacilityTemplate.DataName ,default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
	}
}

//retrieves all difficulty variants of a given facility template
static function FindFacilityTemplateAllDifficulties(name DataName, out array<X2FacilityTemplate> FacilityTemplates, optional X2StrategyElementTemplateManager StrategyTemplateMgr)
{
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate;
	local X2FacilityTemplate FacilityTemplate;

	if(StrategyTemplateMgr == none)
		StrategyTemplateMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	StrategyTemplateMgr.FindDataTemplateAllDifficulties(DataName, DataTemplates);
	FacilityTemplates.Length = 0;
	foreach DataTemplates(DataTemplate)
	{
		FacilityTemplate = X2FacilityTemplate(DataTemplate);
		if( FacilityTemplate != none )
		{
			FacilityTemplates.AddItem(FacilityTemplate);
		}
	}
}

//================================================================================================================
// UNLOCK SLOTS WITH MECHATRONIC WARFARE && CREATE A SPARK && UNLOCK SPARK EQUIPMENT
//================================================================================================================

static function PatchMechWar()
{
	local X2StrategyElementTemplateManager      AllItems;
	local X2TechTemplate						CurrentSchematic;

	// Find the schematic template
	AllItems = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	CurrentSchematic = X2TechTemplate(AllItems.FindStrategyElementTemplate('MechanizedWarfare'));
	
	if ( CurrentSchematic != none )
	{
		CurrentSchematic.ResearchCompletedFn = class'X2StrategyElement_TechsMW_Rusty'.static.CreateSparkSetup;
		`log("MECHWAR PROJECT PATCHED",default.bENABLE_SPARK_REPAIRBAY_LOG,'MW_RUSTY_SPARKSLOTS');
	}
}
