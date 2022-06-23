-- description Create regions from selected item position with offset number, rename from active take
-- @version 1.0
-- @author kytdkut

retval, offset = reaper.GetUserInputs("Enter region index offset", 1, "Region index offset", "1")

function Main()
	reaper.Undo_BeginBlock()
	for item_index = 0, reaper.CountSelectedMediaItems(0) - 1 do
		current_item = reaper.GetSelectedMediaItem(0, item_index)
		current_item_pos = reaper.GetMediaItemInfo_Value(current_item, "D_POSITION")
		current_item_end = current_item_pos + reaper.GetMediaItemInfo_Value(current_item, "D_LENGTH")
		current_take = reaper.GetActiveTake(current_item)
		current_take_name = reaper.GetTakeName(current_take)
		reaper.AddProjectMarker(0, 1, current_item_pos, current_item_end, current_take_name, item_index + offset)
	end
	reaper.Undo_EndBlock("Create regions from selected items position with offset number - name from active take", -1)
end

if retval == true then
	Main()
end	
