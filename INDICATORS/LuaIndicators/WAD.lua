Settings = {
Name = "*WAD (Williams' A/D)", 
round = "off",
line = {{
		Name = "WAD",
		Type = TYPE_HISTOGRAM, 
		Color = RGB(255, 0, 0)
		},
		{
		Name = "line 0",
		Type = TYPE_LINE, 
		Color = RGB(0, 255, 0)
		}
		}
}

function Init() 
	func = WAD()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function WAD() --Williams' A/D ("WAD")
	local CumWAD={}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local R = (Fsettings.round or "off")
local WADn = 0
if I==1 then
	CumWAD[I]=0
end
if I>1 then
	local Price = Value(I,"Close",ds)
	local PrevPrice = Value(I-1,"Close",ds)
	TH = math.max(PrevPrice, Value(I,"High",ds))
	TL = math.min(PrevPrice, Value(I,"Low",ds))
	if Price > PrevPrice then
		WADn = Price - TL
	elseif Price < PrevPrice then
		WADn = Price - TH
	elseif Price == PrevPrice then
		WADn = 0
	end
	CumWAD[I]=CumWAD[I-1] + WADn
	Out=CumWAD[I]
	return rounding(Out, R),0
end
return nil,0
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