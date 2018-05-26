--[[
******积分赛管理类*******

]]

local BaseManager = require("lua.gamedata.BaseManager")
local ScoreMatchManager = class("ScoreMatchManager", BaseManager)
ScoreMatchManager.OnMatch1v1Res 	= "ScoreMatchManager.OnMatch1v1Res"
ScoreMatchManager.RankingListScoreMatch1v1Back 	= "ScoreMatchManager.RankingListScoreMatch1v1Back"
ScoreMatchManager.s2cOnScoreMatchInfoRes="ScoreMatchManager.s2cOnScoreMatchInfoRes"
ScoreMatchManager.s2cOnOnBuyMoreTeamRes="ScoreMatchManager.s2cOnOnBuyMoreTeamRes"
ScoreMatchManager.s2cRankingListScoreMatch3v3 	= "ScoreMatchManager.s2cRankingListScoreMatch3v3"
ScoreMatchManager.s2cOnMatch3v3Res	= "ScoreMatchManager.s2cOnMatch3v3Res"
ScoreMatchManager.s2cOnScoreMatchFightResult	= "ScoreMatchManager.s2cOnScoreMatchFightResult"
ScoreMatchManager.s2cOnTeamListRes	= "ScoreMatchManager.s2cOnTeamListRes"


function ScoreMatchManager:ctor()
	self.super.ctor(self)
end

function ScoreMatchManager:init()
    self.super.init(self)
    self.ScoreMatchInfoRes=nil
    self.openScoreMatchBoardLayerIng=0;
    self.RankingListScoreMatch1v1Info=nil;
    self.RankingListScoreMatch3v3Info=nil;
    self.RankingListScoreMatch1v1InfoCount=0
    self.RankingListScoreMatch3v3InfoCount=0
    self.rewardTime=0;
    self.needOpenMyTeamPos=0;
    self.openScoreMatchTeamMainLayerIngPos=0;
    self. team3v3teamList=nil
    self.ScoreMatchFight=nil
    self.notShowFull=true
    self.openTeamMainLayer=false;
   TFDirector:addProto(s2c.SCORE_MATCH_INFO_RES, self, self.OnScoreMatchInfoRes)
   TFDirector:addProto(s2c.MATCH1V1_RES, self, self.OnMatch1v1Res)
   TFDirector:addProto(s2c.RANKING_LIST_SCORE_MATCH1V1, self, self.OnRankingListScoreMatch1v1)
   TFDirector:addProto(s2c.RANKING_LIST_SCORE_MATCH3V3, self, self.OnRankingListScoreMatch3v3)
   TFDirector:addProto(s2c.CREATE_TEAM_RES, self, self.OnCreateTeamRes)
   TFDirector:addProto(s2c.EXIT_TEAM_RES, self, self.OnExitTeamRes)
   TFDirector:addProto(s2c.TEAM_LIST_RES, self, self.OnTeamListRes)
   TFDirector:addProto(s2c.JOIN_TEAM_RES, self, self.OnJoinTeamRes)
   TFDirector:addProto(s2c.KICK_TEAM_RES, self, self.OnKickTeamRes)
   TFDirector:addProto(s2c.CONFIRM_TEAM_RES, self, self.OnConfirmTeamRes)
   TFDirector:addProto(s2c.BUY_MORE_TEAM_RES, self, self.OnBuyMoreTeamRes)
   TFDirector:addProto(s2c.MATCH3V3_RES, self, self.OnMatch3v3Res)
   TFDirector:addProto(s2c.SCORE_MATCH_FIGHT_RESULT, self, self.OnScoreMatchFightResult)
   TFDirector:addProto(s2c.KICK_TEAM_RES, self, self.OnKickTeamRes)
   
end

function ScoreMatchManager:restart()
   -- TFDirector:addMEGlobalListener(BagManager.ITEM_USED_RESULT, self.usedResultListener)
end


