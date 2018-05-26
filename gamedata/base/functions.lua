--获取技能类型名称
function GetSkillTypeName(type, idx)
	for k,v in pairs(EnumSkillType) do
		if v == type then
			local name = "skill_type_" .. k
			if idx == 1 then
				return localizable[name] .. localizable.skill_suffix
			else
				return localizable[name] .. localizable.skill_suffix .. idx
			end
		end
	end
end

function GetBriefSkillTypeName(type)
	for k,v in pairs(EnumSkillType) do
		if v == type then
			local name = "skill_type_" .. k
			return localizable[name]
		end
	end
end

-- 分解技能描述信息
function SplitSkillDesc(str)
	local desc = {}
	local contents = string.split(str, '|')
    for _, v in pairs(contents) do
        local msg = {}
        msg.str = v
        msg.keys = {}
        desc[#desc + 1] = msg

        local temp = v
        local s, e = string.find(temp, '{')
        while s
        do
            local m, n = string.find(temp, '}')
            if m then
                print(string.sub(temp, s + 1, m - 1))
                msg.keys[#msg.keys + 1] = string.sub(temp, s + 1, m - 1)
                temp = string.sub(temp, m + 1)
                s, e = string.find(temp, '{')
            else
                break
            end
        end
    end
    return desc
end

function getBtnPathByState(state)
	if state == EnumBtnType.Normal then
		return "ui/common/btn/btn_common.png"
	elseif state == EnumBtnType.Select then
		return "ui/common/btn/btn_common3.png"
	elseif state == EnumBtnType.Disable then
		return "ui/common/btn/btn_common2.png"
	end
	return "ui/common/btn/btn_common.png"
end

function GetFormationFullImage( index )
	-- body
	if index < 1 or index > 5 then return "" end

	return "ui/common/icon/img_" .. index .. ".png"
end
--[[
QualityType = 
{
	"White", 		--1 白
	"Green", 		--2 绿
	"Blue", 		--3 蓝
	"Purple", 		--4 紫
	"Orange",		--5 橙
	"Red",			--6 红
	"Max",	---
}
]]

--通过品质获得颜色 
function GetColorByQuality( quality )
	if quality == QualityType.White then	
		return ccc3(225,225,225)
	elseif quality == QualityType.Green then
		return ccc3(125,227,160)
	elseif quality == QualityType.Blue then
		return ccc3(105,172,255)
	elseif quality == QualityType.Purple then
		return ccc3(174,118,251)
	elseif quality == QualityType.Orange then
		return ccc3(255,182,77)
	elseif quality == QualityType.Red then
		return ccc3(255,100,100)
	end
	print("quality 不正确",quality)
	return ccc3(107,107,107)
end

--通过百分比获得颜色 
function GetColorByPercen( percen )
	percen = math.floor(percen)
	if percen >= 0 and percen <= 20 then	
		return ccc3(0,255,0)
	elseif percen >= 21 and percen <= 40 then
		return ccc3(30,145,255)
	elseif percen >= 41 and percen <= 60 then
		return ccc3(153,50,205)
	elseif percen >= 61 and percen <= 80 then
		return ccc3(255,165,0)
	elseif percen >= 81 and percen <= 100 then
		return ccc3(255,0,0)
	end
	print("percen 不正确",percen)
	return ccc3(107,107,107)
end

--通过百分比获得颜色 
function GetHtmlColorByPercen( percen )
	percen = math.floor(percen)
	if percen >= 0 and percen <= 20 then	
		return "#00ff00"
	elseif percen >= 21 and percen <= 40 then
		return "#1e91ff"
	elseif percen >= 41 and percen <= 60 then
		return "#9932cd"
	elseif percen >= 61 and percen <= 80 then
		return "#ffa500"
	elseif percen >= 81 and percen <= 100 then
		return "#ff0000"
	end
	print("percen 不正确",percen)
	return "#fffdf1"
end

function GetHtmlColorByQuality(quality)
	if quality == QualityType.White then	
		return "#fffdf1"
	elseif quality == QualityType.Green then
		return "#00ff00"
	elseif quality == QualityType.Blue then
		return "#1e91ff"
	elseif quality == QualityType.Purple then
		return "#9932cd"
	elseif quality == QualityType.Orange then
		return "#ffa500"
	elseif quality == QualityType.Red then
		return "#ff0000"
	end
	print("quality 不正确",quality)
	return "#fffdf1"
end

--获取名字底
function GetCardNameBgByQuality(quality)
	if quality < 1 or quality > 6 then
		print("quality 不正确",quality)
		return "ui/common/icon/bg_theme1.png"
	end
	return "ui/common/icon/bg_theme" .. quality .. ".png"
end

--角色列表背景图
function GetCardBgByQuality( quality )
	if quality < 1 or quality > 6 then
		print("quality 不正确",quality)
		return "ui/role/bg_1.png"
	end
	return "ui/role/bg_" .. quality .. ".png"
end

function GetCardNameSmallBgByQuality(quality)
	if quality < 1 or quality > 6 then
		print("quality 不正确",quality)
		return "ui/common/icon/bg_quality1.png"
	end
	return "ui/common/icon/bg_quality" .. quality .. ".png"
end

--通过角色id获得roleicon
function GetRoleIconById( id )
	local basePath = "icon/roleicon/"
	local path = basePath .. id .. '.png'
	return path
end
--通过角色id获得rolebig
function GetRoleBigById( id )
	local basePath = "icon/rolebig/"
	local path = basePath .. id .. '.png'
	return path
end
--通过角色id获得rolepresent
function GetRolePresentById( id )
	local basePath = "icon/rolepresent/"
	local path = basePath .. id .. '.png'
	return path
end
--通过versionId获得role lihui
function GetRoleLiHuiByVersionId( id )
	local basePath = "icon/rolelihui/"
	local path = basePath .. id .. '.jpg'
	return path
end
--通过品质获得颜色图标 (外框)
function GetColorKuangByQuality( quality )
	local basePath = "ui/common/icon/"
	if quality == QualityType.White then	
		return  basePath .. "quality_white.png"
	elseif quality == QualityType.Green then
		return basePath .. "quality_green.png"
	elseif quality == QualityType.Blue then
		return basePath .. "quality_blue.png"
	elseif quality == QualityType.Purple then
		return basePath .. "quality_purple.png"
	elseif quality == QualityType.Orange then
		return basePath .. "quality_orange.png"
	elseif quality == QualityType.Red then
		return basePath .. "quality_red.png"
	end
	--print("quality 不正确",quality)
	return basePath .. "quality_white.png"
end

--通过品质获得颜色图标 (圆外框)
function GetColorRollKuangByQuality( quality )
	-- body
	local basePath = "ui/common/icon/"
	if quality == QualityType.White then	
		return  basePath .. "quality_roll_white.png"
	elseif quality == QualityType.Green then
		return basePath .. "quality_roll_green.png"
	elseif quality == QualityType.Blue then
		return basePath .. "quality_roll_blue.png"
	elseif quality == QualityType.Purple then
		return basePath .. "quality_roll_purple.png"
	elseif quality == QualityType.Orange then
		return basePath .. "quality_roll_orange.png"
	elseif quality == QualityType.Red then
		return basePath .. "quality_roll_red.png"
	end
	--print("quality 不正确",quality)
	return basePath .. "quality_roll_white.png"
end

function GetColorBottomByQuality(quality)
	local basePath = "ui/common/icon/"
	-- if quality == QualityType.White then	
	-- 	return  basePath .. "quality_white_di.png"
	-- elseif quality == QualityType.Green then
	-- 	return basePath .. "quality_green_di.png"
	-- elseif quality == QualityType.Blue then
	-- 	return basePath .. "quality_blue_di.png"
	-- elseif quality == QualityType.Purple then
	-- 	return basePath .. "quality_purple_di.png"
	-- elseif quality == QualityType.Orange then
	-- 	return basePath .. "quality_orange_di.png"
	-- elseif quality == QualityType.Red then
	-- 	return basePath .. "quality_red_di.png"
	-- end
	--print("quality 不正确",quality)
	-- return basePath .. "quality_white_di.png"
	return basePath .. "quality_0.png"
end

function GetColorRollBottomByQuality(quality)
	local basePath = "ui/common/icon/"
	-- if quality == QualityType.White then	
	-- 	return  basePath .. "quality_roll_white_di.png"
	-- elseif quality == QualityType.Green then
	-- 	return basePath .. "quality_roll_green_di.png"
	-- elseif quality == QualityType.Blue then
	-- 	return basePath .. "quality_roll_blue_di.png"
	-- elseif quality == QualityType.Purple then
	-- 	return basePath .. "quality_roll_purple_di.png"
	-- elseif quality == QualityType.Orange then
	-- 	return basePath .. "quality_roll_orange_di.png"
	-- elseif quality == QualityType.Red then
	-- 	return basePath .. "quality_roll_red_di.png"
	-- end
	-- --print("quality 不正确",quality)
	-- return basePath .. "quality_roll_white_di.png"
	return basePath .. "quality_roll_0.png"
end

-- 通过id获得神器展示图
function GetArtifactIconById( id )
	return "icon/artifactbig/" .. id .. ".png"
end

-- 通过id获得神器Icon
function GetArtifactImgIconById( id )
	return "icon/artifact/" .. id .. ".png"
end

-- 通过id获得神器碎片Icon
function GetArtifactFragById( id )
	return "icon/artifact/" .. id .. ".png"
end
-- 通过品质获得神器底框
function GetArtifactBgByQuality( quality )
	return "ui/shenqi/bg_shenqi" .. quality .. ".png"
end

-- 通过品质获得神器名字底图
function GetArtifactNameBgByQuality( quality )
	-- return "ui/shenqi/bg_name" .. quality .. ".png"
	return "ui/fabao/bg_name.png"
end

-- 通过kind获得天书 头建筑图
function GetBookWorldTopImgBykind( kind )
	return "ui/bookworld/top_" .. kind ..".png"
end

-- 通过id获得天书建筑图
function GetBookWorldImgByid( id )
	return "icon/bookworld/" .. id .. ".png"
end

-- 通过id获得天书研究icon
function GetBookWorldResearImgByid( id )
	return "icon/bookworld/research/" .. id .. ".png"
end

-- 通过宠物累心获得宠物标签
function GetPetTagByType( type )

	if type == EnumPetType.Life then--生命
		return "ui/pet/sx_02.png"
	elseif type == EnumPetType.Attack then--攻击
		return "ui/pet/sx_01.png"
	elseif type == EnumPetType.PhyDef then--物防
		return "ui/pet/sx_04.png"
	elseif type == EnumPetType.MagDef then--法防
		return "ui/pet/sx_05.png"
	elseif type == EnumPetType.Speed then--速度
		return "ui/pet/sx_03.png"
	end
	print("type 不正确",type)
	return "ui/pet/sx_01.png"
end

function GetPetDivisionImgByValue( value )
	return "ui/pet/text_jie" .. value .. ".png"
end

--通过品质获得颜色图标 (圆圈)
function GetColorRoadIconByQuality( quality )
	if quality == QualityType.White then	
		return "ui/army/js_shangzhenweibai_icon.png"
	elseif quality == QualityType.Green then
		return "ui/army/js_shangzhenweilv_icon.png"
	elseif quality == QualityType.Blue then
		return "ui/army/js_shangzhenweilan_icon.png"
	elseif quality == QualityType.Purple then
		return "ui/army/js_shangzhenweizi_icon.png"
	elseif quality == QualityType.ChuanShuo then
		return "ui/army/js_shangzhenweich_icon.png"
	end
	print("quality 不正确",quality)
	return "ui/army/js_shangzhenweibai_icon.png"
end

--获取进度条资源
function GetColorLoadingImgByLevel( level )
	-- local lv = math.floor(level / 5)
	local num = level % 5
	if num == 0 then
		return "ui/equipment/bar01_04.png"
	elseif num == 1 then
		return "ui/equipment/bar01_02.png"
	elseif num == 2 then
		return "ui/equipment/bar01_05.png"
	elseif num == 3 then
		return "ui/equipment/bar01_03.png"
	elseif num == 4 then
		return "ui/equipment/bar01_01.png"
	end

	return "ui/equipment/bar01_02.png"
end

--获得角色水平的品质描述   eg:神话
function GetRoleHorizontalIconByQuality(quality)
	local path = "ui/common/icon/quality_" .. quality .. ".png"
	if not TFFileUtil:existFile(path) then
		print("quality 不正确",quality)
		return
	end
	return path
end

--获得角色垂直的品质描述   eg:神话
function GetRoleVerticalIconByQuality(quality)
	local path = "ui/common/icon/quality_" .. quality .. ".png"
	if not TFFileUtil:existFile(path) then
		print("quality 不正确",quality)
		return
	end
	return path
end

--卡牌职业
-- EnumCareerType = 
-- {
-- 	"All",		--全部
-- 	"Dps", 		--输出
-- 	"Def",		--防御
-- 	"Heal",		--治疗
-- 	"Control", 	--控制
-- }
function GetRoleCareerIconByCareer(career)
	local basePath = "ui/common/icon/"
	if career == EnumCareerType.Dps then
		return basePath .. "icon_dps.png"
	elseif career == EnumCareerType.Def then
		return basePath .. "icon_def.png"
	elseif career == EnumCareerType.Heal then
		return basePath .. "icon_heal.png"
	elseif career == EnumCareerType.Control then
		return basePath .. "icon_control.png"
	end
	print("not career .")
end

function GetRoleCareerImgByCareer(career)
	local basePath = "ui/role/"
	if career == EnumCareerType.Dps then
		return basePath .. "n_t_shuchu.png"
	elseif career == EnumCareerType.Def then
		return basePath .. "n_t_fangyu.png"
	elseif career == EnumCareerType.Heal then
		return basePath .. "n_t_zhiliao.png"
	elseif career == EnumCareerType.Control then
		return basePath .. "n_t_kongzhi.png"
	end
	print("not career .")
end

function GetRolePrefesstionIconByDamageType( damageType )
	--1:物理，2法术
	local basePath = 'ui/role/'
	if damageType == 1 then
	    return basePath .. 'wulishuchutubiao.png'
	elseif damageType == 2 then
	    return basePath .. 'mofashuchutubiao.png'
	end
	print('not damagetType')
end

--获取角色星级图标
function GetRoleStarIcons(star)
	local iconPaths = {}
	local level = math.floor(star / 5)
	local num = star % 5
	for i=1,5 do
		local iconPath = "ui/common/icon/icon_break"
		if i <= num then
			iconPath = iconPath .. level + 1 .. ".png"
		else
			iconPath = iconPath .. level .. ".png"
		end
		iconPaths[i] = iconPath
	end
	return iconPaths
end

--获取法宝星级图标
function GetTalismanStarIcons(star)
	local iconPaths = {}
	local level = math.floor(star / 5)
	local num = star % 5
	for i=1,5 do
		local iconPath = "ui/common/icon/icon_break"
		if i <= num then
			iconPath = iconPath .. level + 1 .. ".png"
		else
			if level == 0 then 
				iconPath = nil
			else
				iconPath = iconPath .. level .. ".png"
			end
		end
		iconPaths[i] = iconPath
	end
	return iconPaths
end

--获取装备星级图标
function GetEquipmentStarIcons(star)
	local iconPaths = {}
	local level = math.floor(star / 5)
	local num = star % 5
	for i=1,5 do
		local iconPath = "ui/common/icon/img_star"
		if i <= num then
			iconPath = iconPath .. level + 1 .. ".png"
		else
			if level == 0 then 
				iconPath = nil
			else
				iconPath = iconPath .. level .. ".png"
			end
			-- iconPath = iconPath .. level .. ".png"
		end
		iconPaths[i] = iconPath
	end
	return iconPaths
end

--碎片遮罩图标
function GetFragIconByQuality(quality)
	local basePath = "ui/common/icon/"
	if quality == QualityType.White then	
		return  basePath .. "qualityh_white.png"
	elseif quality == QualityType.Green then
		return basePath .. "qualityh_green.png"
	elseif quality == QualityType.Blue then
		return basePath .. "qualityh_blue.png"
	elseif quality == QualityType.Purple then
		return basePath .. "qualityh_purple.png"
	elseif quality == QualityType.Orange then
		return basePath .. "qualityh_orange.png"
	elseif quality == QualityType.Red then
		return basePath .. "qualityh_red.png"
	end
	--print("quality 不正确",quality)
	return basePath .. "qualityh_white.png"
end

--神器碎片图标
function GetArtifactFragIconByQuality(quality, index)
	-- local basePath = "ui/common/icon/"
	local basePath = "ui/fabao/"
	if quality == QualityType.White then	
		return  basePath .. "qualityh_white.png"
	elseif quality == QualityType.Green then
		return basePath .. "qualityh_green.png"
	elseif quality == QualityType.Blue then
		return basePath .. "qualityh_blue_" .. index .. ".png"
	elseif quality == QualityType.Purple then
		return basePath .. "qualityh_purple_" .. index .. ".png"
	elseif quality == QualityType.Orange then
		return basePath .. "qualityh_orange_" .. index .. ".png"
	elseif quality == QualityType.Red then
		return basePath .. "qualityh_red_" .. index .. ".png"
	end

	--print("quality 不正确",quality)
	return basePath .. "qualityh_white.png"
end

--根据资源是否足够获取颜色
function GetColorByResIsEnough(enough)
	if enough then
		return ccc3(127,255,0)
	else
		return ccc3(255,0,4)
	end
end

function GetTimeString(totalSecond)
    local hour = math.floor(totalSecond/3600)
    local min = math.floor((totalSecond - hour*3600)/60)
    local day = math.floor(hour/24)

    local string = ""

    if day > 0 then
        --string = string..day.."天前"
        string = string.. stringUtils.format(localizable.common_day_befor,day)
    end

    if hour > 0 and day == 0 then
        --string = string..hour.."小时前"
        string = string..stringUtils.format(localizable.common_hour_befor,hour)        
    end

    -- if min > 0 and hour == 0 then
    --     string = string..min.."分钟前"
    -- end

    if hour == 0 then
        if min > 0 then
            --string = string..min.."分钟前"
            string = string..stringUtils.format(localizable.common_min_befor,min)
        else
            --string = "刚刚"
            string = localizable.common_justnow
        end
    end


    return string
end

function GetTalismanLevelLimitByQuality(quality)
	local level = 0
	if QualityType.Blue == quality then
		level = ConstantData:getValue("Talisman.Blue.Level.Limit")
	elseif QualityType.Purple == quality then
		level = ConstantData:getValue("Talisman.Purple.Level.Limit")
	elseif QualityType.Orange == quality then
		level = ConstantData:getValue("Talisman.Orange.Level.Limit")
	elseif QualityType.Red == quality then
		level = ConstantData:getValue("Talisman.Red.Level.Limit")
	end
	return level
end

--[[
	获取资源图标，这里的资源指的是玩家数值数据，例如铜币、元宝、悟性点等
]]
function GetResourceIcon(resType)
	if resType == EnumResourceType.Coin then
		return "ui/common/icon/icon_money.png"
	elseif resType == EnumResourceType.Sycee then
		return "ui/common/icon/icon_gold.png"
	elseif resType == EnumResourceType.Strengh then
		return "ui/common/icon/icon_tili.png"
	elseif resType == EnumResourceType.RoleCard then
		return "ui/common/icon/icon_exp.png"
	elseif resType == EnumResourceType.GroupExp then
		return "ui/common/icon/icon_exp.png"
	--银玉签
	elseif resType == EnumResourceType.SilverLot then
		return "ui/common/icon/icon_yyq.png"
	--金玉签
	elseif resType == EnumResourceType.GoldenLot then
		return "ui/common/icon/icon_jyq.png"
	--侠义值
	elseif resType == EnumResourceType.Errantry then
		return "ui/common/icon/icon_xyz.png"
	--鬼神之塔货币
	elseif resType == EnumResourceType.GhostTowerCoin then
		return "ui/common/icon/icon_gsb.png"
	--竞技场货币
	elseif resType == EnumResourceType.ArenaCoin then
		return "ui/common/icon/icon_ly.png"
	--武道会货币
	elseif resType == EnumResourceType.WudaohuiCoin then
		return "ui/common/icon/icon_sjb.png"
		
	--建木通天货币
	elseif resType == EnumResourceType.HeroHillCoin then
		return "ui/common/icon/icon_jmjy.png"
	elseif resType == EnumResourceType.XianYuanCoin then
		return "ui/common/icon/icon_xianyuzhi.png"
	--木材
	elseif resType == EnumResourceType.Wood then
		return "ui/common/icon/icon_mu.png"
	--石矿
	elseif resType == EnumResourceType.Stone then
		return "ui/common/icon/icon_shi.png"
	--金属
	elseif resType == EnumResourceType.Metal then
		return "ui/common/icon/icon_jin.png"
	elseif resType == EnumResourceType.GuildContribution then
		return "ui/common/icon/icon_banggong.png"
	end
	-- -- vip积分
	-- elseif resType == EnumResourceType.VIP_SCORE then
	-- 	return "ui_new/common/icon_vip.png"
	-- elseif resType == EnumResourceType.XIAYI then
	-- 	return "ui_new/common/icon_xiayi.png"
	-- elseif resType == EnumResourceType.FACTION_GX then
	-- 	return "ui_new/faction/icon_gongxian.png"
	-- elseif resType == EnumResourceType.VESSELBREACH then
	-- 	return "ui_new/climb/wl_jinglu_s.png"
	-- elseif resType == EnumResourceType.CLIMBSTAR then
	-- 	return "ui_new/climb/wl_xingxing.png"
	-- elseif resType == EnumResourceType.YUELI then
	-- 	return "ui_new/tianshu/img_yueli.png"
	-- elseif resType == EnumResourceType.SHALU_VALUE then
	-- 	return "ui_new/youli/skillscore.png"
	-- elseif resType == EnumResourceType.TEMP_COIN then
	-- 	return "ui_new/common/icon_coin.png"
	-- elseif resType == EnumResourceType.TEMP_YUELI then
	-- 	return "ui_new/tianshu/img_yueli.png"
	-- elseif resType == EnumResourceType.LOWHONOR then
	-- 	return "ui_new/wulin/icon_ryl4.png"
	-- elseif resType == EnumResourceType.HIGHTHONOR then
	-- 	return "ui_new/wulin/icon_ryl3.png"
	-- end

	
	print("没有这个资源类型的图片 : ",resType)
	return GetDefaultIcon()
end

--根据资源类型 通过常量表获取对应的道具模版id
function GetIDByResourceType(resType)
	if resType == EnumResourceType.Coin then
		return ConstantData:getResID("Lucky.Charm.itemid")
	elseif resType == EnumResourceType.Strengh then
		return ConstantData:getResID("Strengh.Pill.itemid")
	elseif resType == EnumResourceType.Arena then
		return ConstantData:getResID("Arena.Pill.itemid")
	elseif resType == EnumResourceType.Spirit then
		return ConstantData:getResID("Spirit.Pill.itemid")
	end

	print("常量表中没有对应的资源类型的模版id  resType:", resType)
	return 0
end

function getVipFunctionIdByResourceType(resType)
	if resType == EnumResourceType.Coin then
		return EnumVipFunctionID.Coin
	elseif resType == EnumResourceType.Strengh then
		return EnumVipFunctionID.Strengh
	elseif resType == EnumResourceType.Arena then
		return EnumVipFunctionID.Arena
	elseif resType == EnumResourceType.Spirit then
		return EnumVipFunctionID.Spirit
	end

	print("Vip功能中没有对应的资源类型的模版id  resType:", resType)
	return 0
end

--[[
	获取资源图标，这里的资源指的是玩家数值数据，例如铜币、元宝、体力等
]]
function GetResourceIconForGeneralHead(resType)
	if resType == HeadResType.Coin then
		return "ui/common/icon/icon_money.png"
	elseif resType == HeadResType.Sycee then
		return "ui/common/icon/icon_gold.png"
	--体力
	elseif resType == HeadResType.Vitality then
		return "ui/common/icon/icon_tili.png"
	--精力
	elseif resType == HeadResType.SpiritPoint then
		return "ui/common/icon/icon_vitality.png"
	--竞技场币
	elseif resType == HeadResType.Arena then
		return "ui/common/icon/icon_jjc.png"
	elseif resType == HeadResType.GuildContribution then
		return "ui/common/icon/icon_banggong.png"


	-- 建木经元
	elseif resType == HeadResType.Bloody then
		return "ui/common/icon/icon_jmjy.png"
	-- 鬼神币
	elseif resType == HeadResType.Tower then
		return "ui/common/icon/icon_gsb.png"
	--龙玉
	elseif resType == HeadResType.LongYu then
		return "ui/common/icon/icon_ly.png"
	-- 金玉签
	elseif resType == HeadResType.GoldenLot then
		return "ui/common/icon/icon_jyq.png"
	-- 银玉签
	elseif resType == HeadResType.SilverLot then
		return "ui/common/icon/icon_yyq.png"
	--侠义值
	elseif resType == HeadResType.XiaYi then
		return "ui/common/icon/icon_xyz.png"
	--抽签货币
	elseif resType == HeadResType.CommonLot then
		return "ui/common/icon/icon_qian.png"
	--竞技场币
	elseif resType == HeadResType.ArenaLot then
		return "ui/common/icon/icon_ly.png"
	--武道会币
	elseif resType == HeadResType.WudaohuiLot then
		return "ui/common/icon/icon_sjb.png"
	elseif resType == HeadResType.LotCoin then
		return "ui/common/icon/icon_xianyuzhi.png"
	elseif resType == HeadResType.BookWorldAccelerate then
		return "ui/common/icon/icon_jia.png"
	elseif resType == HeadResType.BookWorldSteal then
		return "ui/common/icon/icon_box.png"
	end

	
	print("没有这个资源类型的图片 : ",resType)
	return GetDefaultIcon()
end

--[[
	通过资源类型获取资源数值
]]
function getResValueByTypeForGeneralHead(resType)
	if resType == HeadResType.Coin then
		return Utils:getSystemShowText(MainPlayer:getCoin())
	elseif resType == HeadResType.Sycee then
		return Utils:getSystemShowText(MainPlayer:getSycee())
	elseif resType == HeadResType.Vitality then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
		return Utils:getSystemShowText(times:getLeftValue())  .. "/" .. times.maxValue
	elseif resType == HeadResType.SpiritPoint then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.SpiritPoint)
		return Utils:getSystemShowText(times:getLeftValue())  .. "/" .. times.maxValue
	elseif resType == HeadResType.Arena then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.ArenaPoint)	
		return Utils:getSystemShowText(times:getLeftValue())
	elseif resType == HeadResType.GuildContribution then
	 	return Utils:getSystemShowText(GuildManager:getGuildContribution())
	elseif resType == HeadResType.Bloody then
		return Utils:getSystemShowText(MainPlayer.heroHillCoin) or 0
	elseif resType == HeadResType.Tower then
		return Utils:getSystemShowText(MainPlayer.ghostTowerCoin)
	elseif resType == HeadResType.LongYu then
		return Utils:getSystemShowText(MainPlayer.arenaCoin)
	elseif resType == HeadResType.GoldenLot then
		return Utils:getSystemShowText(MainPlayer.goldenLotCoin)
	elseif resType == HeadResType.SilverLot then
		return Utils:getSystemShowText(MainPlayer.silverLotCoin)
	elseif resType == HeadResType.XiaYi then
		return Utils:getSystemShowText(MainPlayer.errantry)
	--抽签货币
	elseif resType == HeadResType.CommonLot then
		local one_id = ConstantData:getValue("Ordinary.Card.One")
    	local one_data = LotteryConsumeData:objectByID(one_id)
    	local one_coinNum = BagManager:getGoodsNumByTplId(one_data.goods_id)
    	return Utils:getSystemShowText(one_coinNum)
    elseif resType == HeadResType.ArenaLot then
		return Utils:getSystemShowText(MainPlayer.arenaCoin)
	elseif resType == HeadResType.WudaohuiLot then
		print("++++WudaohuiLot+++112+++",MainPlayer.wudaohuiCoin)
    	return Utils:getSystemShowText(MainPlayer.wudaohuiCoin)
    elseif resType == HeadResType.LotCoin then
    	return Utils:getSystemShowText(MainPlayer:getLotteryCoin())
    elseif resType == HeadResType.BookWorldAccelerate then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.BookWorldAccelerate)
		return Utils:getSystemShowText(times:getLeftValue())  .. "/" .. times.maxValue
	elseif resType == HeadResType.BookWorldSteal then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.BookWorldSteal)
		return Utils:getSystemShowText(times:getLeftValue())  .. "/" .. times.maxValue
	end
	print("unknow res type : ",resType)
	return 0
