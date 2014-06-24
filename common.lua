require ('poco/3rdPartyLibrary.lua')
-- Poco Common Library V2 --
if not deep_clone then return end
local inGame = CopDamage ~= nil
function _pairs(t, f) -- pairs but sorted
  local a = {}
  for n in pairs(t or {}) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0
  return function ()
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
  end
end
local clr = function(bgr)
	return Color(bgr%0x100,math.floor(bgr/0x100) % 0x100,math.floor(bgr/0x10000))
end
cl = {
	Aqua				=clr(0xFFFF00),
	Black				=clr(0x000000),
	Blue				=clr(0xFF0000),
	Cream				=clr(0xF0FBFF),
	DkGray			=clr(0x808080),
	Fuchsia			=clr(0xFF00FF),
	Gray				=clr(0x808080),
	Green				=clr(0x008000),
	Lime				=clr(0x00FF00),
	LtGray			=clr(0xC0C0C0),
	Maroon			=clr(0x000080),
	MedGray			=clr(0xA4A0A0),
	MoneyGreen	=clr(0xC0DCC0),
	Navy				=clr(0x800000),
	Olive				=clr(0x008080),
	Purple			=clr(0x800080),
	Red					=clr(0x0000FF),
	Silver			=clr(0xC0C0C0),
	SkyBlue			=clr(0xF0CAA6),
	Teal				=clr(0x808000),
	White				=clr(0xFFFFFF),
	Yellow			=clr(0x00FFFF),
}

