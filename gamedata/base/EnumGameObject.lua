--[[
******枚举*******

	-- by Stephen.tao
	-- 2013/11/25
]]

--卡牌职业
EnumCareerType = 
{
	"All",		--全部
	"Dps", 		--输出
	"Def",		--防御
	"Heal",		--治疗
	"Control", 	--控制
}
EnumCareerType = CreatEnumTable(EnumCareerType, -1)

EnumRoleState = 
{
	"Stand",    		--待机
	"Run", 				--跑步
	"Left",				--左
	"Right", 			--右
	"Front", 			--前
	"After", 			--后
	"FrontLeft", 		--左前
	"AfterLeft", 		--左后
	"FrontRight", 		--右前
	"AfterRight", 		--右后
}
EnumRoleState = CreatEnumTable(EnumRoleState, 0)

EnumRoleStateName = 
{
	[1]  = "stand",
	[2]  = "run",
	[3]  = "run4",
	[4]  = "run6",
	[5]  = "run8",
	[6]  = "run2",
	[7]  = "run7",
	[8]  = "run1",
	[9]  = "run9",
	[10] = "run3",
}


EnumSeryType =
{
	AllSeryType		 	= 0,
	OneSeryType 		= 11,
	TwoUPSeryType		= 21,
	TwoDownSeryType   	= 22,
	ThreeUPSeryType		= 31,
	ThreeDownSeryType   = 32,
	FourUPSeryType		= 41,
	FourDownSeryType   	= 42,
	FiveUPSeryType		= 51,
	FiveDownSeryType   	= 52,
	FiveUPSeryType		= 53,
	SixUPSeryType		= 61,
	SixDownSeryType   	= 62,
}

--攻击类型
EnumDamageType = 
{
	Physical = 1,	--物理
	Magical	= 2,	--法术
}

--抽卡类型
EnumLotteryType = 
{
	Normal = 1,    --普通抽卡
	Senior = 2,	   --高级抽卡
	Extreme = 3,   --至尊抽卡
}

--神器类型
EnumAtriFactType = 
{
	All 	 		 = 0,		--全部
	Dps 			 = 1,		--输出
	Def 			 = 2,		--防御
	Heal 			 = 3,		--治疗
}

--宠物类型
EnumPetType = 
{
	Life 	 		 = 1,		--生命
	Attack 			 = 2,		--攻击
	PhyDef	 		 = 3,		--物防
	MagDef 			 = 4,		--法防
	Speed 			 = 5,		--速度
}

-- 七天活动按钮类型
EnumSevenDaysButtonType = 
{
	FuLi		 	 = 1,    --每日福利
	ZhuXian		 	 = 2,    --主线副本
	JinJie  		 = 3, 	 --进阶
	FengShenYanWu 	 = 4, 	 --封神演武
	ShenQi 		 	 = 5, 	 --神器
	JingYing		 = 6,    --精英副本
	ZhuangBei 		 = 7,    --装备
	JianMu 			 = 8, 	 --建木通天
	JingLian 		 = 9, 	 --装备精炼
	GuiShen 		 = 10, 	 --鬼神之塔
	ShengXing 		 = 11, 	 --装备升星
	XiangQian 		 = 12, 	 --装备镶嵌
	BaoShi 			 = 13,   --装备宝石
	ChouQian 		 = 14, 	 --抽签
	TuPo 			 = 15,   --突破
	YueKa			 = 16,   --月卡
	XianGou 		 = 17,	 --限购
}

--时间回复参数类型
EnumTimeRecoverType = 
{
	Vitality			= 1,	--体力
	SkillPoint			= 2,	--技能点
	NormalRecruit   	= 3,    --普通抽卡
	TopRecruit  		= 4,    --高级抽卡
	SpiritPoint   		= 5, 	--精力
	ArenaPoint    		= 6,	--竞技场次数
	Discount  			= 7, 	--高级十连抽折扣次数
	GhostTower			= 8,	--鬼神之塔挑战次数
	BloodyWeather 		= 9,	--建木通天天气次数
	BloodyWar			= 10,	--建木通天挑战次数
	BoCai           	= 11,	--博彩刷新时间
	BookWorldAccelerate = 12,   --天书世界加速次数
	BookWorldSteal      = 13,   --天书世界偷取次数
	Chat 				= 14,	--免费聊天次数
}

--属性类型枚举
EnumAttributeType = 
{
	--Constitution     	--体质
	--Force 			--力量
	--Endurance    		--耐力
	--Wisdom       		--智慧
	--Spirit       		--精神
	--Agility      	    --敏捷
	--Gold					= 18,		--金
	--Wood    				= 19,		--木
	--Water   				= 20,		--水
	--Fire    				= 21,		--火
	--Soil    				= 22,		--土
	--Nothing 				= 23,		--无

	Hp        				= 1,		--生命
	Atk 					= 2,		--攻击
	PhyDef 					= 3,		--物理防御
	MagicDef 				= 4,		--法术防御
	Speed 					= 5,		--速度
	Hit 					= 6,		--命中
	Miss 					= 7,		--闪避
	Crit 					= 8,		--暴击
	CritResistance 			= 9,		--暴抗
	
	HPPercent 				= 101,		--生命%
	AtkPercent 				= 102,		--攻击%
	PhyDefPercent 			= 103,		--物理防御%
	MagicDefPercent 		= 104,		--法术防御%
	SpeedPercent 			= 105,		--速度%
	HitPercent 				= 106,		--命中%
	MissPercent 			= 107,		--闪避%
	CritPercent 			= 108,		--暴击%
	CritResistancePercent 	= 109,		--抗暴%

	BaseCritRate			= 201,      --基础暴击率
	AddCritRate				= 202,		--附加暴击率
	BaseHitRate				= 203,		--基础命中率
	AddHitRate				= 204,		--附加命中率
	BaseMissRate			= 205, 		--基础闪避率
	AddMissRate				= 206,		--附加闪避率
	BaseCritResistanceRate  = 207, 		--基础抗暴率
	AddCritResistanceRate	= 208,		--附加抗爆率
	CritHurt 				= 209,		--暴击伤害(暴击倍率)
	BaseBeatBack 			= 210,     	--基础反击率
	AddBeatBack 			= 211, 		--附加反击率
	BaseBlock				= 212, 		--基础格挡率
	AddBlock				= 213,		--附加格挡率
	BaseDefuse 				= 214, 		--基础化解率
	AddDefuse 				= 215, 		--附加化解率
	
	NormalPhyHurtAdd 		= 301,		--普攻物理伤害加成%
	NormalMagicHurtAdd 		= 302,		--普攻法术伤害加成%
	SkillPhyHurtAdd 		= 303,		--技能物理伤害加成%
	SkillMagicHurtAdd 		= 304,		--技能法术伤害加成%
	NormalPhyHurtReduce 	= 305,		--普攻物理伤害减免%
	NormalMagicHurtReduce 	= 306,		--普攻法术伤害减免%
	SkillPhyHurtReduce 		= 307,		--技能物理伤害减免%
	SkillMagicHurtReduce 	= 308,		--技能法术伤害减免%
	PersistenceHurtAdd 		= 309,		--持续性伤害加成%
	PersistenceHurtReduce 	= 310,		--持续性伤害减免%
	BeHealAdd				= 311,		--受到治疗效果加成%
	BeHealReduce 			= 312,		--受到治疗效果减免%
	HealAdd 				= 313,		--治疗效果加成%
	HealReduce 				= 314,		--治疗效果减免%
	PhyPenetrate 			= 315,		--物理穿透%
	MagicPenetrate 			= 316,		--法术穿透%
	NormalHurtAdd 			= 317,		--普攻伤害加成
	SkillHurtAdd 			= 318,		--技能伤害加成
	NormalHurtReduce     	= 319,		--普攻伤害减免
	SkillHurtReduce 		= 320,		--技能伤害减免
	DefuseHurtPercent 		= 321, 		--化解伤害%
	BlockHurtPercent  		= 322, 		--格挡伤害%
	DefuseHurt 				= 323, 		--化解伤害固定值
	BlockHurt  				= 324, 		--格挡伤害固定值
	AllHurtAdd				= 325,		--伤害加成%
	AllHurtReduce			= 326,		--伤害减免%
	PvpHurtAdd				= 327,		--PVP伤害加成%
	PvpHurtReduce			= 328,		--PVP伤害减免%

	Suck 					= 401, 		--吸血
	Rebound 				= 402, 		--反弹
	Anger					= 403, 		--怒气
	SuckPercent				= 411, 		--吸血%
	ReboundPercent			= 412, 		--反弹%
	AngerPercent 			= 413,		--怒气%

	PowerPercent  			= 500, 		--战力百分比
}
EnumAttributeTypeIndex = {}
for k,v in pairs(EnumAttributeType) do
	EnumAttributeTypeIndex[v] = k
