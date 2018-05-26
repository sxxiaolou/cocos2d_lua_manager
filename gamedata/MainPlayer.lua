local MainPlayer = class("MainPlayer")

GameObject = require('lua.gamedata.base.GameObject')

--require("lua.config.ClientInfo")
--utf8字符集处理
require("lua.character_set.utf8")
--url编码
require("lua.character_set.urlCodec")

ErrorCodeManager = require('lua.gamedata.ErrorCodeManager')
CommonManager 	 = require("lua.gamedata.CommonManager")
FunctionManager  = require("lua.gamedata.FunctionManager")
CommonUiManager  = require("lua.gamedata.CommonUiManager")
--RedPointManager = require('lua.gamedata.RedPointManager')


--
if IS_SUB_PACKAGE then
	PackageDownManager = require("lua.gamedata.PackageDownManager")
end

----战斗动画资源全局管理器----
GameResourceManager	= require("lua.gamedata.GameResourceManager")
---------------------end---

----   新手引导管理器 ------
PlayerGuideManager= require("lua.gamedata.PlayerGuideManager")
-------------- end --------------

----各模块管理器----
LoginManager = require("lua.gamedata.LoginManager")
CardRoleManager = require("lua.gamedata.CardRoleManager")
PetRoleManager = require('lua.gamedata.PetRoleManager')
GodPetManager = require('lua.gamedata.GodPetManager')
FormationManager = require("lua.gamedata.FormationManager")
BagManager = require("lua.gamedata.BagManager")
GuildManager = require("lua.gamedata.GuildManager")
GuildDungeonManager = require("lua.gamedata.GuildDungeonManager")
GuildTaskManager = require("lua.gamedata.GuildTaskManager")
NewChatManager = require("lua.gamedata.NewChatManager")
VoiceManager = require("lua.gamedata.VoiceManager")
MissionManager = require('lua.gamedata.MissionManager')
RecoverableResManager = require('lua.gamedata.RecoverableResManager')
ServerSwitchManager = require('lua.gamedata.ServerSwitchManager')
RewardManager = require('lua.gamedata.RewardManager')
MaterialManager = require('lua.gamedata.MaterialManager')
SettingManager = require('lua.gamedata.SettingManager')
TaskManager = require('lua.gamedata.TaskManager')
LotteryManager   = require('lua.gamedata.LotteryManager')
BoCaiManager   = require('lua.gamedata.BoCaiManager')
WuDaoHuiManager   = require('lua.gamedata.WuDaoHuiManager')
RoleRefineManager   = require('lua.gamedata.RoleRefineManager')
DebugModeManager = require('lua.gamedata.DebugModeManager')
EquipmentManager  = require('lua.gamedata.EquipmentManager')
ArenaManager = require('lua.gamedata.ArenaManager')
RecycleManager = require('lua.gamedata.RecycleManager')
--TalismanManager = require('lua.gamedata.TalismanManager')
GhostTowerManager = require('lua.gamedata.GhostTowerManager')
FriendManager = require("lua.gamedata.FriendManager")
OtherPlayerManager = require("lua.gamedata.OtherPlayerManager")
ShopManager = require('lua.gamedata.ShopManager')
RankManager = require('lua.gamedata.RankManager')
BloodyWarManager = require('lua.gamedata.BloodyWarManager')
NotifyManager = require('lua.gamedata.NotifyManager')
SevenDaysManager = require('lua.gamedata.SevenDaysManager')
OnlineActivitiesManager = require('lua.gamedata.OnlineActivitiesManager')
CustomActivitiesManager = require('lua.gamedata.CustomActivitiesManager')
RebuyManager = require('lua.gamedata.RebuyManager')
MovieManager    = require('lua.gamedata.MovieManager')
PayManager      = require('lua.gamedata.PayManager')
ArtifactManager = require('lua.gamedata.ArtifactManager')
NewArtifactManager = require('lua.gamedata.NewArtifactManager')
AdventureManager = require('lua.gamedata.AdventureManager')
FuliManager  = require('lua.gamedata.FuliManager')
JumpToManager  = require('lua.gamedata.JumpToManager')
BookWorldManager  = require('lua.gamedata.BookWorldManager')
MapManager = require('lua.gamedata.MapManager')
SyncPosManager = require('lua.gamedata.SyncPosManager')
EyeManager = require('lua.gamedata.EyeManager')
TaskMainManager = require('lua.gamedata.TaskMainManager')
TeamManager = require('lua.gamedata.TeamManager')
RoundTaskManager = require('lua.gamedata.RoundTaskManager')
CelueManager = require('lua.gamedata.CelueManager')
StatisticsManager = require('lua.gamedata.StatisticsManager')
FirstPayManager = require('lua.gamedata.FirstPayManager')
ShiZhuangManager = require('lua.gamedata.ShiZhuangManager')
ScoreMatchManager = require('lua.gamedata.ScoreMatchManager')
MessageManager = require("lua.gamedata.MessageManager")
TitleManager = require('lua.gamedata.TitleManager')
GuildWarManager = require('lua.gamedata.GuildWarManager')
SpecialEquipmentManager = require("lua.gamedata.SpecialEquipmentManager")
---------------------end-- MainPlayer:restart()

----battle模块----
FightManager = require('lua.gamedata.FightManager')
WorldBossManager = require('lua.gamedata.WorldBossManager')

--本地数据存储
SaveManager = require("lua.save.SaveManager")

