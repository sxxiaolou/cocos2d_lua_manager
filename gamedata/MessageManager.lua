-- Created by ZZTENG on 2017/01/31.
--消息推送类型管理

local MessageManager = class("MessageManager", BaseManager)

function MessageManager:ctor()
	self.super.ctor(self)
end

function MessageManager:init()
    self.super.init(self)

    self.infoTypeList = {}
end

function MessageManager:restart()
    -- 清除数据
    self.infoTypeList = {}
end

function MessageManager:pushTypeInMessageLayer( type )
    table.uniqueAdd(self.infoTypeList,type)
end

function MessageManager:removeTypeFormTypeList( type )
    table.removeOne(self.infoTypeList,function ( curType )
        if curType == type then
            return true
        else
            return false
        end
    end)
end

function MessageManager:getFirstType( ... )
    if #self.infoTypeList == 0 then return nil end
    return self.infoTypeList[1]
end

function MessageManager:removeTopTypeFormList( ... )
    if #self.infoTypeList == 0 then return end
    table.remove(self.infoTypeList,1)
end

function MessageManager:isHaveType( type )
    for k,v in pairs(self.infoTypeList) do
        if v == type then 
            return true
        end
    end
    return false
end

return MessageManager:new()