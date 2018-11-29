local CreateBoneNode = {}

function CreateBoneNode.createWithExport(export,armatureName)
  ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(export)
  local actor = ccs.Armature:create(armatureName)
  return actor
end

return CreateBoneNode
