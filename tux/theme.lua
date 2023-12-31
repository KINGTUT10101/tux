-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

local theme = {}
theme.cornerRadius = 2

local function drawDefaultSlice (self, x, y, w, h)
	love.graphics.rectangle ("line", x, y, w, h)
end

theme.rectColor = {
	normal   = {bg = {0.25, 0.25, 0.25, 1}, fg = {0.73, 0.73, 0.73, 1}},
	hovered  = {bg = {0.19, 0.6, 0.73, 1}, fg = {1, 1, 1, 1}},
	active   = {bg = {1, 0.6, 0, 1}, fg = {1, 1, 1, 1}}
}

theme.sliceColor = {
	normal   = {bg = {0.75, 0.75, 0.75, 1}, fg = {0.73, 0.73, 0.73, 1}},
	hovered  = {bg = {1, 1, 1, 1}, fg = {1, 1, 1, 1}},
	active   = {bg = {0.55, 0.55, 0.55, 1}, fg = {1, 1, 1, 1}}
}

theme.slices = {
	normal = {
		draw = drawDefaultSlice
	},
	hovered = {
		draw = drawDefaultSlice
	},
	active = {
		draw = drawDefaultSlice
	},
}


--- Returns the color for the given state of type of the UI item.
-- @param opt (table) The UI item's options table
-- @return A table of color values for the foreground and background
function theme.getColorForState(opt)
	local state = opt.state or "normal"
	local colorType = opt.slices == nil and "rectColor" or "sliceColor"
	
	return (opt.color ~= nil and opt.color[state] ~= nil) and opt.color[state] or theme[colorType][state]
end

--- Returns the padding values for a UI item.
-- @param opt (table) The UI item's options table
-- @return (number) The left edge padding
-- @return (number) The right edge padding
-- @return (number) The top edge padding
-- @return (number) The bottom edge padding
function theme.getPadding (opt)
	local padX, padY = opt.padX or 0, opt.padY or 0
	local padLeft, padRight = opt.padLeft or padX, opt.padRight or padX
	local padTop, padBottom = opt.padTop or padY, opt.padBottom or padY

	return padLeft, padRight, padTop, padBottom
end

--- Returns the font to be used for a UI item.
-- @param opt (table) The UI item's options table
-- @return (Font) A font object
function theme.getFont (opt)
	return opt.font or love.graphics.getFont ()
end

--- Renders either a rectangle or a nineslice to the screen.
-- It will default to drawing a rectangle if no slices are defined in the options table.
-- @param x (number) The x position of the box
-- @param y (number) The y position of the box
-- @param w (number) The width of the box
-- @param h (number) The height of the box
-- @param opt (table) A UI item's options table
function theme.drawBox(x, y, w, h, opt)
	local color = theme.getColorForState(opt).bg
	local cornerRadius = opt.cornerRadius or theme.cornerRadius
	
	w = math.max(cornerRadius/2, w)
	if h < cornerRadius/2 then
		y, h = y - (cornerRadius - h), cornerRadius / 2
	end

	love.graphics.setColor(color)

	if opt.slices == nil then
		love.graphics.rectangle(opt.rectMode or "fill", x, y, w, h, cornerRadius)
	else
		-- Defaults to the theme slices if no slices are defined for the current state
		if opt.slices[opt.state] == nil then
			theme.slices[opt.state]:draw (x, y, w, h)
		else
			opt.slices[opt.state]:draw (x, y, w, h)
		end
	end
end

--- Renders text to the screen.
-- @todo Add an option to cut off long long and possiby end them with an ellipses instead
-- @param text (string) The text to be shown
-- @param x (number) The x position of the box
-- @param y (number) The y position of the box
-- @param w (number) The width of the box
-- @param h (number) The height of the box
-- @param opt (table) A UI item's options table
function theme.drawText (text, x, y, w, h, opt)
	text = text or ""
	
	local offsetX, offsetY
	local font = theme.getFont (opt)
	local padLeft, padRight, padTop, padBottom = theme.getPadding (opt)
	local color = theme.getColorForState(opt).fg

	x = x + padLeft
	y = y + padTop
	w = w - (padLeft + padRight)
	h = h - (padTop + padBottom)

	local maxTextWidth, wrappedText = font:getWrap(text, w)
	local fontH = font:getHeight()
	local textH = fontH * #wrappedText

	if textH > h then
		text = ""
		textH = fontH * math.floor (h / fontH)
		for i = 1, math.floor (h / fontH) do
			text = text .. wrappedText[i] .. "\n"
		end
	end

	if opt.valign == "top" then
		offsetY = padTop
	elseif opt.valign == "bottom" then
		offsetY = h - textH - padBottom
	else
		offsetY = (h - textH) / 2
	end
    
	love.graphics.setFont (font)
	love.graphics.setColor (color)
	love.graphics.printf (text, x, y + offsetY, w, opt.align or "center")
end

