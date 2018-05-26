--[[
******服务器开关管理类*******

	-- by Jing
	-- 2017/12/1
]]

local BaseManager = require("lua.gamedata.BaseManager")
local ServerSwitchManager = class("ServerSwitchManager", BaseManager)

ServerSwitchManager.ServerSwitchChange= "ServerSwitchManager.ServerSwitchChange" --服务器开关变更
ServerSwitchManager.AllServerSwitchChange= "ServerSwitchManager.AllServerSwitchChange" --所有服务器开关变更

--ServerSwitchType

function ServerSwitchManager:ctor(data)
	self.super.ctor(self)
end

function ServerSwitchManager:init()
	self.super.init(self)

	self.serverSwitch = {}
    TFDirector:addProto(s2c.SERVER_SWITCH_INFO_RESULT, self, self.onServerSwitchInfoResult)
end

function ServerSwitchManager:restart()
	self:reset()
end

function ServerSwitchManager:reset()
	for k,v in pairs(self.serverSwitch) do
		if v.beginTimer then
			TFDirector:removeTimer(v.beginTimer)
			v.beginTimer = nil 
		end
		if v.endTimer then
			TFDirector:removeTimer(v.endTimer)
			v.endTimer = nil 
		end
	end
	self.serverSwitch = {}
end

--是否开启服务器
function ServerSwitchManager:isServerOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.Server)
end

--是否开启登录
function ServerSwitchManager:isLoginOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.Login)
end

--是否开启充值
function ServerSwitchManager:isPayOpen()
	return self:getServerSwitchStatue(ServerSwitchType.Pay)
end

--是否开启创建角色
function ServerSwitchManager:isCreateRoleOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.CreatePlayer)
end

-- 是否开启微信关注
function ServerSwitchManager:isWeChatOpen()
	return self:getServerSwitchStatue(ServerSwitchType.WeChat)
end

--是否开启礼包码
function ServerSwitchManager:isExchangeOpen()
	return self:getServerSwitchStatue(ServerSwitchType.LiBaoMa)
end

-- 是否开启分享
function ServerSwitchManager:isShareOpen()
	return self:getServerSwitchStatue(ServerSwitchType.Share)
end

--是否开启签到
function ServerSwitchManager:isSignOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.Sign)
end

--是否开启月卡
function ServerSwitchManager:isMonthCardOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.MonthCard)
end

--是否开启跨服聊天
function ServerSwitchManager:isServerChatOpen()
	return self:getServerSwitchStatue(ServerSwitchType.ServerChat)
end

--是否开启防沉迷
function ServerSwitchManager:isAntiAddictionOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.AntiAddiction)
end

--是否开启屏蔽敏感字
function ServerSwitchManager:isSensitiveOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.Sensitive)
end

--是否开启武道会
function ServerSwitchManager:isOpenWudaohui()
	--print('++++++++++++++++++sjj++++++++++++++++++',ServerSwitchType.Wudaohui)
	return self:getServerSwitchStatue(ServerSwitchType.Wudaohui)
	--return false
end

--是否开启VIP特权页面
function ServerSwitchManager:isCustomerServicesOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.CustomerServices)
end

--是否开启组队喊话
function ServerSwitchManager:isTeamShoutOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.TeamShout)
end

--是否开启活动页面
function ServerSwitchManager:isOnlineActivityOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.Activity)
end

--是否开启神宠
function ServerSwitchManager:isGodPetOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.GodPet)
end

--是否开启百万红包
function ServerSwitchManager:isWeChatRedPacketOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.WeChatRedPacket)
end

--是否开启积分赛
function ServerSwitchManager:isScoreMatchOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.ScoreMatch)
end

--是否开启分享
function ServerSwitchManager:isReviewOpen()
	return self:getServerSwitchStatue(ServerSwitchType.Share)
end

--是否开启炼体
function ServerSwitchManager:isCardRefineOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.CardRefine)
end

