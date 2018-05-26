--
-- Author: Stephen
-- Date: 2015-5-13
--

local TFLengthArray = require('lua.public.TFLengthArray')
local GameResourceManager = class("GameResourceManager")

function GameResourceManager:ctor()
	self.m_ourRolelist = {}
	self.m_enemyList = TFLengthArray:new(6)
	self.m_nowLevel = 0

	self.m_npclist = {}
	self.m_removeNpclist = TFLengthArray:new(4)
end

function GameResourceManager:restart()
	self.m_ourRolelist = {}
	self.m_enemyList:clear()
	self.m_nowLevel = 0

	self.m_npclist = {}
	self.m_removeNpclist:clear()
end

function GameResourceManager:addRole( role_id , armature )
	if self.m_ourRolelist[role_id] ~= nil then
		return
	end
	self.m_ourRolelist[role_id] = {}
	self.m_ourRolelist[role_id].m_armature = armature
	armature:retain()
end

function GameResourceManager:addRoleEffect( role_id , effect_id , armature )
	if self.m_ourRolelist[role_id] == nil then
		return
	end
	if self.m_nowLevel > 1 then
		self.m_nowLevel = 1
	end
	local role = self.m_ourRolelist[role_id]
	if role.effect == nil then 
		role.effect = {}
	end
	if role.effect[effect_id] == nil then
		role.effect[effect_id] = armature
		armature:retain()
	end
end

function GameResourceManager:removeRole( role_id )
	local role = self.m_ourRolelist[role_id]
	if role == nil then
		return
	end
	role.m_armature:release()
	if role.effect then
		for k,v in pairs(role.effect) do
			v:release()
		end
	end
	self.m_ourRolelist[role_id] = nil
end



function GameResourceManager:addEnemy( role_id , armature )
	self.m_nowLevel = 0
	local enemy = {}
	enemy.m_id = role_id
	enemy.m_armature = {}
	enemy.m_armature.armature = armature
	if self.m_enemyList:indexByKey("m_id" , enemy) == -1 then
		armature:retain()
	end
	self.m_enemyList:push("m_id" , enemy)
	if self.m_enemyList:length() > self.m_enemyList.m_maxLength then
		local temp = self.m_enemyList:pop()
		print("addEnemy  remove id == ",temp.m_id)
		if temp and temp.m_armature then
			for k,v in pairs(temp.m_armature) do
				v:release();
				v = nil
			end
		end
		temp.m_armature = nil
	end

end

function GameResourceManager:addEnemyEffect( role_id , effect_id , armature )
	for v in self.m_enemyList:iterator() do
		if v.m_id == role_id then
			if v.m_armature[effect_id] == nil then
				v.m_armature[effect_id] = armature
				armature:retain()
			end
			return
		end
	end
end

function GameResourceManager:clearRoleEffect( )
	for _,role in pairs(self.m_ourRolelist) do
		if role and role.effect then
			for __,k in pairs(role.effect) do
				k:release()
			end
			role.effect = nil
		end
	end
end

function GameResourceManager:clearRole( )
	for _,v in pairs(self.m_ourRolelist) do
		if v and v.m_armature then
			v.m_armature:release()
		end
		if v and v.effect then
			for __,k in pairs(v.effect) do
				k:release()
			end
			v.effect = nil
		end
	end
	-- self.m_ourRolelist = nil
	self.m_ourRolelist = {}
end

function GameResourceManager:clearEnemyList()
	while self.m_enemyList:length() > 0  do
		local temp = self.m_enemyList:pop()
		if temp then
			for k,v in pairs(temp.m_armature) do
				v:release();
			end
		end
	end
end

function GameResourceManager:useTime( role_id )
	local num = 0
	for k,v in pairs(self.m_ourRolelist) do
		if k == role_id then
			num = num + 1
		end
	end
	for v in self.m_enemyList:iterator() do
		if v.m_id == role_id then
			num = num + 1
		end
	end
	return num
end

function GameResourceManager:clearAll()
	self:clearEnemyList()
	self:clearRoleEffect()
	me.ArmatureDataManager:removeUnusedArmatureInfo()
	CCDirector:sharedDirector():purgeCachedData()
end

function GameResourceManager:MemoryWarning()
	if self.m_nowLevel == 0 then
		self:clearEnemyList()
		self.m_nowLevel = 1
		return true
	elseif self.m_nowLevel == 1 then
		self:clearRoleEffect()
		self.m_nowLevel = 2
		return true
	else
		return false
		-- self:clearRole()
	end
	return true
end

function GameResourceManager:getRoleAniById( id , scale)
	scale = scale or 1
	local resPath = "skeleton/".. id .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("skeleton/"..id, 1)
	else
		id = 9999
		if IS_SUB_PACKAGE and not MissionManager:findMission(1004001) then
			id = MainPlayer:getSex()
		end
		print(resPath.." not find, default id:", id)
		TFResourceHelper:instance():addSkeletonFromFile("skeleton/"..id, 1)
	end
	local skeleton = TFSkeleton:create("skeleton/" .. id)
	if skeleton == nil then
		assert(false, "skeleton"..id.."create error")
		return nil
	end

	skeleton:setPosition(ccp(0,0))
	skeleton:setTouchEnabled(false)
	skeleton:setScale(scale)
    skeleton:setTimeScale(GameConfig.SPINE_TIMESCALE)
    skeleton:play(0, "stand", 1)
	return skeleton
