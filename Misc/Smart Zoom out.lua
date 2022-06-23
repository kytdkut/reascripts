-- @description Smart zoom in
-- @version 1.0
-- @author kytdkut
-- @about zooms out to the center of the screen if the edit cursor is not visible, or to the edit cursor if it is visible

zoom_amt = 2.2
cur_pos = reaper.GetCursorPosition(0)
start_time, end_time = reaper.GetSet_ArrangeView2(0, 0, 0, 0, 0, 0)
cur_zoom = reaper.GetHZoomLevel()
  
if  start_time > cur_pos or end_time < cur_pos then
  reaper.adjustZoom(cur_zoom / zoom_amt, 1, 1, 3)
else
  reaper.adjustZoom(cur_zoom / zoom_amt, 1, 1, 1, -1)
end
