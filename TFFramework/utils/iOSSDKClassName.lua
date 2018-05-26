iOSSDKClassName = {}
iOSSDKClassName.name = nil

function iOSSDKClassName:get()
	if iOSSDKClassName.name then
		return iOSSDKClassName.name
	end

	--检查配置文件中
	local cnFile = "default/sdkcn.lua"
	if TFFileUtil:existFile(cnFile) then
		local sdkcn = require("default.sdkcn")
		iOSSDKClassName.name = sdkcn.name
		return iOSSDKClassName.name
	end
	--通过函数调用确认
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		local classname = "KoSdkManager"
	    local ok,ret = TFLuaOcJava.callStaticMethod(classname, "isKoSdk")
	    if not ok then
	        classname = "HeitaoManager"
	    end
	    iOSSDKClassName.name = classname
	end

	return iOSSDKClassName.name
end

return iOSSDKClassName