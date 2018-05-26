-- 语音管理类
-- Author: Jing
-- Date: 2016-08-02
--

local VoiceManager = class("VoiceManager", BaseManager)

--临时测试帐号密码
-- VoiceManager.appID 			= "1998589218"
-- VoiceManager.appKey 		= "d4649fc63155bff6861574d128dde271"

--正式帐号密码
VoiceManager.appID 			= "1436765700"
VoiceManager.appKey 		= "693aa81e7366552226bbadf6bc3b342a"

VoiceManager.UploadFileCallBack = "VoiceManager.UploadFileCallBack"
VoiceManager.DownloadFileCallBack = "VoiceManager.DownloadFileCallBack"
VoiceManager.PlayFileCallBack = "VoiceManager.PlayFileCallBack"
VoiceManager.Speech2TextCallBack = "VoiceManager.Speech2TextCallBack"

local VoicePath = nil
local wpath = me.FileUtils:getWritablePath():gsub("\\", "/")
if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
	local sdPath = TFDeviceInfo:getSDPath()
	if sdPath==nil then
		VoicePath = wpath .. "voicecache/"
	else
		VoicePath = sdPath .. "playmore/0/voicecache/"
	end
else
	VoicePath = wpath .. "../Library/voicecache/"
end
TFFileUtil:createDir(VoicePath)

--临时:如果是语音消息content="#*#*&" + fileID
--fileID:上传的音频文件的id

GCloudVoiceMode = 
{
	RealTime = 0, --realtime mode for TeamRoom or NationalRoom
	Messages = 1, --voice message mode
	Translation = 2, --speach to text mode
}

local IMSDKManager = QQIMSDKManager:Inst()

function VoiceManager:ctor()
	self.super.ctor(self)
end

function VoiceManager:init()
	self.pollTimer = TFDirector:addTimer(0, -1, nil, function ()
		if self.hasInit==0 then
			IMSDKManager:Poll()
		end
	end)
end

function VoiceManager:restart()
	self.openID = nil
	self.hasInit = nil
end

function VoiceManager:StartRecording()
	local recordpath = VoicePath .. "audio.dat"
	return IMSDKManager:StartRecording(recordpath), recordpath
end

function VoiceManager:StopRecording()
	return IMSDKManager:StopRecording()
end

function VoiceManager:UploadRecordedFile(filePath)
	filePath = VoicePath .. "audio.dat"
	local ret = IMSDKManager:UploadRecordedFile(filePath)
	return ret
end

function VoiceManager:DownloadRecordedFile(fileID)
	local filePath = self:getDlFileName()
	return IMSDKManager:DownloadRecordedFile(fileID, filePath), filePath
end

function VoiceManager:PlayRecordedFile(filePath)
	local ret = IMSDKManager:PlayRecordedFile(filePath)
	return ret
end

function VoiceManager:StopPlayFile()
	return IMSDKManager:StopPlayFile()
end

function VoiceManager:SpeechToText(fileID)
    print("SpeechToText fileID", fileID)
	return IMSDKManager:SpeechToText(fileID)
end

function VoiceManager:SetAppInfo(playerId)
	self.openID = playerId
	print("self.openID ", self.openID)

	self.hasInit = IMSDKManager:Init(VoiceManager.appID, VoiceManager.appKey, self.openID)
	print("VoiceManager:SetAppInfo Result:", self.hasInit)

 	-- IMSDKManager:SetMode(GCloudVoiceMode.Messages)

	--上传完成回调
	local function OnUploadFileHandlerCallBack( code, filePath , fileID )
		-- if self:error(code) then
		-- 	return
		-- end
		TFDirector:dispatchGlobalEventWith(VoiceManager.UploadFileCallBack, code, filePath , fileID)
	end
	IMSDKManager:setOnUploadFileHandler(OnUploadFileHandlerCallBack)

	--[[
		Callback when download voice file successful or failed.
		
		@param code: a GCloudVoiceCompleteCode code . You should check this first.
		@param filePath: file to download to .
		@param fileID: if success ,get back the id for the file.
	]]
	--下载完成回调
	local function OnDownloadFileHandlerCallBack( code, filePath , fileID )
		-- if self:error(code) then
	--   		return
	--   	end
		TFDirector:dispatchGlobalEventWith(VoiceManager.DownloadFileCallBack, code, filePath , fileID)
	end
	IMSDKManager:setOnDownloadFileHandler(OnDownloadFileHandlerCallBack)

	--[[
	Callback when finish a voice file play end.
	@param filePath: file had been plaied.
	]]
	--正常播放完成后回调
	local function OnPlayRecordedFileHandlerCallBack( code, filePath )
		-- if self:error(code) then
	--   		return
	--   	end
		TFDirector:dispatchGlobalEventWith(VoiceManager.PlayFileCallBack, code, filePath)
	end
	IMSDKManager:setOnPlayRecordedFileHandler(OnPlayRecordedFileHandlerCallBack)

	--语音转文字完成后回调
	local function OnSpeechToTextHandlerCallBack( code, filePath , result )
		-- if self:error(code) then
	--   		return
	--   	end
		if filePath ~= nil and result ~= nil then
			TFDirector:dispatchGlobalEventWith(VoiceManager.Speech2TextCallBack, code, filePath, result)
		end
	end
	IMSDKManager:setOnSpeechToTextHandler(OnSpeechToTextHandlerCallBack)
