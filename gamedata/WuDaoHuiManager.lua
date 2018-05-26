--
-- 武道会管理类
-- Author: sjj
-- Date: 2017-12-18
--
local BaseManager = require('lua.gamedata.BaseManager')
local WuDaoHuiManager = class("WuDaoHuiManager", BaseManager)

print("++++++++++++sjj+++++WuDaoHuiManager+++++")

function WuDaoHuiManager:ctor()
	self.super.ctor(self)
end

WuDaoHuiManager.betSuccess  = "WuDaoHuiManager.betSuccess"

WuDaoHuiManager.BtnOpenFlag=false

function WuDaoHuiManager:init()
	self.super.init(self)

	TFDirector:addProto(s2c.ARENA_MATCH_RES, self, self.onReceiveArenaMatchRes)--1311
	--TFDirector:addProto(s2c.ARENA_MATCH_RECORD_RES, self, self.onReceiveLookBeforeBattleView)--1312
	TFDirector:addProto(s2c.ARENA_MATCH_BET_INFO_RES, self, self.onReceiveGambleInfo)--1313
	TFDirector:addProto(s2c.ARENA_MATCH_BET_RES, self, self.onReceiveGambleSuccess)--1314	
	TFDirector:addProto(s2c.ARENA_MATCH_POINT, self, self.onReceiveRedTips)--1315	
	--WuDaoHuiManager:TestData()  	
end

function WuDaoHuiManager:restart()--切换账号	
	self:InitVar()		
end

function WuDaoHuiManager:InitVar()	--变量释放
	WuDaoHuiManager.MainLayer=nil
	WuDaoHuiManager.RedTips=nil	
end

function WuDaoHuiManager:ShowPanelInfo(Panel_player,twoPlayers)
	--print('+++++++++++++++sjj++++++++33333+++++',Panel_player)
	local Panel_player1=TFDirector:getChildByPath(Panel_player, "Panel_player1")
	local Panel_player2=TFDirector:getChildByPath(Panel_player, "Panel_player2")
	self:ShowPanelItem(Panel_player1,twoPlayers.playerA,
		function ()   

			self:sendRequestGambleMatch(twoPlayers.playerA.playerId,1)
       	end,
       	function ()  

       		self:sendRequestGambleMatch(twoPlayers.playerA.playerId,2)
       	end
       )  
	self:ShowPanelItem(Panel_player2,twoPlayers.playerB,
		function ()   

			self:sendRequestGambleMatch(twoPlayers.playerB.playerId,1)
       	end,
       	function ()  

			self:sendRequestGambleMatch(twoPlayers.playerB.playerId,2)
       	end
		)  
end

