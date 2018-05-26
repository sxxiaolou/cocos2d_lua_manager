--
-- 邮件公告管理类
-- Author: Jin
-- Date: 2016-10-31
--

local BaseManager = require('lua.gamedata.BaseManager')
local NotifyManager = class("NotifyManager", BaseManager)
-- NotifyMessageLayer = require("lua.logic.notify.NotifyMessageLayer")

NotifyManager.RefreshMailList = "NotifyManager.RefreshMailList"
NotifyManager.RefreshNotifyNum = "NotifyManager.RefreshNotifyNum"

NotifyManager.SYSTEM_NOTIFY = 1
NotifyManager.FIGHT_NOTIFY = 2
function NotifyManager:ctor()
	self.super.ctor(self)
end

function NotifyManager:init()
	self.super.init(self)

	self.fightList = TFMapArray:new()
	self.systemList = TFMapArray:new()
	self.guildList = TFMapArray:new()
	TFDirector:addProto(s2c.RETURN_NOTIFY_NUM, self, self.onReceiveNotifyNum)
	TFDirector:addProto(s2c.RETURN_FIGHT_NOTIFY, self, self.onReceiveFightNotify)
	TFDirector:addProto(s2c.RETURN_SYSTEM_NOTIFY, self, self.onReceiveSystemNotify)
	TFDirector:addProto(s2c.RETURN_GUILD_NOTIFY, self, self.onReceiveGuildNotify)
	TFDirector:addProto(s2c.SEND_GUILD_MAIL_RES, self, self.onReceiveGuildMailSucess)
	TFDirector:addProto(s2c.GET_SYSTEM_NOTIFY_ITEM_SUC, self, self.onReceiveGetSystemNotifyItemSuc)
	TFDirector:addProto(s2c.DELETE_MAIL_SUCCESS, self, self.onReceiveDeleteMailSuc)
	TFDirector:addProto(s2c.MAIL_STATE_CHANGED_LIST, self, self.onReceiveMailStateChangedList)
	TFDirector:addProto(s2c.SYSTEM_NOTIFY_READ_SUC, self, self.onReceiveSystemNotifyReadSuc)

	-- TFDirector:addProto(s2c.GET_CARD_NOTIFY, self, self.GetCardNotify)
	-- TFDirector:addProto(s2c.OBTAIN_GEM_NOTIFY, 	 self, self.obtainGemNotify)
	TFDirector:addProto(s2c.SYSTEM_NOTICE_MESSAGE,self, self.ReceiveEmergencyNotify)
	TFDirector:addProto(s2c.REPEAT_SYSTEM_MESSAGE,self, self.repeatSystemMessage)
	TFDirector:addProto(s2c.REPEAT_SYSTEM_MESSAGE_LIST,self, self.repeatSystemMessageList)
	TFDirector:addProto(s2c.DEL_REPEAT_SYSTEM_MESSAGE,self, self.delRepeatSystemMessage)

	self.MessageArray = TFArray:new()
	self.repeatSystemMessageArray = TFArray:new()

	self:reset()

	self:addRepeatSystemMessageTimer()

	self.onEnterHomeListener = function(events)
    	local len = self.MessageArray:length()
    	if len < 1 then return end
    	if self.notifyLayer == nil then
			local msgNode = self.MessageArray:front()
			-- print("msgNode = ", msgNode)
			if msgNode then
				-- print("msgNode.content 11 = ", msgNode.content)
				msgNode.times = msgNode.times - 1
				self:displayMessage(msgNode.content)
			end
		end
	end
	TFDirector:addMEGlobalListener("onEnterHomeScene", self.onEnterHomeListener)
end

function NotifyManager:restart()
	self:reset()
end

function NotifyManager:reset()
	self.fightNum = 0
	self.systemNum = 0
	self.guildNum = 0
	self.fightList:clear()
	self.systemList:clear()
	self.guildList:clear()
	self.MessageArray:clear()
	self.repeatSystemMessageArray:clear()
end

-- protocol
function NotifyManager:sendQueryFightNotify()
	self:sendWithLoading(c2s.QUERY_FIGHT_NOTIFY, false)
end