function  ScoreMatchManager:StaropenScoreMatchBoardLayer(type)
    self.openScoreMatchBoardLayerIng=type;
    if type==1 then
    self:sendQueryRankingBaseInfo(EnumRankType.ScoreMatch1V1,0,10);
    else
    self:sendQueryRankingBaseInfo(EnumRankType.ScoreMatch3V3,0,10);
    end
end


function  ScoreMatchManager:openScoreMatchMainLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchMainLayer")
    layer:loadData()
    AlertManager:show()
end

function  ScoreMatchManager:openScoreMatch1V1MainLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchOneMainLayer")
    layer:loadData()
    AlertManager:show()
end

function  ScoreMatchManager:openScoreMatchOnePipeiLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchOnePipeiLayer")
    layer:loadData()
    AlertManager:show()
end

function  ScoreMatchManager:openScoreMatchBoardLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchBoardLayer")
    layer:loadData(self.openScoreMatchBoardLayerIng)
    AlertManager:show()
    self.openScoreMatchBoardLayerIng=0
end

function  ScoreMatchManager:openScoreMatchJiangLiLayer(type)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchJiangLiLayer")
    layer:loadData(type)
    AlertManager:show()
end
--3v3主界面
function  ScoreMatchManager:openScoreMatchThreeMainLayer()
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchThreeMainLayer")
    layer:loadData()
    AlertManager:show()
end
--3v3我的队伍界面
function  ScoreMatchManager:openScoreMatchMyTeamLayer(pos)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchMyTeamLayer")
    layer:loadData(pos)
    AlertManager:show()
end
--3v3寻求组队界面
function  ScoreMatchManager:openScoreMatchTeamMainLayer(pos)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchTeamMainLayer")
    layer:loadData(pos)
    AlertManager:show()
end

--3v3匹配界面
function  ScoreMatchManager:openScoreMatch3v3PiPeiLayer(pos)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatch3v3PiPeiLayer")
    layer:loadData(pos)
    AlertManager:show()
end
--3v3匹配界面
function  ScoreMatchManager:openScoreMatchAddLayer(pos)
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchAddLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
   -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.ScoreMatch.ScoreMatchAddLayer")
    layer:loadData(pos)
    AlertManager:show()
end




--请求积分赛信息
function ScoreMatchManager:sendScoreMatchInfoReq()
   -- print('--------------------------------------------------------------------------sendScoreMatchInfoReq',true)
	self:sendWithLoading(c2s.SCORE_MATCH_INFO_REQ, true)
end

--请求匹配1v1 或者进入1v1战斗
function ScoreMatchManager:sendMatch1v1Req(type,enemyId)
    -- print('--------------------------------------------------------------------------sendScoreMatchInfoReq',true)
     self:send(c2s.MATCH1V1_REQ, type,enemyId)
 end

--请求匹配3v3 或者进入3v3战斗
function ScoreMatchManager:sendMatch3v3Req(teamId,type,enemyId)
    -- print('--------------------------------------------------------------------------sendScoreMatchInfoReq',true)
     self:send(c2s.MATCH3V3_REQ, teamId,type,enemyId)
 end

 
--请求排行信息
function ScoreMatchManager:sendQueryRankingBaseInfo(type,startIndex,length)
   -- print('--------------------------------------------------------------------------sendQueryRankingBaseInfo')
     self:sendWithLoading(c2s.QUERY_RANKING_BASE_INFO, type,startIndex,length)
 end

--请求领取段位奖励
function ScoreMatchManager:sendScoreRewardReq(type,level)
  --  print('--------------------------------------------------------------------------sendScoreRewardReq...................................')
     self:sendWithLoading(c2s.SCORE_REWARD_REQ, type,level)
 end
 
--请求创建3v3队伍
function ScoreMatchManager:sendCreateTeamReq(pos,name)
  --  print('--------------------------------------------------------------------------sendCreateTeamReq...................................')
     self:sendWithLoading(c2s.CREATE_TEAM_REQ, pos,name)
 end
 --请求退出3v3队伍
