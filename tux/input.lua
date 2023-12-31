-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')
local utf8 = require 'utf8'

local function split(str, pos)
	local offset = utf8.offset(str, pos) or 0
	return str:sub(1, offset-1), str:sub(offset)
end

return function(core, input, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or input
	opt.font = opt.font or love.graphics.getFont()

	local text_width = opt.font:getWidth(input.text)
	w = w or text_width + 6
	h = h or opt.font:getHeight() + 4

	input.text = input.text or ""
	input.cursor = math.max(1, math.min(utf8.len(input.text)+1, input.cursor or utf8.len(input.text)+1))
	-- cursor is position *before* the character (including EOS) i.e. in "hello":
	--   position 1: |hello
	--   position 2: h|ello
	--   ...
	--   position 6: hello|

	-- get size of text and cursor position
	opt.cursor_pos = 0
	if input.cursor > 1 then
		local s = input.text:sub(1, utf8.offset(input.text, input.cursor)-1)
		opt.cursor_pos = opt.font:getWidth(s)
	end

	-- compute drawing offset
	local wm = w - 6 -- consider margin
	input.text_draw_offset = input.text_draw_offset or 0
	if opt.cursor_pos - input.text_draw_offset < 0 then
		-- cursor left of input box
		input.text_draw_offset = opt.cursor_pos
	end
	if opt.cursor_pos - input.text_draw_offset > wm then
		-- cursor right of input box
		input.text_draw_offset = opt.cursor_pos - wm
	end
	if text_width - input.text_draw_offset < wm and text_width > wm then
		-- text bigger than input box, but does not fill it
		input.text_draw_offset = text_width - wm
	end

	-- user interaction
	if input.forcefocus ~= nil and input.forcefocus then
		core.active = opt.id
		input.forcefocus = false
	end

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	opt.hasKeyboardFocus = core:grabKeyboardFocus(opt.id)

	if (core.candidate_text.text == "") and opt.hasKeyboardFocus then
		local keycode,char = core:getPressedKey()
		-- text input
		if char and char ~= "" then
			local a,b = split(input.text, input.cursor)
			input.text = table.concat{a, char, b}
			input.cursor = input.cursor + utf8.len(char)
		end

		-- text editing
		if keycode == 'backspace' then
			local a,b = split(input.text, input.cursor)
			input.text = table.concat{split(a,utf8.len(a)), b}
			input.cursor = math.max(1, input.cursor-1)
		elseif keycode == 'delete' then
			local a,b = split(input.text, input.cursor)
			local _,b = split(b, 2)
			input.text = table.concat{a, b}
		end

		-- cursor movement
		if keycode =='left' then
			input.cursor = math.max(0, input.cursor-1)
		elseif keycode =='right' then -- cursor movement
			input.cursor = math.min(utf8.len(input.text)+1, input.cursor+1)
		elseif keycode =='home' then -- cursor movement
			input.cursor = 1
		elseif keycode =='end' then -- cursor movement
			input.cursor = utf8.len(input.text)+1
		end

		-- Moves the cursor position to the character that the user clicked on
		if core:mouseReleasedOn(opt.id) then
			local mouseX, mouseY = core:getMousePosition()

			local font = core.theme.getFont (opt)
			local fontHeight = font:getHeight ()
			local padLeft, padRight, padTop, padBottom = core.theme.getPadding (opt)

			local paddedWidth = w - padLeft - padRight
			-- Grab the wrapped string to iterate on it row by row
			local _, wrappedString = font:getWrap(input.text, paddedWidth)

			-- Offset the mouse position to find the nearest text row
			local row = math.ceil ((mouseY - padTop - y) / fontHeight)

			local stringToSearch = wrappedString[row]

			if stringToSearch == nil then
				input.cursor = input.text:len () + 1 -- Set to one if the row doesn't contain text yet
			else
				input.cursor = utf8.len(stringToSearch) + 1 -- Max position for the cursor in the given row
				
				-- Iterate through each character in the row to see which one is closest to the cursor
				local lastLength = 0
				for i = 1, input.cursor do
					-- Get the characters up to the cursor position
					local subString = input.text:sub(0, utf8.offset(stringToSearch, i)-1)
					local currentLength = opt.font:getWidth(subString)
					
					if currentLength >= mouseX - x - padLeft then
						-- Round to nearest character
						if (mouseX - x - padLeft - lastLength) / (currentLength - lastLength) > 0.50 then
							input.cursor = i
						else
							input.cursor = i-1
						end
						break
					end

					lastLength = currentLength
				end

				-- Calculate the final position by adding the sum of the characters in the previous rows
				local sum = 0
				for i = 1, row - 1 do
					sum = sum + wrappedString[i]:len ()
				end
				input.cursor = input.cursor + sum
			end
		end
	end

	input.candidate_text = {text=core.candidate_text.text, start=core.candidate_text.start, length=core.candidate_text.length}
	core:registerDraw(opt.draw or core.theme.Input, input, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		submitted = core:keyPressedOn(opt.id, "return"),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
