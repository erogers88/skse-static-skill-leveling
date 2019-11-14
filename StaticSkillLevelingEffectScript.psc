scriptname StaticSkillLevelingEffectScript extends ActiveMagicEffect
{This script checks for a level up when the player wakes from sleep and allows them to assign skillpoints}

;==========================================
;Initialization Properties
;==========================================

Message property InitializationMessage auto

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
string[] property SkillNames auto
{These are the names of the skills}
int[] property BaseSkillLevels auto
{These are the base values of the players skills}
int[] property MaxSkillLevels auto
{These are the max values of the players skills}
int[] property SkillLevelRacialBonuses auto
{These are the racial bonuses for the players skills}

;==========================================
;Skillpoint Related Properties
;==========================================

int property CurrentSkillPointsGained auto
{This is the number of current skill points remaining to allocate}
int property SkillPointsPerLevel auto
{This is the number of skillpoints gained per level}
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
Message property HelpMenu auto
{This is the message that appears when a user clicks Help}
Message property NotEnoughSkillPointsMenu auto
{This is the message that appears when a user does not have enough points to level a skill}
Message property SkillIsAtMaxLevelMenu auto
{This is the message that appears when a user tries to level a skill above max level}

;==============================================================================================================

;==========================================
;Register for sleep and track player level
;==========================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Initialization()
EndEvent

;==========================================
;Set player skill levels when race menu is closed
;==========================================

Event OnMenuClose(string menuName)
    if (menuName == "RaceSex Menu")
        SetInitialSkills()
        ;Debug.MessageBox("Race Menu Close Detected")
    endif
EndEvent

;============================================
;Main handler for leveling after sleep
;============================================

Event OnSleepStop(bool abInterrupted)
    if (abInterrupted)
    ;do nothing if interrupted
	else
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
    CurrentSkillPointsGained = CurrentSkillPointsGained + CalculateSkillPointsGained()
    TrackedPlayerLevel = CurrentPlayerLevel
    SetBaseSkillLevels()
    SetMaxSkillLevels()

    int CurrentMenu = 0
    int IndexOfCurrentSelectedSkill
    int LevelOfCurrentSelectedSkill
    bool HasEnoughSkillPointsToIncreaseSkill
    bool SkillIsBelowMaxLevel

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
            ;Debug.MessageBox("This is the index of the selected skill" + IndexOfCurrentSelectedSkill)
            LevelOfCurrentSelectedSkill = BaseSkillLevels[IndexOfCurrentSelectedSkill]
            ;Debug.MessageBox("This is the level of the selected skill" + LevelOfCurrentSelectedSkill)
            ;Debug.MessageBox("This is the max level of the selected skill" + MaxSkillLevels[IndexOfCurrentSelectedSkill])
            HasEnoughSkillPointsToIncreaseSkill = CheckEnoughSkillPointsToIncreaseSkill(LevelOfCurrentSelectedSkill)
            SkillIsBelowMaxLevel = CheckSkillIsBelowMaxLevel(IndexOfCurrentSelectedSkill)
            if(SkillIsBelowMaxLevel == false)
                SkillIsAtMaxLevelMenu.show()
            elseif(HasEnoughSkillPointsToIncreaseSkill == false)
                NotEnoughSkillPointsMenu.show()
            endif
            ;Debug.MessageBox("Do you have enough skill points?" + HasEnoughSkillPointsToIncreaseSkill)
            ;Debug.MessageBox("Is the skill you are trying to increase below max level?" + SkillIsBelowMaxLevel)
            if(HasEnoughSkillPointsToIncreaseSkill && SkillIsBelowMaxLevel)
                Game.IncrementSkill(SkillNames[IndexOfCurrentSelectedSkill])
                ActorValueInfo.GetActorValueInfoByName(SkillNames[IndexOfCurrentSelectedSkill]).SetSkillExperience(0.0)
                CurrentSkillPointsGained = CurrentSkillPointsGained - SkillPointCostToIncreaseSkill(LevelOfCurrentSelectedSkill)
                BaseSkillLevels[IndexOfCurrentSelectedSkill] = BaseSkillLevels[IndexOfCurrentSelectedSkill] + 1
                ;Debug.MessageBox("This occurs inside the if statement to try and level the skill")
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
		returnValue = ThiefSkillMenu.show(CurrentPlayerLevel, CurrentSkillPointsGained, BaseSkillLevels[6], BaseSkillLevels[7], BaseSkillLevels[8], BaseSkillLevels[9], BaseSkillLevels[10], BaseSkillLevels[11])
	else
		returnValue = WarriorSkillMenu.show(CurrentPlayerLevel, CurrentSkillPointsGained, BaseSkillLevels[12], BaseSkillLevels[13], BaseSkillLevels[14], BaseSkillLevels[15], BaseSkillLevels[16], BaseSkillLevels[17])
	endif
    return returnValue
EndFunction

int Function DisplayDoneMenu()
    int returnValue
    returnValue = DoneMenu.show()
    return returnValue
EndFunction

Function DisplayHelpMenu()
    HelpMenu.show(SkillPointsPerLevel, SkillPointCost0, SkillPointCost25, SkillPointCost50, SkillPointCost75, MaxSkillLevelBaseDefault, MaxSkillLevelMultiplier)
EndFunction

int Function CalculateSkillPointsGained()
    int NumLevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
    int SkillPointsToReturn = NumLevelsGained * SkillPointsPerLevel
    return SkillPointsToReturn
EndFunction

int Function GetSkillNameIndex(int menuNumber, int Option)
	return Option - 1 + menuNumber * 6
    ;This calculates the index in the skill arrays based on the menu option
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

    ;trigger for sleep
    RegisterForSleep()  

    ;set trigger for racemenu closing
    RegisterForMenu("RaceSex Menu")

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
    ;Debug.MessageBox("This is in the max skill level function, and this is a skill number:" + MaxSkillLevels[7])
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
    ;Debug.MessageBox("This is in the racial bonus function, and this is a skill number:" + SkillLevelRacialBonuses[7])
EndFunction