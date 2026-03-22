#!/usr/bin/env python3
"""
Use pbxproj library to properly remove Live Activity target
"""
from pbxproj import XcodeProject

project_path = '/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj'
project = XcodeProject(project_path)

# Find the Live Activity target
target = project.get_target_by_name('SRRadioLiveActivity')
if target:
    print(f"Found target: {target.name}")
    
    # Get all file references related to LiveActivity
    files_to_remove = []
    for file_id in project.get_ids():
        obj = project.get_object(file_id)
        if obj and hasattr(obj, 'name') and obj.name:
            name_str = str(obj.name)
            if 'LiveActivity' in name_str or 'SRRadioAttributes' in name_str:
                files_to_remove.append(file_id)
                print(f"Will remove: {name_str} ({file_id})")
    
    # Remove files
    for file_id in files_to_remove:
        try:
            project.remove_file_by_id(file_id)
            print(f"Removed: {file_id}")
        except Exception as e:
            print(f"Error removing {file_id}: {e}")
    
    print("Note: Target removal may need to be done manually in Xcode")
else:
    print("LiveActivity target not found")

# Save the project
project.save()
print("Project saved")
