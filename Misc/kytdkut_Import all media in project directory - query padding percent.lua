-- description Import all media in project directory - query padding percent
-- @version 1.0
-- @author kytdkut

-- Sound in Words - only intended for internal use
local project_path = reaper.GetProjectPath(0)
local files = {}
local item_durs = {}
local retval, padding_percent = reaper.GetUserInputs("Insert padding amount", 1, "LoSy percent amount:", 10, 100)

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
end

function RepositionItems()
    local selected_track = reaper.GetSelectedTrack(0, 0)
    local num_items = reaper.CountTrackMediaItems(selected_track)
    -- get durs
    for i = 0, num_items - 1 do
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        item_durs[i + 1] = reaper.GetMediaItemInfo_Value(current_item, 'D_LENGTH')
    end
    -- first repositioning - 2x item dur
    for i = num_items - 1, 1, -1 do -- reverse iterate
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        local current_item_pos = reaper.GetMediaItemInfo_Value(current_item, 'D_POSITION')
        reaper.SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos * 3)
    end
    -- second repositioning
    local item_durs_sum = 0
    for _, dur in ipairs(item_durs) do
        item_durs_sum = item_durs_sum + dur
    end
    for i = num_items - 1, 1, -1 do
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        local current_item_pos = reaper.GetMediaItemInfo_Value(current_item, 'D_POSITION')
        local current_item_dur = reaper.GetMediaItemInfo_Value(current_item, 'D_LENGTH')
        item_durs_sum = item_durs_sum - current_item_dur -- discard current item dur
        reaper.SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + item_durs_sum * padding_percent / 100)
    end
    -- third repositioning - add 2 secs
    for i = num_items - 1, 1, -1 do
        local current_item = reaper.GetTrackMediaItem(selected_track, i)
        local current_item_pos = reaper.GetMediaItemInfo_Value(current_item, 'D_POSITION')
        reaper.SetMediaItemInfo_Value(current_item, 'D_POSITION', current_item_pos + 2 * i)
    end
end

if retval then
    reaper.Undo_BeginBlock()
    reaper.SetEditCurPos(0, 1, 1)
    GetFilesInMediaFolder()
    for i in pairs(files) do
        reaper.InsertMedia(project_path .. "/"  .. files[i], 0)
    end
    RepositionItems()
    reaper.SetEditCurPos(0, 1, 1)
    reaper.Undo_EndBlock("Import all media in project directory - query padding percent", -1)
end
