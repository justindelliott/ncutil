//
//  ncutil3 - network configuration utility, version 3
//  NCPPPInterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCPPPInterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents a PPP interface
  layer.  This is an extremely limited private subclass, and represents
  the minimal amount of work necessary!
*/
@interface NCPPPInterfaceNode : NCInterfaceNode

@end

//
#pragma mark -
//

@implementation NCPPPInterfaceNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCPPPInterfaceNodePropertyHandler = nil;
    if (NCPPPInterfaceNodePropertyHandler == nil) {
      CFIndex         count = 42;
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
      PROPERTY_DECL2(27,kNCPropertyTypeNumber,CFSTR("idle-reminder-timer"),kSCPropNetPPPIdleReminderTimer)
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
      PROPERTY_DECL3(41,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)

      NCPPPInterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(authPromptEnum);
      CFRelease(authProtocolEnum);
    }
    return NCPPPInterfaceNodePropertyHandler;
  }
  
//

  - (void) setDefaultProperties
  {
    CFNumberRef   number;
    CFIndex       value;
    
    [super setDefaultProperties];
    //
    [self setValue:CFZero() ofProperty:kSCPropNetPPPACSPEnabled];
    [self setValue:CFZero() ofProperty:kSCPropNetPPPCommDisplayTerminalWindow];
    
    [self setValue:CFOne() ofProperty:kSCPropNetPPPCommRedialEnabled];
    [self setValue:CFOne() ofProperty:kSCPropNetPPPCommRedialCount];
    value = 5;
    if ((number = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
      [self setValue:number ofProperty:kSCPropNetPPPCommRedialInterval];
      CFRelease(number);
    }
    
    [self setValue:CFZero() ofProperty:kSCPropNetPPPCommUseTerminalScript];
    [self setValue:CFZero() ofProperty:kSCPropNetPPPDialOnDemand];
    
    [self setValue:CFZero() ofProperty:kSCPropNetPPPDisconnectOnIdle];
    value = 1800;
    if ((number = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
      [self setValue:number ofProperty:kSCPropNetPPPDisconnectOnIdleTimer];
      CFRelease(number);
    }
    
    [self setValue:CFOne() ofProperty:kSCPropNetPPPDisconnectOnSleep];
    [self setValue:CFOne() ofProperty:kSCPropNetPPPDisconnectOnLogout];
    
    [self setValue:CFZero() ofProperty:kSCPropNetPPPIdleReminder];
    value = 1800;
    if ((number = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
      [self setValue:number ofProperty:kSCPropNetPPPIdleReminderTimer];
      CFRelease(number);
    }
    
    [self setValue:CFOne() ofProperty:kSCPropNetPPPIPCPCompressionVJ];
    [self setValue:CFOne() ofProperty:kSCPropNetPPPLCPEchoEnabled];
    
    value = 4;
    if ((number = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
      [self setValue:number ofProperty:kSCPropNetPPPLCPEchoFailure];
      CFRelease(number);
    }
    value = 10;
    if ((number = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
      [self setValue:number ofProperty:kSCPropNetPPPLCPEchoInterval];
      CFRelease(number);
    }
    
    [self setValue:CFSTR("/tmp/ppp.log") ofProperty:kSCPropNetPPPLogfile];
    
    [self setValue:CFZero() ofProperty:kSCPropNetPPPVerboseLogging];
  }
  
@end
