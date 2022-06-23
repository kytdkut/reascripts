# @version 1.0
# @author kytdkut
# description Compare loudness between regions of a reference track and rendered files

# Sound in Words - only intended for internal use
# Compare loudness between regions of a reference track and rendered files
# TODO: clear redundant code
# TODO: refactor using loudness reascript api

import reaper_python
from math import log10, exp
from sws_python import *

reference_track_name = 'enUS reference'
track_to_fix_name = 'RX Edits'
master_track = RPR_GetMasterTrack(0) # for clearing RRM
count_tracks = RPR_CountTracks(0)

# some wrapper for cleaner code

def show_message_box(_msg):
    RPR_ShowMessageBox(_msg, "Render and compare", 0)
    
# core functions

def get_track_with_name(_name):
    for i in range(RPR_CountTracks(0)):
        track = RPR_GetTrack(0, i)
        _, _, _, track_name, _ = RPR_GetSetMediaTrackInfo_String(track, 'P_NAME', '', False)
        if track_name == _name:
            return track
    return None

def get_render_settings():
    settings = RPR_GetSetProjectInfo(0, 'RENDER_SETTINGS', 0, 0)
    bounds_flag = RPR_GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', 0, 0)
    add_to_proj = RPR_GetSetProjectInfo(0, 'RENDER_ADDTOPROJ', 0, 0)
    _, _, _, pattern, _ = RPR_GetSetProjectInfo_String(0, 'RENDER_PATTERN', '', 0)
    return [settings, bounds_flag, add_to_proj, pattern]

def set_render_settings(_render_settings, _render_bounds_flag, render_add_to_proj, _render_pattern):
    RPR_GetSetProjectInfo(0, 'RENDER_SETTINGS', _render_settings, 1)
    RPR_GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', _render_bounds_flag, 1)
    RPR_GetSetProjectInfo(0, 'RENDER_ADDTOPROJ', render_add_to_proj, 1)
    RPR_GetSetProjectInfo_String(0, 'RENDER_PATTERN', _render_pattern, 1)

def get_region_render_matrix_state():
    rrm_state = {}
    i = 0
    while True:
        retval, _, isrgn, region_start, region_end,_, rgidx = RPR_EnumProjectMarkers(i, 0, 0.0, 0.0, '', 0) # get region number i
        if isrgn == 1.0: # if it is a region...
            track = RPR_EnumRegionRenderMatrix(0, rgidx, 0) # check if it has a track assigned in the render matrix
            track_number = RPR_GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER') # retuns 0.0 if empty
            if track_number != 0.0:
                rrm_state[rgidx] =  track, region_start, region_end
        if retval == 0:
            break
        i += 1
    return rrm_state

def clear_region_render_matrix(_clear_list):
    for region in _clear_list:
        RPR_SetRegionRenderMatrix(0, region[0], region[1][0], -1)

def render_and_compare_loudness(_rrm_state, _loudness_deviation, _autofix_range):
    RPR_Main_OnCommand(40297, 0) # Track: Unselect all tracks
    RPR_Main_OnCommand(42230, 0) # File: Render project, using the most recent render settings, auto-close render dialog
    track_count_after_render = RPR_CountTracks(0)
    if track_count_after_render != count_tracks + 1:
        show_message_box(f'Something went wrong. Aborting.')
        return False, False # this functions always returns a tuple
    analysis_track = RPR_GetTrack(0, count_tracks) # zero-based
    RPR_SetTrackSelected(analysis_track, True)
    RPR_SetTrackSelected(reference_track, True)
    regions_passed = []
    regions_to_fix = {}
    for item in _rrm_state.items():
        rgidx, (_, region_start, region_end) = item
        RPR_Main_OnCommand(40635, 0) # Time selection: Remove time selection
        RPR_Main_OnCommand(40289, 0) # Item: Unselect all items
        RPR_GetSet_LoopTimeRange2(0, True, False, region_start, region_end, False)
        RPR_Main_OnCommand(40718, 0) # Item: Select all items on selected tracks in current time selection

        # get reference item properties
        reference_item = RPR_GetSelectedMediaItem(0, 0)
        reference_take = RPR_GetActiveTake(reference_item)
        _, _, reference_take_loudness = NF_AnalyzeTakeLoudness_IntegratedOnly(reference_take, 0)
        # get localized item properties
        analysis_track_item = RPR_GetSelectedMediaItem(0, 1)
        analysis_track_take = RPR_GetActiveTake(analysis_track_item)
        _, _, analysis_take_loudness = NF_AnalyzeTakeLoudness_IntegratedOnly(analysis_track_take, 0)

        loudness_delta = analysis_take_loudness - reference_take_loudness
        if abs(loudness_delta) <= _loudness_deviation:
            regions_passed.append(item)
        elif abs(loudness_delta) <= _autofix_range:
            regions_to_fix[rgidx] = loudness_delta, region_start, region_end
        else:
            RPR_AddProjectMarker(0, 0, region_start, 0.0, str(round(analysis_take_loudness - reference_take_loudness , 2)) + ' dB LUFS', -1)
    
    RPR_Main_OnCommand(40635, 0) # Time selection: Remove time selection
    RPR_Main_OnCommand(40289, 0) # Item: Unselect all items
    RPR_DeleteTrack(analysis_track)
    return regions_passed, regions_to_fix

