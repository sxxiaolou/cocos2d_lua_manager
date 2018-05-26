--[[
    This module is developed by Eason
    2015/10/26
]]

local FriendManager = class("FriendManager",BaseManager)

local localVars = {
	isRequestFriendList = false,
	isRequestFriendApplyList = false,

	friendInfoList = {},
	recommendFriendList = {},
	friendApplyList = {},
	applyFriendID = {},

	excuteType = nil,

	isShowRedPoint = false,
	showNewFriendRedPoint = false,
	showNewApplyRedPoint = false,

	pageIndex = {friendsList = 1, addFriend = 2, applicationList = 3},
    selectedPageIndex = 0,
}

FriendManager.UpdateList = "FriendManager.UpdateList"
FriendManager.UpdateJump = 'FriendManager.UpdateJump'

function FriendManager:ctor(Data)
	TFDirector:addProto(s2c.FRIEND_INFO_LIST, self, self.onFriendInfoList)
	TFDirector:addProto(s2c.RECOMMEND_FRIEND_LIST, self, self.onRecommendFriendList)
	TFDirector:addProto(s2c.FRIEND_APPLY_LIST, self, self.onFriendApplyList)
	TFDirector:addProto(s2c.APPLY_FRIEND_SUCESS, self, self.onApplyFriendSucess)
	TFDirector:addProto(s2c.RECOMMEND_FRIEND, self, self.onSearchFriend)
	TFDirector:addProto(s2c.SUCESS_FRIEND_EXEC, self, self.onSucessFriendExec)
	TFDirector:addProto(s2c.NEW_APPLY, self, self.onNewApply)
	TFDirector:addProto(s2c.NEW_FRIEND, self, self.onNewFriend)

end

function FriendManager:restart()
	localVars.isRequestFriendList = false
	localVars.isRequestFriendApplyList = false

	localVars.isShowRedPoint = false
	localVars.showNewFriendRedPoint = false
	localVars.showNewApplyRedPoint = false
	self.isOpenFriendMainLayer = nil

	localVars.friendInfoList = {}
	localVars.recommendFriendList = {}
	localVars.friendApplyList = {}
	localVars.applyFriendID = {}
end

function FriendManager:reloadFriendList()
	localVars.isRequestFriendList = false
	self:requestFriendList()
end

function FriendManager:requestFriendList()
	-- print("FriendManager:requestFriendList()")

	if not localVars.isRequestFriendList then
		self:sendWithLoading(c2s.GAIN_FRIEND_LIST, {false})
	end
end

function FriendManager:onFriendInfoList(events)
	-- print("FriendManager:onFriendInfoList(events)",events.data.friends)

	-- localVars.isRequestFriendList = true
	hideLoading()

	localVars.friendInfoList = nil
	localVars.friendInfoList = {}
	local data = events.data
	if data.friends then
		-- print(data.friends)
		for _, v in pairs(data.friends) do
			table.insert(localVars.friendInfoList, v)
		end
	end
	local layer = AlertManager:getLayerByName("lua.logic.friends.FriendLayer")
	if not layer and self.isOpenFriendMainLayer then
		self.isOpenFriendMainLayer = false
        FriendManager:openFriendMainLayer()
	end
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
end

function FriendManager:requestRecommendFriend()
	-- print("FriendManager:requestRecommendFriend()")
	TFDirector:send(c2s.GAIN_RECOMMEND_FRIEND, {false})
end

function FriendManager:openFriendMainLayer()
	self.friendLayer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.friends.FriendLayer");
    AlertManager:show();
end

-- function FriendManager:openMainLayer()
-- 	self.mainLayer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.home.MenuLayer");
--     AlertManager:show();
-- end

function FriendManager:onRecommendFriendList(events)
	-- print("FriendManager:onRecommendFriendList(events)",events.data.list)

	localVars.recommendFriendList = nil
	localVars.recommendFriendList = {}
	local data = events.data
	if data.list then
		-- print(data.list)
		for _, v in pairs(data.list) do
			table.insert(localVars.recommendFriendList, v)
		end
	end

	-- 请求更新列表
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
end

