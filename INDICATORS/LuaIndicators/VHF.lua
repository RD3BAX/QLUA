Settings = {
Name = "*VHF (Vertical Horizontal Filter)", 
round = "off",
Period = 28, 
VType = "Close", --Open, High, Low, Close, Volume, Median, Typical, Weighted, Difference
line = {{
		Name = "VHF", 
		Type = TYPE_LINE, 
		Color = RGB(255, 0, 0)
		}
		}
}
	
function Init() 
	func = VHF()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function VHF() --Vertical Horizontal Filter ("VHF")
	local VHF_tmp={}
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local R = (Fsettings.round or "off")
local P = (Fsettings.Period or 28)
local VT = (Fsettings.VType or "Close")
VHF_tmp[I]=Value(I,VT,ds)
if I>P then
	local sum=0
	for i = I-P+1, I do
		sum=sum+math.abs(Value(i,VT,ds)-Value(i-1,VT,ds))
	end
	Out=(math.max(unpack(VHF_tmp,I-P+1,I))-math.min(unpack(VHF_tmp,I-P+1,I))) / sum
	return rounding(Out, R)
end
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