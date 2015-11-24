
--user: root   zk
--pwd:	123456

DBExecutor = {}
DBExecutor.__index = DBExecutor

function DBExecutor:new()
	
	local o = {}
	setmetatable(o, self)

	o.sqlCreater = SqlCreater:new(_mysqlHelper)

	return o
end

function DBExecutor:InsertSql(tableName, tableContent)
	
	local sql = self.sqlCreater:GenInertSql(tableName, tableContent)
	local retCode = _mysqlHelper:Query(sql, string.len(sql))
	
	if retCode ~= 0 then
		--todo error
		print("execute error: " .. sql)
		return false
	else
		return true
	end
end

function DBExecutor:UpdateSql(tableName, tableContent, where)
	
	local sql = self.sqlCreater:GenInertSql(tableName, tableContent, where)
	local retCode = _mysqlHelper:Query(sql, string.len(sql))
	
	if retCode ~= 0 then
		--todo error
		print("execute error: " .. sql)
		return false
	else
		return true
	end
end
 
