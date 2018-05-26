local BaseManager = class("BaseManager")

function BaseManager:ctor()
	self:init()
end

function BaseManager:init()
	-- body
end

function BaseManager:send(nCode, ...)
	TFDirector:send(nCode, {...})
end

function BaseManager:sendWithLoading(nCode, ...)
	showLoading()
	TFDirector:send(nCode, {...})
end

function BaseManager:sendWithLongLoading(nCode, ...)
	showLongLoading()
	TFDirector:send(nCode, {...})
end

return BaseManager

