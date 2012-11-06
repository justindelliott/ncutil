//
//  ncutil3 - network configuration utility, version 3
//  NCSMBProtocolNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCSMBProtocolNode
  A subclass of <TT>NCProtocol</TT> that represents the SMB
  protocol.
*/
@interface NCSMBProtocolNode : NCProtocolNode

@end

//
#pragma mark -
//

@implementation NCSMBProtocolNode
  
  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCSMBProtocolNodePropertyHandler = nil;
    if (NCSMBProtocolNodePropertyHandler == nil) {
      CFIndex         count = 6;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFStringRef			nodeTypeEnumVals[] = {
                        kSCValNetSMBNetBIOSNodeTypeBroadcast,
                        kSCValNetSMBNetBIOSNodeTypePeer,
                        kSCValNetSMBNetBIOSNodeTypeMixed,
                        kSCValNetSMBNetBIOSNodeTypeHybrid
                      };
      CFArrayRef      nodeTypeEnum = CFArrayCreate(
                                        kCFAllocatorDefault,
                                        (const void**)nodeTypeEnumVals,
                                        4,
                                        &kCFTypeArrayCallBacks
                                      );
      
      PROPERTY_DECL2( 0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL2( 1,kNCPropertyTypeString,CFSTR("netbios-name"),kSCPropNetSMBNetBIOSName)
      PROPERTY_DECL(  2,kNCPropertyTypeStringEnum,CFSTR("netbios-node-type"),kSCPropNetSMBNetBIOSName,FALSE,nodeTypeEnum)
      PROPERTY_DECL2( 3,kNCPropertyTypeString,CFSTR("netbios-scope"),kSCPropNetSMBNetBIOSScope)
      PROPERTY_DECL2( 4,kNCPropertyTypeIP4Array,CFSTR("netbios-wins-addresses"),kSCPropNetSMBWINSAddresses)
      PROPERTY_DECL2( 5,kNCPropertyTypeString,CFSTR("netbios-workgroup"),kSCPropNetSMBWorkgroup)
      
      NCSMBProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
      
      CFRelease(nodeTypeEnum);
    }
    return NCSMBProtocolNodePropertyHandler;
  }
  
@end