end

--下载的音频文件名字
function VoiceManager:getDlFileName()
	self.idx = (self.idx or 0) + 1
	if self.idx>9 then self.idx=1 end

	local filePath = VoicePath .. "download" .. self.idx .. ".dat"
	print("getDlFileName", filePath)
	return filePath
end


GCloudVoiceCompleteCode = 
{
	[0x1001] = "需要的参数传入为NULL，请传入正确参数",
	[0x1002] = "出现该错误码，说明你需要在调用出错函数前调用SetAppInfo函数，SetAppInfo一般在最开始调用，先于Init调用",
	[0x1003] = "初始化出错，出现该错误请取日志发给我们定位",
	[0x1004] = "正在录音中，不能做其它函数调用操作，如再次StartRecording,若要做相关操作，请先StopRecording",
	[0x1005] = "Poll Buffer出错，出现该错误请取日志发给我们定位",
	[0x1006] = "模式不对，如：在录音模式，但调用实时语音API，请SetMode到对应的模式",
	[0x1007] = "参数值为空或者非法，如超时范围不符合要求等。请参照头文件函数接品注释传入合法的参数值",
	[0x1008] = "打开文件错误，看是否该文件不存在，或者没有权限",
	[0x1009] = "调用出错函数前，没有调用 Init,请先调用Init",
	[0x100A] = "一般发生在C#接口调用中，没有获取到gcloudvoice实例导致内部引擎实例出错",
	[0x100B] = "C# poll出错，出现该错误请取日志发给我们定位",
	[0x100C] = "Poll返回内部没有回调消息",

	[0x2001] = "该错误发生在实时语音接口中，状态出错，如想JoinRoom，但是前面已经加入了房间，没有调用QuitRoom; 或者想OpenMic，但是前面并没有成功进入房间，也或者想QuitRoom，但是前面并没有进房。",
	[0x2002] = "加入房间失败，看看参数是否合法，或者请取日志发给我们定位",
	[0x2003] = "退房错误，退出房间的roomname需要和前面joinroom时一样，否则会报该错误",
	[0x2004] = "在大房间里面，调用OpenMic，但是因为是以听众进房的，没有开麦克风权限",

	[0x3001] = "ApplyKey出错，出现该错误请取日志发给我们定位",
	[0x3002] = "文件不存在或者没有权限访问，请注意这里的文件路径是包含文件名的完整路径",
	[0x3003] = "Android上没有权限访问MicPhone，请检查下是台允许了应用使用麦克风。或者可能是Android6.0以上返回，打开麦克风失败，参照FAQ第一条，更新Android.Support.V4.jar包。",
	[0x3004] = "使用离线、语音转文字API前，请先调用ApplyMessageKey",
	[0x3005] = "上文件出错，可能是文件大小为0，或者文件不存在",
	[0x3006] = "http正在上传或者下载语音消息",
	[0x3007] = "下载文件出错是，请确认fileid是否正确",
	[0x3008] = "开关Speaker出错，出现该错误请取日志发给我们定位",
	[0x3009] = "播放离线文件出错，请确认文件是由我们录制的，否则出现该错误请取日志发给我们定位",

	[0x5001] = "一般可能是Android6.0以上返回，打开麦克风失败，参照FAQ第一条，更新Android.Support.V4.jar包。",
	[0x5002] = "出现该错误请取日志发给我们定位,腾讯的锅",
	[0x5003] = "出现该错误请取日志发给我们定位,腾讯的锅",
}

function VoiceManager:error(code)
	if code==0x0 then
		return false
	end
	local errInfo = GCloudVoiceCompleteCode[code]
	print("code", code, "info", errInfo)
	return true
end

return VoiceManager:new()