MainPlayer.ExpChange 		= "MainPlayer.ExpChange" 			--团队经验
MainPlayer.LevelChange 		= "MainPlayer.LevelChange"     		--团队等级
MainPlayer.VipLevelChange 	= "MainPlayer.VipLevelChange"       --VIP等级
MainPlayer.TotalRechargeChange 	= "MainPlayer.TotalRechargeChange"       --VIP等级
MainPlayer.SyceeChange 		= "MainPlayer.SyceeChange"			--元宝
MainPlayer.CoinChange 		= "MainPlayer.CoinChange"           --铜币
MainPlayer.GenuineQiChange 	= "MainPlayer.GenuineQiChange" 		--悟性点
MainPlayer.PlayerInfoChange = "MainPlayer.PlayerInfoChange" 	--玩家数据更新

--david.dai add
MainPlayer.RoleExp 			= "MainPlayer.RoleExp"				--角色经验（未使用）
MainPlayer.QunHaoScore 		= "MainPlayer.QunHaoScore"  		--群豪谱积分
MainPlayer.ErrantryChange 		= "MainPlayer.ErrantryChange"  		--侠义值

--通知资源更新，多条
MainPlayer.ResourceUpdateNotifyBatch 		= "MainPlayer.ResourceUpdateNotifyBatch"  		--通用资源更新通知

MainPlayer.ChallengeTimesChange			= "MainPlayer.ChallengeTimesChange"
MainPlayer.RE_CONNECT_COMPLETE			= "MainPlayer.RE_CONNECT_COMPLETE"
MainPlayer.GAME_RESET					= "MainPlayer.GAME_RESET" --游戏重置
MainPlayer.MultipleOutputNotifyMessage	= "MainPlayer.MultipleOutputNotifyMessage"
MainPlayer.NEW_GUIDE_REWARD	 			= "MainPlayer.NEW_GUIDE_REWARD"
MainPlayer.GuideRecode      			= "MainPlayer.GuideRecode"
MainPlayer.RE_NAME 						= "MainPlayer.RE_NAME"

--新手引导最大id     
MainPlayer.GUIDE_MOVIE = 99999
MainPlayer.MAX_GUIDE_ID = 88888

function MainPlayer:ctor()
	self:init()
	self:registerEvents()
end

function MainPlayer:init()

	self.vipLevel	= 0 			--vip等级
	self.name  		= "" 			--角色名
	self.curExp 	= 0 			--当前经验
	self.sex 		= 0 			--性别
	self.level 		= 0 			--等级
	self.playerId	= "" 			--玩家id
	self.profession = 1 			--职业
	self.useIcon	= 0 			--头像id
	self.frameId	= 0 			--头像框id
	self.sycee 		= 0 			-- 元宝 （rmb）
	self.coin 		= 0 			-- 铜币	（游戏金钱）
	self.stat  		= 0
	self.speed 		= 0				--主角移动速度
	self.addSpeeds 	= 0				--速度增加量
	self.verticalName 		= 0		--垂直显示名字
	self.playerProperties 	= 0		--玩家特性

	--登录时间 
	self.loginTime = 0
	self.pushTime = {}

	self.multipleOutputList = {}

	-- 主城位置
	self.MenuScenePos = -800
	-- 主角位置
	self:initMainRolePos()
	-- npc位置
	self:initNPCPos()

	self.destinyStar		= nil
	self.errantry 		 	= nil
	self.heroHillCoin 		= nil
	self.arenaCoin        	= nil
	self.wudaohuiCoin       = nil
	self.ghostTowerCoin     = nil
	self.petCoin        	= nil
	self.goldenLotCoin  	= nil
	self.silverLotCoin  	= nil
	self.vipExp 			= nil
	self.isFirstPay 		= nil
	self.isGotPayReward  	= nil
	self.payTotalSycee    	= nil
	self.isVipSign  		= nil
	self.useQuickPassTimes  = nil
	self.totalRecharge 		= nil
	self.registTime 		= nil
	self.guideList = {}
	self.timeDifference = 0
	self.subPackage = {}

	-- 登录时间
	self.loginTime = nil
	self.loadingRes = nil
	self.newFunctionId = {}
	
	if self.activityIcons == nil then
		self.activityIcons = TFArray:new()
	end
	self.activityIcons:clear()

	self.is_UpLevel = false
	self.upLevelData = nil

	self.isOpenVip = true
	self.hasOpenNL = false
	self.pushDialogNow = nil
end

function MainPlayer:dispose()
	self:removeEvents()
	self:init()
end

function MainPlayer:registerEvents()
	TFDirector:addProto(s2c.PLAYER_INFO, self, self.playerInfoHandle)
	TFDirector:addProto(s2c.UPDATE_PLAYER_INFO, self, self.updatePlayerInfoHandle)

	TFDirector:addProto(s2c.DINING,self, self.onReceiveGetDiningInfo)

	TFDirector:addProto(s2c.TEAM_UPGRADE, self, self.updateTeamInfo)
	TFDirector:addProto(s2c.ALL_LOADING_RES, self, self.updateLoadingRes)

	TFDirector:addProto(s2c.GET_NEW_FUNCTION_GUIDE, self, self.getNewFunctionInfo)
	TFDirector:addProto(s2c.GET_NEW_FUNCTION_REWARD_RESULT, self, self.getNewFunctionResult)

	TFDirector:addProto(s2c.GUIDE_RECORD_RESULT, self, self.guideRecordResult)

	--TFDirector:addProto(s2c.GUIDE_RECORD_RESULT, self, self.openWeixin)


	self.enterBack = function(events) 
		print("enterBack")
		self.justEnterBack = true
	end
    TFDirector:addMEGlobalListener("applicationDidEnterBackground", self.enterBack)

	self.enterFor = function(events) 
		print("enterFor")
		if self.justEnterBack then
			self.justEnterBack = false

			local isTeam = TeamManager:ishaveTeam()
			local isLeader = SyncPosManager:getTeamInfoByLeaderId(self.playerId)
			local isTeamMember =  isTeam and not isLeader
			if isTeamMember then
				SettingManager:LoginOut()
			end
		end 
	end
	TFDirector:addMEGlobalListener("applicationWillEnterForeground", self.enterFor)
	

	--power
    self.RolePowerBeginListener = function(events)
		local type = nil
		if events.data[1] and events.data[1] == FormationManager.formationType then
			type = FormationManager.formationType
		else
			type = EnumFormationType.PVE
		end
		print('RolePowerBeginListener',type)
		FormationManager:setOldFormationPower( self:getPower(type),type) 
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_POWER_BEGIN, self.RolePowerBeginListener)

	self.RolePowerEndListener = function(events)
		local type = nil
		if events.data[1] and events.data[1] == FormationManager.formationType then
			type = FormationManager.formationType
		else
			type = EnumFormationType.PVE
		end
		print('RolePowerEndListener',type,self:getPower(type),FormationManager:getOldFormationPower(type))
		local value = math.floor( self:getPower(type) - FormationManager:getOldFormationPower(type))
        if value ~= 0 and value ~= self:getPower(type) then
            powerUpLayer(value)
        end
        FormationManager:setOldFormationPower( self:getPower(type),type ) 
    end
	TFDirector:addMEGlobalListener(CardRoleManager.ROLE_POWER_END, self.RolePowerEndListener)