--是否开启红包雨
function ServerSwitchManager:isLuckyRainOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.LuckyRain)
end

--是否开启公会副本
function ServerSwitchManager:isGuildCopyOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.GuildCopy)
end

--是否开启公会邮件
function ServerSwitchManager:isGuildMailOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.GuildMail)
end

--是否开启其他玩家阵容
function ServerSwitchManager:isOtherPlayerFormationOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.OtherPlayerFormation)
end

--是否开启宠物合成
function ServerSwitchManager:isPetComposeOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.PetCompose)
end

--是否开启寻宝
function ServerSwitchManager:isTreasureHuntOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.TreasureHunt)
end

--是否开启帮会战
function ServerSwitchManager:isGuildWarOpen( ... )
	return self:getServerSwitchStatue(ServerSwitchType.GuildWar)
end

function ServerSwitchManager:onServerSwitchInfoResult( event )
    -- print('ServerSwitchManager:onServerSwitchInfoResult==>',event)

    local count = #event.data.switchList
	for i=1,count do
		local data =  event.data.switchList[i]
		self:_serverSwitchInfo(data)
	end

	TFDirector:dispatchGlobalEventWith(ServerSwitchManager.AllServerSwitchChange)
end


function ServerSwitchManager:_serverSwitchInfo(data )
	if self.serverSwitch[data.switchType] == nil then
		self.serverSwitch[data.switchType] = {}
	end
	local nowTime  = MainPlayer:getNowtime()*1000
	self.serverSwitch[data.switchType].open = data.open
	if self.serverSwitch[data.switchType].beginTimer then
		TFDirector:removeTimer(self.serverSwitch[data.switchType].beginTimer)
		self.serverSwitch[data.switchType].beginTimer = nil
	end
	if self.serverSwitch[data.switchType].endTimer then
		TFDirector:removeTimer(self.serverSwitch[data.switchType].endTimer)
		self.serverSwitch[data.switchType].endTimer = nil
	end
	if self.serverSwitch[data.switchType].open == false then
		TFDirector:dispatchGlobalEventWith(ServerSwitchManager.ServerSwitchChange, data.switchType)
		return
	end
	if data.beginTime ~= nil and data.beginTime > nowTime then
		self.serverSwitch[data.switchType].open = false
		self.serverSwitch[data.switchType].beginTimer = TFDirector:addTimer(data.beginTime - nowTime ,1 ,nil,
			function ()
				self.serverSwitch[data.switchType].open = true
				TFDirector:dispatchGlobalEventWith(ServerSwitchManager.ServerSwitchChange, data.switchType)
				self.serverSwitch[data.switchType].beginTimer = nil
			end)
		TFDirector:dispatchGlobalEventWith(ServerSwitchManager.ServerSwitchChange, data.switchType)
		return
	end
	if data.endTime ~= nil and data.endTime > nowTime then
		self.serverSwitch[data.switchType].endTimer = TFDirector:addTimer(data.endTime - nowTime ,1 ,nil,
			function ()
				self.serverSwitch[data.switchType].open = false
				TFDirector:dispatchGlobalEventWith(ServerSwitchManager.ServerSwitchChange, data.switchType)
				self.serverSwitch[data.switchType].endTimer = nil
			end)
	end
	if  data.endTime ~= nil and data.endTime ~= 0 and data.endTime <= nowTime then
		if self.serverSwitch[data.switchType].endTimer then
			TFDirector:removeTimer(self.serverSwitch[data.switchType].endTimer)
			self.serverSwitch[data.switchType].endTimer = nil
		end
		if self.serverSwitch[data.switchType].open == true then
			self.serverSwitch[data.switchType].open = false
		end
	end
	TFDirector:dispatchGlobalEventWith(ServerSwitchManager.ServerSwitchChange, data.switchType)
end


function ServerSwitchManager:getServerSwitchStatue(key)
	if not key or not self.serverSwitch[key] then
		return false
	end

	return self.serverSwitch[key].open
end


return ServerSwitchManager:new()