function FriendManager:requestFriendApplyList()
	-- print("FriendManager:requestFriendApplyList()")

	if not localVars.isRequestFriendApplyList then
		TFDirector:send(c2s.GAIN_FRIEND_APPLY_LIST, {false})
	end
end

function FriendManager:onFriendApplyList(events)
	-- print("FriendManager:onFriendApplyList(events)",events.data.infos)

	localVars.isRequestFriendApplyList = true

	localVars.friendApplyList = nil
	localVars.friendApplyList = {}
	local data = events.data
	if data.infos then
		for _, v in pairs(data.infos) do
			table.insert(localVars.friendApplyList, v)
		end
	end
	self:removeApplyInFriendList()

	-- 请求更新列表
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
end

--是否有好友
function FriendManager:isHaveFriend( ... )
	return #localVars.friendInfoList > 0
end

function FriendManager:getFriendInfoList()
	return localVars.friendInfoList
end

function FriendManager:getRecommendFriendList()
	return localVars.recommendFriendList
end

function FriendManager:getFriendApplyList()
	return localVars.friendApplyList
end

function FriendManager:queryPlayer(name)
	-- print("FriendManager:queryPlayer(name)")
	-- print(name)

	if string.len(name) > 0 then
		TFDirector:send(c2s.QUERY_PLAYER, {name})
	end
end

function FriendManager:onSearchFriend(events)
	-- print("FriendManager:onSearchFriend(events)")
	local data = events.data
	if data then
		-- print(data)
		localVars.recommendFriendList = nil
		localVars.recommendFriendList = {}
		localVars.recommendFriendList[1] = data

		-- 请求更新列表
		TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
	end
end

function FriendManager:requestFriend(friendID)
	-- print("FriendManager:requestFriend(friendID)")
	-- print(friendID)

	localVars.applyFriendID = nil
	localVars.applyFriendID = {}
	localVars.applyFriendID[1] = friendID

	TFDirector:send(c2s.APPLY_FRIEND, {localVars.applyFriendID})
end

function FriendManager:requestAllFriend()
	-- print("FriendManager:requestAllFriend()")
	localVars.applyFriendID = nil
	localVars.applyFriendID = {}

	for _, v in pairs(localVars.recommendFriendList) do
		if not v.apply then
			table.insert(localVars.applyFriendID, v.info.playerId)
		end
	end

	-- print(localVars.applyFriendID)

	if #localVars.applyFriendID > 0 then
		TFDirector:send(c2s.APPLY_FRIEND, {localVars.applyFriendID})
	else
		-- toastMessage("列表内已全部申请")

        toastMessage(localizable.FriendManager_list_req_all)
	end
end

function FriendManager:onApplyFriendSucess(events)
	-- print("FriendManager:onApplyFriendSucess(events)")
	-- toastMessage("已发送申请")
    toastMessage(localizable.FriendManager_list_req_send)

	for i = 1, #localVars.recommendFriendList do
		for j = 1, #localVars.applyFriendID do
			if localVars.recommendFriendList[i].info.playerId == localVars.applyFriendID[j] then
				localVars.recommendFriendList[i].apply = true
			end
		end
	end

	-- 请求更新列表
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateJump)
end

function FriendManager:excuteFriendApply(type, friendID)
	-- print("FriendManager:excuteFriendApply(type, friendID)")
	-- print(type, friendID)

	localVars.excuteType = type

	-- 全部忽略或同意
	if friendID == 0 then
		if #localVars.friendApplyList > 0 then
			TFDirector:send(c2s.EXEC_APPLY_FRIEND, {type, tostring(friendID)})
		else
			-- toastMessage("列表内无申请消息")
			toastMessage(localizable.FriendManager_list_empty)
		end
	else
		TFDirector:send(c2s.EXEC_APPLY_FRIEND, {type, tostring(friendID)})
	end
end

