-- copied from https://gist.github.com/tmandry/a5b1ab6d6ea012c1e8c5

local events = hs.uielement.watcher
local application = require "hs.application"

local appsWather = nil
local watchers = {}
local windowEventWatcher = nil
local windowEvents = {open   = events.windowCreated,
                      close  = events.elementDestroyed,
                      move   = events.windowMoved,
                      resize = events.windowResized}

local function cleanupWindowWatcher(pid, windowId)
   watchers[pid].windows[windowId]:stop()
   watchers[pid].windows[windowId] = nil
end

local function cleanupAppWatchers(pid)
   watchers[pid].watcher:stop()
   for id, watcher in ipairs(watchers[pid].windows) do
      watcher:stop()
   end
   watchers[pid] = nil
end

local function handleWindowEvent(win, event, watcher, info)
  if event == events.elementDestroyed then
     cleanupWindowWatcher(info.pid, info.id)
     windowEventWatcher("closed")
  else
     windowEventWatcher("other")
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
 
    if not initializing then
      hs.alert.show('window created: '..win:id()..' with title: '..win:title())
    end
  end
end


local function handleAppEvent(element, event)
  print("app event"..event)
  if event == events.windowCreated then
    watchWindow(element)
    windowEventWatcher("open")
  elseif event == events.focusedWindowChanged then
    windowEventWatcher("focus")
    -- Handle window change
  end
end

local function watchApp(app, initializing)
  print "watching app"
  print(app)
  if watchers[app:pid()] then return end
  print "post watching"

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
    print "app event" 
    watchApp(app)
  elseif event == hs.application.watcher.terminated then
    -- Clean up
    print('cleaning up app'..app:pid()..'')
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
  for i, app in ipairs(apps) do
     print(app)
      print("starting app things"..app:title())
      if app:title() ~= "Hammerspoon" then
        watchApp(app, true)
    end
  end
end

local function stop()
   appsWatcher:stop()
   for pid, watchers in ipairs(watchers) do
      cleanupAppWatchers(pid)
   end
   windowEventWatcher = nil
end



return {
   start = start,
   stop  = stop,
   events = windowEvents
}
