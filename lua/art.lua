local function getLen(str, start_pos)
	local byte = string.byte(str, start_pos)
	if not byte then
		return nil
	end
	return (byte < 0x80 and 1) or (byte < 0xE0 and 2) or (byte < 0xF0 and 3) or (byte < 0xF8 and 4) or 1
end

local function colorize(header, header_color_map, colors)
	for letter, color in pairs(colors) do
		local color_name = "AlphaJemuelKwelKwelWalangTatay" .. letter
		vim.api.nvim_set_hl(0, color_name, color)
		colors[letter] = color_name
	end

	local colorized = {}

	for i, line in ipairs(header_color_map) do
		local colorized_line = {}
		local pos = 0

		for j = 1, #line do
			local start = pos
			pos = pos + getLen(header[i], start + 1)

			local color_name = colors[line:sub(j, j)]
			if color_name then
				table.insert(colorized_line, { color_name, start, pos })
			end
		end

		table.insert(colorized, colorized_line)
	end

	return colorized
end

local function getArtData(name)
	return require("pixels." .. name)
end

local function duplicate_chars(arr)
	local result = {}
	for i = 1, #arr do
		local new_str = ""
		for j = 1, #arr[i] do
			local char = arr[i]:sub(j, j)
			new_str = new_str .. char .. char
		end
		table.insert(result, new_str)
	end
	return result
end

local function pixels(name, config)
	local color_map
	local colors
	if name == "custom" then
		color_map = config.map
		colors = config.colors
	else
		color_map = getArtData(name).map
		colors = getArtData(name).colors
	end
	color_map = duplicate_chars(color_map)

	local header = {}
	for _, line in ipairs(color_map) do
		local header_line = [[]]
		for i = 1, #line do
			if line:sub(i, i) ~= " " then
				header_line = header_line .. "█"
			else
				header_line = header_line .. " "
			end
		end
		table.insert(header, header_line)
	end

	local colorized = colorize(header, color_map, colors)

	return {
		val = header,
		opts = { hl = colorized, position = "center" },
		type = "text",
	}
end
local M = {}

M.pixels = function(name, config)
	return pixels(name, config)
end

return M
