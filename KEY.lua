local Library = {}
local U, Tw = game:GetService("UserInputService"), game:GetService("TweenService")
local KeyGUI = pcall(function() return makefolder and readfile and writefile and setclipboard end)

function Library.Load(o)
	local function init(getFrame)
		if not getFrame then return {nil, nil} end
		
		local MTREL = "Glass"
		local binds = {}
		local root = Instance.new('Folder', workspace.CurrentCamera)
		root.Name = 'BlurSnox'

		local gTokenMH = 99999999
		local gToken = math.random(1, gTokenMH)

		local DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
		DepthOfField.FarIntensity = 0
		DepthOfField.FocusDistance = 51.6
		DepthOfField.InFocusRadius = 50
		DepthOfField.NearIntensity = 1
		DepthOfField.Name = "DPT_"..gToken

		local frame = Instance.new('Frame')
		frame.Parent = getFrame
		frame.Size = UDim2.new(0.95, 0, 0.95, 0)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1

		local GenUid
		do
			local id = 0
			function GenUid()
				id = id + 1
				return 'neon::'..tostring(id)
			end
		end

		do
			local function IsNotNaN(x)
				return x == x
			end
			local continue = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0,0).Origin.x)
			while not continue do
				game:GetService('RunService').RenderStepped:Wait()
				continue = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0,0).Origin.x)
			end
		end

		local DrawQuad
		do
			local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
			local sz = 0.2

			local function DrawTriangle(v1, v2, v3, p0, p1)
				local s1 = (v1 - v2).magnitude
				local s2 = (v2 - v3).magnitude
				local s3 = (v3 - v1).magnitude
				local smax = max(s1, s2, s3)
				local A, B, C
				if s1 == smax then
					A, B, C = v1, v2, v3
				elseif s2 == smax then
					A, B, C = v2, v3, v1
				elseif s3 == smax then
					A, B, C = v3, v1, v2
				end

				local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
				local perp = sqrt((C-A).magnitude^2 - para*para)
				local dif_para = (A - B).magnitude - para

				local st = CFrame.new(B, A)
				local za = CFrame.Angles(pi/2,0,0)

				local cf0 = st
				local Top_Look = (cf0 * za).lookVector
				local Mid_Point = A + CFrame.new(A, B).lookVector * para
				local Needed_Look = CFrame.new(Mid_Point, C).lookVector
				local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z
				local ac = CFrame.Angles(0, 0, acos(dot))

				cf0 = cf0 * ac
				if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
				end
				cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

				local cf1 = st * ac * CFrame.Angles(0, pi, 0)
				if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
				end
				cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

				if not p0 then
					p0 = Instance.new('Part')
					p0.FormFactor = 'Custom'
					p0.TopSurface = 0
					p0.BottomSurface = 0
					p0.Anchored = true
					p0.CanCollide = false
					p0.CastShadow = false
					p0.Material = MTREL
					p0.Size = Vector3.new(sz, sz, sz)
					local mesh = Instance.new('SpecialMesh', p0)
					mesh.MeshType = 2
					mesh.Name = 'WedgeMesh'
				end
				p0.WedgeMesh.Scale = Vector3.new(0, perp/sz, para/sz)
				p0.CFrame = cf0

				if not p1 then
					p1 = p0:Clone()
				end
				p1.WedgeMesh.Scale = Vector3.new(0, perp/sz, dif_para/sz)
				p1.CFrame = cf1

				return p0, p1
			end

			function DrawQuad(v1, v2, v3, v4, parts)
				parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
				parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
			end
		end

		if binds[frame] then
			return binds[frame].parts
		end

		local uid = GenUid()
		local parts = {}
		local f = Instance.new('Folder', root)
		f.Name = frame.Name

		local parents = {}
		do
			local function add(child)
				if child:IsA('GuiObject') then
					parents[#parents + 1] = child
					add(child.Parent)
				end
			end
			add(frame)
		end

		local function UpdateOrientation(fetchProps)
			local properties = {
				Transparency = 0.98;
				BrickColor = BrickColor.new('Institutional white');
			}
			local zIndex = 1 - 0.05*frame.ZIndex

			local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
			do
				local rot = 0;
				for _, v in ipairs(parents) do
					rot = rot + v.Rotation
				end
				if rot ~= 0 and rot%180 ~= 0 then
					local mid = tl:lerp(br, 0.5)
					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
					local vec = tl
					tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
					tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
					bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
					br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
				end
			end
			DrawQuad(
				workspace.CurrentCamera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
				workspace.CurrentCamera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
				parts
			)
			if fetchProps then
				for _, pt in pairs(parts) do
					pt.Parent = f
				end
				for propName, propValue in pairs(properties) do
					for _, pt in pairs(parts) do
						pt[propName] = propValue
					end
				end
			end
		end

		UpdateOrientation(true)
		game:GetService('RunService'):BindToRenderStep(uid, 2000, UpdateOrientation)
		return {
			DepthOfField,
			frame
		}
	end
	
	local function gl(i)
		if not i then
			return {
				Image = "",
				ImageRectSize = Vector2.new(0, 0),
				ImageRectOffset = Vector2.new(0, 0),
			}
		elseif type(i) == 'number' then
			return {
				Image = "rbxassetid://".. tostring(i),
				ImageRectSize = Vector2.new(0, 0),
				ImageRectOffset = Vector2.new(0, 0),
			}
		elseif type(i) == 'string' and not i:find('rbxassetid://') then
			return {
				Image = "rbxassetid://".. i,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectOffset = Vector2.new(0, 0),
			}
		else
			return {
				Image = i,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectOffset = Vector2.new(0, 0),
			}
		end
	end
	
	local function tw(info)
		if not info then 
			return { Play = function() end } 
		end
		if not info.v or not info.v:IsA("Instance") then 
			return { Play = function() end } 
		end
		
		local direction = Enum.EasingDirection.Out
		if type(info.d) == "string" then
			if Enum.EasingDirection[info.d] then
				direction = Enum.EasingDirection[info.d]
			end
		elseif info.d then
			direction = info.d
		end
		
		local style = info.s or Enum.EasingStyle.Quad
		local time = info.t or 0.3
		
		local success, tween = pcall(function()
			return Tw:Create(
				info.v,
				TweenInfo.new(time, style, direction),
				info.g or {}
			)
		end)
		
		if success and tween then
			return tween
		else
			return { Play = function() end }
		end
	end
	
	local function lak(t, o)
		if not t or not o then return end
		
		local a, b, c, d
		local function u(i)
			if not i or not d then return end
			local dt = i.Position - c
			tw({v = o, t = 0.05, s = Enum.EasingStyle.Linear, d = "InOut", g = {Position = UDim2.new(d.X.Scale, d.X.Offset + dt.X, d.Y.Scale, d.Y.Offset + dt.Y)}}):Play()
		end
		t.InputBegan:Connect(function(i) 
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
				a = true 
				c = i.Position 
				d = o.Position
				i.Changed:Connect(function() 
					if i.UserInputState == Enum.UserInputState.End then 
						a = false 
					end 
				end) 
			end 
		end)
		t.InputChanged:Connect(function(i) 
			if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then 
				b = i 
			end 
		end)
		U.InputChanged:Connect(function(i) 
			if i == b and a then 
				u(i) 
			end 
		end)
	end
	
	local function click(p)
		if not p then return end
		
		local Click = Instance.new("TextButton")
		Click.Name = "Click"
		Click.Parent = p
		Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Click.BackgroundTransparency = 1.000
		Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Click.BorderSizePixel = 0
		Click.Size = UDim2.new(1, 0, 1, 0)
		Click.Font = Enum.Font.SourceSans
		Click.Text = ""
		Click.TextColor3 = Color3.fromRGB(0, 0, 0)
		Click.TextSize = 14.000
		return Click
	end

	local HubName = o.Name or 'SindexHub'
	local Color = o.Color or Color3.fromRGB(138, 43, 226)
	local Icon = o.Icon or 14930953469
	local Key = o.Key or {}

	if KeyGUI then 
		pcall(function()
			makefolder("SindexHub")
		end)
	end
	local savedKey = ""
	if KeyGUI then
		local success, key = pcall(readfile, "SindexHub/key.txt")
		if success then
			savedKey = key or ""
		end
	end

	local ScreenGui = Instance.new("ScreenGui")
	local Background_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local UIGradient_1 = Instance.new("UIGradient")
	local UIPadding_1 = Instance.new("UIPadding")
	local Left_1 = Instance.new("CanvasGroup")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local TItleIcon_1 = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local ImageLabel_1 = Instance.new("ImageLabel")
	local TextLabel_1 = Instance.new("TextLabel")
	local adsframe_1 = Instance.new("Frame")
	local ads_1 = Instance.new("TextLabel")
	local KeyFrame_1 = Instance.new("Frame")
	local UIListLayout_3 = Instance.new("UIListLayout")
	local TextLabel_2 = Instance.new("TextLabel")
	local Frame_1 = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local ImageLabel_2 = Instance.new("ImageLabel")
	local Keybox_1 = Instance.new("Frame")
	local UICorner_3 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local UIPadding_2 = Instance.new("UIPadding")
	local TextBox_1 = Instance.new("TextBox")
	local RedeemFrame_1 = Instance.new("Frame")
	local UIListLayout_4 = Instance.new("UIListLayout")
	local Button_1 = Instance.new("Frame")
	local UICorner_4 = Instance.new("UICorner")
	local Shadow_1 = Instance.new("ImageLabel")
	local Text_1 = Instance.new("Frame")
	local UIListLayout_5 = Instance.new("UIListLayout")
	local TextLabel_3 = Instance.new("TextLabel")
	local ImageLabel_3 = Instance.new("ImageLabel")
	local Click_1 = Instance.new("TextButton")
	local TextLabel_4 = Instance.new("TextLabel")
	local Line_1 = Instance.new("Frame")
	local TabList_1 = Instance.new("Frame")
	local UIListLayout_7 = Instance.new("UIListLayout")

	ScreenGui.Parent = (not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Name = "SindexKeySystem"

	Background_1.Name = "Background"
	Background_1.Parent = ScreenGui
	Background_1.AutomaticSize = Enum.AutomaticSize.Y
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = UDim2.new(0.4, 0,0, 0)
	Background_1.ClipsDescendants = true
	Background_1.BackgroundTransparency = 1
	
	lak(Background_1, Background_1)

	init(Background_1)

	UICorner_1.Parent = Background_1
	UICorner_1.CornerRadius = UDim.new(0,15)

	UIGradient_1.Parent = Background_1
	UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 15, 50)), ColorSequenceKeypoint.new(0.5, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 50))}
	UIGradient_1.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.5,0.04375), NumberSequenceKeypoint.new(1,0)}
	UIGradient_1.Rotation = 45

	local UIStroke_3 = Instance.new("UIStroke")
	UIStroke_3.Parent = Background_1
	UIStroke_3.Color = Color
	UIStroke_3.Thickness = 1
	UIStroke_3.Transparency = 0.7

	local Shadow_BG = Instance.new("ImageLabel")
	Shadow_BG.Name = "Shadow_BG"
	Shadow_BG.Parent = ScreenGui
	Shadow_BG.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_BG.BackgroundTransparency = 1
	Shadow_BG.Position = Background_1.Position
	Shadow_BG.Size = UDim2.new(1.1, 0,1.1, 0)
	Shadow_BG.Image = "rbxassetid://1316045217"
	Shadow_BG.ImageColor3 = Color3.fromRGB(0,0,0)
	Shadow_BG.ImageTransparency = 0.7
	Shadow_BG.ScaleType = Enum.ScaleType.Slice
	Shadow_BG.SliceCenter = Rect.new(10, 10, 118, 118)
	Shadow_BG.ZIndex = 0

	UIPadding_1.Parent = Background_1
	UIPadding_1.PaddingBottom = UDim.new(0,10)
	UIPadding_1.PaddingLeft = UDim.new(0,10)
	UIPadding_1.PaddingRight = UDim.new(0,10)
	UIPadding_1.PaddingTop = UDim.new(0,10)

	Left_1.Name = "Left"
	Left_1.Parent = Background_1
	Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Left_1.BackgroundTransparency = 1
	Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Left_1.BorderSizePixel = 0
	Left_1.Size = UDim2.new(1, 0,1, 0)
	Left_1.GroupTransparency = 1
	Left_1.ClipsDescendants = false

	UIListLayout_1.Parent = Left_1
	UIListLayout_1.Padding = UDim.new(0,8)
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

	TItleIcon_1.Name = "TItleIcon"
	TItleIcon_1.Parent = Left_1
	TItleIcon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TItleIcon_1.BackgroundTransparency = 1
	TItleIcon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TItleIcon_1.BorderSizePixel = 0
	TItleIcon_1.Size = UDim2.new(0, 100,0, 20)

	UIListLayout_2.Parent = TItleIcon_1
	UIListLayout_2.Padding = UDim.new(0,8)
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	ImageLabel_1.Parent = TItleIcon_1
	ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_1.BackgroundTransparency = 1
	ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_1.BorderSizePixel = 0
	ImageLabel_1.Size = UDim2.new(0, 17,0, 17)
	ImageLabel_1.Image = gl(Icon).Image
	ImageLabel_1.ImageTransparency = 1

	local UIGradient_Icon = Instance.new("UIGradient")
	UIGradient_Icon.Parent = ImageLabel_1
	UIGradient_Icon.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}
	UIGradient_Icon.Transparency = NumberSequence.new(1)
	UIGradient_Icon.Rotation = 90

	TextLabel_1.Parent = TItleIcon_1
	TextLabel_1.AutomaticSize = Enum.AutomaticSize.X
	TextLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_1.BackgroundTransparency = 1
	TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_1.BorderSizePixel = 0
	TextLabel_1.Size = UDim2.new(0, 0,0, 20)
	TextLabel_1.Font = Enum.Font.Gotham
	TextLabel_1.Text = "Sindex KEY SYSTEM"
	TextLabel_1.TextColor3 = Color
	TextLabel_1.TextSize = 11
	TextLabel_1.TextTransparency = 1
	TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left

	adsframe_1.Name = "adsframe"
	adsframe_1.Parent = Left_1
	adsframe_1.AutomaticSize = Enum.AutomaticSize.Y
	adsframe_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	adsframe_1.BackgroundTransparency = 1
	adsframe_1.BorderColor3 = Color3.fromRGB(0,0,0)
	adsframe_1.BorderSizePixel = 0
	adsframe_1.LayoutOrder = 1
	adsframe_1.Size = UDim2.new(1, 0,0, 0)

	ads_1.Name = "ads"
	ads_1.Parent = adsframe_1
	ads_1.AutomaticSize = Enum.AutomaticSize.Y
	ads_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ads_1.BackgroundTransparency = 1
	ads_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ads_1.BorderSizePixel = 0
	ads_1.Size = UDim2.new(1, 0,1, 0)
	ads_1.Font = Enum.Font.GothamBold
	ads_1.RichText = true
	ads_1.Text = "WELCOME TO ,\n<font color='"..string.format("rgb(%d, %d, %d)", Color.r * 255, Color.g * 255, Color.b * 255).."'>"..HubName.." Key System</font>"
	ads_1.TextColor3 = Color3.fromRGB(255,255,255)
	ads_1.TextSize = 22
	ads_1.TextTransparency = 1
	ads_1.TextWrapped = true
	ads_1.TextXAlignment = Enum.TextXAlignment.Left

	KeyFrame_1.Name = "KeyFrame"
	KeyFrame_1.Parent = Left_1
	KeyFrame_1.AutomaticSize = Enum.AutomaticSize.Y
	KeyFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	KeyFrame_1.BackgroundTransparency = 1
	KeyFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	KeyFrame_1.BorderSizePixel = 0
	KeyFrame_1.LayoutOrder = 2
	KeyFrame_1.Size = UDim2.new(1, 0,0, 0)

	UIListLayout_3.Parent = KeyFrame_1
	UIListLayout_3.Padding = UDim.new(0,5)
	UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

	TextLabel_2.Parent = KeyFrame_1
	TextLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_2.BackgroundTransparency = 1
	TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_2.BorderSizePixel = 0
	TextLabel_2.Size = UDim2.new(1, 0,0, 20)
	TextLabel_2.Font = Enum.Font.Gotham
	TextLabel_2.Text = "License Key"
	TextLabel_2.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel_2.TextSize = 12
	TextLabel_2.TextTransparency = 1
	TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

	Frame_1.Parent = TextLabel_2
	Frame_1.AnchorPoint = Vector2.new(1, 0.5)
	Frame_1.BackgroundColor3 = Color
	Frame_1.BackgroundTransparency = 1
	Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Frame_1.BorderSizePixel = 0
	Frame_1.Position = UDim2.new(1, 0,0.5, 0)
	Frame_1.Size = UDim2.new(0, 18,0, 18)

	UICorner_2.Parent = Frame_1
	UICorner_2.CornerRadius = UDim.new(1,0)

	local UIStroke_Eye = Instance.new("UIStroke")
	UIStroke_Eye.Parent = Frame_1
	UIStroke_Eye.Color = Color
	UIStroke_Eye.Thickness = 1
	UIStroke_Eye.Transparency = 1

	ImageLabel_2.Parent = Frame_1
	ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_2.BackgroundTransparency = 1
	ImageLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_2.BorderSizePixel = 0
	ImageLabel_2.Position = UDim2.new(0.5, 0,0.5, 0)
	ImageLabel_2.Size = UDim2.new(0, 12,0, 12)
	ImageLabel_2.Image = "rbxassetid://13868333926"
	ImageLabel_2.ImageTransparency = 1
	
	local HideShowKey = click(Frame_1)

	Keybox_1.Name = "Keybox"
	Keybox_1.Parent = KeyFrame_1
	Keybox_1.BackgroundColor3 = Color
	Keybox_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Keybox_1.BorderSizePixel = 0
	Keybox_1.LayoutOrder = 1
	Keybox_1.Size = UDim2.new(1, 0,0, 30)
	Keybox_1.Transparency = 1

	UICorner_3.Parent = Keybox_1
	UICorner_3.CornerRadius = UDim.new(0,4)

	UIStroke_1.Parent = Keybox_1
	UIStroke_1.Color = Color
	UIStroke_1.Thickness = 1.2
	UIStroke_1.Transparency = 1

	local UIGradient_Keybox = Instance.new("UIGradient")
	UIGradient_Keybox.Parent = Keybox_1
	UIGradient_Keybox.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}
	UIGradient_Keybox.Transparency = NumberSequence.new(1)
	UIGradient_Keybox.Rotation = 90

	local Shadow_Keybox = Instance.new("ImageLabel")
	Shadow_Keybox.Name = "Shadow_Keybox"
	Shadow_Keybox.Parent = Keybox_1
	Shadow_Keybox.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_Keybox.BackgroundTransparency = 1
	Shadow_Keybox.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_Keybox.Size = UDim2.new(1.05, 0,1.05, 0)
	Shadow_Keybox.Image = "rbxassetid://1316045217"
	Shadow_Keybox.ImageColor3 = Color
	Shadow_Keybox.ImageTransparency = 1
	Shadow_Keybox.ScaleType = Enum.ScaleType.Slice
	Shadow_Keybox.SliceCenter = Rect.new(10, 10, 118, 118)
	Shadow_Keybox.ZIndex = 0

	UIPadding_2.Parent = Keybox_1
	UIPadding_2.PaddingLeft = UDim.new(0,10)
	UIPadding_2.PaddingRight = UDim.new(0,10)

	TextBox_1.Parent = Keybox_1
	TextBox_1.Active = true
	TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextBox_1.BackgroundTransparency = 1
	TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TextBox_1.BorderSizePixel = 0
	TextBox_1.CursorPosition = -1
	TextBox_1.Size = UDim2.new(1, 0,1, 0)
	TextBox_1.Font = Enum.Font.Gotham
	TextBox_1.PlaceholderColor3 = Color3.fromRGB(134,134,134)
	TextBox_1.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
	TextBox_1.Text = ""
	TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
	TextBox_1.TextSize = 12
	TextBox_1.TextTransparency = 1
	TextBox_1.TextXAlignment = Enum.TextXAlignment.Left
	TextBox_1.ClearTextOnFocus = false

	RedeemFrame_1.Name = "RedeemFrame"
	RedeemFrame_1.Parent = Left_1
	RedeemFrame_1.AutomaticSize = Enum.AutomaticSize.Y
	RedeemFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	RedeemFrame_1.BackgroundTransparency = 1
	RedeemFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	RedeemFrame_1.BorderSizePixel = 0
	RedeemFrame_1.LayoutOrder = 3
	RedeemFrame_1.Size = UDim2.new(1, 0,0, 0)

	UIListLayout_4.Parent = RedeemFrame_1
	UIListLayout_4.Padding = UDim.new(0,10)
	UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder

	Button_1.Name = "Button"
	Button_1.Parent = RedeemFrame_1
	Button_1.BackgroundColor3 = Color
	Button_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Button_1.BorderSizePixel = 0
	Button_1.Size = UDim2.new(1, 0,0, 30)
	Button_1.BackgroundTransparency = 1

	UICorner_4.Parent = Button_1
	UICorner_4.CornerRadius = UDim.new(0,6)

	local UIGradient_Button = Instance.new("UIGradient")
	UIGradient_Button.Parent = Button_1
	UIGradient_Button.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}
	UIGradient_Button.Transparency = NumberSequence.new(1)
	UIGradient_Button.Rotation = 90

	Shadow_1.Name = "Shadow"
	Shadow_1.Parent = Button_1
	Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_1.BackgroundColor3 = Color3.fromRGB(163,162,165)
	Shadow_1.BackgroundTransparency = 1
	Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_1.Size = UDim2.new(1.05, 0,1.5, 0)
	Shadow_1.Image = "rbxassetid://1316045217"
	Shadow_1.ImageColor3 = Color
	Shadow_1.ImageTransparency = 1
	Shadow_1.ScaleType = Enum.ScaleType.Slice
	Shadow_1.SliceCenter = Rect.new(10, 10, 118, 118)

	Text_1.Name = "Text"
	Text_1.Parent = Button_1
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_5.Parent = Text_1
	UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center

	TextLabel_3.Parent = Text_1
	TextLabel_3.AutomaticSize = Enum.AutomaticSize.X
	TextLabel_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_3.BackgroundTransparency = 1
	TextLabel_3.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_3.BorderSizePixel = 0
	TextLabel_3.Size = UDim2.new(0, 0,1, 0)
	TextLabel_3.Font = Enum.Font.GothamBold
	TextLabel_3.Text = "Redeem"
	TextLabel_3.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel_3.TextSize = 12
	TextLabel_3.TextTransparency = 1

	ImageLabel_3.Parent = Text_1
	ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_3.BackgroundTransparency = 1
	ImageLabel_3.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_3.BorderSizePixel = 0
	ImageLabel_3.LayoutOrder = 2
	ImageLabel_3.Size = UDim2.new(0, 20,0, 20)
	ImageLabel_3.Image = "rbxassetid://14938884688"
	ImageLabel_3.ImageTransparency = 1

	Click_1.Name = "Click"
	Click_1.Parent = Button_1
	Click_1.Active = true
	Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Click_1.BackgroundTransparency = 1
	Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Click_1.BorderSizePixel = 0
	Click_1.Size = UDim2.new(1, 0,1, 0)
	Click_1.Font = Enum.Font.SourceSans
	Click_1.Text = ""
	Click_1.TextSize = 14

	local HoverButton1 = Instance.new("Frame")
	HoverButton1.Name = "HoverButton"
	HoverButton1.Parent = Button_1
	HoverButton1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	HoverButton1.BackgroundTransparency = 0.9
	HoverButton1.BorderSizePixel = 0
	HoverButton1.Size = UDim2.new(1,0,1,0)
	HoverButton1.Visible = false

	if Button_1 then
		Button_1.MouseEnter:Connect(function()
			HoverButton1.Visible = true
			tw({v = HoverButton1, t = 0.15, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.7}}):Play()
		end)

		Button_1.MouseLeave:Connect(function()
			tw({v = HoverButton1, t = 0.15, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.9}}):Play()
			task.delay(0.15, function() HoverButton1.Visible = false end)
		end)
	end

	local Button_2 = Instance.new("Frame")
	Button_2.Name = "Button"
	Button_2.Parent = RedeemFrame_1
	Button_2.BackgroundColor3 = Color
	Button_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Button_2.BorderSizePixel = 0
	Button_2.Size = UDim2.new(1, 0,0, 30)
	Button_2.BackgroundTransparency = 1
	Button_2.LayoutOrder = 1
	local UICorner_5 = Instance.new("UICorner")
	UICorner_5.Parent = Button_2
	UICorner_5.CornerRadius = UDim.new(0,6)
	local UIGradient_Button2 = Instance.new("UIGradient")
	UIGradient_Button2.Parent = Button_2
	UIGradient_Button2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}
	UIGradient_Button2.Transparency = NumberSequence.new(1)
	UIGradient_Button2.Rotation = 90
	local Shadow_2 = Instance.new("ImageLabel")
	Shadow_2.Name = "Shadow"
	Shadow_2.Parent = Button_2
	Shadow_2.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_2.BackgroundColor3 = Color3.fromRGB(163,162,165)
	Shadow_2.BackgroundTransparency = 1
	Shadow_2.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_2.Size = UDim2.new(1.05, 0,1.5, 0)
	Shadow_2.Image = "rbxassetid://1316045217"
	Shadow_2.ImageColor3 = Color
	Shadow_2.ImageTransparency = 1
	Shadow_2.ScaleType = Enum.ScaleType.Slice
	Shadow_2.SliceCenter = Rect.new(10, 10, 118, 118)
	local Text_2 = Instance.new("Frame")
	Text_2.Name = "Text"
	Text_2.Parent = Button_2
	Text_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_2.BackgroundTransparency = 1
	Text_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_2.BorderSizePixel = 0
	Text_2.Size = UDim2.new(1, 0,1, 0)
	local UIListLayout_6 = Instance.new("UIListLayout")
	UIListLayout_6.Parent = Text_2
	UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_6.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center
	local TextLabel_6 = Instance.new("TextLabel")
	TextLabel_6.Parent = Text_2
	TextLabel_6.AutomaticSize = Enum.AutomaticSize.X
	TextLabel_6.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_6.BackgroundTransparency = 1
	TextLabel_6.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_6.BorderSizePixel = 0
	TextLabel_6.Size = UDim2.new(0, 0,1, 0)
	TextLabel_6.Font = Enum.Font.GothamBold
	TextLabel_6.Text = "Get Key"
	TextLabel_6.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel_6.TextSize = 12
	TextLabel_6.TextTransparency = 1
	local ImageLabel_4 = Instance.new("ImageLabel")
	ImageLabel_4.Parent = Text_2
	ImageLabel_4.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_4.BackgroundTransparency = 1
	ImageLabel_4.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_4.BorderSizePixel = 0
	ImageLabel_4.LayoutOrder = 2
	ImageLabel_4.Size = UDim2.new(0, 20,0, 20)
	ImageLabel_4.Image = "rbxassetid://14938884688"
	ImageLabel_4.ImageTransparency = 1
	local Click_2 = Instance.new("TextButton")
	Click_2.Name = "Click"
	Click_2.Parent = Button_2
	Click_2.Active = true
	Click_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Click_2.BackgroundTransparency = 1
	Click_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Click_2.BorderSizePixel = 0
	Click_2.Size = UDim2.new(1, 0,1, 0)
	Click_2.Font = Enum.Font.SourceSans
	Click_2.Text = ""
	Click_2.TextSize = 14

	local HoverButton2 = Instance.new("Frame")
	HoverButton2.Name = "HoverButton"
	HoverButton2.Parent = Button_2
	HoverButton2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	HoverButton2.BackgroundTransparency = 0.9
	HoverButton2.BorderSizePixel = 0
	HoverButton2.Size = UDim2.new(1,0,1,0)
	HoverButton2.Visible = false

	if Button_2 then
		Button_2.MouseEnter:Connect(function()
			HoverButton2.Visible = true
			tw({v = HoverButton2, t = 0.15, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.7}}):Play()
		end)

		Button_2.MouseLeave:Connect(function()
			tw({v = HoverButton2, t = 0.15, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.9}}):Play()
			task.delay(0.15, function() HoverButton2.Visible = false end)
		end)
	end

	TextLabel_4.Parent = RedeemFrame_1
	TextLabel_4.AutomaticSize = Enum.AutomaticSize.XY
	TextLabel_4.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TextLabel_4.BackgroundTransparency = 1
	TextLabel_4.BorderColor3 = Color3.fromRGB(0,0,0)
	TextLabel_4.BorderSizePixel = 0
	TextLabel_4.LayoutOrder = 2
	TextLabel_4.Size = UDim2.new(0, 0,0, 0)
	TextLabel_4.Font = Enum.Font.Gotham
	TextLabel_4.RichText = true
	TextLabel_4.Text = "Need support? <font color='"..string.format("rgb(%d, %d, %d)", Color.r * 255, Color.g * 255, Color.b * 255).."'>Join the Discord</font>"
	TextLabel_4.TextColor3 = Color3.fromRGB(255,255,255)
	TextLabel_4.TextSize = 12
	TextLabel_4.TextTransparency = 1
	
	local ClickJoinDis = click(TextLabel_4)

	Line_1.Name = "Line"
	Line_1.Parent = RedeemFrame_1
	Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Line_1.BackgroundTransparency = 1
	Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Line_1.BorderSizePixel = 0
	Line_1.LayoutOrder = 4
	Line_1.Size = UDim2.new(1, 0,0, 1)

	TabList_1.Name = "TabList"
	TabList_1.Parent = Left_1
	TabList_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabList_1.BackgroundTransparency = 1
	TabList_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabList_1.BorderSizePixel = 0
	TabList_1.LayoutOrder = 4
	TabList_1.Size = UDim2.new(1, 0,0, 20)

	UIListLayout_7.Parent = TabList_1
	UIListLayout_7.Padding = UDim.new(0,8)
	UIListLayout_7.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_7.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_7.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_7.VerticalAlignment = Enum.VerticalAlignment.Center

	UIListLayout_7:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if #TabList_1:GetChildren() > 1 then
			TabList_1.Visible = true
		else
			TabList_1.Visible = false
		end
	end)

	local NotifyContainer = Instance.new("Frame")
	NotifyContainer.Name = "NotifyContainer"
	NotifyContainer.Parent = ScreenGui
	NotifyContainer.AnchorPoint = Vector2.new(1, 0.5)
	NotifyContainer.BackgroundTransparency = 1
	NotifyContainer.Position = UDim2.new(1, -20, 0.5, 0)
	NotifyContainer.Size = UDim2.new(0, 300, 0, 500)
	
	local UIListLayout_NotifyContainer = Instance.new("UIListLayout")
	UIListLayout_NotifyContainer.Parent = NotifyContainer
	UIListLayout_NotifyContainer.Padding = UDim.new(0, 10)
	UIListLayout_NotifyContainer.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_NotifyContainer.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_NotifyContainer.VerticalAlignment = Enum.VerticalAlignment.Bottom

	task.spawn(function()
		Background_1.Position = UDim2.new(0.5, 0,0.5, -100)
		Background_1.BackgroundTransparency = 1
		Shadow_BG.ImageTransparency = 1
		
		tw({v = Background_1, t = 0.7, s = Enum.EasingStyle.Back, d = "Out", g = {Position = UDim2.new(0.5, 0,0.5, 0)}}):Play()
		tw({v = Background_1, t = 0.5, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.15}}):Play()
		tw({v = Shadow_BG, t = 0.5, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.7}}):Play()
		
		task.delay(0.1, function()
			tw({v = Left_1, t = 0.4, s = Enum.EasingStyle.Quad, d = "Out", g = {GroupTransparency = 0}}):Play()
			
			task.delay(0.1, function()
				tw({v = ImageLabel_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.8}}):Play()
				tw({v = UIGradient_Icon, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = NumberSequence.new(0.2)}}):Play()
				tw({v = TextLabel_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0.8}}):Play()
				
				task.delay(0.05, function()
					tw({v = ads_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0}}):Play()
					
					task.delay(0.05, function()
						tw({v = TextLabel_2, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0.2}}):Play()
						tw({v = Frame_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.56}}):Play()
						tw({v = UIStroke_Eye, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = 0.5}}):Play()
						tw({v = ImageLabel_2, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0}}):Play()
						
						task.delay(0.05, function()
							tw({v = Keybox_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = 0.76}}):Play()
							tw({v = UIStroke_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = 0.64}}):Play()
							tw({v = UIGradient_Keybox, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = NumberSequence.new(0.76)}}):Play()
							tw({v = Shadow_Keybox, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.8}}):Play()
							tw({v = TextBox_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0}}):Play()
							
							task.delay(0.05, function()
								tw({v = Button_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0}}):Play()
								tw({v = UIGradient_Button, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = NumberSequence.new(0.1)}}):Play()
								tw({v = Shadow_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.8}}):Play()
								tw({v = TextLabel_3, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0.1}}):Play()
								tw({v = ImageLabel_3, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.1}}):Play()
								
								task.delay(0.05, function()
									tw({v = Button_2, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0}}):Play()
									tw({v = UIGradient_Button2, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {Transparency = NumberSequence.new(0.1)}}):Play()
									tw({v = Shadow_2, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.8}}):Play()
									tw({v = TextLabel_6, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0.1}}):Play()
									tw({v = ImageLabel_4, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 0.1}}):Play()
									
									task.delay(0.05, function()
										tw({v = TextLabel_4, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {TextTransparency = 0.5}}):Play()
										tw({v = Line_1, t = 0.3, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 0.9}}):Play()
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)

	local tab = {}

	function tab.New(p)
		if not p then return end
		
		local Title = p.Title or 'null'
		local Icon = p.Icon or 14924054039
		local Callback = p.Callback or function() end
		local Tab_1 = Instance.new("Frame")
		local UICorner_Tab = Instance.new("UICorner")
		local UIGradient_Tab = Instance.new("UIGradient")
		local UIListLayout_Tab = Instance.new("UIListLayout")
		local UIPadding_Tab = Instance.new("UIPadding")
		local ImageLabel_Tab = Instance.new("ImageLabel")
		local TextLabel_Tab = Instance.new("TextLabel")
		local newf = Instance.new('Frame')

		newf.Parent = Tab_1
		newf.BackgroundTransparency = 1
		newf.Size = UDim2.new(1, 0, 1, 0)

		Tab_1.Name = "Tab"
		Tab_1.Parent = TabList_1
		Tab_1.AutomaticSize = Enum.AutomaticSize.X
		Tab_1.BackgroundColor3 = Color
		Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Tab_1.BorderSizePixel = 0
		Tab_1.Size = UDim2.new(0, 25,0, 25)

		UICorner_Tab.Parent = Tab_1
		UICorner_Tab.CornerRadius = UDim.new(1,0)

		UIGradient_Tab.Parent = Tab_1
		UIGradient_Tab.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 168, 168))}
		UIGradient_Tab.Rotation = 0

		UIListLayout_Tab.Parent = newf
		UIListLayout_Tab.Padding = UDim.new(0,6)
		UIListLayout_Tab.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_Tab.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_Tab.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_Tab.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_Tab.Parent = newf
		UIPadding_Tab.PaddingLeft = UDim.new(0,8)
		UIPadding_Tab.PaddingRight = UDim.new(0,8)

		ImageLabel_Tab.Parent = newf
		ImageLabel_Tab.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ImageLabel_Tab.BackgroundTransparency = 1
		ImageLabel_Tab.BorderColor3 = Color3.fromRGB(0,0,0)
		ImageLabel_Tab.BorderSizePixel = 0
		ImageLabel_Tab.Size = UDim2.new(0, 15,0, 15)
		ImageLabel_Tab.Image = gl(Icon).Image

		TextLabel_Tab.Parent = newf
		TextLabel_Tab.AutomaticSize = Enum.AutomaticSize.X
		TextLabel_Tab.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TextLabel_Tab.BackgroundTransparency = 1
		TextLabel_Tab.BorderColor3 = Color3.fromRGB(0,0,0)
		TextLabel_Tab.BorderSizePixel = 0
		TextLabel_Tab.LayoutOrder = 1
		TextLabel_Tab.Size = UDim2.new(0, 0,1, 0)
		TextLabel_Tab.Font = Enum.Font.Gotham
		TextLabel_Tab.Text = Title
		TextLabel_Tab.TextColor3 = Color3.fromRGB(255,255,255)
		TextLabel_Tab.TextSize = 13

		task.delay(0.1, function()
			TextLabel_Tab.TextXAlignment = Enum.TextXAlignment.Left
		end)

		local Click = click(Tab_1)
		if Click then
			Click.MouseButton1Click:Connect(Callback)
		end
	end

	function tab.Notify(p)
		if not p then return {Set = function() end} end
		
		local Title = p.Title or 'Notification'
		local Icon = p.Icon or 14924054039
		local ColorN = p.Color or Color3.fromRGB(50, 50, 50)
		local Time = p.Time or 5
		
		local NotifyFrame = Instance.new("Frame")
		local UICorner_Notify = Instance.new("UICorner")
		local UIStroke_Notify = Instance.new("UIStroke")
		local Shadow_Notify = Instance.new("ImageLabel")
		local Content = Instance.new("Frame")
		local UIListLayout_Content = Instance.new("UIListLayout")
		local IconFrame = Instance.new("Frame")
		local IconImage = Instance.new("ImageLabel")
		local TextFrame = Instance.new("Frame")
		local TextLabel_Notify = Instance.new("TextLabel")
		
		NotifyFrame.Name = "Notify"
		NotifyFrame.Parent = NotifyContainer
		NotifyFrame.BackgroundColor3 = ColorN
		NotifyFrame.BackgroundTransparency = 1
		NotifyFrame.Size = UDim2.new(1, 0, 0, 0)
		NotifyFrame.Position = UDim2.new(1, 0, 1, 0)
		NotifyFrame.ClipsDescendants = true
		
		UICorner_Notify.Parent = NotifyFrame
		UICorner_Notify.CornerRadius = UDim.new(0, 8)
		
		UIStroke_Notify.Parent = NotifyFrame
		UIStroke_Notify.Color = ColorN
		UIStroke_Notify.Thickness = 1
		UIStroke_Notify.Transparency = 1
		
		Shadow_Notify.Name = "Shadow"
		Shadow_Notify.Parent = NotifyFrame
		Shadow_Notify.AnchorPoint = Vector2.new(0.5, 0.5)
		Shadow_Notify.BackgroundTransparency = 1
		Shadow_Notify.Position = UDim2.new(0.5, 0, 0.5, 0)
		Shadow_Notify.Size = UDim2.new(1.1, 0, 1.1, 0)
		Shadow_Notify.Image = "rbxassetid://1316045217"
		Shadow_Notify.ImageColor3 = Color3.fromRGB(0, 0, 0)
		Shadow_Notify.ImageTransparency = 1
		Shadow_Notify.ScaleType = Enum.ScaleType.Slice
		Shadow_Notify.SliceCenter = Rect.new(10, 10, 118, 118)
		Shadow_Notify.ZIndex = -1
		
		Content.Name = "Content"
		Content.Parent = NotifyFrame
		Content.BackgroundTransparency = 1
		Content.Size = UDim2.new(1, 0, 1, 0)
		
		UIListLayout_Content.Parent = Content
		UIListLayout_Content.Padding = UDim.new(0, 10)
		UIListLayout_Content.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_Content.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_Content.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_Content.VerticalAlignment = Enum.VerticalAlignment.Center
		
		IconFrame.Name = "IconFrame"
		IconFrame.Parent = Content
		IconFrame.BackgroundTransparency = 1
		IconFrame.Size = UDim2.new(0, 30, 0, 30)
		
		IconImage.Name = "Icon"
		IconImage.Parent = IconFrame
		IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
		IconImage.BackgroundTransparency = 1
		IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconImage.Size = UDim2.new(1, 0, 1, 0)
		IconImage.Image = gl(Icon).Image
		IconImage.ImageTransparency = 1
		
		TextFrame.Name = "TextFrame"
		TextFrame.Parent = Content
		TextFrame.BackgroundTransparency = 1
		TextFrame.Size = UDim2.new(1, -50, 1, 0)
		
		TextLabel_Notify.Name = "Text"
		TextLabel_Notify.Parent = TextFrame
		TextLabel_Notify.BackgroundTransparency = 1
		TextLabel_Notify.Size = UDim2.new(1, 0, 1, 0)
		TextLabel_Notify.Font = Enum.Font.GothamBold
		TextLabel_Notify.Text = Title
		TextLabel_Notify.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel_Notify.TextSize = 14
		TextLabel_Notify.TextTransparency = 1
		TextLabel_Notify.TextWrapped = true
		TextLabel_Notify.TextXAlignment = Enum.TextXAlignment.Left
		
		local textSize = game:GetService("TextService"):GetTextSize(Title, 14, Enum.Font.GothamBold, Vector2.new(240, math.huge))
		local height = math.max(60, textSize.Y + 30)
		
		NotifyFrame.Size = UDim2.new(1, 0, 0, height)
		
		tw({v = NotifyFrame, t = 0.3, s = Enum.EasingStyle.Back, d = "Out", g = {Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.2}}):Play()
		tw({v = UIStroke_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "Out", g = {Transparency = 0}}):Play()
		tw({v = Shadow_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "Out", g = {ImageTransparency = 0.5}}):Play()
		tw({v = IconImage, t = 0.3, s = Enum.EasingStyle.Back, d = "Out", g = {ImageTransparency = 0}}):Play()
		tw({v = TextLabel_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "Out", g = {TextTransparency = 0}}):Play()
		
		local connection
		connection = game:GetService("RunService").Heartbeat:Connect(function()
			if NotifyFrame.Parent then
				UIListLayout_NotifyContainer:ApplyLayout()
			else
				connection:Disconnect()
			end
		end)
		
		task.spawn(function()
			task.wait(Time)
			
			tw({v = NotifyFrame, t = 0.3, s = Enum.EasingStyle.Back, d = "In", g = {Position = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}}):Play()
			tw({v = UIStroke_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "In", g = {Transparency = 1}}):Play()
			tw({v = Shadow_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "In", g = {ImageTransparency = 1}}):Play()
			tw({v = IconImage, t = 0.3, s = Enum.EasingStyle.Back, d = "In", g = {ImageTransparency = 1}}):Play()
			tw({v = TextLabel_Notify, t = 0.3, s = Enum.EasingStyle.Back, d = "In", g = {TextTransparency = 1}}):Play()
			
			task.delay(0.3, function()
				if NotifyFrame.Parent then
					NotifyFrame:Destroy()
				end
			end)
		end)
		
		local n = {}
		
		function n:Set(newText)
			if TextLabel_Notify then
				TextLabel_Notify.Text = newText
				local newTextSize = game:GetService("TextService"):GetTextSize(newText, 14, Enum.Font.GothamBold, Vector2.new(240, math.huge))
				local newHeight = math.max(60, newTextSize.Y + 30)
				tw({v = NotifyFrame, t = 0.2, g = {Size = UDim2.new(1, 0, 0, newHeight)}}):Play()
			end
		end
		
		return n
	end

	local realText = ""
	local hidden = true
	local lastLength = 0
	local te = "*"
	
	local TextLabel_Overlay = Instance.new('TextLabel')
	TextLabel_Overlay.Text = realText
	TextLabel_Overlay.TextTransparency = 1
	TextLabel_Overlay.BackgroundTransparency = 1
	TextLabel_Overlay.Size = TextBox_1.Size
	TextLabel_Overlay.Font = TextBox_1.Font
	TextLabel_Overlay.TextSize = TextBox_1.TextSize
	TextLabel_Overlay.TextColor3 = TextBox_1.TextColor3
	TextLabel_Overlay.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel_Overlay.TextYAlignment = Enum.TextYAlignment.Center
	TextLabel_Overlay.Parent = TextBox_1
	
	TextBox_1.TextTransparency = 1
	TextBox_1.Text = ""
	TextLabel_Overlay.Text = ""
	TextLabel_Overlay.TextTransparency = 1

	if savedKey ~= "" then
		realText = savedKey
		TextBox_1.Text = string.rep(te, #realText)
		TextLabel_Overlay.Text = realText
		lastLength = #realText
	end

	TextBox_1:GetPropertyChangedSignal("Text"):Connect(function()
		if hidden then
			if TextBox_1.Text == "" then
				realText = ""
			else
				local newLen = #TextBox_1.Text
				if newLen < lastLength then
					realText = realText:sub(1, -2)
				elseif newLen > lastLength then
					realText = realText .. TextBox_1.Text:sub(-1)
				end
			end
			TextBox_1.Text = string.rep(te, #realText)
		else
			realText = TextBox_1.Text
		end

		lastLength = #realText
		TextLabel_Overlay.Text = realText
	end)

	if HideShowKey then
		HideShowKey.MouseButton1Click:Connect(function()
			hidden = not hidden

			if hidden then
				TextBox_1.Text = string.rep(te, #realText)
				ImageLabel_2.Image = "rbxassetid://13868333926"
			else
				TextBox_1.Text = realText
				ImageLabel_2.Image = "rbxassetid://13868333927"
			end

			lastLength = #realText
		end)
	end

	if ClickJoinDis then
		ClickJoinDis.MouseButton1Click:Connect(function()
			if KeyGUI then 
				pcall(setclipboard, o.DiscordLink or "discord.gg") 
			end
			tab.Notify({
				Title = 'Discord link copied!',
				Icon = 14939475472,
				Time = 3,
				Color = Color3.fromRGB(88, 101, 242)
			})
		end)
	end
	
	local checkingKey = false
	
	if Click_2 then
		Click_2.MouseButton1Click:Connect(function()
			tw({v = Button_2, t = 0.1, s = Enum.EasingStyle.Quad, d = "InOut", g = {Size = UDim2.new(1, 0,0, 28), BackgroundColor3 = Color3.fromRGB(100, 220, 100)}}):Play()
			task.delay(0.1, function()
				tw({v = Button_2, t = 0.1, s = Enum.EasingStyle.Quad, d = "InOut", g = {Size = UDim2.new(1, 0,0, 30), BackgroundColor3 = Color}}):Play()
			end)
			if o.KeyLink then
				if KeyGUI then 
					pcall(setclipboard, o.KeyLink) 
				end
				tab.Notify({
					Title = 'Key link copied to clipboard!',
					Icon = 14938884688,
					Time = 3,
					Color = Color3.fromRGB(76, 175, 80)
				})
			else
				tab.Notify({
					Title = 'No key link provided',
					Icon = 14943813832,
					Time = 3,
					Color = Color3.fromRGB(244, 67, 54)
				})
			end
		end)
	end
	
	if Click_1 then
		Click_1.MouseButton1Click:Connect(function()
			if checkingKey then return end
			checkingKey = true
			
			tw({v = Button_1, t = 0.1, s = Enum.EasingStyle.Quad, d = "InOut", g = {Size = UDim2.new(1, 0,0, 28), BackgroundColor3 = Color3.fromRGB(255, 193, 7)}}):Play()
			
			local checkNotify = tab.Notify({
				Title = 'Checking Key...',
				Icon = 14939512891,
				Time = 10,
				Color = Color3.fromRGB(255, 193, 7)
			})
			
			task.delay(0.5, function()
				local input = realText
				local found = false

				for _, v in ipairs(Key) do
					if input == v then
						found = true
						break
					end
				end

				if found then
					if KeyGUI then 
						pcall(writefile, "SindexHub/key.txt", input) 
					end
					
					task.delay(0.3, function()
						checkNotify:Set('Key Verified Successfully!')
						tab.Notify({
							Title = 'Loading script...',
							Icon = 14939512891,
							Time = 2,
							Color = Color3.fromRGB(76, 175, 80)
						})
					end)
					
					tw({v = Button_1, t = 0.2, s = Enum.EasingStyle.Quad, d = "InOut", g = {BackgroundColor3 = Color3.fromRGB(76, 175, 80)}}):Play()
					
					task.delay(1.5, function()
						tw({v = Left_1, t = 0.25, s = Enum.EasingStyle.Quad, d = "Out", g = {GroupTransparency = 1}}):Play()
						task.delay(0.25, function()
							tw({v = Background_1, t = 0.25, s = Enum.EasingStyle.Quad, d = "Out", g = {BackgroundTransparency = 1}}):Play()
							tw({v = Shadow_BG, t = 0.25, s = Enum.EasingStyle.Quad, d = "Out", g = {ImageTransparency = 1}}):Play()
							task.delay(0.3, function()
								ScreenGui:Destroy()
								if o.Callback then
									o.Callback()
								end
							end)	
						end)
					end)
				else
					tw({v = Keybox_1, t = 0.2, s = Enum.EasingStyle.Quad, d = "InOut", g = {BackgroundColor3 = Color3.fromRGB(244, 67, 54)}}):Play()
					task.delay(0.2, function()
						tw({v = Keybox_1, t = 0.2, s = Enum.EasingStyle.Quad, d = "InOut", g = {BackgroundColor3 = Color}}):Play()
					end)
					
					checkNotify:Set('Invalid Key!')
					
					tab.Notify({
						Title = 'Invalid key! Please check and try again.',
						Icon = 14943813832,
						Time = 3,
						Color = Color3.fromRGB(244, 67, 54)
					})
					
					tw({v = Button_1, t = 0.2, s = Enum.EasingStyle.Quad, d = "InOut", g = {BackgroundColor3 = Color3.fromRGB(244, 67, 54)}}):Play()
					
					task.delay(0.5, function()
						tw({v = Button_1, t = 0.2, s = Enum.EasingStyle.Quad, d = "InOut", g = {BackgroundColor3 = Color, Size = UDim2.new(1, 0,0, 30)}}):Play()
						checkingKey = false
					end)
				end
			end)
		end)
	end

	return tab
end

return Library
