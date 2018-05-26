--[[
******数据统计管理*******

	-- by Tony
	-- 2017/4/14
]]

local BaseManager = require("lua.gamedata.BaseManager")
local StatisticsManager = class("StatisticsManager", BaseManager)

function StatisticsManager:ctor(data)
	self.super.ctor(self)
end

function StatisticsManager:init()
	self.super.init(self)
	self.switcher = false
	self.statMap = {}
	self:initStatisticsData()

	TFDirector:addProto(s2c.LOG_SWITCHER, self, self.onReceiveLogSwitch)
end

function StatisticsManager:restart(  )
	self.switcher = false
end

function StatisticsManager:initStatisticsData( ... )
	local statisticsList = {
		FunctionManager.MenuGamble,		
		FunctionManager.MenuShop,		
		FunctionManager.MenuFuLi,		
		FunctionManager.MenuWeixin,		
		FunctionManager.MenuWudaohui,		
		FunctionManager.MenuLottery,    
		FunctionManager.MenuSevenDays,  
		FunctionManager.MenuRank,       
		FunctionManager.MenuPlayerInfo,    
		FunctionManager.MenuBuyCoin,    	
		FunctionManager.MenuPay,    	
		FunctionManager.MenuBuyStrengh,   
		FunctionManager.MenuHandBook,    
		FunctionManager.MenuNewShenQi,   
		FunctionManager.MenuTask,    
		FunctionManager.BookWorld,    
		FunctionManager.MenuRecycle,    
		FunctionManager.ChallengeScene,    
		FunctionManager.MenuShanzi,    
		FunctionManager.MenuNewRoad,
		FunctionManager.MenuChapter,
		FunctionManager.MenuChallenge,
		FunctionManager.MenuEye,
		FunctionManager.Pet,
		FunctionManager.MenuGuild,
		FunctionManager.MenuEquip,
		FunctionManager.MenuFormation,
		FunctionManager.MenuRoleList,
		FunctionManager.MenuArtifact,
		FunctionManager.MenuMail,
		FunctionManager.MenuFriend,
		FunctionManager.MenuBag,
		FunctionManager.MenuRightOffBtn,
		FunctionManager.MenuTaskGoto,
	}

	for i,v in ipairs(statisticsList) do
		self.statMap[v] = true
	end
end

function StatisticsManager:layerJump( id )
	if self.switcher and self.statMap[id] then
		self:sendOperateLogMsg(id)
	end
end

function StatisticsManager:sendOperateLogMsg( operateId )
	self:send(c2s.OPERATE_LOG, { operateId }, "")
end


function StatisticsManager:onReceiveLogSwitch( event )
	self.switcher = event.data.switcher
end

return StatisticsManager:new()