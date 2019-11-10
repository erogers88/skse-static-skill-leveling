scriptname StaticSkillLevelingEffectScript extends ActiveMagicEffect
{This script checks for a level up when the player wakes from sleep and allows them to assign skillpoints}


;==========================================
;Player Level Properties
;==========================================

int property TrackedPlayerLevel auto
{This tracks the players level}
int property CurrentPlayerLevel auto
{This is the current players level}
int property NumLevelsGained auto
{This is the number of levels gained that is calculated when the player sleeps}


;==========================================
;Skillpoint Related Properties
;==========================================

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

;==============================================================================================================

;==========================================
;Register for sleep and track player level
;==========================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
    Initialization()
	;Debug.Messagebox("This ran inside the effect start")
EndEvent

;============================================
;Main handler for leveling after sleep
;============================================

Event OnSleepStop(bool abInterrupted)
	if abInterrupted
	    ;Debug.MessageBox("Player was woken by something!")
	else
	    ;Debug.MessageBox("Player woke up naturally")
        CurrentPlayerLevel = Game.GetPlayer().GetLevel()
            if (CurrentPlayerLevel > TrackedPlayerLevel)
                NumLevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
                ;Add Skills here by calling AddSkills function
                AddSkills(NumLevelsGained)       
            endif   
	endIf
    RegisterForSleep()
endEvent



;============================================
;Functions
;============================================

Function AddSkills(int LevelsGained)
    LevelUpMenu.show()
	TrackedPlayerLevel = CurrentPlayerLevel
EndFunction

Function Initialization()	
    TrackedPlayerLevel = Game.GetPlayer().GetLevel()
    RegisterForSleep()  
	;Debug.Messagebox("This ran inside the initialization function")
EndFunction