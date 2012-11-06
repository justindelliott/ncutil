//
//  ncutil3 - network configuration utility, version 3
//  NCIPv6ProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCIPv6ProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the IPv6
  protocol.
*/
@interface NCIPv6ProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCIPv6ProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCIPv6ProtocolNodePropertyHandler = nil;
    if (NCIPv6ProtocolNodePropertyHandler == nil) {
      CFIndex         count = 7;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			methodEnumVals[] = {
                        kSCValNetIPv6ConfigMethodAutomatic,
                        kSCValNetIPv6ConfigMethodManual,
                        kSCValNetIPv6ConfigMethodRouterAdvertisement,
                        kSCValNetIPv6ConfigMethod6to4
                      };
      CFArrayRef      methodEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)methodEnumVals,
                                        4,
                                        &kCFTypeArrayCallBacks
                                      );
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL(1,kNCPropertyTypeStringEnum,CFSTR("method"),kSCPropNetIPv6ConfigMethod,FALSE,methodEnum)
      PROPERTY_DECL2(2,kNCPropertyTypeIP6Array,CFSTR("ip-address"),kSCPropNetIPv6Addresses)
      PROPERTY_DECL2(3,kNCPropertyTypeIP6Array,CFSTR("destination-address"),kSCPropNetIPv6DestAddresses)
      PROPERTY_DECL2(4,kNCPropertyTypeIP6,CFSTR("router-address"),kSCPropNetIPv6Router)
      PROPERTY_DECL2(5,kNCPropertyTypeNumberArray,CFSTR("prefix-length"),kSCPropNetIPv6PrefixLength)
      PROPERTY_DECL2(6,kNCPropertyTypeNumber,CFSTR("ipv6-flags"),kSCPropNetIPv6Flags)
      
      NCIPv6ProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(methodEnum);
    }
    return NCIPv6ProtocolNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:kSCValNetIPv6ConfigMethodAutomatic ofProperty:kSCPropNetIPv6ConfigMethod];
  }
  
@end
