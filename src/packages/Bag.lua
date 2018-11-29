local Bag = {}
-- Keeps adding order only when no child has been removed.
function Bag:add(child)
  self[#self+1] = child
end

function Bag:remove(child)
  local last = #self
  for i, v in ipairs(self) do
    if child == v then
      if i < last then
        self[i] = self[last]
      end
      self[last] = nil
      break
    end
  end
end

return Bag
