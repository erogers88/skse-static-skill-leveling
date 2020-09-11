scriptname StaticSkillLevelingEffectScript extends ActiveMagicEffect
{This script checks for a level up when the player wakes from sleep and allows them to assign skillpoints}

;==========================================
;Initialization Properties
;==========================================

Message property InitializationMessage auto
{This is the message that shows when the mod first starts}

;==========================================
;Player Level Properties
;==========================================

int property TrackedPlayerLevel auto
{This tracks the players level}
int property CurrentPlayerLevel auto
{This is the current players level}

;==========================================
;Player Skill Properties
;==========================================

int property MaxSkillLevelBaseDefault auto
{This is the base value for the players max skills, default 18}
int property MaxSkillLevelMultiplier auto
{This is the number added to the players allowable max every level, default 2}
int property MaxSkillLevelTotal auto
{This is the final maximum skill level, default 100}
int property MaxLevelsPerSkillPerPlayerLevel auto
{The maximum number of skill levels a player can gain per level for one skill}
string[] property SkillNames auto
{These are the names of the skills}
int[] property BaseSkillLevels auto
{These are the base values of the players skills}
int[] property MaxSkillLevels auto
{These are the max values of the players skills}
int[] property SkillIncreases auto
{This tracks the number of increases of each skill per levelup}
int[] property SkillLevelRacialBonuses auto
{These are the racial bonuses for the players skills}
int[] property SkillBethesdaIndex auto
{This is a lookup to map from my skill ordering to Bethesdas}

;==========================================
;Skillpoint Related Properties
;==========================================

int property CurrentSkillPointsGained auto
{This is the number of current skill points remaining to allocate}
int property SkillPointsPerLevel auto
{This is the base number of skillpoints gained per level}
int property SkillPointsLevelMultiplier auto
{This is the multiplier added to the base number of skillpoints per level}
int property SkillPointCost0 auto
{This is the cost of raising a skill to 25}
int property SkillPointCost25 auto
{This is the cost of raising a skill from 25-50}
int property SkillPointCost50 auto
{This is the cost of raising a skill from 50-75}
int property SkillPointCost75 auto
{This is the cost of raising a skill above 75}

;==========================================
;Level Up Menu Properties
;==========================================

Message Property MagicSkillMenu auto
{Menu to display on leveling Magic skills}
Message Property WarriorSkillMenu auto
{Menu to display on leveling Warrior Skills}
Message Property ThiefSkillMenu auto
{Menu to display on leveling Thief Skills}
Message property DoneMenu auto
{This is the message that confirm the completion of skill assignment}
Message property HelpMenu1 auto
{This is page 1 of the help menu that appears when a user clicks Help}
Message property HelpMenu2 auto
{This is page 2 of the help menu that appears when a user clicks Help}
Message property HelpMenu3 auto
{This is page 3 of the help menu that appears when a user clicks Help}
Message property HelpMenu4 auto
{This is page 4 of the help menu that appears when a user clicks Help}
Message property HelpMenu5 auto
{This is page 5 of the help menu that appears when a user clicks Help}
Message property NotEnoughSkillPointsMenu auto
{This is the message that appears when a user does not have enough points to level a skill}
Message property SkillIsAtMaxLevelMenu auto
{This is the message that appears when a user tries to level a skill above max level}
Message property SkillIncreasesAtMaxMenu auto
{This is the message that appears when a player has increases the skill the max times for that skill per level}

;==============================================================================================================

;==========================================
;Register for sleep and track player level
;==========================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Initialization()
EndEvent

;==========================================
;Set racial bonuses if player changed race
;==========================================

Event OnMenuClose(string menuName)
    if (menuName == "RaceSex Menu" && CurrentPlayerLevel == 1)
        SetInitialSkills()
    else
        UnregisterForMenu("RaceSex Menu")
    endif
EndEvent

;============================================
;Main handler for leveling after sleep
;============================================

Event OnSleepStop(bool abInterrupted)
    if (abInterrupted)
    ;do nothing if interrupted
    else
        Utility.Wait(1)
        CurrentPlayerLevel = Game.GetPlayer().GetLevel()
            if (CurrentPlayerLevel > TrackedPlayerLevel)
                AddSkills()       
            endif   
	endIf
endEvent