end

function MainPlayer:removeEvents()
	TFDirector:removeProto(s2c.PLAYER_INFO, self, self.playerInfoHandle)
	TFDirector:removeProto(s2c.UPDATE_PLAYER_INFO, self, self.updatePlayerInfoHandle)
	TFDirector:removeProto(s2c.ALL_LOADING_RES, self, self.updateLoadingRes)

	TFDirector:removeProto(s2c.DINING, self, self.onReceiveGetDiningInfo)
	TFDirector:removeProto(s2c.TEAM_UPGRADE, self, self.updateTeamInfo)
	TFDirector:removeProto(s2c.GET_NEW_FUNCTION_GUIDE, self, self.getNewFunctionInfo)
	TFDirector:removeProto(s2c.GET_NEW_FUNCTION_REWARD_RESULT, self, self.getNewFunctionResult)

	TFDirector:removeProto(s2c.GUIDE_RECORD_RESULT, self, self.guideRecordResult)
	--TFDirector:addProto(s2c.GUIDE_RECORD_RESULT, self, self.openWeixin)

	TFDirector:removeMEGlobalListener("applicationDidEnterBackground", self.enterBack)
	self.enterBack = nil
	TFDirector:removeMEGlobalListener("applicationWillEnterForeground", self.enterFor)
	self.enterFor = nil

	--power
    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_POWER_BEGIN, self.RolePowerBeginListener)
    self.RolePowerBeginListener = nil
    
	TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_POWER_END, self.RolePowerEndListener)
    self.RolePowerEndListener = nil
end

function MainPlayer:playerInfoHandle(event)
	local playerInfo = event.data
	-- print("playerInfoHandle", playerInfo)

	self.playerId 			= playerInfo.playerId 	--玩家id
	self.sex 	  			= playerInfo.sex  		--性别   1、男 2、 女
	self.sex 				= (self.sex ~= 1) and 2 or self.sex
	self.name 	  			= playerInfo.name 		--角色名
	self.level 				= playerInfo.level 		--等级
	self.coin 				= playerInfo.coin 		--铜币
	self.curExp 			= playerInfo.exp 		--当前经验
	self.sycee 				= playerInfo.sycee 		--元宝
	self.destinyStar		= playerInfo.destinyStar--可用星星数量
	self.vipLevel 			= playerInfo.vipLevel 	--vip等级
	self.errantry 		 	= playerInfo.xiayi    --侠义值
	self.heroHillCoin 		= playerInfo.heroHillCoin 	--群英山货币
	self.arenaCoin        	= playerInfo.arenaCoin 		--竞技场货币
	self.wudaohuiCoin       = playerInfo.arenaMatchCoin --武道会货币
	self.ghostTowerCoin     = playerInfo.ghostTowerCoin	--鬼神之塔货币
	self.petCoin        	= playerInfo.petCoin 		--宠物货币
	self.goldenLotCoin  	= playerInfo.goldenLotCoin  --金签货币
	self.silverLotCoin  	= playerInfo.silverLotCoin  --银签货币
	self.vipExp 			= playerInfo.vipExp 		--vip经验
	self.isFirstPay 		= playerInfo.isFirstPay 	--是否首充
	self.isGotPayReward  	= playerInfo.isGotPayReward --是否领取过首充奖励
	self.payTotalSycee    	= playerInfo.payTotalSycee 	--充值过的总元宝
	self.isVipSign  		= playerInfo.isVipSign 		--今天是否vip签到过
	self.stat 				= tonumber(playerInfo.statStep) or 0  --统计步骤
	self.lotteryCoin        = playerInfo.lotteryCoin 		--博彩货币
	self.HeadId				= playerInfo.HeadId			--头像ID
	self.serverId  			= playerInfo.serverId or 0		
	self.offlineTime  		= playerInfo.offlineTime or 0	--符鬼离线时间  

	self.useQuickPassTimes  = playerInfo.useQuickPassTimes   --当天已使用免费扫荡次数

	self.totalRecharge 		= playerInfo.totalRecharge
	self.registTime 		= playerInfo.registTime 

	if playerInfo.subPackage then 			--分包下载状态
		for _,v in pairs(playerInfo.subPackage) do
			self.subPackage[v.id] = v.status
		end
	end	

	self:initUserDefaultData()

	local man = ConstantData:getValue("Card.Role.Male")
	local female = ConstantData:getValue("Card.Role.Female")
	if self.HeadId == man or self.HeadId == female then
		self.HeadId = nil
	end

	--headIcon 
	if self.sex == 1 then
		self.useIcon = "icon/roleicon/1.png"
	elseif self.sex == 2 then
		self.useIcon = "icon/roleicon/2.png"
	end

	-- self:addActivityIcon(EnumActivityType.FuLi, true)

	--self:addActivityIcon(EnumActivityType.Weixin, true)
    -- self:openWeixinIcon()
	local serverTime = math.ceil(playerInfo.serverTime/1000)	--服务器时间
	self.timeDifference = serverTime - os.time() 

	-- 登录时间
	self.loginTime = serverTime

	--bugly
	local resVersion = self.resVersion or ""
	hjSetUserId(string.format("%s_s%s_%s", self.playerId, self.serverId, resVersion))
	VoiceManager:SetAppInfo(self.playerId)