end

AttributeTypeStr = localizable.AttributeTypeStr

-- 1.我方
-- 2.敌方
-- 3.自身
EnumSkillTargetCampType = 
{
	Ally = 1,
	Enemy = 2,
	Self = 3,
}

-- 1、单体
-- 2、全体
-- 3、横排
-- 4、竖排
-- 5、随机（1个或多个）
-- 6、血最少
-- 7、物理防御最少
-- 8、法术防御最少
-- 9、物理防御最高
-- 10、法术防御最高
-- 13、攻击最低
-- 15、攻击最高
-- 17、附近（目标及上下左右多个目标）
-- 18、后排单体（原先打敌方单体时，需要打该单体所在横排中的最后一名角色，如果只有一名就是他了）
-- 19、后排竖排（打上述后排单体并和他在同一竖排的敌方）
-- 21、输出职业
-- 22、防御职业
-- 23、控制职业
-- 24、治疗职业
-- 25、血最多
-- 26、双防和最高
-- 27、复活标记目标专用
-- 28、自身身后同排
-- 29、目标的上下左右多个目标（状态专用,以技能目标为基准）
-- 30、除自己以外的血最少(只剩下自己目标还会是自己)
-- 31、命中目标中随机（状态专用,以技能目标为基准）
-- 32、随机固定数量（可重复）
--技能目标类型枚举 
EnumSkillTargetType = 
{		
	Single 		= 1,
	All 		= 2,
	Row 		= 3,
	Column 		= 4,
	Random 		= 5,
	HpMin 		= 6,
	PhyDefMin 	= 7,
	MagicDefMin	= 8,
	PhyDefMax 	= 9,
	MagicDefMax = 10,
	AtkMin 		= 13,
	AtkMax 		= 15,
	Nearby 		= 17,
	BackSingle  = 18,
	BackColumn 	= 19,
	Dps 		= 21,
	Def 		= 22,
	Control 	= 23,
	Heal 		= 24,
	HpMax 		= 25,
	DefMax 		= 26,
	CanRevival	= 27,
	SameRowBehind=28,
	STargetNearby=29,
	HpMinExcSelf =30,
	RandomInTar  =31,
	RandomNum 	 =32,
}

SkillTargetTypeStr = localizable.SkillTargetTypeStr


EnumSkillTriggerConditionType =
{
	NoCondition						= 0,		--没有条件
	CastNormalAttack 				= 1,		--释放普攻时
	AttackedType_Dodge	 			= 2,
	AttackedType_Damage				= 3,
	AttackedType_Heal				= 4,
	AttackedType_CritDamage			= 5,
	AttackedType_TargetDead			= 6,		--目标死亡
	AttackedType_ActSkill			= 7,		--主动技能
	AttackedType_TargetLock			= 8,		--被锁定目标
	AttackedType_TargetNotSelf		= 9,		--目标非自己
	AttackedType_TargetAlive		= 10,		--目标未死亡
	AttackedType_SelfHp				= 11,		--自身血量判定
	AttackedType_SmaSkill			= 12,		--小技能
	AttackedType_NpcType			= 13,		--目标Npc类型
	AttackedType_TargetNotSameRow	= 14,		--目标非同排
	AttackedType_AtkedTargetAlive	= 15,		--命中目标未死亡
	AttackedType_TargetCount		= 16,		--目标数量大于
	AttackedType_SameSex			= 17,		--是否相同性别(0非1同)
	AttackedType_Block				= 18,		--格挡
}

-- 1:普攻
-- 2:主动
-- 3:被动
-- 4:觉醒
-- 5:反击
-- 6:追击
-- 7:小技能
--技能类型枚举 
EnumSkillType = 
{
	"NormalAttack",		
	"ActiveSkill",		    
	"PasSkill",
	"AwakeSkill",		
	"BeatbackSkill",
	"PursueSkill",
	"SmallSkill",
}
EnumSkillType = CreatEnumTable(EnumSkillType)


-- 1、普通
-- 2、共生
-- 3、单一
-- 4、关联
EnumSkillEftOrStateType = 
{
	Eses_Normal = 1,
	Eses_And = 2,
	Eses_Or = 3,
	Eses_Connet = 4,
}

-- 1、直到创建者死亡
-- 2、直到宿主死亡
-- 3、直到被攻击
-- 4、回合数
-- 5、出手次数
-- 6、使用次数
-- 7、自身出手结束
EnumSkillStatePersistType = 
{
	EStateCreaterDead 		= 1,
	EStateOwnerDead 		= 2,
	EUntilAttacked			= 3,
	ERoundNum				= 4,
	EMoveNum				= 5,
	EUseTimes				= 6,
	ESelfMoveEnd			= 7,
}



