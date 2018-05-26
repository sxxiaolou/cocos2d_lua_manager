local LoginManager = class('LoginManager', BaseManager)

LoginManager.CREATE_PLAYER_SUC	 =  "LoginManager.CREATE_PLAYER_SUC"

function LoginManager:ctor(data)
	self.super.ctor(self, data)
	self:reset()
end

function LoginManager:init()
	TFDirector:addProto(s2c.LOGIN_RESULT, self, self.loginHandle)
	TFDirector:addProto(s2c.CREATE_PLAYER_RESULT, self, self.createPlayerHandle)
	TFDirector:addProto(s2c.BEFORE_ENTER_GAME, self, self.beforeEnterGame)
	TFDirector:addProto(s2c.ENTER_GAME, self, self.enterGame)
end

function LoginManager:reset()
	self.firstLoginMark = true 		--标记是否首次登陆
	self.bIsEnterGame = false       --是否已经进入游戏
	self.bFirstLogin = false	
	self.bIsNewRole = false			-- 是否为新角色
end

function LoginManager:restart()
	self:reset()
end

--请求创建角色
function LoginManager:requestCreatePlayer(playerName, sex, profession)
	self:sendWithLoading(c2s.REGIST_DATA, playerName, sex, profession)
end

--请求进入游戏(创建角色成功后需要主动请求进入游戏)
function LoginManager:requestEnterGame()
	self:sendWithLoading(c2s.REQUEST_ENTER_GAME, true)
end

function LoginManager:loginHandle(event)
	if event.data.statusCode == 0 then
		if event.data.empty then
			hideAllLoading()  
			local currentScene = Public:currentScene()
			if currentScene == nil or currentScene.__cname == "CreatePlayerScene" then
				return
			end
			if PlayerGuideManager.bOpenGuide and PlayerGuideManager.bOpenGuide == true then
			 	AlertManager:changeScene(SceneType.FIRSTBATTLE)
			else
				AlertManager:changeScene(SceneType.CREATEPLAYER)
			end
		end
	else
		hideAllLoading()
		--toastMessage("登陆失败")
		toastMessage(localizable.loginNoticePage_login_fail)
	end
end

function LoginManager:createPlayerHandle(event)
	hideLoading()
	if event.data.statusCode ~= 0 then
		--toastMessage("创建角色失败")
		toastMessage(localizable.createPlayer_create_fail)
	else
		print("创建角色成功")
		self.bIsNewRole = true
		TFDirector:dispatchGlobalEventWith(LoginManager.CREATE_PLAYER_SUC, 0)
	end
end

function LoginManager:beforeEnterGame(event)
	print("--------------开始进入游戏----------------")
--[[
	[1] = {--BeforeEnterGame
		[1] = 'int64':serverStartup	[服务器启动时间轴]
		[2] = 'int64':lastLogon	[最后一次走登录流程的时间轴]
	}
--]]
	--self:restart()
	local data = event.data
	local time = math.max(data.serverStartup , data.lastLogon)
	self.logonTime = time
end

function LoginManager:enterGame(event)
	print("--------------完成进入游戏----------------")
	local resVersion = event.data.resVersion
	print("resVersion:" .. resVersion)
	self.bIsEnterGame = true

	self.firstLoginMark = false
	-- if self.bIsNewRole then
	-- 	print("该角色为首次创建 进入游戏")
	-- 	MissionManager:openMissionWorldLayer()
	-- else
	-- 	print("该角色非首次创建 进入游戏")
	-- 	TFDirector:changeScene(SceneType.HOME)
	-- end

	--策划需求    
	if MainPlayer:quickInMissionWorld() then --MissionManager:isInFirstChapter() then
		print("未通关第一章 直接进入大地图 副本关卡")
		-- MissionManager:openMissionWorldLayer()
		-- CommonManager:requestEnterInScene(EnumSceneType.BigWorld)
	else
		print("通关第一章 进入主城")
		-- TFDirector:changeScene(SceneType.HOME)
		-- CommonManager:requestEnterInScene(EnumSceneType.Home)
	end
	--主界面弹弹弹
	MainPlayer:initPushDialogs()

	--跳过所有的新手引导    
	-- PlayerGuideManager:saveGuideStep_test()

	--添加计时器
	BookWorldManager:addTimer()
	-- print("=========== lalalal", MainPlayer.playerId)
	if HeitaoSdk then
		local isNewRole = 0

		if self.bIsNewRole then
			isNewRole = 1
		end

		HeitaoSdk.enterGame(MainPlayer.playerId, MainPlayer.name, MainPlayer.level, isNewRole)
	end
	
	-- -- 是否是新角色
	-- self.bIsNewRole = false
	CommonManager.TryReLoginFailTimes = 0
	CommonManager:startHeartBeat()

	self:backDownLoad()
end

--后台下载    
function LoginManager:backDownLoad()

	if (MissionManager:findMission(1004001) or MainPlayer:getLevel() >= 10)  then return end

	if  MainPlayer:isCanBackDownLoad() and TFDeviceInfo:getNetWorkType() == "WIFI" then
		local tbl = PackageDownManager:getDownLoadTypes()
		PackageDownManager:setDownLoadList(tbl, true)
	end
end

function LoginManager:createPanel()
	local panel = TFPanel:create()
	panel:setSize(GameConfig.WS)
	panel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	panel:setBackGroundColor(ccc3(0, 0, 0))

	local self = Public:currentScene()
	self:addChild(panel)
	return panel
end

function LoginManager:testUI(file)
	local panel = self:createPanel()
	local layer = require(file):new()
	panel:addChild(layer)
end

function LoginManager:testSkeleton()
	local self = Public:currentScene()
	TFResourceHelper:instance():addSkeletonFromFile("skeleton/10001", 1.0)
    local skeleton = TFSkeleton:create("skeleton/10001")
    skeleton:setPosition(ccp(500, 300))
    self:addChild(skeleton)
    skeleton:play(0, "stand", 1)

	TFDirector:addTimer(5000, -1, nil, function(dt) 
			skeleton:play(0, "jitui", 1)
		    local movePos = skeleton:getPosition() - ccp(300, 0)
			local middlePosX = (skeleton:getPositionX() + movePos.x)/2
			local dist = math.abs(skeleton:getPositionX() - movePos.x)
			local middlePosY = (skeleton:getPositionY() + movePos.y)/2 + dist/2

			local dieEffect = 
			{
				target = skeleton,
				ease = {type=TFEaseType.EASE_IN, rate=100},
				{
					duration = 1.0 / 1.0,
					bezier =
					{
						{
							x = middlePosX,
							y = middlePosY,
						},
						{
							x = middlePosX,
							y = middlePosY,
						},
						{
							x = movePos.x,
							y = movePos.y,
						},
					},
					rotate = -90,
					
					onComplete = function()
						skeleton:setPosition(ccp(500, 300))
						skeleton:play(0, "stand", 1)
						skeleton:setRotation(0)
					end
				}
			}
			TFDirector:toTween(dieEffect)
	 end)
end

return LoginManager:new()