def fix_loudness(_regions_to_fix, _track_to_fix):
    RPR_SetOnlyTrackSelected(_track_to_fix)
    for item in _regions_to_fix.items():
        RPR_Main_OnCommand(40635, 0) # Time selection: Remove time selection
        RPR_Main_OnCommand(40289, 0) # Item: Unselect all items
        _, (loudness_delta, region_start, region_end) = item
        RPR_GetSet_LoopTimeRange2(0, True, False, region_start, region_end, False)
        RPR_Main_OnCommand(40718, 0) # Item: Select all items on selected tracks in current time selection
        # next: apply gain needed to reach desired loudness, even if there are multiple items in the same region
        num_items = RPR_CountSelectedMediaItems(0)
        for i in range(num_items):
            this_item = RPR_GetSelectedMediaItem(0, i)
            old_vol = RPR_GetMediaItemInfo_Value(this_item, "D_VOL")
            try:
                old_vol_db = 20 * log10(old_vol)
            except ValueError:
                old_vol_db = 0
            new_vol_db = old_vol_db - loudness_delta
            if new_vol_db > 24:
                new_vol_db = 24
            new_vol = exp(new_vol_db * 0.11512925464970228420089957273422)
            RPR_SetMediaItemInfo_Value(this_item, "D_VOL", new_vol)

def main():
    retval, _, _, _, retvals_csv, _ = RPR_GetUserInputs("Render and compare", 2, "Loudness deviation (db LUFS):, Autofix range (0 to disable):", "2,7", 5)
    if not retval:
        return
    loudness_deviation, autofix_range = retvals_csv.split(",")
    try:
        loudness_deviation = float(loudness_deviation)
    except ValueError:
        show_message_box("Please insert a valid loudness deviation value.")
        return
    try:
        autofix_range = float(autofix_range)
    except ValueError:
        show_message_box("Please insert a valid autofix range, or 0 to disable autofixing.")
        return

    RPR_Undo_BeginBlock()
    RPR_PreventUIRefresh(1)
    render_settings, render_bounds_flag, render_add_to_proj, render_pattern = get_render_settings()
    set_render_settings(render_settings, render_bounds_flag, 1 , render_pattern) # make sure addtoproj is enabled
    region_render_manager_state = get_region_render_matrix_state()
    regions_passed, regions_to_fix = render_and_compare_loudness(region_render_manager_state, loudness_deviation, autofix_range)
    set_render_settings(render_settings, render_bounds_flag, render_add_to_proj, render_pattern) # restore previous render settings
    if regions_passed is False: # if render is aborted
        return
    if autofix_range > 0.0:
        track_to_fix = get_track_with_name(track_to_fix_name)
        if track_to_fix is None:
            show_message_box(f'Track {track_to_fix_name} not found. Cannot autofix loudness.')
        else:
            fix_loudness(regions_to_fix, track_to_fix)
    if RPR_ShowMessageBox('Do you want to clear the render matrix from regions that passed the check?', 'Render and compare', 4) == 6:
        clear_region_render_matrix(regions_passed)
    RPR_PreventUIRefresh(-1)
    RPR_Undo_EndBlock('Render and compare loudness', -1)

    show_message_box("All done.")

reference_track = get_track_with_name(reference_track_name)

if reference_track is None:
    show_message_box(f'Track "{reference_track}" not present. Aborting.')
else:
    main()
