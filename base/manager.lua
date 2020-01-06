--------------------------------------------------------------
--
-- Manager
--
--	e.g.
--		m = Manager()
--		m:Init( "name", clz )
--
--		data = { "test" }
--		m:AddData( 1, data )
--
--------------------------------------------------------------
Manager = class()

local _managers = {}

--------------------------------------------------------------
function Manager:__init( name, clz )
	self._name = name
	self._clz = clz
	self._datas = {}
	self._count = 0	
	self._alloateId = 0
	self._removeList = nil

	table.insert( _managers, self )
end

--------------------------------------------------------------
function Manager:GetCount()
	return self._count
end

--------------------------------------------------------------
function Manager:GetData( id )
	if not id or id == 0 then return nil end
	if not self._datas then return nil end
	return self._datas[id]
end

--------------------------------------------------------------
function Manager:GetIndexData( index )
	for _, data in pairs( self._datas ) do
		if index > 1 then
			index = index - 1
		else
			return data
		end
	end
	return nil
end

--------------------------------------------------------------
function Manager:NewID()
	self._alloateId = self._alloateId + 1
	return self._alloateId
end

--------------------------------------------------------------
function Manager:Clear()
	self._datas     = {}
	self._count     = 0
	self._alloateId = 0
end

--------------------------------------------------------------
--[[
	e.g
		enum_datamng = 
		{
			TYPE_PLAYER = 1
		}		

		Player = class()

		m = Manager()		
		m:Init( "plaer_mgr", Player )
--]]
function Manager:Init( name, clz )
	self._name = name or self._name

	self._clz  = clz or self._clz
end

--------------------------------------------------------------
--[[
	[datas]
	  [ id=1, ... ]		
	  [ id=2, ... ]
--]]
function Manager:LoadFromData( datas )
	if not datas then
		print( "!!! Manager:LoadFromdata() Failed! Name = " .. ( self._name or "" ) )
		return 0
	end

	if not self._clz then
		error( "no clz" )
		return 0
	end

	--load new datas
	local number = 0
	for k, data in pairs( datas ) do		
		local newData = self._clz()

		if data.id == nil then
			--less codes, use index as key-id
			data.id = k
		end
		
		newData:Load( data )

		self:AddData( newData.id, newData )
		
		--set allocated id
		if self._alloateId <= data.id then
			self._alloateId = data.id
		end

		number = number + 1
	end

	return number
end

--------------------------------------------------------------
function Manager:NewData( ... )
	if not self._clz then error( "no class-object for manager" ) return nil end
	local newId = self:NewID()
	local newData = self._clz( ... )
	newData.id = newId
	self:AddData( newId, newData )	
	return newData
end

--------------------------------------------------------------
function Manager:AddData( id, data )
	if self._removeList then
		DBG_Warning( "Mng", "Add data in Foreach() is not recommended! name=" .. ( self._name or "" ) )
	end

	if not self._datas[id] then self._count = self._count + 1 end

	self._datas[id] = data

	return true
end

--------------------------------------------------------------
function Manager:BeginTraversal()
	self._removeList = {}
end

--------------------------------------------------------------
function Manager:EndTraversal()
	--remove list
	if self._removeList then
		local num = 0
		for _, id in pairs( self._removeList ) do
			local data = self._datas[id]			
			--print( "remove id=" .. id, data:ToString() )
			self._datas[id] = nil
			num = num + 1
		end
		if num > 0 then
			--InputUtil_Pause( "end travesal" )
		end
		self._removeList = nil
	end
end

--------------------------------------------------------------
function Manager:RemoveData( id, fn )
	if not self._datas[id] then
		return false
	end
	if self._removeList then
		DBG_Warning( "Mng", "Remove data ( name=" .. ( self._name or "" ) .. ") isn't recommended when Traveling Data" )
		if self._datas[id] then
			table.insert( self._removeList, id )
			--print( "put id=" .. id .. " into remove list" )
		end
		return
	end
	if not fn or fn( self._datas[id] ) then
		self._datas[id] = nil
		self._count = self._count - 1
		return true
	end	
	return false
end

--------------------------------------------------------------
function Manager:RemoveAllData( fn )
	if self._removeList then
		error( "Mng", "RemoveAll isn't recommended when Traversal Data!" )
	end
	for k, data in pairs( self._datas ) do
		if not fn or fn( data ) then
			self._datas[k] = nil
			self._count = self._count - 1
		end
	end
end

--------------------------------------------------------------
function Manager:ForeachData( fn )
	self:BeginTraversal()
	for k, data in pairs( self._datas ) do
		fn( data )
	end
	self:EndTraversal()
end

--------------------------------------------------------------
--Filter data by given function, return true means find the right data
function Manager:FindData( fn )
	self:BeginTraversal()
	local ret
	for k, data in pairs( self._datas ) do
		if fn( data ) == true then			
			ret = data
			break
		end
	end
	self:EndTraversal()
	return ret
end

--------------------------------------------------------------