--[[
******功能管理类*******

	-- by Tony
	-- 2016/9/1
]]

local FunctionManager = class("FunctionManager")

--====================== SDK 相关 ===============================
FunctionManager.Share 		= 10 	-- SDK 分享功能

--====================== 主城 =================================== 
--MENU   			= 200
FunctionManager.MenuRoleList 		= EnumFunctionType.MENU + 1 	--角色入口
FunctionManager.MenuTask 			= EnumFunctionType.MENU + 2 	--每日任务
FunctionManager.MenuLottery 		= EnumFunctionType.MENU + 3  	--抽卡(规则)
FunctionManager.MenuEquip	 		= EnumFunctionType.MENU + 4 	--装备
--FunctionManager.MenuGrab 			= EnumFunctionType.MENU + 5
FunctionManager.MenuFormation 		= EnumFunctionType.MENU + 6 	--阵容
FunctionManager.MenuFriend 			= EnumFunctionType.MENU + 7 	--好友
FunctionManager.MenuBag 			= EnumFunctionType.MENU + 8 	--背包
FunctionManager.MenuRecycle 		= EnumFunctionType.MENU + 9 	--回收
FunctionManager.MenuRank 			= EnumFunctionType.MENU + 10   	--排行
FunctionManager.MenuChat 			= EnumFunctionType.MENU + 11  	--聊天
FunctionManager.MenuShop 			= EnumFunctionType.MENU + 12  	--商城
FunctionManager.MenuFunc 			= EnumFunctionType.MENU + 13 	--功能入口  竞技场 建木通天 鬼神之塔
FunctionManager.MenuPay 			= 3 --EnumFunctionType.MENU + 14    --充值
FunctionManager.MenuSevenDays  		= EnumFunctionType.MENU + 15    --七日活动
FunctionManager.MenuActivity 		= EnumFunctionType.MENU + 16 	--活动
FunctionManager.MenuMail 			= EnumFunctionType.MENU + 17    --邮件
FunctionManager.MenuHandBook        = EnumFunctionType.MENU + 18    --图鉴
FunctionManager.MenuArtifact  		= EnumFunctionType.MENU + 19  	--神器(规则)
FunctionManager.MenuNewRoad 		= EnumFunctionType.MENU + 20 	--新功能开启
FunctionManager.MenuNewMission 		= EnumFunctionType.MENU + 21 	--新引导功能
FunctionManager.MenuSign 			= EnumFunctionType.MENU + 22 	--签到  (规则)
FunctionManager.MenuEatSteamed  	= EnumFunctionType.MENU + 23  	--吃包子
FunctionManager.MenuGamble		  	= EnumFunctionType.MENU + 24  	--博彩(规则)
FunctionManager.MenuNewShenQi		= EnumFunctionType.MENU + 25  	--新神器(规则)
FunctionManager.MenuEye 			= EnumFunctionType.MENU + 26 	--异色之瞳  
FunctionManager.MenuChapter 		= EnumFunctionType.MENU + 27
FunctionManager.MenuLeftTop 		= EnumFunctionType.MENU + 28 		
FunctionManager.MenuTaskMain 		= EnumFunctionType.MENU + 29
FunctionManager.MenuRightBottom     = EnumFunctionType.MENU + 30

