//
//  ncutil3 - network configuration utility, version 3
//  NCEntityPropertyHandlers
//
//  Property handlers for service entities.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCEntityPropertyHandlers.h"

NCPropertyHandler*
NCAppleTalkEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_AppleTalk = nil;
  if (NCEntityPropertyHandler_AppleTalk == nil) {
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
    
    NCEntityPropertyHandler_AppleTalk = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(methodEnum);
  }
  return NCEntityPropertyHandler_AppleTalk;
}

NCPropertyHandler*
NCDNSEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_DNS = nil;
  if (NCEntityPropertyHandler_DNS == nil) {
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
    
    NCEntityPropertyHandler_DNS = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_DNS;
}

NCPropertyHandler*
NCIP4EntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_IP4 = nil;
  if (NCEntityPropertyHandler_IP4 == nil) {
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
    
    NCEntityPropertyHandler_IP4 = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(methodEnum);
  }
  return NCEntityPropertyHandler_IP4;
}

NCPropertyHandler*
NCIP6EntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_IP6 = nil;
  if (NCEntityPropertyHandler_IP6 == nil) {
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
    
    NCEntityPropertyHandler_IP6 = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(methodEnum);
  }
  return NCEntityPropertyHandler_IP6;
}

NCPropertyHandler*
NCProxiesEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_Proxies = nil;
  if (NCEntityPropertyHandler_Proxies == nil) {
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
    
    NCEntityPropertyHandler_Proxies = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_Proxies;
}

NCPropertyHandler*
NC6to4EntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_6to4 = nil;
  if (NCEntityPropertyHandler_6to4 == nil) {
    CFIndex         count = 3;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    
    PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    PROPERTY_DECL2(1,kNCPropertyTypeIP4,CFSTR("relay-address"),kSCPropNet6to4Relay)
    PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
    
    NCEntityPropertyHandler_6to4 = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_6to4;
}

