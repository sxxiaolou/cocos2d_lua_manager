--
-- 新聊天系统
-- Tony
-- 2017-11-14 08:55:44
--

local BaseManager = require('lua.gamedata.BaseManager')
local NewChatManager = class("NewChatManager", BaseManager)

NewChatManager.kSpeakerGoodsIdKey = "Chat.Trumpet"
NewChatManager.kServerSpeakerGoodsIdKey = "Chat.ServerBroadcast.GoodsId"

NewChatManager.CHAT_MSG_UPDATE = "NewChatManager.CHAT_MSG_UPDATE"
NewChatManager.STRANGER_UPDATE = "NewChatManager.STRANGER_UPDATE"
NewChatManager.BLACK_UPDATE = "NewChatManager.BLACK_UPDATE"

NewChatManager.CHAT_SETTING = "NewChatManager.CHAT_SETTING"
NewChatManager.PLAYER_ONLINE = "NewChatManager.PLAYER_ONLINE"

NewChatManager.ChatMainLayerRefresh = "NewChatManager.ChatMainLayerRefresh"
NewChatManager.ChatPrivateRedPoint  = "NewChatManager.ChatPrivateRedPoint"

-- //陌生人信息
-- message ChatPlayerInfo
-- {
-- 	required string playerId = 1;		//说话人的id
-- 	required int32 roleId = 2;			//主角角色ID，卡牌ID
-- 	required int32 quality = 3;			//说话角色的主角品质
-- 	required string name = 4;			//说话人的名字
-- 	required int32 vipLevel =5;			//VIP等级
-- 	required int32 level = 6; 			//玩家等级
-- 	optional int32 guildId = 7; 		//公会编号
-- 	optional string guildName = 8; 	//公会名称
-- 	optional int32 competence = 9;		//公会职位 1会长 2副会长 3成员
-- 	optional int32 serverId = 10;
-- 	optional string serverName = 11;
-- 	required int32 power = 12;
-- }

-- //消息
-- message ChatMessageInfo
-- {
-- 	required ChatType type = 1;		//聊天类型；1、公共，2、私聊；3、帮派；
-- 	required string content = 2;		//消息;
-- 	optional string fileId = 3; 	//语音文件
-- 	optional int32 voiceTimer = 4;	//语音时长
-- 	required int64 timeStamp = 5;		//消息发送时间
-- 	required string playerId = 6;		//说话人的id
-- 	optional string targetId = 7;		//接收者id
-- }

function NewChatManager:ctor(data)
	self.super.ctor(self, data)
end

function NewChatManager:init()
	self.super.init(self)

	self.chatList = TFArray:new()
	self.playerChatRedPoint = {}
	self.strangerList = {} 			--陌生人列表    
	self.blackList = {} 			--黑名单列表  
	self.chatPointMsg = TFArray:new()
	self.speechText = {}
	self.chatSetting = {}
	self:initSmileArr()
	self:initSmileConfig()

	TFDirector:addProto(s2c.CHAT_RECEIVE_NEW, self, self.onChatReceiveNew)
	TFDirector:addProto(s2c.CHAT_INFO_NEW, self, self.onChatInfoNew)
	TFDirector:addProto(s2c.PLAYER_CHAT_RED_POINT, self, self.onPlayerChatRedPoint)
	TFDirector:addProto(s2c.STRANGER_LIST_RESULT, self, self.onStrangerListResult)
	TFDirector:addProto(s2c.CHAT_POINT_RESULT, self, self.onChatPointResult)
	TFDirector:addProto(s2c.CHAT_BLACKLIST_RESULT, self, self.onChatBlacklistResult)
	TFDirector:addProto(s2c.CHAT_SETTING_RESULT, self, self.onChatSettingResult)
	TFDirector:addProto(s2c.CHAT_ONLINE_RESULT, self, self.onChatOnlineResult)
end

function NewChatManager:restart()
	if self.chatList then
		self.chatList:clear()
	end
	if self.chatPointMsg then
		self.chatPointMsg:clear()
	end
	self.playerChatRedPoint = {}
	self.blackList = {} 
	self.speechText = {}
end

--================ send ====================================================
--聊天 
function NewChatManager:sendChatMsgNew(type, content, fileId, voiceTimer)
	self:send(c2s.CHAT_MSG_NEW, type, content, fileId, voiceTimer)
