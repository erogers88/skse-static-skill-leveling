ScriptName StaticSkillLevelingEffectScript Extends ActiveMagicEffect
{This script checks for a level up when the player wakes from sleep and allows them to assign skillpoints}

Actor Property PlayerRef Auto
StaticSkillLevelingMCMScript Property m Auto

;==========================================
;Initialization Properties
;==========================================

Message Property InitializationMessage Auto
{This is the message that shows when the mod first starts}

;==========================================
;Player Level Properties
;==========================================

;Int Property TrackedPlayerLevel Auto
;{This tracks the players level}
;Int Property CurrentPlayerLevel Auto
;{This is the current players level}

;==========================================
;Player Skill Properties
;==========================================

;Int Property MaxSkillLevelBaseDefault Auto
;{This is the base value for the players max skills, default 18}
;Int Property MaxSkillLevelMultiplier Auto
;{This is the number added to the players allowable max every level, default 2}
;Int Property MaxSkillLevelTotal Auto
;{This is the final maximum skill level, default 100}
;Int Property MaxLevelsPerSkillPerPlayerLevel Auto
;{The maximum number of skill levels a player can gain per level for one skill}
String[] Property SkillNames Auto
{These are the names of the skills}
Int[] Property BaseSkillLevels Auto
{These are the base values of the players skills}
Int[] Property MaxSkillLevels Auto
{These are the max values of the players skills}
;Int[] Property SkillIncreases Auto
;{This tracks the number of increases of each skill per levelup}
Int[] Property SkillLevelRacialBonuses Auto
{These are the racial bonuses for the players skills}
Int[] Property SkillBethesdaIndex Auto
{This is a lookup to map from my skill ordering to Bethesdas}

;==========================================
;Skillpoint Related Properties
;==========================================

;Int Property CurrentSkillPointsGained Auto
;{This is the number of current skill points remaining to allocate}
;Int Property SkillPointsPerLevel Auto
;{This is the base number of skillpoints gained per level}
;Int Property SkillPointsLevelMultiplier Auto
;{This is the multiplier added to the base number of skillpoints per level}
;Int Property SkillPointCost0 Auto
;{This is the cost of raising a skill to 25}
;Int Property SkillPointCost25 Auto
;{This is the cost of raising a skill from 25-50}
;Int Property SkillPointCost50 Auto
;{This is the cost of raising a skill from 50-75}
;Int Property SkillPointCost75 Auto
;{This is the cost of raising a skill above 75}

;==========================================
;Level Up Menu Properties
;==========================================

Message Property MagicSkillMenu Auto
{Menu to display on leveling Magic skills}
Message Property WarriorSkillMenu Auto
{Menu to display on leveling Warrior Skills}
Message Property ThiefSkillMenu Auto
{Menu to display on leveling Thief Skills}
Message Property DoneMenu Auto
{This is the message that confirm the completion of skill assignment}
Message Property HelpMenu1 Auto
{This is page 1 of the help menu that appears when a user clicks Help}
Message Property HelpMenu2 Auto
{This is page 2 of the help menu that appears when a user clicks Help}
Message Property HelpMenu3 Auto
{This is page 3 of the help menu that appears when a user clicks Help}
Message Property HelpMenu4 Auto
{This is page 4 of the help menu that appears when a user clicks Help}
Message Property HelpMenu5 Auto
{This is page 5 of the help menu that appears when a user clicks Help}
Message Property NotEnoughSkillPointsMenu Auto
{This is the message that appears when a user does not have enough points to level a skill}
Message Property SkillIsAtMaxLevelMenu Auto
{This is the message that appears when a user tries to level a skill above max level}
Message Property SkillIncreasesAtMaxMenu Auto
{This is the message that appears when a player has increases the skill the max times for that skill per level}

;==============================================================================================================

Function _Log(String asTextToPrint, Int aiSeverity = 0)
  Debug.OpenUserLog("StaticSkillLeveling")
  Debug.TraceUser("StaticSkillLeveling", "EffectScript> " + asTextToPrint, aiSeverity)
EndFunction

