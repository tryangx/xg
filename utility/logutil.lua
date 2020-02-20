function Log_ToString( ... )
	args = { ... }
	if #args == 0 then return end

	local content = ""
	for i = 1, #args do
		local type = typeof( args[i] )
		if type == "string" or type == "number" then
			content = content .. args[i] .. " "
		end
	end
	return content
end

-----------------------------------------------

LogUtility = class()

LogWarningLevel = 
{
	DEBUG  = 0,

	LOG    = 1,

	IMPORTANT = 50,
		
	ERROR  = 100,
}

function LogUtility:__init( fileName, logLevel, isPrintLog, isAdd )
	self.logs = {}
	self.logIndex = 1
	
	self.fileUtility = nil
	self.isPrintLog  = isPrintLog or false
	self.logLevel    = logLevel or LogWarningLevel.LOG
	self.isAdd       = isAdd

	self:SetLogFile( fileName )
end

function LogUtility:SetLogFile( fileName )
	if not self.fileUtility then self.fileUtility = SaveFileUtility() end
	self.fileUtility:OpenFile( fileName, not self.isAdd )
end

function LogUtility:SetPrinterMode( isOn )		
	self.isPrintLog = isOn
end

function LogUtility:SetAddMode( isAdd )
	self.isAdd = isAdd
	if self.fileUtility then
		self.fileUtility:SetMode( isAdd )
	end
end

function LogUtility:SetLogLevel( level )
	self.logLevel = level
end

function LogUtility:WriteContent( content, level )
	if self.isPrintLog == true and self.logLevel and self.logLevel <= level then print( content ) end

	if level <= LogWarningLevel.DEBUG then
		content = "[DBG] " .. content
	elseif level <= LogWarningLevel.LOG then
		content = "[LOG] " .. content
	elseif level <= LogWarningLevel.IMPORTANT then
		content = "[IMPT] " .. content
	elseif level <= LogWarningLevel.ERROR then
		content = "[ERR] " .. content
	end
	--print( self.isPrintLog, self.logLevel, level )
	
	self.fileUtility:WriteContent( content .. "\n" )
	table.insert( self.logs, content )
end

function LogUtility:WriteDebug( ... )
	self:WriteContent( Log_ToString( ... ), LogWarningLevel.DEBUG )
end
function LogUtility:WriteLog( ... )
	self:WriteContent( Log_ToString( ... ), LogWarningLevel.LOG )
end
function LogUtility:WriteImportant( ... )
	self:WriteContent( Log_ToString( ... ), LogWarningLevel.IMPORTANT )
end
function LogUtility:WriteError( ... )
	self:WriteContent( Log_ToString( ... ), LogWarningLevel.ERROR )
end

function LogUtility:Clear()
	self.logs = {}
	self.logIndex = 1
end