end

function MainPlayer:updatePlayerInfoHandle(event)
	local info = event.data

	self.level 			= info.level or self.level
	self.coin 			= info.coin or self.coin
	self.curExp 		= info.exp or self.curExp
	self.sycee 			= info.sycee or self.sycee
	self.destinyStar 	= info.destinyStar or self.destinyStar
	self.vipLevel 		= info.vipLevel or self.vipLevel
	self.errantry 		= info.xiayi or self.errantry
	self.heroHillCoin 	= info.heroHillCoin or self.heroHillCoin
	self.arenaCoin      = info.arenaCoin or self.arenaCoin
	self.wudaohuiCoin   = info.arenaMatchCoin or self.wudaohuiCoin
	self.ghostTowerCoin = info.ghostTowerCoin or self.ghostTowerCoin
	self.petCoin  		= info.petCoin or self.petCoin
	self.goldenLotCoin  = info.goldenLotCoin or self.goldenLotCoin
	self.silverLotCoin  = info.silverLotCoin or self.silverLotCoin
	self.vipExp 		= info.vipExp or self.vipExp
	self.isFirstPay 	= info.isFirstPay or self.isFirstPay
	self.isGotPayReward = info.isGotPayReward or self.isGotPayReward
	self.payTotalSycee  = info.payTotalSycee or self.payTotalSycee
	self.lotteryCoin    = info.lotteryCoin or self.lotteryCoin		--博彩货币
	self.HeadId			= info.HeadId or self.HeadId				--头像ID
	self.offlineTime  	= info.offlineTime or self.offlineTime

	if info.subPackage then
		self.subPackage[info.subPackage.id] = info.subPackage.status
	end

	TFDirector:dispatchGlobalEventWith(MainPlayer.PlayerInfoChange, 0)
	
	if HeitaoSdk and info.level then
		HeitaoSdk.GameLevelChanged(info.level)
	end 

end

function MainPlayer:initUserDefaultData()
	CCUserDefault:sharedUserDefault():setBoolForKey("role_vitality_auto", false)
	CCUserDefault:sharedUserDefault():setBoolForKey("role_spirit_auto", false)
	if self.level == 1 and self.curExp == 0 then
		CCUserDefault:sharedUserDefault():setBoolForKey("battle_ui_layer_auto", false)
		CCUserDefault:sharedUserDefault():setIntegerForKey("battle_ui_layer_speed", 0)
		CCUserDefault:sharedUserDefault():setStringForKey("player_guide", "")
	end

	local speed = CCUserDefault:sharedUserDefault():getIntegerForKey("battle_ui_layer_speed", 0)
	if speed == 2 then
		local data = Public:getVipOpen(EnumVipFunctionID.BattleSpeed)
		local needLevel = ConstantData:getValue("Battle.Three.Speed.Level")
		if self.level >= needLevel or (data and data.isOpen) then
		else
			CCUserDefault:sharedUserDefault():setIntegerForKey("battle_ui_layer_speed", 0)
		end
	end

	local mark = CCUserDefault:sharedUserDefault():getStringForKey("mark_chapter_pos")
	if mark ~= "" then
		if not string.find(mark, self.playerId) then
			CCUserDefault:sharedUserDefault():setStringForKey("mark_chapter_pos", "")
		end
	end
	mark = CCUserDefault:sharedUserDefault():getStringForKey("mark_chapter_trans_pos")
	if mark ~= "" then
		if not string.find(mark, self.playerId) then
			CCUserDefault:sharedUserDefault():setStringForKey("mark_chapter_trans_pos", "")
			-- send to server
		end
	end
	CCUserDefault:sharedUserDefault():flush()
end

function MainPlayer:onReceiveGetDiningInfo( event )
	local data = event.data
	if tonumber(data.power) == 0 then return end
 	toastMessage(stringUtils.format(localizable.QiyuManager_tilizengjia, data.power))
end

--新手引导    
function MainPlayer:guideRecordResult(event)
	local data = event.data

	local records = data.record or {}
	-- print("==  guideRecordResult == ", records)

	self.guideList = {}
	for k,v in pairs(records) do
		self.guideList[v] = v
	end
	-- print("==== guideList", self.guideList)
	PlayerGuideManager:initGuideLayers()
	MovieManager:initMovie()
end

--是否开启微信关注
function MainPlayer:openWeixinIcon()	
    self:addActivityIcon(EnumActivityType.Weixin, ServerSwitchManager:isWeChatOpen())
end

--记录引导进度 
function MainPlayer:sendRequestGuideRecord(record)
	-- print("^^^^^^^^^^^^^^^^ sendRequestGuideRecord: ", record)
	self:saveGuideRecord(record)
	TFDirector:send(c2s.REQUEST_GUIDE_RECORD, {record})

	TFDirector:dispatchGlobalEventWith(MainPlayer.GuideRecode, nil)
end

function MainPlayer:saveGuideRecord(id)
	self.guideList[id] = id
end