NCPropertyHandler*
NCModemEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_Modem = nil;
  if (NCEntityPropertyHandler_Modem == nil) {
    CFIndex         count = 15;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    CFStringRef			dialModeEnumVals[] = {
                      kSCValNetModemDialModeIgnoreDialTone,
                      kSCValNetModemDialModeManual,
                      kSCValNetModemDialModeWaitForDialTone
                    };
    CFArrayRef      dialModeEnum = CFArrayCreate(
                                      kCFAllocatorDefault,
                                      (const void**)dialModeEnumVals,
                                      3,
                                      &kCFTypeArrayCallBacks
                                    );
    
    PROPERTY_DECL2( 0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    PROPERTY_DECL(  1,kNCPropertyTypeStringEnum,CFSTR("dial-mode"),kSCPropNetModemDialMode,FALSE,dialModeEnum)
    PROPERTY_DECL2( 2,kNCPropertyTypeBoolean,CFSTR("error-correction"),kSCPropNetModemErrorCorrection)
    PROPERTY_DECL2( 3,kNCPropertyTypeBoolean,CFSTR("pulse-dial"),kSCPropNetModemPulseDial)
    PROPERTY_DECL2( 4,kNCPropertyTypeBoolean,CFSTR("audible-dial"),kSCPropNetModemSpeaker)
    PROPERTY_DECL2( 5,kNCPropertyTypeBoolean,CFSTR("data-compression"),kSCPropNetModemDataCompression)
    PROPERTY_DECL2( 6,kNCPropertyTypeString,CFSTR("modem-script"),kSCPropNetModemConnectionScript)
    PROPERTY_DECL2( 7,kNCPropertyTypeNumber,CFSTR("connect-at-speed"),kSCPropNetModemConnectSpeed)
    PROPERTY_DECL2( 8,kNCPropertyTypeBoolean,CFSTR("call-waiting-alert"),kSCPropNetModemHoldCallWaitingAudibleAlert)
    PROPERTY_DECL2( 9,kNCPropertyTypeBoolean,CFSTR("disconnect-on-answer"),kSCPropNetModemHoldDisconnectOnAnswer)
    PROPERTY_DECL2(10,kNCPropertyTypeBoolean,CFSTR("hold-enabled"),kSCPropNetModemHoldEnabled)
    PROPERTY_DECL2(11,kNCPropertyTypeBoolean,CFSTR("hold-reminder"),kSCPropNetModemHoldReminder)
    PROPERTY_DECL2(12,kNCPropertyTypeNumber,CFSTR("hold-reminder-timer"),kSCPropNetModemHoldReminderTime)
    PROPERTY_DECL2(13,kNCPropertyTypeString,CFSTR("note"),kSCPropNetModemNote)
    PROPERTY_DECL3(14,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)

    NCEntityPropertyHandler_Modem = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_Modem;
}

NCPropertyHandler*
NCPPPEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_PPP = nil;
  if (NCEntityPropertyHandler_PPP == nil) {
    CFIndex         count = 41;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    CFStringRef			authPromptEnumVals[] = {
                      kSCValNetPPPAuthPromptBefore,
                      kSCValNetPPPAuthPromptAfter
                    };
    CFArrayRef      authPromptEnum = CFArrayCreate(
                                      kCFAllocatorDefault,
                                      (const void**)authPromptEnumVals,
                                      2,
                                      &kCFTypeArrayCallBacks
                                    );
    CFStringRef			authProtocolEnumVals[] = {
                      kSCValNetPPPAuthProtocolCHAP,
                      kSCValNetPPPAuthProtocolEAP,
                      kSCValNetPPPAuthProtocolMSCHAP1,
                      kSCValNetPPPAuthProtocolMSCHAP2,
                      kSCValNetPPPAuthProtocolPAP
                    };
    CFArrayRef      authProtocolEnum = CFArrayCreate(
                                      kCFAllocatorDefault,
                                      (const void**)authProtocolEnumVals,
                                      5,
                                      &kCFTypeArrayCallBacks
                                    );
    
    PROPERTY_DECL2( 0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    PROPERTY_DECL2( 1,kNCPropertyTypeString,CFSTR("service-provider"),kSCPropUserDefinedName)
    PROPERTY_DECL2( 2,kNCPropertyTypeBoolean,CFSTR("ACSP-enabled"),kSCPropNetPPPACSPEnabled)
    // PPP authentification items [ 5]:
    PROPERTY_DECL2( 3,kNCPropertyTypeString,CFSTR("account-name"),kSCPropNetPPPAuthName)
    PROPERTY_DECL ( 4,kNCPropertyTypePassword,CFSTR("account-password"),kSCPropNetPPPAuthPassword,FALSE,kSCPropNetPPPAuthPasswordEncryption)
    PROPERTY_DECL ( 5,kNCPropertyTypeStringEnum,CFSTR("prompt-when"),kSCPropNetPPPAuthPrompt,FALSE,authPromptEnum)
    PROPERTY_DECL ( 6,kNCPropertyTypeStringEnum,CFSTR("auth-protocol"),kSCPropNetPPPAuthProtocol,FALSE,authProtocolEnum)
    PROPERTY_DECL2( 7,kNCPropertyTypeStringArray,CFSTR("auth-plugins"),kSCPropNetPPPAuthEAPPlugins)
    // PPP Communications items [ 9]:
    PROPERTY_DECL2( 8,kNCPropertyTypeString,CFSTR("remote-address"),kSCPropNetPPPCommRemoteAddress)
    PROPERTY_DECL2( 9,kNCPropertyTypeString,CFSTR("alt-remote-address"),kSCPropNetPPPCommAlternateRemoteAddress)
    PROPERTY_DECL2(10,kNCPropertyTypeBoolean,CFSTR("redial-enable"),kSCPropNetPPPCommRedialEnabled)
    PROPERTY_DECL2(11,kNCPropertyTypeNumber,CFSTR("redial-count"),kSCPropNetPPPCommRedialCount)
    PROPERTY_DECL2(12,kNCPropertyTypeNumber,CFSTR("redial-interval"),kSCPropNetPPPCommRedialInterval)
    PROPERTY_DECL2(13,kNCPropertyTypeNumber,CFSTR("connect-delay"),kSCPropNetPPPCommConnectDelay)
    PROPERTY_DECL2(14,kNCPropertyTypeString,CFSTR("terminal-script"),kSCPropNetPPPCommTerminalScript)
    PROPERTY_DECL2(15,kNCPropertyTypeBoolean,CFSTR("show-terminal-window"),kSCPropNetPPPCommDisplayTerminalWindow)
    PROPERTY_DECL2(16,kNCPropertyTypeBoolean,CFSTR("use-terminal-script"),kSCPropNetPPPCommUseTerminalScript)
    // PPP Options [12]:
    PROPERTY_DECL2(17,kNCPropertyTypeBoolean,CFSTR("disconnect-on-sleep"),kSCPropNetPPPDisconnectOnSleep)
    PROPERTY_DECL2(18,kNCPropertyTypeStringArray,CFSTR("ppp-plugins"),kSCPropNetPPPPlugins)
    PROPERTY_DECL2(19,kNCPropertyTypeNumber,CFSTR("session-time-limit"),kSCPropNetPPPSessionTimer)
    PROPERTY_DECL2(20,kNCPropertyTypeBoolean,CFSTR("use-session-time-limit"),kSCPropNetPPPUseSessionTimer)
    PROPERTY_DECL2(21,kNCPropertyTypeString,CFSTR("ppp-log-file"),kSCPropNetPPPLogfile)
    PROPERTY_DECL2(22,kNCPropertyTypeBoolean,CFSTR("verbose-logging-enable"),kSCPropNetPPPVerboseLogging)
    PROPERTY_DECL2(23,kNCPropertyTypeBoolean,CFSTR("dial-on-demand-enable"),kSCPropNetPPPDialOnDemand)
    PROPERTY_DECL2(24,kNCPropertyTypeBoolean,CFSTR("idle-disconnect-enable"),kSCPropNetPPPDisconnectOnIdle)
    PROPERTY_DECL2(25,kNCPropertyTypeNumber,CFSTR("idle-disconnect-timer"),kSCPropNetPPPDisconnectOnIdleTimer)
    PROPERTY_DECL2(26,kNCPropertyTypeBoolean,CFSTR("idle-reminder-enable"),kSCPropNetPPPIdleReminder)
    PROPERTY_DECL2(27,kNCPropertyTypeNumber,CFSTR("reminder-timer"),kSCPropNetPPPIdleReminderTimer)
    PROPERTY_DECL2(28,kNCPropertyTypeBoolean,CFSTR("logout-disconnect-enable"),kSCPropNetPPPDisconnectOnLogout)
    // PPP compression options [ 3]:
    PROPERTY_DECL2(29,kNCPropertyTypeBoolean,CFSTR("header-compression-enable"),kSCPropNetPPPIPCPCompressionVJ)
    PROPERTY_DECL2(30,kNCPropertyTypeBoolean,CFSTR("address-compression-enable"),kSCPropNetPPPLCPCompressionACField)
    PROPERTY_DECL2(31,kNCPropertyTypeBoolean,CFSTR("protocol-compression-enable"),kSCPropNetPPPLCPCompressionPField)
    // PPP LCP options [ 7]:
    PROPERTY_DECL2(32,kNCPropertyTypeBoolean,CFSTR("ppp-echo-enable"),kSCPropNetPPPLCPEchoEnabled)
    PROPERTY_DECL2(33,kNCPropertyTypeNumber,CFSTR("ppp-echo-failafter"),kSCPropNetPPPLCPEchoFailure)
    PROPERTY_DECL2(34,kNCPropertyTypeNumber,CFSTR("ppp-echo-interval"),kSCPropNetPPPLCPEchoInterval)
    PROPERTY_DECL2(35,kNCPropertyTypeNumber,CFSTR("max-receive-unitsize"),kSCPropNetPPPLCPMRU)
    PROPERTY_DECL2(36,kNCPropertyTypeNumber,CFSTR("max-transmit-unitsize"),kSCPropNetPPPLCPMTU)
    PROPERTY_DECL2(37,kNCPropertyTypeNumber,CFSTR("receive-accm"),kSCPropNetPPPLCPReceiveACCM)
    PROPERTY_DECL2(38,kNCPropertyTypeNumber,CFSTR("transmit-accm"),kSCPropNetPPPLCPTransmitACCM)
    // CCP (???)
    PROPERTY_DECL2(39,kNCPropertyTypeBoolean,CFSTR("ccp-enable"),kSCPropNetPPPCCPEnabled)
    
    PROPERTY_DECL3(40,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)

    NCEntityPropertyHandler_PPP = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(authPromptEnum);
    CFRelease(authProtocolEnum);
  }
  return NCEntityPropertyHandler_PPP;
}

NCPropertyHandler*
NCL2TPEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_L2TP = nil;
  if (NCEntityPropertyHandler_L2TP == nil) {
    CFIndex         count = 4;
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
    
    NCEntityPropertyHandler_L2TP = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(transportEnum);
  }
  return NCEntityPropertyHandler_L2TP;
}

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1050

