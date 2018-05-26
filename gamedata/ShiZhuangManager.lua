--[[
******时装管理类*******

]]

local BaseManager = require("lua.gamedata.BaseManager")
local ShiZhuangManager = class("ShiZhuangManager", BaseManager)
--返回角色时装信息事件
ShiZhuangManager.FASHIONINFORES 	= "ShiZhuangManager.FashionInfoRes"

function ShiZhuangManager:ctor()
	self.super.ctor(self)
	self.super.ctor(self)
end

function ShiZhuangManager:init()
    self.super.init(self)
    self.FashionInfoResInfo=nil
    ShiZhuangManager.openshizhuangIng=false;
    self.cardRole=nil;
    TFDirector:addProto(s2c.FASHION_INFO_RES, self, self.OnFashionInfoRes)
    TFDirector:addProto(s2c.FASHION_BUY_RES, self, self.OnFashionBuyRes)
    
end

function ShiZhuangManager:restart()
    TFDirector:addMEGlobalListener(BagManager.ITEM_USED_RESULT, self.usedResultListener)
end

function  ShiZhuangManager:openShiZhuang(cardRole)
    ShiZhuangManager.openshizhuangIng=true;
    self.cardRole=cardRole;
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrropenShiZhuang1222222222222222222222222222222222222222222222222222222222')
    self:sendFashionInfoReq(cardRole.gmId)
end

function ShiZhuangManager:openShiZhuangLayer(cardRole)
    ShiZhuangManager.openshizhuangIng=false;
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shizhuang.ShiZhuangLayer")
   layer:loadData(cardRole)
   AlertManager:show()
  -- print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrropenShiZhuang111111111111111111111111111111111111111111',ShiZhuangManager.openshizhuangIng)
end



function ShiZhuangManager:openHuoDeNewShiZhuangLayer(fashionid)
   -- ShiZhuangManager.openshizhuangIng=false;
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shizhuang.HuoDeNewShiZhuangLayer",AlertManager.BLOCK_AND_GRAY_CLOSE)
   layer:loadData(fashionid)
   AlertManager:show()
  -- print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrropenShiZhuang111111111111111111111111111111111111111111',ShiZhuangManager.openshizhuangIng)
end
function ShiZhuangManager:setFashionInfoResInfo()

end

--请求角色时装信息
function ShiZhuangManager:sendFashionInfoReq(roleId)
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrsendFashionInfoReq',roleId)
	self:sendWithLoading(c2s.FASHION_INFO_REQ, roleId)
end
-- 点新时装
function ShiZhuangManager:FashionNewReq(roleId,fashionId)
    self:sendWithLoading(c2s.FASHION_NEW_REQ, roleId,fashionId)
end
-- 买时装
function ShiZhuangManager:FashionBuyReq(roleId,fashionId)
    self:sendWithLoading(c2s.FASHION_BUY_REQ, roleId,fashionId)
end
--换时装
function ShiZhuangManager:FashionChangeReq(roleId,fashionId)
    self:sendWithLoading(c2s.FASHION_CHANGE_REQ, roleId,fashionId)
end

--返回角色时装信息
function ShiZhuangManager:OnFashionInfoRes( event )
    hideLoading()
    local data = event.data
    self.FashionInfoResInfo= event.data;
    TFDirector:dispatchGlobalEventWith(ShiZhuangManager.FASHIONINFORES, data)
 --   print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr'..
 --   'rrrrrrrrrrrrrrrrrrr'..
 --   'rrrrrrrrrrrr'..
  --  'rrrrrrrrrrrshizhuang self.showId= ',data)
  --  print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr', ShiZhuangManager.openshizhuangIng)
   
    if ShiZhuangManager.openshizhuangIng then
        ShiZhuangManager:openShiZhuangLayer( self.cardRole);

    end
    -- body
end
--返回时装获得
function ShiZhuangManager:OnFashionBuyRes( event )
    hideLoading()
    local data = event.data
  --  self.FashionInfoResInfo= event.data;
  --  TFDirector:dispatchGlobalEventWith(BagManager.ITEM_USED_RESULT, data)
    -- body
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrFashionBuyRes'..data.fashionId)
end

return ShiZhuangManager:new()