FunctionManager.MenuGuild 			= EnumFunctionType.MENU + 31 	--公会
FunctionManager.MenuFuLi            = EnumFunctionType.MENU + 32    --福利
FunctionManager.MenuYueka           = EnumFunctionType.MENU + 33    --月卡
FunctionManager.MenuPlayerInfo      = EnumFunctionType.MENU + 34    --团队信息界面
FunctionManager.MenuBuyCoin      	= EnumFunctionType.MENU + 35    --购买金币
FunctionManager.MenuBuyStrengh      = EnumFunctionType.MENU + 36    --购买体力
FunctionManager.MenuChallenge       = EnumFunctionType.MENU + 37    --挑战按钮
FunctionManager.MenuMissionChapter  = EnumFunctionType.MENU + 38    --章节列表按钮
FunctionManager.MenuRightOffBtn 	= EnumFunctionType.MENU + 39    --右侧任务展开钮
FunctionManager.MenuTaskGoto 		= EnumFunctionType.MENU + 40    --任务点击前往
FunctionManager.MenuShanzi 	 		= EnumFunctionType.MENU + 41    --扇子铺
FunctionManager.MenuWeixin          = EnumFunctionType.MENU + 42    --微信
FunctionManager.MenuShouchong       = EnumFunctionType.MENU + 43    --首冲
FunctionManager.MenuWudaohui        = EnumFunctionType.MENU + 44    --武道会
FunctionManager.MenuSevenDaysLogin  = EnumFunctionType.MENU + 45    --七天登录 
FunctionManager.MenuVipEnter		= EnumFunctionType.MENU + 46    --vip 
FunctionManager.MenuCustomerServices= EnumFunctionType.MENU + 47    --客服
FunctionManager.MenuWeChatRedPacket	= EnumFunctionType.MENU + 48	--微信百万红包
FunctionManager.MenuGodPet			= EnumFunctionType.MENU + 49	--神宠
FunctionManager.MenuHead            = EnumFunctionType.MENU +50     --头像
FunctionManager.MenuGuildWar        = EnumFunctionType.MENU + 51    --帮会战
--FunctionManager.MenuRoleList = EnumFunctionType.MENU + 1

--====================== 卡牌 ====================================
--ROLE 			= 300
FunctionManager.RoleList 			= EnumFunctionType.ROLE + 1 	--角色列表
FunctionManager.RoleListSoul 		= EnumFunctionType.ROLE + 2 	--角色碎片
FunctionManager.RoleListItem 		= EnumFunctionType.ROLE + 3 	--角色列表项
FunctionManager.RoleInfoTransfer 	= EnumFunctionType.ROLE + 4 	--角色传功
FunctionManager.RoleInfoStar 		= EnumFunctionType.ROLE + 5 	--角色升星
FunctionManager.RoleInfoSkill 		= EnumFunctionType.ROLE + 6 	--技能
FunctionManager.RoleInfoBook 		= EnumFunctionType.ROLE + 7 	--进阶
FunctionManager.RoleDestiny 		= EnumFunctionType.ROLE + 8 	--天命
FunctionManager.RoleEquip 			= EnumFunctionType.ROLE + 9 	--装备
FunctionManager.RoleArtifact        = EnumFunctionType.ROLE + 10    --神器
FunctionManager.RoleLevelUp        	= EnumFunctionType.ROLE + 11    --角色升级
FunctionManager.RoleRefine        	= EnumFunctionType.ROLE + 12    --角色炼体

--======================== 抽卡 ================================
FunctionManager.Lottery 			= EnumFunctionType.LOTTERY + 1
FunctionManager.LotteryFree 		= EnumFunctionType.LOTTERY + 2 --免费抽取
FunctionManager.LotteryTen 	 		= EnumFunctionType.LOTTERY + 3 --十连抽


--======================== 装备 ===============================
FunctionManager.Equipment 			= EnumFunctionType.EQUIPMENT + 1 	--装备
FunctionManager.EquipmentWeapon 	= EnumFunctionType.EQUIPMENT + 2 	--武器
FunctionManager.EquipmentHelmet 	= EnumFunctionType.EQUIPMENT + 3 	--头盔
FunctionManager.EquipmentClothes	= EnumFunctionType.EQUIPMENT + 4 	--衣服
FunctionManager.EquipmentBelt   	= EnumFunctionType.EQUIPMENT + 5 	--腰带
FunctionManager.EquipmentShoe   	= EnumFunctionType.EQUIPMENT + 6	--鞋子
FunctionManager.EquipmentUpgrade	= EnumFunctionType.EQUIPMENT + 7 	--
FunctionManager.EquipmentRefining	= EnumFunctionType.EQUIPMENT + 8 	--精炼
FunctionManager.EquipmentStar   	= EnumFunctionType.EQUIPMENT + 9 	--升星
FunctionManager.EquipmentGem    	= EnumFunctionType.EQUIPMENT + 10 	--宝石
FunctionManager.EquipmentAwake	    = EnumFunctionType.EQUIPMENT + 11 	--觉醒
FunctionManager.EquipmentIntensify	= EnumFunctionType.EQUIPMENT + 12 	--强化
FunctionManager.EquipmentMaster		= EnumFunctionType.EQUIPMENT + 13 	--装备大师
FunctionManager.EquipmentOneKeyEquip	= EnumFunctionType.EQUIPMENT + 14 	--一键装备
FunctionManager.EquipmentOneKeyIntensify= EnumFunctionType.EQUIPMENT + 15 	--一键强化

