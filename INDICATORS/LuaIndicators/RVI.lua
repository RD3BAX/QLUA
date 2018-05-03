Settings = {
Name = "*RVI (Relative Vigor Index)", 
round = "off",
Period = 10,
line = {{
		Name = "RVI", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		},
		{
		Name = "RVI - Signal", 
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 0)
		}
		}
}

function Init() 
	func = RVI()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function RVI() --Relative Vigor I ("RVI")
	t_RVI = {}
	RangeAverage = {}
	MoveAverage = {}
return function (I, Fsettings, ds)
local Fsettings=(Fsettings or {})
local P = (Fsettings.Period or 10)
local R = (Fsettings.round or "off")
local RVI_Signal = nil
local function C_O(i)
	return  Value(i,"Close",ds) - Value(i,"Open",ds)
end
local function H_L(i)
	return  Value(i,"High",ds) - Value(i,"Low",ds)
end
if I > 3 then
	MoveAverage[I] = C_O(I) + 2 * C_O(I-1) + 2 * C_O(I-2) + C_O(I-3)
	RangeAverage[I] = H_L(I) + 2 * H_L(I-1) + 2 * H_L(I-2) + H_L(I-3)
end
if I > P + 2 then
	local sumMA = 0
	local sumRA = 0
	for i = I-P+1, I do
		sumMA = sumMA + MoveAverage[i]
		sumRA = sumRA + RangeAverage[i]
	end
	t_RVI[I] = sumMA / sumRA
end
if I >= P + 6 then
	RVI_Signal = (t_RVI[I] + 2* t_RVI[I-1] + 2* t_RVI[I-2] + t_RVI[I-3]) / 6
end
return rounding(t_RVI[I], R), rounding(RVI_Signal, R)
end
end

function rounding(num, round) 
if round and string.upper(round)== "ON" then round=0 end
if num and tonumber(round) then
	local mult = 10^round
	if num >= 0 then return math.floor(num * mult + 0.5) / mult
	else return math.ceil(num * mult - 0.5) / mult end
else return num end
end

function Value(I,VType,ds) 
local Out = nil
VType=(VType and string.upper(string.sub(VType,1,1))) or "A"
	if VType == "O" then		--Open
		Out = (O and O(I)) or (ds and ds:O(I))
	elseif VType == "H" then 	--High
		Out = (H and H(I)) or (ds and ds:H(I))
	elseif VType == "L" then	--Low
		Out = (L and L(I)) or (ds and ds:L(I))
	elseif VType == "C" then	--Close
		Out = (C and C(I)) or (ds and ds:C(I))
	elseif VType == "V" then	--Volume
		Out = (V and V(I)) or (ds and ds:V(I)) 
	elseif VType == "M" then	--Median
		Out = ((Value(I,"H",ds) + Value(I,"L",ds)) / 2)
	elseif VType == "T" then	--Typical
		Out = ((Value(I,"M",ds) * 2 + Value(I,"C",ds))/3)
	elseif VType == "W" then	--Weighted
		Out = ((Value(I,"T",ds) * 3 + Value(I,"O",ds))/4) 
	elseif VType == "D" then	--Difference
		Out = (Value(I,"H",ds) - Value(I,"L",ds))
	elseif VType == "A" then	--Any
		if ds then Out = ds[I] else Out = nil end
	end
return Out
end