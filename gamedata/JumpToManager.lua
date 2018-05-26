--	跳转系统
--  sunyunpeng
-- 	Date: 2017-04-24
--

local JumpToManager = class("JumpToManager", BaseManager)

JumpToManager.MENULAYER_OPEN_GEMBLE			= "JumpToManager.MENULAYER_OPEN_GEMBLE"

function JumpToManager:ctor(data)
	self.super.ctor(self)
end

function JumpToManager:init()
	self.super.init(self)

	self.tJumpFunction = {
		[FunctionManager.MenuRoleList]			  	= self.jumpToRole,     			--伙伴201
		[FunctionManager.MenuTask]  				= self.jumpToTask,	  			--任务202
		[FunctionManager.MenuLottery]  				= self.jumpToLottery,   		--抽卡203
		[FunctionManager.MenuEquip]					= self.jumpToEquipment,			--装备204
		[FunctionManager.MenuFormation]  			= self.jumpToFormation,     	--阵容206
		[FunctionManager.MenuFriend]  				= self.jumpToFriend, 			--好友207  
		[FunctionManager.MenuBag]  					= self.jumpToBag, 				--背包208
		[FunctionManager.MenuRecycle]  				= self.jumpToRecycle, 			--回收209
		[FunctionManager.MenuRank]  				= self.jumpToRank, 	 			--排行210
		[FunctionManager.MenuChat]  				= self.jumpToChat, 				--聊天211
		[FunctionManager.MenuShop] 					= self.jumpToShop, 				--商城212
		[FunctionManager.MenuFunc] 					= self.jumpToFunc, 				--功能入口  竞技场 建木通天 鬼神之塔213
		[FunctionManager.MenuPay] 					= self.jumpToPay, 				--充值204
		[FunctionManager.MenuSevenDays] 			= self.jumpToSevenDays, 		--七日活动215
		[FunctionManager.MenuActivity] 				= self.jumpToActivity, 			--活动216
		[FunctionManager.MenuMail] 					= self.jumpToMail, 				--邮件217
		[FunctionManager.MenuHandBook] 				= self.jumpToHandBook, 			--图鉴218 
		[FunctionManager.MenuArtifact] 				= self.jumpToArtifact, 			--神器219
		[FunctionManager.MenuNewRoad] 				= self.jumpToNewRoad, 			--功能开启
																					--首冲220
																					--月卡221
		[FunctionManager.MenuSign] 					= self.jumpToSignLayer,			--签到222
		[FunctionManager.MenuEatSteamed] 			= self.jumpToEatSteamed, 		--吃包子223
		[FunctionManager.BookWorld]					= self.jumpToBookWorld, 		--天书
		[FunctionManager.MenuGamble]				= self.jumpTozhuanpan, 			--博彩
		[FunctionManager.MenuNewShenQi]             = self.jumpToNewShenQi,         --新神器
		[FunctionManager.MenuGuild]					= self.jumpToGuild,				--帮会
		[FunctionManager.MenuFuLi]                  = self.jumpToFuLi,              -- 福利
		[FunctionManager.MenuWeixin]                = self.jumpToMenuWeixin,        -- 微信
		[FunctionManager.MenuYueka]                 = self.jumpToYueka,             --月卡
		[FunctionManager.MenuVipEnter]              = self.jumpToVip,             	--vip
		[FunctionManager.MenuCustomerServices]      = self.jumpToCustomerServices,  --客服
		[FunctionManager.MenuChapter]               = self.jumpToMissionChapter,    --章节列表
		[FunctionManager.MenuGodPet]                = self.jumpToGodPet,            --神宠
		[FunctionManager.MenuGuildWar]              = self.jumpToGuildWar,          --帮会战


		[FunctionManager.RoleList] 					= self.jumpToRole, 				--角色列表 301
		[FunctionManager.RoleInfoStar] 				= self.jumptoCardRole, 			--角色升星
		[FunctionManager.RoleInfoSkill] 			= self.jumptoCardRole, 			--技能
		[FunctionManager.RoleInfoBook] 				= self.jumptoCardRole, 			--进阶
		[FunctionManager.RoleDestiny] 				= self.jumpToDestinyLayer, 		--天命
		[FunctionManager.RoleEquip] 				= self.jumpToEquipment, 		--装备
		[FunctionManager.RoleArtifact]        		= self.jumptoCardRole,    		--神器

		[FunctionManager.Equipment] 				= self.jumptoCardEquip, 		--装备
		[FunctionManager.EquipmentWeapon] 			= self.jumptoCardEquip, 		--武器
		[FunctionManager.EquipmentHelmet] 			= self.jumptoCardEquip, 		--头盔
		[FunctionManager.EquipmentClothes]			= self.jumptoCardEquip, 		--衣服
		[FunctionManager.EquipmentBelt]  			= self.jumptoCardEquip, 		--腰带
		[FunctionManager.EquipmentShoe]   			= self.jumptoCardEquip,			--鞋子

		[FunctionManager.Lottery] 					= self.jumpToLottery, 			--抽卡

		-- [FunctionManager.Equipment] = self.jumpToLottery, 						--装备
		[FunctionManager.TaskList] 					= self.jumpToTask, 				--任务
		[FunctionManager.AchievementList]           = self.jumpToAchievement,        --成就

		[FunctionManager.ChallengeArena]    		= self.jumpToArena,   			--竞技场入口
		[FunctionManager.ChallengeGhost]   			= self.jumpToGhost,   			--鬼神之塔
		[FunctionManager.ChallengeBloody]     		= self.jumpToBloody,  			--建木通天 
		[FunctionManager.ChallengeDaily]      		= self.jumpToDaily,   			--日常副本
		[FunctionManager.ChallengeAdventure]  		= self.jumpToAdventure,  		--山海奇遇
		[FunctionManager.ChallengeWorldBoss]		= self.jumpToWorldBoss,			--世界boss
		[FunctionManager.ChallengeJiFen]			= self.jumpToJIFenGame,			--轩辕论剑

		[FunctionManager.Arena] 					= self.jumpToArena, 			--竞技场

		[FunctionManager.MissionMain] 				= self.jumpToMainMission, 		--主线
		[FunctionManager.MissionElite] 				= self.jumpToEliteMission, 		--精英
		-- [FunctionManager.MissionDaily] 				= self.jumpToDayMission,  	--日常

		[FunctionManager.ShopSycee] 				= self.jumpToSyceeShop, 		--元宝商城
		[FunctionManager.ShopArena] 				= self.jumpToShopArena, 		--竞技场商店
		[FunctionManager.ShopRole] 					= self.jumpToShopRole, 			--角色商店
		[FunctionManager.ShopTower] 				= self.jumpToShopTower, 		--鬼神之塔商店
		[FunctionManager.ShopDevildom] 				= self.jumpToShopDevildom, 		--魔界商店
		[FunctionManager.ShopFaction] 				= self.jumpToShopFaction, 		--帮会商店
		[FunctionManager.ShopQunying]				= self.jumpToShopQunying, 		--群英山商店
		[FunctionManager.ShopTowerRandom] 			= self.jumpToShopTowerRandom, 	--鬼神之塔随机商店
		[FunctionManager.ShopQunyingRandom] 		= self.jumpToShopQunyingRandom, --群英随机商店
		[FunctionManager.ShopTowerMaterial] 		= self.jumpToShopTowerMaterial, --材料商店
		[FunctionManager.ShopLottery] 				= self.jumpToShopLottery, 		--抽卡商店
		[FunctionManager.ShopBocai] 				= self.jumpToShopBoCai, 		--博彩商店
		[FunctionManager.SevenDay]            		= self.jumpToSevenDays, 		--每日
		[FunctionManager.MenuRecycle]  				= self.jumpToRecycle,  		 	--回收
		[FunctionManager.MenuPlayerInfo]  			= self.jumpToPlayerInfo,	    --团队信息界面
		[FunctionManager.MenuChallenge]  			= self.jumpToChallenge,	        --挑战按钮
		[FunctionManager.ChallengeScene]  			= self.jumpToChallenge,	        --机关房
		[FunctionManager.MenuMissionChapter]  		= self.jumpToMissionChapter,	--章节列表

		[FunctionManager.BuyShopStrengh]  			= self.jumpToBuyShopStrengh, 	--购买包子
		[FunctionManager.BuyShopSpirit]  			= self.jumpToBuyShopSpirit, 	--购买精力
		[FunctionManager.BuyShopCoin]  				= self.jumpToBuyShopCoin, 		--购买招财符
		[FunctionManager.RoundTask]  				= self.jumpToRoundTask, 		--降妖伏魔
		[FunctionManager.Pet]						= self.jumptoPetLayer,			--宠物
		[FunctionManager.PetMerge]					= self.jumptoPetMergeLayer,		--宠物合成


		[FunctionManager.GuildMain] 				= self.jumpToGuildMain, 		--帮会主信息页面
		[FunctionManager.GuildShop] 				= self.jumpToShopFaction, 		--帮会商店
		[FunctionManager.GuildDonation] 			= self.jumpToGuildDonation, 	--帮会祭拜
		[FunctionManager.GuildDungeon]				= self.jumpToGuildDungeon,		--帮会幻境	
		[FunctionManager.GuildTask]                 = self.jumpToGuildTask,         --帮会任务
		[FunctionManager.GuildWar]                  = self.jumpToGuildWar,          --帮会战 

		[FunctionManager.MenuWudaohui] 				= self.jumpToWudaohui, 	--武道会
		[FunctionManager.MenuSevenDaysLogin] 		= self.jumpToSevenDaysLogin, 	--七天登录豪礼
		[FunctionManager.ShopWudaohui] 		        = self.jumpToShopWudaohui, 	--武道会商店

		[FunctionManager.SpecialEquipment]          = self.jumpToSpecialEquipment    --专属装备

	}

	--跳转场景完成监听
	self.onLoadSceneFinish = function(events)
		print('aaaaaaaaaaaaaaaaaaaaa',self.canFinishFunc)
		if not self.canFinishFunc or self.onLoadSceneFinishFunc == nil then return end
		self.canFinishFunc = false    --场景跳转是否执行回调
		TFFunction.call(self.onLoadSceneFinishFunc)
	end
	TFDirector:addMEGlobalListener(AlertManager.ENTER_SCENE_FINISH, self.onLoadSceneFinish)