function FriendManager:onSucessFriendExec(events)
	-- print("FriendManager:onSucessFriendExec(events)")
	local tmp = {}

	local data = events.data
	if data.playerIds then
		-- print(data.playerIds)
		-- print(data.type)

		local type = data.type

		if type == 1 then
			-- 处理申请
			for i = 1, #localVars.friendApplyList do
				local found = false
				for j = 1, #data.playerIds do
					if data.playerIds[j] == localVars.friendApplyList[i].playerId then
						found = true
						break
					end
				end
			
				-- -- 添加好友
				-- if localVars.excuteType == 1 or localVars.excuteType == 2 then
				-- 	if found then
				-- 		local t = {}
				-- 		t.info = localVars.friendApplyList[i]
				-- 		t.give = false
				-- 		table.insert(localVars.friendInfoList, t)
				-- 	end
				-- end

				if not found then
					table.insert(tmp, localVars.friendApplyList[i])
				end
			end

			localVars.friendApplyList = nil
			localVars.friendApplyList = tmp

		elseif type == 2 then
			--赠送礼物
			-- print(localVars.friendInfoList)
			for i = 1, #data.playerIds do
				for j = 1, #localVars.friendInfoList do
					if data.playerIds[i] == localVars.friendInfoList[j].info.playerId then
						localVars.friendInfoList[j].give = false
						break
					end
				end
			end

		elseif type == 3 then
			-- 领取礼物
			for i = 1, #data.playerIds do
				for j = 1, #localVars.friendInfoList do
					if data.playerIds[i] == localVars.friendInfoList[j].info.playerId then
						localVars.friendInfoList[j].receive = 2
						break
					end
				end
			end
			-- print(localVars.drawPlayers)

		elseif type == 5 then
			-- 新礼物
			for i = 1, #data.playerIds do
				for j = 1, #localVars.friendInfoList do
					if data.playerIds[i] == localVars.friendInfoList[j].info.playerId then
						localVars.friendInfoList[j].receive = 1
						break
					end
				end
			end

			-- 没有打开好友界面
			if localVars.selectedPageIndex ~= localVars.pageIndex.friendsList then
				-- self.friendLayer:updateRedPoint()
			end

		elseif type == 4 or type == 6 then
			-- 删除好友
			if type == 4 then
				-- 关闭详情界面
				-- AlertManager:close()
			end

			for i = 1, #localVars.friendInfoList do
				local found = false
				for j = 1, #data.playerIds do
					if data.playerIds[j] == localVars.friendInfoList[i].info.playerId then
						found = true
						break
					end
				end

				if not found then
					table.insert(tmp, localVars.friendInfoList[i])
				else
					-- NewChatManager:removeNewMessageByID(localVars.friendInfoList[i].info.playerId)
				end
			end

			localVars.friendInfoList = nil
			localVars.friendInfoList = tmp

			-- 如果已经没有新消息了
			-- if #ChatManager:getNewMessageList() <= 0 then
			-- 	ChatManager:hidePrivateChatRedPoint()
			-- end
		elseif type == 7 then
			--标记好友
			for i = 1, #data.playerIds do
				for j = 1, #localVars.friendInfoList do
					if data.playerIds[i] == localVars.friendInfoList[j].info.playerId then
						localVars.friendInfoList[j].info.sign = not localVars.friendInfoList[j].info.sign
						break
					end
				end
			end
			local FriendInfoLayer = AlertManager:getTopLayer()
			if FriendInfoLayer.setSign ~= nil then
				FriendInfoLayer:setSign()
			end
		elseif type == 8 then
		end
	end

	-- 请求更新列表
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
	TFDirector:dispatchGlobalEventWith(FriendManager.UpdateJump)
end

function FriendManager:friendChallenge(friendID)
	TFDirector:send(c2s.FRIEND_CHALLENGE, {friendID})
end

function FriendManager:deleteFriend(friendID)
	TFDirector:send(c2s.DELETE_FRIEND, {friendID})
end

function FriendManager:signFriend(friendID)
	TFDirector:send(c2s.SIGN_FRIEND, {friendID})
end

-- 赠送礼物
function FriendManager:send(friendID)
	-- print("FriendManager:send(friendID)")
	TFDirector:send(c2s.GIVE_GIFI, {tostring(friendID)})
end