;============================================
;Menu Functions
;============================================

Function AddSkills()
    SetSkillBethesdaIndex()
    
    CurrentSkillPointsGained = CurrentSkillPointsGained + CalculateSkillPointsGained()
    int LevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
    SetSkillIncreasesBaselineIndex()
    TrackedPlayerLevel = CurrentPlayerLevel

    SetBaseSkillLevels()
    SetMaxSkillLevels()

    int IndexOfCurrentSelectedSkill
    int LevelOfCurrentSelectedSkill
    bool HasEnoughSkillPointsToIncreaseSkill
    bool SkillIsBelowMaxLevel
    bool SkillIncreasesBelowMax

    int CurrentMenu = 0
    int OptionDoneMenu
    int Option = 10
    while(Option != 8);didn't exit
        Option = DisplaySkillMenu(CurrentMenu)
        ;change menu if player picked another one
    	if(Option == 0)
            if(CurrentMenu == 0)
                CurrentMenu = 2
            elseif(CurrentMenu == 1)
                CurrentMenu = 0
            else
                CurrentMenu = 1
            endif
        elseif(Option == 7)
            if(CurrentMenu == 0)
                CurrentMenu = 1
            elseif(CurrentMenu == 1)
                CurrentMenu = 2
            else
                CurrentMenu = 0
            endif           

        ;if player selected a skill to level
        elseif(Option >= 1 && Option <= 6)
            IndexOfCurrentSelectedSkill = GetSkillNameIndex(CurrentMenu, Option)
            ;This is the index of the selected skill
            LevelOfCurrentSelectedSkill = BaseSkillLevels[IndexOfCurrentSelectedSkill]
            ;This is the level of the selected skill
            HasEnoughSkillPointsToIncreaseSkill = CheckEnoughSkillPointsToIncreaseSkill(LevelOfCurrentSelectedSkill)
            SkillIsBelowMaxLevel = CheckSkillIsBelowMaxLevel(IndexOfCurrentSelectedSkill)
            SkillIncreasesBelowMax = CheckSkillIncreasesBelowMax(IndexOfCurrentSelectedSkill, LevelsGained)
            if(SkillIsBelowMaxLevel == false)
                SkillIsAtMaxLevelMenu.show()
            elseif(SkillIncreasesBelowMax == false)
                SkillIncreasesAtMaxMenu.show()
            elseif(HasEnoughSkillPointsToIncreaseSkill == false)
                NotEnoughSkillPointsMenu.show()
            endif
            ;Do you have enough skill points?
            ;Is the skill you are trying to increase below max level?
            ;Have you already increased the skill the maximum number of times?
            if(HasEnoughSkillPointsToIncreaseSkill && SkillIsBelowMaxLevel && SkillIncreasesBelowMax)
                Game.IncrementSkill(SkillNames[IndexOfCurrentSelectedSkill])
                ActorValueInfo.GetActorValueInfoByName(SkillNames[IndexOfCurrentSelectedSkill]).SetSkillExperience(0.0)
                CurrentSkillPointsGained = CurrentSkillPointsGained - SkillPointCostToIncreaseSkill(LevelOfCurrentSelectedSkill)
                BaseSkillLevels[IndexOfCurrentSelectedSkill] = BaseSkillLevels[IndexOfCurrentSelectedSkill] + 1
                SkillIncreases[IndexOfCurrentSelectedSkill] = SkillIncreases[IndexOfCurrentSelectedSkill] + 1
            endif

        ;if player is done
        elseif(Option == 8)
            OptionDoneMenu = DisplayDoneMenu()
            if(OptionDoneMenu == 1)
                ;set != 8 to cancel done
                Option = 10
            else
            ;player confirms done
            endif

        elseif(Option == 9)
            DisplayHelpMenu()
            Option = 10

        endif
    endWhile
EndFunction


