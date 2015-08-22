-- recommendbook.lua

-- 加载Matrix类
local matrix = require('test_matrix')
local math = require('math')
local os = require("os")
local Helper = require("serialize")

-- 数据集：ratings.data (MovieLens的投票数据，中等，约100万行，6000多用户，近4000部电影)
local RAW_DATA_FILE = "/Users/baidu/Downloads/ml-1m/ratings.dat"
local ROW = {from=1,to=6040}
local COL = {from=1,to=3952}
local uPrefix = "u"

--[[
从文件中加载数据，输出为M*4的矩阵，元素为{UserID,MovieID,Rating,Timestamp}
--]]
function LoadData(filename)
	print("Loading data begin ...")

	local t1 = os.time()

	local handle = io.open(filename, "r")
	local re = {}
	for line in handle:lines() do
		local data = {}
		for item in string.gmatch(line, "(%d+)") do
			table.insert(data, tonumber(item))
		end
		table.insert(re, data)
	end
	handle:close()

	local t2 = os.time()

	print("Loading data end ...")
	print("data colums: " .. #re .. ", time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

function SaveToFile(filename, doc)
	local handle = io.open(filename, "w")
	handle:write(doc)
	handle:flush()
	handle:close()
end
--[[
加载初始数据，生成uid,mid(s)矩阵
--]]
function LoadIntoUserMatrix(data)
	print("Load raw data into uid-mid matrix begin ...")

	local t1 = os.time()

	local re = {}
	local size = 0
	for _,v in pairs(data) do
		local key = uPrefix .. v[1] -- key = "u" .. UID
		if re[key] then -- set matrix[uid][mid] to 1
			re[key][v[2]] = 1
		else
			re[key] = {}
			re[key][v[2]] = 1
			size = size + 1
		end
	end

	local t2 = os.time()

	print("Load raw data into uid-mid matrix end ...")
	print("uid-mid matrix colums: " .. size .. ", time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

--[[
测试数据矩阵的正确性，汗！！
--]]
function dataTest(mtx)
	local data = mtx

	if type(data) ~= 'table' then
		error("param must be a table")
	end

	local function _test(uid, mid)
		if data[uPrefix .. uid][mid] then
			-- 调试：序列化输出table Helper.serialize(data[uPrefix .. uid])
			print("success")
		else
			local errstr = string.format('data[%s:%s] not existed!! Please check your Matrix!!', uPrefix .. uid, ' ' .. mid)
			error(errstr)
		end
	end

	_test(6028, 3000)
	_test(5990, 2051)
	_test(1, 3408)
	_test(1, 2355)
	_test(1, 1197)
	_test(20, 1912)
	_test(20, 2571)
	_test(6040, 3735)
	_test(6040, 2791)
	_test(6040, 2794)

end

--[[
初始化一个M*N的矩阵
--]]
function LoadDataIntoMatrix(raw)
	local mtx = matrix:new(ROW.to, COL.to, nil)
	for i=1,#raw do
		mtx[raw[i][1]][raw[i][2]] = 1
	end
	return mtx
end

--[[
给定数据集data，将它随机分成M份，取出其中的第k份，返回第k份，M-1份
--]]
function SplitData(data, M, k, seed)
	print("SplitData matrix begin ...")

	local t1 = os.time()

	local test = {}
	local train = {}
	math.randomseed(seed)
	for uid,v in pairs(data) do
		if math.random(0,M) == k then
			test[uid] = v
		else
			train[uid] = v
		end
	end

	local t2 = os.time()
	print("SplitData matrix time used: " .. os.difftime(t2, t1) .. "s")

	return train, test
end

function W_U_V_Jaccard(data)
	print("W_U_V_Jaccard matrix begin ...")

	local t1 = os.time()

	local re = {}
	for u,j in pairs(data) do
		re[u] = {}
		for v,k in pairs(data) do
			if re[v][u] then
				re[u][v] = re[v][u]
			elseif u == v then
				re[u][v] = 0
			else
				re[u][v] = matrix.norm(matrix.kintersecation(j,k))/matrix.norm(matrix.union(j,k))
			end
		end
	end

	local t2 = os.time()
	print("W_U_V_Jaccard matrix time used: " .. os.difftime(t2, t1) .. "s")

	return re
end

local raw = LoadData(RAW_DATA_FILE)
local umMtx = LoadIntoUserMatrix(raw)
dataTest(umMtx)
local train, test = SplitData(umMtx, 8, 2, os.clock())
local WuvMtx = W_U_V_Jaccard(train)
Helper.serialize(WuvMtx)
