-- All layouts must provide an arrangment function that accepts 2 arguments
-- geometry: an object with keys width and height
-- windows: a list of window objects to arrange
--
-- The arrange function should return a list of window frames (objects
-- with x,y,width,height keys). It can also return nil to indicate
-- that action should be taken on the provided windows.
local layouts = {}
local layoutOrder = {}

local function addLayout(name, arrangeFn)
   if not layouts[name] then
      layouts[name] = arrangeFn
      table.insert(layoutOrder, name)
   end
end

local function getLayout(name)
   return layouts[name]
end

local function getLayoutNames()
   return layoutOrder
end

local function noopLayout(screenGeo, windows)
   return nil
end

addLayout("float", noopLayout)

return {
   add = addLayout,
   get = getLayout,
   list = getLayoutNames
}
