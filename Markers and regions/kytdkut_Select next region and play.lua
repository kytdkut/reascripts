-- description Select next region and play
-- @version 1.0
-- @author kytdkut

reaper.Main_OnCommand(1016, 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELNEXTREG"), 0)
time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
reaper.SetEditCurPos(time_sel_start, 1, 0)
reaper.Main_OnCommand(40718, 0)
reaper.Main_OnCommand(1007, 0)