function ScoreMatchManager:sendExitTeamReq(teamId)
   -- print('--------------------------------------------------------------------------sendExitTeamReq...................................')
     self:sendWithLoading(c2s.EXIT_TEAM_REQ, teamId)
 end
  --请求队伍列表
function ScoreMatchManager:sendTeamListReq(openingpos,page,noShowFull,openlayer)
   -- print('--------------------------------------------------------------------------sendTeamListReq...................................')
    self.notShowFull=noShowFull
    self.openTeamMainLayer=openlayer
    self.openScoreMatchTeamMainLayerIngPos=openingpos
     self:sendWithLoading(c2s.TEAM_LIST_REQ,page,noShowFull)

 end
 
   --请求加入队伍
function ScoreMatchManager:sendJoinTeamReq(teamId,pos,joinNow)
  --  print('--------------------------------------------------------------------------sendTeamListReq...................................')
     self:sendWithLoading(c2s.JOIN_TEAM_REQ,teamId,pos,joinNow)
 end
 
   --请求踢人
function ScoreMatchManager:sendKickTeamReq(teamId,playerId)
  --  print('--------------------------------------------------------------------------sendKickTeamReq...................................')
     self:sendWithLoading(c2s.KICK_TEAM_REQ,teamId,playerId)
 end
    --请求确认队伍
function ScoreMatchManager:sendConfirmTeamReq(teamId)
   -- print('--------------------------------------------------------------------------sendConfirmTeamReq...................................')
     self:sendWithLoading(c2s.CONFIRM_TEAM_REQ,teamId)
 end
     --请求购买队伍
function ScoreMatchManager:sendBuyMoreTeamReq()
   -- print('--------------------------------------------------------------------------sendBuyMoreTeamReq...................................')
     self:sendWithLoading(c2s.BUY_MORE_TEAM_REQ,true)
 end
     --请求邀请队员
function ScoreMatchManager:sendInviteTeamReq(id,playerId)
     --   print('--------------------------------------------------------------------------sendInviteTeamReq...................................')
         self:send(c2s.INVITE_TEAM_REQ,id,playerId)
end
     --请求接受邀请
function ScoreMatchManager:sendAcceptInvite(id)
    --    print('--------------------------------------------------------------------------sendAcceptInvite...................................')
         self:send(c2s.ACCEPT_INVITE,id)
end


 function ScoreMatchManager:getPlayerMateIndex(teamtype,playerid)

    for i=1, #self.ScoreMatchInfoRes.match3v3 do
        if self.ScoreMatchInfoRes.match3v3[i].pos==teamtype-6 then
         local  t_players= self.ScoreMatchInfoRes.match3v3[i].players
         for k=1,#t_players do
            if t_players[k].playerId==playerid then
                return  t_players[k].mateIndex
            end
         end
        end
    end
    return 0
 end

 function ScoreMatchManager:getPlayerisLeader(teamtype)

    for i=1, #self.ScoreMatchInfoRes.match3v3 do
        if self.ScoreMatchInfoRes.match3v3[i].pos==teamtype-6 then
         local  t_players= self.ScoreMatchInfoRes.match3v3[i].players
         for k=1,#t_players do
            if t_players[k].playerId==MainPlayer:getPlayerId()   then
                return  t_players[k].isLeader
            end
         end
        end
    end
    return false
    end

    function ScoreMatchManager:getPlayeridList(teamtype)
        local idList =TFArray:new()
            for i=1, #self.ScoreMatchInfoRes.match3v3 do
                if self.ScoreMatchInfoRes.match3v3[i].pos==teamtype-6 then
                 local  t_players= self.ScoreMatchInfoRes.match3v3[i].players
                 for k=1,#t_players do
                    idList:push(t_players[k].playerId)
                end
                 end
                end
           
            return idList
    end