end

function GetResourceNameForGeneralHead(resType)
	return localizable.ResourceNameForGeneralHead[resType]
end

function getResValueByType(resType)
	if resType == EnumResourceType.Coin then
		return MainPlayer:getCoin()
	elseif resType == EnumResourceType.Sycee then
		return MainPlayer:getSycee()
	elseif resType == EnumResourceType.Strengh then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
		return times:getLeftValue()
	elseif resType == EnumResourceType.ArenaCoin then
		return MainPlayer.arenaCoin
	elseif resType == EnumResourceType.WudaohuiCoin then
		return MainPlayer.wudaohuiCoin
	elseif resType == EnumResourceType.XianYuanCoin then
		return MainPlayer.lotteryCoin
	elseif resType == EnumResourceType.HeroHillCoin then
		return MainPlayer.heroHillCoin or 0
	elseif resType == EnumResourceType.GhostTowerCoin then
		return MainPlayer.ghostTowerCoin
	elseif resType == EnumResourceType.ArenaCoin then
		return MainPlayer.arenaCoin
	elseif resType == EnumResourceType.GoldenLot then
		return MainPlayer.goldenLotCoin
	elseif resType == EnumResourceType.SilverLot then
		return MainPlayer.silverLotCoin
	elseif resType == EnumResourceType.Errantry then
		return MainPlayer.errantry
	elseif resType == EnumResourceType.GuildContribution then
		print("GuildManager:getGuildContribution()", GuildManager:getGuildContribution())
		return GuildManager:getGuildContribution()
	end
	print("unknow res type : ",resType)
	return 0