function FriendManager:deleteAll(offline)
	-- print("deleteAll " .. offline)
	TFDirector:send(c2s.ONE_KEY_DEL_FRIEND, {tostring(offline)})
end

function FriendManager:sendAll()
	
	local function isCanSend()
		if localVars.friendInfoList and #localVars.friendInfoList > 0 then
			for k,v in pairs(localVars.friendInfoList) do
				if v.give then
					return true
				end
			end
		end
		return false
	end

	if isCanSend() then
		TFDirector:send(c2s.GIVE_GIFI,{""})
	else
		-- toastMessage("所有好友已赠送礼物")
		toastMessage(localizable.FriendManager_gift_all)
	end
end

-- 领取礼物
function FriendManager:get(friendID)
	TFDirector:send(c2s.DRAW_GIVE_GIFI, {tostring(friendID)})
end

function FriendManager:getAll()
	
	local function isCanGet()
		if localVars.friendInfoList and #localVars.friendInfoList > 0 then
			for k,v in pairs(localVars.friendInfoList) do
				if v.receive == 1 then
					return true
				end
			end
		end
		return false
	end

	if isCanGet() then
		TFDirector:send(c2s.DRAW_GIVE_GIFI, {""})
	else
 		-- toastMessage("所有礼物已领取") 
		toastMessage(localizable.FriendManager_gift_get)
	end
end

function FriendManager:onNewApply(events)
	-- print("FriendManager:onNewApply(events)",events.data.info)
	local data = events.data
	if data then
		-- print(data)
		table.insert(localVars.friendApplyList, data.info)

		-- 没有打开好友界面
		if localVars.selectedPageIndex == localVars.pageIndex.applicationList then
			-- 请求更新列表
		else
			-- self.friendLayer:updateRedPoint()
		end
		self:removeApplyInFriendList()
		TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
	end
end

function FriendManager:onNewFriend(events)
	-- print("FriendManager:onNewFriend(events)")
	local data = events.data
	if data then
		-- print(data)
		table.insert(localVars.friendInfoList, data.friend)
		-- 没有打开好友界面
		if localVars.selectedPageIndex == localVars.pageIndex.friendsList then
			-- 请求更新列表
			TFDirector:dispatchGlobalEventWith(FriendManager.UpdateList)
		else
			-- self.friendLayer:updateRedPoint()
		end
	end
end

function FriendManager:isInFriendList(playerID)
	for i = 1, #localVars.friendInfoList do
		if localVars.friendInfoList[i].info.playerId == playerID then
			return true
		end
	end

	return false
end

--申请列表过滤好友，（客户端暂做处理）
function FriendManager:removeApplyInFriendList( ... )
	local  function canRemove ( friendApply )
		local playerID = friendApply.playerId
		if  playerID and self:isInFriendList(playerID) then
			return true
		end
		return false
	end
	table.removeAll(localVars.friendApplyList,canRemove)
end

function FriendManager:getFriendByID(friendID)
	for i = 1, #localVars.friendInfoList do
		if localVars.friendInfoList[i].info.playerId == friendID then
			return localVars.friendInfoList[i]
		end
	end

	return nil
end

function FriendManager:getFriendInfoByID(friendID)
	for i = 1, #localVars.friendInfoList do
		if localVars.friendInfoList[i].info.playerId == friendID then
			return localVars.friendInfoList[i].info
		end
	end

	return nil
end

function FriendManager:setSelectedPageIndex(index)
	localVars.selectedPageIndex = index
end

function FriendManager:isShowRedPoint()
	localVars.isShowRedPoint = false

	for k,v in pairs(localVars.friendInfoList) do
		if v.receive == 1 then
			localVars.isShowRedPoint = true
			break
		end
	end

	if #localVars.friendApplyList > 0 then
		localVars.isShowRedPoint = true
	end

	return localVars.isShowRedPoint
end


function FriendManager:isShowNewFriendRedPoint()

	localVars.showNewFriendRedPoint = false
	for k,v in pairs(localVars.friendInfoList) do
		if v.receive == 1 then
			localVars.showNewFriendRedPoint = true
			break
		end
	end
	return localVars.showNewFriendRedPoint

