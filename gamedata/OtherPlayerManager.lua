--[[
******其它玩家游戏数据管理类*******

	-- by Jing
	-- 2016/6/28
]]


local BaseManager = require('lua.gamedata.BaseManager')
local OtherPlayerManager = class("OtherPlayerManager", BaseManager)

local CardRole = require('lua.gamedata.base.CardRole')
local CardEquipment = require("lua.gamedata.base.CardEquipment")
local PetRole = require('lua.gamedata.base.PetRole')

OtherPlayerManager.FriendFight = "OtherPlayerManager.friendsFight"

function OtherPlayerManager:ctor()
	self.super.ctor(self)
end

function OtherPlayerManager:init()
	self.super.init(self)

	self.otherPlayerList = {}

	TFDirector:addProto(s2c.GET_OTHER_PLAYER_SUC, self, self.onGetOtherPlayerInfo)

	TFDirector:addProto(s2c.CARD_INFO_RES, self, self.onCardInfoRes)
end

function OtherPlayerManager:restart()
	self.otherPlayerList = {}
end

-- protocol
function OtherPlayerManager:sendGetOtherPlayer(playerId, openFormation)
	self.isOpenFormation = openFormation
	if self.isOpenFormation and not ServerSwitchManager:isOtherPlayerFormationOpen() then
		self.isOpenFormation = false
		toastMessage(localizable.commom_no_open2)
		return
	end
	self:sendWithLoading(c2s.GET_OTHER_PLAYER, playerId)
end

function OtherPlayerManager:sendChallengeOtherPlayer(playerId)
	self:sendWithLoading(c2s.CHALLENGE_OTHER_PLAYER, playerId)
end

function OtherPlayerManager:onGetOtherPlayerInfo(event)
	hideLoading()

	local otherPlayerInfo = event.data.player
	-- otherPlayerInfo.formation = stringToNumberTable(otherPlayerInfo.formation, ',')
	self.otherPlayerList[otherPlayerInfo.playerId] = otherPlayerInfo

	if self.isOpenFormation then
		self.isOpenFormation = false
		self:openOtherFormationLayer(otherPlayerInfo)
	else
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.FriendFight , otherPlayerInfo)
	end
end


----------查看其它玩家阵型
function OtherPlayerManager:openOtherFormationLayer(otherPlayerInfo)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.OtherFormationLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(otherPlayerInfo)
    AlertManager:show()
end

function OtherPlayerManager:sendCardInfoReq(playerId, roleId)
	if not ServerSwitchManager:isOtherPlayerFormationOpen() then
		toastMessage(localizable.commom_no_open2)
		return
	end
	self:sendWithLoading(c2s.CARD_INFO_REQ, playerId, roleId)
end

function OtherPlayerManager:onCardInfoRes(event)
	hideLoading()
	local data = event.data
	local info = data.rolecard

	info.playerId = -1 -- 其他玩家
	info.name = data.playerName
	local cardRole = CardRole:new(info)
	cardRole.totalAttribute = cardRole.totalAttribute or {}
	cardRole.totalAttribute.attribute = cardRole.totalAttribute.attribute or {}

	cardRole.totalAttribute.attribute[EnumAttributeType.Hp] = data.attribute.hp
	cardRole.totalAttribute.attribute[EnumAttributeType.Atk] = data.attribute.attack
	cardRole.totalAttribute.attribute[EnumAttributeType.PhyDef] = data.attribute.phyDef
	cardRole.totalAttribute.attribute[EnumAttributeType.MagicDef] = data.attribute.magDef
	cardRole.totalAttribute.attribute[EnumAttributeType.Speed] = data.attribute.speed
	cardRole.totalAttribute.attribute[EnumAttributeType.Hit] = data.attribute.hitRate
	cardRole.totalAttribute.attribute[EnumAttributeType.Miss] = data.attribute.dodgeRate
	cardRole.totalAttribute.attribute[EnumAttributeType.Crit] = data.attribute.critRate
	cardRole.totalAttribute.attribute[EnumAttributeType.CritResistance] = data.attribute.resistCritRate

	cardRole.power = data.attribute.power

	local equip = {}
	for i,v in ipairs(data.equip or {}) do
		cardEquip = CardEquipment:new(v)
		equip[v.id] = cardEquip
	end
	data.equip = equip

	-- for i,v in ipairs(data.artifact or {}) do
	if data.artifact then
		data.artifact = ArtifactManager:onCreateArtifact( data.artifact )
	end

	if data.pet then
		data.pet = PetRole:new(data.pet)
	end
	-- end

	CardRoleManager:setSelectedCardRole(cardRole)
    CardRoleManager:openRoleInfoLayer(cardRole, data)
end

function OtherPlayerManager:openPetLookLayer(petInfo)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.pet.PetLookLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(petInfo)
    AlertManager:show()
end

return OtherPlayerManager:new()