_ = {
	F = function (n,k) -- ff
		k = k or 2
		if type(n) == 'number' then
			local r = string.format('%.'..k..'g', n):sub(1,k+2)
			return r:find('e') and tostring(math.floor(n)) or r
		elseif type(n) == 'table' then
			return zinspect(n):gsub('\n','')
		else
			return tostring(n)
		end
	end,
	S = function (...) -- toStr
		local a,b = clone({...}) , {}
		for k,v in pairs(a) do
			b[#b+1] = _.F(v)
		end
		local r,err = pcall(table.concat,b,' ')
		if r then
			return err
		else
			return '_.s Err: '..zinspect(b):gsub('\n','')
		end
	end,
	C = function (name,message,color) -- Chat
		if not message then
			message = name
			name = nil
		end
		if not tostring(color):find('Color') then
			color = nil
		end
		message = _.S(message)
		if managers and managers.chat and managers.chat._receivers and managers.chat._receivers[1] then
			for __,rcv in pairs( managers.chat._receivers[1] ) do
				rcv:receive_message( name or "*", message, color or tweak_data.chat_colors[5] )
			end
		else
			_('_.C',message)
		end
	end,
	D = function (...) -- Debug
		if managers and managers.mission then
			managers.mission._show_debug_subtitle(managers.mission,_.S(...)..'  ')
			return true
		else
			_('_.D',...)
		end
	end,
	O = function (...) -- File
		local f = io.open("poco\\output.txt", "a")
		f:write(_.S(...).."\n")
		f:close()
	end,
	R = function (mask) -- RayTest
		-- local _maskDefault = World:make_slot_mask( 2, 8, 11, 12, 14, 16, 18, 21, 22, 25, 26, 33, 34, 35 )
		local from = alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
		if not from then return end
		local to = from + managers.player:player_unit():movement():m_head_rot():y() * 30000
		local masks = type(mask)=='string' and managers.slot:get_mask( mask ) or mask or managers.slot:get_mask( 'bullet_impact_targets' )
		return World:raycast( "ray", from, to, "slot_mask", masks)
	end,
	G = function (path,fallback,origin) -- SafeGet
		local from = origin or _G
		local lPath = ''
		for curr,delim in string.gmatch (path, "([%a_]+)([^%a_]*)") do
			local isFunc = string.find(delim,'%(')
			if isFunc then
				from = from[curr](from)
			else
				from = from[curr]
			end
			lPath = lPath..curr..delim
			if not from then
				break
			elseif type(from) ~= 'table' and type(from) ~= 'userdata' then
				if lPath ~= path then
					from = nil
					break
				end
			end
		end
		if not from and fallback ~= nil then
			return fallback
		else
			return from
		end
	end
}
setmetatable(_,{__call = function(__,...)io.stderr:write(_.S(...)..'\n')end})
UNDERSCORE = _
if clone then
	for k,v in pairs(clone(_)) do
		_[k:lower()] = v
	end
end
_assert = _assert or assert
assert = function()	end
function string:usub(start,num)
	local r = ''
	for i,t in ipairs(utf8.characters(self) or {}) do
		if (num and (i>=start and i<num+start)) or not num and (i<=start) then
			r = r .. t
		end
	end
	return r
end
-----------
TPocoBase = class()
TPocoBase.className = 'Base'
TPocoBase.classVersion = 0

function TPocoBase:init()
	self.inherited = self
	local data = Poco.save[self.className]
	if data then
		self:import(data)
	end
	if self.onInit and self:onInit() then
		Poco:register(self.className..'_update',callback(self,self,'Update'))
		self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func( callback( self, self, "onResolutionChanged" ) )
	else
		self:destroy()
	end
end
function TPocoBase:onResolutionChanged()
end
function TPocoBase:import(data)
end
function TPocoBase:export()
end
function TPocoBase:name(inner)
	return (inner and '' or 'Poco')..self.className..self.classVersion
end
function TPocoBase:Update(t,dt)
end
function TPocoBase:err(msg,deeper)
	local di = debug.getinfo(3+(deeper or 0))
	managers.menu_component:post_event( "zoom_in")
	self._lastError = _.s(msg,di and di.short_src..':'..di.currentline or '@?')
end
function TPocoBase:lastError()
	return self._lastError or ''
end

function TPocoBase:destroy(...)
	managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	if self.onDestroy then self:onDestroy(...) end
	self.dead = true
	Poco:unregister(self.className..'_update',callback(self,self,'Update'))
end
----------
TPoco = class()
function TPoco:init()
	self.addOns = {}
	self.funcs = {}
	self.save = {}
	self.binds = {down={},up={}}
	if inGame then
		self.pnl = managers.hud._workspace:panel():panel({ name = "poco_sheet" , layer = 50000})
	end
	self._kbd = Input:keyboard()
	if not setup._update then
		setup._update = setup.update
	end
	setup.update = function(setup_self,t,dt)
		setup_self:_update(t,dt)
		if not self.dead then
			self:Update(t,dt)
		end
	end
	_('Poco:Init')
end
function TPoco:Bind(sender,key,downCbk,upCbk)
	local name = sender:name(1)
	self.binds.down[key] = downCbk and {name,downCbk} or nil
	self.binds.up[key] = upCbk and {name,upCbk} or nil
end
function TPoco:LoadOptions(key,obj)
	local extOpt = io.open('poco\\'..key..'_config.lua','r')
	local merge
	merge = function (t1, t2)
		for k, v in pairs(t2) do
			if (type(v) == "table") and (type(t1[k] or false) == "table") then
				merge(t1[k], t2[k])
			else
				t1[k] = v
			end
		end
		return t1
	end
	if extOpt then
		extOpt = loadstring(extOpt:read('*all'))()
		obj = merge(obj,extOpt or {})
	else
		_('No config file found. (poco\\'..key..'_config.lua)')
	end
end
function TPoco:UnBind(sender)
	local name = sender:name(1)
	for key,cbk in pairs(clone(self.binds.down)) do
		if cbk[1]==name then
			self.binds.down[key] = nil
		end
	end
	for key,cbk in pairs(clone(self.binds.up)) do
		if cbk[1]==name then
			self.binds.up[key] = nil
		end
	end
end
function TPoco:AddOn(ancestor)
	local name = ancestor.className
	local addOn = self.addOns[name]
	if addOn then
		self:UnBind(addOn)
		addOn:export()
		addOn:destroy()
		self.addOns[name] = nil
		return
	else
		local addon = ancestor:new()
		self.addOns[name] = addon
		return addon
	end
end
function TPoco:Update(t,dt)
	if not managers.menu_component:input_focus() then
		for key,cbks in pairs(self.binds.down) do
			if cbks and self._kbd:pressed(key) then
				cbks[2](t,dt)
			end
		end
		for key,cbks in pairs(self.binds.up) do
			if cbks and self._kbd:released(key) then
				cbks[2](t,dt)
			end
		end
	end

	for __,func in pairs(self.funcs) do
		func(t,dt)
	end
end
function TPoco:register(key,func)
	if not self.funcs[key] then
		self.funcs[key] = func
	end
end
function TPoco:unregister(key)
	self.funcs[key] = nil
end
function TPoco:destroy()
	for k,v in pairs(self.addOns) do
		v:destroy()
	end
	self.dead = true
	managers.hud._workspace:remove(self.pnl)
	setup.update = setup._update
	setup._update = nil
	_('Poco:destroy')
end



if Poco and not Poco.dead then
	Poco:destroy()
else
	Poco = TPoco:new()
end

