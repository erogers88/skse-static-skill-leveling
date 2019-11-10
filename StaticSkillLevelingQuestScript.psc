scriptname StaticSkillLevelingQuest extends Quest
{This script adds a hidden active effect to the character upon game start that enables static leveling}

Event OnInit()
Game.GetPlayer().AddSpell(StaticSkillLevelingEffect)
EndEvent