end

function GameResourceManager:PlaySpineEffectOnce(spineName, name, func,timeScale,scale )
	scale = scale or 1
	timeScale = timeScale or 1.0
	local skeleton = GameResourceManager:getEffectAniById(spineName, scale, 0, name)
	if func ~= nil then
		skeleton:addMEListener(TFSKELETON_COMPLETE, func)
	end
	return skeleton
end

function GameResourceManager:PlaySpineEffectLoop(spineName, name, func,timeScale,scale)
	scale = scale or 1
	timeScale = timeScale or 1.0
	local skeleton = GameResourceManager:getEffectAniById(spineName, scale, 1, name)
	if func ~= nil then
		skeleton:addMEListener(TFSKELETON_COMPLETE, func)
	end
	return skeleton
end

function GameResourceManager:getEffectAniById(effectId, scale, loop, name,timeScale)
	scale = scale or 1
	timeScale = timeScale or 1.0
	name = name or "bofang"
	local resPath = "effect/".. effectId .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("effect/"..effectId, 1)
	else
		print(resPath.."not find")
		return nil
	end
	local skeleton = TFSkeleton:create("effect/" .. effectId)
	if skeleton == nil then
		assert(false, "effect"..effectId.."create error")
		return nil
	end

	if loop ~= nil and (loop == 0 or loop == false) then
		loop = 0
	else
		loop = 1
	end
	skeleton:setPosition(ccp(0,0))
	skeleton:setTouchEnabled(false)
	skeleton:setScale(scale)
    skeleton:setTimeScale(GameConfig.SPINE_TIMESCALE * timeScale)
    skeleton:play(0, name, loop)
	return skeleton
end

function GameResourceManager:getTitleEffectAniById(effectId, scale, loop, name,timeScale)
	scale = scale or 1
	timeScale = timeScale or 1.0
	name = name or "bofang"
	local resPath = "chenghao/".. effectId .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("chenghao/"..effectId, 1)
	else
		print(resPath.."not find")
		return nil
	end
	local skeleton = TFSkeleton:create("chenghao/" .. effectId)
	if skeleton == nil then
		assert(false, "effect"..effectId.."create error")
		return nil
	end

	if loop ~= nil and (loop == 0 or loop == false) then
		loop = 0
	else
		loop = 1
	end
	skeleton:setPosition(ccp(0,0))
	skeleton:setTouchEnabled(false)
	skeleton:setScale(scale)
    skeleton:setTimeScale(GameConfig.SPINE_TIMESCALE * timeScale)
    skeleton:play(0, name, loop)
	return skeleton
end


function GameResourceManager:getRoleSkillEft(eftFile, eftName, scale, loop)
	scale = scale or 1
	local resPath = "effect/".. eftFile .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("effect/"..eftFile, scale)
	else
		print(resPath.."not find")
		return nil
	end
	local skeleton = TFSkeleton:create("effect/" .. eftFile)
	if skeleton == nil then
		assert(false, "effect"..eftFile.."create error")
		return nil
	end

	if loop ~= nil and (loop == 0 or loop == false) then
		loop = 0
	else
		loop = 1
	end
	skeleton:setPosition(ccp(0,0))
	skeleton:setTouchEnabled(false)
    skeleton:setTimeScale(GameConfig.SPINE_TIMESCALE)
    skeleton:play(0, eftName, loop)
	return skeleton
end

function GameResourceManager:cacheRoleSkillEft(eftFile)
	local resPath = "effect/".. eftFile .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("effect/"..eftFile, 1)
	else
		print("when cache: " .. resPath.."not find")
	end
end

function GameResourceManager:getMapEffectById(mapId, scale, loop, name, timeScale)
	scale = scale or 1
	timeScale = timeScale or 1.0
	name = name or "bofang"
	local resPath = "mapeffect/mission".. mapId .. ".json"
	if TFFileUtil:existFile(resPath) then
		TFResourceHelper:instance():addSkeletonFromFile("mapeffect/mission"..mapId, scale)
	else
		print(resPath.."not find")
		return nil
	end
	local skeleton = TFSkeleton:create("mapeffect/mission" .. mapId)
	if skeleton == nil then
		assert(false, "mapeffect/mission"..mapId.."create error")
		return nil
	end

	if loop ~= nil and (loop == 0 or loop == false) then
		loop = 0
	else
		loop = 1
	end
	skeleton:setPosition(ccp(0,0))
	skeleton:setTouchEnabled(false)
	skeleton:setScale(scale)
    skeleton:setTimeScale(GameConfig.SPINE_TIMESCALE * timeScale)
    skeleton:play(0, name, loop)
	return skeleton
end

return GameResourceManager:new()
