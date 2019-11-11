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

Message property LevelUpMenu auto
{This is the message that allows the player to assign skill points}

Message Property MagicSkillMenu auto
{Menu to display on leveling Magic skills}

Message Property WarriorSkillMenu auto
{Menu to display on leveling Warrior Skills}

Message Property ThiefSkillMenu auto
{Menu to display on leveling Thief Skills}

;==============================================================================================================

;==========================================
;Register for sleep and track player level
;==========================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Initialization()
EndEvent

;============================================
;Main handler for leveling after sleep
;============================================

Event OnSleepStop(bool abInterrupted)
	if abInterrupted
    ;do nothing if interrupted
	else
        CurrentPlayerLevel = Game.GetPlayer().GetLevel()
            if (CurrentPlayerLevel > TrackedPlayerLevel)
                AddSkills(NumLevelsGained)       
            endif   
	endIf
    RegisterForSleep()
    ;Maybe not needed - check later
endEvent



;============================================
;Menu Functions
;============================================

Function AddSkills(int levelsGained)
    CurrentSkillPointsGained = CurrentSkillPointsGained + CalculateSkillPointsGained()
    TrackedPlayerLevel = CurrentPlayerLevel
    SetBaseSkillLevels()
    SetMaxSkillLevels()

    int CurrentMenu = 0
    int IndexOfCurrentSelectedSkill
    int LevelOfCurrentSelectedSkill
    bool CanCurrentSelectedSkillBeIncreased
    int Option = DisplaySkillMenu.show(CurrentMenu)
    while(Option <> 8);didn't exit
        ;change menu if player picked another one
    	if(Option == 0)
			currentMenu -= 1
			if (currentMenu < 0)
				currentMenu = 2
			endif
		elseif (Option == 7)
			currentMenu += 1
			if (currentMenu > 2)
				currentMenu = 0
		    endif
        ;if player selected a skill to level
        else
        IndexOfCurrentSelectedSkill = GetSkillNameIndex(CurrentMenu, Option)
        LevelOfCurrentSelectedSkill = BaseSkillLevels[IndexOfCurrentSelectedSkill]
        CanCurrentSelectedSkillBeIncreased = EnoughSkillPointsToIncreaseSkill(LevelOfCurrentSelectedSkill)
        if(CanCurrentSelectedSkillBeIncreased && BaseSkillLevels[IndexOfCurrentSelectedSkill] > MaxSkillLevels[IndexOfCurrentSelectedSkill])
            Game.IncrementSkill(SkillNames[IndexOfCurrentSelectedSkill])
            CurrentSkillPointsGained = CurrentSkillPointsGained - SkillPointCostToIncreaseSkill(LevelOfCurrentSelectedSkill)
            BaseSkillLevels[IndexOfCurrentSelectedSkill] = BaseSkillLevels[IndexOfCurrentSelectedSkill] + 1
        endif
        Option = DisplaySkillMenu.show(CurrentMenu)
EndFunction


int Function DisplaySkillMenu(int menuNumber)
	if(menuNumber == 0)
		returnValue = MagicSkillMenu.show(CurrentSkillPointsGained, BaseSkillLevels[0], BaseSkillLevels[1], BaseSkillLevels[2], BaseSkillLevels[3], BaseSkillLevels[4], BaseSkillLevels[5])
	elseif(menuNumber == 1)
		returnValue = ThiefSkillMenu.show(CurrentSkillPointsGained, BaseSkillLevels[6], BaseSkillLevels[7], BaseSkillLevels[8], BaseSkillLevels[9], BaseSkillLevels[10], BaseSkillLevels[11])
	else
		returnValue = WarriorSkillMenu.show(CurrentSkillPointsGained, BaseSkillLevels[12], BaseSkillLevels[13], BaseSkillLevels[14], BaseSkillLevels[15], BaseSkillLevels[16], BaseSkillLevels[17])
	endif
EndFunction