end

function JumpToManager:restart()
	self.tJumpFunction = {}
end


function JumpToManager:jumpToRole()
	CardRoleManager:openRoleListLayer()
end

function JumpToManager:jumpToWudaohui()
	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Other, EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Other, EnumSubPackageType.Role})
		return
	end

	--print('**********sjj***********jumpToManager:jumpToWudaohui*******************')
	WuDaoHuiManager:openWuDaoHuiMainLayer()
end

function JumpToManager:jumpToEquipment()
	local role = CardRoleManager:getRoleHaveEquipmentRedPoint()
	if role then 
        CardRoleManager:setSelectedCardRole(role)
        CardRoleManager:openRoleInfoLayer(role)
    end
end

function JumpToManager:jumpToTask()
	local can_jump = self:isCanJump(FunctionManager.TaskList)
	if can_jump then
        --jump task
		TaskManager:showTaskLayer(1)
    else
        -- jump achievement
		TaskManager:showTaskLayer(2)
    end
end

function JumpToManager:jumpToAchievement( ... )
	TaskManager:showTaskLayer(2)
end

function JumpToManager:jumpToLottery(tag,isMoved)
	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Role})
		return
	end

	if isMoved == nil then  
		LotteryManager:openLotteryLayer() 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','btn_simiao','onTouchBeganHandle')
	end
	self:jumpGoto('HomeScene','btn_simiao','onTouchBeganHandle')
	-- LotteryManager:openLotteryLayer()
