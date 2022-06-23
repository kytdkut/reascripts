-- @version 1.0
-- @description Create LoSy margins - percent
-- @author kytdkut

-- Sound in Words - only intended for internal use

reference_track_name = 'enUS reference'
track_count = reaper.CountTracks(0)
_, user_input = reaper.GetUserInputs("Margin size", 1, "LoSy percent amount:", 10, 100)
margin_size_p = user_input / 100

function GetTrackWithName()
    for i = 0, track_count - 1 do
        track = reaper.GetTrack(0, i)
        retval, track_name = reaper.GetSetMediaTrackInfo_String(track, 'P_NAME', '', false)
        if track_name == reference_track_name then
            return track
        end
    end
end

function Main()
    reference_track_idx = reaper.GetMediaTrackInfo_Value(reference_track, "IP_TRACKNUMBER")
    reference_track_num_items = reaper.CountTrackMediaItems(reference_track)
    if reference_track_num_items == 0 then
        reaper.ShowMessageBox("Track 'enUS reference' has zero items. Aborting.", 'Create LoSy margins', 0)
        return
    end
    reaper.InsertTrackAtIndex(reference_track_idx, true) -- zero based
    margin_track = reaper.GetTrack(0, reference_track_idx)
    reaper.GetSetMediaTrackInfo_String(margin_track, "P_NAME", "LoSy margins", true)
    for i = 0, reference_track_num_items - 1 do
        item = reaper.GetTrackMediaItem(reference_track, i)
        item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        margin_size = item_length * margin_size_p * 2
        item_end = item_pos + item_length
        reaper.CreateNewMIDIItemInProj(margin_track, item_end - margin_size / 2, item_end + margin_size / 2)
    end
end

reference_track = GetTrackWithName()

if not reference_track then
    reaper.ShowMessageBox("Track 'enUS reference' not present. Aborting.", 'Create LoSy margins', 0)
else
    Main()
end