int Function CalculateSkillPointsGained()
    int NumLevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
    int SkillPointsToReturn = numLevels * SkillPointsPerLevel
    return SkillPointsToReturn
EndFunction

int Function GetSkillNameIndex(int menuNumber, int Option)
	return Option - 1 + menuNumber * 6
    ;This calculates the index in the skill arrays based on the menu option
EndFunction

bool Function EnoughSkillPointsToIncreaseSkill(num levelOfSkill)
    if(levelOfSkill < 25)
        if(CurrentSkillPointsGained >= SkillPointCost0)
            return true
        else
            return false
    elseif(levelOfSkill >= 25 && levelOfSkill < 50)
        if(CurrentSkillPointsGained >= SkillPointCost25)
            return true
        else
            return false
    elseif(levelOfSkill >= 50 && levelOfSkill < 75)
        if(CurrentSkillPointsGained >= SkillPointCost50)
            return true
        else
            return false   
    elseif(levelOfSkill >= 75)
        if(CurrentSkillPointsGained >= SkillPointCost75)
            return true
        else
            return false   
EndFunction

int Function SkillPointCostToIncreaseSkill(num levelOfSkill)
    if(levelOfSkill < 25)
        return SkillPointCost0
    elseif(levelOfSkill >= 25 && levelOfSkill < 50)
        return SkillPointCost25
    elseif(levelOfSkill >= 50 && levelOfSkill < 75)
        return SkillPointCost50
    elseif(levelOfSkill >= 75)
        return SkillPointCost75 
EndFunction

;============================================
;Setup Functions
;============================================

Function Initialization()	
    ;set initial player levels
    int tempPlayerLevel = Game.GetPlayer().GetLevel()
    CurrentPlayerLevel = tempPlayerLevel
    TrackedPlayerLevel = tempPlayerLevel

    ;trigger for sleep
    RegisterForSleep()  

    ;set base skill names, base skill levels, and max skill levels
    SetBaseSkillNames()
    SetBaseSkillLevels()
    SetRacialBonuses()
    SetMaxSkillLevels()

    ;display confirmation message
    InitializationMessage.show()
EndFunction

Function SetBaseSkillNames()
    SkillNames[0] = "Alteration"
	SkillNames[1] = "Conjuration"
	SkillNames[2] = "Destruction"
	SkillNames[3] = "Enchanting"
	SkillNames[4] = "Illusion"
	SkillNames[5] = "Restoration"
	SkillNames[6] = "Alchemy"
	SkillNames[7] = "LightArmor"
	SkillNames[8] = "Lockpicking"
	SkillNames[9] = "Pickpocket"
	SkillNames[10] = "Sneak"
	SkillNames[11] = "Speechcraft"
	SkillNames[12] = "Marksman"
	SkillNames[13] = "Block"
	SkillNames[14] = "HeavyArmor"
	SkillNames[15] = "OneHanded"
	SkillNames[16] = "Smithing"
	SkillNames[17] = "TwoHanded"
EndFunction

Function SetBaseSkillLevels()
    int i = 0
    while(i < SkillNames.length)
        BaseSkillLevels[i] = Game.GetPlayer().GetBaseActorValue(SkillNames[i])
        i += 1
    endWhile
EndFunction

Function SetMaxSkillLevels()
    int i = 0
    while(i < SkillNames.length)
        MaxSkillLevels[i] = MaxSkillLevelBaseDefault + (CurrentPlayerLevel * MaxSkillLevelMultiplier) + SkillLevelRacialBonuses[i]
    endWhile
EndFunction

Function SetRacialBonuses()
    int r = 0
    while(r < SkillNames.length)
        if(BaseSkillLevels[r] > 18)
            if(BaseSkillLevels[r] > 20)
                SkillLevelRacialBonuses[r] = 10
            else
                SkillLevelRacialBonuses[r] = 5
            endif
        else
            BaseSkillLevels[r] = 0
        endif
    endWhile   
EndFunction