-- test_class.lua

--[[
帐户基类：Account
方法：存款&取款
限制：取款的数目不能超过其存款
--]]
Account = {balance = 0}

function Account:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Account:deposit(v)
	self.balance = self.balance + v
end

--[[
取款的额度最大为存款数
--]]
function Account:withdraw(v)
	if v > self.balance then
		error("insufficient funds")
	end
	self.balance = self.balance - v
end

--[[
子类：SpecailAccount
--]]
SpecailAccount = Account:new()

function SpecailAccount:getLimit()
	return self.balance * 0.10
end

function SpecailAccount:withdraw(v)
	if v - self.balance >= self:getLimit() then error("insufficient funds") end
	self.balance = self.balance - v
end

s = SpecailAccount:new({limit = 1000.00})

s:deposit(10000.00)
print(s.balance)
s:withdraw(2000.00)
print(s.balance)
s:withdraw(8700.00)
print(s.balance)
s:withdraw(700.00)