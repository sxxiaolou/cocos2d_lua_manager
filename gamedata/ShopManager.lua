--[[
******商店管理类*******

	-- by Tony
	-- 2016/10/18
]]

local BaseManager = require('lua.gamedata.BaseManager')
local ShopManager = class("ShopManager", BaseManager)

ShopManager.UpdateShop = "ShopManager.UpdateShop"
ShopManager.CloseShop = "ShopManager.CloseShop"
ShopManager.UpdateGuildShop = "ShopManager.UpdateGuildShop"

function ShopManager:ctor(data)
	self.super.ctor(self, data)

end

function ShopManager:init()
	self.super.init(self)
	
	TFDirector:addProto(s2c.ALL_SHOP_INFO, self, self.onReceiveAllShopInfo)
	TFDirector:addProto(s2c.SHOP_INFO, self, self.onReceiveShopInfo)
	TFDirector:addProto(s2c.REFRESH_SHOP, self, self.onReceiveRefreshShop)
	TFDirector:addProto(s2c.BUY_COMMODITY, self, self.onReceiveBuy)
	TFDirector:addProto(s2c.CLOSE_SHOP, self, self.onCloseShop)
	TFDirector:addProto(s2c.GUILD_SHOP_INFO_RES, self, self.onReceiveGuildShop)
	TFDirector:addProto(s2c.GUILD_SHOP_BUY_RES, self, self.onReceiveGuildBuy)

	self.shopMap = {}
	--登录游戏，各类型商店只做第一个红点显示，进入界面红点取消
	self.firstShopRedPointList = {}
end

function ShopManager:restart()
	for _,v in pairs(self.shopMap) do
		v = nil
	end
	self.shopMap = {}
	self.firstShopRedPointList = {}
end



function ShopManager:onReceiveAllShopInfo(event)
	hideLoading()

	local data = event.data
	-- print("===== onReceiveAllShopInfo ========", data)
	local shops = data.shops or {}
	for _,shop in pairs(shops) do
		self:addShop(shop)
	end
end

function ShopManager:onReceiveShopInfo(event)
	hideLoading()

	local data = event.data
	-- print("===== onReceiveShopInfo ========", data)
	self:addShop(data)

	TFDirector:dispatchGlobalEventWith(ShopManager.UpdateShop, 0)
end

function ShopManager:onReceiveRefreshShop(event)
	hideLoading()
end

function ShopManager:onReceiveBuy(event)
	hideLoading()

	local data = event.data
	local shopInfo = self:findShop(data.shopType, data.shopTag)
	if shopInfo then
		for _,v in pairs(shopInfo.commodities) do
			if v.id == data.id then
				v.enabled = data.enabled
				v.remainTimes = data.remainTimes
				v.consumeNumber = data.consumeNumber
			end
		end
	end
	TFDirector:dispatchGlobalEventWith(ShopManager.UpdateShop, 0)
end

function ShopManager:onReceiveGuildBuy(event)
	hideLoading()
	GuildManager:updateContributionValue(event.data.contribution)
	self:send(c2s.GUILD_SHOP_INFO_REQ, true)
end

function ShopManager:getGuildShopData()
	return clone(self.guild_shop_data)
end

function ShopManager:onCloseShop( event )
	hideLoading()

	local data = event.data
	-- print("===========  close shop", data)
	if data == nil then return end

	local shopType = data.shopType
	local shopTag = data.shopTag
	self:deleteShop(shopType, shopTag)

	TFDirector:dispatchGlobalEventWith(ShopManager.CloseShop, 0)
end

