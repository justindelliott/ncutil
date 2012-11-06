//
//  ncutil3 - network configuration utility, version 3
//  NCPortOptions
//
//  Moved over from NCUtilFoundation 1.0.  Retrieves hardware-level
//  configuration options via IOKit to make our interface a bit
//  more intelligent.
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCObject.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/network/IONetworkMedium.h>

/*!
  @function NCCreateMediumTypeString
  Given a numerical type word (definitions are in if_media.h
  and IONetworkMedium.h) returns a <TT>CFString</TT>.  Used to
  look-up specific medium types in the medium dictionary
  returned by the IOKit.
  @param type a medium descriptor formed as a bitwise OR of
  type, sub-type, and options for the media in question.
  @result a <TT>CFString</TT> that should be released when
  you are finished with it
*/
CF_INLINE CFStringRef
NCCreateMediumTypeString(
  IOMediumType    type
)
{
  return CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%08X"),type);
}
/*!
  @function NCMediaDescriptor_CFStringForSubType
  Given a medium descriptor word, creates a <TT>CFString</TT> which
  matches the sub-type portion of the descriptor.  The routine works
  on all media types defined by if_media.h
  @param medium a medium descriptor
  @result returns <TT>NULL</TT> if the descriptor did not describe
  any defined media types, otherwise returns a <TT>CFString</TT> which
  should be released when you are finished with it
*/
CFStringRef NCMediaDescriptor_CFStringForSubType(IOMediumType medium);
/*!
  @function NCMediaDescriptor_CFStringsForCommonOptions
  Given a medium descriptor word, this function adds <TT>CFString</TT>
  records for any common options it finds in the descriptor to a
  <TT>CFSet</TT>.  If the incoming <TT>CFSet</TT> parameter was
  <TT>NULL</TT>, then a new <TT>CFSet</TT> is created if any options
  are encountered for this particular descriptor.
  @param medium a medium descriptor
  @param reuseSet pass <TT>NULL</TT> and a new set will be created;
  otherwise, new strings are added to this <TT>CFSet</TT> as they
  are found
  @result if you provided an existing <TT>CFSet</TT> its value will
  be returned in all cases; otherwise, the return value will be <TT>NULL</TT>
  if no options were found (and hence no <TT>CFSet</TT> needed to be
  created anyway) or a new <TT>CFSet</TT> is returned which you should
  release when you are finished using
*/
CFMutableSetRef NCMediaDescriptor_CFStringsForCommonOptions(IOMediumType medium,CFMutableSetRef reuseSet);
/*!
  @function NCMediaDescriptor_CFStringsForMediaSpecificOptions
  Given a medium descriptor word, this function adds <TT>CFString</TT>
  records for any media-specific options it finds in the descriptor to a
  <TT>CFSet</TT>.  If the incoming <TT>CFSet</TT> parameter was
  <TT>NULL</TT>, then a new <TT>CFSet</TT> is created if any options
  are encountered for this particular descriptor.
  @param medium a medium descriptor
  @param reuseSet pass <TT>NULL</TT> and a new set will be created;
  otherwise, new strings are added to this <TT>CFSet</TT> as they
  are found
  @result if you provided an existing <TT>CFSet</TT> its value will
  be returned in all cases; otherwise, the return value will be <TT>NULL</TT>
  if no options were found (and hence no <TT>CFSet</TT> needed to be
  created anyway) or a new <TT>CFSet</TT> is returned which you should
  release when you are finished using
*/
CFMutableSetRef NCMediaDescriptor_CFStringsForMediaSpecificOptions(IOMediumType medium,CFMutableSetRef reuseSet);

/*!
  @class NCPortOptions
  @abstract Represents the allowable options and sub-types for a
  port
  @discussion The <TT>NCPortOptions</TT> class uses the IOKit to
  retrieve hardware-level options for a particular network port
  and creates a dictionary of media sub-types for the port as well
  as a set of options available for each sub-type.  For instance,
  consider the following ethernet port and the medium descriptors
  returned for it by IOKit:
<PRE>
    00000020
    00000022
    00100023
    00100026 
    00200023
    00200026
    08100023
    08100026
</PRE>
  Initializing an <TT>NCPortOptions</TT> object for this port will
  yield the following data (as shown via the <TT>summarizeToStream:</TT>
  method):
<PRE>
    NCPortOptions[1] { mtu: 1500 
      100baseTX: half-duplex | hw-loopback | full-duplex 
      none: 
      10baseT/UTP: half-duplex | hw-loopback | full-duplex 
      autoselect: 
    }
</PRE>
  The class also defines methods for retrieving an array of the
  sub-type names for the port, as well as for retrieving the <TT>CFSet</TT>
  of options defined for any particular sub-type.  These are
  meant to be convenience methods, since the user may also
  request the dictionary itself and access these components
  by hand.<BR>
  <BR>
  The class also features a medium-descriptor validation method
  which can be used with the numerical constants defined in
  <TT>if_media.h</TT> to determine whether a particular
  medium-descriptor is valid in the context of this port.
*/
@interface NCPortOptions : NCObject
{
  CFDictionaryRef         mediumTypesFromIOKit;
  CFMutableDictionaryRef  portOptionsDictionary;
  CFIndex                 maxTransmitUnitSize;
}