NCPropertyHandler*
NCNetInfoEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_NetInfo = nil;
  if (NCEntityPropertyHandler_NetInfo == nil) {
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
    
    NCEntityPropertyHandler_NetInfo = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
    
    CFRelease(bindingMethodEnum);
  }
  return NCEntityPropertyHandler_NetInfo;
}

#endif

NCPropertyHandler*
NCFireWireEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_FireWire = nil;
  if (NCEntityPropertyHandler_FireWire == nil) {
    CFIndex         count = 3;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    
    PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    PROPERTY_DECL3(1,kNCPropertyTypeMAC,CFSTR("mac-address"),kSCPropMACAddress,TRUE)
    PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
    
    NCEntityPropertyHandler_FireWire = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_FireWire;
}

NCPropertyHandler*
NCGenericEntityPropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_Generic = nil;
  if (NCEntityPropertyHandler_Generic == nil) {
    CFIndex         count = 1;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    
    PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    
    NCEntityPropertyHandler_Generic = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_Generic;
}

NCPropertyHandler*
NCGenericInterfacePropertyHandler()
{
  static NCPropertyHandler* NCEntityPropertyHandler_Generic = nil;
  if (NCEntityPropertyHandler_Generic == nil) {
    CFIndex         count = 3;
    NCPropertyRef   properties[count];
    CFStringRef     uiNames[count];
    
    PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
    PROPERTY_DECL3(1,kNCPropertyTypeMAC,CFSTR("mac-address"),kSCPropMACAddress,TRUE)
    PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
    
    NCEntityPropertyHandler_Generic = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
    
    while (count--) {
      CFRelease(uiNames[count]);
      NCPropertyRelease(properties[count]);
    }
  }
  return NCEntityPropertyHandler_Generic;
}