end

--私聊聊天
function NewChatManager:sendPlayerChatMsg(type, content, fileId, playerName, playerId, voiceTimer)
	self:send(c2s.PLAYER_CHAT, type, content, fileId, playerName, playerId, voiceTimer)
end

--获取玩家聊天记录
function NewChatManager:sendGetPlayerChatRecord(playerId, index, size)
	self:sendWithLoading(c2s.GET_PLAYER_CHAT_RECORD, playerId, index, size)
end

--陌生人       
function NewChatManager:sendGetChatStrangerList()
	self:sendWithLoading(c2s.GET_CHAT_STRANGER_LIST, false)
end

--黑名单    
function NewChatManager:sendGetChatBlacklist()
	self:send(c2s.GET_CHAT_BLACKLIST, false)
end

--添加黑名单
function NewChatManager:sendAddChatBlacklist(playerId)
	self:sendWithLoading(c2s.ADD_CHAT_BLACKLIST, playerId)
end

--删除黑名单
function NewChatManager:sendDeleteChatBlacklist(playerId)
	self:sendWithLoading(c2s.DELETE_CHAT_BLACKLIST, playerId)
end

function NewChatManager:sendChatSetting(index)
	self:send(c2s.CHAT_SETTING, index)
end

function NewChatManager:sendChatOnline(playerId)
	self:sendWithLoading(c2s.CHAT_ONLINE, playerId)
end

function NewChatManager:sendChatExitPlayer(playerId)
	self:send(c2s.CHAT_EXIT_PLAYER, playerId)
end

--==========================================================================

--聊天内容 
function NewChatManager:onChatReceiveNew(event)
	hideLoading()

	local chat = event.data.chat or {}
	for _, v in pairs(chat) do
		self:addChatMsg(v)
	end

	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_MSG_UPDATE)
end

--聊天信息结构体 
function NewChatManager:onChatInfoNew(event)
	hideLoading()

	local data = event.data
	self:addChatMsg(data)

	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_MSG_UPDATE)
end

--私聊红点 
function NewChatManager:onPlayerChatRedPoint(event)
	hideLoading()

	local playerId = event.data.playerId or {}
	for _, id in pairs(playerId) do
		if self.curPlayerId == nil or id ~= self.curPlayerId then
			self.playerChatRedPoint[id] = true
		end
	end
	TFDirector:dispatchGlobalEventWith(NewChatManager.ChatPrivateRedPoint)
end

--陌生人列表 
function NewChatManager:onStrangerListResult(event)
	hideLoading()

	local list = event.data.list or {}
	self.strangerList = {}

	for k,v in pairs(list) do
		if self.strangerInfo == nil or (self.strangerInfo and v.playerId ~= self.strangerInfo.playerId) then
			self.strangerList[k] = {info=v}
		end
	end

	if self.strangerInfo then
		table.insert(self.strangerList, 1, {info = self.strangerInfo})
		self.strangerInfo = nil
	end
	TFDirector:dispatchGlobalEventWith(NewChatManager.STRANGER_UPDATE)
end

--点对点消息 
function NewChatManager:onChatPointResult(event)
	hideLoading()
	local message = event.data.msg or {}
	for _, msg in pairs(message) do
		local info = self:getChatPointPlayer(msg.playerId)
		if info then
			local temp = {msg = msg, info = info}
			self.chatPointMsg:push(temp)
			self:setTplType(temp)
			if temp.msg.fileId and temp.msg.fileId ~= "" then
				self:speechToText(temp.msg.fileId)
			end
		end
	end
	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_MSG_UPDATE)
end

--黑名单 
function NewChatManager:onChatBlacklistResult(event)
	hideLoading()

	-- print("onChatBlacklistResult =", event.data.list)
	local list = event.data.list or {}
	self.blackList = list

	-- self:openChatSetLayer()
	TFDirector:dispatchGlobalEventWith(NewChatManager.BLACK_UPDATE)
end

--聊天设置   
function NewChatManager:onChatSettingResult(event)
	hideLoading()

	local index = event.data.index or {}
	self.chatSetting = {}

	for k,v in pairs(index) do
		self.chatSetting[v] = true
	end
	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_SETTING)
end