function NotifyManager:sendQuerySystemNotify()
	self:sendWithLoading(c2s.QUERY_SYSTEM_NOTIFY, false)
end

function NotifyManager:sendQueryGetSystemNotifyItem(notifyId)
	self:sendWithLoading(c2s.QUERY_GET_SYSTEM_NOTIFY_ITEM, notifyId)
end

function NotifyManager:sendQueryGuildNotify( ... )
	self:sendWithLoading(c2s.QUERY_GUILD_NOTIFY,false)
end

function NotifyManager:sendGuildMailReq( playerList,title,content )
	self:sendWithLoading(c2s.SEND_GUILD_MAIL_REQ,playerList,title,content)
end

function NotifyManager:sendDelMail(notifyId, type)
	self.updateType = type
	self:sendWithLoading(c2s.REQUEST_DEL_EMAIL, notifyId, type)
end

function NotifyManager:sendQuerySystemNotifyRead(notifyId,type)
	self:sendWithLoading(c2s.QUERY_SYSTEM_NOTIFY_READ, notifyId,type)
end

-- 邮件数量  
function NotifyManager:onReceiveNotifyNum(event)
	local data = event.data
	print("==onReceiveNotifyNum==", data)
	if data.fightNotifyNum then self.fightNum = data.fightNotifyNum end
	if data.systemNotifyNum then self.systemNum = data.systemNotifyNum end
	if data.guildNotifyNum then self.guildNum = data.guildNotifyNum end
	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshNotifyNum, 0)
end

