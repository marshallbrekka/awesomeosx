local function make()
   return {
      -- map of window objects by window id
      windows = {},
      layoutName  = nil,
      -- array of window objects
      windowOrder = {}
   }
end

local function copy(workspace)
   local blank = make()
   for id, window in pairs(workspace.windows) do
      blank.windows[id] = window
   end
   for index, window in ipairs(workspace.windowOrder) do
      table.insert(blank.windowOrder, window)
   end
   blank.layoutName = workspace.layoutName
   return blank
end

local function layout(workspace)
   -- noop for now
   return nil
end


return {
   make = make,
   copy = copy,
   layout = layout
}