--是否在线
function NewChatManager:onChatOnlineResult(event)
	hideLoading()

	local playerId = event.data.playerId
	local online = event.data.online
	local lastLoginTime = event.data.lastLoginTime
	TFDirector:dispatchGlobalEventWith(NewChatManager.PLAYER_ONLINE, playerId, online, lastLoginTime)
end

--==========================================================================

function NewChatManager:speechToText(fileId)
	VoiceManager:SpeechToText(fileId)
end

function NewChatManager:addChatMsg(msg)
	self.chatList:push(msg)
	self:setTplType(msg)
	if msg.msg.fileId and msg.msg.fileId ~= "" then
		self:speechToText(msg.msg.fileId)
	end
end

function NewChatManager:setTplType(msg)
	if msg.tplType then return end
	
	if msg.msg.type == EnumNewChatType.System then
		msg.tplType = EnumNewChatTplType.Text
	elseif msg.msg.fileId and msg.msg.fileId ~= "" then
		msg.tplType = EnumNewChatTplType.Voice
	else
		msg.tplType = EnumNewChatTplType.Normal
	end
end

function NewChatManager:getChatListByType(types, array)
	if (not self.chatList and not self.chatPointMsg) or not types then return nil end

	local function checkType(type)
		for k,v in pairs(types) do
			if v == type then
				return true
			end
		end
		return false
	end

	local array = array or TFArray:new()
	array:clear()
	for chat in self.chatList:iterator() do
		if checkType(chat.msg.type) then
			array:push(chat)
		end
	end
	for chat in self.chatPointMsg:iterator() do
		if checkType(chat.msg.type) and chat.info.playerId ~= MainPlayer:getPlayerId() and (MainPlayer:getNowtime() * 1000 - chat.msg.timeStamp) < 60000 then
			array:push(chat)
		end
	end
	return array
end

function NewChatManager:getChatPointPlayer(playerId)
	if playerId == MainPlayer:getPlayerId() then
		return {
			playerId = playerId,
			roleId = MainPlayer:getHeadId(),
			quality = MainPlayer:getMainRole().quality,
			name = MainPlayer:getName(),
			vipLevel = MainPlayer:getVipLevel(),
			level = MainPlayer:getLevel(),
			guildId = GuildManager:getGuildId() or "",
			guildName = GuildManager:getGuildName() or "",
			competence = nil,
			serverId = MainPlayer:getServerId(),
			power = MainPlayer:getPower(),
		}
	end

	local friend = FriendManager:getFriendByID(playerId)
	if friend then
		return {
			playerId = friend.info.playerId,
			roleId = friend.info.icon,
			quality = friend.info.headPicFrame,
			name = friend.info.name,
			vipLevel = friend.info.vip,
			level = friend.info.level,
			guildId = friend.info.guildId,
			guildName = friend.info.guildName,
			competence = nil,
			serverId = friend.info.serverId or MainPlayer:getServerId(),
			power = friend.info.power,
		}
	end

	if self.strangerList then
		for k,v in pairs(self.strangerList) do
			if v.info.playerId == playerId then
				return v.info
			end
		end
	end
	return nil
end

--获取小喇叭个数 
function NewChatManager:getSpeakerNumber()
	local speakerConstant = ConstantData:objectByID(NewChatManager.kSpeakerGoodsIdKey)
	local item = BagManager:getGoodsByTplId(speakerConstant.res_id)
	if item == nil then
		return 0
	end
	return item.num
end

--获取跨服小喇叭个数 
function NewChatManager:getServerSpeakerNumber()
	return self:getSpeakerNumber()
	-- local speakerConstant = ConstantData:objectByID(NewChatManager.kServerSpeakerGoodsIdKey)
	-- local item = nil --BagManager:getItemById(speakerConstant.res_id)
	-- if item == nil then
	-- 	return 0
	-- end
	-- return item.num
end

function NewChatManager:removeNewMessageByID(playerId)
	self.playerChatRedPoint[playerId] = nil
end

function NewChatManager:addSpeechText(fileId, text)
	if fileId and not self.speechText[fileId] then
		self.speechText[fileId] = text
	end
end

function NewChatManager:getSpeechText(fileId)
	return self.speechText[fileId]
end

function NewChatManager:getSetting(index)
	return self.chatSetting[index]
end