-- 1、物理伤害
-- 2、法术伤害
-- 3、混合伤害
-- 4、物理治疗
-- 5、法术治疗
-- 6、混合治疗
-- 7、直接效果
EnumSkillHurtType = 
{		
	"PhysicalInjury",
	"SpellInjury",
	"MixInjury",
	"PhysicalHeal",
	"SpellHeal",
	"MixHeal",
	"JustBuffOrEft",
}

EnumSkillHurtType = CreatEnumTable(EnumSkillHurtType)

-- 1、buff
-- 2、debuff
-- 3、特殊（无法被驱散等）
EnumSkillBuffType = 
{
	Buff 		= 1,
	Debuff		= 2,
	Other		= 3,
}

-- 1、流血
-- 2、中毒
-- 3、灼烧
-- 4、冰冻
-- 5、混乱
-- 6、封印
-- 7、晕眩
-- 8、挑衅
-- 9、护盾
-- 10、失明
-- 11、耗弱
-- 15、守护
-- 16、移花接木
-- 17、锁定目标
-- 18、必暴
-- 19、必闪
-- 20、已复活标记（古月圣专用）
-- 21、反击标记
-- 22、反弹标记
-- 23、伤害加深印记(被打受击)
-- 24、魔法伤害必暴击
-- 25、光环技能
-- 26、追随Buff
-- 27、物理伤害加深印记
-- 28、法术伤害加深印记
-- 29、守护
-- 30、伤害加成印记(打别人)
EnumSkillBuffFlag = 
{
	Bleed 		= 1,
	Poison 		= 2,
	Burning 	= 3,
	Freeze 		= 4,
	Chaos 		= 5,
	Seal 		= 6,
	Stun 		= 7,
	Provocation = 8,
	Shield	    = 9,
	
	Helper	    = 15,
	Yihuajiemu  = 16,
	LockTarget  = 17,
	CritAdjust	= 18,
	MissAdjust	= 19,
	HasRevival	= 20,
	BeatBack    = 21,
	ReflexPerc  = 22,
	DamageAdd   = 23,
	MagicMark   = 24,
	AuraSpell	= 25,
	PursueBuff	= 26,
	PhyDamageAdd= 27,
	MagDamageAdd= 28,
	HpMin 		= 29,
	HitDamageAdd= 30,
}

-- SkillTypeStr = 
-- {		
-- 	"主动技能",		
-- 	"主动治疗",		
-- 	"主动技能",		
-- 	"被动属性",	
-- 	"增益光环",		
-- 	"减持光环",		
-- 	"被动技能",		
-- 	"主动技能",		
-- }
SkillTypeStr = localizable.SkillTypeStr

-- SkillSexStr = 
-- {		
-- 	"异性",		
-- 	"同性",			
-- }
SkillSexStr = localizable.SkillSexStr

-- SkillEffectStr = 
-- {		
-- 	"吸怒",		
-- 	"减敌怒",		
-- 	"增己怒",		
-- 	"吸血",	
-- 	"反弹",		
-- 	"反击 ",		
-- 	"化解",		
-- 	"破阵 ",	
-- 	"复活",		
-- 	"净化 ",		
-- 	"致死",		
-- 	"免疫",	
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"乾坤",
-- 	"七伤",
-- 	[22]= "吸星大法",
-- 	[23]= "吸星大法",
-- 	[24]= "伤害递增",
-- 	[25]= "闪避释放技能",
-- }
SkillEffectStr = localizable.SkillEffectStr

-- SkillBuffHurtStr = 
-- {
-- 	"中毒",		
-- 	"灼烧",		
-- 	"破绽",		
-- 	"虚弱",		
-- 	"内伤",		
-- 	"迟缓",		
-- 	"失明",		
-- 	"神力",		
-- 	"防守",		
-- 	"混乱",		
-- 	"散功",		
-- 	"点穴",		
-- 	"眩晕",		
-- 	"冻结",		
-- 	"昏睡",		
-- 	"低落",		
-- 	"回血",	
-- 	"",
-- 	"",	
-- 	"痛饮",		
-- 	"逍遥游",		
-- 	"易筋",		
-- 	"背剑",		
-- 	"天池",		
-- 	"赏善",		
-- 	"罚恶",
-- 	"",
-- 	-- "",
-- 	-- "",
-- 	-- "",
-- 	-- "",
-- 	[31]="逆行经脉",
-- 	[33]="不死不休",		
-- 	[34]="不死不休",
-- 	[35]="寒毒",
-- 	[36]="寒毒",	
-- 	[37]="胆怯",


-- 	[40]= "普攻伤害",
-- 	[41]= "技能伤害",
-- 	[42]= "毒和火的持续伤害",
-- 	[43]= "负面状态概率",
-- 	[44]= "伤害",
-- 	[45]= "治疗量",
-- 	[46]= "增益属性状态效果",
-- 	[47]= "负面属性状态效果",
	
-- 	[50]= "流血",
-- 	[51]= "吸星大法",
-- 	[52]= "吸星大法",
-- 	[53]= "必中",
-- 	[54]= "技能反击",
-- 	[55]= "重伤",
-- }
SkillBuffHurtStr = localizable.SkillBuffHurtStr

--[[
	随机商店类型定义
]]
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

QualityTypePy = 
{
	"bai", 		--1 白
	"lv", 		--2 绿
	"lan", 		--3 蓝
	"zi", 		--4 紫
	"cheng",		--5 橙
	"hong",		--6 红
	"Max",	---
}

QualityType = CreatEnumTable(QualityType)

-- 物品产出途径
-- EnumItemOutPutType = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "招募" ,"金宝箱", "银宝箱", "暂无途径产出"}
--                       1       2        3          4       5        6          7       8        9          10        11       12        13       14     15      16    17      18      19    			 20       21     22
-- EnumItemOutPutType = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "酒馆" ,"金宝箱", "银宝箱", "铜宝箱","VIP奖励","VIP礼包","活动","签到","成就","日常", "雁门关", "通过活动获取", "祈愿","藏书阁","游历"}
EnumItemOutPutType = localizable.EnumItemOutPutType

-- 武学的等级描述
-- EnumWuxueLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七"}
EnumWuxueLevelType = localizable.EnumWuxueLevelType

--added by wuqi
--天书重数
-- EnumSkyBookLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十"}
EnumSkyBookLevelType = localizable.EnumSkyBookLevelType

