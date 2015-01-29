local window = require "hs.window"
local mouse  = require "hs.mouse"
local events = require "hs.eventtap"
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

return {
       windowUnderPoint = windowUnderPoint,
       windowUnderMouse = windowUnderMouse,
       focusIfNotFocused = focusIfNotFocused,
       watchMouse = watchMouse,
       stopWatchMouse = stopWatchMouse
       }