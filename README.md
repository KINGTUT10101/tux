## TUX

> **NOTE: This project is no longer being developed in favor of** [**Tux Redux**](https://github.com/KINGTUT10101/TuxRedux)**, a complete remake of Tux/SUIT**

An improved version of SUIT with more components, a better layout system, and a GUI manager. This project will be updated once I finish my current project, Just Another Sand Game.

This library should support most of SUIT's features right now, although that may change in the future as new features are added. Here's a quick overview of the current features and how you can use them (better docs will be provided some time in the future):

*   Padding
    *   Most UI items now support padding, which can shift the internal elements away from the item's edges
    *   Available options: opt.padAll, opt.padX, opt.padY, opt.padLeft, opt.padRight, opt.padTop, opt.padBottom
    *   Lower level options will overwrite higher level ones. For example, setting opt.padAll to 10 and opt.padLeft to 5 will give the left edge 5 pixels of padding and every other edge 10 pixels of padding
*   Improved alignment
    *   Text alignment will now account for the number of lines of text properly. This was mainly an issue when opt.valign was set to "bottom"
*   Icon support
    *   Some UI items (currently labels and buttons) now support icons
    *   Icons will render on the opposite alignment of the text. For example, if opt.align is "top" then the text will be aligned to the top and the image will be aligned to the bottom
    *   Simply set opt.image to a LOVE2D Image object to use this feature
    *   You can also change the image's scale by setting the value of opt.scale
*   Nineslice (ninepatch) support
    *   All UI items now have the option to use nineslices for rendering instead of plain rectangles
    *   Common nineslice libraries should work, such as slicy, patchy, or tangerine. However, any library can work so long as the nineslices are rendered using the method sliceObj:draw (x, y, w, h)
    *   By default, the library will render rectangles if you haven't provided any actual nineslices to the theme. You can set the default nineslices by changing the values of suit.theme.slices. It is a table containing three keys: normal, hovered, and active
    *   Custom nineslices can be provided to individual UI items by setting the value of opt.slices. This should be a table that contains one slice for each state, similar to setting the value of suit.theme.slices
*   Modified color theming
    *   Default colors for rectangle boxes are now stored in suit.theme.rectColor
    *   Default colors for nineslices are now stored in suit.theme.sliceColor
*   Better text input boxes
    *   Input boxes support multiline text
    *   Input boxes are highlighted while the user is typing. This can be disabled by setting opt.highlight to false
*   Automatically generated IDs
    *   IDs are now generated automatically for each UI item you render. This should eliminate the need to assign custom IDs to UI items with the same text
    *   However, you can still assign custom IDs by changing the value of opt.id

## Documentation?

Over at [readthedocs](http://suit.readthedocs.org/en/latest/).

## Looks?

Here is how SUIT looks like with the default theme:

![Demo of all widgets](docs/_static/demo.gif)

More info and code is over at [readthedocs](http://suit.readthedocs.org/en/latest/).

## Hello, World!

```plaintext
-- suit up
local suit = require 'suit'

-- storage for text input
local input = {text = ""}

-- make love use font which support CJK text
function love.load()
    local font = love.graphics.newFont("NotoSansHans-Regular.otf", 20)
    love.graphics.setFont(font)
end

-- all the UI is defined in love.update or functions that are called from here
function love.update(dt)
    -- put the layout origin at position (100,100)
    -- the layout will grow down and to the right from this point
    suit.layout:reset(100,100)

    -- put an input widget at the layout origin, with a cell size of 200 by 30 pixels
    suit.Input(input, suit.layout:row(200,30))

    -- put a label that displays the text below the first cell
    -- the cell size is the same as the last one (200x30 px)
    -- the label text will be aligned to the left
    suit.Label("Hello, "..input.text, {align = "left"}, suit.layout:row())

    -- put an empty cell that has the same size as the last cell (200x30 px)
    suit.layout:row()

    -- put a button of size 200x30 px in the cell below
    -- if the button is pressed, quit the game
    if suit.Button("Close", suit.layout:row()).hit then
        love.event.quit()
    end
end

function love.draw()
    -- draw the gui
    suit.draw()
end

function love.textedited(text, start, length)
    -- for IME input
    suit.textedited(text, start, length)
end

function love.textinput(t)
    -- forward text input to SUIT
    suit.textinput(t)
end

function love.keypressed(key)
    -- forward keypresses to SUIT
    suit.keypressed(key)
end
```