-- 战斗消息
function NotifyManager:onReceiveFightNotify(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveFightNotify==", data)

	--清除红点
	self.fightNum = 0

	local list = data.list or {}
	self.fightList:clear()

	for k,info in pairs(list) do
		self.fightList:pushbyid(info.reportId, info)
	end

	self.fightList:sort(function(f1, f2) return f1.time > f2.time end)

	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

-- 系统消息
function NotifyManager:onReceiveSystemNotify(event)
	hideLoading()
	local data = event.data
	print("==onReceiveSystemNotify==")

	local list = data.notifyList or {}
	self.systemList:clear()

	for k,info in pairs(list) do
		self.systemList:pushbyid(info.id, info)
	end

	self.systemList:sort(function(f1, f2) return f1.time > f2.time end)

	local layer = AlertManager:getLayerByName('lua.logic.notify.NotifyLayer')
	if layer then
		TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
	else
		self:openNotifyLayer()
	end
end

--公会邮件
function NotifyManager:onReceiveGuildNotify( event )
	hideLoading()
	local data = event.data
	print('NotifyManager:onReceiveGuildNotify:',data)
	local list = data.list or {}
	self.guildList:clear()

	for k,info in pairs(list) do
		self.guildList:pushbyid(info.id, info)
	end

	self.guildList:sort(function(f1, f2) return f1.time > f2.time end)
	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

--发送公会邮件成功
function NotifyManager:onReceiveGuildMailSucess( event )
	hideLoading()
	local data = event.data
	print('NotifyManager:onReceiveGuildMailSucess:',data)
	if data.result then
		toastMessage(localizable.guild_mail_send_sucess)
		local layer = AlertManager:getLayerByName('lua.logic.guild.GuildMailLayer')
		if layer then
			AlertManager:closeLayer(layer)
		end
	end
end

-- 领取邮件物品成功
function NotifyManager:onReceiveGetSystemNotifyItemSuc(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveGetSystemNotifyItemSuc==")

	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

-- 删除邮件成功
function NotifyManager:onReceiveDeleteMailSuc(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveDeleteMailSuc==")

	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

function NotifyManager:onReceiveSystemNotifyReadSuc(event)
	hideLoading()
	local data = event.data
	-- print("==onReceiveSystemNotifyReadSuc==")

	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

function NotifyManager:onReceiveMailStateChangedList(event)
	hideLoading()
	local data = event.data
	local typ = data.type
	-- print("==onReceiveMailStateChangedList==", data)

	-- if typ == NotifyManager.SYSTEM_NOTIFY then
	for k,info in pairs(data.mail) do
		local mail1 = self.systemList:objectByID(info.id)
		local mail2 = self.fightList:objectByID(info.id)
		local mail3 = self.guildList:objectByID(info.id)
		if mail1 then
			if info.status < 2 then
				mail1.status = info.status
			else
				self.systemList:removeById(info.id)
			end
		end
		if mail2 then
			if info.status < 2 then
				mail2.status = info.status
			else
				self.fightList:removeById(info.id)
			end
		end
		if mail3 then
			if info.status < 2 then
				mail3.status = info.status
			else
				self.guildList:removeById(info.id)
			end
		end
	end
	-- else
	if mail1 then
		self.systemList:sort(function(f1, f2) return f1.time > f2.time end)
	end

	if mail2 then
		self.fightList:sort(function(f1, f2) return f1.time > f2.time end)
	end
	
	if mail3 then
		self.guildList:sort(function(f1, f2) return f1.time > f2.time end)
	end

	TFDirector:dispatchGlobalEventWith(NotifyManager.RefreshMailList, 0)
end

-- notice
-- function NotifyManager:GetCardNotify(event)
-- 	local msgData = event.data
-- 	if msgData.playerName == MainPlayer.name then
-- 		return
-- 	end

-- 	local cardConfig = CardData:objectByID(msgData.cardId)
-- 	if cardConfig == nil then
-- 		return
-- 	end

-- 	local nameRGBValue = '#ff4ef5'
-- 	if cardConfig.quality == 5 then
-- 		nameRGBValue = '#ff9c00'
-- 	end

-- 	local strFormat = localizable.NotifyManager_getRole_strFormat
-- 	local strFormatChat = localizable.NotifyManager_getRole_strFormatChat

-- 	local radomIndex = math.random(1, #strFormat)
-- 	local notifyStr = stringUtils.format(strFormat[radomIndex], msgData.playerName, nameRGBValue, cardConfig.name)
-- 	local notifyStrChat = stringUtils.format(strFormatChat[radomIndex], msgData.playerName, nameRGBValue, cardConfig.name)

-- 	if cardConfig.quality == 5 then
-- 		self:sendMsgToChat(notifyStrChat)
-- 	end
-- 	self:addMessage(notifyStr, 1, 1)
-- end

--[[
获得宝石通知
]]
-- function NotifyManager:obtainGemNotify(event)
-- 	local msgData = event.data
-- 	local operationType = msgData.operationType
-- 		if operationType and operationType >0  then
-- 		if operationType == 203 then
-- 			return
-- 		elseif operationType == 204 then
-- 			return
-- 		elseif operationType == 207 then
-- 			return
-- 		elseif operationType == 211 then
-- 			return
-- 		end
-- 	end

-- 	local goodsTemplate = EquipGemData:objectByID(msgData.templateId)
-- 	if goodsTemplate == nil then
-- 		return
-- 	end

-- 	local nameRGBValue = '#ff4ef5'
-- 	if goodsTemplate.quality == 5 then
-- 		nameRGBValue = '#ff9c00'
-- 	end

	
-- 	local operationStrFormat = ''
-- 	if operationType and operationType >0  then
-- 		if operationType == 104 then
-- 			--operationStrFormat = "，通过宝石合成，"--[[<font color="#000000" fontSize="26">，通过宝石合成，</font>]]
-- 			operationStrFormat = localizable.NotifyManager_operationStrFormat1
-- 		elseif operationType == 203 then
-- 			--operationStrFormat = "，通过宝石拆卸，"--[[<font color="#000000" fontSize="26">，通过宝石拆卸，</font>]]
-- 			operationStrFormat = localizable.NotifyManager_operationStrFormat2
-- 		elseif operationType == 204 then
-- 			--operationStrFormat = "，通过装备升星，"--[[<font color="#000000" fontSize="26">，通过装备升星，</font>]]
-- 			operationStrFormat = localizable.NotifyManager_operationStrFormat3
-- 		elseif operationType == 207 then
-- 			--operationStrFormat = "，通过出售装备，"--[[<font color="#000000" fontSize="26">，通过出售装备，</font>]]
-- 			operationStrFormat = localizable.NotifyManager_operationStrFormat4
-- 		elseif operationType == 211 then
-- 			--operationStrFormat = "，通过装备重铸，"--[[<font color="#000000" fontSize="26">，通过装备重铸，</font>]]
-- 			operationStrFormat = localizable.NotifyManager_operationStrFormat5
-- 		end
-- 	end

-- 	local strFormat = localizable.NotifyManager_obtainGemNotify_strFormat
-- 	-- {
-- 	-- 	[[<p style="text-align:left margin:5px">
-- 	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

-- 	-- 	[[<p style="text-align:left margin:5px">
-- 	-- 	<font color="#feff8f" fontSize="26">%s</font><font color="#ffffff" fontSize="26">%s</font><font color="#ffffff" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#ffffff" fontSize="26"> x%s，快来围观！</font></p>]],
-- 	-- }
-- 	local strFormatChat = localizable.NotifyManager_obtainGemNotify_strFormatChat
-- 	-- {
-- 	-- 	[[<p style="text-align:left margin:5px">
-- 	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，一统江湖指日可待！</font></p>]],

-- 	-- 	[[<p style="text-align:left margin:5px">
-- 	-- 	<font color="#ff0000" fontSize="26">%s</font><font color="#000000" fontSize="26">%s</font><font color="#000000" fontSize="26">获得了</font><font color="]]..nameRGBValue..[[" fontSize="26">%s</font><font color="#000000" fontSize="26"> x%s，快来围观！</font></p>]],
-- 	-- }

-- 	local radomIndex = math.random(1, #strFormat)
-- 	local notifyStr = stringUtils.format(strFormat[radomIndex], msgData.playerName,operationStrFormat, nameRGBValue, goodsTemplate.name,msgData.number)
-- 	local notifyStrChat = stringUtils.format(strFormatChat[radomIndex], msgData.playerName,operationStrFormat, nameRGBValue, goodsTemplate.name,msgData.number)

-- 	-- self:ShowNotifyMessage(notifyStr)
-- 	-- if goodsTemplate.quality == 5 then
-- 	self:sendMsgToChat(notifyStrChat)
-- 	-- end
-- 	self:addMessage(notifyStr, 1, 1)
-- end

--紧急通知
function NotifyManager:ReceiveEmergencyNotify(event)
	if event.data.content == nil then
		return
	end

	local content = event.data.content
	if content == "" then
		return
	end

	-- local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF0000" fontSize="26">%s</font></p>]]
	-- local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF4444" fontSize="26">{p1}</font></p>]]
	-- local notifyStr = stringUtils.format(strFormat, content)
	local notifyStr = content
	self:sendMsgToChat(notifyStr)
	-- print("ReceiveEmergencyNotify===", notifyStr)

	-- self:RemoveNotifyMessage()
	-- self:ShowNotifyMessage(notifyStr)

	local disTimes 		= 1
	local disPriority 	= event.data.priority or 3

	local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF4444">{p1}</font></p>]]
	notifyStr = stringUtils.format(strFormat, notifyStr)
	self:addMessage(notifyStr, disTimes, disPriority)
end

--可重复系统消息主动推出
function NotifyManager:repeatSystemMessage(event)
	local data = event.data
	-- print("NotifyManager:repeatSystemMessage--->",data)
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == data.messageId then
			for key ,value in pairs(data) do
				notify[key] =  value
				return
			end
		end
	end
	local notify = clone(data)
	notify.cur_time = notify.intervalTime
	notify.isAdd = false
	notify.add_times = 0
	self.repeatSystemMessageArray:pushBack(notify)
end

--可重复系统消息列表主动推出
function NotifyManager:repeatSystemMessageList(event)
	local data = event.data
	-- print("NotifyManager:repeatSystemMessageList--->",data)
	self.repeatSystemMessageArray:clear()
	if data.msg then
		for i=1,#data.msg do
			local notify = clone(data.msg[i])
			notify.cur_time = notify.intervalTime
			notify.isAdd = false
			notify.add_times = 0
			self.repeatSystemMessageArray:pushBack(notify)
		end
	end
end

--可重复系统消息删除
function NotifyManager:delRepeatSystemMessage(event)
	local data = event.data
	-- print("NotifyManager:delRepeatSystemMessage--->",data)
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == data.messageId then
			self.repeatSystemMessageArray:removeObject(notify)
			return
		end
	end
end

function NotifyManager:getRepeatSystemMessageById(messageId )
	for notify in self.repeatSystemMessageArray:iterator() do 
		if notify.messageId == messageId then
			return notify
		end
	end
end

function NotifyManager:updateRepeatSystemMessage()
	if self.repeatSystemMessageArray:length() == 0 then
		return
	end
	local nowTime  = MainPlayer:getNowtime() * 1000
	local removeArray = TFArray:new()
	for notify in self.repeatSystemMessageArray:iterator() do
		-- print("notify === ", notify.content, " ", notify.cur_time, " ", notify.add_times)
		if notify.beginTime == nil or notify.beginTime <= nowTime then
			if notify.endTime == nil or notify.endTime >= nowTime then
				if notify.repeatTime == nil or notify.repeatTime > notify.add_times then
					if notify.isAdd == false then
						notify.cur_time = notify.cur_time + 1
						if notify.cur_time >= notify.intervalTime then
							-- print("-------------------------add 111-------------------------->",notify.messageId)
							notify.cur_time = 0
							notify.isAdd = true
							-- notify.add_times = notify.add_times + 1
							self:sendMsgToChat(notify.content)

							local strFormat = [[<p style="text-align:left margin:5px"><font color="#FF4444">{p1}</font></p>]]
							local notifyStr = stringUtils.format(strFormat, notify.content)
							self:addMessage(notifyStr,1,notify.priority,notify.messageId)
						end
					end
				else
					removeArray:pushBack(notify)
				end
			else
				removeArray:pushBack(notify)
			end
		end
	end
	for v in removeArray:iterator() do
		-- print("remove ---------->",v)
		self.repeatSystemMessageArray:removeObject(v)
	end
	removeArray:clear()
end

function NotifyManager:addRepeatSystemMessageTimer()
	if self.repeatSystemMessageTimer == nil then
		self.repeatSystemMessageTimer = TFDirector:addTimer(1000,-1,nil,function ()
			self:updateRepeatSystemMessage()
		end)
	end
end

function NotifyManager:ShowNotifyMessage(notifyStr)
	if not tolua.isnull(self.notifyLayer) then
		return
	end

	local currentScene = Public:currentScene()
    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
       return
    end

	self:RemoveNotifyMessage()

	self.notifyLayer = require("lua.logic.notify.NotifyMessageLayer"):new()
	self.notifyLayer:setPosition(ccp(GameConfig.WS.width/2, 110))
	self.notifyLayer:setZOrder(500)
	currentScene:addLayer(self.notifyLayer)

    self.notifyLayer:ShowText(notifyStr)
end

function NotifyManager:RemoveNotifyMessage()
	if not tolua.isnull(self.notifyLayer) then
		Public:currentScene():removeLayer(self.notifyLayer)
	end
	self.notifyLayer = nil
end

-- api
function NotifyManager:openNotifyLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.notify.NotifyLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function NotifyManager:openMailDetailLayer(mail)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.notify.MailDetailLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setData(mail)
	AlertManager:show()
end

function NotifyManager:openMailDetailLayer2(mail)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.notify.MailDetailLayer2", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setData(mail)
	AlertManager:show()
end

--local
function NotifyManager:sendMsgToChat(content)
	--[[
message ChatInfo
{
	required int32 chatType = 1;	// 聊天类型；1、公共，2、私聊；3、帮派； 
	required string message = 2;	//消息;
	required int32 playerId = 3;	//说话人的id 
	required string name = 4;		//说话人的名字 
}
]]
	-- local msg = {}
	-- msg.chatType = EnumChatType.Public
	-- msg.roleId 	 = 0
	-- msg.content  = content --"11213141"
	-- msg.name     = "系统公告"
	-- msg.timestamp= MainPlayer:getNowtime() * 1000

	-- ChatManager:addReceive(msg)

	NewChatManager:addNotifyChatMsg(content)
end

function NotifyManager:addMessage(disContent, disTimes, disPriority,reapteMessageId)
	--策划添加，  第一章时，不应该显示跑马灯     
	local value = ConstantData:getValue("Notify.Hidden.in.Guide")
	if MissionManager:getStarLevelByMissionId(value) == 0 then return end

	local showTime 		= disTimes or 1
	local showPriority 	= disPriority or 1
	if reapteMessageId == nil then
		reapteMessageId = 0
	end

	local len = self.MessageArray:length()
	
	if len >= 10 and disPriority == 1 then
		print("---NotifyManager:addMessag 已达到最大10条 不在添加，优先级高的不加限制")
		return
	end

	local msgNode = {
		content  = disContent,
		times 	 = showTime,
		priority = showPriority,
		reapteMessageId = reapteMessageId,
	}

	self.MessageArray:push(msgNode)

	local function sortCmp(node1, node2)
		if node1 == nil then
			return false
		end

		if node1 and node2 and node1.priority > node2.priority then
			return true
		end

		return false
	end


	local len = self.MessageArray:length()

	if len > 1 then
		self.MessageArray:sort(sortCmp)
	end

	-- print("---NotifyManager:addMessage--count", len)
	local currentScene = Public:currentScene()
	if self.notifyLayer == nil and currentScene.__cname ~= "BattleResultScene" and currentScene.__cname ~= "BattleScene" then
		local msgNode = self.MessageArray:front()
		-- print("msgNode = ", msgNode)
		if msgNode then
			-- print("msgNode.content 11 = ", msgNode.content)
			msgNode.times = msgNode.times - 1
			self:displayMessage(msgNode.content)
		end
	end
end

function NotifyManager:displayMessageCompelete()
	self:RemoveNotifyMessage()
	-- print("self.MessageArray:length( ----------->",self.MessageArray:length())
	if self.MessageArray:length() == 0 then
		return
	end
	--否还有公告
	local msgNode = self.MessageArray:front()
	while self.MessageArray:length() > 0 and msgNode == nil do
		self.MessageArray:popFront()
		msgNode = self.MessageArray:front()
	end
	if self.MessageArray:length() == 0 or msgNode == nil then
		print("广播播完了")
		return
	end

	-- print("msgNode.times = ", msgNode.times)
	if msgNode.times > 0 then
		msgNode.times = msgNode.times - 1
		self:displayMessage(msgNode.content)

	else
		if msgNode.reapteMessageId ~= 0 then
			-- print("-----add ------------>",msgNode.reapteMessageId)
			local notify = self:getRepeatSystemMessageById(msgNode.reapteMessageId )
			if notify then
				notify.isAdd = false
				notify.add_times = notify.add_times + 1
			end
		end
		self.MessageArray:popFront()

		self:displayMessageCompelete()
	end
end

function NotifyManager:displayMessage(notifyStr)
	-- if not tolua.isnull(self.notifyLayer) then
	-- 	return
	-- end

	local currentScene = Public:currentScene()
    if currentScene.__cname == "BattleResultScene" or currentScene.__cname == "BattleScene" or currentScene:getTopLayer().__cname =="RedPacketRainLayer" then
       return
    end

    if self.notifyLayer == nil then
		self.notifyLayer = require("lua.logic.notify.NotifyMessageLayer"):new()
		self.notifyLayer:setPosition(ccp(GameConfig.WS.width/2, 25))
		self.notifyLayer:setZOrder(500)
		currentScene:addLayer(self.notifyLayer)

	    self.notifyLayer:ShowText(notifyStr)
   	end
end

--=========================== redpoint ===============================

function NotifyManager:isHaveRedPoint()
	if self:isHaveSystem() then return true end
	if self:isHaveFight() then return true end
	if self:isHaveGuild() then return true end
	return false
end

function NotifyManager:isHaveSystem()
	-- for data in self.systemList:iterator() do
	-- 	if data.status == 0 then
	-- 		return true
	-- 	end
	-- end
	-- return false

	return self.systemNum > 0
end

function NotifyManager:isHaveFight()
	return self.fightNum > 0
end

function NotifyManager:isHaveGuild( ... )
	return self.guildNum > 0
end

--=========================== end      ===============================

return NotifyManager:new()