--===========================  神器  ================================
FunctionManager.ArtifactList 		= EnumFunctionType.ARTIFACT + 1   --神器列表
FunctionManager.ArtifactItem 		= EnumFunctionType.ARTIFACT + 2   --神器item

--========================  夺宝 =============================
FunctionManager.GrabTalismanItem        = EnumFunctionType.TALISMAN  + 1


----======================= 任务 成就 ========================
FunctionManager.TaskList 			= EnumFunctionType.TASK + 1 	--任务列表
FunctionManager.AchievementList  	= EnumFunctionType.TASK + 2 	--成就列表
FunctionManager.AchievementLottery 	= EnumFunctionType.TASK + 3 	
FunctionManager.AchievementTalisman = EnumFunctionType.TASK + 4

--========================  挑战 =================================
FunctionManager.ChallengeArena    	= EnumFunctionType.CHALLENGE + 1   --竞技场入口(规则)
FunctionManager.ChallengeGhost   	= EnumFunctionType.CHALLENGE + 2   --鬼神之塔 (规则)
FunctionManager.ChallengeBloody     = EnumFunctionType.CHALLENGE + 3   --建木通天 (规则)
FunctionManager.ChallengeDaily      = EnumFunctionType.CHALLENGE + 4   --日常副本
FunctionManager.ChallengeAdventure  = EnumFunctionType.CHALLENGE + 5   --山海奇遇(规则)
FunctionManager.ChallengeWorldBoss  = EnumFunctionType.CHALLENGE + 6   --世界boss(规则)
FunctionManager.ChallengeScene  	= EnumFunctionType.CHALLENGE + 7   --机关房场景
FunctionManager.ChallengeJiFen  	= EnumFunctionType.CHALLENGE + 8   --轩辕论剑


FunctionManager.ChallengeItem 		= EnumFunctionType.CHALLENGE + 50  --挑战item

---=======================  竞技场 ==========================
FunctionManager.Arena 				= EnumFunctionType.ARENA + 1 	--竞技场
FunctionManager.ArenaGrade          = EnumFunctionType.ARENA + 2    --竞技场积分


--========================  鬼神之塔 ==========================

FunctionManager.GhostRule 	 		= EnumFunctionType.GHOST + 1   --鬼神之塔（规则）

--========================  建木通天 ===========================

---======================== 战斗ui ==========================
FunctionManager.BattleAuto 			= EnumFunctionType.BATTLE + 1 	--自动战斗
FunctionManager.BattleSpeed 		= EnumFunctionType.BATTLE + 2 	--加速战斗
FunctionManager.BattleStop			= EnumFunctionType.BATTLE + 3 	--暂停战斗
FunctionManager.BattleSkip 			= EnumFunctionType.BATTLE + 4	--跳过战斗
FunctionManager.BattleQuit 			= EnumFunctionType.BATTLE + 5 	--退出战斗