function MainPlayer:isGuideFunctionOpen(id)
	if self.guideList[id] or self.guideList[MainPlayer.GUIDE_MOVIE] then
		return true
	end
	return false
end

function MainPlayer:quickInMission()
	-- if self.level >= 10 then
	-- 	return false
	-- end
	-- if self:isGuideFunctionOpen(11) then
	-- 	return false
	-- end
	-- return true
	return self:quickInMissionWorld()
end

function MainPlayer:quickInMissionWorld()
	if self.level >= 10 then
		return false
	end
	-- if self:isGuideFunctionOpen(13) then
	-- 	return false
	-- end
	if MissionManager:getStarLevelByMissionId(1001005) > 0 then
		return false
	end
	return true
end

function MainPlayer:updateTeamInfo( event )
	local data = event.data
	local Vitality = self:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
	data.Vitality = Vitality
	--团队升级
	if data.type == 0 then	
		self.is_UpLevel = true
		self.upLevelData = data
	--vip升级
	elseif data.type == 1 then

	end
end

function MainPlayer:openTeamUpLevelLayer()
	if not self.is_UpLevel or MissionManager:getMissionsweep() then return end
	MissionManager:openTeamUpLevelLayer(self.upLevelData)
end

function MainPlayer:openChoiceHeadLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.ChangeHeadLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
	AlertManager:show()
end

