//
//  ncutil3 - network configuration utility, version 3
//  NCAirPortProtocolNode
//
//  Special class to handle AirPort entities.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCAirPortProtocolNode.h"

@implementation NCAirPortProtocolNode

  + (CFStringRef) directoryType
  {
    static CFStringRef NCAirPortProtocolNode_DirectoryType = NULL;
    if (!NCAirPortProtocolNode_DirectoryType)
      NCAirPortProtocolNode_DirectoryType = CFSTR("Protocol");
    return NCAirPortProtocolNode_DirectoryType;
  }

//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andPath:(CFStringRef)scPath
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]])
      [self setPreferencePath:scPath];
    return self;
  }
  
//

  + (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCProtocolPropertyHandler_AirPort = nil;
    if (NCProtocolPropertyHandler_AirPort == nil) {
      CFIndex         count = 7;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef     joinModeEnumVals[] = {
                          kSCValNetAirPortJoinModeAutomatic,
                          kSCValNetAirPortJoinModePreferred,
                          kSCValNetAirPortJoinModeRecent,
                          kSCValNetAirPortJoinModeStrongest
                        };
      CFArrayRef      joinModeEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)joinModeEnumVals,
                                        4,
                                        &kCFTypeArrayCallBacks
                                      );
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL2(1,kNCPropertyTypeBoolean,CFSTR("allow-net-creation"),kSCPropNetAirPortAllowNetCreation)
      PROPERTY_DECL(2,kNCPropertyTypePassword,CFSTR("password"),kSCPropNetAirPortAuthPassword,FALSE,kSCPropNetAirPortAuthPasswordEncryption)
      PROPERTY_DECL(3,kNCPropertyTypeStringEnum,CFSTR("join-mode"),kSCPropNetAirPortJoinMode,FALSE,joinModeEnum)
      PROPERTY_DECL2(4,kNCPropertyTypeBoolean,CFSTR("power-on"),kSCPropNetAirPortPowerEnabled)
      PROPERTY_DECL2(5,kNCPropertyTypeString,CFSTR("preferred-net"),kSCPropNetAirPortPreferredNetwork)
      PROPERTY_DECL2(6,kNCPropertyTypeBoolean,CFSTR("save-passwords"),kSCPropNetAirPortSavePasswords)
      
      NCProtocolPropertyHandler_AirPort = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(joinModeEnum);
    }
    return NCProtocolPropertyHandler_AirPort;
  }

//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:kSCValNetAirPortJoinModeAutomatic ofProperty:kSCPropNetAirPortJoinMode];
  }

//

  - (CFStringRef) directoryName
  {
    static CFStringRef NCAirPortProtocolNodeName = NULL;
    if (!NCAirPortProtocolNodeName)
      NCAirPortProtocolNodeName = CFSTR("Apple AirPort");
    return NCAirPortProtocolNodeName;
  }
  
//

  - (BOOL) setDirectoryName:(CFStringRef)name
  {
    return NO;
  }

@end
