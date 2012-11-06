//
//  ncutil3 - network configuration utility, version 3
//  NCPropertyHandler
//
//  Maintains an entire list of properties.
//
//  Created by Jeffrey Frey on Wed Jun 1 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCObject.h"
#include "NCProperty.h"

/*!
  @class NCPropertyEnumerator
  Enumerates the properties contained in an instance of <TT>NCPropertyHandler</TT>.
*/
@interface NCPropertyEnumerator : NCObject
{
  NCPropertyRef*      _curProp;
  NCPropertyRef*      _endProp;
}

/*!
  @method nextProperty
  Returns a reference to the next available property for the parent <TT>NCPropertyHandler</TT>
  or <TT>NULL</TT> if no more properties remain.
*/
- (NCPropertyRef) nextProperty;

@end

/*!
  @class NCPropertyHandler
  Instances of <TT>NCPropertyHandler</TT> wrap arrays of property descriptions.
*/
@interface NCPropertyHandler : NCObject
{
  CFIndex           _propertyCount;
  NCPropertyRef*    _propertyList;
}

/*!
  @method propertyHandlerWithProperties:count:
  Returns an autoreleased <TT>NCPropertyHandler</TT> instance that contains the properties
  contained in <TT>propList</TT>.  The instance uses the NCPropertyRetain() function to
  retain a reference to each property in <TT>propList</TT>.
*/
+ (NCPropertyHandler*) propertyHandlerWithProperties:(NCPropertyRef*)propList count:(CFIndex)count;

/*!
  @method propertyCount
  Returns the number of properties present in the receiver.
*/
- (CFIndex) propertyCount;
/*!
  @method propertyWithUIName:
  If present in the receiver, returns the NCProperty with the given user
  interface name.
*/
- (NCPropertyRef) propertyWithUIName:(CFStringRef)propUIName;
/*!
  @method propertyWithSCName:
  If present in the receiver, returns the NCProperty with the given
  SystemConfiguration name.
*/
- (NCPropertyRef) propertyWithSCName:(CFStringRef)propSCName;
/*!
  @method propertyEnumerator
  Returns an autoreleased instance of <TT>NCPropertyEnumerator</TT> that will interate
  over the properties contained in the receiver.
*/
- (NCPropertyEnumerator*) propertyEnumerator;
/*!
  @method summarizeHandledPropertiesToStream:
  Writes a summary of all the properties contained in the receiver.  The summary presents
  information on the type and user interface name for each parameter, as well as supplemental
  data such as the acceptable values in a string enumeration.
*/
- (void) summarizeHandledPropertiesToStream:(FILE*)stream;
/*!
  @method summarizeHandledPropertiesToStream:locked:
  Writes a summary of all the properties contained in the receiver.  The summary presents
  information on the type and user interface name for each parameter, as well as supplemental
  data such as the acceptable values in a string enumeration.  The <TT>locked</TT> argument
  provides an override mechanism for the per-property locks.
*/
- (void) summarizeHandledPropertiesToStream:(FILE*)stream locked:(BOOL)locked;

@end
