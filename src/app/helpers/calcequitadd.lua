local CalcEquipAdd = {}
function CalcEquipAdd.calc(level)
  return 0.01 * level
end

function CalcEquipAdd.calcChance(level)
  if level > 60 then level = 60 end

  local min = 1
  local max = 60
  local ret = 1 - (level - min) / (max - min) * (1 - 0.2)
  return ret
end

function CalcEquipAdd.calcCost(level)
  if level > 60 then level = 60 end

  local min = 1
  local max = 60
  local ret = (level - min) / (max - min) * (5000 - 30) + 30
  return ret
end

local names = {
  { '木手斧' },
  { '冷铁头盔' },
  { '紫藤甲' },
  { '紫藤护足' },
}
function CalcEquipAdd.getEquipName(index,level)
  return names[index][1]
end

local attributes = {
  '伤害加成',
  '物防加成',
  '魔防加成',
  '闪避加成',
}
function CalcEquipAdd.getEquipAddName(index)
  return attributes[index]
end

function CalcEquipAdd.getEquipPath(level)
  local index = math.floor(level / 5)
  if index > 7 then
    index = 7
  end

  return index
end

return CalcEquipAdd
