//
//  ncutil3 - network configuration utility, version 3
//  NCIPv4ProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCIPv4ProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the IPv4
  protocol.
*/
@interface NCIPv4ProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCIPv4ProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCIPv4ProtocolNodePropertyHandler = nil;
    
    if (NCIPv4ProtocolNodePropertyHandler == nil) {
      CFIndex         count = 8;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			methodEnumVals[] = {
                        kSCValNetIPv4ConfigMethodBOOTP,
                        kSCValNetIPv4ConfigMethodDHCP,
                        kSCValNetIPv4ConfigMethodINFORM,
                        kSCValNetIPv4ConfigMethodLinkLocal,
                        kSCValNetIPv4ConfigMethodManual,
                        kSCValNetIPv4ConfigMethodPPP
                      };
      CFArrayRef      methodEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)methodEnumVals,
                                        6,
                                        &kCFTypeArrayCallBacks
                                      );
                                      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL(1,kNCPropertyTypeStringEnum,CFSTR("method"),kSCPropNetIPv4ConfigMethod,FALSE,methodEnum)
      PROPERTY_DECL2(2,kNCPropertyTypeIP4Array,CFSTR("ip-address"),kSCPropNetIPv4Addresses)
      PROPERTY_DECL2(3,kNCPropertyTypeIP4Array,CFSTR("subnet-mask"),kSCPropNetIPv4SubnetMasks)
      PROPERTY_DECL2(4,kNCPropertyTypeIP4,CFSTR("router"),kSCPropNetIPv4Router)
      PROPERTY_DECL2(5,kNCPropertyTypeString,CFSTR("dhcp-client-id"),kSCPropNetIPv4DHCPClientID)
      PROPERTY_DECL2(6,kNCPropertyTypeIP4Array,CFSTR("destination-address"),kSCPropNetIPv4DestAddresses)
      PROPERTY_DECL2(7,kNCPropertyTypeIP4Array,CFSTR("broadcast-address"),kSCPropNetIPv4BroadcastAddresses)
      
      NCIPv4ProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(methodEnum);
    }
    return NCIPv4ProtocolNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:kSCValNetIPv4ConfigMethodDHCP ofProperty:kSCPropNetIPv4ConfigMethod];
  }
  
@end
