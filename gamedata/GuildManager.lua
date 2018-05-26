-- 公会管理类
-- Author: Jin
-- Date: 2016-08-02
--

local GuildManager = class("GuildManager", BaseManager)

local CardEquipment = require("lua.gamedata.base.CardEquipment")

-- 物品结构:{
-- type=1, 类型
-- 	id=2, 实例id
-- 	tplId=3, 模板id
-- 	num=4, 数量
-- 	template={}, 模板数据
--  cardEquip = {}, 装备数据
-- }

GuildManager.UPDATE_GUILD_LIST 			= "GuildManager.UPDATE_GUILD_LIST"
GuildManager.UPDATE_GUILD_INFO 			= "GuildManager.UPDATE_GUILD_INFO"
GuildManager.UPDATE_RANK_LIST 			= "GuildManager.UPDATE_RANK_LIST"
GuildManager.UPDATE_MEMBER_LIST 		= "GuildManager.UPDATE_MEMBER_LIST"
GuildManager.UPDATE_APPLY_LIST 			= "GuildManager.UPDATE_APPLY_LIST"
GuildManager.UPDATE_CREATE_SUCCESS 		= "GuildManager.UPDATE_CREATE_SUCCESS"
GuildManager.UPDATE_EVENT_LIST 	 		= "GuildManager.UPDATE_EVENT_LIST"

GuildManager.UPDATE_JOIN_GUILD 	 		= "GuildManager.UPDATE_JOIN_GUILD"
GuildManager.UPDATE_EXIT_GUILD 	 		= "GuildManager.UPDATE_EXIT_GUILD"

GuildManager.UPDATE_GUILD_RED_POINT		= "GuildManager.UPDATE_GUILD_RED_POINT"

GuildManager.JoinLayer 					= "JoinLayer"
GuildManager.RankLayer 					= "RankLayer"
GuildManager.MainSence 					= "mainSence"
GuildManager.TaskLayer                  = 'TaskLayer'
GuildManager.DonationLayer              = 'DonationLayer'

function GuildManager:ctor()
	self.super.ctor(self)
end

function GuildManager:init()
	self.super.init(self)

	self:restart()

	TFDirector:addProto(s2c.CREATE_GUILD_RES, self, self.onReceiveCreateGuildRes)
	TFDirector:addProto(s2c.GUILD_INFO_RES, self, self.onReceiveGuildInfoRes)
	TFDirector:addProto(s2c.GUILD_LIST_RES, self, self.onReceiveGuildListRes)
	TFDirector:addProto(s2c.GUILD_MEMBER_LIST_RES, self, self.onReceiveGuildMemberListRes)
	TFDirector:addProto(s2c.APPLY_LIST_RES, self, self.onReceiveApplyListRes)
	TFDirector:addProto(s2c.GUILD_RANK_RES, self, self.onReceiveRankListRes)
	TFDirector:addProto(s2c.EXIT_GUILD_RES, self, self.onReceiveExitGuildRes)
	TFDirector:addProto(s2c.APPLY_GUILD_RES, self, self.onReceiveApplyGuildRes)
	TFDirector:addProto(s2c.GUILD_EVENT_LIST_RES, self, self.onReceiveEventListRes)
	TFDirector:addProto(s2c.KICK_MEMBER_RES, self, self.onReceiveKickMemberRes)
	TFDirector:addProto(s2c.MODIFY_DUTY_RES, self, self.onReceiveModifyDutyRes)
	TFDirector:addProto(s2c.GUILD_SETTING_RES, self, self.onReceiveGuildSetRes)
	TFDirector:addProto(s2c.AGREE_APPLY_RES, self, self.onReceiveAgreeApplyRes)
	TFDirector:addProto(s2c.GUILD_OPERATE_NOTICE, self, self.onReceiveOperateNotice)
	TFDirector:addProto(s2c.KICK_LEADER_RES, self, self.onReceiveKickLeaderRes)
	TFDirector:addProto(s2c.BUILD_LEVELUP_RES, self, self.onReceiveBuildLevelUpRes)
	TFDirector:addProto(s2c.GUILD_SIGN_INFO_RES, self, self.onReceiveGuildSignInfoRes)
	TFDirector:addProto(s2c.GUILD_SIGN_RES, self, self.onGuildSignRes)
	TFDirector:addProto(s2c.GUILD_SIGN_REWARD_RES, self, self.onReceiveGuildSignRewardRes)
	TFDirector:addProto(s2c.GUILD_CHANGE_NAME, self, self.onReceiveGuildChangeName)

	TFDirector:addProto(s2c.GUILD_UPDATE, self, self.onReceiveGuildRedUpdate)
