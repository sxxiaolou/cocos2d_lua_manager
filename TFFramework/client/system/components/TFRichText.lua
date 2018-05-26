--
-- Author: xiaoda.zhuang
-- Date: 2014-09-28 09:43:53
--

local _pcreate = TFRichText.create
function TFRichText:create(size)
	local obj = nil
	if size then 
		obj = _pcreate(TFRichText, size)
	else 
		obj = _pcreate(TFRichText)
	end
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	obj = TFRichText:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	if TF_FONT_DEFAULT then val.fontName = TF_FONT_DEFAULT end
	if obj then
		obj:initMERichText(val, parent)
	end
	return true, obj
end
rawset(TFRichText, "initControl", initControl)

local _setText = TFRichText.setText
function TFRichText:setText(text)
	text = text or ""
	_setText(self, text)
end

return TFRichText