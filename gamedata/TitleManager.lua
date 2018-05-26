-- Created by ZZTENG on 2017/02/14.
--称号管理

local TitleManager = class("TitleManager", BaseManager)

TitleManager.UPDATE_TITLE_INFO = 'TitleManager.UPDATE_TITLE_INFO'

function TitleManager:ctor()
	self.super.ctor(self)
end

function TitleManager:init()
    self.super.init(self)
    self:reset()

    TFDirector:addProto(s2c.TITLE_INFO_LIST, self, self.onReceiveTitleInfoList)
    TFDirector:addProto(s2c.UPDATE_TITLE_INFO, self, self.onReceiveUpdateTitleInfo)
    TFDirector:addProto(s2c.USE_TITLE_SUCESS, self, self.onReceiveUseTitleSucess)
    TFDirector:addProto(s2c.ACTIVE_TITLE_SUCESS, self, self.onReceiveActiveTitleSucess)

    self.updateTitleAttr = function ( ... )
        self:addTitleAttr()
    end
    TFDirector:addMEGlobalListener(FormationManager.UPDATE_FORMATION, self.updateTitleAttr)
end

function TitleManager:restart()
    self:reset()
end

function TitleManager:reset( ... )
    self.titleInfoList = {}
    self.titleAttribute = {}
    self:endTimingTitle()
end

--utils func
--通过称号id得到info
function TitleManager:getTitleInfoById( id )
   for _,titleInfo in pairs(self.titleInfoList) do
       if titleInfo.id == id then
          return titleInfo
       end
   end
   return nil
end

--通过页签得到称号list
function TitleManager:getTitleListByType( type )
    local titleInfoList = {}
    for k,v in pairs(self.titleInfoList) do
        local info = TitleData:getTitleInfoById(v.id)
        if info == nil then break end
        if info.tab == type then 
            table.insert(titleInfoList,v)
        end
        
    end
    return titleInfoList
end
--该称号是否拥有
function TitleManager:haveTitleById( id )
    for k,v in pairs(self.titleInfoList) do
        if v.id == id and v.status == 2 then
            return true
        end
    end
    return false
end

--得到已激活有时间限制的称号
function TitleManager:getTimingTitleInfoList( ... )
    local titleInfoList = {}
    for k,v in pairs(self.titleInfoList) do
        if v.status == 2 and v.remainTime > 0 then
            table.insert(titleInfoList,v)
        end
    end
    return titleInfoList
end

--开始计时时间限制称号
function TitleManager:startTimingTitle( ... )
    local min_remain_time = self:getMinRemainTime()
    print('hhhhhhhhhhhhhhhhhhhhh',min_remain_time)
    if min_remain_time == nil then 
        self:endTimingTitle()
        return 
    end
    if self.limit_time_id then return end
    local  function callback( ... )
        self:endTimingTitle()
        self:sendRefreshTitleInfo()
    end
    self.limit_time_id = TFDirector:addTimer(min_remain_time,1,callback)
end
--结束计时
function TitleManager:endTimingTitle( ... )
    if not self.limit_time_id then return end
    TFDirector:removeTimer(self.limit_time_id)
    self.limit_time_id = nil
end

--得到激活有时间限制，最小时间
function TitleManager:getMinRemainTime( ... )
    local min_remain_time = nil
    local titleInfoList = self:getTimingTitleInfoList()
    for k,v in pairs(titleInfoList) do
        if min_remain_time == nil then
            min_remain_time = v.remainTime
        else
           if min_remain_time <= v.remainTime then
              min_remain_time = v.remainTime
           end
       end
    end
    return min_remain_time
end

--添加称号属性
function TitleManager:addTitleAttr( ... )
    self.titleAttribute = {}
    for k,titleInfo in pairs(self.titleInfoList) do
        if titleInfo.status == 2 then
            local data = TitleData:getTitleInfoById(titleInfo.id)
            if data == nil then  end
            local attr = GetAttrByStringForExtra(data.attrs)
            for k,v in pairs(attr) do
                if self.titleAttribute[k] then
                    self.titleAttribute[k] = self.titleAttribute[k] + v
                else
                    self.titleAttribute[k] = v
                end
            end
        end
    end
    CardRoleManager:updateTitleAttr()
end

--是否使用称号
function TitleManager:isUseTitle( ... )
    for k,titleInfo in pairs(self.titleInfoList) do
        if titleInfo.isUse then
            return true
        end
    end
    return false
end

--目前使用的称号
function TitleManager:useTitleId( ... )
    for k,titleInfo in pairs(self.titleInfoList) do
        if titleInfo.isUse then
            return titleInfo.id 
        end
    end
    return nil
end

--receive proto
function TitleManager:onReceiveTitleInfoList( event )
    print('TitleManager:onReceiveTitleInfoList:',event.data)
    local data = event.data or {}
    self.titleInfoList = data.info or {}
    self:startTimingTitle()
    self:addTitleAttr()
end

function TitleManager:onReceiveUpdateTitleInfo( event )
    hideLoading()
    -- print('TitleManager:onReceiveUpdateTitleInfo:',event.data)
    local data = event.data or {}
    for k,title_info in pairs(data.info or {}) do
        for k,v in pairs(self.titleInfoList) do
            if title_info.id == v.id then
                self.titleInfoList[k] = title_info
                break
            end
        end
    end
    self:startTimingTitle()
    self:addTitleAttr()

    TFDirector:dispatchGlobalEventWith(TitleManager.UPDATE_TITLE_INFO,nil)
end

function TitleManager:onReceiveUseTitleSucess( event )
    hideLoading()
end

function TitleManager:onReceiveActiveTitleSucess(event)
    hideLoading()
end

--send proto
--更新称号信息
function TitleManager:sendUpdateTitleInfo( id )
    self:sendWithLoading(c2s.UPDATE_TITLE_INFO,id)
end
--使用称号
function TitleManager:sendUseTitle( id )
    self:sendWithLoading(c2s.USE_TITLE,id)
end
--激活称号
function TitleManager:sendActiveTitle( id )
    self:sendWithLoading(c2s.ACTIVE_TITLE,id)
end
--刷新所有计时器时间称号信息
function TitleManager:sendRefreshTitleInfo(  )
    self:send(c2s.REFRESH_TITLE_INFO,false)
end
--查看红点
function TitleManager:sendCheckNotify( title_id_list )
    self:sendWithLoading(c2s.CHECK_NOTIFY,title_id_list,false)
end

--red point
--称号入口红点
function TitleManager:titleIconRedPoint( ... )
    for k,v in pairs(self.titleInfoList) do
        if v.notify == 1 then
            return true
        end
    end
    return false
end

--称号页签红点
function TitleManager:titleTabRedPoin( type )
    local titleInfoList = self:getTitleListByType(type)
    for k,v in pairs(titleInfoList) do
        if v.notify == 1 then
            return true
        end
    end
    return false
end

return TitleManager:new()