--=========================  关卡 ===========================
FunctionManager.MissionMain 		= EnumFunctionType.MISSION + 1 	--主线
FunctionManager.MissionElite 		= EnumFunctionType.MISSION + 2 	--精英
-- FunctionManager.MissionDaily 		= EnumFunctionType.MISSION + 3  --日常
FunctionManager.MissionTenPass      = EnumFunctionType.MISSION + 4  --十连扫荡
FunctionManager.MissionBoxLayer  	= EnumFunctionType.MISSION + 5  --box面板
FunctionManager.MissionOneKey 		= EnumFunctionType.MISSION + 6  --一键托管
FunctionManager.MissionShowMenu     = EnumFunctionType.MISSION + 7  --打开menu
FunctionManager.MissionHideMenu     = EnumFunctionType.MISSION + 8  --隐藏menu


--========================== 商城 ================================
FunctionManager.ShopSycee 			= EnumFunctionType.MALL + 1 	--元宝商城
FunctionManager.ShopArena 			= EnumFunctionType.MALL + 2 	--竞技场商店
FunctionManager.ShopRole 			= EnumFunctionType.MALL + 3 	--角色商店
FunctionManager.ShopTower 			= EnumFunctionType.MALL + 4 	--鬼神之塔商店
FunctionManager.ShopDevildom 		= EnumFunctionType.MALL + 5 	--魔界商店
FunctionManager.ShopFaction 		= EnumFunctionType.MALL + 6 	--帮会商店
FunctionManager.ShopQunying 		= EnumFunctionType.MALL + 7 	--群英山商店
FunctionManager.ShopPet 			= EnumFunctionType.MALL + 8 	--宠物商店
FunctionManager.ShopTowerRandom 	= EnumFunctionType.MALL + 9 	--鬼神之塔随机商店
FunctionManager.ShopQunyingRandom 	= EnumFunctionType.MALL + 10 	--群英随机商店
FunctionManager.ShopTowerMaterial 	= EnumFunctionType.MALL + 11 	--材料商店
FunctionManager.ShopLottery 		= EnumFunctionType.MALL + 12 	--抽卡商店
FunctionManager.ShopBocai  			= EnumFunctionType.MALL + 13    --博彩商店
FunctionManager.ShopWudaohui  		= EnumFunctionType.MALL + 14    --武道会商店

FunctionManager.ShopTab 			= EnumFunctionType.MALL + 50    --商店tab

--=========================  七日活动 ================================
FunctionManager.SevenDay            = EnumFunctionType.SEVENDAYS + 1 --每日
FunctionManager.SevenTab  			= EnumFunctionType.SEVENDAYS + 2 

--==========================  回收系统 ===============================
FunctionManager.RecycleRole 	  	= EnumFunctionType.RECYCLE + 1   --伙伴回收（规则）
FunctionManager.RecycleRoleRebirth 	= EnumFunctionType.RECYCLE + 2 	 --伙伴重生（规则）
FunctionManager.RecycleEquipRebirth = EnumFunctionType.RECYCLE + 3   --装备重生（规则）
FunctionManager.RecycleEquipCompose = EnumFunctionType.RECYCLE + 4 	 --装备合成（规则）
FunctionManager.RecycleGemCompose   = EnumFunctionType.RECYCLE + 5 	 --宝石合成（规则）

--========================== 背包 ====================================
FunctionManager.Bag  				= EnumFunctionType.GOODS + 1 --背包
FunctionManager.BagProp  			= EnumFunctionType.GOODS + 2 --道具
FunctionManager.BagEquip  			= EnumFunctionType.GOODS + 3 --装备
FunctionManager.BagBook  			= EnumFunctionType.GOODS + 4 --宝物
FunctionManager.BagGem  			= EnumFunctionType.GOODS + 5 --宝石
FunctionManager.BagRequire          = EnumFunctionType.GOODS + 6 --获取途径
FunctionManager.BagPropFrag 		= EnumFunctionType.GOODS + 7 --背包道具碎片 

--========================== 购买 ====================================
FunctionManager.BuyShopStrengh  	= EnumFunctionType.BUYSHOP + 1 --购买包子
FunctionManager.BuyShopSpirit  		= EnumFunctionType.BUYSHOP + 2 --购买精力
FunctionManager.BuyShopCoin		  	= EnumFunctionType.BUYSHOP + 3 --购买招财符