Function LogInfo(String asTextToPrint)
  _Log("[INFO] " + asTextToPrint, 0)
EndFunction

Function LogWarning(String asTextToPrint)
  _Log("[WARN] " + asTextToPrint, 1)
EndFunction

Function LogError(String asTextToPrint)
  _Log("[ERRO] " + asTextToPrint, 2)
EndFunction

;==========================================
;Register for sleep and track player level
;==========================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Initialization()
EndEvent

;==========================================
;Set racial bonuses if player changed race
;==========================================

Event OnMenuClose(String asMenuName)
  If asMenuName == "RaceSex Menu" && m.CurrentPlayerLevel == 1
    SetInitialSkills()
  Else
    UnregisterForMenu("RaceSex Menu")
  EndIf
EndEvent

;============================================
;Main handler for leveling after sleep
;============================================

Event OnSleepStop(Bool abInterrupted)
  If abInterrupted
    ;do nothing if interrupted
  Else
    Utility.Wait(1)
    m.CurrentPlayerLevel = PlayerRef.GetLevel()
    If m.CurrentPlayerLevel > m.TrackedPlayerLevel
      AddSkills()
    EndIf
  EndIf
EndEvent

;============================================
;Menu Functions
;============================================

Function AddSkills()
  m.CurrentSkillPointsGained = m.CurrentSkillPointsGained + CalculateSkillPointsGained()

  Int LevelsGained = m.CurrentPlayerLevel - m.TrackedPlayerLevel
  SetSkillIncreasesBaselineIndex()
  m.TrackedPlayerLevel = m.CurrentPlayerLevel

  SetBaseSkillLevels()
  SetMaxSkillLevels()

  Int IndexOfCurrentSelectedSkill
  Int LevelOfCurrentSelectedSkill
  Bool HasEnoughSkillPointsToIncreaseSkill
  Bool SkillIsBelowMaxLevel
  Bool SkillIncreasesBelowMax

  Int CurrentMenu = 0
  Int OptionDoneMenu
  Int Option = 10

  LogInfo("BaseSkillLevels:" + BaseSkillLevels)
  LogInfo("MaxSkillLevels:" + MaxSkillLevels)
  LogInfo("SkillLevelRacialBonuses:" + SkillLevelRacialBonuses)

  While Option != 8  ; didn't exit
    Option = DisplaySkillMenu(CurrentMenu)

    ; change menu if player picked another one
    If Option == 0
      If CurrentMenu == 0
        CurrentMenu = 2
      ElseIf CurrentMenu == 1
        CurrentMenu = 0
      Else
        CurrentMenu = 1
      EndIf

    ElseIf Option == 7
      If CurrentMenu == 0
        CurrentMenu = 1
      ElseIf CurrentMenu == 1
        CurrentMenu = 2
      Else
        CurrentMenu = 0
      EndIf

    ; if player selected a skill to level
    ElseIf LibMathf.InRange(Option, 1, 6)
      IndexOfCurrentSelectedSkill = GetSkillNameIndex(CurrentMenu, Option)
      ; This is the index of the selected skill

      LevelOfCurrentSelectedSkill = BaseSkillLevels[IndexOfCurrentSelectedSkill]
      ; This is the level of the selected skill
      HasEnoughSkillPointsToIncreaseSkill = CheckEnoughSkillPointsToIncreaseSkill(LevelOfCurrentSelectedSkill)
      SkillIsBelowMaxLevel                = CheckSkillIsBelowMaxLevel(IndexOfCurrentSelectedSkill)
      SkillIncreasesBelowMax              = CheckSkillIncreasesBelowMax(IndexOfCurrentSelectedSkill, LevelsGained)

      If !SkillIsBelowMaxLevel
        SkillIsAtMaxLevelMenu.Show()
      ElseIf !SkillIncreasesBelowMax
        SkillIncreasesAtMaxMenu.Show()
      ElseIf !HasEnoughSkillPointsToIncreaseSkill
        NotEnoughSkillPointsMenu.Show()
      EndIf

      ; Do you have enough skill points?
      ; Is the skill you are trying to increase below max level?
      ; Have you already increased the skill the maximum number of times?
      If HasEnoughSkillPointsToIncreaseSkill && SkillIsBelowMaxLevel && SkillIncreasesBelowMax
        Game.IncrementSkill(SkillNames[IndexOfCurrentSelectedSkill])
        ActorValueInfo.GetActorValueInfoByName(SkillNames[IndexOfCurrentSelectedSkill]).SetSkillExperience(0.0)

        m.CurrentSkillPointsGained                     = m.CurrentSkillPointsGained - SkillPointCostToIncreaseSkill(LevelOfCurrentSelectedSkill)
        BaseSkillLevels[IndexOfCurrentSelectedSkill] = BaseSkillLevels[IndexOfCurrentSelectedSkill] + 1
        m.SkillIncreases[IndexOfCurrentSelectedSkill]  = m.SkillIncreases[IndexOfCurrentSelectedSkill] + 1
      EndIf

    ;if player is done
    ElseIf Option == 8
      OptionDoneMenu = DisplayDoneMenu()

      If OptionDoneMenu == 1
        ;set != 8 to cancel done
        Option = 10
      Else
        ;player confirms done
      EndIf

    ElseIf Option == 9
      DisplayHelpMenu()
      Option = 10
    EndIf
  EndWhile
