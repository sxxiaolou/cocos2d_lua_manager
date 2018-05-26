-- Created by ZZTENG on 2017/11/30.
-- 读取资源路径统一管理,便于资源管理,整理版本

--[[
    规则： 以资源目录区分(基本单个系统模块都会以单个目录放资源)
       程序中使用路径命名规范：路径(用全局变量定义)+资源名
       凡是使用此目录下资源，在全局变量定义此目录名下面备注下
       例子：
          uiconfig_handbook_path = 'lua.uiconfig.handbook.'
          --[1. name1
             2. name2 ~ name8
             ...
          ]
]]
--============================UI导出lua配置=======================================
--统一路径
local uiconfig_path = 'lua.uiconfig.'
--图鉴
uiconfig_handbook_path = uiconfig_path .. 'handbook.'
--[[
    1. HandBookMainLayer
    2. HandBookRoleStarLayer
    3. HandBookShowLayer
    4. HandBookXiangLayer
    5. NewHandBookMainLayer
    6. NewHandBookRoleLayer
]]









--===========================声音=================================================
--统一路径
local sound_path = 'sound/'
--背景音乐
sound_bgmusic_path = sound_path .. 'bgmusic/'