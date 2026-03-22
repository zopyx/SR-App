#!/usr/bin/env python3
"""
Use openstep_parser to properly parse and modify pbxproj
"""
from openstep_parser import openstep_parser

project_path = '/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj'

# Read and parse
with open(project_path, 'r') as f:
    pbxproj = openstep_parser.OpenStepDecoder.ParseFromFile(f)

# Print structure to understand
print("Root keys:", list(pbxproj.keys()))
if 'objects' in pbxproj:
    print("Object count:", len(pbxproj['objects']))
    
# Find targets
for key, obj in pbxproj['objects'].items():
    if isinstance(obj, dict) and obj.get('isa') == 'PBXNativeTarget':
        print(f"Target: {obj.get('name')} ({key})")
