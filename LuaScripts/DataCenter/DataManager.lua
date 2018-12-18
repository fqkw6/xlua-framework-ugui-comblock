--[[
-- added by wsh @ 2017-12-05
-- 数据管理系统：消息系统
-- 注意：
-- 1、理论上，网络层状态数据到来，只需要操作数据中心修改逻辑数据，不要直接修改游戏逻辑
-- 2、网络层操作数据到来，等同于用户操作，操作Ctrl层（MVC架构）或者System（ECS架构），让它们来操作数据层
-- 3、游戏UI模块各Model层监听数据中心消息提取各个Window关注的模型数据
--]]

local Messenger = require "Framework.Common.Messenger"
local unpack = unpack or table.unpack

---@class DataManager:Singleton
local DataManager = BaseClass("DataManager", Singleton);

function DataManager:__init()
	self.data_message_center = Messenger.New()
end

function DataManager:__delete()
	self.data_message_center = nil
end

-- 注册消息
function DataManager:AddListener(e_type, e_listener, ...)
	self.data_message_center:AddListener(e_type, e_listener, ...)
end

-- 发送消息
function DataManager:Broadcast(e_type, ...)
	self.data_message_center:Broadcast(e_type, ...)
end

-- 注销消息
function DataManager:RemoveListener(e_type, e_listener)
	self.data_message_center:RemoveListener(e_type, e_listener)
end

return DataManager;