--==========================  活动 ===================================

FunctionManager.Activity 			= EnumFunctionType.ACTIVITY + 1 --活动
FunctionManager.ActivityItem 		= EnumFunctionType.ACTIVITY + 2 --活动item
FunctionManager.ActivityFuliEveryDay 		= EnumFunctionType.ACTIVITY + 3 --每日福利
FunctionManager.ActivityWeChatRedPacketTab  = EnumFunctionType.ACTIVITY + 4 --微信红包标签
FunctionManager.ActivityMainUIItem  = EnumFunctionType.ACTIVITY + 5 --活动主界面UI
FunctionManager.NewYearActDay 		= EnumFunctionType.ACTIVITY + 6 --新年活动天数标签
FunctionManager.NewYearActDayTab 	= EnumFunctionType.ACTIVITY + 7 --新年活动Tab标签
FunctionManager.ActivityNewYearHit	 		= EnumFunctionType.ACTIVITY + 8 --打年兽活动

--==========================  好友   ===================================
FunctionManager.Friend 				= EnumFunctionType.FRIEND + 1   --好友界面
FunctionManager.FriendTab 			= EnumFunctionType.FRIEND + 2 	--好友tab

--==========================  邮箱   ===================================
FunctionManager.SystemMail          = EnumFunctionType.MAIL + 1 	--系统邮箱
FunctionManager.BattleMail          = EnumFunctionType.MAIL + 2 	--战斗邮箱
FunctionManager.GuildMail           = EnumFunctionType.MAIL + 3     --公会邮箱

--==========================  聊天   ==================================
FunctionManager.Chat 				= EnumFunctionType.CHAT + 1 	--聊天
FunctionManager.ChatTab 			= EnumFunctionType.CHAT + 2 	--聊天tab
FunctionManager.ChatFriendItem 			= EnumFunctionType.CHAT + 3 	--聊天好友tab
FunctionManager.ChatSystem 			= EnumFunctionType.CHAT + 4 	--系统聊天
FunctionManager.ChatWorld 			= EnumFunctionType.CHAT + 5 	--世界聊天
FunctionManager.ChatServer 			= EnumFunctionType.CHAT + 6 	--跨服聊天
FunctionManager.ChatParty 			= EnumFunctionType.CHAT + 7 	--组队聊天
FunctionManager.ChatGuild 			= EnumFunctionType.CHAT + 8 	--帮会聊天
FunctionManager.ChatTeam 			= EnumFunctionType.CHAT + 9 	--队伍聊天
FunctionManager.ChatCurrent 		= EnumFunctionType.CHAT + 10 	--当前聊天
FunctionManager.ChatFriend 			= EnumFunctionType.CHAT + 11 	--好友聊天
FunctionManager.ChatPrivate 		= EnumFunctionType.CHAT + 12 	--私信聊天

FunctionManager.ChatCommonWorld   	= EnumFunctionType.CHAT + 50 	--通用界面 世界语音聊天
FunctionManager.ChatCommonGuild     = EnumFunctionType.CHAT + 51 	--通用界面 公会语音聊天 

--========================== 天书世界 =================================
FunctionManager.BookWorld    		= EnumFunctionType.BOOKWORLD + 1  --天书世界

--========================== 博彩     =================================
FunctionManager.BoCai  				= EnumFunctionType.BOCAI + 1

--========================== 宠物 ======================================
FunctionManager.Pet 				= EnumFunctionType.PET + 1 		--宠物入口
FunctionManager.PetOpenLeft			= EnumFunctionType.PET + 2 		--宠物左栏位
FunctionManager.PetOpenRight		= EnumFunctionType.PET + 3 		--宠物右栏位
FunctionManager.PetMerge			= EnumFunctionType.PET + 4 		--宠物合成
FunctionManager.PetChoice			= EnumFunctionType.PET + 5 		--宠物更换
FunctionManager.PetMessage			= EnumFunctionType.PET + 6 		--宠物切页
FunctionManager.PetUpLevel			= EnumFunctionType.PET + 7 		--升级切页

