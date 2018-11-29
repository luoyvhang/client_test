local PhoneDevice = {}
local device = require("cocos.framework.device")
local luaoc = require('cocos.cocos2d.luaoc')
local luaj = require('cocos.cocos2d.luaj')

local function getDeviceInfoForIOS()
	local ok,ret = luaoc.callStaticMethod("OCLuaTool", "getDeviceInfo",{w=1})

    if ok then

        if ret.token and ret.token ~= "" then
    	   ret.token = string.gsub(ret.token,"<","")
    	   ret.token = string.gsub(ret.token,">","")
    	   ret.token = string.gsub(ret.token," ","")
        end

        local DeviceData = {
            deviceId = ret.token or "",
            deviceModel = ret.deviceModel or "",
            devicePlatform = "iOS",
            systemVersion = ret.systemVersion or "",
        }

        return DeviceData
    else
        return
    end
end

local function callJava(javaMethodName)
    local javaClassName = "org.cocos2dx.lua.SystemInfo"
    local javaMethodSig = "()Ljava/lang/String;"
    -- "getModel"
    -- getSdkVersion
    -- getReleaseVersion

    return luaj.callStaticMethod(javaClassName, javaMethodName, {}, javaMethodSig)
end
--==============================--
--desc:
--time:2017-07-14 11:51:08
--@javaMethodName:
--@return 
--==============================----
local function callJavaBy(javaMethodName)
    local javaClassName = "org.cocos2dx.lua.AppActivity"
    local javaMethodSig = "()Ljava/lang/String;"
    -- "getNetInfo"

    return luaj.callStaticMethod(javaClassName, javaMethodName, {}, javaMethodSig)
end

local function getDeviceInfoAndroid()
    local ok1, model = callJava('getModel')
    local ok2, brand = callJava('getBrand')
    local ok3, version = callJava('getReleaseVersion')
    local ok4, token = callJava('getToken')

    model = model or ""
    brand = brand or ""

    return {
            deviceModel = brand.."-"..model,
            deviceId = token or "",
            devicePlatform = "Android",
            systemVersion = version or "",
        }
end

local function UploadData(request,DeviceData)
    tools.connect( request , net.port.postDeviceId , function(data)
        dump(data)
        request:removeSelf()
    end ,
    {sendData=DeviceData})
end

PhoneDevice.UploadingDeviceInfo = function(request)
    local DeviceData

	if device.platform == "android" then
        print('android.......')
        DeviceData = getDeviceInfoAndroid()
    elseif device.platform == "ios" then
    	DeviceData = getDeviceInfoForIOS()
    end

    if DeviceData and request then
        UploadData( request,DeviceData )
    elseif request then
        request:removeSelf()
    end

end

return PhoneDevice