int Function DisplaySkillMenu(int menuNumber)
	int returnValue
    if(menuNumber == 0)
		returnValue = MagicSkillMenu.show(CurrentPlayerLevel, CurrentSkillPointsGained, BaseSkillLevels[0], BaseSkillLevels[1], BaseSkillLevels[2], BaseSkillLevels[3], BaseSkillLevels[4], BaseSkillLevels[5])
	elseif(menuNumber == 1)
        returnValue = WarriorSkillMenu.show(CurrentPlayerLevel, CurrentSkillPointsGained, BaseSkillLevels[12], BaseSkillLevels[13], BaseSkillLevels[14], BaseSkillLevels[15], BaseSkillLevels[16], BaseSkillLevels[17])
	else
		returnValue = ThiefSkillMenu.show(CurrentPlayerLevel, CurrentSkillPointsGained, BaseSkillLevels[6], BaseSkillLevels[7], BaseSkillLevels[8], BaseSkillLevels[9], BaseSkillLevels[10], BaseSkillLevels[11])
	endif
    return returnValue
EndFunction

int Function DisplayDoneMenu()
    int returnValue
    returnValue = DoneMenu.show()
    return returnValue
EndFunction

Function DisplayHelpMenu()
    HelpMenu1.show()
    HelpMenu2.show(SkillPointsPerLevel, SkillPointsLevelMultiplier)
    HelpMenu3.show(SkillPointCost0, SkillPointCost25, SkillPointCost50, SkillPointCost75)
    HelpMenu4.show()
    HelpMenu5.show(MaxSkillLevelBaseDefault, MaxSkillLevelMultiplier)
EndFunction

int Function CalculateSkillPointsGained()
    int SkillPointsToReturn = 0
    int LevelCounter = TrackedPlayerLevel
    while (LevelCounter < CurrentPlayerLevel)
        LevelCounter += 1
        SkillPointsToReturn = SkillPointsToReturn + SkillPointsPerLevel + (LevelCounter * SkillPointsLevelMultiplier)
    endWhile
    return SkillPointsToReturn
EndFunction

int Function GetSkillNameIndex(int menuNumber, int Option)
    int tempIndex = Option - 1 + menuNumber * 6
    return SkillBethesdaIndex[tempIndex]
    ;This calculates the index in the skill arrays based on the menu option, and also accounts for a lookup to Bethesda ordering
EndFunction

bool Function CheckEnoughSkillPointsToIncreaseSkill(int levelOfSkill)
    if(levelOfSkill < 25)
        if(CurrentSkillPointsGained >= SkillPointCost0)
            return true
        else
            return false
        endif
    elseif(levelOfSkill >= 25 && levelOfSkill < 50)
        if(CurrentSkillPointsGained >= SkillPointCost25)
            return true
        else
            return false
        endif
    elseif(levelOfSkill >= 50 && levelOfSkill < 75)
        if(CurrentSkillPointsGained >= SkillPointCost50)
            return true
        else
            return false
        endif
    elseif(levelOfSkill >= 75)
        if(CurrentSkillPointsGained >= SkillPointCost75)
            return true
        else
            return false   
        endif
    endif
EndFunction

bool Function CheckSkillIsBelowMaxLevel(int skillIndexNumber)
    if(BaseSkillLevels[skillIndexNumber] < MaxSkillLevels[skillIndexNumber] && BaseSkillLevels[skillIndexNumber] < MaxSkillLevelTotal)
        return true
    else
        return false
    endif
EndFunction

bool Function CheckSkillIncreasesBelowMax(int skillIndexNumber, int levelsGained)
    int NumTimesAllowedToLevelSkill = levelsGained * MaxLevelsPerSkillPerPlayerLevel
    if (SkillIncreases[skillIndexNumber] < NumTimesAllowedToLevelSkill)
        return true
    else
        return false
    endif
EndFunction

int Function SkillPointCostToIncreaseSkill(int levelOfSkill)
    if(levelOfSkill < 25)
        return SkillPointCost0
    elseif(levelOfSkill >= 25 && levelOfSkill < 50)
        return SkillPointCost25
    elseif(levelOfSkill >= 50 && levelOfSkill < 75)
        return SkillPointCost50
    elseif(levelOfSkill >= 75)
        return SkillPointCost75 
    endif
EndFunction

;============================================
;Setup Functions
;============================================

Function Initialization()	
    ;set initial player levels
    int tempPlayerLevel = Game.GetPlayer().GetLevel()
    CurrentPlayerLevel = tempPlayerLevel
    TrackedPlayerLevel = tempPlayerLevel
    CurrentSkillPointsGained = 0

    ;set trigger for sleep
    RegisterForSleep()  

    ;set trigger for racemenu closing
    RegisterForMenu("RaceSex Menu")

    ;set initial skill values
    SetInitialSkills()

    ;display confirmation message
    InitializationMessage.show()
