//
//  ncutil3 - network configuration utility, version 3
//  NCEthernetInterfaceNode
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

/*!
  @class NCEthernetInterfaceNode
  A subclass of <TT>NCInterfaceNode</TT> that represents an Ethernet
  device.  We use a special private subclass in this case because
  an Ethernet device can have context-specific configuration data
  associated with it:  the sub-type for the media determines what
  options are appropriate to it.  So out of all the classes, this
  one is really the most dynamic, since changing the sub-type will
  trigger a change in the property handler!
*/
@interface NCEthernetInterfaceNode : NCInterfaceNode
{
  NCPortOptions*      _portOptions;
  NCPropertyHandler*  _propertyHandler;
}

@end

//
#pragma mark -
//

@implementation NCEthernetInterfaceNode

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterface:(SCNetworkInterfaceRef)theInterface
  {
    if (self = [super initWithRootDirectory:root andNetworkInterface:theInterface]) {
      //  Get a port options object for us:
      _portOptions = [[NCPortOptions portOptionsWithBSDDevice:SCNetworkInterfaceGetBSDName(theInterface)] retain];
    }
    return self;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterfaceTemplate:(SCNetworkInterfaceRef)theInterface
  {
    //  NO port options for a template.  Just initialize like a regular NCInterfaceNode
    //  instance.
    return [super initWithRootDirectory:root andNetworkInterfaceTemplate:theInterface];
  }
  
//

  - (void) dealloc
  {
    if (_portOptions) [_portOptions release];
    if (_propertyHandler) [_propertyHandler release];
    [super dealloc];
  }

//

  - (void) invalidatePropertyHandler
  {
    if (_propertyHandler) [_propertyHandler release];
    _propertyHandler = nil;
  }

//

  - (NCPropertyHandler*) propertyHandler
  {
    if (!_propertyHandler) {
      CFIndex         count = 7;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      CFArrayRef      enumValArray;
      CFSetRef        enumValSet;
      CFIndex         mtu;
      CFStringRef     curSubType = [self valueOfProperty:kSCPropNetEthernetMediaSubType];
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL3(1,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
      PROPERTY_DECL3(2,kNCPropertyTypeMAC,CFSTR("mac-address"),kSCPropMACAddress,TRUE)
      PROPERTY_DECL3(3,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)
      
      if (_portOptions) {
        if ((enumValArray = [_portOptions mediaSubTypes])) {
          PROPERTY_DECL(4,kNCPropertyTypeStringEnum,CFSTR("media-sub-type"),kSCPropNetEthernetMediaSubType,FALSE,enumValArray)
        } else {
          PROPERTY_DECL2(4,kNCPropertyTypeString,CFSTR("media-sub-type"),kSCPropNetEthernetMediaSubType)
        }
        
        if (curSubType && (enumValSet = [_portOptions optionsForMediaSubType:curSubType])) {
          PROPERTY_DECL(5,kNCPropertyTypeStringEnumArray,CFSTR("media-options"),kSCPropNetEthernetMediaOptions,FALSE,enumValSet)
        } else {
          PROPERTY_DECL2(5,kNCPropertyTypeStringArray,CFSTR("media-options"),kSCPropNetEthernetMediaOptions)
        }
        
        if ((mtu = [_portOptions maxTransmitUnitSize])) {
          //  A bit of tom-foolery:  we can fit TWO 32-bit integers into the 64-bit
          //  type, so as long as we work with it that way we should be fine.  Though
          //  I'd like to see a CFRange object in the future...
          SInt32          intRange[2] = { 72 , mtu };
          CFNumberRef     range = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt64Type,(SInt64*)intRange);
          
          PROPERTY_DECL(6,kNCPropertyTypeNumberWithRange,CFSTR("mtu"),kSCPropNetEthernetMTU,FALSE,range)
          CFRelease(range);
        } else {
          PROPERTY_DECL2(6,kNCPropertyTypeNumber,CFSTR("mtu"),kSCPropNetEthernetMTU)
        }
      } else {
        count = 4;
      }
      
      _propertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return _propertyHandler;
  }

//

  - (BOOL) setValue:(CFPropertyListRef)value
    ofProperty:(CFStringRef)property
  {
    BOOL    result = [super setValue:value ofProperty:property];
    
    //  If it was the media sub-type then we need to invalidate the
    //  property handler:
    if (result && CFStringCompare(property,kSCPropNetEthernetMediaSubType,0) == kCFCompareEqualTo)
      [self invalidatePropertyHandler];
    return result;
  }
  
@end
