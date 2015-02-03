local events = hs.uielement.watcher
local application = require "hs.application"

local appsWatcher = nil
local watchers = {}
local windowEventWatcher = nil
local windowEvents = {open   = events.windowCreated,
                      close  = events.elementDestroyed,
                      move   = events.windowMoved,
                      resize = events.windowResized,
                      focus  = events.focusedWindowChanged}

local function cleanupWindowWatcher(pid, windowId)
   watchers[pid].windows[windowId]:stop()
   watchers[pid].windows[windowId] = nil
   windowEventWatcher(windowEvents.close, pid, windowId)
end

local function cleanupAppWatchers(pid)
   watchers[pid].watcher:stop()
   for windowId, watcher in pairs(watchers[pid].windows) do
      cleanupWindowWatcher(pid, windowId)
   end
   watchers[pid] = nil
end

local function handleWindowEvent(win, event, watcher, info)
  if event == events.elementDestroyed then
     cleanupWindowWatcher(info.pid, info.id)
  else
    -- TODO add other window events
    -- windowEventWatcher("other")
    -- Handle other events...
  end
  hs.alert.show('window event '..event..' on '..info.id)
end

local function watchWindow(win, initializing)
  local appWindows = watchers[win:application():pid()].windows
  if win:isStandard() and not appWindows[win:id()] then
    local watcher = win:newWatcher(handleWindowEvent, {pid=win:pid(), id=win:id()})
    appWindows[win:id()] = watcher
    watcher:start({events.elementDestroyed, events.windowResized, events.windowMoved})
    windowEventWatcher(windowEvents.open, win:pid(), win:id())
  end
end


local function handleAppEvent(element, event)
  if event == events.windowCreated then
    watchWindow(element)
  elseif event == events.focusedWindowChanged then
    windowEventWatcher(events.focusedWindowChanged)
    -- Handle window change
  end
end

local function watchApp(app, initializing)
  if watchers[app:pid()] then return end
  local watcher = app:newWatcher(handleAppEvent)
  watchers[app:pid()] = {watcher = watcher, windows = {}}
  watcher:start({events.windowCreated, events.focusedWindowChanged})
 
  -- Watch any windows that already exist
  for i, window in pairs(app:allWindows()) do
    watchWindow(window, initializing)
  end
end


local function handleAppLifeEvent(name, event, app)
  if event == hs.application.watcher.launched then
    watchApp(app)
  elseif event == hs.application.watcher.terminated then
    -- Clean up
    cleanupAppWatchers(app:pid())
  end
end

local function start(callback)
  if windowEventWatcher then error("watcher already running, can't start") end
  windowEventWatcher = callback
  appsWatcher = application.watcher.new(handleAppLifeEvent)
  appsWatcher:start()
 
  -- Watch any apps that already exist
  local apps = hs.application.runningApplications()
  for i, app in pairs(apps) do
    if app:kind() == 1 then
       if app:title() ~= "Hammerspoon" then
          watchApp(app, true)
       end
    end
  end
end

local function stop()
   appsWatcher:stop()
   for pid, watchers in pairs(watchers) do
      cleanupAppWatchers(pid)
   end
   windowEventWatcher = nil
end



return {
   start = start,
   stop  = stop,
   events = windowEvents,
   watchers = watchers
}
