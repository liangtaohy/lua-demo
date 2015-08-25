-- recommendbook.lua
--[[
# 协同过滤实验之基于用户领域的协同过滤
## 用户相似度算法：
1. Jaccard相似度
2. 余弦相似度
3. Pearson相似度
## 数据集

--]]
-- 加载Matrix类
local matrix = require('test_matrix')
local math = require('math')
local os = require("os")
local Helper = require("serialize")

-- 数据集：ratings.data (MovieLens的投票数据，中等，约100万行，6000多用户，近4000部电影)
local RAW_DATA_FILE = "/Users/baidu/Downloads/ml-1m/ratings.dat"
local OUTPUT_FILE = "/Users/baidu/Downloads/ml-1m/wuv.dat"
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
	if handle == nil then
		error("failed to open file: [" .. filename .. "] in r mode")
	end
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
	if handle == nil then
		error("failed to open file: [" .. filename .. "] in w mode")
	end
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
构建物品-用户倒排表
--]]
function BuildItemUsersInverseTable(data)
	print("Load raw data into item-users matrix begin ...")

	local t1 = os.time()

	local re = {}

	for _,v in pairs() do
		local item = v[2]
		if re[item] == nil then
			re[item] = {}
		end
		table.insert(re[item], v[1]) -- insert user into users queue
	end

	local t2 = os.time()
	print("Load raw data into item-users matrix end ...")
	print("item-users matrix time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

--[[
构建物品-用户倒排表
输入为train矩阵，结构为：[ [u] = items], items = [ [item] = 1 ], u为uid, item为movie id
--]]
function BuildItemInverseTableByTrain(train)
	print("Build item_users inverse table by train dataset")
	local t1 = os.time()

	local re = {}

	for u,items in pairs(train) do
		for _, item in pairs(items) do
			if re[item] == nil then
				re[item] = {}
			end
			table.insert(re[item], u)
		end
	end

	local t2 = os.time()
	print("Build item_users inverse table by train dataset: " .. os.difftime(t2, t1) .. "s")

	return re
end
--[[
用户相似度计算
算法为余弦相似度公式
未考虑物品评分信息，只考虑用户对物品是否有过行为
--]]
function UserSimilarity_sin(train)
	print("UserSimilarity_sin begin ...")

	local t1 = os.time()

	local N = {} -- N[u]为用户u有过行为的物品数量
	local C = {} -- C[u][v]为用户[u,v]有过行为的物品数量

	for item, users in pairs(train) do
		for _,u in pairs(users) do
			N[u] = N[u] and N[u] + 1 or 1
			C[u] = C[u] or {}
			for _,v in pairs(users) do
				if u ~= v then
					C[u][v] = C[u][v] and C[u][v] + 1 or 1
				end
			end
		end
	end

	local W = {} -- W[u][v]为[u,v]相似度
	for u, related_users in pairs(C) do
		W[u] = {}
		for v, cuv in pairs(related_users) do
			W[u][v] = cuv / math.sqrt(N[u]*N[v])
			local log = string.format("%s %s %f", tostring(u), tostring(v), W[u][v])
			print(log)
		end
	end

	local t2 = os.time()
	print("UserSimilarity_sin time used: " .. os.difftime(t2, t1) .. "s")

	return W
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

--[[
[u,v]用户相似度
算法为Jaccard公式
未考虑评分信息，只考虑是否有过行为
--]]
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
--local WuvMtx = W_U_V_Jaccard(train)
--local Wuv_Str = Helper.serialize(WuvMtx)
local tTrain = BuildItemInverseTableByTrain(train)
local W = UserSimilarity_sin(tTrain)
local w_str = Helper.serialize(W)
SaveToFile(OUTPUT_FILE, w_str)