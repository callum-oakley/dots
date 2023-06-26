GRID_W = 12
GRID_H = 12

GRID_MARGIN = 0

hs.application.enableSpotlightForNameSearches(true)
hs.grid.setGrid(hs.geometry(nil, nil, GRID_W, GRID_H))
    .setMargins({ GRID_MARGIN, GRID_MARGIN })
hs.window.animationDuration = 0

function IndexOf(table, elem)
  for i, x in ipairs(table) do
    if x == elem then
      return i
    end
  end
  -- we're going to sort with this function, so math.huge ensures elements
  -- that aren't found get pushed to the end
  return math.huge
end

function Filter(from, f)
  local filtered = {}
  for _, x in ipairs(from) do
    if f(x) then
      table.insert(filtered, x)
    end
  end
  return filtered
end

MruWindows = {}
MruWindowIndex = math.huge

-- Syncs up the window state with reality and moves the currently focused
-- window to the top of the stack. We want to call this on cmd down (about to
-- start changing focus) and cmd up (finished changing focus).
function RefreshWindowState()
  local windows = Filter(
    hs.window.filter.defaultCurrentSpace:getWindows(),
    function(window) return window:isStandard() end
  )

  -- preserve the order from the last state
  table.sort(windows, function(a, b)
    return IndexOf(MruWindows, a) < IndexOf(MruWindows, b)
  end)

  MruWindows = windows

  MruWindowIndex = IndexOf(MruWindows, hs.window.focusedWindow())

  if MruWindowIndex == math.huge or MruWindowIndex == 1 then
    return
  end

  local window = table.remove(MruWindows, MruWindowIndex)
  table.insert(MruWindows, 1, window)

  MruWindowIndex = 1
end

-- Changes focus to the next (direction=1) or previous (direction=-1) window,
-- in order of most recent use.
function ChangeFocus(direction)
  if #MruWindows == 0 then
    return
  end

  if MruWindowIndex == math.huge then
    MruWindowIndex = 1
  else
    -- god I hate one indexing...
    MruWindowIndex = (MruWindowIndex + direction - 1) % #MruWindows + 1
  end

  MruWindows[MruWindowIndex]:focus()
end

function SnapWindow()
  hs.grid.snap(hs.window.focusedWindow())
end

MaximizedWindows = {}

function IsMaximized(window)
  local windowFrame = window:frame()
  local screenFrame = hs.screen.mainScreen():frame()
  return windowFrame.h + 2 * GRID_MARGIN == screenFrame.h and
      windowFrame.w + 2 * GRID_MARGIN == screenFrame.w
end

function ToggleMaximizeWindow()
  local window = hs.window.focusedWindow()
  if IsMaximized(window) and MaximizedWindows[window:id()] then
    window:setFrame(MaximizedWindows[window:id()])
    MaximizedWindows[window:id()] = nil
  else
    MaximizedWindows[window:id()] = window:frame()
    hs.grid.maximizeWindow(window)
  end
end

function Bind(mods, key, f)
  hs.hotkey.bind(mods, key, f("press"), f("release"), f("repeat"))
end

function PressKey(mods, key)
  return function(case)
    if case == "press" then
      return function()
        hs.eventtap.event.newKeyEvent(mods, key, true):post()
      end
    elseif case == "release" then
      return function()
        hs.eventtap.event.newKeyEvent(mods, key, false):post()
      end
    elseif case == "repeat" then
      return function()
        hs.eventtap.event.newKeyEvent(mods, key, true):post()
      end
    end
  end
end

function OnPressOrRepeat(f)
  return function(case)
    if case == "press" or case == "repeat" then
      return f
    end
  end
end

function BindPR(mods, key, f)
  return Bind(mods, key, OnPressOrRepeat(f))
end

function PressSystemKey(key)
  hs.eventtap.event.newSystemKeyEvent(key, true):post()
  hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

function OpenForSpace(name, menuItem)
  hs.application.launchOrFocus(name)
  local app = hs.application.find(name)
  if #app:visibleWindows() == 0 then
    app:selectMenuItem(menuItem)
  end
end

