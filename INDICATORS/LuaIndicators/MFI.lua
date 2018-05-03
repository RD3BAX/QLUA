Settings = {
Name = "*MFI (Money FLow Index)", 
round = "off",
Period = 3, 
line = {{
		Name = "MFI", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		},
		{
		Name = "line 80",
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 0)
		},
		{
		Name = "line 20",
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 0)
		}
		}
}

function Init() 
	func = MFI()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function MFI() --Money FLow Index ("MFI")
	local Fp = {}
	local Fn = {}
	local TP = {}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local P = (Fsettings.Period or 3)
local R = (Fsettings.round or "off")
	TP[I] = Value(I, "Typical", ds)
	local MF = TP[I] * Value(I, "Volume", ds)
if I>1 then
	Fn[I] = 0
	Fp[I] = 0
	if TP[I] > TP[I-1] then
		Fp[I] = MF
	elseif TP[I] < TP[I-1] then
		Fn[I] = MF
	end
end
if I>P then
	local sumFp = 0
	local sumFn = 0
	for i = I-P+1, I do
		sumFp = sumFp + Fp[i]
		sumFn = sumFn + Fn[i]
	end
	local Ratio = sumFp / sumFn
	Out = 100 - 100 / (1 + Ratio)
end
	return rounding(Out, R),80,20
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