end

function getResValueByTypeAndTplId( resType,tplId )
	--1.玩家身上，2，背包
	if resType == EnumResourceType.Coin then
		return MainPlayer:getCoin()
	elseif resType == EnumResourceType.Sycee then
		return MainPlayer:getSycee()
	elseif resType == EnumResourceType.Strengh then
		local times = MainPlayer:GetChallengeTimesInfo(EnumTimeRecoverType.Vitality)
		return times:getLeftValue()
	elseif resType == EnumResourceType.ArenaCoin then
		return MainPlayer.arenaCoin
	elseif resType == EnumResourceType.WudaohuiCoin then
		return MainPlayer.wudaohuiCoin
	elseif resType == EnumResourceType.XianYuanCoin then
		return MainPlayer.lotteryCoin
	elseif resType == EnumResourceType.HeroHillCoin then
		return MainPlayer.heroHillCoin or 0
	elseif resType == EnumResourceType.GhostTowerCoin then
		return MainPlayer.ghostTowerCoin
	elseif resType == EnumResourceType.ArenaCoin then
		return MainPlayer.arenaCoin
	elseif resType == EnumResourceType.GoldenLot then
		return MainPlayer.goldenLotCoin
	elseif resType == EnumResourceType.SilverLot then
		return MainPlayer.silverLotCoin
	elseif resType == EnumResourceType.Errantry then
		return MainPlayer.errantry
	elseif resType == EnumResourceType.GuildContribution then
		print("GuildManager:getGuildContribution()", GuildManager:getGuildContribution())
		return GuildManager:getGuildContribution()
	end
	return BagManager:getGoodsNumByTypeAndTplId(resType,tplId)
	-- print("unknow res type : ",resType)
