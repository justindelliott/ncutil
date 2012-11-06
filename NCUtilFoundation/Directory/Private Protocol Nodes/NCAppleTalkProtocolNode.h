//
//  ncutil3 - network configuration utility, version 3
//  NCAppleTalkProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCAppleTalkProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the AppleTalk
  protocol.
*/
@interface NCAppleTalkProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCAppleTalkProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCAppleTalkProtocolNodePropertyHandler = nil;
    if (NCAppleTalkProtocolNodePropertyHandler == nil) {
      CFIndex         count = 7;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			methodEnumVals[] = {
                        kSCValNetAppleTalkConfigMethodNode,
                        kSCValNetAppleTalkConfigMethodRouter,
                        kSCValNetAppleTalkConfigMethodSeedRouter
                      };
      CFArrayRef      methodEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)methodEnumVals,
                                        3,
                                        &kCFTypeArrayCallBacks
                                      );
                                      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL(1,kNCPropertyTypeStringEnum,CFSTR("method"),kSCPropNetAppleTalkConfigMethod,FALSE,methodEnum)
      PROPERTY_DECL2(2,kNCPropertyTypeString,CFSTR("default-zone"),kSCPropNetAppleTalkDefaultZone)
      PROPERTY_DECL2(3,kNCPropertyTypeNumber,CFSTR("network-id"),kSCPropNetAppleTalkNetworkID)
      PROPERTY_DECL2(4,kNCPropertyTypeNumber,CFSTR("node-id"),kSCPropNetAppleTalkNodeID)
      PROPERTY_DECL2(5,kNCPropertyTypeNumberArray,CFSTR("seed-network-range"),kSCPropNetAppleTalkSeedNetworkRange)
      PROPERTY_DECL2(6,kNCPropertyTypeStringArray,CFSTR("seed-zones"),kSCPropNetAppleTalkSeedZones)
      
      NCAppleTalkProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(methodEnum);
    }
    return NCAppleTalkProtocolNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setDirectoryIsActive:NO];
    [self setValue:kSCValNetAppleTalkConfigMethodNode ofProperty:kSCPropNetAppleTalkConfigMethod];
  }
  
@end
