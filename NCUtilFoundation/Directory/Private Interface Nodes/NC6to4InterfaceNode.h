//
//  ncutil3 - network configuration utility, version 3
//  NC6to4InterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NC6to4InterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents a 6-to-4 IP
  route.  This is an extremely limited private subclass, and represents
  the minimal amount of work necessary!
*/
@interface NC6to4InterfaceNode : NCInterfaceNode

@end

//
#pragma mark -
//

@implementation NC6to4InterfaceNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NC6to4InterfaceNodePropertyHandler = nil;
    if (NC6to4InterfaceNodePropertyHandler == nil) {
      CFIndex         count = 4;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL2(1,kNCPropertyTypeIP4,CFSTR("relay-address"),kSCPropNet6to4Relay)
      PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
      PROPERTY_DECL3(3,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)
      
      NC6to4InterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NC6to4InterfaceNodePropertyHandler;
  }
  
@end