end

function JumpToManager:jumpToFormation()
	-- FormationManager:setArmyLayerType( true )
	FormationManager:openFormationLayer()
end

function JumpToManager:jumpToFriend()
	-- FriendManager:openFriendMainLayer()
	FriendManager.isOpenFriendMainLayer = true
	FriendManager:requestFriendList()
	-- NotifyManager:displayMessage("我就是做个测试啊啊啊啊啊啊啊啊")
end

function JumpToManager:jumpToBag()
	BagManager:openBagLayer(EnumGoodsType.Prop)
    
	--zzteng test
	-- PayManager:openMouthCardLayer()
	-- AlertManager:addLayerToQueueAndCacheByFile("lua.logic.arena.ArenaRewardLayer");
    -- AlertManager:show();
	-- MissionManager:openTeamUpLevelLayer()
	-- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.shenqi.NewShenQiOpenLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    -- AlertManager:show()
end

function JumpToManager:jumpToRecycle(tag,isMoved)
	if isMoved == nil then  
		RecycleManager:openRecycleLayer() 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','btn_huishou','onTouchBeganHandle')
	end
	self:jumpGoto('HomeScene','btn_simiao','onTouchBeganHandle')
	-- RecycleManager:openRecycleLayer()
end

function JumpToManager:jumpToRank(tag,isMoved)
	if isMoved == nil then  
		RankManager:sendQueryRankingBaseInfo(EnumRankType.Top_Power, 0, 10) 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','btn_paihangbang','onTouchBeganHandle')
	end
	self:jumpGoto('HomeScene','btn_paihangbang','onTouchBeganHandle')
	-- RankManager:sendQueryRankingBaseInfo(EnumRankType.Top_Power, 0, 10)
end 

function JumpToManager:jumpToChat()
	NewChatManager:openChatMainLayer() 
end

function JumpToManager:jumpToShop()
	CommonManager:requestEnterInScene(EnumSceneType.Mall)
end

function JumpToManager:jumpToFunc()
	CommonManager:openChoiceLayer()
