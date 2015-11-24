
SqlCreater = {}
SqlCreater.__index = SqlCreater

function SqlCreater:new(mysqlHelper)
	
	local o = {}
	setmetatable(o, self)

	o.mysqlHelper = mysqlHelper
	
	return o
end

function SqlCreater:GenInsertSql(tableName, tableContent)
	
	local sqlT = {}
	
	table.insert(sqlT, "insert into ")
	table.insert(sqlT, tableName)
	table.insert(sqlT, "(")

	local fieldCount = #tableContent
	for i = 1, fieldCount do
		local key = tableContent[i].name
		table.insert(sqlT, key)
		if i ~= fieldCount then
			table.insert(sqlT, ", ")
		end
	end
	table.insert(sqlT, ") values (")
	
	for i = 1, fieldCount do
		local fieldType = tableContent[i].type
		local content = tableContent[i].content
		if fieldType == "string" then
			content = self.mysqlHelper:TranslateString(content, string.len(content))	
		end
		if fieldType == "string" then
			table.insert(sqlT, "'")
		end
		table.insert(sqlT, content)
		if fieldType == "string" then
			table.insert(sqlT, "'")
		end

		if i ~= fieldCount then
			table.insert(sqlT, ", ")
		end
	end
	table.insert(sqlT, ")")

	return table.concat(sqlT)
end

function SqlCreater:GenUpdateSql(tableName, tableContent, where)
	
	local sqlT = {}
	
	table.insert(sqlT, "update ")
	table.insert(sqlT, tableName)
	table.insert(sqlT, " set ")

	local fieldCount = #tableContent
	for i = 1, fieldCount do
		local key = tableContent[i].name
		local fieldType = tableContent[i].type
		local content = tableContent[i].content
		if fieldType == "string" then
			content = self.mysqlHelper:TranslateString(content, string.len(content))	
		end
		
		table.insert(sqlT, key)
		table.insert(sqlT, " = ")
		
		if fieldType == "string" then
			table.insert(sqlT, "'")
		end
		table.insert(sqlT, content)
		if fieldType == "string" then
			table.insert(sqlT, "'")
		end
		
		if i ~= fieldCount then
			table.insert(sqlT, ", ")
		end
	end
	table.insert(sqlT, " where ")
	
	local whereCount = #where
	for i = 1, whereCount do
		local key = where[i].name
		local fieldType = where[i].type
		local content = where[i].content
		content = self:TranslateField(fieldType, content)	

		table.insert(sqlT, key)
		table.insert(sqlT, " = ")
		table.insert(sqlT, content)
		
		if i ~= fieldCount then
			table.insert(sqlT, " and ")
		end
	end

	return table.concat(sqlT)
end