EndFunction

Int Function DisplaySkillMenu(Int menuNumber)
  If menuNumber == 0
    Return MagicSkillMenu.Show(m.CurrentPlayerLevel, m.CurrentSkillPointsGained, BaseSkillLevels[0], BaseSkillLevels[1], BaseSkillLevels[2], BaseSkillLevels[3], BaseSkillLevels[4], BaseSkillLevels[5])
  EndIf

  If menuNumber == 1
    Return WarriorSkillMenu.Show(m.CurrentPlayerLevel, m.CurrentSkillPointsGained, BaseSkillLevels[12], BaseSkillLevels[13], BaseSkillLevels[14], BaseSkillLevels[15], BaseSkillLevels[16], BaseSkillLevels[17])
  EndIf

  Return ThiefSkillMenu.Show(m.CurrentPlayerLevel, m.CurrentSkillPointsGained, BaseSkillLevels[6], BaseSkillLevels[7], BaseSkillLevels[8], BaseSkillLevels[9], BaseSkillLevels[10], BaseSkillLevels[11])
EndFunction

Int Function DisplayDoneMenu()
  Return DoneMenu.Show()
EndFunction

Function DisplayHelpMenu()
  HelpMenu1.Show()
  HelpMenu2.Show(m.SkillPointsPerLevel, m.SkillPointsLevelMultiplier)
  HelpMenu3.Show(m.SkillPointCost0, m.SkillPointCost25, m.SkillPointCost50, m.SkillPointCost75)
  HelpMenu4.Show()
  HelpMenu5.Show(m.MaxSkillLevelBaseDefault, m.MaxSkillLevelMultiplier)
EndFunction

Int Function CalculateSkillPointsGained()
  Int SkillPointsToReturn = 0
  Int LevelCounter = m.TrackedPlayerLevel

  While LevelCounter < m.CurrentPlayerLevel
    LevelCounter += 1
    SkillPointsToReturn += m.SkillPointsPerLevel + (LevelCounter * m.SkillPointsLevelMultiplier)
  EndWhile

  Return SkillPointsToReturn
EndFunction

Int Function GetSkillNameIndex(Int menuNumber, Int Option)
  Int tempIndex = Option - 1 + menuNumber * 6
  Return SkillBethesdaIndex[tempIndex]
  ;This calculates the index in the skill arrays based on the menu option, and also accounts for a lookup to Bethesda ordering
EndFunction

