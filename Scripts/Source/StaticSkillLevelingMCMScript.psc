Scriptname StaticSkillLevelingMCMScript extends SKI_ConfigBase

;==========================================
;Player Level Properties
;==========================================

Int Property TrackedPlayerLevel = 1 Auto
;{This tracks the players level}
Int Property CurrentPlayerLevel = 1 Auto
;{This is the current players level}
Spell Property StaticSkillLevelingSpell Auto
bool Property ReAdd = True Auto

;==========================================
;Player Skill Properties
;==========================================

Int Property MaxSkillLevelBaseDefault = 18 Auto
Int MaxSkillLevelBaseDefaultOID
;{This is the base value for the players max skills, default 18}
Int Property MaxSkillLevelMultiplier = 2 Auto
Int MaxSkillLevelMultiplierOID
;{This is the number added to the players allowable max every level, default 2}
Int Property MaxSkillLevelTotal = 100 Auto
Int MaxSkillLevelTotalOID
;{This is the final maximum skill level, default 100}
Int Property MaxLevelsPerSkillPerPlayerLevel = 5 Auto
Int MaxLevelsPerSkillPerPlayerLevelOID
;{The maximum number of skill levels a player can gain per level for one skill}
Int[] Property SkillIncreases Auto
;{This tracks the number of increases of each skill per levelup}

Int ReAddOID

;==========================================
;Skillpoint Related Properties
;==========================================

Int Property CurrentSkillPointsGained Auto
;{This is the number of current skill points remaining to allocate}
Int Property SkillPointsPerLevel = 15 Auto
Int SkillPointsPerLevelOID
;{This is the base number of skillpoints gained per level}
Int Property SkillPointsLevelMultiplier = 3 Auto
Int SkillPointsLevelMultiplierOID
;{This is the multiplier added to the base number of skillpoints per level}
Int Property SkillPointCost0 = 3 Auto
Int SkillPointCost0OID
;{This is the cost of raising a skill to 25}
Int Property SkillPointCost25 = 5 Auto
Int SkillPointCost25OID
;{This is the cost of raising a skill from 25-50}
Int Property SkillPointCost50 = 7 Auto
Int SkillPointCost50OID
;{This is the cost of raising a skill from 50-75}
Int Property SkillPointCost75 = 9 Auto
Int SkillPointCost75OID
;{This is the cost of raising a skill above 75}

;==============================================================================================================



Event OnPageReset(string page)
    SetCursorFillMode(TOP_TO_BOTTOM)
    MaxSkillLevelBaseDefaultOID = AddSliderOption("Base Max Skill Level", MaxSkillLevelBaseDefault)
    MaxSkillLevelMultiplierOID = AddSliderOption("Max Skill Level Per Level Up", MaxSkillLevelMultiplier)
    MaxSkillLevelTotalOID = AddSliderOption("Max Final Skill Level", MaxSkillLevelTotal)
    MaxLevelsPerSkillPerPlayerLevelOID = AddSliderOption("Max Skill Increases Per Level Up", MaxLevelsPerSkillPerPlayerLevel)
    SetCursorPosition(1)
    SkillPointsPerLevelOID = AddSliderOption("Fixed Skill Points Per Level", SkillPointsPerLevel)
    SkillPointsLevelMultiplierOID = AddSliderOption("Additional Skill Points Mult.", SkillPointsLevelMultiplier)
    SkillPointCost0OID = AddSliderOption("Skill Points Req. For Skills Under 25", SkillPointCost0)
    SkillPointCost25OID = AddSliderOption("Skill Points Req. For Skills Over 25", SkillPointCost25)
    SkillPointCost50OID = AddSliderOption("Skill Points Req. For Skills Over 50", SkillPointCost50)
    SkillPointCost75OID = AddSliderOption("Skill Points Req. For Skills Over 75", SkillPointCost75)
EndEvent

