#!/usr/bin/env python3
"""
Script to remove Live Activity target and references from project.pbxproj
"""

import re

# Read the file
with open('/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Lines/patterns to remove
lines_to_remove = [
    # PBXBuildFile section - Live Activity related
    '\t\tA2000000000000000000010F /* SRRadioAttributes.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000000000000000000001F /* SRRadioAttributes.swift */; };',
    '\t\tA20000000000000000000110 /* LiveActivityManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = A10000000000000000000020 /* LiveActivityManager.swift */; };',
    '\t\tA30000000000000000000001 /* SRRadioLiveActivityBundle.swift in Sources */ = {isa = PBXBuildFile; fileRef = A30000000000000000000011 /* SRRadioLiveActivityBundle.swift */; };',
    '\t\tA30000000000000000000002 /* SRRadioLiveActivity.swift in Sources */ = {isa = PBXBuildFile; fileRef = A30000000000000000000012 /* SRRadioLiveActivity.swift */; };',
    '\t\tA30000000000000000000003 /* SRRadioAttributes.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1000000000000000000001F /* SRRadioAttributes.swift */; };',
    '\t\tA30000000000000000000004 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = A1000000000000000000001B /* Assets.xcassets */; };',
    '\t\tA30000000000000000000005 /* SRRadioLiveActivityExtension.appex in Embed Foundation Extensions */ = {isa = PBXBuildFile; fileRef = A30000000000000000000010 /* SRRadioLiveActivityExtension.appex */; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };',
    
    # PBXContainerItemProxy section - entire block
    '\tA30000000000000000000020 /* PBXContainerItemProxy */ = {\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = A10000000000000000000060 /* Project object */;\n\t\t\tproxyType = 1;\n\t\t\tremoteGlobalIDString = A30000000000000000000050;\n\t\t\tremoteInfo = SRRadioLiveActivity;\n\t\t};',
    
    # PBXCopyFilesBuildPhase section - entire block
    '\tA30000000000000000000060 /* Embed Foundation Extensions */ = {\n\t\t\tisa = PBXCopyFilesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tdstPath = "";\n\t\t\tdstSubfolderSpec = 13;\n\t\t\tfiles = (\n\t\t\t\tA30000000000000000000005 /* SRRadioLiveActivityExtension.appex in Embed Foundation Extensions */,\n\t\t\t);\n\t\t\tname = "Embed Foundation Extensions";\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};',
    
    # PBXFileReference section
    '\t\tA30000000000000000000010 /* SRRadioLiveActivityExtension.appex */ = {isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = SRRadioLiveActivityExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; };',
    '\t\tA1000000000000000000001F /* SRRadioAttributes.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SRRadioAttributes.swift; sourceTree = "<group>"; };',
    '\t\tA10000000000000000000020 /* LiveActivityManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LiveActivityManager.swift; sourceTree = "<group>"; };',
    '\t\tA30000000000000000000011 /* SRRadioLiveActivityBundle.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SRRadioLiveActivityBundle.swift; sourceTree = "<group>"; };',
    '\t\tA30000000000000000000012 /* SRRadioLiveActivity.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SRRadioLiveActivity.swift; sourceTree = "<group>"; };',
    
    # PBXFrameworksBuildPhase - Live Activity frameworks
    '\tA30000000000000000000030 /* Frameworks */ = {\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};',
    
    # PBXGroup section - SRRadioLiveActivity group
    '\tA30000000000000000000040 /* SRRadioLiveActivity */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\tA30000000000000000000011 /* SRRadioLiveActivityBundle.swift */,\n\t\t\t\tA30000000000000000000012 /* SRRadioLiveActivity.swift */,\n\t\t\t);\n\t\t\tpath = SRRadioLiveActivity;\n\t\t\tsourceTree = "<group>";\n\t\t};',
    
    # PBXNativeTarget section - entire SRRadioLiveActivity target
    '\tA30000000000000000000050 /* SRRadioLiveActivity */ = {\n\t\t\tisa = PBXNativeTarget;\n\t\t\tbuildConfigurationList = A30000000000000000000051 /* Build configuration list for PBXNativeTarget "SRRadioLiveActivity" */;\n\t\t\tbuildPhases = (\n\t\t\t\tA30000000000000000000052 /* Sources */,\n\t\t\t\tA30000000000000000000030 /* Frameworks */,\n\t\t\t\tA30000000000000000000053 /* Resources */,\n\t\t\t);\n\t\t\tbuildRules = (\n\t\t\t);\n\t\t\tdependencies = (\n\t\t\t);\n\t\t\tname = SRRadioLiveActivity;\n\t\t\tproductName = SRRadioLiveActivity;\n\t\t\tproductReference = A30000000000000000000010 /* SRRadioLiveActivityExtension.appex */;\n\t\t\tproductType = "com.apple.product-type.app-extension";\n\t\t};',
    
    # PBXResourcesBuildPhase - Live Activity resources
    '\tA30000000000000000000053 /* Resources */ = {\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\tA30000000000000000000004 /* Assets.xcassets in Resources */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};',
    
    # PBXSourcesBuildPhase - Live Activity sources
    '\tA30000000000000000000052 /* Sources */ = {\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\tA30000000000000000000001 /* SRRadioLiveActivityBundle.swift in Sources */,\n\t\t\t\tA30000000000000000000002 /* SRRadioLiveActivity.swift in Sources */,\n\t\t\t\tA30000000000000000000003 /* SRRadioAttributes.swift in Sources */,\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t};',
    
    # PBXTargetDependency section
    '\tA30000000000000000000021 /* PBXTargetDependency */ = {\n\t\t\tisa = PBXTargetDependency;\n\t\t\ttarget = A30000000000000000000050 /* SRRadioLiveActivity */;\n\t\t\ttargetProxy = A30000000000000000000020 /* PBXContainerItemProxy */;\n\t\t};',
]

# Remove each pattern
for pattern in lines_to_remove:
    content = content.replace(pattern + '\n', '')

# Also need to remove from various sections more carefully

# Remove from PBXGroup children (main group)
content = re.sub(
    r'\t\t\tA30000000000000000000040 /\* SRRadioLiveActivity \*/,\n',
    '',
    content
)

# Remove from Products group
content = re.sub(
    r'\t\t\tA30000000000000000000010 /\* SRRadioLiveActivityExtension\.appex \*/,\n',
    '',
    content
)

# Remove from Models group
content = re.sub(
    r'\t\t\tA1000000000000000000001F /\* SRRadioAttributes\.swift \*/,\n',
    '',
    content
)

# Remove from Services group
content = re.sub(
    r'\t\t\tA10000000000000000000020 /\* LiveActivityManager\.swift \*/,\n',
    '',
    content
)

# Remove from main app target build phases (Embed Foundation Extensions)
content = re.sub(
    r'\t\t\tA30000000000000000000060 /\* Embed Foundation Extensions \*/,\n',
    '',
    content
)

# Remove from main app target dependencies
content = re.sub(
    r'\t\t\tA30000000000000000000021 /\* PBXTargetDependency \*/,\n',
    '',
    content
)

# Remove from project targets list
content = re.sub(
    r'\t\t\tA30000000000000000000050 /\* SRRadioLiveActivity \*/,\n',
    '',
    content
)

# Remove from TargetAttributes in PBXProject
content = re.sub(
    r'\t\t\t\tA30000000000000000000050 = \{\n\t\t\t\t\tCreatedOnToolsVersion = 15\.0;\n\t\t\t\t};\n',
    '',
    content
)

# Remove XCBuildConfiguration for LiveActivity (Debug and Release)
content = re.sub(
    r'\tA30000000000000000000072 /\* Debug \*/ = \{[^}]+\};\n\t\t\tname = Debug;\n\t\t};\n\t\tA30000000000000000000073 /\* Release \*/ = \{[^}]+\};\n\t\t\tname = Release;\n\t\t};\n',
    '',
    content,
    flags=re.DOTALL
)

# Remove XCConfigurationList for SRRadioLiveActivity
content = re.sub(
    r'\tA30000000000000000000051 /\* Build configuration list for PBXNativeTarget "SRRadioLiveActivity" \*/ = \{[^}]+\};\n',
    '',
    content,
    flags=re.DOTALL
)

# Write the file back
with open('/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Live Activity references removed from project.pbxproj")
