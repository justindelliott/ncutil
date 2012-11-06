//
//  ncutil3 - network configuration utility, version 3
//  NCGlobalNetInfoNode
//
//  Directory node subclass that handles the location-global
//  NetInfo information.
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCGlobalNetInfoNode.h"
#import "NCEntityPropertyHandlers.h"

@implementation NCGlobalNetInfoNode

  + (CFStringRef) directoryType
  {
    static CFStringRef NCGlobalNetInfo_DirectoryType = NULL;
    if (!NCGlobalNetInfo_DirectoryType)
      NCGlobalNetInfo_DirectoryType = CFSTR("Global NetInfo");
    return NCGlobalNetInfo_DirectoryType;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkSet:(SCNetworkSetRef)theSet
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      //  Construct an appropriate path to the global entity:
      CFStringRef     locID = SCNetworkSetGetSetID(theSet);
      CFStringRef     netInfoPath = SCPathCreateFromComponents(
                                        kSCPrefSets,
                                        locID,
                                        kSCCompNetwork,
                                        kSCCompGlobal,
                                        kSCEntNetNetInfo,
                                        NULL
                                      );
      if (netInfoPath) {
        if (SCPreferencesPathGetValue([[root preferenceSession] sessionReference],netInfoPath)) {
          [self setPreferencePath:netInfoPath];
        } else {
          [self release];
          self = nil;
        }
        CFRelease(netInfoPath);
      } else {
        [self release];
        self = nil;
      }
    }
    return self;
  }
  
//

  + (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCGlobalNetInfoNodePropertyHandler = nil;
    if (NCGlobalNetInfoNodePropertyHandler == nil) {
      CFIndex         count = 5;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			bindingMethodEnumVals[] = {
                        kSCValNetNetInfoBindingMethodsBroadcast,
                        kSCValNetNetInfoBindingMethodsDHCP,
                        kSCValNetNetInfoBindingMethodsManual
                      };
      CFArrayRef      bindingMethodEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)bindingMethodEnumVals,
                                        3,
                                        &kCFTypeArrayCallBacks
                                      );
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL (1,kNCPropertyTypeStringEnumArray,CFSTR("binding-method"),kSCPropNetNetInfoBindingMethods,FALSE,bindingMethodEnum)
      PROPERTY_DECL2(2,kNCPropertyTypeStringArray,CFSTR("server-address"),kSCPropNetNetInfoServerAddresses)
      PROPERTY_DECL2(3,kNCPropertyTypeStringArray,CFSTR("server-tag"),kSCPropNetNetInfoServerTags)
      PROPERTY_DECL2(4,kNCPropertyTypeString,CFSTR("broadcast-tag"),kSCPropNetNetInfoBroadcastServerTag)
      
      NCGlobalNetInfoNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(bindingMethodEnum);
    }
    return NCGlobalNetInfoNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setDirectoryIsActive:NO];
    [self setValue:kSCValNetNetInfoBindingMethodsDHCP ofProperty:kSCPropNetNetInfoBindingMethods];
  }

//

  - (CFStringRef) directoryName
  {
    return kSCEntNetNetInfo;
  }

//

  - (void) setDirectoryName:(CFStringRef)name
  {
  }

@end
