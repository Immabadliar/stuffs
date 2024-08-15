-- [Variables] --
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Content = Shared.Content

local CartsDataBase = require(Content.Carts)

local Server = ServerScriptService.Server
local Services = Server.Services

local DataService = require(Services.DataService)

local function CanAddItemToCart(DataReplica)
	local CartContent = CartsDataBase:GetCart(DataReplica.Data.EquippedCart)
	return not (#DataReplica.Data.ItemsInCart == CartContent.Capacity)
end

local function CreateProximityPrompt(self)
	local NewPrompt = Instance.new("ProximityPrompt")
	
	NewPrompt.RequiresLineOfSight = false
	NewPrompt.Enabled = true
	
	NewPrompt.ActionText = "Grab"
	
	NewPrompt.Parent = self.Instance
	return NewPrompt
end

-- [Item] --
local Item = {}
Item.Tag = "Item"

function Item:Construct()
	if (math.random(1, 3) == 2) then
		self.Instance:Destroy()
	end
	
	self.Prompt = CreateProximityPrompt(self)
	
	self.Prompt.Triggered:Connect(function(Player)
		local DataReplica = DataService:GetDataReplica(Player)
		
		if (CanAddItemToCart(DataReplica) == false) then
			return
		end
		
		self.Instance:AddTag("Invisible")
				
		DataReplica:Write("AddToCart", self.Attributes.ItemID)
		
		task.wait(math.random(5, 15))
		self.Instance:RemoveTag("Invisible")
	end)
end

return Item

--end script one--

______________________________


--start script two--

-- [Variables] --
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = Shared.Packages

local Server = ServerScriptService.Server
local Components = Server.Components
local Services = Server.Services

local Binder = require(Packages.Binder)
local Loader = require(Packages.Loader)

local function NewClass(Component)
	local NewClass = {}
	NewClass.__index = NewClass

	function NewClass.Construct(Object)
		local self = {}
		setmetatable(self, NewClass)

		self.Attributes = Object:GetAttributes()
		self.Instance = Object

		Component.Construct(self)
		return self
	end

	function NewClass:Destroy()
		if (Component.Destroy == nil) then
			return
		end

		Component.Destroy(self)
	end

	return NewClass
end

-- [StartServer] --
local LoadedServices = Loader.LoadDescendants(
	Services, Loader.MatchesName("Service$")
)

Loader.SpawnAll(LoadedServices, false, "OnInit")
Loader.SpawnAll(LoadedServices, true, "OnStart")

for _, ComponentModule in ipairs(Components:GetChildren()) do
	local Component = require(ComponentModule)
	local Tag = Component.Tag


	local NewBinder = Binder.new(Tag, NewClass(Component))
	NewBinder:bind()
end


-- end script two -- 

--------------


-- [Variables] --
--http://www.roblox.com/asset/?id=507770239

local function CreateAnimation()
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://507770239"
	return Animation
end

-- [NPC] --
local NPC = {}
NPC.Tag = "NPC"

function NPC:Construct()
	self.Humanoid = self.Instance:FindFirstChildWhichIsA("Humanoid")
	
	local NewWaveAnimation = CreateAnimation()
	NewWaveAnimation.Parent = self.Humanoid
	
	self.AnimationTrack = self.Humanoid:LoadAnimation(NewWaveAnimation)

	self.AnimationTrack:Play()
	self.AnimationTrack.Looped = true
end

return NPC

-- end script 3 -- 

-- [Variables] --
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local Content = Shared.Content

local ItemsDataBase = require(Content.Items)

local Server = ServerScriptService.Server
local Services = Server.Services

local DataService = require(Services.DataService)

-- [Sell] --
local Sell = {}
Sell.Tag = "Sell"

function Sell:Construct()
	
	self.Instance.Touched:Connect(function(Hit)
		local Player = Players:GetPlayerFromCharacter(Hit.Parent)
		
		if (Player == nil) then
			return
		end
		
		local DataReplica = DataService:GetDataReplica(Player)
		local CartItems = DataReplica.Data.ItemsInCart
		
		for _, ItemID in ipairs(CartItems) do
			DataReplica:Write("IncrementCoins", ItemsDataBase:GetItem(ItemID).Value)
		end
		
		DataReplica:Write("ClearCart")
	end)
end

return Sell

--end script four--

_______________________________________

-- [Variables] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Shared = ReplicatedStorage.Shared
local Packages = Shared.Packages

local HIDDEN_CFRAME = CFrame.new(0, 10e8, 0)

-- [Invisible] --
local Invisible = {}
Invisible.Tag = "Invisible"

function Invisible:Construct()
	if (self.Instance:IsA("BasePart") == true) then
		self.OldCFrame = self.Instance.CFrame
		self.Instance:PivotTo(HIDDEN_CFRAME)
	else
		self.OldParent = self.Instance.Parent
		self.Instance.Parent = ReplicatedFirst
	end
end

function Invisible:Destroy()
	if (self.Instance:IsA("BasePart") == true) then
		self.Instance:PivotTo(self.OldCFrame)
	else
		self.Instance.Parent = self.OldParent
	end
end

return Invisible




-- [Variables] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local Content = Shared.Content

local CartsDataBase = require(Content.Carts)

local Client = ReplicatedStorage.Client
local Controllers = Client.Controllers

local Player = Players.LocalPlayer

local DataController = require(Controllers.DataController)
local DataReplica = DataController:GetDataReplica(Player)

local MaxStorage = 0

local function OnItemsInCartChanged()
	local ItemsInCartLength = #DataReplica.Data.ItemsInCart
	script.Parent.Text = `{ItemsInCartLength}/{MaxStorage}`
end

local function OnEquippedCartUpdated(CartID)
	MaxStorage = CartsDataBase:GetCart(CartID).Capacity
	OnItemsInCartChanged()
end

-- [StorageDisplayer] --
OnEquippedCartUpdated(DataReplica.Data.EquippedCart)
OnItemsInCartChanged()

DataReplica:ListenToChange("EquippedCart", OnEquippedCartUpdated)
DataReplica:ListenToWrite("AddToCart", OnItemsInCartChanged)
DataReplica:ListenToWrite("ClearCart", OnItemsInCartChanged)



-- [Variables] --
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Leaderstats = Player:WaitForChild("leaderstats")
local Coins = Leaderstats:WaitForChild("💰 Coins")

local LastAmount = 0

local function UpdateCoins(NewAmount)
	
	local PlusText = (NewAmount - LastAmount)
	
	if (PlusText < 0) then
		return
	end
	
	local NewPlusText = script.Plus:Clone()
	NewPlusText.Text = "+"..tostring(PlusText)
	
	NewPlusText.Position = UDim2.fromScale(math.random(10, 90) * 0.01, math.random(10, 90) * 0.01)
	
	NewPlusText.Parent = script.Parent
	NewPlusText:TweenSize(
		UDim2.fromScale(
			NewPlusText.Size.X.Scale * 1.25,
			NewPlusText.Size.Y.Scale * 1.25
		),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		0.25,
		true,
		function()
			task.wait(1)
			NewPlusText:Destroy()
		end
	)
	
	LastAmount = NewAmount
end

-- [+1Displayer] --
LastAmount = Coins.Value
Coins.Changed:Connect(UpdateCoins)

