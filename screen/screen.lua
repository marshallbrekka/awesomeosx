local window = require "awesomeosx.window.window"
local screen = require "hs.screen"
local mouse  = require "hs.mouse"

local function focusWindowUnderMouse ()
   window.focusIfNotFocused(window.windowUnderMouse())
end

local function focus (screenNumber)
   local screens = screen.allScreens()
   local frame = screens[screenNumber]:frame()
   mouse.set({x = frame.x + 10, y = frame.y + 10})
   focusWindowUnderMouse()
end

return {
   focus = focus
}