--- Renders an image to the screen.
-- Images will be rendered opposite of the defined alignment.
-- @param image (Image) The image to be shown
-- @param x (number) The x position of the box
-- @param y (number) The y position of the box
-- @param w (number) The width of the box
-- @param h (number) The height of the box
-- @param opt (table) A UI item's options table
function theme.drawImage (image, x, y, w, h, opt)
	if image ~= nil then
		local offsetX, offsetY
		local padLeft, padRight, padTop, padBottom = theme.getPadding (opt)
		local imageWidth = image:getWidth () * (opt.scale or 1)
		local imageHeight = image:getHeight () * (opt.scale or 1)

		x = x + padLeft
		y = y + padTop
		w = w - (padLeft + padRight)
		h = h - (padTop + padBottom)

		-- Images will render on the opposite side of the text
		if opt.valign == "bottom" then
			offsetY = padTop
		elseif opt.valign == "top" then
			offsetY = h - imageHeight - padBottom
		else
			offsetY = (h - imageHeight) / 2
		end

		if opt.align == "right" then
			offsetX = padLeft
		elseif opt.align == "left" then
			offsetX = w - imageWidth - padRight
		else
			offsetX = (w - imageWidth) / 2
		end
		
		love.graphics.setColor (opt.imageColor or {1, 1, 1, 1})
		love.graphics.draw (opt.image, x + offsetX, y + offsetY, nil, opt.scale, opt.scale)
	end
end

--- A simple box meant to display some content. It does not change appearance.
-- It will always render as if its state is normal.
function theme.Label(text, opt, x,y,w,h)
	opt.state = "normal" -- Prevents the label from changing state

	theme.drawBox(x, y, w, h, opt)
	theme.drawImage (opt.image, x, y, w, h, opt)
	theme.drawText (text, x, y, w, h, opt)
end

function theme.Button(text, opt, x, y, w, h)
	theme.drawBox(x, y, w, h, opt)
	theme.drawImage (opt.image, x, y, w, h, opt)
	theme.drawText (text, x, y, w, h, opt)
end

function theme.Checkbox(chk, opt, x, y, w, h)
	local renderColor = theme.getColorForState(opt)

	theme.drawBox(x+h/10, y+h/10, h*.8, h*.8, opt)

	if chk.checked then
		local origStyle = love.graphics.getLineStyle ()
		local origWidth = love.graphics.getLineWidth ()
		local origJoin = love.graphics.getLineJoin ()

		love.graphics.setLineStyle('smooth')
		love.graphics.setLineWidth(5)
		love.graphics.setLineJoin("bevel")

		love.graphics.setColor (renderColor.fg)
		love.graphics.line(x+h*.2, y+h*.55, x+h*.45, y+h*.75, x+h*.8, y+h*.2)

		love.graphics.setLineStyle(origStyle)
		love.graphics.setLineWidth(origWidth)
		love.graphics.setLineJoin(origJoin)
	end

	if chk.text then
		opt.align = opt.align or "left"
		theme.drawText (chk.text, x, y, w, h, opt)
	end
end

function theme.Slider(fraction, opt, x, y, w, h)
	local xb, yb, wb, hb -- size of the progress bar
	local r =  math.min(w,h) / 2.1
	if opt.vertical then
		x, w = x + w*.25, w*.5
		xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
	else
		y, h = y + h*.25, h*.5
		xb, yb, wb, hb = x,y, w*fraction, h
	end

	theme.drawBox(x,y,w,h, opt)

	local renderColor = theme.getColorForState(opt)
	opt.color = opt.color or {}
	opt.color[opt.state] = {bg=renderColor.fg}
	theme.drawBox(xb, yb, wb, hb, opt)

	if opt.state ~= nil and opt.state ~= "normal" then
		love.graphics.setColor((opt.color and opt.color.active or {}).fg or theme.rectColor.active.fg)
		if opt.vertical then
			love.graphics.circle('fill', x+wb/2, yb, r)
		else
			love.graphics.circle('fill', x+wb, yb+hb/2, r)
		end
	end
end

--- An input box that supports multiline text editing and keyboard navigation.
-- Alignment is ignored and always set to the top-left
-- Set opt.highlight to false to remove the highlight when users are typing in the box
function theme.Input(input, opt, x, y, w, h)
	opt.state = "normal" -- Prevents the label from changing state
	opt.align = "left"
	opt.valign = "top"

	theme.drawBox(x, y, w, h, opt)

	-- text
	opt.align = opt.align or "left"
	theme.drawText (input.text, x, y, w, h, opt)

	-- candidate text
	theme.drawText (input.candidate_text.text, x, y, w, h, opt)
	
	-- candidate text rectangle box
	if opt.hasKeyboardFocus and opt.highlight ~= false then
		local cornerRadius = opt.cornerRadius or theme.cornerRadius
		love.graphics.setColor (theme.getColorForState (opt).fg)
		love.graphics.rectangle ("line", x, y, w, h, cornerRadius)
	end

	-- Cursor rendering
	if opt.hasKeyboardFocus and (love.timer.getTime() % 1) > .5 then
		local font = theme.getFont (opt)
		local fontHeight = font:getHeight ()
		local padLeft, padRight, padTop, padBottom = theme.getPadding (opt)
		local paddedWidth = w - padLeft - padRight

		local cursorText = input.text:sub (1, input.cursor - 1) -- All the text up to the cursor position
		local _, wrappedString = font:getWrap(cursorText, paddedWidth)
		local lastLineWidth = font:getWidth (wrappedString[#wrappedString])

		local offsetX = (lastLineWidth + padLeft)
		local offsetY = (#wrappedString - 1) * fontHeight + padTop

		love.graphics.setColor (theme.getColorForState(opt).fg)
		love.graphics.line(x + offsetX, y + offsetY, x + offsetX, y + offsetY + fontHeight)
	end
end

return theme
