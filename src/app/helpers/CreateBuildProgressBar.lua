local Controller = require('mvc.Controller')
local CreateBuildProgressBar = {}

function CreateBuildProgressBar.create(buildingName)
  local app = require("app.App"):instance()
  local buildings = app.session.buildings
  local startTime = buildings[buildingName].time
  if startTime ~= 0 then
    --local tab = os.date("*t",second)
    local lvl = 1

    local total = buildings:getConfigBy(buildingName).components.upgrade[lvl].time
    local ctrl = Controller:load('ProgressBarController',startTime, total)
    return ctrl
  end
end

return CreateBuildProgressBar
