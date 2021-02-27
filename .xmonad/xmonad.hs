{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeOperators #-}

-- import PagerHints (pagerHints)

import Control.Monad (forM_, join)
import Control.Monad.IO.Class (liftIO)
import Data.Function (on)
import Data.List (sortBy)
import Data.Map (Map)
-- (xmobar, PP(..))

-- (fadeWindowsLogHook)

import qualified Data.Map as M
import Data.Monoid ((<>))
import Graphics.X11.Xlib ()
import System.Exit (ExitCode (ExitSuccess), exitWith)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CycleWS (nextWS, prevWS, shiftToNext, shiftToPrev)
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.Search
import XMonad.Actions.SpawnOn (manageSpawn, spawnOn)
import XMonad.Actions.Submap
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Config.Xfce
import XMonad.Hooks.DynamicLog
import qualified XMonad.Hooks.DynamicLog as DLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks (AvoidStruts, ToggleStruts (..), avoidStruts, docks, docksEventHook, manageDocks)
import XMonad.Hooks.SetWMName
import qualified XMonad.Hooks.SetWMName as Window
import XMonad.Layout.BinarySpacePartition
import qualified XMonad.Layout.BinarySpacePartition as BSP
import qualified XMonad.Layout.IndependentScreens as LIS
import XMonad.Layout.LayoutModifier (ModifiedLayout)
import XMonad.Layout.Maximize (Maximize, maximize, maximizeRestore)
import XMonad.Layout.Spacing
import qualified XMonad.Layout.WindowNavigation as Window (Navigate (..))
import XMonad.ManageHook
import XMonad.Prompt (XPConfig (..), XPrompt)
import qualified XMonad.Prompt as Prompt
import qualified XMonad.StackSet as W
import XMonad.Util.Cursor (setDefaultCursor)
import qualified XMonad.Util.EZConfig as EZ
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run (safeSpawn)
import qualified XMonad.Util.Run as Run (safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["terminal", "code", "web", "other"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#dddddd"

myFocusedBorderColor = "#00ff00"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      -- launch dmenu
      ((modm, xK_p), spawn "rofi -show run"),
      -- Screenshot (requires flameshot)
      ((modm .|. shiftMask, xK_Print), spawn "flameshot gui"),
      ((modm, xK_Print), spawn "flameshot full -p /home/mohsin/Pictures/"),
      -- launch gmrun
      ((modm .|. shiftMask, xK_p), spawn "gmrun"),
      -- close focused window
      ((modm .|. shiftMask, xK_c), kill),
      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Tab), windows W.focusDown),
      -- Move focus to the next window
      ((modm, xK_j), windows W.focusDown),
      -- Move focus to the previous window
      ((modm, xK_k), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm, xK_Return), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm, xK_h), sendMessage Shrink),
      -- Expand the master area
      ((modm, xK_l), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      ((modm .|. shiftMask, xK_e), spawnOnce ("emacs &")),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      ((modm, xK_b), sendMessage ToggleStruts),
      -- Quit xmonad
      ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess)),
      -- Restart xmonad
      ((modm, xK_q), spawn "killall polybar; xmonad --recompile; xmonad --restart; ~/.config/polybar/launch-xmonad.sh &"),
      -- Run xmessage with a summary of the default keybindings (useful for beginners)
      ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1),
        ( \w ->
            focus w >> mouseMoveWindow w
              >> windows W.shiftMaster
        )
      ),
      -- mod-button2, Raise the window to the top of the stack
      ((modm, button2), (\w -> focus w >> windows W.shiftMaster)),
      -- mod-button3, Set the window to floating mode and resize by dragging
      ( (modm, button3),
        ( \w ->
            focus w >> mouseResizeWindow w
              >> windows W.shiftMaster
        )
      )
      -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