end

function JumpToManager:jumpToPay()
	--充值开关
	if ServerSwitchManager:isPayOpen() then
	    PayManager:openPayLayer()
	else
	   toastMessage(localizable.PayManager_not_open)
	end
end

function JumpToManager:jumpToSevenDays()
	-- if SevenDaysManager.openDays <= 8 then
	-- 	SevenDaysManager:openSevenDaysLayer()
	-- end
	SevenDaysManager.canOpen = true
	SevenDaysManager:sendQuerySevenDaysGoalTask()
end

function JumpToManager:jumpToSevenDaysLogin( )
	SevenDaysManager:sendQUeryLoginSevenDaysGoalTask()
end

function JumpToManager:jumpToMenuWeixin( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.yunying.WeixinLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function JumpToManager:jumpToActivity()
	OnlineActivitiesManager:sendRequestAllActivityInfo()
end

function JumpToManager:jumpToPlayerInfo()
	CommonManager:openPlayerInfoLayer()
end

function JumpToManager:jumpToMail()
	NotifyManager:sendQuerySystemNotify()
end

function JumpToManager:jumpToHandBook()
	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Other, EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Other, EnumSubPackageType.Role})
		return
	end

	CommonManager:openHandbookLayer()
end

function JumpToManager:jumpToArtifact()
	ArtifactManager:openArtifactMainLayer()
end

function JumpToManager:jumpToNewRoad( ... )
	CommonManager:openNewRoadLayer()
end

function JumpToManager:jumpToNewShenQi( )
	NewArtifactManager:openNewArtifactMainLayer()
	-- NewArtifactManager:openNewShenQiOpenLayer()
end

function JumpToManager:jumpToGuild()
	-- body
	GuildManager:openGuildLayer()
end

function JumpToManager:jumpToFuLi( ... )
	-- FuliManager:setOpenFuliType(FuliManager.fuliTypeList[1])
	FuliManager:startOpenFuliLayer(FuliManager.fuliTypeList[1])
end

function JumpToManager:jumpToYueka( ... )
	if ServerSwitchManager:isMonthCardOpen() then
		PayManager:openMouthCardLayer()
	else
		toastMessage(localizable.mouth_card_not_open)
	end
end

function JumpToManager:jumpToVip()
	PayManager:openVipLayer()
end

function JumpToManager:jumpToCustomerServices( )
	CustomActivitiesManager:openCustomerServicesLayer()
end

function JumpToManager:jumpToEatSteamed(tag,isMoved)
	-- local b_show = Utils:isDining()
	-- local data = DietData:getDietList()
	-- if not b_show then
	-- 	toastMessage(stringUtils.format(localizable.task_daily_tili,data[1].beginT,data[2].beginT,data[3].beginT))
	-- else
	-- 	AlertManager:closeAll()
	-- 	local currentScene = Public:currentScene()
	-- 	if currentScene and currentScene.getTopLayer then
	-- 		local topLayer = currentScene:getTopLayer()
	-- 		if topLayer then
	-- 			topLayer:SetPanelDiPosition(-1530, topLayer)
	-- 		end
	-- 	end
	-- end
	-- FuliManager:setOpenFuliType(EnumFuLiType.EatBaozi)
	if isMoved == nil then  
		FuliManager:startOpenFuliLayer(EnumFuLiType.EatBaozi) 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','btn_sugar','sungarClickHandle')
	end
	self:jumpGoto('HomeScene','btn_sugar','sungarClickHandle')
	-- FuliManager:startOpenFuliLayer(EnumFuLiType.EatBaozi)
end

function JumpToManager:jumptoCardRole()
	local cardRole = CardRoleManager:getSelectedCardRole()
    CardRoleManager:openRoleInfoLayer(cardRole)
end

function JumpToManager:jumpToDestinyLayer()
	CardRoleManager:openDestinyLayer()
end

function JumpToManager:jumptoCardEquip()
	-- EquipmentManager:openEquipmentLayer(0)
	--------------临时处理方式
	self:jumptoCardRole()
end

function JumpToManager:jumpToArena(tag,isMoved)
	if isMoved == nil then  
		ArenaManager:sendArenaGetPlayerList()
		ArenaManager:sendArenaGetArenaInfo()
		ArenaManager.openArenaPlayerListLayerState = true 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('ChallengeScene','panel_fengshenyanwu','onTouchClickHandle')
	end
	self:jumpGoto('ChallengeScene','panel_fengshenyanwu','onTouchClickHandle')

	-- ArenaManager:openArenaPlayerListLayer()
	-- ArenaManager:sendArenaGetPlayerList()
	-- ArenaManager:sendArenaGetArenaInfo()
	-- ArenaManager.openArenaPlayerListLayerState = true
