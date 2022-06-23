-- @description Move cursor to time selection end
-- @version 1.0
-- @author kytdkut

time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
reaper.SetEditCurPos(time_sel_end, 1, 0)
