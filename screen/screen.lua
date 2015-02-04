window = require "awesomeosx.window.window"
screen = require "hs.screen"
mouse  = require "hs.mouse"

local function focusWindowUnderMouse ()
   window.focusIfNotFocused(window.windowUnderMouse())
end

local function focus (screenNumber)
   local screens = screen.allScreens()
   local frame = screens[screenNumber]:frame()
   mouse.set({x = frame.x, y = frame.y})
   focusWindowUnderMouse()
end

return {
   focus = focus
}