end

function GuildManager:restart()
	self.guildAllInfo = {}
	self.jumpLayerFlag = {}
	self.guildListReqInfo = {}

	self.guildRedPoints = {}

	self.autoOpenLayer = {}

	self.appleList = nil
	self.guildMemberList = nil
end

function GuildManager:sendGuildLevelUpReq(buildType)
	self:sendWithLoading(c2s.BUILD_LEVELUP_REQ, buildType)
end

function GuildManager:sendApplyListReq(index, name)
	self:send(c2s.APPLY_LIST_REQ, true)
end

function GuildManager:sendMemberListReq(index, name)
	self:send(c2s.GUILD_MEMBER_LIST_REQ, true)
end

function GuildManager:sendGuildListReq(index, name)
	self.guildListReqInfo.index = index
	self.guildListReqInfo.name = name
	self:send(c2s.GUILD_LIST_REQ, index or 0, name or "", "")
end

function GuildManager:sendGuildInfoReq()
	self:send(c2s.GUILD_INFO_REQ, "")
end

function GuildManager:sendKickLeaderReq()
	self:send(c2s.KICK_LEADER_REQ, "")
end

function GuildManager:sendApplyGuildReq( guildId, joinNow )
	self:sendWithLoading(c2s.APPLY_GUILD_REQ, guildId, joinNow, "")
end

function GuildManager:sendExitGuildReq( )
	self:sendWithLoading(c2s.EXIT_GUILD_REQ, "")
end

function GuildManager:sendCreateGuildReq(guildName, guildIcon)
	self:sendWithLoading(c2s.CREATE_GUILD_REQ, guildName, guildIcon)
end

function GuildManager:sendGuildEventListReq(date)
	self:sendWithLoading(c2s.GUILD_EVENT_LIST_REQ, date)
end

function GuildManager:sendAgreeApplyReq(agree, all, playerId)
	self:sendWithLoading(c2s.AGREE_APPLY_REQ, agree, all, playerId)
end

function GuildManager:sendSignInfoReq( )
	self:sendWithLoading(c2s.GUILD_SIGN_INFO_REQ, "")
end

function GuildManager:guildSign(index)
	self:sendWithLoading(c2s.GUILD_SIGN_REQ, index)
end

function GuildManager:receiveSignReward(index)
	self:sendWithLoading(c2s.GUILD_SIGN_REWARD_REQ, index)
end

function GuildManager:sendGuildSetReq(joinPower, joinNow, noJoin, inComment, outComment, flag)
	self.setInfo = {
		joinPower = joinPower,
		joinNow = joinNow,
		noJoin = noJoin,
		inComment = inComment,
		outComment = outComment,
		flag = flag
	}
	self:sendWithLoading(c2s.GUILD_SETTING_REQ, joinPower, joinNow, noJoin, inComment, outComment, flag)
end

function GuildManager:sendGuildRankReq(index)
	self:sendWithLoading(c2s.GUILD_RANK_REQ, index or 0)
	self.jumpLayerFlag[GuildManager.RankLayer] = true
end

function GuildManager:sendKickMemberReq( playerId )
	self:sendWithLoading(c2s.KICK_MEMBER_REQ, playerId)
end

function GuildManager:sendModifyDutyReq( playerId, duty )
	self:sendWithLoading(c2s.MODIFY_DUTY_REQ, playerId, duty)
end

function GuildManager:sendGuildChangeName( name )
	self:sendWithLoading(c2s.GUILD_CHANGE_NAME, name)
end

function GuildManager:openGuildLayer()
	if not self:hasGuild() then
		self.jumpLayerFlag[GuildManager.JoinLayer] = true		
		self:sendGuildListReq()
	else
		self:enterGuildSence()
	end
end

function GuildManager:hasGuild()
	return self.guildAllInfo.guildInfo ~= nil