end

--[[
	通过资源类型获取资源数值的表达式，显示样式，会根据数值范围自动转换成特定表达式，例如：10000000返回为1000w
]]
function getResValueExpressionByTypeForGH(resType)
	local value = getResValueByTypeForGH(resType)
	if value and type(value) == "number" and value > 1000000 then
		local fuck  = value/10000
		local floatValue = string.format("%.0f",fuck)
		--return floatValue .."万"
		floatValue = stringUtils.format(localizable.fun_wan_desc,floatValue)
		return floatValue
	else 
		return value
	end
end

--判断资源是否可以购买
function canBuyResource(resType)
	if resType == HeadResType.Coin then
		return true
	elseif resType == HeadResType.Sycee then
		return true
	elseif resType == HeadResType.Vitality then
		return true
	elseif resType == HeadResType.Arena then
		return true
	-- elseif resType == HeadResType.CLIMB then
	-- 	return true  --界面逻辑优化建议 2015/10/10
	-- elseif resType == HeadResType.SKILL_POINT then
	-- 	return true
		
	-- elseif resType == HeadResType.JIEKUANGLING then
	-- 	return true
	-- elseif resType == HeadResType.BAOZI then
	-- 	return true
	end
	return false
end

--判断资源是否可自动回复
function canRefreshResource(type)
	if HeadResType.Vitality == type then
		return true
	elseif  HeadResType.Arena == type then
		return true
	end
	return false
end

--获取功能模块图标
function getFunctionIcon(functionId)
	local path = "icon/function/" .. functionId .. ".png"
	if not TFFileUtil:existFile(path) then
		functionId = math.floor(functionId/100)*100
		return "icon/function/" .. functionId .. ".png"
	end
	return path
end

function getIsFragByResType(resType)
	if resType == EnumResourceType.MaterialFrag then
		return true
	elseif resType == EnumResourceType.RoleFrag then
		return true
	elseif resType == EnumResourceType.EquipFrag then
		return true
	elseif resType == EnumResourceType.ArtifactFrag then
		return true
	end
	return false
end

function getStringTable(content)
	local tbl = {}
	local length = string.utf8len(content)
	for i=1, length do
		tbl[i] = SubStringUTF8(content, i, i)
	end
	return tbl
end


function getStringTableTest(content)
	local tbl = {}
	local length = string.utf8len(content)

	for i=1, length do
		tbl[i] = SubStringUTF8(content, i, i)
		local m = string.byte(tbl[i])
		if m <= 127 then
			tbl[i] = tbl[i] .. " "
		end		
	end

	local str = ""
	for i=1,length do
		str = str .. tbl[i]
	end
	return str
end

--截取中英混合的UTF8字符串，endIndex可缺省
function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

function getSkillTypeIcon(type)
	if type == EnumSkillType.NormalAttack then
	elseif type == EnumSkillType.ActiveSkill then
		return "ui/role/n_icon_zhu.png"
	elseif type == EnumSkillType.PasSkill then
		return "ui/role/n_icon_bei.png"
	elseif type == EnumSkillType.AwakeSkill then
	end
	print("没有此类型的技能类型图标", type)
	return ""