function WuDaoHuiManager:ShowPanelItem(panelItem,tempPlayerData,ClickBtnjinbiCallBack,ClickBtnyuanbaoCallBack)  
	local Image_playerIcon=TFDirector:getChildByPath(panelItem, "Image_playerIcon")
	--print('+++++++++++++++sjj++++++++55555555',Image_playerIcon)
	TFDirector:getChildByPath(panelItem, "Image_playerIcon"):setTexture("icon/head/" .. tempPlayerData.headIcon ..".png")
	TFDirector:getChildByPath(panelItem, "Label_playername"):setText(tempPlayerData.name.."")
	--TFDirector:getChildByPath(panelItem, "Label_playerpower"):setText('战:'..tempPlayerData.power.."")	
	TFDirector:getChildByPath(panelItem, "Label_playerpower"):setText(localizable.wudaohui_zhan..tempPlayerData.power)	
	TFDirector:getChildByPath(panelItem, "Label_supportnum"):setText(tempPlayerData.betCount)
	TFDirector:getChildByPath(panelItem, "Label_playerlevel"):setText(tempPlayerData.level)	
	local Btn_jinbi = TFDirector:getChildByPath(panelItem, "Btn_jinbi")
	local Btn_yuanbao = TFDirector:getChildByPath(panelItem, "Btn_yuanbao")
		
	local costJinbi=ConstantData:objectByID("arena.match.GuessingCost1").value
	local stringJinbi=costJinbi..''
	if type(costJinbi) == "number" and  costJinbi>=10000 then
		local fuck  = costJinbi/10000
		local floatValue = string.format("%.0f",fuck)	
		stringJinbi = stringUtils.format(localizable.fun_wan_desc,floatValue)
	end

	local costYuanbao=ConstantData:objectByID("arena.match.GuessingCost2").value
	local stringYuanbao=costYuanbao..''
	if type(costYuanbao) == "number" and costYuanbao>=10000 then
		local fuck  = costYuanbao/10000
		local floatValue = string.format("%.0f",fuck)	
		stringYuanbao = stringUtils.format(localizable.fun_wan_desc,floatValue)
	end

	TFDirector:getChildByPath(Btn_jinbi, "Label_num"):setText(stringJinbi)
	TFDirector:getChildByPath(Btn_yuanbao, "Label_num"):setText(stringYuanbao)

	Btn_jinbi:addMEListener(TFWIDGET_CLICK,ClickBtnjinbiCallBack)
	Btn_yuanbao:addMEListener(TFWIDGET_CLICK,ClickBtnyuanbaoCallBack)
	local DetailItemList={}
	for i=1,5 do 
		local tempItem = TFDirector:getChildByPath( panelItem, "panel_item"..i)
		DetailItemList[i]=tempItem		
		tempItem:setVisible(false)	
	end
	local tempIndex=1
	for key, value in pairs(tempPlayerData.cards) do   
		self:DetailItem( DetailItemList[tempIndex], value, tempPlayerData )
		tempIndex=tempIndex+1		
	end
end

function WuDaoHuiManager:DetailItem(uiItem,MatchCardData ,tempPlayerData) 
	uiItem:setVisible(true)		
    uiItem.bg_icon      = TFDirector:getChildByPath(uiItem, "bg_icon")
    uiItem.quality = TFDirector:getChildByPath(uiItem.bg_icon, "img_kuang")
    uiItem.icon = TFDirector:getChildByPath(uiItem.bg_icon, "img_icon")
    uiItem.name = TFDirector:getChildByPath(uiItem, "txt_name")
    uiItem.level = TFDirector:getChildByPath(uiItem, "txt_lv")
    uiItem.career = TFDirector:getChildByPath(uiItem, "img_type")  
	local  roleData= CardData:objectByID(MatchCardData.templateId)
	uiItem.quality:setTexture(GetColorKuangByQuality(MatchCardData.quality))
	uiItem.icon:setTexture(roleData:getIcon())
	local name = roleData.name
	if MatchCardData.star > 0 then
		name = name .. " +" .. MatchCardData.star
	end	
	if MatchCardData.templateId==1 or MatchCardData.templateId==2 then
		name=tempPlayerData.name .. " +" .. MatchCardData.star
	end
	uiItem.name:setText(name)
	uiItem.name:setColor(GetColorByQuality(roleData.quality))
	uiItem.level:setText(MatchCardData.level.."")
	uiItem.career:setTexture(roleData:getCareerPath())
end

-- protocol

function WuDaoHuiManager:sendInitData()  -- 请求初始数据--1311
	print('**********sjj**********WuDaoHuiManager***sendInitData*******1311********')
	self:sendWithLoading(c2s.ARENA_MATCH_REQ, false)
end

function WuDaoHuiManager:sendRequestLookBackBattle(stringPlayerId,intRound,index)  -- 竞技场比赛回放请求--1312
	print('**********sjj**********WuDaoHuiManager***sendInitData*******1312********')
	self:sendWithLoading(c2s.ARENA_MATCH_RECORD_REQ, stringPlayerId,WuDaoHuiManager.serverType,intRound,index)
end
function WuDaoHuiManager:sendRequestGambleInfo(stringPlayerId,round)  -- 竞技场比赛下注信息--1313
	print('**********sjj**********WuDaoHuiManager***sendRequestGambleInfo*******1313********')
	self:sendWithLoading(c2s.ARENA_MATCH_BET_INFO_REQ, stringPlayerId,WuDaoHuiManager.serverType,round)