function NewChatManager:isInBaclkList(playerId)
	if not self.blackList then return false end
	for k,v in pairs(self.blackList) do
		if v.playerId == playerId then
			return true
		end
	end
	return false
end

function NewChatManager:clearChatPointMsg()
	self.chatPointMsg:clear()
end

--添加陌生人聊天   
function NewChatManager:addStrangerInfo(info)
	self.strangerInfo = info
end

--当前聊天界面类型    
function NewChatManager:setCurrentType(type)
	self.currentType = type
end

function NewChatManager:getCurrentType()
	return self.currentType or EnumNewChatType.World
end

--初始化表情对应的动画
function NewChatManager:initSmileArr()
    self.smileArr = require('lua.table.t_s_smile.lua')
end

--获取表情动画array
function NewChatManager:getSmileArr()
	return self.smileArr
end

--初始化表情配置
function NewChatManager:initSmileConfig()
	local tSmileConfig={}
	
    local szMcMsg = [[<mc src="%s" play="auto" anim="default" />]]
    local szImgMsg = [[<img src="%s" />]]
    for v in self.smileArr:iterator() do
		if v.smile_type == 1 then
			local smile = string.format(szMcMsg, v.path)
			tSmileConfig[v.name] = smile
		elseif v.smile_type == 2 then
			local smile = string.format(szImgMsg, v.path)
			tSmileConfig[v.name] = smile
		end
    end
    self.tSmileConfig = tSmileConfig
end

--获取表情配置  
function NewChatManager:getSmileConfig()
    return self.tSmileConfig
end