Bind({ "ctrl" }, "h", PressKey(nil, "left"))
Bind({ "ctrl" }, "j", PressKey(nil, "down"))
Bind({ "ctrl" }, "k", PressKey(nil, "up"))
Bind({ "ctrl" }, "l", PressKey(nil, "right"))
Bind({ "ctrl", "cmd" }, "h", PressKey({ "cmd" }, "left"))
Bind({ "ctrl", "cmd" }, "j", PressKey({ "cmd" }, "down"))
Bind({ "ctrl", "cmd" }, "k", PressKey({ "cmd" }, "up"))
Bind({ "ctrl", "cmd" }, "l", PressKey({ "cmd" }, "right"))
Bind({ "ctrl", "alt" }, "h", PressKey({ "alt" }, "left"))
Bind({ "ctrl", "alt" }, "j", PressKey({ "alt" }, "down"))
Bind({ "ctrl", "alt" }, "k", PressKey({ "alt" }, "up"))
Bind({ "ctrl", "alt" }, "l", PressKey({ "alt" }, "right"))
Bind({ "ctrl", "shift" }, "h", PressKey({ "shift" }, "left"))
Bind({ "ctrl", "shift" }, "j", PressKey({ "shift" }, "down"))
Bind({ "ctrl", "shift" }, "k", PressKey({ "shift" }, "up"))
Bind({ "ctrl", "shift" }, "l", PressKey({ "shift" }, "right"))
Bind({ "ctrl", "cmd", "shift" }, "h", PressKey({ "cmd", "shift" }, "left"))
Bind({ "ctrl", "cmd", "shift" }, "j", PressKey({ "cmd", "shift" }, "down"))
Bind({ "ctrl", "cmd", "shift" }, "k", PressKey({ "cmd", "shift" }, "up"))
Bind({ "ctrl", "cmd", "shift" }, "l", PressKey({ "cmd", "shift" }, "right"))
Bind({ "ctrl", "alt", "shift" }, "h", PressKey({ "alt", "shift" }, "left"))
Bind({ "ctrl", "alt", "shift" }, "j", PressKey({ "alt", "shift" }, "down"))
Bind({ "ctrl", "alt", "shift" }, "k", PressKey({ "alt", "shift" }, "up"))
Bind({ "ctrl", "alt", "shift" }, "l", PressKey({ "alt", "shift" }, "right"))

BindPR({ "alt" }, "[", function() PressSystemKey("SOUND_DOWN") end)
BindPR({ "alt" }, "]", function() PressSystemKey("SOUND_UP") end)
BindPR({ "alt" }, "'", function() PressSystemKey("PLAY") end)
BindPR({ "alt" }, "t", function() OpenForSpace("kitty", "New OS Window") end)
BindPR({ "alt" }, "b", function() OpenForSpace("Google Chrome", "New Window") end)
BindPR({ "alt" }, "m", ToggleMaximizeWindow)
BindPR({ "alt" }, "h", hs.grid.pushWindowLeft)
BindPR({ "alt" }, "j", hs.grid.pushWindowDown)
BindPR({ "alt" }, "k", hs.grid.pushWindowUp)
BindPR({ "alt" }, "l", hs.grid.pushWindowRight)
BindPR({ "alt" }, "f", function() hs.window.focusedWindow():centerOnScreen() end)
BindPR({ "alt", "cmd" }, "h", hs.grid.resizeWindowThinner)
BindPR({ "alt", "cmd" }, "j", hs.grid.resizeWindowTaller)
BindPR({ "alt", "cmd" }, "k", hs.grid.resizeWindowShorter)
BindPR({ "alt", "cmd" }, "l", hs.grid.resizeWindowWider)
BindPR({ "alt", "cmd" }, "f", SnapWindow)

-- Can't override cmd-tab with a regular hotkey for some reason
KeyDownTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  if e:getKeyCode() == 48 then -- tab
    local mods = e:getFlags()
    if mods.cmd then
      if mods.shift then
        ChangeFocus(-1)
        return true
      else
        ChangeFocus(1)
        return true
      end
    end
  end
end):start()

FlagsChangedTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
  -- cmd up or down
  if hs.eventtap.checkKeyboardModifiers().cmd ~= e:getFlags().cmd then
    RefreshWindowState()
  end
end):start()
