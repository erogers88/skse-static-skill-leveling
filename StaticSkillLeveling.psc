scriptname StaticSkillLeveling extends ActiveMagicEffect

int TrackedPlayerLevel auto
int CurrentPlayerLevel auto
int NumLevelsGained auto

int SkillPointsPerLevel auto
int SkillPointCost0 auto
int SkillPointCost25 auto
int SkillPointCost50 auto
int SkillPointCost75 auto

Event OnSleepStop(bool abInterrupted)
    CurrentPlayerLevel = Game.GetPlayer().GetLevel()
    {Allow assignment of skills if player level has changed and sleep is not interrupted}
    if (CurrentPlayerLevel > TrackedPlayerLevel && !abInterrupted)
        NumLevelsGained = CurrentPlayerLevel - TrackedPlayerLevel
        {Call SkillMenu function}
    endif
    
        
EndEvent

Function SkillMenu()

