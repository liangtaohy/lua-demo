-- test_matrix.lua

local matrix = {_TYPE='module', _NAME='matrix', _VERSION='0.0.1.20150812', _AUTHOR='liangtao01'}
local matrix_meta = {}

function matrix:new(rows, column, value)
	local mtx = {}
	local value = value or '0'
	local _t_rows = type(rows)
	if _t_rows == 'table' then -- unsupported now
		return false
	end
	if type(rows) == 'number' and column == 'I' then
		for i=1,rows do
			mtx[i] = {}
			for j=1,rows do
				if i==j then
					mtx[i][j] = value
				else
					mtx[i][j] = 0
				end
			end
		end
	else
		for i=1,rows do
			mtx[i] = {}
			for j=1,column do
				mtx[i][j] = value
			end
		end
	end
	return setmetatable(mtx, matrix_meta)
end

--[[
set __call behavior of matrix(...)
--]]
setmetatable( matrix, { __call = function( ... ) return matrix:new( ... ) end } )

-- Add two matrixes
function matrix.add(m1,m2)
	local m1Len = #m1
	local m2Len = #m2
	local mtx = {}
	for i=1,m1Len do
		local m3i = {}
		mtx[i] = m3i
		for j=1,#mtx[1] do
			m3i[j] = m1[i][j] + m2[i][j]
		end
	end
	return setmetatable(mtx, matrix_meta)
end

-- Substract two matrixes
function matrix.sub(m1, m2)
	local m1Len = #m1
	local m2Len = #m2
	local mtx = {}
	for i=1,m1Len do
		local m3i = {}
		mtx[i] = m3i
		for j=1,#mtx[1] do
			m3i[j] = m1[i][j] - m2[i][j]
		end
	end
	return setmetatable(mtx, matrix_meta)
end

function matrix:dump(self)
	local len = #self
	for i=1,len do
		local log = nil
		for j=1,#self[i] do
			if log then
				log = log .. "," .. self[i][j]
			else
				log = "" .. self[i][j]
			end
		end
		print(log)
	end
end
--[[
-- matrix multiple
-- m1's columns must be equal to m2's rows
--]]
function matrix.mul(m1, m2)
	local m1Len = #m1
	local m2Len = #m2
	local rows = #m2[1]
	local mtx = {}
	assert(m1Len == rows, "m1 columns must be equal to m2 rows")
	for i=1, m1Len do
		mtx[i] = {}
		for j=1, m2Len do
			local sum = m1[i][1]*m2[1][j]
			for k=2, m2Len do
				sum = sum + m1[i][k]*m2[k][j]
			end
			mtx[i][j] = sum
		end
	end
	return setmetatable(mtx, matrix_meta)
end

--[[
求m1与m2的并集
return replicated, table
有两个返回值：replicated为重复的键的数目, table为求并集后的新表
--]]
function matrix.union(m1, m2)
	local re = {}
	local replicated = 0
	for k,v in pairs(m1) do
		re[k] = v
	end
	for k,v in pairs(m2) do
		if re[k] == nil then
			re[k] = v
		else
			replicated = replicated + 1 -- 统计重复的键
		end
	end
	return re
end

--[[
合并矩阵m1,m2。如果有相同的key，则保留m1[k]的值，m2[k]的被丢弃
--]]
function matrix.kintersecation(m1, m2)
	local re = {}
	for k,v in pairs(m1) do
		if m2[k] ~= nil then
			re[k] = v
		end
	end
	return re
end

--[[
1xN维矩阵的欧氏长度，即向量的欧氏长度
|{a,b,c}| = sqrt(a^2 + b^2 + c^2)
--]]
function matrix.norm(o)
	local euclidean = 0
	for _,v in pairs(o) do
		local _t = type(v)
		if _t == 'number' then
			if type(v) == 'number' and v ~= nil and v ~= false and v ~= 0 then
				euclidean = euclidean + v*v
			end
		else
			error("matrix contains non-number value!!")
		end
	end
	return math.sqrt(euclidean)
end

return matrix