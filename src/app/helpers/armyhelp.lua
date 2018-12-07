local ArmyHelp = {}
local emu = require "app.fight.Ro_Config"
local ArmyData = require 'app.fight.ArmyData'
local CalcEquipAdd = require('app.helpers.calcequitadd')
local CalcLevelupSolider = require('app.helpers.calclevelupsolider')
local HeroSkillModule = require('app.fight.HeroSkillModule')

local function deepcopy(src,des)
  for k,v in pairs(src) do
    if type(v) == 'table' then
      des[k] = {}
      deepcopy(src[k],des[k])
    else
      des[k] = v
    end
  end
end

function ArmyHelp.convert(input)
  local app = require("app.App"):instance()
  local lineup = {}
  deepcopy(input,lineup)

  for i = 4, 1, -1 do
    local slot = lineup['slot'..i]
    if slot then
      local soldier = slot.soldier
      if soldier then
        local t = type(soldier)

        if t == 'string' then
          slot.soldier = app.session.soldier:getSoldierById(soldier)
        end
      end

      local hero = slot.hero
      if hero then
        local t = type(hero)

        if t == 'string' then
          slot.hero = app.session.heroes:getHeroById(hero)
        end
      end
    end
  end

  return lineup
end

local mainHeroArmyIndex = {
  {
    emu.A_BAR_HERO_LV1,
    emu.A_BAR_HERO_LV2,
    emu.A_BAR_HERO_LV3,
    emu.A_BAR_HERO_LV4,
  },
  {
    emu.A_WAR_HERO_LV1,
    emu.A_WAR_HERO_LV2,
    emu.A_WAR_HERO_LV3,
    emu.A_WAR_HERO_LV4,
  },
  {
    emu.A_ARCH_HERO_LV1,
    emu.A_ARCH_HERO_LV2,
    emu.A_ARCH_HERO_LV3,
    emu.A_ARCH_HERO_LV4,
  },
  {
    emu.A_WIZ_HERO_LV1,
    emu.A_WIZ_HERO_LV2,
    emu.A_WIZ_HERO_LV3,
    emu.A_WIZ_HERO_LV4,
  },
}

local function packMainHero(st, hero)
  local app = require("app.App"):instance()

  local tdata = ArmyData.GetArmyInfo_byNoHighSoldier(mainHeroArmyIndex[hero.index][1])
  for k,v in pairs(tdata) do
    --st[k] = v
  end

  local Property = app.session.heroes:getProperty(hero)
  for k,v in pairs(Property) do
    if st[k] then
      st[k] = st[k] + v.value
    end
  end
end

local function packHero(st, hero, soldier)
  local data = ArmyData.GetArmyInfo_byNoHighSoldier(soldier.index)
  -- 英雄加成
  local weapon_add = CalcEquipAdd.calc(hero.equipped.weapon.level+1)
  st.damage = st.damage + data.damage * weapon_add

  local head_add = CalcEquipAdd.calc(hero.equipped.head.level+1)
  st.defense_phy = st.defense_phy + data.defense_phy * head_add

  local torso_add = CalcEquipAdd.calc(hero.equipped.torso.level+1)
  st.defense_mag = st.defense_mag + data.defense_mag * torso_add

  st.miss = st.miss + data.miss * CalcEquipAdd.calc(hero.equipped.torso.level+1)


end
---打包普通英雄技能
local function packHeroSkill(hero)
  local skillIds = {}
  if hero.auto then
    skillIds[#skillIds+1] =
    {
      hero.auto,
      hero.skill0Level+1
    }
  end

  if hero.passive and hero.passive ~= -1 then
    skillIds[#skillIds+1] =
    {
      hero.passive,
      hero.skill1Level+1
    }
  end

  local skill_num = #skillIds
  local skill_data = {}
  local skill_destroy = {}
  for s = 1,skill_num do
    local skillid = skillIds[s][1]
    local creator = HeroSkillModule.getCreateSkillFun(skillid)
    if creator then
      skill_data[s-1] = creator(skillIds[s][2])
      skill_destroy[s-1] = HeroSkillModule.getDestroySkillFun(skillid)
    end
  end
  return skill_num, skill_data, skill_destroy
end

local function packageSoldier(st, slot, soldier)
  local index
  -- 士兵的等级加成
  local data = ArmyData.GetArmyInfo_byNoHighSoldier(soldier.index)
  st.damage = st.damage + CalcLevelupSolider.getLevelUpPercent(soldier.level) * data.damage
  st.hp = st.hp + CalcLevelupSolider.getLevelUpPercent(soldier.level) * data.hp
  if soldier then
    index = soldier.index
    if index < 9 then
      index = index * 2
      if soldier.level >= 10 then
        index = index + 1
      end
    end
    return slot.count, index
  end
end

function ArmyHelp.create(lineup,isDefense,g_Combat)
  local app = require("app.App"):instance()

  for i = 4, 1, -1 do
    local slot = lineup['slot'..i]
    if slot then
      local st = {}
      ArmyData.InitAttData(st, nil, false)
      local hero = slot.hero
      local t = type(hero)
      if t == 'string' then
        hero = app.session.heroes:getHeroById(hero)
      end

      local soldier = slot.soldier
      if soldier then
        t = type(soldier)
        if t == 'string' then
          soldier = app.session.soldier:getSoldierById(soldier)
        end
      end

      -- change hero to data
      local say
      local armyhero
      local count
      local hType

      if hero then
        local index
        say = hero.fightString
        if hero.isMainHero then--主英雄
          count = 1
          local heroCfg = {90, 94, 98, 102}
          hType = mainHeroArmyIndex[hero.index][1]
          index = heroCfg[hero.index]
          print('mainHeroArmyIndex[hero.index][1] is',mainHeroArmyIndex[hero.index][1])
          packMainHero(st, hero)
          dump(st)
        else--普通英雄
          index = hero.index-1
          count, hType = packageSoldier(st, slot, soldier)
          packHero(st, hero, soldier)
          hero.auto = hero.index - 1
        end
        local skill_num, skill_data, skill_destroy = packHeroSkill(hero)
        armyhero = ArmyData.CreateHero(index, 0, st, skill_num, skill_data, skill_destroy)
        armyhero.isMainHero = hero.isMainHero
      else--没有英雄
        count, hType = packageSoldier(st, slot, soldier)
        armyhero = ArmyData.CreateHero(-1, 0, st, 0, {}, {})
      end
      ArmyData.CreateArmy(g_Combat, isDefense, i - 1, hType, count, armyhero, 1, say)
    end
  end
end

return ArmyHelp