end

function JumpToManager:jumpToGhost()
	GhostTowerManager:openGhostTowerFloorLayer()
end

function JumpToManager:jumpToBloody(tag,isMoved)
	if isMoved == nil then  
		BloodyWarManager:sendQueryBloodyDetail()
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('ChallengeScene','panel_jianmutongtian','onTouchClickHandle')
	end
	self:jumpGoto('ChallengeScene','panel_jianmutongtian','onTouchClickHandle')

	-- BloodyWarManager:sendQueryBloodyDetail()
end

function JumpToManager:jumpToDaily()
	-- MissionManager:openMissionDayLayer()
end

function JumpToManager:jumpToAdventure(tag,isMoved)
	if isMoved == nil then  
		AdventureManager:openJiaoMainLayer()
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('ChallengeScene','panel_shanhaiqiyu','onTouchClickHandle')
	end
	self:jumpGoto('ChallengeScene','panel_shanhaiqiyu','onTouchClickHandle')


	-- AdventureManager:openJiaoMainLayer()
end

function JumpToManager:jumpToWorldBoss(tag,isMoved)
	if isMoved == nil then  
		WorldBossManager:enter(true,true)
		WorldBossManager:sendBossOpenTime()
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('ChallengeScene','panel_zhenyaxiongshou','onTouchClickHandle')
	end
	self:jumpGoto('ChallengeScene','panel_zhenyaxiongshou','onTouchClickHandle')
	
	-- WorldBossManager:enter(true,true)
end

function JumpToManager:jumpToJIFenGame(tag)
	ScoreMatchManager:openScoreMatchMainLayer()
end

function JumpToManager:jumpToMainMission(tag)
	local data = MissionManager:currentMissionByType( EnumMissionType.Main )
	if not data then
		toastMessage(localizable.common_unopened)
		return
	end
	
	if tag then
		local value = 0
		local mission = MissionData:objectByID(tag)
		if mission then
			value = mission.chapter
		end
		if data.template.id < tag then
	    	toastMessage(localizable.common_unopened)
	    	return
	    end
	    -- MissionManager:openMissionNewLayer( value, tag )
		CommonManager:requestEnterInScene(nil, value)
	else
		-- MissionManager:openMissionNewLayer( data.template.chapter)
		CommonManager:requestEnterInScene(nil, data.template.chapter)
	end 
end

function JumpToManager:jumpToEliteMission(tag)
	local data = MissionManager:currentMissionByType( EnumMissionType.Elite )
	if not data then
		toastMessage(localizable.common_unopened)
		return
	end

	if tag then
		local value = 0
		local mission = MissionData:objectByID(tag)
		if mission then
			value = mission.chapter
		end
		if data.template.id < tag then
	    	toastMessage(localizable.common_unopened)
	    	return
	    end
	    -- MissionManager:openMissionNewLayer( value, tag )
	else
		-- MissionManager:openMissionNewLayer( data.template.chapter)
	end
end

function JumpToManager:jumpToDayMission()
	-- MissionManager:openMissionDayLayer()
end

function JumpToManager:jumpToSyceeShop(tag,isMoved)

	ShopManager:showShopLayer(EnumShopType.SyceeShop,tag)
end

function JumpToManager:jumpToShopArena(tag,isMoved)

	ShopManager:showShopLayer(EnumShopType.ArenaShop,tag)
end

function JumpToManager:jumpToShopWudaohui(tag,isMoved)
	
	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Other, EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Other, EnumSubPackageType.Role})
		return
	end
	
	ShopManager:showShopLayer(EnumShopType.WudaohuiShop,tag)
end

function JumpToManager:jumpToShopRole(tag,isMoved)
	
	ShopManager:showShopLayer(EnumShopType.RoleShop,tag)
end

function JumpToManager:jumpToShopTower(tag)
	ShopManager:showShopLayer(EnumShopType.TowerShop,tag)
end

function JumpToManager:jumpToShopDevildom(tag)
	ShopManager:showShopLayer(EnumShopType.DevildomShop,tag)
end

function JumpToManager:jumpToShopFaction(tag,isMoved)
	
	GuildManager:openStoreLayer()
end

function JumpToManager:jumpToShopQunying(tag,isMoved)

	ShopManager:showShopLayer(EnumShopType.QunyingShop,tag)
end

function JumpToManager:jumpToShopPet(tag)
	ShopManager:showShopLayer(EnumShopType.PetShop,tag)
end

function JumpToManager:jumpToShopTowerRandom(tag)
	ShopManager:showShopLayer(EnumShopType.TowerRandomShop,tag)