-- 武学一重：初探门径、武学二重：熟能生巧、武学三重：小有所成、武学四重：登堂入室、武学五重：炉火纯青、武学六重：登峰造极、武学七重：出神入化、武学八重：返璞归真、武学九重：一代宗师
-- EnumWuxueDescType   = {"初探门径","熟能生巧","小有所成","登堂入室","炉火纯青","登峰造极","出神入化","返璞归真","一代宗师","一代宗师","小隐于野","大隐于市","只是传说","近乎仙人","一代宗师","一代宗师","一代宗师","一代宗师"}
EnumWuxueDescType = localizable.EnumWuxueDescType

-- 秘籍的等级描述
-- EnumBookDescType   = {"普通","高级","专家","宗师","传说"}
EnumBookDescType = localizable.EnumBookDescType
-- 武学颜色
EnumWuxueColorType = 
{
	ccc3(72,88,255),--1
	ccc3(72,88,255),--2
	ccc3(72,88,255),--3
	ccc3(72,88,255),--4
	ccc3(72,88,255),--5
	ccc3(72,88,255),--6
	ccc3(72,88,255),--7
	ccc3(72,88,255),--8
	ccc3(72,88,255),--9
	ccc3(72,88,255),--10
	ccc3(72,88,255),--11
	ccc3(72,88,255),--12
	ccc3(72,88,255),--13
	ccc3(72,88,255),--14
	ccc3(72,88,255),--15
	ccc3(72,88,255),--16
	ccc3(72,88,255)--17
}

-- 武学等级对应的背景极及颜色索引
EnumWuxueBGType = 
{
	1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5
----1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17
}

-- 技能解锁对应的武学等级
EnumSkillLock = {1, 2, 4}


LianTiQualityNameStr = 
{
	localizable.LianTi_Quality_Name_1,
	localizable.LianTi_Quality_Name_2,
	localizable.LianTi_Quality_Name_3,
	localizable.LianTi_Quality_Name_4
}

ServerSwitchType = 
{
    Server			= 1,            	--服务器(服务器控制)
    Login			= 2,				--登录(服务器控制)
    Pay				= 3,            	--充值
    CreatePlayer	= 4,            	--创建角色(服务器控制)
    WeChat			= 5,				--微信关注
    LiBaoMa			= 6,            	--礼包码

    Share   		= 10,            	--分享功能
    Sign			= 11,            	--签到
    MonthCard		= 12,            	--月卡
    ServerChat 		= 17,			 	--跨服聊天
    AntiAddiction 	= 18,			 	--是否防沉迷
    Sensitive	 	= 19,			 	--是否屏蔽敏感字
    Wudaohui 		= 20,			 	--武道会
    CustomerServices= 21,	 			--客服页面
    TeamShout 		= 22,				--组队喊话
    Activity 		= 23,				--活动
    GodPet			= 24,	 			--神宠
	WeChatRedPacket = 25,		 		--微信百万红包
	ScoreMatch 		= 26,		 		--积分赛
	Review			= 27,				--评分
	CardRefine		= 28,				--是否开启炼体
	LuckyRain		= 29,				--是否开启红包雨
	GuildMail       = 30,               --是否开启公会邮件
	GuildCopy       = 31,               --是否开启公会副本
	OtherPlayerFormation = 32,          --其他玩家阵容
	PetCompose      = 33,               --宠物合成
	TreasureHunt	= 34,				--是否开启寻宝
	GuildWar        = 36,             	--帮会战 
}

--quanhuan add RankListType
RankListType = {
	Rank_List_None = 0,
	Rank_List_Hero = 1,		--英雄榜
	Rank_List_Qunhao = 2,	--群豪榜
	Rank_List_Wuliang = 3,	--无量榜
	Rank_List_Xiake = 4,	--侠客榜
	Rank_List_Shengbin = 5,	--神兵榜
	Rank_List_fumo = 6,	    --附魔榜
	Rank_List_FactionLevel = 7,		--公会等级榜
	Rank_List_FactionPower = 8,		--公会战力榜
	Rank_List_ShaLu = 13,	--杀戮榜
	Rank_List_Max = 14
}

LineUpType = {
	LineUp_Main 			= 1,	--主阵容
	LineUp_BloodyBattle 	= 2,	--血战
	LineUp_Attack 			= 3,	--武林大会攻击阵容
	LineUp_Defense 			= 4,	--武林大会防守阵容
	LineUp_QunhaoDef		= 5,	--群豪谱防守
	LineUp_Mine1_Defense 	= 6,	--挖矿防守阵型1
	LineUp_Mine2_Defense	= 7,	--挖矿防守阵型2
	LineUp__MERCENARY_TEAM  = 8,	--我方派遣的雇佣队伍
	LineUp_HIRE_TEAM  		= 9,	--我方雇佣阵型
	LineUp_DOUBLE_1			= 10,	--双阵容 一
	LineUp_DOUBLE_2			= 11,	--双阵容 二
	LineUp_MAX				= 12,
}


EnumFightEffectType = {
	FightEffectType_NormalAttack = 40,		--普攻修正
	FightEffectType_SkillAttack = 41,		--技能修正
	FightEffectType_DotHurt = 42,			--dot伤害修正
	FightEffectType_DotPercent = 43,		--dot几率修正
	FightEffectType_HurtGain = 44,			--总伤害修正
	FightEffectType_BonusHealing = 45,		--治疗修正
	FightEffectType_GoodAttr = 46,		--有益属性修正值
	FightEffectType_BadAttr = 47,		--减益属性修正值
	FightEffectType_NoShanBi = 48,		--无视强制闪避
}
EnumFightAttributeType = {
	Immune = 1,					-- 免疫属性
	Effect_extra = 2,			-- 效果属性
	Be_effect_extra = 3,		--被动效果属性
}

EnumFightStrategyType = {
	StrategyType_PVE 			= 1,					--主阵型
	StrategyType_BLOOY 			= 2,					--雁门关
	StrategyType_CHAMPIONS_ATK 	= 3,					--挑战赛攻击
	StrategyType_CHAMPIONS_DEF 	= 4,					--挑战赛防守
	StrategyType_AREAN 			= 5,					--群豪谱防守
	StrategyType_MINE1_DEF 		= 6,					--挖矿1
	StrategyType_MINE2_DEF 		= 7,					--挖矿2
	StrategyType_MERCENARY_TEAM = 8,					--我方派遣的雇佣队伍
	StrategyType_HIRE_TEAM		= 9,					--我方雇佣阵型
	StrategyType_DOUBLE_1		= 10,					--双阵容 一
	StrategyType_DOUBLE_2		= 11,					--双阵容 二
	StrategyType_Max			= 12,
}

--聊天类型枚举
EnumChatType = 
{		
	"Public"     ,  --公聊
	"Gang"	     ,	--帮派
	"GM" 	     ,  --GM频道
	"PrivateChat",	--私聊
	"Server",--跨服
	"FactionNotice", --帮派通告
	"VipDeclaration" --土豪发言
}

