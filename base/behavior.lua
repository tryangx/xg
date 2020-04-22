------------------------------
------------------------------
local function debugmsg( content )
	--if true then
	if nil then
		print( content )
	end
end


------------------------------
-- Behavior Node
------------------------------

BehaviorNodeType = 
{
	INVALID           = 0,

	-------------------------
	-- Composite Node
	-------------------------
	-- Run all nodes in given sequence one by one until any node return true, default return false
	SELECTOR          = 100,
	
	-- Run all nodes in random sequence one by one until any node return true, default return false
	RANDOM_SELECTOR   = 101,
	
	-- Run all nodes in given sequence one by one, return false when any node return false, default return true
	SEQUENCE          = 120,
	
	-- Run all nodes in given sequence one by one, return true when any node return true, default return false
	PARALLEL          = 130,
	
	-- Run all nodes in given sequence on by one, until all node return false
	LOOP              = 140,


	------------------------
	-- Behaviour Node
	------------------------
	-- Execute the action, always return true
	ACTION            = 210,
	
	-- Execute the action until condition return true or none condition, after that return true, default return false
	CONDITION_ACTION  = 220,
	
	
	------------------------
	-- Decorator Node
	-------------------------
	SUCCESSOR         = 310,
	
	FAILURE           = 320,
	
	NEGATE            = 330,	
	

	------------------------
	-- Condition Node
	-------------------------
	-- Return the result of condition
	FILTER            = 410,


	------------------------
	-- Debug Node
	-------------------------
	MESSAGE           = 500,
	PAUSE             = 510,
	MESSAGE_FALSE     = 520,
	PAUSE_FALSE       = 530,
}

BehaviorNodeStatus = 
{
	IDLE      = 0,
	RUNNING   = 1,
	COMPLETED = 2,
}

BehaviorNode = class()

function BehaviorNode:__init( root, type, desc )
	self.type      = type
	self.desc      = desc
	self.root      = root
	self.children  = {}
	self.status    = BehaviorNodeStatus.IDLE	
	self.action    = nil
	self.condition = nil
	self.params    = nil
end

function BehaviorNode:SetActionNode( action )
	self.type = BehaviorNodeType.ACTION
	self.func = action
end

function BehaviorNode:SetConditionActionNode( condition, action )
	self.type = BehaviorNodeType.CONDITION_ACTION
	self.func = action
	self.condition = condition
end

function BehaviorNode:SetFilterNode( filter )
	self.type = BehaviorNodeType.FILTER
	self.condition = filter
end

function BehaviorNode:AppendChild( child )
	table.insert( self.children, child )
end

function BehaviorNode:GetFirstChild()
	return self.children[1]
end

--[[
	@usage
		data = 
		{
			type = "RANDOM_SELECTOR", desc = "Root", children = 
			{
				--military
				{ 
					type = "CONDITION_ACTION", desc = "military", condition = function() debugmsg( "check military" ) end, action = function() debugmsg( "execute military" ) end, children = {},
				},
				--develop
				{
					type = "CONDITION_ACTION", desc = "develop", condition = function() debugmsg( "check develop" ) end, action = function() debugmsg( "execute develop" ) end, children = {},
				},
			},
		}
		node = BehaviorNode( true )
		node:BuildTree( data )
--]]
function BehaviorNode:BuildTree( data )
	if not data or not data.type then
		Dump( data )
		error( "Data hasn't type" )
		return
	end
	
	-- Base information
	--debugmsg( data.type, data.desc, data.condition, data.action )
	self.type = BehaviorNodeType[string.upper(data.type)]
	self.desc = data.desc

	if not self.type then
		error( "invalid tree node=" .. data.type )
		return
	end
	
	-- Extension
	self.params = data.params
	
	-- Node type
	if self.type == BehaviorNodeType.ACTION then
		self.action = data.action
		if not self.action then
			Dump( data )			
			error( "ACTION function is invalid", self.type )
			return false
		end
	elseif self.type == BehaviorNodeType.CONDITION_ACTION then
		self.action    = data.action		
		self.condition = data.condition
		if ( not self.condition or not self.action ) then
			Dump( data )
			error( "ACTION or CONDITION function is invalid" )
			return false
		end
	elseif self.type == BehaviorNodeType.FILTER then
		self.condition = data.condition
		if not self.condition then
			Dump( data )
			error( "FILTER function is invalid", self.type )
			return false
		end
	end
	
	-- Children nodes
	--debugmsg( 'build node', self.type, self.desc )
	if data.children then
		for k, childData in ipairs( data.children ) do
			local child = BehaviorNode()
			if child:BuildTree( childData ) == false then
				if self.root == true then
					Dump( data )
					error( "Build tree failed!" )
				end
				return false
			else
				self:AppendChild( child )
				--debugmsg( 'append child', child.type, child.desc )
			end
		end
	end
