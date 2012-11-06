//
//  ncutil3 - network configuration utility, version 3
//  NCFireWireInterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCFireWireInterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents a FireWire
  device.  This is an extremely limited private subclass, and represents
  the minimal amount of work necessary!
*/
@interface NCFireWireInterfaceNode : NCInterfaceNode

@end

//
#pragma mark -
//

@implementation NCFireWireInterfaceNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCFireWireInterfaceNodePropertyHandler = nil;
    if (NCFireWireInterfaceNodePropertyHandler == nil) {
      CFIndex         count = 4;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL3(1,kNCPropertyTypeMAC,CFSTR("mac-address"),kSCPropMACAddress,TRUE)
      PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
      PROPERTY_DECL3(3,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)
      
      NCFireWireInterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCFireWireInterfaceNodePropertyHandler;
  }
  
@end
