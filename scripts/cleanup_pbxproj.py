#!/usr/bin/env python3
"""
Carefully remove Live Activity blocks from project.pbxproj
"""

with open('/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Remove PBXContainerItemProxy block for LiveActivity
content = content.replace('''/* Begin PBXContainerItemProxy section */
		A30000000000000000000020 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = A10000000000000000000060 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = A30000000000000000000050;
			remoteInfo = SRRadioLiveActivity;
		};
/* End PBXContainerItemProxy section */
''', '')

# Remove PBXCopyFilesBuildPhase section
content = content.replace('''/* Begin PBXCopyFilesBuildPhase section */
		A30000000000000000000060 /* Embed Foundation Extensions */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
			);
			name = "Embed Foundation Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
''', '')

# Remove PBXTargetDependency for LiveActivity
content = content.replace('''/* Begin PBXTargetDependency section */
		A30000000000000000000021 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = A30000000000000000000050;
			targetProxy = A30000000000000000000020;
		};
/* End PBXTargetDependency section */
''', '')

# Remove SRRadioLiveActivity group
content = content.replace('''		A30000000000000000000040 /* SRRadioLiveActivity */ = {
			isa = PBXGroup;
			children = (
			);
			path = SRRadioLiveActivity;
			sourceTree = "<group>";
		};
''', '')

# Remove from main group children
content = content.replace('				A30000000000000000000040 /* SRRadioLiveActivity */,\n', '')

# Remove from Products group children  
content = content.replace('				A30000000000000000000010 /* SRRadioLiveActivityExtension.appex */,\n', '')

# Remove from Models group children
content = content.replace('				A1000000000000000000001F /* SRRadioAttributes.swift */,\n', '')

# Remove from Services group children
content = content.replace('				A10000000000000000000020 /* LiveActivityManager.swift */,\n', '')

# Remove from main target build phases
content = content.replace('				A30000000000000000000060 /* Embed Foundation Extensions */,\n', '')

# Remove from main target dependencies
content = content.replace('				A30000000000000000000021 /* PBXTargetDependency */,\n', '')

# Remove from project targets
content = content.replace('				A30000000000000000000050 /* SRRadioLiveActivity */,\n', '')

# Remove TargetAttributes for LiveActivity
content = content.replace('''					A30000000000000000000050 = {
						CreatedOnToolsVersion = 15.0;
					};
''', '')

# Remove XCConfigurationList for LiveActivity target
content = content.replace('''		A30000000000000000000051 /* Build configuration list for PBXNativeTarget "SRRadioLiveActivity" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A30000000000000000000072 /* Debug */,
				A30000000000000000000073 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
''', '')

# Remove XCBuildConfiguration for LiveActivity Debug
content = content.replace('''		A30000000000000000000072 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4PC9Z56E47;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = SRRadioLiveActivity/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.1;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SKIP_INSTALL = YES;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
''', '')

# Remove XCBuildConfiguration for LiveActivity Release
content = content.replace('''		A30000000000000000000073 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4PC9Z56E47;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = SRRadioLiveActivity/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.1;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
					"@executable_path/../../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SKIP_INSTALL = YES;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.9;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
''', '')

with open('/Users/ajung/src/sr2/SRRadio/SRRadio.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("Live Activity blocks removed")