function ShopManager:onReceiveGuildShop( event )

	local commodities = {}
	table.sort(event.data.goods, function(a, b) return a.id < b.id end)
	local goods_config_list = GuildShopData:getItemlist()
	for _, good_info in pairs(event.data.goods) do
		local commodity = {}
		local goods = DropData:getGoodsById(good_info.goodsId)
		-- local reward = BaseDataManager:getReward(goods)
		local reward = BaseDataManager:getReward({tplId = good_info.goodsId, type = good_info.res_type})

		commodity.resId = good_info.goodsId
		commodity.id = good_info.id
		commodity.resType = goods_config_list[good_info.id].res_type
		commodity.remainTimes = good_info.count
		commodity.consumeType = EnumResourceType.GuildContribution
		commodity.needVipLevel = 0
		commodity.shopTag = 1
		commodity.number = good_info.countOnce
		commodity.consumeId = 0
		commodity.commodityTag = 0
		commodity.consumeNumber = {good_info.price}
		commodity.maxTimes = 1
		commodity.enabled = true
		commodity.shopType = EnumShopType.FactionShop
		commodity.guildShopLevel = good_info.needLevel
		commodity.type = goods_config_list[good_info.id].type
		commodities[#commodities+1]= commodity
	end
	-- local shopInfo = self:findShop(event.data.shopType, event.data.shopTag)
	-- if shopInfo then
	-- 	shopInfo.commodities = commodities
	-- end

	for k,v in pairs(self.shopMap) do
		if v.shopType == EnumShopType.FactionShop and v.shopTag == 1 then
			v.commodities = commodities
		end
	end

	TFDirector:dispatchGlobalEventWith(ShopManager.UpdateShop, 0)


	-- if AlertManager:getLayerByName("lua.logic.guild.GuildShopLayer") then
	-- 	print("********************", event.data)
	-- 	TFDirector:dispatchGlobalEventWith(ShopManager.UpdateGuildShop, event.data)
	-- else
	-- 	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildShopLayer")
	-- 	layer:loadData(EnumShopType.FactionShop, event.data)
	-- 	AlertManager:show()
	-- end
end

-- =================== proto ===================== 

function ShopManager:sendRefreshShop(shopType, shopTag)
	self:sendWithLoading(c2s.REFRESH_SHOP , shopType, shopTag)
end

-- 购买商品id, 购买商品的数量，购买商品的格子位子
function ShopManager:sendBuyCommodity(commodityId, num, cell)
	self:sendWithLoading(c2s.BUY_COMMODITY , commodityId, num, cell)
end

function ShopManager:sendBuyGuildCommodity(commodityId, num, cell)
	-- print("commodityId", commodityId, num, cell)
	self:sendWithLoading(c2s.GUILD_SHOP_BUY_REQ, commodityId, num)
end

--======================= end ==============================

function ShopManager:addShop(shop)
	-- print("function ShopManager:addShop(shop)", shop.shopType)
	for k,v in pairs(self.shopMap) do
		if v.shopType == shop.shopType and v.shopTag == shop.shopTag then
			self.shopMap[k] = shop
			return
		end
	end
	self.shopMap[#self.shopMap+1]=shop
	if shop.shopType == 16 then
		self:send(c2s.GUILD_SHOP_INFO_REQ, true)
	end
end

function ShopManager:deleteShop(shopType, shopTag)
	for k,v in pairs(self.shopMap) do
		if v.shopType == shopType and v.shopTag == shopTag then
			self.shopMap[k] = nil
			return
		end
	end
end

function ShopManager:findShop(shopType, shopTag)
	for k,v in pairs(self.shopMap) do
		if v.shopType == shopType and v.shopTag == shopTag then
			return v
		end
	end
	return nil
end

function ShopManager:getShop()
	return self.shopMap
end

function ShopManager:getShopByType(shopType)
	local shops = {}
	for k,v in pairs(self.shopMap) do
		if v.shopType == shopType then
			table.insert(shops,v)
		end
	end
	return shops
end

function ShopManager:getTagByType(shopType)
	local tags = {}
	local count = 0
	for k,v in pairs(self.shopMap) do
		if v.shopType == shopType then
			tags[v.shopTag]=v.shopTag
			count = count + 1
		end
	end
	return tags, count
end

function ShopManager:getShopCell(data)
	local shop = self:findShop(data.shopType, data.shopTag)
	if shop then
		local count = #shop.commodities
		for i=1,count do
			if shop.commodities[i].id == data.id then
				return i
			end
		end
	end
	return 0
end

function ShopManager:getCommoditie(shopType, id)
	for k,v in pairs(self.shopMap) do
		if v.shopType == shopType then
			local count = #v.commodities
			for i=1,count do
				if v.commodities[i].id == id then
					return true, v.commodities[i]
				end
			end
		end
	end
	return false, nil
end

function ShopManager:getConsumeNumber(consumeNumber, num)
	local count = #consumeNumber
	local total = 0
	for i=1,num do
		if i < count then
			total = total + consumeNumber[i]
		else
			total = total + consumeNumber[count]
		end
	end
	return total
end

function ShopManager:getShopData(goodId, shopType)
	if goodId == nil then return nil end
	shopType = shopType or EnumShopType.SyceeShop
	local tags = self:getTagByType(shopType)
	for k,v in pairs(tags) do
		local shop = self:findShop(shopType, v)
		if shop and shop.commodities then
			for m,n in pairs(shop.commodities) do
				if n and n.resId and n.resId == goodId then
					return n
				end
			end
		end
	end
	return nil
end

function ShopManager:showShopMainLayer()
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shop.ShopMainLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    AlertManager:show()
end

function ShopManager:showShopLayer(type, tag)
	self:send(c2s.GUILD_SHOP_INFO_REQ, true)

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shop.ShopLayer")
	layer:loadData(type, tag)
	AlertManager:show()
end

function ShopManager:showShoppingLayer(data)
	-- print("showShoppingLayer", data)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.CommonBuyLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	layer:loadData(data)
    AlertManager:show()
end

function ShopManager:showTowerRandomLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shop.ShopTowerRandomLayer")
	layer:loadData(1)
    AlertManager:show()
end

-- 显示博彩商店
function ShopManager:showBoCaiLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shop.ShopTowerRandomLayer")
	layer:loadData(2)
    AlertManager:show()
end

function ShopManager:GetShopNameByType( types )
	-- body
	if types == EnumShopType.SyceeShop then
		return "ui/shop/img_yuanbao_shop.png"
	elseif types == EnumShopType.ArenaShop then
		return "ui/shop/img_jjc.png"
	elseif types == EnumShopType.RoleShop then
		return "ui/shop/img_juese.png"
	elseif types == EnumShopType.TowerShop then
		return "ui/shop/img_guishenzhita.png"
	elseif types == EnumShopType.DevildomShop then
		return "ui/shop/img_mojie.png"
	elseif types == EnumShopType.FactionShop then
		return "ui/shop/img_gonghui.png"
	elseif types == EnumShopType.QunyingShop then
		return "ui/shop/img_qunyingshan.png"
	elseif types == EnumShopType.PetShop then
		return "ui/shop/img_chongwushangdian.png"
	elseif types == EnumShopType.TowerRandomShop then
		return "ui/shop/img_guishensuiji.png"
	elseif types == EnumShopType.QunyingRandomShop then
		return "ui/shop/img_tongtiansuiji.png"
	elseif types == EnumShopType.TowerMaterialShop then
		return "ui/shop/img_guishencailiao.png"
	elseif types == EnumShopType.LotteryShop then
		return "ui/shop/img_choujiang.png"
	elseif types == EnumShopType.BocaiShop then
		return "ui/shop/img_xianyuanshangdian.png"
	end

	return "ui/shop/img_yuanbao_shop.png"
end

function ShopManager:GetShopBgByType( types )
	
	for k,v in pairs(EnumShopType) do
		if v == types then
			return "icon/shop/img_shop_" .. types ..".png"
		end
	end

	return "ui/shop/img_shop_11.png"
end

function ShopManager:getShopFunctionId(type)
	if type == EnumShopType.SyceeShop then
		return FunctionManager.ShopSycee
	elseif type == EnumShopType.ArenaShop then
		return FunctionManager.ShopArena
	elseif type == EnumShopType.RoleShop then
		return FunctionManager.ShopRole
	elseif type == EnumShopType.TowerShop then
		return FunctionManager.ShopTower
	elseif type == EnumShopType.DevildomShop then
		return FunctionManager.ShopDevildom
	elseif type == EnumShopType.FactionShop then
		return FunctionManager.ShopFaction
	elseif type == EnumShopType.QunyingShop then
		return FunctionManager.ShopQunying
	elseif type == EnumShopType.PetShop then
		return FunctionManager.ShopPet
	elseif type == EnumShopType.TowerRandomShop then
		return FunctionManager.ShopTowerRandom
	elseif type == EnumShopType.QunyingRandomShop then
		return FunctionManager.ShopQunyingRandom
	elseif type == EnumShopType.TowerMaterialShop then
		return FunctionManager.ShopTowerMaterial
	elseif type == EnumShopType.ShopLottery then
		return FunctionManager.ShopLottery
	end

	return FunctionManager.ShopSycee
end

function ShopManager:isHaveRedPoint(shopType)
	if self.firstShopRedPointList[shopType] then
		return false
	end
	for k,v1 in pairs(self.shopMap) do
		if v1.shopType == shopType then
			for i,v2 in ipairs(v1.commodities or {}) do
				if v2.enabled and (v2.maxTimes == 0 or (v2.maxTimes ~= 0 and v2.remainTimes ~= 0 )) then
					local resNum = getResValueByType(v2.consumeType)
					if v2.consumeType == EnumResourceType.Sycee or v2.consumeType == EnumResourceType.Coin then
						if v2.maxTimes ~= 0 and  resNum >= v2.consumeNumber[1] then	--为元宝或金币时，只有限购才会显示红点
							return true
						end
					else
						if  resNum >= v2.consumeNumber[1] then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

return ShopManager:new()