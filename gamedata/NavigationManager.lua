--[[  
虚拟摇杆类 Layer  
几种组合方式：  
1.固定位置   不自动隐藏  
2.固定位置   自动隐藏  
3.非固定位置 自动隐藏  
Init 初始化  
Release 释放  
SetEnable 启用  
IsEnable 是否启用  
--]]  
  
  
-- local NavigationManager = class("NavigationManager", function(...)
--     local layer = TFPanel:create()
--     layer:setName("NavigationManager")
--     return layer
-- end)

local NavigationManager = class("NavigationManager", BaseLayer)

-- 8个方向  
NavigationManager.eDirection = {  
    None = 0,  
    U = 1,  
    UR = 2,  
    R = 3,  
    DR = 4,  
    D = 5,  
    DL = 6,  
    L = 7,  
    UL = 8  
}  
  
NavigationManager._instance = nil  
  
NavigationManager._touchArea = nil  
NavigationManager._naviBallNode = nil  
NavigationManager._downPos = nil  
  
NavigationManager._isEnable = false  
NavigationManager._naviCallback = nil  
  
NavigationManager._rootNode = nil  
NavigationManager._naviBallNode = nil  
NavigationManager._radius = 0  
  
NavigationManager._naviPosition = nil -- nil时跟随点击位置  
NavigationManager._isAutoHide = true  -- 非点击或移动状态自动隐藏


function NavigationManager:ctor()

end

function NavigationManager:restart()  
    if NavigationManager._instance ~= nil then  
        NavigationManager._instance:Release()  
        NavigationManager._instance = nil  
    end  
end  

--[[参数表  
isEnable 是否启用  
isAutoHide 是否自动隐藏，如果没有固定位置，则此参数无效，按照自动隐藏处理  
naviPosition 摇杆位置，nil则跟随点击位置，否则有固定位置  
radius 摇杆半径  
touchArea 有效触摸区域，在此区域内点击才会处理摇杆操作  
naviCallback 方向更改回调，回传角度与8个反向，参考eDirection，角度以右为0，上为90，下为-90  
]]  
-- 初始化 naviPosition nil则根据点击位置变化 有值则固定位置  
function NavigationManager:Init(isEnable, isAutoHide, naviPosition, radius, touchArea, naviCallback)  
    -- 没有固定位置的 只能是自动隐藏  
    if naviPosition == nil then  
        isAutoHide = true  
    end  
    -- 加载ui  
    self._rootNode = TFPanel:create()--cc.CSLoader:createNode(naviCsbName)  
    self._rootNode:setSize(CCSize(150, 150))
    self._rootNode:setAnchorPoint(ccp(0.5, 0.5))
    if self._rootNode == nil then  
        print('error load csb!')  
        return false  
    end  
    self._naviBallNode = TFImage:create()
    self._naviBallNode:setTexture("ui/bocai/btn_xianyuanshangdian.png")--self._rootNode:getChildByName(ballKey)  
    self._rootNode:setVisible(false)  
    self._naviBallNode:setVisible(true)  
    self._rootNode:addChild(self._naviBallNode)
    self._radius = radius  
  
    self:addChild(self._rootNode, 1)  
  
    self._naviCallback = naviCallback  
  
    self:SetTouchArea(touchArea)  
    self:SetNaviPosition(naviPosition)  
    self:SetAutoHide(isAutoHide)  
    self:SetEnable(isEnable)  
  
    if not self:IsAutoHide() then  
        self._rootNode:setVisible(true)  
    end  
  
    -- 监听触摸  
    -- self._naviBallNode = cc.EventListenerTouchOneByOne:create()  
    self._naviBallNode:setTouchEnabled(true)
    self._naviBallNode.logic = self
    self._naviBallNode:addMEListener(TFWIDGET_TOUCHBEGAN, self.onTouchBegan)  
    self._naviBallNode:addMEListener(TFWIDGET_TOUCHMOVED, self.onTouchMoved)  
    self._naviBallNode:addMEListener(TFWIDGET_TOUCHENDED, self.onTouchEnded)  
    self._naviBallNode:addMEListener(TFWIDGET_CLICK, self.onTouchCanceled)  
  
    -- local eventDispatcher = self:getEventDispatcher()  
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(self._naviBallNode, self)  
  
    -- return self  
end  
  
-- 释放  
function NavigationManager:Release()  
    if self._naviBallNode ~= nil then  
        cc.EventDispatcher:removeEventListener(self._naviBallNode)  
        self._naviBallNode = nil  
    end  
  
    if self._naviCallback ~= nil then  
        self._naviCallback = nil  
    end  
end  
  
-- 启用  
function NavigationManager:SetEnable(isEnable)  
    self._isEnable = isEnable  
end  
  
-- 是否启用  
function NavigationManager:IsEnable()  
    return self._isEnable  
end  
  
-- 自动隐藏  
function NavigationManager:SetAutoHide(isAutoHide)  
    self._isAutoHide = isAutoHide  
end  
  
-- 是否自动隐藏  
function NavigationManager:IsAutoHide()  
    return self._isAutoHide  
end  
  
-- 设置位置  
function NavigationManager:SetNaviPosition(naviPosition)  
    self._naviPosition = naviPosition  
    if self._naviPosition ~= nil then  
        self._rootNode:setPosition(self._naviPosition)  
    end  
end  
  
-- 位置是否跟随初始点击位置变动  
function NavigationManager:IsPosCanChange()  
    return (self._naviPosition == nil)  