EnumChatType = CreatEnumTable(EnumChatType)

--PVE副本类型
EnumMissionType = {
	Main 						= 1,					--主线
	Elite 						= 2,					--精英
	Daily						= 3,					--日常
	Dungeon  					= 6,					--公会幻境
}

EnumMissionBoxRewardType = {
	Star = 1, 		--获得XX星星奖励
	Mission = 2,    --通关第XX关卡奖励
}

EnumBtnType =
{
	Normal 	 = 1,
	Select 	 = 2,
	Disable  = 3,
}

--功能模块定义枚举
EnumFunctionType = {
	LOGIN 			= 100, 			--登录
	MENU   			= 200, 			--主城
	ROLE 			= 300,			--角色
	BATTLE 			= 400,			--战斗
	GOODS 			= 500,			--物品
	MISSION 		= 600,			--关卡
	LOTTERY 		= 700, 			--抽卡
	EQUIPMENT 		= 800, 			--装备
	TALISMAN 		= 900, 			--夺宝
	TASK 			= 1000, 		--任务 成就
	MALL  			= 1100, 		--商城
	-- RECHARGE 		= 1200, 		--充值
	ACTIVITY 		= 1300, 		--活动
	MISSION_BOX     = 1400, 		--关卡宝箱
	ARENA 			= 1500, 		--竞技场
	MAIL 			= 1600, 		--邮箱   
	SEVENDAYS     	= 1700, 		--七日活动  
	ADVENTURE 		= 1800, 		--山海奇遇
	BOOKWORLD 		= 1900, 		--天书世界
	FACTION         = 2000, 		--公会
	CHALLENGE 		= 2100, 		--挑战入口 
	ARTIFACT 		= 2200,     	--神器   
	RECYCLE 		= 2300,  		--回收
	BUYSHOP			= 2400,			--购买
	FRIEND 			= 2500, 		--好友
	CHAT 		    = 2600, 		--聊天	
	GHOST 			= 2700, 		--鬼神之塔
	BOCAI  			= 2800, 		--博彩系统
	PET 			= 2900, 		--宠物  
	MAINTASK 		= 3000, 		--任务引导   
	TEAM 			= 3100, 		--组队玩法 组队任务 
	CELUE           = 3200,         --技能策略
	GUILD 			= 3300, 		--帮会
	NEWARTIFACT     = 3400,         --新神器
	ScoreMatch     = 3500,         --积分赛
	Title          = 3600,         --称号
	SpecialEquipMent = 3700,       --专属装备
	
	 

	-- QUN_HAO 		= 600,			--群豪谱
	-- EVER_QUEST  	= 700,		--铜人阵
	-- ROLE_TRAIN 		= 800,		--角色培养
	-- MIJI 			= 900,			--秘籍
	-- CLIMB 			= 1000,			--无量山
	-- GANG 			= 1100,			--帮派
	-- MALL 			= 1200,			--商城
	-- RECHARGE 		= 1300,		--充值
	-- CHAT 			= 1400,			--聊天
	-- REICUTE 		= 1500,			--招募
	-- TFSSAGE 		= 1600,			--消息
	-- SETTING 		= 1700,			--设置
	-- SKILL 			= 1800,			--技能（废弃，原团队技能）
	-- TASK 			= 1900,			--成就，任务
	-- RECOVERY_POINT 	= 2000,	--体力
	-- TREASURE 		= 2100,		--江湖宝藏
	-- SPELL 			= 2200,			--法术，角色技能
	-- DROP 			= 2300,			--掉落
	-- PUBLIC 			= 2400			--公共模块
}

-- EnumShaderType =
-- {
-- 	ShaderPositionTextureColor 		  = "ShaderPositionTextureColor"
-- 	ShaderPositionTextureColorAlphaTest = "ShaderPositionTextureColorAlphaTest"
-- 	ShaderPositionColor 				  = "ShaderPositionColor"
-- 	ShaderPositionTexture 			  = "ShaderPositionTexture"
-- 	ShaderPositionTexture_uColor 		  = "ShaderPositionTexture_uColor"
-- 	ShaderPositionTextureA8Color 		  = "ShaderPositionTextureA8Color"
-- 	ShaderPosition_uColor 			  = "ShaderPosition_uColor"
-- 	ShaderPositionLengthTextureColor 	  = "ShaderPositionLengthTextureColor"
-- 	Shader_ControlSwitch 				  = "Shader_ControlSwitch"
-- 	GrayShader						  = "GrayShader"
-- 	HighLight						  = "HighLight"
-- 	OutLine							  = "OutLine"
-- 	Mix_uColor						  = "Mix_uColor"
-- 	BlurMask							  = "BlurMask"
-- }

--回收系统按钮类型
EnumRecycleType = {
	RoleDiscard 				= 1,
	RoleRebirth 				= 2, 
	EquipRebirth				= 3,
	EquipHeCheng				= 4,
	GemHeCheng 					= 5,
	PetRebirth 					= 6,
	ArtifactRebirth 		    = 7,
}
--主城点击类型
EnumMenuClickType = {
	MenuXuanyuanbang	 		= 6,				--轩辕帮
	MenuHuangGong				= 7,				--皇宫
	MenuYingGuoGong 			= 8, 				--英国公府
	MenuChangAn					= 9,				--长安街道
	MenuXianLIngBaoJing			= 10,				--仙灵宝镜
	MenuShangYeJie  			= 11, 				--商业街
	MenuChouQian				= 12,				--抽签
	MenuPaiHangBang				= 13,				--排行榜
	MenuHuiShou	 				= 14,				--回收
	MenuRenWu					= 15,				--任务
	MenuJiGuanFang 				= 16, 				--机关房
	MenuShanZiPu				= 17,				--扇子铺
	MenuShiWei 					= 18, 				--侍卫
	MenuLiLian					= 19,				--历练	
}

--大地图点击类型
EnumBigWorldClickType = {
	BigWorldMainCity			= 2,				--主城
	BigWorldMission 			= 3, 				--普通副本
	BigWorldElite				= 4,				--精英副本
	BigWorldArena				= 5,				--封神演武
	BigWorldJiaoFei 			= 6,				--山海奇遇
	BigWorldBoss 				= 7,				--世界boss
	BigWorldTower 				= 8, 				--鬼神之塔
	BigWorldDaily				= 9,				--日常副本
	BigWorldBloodyWar			= 10,				--建木通天
	BigWorldVisible				= 11,				--隐藏
	BigWorldJiFenGame			= 23,				--轩辕论剑
}

