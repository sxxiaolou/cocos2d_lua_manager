--[[--
	table扩展方法

	--By: yun.bo
	--2013/7/8
]]

local table = table
local type = type 
local pairs = pairs
local next = next
local tonumber = tonumber

--[[--
	合并表
]]
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
    return dest
end

--[[--
	表克隆, 深度复制
]]
local _copy
_copy = function(t, lookup)
    if type(t) ~= "table" then
        return t
    elseif lookup[t] then
        return lookup[t]
    end
    local n = {}
    lookup[t] = n
    for key, value in pairs(t) do
        n[_copy(key, lookup)] = _copy(value, lookup)
    end
    return n
end

function table.deepclone(t)
    local lookup = {}
    return _copy(t, lookup)
end

function table.clone(tab)
    local object = {}
    for k, v in pairs(tab) do   
        if type(v) == "table" then
            object[k] = table.clone(v)
        else
            object[k] = v
        end
    end
    return object
end

--[[--
	表克隆, 浅复制
]]
function table.clone2(tab)
	local object = {}
	for k, v in pairs(tab) do	
		object[k] = v
	end
	return object;
end

--[[--
	清空表内所有属性
]]
function table.clear(tab)
	if tab then
		local field = next(tab)
		while field do
			tab[field] = nil
			field = next(tab)
		end
	end
	return tab
end

--[[--
	在表内检索指定的值, 返回其索引
]]
function table.find(tab, value)
	return table.indexOf(tab, value)
end

--[[--
	获取表内所有元素个数
]]
function table.count(tab)
	local cnt = 0
	for _, _ in pairs(tab) do
		cnt = cnt + 1
	end
	return cnt
end


function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

--[[--

insert list.

**Usage:**

    local dest = {1, 2, 3}
    local src  = {4, 5, 6}
    table.insertTo(dest, src)
    -- dest = {1, 2, 3, 4, 5, 6}
	dest = {1, 2, 3}
	table.insertTo(dest, src, 5)
    -- dest = {1, 2, 3, nil, 4, 5, 6}


@param table dest
@param table src
@param table begin insert position for dest
]]
function table.insertTo(dest, src, begin)
    if not src then return end
    
	begin = tonumber(begin)
	if begin == nil then
		begin = #dest + 1
	end

	local len = #src
	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

--[[
search target index at list.

@param table list
@param * target
@param int from idx, default 1
@param bool useNaxN, the len use table.maxn(true) or #(false) default:false
@param return index of target at list, if not return -1
]]
function table.indexOf(list, target, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	for i = from, len do
		if list[i] == target then
			return i
		end
	end
	return -1
end

function table.indexOfKey(list, key, value, from, useMaxN)
	local len = (useMaxN and #list) or table.maxn(list)
	if from == nil then
		from = 1
	end
	local item = nil
	for i = from, len do
		item = list[i]
		if item ~= nil and item[key] == value then
			return i
		end
	end
	return -1
end

function table.removeItem(t, item, removeAll)
    for i = #t, 1, -1 do
        if t[i] == item then
            table.remove(t, i)
            if not removeAll then break end
        end
    end
end

function table.map(t, fun)
    for k,v in pairs(t) do
        t[k] = fun(v, k)
    end
    return t
end

function table.walk(t, fun)
    for k,v in pairs(t) do
        fun(v, k)
    end
    return t
end

function table.filter(t, fun)
    for k,v in pairs(t) do
        if not fun(v, k) then
            t[k] = nil
        end
    end
    return t
end

function table.unique(t)
    local r = {}
    local n = {}
    for i = #t, 1, -1 do
        local v = t[i]
        if not r[v] then
            r[v] = true
            n[#n + 1] = v
        end
    end
    return n
end

function table.keyOfItem(t, item)
    for k,v in pairs(t) do
        if v == item then return k end
    end
    return nil
end

-- 往列表中添加元素，重复则过滤
function table.uniqueAdd(t, item)
	if table.indexOf(t, item) == -1 then
		table.insert(t, item)
	end
end

function table.findOne(array, match)
    for _, v in pairs(array) do
        if match(v) then
            return v
        end
    end
    return nil
end

function table.findAll( array, match )
    local result = {}
    for _, v in pairs(array) do
        if match(v) then
            table.insert(result, v)
        end
    end
    return result
end

function table.removeAll( array, match )
    local i, c = #array, 0
    while i ~= 0 do
        if match(array[i]) then
            table.remove(array, i)
            c = c + 1
        end
        i = i - 1
    end
    return c
end

function table.removeOne( array, match )
    for i,v in ipairs(array) do
        if match(v) then
            table.remove(array, i)
            return v
        end
    end
    return nil
end