end

function JumpToManager:jumpToShopQunyingRandom(tag)
	ShopManager:showShopLayer(EnumShopType.QunyingRandomShop,tag)
end

function JumpToManager:jumpToShopTowerMaterial(tag)
	ShopManager:showShopLayer(EnumShopType.TowerMaterialShop,tag)
end

function JumpToManager:jumpToShopLottery(tag,isMoved)
	
	ShopManager:showShopLayer(EnumShopType.LotteryShop,tag)
end

function JumpToManager:jumpToShopBoCai(tag,isMoved)
	
	ShopManager:showShopLayer(EnumShopType.BocaiShop,tag)
end


function JumpToManager:jumpToBuyShopStrengh()
	CommonManager:openCommonBuyLayer(EnumResourceType.Strengh)
end

function JumpToManager:jumpToBuyShopSpirit()
	CommonManager:openCommonBuyLayer(EnumResourceType.Spirit)
end

function JumpToManager:jumpToBuyShopCoin()
	CommonManager:openCommonBuyLayer(EnumResourceType.Coin)
end

function JumpToManager:jumpToRoundTask(tag,isMoved)
	if isMoved == nil then  
		RoundTaskManager:openRunMainLayer() 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('ChallengeScene','btn_run','onTouchClickHandle')
	end
	self:jumpGoto('ChallengeScene','btn_run','onTouchClickHandle')

	-- RoundTaskManager:openRunMainLayer()
end

function JumpToManager:jumptoPetLayer()
	PetRoleManager:openPetChooseLayer()
end

function JumpToManager:jumptoPetMergeLayer()
	if ServerSwitchManager:isPetComposeOpen() then
		PetRoleManager:openPetHCLayer()
	else
		toastMessage(localizable.common_yet_open)
	end
end

function JumpToManager:jumpToBookWorld(tag,isMoved)
	if isMoved == nil then  
		BookWorldManager:sendBookWorld(MainPlayer.playerId) 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','btn_bookWorld','bookWorldClickHandle')
	end
	self:jumpGoto('HomeScene','btn_bookWorld','bookWorldClickHandle')
	-- BookWorldManager:sendBookWorld(MainPlayer.playerId)
end

function JumpToManager:jumpTozhuanpan(tag,isMoved)
	if isMoved == nil then  
		TFDirector:dispatchGlobalEventWith(JumpToManager.MENULAYER_OPEN_GEMBLE, 0) 
		return
	end
	self.onLoadSceneFinishFunc = function ( ... )
		self:jumpGoto('HomeScene','panel_zhuanpan','onTouchBeganHandle')
	end
	self:jumpGoto('HomeScene','panel_zhuanpan','onTouchBeganHandle')

	-- TFDirector:dispatchGlobalEventWith(JumpToManager.MENULAYER_OPEN_GEMBLE, 0)
end

function JumpToManager:jumpToSignLayer()
	FuliManager:openSignLayer()
end

function JumpToManager:jumpToChallenge()
	CommonManager:requestEnterInScene(EnumSceneType.Challenge)
end

function JumpToManager:jumpToMissionChapter( ... )
	MissionManager:openMissionChapterLayer()
end

function JumpToManager:jumpToGodPet( ... )
	GodPetManager:openShenChongCatchLayer()
end

function JumpToManager:jumpToGuildWar( ... )
	if ServerSwitchManager:isGuildWarOpen() then
		if GuildWarManager:canGuildWarOpen() then
			GuildWarManager.openLayerList['mainLayer'] = true
			GuildWarManager:sendGetGuildBattleStatusInfo()
		else
			GuildWarManager:openGuildWarMainLayer()
		end
	else
		toastMessage(localizable.common_yet_open)
	end
end

function JumpToManager:jumpToGuildMain( ... )
	GuildManager:openGuildMainLayer( )
end

function JumpToManager:jumpToGuildDonation( ... )
	GuildManager:sendSignInfoReq( )
end

function JumpToManager:jumpToGuildDungeon( ... )
	GuildDungeonManager:openGuildDungeonLayer()
end 

function JumpToManager:jumpToGuildTask( ... )
	GuildTaskManager.isOpenTask = true
	GuildTaskManager:sendRefreshGuildTaskReq()
end

function JumpToManager:jumpToSpecialEquipment( )
	SpecialEquipmentManager:openSpecialEquipmentMainLayer()
end