end

function GuildManager:getGuildId()
	if not self:hasGuild() then
		return nil
	end
	return self.guildAllInfo.guildInfo.id
end

function GuildManager:updateGuildName( name )
	if not self:hasGuild() or name == nil then
		return nil
	end
	self.guildAllInfo.guildInfo.name = name
end

function GuildManager:getGuildName()
	if not self:hasGuild() then
		return nil
	end
	return self.guildAllInfo.guildInfo.name
end

function GuildManager:getGuildLevel()
	if not self:hasGuild() then
		return nil
	end
	return self.guildAllInfo.guildInfo.level
end

function GuildManager:getGuildDuty( ... )
	if not self:hasGuild() then
		return nil
	end
	return self.guildAllInfo.guildInfo.duty
end

function GuildManager:checkInMyGuildByName(guildName)
	local name = self:getGuildName()
	if name and (name == guildName) then
		return true
	end
	return false
end

function GuildManager:enterGuildSence( )
	self.jumpLayerFlag[GuildManager.MainSence] = true
	self:sendGuildInfoReq()
end

function GuildManager:exitGuildSence( )
	-- AlertManager:changeScene(SceneType.HOME,nil)
	if self.lastSceneName ~= nil then
		local sceneId = GetSceneIdBySceneName(self.lastSceneName)
		self.lastSceneName = nil
		CommonManager:requestEnterInScene(sceneId)
	end

	-- TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_EXIT_GUILD, 0)
end

function GuildManager:openGuildSence( )
	local currentScene = Public:currentScene()
	self.lastSceneName = currentScene.__cname
	local sync = true
	if sync then --同步帮会场景中的帮会成员
		self:syncOpenGuildSence()
		return
	end
	AlertManager:changeScene(SceneType.GUILD)
	-- self:openGuildMainLayer()
	-- AlertManager:changeScene(SceneType.Guild) --nil,TFSceneChangeType_PopBack
	-- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildSceneLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	-- AlertManager:show()
	-- self:sendSignInfoReq()
end

--进入帮会场景
function GuildManager:syncOpenGuildSence()
	CommonManager:requestEnterInScene(EnumSceneType.Guild)
end

function GuildManager:openGuildMainLayer( )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildMainLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildJoinLayer( )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildJoinLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildCreateLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildCreateLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildRankLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildRankLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildEventLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildEventLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildAppointmentLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildAppointmentLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildImpeachLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildImpeachLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildSkillLayer()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildSkillLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:openGuildDonationLayer(data)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildDonationLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	layer:setData(data)
	AlertManager:show()
end

function GuildManager:openGuildOperationLayer(pos)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildOperationLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:loadData(pos)
	AlertManager:show()
end

function GuildManager:openBoxChooseLayer(boxInfo)
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bloodywar.BloodyWarChooseLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setData(boxInfo)
	AlertManager:show()
end

function GuildManager:openGuildMailLayer( playerId )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildMailLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setData(playerId)
	AlertManager:show()
end

function GuildManager:openGuildChangeNameLayer( ... )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.guild.GuildChangeNameLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
	AlertManager:show()
end

function GuildManager:onReceiveCreateGuildRes( event )
	hideLoading()
	AlertManager:closeLayerByName("lua.logic.guild.GuildCreateLayer")
	AlertManager:closeLayerByName("lua.logic.guild.GuildJoinLayer")

	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_JOIN_GUILD, 0)
	self:enterGuildSence()
end

function GuildManager:onReceiveExitGuildRes( event )
	hideLoading()

	self:restart()
	self:exitGuildSence()
end

function GuildManager:onReceiveApplyGuildRes( event )
	hideLoading()
	if event.data.result then
		AlertManager:closeLayerByName("lua.logic.guild.GuildJoinLayer")

		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_JOIN_GUILD, 0)
		self:enterGuildSence()
	else
		self:sendGuildListReq(self.guildListReqInfo.index, self.guildListReqInfo.name)
	end
end

function GuildManager:onReceiveKickMemberRes( event )
	hideLoading()
	if event.data.result then
		AlertManager:closeLayerByName("lua.logic.guild.GuildOperationLayer")
		self:sendMemberListReq()
		self:sendGuildInfoReq()
	end