Event OnOptionSliderOpen(int option)
    If option == MaxSkillLevelBaseDefaultOID
        SetSliderDialogStartValue(MaxSkillLevelBaseDefault)
        SetSliderDialogDefaultValue(18.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == MaxSkillLevelMultiplierOID
        SetSliderDialogStartValue(MaxSkillLevelMultiplier)
        SetSliderDialogDefaultValue(2.0)
        SetSliderDialogRange(0.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == MaxSkillLevelTotalOID
        SetSliderDialogStartValue(MaxSkillLevelTotal)
        SetSliderDialogDefaultValue(100.0)
        SetSliderDialogRange(100.0,1000.0)
        SetSliderDialogInterval(5.0)
    ElseIf option == MaxLevelsPerSkillPerPlayerLevelOID
        SetSliderDialogStartValue(MaxLevelsPerSkillPerPlayerLevel)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
        
    ElseIf option == SkillPointsPerLevelOID
        SetSliderDialogStartValue(SkillPointsPerLevel)
        SetSliderDialogDefaultValue(15.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == SkillPointsLevelMultiplierOID
        SetSliderDialogStartValue(SkillPointsLevelMultiplier)
        SetSliderDialogDefaultValue(3.0)
        SetSliderDialogRange(0.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == SkillPointCost0OID
        SetSliderDialogStartValue(SkillPointCost0)
        SetSliderDialogDefaultValue(3.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == SkillPointCost25OID
        SetSliderDialogStartValue(SkillPointCost25)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == SkillPointCost50OID
        SetSliderDialogStartValue(SkillPointCost50)
        SetSliderDialogDefaultValue(7.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == SkillPointCost75OID
        SetSliderDialogStartValue(SkillPointCost75)
        SetSliderDialogDefaultValue(9.0)
        SetSliderDialogRange(1.0,100.0)
        SetSliderDialogInterval(1.0)
    EndIf
EndEvent

Event OnOptionSliderAccept(int option, float value)
    If option == MaxSkillLevelBaseDefaultOID
        Debug.MessageBox("Make sure fSkillCapBase in Experience.ini or SkillCap Base in the Experience MCM matches this value!")
        MaxSkillLevelBaseDefault = value as int
    ElseIf option == MaxSkillLevelMultiplierOID
        Debug.MessageBox("Make sure fSkillCapMult in Experience.ini or SkillCap Multiplier in the Experience MCM matches this value!")
        MaxSkillLevelMultiplier = value as int
    ElseIf option == MaxSkillLevelTotalOID
        MaxSkillLevelTotal = value as int
    ElseIf option == MaxLevelsPerSkillPerPlayerLevelOID
        MaxLevelsPerSkillPerPlayerLevel = value as int
        
    ElseIf option == SkillPointsPerLevelOID
        SkillPointsPerLevel = value as int
    ElseIf option == SkillPointsLevelMultiplierOID
        SkillPointsLevelMultiplier = value as int
    ElseIf option == SkillPointCost0OID
        SkillPointCost0 = value as int
    ElseIf option == SkillPointCost25OID
        SkillPointCost25 = value as int
    ElseIf option == SkillPointCost50OID
        SkillPointCost50 = value as int
    ElseIf option == SkillPointCost75OID
        SkillPointCost75 = value as int
    EndIf
    SetSliderOptionValue(option, value, "{0}")
EndEvent

Event OnOptionHighlight(int option)
    If option == MaxSkillLevelBaseDefaultOID
        SetInfoText("The base value for the player's max skills.")
    ElseIf option == MaxSkillLevelMultiplierOID
        SetInfoText("The value added to the allowable max skill level multiplied by the player's current level. Example: At the default value of 2 and player level 16, the max level for all skills will be (Base Max Skill Level + 32).")
    ElseIf option == MaxSkillLevelTotalOID
        SetInfoText("This is the final maximum skill level. Vanilla default is 100.")
    ElseIf option == MaxLevelsPerSkillPerPlayerLevelOID
        SetInfoText("The maximum number of skill levels a player can gain per level for one skill. At the default value of 5, you can only increase the same skill 5 times per player level up.")
        
    ElseIf option == SkillPointsPerLevelOID
        SetInfoText("The base number of skill points gained per level.")
    ElseIf option == SkillPointsLevelMultiplierOID
        SetInfoText("The additional number of skill points gained per level. (Fixed Skill Points Per Level) + (Player Level x Additional Skill Points Mult.) = Total skill points to spend")
    ElseIf option == SkillPointCost0OID
        SetInfoText("The skill point cost of raising 1 skill level if the skill is between 0-24.")
    ElseIf option == SkillPointCost25OID
        SetInfoText("The skill point cost of raising 1 skill level if the skill is between 25-49.")
    ElseIf option == SkillPointCost50OID
        SetInfoText("The skill point cost of raising 1 skill level if the skill is between 50-74.")
    ElseIf option == SkillPointCost75OID
        SetInfoText("The skill point cost of raising 1 skill level if the skill is above 75.")
    EndIf
EndEvent