--前往场景，控件名，控件点击func
function JumpToManager:jumpGoto( scene_name,widget_name,func_name )
	local scene = Public:currentScene()
	if scene.__cname == scene_name then
		self.canFinishFunc = nil
		self.onLoadSceneFinishFunc = nil

		if scene.__cname == 'HomeScene' then
			AlertManager:closeAllWithoutSpecial('lua.logic.home.MenuLayer')
		elseif scene.__cname == 'ChallengeScene' then
			AlertManager:closeAllWithoutSpecial('lua.logic.challenge.JiGuanFangLayer')
		end
		local curScene = Public:currentScene()
		local topLayer = curScene:getTopLayer()
		if topLayer == nil then return end
		if topLayer[widget_name] and topLayer[func_name] then
			topLayer[func_name](topLayer[widget_name])
		end
	else
		if scene.__cname == 'HomeScene' then
			--目前只有去机关房
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.home.MenuLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer.panel_jiguan and topLayer.onTouchBeganHandle then
				self.canListenClick = true
				topLayer.onTouchBeganHandle(topLayer.panel_jiguan)
			end
		elseif scene.__cname == 'MissionScene' then
			--去大地图
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.mission_new.MissionLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer.btn_back and topLayer.onBackClickHandle then
				self.canListenClick = true
				topLayer.onBackClickHandle(topLayer.btn_back)
			end
		elseif scene.__cname == 'BigWorldScene'  then
			--去主城
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.mission_new.MissionWorldLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer and topLayer.onBackClickhandle then
				self.canListenClick = true
				topLayer.onBackClickhandle(topLayer)
			end
		elseif scene.__cname == 'MallScene' then
			--去主城
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.shop.MallLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer.panel_zhucheng and topLayer.onTouchClickHandle then
				self.canListenClick = true
				topLayer.onTouchClickHandle(topLayer.panel_zhucheng)
			end
		elseif scene.__cname == 'ChallengeScene' then
			--去主城
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.challenge.JiGuanFangLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer.panel_zhucheng and topLayer.onTouchClickHandle then
				self.canListenClick = true
				topLayer.onTouchClickHandle(topLayer.panel_zhucheng)
			end
		elseif scene.__cname == 'GuildScene' then
			--去主城
			self.canFinishFunc = true
			AlertManager:closeAllWithoutSpecial('lua.logic.guild.GuildSceneLayer')
			local curScene = Public:currentScene()
			local topLayer = curScene:getTopLayer()
			if topLayer == nil then return end
			if topLayer.btnBack and topLayer.backToHome then
				self.canListenClick = true
				topLayer.backToHome(topLayer.btnBack)
			end
		end
	end
end


function JumpToManager:isCanJump( info )

	local tbl = stringToNumberTable(info, "_")
	local id = tbl[1]
	local tag = tbl[2]
	local configure = FunctionOpenConfigure:objectByID(id)
	if configure then
		if configure.level > MainPlayer:getLevel() then
			-- toastMessage(stringUtils.format(localizable.common_function_openlevel, configure.level))
			local str = stringUtils.format(localizable.common_function_openlevel, configure.level, configure.desc)
			return false, id, tag, str
	    end

	    local template = MissionData:objectByID(configure.mission_id)
	    local starLevel = MissionManager:getStarLevelByMissionId(configure.mission_id)
	    if starLevel == 0 and template then
	    	-- local chapter = ChapterData:objectByID(template.chapter)
	    	-- toastMessage(stringUtils.format(localizable.commom_function_openmission, chapter.name))
			local str = stringUtils.format(localizable.commom_function_openmission, template.brief, configure.desc)
			return false, id, tag, str
	    end
	end

	return true, id, tag
end

--info:功能id，isMoved:跑过去才打开
function JumpToManager:jumpToByFunctionId( info,isMoved )
	-- print("info " .. info)
	local is_can, id, tag, str = self:isCanJump(info)
	if not is_can then
		toastMessage(str)
		return
	end
	
	if id == FunctionManager.RoleInfoStar then--角色升星
		CardRoleManager:setCardRoleInfoBtn( 3 )
	elseif id == FunctionManager.RoleInfoBook then--角色进阶
		CardRoleManager:setCardRoleInfoBtn( 2 )
	end	
	-- print("info " .. info)
	if self.tJumpFunction[id] then
		StatisticsManager:layerJump( id )
		TFFunction.call(self.tJumpFunction[id], self, tag,isMoved)
	else
		toastMessage(localizable.common_unopened)
	end
end

