--[[
******地图管理类*******

	-- by Jing
	-- 2017/7/7
]]
--版本2：拆分出每个地图的数据

local BaseManager = require('lua.gamedata.BaseManager')
local MapManager = class("MapManager", BaseManager)

function MapManager:ctor(data)
	self.super.ctor(self)

    self.gridX = 24
    self.gridY = 24
end

function MapManager:init()
	self.super.init(self)

	self:registerEvents()
end

function MapManager:getMapData(mapId)
    return MapData:objectByID(mapId)
end

function MapManager:getMapData2(mapId)
    if not mapId then
        return nil
    end
    local mapFile = "lua/map/map" .. mapId .. ".lua"
    if TFFileUtil:existFile(mapFile) then
        if package.loaded["lua.map.map" .. mapId] then
            package.loaded["lua.map.map" .. mapId] = nil
        end
        local d = require("lua.map.map" .. mapId)
        return d
    end
    return nil
end

function MapManager:openEditorLayer()
    print("=====================================")
    print("==============地图编辑===============")
    print("==============地图编辑===============")
    print("=====================================")

    if self.hasOpen then return end
    self.hasOpen = true
    -- AlertManager:addLayerByFile("lua.logic.editor.MapEditorLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
    AlertManager:addLayerByFile("lua.logic.editor.MapEditorLayer2",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
    AlertManager:show()
end

function MapManager:restart()
end

function MapManager:registerEvents()
end

function MapManager:removeEvents()
end

function MapManager:dispose()
	self:removeEvents()
end

function MapManager:saveMapData(mapId, data)
    if mapId==nil or data==nil then return end
    local d = MapData:objectByID(mapId)
    if d then
        MapData:removeObject(d)
    end
    MapData:push({ id = mapId, data = data})
    self:saveToFile()
end

function MapManager:saveToFile()

    local path = "lua/design/t_s_map_data.lua"
    local fullpath = me.FileUtils:fullPathForFilename(path)

    local head = [==[
local mapArray = MEMapArray:new()
]==]

    local file = io.open(fullpath, "wb+")
    if not file then return end
    file:close()

    local file = io.open(fullpath, "rb+")
    print(file, fullpath)
    if not file then return end

    local format = string.format

    local function writeString(file, key, val, def)
        if val and val ~= def then
            -- file:write(format("%s = \"%s\", ", key, val or ""))
            file:write(format("%s = \"%s\" ", key, val or ""))
        end
    end

    file:write(head)

    for info in MapData:iterator() do 
        -- print("info ", info)
        file:write("mapArray:push({")

        file:write(format("id = %d,\t", info.id or 0))
        writeString(file, "data", info.data, nil)

        file:write("})\n")
    end

    file:write("\nreturn mapArray\n")
    
    file:close()
end

function MapManager:saveMapData2(mapId, data)
    if mapId==nil or data==nil then return end

    print("==============开始保存===============")

    local fullpath = self:getFullPath(mapId)

    print("fullpath", fullpath)

    local file = io.open(fullpath, "wb+")
    if not file then return print("==============保存失败===============") end
    file:close()

    local file = io.open(fullpath, "rb+")
    print(file, fullpath)
    if not file then return print("==============保存失败===============") end

    file:write(string.format("local d = {\n data = \"%s\" \n} \n return d", data))
    file:close()

    print("==============保存成功===============")
end

function MapManager:getFullPath(mapId)
    local tmpPath = "lua/map/map1.lua"
    local fullpath = me.FileUtils:fullPathForFilename(tmpPath)
    return string.gsub(fullpath, "map1", "map" .. mapId)
end

function MapManager:checkMapData()



    local function checkChapterPosData(chapterPosId)
        local posData = ChapterPosData:objectByID(chapterPosId)

        local trans_pos = GetTwoSpecilDataByString(posData.trans_pos)
        local birth_pos = GetTwoSpecilDataByString(posData.birth_pos)
        local sceneIds = {}
        local function getScene()
            for k,v in pairs(trans_pos) do
                sceneIds[v[1]] = true
                sceneIds[v[3]] = true
            end
            for k,v in pairs(birth_pos) do
                sceneIds[v[1]] = true
            end
        end
        getScene()

        local sceneData = {}
        for id, _ in pairs(sceneIds) do
            local mapData, row, col = GetMapDataById(id)
            sceneData[id] = {mapData = mapData, row = row, col = col}
        end

        local function checkValue(sceneId, value)
            local data = sceneData[sceneId]
            if not data then 
                print(string.format("sceneId:%d, not mapData", sceneId))
                return false 
            end

            local mapData = data.mapData
            local row = data.row
            local col = data.col

            local minArea, maxArea = {}, {}
            local function setMinMax(idx, i, j)
                local min = minArea[idx]
                local max = maxArea[idx]
        
                if min == nil and max == nil then
                    minArea[idx] = {x=i,y=j}
                    maxArea[idx] = {x=i,y=j}
                else
                    if min.x > i then min.x = i end
                    if max.x < i then max.x = i end
        
                    if min.y > j then min.y = j end
                    if max.y < j then max.y = j end
                end
            end

            for i=1, row do
                for j=1, col do
                    if mapData[i] and mapData[i][j] and value == mapData[i][j] then
                        setMinMax(value, i, j)
                    end
                end
            end

            if minArea[value] == nil or maxArea[value] == nil then
                print(string.format("sceneId:%s, not area:%s", sceneId, value))
                return false
            end
            local minPos = minArea[value]
            local maxPos = maxArea[value]
            local x = math.ceil((minPos.x + maxPos.x) *0.5)
            local y = math.ceil((minPos.y + maxPos.y) *0.5)
            
            if mapData[x] and mapData[x][y] and mapData[x][y] ~= 0 then
                return true
            end
            print(string.format("sceneId:%s, area:%s, %s", sceneId, value, mapData[x][y]))
            return false
        end

        local posName = {"birth_pos", "trans_pos", "box_pos", "boss_pos", "back_pos",
        "mission_pos", "npc_pos", "arrow_pos", "drop_pos", "mec_pos", "repeat_pos",
        "tele_pos", "pet_pos", "task_pos", "onekey_index", "eye_pos"}

        local posInfo = {}
        for k,v in pairs(posName) do
            posInfo[v] = GetTwoSpecilDataByString(posData[v])
        end

        for k, tbl in pairs(posInfo) do
            for m,n in pairs(tbl) do
                if n and n[2] then
                    if not checkValue(n[1], n[2]) then
                        assert(false, string.format( "chapterPosId: %s,sceneId:%s,name:%s, not area point:%s", chapterPosId, n[1], k, n[2]))
                    end
                end
                if k == "trans_pos" and n[3] and n[4] then
                    if not checkValue(n[3], n[4]) then
                        assert(false, string.format( "chapterPosId: %s,sceneId:%s,name:%s, not area point:%s", chapterPosId, n[3], k, n[4]))
                    end
                end
                if k == "arrow_pos" and n[4] and n[5] then
                    if not checkValue(n[4], n[5]) then
                        assert(false, string.format( "chapterPosId: %s,sceneId:%s,name:%s, not area point:%s", chapterPosId, n[4], k, n[5]))
                    end
                end
            end
        end
    end
    
    for chapter in ChapterData:iterator() do
        checkChapterPosData(chapter.lock)
        checkChapterPosData(chapter.unlock)
    end
end

function MapManager:checkTransAndArrow()
    local function checkData(posData)
        local trans_pos = GetTwoSpecilDataByString(posData.trans_pos)
        local arrow_pos = GetTwoSpecilDataByString(posData.arrow_pos)

        for k,v in pairs(trans_pos) do
            for m, n in pairs(arrow_pos) do
                if v[2] == n[2] and v[1] == n[1] then
                    if v[3] == n[4] then
                    else
                        print("::", v, n)
                        local str = string.format("chapter_pos_s id: %s trans_pos: %d_%d_%d_%d", posData.id, v[1], v[2], v[3], v[4])
                        assert(false, str)
                    end
                end
            end
        end
    end

    for posData in ChapterPosData:iterator() do
        checkData(posData)
    end
end

return MapManager:new()