//
//  ncutil3 - network configuration utility, version 3
//  NCL2TPInterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCL2TPInterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents a L2TP interface
  layer.  This is an extremely limited private subclass, and represents
  the minimal amount of work necessary!
*/
@interface NCL2TPInterfaceNode : NCInterfaceNode

@end

//
#pragma mark -
//

@implementation NCL2TPInterfaceNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCL2TPInterfaceNodePropertyHandler = nil;
    if (NCL2TPInterfaceNodePropertyHandler == nil) {
      CFIndex         count = 5;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			transportEnumVals[] = {
                        kSCValNetL2TPTransportIP,
                        kSCValNetL2TPTransportIPSec
                      };
      CFArrayRef      transportEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)transportEnumVals,
                                        2,
                                        &kCFTypeArrayCallBacks
                                      );
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL (1,kNCPropertyTypePassword,CFSTR("shared-secret"),kSCPropNetL2TPIPSecSharedSecret,FALSE,kSCPropNetL2TPIPSecSharedSecretEncryption)
      PROPERTY_DECL (2,kNCPropertyTypeStringEnum,CFSTR("transport-method"),kSCPropNetL2TPTransport,FALSE,transportEnum)
      PROPERTY_DECL3(3,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
      PROPERTY_DECL3(4,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)
      
      NCL2TPInterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(transportEnum);
    }
    return NCL2TPInterfaceNodePropertyHandler;
  }
  
@end
