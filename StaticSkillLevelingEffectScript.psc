scriptname StaticSkillLevelingEffectScript extends ActiveMagicEffect

int property TrackedPlayerLevel auto
int property CurrentPlayerLevel auto
int property NumLevelsGained auto

int property SkillPointsPerLevel auto
int property SkillPointCost0 auto
int property SkillPointCost25 auto
int property SkillPointCost50 auto
int property SkillPointCost75 auto

Message property LevelUpMenu auto

;==========================================
;Register for sleep and track player level
;==========================================

Event OnInit()
    Initialization()
EndEvent

Event OnPlayerLoadGame()
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
    RegisterForPlayerSleep()  
EndFunction