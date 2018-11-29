local HashArray = {}
local tinsert, tremove = table.insert, table.remove

function HashArray.add(t, key, value)
  if t[key] then return end -- already added

  t[key] = value
  tinsert(t, value)
end

local function index(t, value)
  for i, v in ipairs(t) do
    if v == value then
      return i
    end
  end
  return nil
end

function HashArray.remove(t, key, value)
  if t[key] == value then
    tremove(t, index(t, value))
    t[key] = nil
  end
end

function HashArray.hasKey(t, key)
  return t[key] ~= nil
end

function HashArray.hasValue(t, value)
  return index(t, value) ~= nil
end

function HashArray.value(t, key)
  return t[key]
end

function HashArray.values(t)
  local values = {}
  for i,v in ipairs(t) do
    values[i] = v
  end
  return values
end

return HashArray
