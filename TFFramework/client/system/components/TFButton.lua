--[[--
	按钮控件:

	--By: yun.bo
	--2013/7/12
]]
local TFUIBase = TFUIBase
local TFButton = TFButton

local _bcreate = TFButton.create
function TFButton:create(texture)
	local obj = _bcreate(TFButton)
	if  not obj then return end
	TFUIBase:extends(obj)
	if texture then 
		obj:setTextureNormal(texture)
	end
	return obj
end

local function new(val, parent)
	local obj
	obj 	= TFButton:create(val.texture)
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEButton(val, parent)
	return true, obj
end
rawset(TFButton, "initControl", initControl)
-- BY CT : 重写接口兼容三国业务调用
local setFontStrokeEnabled_origin = TFButton.setFontStrokeEnabled
rawset(TFButton, "setFontStrokeEnabled", function ( b,c,s )
	if	s > 0 then
		setFontStrokeEnabled_origin(b, c, s)
	else
		b:setFontStrokeDisabled()
	end
end)

return TFButton