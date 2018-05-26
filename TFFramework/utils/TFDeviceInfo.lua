TFDeviceInfo={}
TFDeviceInfo.CLASS_NAME = nil
TFDeviceInfo.totalMemery = nil
if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    TFDeviceInfo.CLASS_NAME = "TFDeviceInfo"
    if not iOSSDKClassName then require('TFFramework.utils.iOSSDKClassName')  end
    TFDeviceInfo.SDK_CLASS_NAME = iOSSDKClassName:get()
elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    TFDeviceInfo.CLASS_NAME = "org/cocos2dx/lib/TFDeviceInfo"
end

local TG3_GRAVITY_EARTH = 9.80665
function __G_OnAccelerate(x, y, z, t)
    if x ~= 0 and y ~= 0 then 
        TFDirector:dispatchGlobalEventWith("HeitaoSdk.ACCELEROMETER_UPDATE", {x = x * TG3_GRAVITY_EARTH, y = y * TG3_GRAVITY_EARTH})      
    end
end

function TFDeviceInfo.checkResult(ok,ret)
    -- body
    if ok then return ret end
    return nil
end

function TFDeviceInfo:acquirePowerLock()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "acquire",nil,"()V")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:releasePowerLock()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "release",nil,"()V")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getSystemName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSystemName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getSystemVersion()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSystemVersion",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getMachineName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getMachineName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getCurAppName()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCurAppName",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getCurAppVersion()

    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return TFPlugins and TFPlugins.getSdkVersion() or "1.0.0"
    end

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.SDK_CLASS_NAME, "getAppVersion",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCurAppVersion",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    end
end

function TFDeviceInfo:getPhoneNumber()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getPhoneNumber",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getTotalMem()
    if TFDeviceInfo.totalMemery then
        return TFDeviceInfo.totalMemery
    end
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        TFDeviceInfo.totalMemery = math.ceil(TFProcessHelper:getAllMemory() / 1024)
        return TFDeviceInfo.totalMemery
    end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getTotalMem",nil,"()Ljava/lang/String;")
    TFDeviceInfo.totalMemery = TFDeviceInfo.checkResult(ok,ret)
    return TFDeviceInfo.totalMemery
end

function TFDeviceInfo:getFreeMem()
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return math.ceil(TFProcessHelper:getFreeMemory() / 1024)
    end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getFreeMem",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getIsJailBreak()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getIsJailBreak",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getAddreddBook()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getAddreddBook",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

--will return "2G,3G,4G,5G,WIFI,NO"
function TFDeviceInfo:getNetWorkType()
    -- local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getNetWorkType",nil,"()Ljava/lang/String;")
    -- return TFDeviceInfo.checkResult(ok,ret)
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        return "WIFI"
    end

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getNetWorkType",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getNetWorkType",nil,"()Ljava/lang/String;")
        return TFDeviceInfo.checkResult(ok,ret)
    end
end

function TFDeviceInfo:copyToPasteBord(content)
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "copyToPasteBord",{szContent = content})
    else
        TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "copyToPasteBord",{content})
    end
end

function TFDeviceInfo:getClipBoardText()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getClipBoardText",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getDeviceToken()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        return CCApplication:sharedApplication():getDeviceTokenID()
     else
        print("android not support")
        return nil
    end
end

function TFDeviceInfo:getCarrierOperator()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getCarrierOperator",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getSDPath()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        print("ios not support")
        return nil
    else
        local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getSDPath",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

function TFDeviceInfo:getPackageName()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        print("ios not support")
        return nil
    else
        local ok,ret = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getCocos2dxPackageName",nil,"()Ljava/lang/String;")
        if ok and #ret >1 then
            return ret
        else
            return nil
        end
    end
end

-- 退出游戏
function TFDeviceInfo:terminateApp()
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        endToLua()
    else
    	TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "terminateProcess")
    end
end

function TFDeviceInfo:getResolution()
    -- body
    return me.frameSize.width .. 'x' .. me.frameSize.height
end

function TFDeviceInfo:getMacAddress()
    local ok = nil
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getMacAddress")
    else
        print("only support ios")
    end
    return TFDeviceInfo.checkResult(ok,ret)
end

function TFDeviceInfo:getMachineOnlyID()
    local ok = nil
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.SDK_CLASS_NAME,"getIDFA")
    else
    	--不保证不变动
	ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getMachineOnlyID",nil,"()Ljava/lang/String;")
    end
    return TFDeviceInfo.checkResult(ok,ret)
end

