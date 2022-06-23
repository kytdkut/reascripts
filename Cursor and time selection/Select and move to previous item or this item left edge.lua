-- @description Select and move to previous item end or start of selected item
-- @version 1.0
-- @author kytdkut

function Main()
    cursor_pos = reaper.GetCursorPosition()
    sel_item = reaper.GetSelectedMediaItem(0, 0)
    sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item, "D_POSITION")
    sel_item_right_edge = sel_item_pos + reaper.GetMediaItemInfo_Value(sel_item, "D_LENGTH")
    -- check if cursor is inside selected item
    if cursor_pos <= sel_item_right_edge and cursor_pos > sel_item_pos then
        reaper.SetEditCurPos(sel_item_pos, 1, 0)
        reaper.UpdateArrange()
    else
        reaper.Main_OnCommand(40416, 0)
    end
end

if reaper.CountSelectedMediaItems(0) > 0 then
    Main()
else
    reaper.Main_OnCommand(40416, 0)
end