function MainPlayer:updateLoadingRes(event)
	local data = event.data
	local sum_weight = 0
	if data~=nil and data.resList~=nil then
		self.loadingRes = {}
		for k,v in pairs(data.resList) do
			local res = {
				res = v.res or "default",		
				weight = v.weight or 1,			
			}
			res.sum = sum_weight + res.weight
			sum_weight = res.sum

			self.loadingRes[#self.loadingRes+1] = res
		end
	end
end

function MainPlayer:getNewFunctionInfo(event)
	local data = event.data.receiveReward or {}

	self.newFunctionId = {}
	for _,id in pairs(data) do
		self.newFunctionId[id] = id
	end
end

function MainPlayer:getNewFunctionResult(event)
	hideLoading()

	local id = event.data.functionId
	self.newFunctionId[id] = id
	TFDirector:dispatchGlobalEventWith(MainPlayer.NEW_GUIDE_REWARD, 0)
end

function MainPlayer:isNewFunctionGain(id)
	return self.newFunctionId[id] and true or false
end

function MainPlayer:sendNewFunctionId(id)
	showLoading()
	TFDirector:send(c2s.GET_NEW_FUNCTION_REWARD, {id})
end

function MainPlayer:checkMissionGuideReward()
	local mission = MissionManager:currentMissionByType(EnumMissionType.Main)
	if mission == nil then return nil end
	local targets = GuideRewardData:getGuideRewardList(1)
	table.sort(targets, function (a1, a2) return a1.id < a2.id end)
	for k,v in pairs(targets) do
		if v.id and v.value and v.value < mission.id and not self:isNewFunctionGain(v.id) then
			return v
		end
	end
	return nil
end

function MainPlayer:getMissionGuideReward()
	local targets = GuideRewardData:getGuideRewardList(1)
	local mission = MissionManager:currentMissionByType(EnumMissionType.Main)
	if mission == nil or targets == nil then return nil end
	for k,v in pairs(targets) do
		if v.value >= mission.id then
			return v
		end
	end
	return nil
end

--判断当前是否拥有可领取的奖励(显示最后一个)
function MainPlayer:getCanGuideReward(targets)
	if not targets then return nil end
	if not self:getLevel() then return nil end
	
	local lastGuideReward
	
	for k, v in pairs(targets) do
		if self.newFunctionId[v.id] == nil then
			local isValue = false
			local isLevel = false
			
			if v.value == 0 or(v.value ~= 0 and MissionManager:getStarLevelByMissionId(v.value) ~= 0) then			
				isValue = true
			end
			
			if self:getLevel() >= v.level then
				isLevel = true
			end

			if isValue and isLevel then
				lastGuideReward = v
			end
		end
	end
	
	return lastGuideReward
end 

--判断最近可开启的功能
function MainPlayer:getTargetGuideReward(targets)
	if not targets then return nil end
	if not self:getLevel() then return nil end

	local lastGuideReward
	
	for k, v in pairs(targets) do
		if self.newFunctionId[v.id] == nil then
			if v.level > self:getLevel() then
				lastGuideReward = v
				lastGuideReward.prompt = stringUtils.format(localizable.guide_upLv_open, (v.level - self:getLevel()))
				break
			end
			
			if v.value ~= 0 and MissionManager:getStarLevelByMissionId(v.value) == 0 then			
				lastGuideReward = v
				lastGuideReward.prompt = stringUtils.format(localizable.guide_mission_canreceive, MissionManager:getCountByMissionId(v.value))
				break
			end
		end
	end
	
	return lastGuideReward
end     

function MainPlayer:getOneLoadingRes()
	if self.loadingRes==nil or #self.loadingRes==0 then return "default" end
	if #self.loadingRes==1 then	return self.loadingRes[1].res end
	--根据权重随一个
	local randomNum = math.random(1, self.loadingRes[#self.loadingRes].sum)
	for i=1,#self.loadingRes do
		if self.loadingRes[i].sum > randomNum then
			return self.loadingRes[i].res
		end
	end
	return self.loadingRes[#self.loadingRes].res
end

function MainPlayer:reset()
	self:restart()
end

function MainPlayer:restart()
	print("MainPlayer:restart")
	self:init()

	if IS_SUB_PACKAGE then
		PackageDownManager:restart()
	end

	BagManager:restart()
	GuildManager:restart()
	GuildDungeonManager:restart()
	GuildTaskManager:reset()
	CardRoleManager:restart()
	NewChatManager:restart()
	VoiceManager:restart()
	CommonManager:restart()
	CommonUiManager:restart()
	FightManager:restart()
	WorldBossManager:restart()
	FormationManager:restart()
	GameResourceManager:restart()
	LoginManager:restart()
	MaterialManager:restart()
	MissionManager:restart()
	RecoverableResManager:restart()
	ServerSwitchManager:restart()
	RewardManager:restart()
	SettingManager:restart()
	PetRoleManager:restart()
	GodPetManager:restart()
	DebugModeManager:restart()
	RecycleManager:restart()
	--TalismanManager:restart()
	FriendManager:restart()
	OtherPlayerManager:restart()
	ShopManager:restart()
	GhostTowerManager:restart()
	PlayerGuideManager:restart()
	SevenDaysManager:restart()
	OnlineActivitiesManager:restart()
	CustomActivitiesManager:restart()
	RebuyManager:restart()
	EquipmentManager:restart()
	MovieManager:restart()
	PayManager:restart()
	TaskManager:restart()
	ArenaManager:restart()
	ArtifactManager:restart()
	AdventureManager:restart()
	FuliManager:restart()
	BookWorldManager:restart()
	MapManager:restart()
	SyncPosManager:restart()
	EyeManager:restart()
	RoundTaskManager:restart()
	NewArtifactManager:restart()
	TaskMainManager:restart()
	TeamManager:restart()
	CelueManager:restart()
	StatisticsManager:restart()
	FirstPayManager:restart()
	MessageManager:restart()
	TitleManager:restart()
end

function MainPlayer:getMainRole()
	return CardRoleManager.mainRole
end

function MainPlayer:addSpeed(value)
	self.addSpeeds = self.addSpeeds + tonumber(value)
end

function MainPlayer:getSpeed(speedLayer)
	local speedMsg = {}
	local curScene = Public:currentScene()
	local sceneName = speedLayer or curScene.__cname
	if sceneName == "HomeScene" then
		speedMsg = MainRolePosData:objectByID( "Main_MoveSpeed" )
	elseif sceneName == "BigWorldScene" then
		speedMsg = MainRolePosData:objectByID( "World_MoveSpeed" )
	elseif sceneName == "MissionScene" then
		speedMsg = MainRolePosData:objectByID( "Ins_MoveSpeed" )
	elseif sceneName == "MallScene" then
		speedMsg = MainRolePosData:objectByID( "Mall_MoveSpeed" )
	end
	self.speed = speedMsg and speedMsg.Speed or 350 
	return self.speed + self.addSpeeds
end

function MainPlayer:getName()
	return self.name
end

function MainPlayer:getSex()
	return self.sex
end

function MainPlayer:getCurExp()
	return self.curExp
end

function MainPlayer:getMaxExp()
	local level = self.level + 1
	local levelData = CardLevelData:objectByID(level)
	if levelData then
		return levelData.group_exp
	end
	return 0
end

function MainPlayer:getLevel()
	return self.level
end

--装备强化上限
function MainPlayer:getEquipLimit()
	return self.level * 2
end

function MainPlayer:getVipLevel()
	return self.vipLevel
end

function MainPlayer:getPlayerId()
	return self.playerId
end

function MainPlayer:getServerId()
	return self.serverId
end

function MainPlayer:getProfession()
	return self.profession
end

function MainPlayer:getUseIcon()
	return self.useIcon
end

function MainPlayer:getFrameId()
	return self.frameId
end

function MainPlayer:getSycee()
	return self.sycee
end

function MainPlayer:getCoin()
	return self.coin
end

function MainPlayer:getLotteryCoin()
	if self.lotteryCoin ~= nil then
		return self.lotteryCoin
	end
	print("getLotteryCoin   self.lotteryCoin == nil")
	return 0
end

function MainPlayer:getHeadId()
	if self.HeadId ~= nil then
		return self.HeadId
	end
	if self:getMainRole() then
		self.HeadId = self:getMainRole().template.id
		return self.HeadId
	end
	return self.sex
end

function MainPlayer:getShowId()
	local mainRole = self:getMainRole()
	if mainRole and mainRole.showId then
		return mainRole.showId
	end
	return self.sex
end

function MainPlayer:getQuality()
	if self:getMainRole() then
		return self:getMainRole():getQuality()
	end
	return QualityType.Red
end

function MainPlayer:getSpirit()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.SpiritPoint)
	return tonumber(times:getLeftValue())
end

--体力
function MainPlayer:getVitality()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
	return times:getLeftValue()  .. "/" .. times.maxValue
end

--精力
function MainPlayer:getSpiritPoint()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.SpiritPoint)
	return times:getLeftValue()  .. "/" .. times.maxValue
end

--竞技场挑战次数
function MainPlayer:getArena()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.ArenaPoint)
	return times:getLeftValue()
end

--抽签次数
function MainPlayer:getLottery()
	return 0
end

--鬼神之塔的挑战次数
function MainPlayer:getClimb()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.GhostTower)
	return times:getLeftValue()
end

function MainPlayer:getPower(type)
	return FormationManager:calcFormationPower(type or EnumFormationType.PVE)
end

--可以上阵的人数
function MainPlayer:getFormationSize()
	return FormationManager:getToBattleSize()
end

--侠义值
function MainPlayer:getErrantryChange()
	return getResValueByTypeForGeneralHead(HeadResType.XiaYi)
end

--竞技场货币
function MainPlayer:getArenaCoin()
	-- return self.arenaCoin
	return getResValueByTypeForGeneralHead(HeadResType.ArenaLot)
end

--武道会货币
function MainPlayer:getWudaohuiCoin()	
	return getResValueByTypeForGeneralHead(HeadResType.WudaohuiLot)
end