--============================任务引导=================================   
FunctionManager.MainTask 				= EnumFunctionType.MAINTASK + 1 		--任务引导

--========================== 组队 ====================================
FunctionManager.Team 				= EnumFunctionType.TEAM + 1          --组队   
FunctionManager.RoundTask 			= EnumFunctionType.TEAM + 2 		 --降妖伏魔
FunctionManager.ScoreMatch3v3 		= EnumFunctionType.TEAM +3		 --积分赛3v3
--=========================== 技能策略 ========================================
FunctionManager.Celue_PVE           = EnumFunctionType.CELUE + 1
FunctionManager.Celue_PVP           = EnumFunctionType.CELUE + 2
FunctionManager.Celue_BloodyWar     = EnumFunctionType.CELUE + 3
FunctionManager.Celue_Team          = EnumFunctionType.CELUE + 4
FunctionManager.Celue_PVP_Match     = EnumFunctionType.CELUE + 5
FunctionManager.Celue_Score_Match_1V1 = EnumFunctionType.CELUE + 6
FunctionManager.Celue_Score_Match_3V3_1 = EnumFunctionType.CELUE + 7
FunctionManager.Celue_Score_Match_3V3_2 = EnumFunctionType.CELUE + 8
FunctionManager.Celue_Score_Match_3V3_3 = EnumFunctionType.CELUE + 9

--=========================== 帮会 ========================================
FunctionManager.GuildMain           = EnumFunctionType.GUILD + 1		--帮会结义堂
FunctionManager.GuildShop           = EnumFunctionType.GUILD + 2 		--帮会商店
FunctionManager.GuildDonation     	= EnumFunctionType.GUILD + 3		--帮会祭拜
FunctionManager.GuildMainItem       = EnumFunctionType.GUILD + 4		--帮会结义堂标签页
FunctionManager.GuildDungeon		= EnumFunctionType.GUILD + 5		--帮会幻境
FunctionManager.GuildTask           = EnumFunctionType.GUILD + 6        --帮会任务
FunctionManager.GuildWar            = EnumFunctionType.GUILD + 7        --帮会战
FunctionManager.GuildWarFormation   = EnumFunctionType.GUILD + 8        --帮会战阵容

--=============================新神器============================================
FunctionManager.NewShenQiIcon       = EnumFunctionType.NEWARTIFACT + 1    --新神器icon
FunctionManager.NewShenQiAttr       = EnumFunctionType.NEWARTIFACT + 2    --新神器属性
FunctionManager.NewShenQiShenActive = EnumFunctionType.NEWARTIFACT + 3    --新神器身激活
FunctionManager.NewShenQiHunLevelUp = EnumFunctionType.NEWARTIFACT + 4    --新神器魄升级
FunctionManager.NewShenQiLingActive = EnumFunctionType.NEWARTIFACT + 5    --新神器灵激活

FunctionManager.ScoreMatch1v1reward1  	= EnumFunctionType.ScoreMatch + 1   --积分赛1v1奖励1
FunctionManager.ScoreMatch1v1reward2  	= EnumFunctionType.ScoreMatch + 2   --积分赛1v1奖励2
FunctionManager.ScoreMatch3v3reward1  	= EnumFunctionType.ScoreMatch + 3   --积分赛3v3奖励1
FunctionManager.ScoreMatch3v3reward2  	= EnumFunctionType.ScoreMatch + 4   --积分赛3v3奖励2
--==============================称号================================================
FunctionManager.TitleIcon = EnumFunctionType.Title + 1 --称号入口
FunctionManager.TitleTab  = EnumFunctionType.Title + 2 --称号页签

--================================专属装备=====================================================
FunctionManager.SpecialEquipment = EnumFunctionType.SpecialEquipMent      --专属装备

function FunctionManager:ctor()
	
end

return FunctionManager:new()