end

function getCardStarLimit(quality, isMain)
	if isMain == true then
		return ConstantData:getValue("Card.Red.Star.Limit")
	end
	for k,v in pairs(QualityType) do
		if v == quality then
			return ConstantData:getValue("Card." .. k .. ".Star.Limit")
		end
	end
	return 0
end

function GetVipLevelImg( level )
	local path = "ui/chat/VIP" .. level .. ".png"
	if TFFileUtil:existFile(resPath) then
		return path		
	end
	return nil
end

function AddRightBtnActions(btn)
	local positX = btn:getPositionX()
     local toastTween = {
        target = btn,
        repeated = 0,
        {
          duration = 0.5,
          x = positX + 5,
        },
        {
          duration = 0.5,
          x = positX - 5,
        },
      }
    TFDirector:toTween(toastTween)
end

function AddLeftBtnActions(btn)
	local positX = btn:getPositionX()
    local toastTween = {
       target = btn,
       repeated = 0,
       {
         duration = 0.5,
         x = positX - 5,
       },
       {
         duration = 0.5,
         x = positX + 5,
       },
    }
    TFDirector:toTween(toastTween)
end

function AddBreatheAction(widget,alphaValue)
    if alphaValue == nil then alphaValue = 0.5 end
	local toastTween = {
       target = widget,
       repeated = 0,
       {
         duration = 0.75,
         alpha = alphaValue,
       },
       {
         duration = 0.75,
         alpha = 1,
       },
    }
    TFDirector:toTween(toastTween)
	return toastTween
end

function AddBreatheAction2(widget)
	widget._orginScale = widget:getScale()
    local toastTween = {
       target = widget,
       repeated = 0,
       {
         duration = 0.9,
		 scale = widget._orginScale * 1.05,
       },
       {
         duration = 0.9,
         scale = widget._orginScale * 0.95,
       },
    }
    TFDirector:toTween(toastTween)
    return toastTween
end

function GetSceneTypeBySceneId(sceneId, chapterId)
	if sceneId == EnumSceneType.BigWorld then
		return SceneType.BIGWORLD
	elseif sceneId == EnumSceneType.Challenge then
		return SceneType.CHALLENGE
	elseif sceneId == EnumSceneType.Home then
		return SceneType.HOME
	elseif sceneId == EnumSceneType.Mall then
		return SceneType.MALL
	elseif sceneId == EnumSceneType.Tavern then
		return SceneType.TAVERN
	elseif sceneId == EnumSceneType.Guild then
		return SceneType.GUILD
	end
	
	return GetChapterSceneType(chapterId)
end 

--根据场景id获得场景的名字
function GetSceneNameBySceneId(sceneId)
	if sceneId == EnumSceneType.BigWorld then
		return "BigWorldScene"
	elseif sceneId == EnumSceneType.Challenge then
		return "ChallengeScene"
	elseif sceneId == EnumSceneType.Home then
		return "HomeScene"
	elseif sceneId == EnumSceneType.Mall then
		return "MallScene"
	elseif sceneId == EnumSceneType.Tavern then
		return "TavernScene"
	elseif sceneId == EnumSceneType.Guild then
		return "GuildScene"
	end
	print("not find sceneId :", sceneId)
	return nil
end

function GetSceneIdBySceneName(name)
	if name == "BigWorldScene" then
		return EnumSceneType.BigWorld
	elseif name == "ChallengeScene" then
		return EnumSceneType.Challenge
	elseif name == "HomeScene" then
		return EnumSceneType.Home
	elseif name == "MallScene" then
		return EnumSceneType.Mall
	elseif name == "TavernScene" then
		return EnumSceneType.Tavern
	elseif name == "GuildScene" then
		return EnumSceneType.Guild
	end
	print("not find sceneName :", name)
	return nil
end

--检测sceneId是否为当前场景   
function CheckCurrentSceneBySceneId(sceneId)
	local currentScene = Public:currentScene()
	local name = GetSceneNameBySceneId(sceneId)
	if currentScene.__cname == name then
		return true
	end
	return false
end

function GetChapterSceneType(chapterId)
	if chapterId then
		local chapterData = ChapterData:objectByID(chapterId)
		
		if chapterData then
			if chapterData.type == EnumMissionType.Dungeon then
				return SceneType.GUILDDREAMLAND
			end
		end
	end
	
	return SceneType.MISSION
end 

function GetChatTypeIconByType(type)
	return "ui/chat/t" .. tonumber(type) .. ".png"
end

--[[
	策划标签的字符串替换
	"<c0>" -> "<font color='#1cb7ff'>"
	"<c1>" -> "<font color='#fe3232'>"
	"<c2>" -> "<font color='#6fd60b'>"
	"<c3>" -> "<font color='#1ab3ff'>"
	"<c>" -> "</font>"
]]
function gsubString( msg )
	msg = string.gsub(msg, "<c0>", "<font color='#1cb7ff'>")
	msg = string.gsub(msg, "<c1>", "<font color='#fe3232'>")
	msg = string.gsub(msg, "<c2>", "<font color='#6fd60b'>")
	msg = string.gsub(msg, "<c3>", "<font color='#1ab3ff'>")
	msg = string.gsub(msg, "<c>","</font>")
	return msg
end

function gsubString1( msg )
	msg = string.gsub(msg, "<c0>", "<font color='#3D3D3D'>")
	msg = string.gsub(msg, "<c1>", "<font color='#6B6B6B'>")
	msg = string.gsub(msg, "<c2>", "<font color='#6CB705'>")
	msg = string.gsub(msg, "<c3>", "<font color='#348DC4'>")
	msg = string.gsub(msg, "<c4>", "<font color='#D748D4'>")
	msg = string.gsub(msg, "<c5>", "<font color='#E87B2B'>")
	msg = string.gsub(msg, "<c6>", "<font color='#C93636'>")
	msg = string.gsub(msg, "<c7>", "<font color='#2D4157'>")
	msg = string.gsub(msg, "<c8>", "<font color='#88573d'>")
	msg = string.gsub(msg, "<c10>", "<font color='#864f2e'>")
	msg = string.gsub(msg, "<c>", "</font>")
	msg = string.gsub(msg, "<b>", "<br/>")
	return msg
end

function gsubString3( msg )
	msg = string.gsub(msg, "<c0>", "<font color='#373737'>")
	msg = string.gsub(msg, "<c1>", "<font color='#fe3232'>")
	msg = string.gsub(msg, "<c2>", "<font color='#6fd60b'>")
	msg = string.gsub(msg, "<c3>", "<font color='#1ab3ff'>")
	msg = string.gsub(msg, "<c>","</font>")
	return msg
end

function RichTextFont(content, color, fontSize)
	local szContent = nil
	if color and fontSize then
		szContent = [[<font color="%s" fontSize="%s">%s</font>]]
		content = string.format(szContent, color, fontSize, content)
	elseif color then
		szContent = [[<font color="%s">%s</font>]]
		content = string.format(szContent, color, content)
	elseif fontSize then
		szContent = [[<font fontSize="%s">%s</font>]]
		content = string.format(szContent, fontSize, content)
	else
		szContent = [[<font>%s</font>]]
		content = string.format(szContent, content)
	end
	return content
end

function GetMapDataById(mapId)
	if not mapId or type(mapId) ~= "number" then return nil end
	
	local mapData = require("lua.map.map" .. mapId .. ".lua")
	if mapData and mapData.data then
		return GetMapDataByString(mapData.data)
	end
	return nil
end


function AddGainAction(widget)
    local toastTween = {
       target = widget,
       repeated = 0,
       {
         duration = 0.075,
         rotate = 6,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         rotate = -6,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         rotate = 4,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         rotate = -4,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         rotate = 2,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         rotate = -2,
       },
       {
         duration = 0.075,
         rotate = 0,
       },
       {
         duration = 0.075,
         delay = 1,
       }
    }
    TFDirector:toTween(toastTween)
end

























































function GetColorRoadIconByQualitySmall( quality )
    if quality == QualityType.White then 
        return "ui/army/gk_head_ding_bg.png"
    elseif quality == QualityType.Green then
        return "ui/army/gk_head_bing_bg.png"
    elseif quality == QualityType.Blue then
        return "ui/army/gk_head_yi_bg.png"
    elseif quality == QualityType.Purple then
        return "ui/army/gk_head_jia_bg.png"
	elseif quality == QualityType.ChuanShuo then
		return "ui/army/gk_head_ch_bg.png"
    end
    print("quality 不正确",quality)
    return "ui/army/gk_head_jia_bg.png"
end