function MainPlayer:getTowerCoin()
	return getResValueByTypeForGeneralHead(HeadResType.Tower)
end

function MainPlayer:getBloodyCoin()
	return getResValueByTypeForGeneralHead(HeadResType.Bloody)
end

--符鬼离线时间   
function MainPlayer:getOfflineTime()
	return self.offlineTime or 0
end

function MainPlayer:setName(name)
	self.name = name
	self.verticalName = toVerticalString(self.name)

	self:getMainRole():setName(name)

	TFDirector:dispatchGlobalEventWith(MainPlayer.RE_NAME)
end

function MainPlayer:getResValueByType(resType)
	if resType == EnumDropType.COIN then
		return self.coin
	elseif resType == EnumDropType.SYCEE then
		return self.sycee
	elseif resType == EnumDropType.GENUINE_QI then
		--return self.genuine_qi
	elseif resType == EnumDropType.EXP then
		return self.curExp
	elseif resType == EnumDropType.HERO_SCORE then
		--return self.qunHaoScore
	elseif resType == EnumDropType.XIAYI then
		--return self.errantry
	elseif resType == EnumDropType.FACTION_GX then
		--return self.dedication
	elseif resType == EnumDropType.recruitIntegral then
		--return self.recruitIntegral
	elseif resType == EnumDropType.VESSELBREACH then
		--return self.vesselBreachValue	
	elseif resType == EnumDropType.LOWHONOR then
		--return self.lowHonor
	elseif resType == EnumDropType.HIGHTHONOR then
		--return self.seniorHonor
	end
	print("unknow res type : ",resType)
	return 0
end

function MainPlayer:getNowtime()
	return os.time() + self.timeDifference
end

function MainPlayer:getLogintime()
	return self.loginTime
end

function MainPlayer:setLogintime(time)
	self.loginTime = time
end

function MainPlayer:getChatFreeTimes()
	local times = self:GetChallengeTimesInfo(EnumTimeRecoverType.Chat)
	return times:getLeftValue()
end

function MainPlayer:getPlayerProperties()
	return nil
end

function MainPlayer:getServerChatFreeTimes()
	return 0
end


function MainPlayer:getMenuScenePos()
	return self.MenuScenePos
end
function MainPlayer:saveMenuScenePos(pos)
	self.MenuScenePos = pos
end

function MainPlayer:initMainRolePos()
	local main_pos = ccp(1300,200)
	local posData = NpcMovePosData:objectByID("panel_mainRole")
	if posData then
		main_pos = posData:getBirthPositon()
	end
	self:saveMenuRolePos(main_pos)
end

function MainPlayer:getMenuRolePos()
	return {pos = ccp(self.MenuRolePosX,self.MenuRolePosY), rotationY = self.MenuRoleRotationY}
end

function MainPlayer:saveMenuRolePos(pos,rotationY)
	self.MenuRolePosX = pos.x
	self.MenuRolePosY = pos.y

	self.MenuRoleRotationY = rotationY or 0
end

function MainPlayer:initNPCPos()
	self.npcPos = {}
	local posData = NpcMovePosData:objectByID("panel_tianshu")
	if posData then
		self:saveMenuNpcPos(posData.id, posData:getBirthPositon(), 0, false, false)
	end

	local posData2 = NpcMovePosData:objectByID("panel_tanghulu")
	if posData2 then
		self:saveMenuNpcPos(posData2.id, posData2:getBirthPositon(), 0, false, false)
	end
	
end

