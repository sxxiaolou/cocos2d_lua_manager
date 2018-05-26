--新手引导触发条件

local tTriggerFunction = {}

--等级满足触发
function tTriggerFunction:getLevel(conditions)
	local teamLv = MainPlayer:getLevel()
	if conditions.level and teamLv ~= conditions.level then
		return false
	end
	return true
end

-- 等级满足触发
function tTriggerFunction:getMinLevel( conditions )
	local teamLv = MainPlayer:getLevel()
	if conditions.minLevel and teamLv < conditions.minLevel then
		return false
	end
	return true
end

-- 等级满足触发
function tTriggerFunction:getMaxLevel( conditions )
	local teamLv = MainPlayer:getLevel()
	if conditions.maxLevel and teamLv > conditions.maxLevel then
		return false
	end
	return true
end

--拥有秘籍触发
function tTriggerFunction:getMartial( conditions )
	if conditions.martial and conditions.martial == false then
		return false
	end
	if conditions.martial and CardRoleManager:isHaveRoleBookAll() == false then
		return false
	end
	return true
end

-- 步骤满足触发
function tTriggerFunction:getStep( conditions )
	if conditions.step then
		local tbl = stringToNumberTable(conditions.step, ",")
		for _,v in pairs(tbl) do
			if PlayerGuideManager:isGuideFunctionOpen(v) then
				return true
			end
		end
		return false
	end
	return true
end

-- 步骤满足跳过      
function tTriggerFunction:getMaxStep( conditions )
	if conditions.maxStep then
		local tbl = stringToNumberTable(conditions.maxStep, ",")
		for k,v in pairs(tbl) do
			if PlayerGuideManager:isGuideFunctionOpen(v) then
				return false
			end
		end
	end
	return true
end

--当前开启的关卡
function tTriggerFunction:getCurMission( conditions )
	if conditions.curMission then
		local status = MissionManager:getStarLevelByMissionId(conditions.curMission)
		if status ~= 0 then
			return false
		end
	end
	return true
end

--通过关卡
function tTriggerFunction:getPassMission(conditions)
	if conditions.passMission then
		local missionId = conditions.passMission
		local mission = MissionManager:findMission(missionId)
		if not mission or mission.starLevel == 0 then
			return false
		end
		if conditions.boss and conditions.boss == true then
			local boxId = MissionManager:getLastStarBoxByChapter(mission.template.chapter)
			if boxId and not MissionManager:findOpenBoxId(boxId, mission.template.chapter) then
				return false
			end
		end
	end
	return true
end

-- 上阵人数满足触发
function tTriggerFunction:getArmyRole( conditions )
	local armyRole = FormationManager:getToBattleSize()
	if conditions.armyRole and armyRole ~= conditions.armyRole then
		return false
	end
	return true
end

--角色可突破
function tTriggerFunction:getRoleFrag(conditions)
	if conditions.roleFrag and conditions.roleFrag == false then
		return false
	end
	if conditions.roleFrag and CardRoleManager:isHaveRoleStarAll() == false then
		return false
	end
	return true
end

-- 拥有人数满足触发
function tTriggerFunction:getRoleNum( conditions )
	local roleNum = CardRoleManager:getRoleNum()
	if conditions.roleNum and roleNum ~= conditions.roleNum then
		return false
	end
	return true
end

function tTriggerFunction:getRoleCompose(conditions)
	if conditions.roleCompose and conditions.roleCompose == false then
		return false
	end
	if conditions.roleCompose and CardRoleManager:isHaveSoul() == false then
		return false
	end
	return true
end

function tTriggerFunction:getTargetMission(conditions)
	if conditions.targetMission and conditions.targetMission == false then
		return false
	end
	if conditions.targetMission and MainPlayer:checkMissionGuideReward() == nil then
		return false
	end
	return true
end

function tTriggerFunction:getPet(conditions)
	if conditions.pet and conditions.pet == false then
		return false
	end
	if conditions.pet and PetRoleManager.petRoleList:length() <= 0 then
		return false
	end
	return true
end

function tTriggerFunction:getTeam(conditions)
	if conditions.team and conditions.team == true then
		return true
	end
	return not TeamManager:ishaveTeam()
end

function tTriggerFunction:getRole(conditions)
	if conditions.role then
		local role = CardRoleManager:getRoleById(conditions.role)
		if not role then
			return false
		end
	end
	return true
end

function tTriggerFunction:getMaxRole(conditions)
	if conditions.maxRole then
		local role = CardRoleManager:getRoleById(conditions.maxRole)
		if role then
			return false
		end
	end
	return true
end

function tTriggerFunction:getWorldBoss(conditions)
	if conditions.worldBoss and conditions.worldBoss == true then
		return WorldBossManager.bossState == 2
	end
	return true
end

--抽卡金签数量满足就触发
function tTriggerFunction:getGoldenLotCoin(conditions)
	if conditions.goldenLotCoin then
		if MainPlayer.goldenLotCoin and MainPlayer.goldenLotCoin < conditions.goldenLotCoin then
			return false
		end
	end
	return true
end

--需要道具数量满足就触发
function tTriggerFunction:getNeedItem(conditions)
	if conditions.needItem then
		local type = needItem[1]
		local tplId = needItem[2]
		local num = needItem[3]
		
		local resNum = 0
		
		if tplId == 0 then
			resNum = getResValueByType(type)
		else
			resNum = BagManager:getGoodsNumByTypeAndTplId(type, tplId)
		end
		
		if resNum < num then
			return false
		end
	end
	return true
end  

--异色之瞳时间       
function tTriggerFunction:getEyeTime(conditions)
	if conditions.eyeTime then
		local rescue = EyeManager:getEyeRescueTime()
		return rescue > conditions.eyeTime
	end
	return true
end

--积分赛是否开启     
function tTriggerFunction:getScoreMatch(conditions)
	if conditions.scoreMatch then
		return ServerSwitchManager:isScoreMatchOpen()
	end
	return true
end

function tTriggerFunction:getServerSwitch(conditions)
	if conditions.serverSwitch then
		return ServerSwitchManager:getServerSwitchStatue(conditions.serverSwitch)
	end
	return true
end

------  剧情条件触发

-- 步骤满足触发    
function tTriggerFunction:getMovieStep( conditions )
	if conditions.movieStep then
		local tbl = stringToNumberTable(conditions.movieStep, ",")
		for _,v in pairs(tbl) do
			if MovieManager:isMovieFunctionOpen(v) then
				return true
			end
		end
		return false
	end
	return true
end

-- 步骤满足跳过   
function tTriggerFunction:getMaxMovieStep( conditions )
	if conditions.maxMovieStep then
		return not MovieManager:isMovieFunctionOpen(conditions.maxMovieStep)
	end
	return true
end

return tTriggerFunction