/*!
  @method portOptionsWithBSDDevice:
  Creates an autoreleased instance of <TT>NCPortOptions</TT> which is
  initialized to represent the sub-types and options available for
  the specified BSD-level network port.  For example:
<PRE>
    NCPortOptions*    opts = [NCPortOptions portOptionsWithBSDDevice:CFSTR("en0")];
    
    if (opts)
      [opts summarizeToStream:stdout];
</PRE>
  This code attempts to create a port options object for the built-in
  ethernet device, <TT>en0</TT>, and if successful summarizes the
  object to the console.
  @result returns <TT>nil</TT> if the object could not be created
*/
+ (NCPortOptions*) portOptionsWithBSDDevice:(CFStringRef)devname;
/*!
  @method portOptionsWithIOKitInterfaceObject:
  Creates an autoreleased instance of <TT>NCPortOptions</TT> which is
  initialized to represent the sub-types and options available for
  the specified IOKit interface-level object.  For instance, the user
  could query IOKit for all ethernet interfaces defined in the service
  domain, and then iterate through each interface and create a port
  options object.
  @result returns <TT>nil</TT> if the object could not be created
*/
+ (NCPortOptions*) portOptionsWithIOKitInterfaceObject:(io_object_t)iface;
/*!
  @method initWithIOKitInterfaceObject:
  Initializes an allocated instance of <TT>NCPortOptions</TT>
  to represent the sub-types and options available for
  the specified IOKit interface-level object.
  @result returns <TT>nil</TT> if any errors were encounted while
  attempting to gather the necessary data from the IOKit
*/
- (id) initWithIOKitInterfaceObject:(io_object_t)iface;
/*!
  @method portOptionsDictionary
  Returns the dictionary of sub-types and options for this object.
  The dictionary uses the media sub-types as keys, and each key
  has a value of either <TT>kCFNull</TT> if no options exist, or
  a value of a <TT>CFSetRef</TT> of its options.
*/
- (CFDictionaryRef) portOptionsDictionary;
/*!
  @method maxTransmitUnitSize
  Returns the maximum allowable transmit unit size for the port
  this object references.
*/
- (CFIndex) maxTransmitUnitSize;
/*!
  @method validMediaSubType:
  Returns <TT>YES</TT> if the given media sub-type name exists
  for the port this object references.
*/
- (BOOL) validMediaSubType:(CFStringRef)subTypeName;
/*!
  @method mediaSubTypes
  Returns an array containing all of the sub-types for this
  port (as <TT>CFString</TT> objects).  You are responsible for
  releasing the returned object when you are finished with it.
*/
- (CFArrayRef) mediaSubTypes;
/*!
  @method optionsForMediaSubType:
  For the given media sub-type (as a <TT>CFString</TT>) returns
  either a <TT>CFSetRef</TT> object containing all of the sub-type's
  allowable options, or returns <TT>NULL</TT> when the sub-type
  does not exist or if the sub-type has no options associated
  with it.  You should NOT release the returned <TT>CFArray</TT>
  object.
*/
- (CFSetRef) optionsForMediaSubType:(CFStringRef)subTypeName;
/*!
  @method validOption:ForMediaSubType:
  For the given media sub-type (as a <TT>CFString</TT>) returns
  whether or not the provided option (also as a <TT>CFString</TT>)
  is allowable.
*/
- (BOOL) validOption:(CFStringRef)option forMediaSubType:(CFStringRef)subTypeName;
/*!
  @method validMediumDescriptor:
  Returns <TT>YES</TT> if the medium descriptor passed to it
  exists for the port which this object references.
*/
- (BOOL) validMediumDescriptor:(IOMediumType)medium;

@end
