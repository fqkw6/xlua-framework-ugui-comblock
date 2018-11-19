--[[
-- added by wsh @ 2017-11-30
-- Lua面向对象设计
--]]

--保存类类型的虚表
local _class = {}
 
-- added by wsh @ 2017-12-09
-- 自定义类型
ClassType = {
	class = 1,
	instance = 2,
}
 
function BaseClass(classname, super)
	assert(type(classname) == "string" and #classname > 0)
	-- 生成一个类类型
	local class_type = {}
	
	-- 在创建对象的时候自动调用
	class_type.__init = false
	class_type.__delete = false
	class_type.__cname = classname
	class_type.__ctype = ClassType.class
	
	class_type.super = super
	class_type.New = function(...)
		-- 生成一个类对象
		local obj = {}
		obj._class_type = class_type
		obj.__ctype = ClassType.instance
		
		-- 在初始化之前注册基类方法
		setmetatable(obj, { 
			__index = _class[class_type],
		})
		-- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.__init then
					c.__init(obj, ...)
				end
			end

			create(class_type, ...)
		end

		-- 注册一个delete方法
		obj.Delete = function(self)
			local now_super = self._class_type 
			while now_super ~= nil do	
				if now_super.__delete then
					now_super.__delete(self)
				end
				now_super = now_super.super
			end
		end

		return obj
	end

	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type, {
		__newindex = function(t,k,v)
			vtbl[k] = v
		end
		, 
		--For call parent method
		__index = vtbl,
	})
 
	if super then
		setmetatable(vtbl, {
			__index = function(t,k)
				local ret = _class[super][k]
				--do not do accept, make hot update work right!
				--vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end


--[[--
如果对象是指定类或其子类的实例，返回 true，否则返回 false

~~~ lua

local Animal = class("Animal")
local Duck = class("Duck", Animal)

print(iskindof(Duck.new(), "Animal")) -- 输出 true

~~~

@param mixed obj 要检查的对象
@param string classname 类名

@return boolean ]]--
function IsKindOf(obj, classname)
	local t = type(obj)
	local mt
	if t == "table" then
		mt = getmetatable(obj)
	elseif t == "userdata" then
		mt = tolua.getpeer(obj)
	end

	while mt do
		if mt.__cname == classname then
			return true
		end
		mt = mt.super
	end

	return false
end

function HandlerNoArg(obj, method)
	return function()
		return method(obj)
	end
end

function HandlerArg1(obj, method, arg1)
	return function(arg1)
		return method(obj,arg1)
	end
end

function Handler(obj, method, ...)
	return function(...)
		return method(obj, ...)
	end
end