--跳转到指定的章节   
function JumpToManager:jumpChapterById(chapterId, mainRolePanel)
	local currentScene = Public:currentScene()
	local topLayer = currentScene:getTopLayer()
	if currentScene.__cname == "MissionScene" then
		if topLayer.__cname ~= "MissionLayer" then
			return
		end
		if topLayer.chapterId == chapterId then
			if TeamManager:ishaveTeam() then
				topLayer:moveToTeamPos()
			end
			return
		end
	end

	-- local scene = nil
	-- local inBigWorld = MissionManager:inBigWorld(chapterId)
	-- if inBigWorld then
	-- 	if not CheckCurrentSceneBySceneId(EnumSceneType.BigWorld) then
	-- 		chapterId = nil
	-- 		scene = EnumSceneType.BigWorld
	-- 	else
	-- 		print("jumpChapterById bigWorld:", chapterId)
	-- 		TFDirector:dispatchGlobalEventWith(MissionManager.MissionChapterGuid, chapterId)
	-- 		return
	-- 	end
	-- else
	-- 	if not CheckCurrentSceneBySceneId(EnumSceneType.Home) then
	-- 		chapterId = nil
	-- 		scene = EnumSceneType.Home
	-- 	else
	-- 		print("jumpChapterById home:", chapterId)
	-- 		if topLayer.JumpHandle then
	-- 			topLayer:JumpHandle(chapterId)
	-- 			return
	-- 		end
	-- 	end
	-- end

	local func = function ()
		self:newJumpChapterById( chapterId )
		-- CommonManager:requestEnterInScene(scene, chapterId)
	end
	Utils:addTransferEffect(mainRolePanel, func)
end

--跳转到指定的场景  
function JumpToManager:jumpSceneByname(sceneName,mainRolePanel)
	if sceneName then
		local currentScene = Public:currentScene()
		-- local topLayer = currentScene:getTopLayer()
		if  currentScene.__cname == sceneName then return end
		if sceneName == "ChallengeScene" then
			MissionManager:setIsJumpChapter( {bool = true, chapterId = EnumJiGuanClickType.JiGuanRoundTask} )
			local func = function ()
				CommonManager:requestEnterInScene(EnumSceneType.Challenge)
			end
			Utils:addTransferEffect(mainRolePanel, func)
		-- elseif topLayer.__cname == "MenuLayer" then
		-- 	topLayer:JumpHandle( chapterId )
		end
	end
end

------------------------章节列表的跳转
function JumpToManager:newJumpChapterById( id, target )
    local curScene = Public:currentScene()
    MissionManager:setIsJumpChapter( {bool = true, chapterId = id} )
    local is_bigWorld = MissionManager:inBigWorld(id)
    if curScene.__cname == "MissionScene" then
        local curLayer = curScene:getButtomLayer()
        if curLayer.chapterId ~= id then
            local curChapter = ChapterData:objectByID(curLayer.chapterId)
            local NextChapter = ChapterData:objectByID(id)
            if curChapter.chapter_title ~= NextChapter.chapter_title then
                if is_bigWorld then
                    CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
                else
                    CommonManager:requestEnterInScene(EnumSceneType.Home)
                end
			else
				MissionManager:setIsJumpChapter( {bool = false, chapterId = nil} )
				if target then 
					AlertManager:closeLayer(target)
				else
					AlertManager:close()
				end
				local topLayer = curScene:getTopLayer()
				local width, height = GameConfig.WS.width, GameConfig.WS.height
				local effect = GameResourceManager:getEffectAniById("shuimozhuanchang", 1, 1, "bofang01")
				effect:setPosition(ccp(width/2,height/2))
				effect:setZOrder(10001)
				topLayer:addChild(effect)
				effect:addMEListener(TFSKELETON_COMPLETE, function ()
					effect:removeMEListener(TFSKELETON_COMPLETE)
					CommonManager:requestEnterInScene(nil, id)
				end)
                return
            end 
		else
			MissionManager:setIsJumpChapter( {bool = false, chapterId = nil} )
			if target then 
				AlertManager:closeLayer(target)
			else
				AlertManager:close()
			end
            return
        end
	elseif curScene.__cname == "HomeScene" or curScene.__cname == "BigWorldScene" then
		local topLayer = curScene:getTopLayer()
		
		if topLayer.__cname == "MenuLayer" or topLayer.__cname == "MissionWorldLayer" then
			topLayer:onShow()
		else
			if target then 
				AlertManager:closeLayer(target)
			else
				AlertManager:close()
			end
		end
	else
		if curScene.__cname == "ChallengeScene" then
			if is_bigWorld then
				CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
			else
				CommonManager:requestEnterInScene(EnumSceneType.Home)
			end
		else
			if target then 
				AlertManager:closeLayer(target)
			else
				AlertManager:close()
			end
			
			if is_bigWorld then
				CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
			else
				CommonManager:requestEnterInScene(EnumSceneType.Home)
			end
		end
    end
    TFDirector:dispatchGlobalEventWith(MissionManager.MissionChapterLayer, id)
end

return JumpToManager:new()