--机关房点击类型
EnumJiGuanClickType = {
	JiGuanMainCity				= 2,				--主城
	JiGuanArena 				= 3, 				--封神演武
	JiGuanJiaoFei 				= 4,				--山海奇遇
	JiGuanBoss					= 5,				--镇压凶兽
	JiGuanBloodyWar				= 6,				--建木通天
	JiGuanRoundTask 			= 7,				--降妖伏魔 
	JiGuanGhostTower			= 8, 				--鬼神之塔
	JiGuanJiFenGame				= 9, 				--轩辕论剑			
}

--商业街点击类型
EnumMallClickType = {
	MallMainCity				= 2,				--主城
	MallBloodyWar				= 3,				--建木通商店
	MallGroup					= 4,				--帮会商店
	MallLottery					= 5,				--抽签商店
	MallSycee					= 6,				--元宝商店
	MallRecycle					= 7,				--伙伴商店（回收）
	MallWheel					= 8,				--仙缘商店（转盘）
	MallRandom					= 9,				--随机商店
	MallArena 					= 10, 				--演武商店	
	MallWudaohui 				= 11, 				--武道会商店	
}

--天书系统建筑类型
EnumBookWorldType = {
	BookWorld 					= 0,				--天枢
	Banda 						= 1,				--茅草屋
	Artifact 					= 2, 				--神器工坊
	Magic						= 3,				--仙术道场
	Reincarnation				= 4,				--转生台
	Armour 						= 5,				--铠装工坊
	Ghosts						= 6,				--鬼神阵
	Lumbering					= 7,				--伐木场
	Mining						= 8,				--采矿场
	Metallurgy 					= 9,				--冶金场
	WoodWarehouse 				= 10,				--木材仓库
	MiningWarehouse 			= 11,				--石矿仓库
	MetalWarehouse 				= 12,				--金属仓库
}

--天书卡牌上阵类型
EnumBookWorldCardType = {
	MyCard	 					= 0,				--自己
	FriendCard					= 1,				--好友/机器人
	InstituteCard				= 2,				--自己研究卡牌
}

--天书研究院类型
EnumBookWorldInstituteType = {
	Production	 				= 1,				--生产
	Demand						= 2,				--需求
	Other						= 3,				--其他
}

-- ================GoodsEnum===============
--物品类型
EnumGoodsType = {
	Material 					= 1,					--秘籍
	MaterialFrag 				= 2,					--秘籍碎片
	Prop 						= 3,					--道具
	RoleFrag 					= 4,					--角色碎片
	Equipment 					= 5,					--装备
	EquipFrag 					= 6,					--装备碎片
	EquipGem 					= 7, 					--装备宝石
	Talisman 					= 8,					--法宝
	TalismanFrag				= 9,					--法宝碎片
	PetFrag 					= 11,					--宠物碎片
	PetSkill 					= 12,					--宠物技能书
	PetSkillFrag 				= 13,					--宠物技能书碎片
	Artifact					= 14,					--神器
	ArtifactFrag				= 15,					--神器碎片
	FashionFrag                 = 17,                   --时装碎片
	PetEggFrag 					= 18, 					--宠物蛋碎片
	SpecialEquip                = 19,                   --专属装备 
	SpecialEquipFrag            = 20,                   --专属武器碎片      
}

--资源类型
EnumResourceType = {
	Material 					= 1,					--秘籍
	MaterialFrag 				= 2,					--秘籍碎片
	Prop 						= 3,					--道具
	RoleFrag 					= 4,					--角色碎片
	Equipment 					= 5,					--装备
	EquipFrag 					= 6,					--装备碎片
	EquipGem 					= 7, 					--装备宝石
	Talisman 					= 8,					--法宝
	TalismanFrag				= 9,					--法宝碎片
	PetFrag 					= 11,					--宠物碎片
	PetSkill 					= 12,					--宠物技能书
	PetSkillFrag 				= 13,					--宠物技能书碎片
	Artifact					= 14,					--神器  (新法宝)
	ArtifactFrag				= 15,					--神器碎片 （新法宝碎片）
	Fashion						= 16,					--时装
	FashionFrag                 = 17,                   --时装碎片
	PetEggFrag 					= 18, 					--宠物蛋碎片
	SpecialEquip                = 19,                   --专属装备 
	SpecialEquipFrag            = 20,                   --专属武器碎片  
	Coin 						= 51,     				--铜币
	Sycee 						= 52,					--元宝
	Errantry 					= 53,					--侠义值
	GhostTowerCoin				= 54,					--鬼神之塔货币
	ArenaCoin 					= 55,					--竞技场货币
	HeroHillCoin 				= 56,					--群英山货币 
	PetCoin 					= 57, 					--宠物商城货币
	GroupExp 					= 58,					--团队经验
	Strengh 					= 59,					--体力
	Spirit 						= 60,					--精力
	Arena 						= 61,					--竞技场挑战次数
	VIPExp 						= 62, 					--vip经验
	GoldenLot 					= 63, 					--金玉签
	SilverLot					= 64,					--银玉签
	ActivePoint					= 65,					--活跃度
	XianYuanCoin				= 69,					--仙缘值
	Wood						= 70,					--木材
	Stone 						= 71,					--石头
	Metal 						= 72,					--金属
	GuildMoney 					= 80,					--帮派资金
	GuildDedication 			= 81,					--帮派贡献
	BookWorldSteal 				= 82,					--天书世界偷取次数
	BloodyTimes 				= 83,					--建木通天挑战次数
	OfflineTime 				= 84,					--符鬼离线挂机时间
	WudaohuiCoin 				= 85,					--武道会货币
	RoleCard 					= 101,					--角色卡牌
	PetCard 					= 102, 					--宠物卡牌
	GuildContribution           = 103

}
 
--道具子类型
EnumGoodsSubType = {
	ExpPill						= 1,					--经验丹
	PetExpPill					= 9,					--宠物经验丹
	PetFlair					= 23,					--宠物资质丹
	PetEgg                      = 24,                   --宠物蛋
	FixedGift					= 53,					--固定礼包
	ChooseGift					= 54,					--多选一礼包
	TurnTable 					= 99, 					--转盘物品
}

--秘籍子类型
EnumMaterialFragSubType = {
	TipsFrag					= 1,					--秘笈碎片
	TipsPaper					= 2,					--秘籍图纸
	PaperFrag					= 3,					--图纸碎片
}

-- 物品使用类型
EnumItemUseType = {
	None 						= 1,					--不使用
	Use 						= 2,					--使用
	Compose 					= 3,					--合成
}

