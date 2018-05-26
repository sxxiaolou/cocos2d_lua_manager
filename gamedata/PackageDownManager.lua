-- 分包下载管理类
-- Author: Tony
-- Date: 2018-04-02
--

local PackageDownManager = class("PackageDownManager", BaseManager)

local PackageDownloader = require("lua.public.PackageDownloader")

PackageDownManager.DOWN_LOAD_LAYER           = "PackageDownManager.DOWN_LOAD_LAYER"
PackageDownManager.DOWN_TIPS_LAYER           = "PackageDownManager.DOWN_TIPS_LAYER"
PackageDownManager.DOWN_LOAD_UPDATE           = "PackageDownManager.DOWN_LOAD_UPDATE"
PackageDownManager.DOWN_LOAD_FINISH           = "PackageDownManager.DOWN_LOAD_FINISH"

function PackageDownManager:ctor()
	self.super.ctor(self)
end

function PackageDownManager:init()
	self.super.init(self)

    self.backDownload = false
	self:initGlobalListener()

    self.downLoadList = nil
    self.localContent = nil
end

function PackageDownManager:initLocalContent()
    local content = PackageDownloader:getLocalFileInfo()
    local delims = {"[Key:]", "[Md5:]", "[HasDownload:]", "[Status:]"}
    local tbl = stringToTable(content, "&")

    local temp = nil
    self.localContent = {}
    for _,v in pairs(tbl) do
        local str = v
        temp = {}
        for m, n in pairs(delims) do
            local t = stringToTable(str, n)
            str = t[2]
            if t[1] ~= "" then temp[#temp+1] = t[1] end
            if m == #delims then temp[#temp] = t[2] end
        end
        temp[#temp+1] = tonumber(temp[#temp]) == 2 and true or false
        self.localContent[temp[1]] = temp
    end
end

function PackageDownManager:getLocalContentByType(type)
    if not type then return end
    if not PackageDownloader.DownLoadStr[type] then return end
    return self.localContent[PackageDownloader.DownLoadStr[type]]
end

function PackageDownManager:initGlobalListener()
	TFDirector:removeMEGlobalListener(PackageDownManager.DOWN_LOAD_LAYER)
    TFDirector:removeMEGlobalListener(PackageDownManager.DOWN_TIPS_LAYER)
    TFDirector:removeMEGlobalListener(PackageDownloader.SERVER_MD5)
    TFDirector:removeMEGlobalListener(PackageDownloader.DOWN_LOAD)

    TFDirector:addMEGlobalListener(PackageDownManager.DOWN_LOAD_LAYER,
    function(events)
        local data = events.data[1]
        self:openDownLoadLayer(data)
    end)
    TFDirector:addMEGlobalListener(PackageDownManager.DOWN_TIPS_LAYER,
    function(events)
        self:openDownTipsLayer()
    end)

    TFDirector:addMEGlobalListener(PackageDownloader.SERVER_MD5, function ()
    	self:onServerMd5()
    end)

    TFDirector:addMEGlobalListener(PackageDownloader.DOWN_LOAD, function (events)
        local data = events.data[1]
    	self:onDownLoad(data)
    end)
end

function PackageDownManager:restart()
    self.backDownload = false
	PackageDownloader:restart()
    self.downLoadList = nil
    self:initLocalContent()
end

function PackageDownManager:createCurDownLoad()
    if self.curDownLoad then return end

    self.curDownLoad = {type=0,cur=0,total=0}
end

function PackageDownManager:onServerMd5()
    if not self.downLoadList or #self.downLoadList == 0 then
        TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_FINISH)
        return
    end

    --非wifi下，停止静默下载
    if self.backDownload and TFDeviceInfo:getNetWorkType() ~= "WIFI" then return end

    if not self.curDownLoad then self:createCurDownLoad() end

    local itemDownList = {}
    for i,v in pairs(self.downLoadList) do
        local itemDown = self:getLocalContentByType(v)
        if not itemDown or not itemDown[#itemDown] then
            itemDownList[#itemDownList + 1] = v
        end
    end

    self.downLoadList = itemDownList

    self.curDownLoad.type = self.downLoadList[1]
    PackageDownloader:downloadPackage(PackageDownloader.DownLoadStr[self.curDownLoad.type], false)
    table.remove(self.downLoadList, 1)
end

function PackageDownManager:onDownLoad(data)
    local param1, param2 = data[1], data[2]
    if not param1 or not param2 then return end
    if not self.curDownLoad then return end

    
    if param1 < 0 and param1 ~= -120 and param1 ~= -110 then
        self.downLoadList = {}
        local str = PackageDownloader.DownLoadStr[self.curDownLoad.type]
        self.localContent[str] = {str, "", 0, false}
        self.curDownLoad = nil
        str = localizable.down_load_code[param1]
        if str == "" or not str then return end
        CommonManager:openNewConfirm1(str,localizable.common_btn_ok)
        return
    end

    if param1 == -120 or param1 == -110 then
        self.curDownLoad.cur = param2
        self.curDownLoad.total = param2
    else
        self.curDownLoad.cur = param1
        self.curDownLoad.total = param2
    end 

    TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_UPDATE)
    if param1 == -120 then
        local str = PackageDownloader.DownLoadStr[self.curDownLoad.type]
        self.localContent[str] = {str, "", 2, true}
        MainPlayer:sendSubPackageDownLoad(self.curDownLoad.type)
        self.curDownLoad = nil
        self:onServerMd5()
    end
end

function PackageDownManager:setDownLoadList(tbl, backDownload)
    self.downLoadList = tbl
    self.backDownload = backDownload or false
    if self.curDownLoad then return end
    PackageDownloader:getTheMd5FromServer()
end

function PackageDownManager:getCurDownLoad()
    return self.curDownLoad
end

function PackageDownManager:isAllDownLoad()
    for k,v in pairs(EnumSubPackageType) do
        if not self:isDownLoadByType(v) then
            return false
        end
    end
    return true
end

function PackageDownManager:isDownLoadByType(type)
    -- if MainPlayer.subPackage[type] then return true end

    local content = PackageDownloader.DownLoadStr[type]
    local temp = self.localContent[content]
    if not temp or not temp[#temp] then return false end
    return true
end

function PackageDownManager:isDownLoad(tbl)
    if not tbl then return false end
    if #tbl == 0 then return self:isAllDownLoad() end
    for _, v in pairs(tbl) do
        -- print("&&&&&&&&&&&&&&&&&&&& ====", v, self:isDownLoadByType(v))
        if not self:isDownLoadByType(v) then
            return false
        end
    end
    return true
end

function PackageDownManager:getDownLoadSize()
    local tbl = {}
    for k,v in pairs(PackageDownloader.DownLoadStr) do
        tbl[k] = ConstantData:getValue("Download." .. v)
    end
    return tbl
end

function PackageDownManager:getDownLoadTypes()
    local tbl = {}
    for _,v in pairs(EnumSubPackageType) do
        local temp = self:getLocalContentByType(v)
        if not temp or not temp[#temp] then --not MainPlayer.subPackage[v] and (
            tbl[#tbl+1]=v
        end
    end

    table.sort( tbl, function( t1, t2 )
        return t1 < t2
    end )

    return tbl
end

--分包下载界面 
function PackageDownManager:openDownLoadLayer(data)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.DownLoadLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:loadData(data)
    AlertManager:show()
end

--分包下载提示界面 
function PackageDownManager:openDownTipsLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.DownTipsLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

return PackageDownManager:new()