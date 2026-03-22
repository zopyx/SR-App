#!/usr/bin/env python3
"""Add new Swift files to the Xcode project."""

import re
import sys

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w') as f:
        f.write(content)

def generate_uuid(existing_uuids):
    """Generate a unique UUID-like identifier."""
    import hashlib
    import time
    
    # Use time-based generation to ensure uniqueness
    base = f"{time.time()}-{len(existing_uuids)}"
    hash_val = hashlib.md5(base.encode()).hexdigest()
    # Format as Xcode UUID (24 hex chars)
    return hash_val[:24].upper()

def add_files_to_project():
    pbxproj_path = "/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj"
    content = read_file(pbxproj_path)
    
    # Find all existing UUIDs to avoid collisions
    existing_uuids = set(re.findall(r'\b([A-F0-9]{24})\b', content))
    
    # Generate new UUIDs for ServiceProtocols.swift
    sp_file_uuid = generate_uuid(existing_uuids)
    existing_uuids.add(sp_file_uuid)
    sp_build_uuid = generate_uuid(existing_uuids)
    existing_uuids.add(sp_build_uuid)
    
    # Generate new UUIDs for Container.swift
    c_file_uuid = generate_uuid(existing_uuids)
    existing_uuids.add(c_file_uuid)
    c_build_uuid = generate_uuid(existing_uuids)
    existing_uuids.add(c_build_uuid)
    
    # Find the Analytics.swift file reference to insert after
    analytics_match = re.search(r'(A10000000000000000000027 /\* Analytics\.swift \*/ = \{isa = PBXFileReference;[^}]+\};)', content)
    if not analytics_match:
        print("ERROR: Could not find Analytics.swift file reference")
        sys.exit(1)
    
    # Add File References after Analytics.swift
    file_refs = f"""{analytics_match.group(0)}
		{sp_file_uuid} /* ServiceProtocols.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ServiceProtocols.swift; sourceTree = "<group>"; }};
		{c_file_uuid} /* Container.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Container.swift; sourceTree = "<group>"; }};"""
    
    content = content.replace(analytics_match.group(0), file_refs)
    
    # Find the Analytics.swift build file to insert after
    analytics_build_match = re.search(r'(A20000000000000000000117 /\* Analytics\.swift in Sources \*/ = \{isa = PBXBuildFile; fileRef = A10000000000000000000027 /\* Analytics\.swift \*/; \};)', content)
    if not analytics_build_match:
        print("ERROR: Could not find Analytics.swift build file")
        sys.exit(1)
    
    # Add Build Files after Analytics.swift
    build_files = f"""{analytics_build_match.group(0)}
		{sp_build_uuid} /* ServiceProtocols.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {sp_file_uuid} /* ServiceProtocols.swift */; }};
		{c_build_uuid} /* Container.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {c_file_uuid} /* Container.swift */; }};"""
    
    content = content.replace(analytics_build_match.group(0), build_files)
    
    # Find the Services group and add the new files
    services_group_match = re.search(r'(A10000000000000000000027 /\* Analytics\.swift \*/,)', content)
    if not services_group_match:
        print("ERROR: Could not find Services group")
        sys.exit(1)
    
    # Add file references to Services group
    services_files = f"""{services_group_match.group(0)}
				{sp_file_uuid} /* ServiceProtocols.swift */,
				{c_file_uuid} /* Container.swift */,"""
    
    content = content.replace(services_group_match.group(0), services_files)
    
    # Find the Sources build phase and add the new files
    # Look for Analytics in Sources build phase
    analytics_sources_match = re.search(r'(A20000000000000000000117 /\* Analytics\.swift in Sources \*/,)', content)
    if not analytics_sources_match:
        print("ERROR: Could not find Analytics in Sources build phase")
        sys.exit(1)
    
    # Add build files to Sources phase
    sources_files = f"""{analytics_sources_match.group(0)}
				{sp_build_uuid} /* ServiceProtocols.swift in Sources */,
				{c_build_uuid} /* Container.swift in Sources */,"""
    
    content = content.replace(analytics_sources_match.group(0), sources_files)
    
    # Write the updated content
    write_file(pbxproj_path, content)
    print(f"Successfully added ServiceProtocols.swift and Container.swift to project")
    print(f"  ServiceProtocols.swift: File UUID={sp_file_uuid}, Build UUID={sp_build_uuid}")
    print(f"  Container.swift: File UUID={c_file_uuid}, Build UUID={c_build_uuid}")

if __name__ == "__main__":
    add_files_to_project()
