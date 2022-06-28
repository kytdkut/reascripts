-- description Import all media in project directory
-- @version 1.01
-- @author kytdkut

-- Sound in Words - only intended for internal use
local project_path = reaper.GetProjectPath(0)
local files = {}
local selected_track = reaper.GetSelectedTrack(0, 0)

function GetFilesInMediaFolder()
    local i = 0
    repeat
        local file = reaper.EnumerateFiles(project_path, i)
        if file then
            local ext = file:match('.-%.(.*)')
            if reaper.IsMediaExtension(ext, false) then
                files[i + 1] = file -- arrays in lua start on 1
            end
            i = i + 1
        end
    until not file
    table.sort(files)
end

function RepositionItems()
    local num_items = reaper.CountTrackMediaItems(selected_track)
    -- first repositioning - 2x item dur
    for i = num_items - 1, 1, -1 do -- reverse iterate
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        local current_item_pos = reaper.GetMediaItemInfo_Value(current_item, 'D_POSITION')
        reaper.SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos * 3)
    end
    -- second repositioning - add 2 secs
    for i = num_items - 1, 1, -1 do
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        local current_item_pos = reaper.GetMediaItemInfo_Value(current_item, 'D_POSITION')
        reaper.SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + 2 * i)
    end
end

if selected_track then
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
	reaper.SetEditCurPos(0, 1, 1)
	GetFilesInMediaFolder()
	for i in pairs(files) do
	    reaper.InsertMedia(project_path .. "/"  .. files[i], 0)
	end
	RepositionItems()
	reaper.SetEditCurPos(0, 1, 1)
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Import all media in project directory - query padding", -1)
end