--myManageHook = composeAll
--    [ className =? "MPlayer"        --> doFloat
--   , className =? "Gimp"           --> doFloat
--   , resource  =? "desktop_window" --> doIgnore
--   , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook

--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
--myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook :: X() = return ()
eventLogHookForPolyBar = do
  winset <- gets windowset
  title <- maybe (return "") (fmap show . getName) . W.peek $ winset
  let currWs = W.currentTag winset
  let wss = map W.tag $ W.workspaces winset

  io $ appendFile "/tmp/.xmonad-title-log" (title ++ "\n")
  io $ appendFile "/tmp/.xmonad-workspace-log" (wsStr currWs wss ++ "\n")
  where
    fmt currWs ws
      | currWs == ws = "[" ++ ws ++ "]"
      | otherwise = " " ++ ws ++ " "
    wsStr currWs wss = join $ map (fmt currWs) $ sortBy (compare `on` (!! 0)) wss

type (:+) f g = Choose f g

infixr 5 :+

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "picom &"
  spawnOnce "dunst &"
  spawnOnce "~/.config/polybar/launch-xmonad.sh &"
  spawnOnce "nm-applet &"
  spawnOnce "fcitx5 &"
  spawnOnce "lxsession &"
  spawnOnce "emacs --daemon &"
  spawnOnce "volumeicon &"
  spawnOnce "wal -i ~/Pictures/Wallpapers/ --backend schemer"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmonad $ myConfig
  where
    myBar = "polybar"

    myConfig =
      ewmh $
        desktopConfig
          { -- simple stuff
            terminal = myTerminal,
            focusFollowsMouse = myFocusFollowsMouse,
            clickJustFocuses = myClickJustFocuses,
            borderWidth = myBorderWidth,
            modMask = myModMask,
            workspaces = myWorkspaces,
            normalBorderColor = myNormalBorderColor,
            focusedBorderColor = myFocusedBorderColor,
            -- key bindings
            keys = myKeys,
            mouseBindings = myMouseBindings,
            -- hooks, layouts
            layoutHook =
              spacingRaw False (Border 5 5 5 5) True (Border 5 5 5 5) True $
                myLayout,
            manageHook = manageDocks <+> manageSpawn <+> manageHook def,
            handleEventHook = fullscreenEventHook <+> handleEventHook desktopConfig,
            logHook = eventLogHookForPolyBar,
            startupHook = myStartupHook <+> startupHook desktopConfig
          }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help =
  unlines
    [ "The default modifier key is 'alt'. Default keybindings:",
      "",
      "-- launching and killing programs",
      "mod-Shift-Enter  Launch xterminal",
      "mod-p            Launch dmenu",
      "mod-Shift-p      Launch gmrun",
      "mod-Shift-c      Close/kill the focused window",
      "mod-Space        Rotate through the available layout algorithms",
      "mod-Shift-Space  Reset the layouts on the current workSpace to default",
      "mod-n            Resize/refresh viewed windows to the correct size",
      "",
      "-- move focus up or down the window stack",
      "mod-Tab        Move focus to the next window",
      "mod-Shift-Tab  Move focus to the previous window",
      "mod-j          Move focus to the next window",
      "mod-k          Move focus to the previous window",
      "mod-m          Move focus to the master window",
      "",
      "-- modifying the window order",
      "mod-Return   Swap the focused window and the master window",
      "mod-Shift-j  Swap the focused window with the next window",
      "mod-Shift-k  Swap the focused window with the previous window",
      "",
      "-- resizing the master/slave ratio",
      "mod-h  Shrink the master area",
      "mod-l  Expand the master area",
      "",
      "-- floating layer support",
      "mod-t  Push window back into tiling; unfloat and re-tile it",
      "",
      "-- increase or decrease number of windows in the master area",
      "mod-comma  (mod-,)   Increment the number of windows in the master area",
      "mod-period (mod-.)   Deincrement the number of windows in the master area",
      "",
      "-- quit, or restart",
      "mod-Shift-q  Quit xmonad",
      "mod-q        Restart xmonad",
      "mod-[1..9]   Switch to workSpace N",
      "",
      "-- Workspaces & screens",
      "mod-Shift-[1..9]   Move client to workspace N",
      "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
      "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
      "",
      "-- Mouse bindings: default actions bound to mouse events",
      "mod-button1  Set the window to floating mode and move by dragging",
      "mod-button2  Raise the window to the top of the stack",
      "mod-button3  Set the window to floating mode and resize by dragging"
    ]
