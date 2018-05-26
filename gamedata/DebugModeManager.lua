--[[
******游戏调试管理类*******

	-- by Jing
	-- 2016/9/6
]]

local BaseManager = require("lua.gamedata.BaseManager")
local DebugModeManager = class("DebugModeManager", BaseManager)

function DebugModeManager:ctor(data)
	self.super.ctor(self)
end

function DebugModeManager:init()
	self.super.init(self)
end

function DebugModeManager:restart()
    -- body
end

function DebugModeManager:checkSpineEvent()
    print("==========================================")
    print("==========调试模式-检查Spine事件==========")
    print("==========调试模式-检查Spine事件==========")
    print("==========================================")
    
    AlertManager:addLayerByFile("lua.logic.debug.DebugCheckSpineEvent",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
    AlertManager:show()
end

function DebugModeManager:openChoiceLayer()
    print("=====================================")
    print("==========调试模式-选择角色==========")
    print("==========调试模式-选择角色==========")
    print("=====================================")


    AlertManager:addLayerByFile("lua.logic.debug.DebugModeLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show()
end

function DebugModeManager:fight(owners, oppos)
    print("owners ", owners)
    print("oppos ", oppos)

    local function isEmpty(arr)
       for k,v in pairs(arr) do
           return false
       end
       return true
    end

    if owners==nil or oppos==nil or isEmpty(owners) or isEmpty(oppos) then
        return
    end

    FightManager:onFightBegin({data = self:packFightData(owners, oppos)})
end

function DebugModeManager:packFightData(owners, oppos)
    local FightBeginMsg = {}
    FightBeginMsg.fighttype = 7
    FightBeginMsg.missionId = 4001
    FightBeginMsg.mapID=1
    FightBeginMsg.angerEnemy=50
    FightBeginMsg.angerSelf=50
    FightBeginMsg.unitList={}

    for k,v in pairs(owners) do
        FightBeginMsg.unitList[#FightBeginMsg.unitList + 1] = self:packUnit(k-1, v)
    end
    for k,v in pairs(oppos) do
        FightBeginMsg.unitList[#FightBeginMsg.unitList + 1] = self:packUnit(k-1+9, v)
    end

    return FightBeginMsg
end

function DebugModeManager:packUnit(pos, id)
    local card = CardData:objectByID(id)
    assert(card~=nil)

    local BattleUnit = {}
    BattleUnit.unitId = id
    BattleUnit.staticId = id
    BattleUnit.attrs = {}
    BattleUnit.typeId = 1
    BattleUnit.posindex = pos
    BattleUnit.name = card.name
    BattleUnit.level = 1
    BattleUnit.skills = {}
    BattleUnit.showId = card.pic_id

    local attrs = card:GetAttr()
    for k,v in pairs(attrs) do
        BattleUnit.attrs[#BattleUnit.attrs + 1] = {attrId=k,attrValue=v}
    end

    local function createSkillData(skillType, skillId, index)
        BattleUnit.skills[#BattleUnit.skills + 1] = {skillType = skillType, skillId = skillId, index = index}
    end

    createSkillData(EnumSkillType.NormalAttack, card.phy_skill, 1)
    createSkillData(2, card.act_skill, 1)
    createSkillData(3, card.pas_skill, 1)
    createSkillData(3, card.pas_skill2, 2)
    createSkillData(3, card.pas_skill3, 3)
    createSkillData(4, card.awake_skill, 1)
    createSkillData(5, card.back_skill, 1)
    createSkillData(6, card.pursue_skill, 1)

    return BattleUnit
end

return DebugModeManager:new()