EndFunction

Function SetInitialSkills()
    ;set base skill names, base skill levels, and max skill levels
    SetBaseSkillNames()
    SetBaseSkillLevels()
    SetRacialBonuses()
    SetMaxSkillLevels()
EndFunction

Function SetBaseSkillNames()
    string[] tempSkillNames = new string[18]
    tempSkillNames[0] = "Alteration"
	tempSkillNames[1] = "Conjuration"
	tempSkillNames[2] = "Destruction"
	tempSkillNames[3] = "Enchanting"
	tempSkillNames[4] = "Illusion"
	tempSkillNames[5] = "Restoration"
	tempSkillNames[6] = "Alchemy"
	tempSkillNames[7] = "LightArmor"
	tempSkillNames[8] = "Lockpicking"
	tempSkillNames[9] = "Pickpocket"
	tempSkillNames[10] = "Sneak"
	tempSkillNames[11] = "Speechcraft"
	tempSkillNames[12] = "Marksman"
	tempSkillNames[13] = "Block"
	tempSkillNames[14] = "HeavyArmor"
	tempSkillNames[15] = "OneHanded"
	tempSkillNames[16] = "Smithing"
	tempSkillNames[17] = "TwoHanded"  
    SkillNames = tempSkillNames
EndFunction

Function SetSkillBethesdaIndex()
    int[] tempSkillIndexNumbers = new int[18]
    tempSkillIndexNumbers[0] = 4
    tempSkillIndexNumbers[1] = 1
    tempSkillIndexNumbers[2] = 2
    tempSkillIndexNumbers[3] = 5
    tempSkillIndexNumbers[4] = 0
    tempSkillIndexNumbers[5] = 3
    tempSkillIndexNumbers[6] = 16
    tempSkillIndexNumbers[7] = 14
    tempSkillIndexNumbers[8] = 13
    tempSkillIndexNumbers[9] = 17
    tempSkillIndexNumbers[10] = 15
    tempSkillIndexNumbers[11] = 12
    tempSkillIndexNumbers[12] = 7
    tempSkillIndexNumbers[13] = 10
    tempSkillIndexNumbers[14] = 8
    tempSkillIndexNumbers[15] = 9
    tempSkillIndexNumbers[16] = 11
    tempSkillIndexNumbers[17] = 6
    SkillBethesdaIndex = tempSkillIndexNumbers
EndFunction

Function SetBaseSkillLevels()
    int valueOfBaseSkill   
    int[] tempBaseSkillLevels = new int[18] 
    int i = 0
    while(i < 18)
        valueOfBaseSkill = Game.GetPlayer().GetBaseActorValue(SkillNames[i]) as int
        tempBaseSkillLevels[i] = valueOfBaseSkill
        i += 1
    endWhile
    BaseSkillLevels = tempBaseSkillLevels
EndFunction

Function SetMaxSkillLevels()
    int[] tempMaxSkillLevels = new int[18]
    int i = 0
    while(i < 18)
        tempMaxSkillLevels[i] = MaxSkillLevelBaseDefault + (CurrentPlayerLevel * MaxSkillLevelMultiplier) + SkillLevelRacialBonuses[i]
        i += 1
    endWhile
    MaxSkillLevels = tempMaxSkillLevels
EndFunction

Function SetSkillIncreasesBaselineIndex()
    int[] tempSkillIncreases = new int[18]
    int i = 0
    while (i < 18)
        SkillIncreases[i] = 0
        i += 1
    endWhile
    SkillIncreases = tempSkillIncreases
EndFunction

Function SetRacialBonuses()
    int[] tempSkillLevelRacialBonuses = new int[18]
    int r = 0
    while(r < 18)
        if(BaseSkillLevels[r] > 18)
            if(BaseSkillLevels[r] > 20)
                tempSkillLevelRacialBonuses[r] = 10
            else
                tempSkillLevelRacialBonuses[r] = 5
            endif
        else
            tempSkillLevelRacialBonuses[r] = 0
        endif
        r += 1
    endWhile  
    SkillLevelRacialBonuses = tempSkillLevelRacialBonuses 
EndFunction