--通过品质获得颜色图标  124
function GetColorIconByQuality( quality )
	local basePath = "ui/common/icon_bg"
	if quality == QualityType.White then
		return basePath .. "/pz_bg_ding_124.png"
	elseif quality == QualityType.Green then
		return basePath .. "/pz_bg_bing_124.png"
	elseif quality == QualityType.Blue then
		return basePath .. "/pz_bg_yi_124.png"
	elseif quality == QualityType.Purple then
		return basePath .. "/pz_bg_jia_124.png"
	elseif quality == QualityType.ChuanShuo then
		return basePath .. "/cheng_124.png"
	end
	print("quality 不正确",quality)
	return basePath .. "/pz_bg_ding_124.png"
end
--通过品质获得颜色图标  124
function GetColorIconByQuality_118( quality )
	local basePath = "ui/common/icon_bg"
	if quality == QualityType.White then
		return basePath .. "/pz_bg_ding_118.png"
	elseif quality == QualityType.Green then
		return basePath .. "/pz_bg_bing_118.png"
	elseif quality == QualityType.Blue then
		return basePath .. "/pz_bg_yi_118.png"
	elseif quality == QualityType.Purple then
		return basePath .. "/pz_bg_jia_118.png"
	elseif quality == QualityType.ChuanShuo then
		return basePath .. "/cheng_118.png"
	end
	print("quality 不正确",quality)
	return basePath .. "/pz_bg_ding_118.png"
end
--通过品质获得颜色图标  82
function GetColorIconByQuality_82( quality )
	local basePath = "ui/common/icon_bg"
	if quality == QualityType.White then
		return basePath .. "/pz_bg_ding_82.png"
	elseif quality == QualityType.Green then
		return basePath .. "/pz_bg_bing_82.png"
	elseif quality == QualityType.Blue then
		return basePath .. "/pz_bg_yi_82.png"
	elseif quality == QualityType.Purple then
		return basePath .. "/pz_bg_jia_82.png"
	elseif quality == QualityType.ChuanShuo then
		return basePath .. "/cheng_82.png"
	end
	print("quality 不正确",quality)
	return basePath .. "/pz_bg_ding_82.png"
end
--通过品质获得颜色图标  58
function GetColorIconByQuality_58( quality )
	local basePath = "ui/common/icon_bg"
	if quality == QualityType.White then
		return basePath .. "/58_baibiankuang_icon.png"
	elseif quality == QualityType.Green then
		return basePath .. "/58_lvbiankuang_icon.png"
	elseif quality == QualityType.Blue then
		return basePath .. "/58_lanbiankuang_icon.png"
	elseif quality == QualityType.Purple then
		return basePath .. "/58_zibiankuang_icon.png"
	elseif quality >= QualityType.ChuanShuo then
		return basePath .. "/58_chengbiankuang_icon.png"
	end
	print("quality 不正确",quality)
	return basePath .. "/58_baibiankuang_icon.png"
end

--获取默认图标图片路径(找不到图标或者图标缺失情况下使用)
function GetDefaultIcon()
	return "ui/common/icon/icon_vitality.png"
end

--通过品质获得颜色图标 
function GetBackgroundForGoods( goodsData )
	return GetColorIconByQuality(goodsData.quality)
end

--通过品质获得品质字 
function GetFontByQuality( quality )
	return "ui/common/icon/quality_".. quality .. ".png"
end

--通过品质获得品质字 
function GetAttributeByType( type )
	return "icon/attribute/".. type .. ".png"
end

function GetAttributeWordsByType( type )
	return localizable.role_attribute[type]
end

--通过属性系数获得属性颜色 
function GetCoefficientColorByNum( num )
	if num >= 0 and num < 0.5  then	
		return ccc3(255,255,255)
	elseif num >= 0.5 and num < 1 then
		return ccc3(0,255,0)
	elseif num >= 1 and num < 1.5 then
		return ccc3(0,0,255)
	elseif num >= 1.5 then
		return ccc3(153,50,205)
	end
	print("quality 不正确",quality)
end


function GetEquiptypeStrByType( equiptype )
	--[[
	if equiptype == 1 then
		return "武器"
	elseif equiptype == 2 then
		return "衣服"
	elseif equiptype == 3 then
		return "戒指"
	elseif equiptype == 4 then
		return "腰带"
	elseif equiptype == 5 then
		return "靴子"
	end
	print("equiptype 不正确",equiptype)
	]]
	return localizable.Equip_Des[equiptype]

end

function GetHuntRewardTagByIndex( index )
	if index == 1 then
		return "ui/activity/jiaobiao2.png"
	elseif index == 2 then
		return "ui/activity/jiaobiao1.png"
	elseif index == 3 then
		return "ui/activity/jiaobiao3.png"
	end
	return ""
end
--[[
字符串转换为table
@expression 表达式
@delim 分隔符
@return table,length
]]
function stringToTable(expression,delim)
	local tbl = {}

	if expression == nil or expression == 0 or expression == "0" or expression == "" then
		return tbl,0
	end

	delim = delim or '|'

	local temptbl = string.split(expression,delim)
	local i = 0
	for k,v in pairs(temptbl) do
		i = i + 1
		tbl[i] = v
	end

	return tbl,i
end

--[[
字符串转换为table
@expression 表达式
@delim 分隔符
@return table,length
]]
function stringToNumberTable(expression,delim)
	local tbl = {}

	if expression == nil or expression == 0 or expression == "0" or expression == "" then
		return tbl,0
	end

	delim = delim or '|'

	local temptbl = string.split(expression,delim)
	local i = 0
	for k,v in pairs(temptbl) do
		i = i + 1
		tbl[i] = tonumber(v)
	end

	return tbl,i
end

--通过字符串获得属性的table表
function GetAttrByString(str)
	local tbl = {}

	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl
	end

	local temptbl = string.split(str,',')			--分解","
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		if temp[1] and temp[2] then
			tbl[tonumber(temp[1])] = tonumber(temp[2])
			--print( temp[1] .. "tbl[temp[1]] = " .. tbl[temp[1]])
		end		
	end

	return tbl
end

--为了解决附加属性按照固定顺序显示添加
function GetAttrByStringForExtra(str)
	local tbl = {}
	local tbl2 = {}

	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl,tbl2
	end

	local index = 1
	local temptbl = string.split(str,',')			--分解","
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		if temp[1] and temp[2] then
			tbl[tonumber(temp[1])] = tonumber(temp[2])
			tbl2[index] = tonumber(temp[1])
			index = index + 1
		end
	end
	tbl = tbl or {};
	tbl2 = tbl2 or {};
	return tbl,tbl2
end

--获取地图格式数据
function GetMapDataByString(str)
	local tbl = {}

	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl, 0, 0
	end

	local i,j = 1,1
	local temp1 = string.split(str, ',')
	for k,v in pairs(temp1) do
		tbl[i] = {}
		local temp2 = string.split(v, '|')
		
		j = 1
		for m,n in pairs(temp2) do
			tbl[i][j] = tonumber(n)
			j = j + 1
		end
		i = i + 1
	end
	return tbl, (i-1), (j-1)
end

--获取章节中的特殊数据 
function GetSpecilDataByString(str, mapId)
	local tbl = {}
	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl
	end

	local temp1 = stringToTable(str, ",")
	for k,v in pairs(temp1) do
		local temp2 = stringToNumberTable(v, "_")
		if temp2[1] == mapId then
			tbl[temp2[2]] = temp2
		end
	end
	return tbl
end