EnumRewardSourceType = {
	Pve 						= 1,					--Pve
	UseProp 					= 100,					--使用道具
	DailyTask 					= 101,   				--每日任务
	DailyTaskPoint 				= 102,					--每日任务积分兑换
	TavernBox 					= 103,					--招募积分兑换
	Bloody 						= 106,					--建木通天小宝箱
	Mail 						= 107;					--邮件
	Adventure_Monster		 	= 108;					--山海奇遇小怪
	Adventure 					= 109;					--山海奇遇
	Shop 						= 200,					--商城
	Arena 						= 201,					--竞技场
	Recycle 					= 202,					--重生
	Grab 						= 203,					--夺宝
	Tower 						= 204,					--鬼神之塔
}

-- ================FormationEnum===============
--阵型类别
EnumFormationType = {
	PVE 						= 1,
	PVP 						= 2,
	BloodyWar					= 3,   --建木通天
	Team       					= 4,
	PVP_Match                   = 5,   --武道会
	SCORE_MATCH_1V1				= 6;--积分赛1V1
	SCORE_MATCH_3V3_1             = 7;--积分赛3V3 1
	SCORE_MATCH_3V3_2             = 8;--积分赛3V3 1
	SCORE_MATCH_3V3_3             = 9;--积分赛3V3 1
}

EnumMasterType = {
	Level 				= 1,		--等级
	Breach				= 2,		--突破
	Evolution 			= 3,		--进阶
	EquipIntension 		= 4,		--装备强化
	EquipQuality		= 5,		--装备品质
	EquipStar			= 6,		--装备升星
	EquipRefining		= 7,		--装备精炼
	EqupGemComplete		= 8,		--装备宝石镶嵌
}

--通用头部资源类型定义枚举
HeadResType = 
{
	Coin 				 = 1,					--铜币
	Sycee 				 = 2,					--元宝
	Vitality 			 = 3, 					--关卡体力
	Arena 	 			 = 4,					--竞技场次数
	SpiritPoint			 = 5,					--精力
	GuildContribution	 = 6,					--帮会贡献

	Bloody 	 			 = 101, 				--建木经元
	Tower 	 			 = 102, 				--鬼神币
	LongYu 		 		 = 103, 				--龙玉
	GoldenLot 			 = 104, 				--金玉签
	SilverLot 	 		 = 105, 				--银玉签
	XiaYi 	        	 = 106, 				--伙伴币(侠义值)
	CommonLot			 = 107,					--抽签货币
	ArenaLot		 	 = 108,					--竞技场币
	LotCoin  			 = 109,					--博彩货币
	BookWorldAccelerate  = 110, 				--天书世界加速次数
	BookWorldSteal  	 = 111, 				--天书世界偷取次数
	WudaohuiLot 		 = 112, 				--武道会币
}

--装备类型枚举
EnumEquipmentType = 
{
	"Weapon",			--武器
	"Helmet",			--头盔
	"Clothes",			--衣服
	"Belt", 			--腰带
	"Shoe",				--靴子
	"Max"	
}
EnumEquipmentType = CreatEnumTable(EnumEquipmentType)

--成就类型枚举
EnumAchievementType = 
{
	Total     		= 1,			--总成就
	ClimbTower      = 2,			--鬼神之塔
	Mission 		= 3,			--副本
	WorldBoss 		= 4,			--世界boss
	Lottery 		= 5,			--抽卡
	Talisman 		= 6,			--夺宝
	Faction 		= 7,			--帮派				
}

--法宝类型枚举
EnumTailsmanType = 
{
	Attack 			= 1,			--攻击
	Defence 		= 2,			--防御
	Exp 			= 3,			--经验
}

--商城类型枚举
EnumShopType = 
{
	SyceeShop 			= 11,	--元宝商城
	ArenaShop 			= 12,	--竞技场商店
	RoleShop 			= 13,	--角色商店
	TowerShop 			= 14, 	--鬼神之塔商店
	DevildomShop 		= 15, 	--魔界商店
	FactionShop 		= 16, 	--帮会商店
	QunyingShop 		= 17, 	--群英山商店
	PetShop				= 18,	--宠物商店
	TowerRandomShop 	= 19,  	--鬼神之塔随机商店
	QunyingRandomShop 	= 20,	--群英随机商店
	TowerMaterialShop 	= 21,	--材料商店
	LotteryShop 		= 22, 	--抽奖商店
	BocaiShop 			= 23, 	--博彩商店
	WudaohuiShop 		= 24, 	--武道会商店
}

--商城类型枚举新
EnumShopTypeNew = 
{
	SyceeShop 			= 11,	--元宝商城
	ArenaShop 			= 12,	--竞技场商店
	RoleShop 			= 13,	--角色商店
	QunyingShop 		= 17, 	--群英山商店
	TowerShop 			= 14, 	--鬼神之塔商店 --公会
	LotteryShop 		= 22, 	--抽奖商店
	BocaiShop 			= 23, 	--博彩商店
}

--神宠集市类型
EnumGodPetShopType = {
	GodPetBuy			= 1,	--购买
	GodPetSell			= 2,	--上架
	GodPetDown			= 3,	--下架
}
--排序类型    
EnumSortType =
{
    Quality = 1,   	--品质
    Power   = 2,    --战力
}

--山海奇遇事件类型    
EnumAllNotityType =
{
    WalkDealer 		 = 1,   --云游商城
    MysteryBox  	 = 2,   --神秘宝箱
    KnowLedgeDiscuss = 3,	--煮酒论道
}

EnumActivityType = 
{
	SevenDays 		= 1,   	--七日活动
	FuLi  			= 2, 	--福利
	Weixin 			= 3,    --微信
	OnlineActivity 	= 5,  	--在线活动

	LoginSevenDay 	= 7,   	--七天登录礼包
	VIPEnter		= 8,	--vip
	MonthCardEnter	= 9,	--月卡
	CustomerServices	= 10,	--客服
	Kenkonitteki	= 11,	--乾坤一掷
	LimitGeneral	= 12,	--限时神将
	MillionRedBag	= 13,	--百万红包
	NewYearActivity	= 14,	--新年活动
	NewYearHit		= 15,	--新年年兽活动
	LanternAct		= 16,	--元宵活动
	TreasureHunt 	= 34,	--寻宝活动

 
	FirstPay 		= 100,    --首充
	Wudaohui 		= 102,    --武道会
	RedPacketRain   = 101,    --红包雨
	GuildWar        = 103,    --帮会战
}

EnumQuickGo =
{
	Recharge = 1, 		--充值
	Mission  = 2, 		--副本
	Vip    	 = 3, 		--vip
	SyceeStore = 4,		--元宝商店
}

EnumBookWorldStatus =
{
	Free 	  = 0, 		--空闲
	Build  	  = 1, 		--建造
	Work      = 2, 		--工作
	Harvest   = 3, 		--收获
	Reseatch  = 4, 		--研究
}