Bool Function CheckEnoughSkillPointsToIncreaseSkill(Int levelOfSkill)
  If levelOfSkill < 25
    Return m.CurrentSkillPointsGained >= m.SkillPointCost0
  EndIf

  If LibMathf.InRange(levelOfSkill, 25, 49)
    Return m.CurrentSkillPointsGained >= m.SkillPointCost25
  EndIf

  If LibMathf.InRange(levelOfSkill, 50, 74)
    Return m.CurrentSkillPointsGained >= m.SkillPointCost50
  EndIf

  If levelOfSkill >= 75
    Return m.CurrentSkillPointsGained >= m.SkillPointCost75
  EndIf
EndFunction

Bool Function CheckSkillIsBelowMaxLevel(Int skillIndexNumber)
  Return BaseSkillLevels[skillIndexNumber] < MaxSkillLevels[skillIndexNumber] && BaseSkillLevels[skillIndexNumber] < m.MaxSkillLevelTotal
EndFunction

Bool Function CheckSkillIncreasesBelowMax(Int skillIndexNumber, Int levelsGained)
  Int NumTimesAllowedToLevelSkill = levelsGained * m.MaxLevelsPerSkillPerPlayerLevel
  Return m.SkillIncreases[skillIndexNumber] < NumTimesAllowedToLevelSkill
EndFunction

Int Function SkillPointCostToIncreaseSkill(Int levelOfSkill)
  If levelOfSkill < 25
    Return m.SkillPointCost0
  EndIf

  If LibMathf.InRange(levelOfSkill, 25, 49)
    Return m.SkillPointCost25
  EndIf

  If LibMathf.InRange(levelOfSkill, 50, 74)
    Return m.SkillPointCost50
  EndIf

  If levelOfSkill >= 75
    Return m.SkillPointCost75
  EndIf
EndFunction

;============================================
;Setup Functions
;============================================

Function Initialization()
  ;set initial player levels
  m.CurrentPlayerLevel = PlayerRef.GetLevel()
  m.TrackedPlayerLevel = m.CurrentPlayerLevel
  m.CurrentSkillPointsGained = 0

  ;set trigger for sleep
  RegisterForSleep()

  ;set trigger for racemenu closing
  RegisterForMenu("RaceSex Menu")

  ;set initial skill values
  SetInitialSkills()

  ;display confirmation message
  InitializationMessage.Show()
EndFunction

Function SetInitialSkills()
  ;set base skill names, base skill levels, and max skill levels
  SetBaseSkillLevels()
  SetRacialBonuses()
  SetMaxSkillLevels()
EndFunction

Function SetBaseSkillLevels()
  Int i = 0

  While i < BaseSkillLevels.Length
    BaseSkillLevels[i] = LibMathf.RoundToInt(PlayerRef.GetBaseActorValue(SkillNames[i]))
    i += 1
  EndWhile

EndFunction

Function SetMaxSkillLevels()
  Int a = m.MaxSkillLevelBaseDefault + (m.CurrentPlayerLevel * m.MaxSkillLevelMultiplier)
  Int i = 0

  While i < MaxSkillLevels.Length
    MaxSkillLevels[i] = a + SkillLevelRacialBonuses[i]
    i += 1
  EndWhile

EndFunction

Function SetSkillIncreasesBaselineIndex()
  int i = 0

  While (i < m.SkillIncreases.Length)
    m.SkillIncreases[i] = 0
    i += 1
  EndWhile

EndFunction

Function SetRacialBonuses()
  int i = 0

  While (i < SkillLevelRacialBonuses.Length)
    SkillLevelRacialBonuses[i] = 0
    i += 1
  EndWhile

  Race playerRace = PlayerRef.GetRace()
  String[] raceSkills = LibFire.GetRaceSkills(playerRace)
  i = 0

  LogInfo("raceSkills:" + raceSkills)

  While i < raceSkills.Length
    Int iSkillName = SkillNames.Find(raceSkills[i])

    LogInfo("iSkillName:" + iSkillName)

    If iSkillName > -1
      SkillLevelRacialBonuses[iSkillName] = LibFire.GetRaceSkillBonus(playerRace, raceSkills[i])
    EndIf

    LogInfo("SkillLevelRacialBonuses[iSkillName]:" + SkillLevelRacialBonuses[iSkillName])

    i += 1
  EndWhile
EndFunction