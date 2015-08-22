-- pca算法

-- 1. load data from local file
-- local debug = require('./debug');
local PCA_DATA_FILE = "./alg_pca_data.txt";
local COLS = 4;
function loadData(filename)
	local handle = io.open(filename, "r");
	local re = {};
	for line in handle:lines() do
		local data = {};
		for item in string.gmatch(line, "(%d+%.%d+)") do
			table.insert(data, item);
		end
		table.insert(re, data);
	end
	handle:close();
	return re;
end

function matrixAvg(matrix)
	local cols = matrix.cols;
	local avgs = {};
	local numbers = {};
	-- 初始化均值集合
	for i = 1,cols do
		table.insert(avgs,0);
		table.insert(numbers, 0);
	end
	for k,v in ipairs(matrix.data) do
		--debug.dump(v);
		if #v==cols then -- 如果没有这个判断，结果不对。原因待查
			for i = 1, cols do
				avgs[i] = avgs[i] + v[i];
				numbers[i] = numbers[i] + 1;
			end
		end
	end
	for i =1,cols do
		avgs[i] = avgs[i] / numbers[i];
		print(avgs[i]);
	end
	return avgs;
end

function matrixSubAvg(matrix, avgs)
	local data = matrix.data;
	local cols = matrix.cols;
	for k,v in ipairs(data) do
		if #v == cols then
			for i = 1, cols do
				v[i] = v[i] - avgs[i];
			end
		end
	end
end
--[[
维度X与Y的协方差计算
--]]
function covXY(X, Y)
	local xLen = #X;
	local yLen = #Y;
	if xLen ~= yLen then
		return false;
	end
	local sum = 0;
	while xLen>0 do
		sum = sum + X[xLen]*Y[xLen];
		xLen = xLen - 1;
	end
	return sum/(yLen - 1);
end

local matrixA = {cols=COLS};
matrixA.data = loadData(PCA_DATA_FILE);
local avgs = matrixAvg(matrixA);

matrixSubAvg(matrixA, avgs);

for i,v in ipairs(matrixA.data) do
	local log = "";
	for j,k in ipairs(v) do
		log = log .. string.format("%.4f\t", k);
	end
	print(log);
end

local matrixXY = {};
for i=1,COLS do
	matrixXY[i] = {};
end
for i,v in ipairs(matrixA.data) do
	if #v == COLS then
		local log = string.format("%f,%f,%f,%f", v[1], v[2], v[3], v[4]);
		print(log);
		table.insert(matrixXY[1], v[1]);
		table.insert(matrixXY[2], v[2]);
		table.insert(matrixXY[3], v[3]);
		table.insert(matrixXY[4], v[4]);
	end
end

local matrixCOV = {};
for i,x in ipairs(matrixXY) do
	for j,y in ipairs(matrixXY) do
		local cxy = covXY(x,y);
		table.insert(matrixCOV, cxy);
	end
end

print("cov_x_y result: ");

local covLen = #matrixCOV;
for i=1,covLen,4 do
	local log = string.format("%.4f,%.4f,%.4f,%.4f", matrixCOV[i],matrixCOV[i+1],matrixCOV[i+2],matrixCOV[i+3]);
	print(log);
end
-- 2. 去中心化
-- 3. 