end

function GuildManager:onReceiveModifyDutyRes( event )
	hideLoading()
	if event.data.result then
		AlertManager:closeLayerByName("lua.logic.guild.GuildAppointmentLayer")
		AlertManager:closeLayerByName("lua.logic.guild.GuildOperationLayer")
		self:sendMemberListReq()
		self:sendGuildInfoReq()
	end
end

function GuildManager:onReceiveAgreeApplyRes( event )
	hideLoading()
	if event.data.result then
		self.guildMemberList = nil
		self:sendApplyListReq()
		self:sendGuildInfoReq()
	end
end

function GuildManager:onReceiveKickLeaderRes( event )
	hideLoading()
	if event.data.result then
		AlertManager:closeLayerByName("lua.logic.guild.GuildImpeachLayer")
		AlertManager:closeLayerByName("lua.logic.guild.GuildOperationLayer")
		self:sendMemberListReq()
		self:sendGuildInfoReq()
	else
		AlertManager:closeLayerByName("lua.logic.guild.GuildImpeachLayer")
		AlertManager:closeLayerByName("lua.logic.guild.GuildOperationLayer")
		self:sendMemberListReq()
	end
end

function GuildManager:onReceiveBuildLevelUpRes( event )
	hideLoading()

	if self.guildAllInfo.buildInfo then
		for i,v in ipairs(self.guildAllInfo.buildInfo) do
			if v.buildType == event.data.buildInfo.buildType then
				self.guildAllInfo.buildInfo[i] = event.data.buildInfo
			end
		end
	end
	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
end

function GuildManager:onReceiveGuildSignInfoRes( event )
	hideLoading()

	local layer = AlertManager:getLayerByName("lua.logic.guild.GuildDonationLayer")
	if layer then
		layer:setData(event.data)
		layer:refreshUI()
	else
		self:openGuildDonationLayer(event.data)
	end
end

function GuildManager:onGuildSignRes(event)
	self:updateContributionValue(event.data.contribution)
	self:updateAssetValue(event.data.guildMoney)
	hideLoading()
	if event.data.result then
		--成功
		self:sendSignInfoReq()
	end
end

function GuildManager:onReceiveGuildSignRewardRes(event)
	hideLoading()
	if event.data.result then
		self:sendSignInfoReq()
	end
end

function GuildManager:onReceiveGuildChangeName( event )
	hideLoading()
	local data = event.data
	print('GuildManager:onReceiveGuildChangeName:',data)
	self:updateGuildName(data.changeName)
	if self:getGuildDuty() == GuildManager.Leader then  
		toastMessage(localizable.guild_name_sucess) 
	end
	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
end

function GuildManager:checkBit(value, b)
	for i = 2, b do
		value = math.floor(value / 2)
	end

	return value %2 == 1
end


function GuildManager:onReceiveGuildSetRes( event )
	hideLoading()
	if event.data.result then
		toastMessage(localizable.guild_set_success)
		if self.setInfo and self.guildAllInfo.guildInfo ~= nil then
			if self:checkBit(self.setInfo.flag, 1) then
				self.guildAllInfo.guildInfo.joinPower = self.setInfo.joinPower
			end
			if self:checkBit(self.setInfo.flag, 2)  then
				self.guildAllInfo.guildInfo.joinNow = self.setInfo.joinNow
			end
			if self:checkBit(self.setInfo.flag, 3)  then
				self.guildAllInfo.guildInfo.noJoin = self.setInfo.noJoin
			end
			if self:checkBit(self.setInfo.flag, 4)  then
				self.guildAllInfo.guildInfo.inComment = self.setInfo.inComment 
			end
			if self:checkBit(self.setInfo.flag, 5)  then
				self.guildAllInfo.guildInfo.outComment = self.setInfo.outComment or self.guildAllInfo.guildInfo.outComment
			end

			TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
		end
	end
end

