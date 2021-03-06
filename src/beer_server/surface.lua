-- Surface API version 1.6.2 by CrazedProgrammer
-- You can find info and documentation on these pages:
-- http://www.computercraft.info/forums2/index.php?/topic/22397-surface-api/
-- You may use this in your ComputerCraft programs and modify it without asking.
-- However, you may not publish this API under your name without asking me.
-- If you have any suggestions, bug reports or questions then please send an email to:
-- crazedprogrammer@gmail.com
version = "1.6.2"

local math_floor, math_cos, math_sin, table_concat, _colors = math.floor, math.cos, math.sin, table.concat, {[1] = "0", [2] = "1", [4] = "2", [8] = "3", [16] = "4", [32] = "5", [64] = "6", [128] = "7", [256] = "8", [512] = "9", [1024] = "a", [2048] = "b", [4096] = "c", [8192] = "d", [16384] = "e", [32768] = "f"}

local function _bufferLine(buffer, width, x1, y1, x2, y2)
	local delta_x = x2 - x1
	local ix = delta_x > 0 and 1 or -1
	delta_x = 2 * math.abs(delta_x)
	local delta_y = y2 - y1
	local iy = delta_y > 0 and 1 or -1
	delta_y = 2 * math.abs(delta_y)
	buffer[(y1 - 1) * width + x1] = true
	if delta_x >= delta_y then
		local error = delta_y - delta_x / 2
		while x1 ~= x2 do
			if (error >= 0) and ((error ~= 0) or (ix > 0)) then
				error = error - delta_x
				y1 = y1 + iy
			end
			error = error + delta_y
			x1 = x1 + ix
			buffer[(y1 - 1) * width + x1] = true
		end
	else
		local error = delta_x - delta_y / 2
		while y1 ~= y2 do
			if (error >= 0) and ((error ~= 0) or (iy > 0)) then
				error = error - delta_y
				x1 = x1 + ix
			end
			error = error + delta_x
			y1 = y1 + iy
			buffer[(y1 - 1) * width + x1] = true
		end
	end
end

