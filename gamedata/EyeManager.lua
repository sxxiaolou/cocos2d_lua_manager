-- 背包管理类
-- Author: Tony
-- Date: 2017-09-12
--

local EyeManager = class("EyeManager", BaseManager)

-- message EyeInfo{
-- 	required bool open = 1;						//开启true 关闭false
-- 	required int32 rescueTime=2;				//剩余时间
-- }

-- //鬼蛙信息
-- message EyeFrogInfo{
-- 	required string id = 1;						//鬼蛙实例id
-- 	required int32 frogId = 2;					//鬼蛙模板id
-- 	required int32 pos = 3;						//位置
-- 	required int32 chapterId=4;					//章节id
-- 	required int32 frogLevel=5;					//
-- 	required int32 frogHP=6;					//血量
-- 	required int64 attackTime=7;				//首次攻击时间

--  template = {}  			--模版信息
-- }

EyeManager.EYE_CHANGE      				= "EyeManager.EYE_CHANGE"
EyeManager.UPDATE_FROG      			= "EyeManager.UPDATE_FROG"
EyeManager.UPDATE_BOX 					= "EyeManager.UPDATE_BOX"

function EyeManager:ctor()
	self.super.ctor(self)
end

function EyeManager:init()
	self.super.init(self)

	self.eyeInfo = {}
	self.frogList = {}

	TFDirector:addProto(s2c.EYE_INFO, self, self.eyeInfoResult)
	TFDirector:addProto(s2c.EYE_BOX_INFO, self, self.eyeBoxInfoResult)
	TFDirector:addProto(s2c.EYE_FROG_INFO, self, self.eyeFrogInfoResult)
	TFDirector:addProto(s2c.EYE_FROG_LIST, self, self.eyeFrogListResult)
end

function EyeManager:restart()
	self.boxIndexs = {}
	self.frogList = {}
end

function EyeManager:eyeInfoResult(event)
	hideLoading()

	local data = event.data
	self.eyeInfo = data

	-- print("######### eyeInfo result ", data)
	TFDirector:dispatchGlobalEventWith("continueClick")
	TFDirector:dispatchGlobalEventWith(EyeManager.EYE_CHANGE, nil)
end

function EyeManager:eyeBoxInfoResult(event)
	hideLoading()

	self.boxIndexs = nil
	local data = event.data
	self.boxIndexs = data.boxId or {}

	-- print("------------ eye Box INfo result ", data)
	TFDirector:dispatchGlobalEventWith(EyeManager.UPDATE_BOX, nil)
end

function EyeManager:eyeFrogInfoResult(event)
	hideLoading()

	local data = event.data
	-- print("++++++++++++++++++++++++ frpg Omfp ", data)
	self:addFrog(data)
end

function EyeManager:eyeFrogListResult(event)
	hideLoading()

	local data = event.data
	local frogList = data.frogList or {}
	-- print("################## frog List ", frogList)
	for k,v in pairs(frogList) do
		self:addFrog(v)
	end
end

-------------------------------- send proto ---------------------------------

function EyeManager:sendOpenEye(open)
	if open then
		StatisticsManager:layerJump( FunctionManager.MenuEye )
	end
	self:send(c2s.OPEN_EYE, open)
end

function EyeManager:sendGetEyeBox(id)
	self:sendWithLoading(c2s.GET_EYE_BOX, id)
end

function EyeManager:sendAttackFrog(id, crit)
	self:sendWithLoading(c2s.ATTACK_FROG, id, crit)
end

-----------------------------------------------------------------------------

function EyeManager:addFrog(data)
	if not data or not data.id or not data.frogId or not data.chapterId then return end

	local frog = self.frogList[data.id]
	if frog then
		frog.pos = data.pos
		frog.chapterId = data.chapterId
		frog.frogHP = data.frogHP
		frog.attackTime = math.floor(data.attackTime/1000)
		frog.createTime = math.floor(data.createTime/1000)
	else
		data.template = EyeFrogData:objectByID(data.frogId)
		data.attackTime = math.floor(data.attackTime/1000)
		data.createTime = math.floor(data.createTime/1000)
		self.frogList[data.id] = data
	end
	-- print("@@@@@@@@@@@@@@@@@@ frog", data)
	TFDirector:dispatchGlobalEventWith(EyeManager.UPDATE_FROG, nil)
end

function EyeManager:getFrog(id)
	return self.frogList[id]
end

function EyeManager:removeFrog(id)
	self.frogList[id] = nil
end

function EyeManager:getChapterIds()
	local tbl = {}
	for k,v in pairs(self.frogList) do
		tbl[v.chapterId] = v.chapterId
	end
	return tbl
end

function EyeManager:getFrogByChapterId(chapterId)
	--暂时去掉      
	-- if not self.frogList then return nil end
	-- for _,v in pairs(self.frogList) do
	-- 	if v.chapterId == chapterId and v.frogHP ~= 0 and
	-- 	(v.attackTime == 0 or (v.attackTime ~= 0 and (MainPlayer:getNowtime()-v.attackTime) < v.template.time)) then
	-- 		return v
	-- 	end
	-- end
	return nil
end

function EyeManager:getFrogRescueTime()
	if not self.frogList then return nil end

	local frog = nil
	local curTime = MainPlayer:getNowtime()
	local time = ConstantData:getValue("frog.disappear.time")
	for k,v in pairs(self.frogList) do
		if curTime - v.createTime < time * 60 and v.frogHP ~= 0 and 
		(v.attackTime == 0 or (v.attackTime ~= 0 and (curTime-v.attackTime) < v.template.time)) then
			if not frog then frog = v end
			if frog.createTime > v.createTime then
				frog = v
			end
		end
	end
	return frog
end

function EyeManager:isOpenEye()
	if self.eyeInfo and self.eyeInfo.open and self.eyeInfo.rescueTime and self.eyeInfo.rescueTime > 0 then
		return true
	end
	return false
end

function EyeManager:getEyeRescueTime()
	if self.eyeInfo then
		return self.eyeInfo.rescueTime or 0
	end
	return 0
end

function EyeManager:reduceRescueTime()
	if self.eyeInfo and self.eyeInfo.rescueTime then
		self.eyeInfo.rescueTime = self.eyeInfo.rescueTime - 1
		if self.eyeInfo.rescueTime <= 0 then
			self.eyeInfo.rescueTime = 0
		end
	else
		self.eyeInfo.rescueTime = 0
	end
	return self.eyeInfo.rescueTime
end

function EyeManager:isHaveEyeBox(idx)
	if not self.boxIndexs then return false end

	for _,v in pairs(self.boxIndexs) do
		if v == idx then
			return true
		end
	end
	return false
end

return EyeManager:new()