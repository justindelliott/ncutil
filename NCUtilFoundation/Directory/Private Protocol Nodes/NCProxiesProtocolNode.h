//
//  ncutil3 - network configuration utility, version 3
//  NCProxiesProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCProxiesProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the Proxies
  protocol.
*/
@interface NCProxiesProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCProxiesProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCProxiesProtocolNodePropertyHandler = nil;
    if (NCProxiesProtocolNodePropertyHandler == nil) {
      CFIndex         count = 25;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2( 0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL2( 1,kNCPropertyTypeStringArray,CFSTR("host-exceptions"),kSCPropNetProxiesExceptionsList)

      PROPERTY_DECL2( 2,kNCPropertyTypeBoolean,CFSTR("ftp-proxy-enable"),kSCPropNetProxiesFTPEnable)
      PROPERTY_DECL2( 3,kNCPropertyTypeString,CFSTR("ftp-proxy-host"),kSCPropNetProxiesFTPProxy)
      PROPERTY_DECL2( 4,kNCPropertyTypeNumber,CFSTR("ftp-proxy-port"),kSCPropNetProxiesFTPPort)
      PROPERTY_DECL2( 5,kNCPropertyTypeBoolean,CFSTR("passive-ftp"),kSCPropNetProxiesFTPPassive)

      PROPERTY_DECL2( 6,kNCPropertyTypeBoolean,CFSTR("http-proxy-enable"),kSCPropNetProxiesHTTPEnable)
      PROPERTY_DECL2( 7,kNCPropertyTypeString,CFSTR("http-proxy-host"),kSCPropNetProxiesHTTPProxy)
      PROPERTY_DECL2( 8,kNCPropertyTypeNumber,CFSTR("http-proxy-port"),kSCPropNetProxiesHTTPPort)

      PROPERTY_DECL2( 9,kNCPropertyTypeBoolean,CFSTR("https-proxy-enable"),kSCPropNetProxiesHTTPSEnable)
      PROPERTY_DECL2(10,kNCPropertyTypeString,CFSTR("https-proxy-host"),kSCPropNetProxiesHTTPSProxy)
      PROPERTY_DECL2(11,kNCPropertyTypeNumber,CFSTR("https-proxy-port"),kSCPropNetProxiesHTTPSPort)

      PROPERTY_DECL2(12,kNCPropertyTypeBoolean,CFSTR("rtsp-proxy-enable"),kSCPropNetProxiesRTSPEnable)
      PROPERTY_DECL2(13,kNCPropertyTypeString,CFSTR("rtsp-proxy-host"),kSCPropNetProxiesRTSPProxy)
      PROPERTY_DECL2(14,kNCPropertyTypeNumber,CFSTR("rtsp-proxy-port"),kSCPropNetProxiesRTSPPort)

      PROPERTY_DECL2(15,kNCPropertyTypeBoolean,CFSTR("gopher-proxy-enable"),kSCPropNetProxiesGopherEnable)
      PROPERTY_DECL2(16,kNCPropertyTypeString,CFSTR("gopher-proxy-host"),kSCPropNetProxiesGopherProxy)
      PROPERTY_DECL2(17,kNCPropertyTypeNumber,CFSTR("gopher-proxy-port"),kSCPropNetProxiesGopherPort)

      PROPERTY_DECL2(18,kNCPropertyTypeBoolean,CFSTR("SOCKS-proxy-enable"),kSCPropNetProxiesSOCKSEnable)
      PROPERTY_DECL2(19,kNCPropertyTypeString,CFSTR("SOCKS-proxy-host"),kSCPropNetProxiesSOCKSProxy)
      PROPERTY_DECL2(20,kNCPropertyTypeNumber,CFSTR("SOCKS-proxy-port"),kSCPropNetProxiesSOCKSPort)

      PROPERTY_DECL2(21,kNCPropertyTypeString,CFSTR("proxy-autoconf-url"),kSCPropNetProxiesProxyAutoConfigURLString)
      PROPERTY_DECL2(22,kNCPropertyTypeBoolean,CFSTR("proxy-autoconf-enable"),kSCPropNetProxiesProxyAutoConfigEnable)
      PROPERTY_DECL2(23,kNCPropertyTypeBoolean,CFSTR("proxy-autodisc-enable"),kSCPropNetProxiesProxyAutoDiscoveryEnable)
      
      PROPERTY_DECL2(24,kNCPropertyTypeBoolean,CFSTR("exclude-simple-hostnames"),kSCPropNetProxiesExcludeSimpleHostnames)
      
      NCProxiesProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCProxiesProtocolNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:CFOne() ofProperty:kSCPropNetProxiesFTPPassive];
  }
  
@end