-- 获取设备剩余内存
function TFDeviceInfo:getMachineFreeSpace()
    local ok = false
    local value = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,value = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME,"getDeviceFreeSpace")
    else
        ok1,valueInternal = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","getInternalMemLeftSize",nil,"()I")
        ok2,valueExt = TFLuaOcJava.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","getExternalTotalMemSize",nil,"()I")
        ok = ok1 and ok2 
        if ok then 
            value = valueInternal > valueExt and valueInternal or valueExt
        else 
            if ok1 then value = valueInternal end
            if ok2 then value = valueExt end
            if value then ok = true end
        end
    end
    return TFDeviceInfo.checkResult(ok,value)
end

-- 生成UUID
function TFDeviceInfo:getUUID()
    if CC_TARGET_PLATFORM ~= CC_PLATFORM_ANDROID then 
        return TFProcessHelper:getUUID()
    end
    local ok, ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getUUID",nil,"()Ljava/lang/String;")
    return TFDeviceInfo.checkResult(ok, ret) 
end

-- 设置重力感应时间间隔
function TFDeviceInfo:setAccelerometerInterval(interval)
    interval = interval or 0.02
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setAccelerometerInterval", {interval = interval})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setAccelerometerInterval", {interval})
    end
end

--打开重力感应
function TFDeviceInfo:setOpenAccelerometer(isOpenAccelerometer)
	if isOpenAccelerometer == nil then isOpenAccelerometer = true end
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setOpenAccelerometer", {isOpenAccelerometer = isOpenAccelerometer})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setOpenAccelerometer", {isOpenAccelerometer})
    end
    return ok
end

function TFDeviceInfo:setCloseAccelerometer()
    TFDeviceInfo:setOpenAccelerometer(false)
end

-- 是否打开系统浏览器
function TFDeviceInfo:openUrl(url)
    local ok  = false
    local ret = nil
    if HeitaoSdk then
        if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
            ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openUrl", {url = url})
        elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
            ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openUrl", {url})
        end
    end

    return ok
end

--打开黑桃sdk的内嵌网页
function TFDeviceInfo:openHeitaoWebUrl(url)
    local ok  = false
    local ret = nil

    if HeitaoSdk then
        if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
            ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openHeitaoWebUrl", {url = url})
        elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
            ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openHeitaoWebUrl", {url})
        end
    end
    return ok
end

--获取手机电量
function TFDeviceInfo:getBatteryLevel()
    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then 
        return 100
    end
    local ok, ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getBatteryLevel", nil, "()I")
    if ok then
        if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then 
            ret = ret * 100
        end
        ret = math.floor(ret)
        return ret
    end
    return 0
end

-- 震动, ios 无法指定时间
function TFDeviceInfo:Vibrator(value)
    local ok,ret
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then 
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "Vibrator")
    else    
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "Vibrator", {value}, "(I)V")
    end
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 取消震动, ios 无效
function TFDeviceInfo:cancelVibrator()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "cancelVibrate")
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 是否保持屏幕常亮
function TFDeviceInfo:setKeepScreenOn(isOn)
    if isOn == nil then isOn = true end
    local ok,ret
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then 
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.SDK_CLASS_NAME, "disableDeviceSleep", { notSleep = isOn })
    else 
        ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setKeepScreenOn", { isOn })
    end
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 设置音效播放速率
function TFDeviceInfo:setSoundEffectRate(rate)
    rate = rate or 1
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "setEffectSpeedRate", { rate })
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 获取音效播放速率
function TFDeviceInfo:getSoundEffectRate()
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getEffectSpeedRate", nil, "()F")
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 获取android应用pss总量
function TFDeviceInfo:getPSS()
    print("get PSS 1", me.platform, me.platform ~= "android")
    if me.platform ~= "android" then return 0 end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getPSS", nil, "()I")
    return TFDeviceInfo.checkResult(ok, ret)
end

-- 获取android应用Mem总量
function TFDeviceInfo:getAppMem()
    if me.platform ~= "android" then return 0 end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "getAppMem", nil, "()I")
    return TFDeviceInfo.checkResult(ok, ret)
end

function TFDeviceInfo:isGoogleObbExist()
    if me.platform ~= "android" then return 0 end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "isGoogleObbExist", nil, "()Z")
    return TFDeviceInfo.checkResult(ok, ret)
end


function TFDeviceInfo:requestStoreReview()
    if me.platform ~= "ios" then return 0 end
    local ok,ret = TFLuaOcJava.callStaticMethod(TFDeviceInfo.CLASS_NAME, "requestStoreReview", nil, "()V")
    return TFDeviceInfo.checkResult(ok, ret)
end

return TFDeviceInfo
  
