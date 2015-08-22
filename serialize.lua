-- serialize.lua
local Helper = {}

--[[
私有方法，用于控制缩进
--]]
local function intent()
	local spaces = {""}
	return function ()
		table.insert(spaces,'\t')
		return spaces
	end
end
local intentTab = intent()

--[[
序列化
--]]
function Helper.serialize(o)
	local _t = type(o)
	if _t == 'nil' then
		io.write(tostring(o))
	elseif _t == 'boolean' then
		io.write(tostring(o))
	elseif _t == 'number' then
		io.write(o)
	elseif _t == 'string' then
		io.write(string.format("%q", o))
	elseif _t == 'table' then
		io.write('{\n');
		local tab = intentTab()
		local tabstr = table.concat(tab)
		for k,v in pairs(o) do
			io.write(tabstr .. "[")
			Helper.serialize(k)
			io.write("] = ")
			Helper.serialize(v)
			io.write(",\n")
		end
		table.remove(tab)
		local tab2 = table.concat(tab)
		io.write(tab2 .. '}')
	end
end

--[[
反序列化
--]]
function Helper.unserialize(o)
	local _t = type(o)
	if _t == "nil" or o == "" then
		return nil
	elseif _t == "number" or _t == "string" or _t == "boolean" then
		o = tostring(o)
	else
		error("unsupported type " .. _t)
	end
	local lua = "do local ret = " .. o .. " return ret end"
	local _f = loadstring(lua) -- 加载脚本，失败的话，返回nil
	return _f and _f() or nil
end

--[[
-- test cases
local x1 = nil
local x2 = 78
local x3 = true
local x4 = 'hello,guy,"are you ok?"'
local x5 = {1,2,3,{name="liangtao",age=32}}
serialize(x1)
serialize(x2)
serialize(x3)
serialize(x4)
io.write('\n')
serialize(x5)
--]]
return Helper