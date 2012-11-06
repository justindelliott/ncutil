//
//  ncutil3 - network configuration utility, version 3
//  NCModemInterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCModemInterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents a modem
  device.  This is an extremely limited private subclass, and represents
  the minimal amount of work necessary!
*/
@interface NCModemInterfaceNode : NCInterfaceNode

@end

//
#pragma mark -
//

@implementation NCModemInterfaceNode

  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCModemInterfaceNodePropertyHandler = nil;
    if (NCModemInterfaceNodePropertyHandler == nil) {
      CFIndex         count = 16;
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
      PROPERTY_DECL3(15,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)

      NCModemInterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCModemInterfaceNodePropertyHandler;
  }
  
//

  - (SCNetworkServiceRef) createNetworkService
  {
    SCNetworkServiceRef   theNewService = NULL;
    
    if ([self isLocked]) {
      SCNetworkInterfaceRef pppOverModem = SCNetworkInterfaceCreateWithInterface(_networkInterface,kSCNetworkInterfaceTypePPP);
      
      if (pppOverModem) {
        theNewService = SCNetworkServiceCreate(
                          [[self preferenceSession] sessionReference],
                          pppOverModem
                        );
        CFRelease(pppOverModem);
      }
    }
    return theNewService;
  }

//

  - (void) setDefaultProperties
  {
    [super setDefaultProperties];
    //
    [self setValue:CFSTR("/Library/Modem Scripts/Apple Internal 56K Modem (v.92)") ofProperty:kSCPropNetModemConnectionScript];
    [self setValue:CFOne() ofProperty:kSCPropNetModemDataCompression];
    [self setValue:kSCValNetModemDialModeWaitForDialTone ofProperty:kSCPropNetModemDialMode];
    [self setValue:CFOne() ofProperty:kSCPropNetModemErrorCorrection];
    [self setValue:CFZero() ofProperty:kSCPropNetModemSpeaker];
  }
  
@end