function GuildManager:onReceiveGuildInfoRes(event)
	print('GuildManager:onReceiveGuildInfoRes:',event.data)
	self.guildAllInfo = event.data

	if self.guildAllInfo.buildInfo then
		local len = #self.guildAllInfo.buildInfo
		for i = len,1,-1 do
			local info = self.guildAllInfo.buildInfo[i]
			local upgradeInfo = GuildUpGrade:getObjectByTypeAndLevel(info.buildType, info.level)
			if not upgradeInfo then
				table.remove(self.guildAllInfo.buildInfo, i)
			end
		end
	end
	
	if self.jumpLayerFlag[GuildManager.MainSence] then
		self.jumpLayerFlag[GuildManager.MainSence] = false

		self:openGuildSence()
	else
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
	end
end

function GuildManager:onReceiveGuildListRes(event)
	self.guildInfoList = event.data.guildInfo or {}
	if self.jumpLayerFlag[GuildManager.JoinLayer] then
		self.jumpLayerFlag[GuildManager.JoinLayer] = false
		self:openGuildJoinLayer()	
	else
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_LIST, 0)
	end
end

function GuildManager:onReceiveGuildMemberListRes(event)
	self.guildMemberList = event.data.members or {}

	table.sort( self.guildMemberList, function ( t1, t2 ) 
		if t1.logoutTime == 0 and t2.logoutTime ~= 0 then
			return true
		elseif t1.logoutTime ~= 0 and t2.logoutTime == 0 then
			return false
		end
		if t1.duty > t2.duty then
			return true
		elseif t1.duty < t2.duty then
			return false
		end

		return t1.logoutTime > t2.logoutTime
	end)

	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_MEMBER_LIST, 0)
end

function GuildManager:onReceiveApplyListRes(event)
	hideLoading()
	self.appleList = event.data.applyList or {}

	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_APPLY_LIST, 0)
end

function GuildManager:onReceiveRankListRes(event)
	hideLoading()
	self.rankListInfo = event.data or {}
	if self.jumpLayerFlag[GuildManager.RankLayer] then
		self.jumpLayerFlag[GuildManager.RankLayer] = false
		self:openGuildRankLayer()	
	else
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_RANK_LIST, 0)
	end
end

function GuildManager:updateContributionValue(contribution)
	self.guildAllInfo.guildInfo.contribution = contribution
	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
	TFDirector:dispatchGlobalEventWith(RecoverableResManager.RecoverableResChange , 0)
end

function GuildManager:updateAssetValue(asset)
	self.guildAllInfo.guildInfo.money = asset
	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_INFO, 0)
	TFDirector:dispatchGlobalEventWith(RecoverableResManager.RecoverableResChange , 0)
end

function GuildManager:setCurMemberInfo( memberInfo )
	self.curMemberInfo = memberInfo
end

function GuildManager:getCurMemberInfo( memberInfo )
	return self.curMemberInfo or {}
end

function GuildManager:getMyRankInfo( ... )
	return self.rankListInfo.myGuildInfo
end

function GuildManager:getRankListInfo( ... )
	return self.rankListInfo.guildListInfo
end

function GuildManager:getGuildInfoList()
	return self.guildInfoList or {}
end

function GuildManager:getGuildInfo()
	return self.guildAllInfo.guildInfo or {}
end

function GuildManager:getBuildInfo()
	return self.guildAllInfo.buildInfo or {}
end

function GuildManager:getGuildMemberList( ... )
	return self.guildMemberList
end

function GuildManager:getApplyList( ... )
	return self.appleList
end

