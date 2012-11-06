//
//  ncutil3 - network configuration utility, version 3
//  NCDNSProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCDNSProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the DNS
  protocol.
*/
@interface NCDNSProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCDNSProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCDNSProtocolNodePropertyHandler = nil;
    if (NCDNSProtocolNodePropertyHandler == nil) {
      CFIndex         count = 11;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2( 0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL2( 1,kNCPropertyTypeDNSSortList,CFSTR("domain-name"),kSCPropNetDNSDomainName)
      PROPERTY_DECL2( 2,kNCPropertyTypeDNSSortList,CFSTR("options"),kSCPropNetDNSOptions)
      PROPERTY_DECL2( 3,kNCPropertyTypeStringArray,CFSTR("search-domains"),kSCPropNetDNSSearchDomains)
      PROPERTY_DECL2( 4,kNCPropertyTypeNumber,CFSTR("search-order"),kSCPropNetDNSSearchOrder)
      PROPERTY_DECL2( 5,kNCPropertyTypeIP4Array,CFSTR("name-server"),kSCPropNetDNSServerAddresses)
      PROPERTY_DECL2( 6,kNCPropertyTypeNumber,CFSTR("server-port"),kSCPropNetDNSSortList)
      PROPERTY_DECL2( 7,kNCPropertyTypeNumber,CFSTR("server-timeout"),kSCPropNetDNSServerTimeout)
      PROPERTY_DECL2( 8,kNCPropertyTypeDNSSortList,CFSTR("sort-list"),kSCPropNetDNSServerPort)
      PROPERTY_DECL2( 9,kNCPropertyTypeStringArray,CFSTR("supplemental-domains"),kSCPropNetDNSSupplementalMatchDomains)
      PROPERTY_DECL2(10,kNCPropertyTypeNumberArray,CFSTR("supplemental-orders"),kSCPropNetDNSSupplementalMatchOrders)
      
      NCDNSProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCDNSProtocolNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:CFSTR("PlaceHolder") ofProperty:CFSTR("PlaceHolder")];
  }
  
@end