end  
  
-- 设置触摸区域  
function NavigationManager:SetTouchArea(touchArea)  
    if touchArea ~= nil then  
        self._touchArea = {}  
        self._touchArea.x = touchArea.x  
        self._touchArea.y = touchArea.y  
        self._touchArea.width = touchArea.width  
        self._touchArea.height = touchArea.height  
    else  
        self._touchArea = nil  
    end  
end  
  
-- 触摸操作回调  
function NavigationManager.onTouchBegan(touch)  
    local self = touch.logic  
    local needNextProcess = false  
  
    if not self:IsEnable() then  
        return needNextProcess  
    end  
  
    if self._touchArea ~= nil then  
        local touchPoint = touch:getTouchStartPos()
        if self._touchArea:hitTest(touchPoint) then  
            -- 需要使用listener的setSwallowTouches，直接使用layer的无效  
            self._naviBallNode:setTouchEnabled(true)  
            self:Update(touchPoint, false)  
            print("in area!!!")  
            needNextProcess = true  
        else  
            self._naviBallNode:setTouchEnabled(false)  
            -- 区域外 考虑不做任何处理  
            self:Update(nil, false)  
            print("NOT IN AREA")  
            needNextProcess = false  
        end  
    end  
  
    return needNextProcess  
end  
  
function NavigationManager.onTouchMoved(touch, event)  
    local self = touch.logic
    local touchPoint = touch:getTouchMovePos()  
    self:Update(touchPoint, true)  
end  
  
function NavigationManager.onTouchEnded(touch, event)  
    local self = touch.logic  
    self:Update(nil, false)  
end  
  
function NavigationManager.onTouchCanceled(touch, event)  
    local self = touch.logic  
    self:Update(nil, false)  
end  
  
-- 更新  
function NavigationManager:Update(touchPos, isMove)  
    local direction, angle = self:UpdateData(touchPos, isMove)  
    local isShow = ((not self:IsAutoHide()) or (self._downPos ~= nil))  
    self:UpdateUI(direction, angle, isShow)  
  
    -- 回调数据  
    if self._naviCallback ~= nil then  
        self._naviCallback(direction, angle)  
    end  
end  
  
-- UI更新  
function NavigationManager:UpdateUI(direction, angle, isShow)  
    local ballPos = {x=0, y=0}  
    if isShow then  
        -- 球位置更新  
        if direction ~= self.eDirection.None then  
            local radians = math.rad(angle)  
            ballPos.x = math.cos(radians)*self._radius  
            ballPos.y = math.sin(radians)*self._radius  
        end  
        self._naviBallNode:setPosition(ballPos)  
        -- 显示更新  
        if self:IsPosCanChange() then  
            self._rootNode:setPosition(self._downPos)  
        end  
    end  
      
    self._rootNode:setVisible(isShow)  
end  
  
-- 数据更新  
function NavigationManager:UpdateData(touchPos, isMove)  
    local direction = self.eDirection.None  
    local angle = 0  
    local isNeedUpdate = false  
  
    -- 按下 或 弹起 记录触摸点  
    if not isMove then  
        self._downPos = touchPos  
        -- 如果是非自动隐藏的 点击时也要进行一次位置判定  
        if not self:IsAutoHide() then  
            isNeedUpdate = true  
        end  
    else -- 移动 更新角度  
        isNeedUpdate = true  
    end  
  
    if isNeedUpdate then  
        if self._downPos ~= nil and touchPos ~= nil then  
            local centerPos = self._downPos  
            -- 如果有指定位置 则从根据指定位置算  
            if not self:IsPosCanChange() then  
                centerPos = self._naviPosition  
            end  
            -- 弧度 然后转 角度  
            local radians = cc.pToAngleSelf(cc.pSub(touchPos, centerPos))  
            -- angle = radians*57.29577951 -- ((__ANGLE__) * 57.29577951f) // PI * 180 CC_RADIANS_TO_DEGREES  
            angle = math.deg(radians)  
            direction = self:AngleToDirection(angle)  
            print("angle:"..tostring(angle))  
            print("direction:"..tostring(direction))  
        else  
            print("downPos or touchPos is nil!")  
        end  
    end  
  
    return direction, angle  
end  
  
-- 角度转方向  
function NavigationManager:AngleToDirection(angle)  
    local direction = self.eDirection.None  
  
    -- -22.5 22.5 67.5 112.5 157.5 -157.5 -112.5 -67.5 -22.5  
    --      R    DR   D     DL    L      UL     U     UR  
    if angle > -22.5 and angle <= 22.5 then  
        direction = self.eDirection.R  
    elseif angle > 22.5 and angle <= 67.5 then  
        direction = self.eDirection.DR  
    elseif angle > 67.5 and angle <= 112.5 then  
        direction = self.eDirection.D  
    elseif angle > 112.5 and angle <= 157.5 then  
        direction = self.eDirection.DL  
    elseif angle > 157.5 or angle <= -157.5 then  -- 特殊  
        direction = self.eDirection.L  
    elseif angle > -157.5 and angle <= -112.5 then  
        direction = self.eDirection.UL  
    elseif angle > -112.5 and angle <= -67.5 then  
        direction = self.eDirection.U  
    elseif angle > -67.5 and angle <= -22.5 then  
        direction = self.eDirection.UR  
    end  
  
    return direction  
end  
  
return NavigationManager