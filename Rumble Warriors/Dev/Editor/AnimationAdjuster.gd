@tool     # makes script run from within the editor 
extends EditorScript    # gives you access to editor functions

func _run():   # this is the main function
	var selection = get_editor_interface().get_selection()
	selection = selection.get_selected_nodes()  # get the actual AnimationPlayer node
	if selection.size()!=1 and not selection is AnimationPlayer: # if the wrong node is selected, do nothing
		return
	else:
		var animationPlayer = selection[0] as AnimationPlayer;
		var animationLibraryKeys = animationPlayer.get_animation_library_list();
		for animLibKey in animationLibraryKeys:
			var animationLibrary = animationPlayer.get_animation_library(animLibKey) as AnimationLibrary;
			var animationKeys = animationLibrary.get_animation_list();
			var numSaved = 0;
			for animKey in animationKeys:
				var animation = animationLibrary.get_animation(animKey) as Animation;
				if(interpolation_change(animation)):
					ResourceSaver.save(animation);
					numSaved += 1;
					print(animKey);
			ResourceSaver.save(animationLibrary);
			print("-------------------------------");
			print("Fixed and saved %s animations!" % [numSaved]);	
			

func interpolation_change(animation : Animation) -> bool:
	var trackCount = animation.get_track_count() # get number of tracks (bones in your case)
	var animationAdjusted = false;
	for i in trackCount:
		if(animation.track_get_interpolation_type(i) != 0 || animation.track_get_interpolation_loop_wrap(i) != false):
			animationAdjusted = true;
			animation.track_set_interpolation_type(i, 0) # change interpolation mode for every track
			animation.track_set_interpolation_loop_wrap(i, false)
	return animationAdjusted;
