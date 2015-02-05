local screen = require "hs.screen"
local screen_watch = require "hs.screen.watcher"

local workspacesByScreenCount = {}
local screenWatcher = nil
local currentScreens = nil

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
   for win in workspace.windowOrder do
      table.insert(newWorkspace.windowOrder win)
   end
   newWorkspace.layoutName = workspace.layoutName
   return newWorkspace
end

local function getWorkspacesForLessScreens(screenCount)
   if screenCount == 1 workspacesByScreenCount[1] then
      return


local function makeWorkspaces(screenCount)
   
   if not workspacesByScreenCount[screenCount] then
      local screenNumber = 1
      while screenNumber <= screenCount do
         local workspaceCopy = copyWorkspace(
end

local function onScreenChange()
   local newScreens = screen.allScreens()
   local oldScreenCount = #currentScreens
   local newScreenCount = #newScreens

   if oldScreenCount > newScreenCount
     

end
