Scriptname StaticSkillLevelingRefAScript extends ReferenceAlias  

StaticSkillLevelingMCMScript Property m Auto
Spell Property StaticSkillLevelingSpell Auto



Event OnPlayerLoadGame()
    If m.ReAdd
        Game.GetPlayer().RemoveSpell(StaticSkillLevelingSpell)
        Game.GetPlayer().AddSpell(StaticSkillLevelingSpell, False)
        m.ReAdd = False
    EndIf
EndEvent