end

function FriendManager:isShowNewApplyRedPoint()

	localVars.showNewApplyRedPoint = false
	if #localVars.friendApplyList > 0 then
		localVars.showNewApplyRedPoint = true
	end

	return localVars.showNewApplyRedPoint --and localVars.selectedPageIndex ~= localVars.pageIndex.applicationList
end

function FriendManager:getNewFriendName()
	local str = "1111111"
	local nameContent = {}
	for k,v in pairs(localVars.friendInfoList) do
		if v.receive == 1 then
			nameContent[#nameContent + 1] = v.info.name
		end
	end

	if #nameContent > 0 then
		local idx = math.floor(math.random(1,#nameContent))
		local friendData = nameContent[idx]
		str = nameContent[idx]
	end
	return str
end

function FriendManager:getNewApplyName()
	local str = ""
	if #localVars.friendApplyList > 0 then
		local friend_index = math.floor(math.random(1,#localVars.friendApplyList))
		local friendData = localVars.friendApplyList[friend_index]
		str = friendData.name
	end
	return str
end

function FriendManager:formatTimeToString(passTime)
	local str

	passTime = passTime / 60
    if passTime < 60 then
    	if passTime < 1 then
    		passTime = 1
    	end

        -- str = "最近登录：" .. math.floor(passTime) .. "分钟前"
        str = stringUtils.format(localizable.FriendManager_login_time_min, math.floor(passTime))

    else
        passTime = passTime / 60
        if passTime < 24 then
            -- str = "最近登录：" .. math.floor(passTime) .. "小时前"

	        str = stringUtils.format(localizable.FriendManager_login_time_hour, math.floor(passTime))

        else
            passTime = passTime / 24

            if passTime < 7 then
                -- str = "最近登录：" .. math.floor(passTime) .. "天前"
		        str = stringUtils.format(localizable.FriendManager_login_time_day, math.floor(passTime))

            else
                passTime = passTime / 7
                if passTime < 2 then
                    -- str = "最近登录：1周前"
		        	str = stringUtils.format(localizable.FriendManager_login_time_week, 1)
                else
                    -- str = "最近登录：2周前"
		        	str = stringUtils.format(localizable.FriendManager_login_time_week, 2)
                end
            end
        end
    end


    return str
end

function FriendManager:formatTimeToStringWithOut(passTime)
	local str

	passTime = passTime / 60
    if passTime < 60 then
    	if passTime < 1 then
    		passTime = 1
    	end

        -- str = "最近登录：" .. math.floor(passTime) .. "分钟前"
        str = stringUtils.format(localizable.FriendManager_login_time_min_ex, math.floor(passTime))

    else
        passTime = passTime / 60
        if passTime < 24 then
            -- str = "最近登录：" .. math.floor(passTime) .. "小时前"

	        str = stringUtils.format(localizable.FriendManager_login_time_hour_ex, math.floor(passTime))

        else
            passTime = passTime / 24

            if passTime < 7 then
                -- str = "最近登录：" .. math.floor(passTime) .. "天前"
		        str = stringUtils.format(localizable.FriendManager_login_time_day_ex, math.floor(passTime))

            else
                passTime = passTime / 7
                if passTime < 2 then
                    -- str = "最近登录：1周前"
		        	str = stringUtils.format(localizable.FriendManager_login_time_week_ex, 1)
                else
                    -- str = "最近登录：2周前"
		        	str = stringUtils.format(localizable.FriendManager_login_time_week_ex, 2)
                end
            end
        end
    end


    return str
end

function FriendManager:moveFriendInfoToFront(id)
	local length = #localVars.friendInfoList
    local tmp = {}
    for i = 1, length do
        if localVars.friendInfoList[i].info.playerId == id then
            table.insert(tmp, localVars.friendInfoList[i])
            break
        end
    end
    for i = 1, length do
        if localVars.friendInfoList[i].info.playerId ~= id then
            table.insert(tmp, localVars.friendInfoList[i])
        end
    end

    localVars.friendInfoList = tmp
end

return FriendManager:new()