function ScoreMatchManager:getHasScoreMatchrewardAndTiems()
    if self.ScoreMatchInfoRes==nil then
        return false
    end
    local  match1v1=self.ScoreMatchInfoRes.match1v1
    local T_reward=match1v1.reward
    local  rewards= stringToTable(T_reward, ',')
   -- local ScoreMatchrewardTableDatas =TFArray:new()
    for v in ScoreMatchLevelrewardData:iterator() do
        if v.type==1 and  v.stage<= match1v1.level then
             b=false
            for t in pairs(rewards) do
                if tonumber(t)==v.stage then
                    b=true
                end
            end
            if b==false then
                return true
            end
         --  ScoreMatchrewardTableDatas:push(v)
        end
        --todo 判断3v3-------------
        --end todo----------------------------------
      end

      if match1v1.restTimes> 0 then
        return true
      end
        --todo 判断3v3-------------
        --end todo----------------------------------

  return false
end
function ScoreMatchManager:getHasScoreMatch1v1rewardAndTiems()
    if self.ScoreMatchInfoRes==nil then
        return false
    end
    local  match1v1=self.ScoreMatchInfoRes.match1v1
    local T_reward=match1v1.reward
    local  rewards= stringToTable(T_reward, ',')
    for v in ScoreMatchLevelrewardData:iterator() do
        if v.type==1 and  v.stage<= match1v1.level then
             b=false
            for t in pairs(rewards) do
                if tonumber(t)==v.stage then
                    b=true
                end
            end
            if b==false then
                return true
            end
        end
      end

    if match1v1.restTimes> 0 then
        return true
      end

      return false
end

function ScoreMatchManager:getHasScoreMatch1v1reward()
    if self.ScoreMatchInfoRes==nil then
        return false
    end
    local  match1v1=self.ScoreMatchInfoRes.match1v1
    local T_reward=match1v1.reward
    local  rewards= stringToTable(T_reward, ',')
    for v in ScoreMatchLevelrewardData:iterator() do
        if v.type==1 and  v.stage<= match1v1.level then
             b=false
            for t in pairs(rewards) do
                if tonumber(t)==v.stage then
                    b=true
                end
            end
            if b==false then
                return true
            end
        end
      end

  return false
end
function ScoreMatchManager:getHasScoreMatch3v3reward()
    if self.ScoreMatchInfoRes==nil then
        return false
    end
    -- local match3v3=self.ScoreMatchInfoRes.match3v3
    -- local t_ranking = -1
    -- local bestmatch3v3=nil
    -- if  match3v3==nil then
    --     t_ranking=0
    --     bestmatch3v3=nil
    -- else
    --     for i=1,#match3v3 do
    --         if match3v3[i].rank>t_ranking then
    --             t_ranking=match3v3[i].rank
    --             bestmatch3v3=match3v3[i]
    --        end
    --     end
    -- end
   local T_reward=self.ScoreMatchInfoRes.reward3v3
   local  rewards= stringToTable(T_reward, ',')
    for t in ScoreMatchLevelrewardData:iterator() do
       if  t.type==1 and  t.stage<= self.ScoreMatchInfoRes.bestLevel then
            b=false
            for v in pairs(rewards) do
                if tonumber(v)==t.stage then
                    b=true
                end
            end
            if b==false then
                return true
            end
       end
      
    
   end


  return false
end
function ScoreMatchManager:getHasScoreMatch3v3tiems()--3v3队伍次数
    if self.ScoreMatchInfoRes==nil then
        return false
    end
    local match3v3=self.ScoreMatchInfoRes.match3v3
    if match3v3==nil then
        return false
    end
    for i=1,#match3v3 do
        if match3v3[i].restTimes>0 then
            return true
        end
    end
