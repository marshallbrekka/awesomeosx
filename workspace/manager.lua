local screen = require "hs.screen"
local hs_window = require "hs.window"
local screen_watch = require "hs.screen.watcher"
local window_watch = require "awesomeosx.window.watcher"
local window_events = window_watch.events

local WORKSPACES_PER_SCREEN = 9

local workspacesByScreenCount = {}
local screenWatcher = nil
local currentScreens = nil

local _initializing = false;

local function screenToIndex(targetScreen)
   local screens = screen.allScreens()
   for i, s in pairs(screens) do
      if s == targetScreen then
         return i
      end
   end
end

local function makeWorkspacesForSingleScreen(constructorFn, activeWorkspace)
   local workspaces = {}
   local number = 1
   while number <= WORKSPACES_PER_SCREEN do
      workspaces[number] = constructorFn(number)
      number = number + 1
   end
   return {active = activeWorkspace or 1,
           workspaces = workspaces}
end

local function blankWorkspace()
   return {
      -- map of window objects by window id
      windows = {},
      layoutName  = nil,
      -- array of window objects
      windowOrder = {}
   }
end

local function copyWorkspace(workspace)
   local newWorkspace = blankWorkspace()
   for id, win in pairs(workspace.windows) do
      newWorkspace.windows[id] = win
   end
   for index, win in ipairs(workspace.windowOrder) do
      table.insert(newWorkspace.windowOrder, win)
   end
   newWorkspace.layoutName = workspace.layoutName
   return newWorkspace
end

--- Given a table of workspaces keyed by their screen count and
--- a number of screens returns the workspaces
--- for the "nearest" number of screens. Can return nil.
---
--- Nearest is defined as the the smallest delta between
--- the new screen count the existing workspaces for various screen
--- counts. If there are screen counts defined with an equal delta
--- then the lower screen count is prefered.
local function getNearestWorkspaces(existingWorkspaces, screenCount)
   local key = nil
   
   for count, workspaces in pairs(existingWorkspaces) do
      if not key then
         key = count
      else
         local keyDelta = math.abs(screenCount - key)
         local countDelta = math.abs(screenCount - count)
         if countDelta < keyDelta or (countDelta == keyDelta and count < key) then
            key = count
         end
      end
   end
   return existingWorkspaces[key]
end



local function makeWorkspaces(screenCount)
   local workspacesToCopy = nil
   local workspaces = nil
   local screenNumber = 1
   if not workspacesByScreenCount[screenCount] then
      workspacesToCopy = getNearestWorkspaces(workspacesByScreenCount, screenCount) or {}
      workspaces = {}
      print("screen "..screenNumber.." "..screenCount)
      while screenNumber <= screenCount do
         local constructorFn = nil
         local activeWorkspace = 1
         if workspacesToCopy[screenNumber] then
            constructorFn = function(workspaceNumber)
               return copyWorkspace(workspacesToCopy[screenNumber].workspaces[workspaceNumber])
            end
            activeWorkspace = workspacesToCopy[screenNumber].active
         else
            constructorFn = blankWorkspace
         end
         workspaces[screenNumber] = makeWorkspacesForSingleScreen(constructorFn, activeWorkspace)
         screenNumber = screenNumber + 1
      end
      workspacesByScreenCount[screenCount] = workspaces
      return workspaces
   else
      return workspacesByScreenCount[screenCount]
   end
end

local function layoutWorkspace(workspace)
   -- noop for now
   return nil
end

local function layoutWorkspaces(workspaces)
   -- do nothing right now
   for i, workspace in pairs(workspaces) do
      layoutWorkspace(workspace)
   end
end

local function onScreenChange()
   local newScreens = screen.allScreens()
   print("screen change "..#newScreens)
   currentScreens = makeWorkspaces(#newScreens)
   layoutWorkspaces(currentScreens)

end

local function onWindowChange(event, pid, window)
   if event == window_events.open then
      local targetScreen = nil
      if _initializing then
         targetScreen = screenToIndex(window:screen())
         print("add to screen "..targetScreen)
      else
         print "not init"
      end
   end

         
   print(event.." "..pid.." "..window:id())
end


local function init()
   _initializing = true
   local screens = screen.allScreens()
   currentScreens = makeWorkspaces(#screens)
   screenWatcher = screen_watch.new(onScreenChange)
   screenWatcher:start()
   window_watch.start(onWindowChange)
   _initializing = false
end


local function doDebug()
   return workspacesByScreenCount
end

return {
   init = init,
   doDebug = doDebug
}