function GuildManager:getGuildSkillList()
	local guildSkill1 = {}
	guildSkill1.name = localizable.guild_skill_name_1
	guildSkill1.effect = localizable.guild_skill_effect_1
	guildSkill1.level = localizable.guild_skill_level_1

	local guildSkill2 = {}
	guildSkill2.name = localizable.guild_skill_name_2
	guildSkill2.effect = localizable.guild_skill_effect_2
	guildSkill2.level = localizable.guild_skill_level_2

	local guildSkill3 = {}
	guildSkill3.name = localizable.guild_skill_name_3
	guildSkill3.effect = localizable.guild_skill_effect_3
	guildSkill3.level = localizable.guild_skill_level_3

	local guildSkill4 = {}
	guildSkill4.name = localizable.guild_skill_name_4
	guildSkill4.effect = localizable.guild_skill_effect_4
	guildSkill4.level = localizable.guild_skill_level_4

	local guildSkill5 = {}
	guildSkill5.name = localizable.guild_skill_name_5
	guildSkill5.effect = localizable.guild_skill_effect_5
	guildSkill5.level = localizable.guild_skill_level_5

	local guildSkillList = {}
	guildSkillList[#guildSkillList + 1] = guildSkill1
	guildSkillList[#guildSkillList + 1] = guildSkill2
	guildSkillList[#guildSkillList + 1] = guildSkill3
	guildSkillList[#guildSkillList + 1] = guildSkill4
	guildSkillList[#guildSkillList + 1] = guildSkill5

	return guildSkillList
end

function GuildManager:onReceiveEventListRes( event )
	hideLoading()

	self.curEvents = event.data.guildEvent

	TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_EVENT_LIST, 0)
end

function GuildManager:onReceiveOperateNotice( event )
	local data = event.data
	if data.noticeType == EnumGuildNoticeType.Kick then
		self:restart()
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_EXIT_GUILD, 0)
		self:exitGuildSence()
	elseif data.noticeType == EnumGuildNoticeType.Duty then
		-- if self.
		self:sendMemberListReq()
		self:sendGuildInfoReq()
	elseif data.noticeType == EnumGuildNoticeType.Apply then
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_JOIN_GUILD, 0)
		self:sendMemberListReq()
		self:sendGuildInfoReq()
	end
end

function GuildManager:getEventList( )
	return self.curEvents or {}
end

function GuildManager:getShowGuildId( guildName )
	return string.sub(guildName, -6, -1)
end

function GuildManager:getGuildContribution(  )
	if self.guildAllInfo.guildInfo then
		return self.guildAllInfo.guildInfo.contribution
	end
	return 0
end

function GuildManager:openPayLayer()
	if true then
		toastMessage(localizable.common_yet_open)
		return
	end
end

function GuildManager:getDutyName( duty )
	return localizable.guild_duty_name[duty] or ""
end

GuildManager.Permissions = {
	Limit 		= "setLimit", 
	Apply 		= "apply", 
	Appointment = "appointment", 
	Build 		= "build", 
	RedBag 		= "redBag", 
	Activity 	= "activity", 
	Icon 		= "setIcon", 
	OutComment 	= "setOutComment", 
	InComment 	= "setInComment",
	Kick 		= "kick",
	Impeach 	= "Impeach"
}

GuildManager.DutyPermission = {
	{GuildManager.Permissions.Impeach},											--成员
	{GuildManager.Permissions.Apply, GuildManager.Permissions.Impeach},			--长老
	{ 											--副会长
		GuildManager.Permissions.Limit, 
		GuildManager.Permissions.Apply, 
		GuildManager.Permissions.Appointment, 
		GuildManager.Permissions.Build,
		GuildManager.Permissions.RedBag, 
		GuildManager.Permissions.Activity, 
		GuildManager.Permissions.OutComment, 
		GuildManager.Permissions.InComment,
		GuildManager.Permissions.Kick,
		GuildManager.Permissions.Impeach
	},
	{ 											--副会长
		GuildManager.Permissions.Limit, 
		GuildManager.Permissions.Apply, 
		GuildManager.Permissions.Appointment, 
		GuildManager.Permissions.Build,
		GuildManager.Permissions.RedBag, 
		GuildManager.Permissions.Activity, 
		GuildManager.Permissions.Icon,
		GuildManager.Permissions.OutComment, 
		GuildManager.Permissions.InComment,
		GuildManager.Permissions.Kick
	}
}

GuildManager.Member = 1
GuildManager.Elders = 2
GuildManager.ViceLeader = 3
GuildManager.Leader = 4

GuildManager.EldersNumLimit = 5
GuildManager.ViceLeaderLimit = 2
function GuildManager:getMineDuty()
	if self.guildAllInfo.guildInfo then
		return self.guildAllInfo.guildInfo.duty
	end
	return 1
end

function GuildManager:getMineDutyPermission(permission, otherDuty)
	if not self:hasGuild() then
		return false
	end
	return self:getDutyPermission(self.guildAllInfo.guildInfo.duty, permission, otherDuty)
end

function GuildManager:getDutyPermission(duty, permission, otherDuty)
	otherDuty = otherDuty or 0
	local permissions = GuildManager.DutyPermission[duty] or {}
	for i,v in ipairs(permissions) do
		if v == permission then
			if permission == GuildManager.Permissions.Appointment then
				if duty == GuildManager.Leader then
					return true
				elseif duty > otherDuty then
					return true
				else 
					return false
				end
			elseif permission == GuildManager.Permissions.Impeach then
				if otherDuty == GuildManager.Leader then
					return true
				else
					return false
				end
			elseif permission == GuildManager.Permissions.Kick then
				if duty > otherDuty then
					return true
				else
					return false
				end
			end
			return true
		end
	end
	return false
end

function GuildManager:getShopBuildingLevel( )
	self.buildList = self:getBuildInfo()
	local shop_level = 0
	for _, build_info in pairs(self.buildList) do
		if build_info.buildType == 4 then
			shop_level = build_info.level
			break
		end
	end
	return shop_level
end

function GuildManager:getSignBuildingLevel()
	self.buildList = self:getBuildInfo()
	local sign_level = 1
	for _, build_info in pairs(self.buildList) do
		if build_info.buildType == 3 then
			sign_level = build_info.level
			break
		end
	end
	return sign_level
end

function GuildManager:checkGuildStore( )
	if not self:hasGuild() then
		return false, localizable.guild_not_join_guild
	elseif self:getShopBuildingLevel() == 0 then
		return false, localizable.guild_shop_level_not_enough
	else
		return true
	end
end

function GuildManager:openStoreLayer( )
	local open,str = self:checkGuildStore()
	if not open then
		toastMessage(str)
	else
		ShopManager:showShopLayer(EnumShopType.FactionShop, 1)
	end
end

function GuildManager:openOneGuildLayer( openFunc )
	if openFunc ~= nil then
		openFunc(self)
	else
		toastMessage(localizable.commom_no_open)
	end
end

function GuildManager:onReceiveGuildRedUpdate( event )
	local data = event.data
	if data then
		if data.isApply ~= nil then self.guildRedPoints['apply'] = data.isApply end
		if data.isSign ~= nil then self.guildRedPoints['sign'] = data.isSign end
		if data.isTask ~= nil then self.guildRedPoints['task'] = data.isTask end
		if data.isWar ~= nil then self.guildRedPoints['war'] = data.isWar end
		if self.guildRedPoints['apply'] then
			self.guildRedPoints['apply'] = self:getMineDutyPermission(GuildManager.Permissions.Apply)
		end
		
		TFDirector:dispatchGlobalEventWith('refresh_yunyin_red', 0)
		TFDirector:dispatchGlobalEventWith(GuildManager.UPDATE_GUILD_RED_POINT, 0)
	end
end

--自己是否有权限发送邮件
function GuildManager:canSendGuildMail( ... )
	local guildInfo = self.guildAllInfo.guildInfo or {}
	local duty = guildInfo.duty or GuildManager.Member
	local limit = ConstantData:getValue('Guild.Mail.Single.Position') or GuildManager.Leader
	if duty >= limit then
		return true
	else
		return false
	end
end
--自己能否有权限发送群发邮件
function GuildManager:canSendGuildGroupMail( ... )
	local guildInfo = self.guildAllInfo.guildInfo or {}
	local duty = guildInfo.duty or GuildManager.Member
	local limit = ConstantData:getValue('Guild.Mail.Multiple.Position') or GuildManager.Leader
	if duty >= limit then
		return true
	else
		return false
	end
end

---------------------帮会红点------------------
function GuildManager:isHaveRedPoint()
	if self:isHaveGuildMainRedPoint() then return true end
	
	if GuildDungeonManager:isHaveRedPoint() then
		return true
	end

	if self:isHaveGuildTaskRedPoint() then return true end
	
	return false
end 

function GuildManager:isHaveGuildMainRedPoint()
	if self:isHaveApplyRedPoint() then return true end
	return false
end

function GuildManager:isHaveGuildWarRedPoint( ... )
	return self.guildRedPoints['war']
end

function GuildManager:isHaveGuildTaskRedPoint( ... )
	return self.guildRedPoints['task'] or GuildTaskManager:completeTaskRedPoint(...)
end

function GuildManager:isHaveApplyRedPoint()
	return self.guildRedPoints['apply']
end

return GuildManager:new()