end
function ScoreMatchManager:getHasScoreMatch3v3rewardAndTiems()
    local b1 = self:getHasScoreMatch3v3tiems()
    local b2 = self:getHasScoreMatch3v3reward()
    if b1 or b2  then
        return true
    end
    return false
end
function ScoreMatchManager:getHasScorehongdian()
    local b1 = self:getHasScoreMatch3v3tiems()
    local b2 = self:getHasScoreMatch3v3reward()
    local b3=self:getHasScoreMatch1v1rewardAndTiems()
    if b1 or b2 or b3 then
        return true
    end
    return false
end

 --返回积分赛信息
function ScoreMatchManager:OnScoreMatchInfoRes( event )
    hideLoading()
    local data = event.data
    self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
   self.rewardTime=data.rewardTime or 0
   if self.mainRoleTimerId then
    TFDirector:removeTimer(self.mainRoleTimerId)
    self.mainRoleTimerId = nil
    self.onTimerUpdated = nil
    end
    self.onTimerUpdated = function(timer)
        if  self.rewardTime>0 then
        self.rewardTime=self.rewardTime-1
        end
    end
 --  self.mainRoleTimerId = TFDirector:addTimer(60000,-1,self.onTimerUpdatedEnd2,self.onTimerUpdated)
   self.mainRoleTimerId = TFDirector:addTimer(1000,-1,nil,self.onTimerUpdated)


   if  self.needOpenMyTeamPos>0 then
      
      self.needOpenMyTeamPos=0
    end
  --  print('------------服务器返回--------------------------------------------------------------OnScoreMatchInfoResOnScoreMatchInfoResOnScoreMatchInfoResOnScoreMatchInfoResOnScoreMatchInfoRes  ScoreMatchInfoRes',data)

    TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cOnScoreMatchInfoRes, data)
end

--返回1v1匹配信息
function ScoreMatchManager:OnMatch1v1Res( event )
    hideLoading()
    local data = event.data
   -- self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
    TFDirector:dispatchGlobalEventWith(ScoreMatchManager.OnMatch1v1Res, data)
  -- print('------------服务器返回--------------------------------------------------------------OnMatch1v1Res ',data)
end

--返回3v3匹配信息
function ScoreMatchManager:OnMatch3v3Res( event )
    hideLoading()
    local data = event.data
   -- self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
    TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cOnMatch3v3Res, data)
  -- print('------------服务器返回--------------------------------------------------------------OnMatch3v3Res ',data)
end

--返回1v1排行信息
function ScoreMatchManager:OnRankingListScoreMatch1v1( event )
    hideLoading()
    local data = event.data
    if data==nil or  data.ranks==nil then
        self.RankingListScoreMatch1v1InfoCount=0
    else
        self.RankingListScoreMatch1v1InfoCount=#data.ranks
    end
 
    if    self.openScoreMatchBoardLayerIng>0  or  self.RankingListScoreMatch1v1Info==nil then
        self.RankingListScoreMatch1v1Info=data
    else
        self.RankingListScoreMatch1v1Info.myRank=data.myRank
        table.insertTo(self.RankingListScoreMatch1v1Info.ranks, data.ranks)
         if  data.ranks==nil or #data.ranks<=0 then
             return
           end
    end
  --  TFDirector:dispatchGlobalEventWith(ScoreMatchManager.OnMatch1v1Res, data)

  TFDirector:dispatchGlobalEventWith(ScoreMatchManager.RankingListScoreMatch1v1Back, data)
 -- print('------------服务器返回--------------------------------------------------------------OnRankingListScoreMatch1v1 ',data)
   if  self.openScoreMatchBoardLayerIng>0 then
    self:openScoreMatchBoardLayer();
   end
 
end