function MainPlayer:saveMenuNpcPos( npcName, npcPos ,rotationY, npcTouch,npcStop )
	for k,v in pairs(self.npcPos) do
		if v.name == npcName then
			v.pos 			= npcPos or ccp(0,0)
			v.npcRotationY	= rotationY or 0
			v.is_touch 		= npcTouch or false
			v.is_stop		= npcStop or false
			return
		end
	end

	self.npcPos[#self.npcPos + 1] = {name = npcName, pos = npcPos, npcRotationY = rotationY, is_touch = npcTouch, is_stop = npcStop}
end

function MainPlayer:saveMainRolePos( pos, scene )
	self.saveMainRoleMsg = {saveMainPos = pos, saveScene = scene}
end

function MainPlayer:getSaveMainRolePos()
	return self.saveMainRoleMsg or {}
end

function MainPlayer:getMenuNpcPosByName(npcName)
	for k,v in pairs(self.npcPos) do
		if v.name == npcName then
			return v
		end
	end
	return nil
end

function MainPlayer:isHaveChallenge()
	--竞技场
	if ArenaManager:isHaveRedPoint() then return true end
	--建木通天
	if BloodyWarManager:isHaveRedPoint() then return true end
	--山海奇遇
	if AdventureManager:isHaveRedPoint() then return true end
	--降妖伏魔
	if RoundTaskManager:isHaveRedPoint() then return true end
	--世界boss
	if WorldBossManager:isHaveRedPoint() then return true end
    -- local function GetDayTimes(chapterId)
	-- 	local dailyData = MissionManager:getDailyByID(chapterId)
	-- 	local template = dailyData.template
	-- 	local isLock = dailyData.isLock
	-- 	local isCheckOpen = dailyData.isCheckOpen
	-- 	--挑战次数
	-- 	local challengeCount = template.challenge_times - dailyData.challengeCount

	-- 	if isCheckOpen == false or isLock == true then
	-- 		challengeCount = 0
	-- 	end
	-- 	return challengeCount
	-- end

	-- local chapters = {3001,3002,3003,3004}
	-- for k,v in pairs(chapters) do
	-- 	if v and GetDayTimes(v) > 0 then
	-- 		return true
	-- 	end
	-- end
    return false
end

--首次进入游戏
function MainPlayer:getIsFirstEnter()
	if PlayerGuideManager.bOpenGuide == false then
		return false
	end
	if self.level ~= 1 then
		return false
	end
	if self.curExp ~= 0 then
		return false
	end
	return true
end

function MainPlayer:initPushDialogs()
	--pushDialogs
	--MainPlayer:dialogClosed(name)
	self.pushDialogs = {}
	local function showDialog(name, info)
		local on_completed = function ( ... )
			self:dialogClosed(name)
		end
		if name=="NoticeLayer" then
			CommonManager:openNoticeLayer(on_completed)
		elseif name=="sc" then
			FirstPayManager:openFirstPayLayer(on_completed)
		elseif name=="seven_day_login" then
			SevenDaysManager:openSevenDaysLoginLayer(on_completed)
		else
			if info.name=="zixun" then
				CustomActivitiesManager:openInformationLayer(on_completed)
			end
		end
	end

	self:registerPushDialogs("NoticeLayer", showDialog)
	local information_num = CustomActivitiesManager:getInformationNum()
	for i=1,information_num do
		self:registerPushDialogs("zixun"..i, showDialog, {name="zixun",index=i})
	end
	if ServerSwitchManager:isPayOpen() and FirstPayManager:isFirstPay() then
		self:registerPushDialogs("sc", showDialog)
	end
	if SevenDaysManager:isHaveSevenDayLoginRed() then
		self:registerPushDialogs("seven_day_login", showDialog)
	end
end

--已经开过公告
function MainPlayer:hasOpenNoticeLayer()
	return self.hasOpenNL
end

function MainPlayer:setHasOpenNoticeLayer()
	self.hasOpenNL = true
end

function MainPlayer:registerPushDialogs(name, showDialogFunc, info)
	if name==nil or showDialogFunc==nil then
		return
	end
	for i=1,#self.pushDialogs do
		if self.pushDialogs[i].name == name then
			print("has register this dialog--->", name)
			self.pushDialogs[i] = {name=name,showDialogFunc=showDialogFunc,info=info}
			return
		end
	end
	self.pushDialogs[#self.pushDialogs + 1] = {name=name,showDialogFunc=showDialogFunc,info=info}
end

function MainPlayer:dialogClosed(name)
	print("dialogClosed", name)
	if not self.pushDialogNow then return end
	for i=1,#self.pushDialogs do
		if self.pushDialogs[i].name == name then
			self:showNextDialog(i+1)
		end
	end
end

function MainPlayer:showNextDialog(index)
	if index>#self.pushDialogs then
		self:setHasOpenNoticeLayer()
		self.pushDialogNow = nil
	else
		local data = self.pushDialogs[index]
		TFFunction.call(data.showDialogFunc, data.name, data.info)
	end
end

function MainPlayer:pushDialogsToYourFace()
	self.pushDialogNow = true
	self:showNextDialog(1)
end

function MainPlayer:GetChallengeTimesInfo(type)
	return RecoverableResManager:getRecoverParamsInfo(type)
end

function MainPlayer:addActivityIcon(id, remove, state)
	for icon in self.activityIcons:iterator() do
		if icon == id then 
			if remove then
				self.activityIcons:removeObject(icon)
			end
			return
		end
	end
	self.activityIcons:push(id)
end

function MainPlayer:getActivityIcons()
	return self.activityIcons
end

--获得当前玩家所在的场景、章节、坐标 
function MainPlayer:getPlayerPos()
	local scene = SyncPosManager.scene
	local chapterId = SyncPosManager.chapterId

	local pos = nil
	local currentScene = Public:currentScene()
	local bottomLayer = currentScene:getButtomLayer()
	if not tolua.isnull(bottomLayer) and not tolua.isnull(bottomLayer.syncPosLayer) and bottomLayer.syncPosLayer.getMainRolePos then
		pos = bottomLayer.syncPosLayer:getMainRolePos()
	else
		pos = ccp(0,0)
	end
	return scene, chapterId, pos.x, pos.y
end

--保存统计  (埋点)   
function MainPlayer:saveStatRecord(stat)
	if stat == nil then
		return
	end
	if VERSION_DEBUG then toastMessage(string.format("当前记录点：%s", stat)) end
	TFDirector:send(c2s.SAVE_STAT_RECORD, {stat})
end

function MainPlayer:skipSaveStatRecord(stat)
	if stat == nil then return end
	if VERSION_DEBUG then
		print("skipSaveStatRecord ============", stat)
		toastMessage(string.format("当前跳过记录点：%s", stat))
	end
	TFDirector:send(c2s.SKIP_SAVE_STAT_RECORD, {stat})
end

--更换头像Id
function MainPlayer:sendChangeHead(HeadId)
	TFDirector:send(c2s.UPDATE_HEAD_ID, {HeadId})
end

---- 分包下载 ---------------------------

function MainPlayer:isSubPackage(types)
	if not types or not self.subPackage then return false end
	for _, id in pairs(types) do
		if not self.subPackage[id] then return false end
	end
	return true
end

function MainPlayer:isSubPackageDownLoad(...)
	if not IS_SUB_PACKAGE then return false end
	if PlayerGuideManager:isPlayGuide() then return false end
	if PackageDownManager:isDownLoad({...}) then return false end
	return true
end

function MainPlayer:isCanBackDownLoad()
	if not IS_SUB_PACKAGE then return false end
	if PackageDownManager:isDownLoad({}) then return false end
	return true
end

function MainPlayer:sendSubPackageDownLoad(type)
	if not type or self.subPackage[type] then return end
	TFDirector:send(c2s.SUB_PACKAGE_DOWNLOAD, {type})
end

----------------------------------------一些配置-------------------------------------------------

--无名手游
function MainPlayer:isWuMing()
	return GlobalConfig and GlobalConfig.iWM
end

return MainPlayer:new()