EnumVipFunctionID = 
{
	VipBox 				= 1001, 	--vip礼包
	BattleSpeed 		= 1002, 	--战斗可加速x3
	Strengh    	  		= 1003, 	--购买体力丹次数
	Spirit 				= 1004,		--购买精力丹次数
	Coin 				= 1005, 	--购买招财符次数
	JianMuPass			= 1006, 	--建木通天扫荡关卡数量
	JianMuBuy 			= 1007, 	--购买建木通天次数
	Tower   			= 1008, 	--购买鬼神之塔次数
	Arena 				= 1009, 	--购买竞技场演武令次数
	--Adventure 			= 1010, 	--山海奇遇可自动战斗
	Chat 				= 1011, 	--每日免费聊天次数
	BookPass 			= 1012, 	--秘籍一键扫荡
	BookWorldHarvest 	= 1022, 	--天书开启一键收取   
	BookWorldWork 		= 1023, 	--天书开启一键工作
	MissionPassTen 		= 1024, 	--开启关卡十连扫荡
	EquipmentIntensify	= 1025, 	--一键强化   
}

EnumRankType = 
{
	Top_Power 			= 1,  		--战力榜
	Hero 				= 2, 		--英雄榜
	Arena 				= 3, 		--竞技场
	Ghost_Tower  		= 4, 		--鬼神之塔
	Guild 				= 5, 		--公会等级
	Guild_Boom 			= 6, 		--公会繁荣
	Stage 				= 7, 		--关卡榜
	BossHurt 			= 8, 		--BOSS伤害榜
	Arena_Top_Power 	= 9, 		--竞技场战力榜
	ScoreMatch1V1 		= 14, 		--积分赛1v1
	ScoreMatch3V3 		= 15, 		--积分赛3v3

}

EnumNewShenQiShuXing = 
{
	Shen                = 1,         -- 身
	Hun                 = 2,         -- 魂
	Ling                = 3,         -- 灵
}
EnumNewShenQiEffect =
{
	Unkown              = 0,        --未知
	Attack_Up           = 1,        --加攻击力
	Move_Speed          = 2,        --加移动
	Hurt_Up             = 3,        --加伤害
	Get_Role            = 4,        --获得角色
	Get_Pet             = 5,        --抓宠
}

EnumNewShenQiCondition = 
{
	Complete_Mission     = 1,       --完成章节
	Kill_Monster         = 2,       --击杀怪物
	Catch_Pet            = 3,       --捕捉宠物
	Open_Eye             = 4,       --开启异色之瞳
	Kill_Adventure_Boss  = 5,       --击杀山海奇遇BOSS
	Collect_Card_Role    = 6,       --收集角色
	Use_Cure_Celue       = 7,       --使用治疗技能
	Complete_Round_task  = 8,       --完成跑环次数

}

EnumMainTaskTab = 
{
	TASk                = 1,         --任务
	TEAM                = 2          --队伍   
}
--任务引导类型
EnumMainTask = 
{
	MAIN_LINE           = 1,         --主线任务
	TEAM_TASK           = 2,         --组团任务
	GUILD_TASK          = 3,         --公会任务
}
--组队任务类型
EnumTeamTask = 
{
	KILL_DEVIL          = 1,         --降妖伏魔
}

EnumRoundTaskRewardType = 
{
	ALONE_TASK          = 1,         --单任务奖励
	ROUND_TASK			= 2,		 --环任务奖励
	WEEK_TASK 			= 3,		 --周任务奖励
	CAPTAIN_TASK		= 4,		 --队长奖励
}

EnumRoundTaskType = 
{
	GATHER_TASK         = 1,         --采集
	SEEK_TASK			= 2,		 --寻人
	MONSTER_TASK 		= 3,		 --打怪
	GOODS_TASK			= 4,		 --寻物
	PET_TASK 			= 5,		 --捉宠
	BOOS_TASK			= 6,		 --沙包
}

EnumRoundTaskStatus = 
{
	NO_TEAM         	= 1,         --未进入降妖伏魔组队及任务状态时	
	HAVE_TEAM			= 2,		 --进入降妖伏魔组队后
	HAVE_TASK 			= 3,		 --开始降妖伏魔任务后（接小任务）
	STATUS_TASK			= 4,		 --开始降妖伏魔任务后（小任务中）
	COMPLETE_TASK 		= 5,		 --开始降妖伏魔任务后（还小任务）	
	ROUND_TASK			= 6,		 --完成降妖伏魔环任务
}

--同步场景分类  
EnumSceneType =
{
	BigWorld 		= 6, 		--大地图
	Challenge   	= 7,		--机关房
	Home 	    	= 8, 		--主城
	Mall 	    	= 9, 		--商业街
	Tavern      	= 10, 		--组队酒馆
	Guild      		= 11, 		--帮会老家
}

--新聊天类型     
EnumNewChatType =
{
	System = 1,
	World = 2,
	Server = 3,
	Party = 4,
	Guild = 5,
	Team = 6,
	Scene = 7,
	Friend = 8,
	Private = 9,
}

EnumNewChatTplType =
{
	Normal = 1,			--普通模版
	Voice = 2,			--语音模版
	Text = 3,			--文本模版 
}

EnumGuildNoticeType = 
{
	Kick = 1,				
	Duty = 2,						
	Apply = 3,
}

EnumFuLiType = 
{
	Sign = 1, 			--签到
	EatBaozi = 2,		--吃包子
	LevelGift = 3,		--等级礼包
	Repurchase = 4,		--资源回购
	FuliEveryDay = 5,	--每日福利
	GrowthFund = 6,		--成长基金
	RedPacketRain = 7,	--红包雨
}

EnumArenaMatchState = 
{
	OFF = 1,			-- 未开始
	BET = 2,			-- 可下注
	NO_FORMATION = 3,	--停止调整阵容
	FIGHT = 4,			-- 战斗中
	END = 5,			--战斗结束
}

EnumMessagePushType = 
{
	TeamKillDevilInvite = 1,		--组队降妖伏魔邀请
	GodPetMining = 2,				--挖矿神宠
	TeamScore3v3Match = 4,          --积分赛3v3	
}

--设置界面推送类型     
EnumPushSwitchType = 
{
	Show_Player = 1,
}

--分享类型     
EnumShareType = 
{
	WeChat = 1,			--朋友圈
	Friend_Circle = 4,	--微信
}

EnumSubPackageType =
{
	Role  = 1,				--游戏角色资源
	Other = 2,  			--游戏资源
	Sound = 3,				--游戏声音资源
}

--=============================称号=====================================
EnumTitleType = 
{
	Common = 1,        --通用
	Challenge = 2,     --挑战
}


EnumPetMergeType = 
{
	mainPet = 1,		--主宠物
	vicePet = 2,		--副宠物
}