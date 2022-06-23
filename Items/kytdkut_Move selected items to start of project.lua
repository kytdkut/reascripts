-- description Move selected items to start of project
-- @version 1.0
-- @author kytdkut

-- Requires SWS
reaper.SetEditCurPos(0, 0, 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_FNG_MOVE_TO_EDIT"), 0)
