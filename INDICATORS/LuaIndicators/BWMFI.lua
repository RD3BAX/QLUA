Settings = {
Name = "*BWMFI (Bill Williams Market Facilitation Index)", 
round = "off",
line = {{
		Name = "BWMFI_Green", 
		Type = TYPE_HISTOGRAM, 
		Color = RGB(0, 255, 0),
		Width = 2
		},
		{
		Name = "BWMFI_Fade", 
		Type = TYPE_HISTOGRAM, 
		Color = RGB(128, 64, 0),
		Width = 2
		},
		{
		Name = "BWMFI_Fake", 
		Type = TYPE_HISTOGRAM, 
		Color = RGB(0, 255, 255),
		Width = 2
		},
		{
		Name = "BWMFI_Squat", 
		Type = TYPE_HISTOGRAM, 
		Color = RGB(255, 0, 255),
		Width = 2
		}
		}
}
bMfiUp = true
bVolUp = true

function Init() 
	func = BWMFI()
	return #Settings.line
end

function OnCalculate(Index)
if Index>1 then
	local prev=func(Index-1, Settings)
	local current=func(Index, Settings)

	if current > prev then bMfiUp=true end
	if current < prev then bMfiUp=false end
	if V(Index) > V(Index-1) then bVolUp=true end
	if V(Index) < V(Index-1) then bVolUp=false end

	if bMfiUp and bVolUp then
		return current,nil,nil,nil 
	elseif not bMfiUp and not bVolUp then
		return nil,current,nil,nil
	elseif bMfiUp and not bVolUp then
		return nil,nil,current,nil
	elseif not bMfiUp and bVolUp then
		return nil,nil,nil,current
	end

else
	return func(Index, Settings),nil,nil,nil
end
end


function BWMFI() --Bill Williams Market Facilitation I ("BWMFI")
return function (I, Fsettings, ds)
local Out = nil
local Fsettings=(Fsettings or {})
local R = (Fsettings.round or "off")
Out = (Value(I, "High", ds)-Value(I, "Low", ds)) / Value(I, "Volume", ds)
return rounding(Out, R)
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