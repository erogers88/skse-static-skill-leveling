scriptname StaticSkillLevelingEffectScript extends ActiveMagicEffect
{This script checks for a level up when the player wakes from sleep and allows them to assign skillpoints}


int property TrackedPlayerLevel auto
{This tracks the players level}

int property CurrentPlayerLevel auto
{This is the current players level}

int property NumLevelsGained auto
{This is the number of levels gained that is calculated when the player sleeps}


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


Message property LevelUpMenu auto
{This is the message that allows the player to assign skill points}

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

Event OnPlayerSleepStop(bool abInterrupted)
    CurrentPlayerLevel = Game.GetPlayer().GetLevel()
    ;Allow assignment of skills if player level has changed and sleep is not interrupted
    if (CurrentPlayerLevel > TrackedPlayerLevel && !abInterrupted)
        NumLevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
        ;Add Skills here by calling AddSkills function
        AddSkills(NumLevelsGained)       
    endif      
EndEvent

;============================================
;Functions
;============================================

Function AddSkills(int LevelsGained)
    LevelUpMenu.show()
EndFunction

Function Initialization()
    TrackedPlayerLevel = Game.GetPlayer().GetLevel()
    RegisterForSleep()  
EndFunction