--返回3v3排行信息
function ScoreMatchManager:OnRankingListScoreMatch3v3( event )
    hideLoading()
    local data = event.data
 
    if data==nil or  data.ranks==nil then
        self.RankingListScoreMatch3v3InfoCount=0
    else
        self.RankingListScoreMatch3v3InfoCount=#data.ranks
    end
    if   self.openScoreMatchBoardLayerIng>0  or  self.RankingListScoreMatch3v3Info==nil then
        self.RankingListScoreMatch3v3Info=data
    else
        self.RankingListScoreMatch3v3Info.myRank=data.myRank
        table.insertTo(self.RankingListScoreMatch3v3Info.ranks, data.ranks)
    end
   -- self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
   print('------------服务器返回--------------------------------------------------------------OnRankingListScoreMatch3v3 ',data)
   TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cRankingListScoreMatch3v3, data)
   if  self.openScoreMatchBoardLayerIng>0 then
    self:openScoreMatchBoardLayer();
   end
end

--返回创建队伍
function ScoreMatchManager:OnCreateTeamRes( event )
    hideLoading()
    local data = event.data
    self.needOpenMyTeamPos=data.pos;
   -- self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
  -- self:sendScoreMatchInfoReq()
  self:openScoreMatchMyTeamLayer(data.pos)
 --  print('------------服务器返回--------------------------------------------------------------OnCreateTeamRes ',data)
end

--返回退出队伍
function ScoreMatchManager:OnExitTeamRes( event )
    hideLoading()
    local data = event.data
   -- self.needOpenMyTeamPos=data.pos;
   -- self.ScoreMatchInfoRes=data
   -- self.FashionInfoResInfo= event.data;
  -- self:sendScoreMatchInfoReq()
  -- print('------------服务器返回--------------------------------------------------------------OnExitTeamRes ',data)
end
--返回队伍列表
function ScoreMatchManager:OnTeamListRes( event )
    hideLoading()
    local data = event.data
    self. team3v3teamList=data.teams
    TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cOnTeamListRes, data)
    if self.openScoreMatchTeamMainLayerIngPos>0 then

        self:openScoreMatchTeamMainLayer(self.openScoreMatchTeamMainLayerIngPos)
        self.openScoreMatchTeamMainLayerIngPos=0
    end
  -- print('------------服务器返回--------------------------------------------------------------OnTeamListRes ',data)
end

--返回加入队伍
function ScoreMatchManager:OnJoinTeamRes( event )
    hideLoading()
    local data = event.data
    self:openScoreMatchMyTeamLayer(data.pos)
  -- print('------------服务器返回--------------------------------------------------------------OnJoinTeamRes ',data)
end
--返回踢人
function ScoreMatchManager:OnKickTeamRes( event )
    hideLoading()
    local data = event.data
  -- print('------------服务器返回--------------------------------------------------------------OnKickTeamRes ',data)
end
--返回确认队伍
function ScoreMatchManager:OnConfirmTeamRes( event )
    hideLoading()
    local data = event.data
 --  print('------------服务器返回--------------------------------------------------------------OnConfirmTeamRes ',data)
end
--返回购买额外队伍
function ScoreMatchManager:OnBuyMoreTeamRes( event )
    hideLoading()
    local data = event.data
   -- ScoreMatchManager.s2cOnOnBuyMoreTeamRes
    TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cOnOnBuyMoreTeamRes, data)
  -- print('------------服务器返回--------------------------------------------------------------OnBuyMoreTeamRes ',data)
end

--返回积分赛战斗后积分变化
function ScoreMatchManager:OnScoreMatchFightResult( event )
    hideLoading()
    local data = event.data
    self.ScoreMatchFight=data
   -- ScoreMatchManager.s2cOnOnBuyMoreTeamRes
   TFDirector:dispatchGlobalEventWith(ScoreMatchManager.s2cOnScoreMatchFightResult, data)
 --  print('------------服务器返回--------------------------------------------------------------OnScoreMatchFightResult---OnScoreMatchFightResult---OnScoreMatchFightResult---OnScoreMatchFightResult---OnScoreMatchFightResult---OnScoreMatchFightResult ',data)
end





return ScoreMatchManager:new()

