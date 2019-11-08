scriptname StaticSkillLeveling extends ActiveMagicEffect

int PlayerLevel auto
bool TriggerSkillAssignment auto

int SkillPointsPerLevel auto
int SkillPointCost0 auto
int SkillPointCost25 auto
int SkillPointCost50 auto
int SkillPointCost75 auto

Event OnSleepStop(bool abInterrupted)

    if (Game.GetPlayer().GetLevel() > PlayerLevel)
        TriggerSkillAssignment = true

    else
        {Don't set skill assignment trigger if player has not leveled up}


    if abInterrupted
        {Player does not level up if sleep is interrupted}
    else
        if TriggerSkillAssignment
            {Call skill assignment menu function}
        else
            {Don't assign skills if player has not leveled}

EndEvent