end

------------------------------
-- Behavior
------------------------------

Behavior = class()

local function Selector( behavior, node )
	if node.desc then debugmsg( "Selector=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	if #node.children == 0 then error( "no selector children" ) end
	for k, child in ipairs( node.children ) do
		local fn = behavior.functions[child.type]
		if fn and fn( behavior, child ) then
			debugmsg( "Selector children return true, node=" .. ( node.desc or "" ) )
			return true
		end
	end
	debugmsg( "Selector return false, node=" .. ( node.desc or "" ) )
	return false
end

local function RandomSelector( behavior, node )	
	if node.desc then debugmsg( "RandomSelector=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	if #node.children == 0 then error( "no randomselector children" ) end

	local children = behavior:Copy( node.children )
	behavior:Shuffle( children )
	for k, child in pairs( children ) do
		local fn = behavior.functions[child.type]
		if fn and fn( behavior, child ) then
			debugmsg( "RandomSelector children return true, node=" .. ( node.desc or "" ) )
			return true
		end
	end
	debugmsg( "RandomSelector return false, node=" .. ( node.desc or "" ) )
	return false
end

local function Sequence( behavior, node )
	if node.desc then
		--debugmsg( "Sequence=" .. ( node.desc or "" ) .. " nodes=" .. #node.children )
	end
	if #node.children == 0 then error( "no sequence children" ) end
	for k, child in pairs( node.children ) do
		local fn = behavior.functions[child.type]
		if fn and fn( behavior, child ) == false then
			debugmsg( "Sequence children return false, node=" .. ( node.desc or "" ) )
			return false
		end
	end
	debugmsg( "Sequence return true, node=" .. ( node.desc or "" ) )
	return true
end


local function Parallel( behavior, node )
	if node.desc then debugmsg( "Parallel" ) end	
	local ret = false	
	for k, child in pairs( node.children ) do
		if behavior.functions[child.type]( behavior, child ) == true then
			debugmsg( "Parallel children return true, node=" .. ( node.desc or "" ) )
			ret = true
		end
	end
	debugmsg( "Parallel return false, node=" .. ( node.desc or "" ) )
	return ret
end


local function Loop( behavior, node )
	if node.desc then debugmsg( "Loop" ) end
	local ret = true
	while ret do
		ret = false
		for _, child in pairs( node.children ) do
			if behavior.functions[child.type]( behavior, child ) then ret = true end
		end
	end
	debugmsg( "Loop return false, node=" .. ( node.desc or "" ) )
	return ret
end


local function Action( behavior, node )
	if node.desc then
		debugmsg( "Action=" .. ( node.desc or "" ) .. " nodes=" .. #node.children )
	end
	if node.action then
		if not node.action then
			debugmsg( "No function for ACTION" )
		end
		if node.params then
			node.action( node.params )
		else
			node.action()
		end
	end
	debugmsg( "Action return, node=" .. ( node.desc or "" ) )
	return true
end

local function ConditionAction( behavior, node )
	if node.desc then debugmsg( "ConditionAction=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	if node.condition and node.condition() then	
		if node.action then node.action( node.params ) end
		debugmsg( "Condition return true, node=" .. ( node.desc or "" ) )
		return true		
	end
	debugmsg( "Condition return false, node=" .. ( node.desc or "" ) )
	return false
end

local function Successor( behavior, node )
	if node.desc then debugmsg( "Successor=" .. ( node.desc or "" ) .. " nodes=" .. #node.children )	end
	local child = node:GetFirstChild()
	if child then behavior:Run( child ) end
	debugmsg( "Succesoor return true, node=" .. ( node.desc or "" ) )
	return true
end

local function Failure( behavior, node )
	if node.desc then debugmsg( "Failure=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	local child = node:GetFirstChild()
	if child then behavior:Run( child ) end
	debugmsg( "Failure return true, node=" .. ( node.desc or "" ) )
	return false
end

local function Negate( behavior, node )
	if node.desc then debugmsg( "Negate=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	local ret = not behavior:Run( node:GetFirstChild() )
	debugmsg( "Negate return " .. ( ret and "true" or "false" ) .. ", node=" .. ( node.desc or "" ) )
	return ret
end

local function Filter( behavior, node )
	if node.desc then debugmsg( "Filter=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	local ret = node.condition and node.condition( node.params )
	debugmsg( "Filter return " .. ( ret and "true" or "false" ) .. ", node=" .. ( node.desc or "" ) )
	return ret
end

local function Message( behavior, node )
	if node.desc then debugmsg( "Filter=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	print( node.desc )
	return true	
end

local function Pause( behavior, node )
	if node.desc then debugmsg( "Filter=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	InputUtil_Pause( node.desc )
	return true
end

local function MessageFalse( behavior, node )
	if node.desc then debugmsg( "Filter=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	print( node.desc )
	return false	
end

local function PauseFalse( behavior, node )
	if node.desc then debugmsg( "Filter=" .. ( node.desc or "" ) .. " nodes=" .. #node.children ) end
	InputUtil_Pause( node.desc )
	return false
end


-------------------------------------------------
-------------------------------------------------
function Behavior:__init( ... )	
	self.functions = {}
	self.functions[BehaviorNodeType.SELECTOR]         = Selector
	self.functions[BehaviorNodeType.RANDOM_SELECTOR]  = RandomSelector
	self.functions[BehaviorNodeType.SEQUENCE]         = Sequence
	self.functions[BehaviorNodeType.PARALLEL]         = Parallel
	self.functions[BehaviorNodeType.LOOP]             = Loop
	
	self.functions[BehaviorNodeType.ACTION]           = Action
	self.functions[BehaviorNodeType.CONDITION_ACTION] = ConditionAction
	
	self.functions[BehaviorNodeType.SUCCESSOR]     = Successor
	self.functions[BehaviorNodeType.FAILURE]       = Failure
	self.functions[BehaviorNodeType.NEGATE]        = Negate
	
	self.functions[BehaviorNodeType.FILTER]        = Filter

	self.functions[BehaviorNodeType.MESSAGE]       = Message;
	self.functions[BehaviorNodeType.PAUSE]         = Pause;
	self.functions[BehaviorNodeType.MESSAGE_FALSE] = MessageFalse;
	self.functions[BehaviorNodeType.PAUSE_FALSE]   = PauseFalse;
end


function Behavior:Run( node )
	if not node then
		error( "invalid behavior node" )
		return false
	end
	
	--if node.desc then debugmsg( "desc=", node.desc, " nodes=" .. #node.children ) end
	
	local func = self.functions[node.type]
	if func then
		return func( self, node )
	end
	
	debugmsg( "Invalid Node Type=", node.type, func )
	return false
end


function Behavior:Random( min, max )
	return Random_GetInt_Sync( min, max )
	--return math.random( min, max )
end


function Behavior:Copy( sour )
	local dest = {}
	for k, v in pairs( sour ) do rawset( dest, k, v ) end
	return dest
end


function Behavior:Shuffle( list )
	local length = #list
	if length > 1 then
		for index = 1, length do
			local target = self:Random( 1, length - 1 )
			list[index], list[target] = list[target], list[index]		
		end
	end
end


------------------------------
-- Behavior Tree Sample
------------------------------
function Behavior_Test()
	data1 = 
	{
		type = "SEQUENCE", children =
		{
			{ type = "FILTER", condition = function() debugmsg( "check1" ) return false end },
			{ type = "ACTION", action = function() debugmsg( "act1" ) end },
		}
	}
	data2 = 
	{
		type = "SEQUENCE", children =
		{
			{ type = "FILTER", condition = function() debugmsg( "check2" ) return true end },
			{ type = "ACTION", action = function() debugmsg( "act2" ) end },
		}
	}
	data3 = 
	{
		type = "SEQUENCE", children = {
			data1,
			data2,
		},
		--[[
		output:
		check1
		]]
	}
	data4 = 
	{
		type = "SELECTOR", children = { 		
			data1,
			data2,
		},
		--[[
		output:
		check1
		check2
		act2
		]]
	}

	--decorator
	data5 = 
	{
		type = "SEQUENCE", children = 
		{
			{ type = "NEGATE", children = 
				{
					{ type = "FILTER", condition = function ( ... )
						debugmsg( "filter return true" )
						return true
					end },
				},
			},			
			{ type = "FILTER", condition = function ( ... )
					debugmsg( "second step, should be here" )
				end
			},
			{ type = "FAILURE" },
		},
	}

	local tree = BehaviorNode( true )
	tree:BuildTree( data5 )
	bev = Behavior()
	bev:Run( tree )
end