end

function WuDaoHuiManager:sendRequestGambleMatch(stringPlayerId,intBetType)  -- 竞技场比赛下注--1314
	print('**********sjj**********WuDaoHuiManager***sendRequestGambleMatch*******1314********',stringPlayerId)
	--print(WuDaoHuiManager.index)
	self:sendWithLoading(c2s.ARENA_MATCH_BET_REQ, stringPlayerId,WuDaoHuiManager.serverType,WuDaoHuiManager.index,intBetType)
end

function WuDaoHuiManager:onReceiveArenaMatchRes(event)--接受初始数据--当接收到消息时需要去通知界面，
	print('**********sjj**********WuDaoHuiManager***onReceiveArenaMatchRes****1311***********')	

	if WuDaoHuiManager.BtnOpenFlag then
		hideLoading()
		if WuDaoHuiManager.MainLayer~=nil then
			WuDaoHuiManager.MainLayer:setData(event.data)		
		else
			self:openLayer(event.data)
		end		
	end 	
end

function WuDaoHuiManager:closeMainLayer()
	WuDaoHuiManager.BtnOpenFlag=false
	WuDaoHuiManager.MainLayer=nil
end

function WuDaoHuiManager:openLayer(data)
	--print('++++++++sjj+++++++++openLayer++++++1+++++++',MainPlayer:getName())
	--print('++++++++sjj+++++++++openLayer+++++++++++++',MainPlayer:getPlayerId())	
	WuDaoHuiManager.MainLayer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.wudaohui.WuDaoHuiMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	WuDaoHuiManager.MainLayer:setData(data)
	AlertManager:show()

end

function WuDaoHuiManager:SetTiletype(btnIndex)
	WuDaoHuiManager.index=btnIndex
end

function WuDaoHuiManager:SetServerype(serverType)
	WuDaoHuiManager.serverType=serverType
end

function WuDaoHuiManager:onReceiveGambleInfo(event)--竞技场比赛下注信息
	print('**********sjj**********WuDaoHcuiManager***onReceiveGambleInfo****1313***********')	
	hideLoading()
	local data = event.data	
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.wudaohui.WuDaoHuiGambleLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:loadData(data.players)
	AlertManager:show()
end

function WuDaoHuiManager:onReceiveGambleSuccess(event)--竞技场比赛下注
	hideLoading()
	local data = event.data
	--print("============  onReceiveItemUsedResult ==== ", data)
	print('**********sjj**********WuDaoHcuiManager***onReceiveGambleSuccess****1314***********',data.playerId)
	TFDirector:dispatchGlobalEventWith(WuDaoHuiManager.betSuccess, data)
end 

function WuDaoHuiManager:onReceiveRedTips(event)--
	local data = event.data		
	WuDaoHuiManager.RedTips = not data.hasBet	
	print('+++++sjj+++++++11+++---------------------------------------------------++++onReceiveRedTips++++222+++++++++',WuDaoHuiManager.RedTips)
	TFDirector:dispatchGlobalEventWith("refresh_yunyin_red")
end 
--------logic-------------onReceiveRedTips
function WuDaoHuiManager:openWuDaoHuiMainLayer()
	print('+++++sjj++++++++++++++openWuDaoHuiMainLayer+++++++++++++')
	if MainPlayer:isSubPackageDownLoad(EnumSubPackageType.Other, EnumSubPackageType.Role) then
		TFDirector:dispatchGlobalEventWith(PackageDownManager.DOWN_LOAD_LAYER, {EnumSubPackageType.Other, EnumSubPackageType.Role})
		return
	end
	WuDaoHuiManager.BtnOpenFlag=true
	self:sendInitData()      
end

function WuDaoHuiManager:RedPointControl()
	if nil==WuDaoHuiManager.RedTips then
		WuDaoHuiManager.RedTips=false
	end
	return WuDaoHuiManager.RedTips
end

function WuDaoHuiManager:GetDiffListByType(titleType)  
	return WuDaoHuiManager.TotalDataList[titleType]
end

return WuDaoHuiManager:new()