local _functions = {
setBounds = function(surf, x1, y1, x2, y2)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x2 < 1 or x1 > surf.width or y2 < 1 or y1 > surf.height then return end
	if x1 < 1 then x1 = 1 end
	if x2 > surf.width then x2 = surf.width end
	if y1 < 1 then y1 = 1 end
	if y2 > surf.height then y2 = surf.height end
	surf.x1, surf.y1, surf.x2, surf.y2 = x1, y1, x2, y2
end,

getBounds = function(surf)
	return surf.x1, surf.y1, surf.x2, surf.y2
end,

copy = function(surf)
	local surf2 = create(surf.width, surf.height)
	surf2.x1, surf2.y1, surf2.x2, surf2.y2, surf2.blink, surf2.curX, surf2.curY, surf2.overwrite = surf.x1, surf.y1, surf.x2, surf.y2, surf.blink, surf.curX, surf.curY, surf.overwrite
	for i=1,surf.width * surf.height * 3 do
		surf2.buffer[i] = surf.buffer[i]
	end
	return surf2
end,

save = function(surf, path, type)
	type = type or "srf"
	local f = fs.open(path, "w")
	if type == "nfp" then
		local color = nil
		for j=1,surf.height do
			if j > 1 then f.write("\n") end
			for i=1,surf.width do
				color = surf.buffer[((j - 1) * surf.width + i) * 3 - 1]
				if color then
					f.write(_colors[color])
				else
					f.write(" ")
				end
			end
		end
	elseif type == "nft" then
		local backcolor, textcolor, char = nil
		for j=1,surf.height do
			if j > 1 then f.write("\n") end
			backcolor, textcolor = nil
			for i=1,surf.width do
				if backcolor ~= surf.buffer[((j - 1) * surf.width + i) * 3 - 1] then
					f.write(string.char(30))
					backcolor = surf.buffer[((j - 1) * surf.width + i) * 3 - 1]
					if backcolor then
						f.write(_colors[backcolor])
					else
						f.write(" ")
					end
				end
				if textcolor ~= surf.buffer[((j - 1) * surf.width + i) * 3] then
					f.write(string.char(31))
					textcolor = surf.buffer[((j - 1) * surf.width + i) * 3]
					if textcolor then
						f.write(_colors[textcolor])
					else
						f.write(" ")
					end
				end
				char = surf.buffer[((j - 1) * surf.width + i) * 3 - 2]
				if char then
					f.write(char)
				else
					f.write(" ")
				end
			end
		end
	elseif type == "srf" then
		f.write(surf:saveString())
	end
	f.close()
end,

saveString = function(surf)
	local str = {"_"..string.format("%04x", surf.width)..string.format("%04x", surf.height)}
	for j=1,surf.height do
		for i=1,surf.width do
			if surf.buffer[((j - 1) * surf.width + i) * 3 - 2] then
				str[#str + 1] = string.format("%02x", surf.buffer[((j - 1) * surf.width + i) * 3 - 2]:byte(1))
			else
				str[#str + 1] = "__"
			end
			if surf.buffer[((j - 1) * surf.width + i) * 3 - 1] then
				str[#str + 1] = _colors[surf.buffer[((j - 1) * surf.width + i) * 3 - 1]]
			else
				str[#str + 1] = "_"
			end
			if surf.buffer[((j - 1) * surf.width + i) * 3] then
				str[#str + 1] = _colors[surf.buffer[((j - 1) * surf.width + i) * 3]]
			else
				str[#str + 1] = "_"
			end
		end
	end
	return table_concat(str)
end,

getTerm = function(surf)
	local term, backcolor, textcolor = { }, colors.black, colors.white
	function term.write(str)
		surf:drawText(surf.curX, surf.curY, tostring(str), backcolor, textcolor)
		surf.curX = surf.curX + #tostring(str)
	end
	function term.blit(str, text, back)
		for i=1,#str do
			if surf.curX >= surf.x1 and surf.curY >= surf.y1 and surf.curX <= surf.x2 and surf.curY <= surf.y2 then
				surf.buffer[((surf.curY - 1) * surf.width + surf.curX) * 3 - 2] = str:sub(i, i)
				surf.buffer[((surf.curY - 1) * surf.width + surf.curX) * 3 - 1] = 2 ^ tonumber(back:sub(i, i), 16)
				surf.buffer[((surf.curY - 1) * surf.width + surf.curX) * 3] = 2 ^ tonumber(text:sub(i, i), 16)
			end
			surf.curX = surf.curX + 1
		end
	end
	function term.clear()
		surf:clear(" ", backcolor, textcolor)
	end
	function term.clearLine(n)
		surf:drawHLine(surf.x1, surf.x2, surf.curY, " ", backcolor, textcolor)
	end
	function term.getCursorPos()
		return surf.curX, surf.curY
	end
	function term.setCursorPos(x, y)
		surf.curX, surf.curY = math_floor(x), math_floor(y)
	end
	function term.setCursorBlink(blink)
		surf.blink = blink
	end
	function term.isColor()
		return true
	end
	term.isColour = term.isColor
	function term.setTextColor(color)
		textcolor = color
	end
	term.setTextColour = term.setTextColor
	function term.setBackgroundColor(color)
		backcolor = color
	end
	term.setBackgroundColour = term.setBackgroundColor
	function term.getSize()
		return surf.width, surf.height
	end
	function term.scroll(n)
		surf:shift(0, -n)
	end
	function term.getTextColor()
		return textcolor
	end
	term.getTextColour = term.getTextColor
	function term.getBackgroundColor()
		return backcolor
	end
	term.getBackgroundColour = term.getBackgroundColor
	return term
end,

render = function(surf, display, x, y, sx1, sy1, sx2, sy2)
	display, x, y, sx1, sy1, sx2, sy2 = display or term, x or 1, y or 1, sx1 or 1, sy1 or 1, sx2 or surf.width, sy2 or surf.height
	if sx1 > sx2 then
		local temp = sx1
		sx1, sx2 = sx2, temp
	end
	if sy1 > sy2 then
		local temp = sy1
		sy1, sy2 = sy2, temp
	end
	if sx2 < 1 or sx1 > surf.width or sy2 < 1 or sy1 > surf.height then return end
	if sx1 < 1 then sx1 = 1 end
	if sx2 > surf.width then sx2 = surf.width end
	if sy1 < 1 then sy1 = 1 end
	if sy2 > surf.height then sy2 = surf.height end
	local cmd = { }
	if display.blit then
		local str, back, text = { }, { }, { }
		for j=sy1,sy2 do
			for i=sx1,sx2 do
				str[i - sx1 + 1] = surf.buffer[((j - 1) * surf.width + i) * 3 - 2] or " "
				back[i - sx1 + 1] = _colors[surf.buffer[((j - 1) * surf.width + i) * 3 - 1] or 32768]
				text[i - sx1 + 1] = _colors[surf.buffer[((j - 1) * surf.width + i) * 3] or 1]
			end
			cmd[#cmd + 1] = y + j - sy1
			cmd[#cmd + 1] = table_concat(str)
			cmd[#cmd + 1] = table_concat(text)
			cmd[#cmd + 1] = table_concat(back)
		end
		for i=1,#cmd,4 do
			display.setCursorPos(x, cmd[i])
			display.blit(cmd[i + 1], cmd[i + 2], cmd[i + 3])
		end
	else
		local str, backcolor, textcolor, backc, textc = "", 0, 0
		for j=sy1,sy2 do
			cmd[#cmd + 1] = 1
			cmd[#cmd + 1] = y + j - sy1
			for i=sx1,sx2 do
				backc, textc = (surf.buffer[((j - 1) * surf.width + i) * 3 - 1] or 32768), (surf.buffer[((j - 1) * surf.width + i) * 3] or 1)
				if backc ~= backcolor then
					backcolor = backc
					if str ~= "" then
						cmd[#cmd + 1] = 4
						cmd[#cmd + 1] = str
						str = ""
					end
					cmd[#cmd + 1] = 2
					cmd[#cmd + 1] = backcolor
				end
				if textc ~= textcolor then
					textcolor = textc
					if str ~= "" then
						cmd[#cmd + 1] = 4
						cmd[#cmd + 1] = str
						str = ""
					end
					cmd[#cmd + 1] = 3
					cmd[#cmd + 1] = textcolor
				end
				str = str..(surf.buffer[((j - 1) * surf.width + i) * 3 - 2] or " ")
			end
			cmd[#cmd + 1] = 4
			cmd[#cmd + 1] = str
			str = ""
		end
		local c, a = nil
		for i=1,#cmd,2 do
			c, a = cmd[i], cmd[i + 1]
			if c == 1 then
				display.setCursorPos(x, a)
			elseif c == 2 then
				display.setBackgroundColor(a)
			elseif c == 3 then
				display.setTextColor(a)
			else
				display.write(a)
			end
		end
	end
	if surf.blink and surf.curX >= 1 and surf.curY >= 1 and surf.curX <= surf.width and surf.curY <= surf.height then
		display.setCursorPos(x + surf.curX - sx1, y + surf.curY - sy1)
		display.setCursorBlink(true)
	elseif surf.blink == false then
		display.setCursorBlink(false)
		surf.blink = nil
	end
	return #cmd / 2
end,

clear = function(surf, char, backcolor, textcolor)
	local overwrite = surf.overwrite
	surf.overwrite = true
	surf:fillRect(surf.x1, surf.y1, surf.x2, surf.y2, char, backcolor, textcolor)
	surf.overwrite = overwrite
end,

drawPixel = function(surf, x, y, char, backcolor, textcolor)
	if x < surf.x1 or y < surf.y1 or x > surf.x2 or y > surf.y2 then return end
	if char or surf.overwrite then
		surf.buffer[((y - 1) * surf.width + x) * 3 - 2] = char
	end
	if backcolor or surf.overwrite then
		surf.buffer[((y - 1) * surf.width + x) * 3 - 1] = backcolor
	end
	if textcolor or surf.overwrite then
		surf.buffer[((y - 1) * surf.width + x) * 3] = textcolor
	end
end,

getPixel = function(surf, x, y)
	if x < 1 or y < 1 or x > surf.width or y > surf.height then return end
	return surf.buffer[((y - 1) * surf.width + x) * 3 - 2], surf.buffer[((y - 1) * surf.width + x) * 3 - 1], surf.buffer[((y - 1) * surf.width + x) * 3]
end,

drawText = function(surf, x, y, text, backcolor, textcolor)
	local px = x
	for i=1,#text do
		if text:sub(i, i) ~= "\n" then
			if x >= surf.x1 and y >= surf.y1 and x <= surf.x2 and y <= surf.y2 then
				surf.buffer[((y - 1) * surf.width + x) * 3 - 2] = text:sub(i, i)
				if backcolor or surf.overwrite then
					surf.buffer[((y - 1) * surf.width + x) * 3 - 1] = backcolor
				end
				if textcolor or surf.overwrite then
					surf.buffer[((y - 1) * surf.width + x) * 3] = textcolor
				end
			end
		else
			x = px - 1
			y = y + 1
		end
		x = x + 1
	end
end,

drawLine = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	local delta_x = x2 - x1
	local ix = delta_x > 0 and 1 or -1
	delta_x = 2 * math.abs(delta_x)
	local delta_y = y2 - y1
	local iy = delta_y > 0 and 1 or -1
	delta_y = 2 * math.abs(delta_y)
	surf:drawPixel(x1, y1, char, backcolor, textcolor)
	if delta_x >= delta_y then
		local error = delta_y - delta_x / 2
		while x1 ~= x2 do
			if (error >= 0) and ((error ~= 0) or (ix > 0)) then
				error = error - delta_x
				y1 = y1 + iy
			end
			error = error + delta_y
			x1 = x1 + ix
			surf:drawPixel(x1, y1, char, backcolor, textcolor)
		end
	else
		local error = delta_x - delta_y / 2
		while y1 ~= y2 do
			if (error >= 0) and ((error ~= 0) or (iy > 0)) then
				error = error - delta_y
				x1 = x1 + ix
			end
			error = error + delta_x
			y1 = y1 + iy
			surf:drawPixel(x1, y1, char, backcolor, textcolor)
		end
	end
end,

drawLines = function(surf, points, mode, char, backcolor, textcolor)
	mode = mode or 1
	if mode == 1 then
		for i=1,#points,4 do
			surf:drawLine(points[i], points[i+1], points[i+2], points[i+3], char, backcolor, textcolor)
		end
	elseif mode == 2 then
		local lastx, lasty = points[1], points[2]
		for i=3,#points,2 do
			local curx, cury = points[i], points[i+1]
			surf:drawLine(lastx, lasty, curx, cury, char, backcolor, textcolor)
			lastx = curx
			lasty = cury
		end
	elseif mode == 3 then
		local midx, midy = points[1], points[2]
		for i=3,#points,2 do
			surf:drawLine(midx, midy, points[i], points[i+1], char, backcolor, textcolor)
		end
	end
end,

drawHLine = function(surf, x1, x2, y, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y < surf.y1 or y > surf.y2 or x2 < surf.x1 or x1 > surf.x2 then return end
	if x1 < surf.x1 then x1 = surf.x1 end
	if x2 > surf.x2 then x2 = surf.x2 end
	if char or surf.overwrite then
		for x=x1,x2 do
			surf.buffer[((y - 1) * surf.width + x) * 3 - 2] = char
		end
	end
	if backcolor or surf.overwrite then
		for x=x1,x2 do
			surf.buffer[((y - 1) * surf.width + x) * 3 - 1] = backcolor
		end
	end
	if textcolor or surf.overwrite then
		for x=x1,x2 do
			surf.buffer[((y - 1) * surf.width + x) * 3] = textcolor
		end
	end
end,

drawVLine = function(surf, y1, y2, x, char, backcolor, textcolor)
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x < surf.x1 or x > surf.x2 or y2 < surf.y1 or y1 > surf.y2 then return end
	if y1 < surf.y1 then y1 = surf.y1 end
	if y2 > surf.y2 then y2 = surf.y2 end
	if char or surf.overwrite then
		for y=y1,y2 do
			surf.buffer[((y - 1) * surf.width + x) * 3 - 2] = char
		end
	end
	if backcolor or surf.overwrite then
		for y=y1,y2 do
			surf.buffer[((y - 1) * surf.width + x) * 3 - 1] = backcolor
		end
	end
	if textcolor or surf.overwrite then
		for y=y1,y2 do
			surf.buffer[((y - 1) * surf.width + x) * 3] = textcolor
		end
	end
end,

drawRect = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	surf:drawHLine(x1, x2, y1, char, backcolor, textcolor)
	surf:drawHLine(x1, x2, y2, char, backcolor, textcolor)
	surf:drawVLine(y1, y2, x1, char, backcolor, textcolor)
	surf:drawVLine(y1, y2, x2, char, backcolor, textcolor)
end,

drawRoundRect = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	surf:drawHLine(x1 + 1, x2 - 1, y1, char, backcolor, textcolor)
	surf:drawHLine(x1 + 1, x2 - 1, y2, char, backcolor, textcolor)
	surf:drawVLine(y1 + 1, y2 - 1, x1, char, backcolor, textcolor)
	surf:drawVLine(y1 + 1, y2 - 1, x2, char, backcolor, textcolor)
end,

drawRoundedRect = function(surf, x1, y1, x2, y2, radius, char, backcolor, textcolor)
	surf:drawHLine(x1 + radius, x2 - radius, y1, char, backcolor, textcolor)
	surf:drawHLine(x1 + radius, x2 - radius, y2, char, backcolor, textcolor)
	surf:drawVLine(y1 + radius, y2 - radius, x1, char, backcolor, textcolor)
	surf:drawVLine(y1 + radius, y2 - radius, x2, char, backcolor, textcolor)
	surf:drawArc(x1, y1, x1 + radius * 2 + 2, y1 + radius * 2 + 2, -math.pi, -math.pi / 2, char, backcolor, textcolor)
	surf:drawArc(x2, y1, x2 - radius * 2 - 2, y1 + radius * 2 + 2, 0, -math.pi / 2, char, backcolor, textcolor)
	surf:drawArc(x1, y2, x1 + radius * 2 + 2, y2 - radius * 2 - 2, math.pi, math.pi / 2, char, backcolor, textcolor)
	surf:drawArc(x2, y2, x2 - radius * 2 - 2, y2 - radius * 2 - 2, 0, math.pi / 2, char, backcolor, textcolor)
end,

fillRect = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x2 < surf.x1 or x1 > surf.x2 or y2 < surf.y1 or y1 > surf.y2 then return end
	if x1 < surf.x1 then x1 = surf.x1 end
	if x2 > surf.x2 then x2 = surf.x2 end
	if y1 < surf.y1 then y1 = surf.y1 end
	if y2 > surf.y2 then y2 = surf.y2 end
	if char or surf.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				surf.buffer[((y - 1) * surf.width + x) * 3 - 2] = char
			end
		end
	end
	if backcolor or surf.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				surf.buffer[((y - 1) * surf.width + x) * 3 - 1] = backcolor
			end
		end
	end
	if textcolor or surf.overwrite then
		for y=y1,y2 do
			for x=x1,x2 do
				surf.buffer[((y - 1) * surf.width + x) * 3] = textcolor
			end
		end
	end
end,

fillRoundRect = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	surf:drawHLine(x1 + 1, x2 - 1, y1, char, backcolor, textcolor)
	surf:drawHLine(x1 + 1, x2 - 1, y2, char, backcolor, textcolor)
	surf:drawVLine(y1 + 1, y2 - 1, x1, char, backcolor, textcolor)
	surf:drawVLine(y1 + 1, y2 - 1, x2, char, backcolor, textcolor)
	surf:fillRect(x1 + 1, y1 + 1, x2 - 1, y2 - 1, char, backcolor, textcolor)
end,

fillRoundedRect = function(surf, x1, y1, x2, y2, radius, char, backcolor, textcolor)
	surf:fillRect(x1 + radius, y1, x2 - radius, y2, char, backcolor, textcolor)
	surf:fillRect(x1, y1 + radius, x1 + radius, y2 - radius, char, backcolor, textcolor)
	surf:fillRect(x2 - radius, y1 + radius, x2, y2 - radius, char, backcolor, textcolor)
	surf:fillPie(x1, y1, x1 + radius * 2 + 2, y1 + radius * 2 + 2, -math.pi, -math.pi / 2, char, backcolor, textcolor)
	surf:fillPie(x2, y1, x2 - radius * 2 - 2, y1 + radius * 2 + 2, 0, -math.pi / 2, char, backcolor, textcolor)
	surf:fillPie(x1, y2, x1 + radius * 2 + 2, y2 - radius * 2 - 2, math.pi, math.pi / 2, char, backcolor, textcolor)
	surf:fillPie(x2, y2, x2 - radius * 2 - 2, y2 - radius * 2 - 2, 0, math.pi / 2, char, backcolor, textcolor)
end,

drawTriangle = function(surf, x1, y1, x2, y2, x3, y3, char, backcolor, textcolor)
	surf:drawLine(x1, y1, x2, y2, char, backcolor, textcolor)
	surf:drawLine(x2, y2, x3, y3, char, backcolor, textcolor)
	surf:drawLine(x3, y3, x1, y1, char, backcolor, textcolor)
end,

fillTriangle = function(surf, x1, y1, x2, y2, x3, y3, char, backcolor, textcolor)
	local minX, minY, maxX, maxY = x1, y1, x1, y1
	if x2 < minX then minX = x2 end
	if x3 < minX then minX = x3 end
	if y2 < minY then minY = y2 end
	if y3 < minY then minY = y3 end
	if x2 > maxX then maxX = x2 end
	if x3 > maxX then maxX = x3 end
	if y2 > maxY then maxY = y2 end
	if y3 > maxY then maxY = y3 end
	local width, height, buffer, min, max = maxX - minX + 1, maxY - minY + 1, { }, 0, 0
	_bufferLine(buffer, width, x1 - minX + 1, y1 - minY + 1, x2 - minX + 1, y2 - minY + 1)
	_bufferLine(buffer, width, x2 - minX + 1, y2 - minY + 1, x3 - minX + 1, y3 - minY + 1)
	_bufferLine(buffer, width, x3 - minX + 1, y3 - minY + 1, x1 - minX + 1, y1 - minY + 1)
	for j=1,height do
		min, max = nil
		for i=1,width do
			if buffer[(j - 1) * width + i] then
				if not min then min = i end
				max = i
			end
		end
		surf:drawHLine(min + minX - 1, max + minX - 1, j + minY - 1, char, backcolor, textcolor)
	end
end,

drawTriangles = function(surf, points, mode, char, backcolor, textcolor)
	mode = mode or 1
	if mode == 1 then
		for i=1,#points,6 do
			surf:drawTriangle(points[i], points[i+1], points[i+2], points[i+3], points[i+4], points[i+5], char, backcolor, textcolor)
		end
	elseif mode == 2 then
		local lastx, lasty, prevx, prevy, curx, cury = points[1], points[2], points[3], points[4]
		for i=5,#points,2 do
			curx, cury = points[i], points[i+1]
			surf:drawTriangle(lastx, lasty, prevx, prevy, curx, cury, char, backcolor, textcolor)
			lastx, lasty, prevx, prevy = prevx, prevy, curx, cury
		end
	elseif mode == 3 then
		local midx, midy, lastx, lasty, curx, cury = points[1], points[2], points[3], points[4]
		for i=5,#points,2 do
			curx, cury = points[i], points[i+1]
			surf:drawTriangle(midx, midy, lastx, lasty, curx, cury, char, backcolor, textcolor)
			lastx, lasty = curx, cury
		end
	end
end,

fillTriangles = function(surf, points, mode, char, backcolor, textcolor)
	mode = mode or 1
	if mode == 1 then
		for i=1,#points,6 do
			surf:fillTriangle(points[i], points[i+1], points[i+2], points[i+3], points[i+4], points[i+5], char, backcolor, textcolor)
		end
	elseif mode == 2 then
		local lastx, lasty, prevx, prevy, curx, cury = points[1], points[2], points[3], points[4]
		for i=5,#points,2 do
			curx, cury = points[i], points[i+1]
			surf:fillTriangle(lastx, lasty, prevx, prevy, curx, cury, char, backcolor, textcolor)
			lastx, lasty, prevx, prevy = prevx, prevy, curx, cury
		end
	elseif mode == 3 then
		local midx, midy, lastx, lasty, curx, cury = points[1], points[2], points[3], points[4]
		for i=5,#points,2 do
			curx, cury = points[i], points[i+1]
			surf:fillTriangle(midx, midy, lastx, lasty, curx, cury, char, backcolor, textcolor)
			lastx, lasty = curx, cury
		end
	end
end,

drawEllipse = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	local step, midX, midY, width, height, lastX, lastY = (math.pi * 2) / 16, (x1 + x2) / 2, (y1 + y2) / 2, (x2 - x1) / 2, (y2 - y1) / 2, 1, 1
	for i=1,17 do
		local x, y = math_floor((midX + math_cos(step * i) * width) + 0.5), math_floor((midY + math_sin(step * i) * height) + 0.5)
		if i > 1 then
			surf:drawLine(lastX, lastY, x, y, char, backcolor, textcolor)
		end
		lastX, lastY = x, y
	end
end,

fillEllipse = function(surf, x1, y1, x2, y2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	local resolution, step, midX, midY, width, height, lastX, lastY, bwidth, bheight, buffer = 16, (math.pi * 2) / 16, (x1 + x2) / 2, (y1 + y2) / 2, (x2 - x1) / 2, (y2 - y1) / 2, 1, 1, x2 - x1 + 1, y2 - y1 + 1, { }
	for i=1,resolution+1 do
		local x, y = math_floor((midX + math_cos(step * i) * width) + 0.5), math_floor((midY + math_sin(step * i) * height) + 0.5)
		if i > 1 then
			_bufferLine(buffer, bwidth, lastX - x1 + 1, lastY - y1 + 1, x - x1 + 1, y - y1 + 1)
		end
		lastX, lastY = x, y
	end
	for j=1,bheight do
		min, max = nil
		for i=1,bwidth do
			if buffer[(j - 1) * bwidth + i] then
				if not min then min = i end
				max = i
			end
		end
		surf:drawHLine(min + x1 - 1, max + x1 - 1, j + y1 - 1, char, backcolor, textcolor)
	end
end,

drawArc = function(surf, x1, y1, x2, y2, a1, a2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if a1 > a2 then
		local temp = a1
		a1, a2 = a2, temp
	end
	local step, midX, midY, width, height, lastX, lastY = (a2 - a1) / 16, (x1 + x2) / 2, (y1 + y2) / 2, (x2 - x1) / 2, (y2 - y1) / 2, 1, 1
	for i=1,17 do
		local x, y = math_floor((midX + math_cos(step * (i - 1) + a1) * width) + 0.5), math_floor((midY - math_sin(step * (i - 1) + a1) * height) + 0.5)
		if i > 1 then
			surf:drawLine(lastX, lastY, x, y, char, backcolor, textcolor)
		end
		lastX, lastY = x, y
	end
end,

drawPie = function(surf, x1, y1, x2, y2, a1, a2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if a1 > a2 then
		local temp = a1
		a1, a2 = a2, temp
	end
	local step, midX, midY, width, height, lastX, lastY = (a2 - a1) / 16, (x1 + x2) / 2, (y1 + y2) / 2, (x2 - x1) / 2, (y2 - y1) / 2, 1, 1
	for i=1,17 do
		local x, y = math_floor((midX + math_cos(step * (i - 1) + a1) * width) + 0.5), math_floor((midY - math_sin(step * (i - 1) + a1) * height) + 0.5)
		if i > 1 then
			surf:drawLine(lastX, lastY, x, y, char, backcolor, textcolor)
		end
		lastX, lastY = x, y
	end
	surf:drawLine(math_floor(midX + 0.5), math_floor(midY + 0.5), math_floor((midX + math_cos(a1) * width) + 0.5), math_floor((midY - math_sin(a1) * height) + 0.5), char, backcolor, textcolor)
	surf:drawLine(math_floor(midX + 0.5), math_floor(midY + 0.5), math_floor((midX + math_cos(a2) * width) + 0.5), math_floor((midY - math_sin(a2) * height) + 0.5), char, backcolor, textcolor)
end,

fillPie = function(surf, x1, y1, x2, y2, a1, a2, char, backcolor, textcolor)
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if a1 > a2 then
		local temp = a1
		a1, a2 = a2, temp
	end
	local step, midX, midY, width, height, lastX, lastY, bwidth, bheight, buffer = (a2 - a1) / 16, (x1 + x2) / 2, (y1 + y2) / 2, (x2 - x1) / 2, (y2 - y1) / 2, 1, 1, x2 - x1 + 1, y2 - y1 + 1, { }
	for i=1,17 do
		local x, y = math_floor((midX + math_cos(step * (i - 1) + a1) * width) + 0.5), math_floor((midY - math_sin(step * (i - 1) + a1) * height) + 0.5)
		if i > 1 then
			_bufferLine(buffer, bwidth, lastX - x1 + 1, lastY - y1 + 1, x - x1 + 1, y - y1 + 1)
		end
		lastX, lastY = x, y
	end
	_bufferLine(buffer, bwidth, math_floor(midX + 0.5) - x1 + 1, math_floor(midY + 0.5) - y1 + 1, math_floor((midX + math_cos(a1) * width) + 0.5) - x1 + 1, math_floor((midY - math_sin(a1) * height) + 0.5) - y1 + 1)
	_bufferLine(buffer, bwidth, math_floor(midX + 0.5) - x1 + 1, math_floor(midY + 0.5) - y1 + 1, math_floor((midX + math_cos(a2) * width) + 0.5) - x1 + 1, math_floor((midY - math_sin(a2) * height) + 0.5) - y1 + 1)
	for j=1,bheight do
		min, max = nil
		for i=1,bwidth do
			if buffer[(j - 1) * bwidth + i] then
				if not min then min = i end
				max = i
			end
		end
		if min then
			surf:drawHLine(min + x1 - 1, max + x1 - 1, j + y1 - 1, char, backcolor, textcolor)
		end
	end
end,

floodFill = function(surf, x, y, char, backcolor, textcolor)
	if x < surf.x1 or y < surf.y1 or x > surf.x2 or y > surf.y2 then return end
	local stack, tchar, tbackcolor, ttextcolor = { x, y }, surf.buffer[((y - 1) * surf.width + x) * 3 - 2], surf.buffer[((y - 1) * surf.width + x) * 3 - 1], surf.buffer[((y - 1) * surf.width + x) * 3]
	if (tchar == char) and (tbackcolor == backcolor) and (ttextcolor == textcolor) then return end
	while #stack > 0 do
		local cx, cy = stack[#stack - 1], stack[#stack]
		stack[#stack] = nil
		stack[#stack] = nil
		if cx >= surf.x1 and cy >= surf.y1 and cx <= surf.x2 and cy <= surf.y2 then
			local cchar, cbackcolor, ctextcolor = surf.buffer[((cy - 1) * surf.width + cx) * 3 - 2], surf.buffer[((cy - 1) * surf.width + cx) * 3 - 1], surf.buffer[((cy - 1) * surf.width + cx) * 3]
			if (tchar == cchar) and (tbackcolor == cbackcolor) and (ttextcolor == ctextcolor) then
				if char or surf.overwrite then
					surf.buffer[((cy - 1) * surf.width + cx) * 3 - 2] = char
				end
				if backcolor or surf.overwrite then
					surf.buffer[((cy - 1) * surf.width + cx) * 3 - 1] = backcolor
				end
				if textcolor or surf.overwrite then
					surf.buffer[((cy - 1) * surf.width + cx) * 3] = textcolor
				end
				stack[#stack + 1] = cx - 1
				stack[#stack + 1] = cy
				stack[#stack + 1] = cx + 1
				stack[#stack + 1] = cy
				stack[#stack + 1] = cx
				stack[#stack + 1] = cy - 1
				stack[#stack + 1] = cx
				stack[#stack + 1] = cy + 1
			end
		end
	end
end,

drawSurface = function(surf, x, y, surf2)
	for j=1,surf2.height do
		for i=1,surf2.width do
			surf:drawPixel(i + x - 1, j + y - 1, surf2.buffer[((j - 1) * surf2.width + i) * 3 - 2], surf2.buffer[((j - 1) * surf2.width + i) * 3 - 1], surf2.buffer[((j - 1) * surf2.width + i) * 3])
		end
	end
end,

drawSurfacePart = function(surf, x, y, sx1, sy1, sx2, sy2, surf2)
	if sx1 > sx2 then
		local temp = sx1
		sx1, sx2 = sx2, temp
	end
	if sy1 > sy2 then
		local temp = sy1
		sy1, sy2 = sy2, temp
	end
	if sx2 < 1 or sx1 > surf2.width or sy2 < 1 or sy1 > surf2.height then return end
	if sx1 < 1 then sx1 = 1 end
	if sx2 > surf2.width then sx2 = surf2.width end
	if sy1 < 1 then sy1 = 1 end
	if sy2 > surf2.height then sy2 = surf2.height end
	for j=sy1,sy2 do
		for i=sx1,sx2 do
			surf:drawPixel(x + i - sx1, y + j - sy1, surf2.buffer[((j - 1) * surf2.width + i) * 3 - 2], surf2.buffer[((j - 1) * surf2.width + i) * 3 - 1], surf2.buffer[((j - 1) * surf2.width + i) * 3])
		end
	end
end,

drawSurfaceScaled = function(surf, x1, y1, x2, y2, surf2)
	local x, width, xinv, y, height, yinv = 0, 0, false, 0, 0, false
	if x1 <= x2 then
		x = x1
		width = x2 - x1 + 1
	else
		x = x2
		width = x1 - x2 + 1
		xinv = true
	end
	if y1 <= y2 then
		y = y1
		height = y2 - y1 + 1
	else
		y = y2
		height = y1 - y2 + 1
		yinv = true
	end
	local xscale, yscale, px, py = width / surf2.width, height / surf2.height
	for j=1,height do
		for i=1,width do
			if xinv then
				px = math_floor((width - i + 0.5) / xscale) + 1
			else
				px = math_floor((i - 0.5) / xscale) + 1
			end
			if yinv then
				py = math_floor((height - j + 0.5) / yscale) + 1
			else
				py = math_floor((j - 0.5) / yscale) + 1
			end
			surf:drawPixel(x + i - 1, y + j - 1, surf2.buffer[((py - 1) * surf2.width + px) * 3 - 2], surf2.buffer[((py - 1) * surf2.width + px) * 3 - 1], surf2.buffer[((py - 1) * surf2.width + px) * 3])
		end
	end
end,

drawSurfaceRotated = function(surf, x, y, ox, oy, angle, surf2)
	local cos, sin, range = math_cos(angle), math_sin(angle), math_floor(math.sqrt(surf2.width * surf2.width + surf2.height * surf2.height))
	x, y = x - math_floor(cos * (ox - 1) + sin * (oy - 1) + 0.5), y - math_floor(cos * (oy - 1) - sin * (ox - 1) + 0.5)
	for j=-range,range do
		for i=-range,range do
			local sx, sy = math_floor(i * cos - j * sin), math_floor(i * sin + j * cos)
			if sx >= 0 and sx < surf2.width and sy >= 0 and sy < surf2.height then
				surf:drawPixel(x + i, y + j, surf2.buffer[(sy * surf2.width + sx) * 3 + 1], surf2.buffer[(sy * surf2.width + sx) * 3 + 2], surf2.buffer[(sy * surf2.width + sx) * 3 + 3])
			end
		end
	end
end,

shader = function(surf, f, x1, y1, x2, y2)
	x1, y1, x2, y2 = x1 or surf.x1, y1 or surf.y1, x2 or surf.x2, y2 or surf.y2
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x2 < surf.x1 or x1 > surf.x2 or y2 < surf.y1 or y1 > surf.y2 then return end
	if x1 < surf.x1 then x1 = surf.x1 end
	if x2 > surf.x2 then x2 = surf.x2 end
	if y1 < surf.y1 then y1 = surf.y1 end
	if y2 > surf.y2 then y2 = surf.y2 end
	local width, buffer = x2 - x1 + 1, { }
	for j=y1,y2 do
		for i=x1,x2 do
			buffer[((j - y1) * width + i - x1) * 3 + 1], buffer[((j - y1) * width + i - x1) * 3 + 2], buffer[((j - y1) * width + i - x1) * 3 + 3] = f(surf.buffer[((j - 1) * surf.width + i) * 3 - 2], surf.buffer[((j - 1) * surf.width + i) * 3 - 1], surf.buffer[((j - 1) * surf.width + i) * 3], i, j)
		end
	end
	for j=y1,y2 do
		for i=x1,x2 do
			surf.buffer[((j - 1) * surf.width + i) * 3 - 2], surf.buffer[((j - 1) * surf.width + i) * 3 - 1], surf.buffer[((j - 1) * surf.width + i) * 3] = buffer[((j - y1) * width + i - x1) * 3 + 1], buffer[((j - y1) * width + i - x1) * 3 + 2], buffer[((j - y1) * width + i - x1) * 3 + 3]
		end
	end
end,

shift = function(surf, x, y, x1, y1, x2, y2)
	x1, y1, x2, y2 = x1 or surf.x1, y1 or surf.y1, x2 or surf.x2, y2 or surf.y2
	if x1 > x2 then
		local temp = x1
		x1, x2 = x2, temp
	end
	if y1 > y2 then
		local temp = y1
		y1, y2 = y2, temp
	end
	if x2 < surf.x1 or x1 > surf.x2 or y2 < surf.y1 or y1 > surf.y2 then return end
	if x1 < surf.x1 then x1 = surf.x1 end
	if x2 > surf.x2 then x2 = surf.x2 end
	if y1 < surf.y1 then y1 = surf.y1 end
	if y2 > surf.y2 then y2 = surf.y2 end
	local width, buffer = x2 - x1 + 1, { }
	for j=y1,y2 do
		for i=x1,x2 do
			if i - x >= 1 and j - y >= 1 and i - x <= surf.width and j - y <= surf.height then
				buffer[((j - y1) * width + i - x1) * 3 + 1], buffer[((j - y1) * width + i - x1) * 3 + 2], buffer[((j - y1) * width + i - x1) * 3 + 3] = surf.buffer[((j - y - 1) * surf.width + i - x) * 3 - 2], surf.buffer[((j - y - 1) * surf.width + i - x) * 3 - 1], surf.buffer[((j - y - 1) * surf.width + i - x) * 3]
			end
		end
	end
	for j=y1,y2 do
		for i=x1,x2 do
			surf.buffer[((j - 1) * surf.width + i) * 3 - 2], surf.buffer[((j - 1) * surf.width + i) * 3 - 1], surf.buffer[((j - 1) * surf.width + i) * 3] = buffer[((j - y1) * width + i - x1) * 3 + 1], buffer[((j - y1) * width + i - x1) * 3 + 2], buffer[((j - y1) * width + i - x1) * 3 + 3]
		end
	end
end
}

function create(width, height, char, backcolor, textcolor)
	local surf = { }
	for k,v in pairs(_functions) do
		surf[k] = v
	end
	surf.width, surf.height, surf.x1, surf.y1, surf.x2, surf.y2, surf.curX, surf.curY, surf.overwrite, surf.buffer = width, height, 1, 1, width, height, 1, 1, false, { }
	if char then
		for i=1,width * height do
			surf.buffer[i * 3 - 2] = char
		end
	end
	if backcolor then
		for i=1,width * height do
			surf.buffer[i * 3 - 1] = backcolor
		end
	end
	if textcolor then
		for i=1,width * height do
			surf.buffer[i * 3] = textcolor
		end
	end
	return surf
end

function load(path)
	local lines, f = { }, fs.open(path, "r")
	for line in f.readLine do
		lines[#lines + 1] = line
	end
	f.close()
	local height = #lines
	if lines[1]:byte(1) == 30 then
		local width, i = 0, 1
		while i <= #lines[1] do
			local char = lines[1]:byte(i)
			if char == 30 or char == 31 then
				i = i + 1
			else
				width = width + 1
			end
			i = i + 1
		end
		local surf, backcolor, textcolor, i, px, char, color = create(width, height)
		for j=1,height do
			i = 1
			px = 1
			while i <= #lines[j] do
				char = lines[j]:byte(i)
				if char == 30 then
					i = i + 1
					char = lines[j]:byte(i)
					color = tonumber(lines[j]:sub(i, i), 16)
					if color then
						backcolor = 2^color
					else
						backcolor = nil
					end
				elseif char == 31 then
					i = i + 1
					char = lines[j]:byte(i)
					color = tonumber(lines[j]:sub(i, i), 16)
					if color then
						textcolor = 2^color
					else
						textcolor = nil
					end
				else
					surf.buffer[((j - 1) * surf.width + px) * 3 - 2] = lines[j]:sub(i, i)
					surf.buffer[((j - 1) * surf.width + px) * 3 - 1] = backcolor
					surf.buffer[((j - 1) * surf.width + px) * 3] = textcolor
					px = px + 1
				end
				i = i + 1
			end
		end
		return surf
	elseif lines[1]:byte(1) == 95 then
		return loadString(lines[1])
	else
		local width = 0
		for i=1,#lines do
			if #lines[i] > width then
				width = #lines[i]
			end
		end
		local surf, color = create(width, height)
		for j=1,height do
			for i=1,width do
				color = tonumber(lines[j]:sub(i, i), 16)
				if color then
					surf.buffer[((j - 1) * surf.width + i) * 3 - 1] = 2 ^ color
				end
			end
		end
		return surf
	end
end

function loadString(str)
	local width, height, n = tonumber(str:sub(2, 5), 16), tonumber(str:sub(6, 9), 16), 10
	local surf = create(width, height)
	for j=1,height do
		for i=1,width do
			if str:byte(n) ~= 95 then
				surf.buffer[((j - 1) * surf.width + i) * 3 - 2] = string.char(tonumber(str:sub(n, n + 1), 16))
			end
			if str:byte(n + 2) ~= 95 then
				surf.buffer[((j - 1) * surf.width + i) * 3 - 1] = 2 ^ tonumber(str:sub(n + 2, n + 2), 16)
			end
			if str:byte(n + 3) ~= 95 then
				surf.buffer[((j - 1) * surf.width + i) * 3] = 2 ^ tonumber(str:sub(n + 3, n + 3), 16)
			end
			n = n + 4
		end
	end
	return surf
end