function NewChatManager:getChatMessage(content, type, link)
	local tSmileConfig = self:getSmileConfig()
    local szMSG = ChatFormatData:getFormat(type)
    local szInput = string.gsub(content, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")

    szInput = szInput:gsub( "<", '&lt;')
    szInput = szInput:gsub( ">", '&gt;')
    for k, v in pairs(tSmileConfig) do
        szInput = string.gsub(szInput, k, v)
	end
	return string.format(szMSG, szInput, link or "")
end

function NewChatManager:getChatFwqTxt(type, info)
	local str = ""
	if type == EnumNewChatType.Server or type == EnumNewChatType.Private then
		if info.serverId then str = "S" .. info.serverId end
	elseif type == EnumNewChatType.Guild then
		str = info.guildName
	elseif type == EnumNewChatType.Team and TeamManager:ishaveTeam() then
		local teamInfo = TeamManager:getTeamInfo()
		if teamInfo.leaderId == info.playerId then
			str = localizable.chat_team_leader
		end
	end
	return str
end

function NewChatManager:getCommonChatMsg(data)
	local tSmileConfig = self:getSmileConfig()
	local content = data.msg.content
	if string.find(content, 'fontSize') then
		content = string.gsub(content, 'fontSize = "20"', 'fontSize = "18"')
	else
		content = string.gsub( content, '<font', '<font fontSize="18"')
	end
	if data.msg.type ~= EnumNewChatType.System and data.tplType ~= EnumNewChatTplType.Text then
		local id = data.msg.link and data.msg.link ~= "" and 101 or 100
		local msgFormat = ChatFormatData:getFormat(id)
		local name = self:getSmileNameByType(data.msg.type)
		content = string.gsub(content, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")
		content = content:gsub( "<", '&lt;')
		content = content:gsub( ">", '&gt;')
		content = string.format(msgFormat, name, data.info.name, "S" .. data.info.serverId, content, data.msg.link or "")
	end
	for k, v in pairs(tSmileConfig) do
		content = string.gsub(content, k, v)
	end
	return content
end

function NewChatManager:getSmileNameByType(type)
	return "@" .. (55 + type)
end

function NewChatManager:isHavePrivateRedPoint()
	for k,v in pairs(self.playerChatRedPoint) do
		return true
	end
	return false
end

function NewChatManager:isHaveFriendRedPoint()
	if not self.playerChatRedPoint then return false end

	local friendList = FriendManager:getFriendInfoList()
	if friendList then
		for _, data in pairs(friendList) do
			if data and data.info and data.info.playerId and self.playerChatRedPoint[data.info.playerId] then
				return true
			end
		end
	end
	return false
end

function NewChatManager:isHaveStrangerRedPoint()
	if not self.playerChatRedPoint then return false end

	for id, v in pairs(self.playerChatRedPoint) do
		if not FriendManager:getFriendByID(id) then
			return true
		end
	end
	return false
end

function NewChatManager:isHavePrivateRedPointById(playerId)
	return self.playerChatRedPoint[playerId]
end

function NewChatManager:addNotifyChatMsg(content)
	--消息字号转换   
	local text = string.find(content, '<font') and "" or content
	local szMSG = ChatFormatData:getFormat(EnumNewChatType.World)
	content = string.format(szMSG, self:getSmileNameByType(EnumNewChatType.World) .. content)

	local msg = {}
	msg.tplType = EnumNewChatTplType.Text
	msg.msg = {
		type = EnumNewChatType.World,
		content = content,
		fileId = "",
		voiceTimer = 0,
		playerId = "",
		timeStamp = MainPlayer:getNowtime() * 1000,
		text = text,    --系统公告文本，衡量文本高度 
	}
	self:addChatMsg(msg)
	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_MSG_UPDATE)
end

function NewChatManager:addEmojiChatMsg(emoji)
	local data = CitadelEmotionData:getEmojiByType(emoji.idx)
	if not data then return end

	local content = nil
	local playerName = self:getPlayerNameById(emoji.playerId)
	local targetName = self:getPlayerNameById(emoji.targetId)
	if not playerName or not targetName then
		return
	end

	local msg = {}
	local tSmileConfig = self:getSmileConfig()
	local content = string.format(data.desc, playerName, targetName)
	content = tSmileConfig[self:getSmileNameByType(EnumNewChatType.Scene)] .. content
	msg.tplType = EnumNewChatTplType.Text
	msg.msg = {
		type = EnumNewChatType.Scene,
		content = content,
		fileId = "",
		voiceTimer = 0,
		playerId = "",
		timeStamp = MainPlayer:getNowtime() * 1000,
	}
	self:addChatMsg(msg)
	TFDirector:dispatchGlobalEventWith(NewChatManager.CHAT_MSG_UPDATE)
end

function NewChatManager:getPlayerNameById(playerId)
	local player = SyncPosManager.players[playerId]
	if player then
		return player.name
	end
end

function NewChatManager:setCurChatPlayerId(playerId)
	if self.curPlayerId == playerId then return end
	if self.curPlayerId then self:sendChatExitPlayer(self.curPlayerId) end
	self.curPlayerId = playerId
end

--获取聊天好友列表      
function NewChatManager:getFriendInfoList()
	local list = FriendManager:getFriendInfoList()
	if not list then return {} end

	return self:sortTable(list)
end

function NewChatManager:getStrangerList()
	if not self.strangerList then return {} end

	return self:sortTable(self.strangerList)
end

function NewChatManager:sortTable(list)
	table.sort(list, function (p1, p2)
		local id1 = p1.info.playerId
		local id2 = p2.info.playerId
		if self.playerChatRedPoint[id1] and self.playerChatRedPoint[id2] then
			return id1 < id2
		elseif self.playerChatRedPoint[id1] then
			return true
		elseif self.playerChatRedPoint[id2] then
			return false
		end
		return false
	end)
	return list
end

--=============================open==========================

function NewChatManager:openChatMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.chat_new.ChatMainLayer", AlertManager.BLOCK_CLOSE, AlertManager.TWEEN_NONE)
    AlertManager:show()
end

function NewChatManager:openChatSetLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.chat_new.NewChatSetLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_NONE)
    AlertManager:show()
end

function NewChatManager:openChatRoleInfoLayer(data)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.chat_new.NewChatRoleInfoLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_NONE)
	layer:loadData(data)
	AlertManager:show()
end

function NewChatManager:openLink(link)
	if not link then return end

	local tbl = stringToTable(link, "_")
	local id = tonumber(tbl[1])
	local isCan, _, _, str = JumpToManager:isCanJump( id )
	if not isCan then
		toastMessage(str)
		return
	end

	local currentScene = Public:currentScene()
	if currentScene.__cname ~= "HomeScene" then return end

	AlertManager:closeAll()
	if id == FunctionManager.Team then
		if tbl[2] then TeamManager:sendJoinTeam(tbl[2]) end
	else
		JumpToManager:jumpToByFunctionId(id)
	end
	
end

return NewChatManager:new()