--获取章节中的特殊数据 
function GetTwoSpecilDataByString(str)
	local tbl = {}
	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl
	end

	local temp1 = stringToTable(str, ",")
	for k,v in pairs(temp1) do
		local temp2 = stringToNumberTable(v, "_")
		tbl[#tbl+1] = temp2
	end
	return tbl
end

function GetMapResByString(str)
	local tbl = {}
	if str == nil or str == 0 or str == "0" or str == "" then
		return tbl
	end
	local temp = stringToTable(str, "|")
	for k,v in pairs(temp) do
		tbl[#tbl+1] = stringToNumberTable(v, ",")
	end
	return tbl
end

--[[
战斗力 = 生命*0.1 + (其他所有属性总和)*0.5
]]
function GetPowerByAttribute( attribute )
	local result = 0
	local num = EnumAttributeType.HPPercent - 1
	for i=EnumAttributeType.Hp, num do
		local x = attribute[i]
		if x then
			result = result + x * ConstantData:getValue("Power." .. EnumAttributeTypeIndex[i])/10000
		end
	end
	local power = math.floor(result)
	return power
end

--[[
装备战斗力计算 =（生命*0.1 + 武力 * 0.5+ 内力*0.5+ 身法*0.5 +防御*0.5 + 冰伤*0.5 + 毒伤*0.5+ 火伤*0.5+冰抗 *0.5+ 火抗*0.5+ 毒抗*0.5 +命中*0.5+闪避*0.5 +暴击*0.5+抗暴.5）*（1+武力%+内力%+身法%+防御%+气血%）
]]
function CalculateEquipPower( attribute )
	local value = attribute[1]
	local result = 0
	if value then
		result = value * 0.1
	end

	for i = 2,15 do
		value = attribute[i]
		if value then
			result = result + value * 0.5
		end
	end

	local mutil = 1.00
	for i = 18,28 do
		value = attribute[i]
		if value then
			mutil = mutil + value / 10000
		end
	end
	result = result * mutil
	local power = math.floor(result)
	return power
end

--[[
装备战斗力计算 =（生命*0.1 + 武力 * 0.5+ 内力*0.5+ 身法*0.5 +防御*0.5 + 冰伤*0.5 + 毒伤*0.5+ 火伤*0.5+冰抗 *0.5+ 火抗*0.5+ 毒抗*0.5 +命中*0.5+闪避*0.5 +暴击*0.5+抗暴.5）*（1+武力%+内力%+身法%+防御%+气血%）
]]
function CalculateGemPower(idx,val)
	if idx == 1 then
		return math.floor(val * 0.1)
	elseif idx < 16 then
		return math.floor(val * 0.5)
	else
		return 0
	end
end

function GetResourceQuality(resType)
	if resType == EnumDropType.COIN then
		return QualityType.Purple
	elseif resType == EnumDropType.SYCEE then
		return QualityType.Purple
	elseif resType == EnumDropType.GENUINE_QI then
		return QualityType.Purple
	elseif resType == EnumDropType.EXP then
		return QualityType.Purple
	elseif resType == EnumDropType.ROLE_EXP then
		return QualityType.Purple
	elseif resType == EnumDropType.HERO_SCORE then
		return QualityType.Purple
	elseif resType == EnumDropType.CLIMBSTAR then
		return QualityType.Purple
	end
	print("Not Define : ",resType)
	return QualityType.Jia
end

function GetResourceName(resType)
	--[[
	if resType == EnumDropType.COIN then
		return "铜币"
	elseif resType == EnumDropType.SYCEE then
		return "元宝"
	elseif resType == EnumDropType.GENUINE_QI then
		return "悟性点"
	elseif resType == EnumDropType.EXP then
		return "团队经验"
	elseif resType == EnumDropType.LEVEL then
		return "团队等级"
	elseif resType == EnumDropType.ROLE_EXP then
		return "角色经验"
	elseif resType == EnumDropType.XIAYI then
		return "侠义值"
	elseif resType == EnumDropType.HERO_SCORE then
		return "群豪谱积分"
	elseif resType == EnumDropType.FACTION_GX then
		return "个人贡献"
	elseif resType == EnumDropType.CLIMBSTAR then
		return "八卦精元"
	elseif resType == EnumDropType.LOWHONOR then
		return "虎令"
	elseif resType == EnumDropType.HIGHTHONOR then
		return "龙令"
	end
	print("resType not found : ",resType)
	return "未知"
	]]
	return localizable.common_resource_type[resType]
	--localizable.ResourceName[resType]
end

function GetPlayerRoleList()
	local list = {77,80}
	return list
end

function IsPlayerRole(id)
	local list = {77,78,79,80}
	for i=1,4 do
		if list[i] == id then
			return true
		end
	end
	return false
end

function GetServerTime()
	if MainPlayer == nil then
		return os.time()
	end
	return MainPlayer:getNowtime()
end

function GetGameTime()
	return GetServerTime()
end

function timestampTodata( str )
	local tbl = {}
	tbl.year , tbl.month , tbl.day , tbl.hour , tbl.min ,tbl.sec = string.match(str,"(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
	local data = os.time(tbl)
	return data
end

function timestampToString( str )
	local date = os.date("*t", str)
	-- print(date)
	local data = string.format("%d年%d月%d日%d时%d分", date.year, date.month, date.day, date.hour, date.min)
	-- local data = os.date("%Y年%m月%d日%H时%M分", str)
	return data
end

function GetGrowNumByKind( kind ,level)
	if kind == EnumAttributeType.Force then
		return math.floor(level/20)+1
	elseif kind == EnumAttributeType.Defence then
		return math.floor(level/20)+1
	elseif kind == EnumAttributeType.Magic then
		return math.floor(level/20)+1
	elseif kind == EnumAttributeType.Blood then
		return math.floor(level/8)+3
	elseif kind == EnumAttributeType.Agility then
		return math.floor(level/20)+1
	end
end

--计算装备成长值
function GetTotalGrowNumByKind( kind ,level)
	if kind == EnumAttributeType.Force then
		--local num = level * 1 + math.floor(level/20)*level-(math.floor(level/20)*20+math.floor(level/20)*(math.floor(level/20)-1)*10)
		--return num
		return level * 7;
	elseif kind == EnumAttributeType.Defence then
		--local num = level * 1 + math.floor(level/20)*level-(math.floor(level/20)*20+math.floor(level/20)*(math.floor(level/20)-1)*10)
		--return num
		return level * 7;
	elseif kind == EnumAttributeType.Magic then
		--local num = level * 1 + math.floor(level/20)*level-(math.floor(level/20)*20+math.floor(level/20)*(math.floor(level/20)-1)*10)
		--return num
		return level * 7;
	elseif kind == EnumAttributeType.Blood then
		--local num = level * 3 + math.floor(level/8)*level-(math.floor(level/8)*8+math.floor(level/8)*(math.floor(level/8)-1)*4)
		--return num
		return level * 35;
	elseif kind == EnumAttributeType.Agility then
		--local num = level * 1 + math.floor(level/20)*level-(math.floor(level/20)*20+math.floor(level/20)*(math.floor(level/20)-1)*10)
		--return num
		return level * 7;
	end
end

--[[
判断属性是否为百分比属性
]]
function isPercentAttr(index)
	return index > 15 and index < 29
end

--[[
转换为百分比数值，用于显示。例如：834，应该显示为8.34%
]]
function covertToPercentValue(index,value)
	local percentValue = string.format("%.2f",value / 100) .. '%'
	return percentValue
end

--[[
转换为显示格式，主要是将百分比属性，转换为百分比数值，用于显示。例如：834，应该显示为8.34%
]]
function covertToDisplayValue(index,value)
	if isPercentAttr(index) then
		return covertToPercentValue(index,value)
	end
	return value
end

--[[
获取IOS系统tokens
]]
function getIOSDeviceTokens()
	return CCApplication:sharedApplication():getDeviceTokenID()
end

--[[
将table转换为字符串
]]
function sz_T2S(_t)  
    local szRet = "{"  
    function doT2S(_i, _v)  
        if "number" == type(_i) then  
            szRet = szRet .. "[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_T2S(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. '["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_T2S(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. "}"  
    return szRet  
end

--function url_encode(str)
--  	if (str) then
--  	  	str = string.gsub (str, "\n", "\r\n")
--  	  	str = string.gsub (str, "([^%w ])",
--  	  	    function (c) return string.format ("%%%02X", string.byte(c)) end)
--  	  	      	str = string.gsub (str, " ", "+")
--  	  	    end
--  	return str    
--end

--function url_decode(str)
--  	str = string.gsub (str, "+", " ")
--  	str = string.gsub (str, "%%(%x%x)",
--  	    function(h) return string.char(tonumber(h,16)) end)
--  	str = string.gsub (str, "\r\n", "\n")
--  	return str
--end

--[[
日期格式转换函数
]]
-- Compatibility: Lua-5.1
function split(str, pat)
   	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   	local fpat = "(.-)" .. pat
    local last_end = 1   
    local s, e, cap = str:find(fpat, 1)   
    while s do      
    	if s ~= 1 or cap ~= "" then
    	    table.insert(t,cap)
    	end      
    	last_end = e+1      
    	s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
      	cap = str:sub(last_end)
      	table.insert(t, cap)
    end
    return t
end


---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
function getTimeByDate(expression)
    local a = split(expression, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
    local t = os.time({year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]})
    return t
end


---- 通过日期获取秒 yyyy-MM-dd HH:mm:ss
function getDateByString(expression)
    local a = split(expression, " ")
    local b = split(a[1], "-")
    local c = split(a[2], ":")
    return {year=b[1],month=b[2],day=b[3], hour=c[1], min=c[2], sec=c[3]}
end

-- 通过区间获得值
function GetVauleByStringRange( str , index )
	-- local index_tbl , vaule_tbl = GetAttrByStringForExtra(str)
	-- print("index_tbl = ",index_tbl)
	-- print("vaule_tbl = ",vaule_tbl)
	-- local temp = 1
	-- for i=1,#index_tbl do
	-- 	if index_tbl[i] <= index and (( i < #index_tbl and index_tbl[i+1] > index) or i ==  #index_tbl) then
	-- 		return vaule_tbl[index_tbl[i]]
	-- 	end
	-- end
	-- print("GetVauleByStringRange error")
	-- return 0

	if string.find(str, "_") then
		local tbl = GetAttrByString(str)
		local temp = 0
		for k,v in pairs(tbl) do
			if index >= k then
				temp = tonumber(v)
			end
		end
		return temp
	else
		return tonumber(str)
	end
end

function GetStringByTbl( tbl )
	local str = ""
	for k,v in pairs(tbl) do
		if str == "" then
		else
			str = str.."|"
		end
		str = str .. k .. "_" .. v
	end
	return str
end

function GetXiaBlueBySoulIdAndNum( id , num )
	local item = ItemData:objectByID(id)
	if item == nil then
		print("没有此侠魂 id== ",id)
		return
	end
	return item.xiayi*num
end

--字符串转table(反序列化,异常数据直接返回nil)  
function t_S2T(_szText)  
    --栈  
    function stack_newStack()  
        local first = 1  
        local last = 0  
        local stack = {}  
        local m_public = {}  
        function m_public.pushBack(_tempObj)  
            last = last + 1  
            stack[last] = _tempObj  
        end  
        function m_public.temp_getBack()  
            if m_public.bool_isEmpty() then  
                return nil  
            else  
                local val = stack[last]  
                return val  
            end  
        end  
        function m_public.popBack()  
            stack[last] = nil  
            last = last - 1  
        end  
        function m_public.bool_isEmpty()  
            if first > last then  
                first = 1  
                last = 0  
                return true  
            else  
                return false  
            end  
        end  
        function m_public.clear()  
            while false == m_public.bool_isEmpty() do  
                stack.popFront()  
            end  
        end  
        return m_public  
    end  
    function getVal(_szVal)  
        local s, e = string.find(_szVal,'"',1,string.len(_szVal))  
        if nil ~= s and nil ~= e then  
            --return _szVal  
            return string.sub(_szVal,2,string.len(_szVal)-1)  
        else  
            return tonumber(_szVal)  
        end  
    end  
  
    local m_szText = _szText  
    local charTemp = string.sub(m_szText,1,1)  
    if "{" == charTemp then  
        m_szText = string.sub(m_szText,2,string.len(m_szText))  
    end  
    function doS2T()  
        local tRet = {}  
        local tTemp = nil  
        local stackOperator = stack_newStack()  
        local stackItem = stack_newStack()  
        local val = ""  
        while true do  
            local dLen = string.len(m_szText)  
            if dLen <= 0 then  
                break  
            end  
  
            charTemp = string.sub(m_szText,1,1)  
            if "[" == charTemp or "=" == charTemp then  
                stackOperator.pushBack(charTemp)  
                m_szText = string.sub(m_szText,2,dLen)  
            elseif '"' == charTemp then  
                local s, e = string.find(m_szText, '"', 2, dLen)  
                if nil ~= s and nil ~= e then  
                    val = val .. string.sub(m_szText,1,s)  
                    m_szText = string.sub(m_szText,s+1,dLen)  
                else  
                    return nil  
                end  
            elseif "]" == charTemp then  
                if "[" == stackOperator.temp_getBack() then  
                    stackOperator.popBack()  
                    stackItem.pushBack(val)  
                    val = ""  
                    m_szText = string.sub(m_szText,2,dLen)  
                else  
                    return nil  
                end  
            elseif "," == charTemp then  
                if "=" == stackOperator.temp_getBack() then  
                    stackOperator.popBack()  
                    local Item = stackItem.temp_getBack()  
                    Item = getVal(Item)  
                    stackItem.popBack()  
                    if nil ~= tTemp then  
                        tRet[Item] = tTemp  
                        tTemp = nil  
                    else  
                        tRet[Item] = getVal(val)  
                    end  
                    val = ""  
                    m_szText = string.sub(m_szText,2,dLen)  
                else  
                    return nil  
                end  
            elseif "{" == charTemp then  
                m_szText = string.sub(m_szText,2,string.len(m_szText))  
                local t = doS2T()  
                if nil ~= t then  
                    szText = sz_T2S(t)  
                    tTemp = t  
                    --val = val .. szText  
                else  
                    return nil  
                end  
            elseif "}" == charTemp then  
                m_szText = string.sub(m_szText,2,string.len(m_szText))  
                return tRet  
            elseif " " ~= charTemp then  
                val = val .. charTemp  
                m_szText = string.sub(m_szText,2,dLen)  
            else  
                m_szText = string.sub(m_szText,2,dLen)  
            end  
        end  
        return tRet  
    end  
    local t = doS2T()  
    return t  
end

--[[
转换为垂直显示字符串
]]
function toVerticalString(s)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8len' (string expected, got ".. type(s).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local len = 0

	local verticalString = ''
	local empty = true
	while pos <= bytes do
		len = len + 1
		local charBytes = utf8charbytes(s, pos)
		local charValue = string.sub(s,pos,pos + charBytes - 1)
		print("toVerticalString : ",charValue,pos,charBytes,s)
		pos = pos + charBytes
		if empty then
			empty = false
		else
			verticalString = verticalString .. '\n'
		end
		verticalString = verticalString .. charValue

	end

	return verticalString
end


function GetFightRoleIconByWuXueLevel( level )
	return "ui/army/c"..level..".png"
end
function GetRoleNameBgByQuality( level )
	return "ui/role/bg-n".. level ..".png"
end

--[[
计算当前天是第几天，相对于1970-01-01 00:00:00。
]]
function calculateDayNumber(seconds)
	--0秒时间为1970-01-01 08:00:00
	local difference = 8 * 60 * 60
	local perdaySeconds = 24 * 60 * 60
	local value = seconds + difference
	return math.floor(value / perdaySeconds)
end



function displayAttributeString(attribute)
	local string = ""
	for i=1,(EnumAttributeType.Max-1) do
		local x = attribute[i]
		if x and x ~= 0 then
			string = string .. AttributeTypeStr[i] .. "：" .. x .. ","
		end
	end
	return string
end


function getColorByString( string )
	local r = ('0x' .. string['2:3']) + 0
	local g = ('0x' .. string['4:5']) + 0
	local b = ('0x' .. string['6:7']) + 0
	return ccc3(r, g, b)
end

function GetColorStringByQuality(quality)
	local tab = GetColorTableByQuality(quality)
	local r = tab[1]
	local g = tab[2]
	local b = tab[3]
	
	local str1 = string.format("%02x", r)
	local str2 = string.format("%02x", g)
	local str3 = string.format("%02x", b)

	return "#" .. str1 .. str2 .. str3
end

--通过品质获得颜色table
function GetColorTableByQuality(quality)
	if quality == QualityType.White then	
		return {190,189,189}
	elseif quality == QualityType.Green then
		return {14,190,172}
	elseif quality == QualityType.Blue then
		return {72,88,255}
	elseif quality == QualityType.ChuanShuo then
		return {231,138,6}
	elseif quality == QualityType.Jia then
		return {189,10,228}
	end

	return {190,189,189}
end

function Lua_writeFile(file_name,addTime,...)
	if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
		return
	end
	if addTime == true then
		local date = os.date("*t", os.time())
		print("date",date)
		local timeStr = date.year.."_"..date.month.."_"..date.day .."_"..date.hour.."_"..date.min.."_"..date.sec
		file_name = file_name..timeStr
	end
	file_name = file_name..".log"
	local f = assert(io.open(file_name, 'w+'))

	local arg = {...}
	-- local ret = ''
	for k, v in pairs(arg) do
		local str = serialize(v)
		-- ret = ret .. '   ' .. str
		f:write(str)
	end
	f:close()
end
function numberToChinese( num )

    --local templete = {'一','二','三','四','五','六','七','八','九'}
    local templete = localizable.EnumWuxueLevelType
    local shiwei = math.floor(num/10)
    local gewei = num%10
    local str = ''
    if shiwei >= 2 then
      str = templete[shiwei]..localizable.functions_text1
    elseif shiwei == 1 then
      str = localizable.functions_text1
    end

    if gewei > 0 then
      str = str..templete[gewei]    
    end
    
    return str  
end

function numberToChineseTable( num )

    --local templete = {'一','二','三','四','五','六','七','八','九'}
    local templete =localizable.EnumWuxueLevelType
    local shiwei = math.floor(num/10)
    local gewei = num%10
    local str = {}
    if shiwei >= 2 then
      str[#str + 1] = templete[shiwei]
      str[#str + 1] = localizable.functions_text1
    elseif shiwei == 1 then
      str[#str + 1] = localizable.functions_text1
    end

    if gewei > 0 then
    	str[#str + 1] = templete[gewei]
    end
    
    return str  
end

function timeout(callback, dt,nRepeat)
	dt = dt or 0
	local tid = -1
	tid = TFDirector:addTimer(dt * 1000, nRepeat or 1, function()
		TFDirector:removeTimer(tid)
		if callback then 
			callback()
		end
	end, nil)
	return tid
end