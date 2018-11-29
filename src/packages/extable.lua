local Table = table

function Table.keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    keys[#keys+1] = k
  end
  return keys
end

function Table.values(t)
  local vals = {}
  for _, v in pairs(t) do
    vals[#vals+1] = v
  end
  return vals
end

function Table.copy(t)
  local n = {}
  for k, v in pairs(t) do
    n[k] = v
  end
  return n
end

return table
