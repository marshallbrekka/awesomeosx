local window = require "hs.window"
local mouse  = require "hs.mouse"
local events = require "hs.eventtap"
local screen = require "hs.screen"
local etypes = require "hs.eventtap.event"

local windowUnderPoint = function(point)
      local windows = window.orderedWindows()
      for i,v in ipairs(windows) do
          local frame = v:frame()
          if frame.x <= point.x and 
             frame.y <= point.y and
             frame.x + frame.w >= point.x and
             frame.y + frame.h >= point.y then
             return v
           end
      end
end

local windowUnderMouse = function()
      return windowUnderPoint(mouse.get())
end

local focusIfNotFocused = function(window)
      if not(window.focusedWindow == window) then
        window:focus()
      end
end

local _onMouseMove = function()
   local callCount = 0
   return function(event)
          if callCount > 10 then
            callCount = 0
            print "changing focus"
            print(callCount)
            focusIfNotFocused(windowUnderMouse())
          else
            callCount = callCount + 1
          end
   end
end

local watchMouse = function()
      local watcher = events.new({etypes.types.mousemoved}, _onMouseMove())
      watcher:start()
      return watcher
end

local stopWatchMouse = function(watcher)
      watcher:stop()
end

local _moveToScreen = function(window, screen)
   local frame = screen:frame()
   window:setTopLeft({x = frame.x, y = frame.y})
end

local moveToScreen = function(window, screenNumber)
   local screen = screen.allScreens()[screenNumber]:frame()
   _moveToScreen(window, screen)
end

local moveToNextScreen = function(window)
   local screen = window:screen():next()
   _moveToScreen(window, screen)
end

local moveToPreviousScreen = function(window)
   local screen = window:screen():previous()
   _moveToScreen(window, screen)
end

return {
       windowUnderPoint  = windowUnderPoint,
       windowUnderMouse  = windowUnderMouse,
       focusIfNotFocused = focusIfNotFocused,
       watchMouse        = watchMouse,
       stopWatchMouse    = stopWatchMouse,
       moveToScreen      = moveToScreen,
       moveToNextScreen  = moveToNextScreen,
       moveToPreviousScreen  = moveToPreviousScreen,
       focusedWindow     = window.focusedWindow
       }
