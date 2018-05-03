Settings = {
Name = "*FRACTALS (Fractals)", 
Period = 5,
line = {{
		Name = "FRACTALS - Down", 
		Type = TYPE_TRIANGLE_DOWN, 
		Color = RGB(255, 0, 0)
		},
		{
		Name = "FRACTALS - Up", 
		Type = TYPE_TRIANGLE_UP, 
		Color = RGB(0, 255, 0)
		}
		}
}
			
function Init() 
	func = FRACTALS()
	return #Settings.line
end

function OnCalculate(Index) 
	return func(Index, Settings)
end

function FRACTALS() --Fractals ("FRACTALS")
	local H_tmp={}
	local L_tmp={}
return function (I, Fsettings, ds)
local Fsettings=(Fsettings or {})
local P = (Fsettings.Period or 5)
P = math.floor(P/2)*2+1
H_tmp[I]=Value(I,"High",ds)
L_tmp[I]=Value(I,"Low",ds)
if I>=P then
	local S = I-P+1+math.floor(P/2)
	local val_h=math.max(unpack(H_tmp,I-P+1,I)) 
	local val_l=math.min(unpack(L_tmp,I-P+1,I))
	local L = Value(S,"Low",ds)
	local H = Value(S,"High",ds)
	if (val_h == H) and (val_h >0) 
		and (val_l == L) and (val_l > 0) then
			if ds then return S,S else
				SetValue(S, 1, val_l)
				SetValue(S, 2, val_h)
			end
	else
		if (val_h == H) and (val_h >0) then
			if ds then return S,nil else
				SetValue(S, 1, nil)
				SetValue(S, 2, val_h)
			end
		end
		if (val_l == L) and (val_l > 0) then
			if ds then return nil,S else
				SetValue(S, 1, val_l)
				SetValue(S, 2, nil)
			end
		end
	end
	
end
	return nil,nil
end
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
		if ds then Out = ds[I] end
	end
return Out
end