--[[
******游戏数据装备牌属性数据类*******

	-- by Stephen.tao
	-- 2014/2/7
]]

local GameAttributeData = class("GameAttributeData")


function GameAttributeData:ctor()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
	self.factor 			= 1
end

 --[[
Data 为字符串，格式：属性索引_属性值,……
如：2_230|3_40
 ]]
function GameAttributeData:init(Data)
	--self.attribute = {}
	self.attribute,self.indexTable = GetAttrByStringForExtra(Data)
	self:updatePower()
end

function GameAttributeData:initWithAttribute(attribute)
	self.attribute = attribute
	self.indexTable = {}
	for k,v in pairs(self.attribute) do
		self.indexTable[#self.indexTable + 1] = k
	end
	self:updatePower()
end

--克隆传入的数据信息类
function GameAttributeData:clone(attr1)
	self.attribute = {}
	for k,v in pairs(attr1.attribute) do
		self.attribute[k] = v
	end
	self:updatePower()
end

--通过index获得属性值，如果index为空则传出整个属性table
function GameAttributeData:getAttribute(index)
	if index then
		return self.attribute[index]
	end
	return self.attribute,self.indexTable
end

--更新战斗力
function GameAttributeData:updatePower()
	self.power = GetPowerByAttribute(self.attribute)

	local powerPercent = self.attribute[EnumAttributeType.PowerPercent]
	if powerPercent ~= nil then
		self.power = math.floor(self.power * (1 + powerPercent/10000))
	end
end

--获得战斗力
function GameAttributeData:getPower()
	return self.power
end

function GameAttributeData:attributeToFloor()
	for _,v in pairs(EnumAttributeType) do
		if self.attribute[v] then
			self.attribute[v] = math.floor(self.attribute[v])
		end
	end
end

--该类属性设置为两个属性table相加值
function GameAttributeData:setAdd(attr1,attr2)
	self.attribute = {}
	for _,v in pairs(EnumAttributeType) do
		local x = attr1.attribute[v] or 0
		local y = attr2.attribute[v] or 0
		self.attribute[v] = x + y
	end
end

--该类属性table增加一个属性table
function GameAttributeData:setAddAttData(attr1)
	for _,v in pairs(EnumAttributeType) do
		local x = attr1.attribute[v]
		if x then
			local y = self.attribute[v] or 0
			self.attribute[v] = x + y
		end
	end
end

--该类属性table增加一个属性table
function GameAttributeData:add(tbl)
	for _,v in pairs(EnumAttributeType) do
		local x = tbl[v]
		if x then
			local y = self.attribute[v] or 0
			self.attribute[v] = x + y
		end
	end
end


--该类属性table与一个属性table一起运算
function GameAttributeData:doMathAttData(attr1,cmp,...)
	for _,v in pairs(EnumAttributeType) do
		local y = attr1.attribute[v]
		if y then
			local x = self.attribute[v] or 0
			if cmp == nil then
				self.attribute[v] = x + y
			else
				self.attribute[v] = cmp(x,y,...)
			end
		end
	end
end

--清零
function GameAttributeData:clear()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
	self.factor = 1
end

--增加某个属性的数字
function GameAttributeData:addAttr(attr_index,attr_num)
	if self.attribute[attr_index] == nil then
		self.attribute[attr_index] = 0
	end
	self.attribute[attr_index] = attr_num + self.attribute[attr_index]
	if self.attribute[attr_index] < 0 then
		self.attribute[attr_index] = 0 
	end
end

--通过非0属性顺序位获得属性值
function GameAttributeData:getAttributeByIndex(index)
	local temp = 1
	for k,v in pairs(self.attribute) do
		if temp == index then
			return k , v
		end
		temp = temp + 1
	end
	-- return nil, nil
end

--通过运算设置属性值
function GameAttributeData:setAttByMath(attr1,cmp,...)
	for i=EnumAttributeType.Hp,EnumAttributeType.CritResistance do
		local x = attr1.attribute[i]
		if x then
			self.attribute[i] = cmp(x, i, ...)
		end
	end
end

--通过属性100位以后的百分比 刷新属性
function GameAttributeData:refreshByPercent()
	for i=EnumAttributeType.Hp,EnumAttributeType.CritResistance do
		local attr = self.attribute[i] or 0
		local percent = self.attribute[i + 100] or 0
		percent = percent/10000
		self.attribute[i] = attr * (1 + percent)
		self.attribute[i + 100] = 0
	end
end

--通过属性18位以后的百分比 刷新装备的角色属性
function GameAttributeData:refreshDataAttrBypercent(data)
	for i=EnumAttributeType.Hp,EnumAttributeType.CritResistance do
		local attr = data.attribute.attribute[i] or 0
		local oldattr = self.attribute[i] or 0
		local percent = self.attribute[i + 100] or 0
		percent = percent/10000
		self.attribute[i] = oldattr + (attr * percent)
		self.attribute[i + 100] = 0
	end
end

function GameAttributeData:getIndexTable()
	return self.indexTable
end

function GameAttributeData:displayString()
	local string = ""
	for i=1,EnumAttributeType.AngerPercent do
		local y = self.attribute[i]
		if y and y ~= 0 then
			string = string .. AttributeTypeStr[i] .. "：" .. y .. ","
		end
	end
	return string
end

function GameAttributeData:setFactor(factor)
	for i=EnumAttributeType.Blood,EnumAttributeType.PrecisenessPercent do
			local attr = self.attribute[i]
			if attr and attr ~= 0 then
				self.attribute[i] = attr/self.factor*factor
			end
	end
	self.factor = factor
end

--获得固定属性table  (<100)
function GameAttributeData:getFixedAttribute()
	local tbl = {}
	local max = EnumAttributeType.HPPercent - 1
	for i=EnumAttributeType.Hp,max do
		tbl[i] = self.attribute[i]
	end
	return tbl
end

function GameAttributeData:getNotFixedAttribute()
	local tbl = {}
	for i=EnumAttributeType.HPPercent,EnumAttributeType.AngerPercent do
		tbl[i] = self.attribute[i]
	end
	return tbl
end

return GameAttributeData