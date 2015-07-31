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

#import "NCPropertyHandler.h"
#include "CFAdditions.h"
#include "NCError.h"

@implementation NCPropertyEnumerator

  - (id) initWithBaseProperty:(NCPropertyRef*)baseProp
    count:(CFIndex)count
  {
    if (self = [super init]) {
      _curProp = baseProp;
      _endProp = baseProp + count;
    }
    return self;
  }
  
//

  - (NCPropertyRef) nextProperty
  {
    if (_curProp < _endProp) {
      NCPropertyRef prop = *_curProp;
      _curProp++;
      return prop;
    }
    return NULL;
  }

@end

//
#pragma mark -
//

@interface NCPropertyHandler(NCPropertyHandlerPrivate)

- (id) initWithStaticList:(NCPropertyRef*)propList count:(CFIndex)count;
- (void) setupList:(NCPropertyRef*)propList;

@end

@implementation NCPropertyHandler(NCPropertyHandlerPrivate)

  - (id) initWithStaticList:(NCPropertyRef*)propList
    count:(CFIndex)count
  {
    if (self = [super init]) {
      _propertyCount = count;
      _propertyList = (NCPropertyRef*)(&_propertyList + 1);
      [self setupList:propList];
    }
    return self;
  }

//

  - (void) setupList:(NCPropertyRef*)propList
  {
    CFIndex         count = _propertyCount;
    NCPropertyRef*  dst = _propertyList;
    
    //  Create our localized copy of the list:
    while (count--) {
      *dst = NCPropertyRetain(*propList);
      dst++;
      propList++;
    }
    //  Now we need to sort the list; none of these lists
    //  are too large, so we'll just do a bubble sort:
    count = _propertyCount;
    while (count--) {
      unsigned int  altCount = (UInt)count;
      
      dst = _propertyList;
      while (altCount--) {
        if (CFStringCompare(NCPropertyGetUIName(*dst),NCPropertyGetUIName(*(dst + 1)),0) == kCFCompareGreaterThan) {
          NCPropertyRef  tmpProp = *dst;
          *dst = *(dst + 1);
          *(dst + 1) = tmpProp;
        }
        dst++;
      }
    }
  }

@end

int
__NCPropCmp(
  const void*   key,
  const void*   obj
)
{
  return CFStringCompare((CFStringRef)key,NCPropertyGetUIName(*((NCPropertyRef*)obj)),0);
}

@implementation NCPropertyHandler

  + (NCPropertyHandler*) propertyHandlerWithProperties:(NCPropertyRef*)propList
    count:(CFIndex)count;
  {
    unsigned int        extraBytes = sizeof(NCPropertyRef) * (UInt)count;
    NCPropertyHandler*  result = NCAllocateObject(self,extraBytes);
    
    if (result)
      result = [result initWithStaticList:propList count:count];
    return result;
  }
  
//

  - (void) dealloc
  {
    CFIndex         count = _propertyCount;
    NCPropertyRef*  prop = _propertyList;
    
    while (count--) {
      NCPropertyRelease(*prop);
      prop++;
    }
    [super dealloc];
  }

//

  - (CFIndex) propertyCount { return _propertyCount; }

//

  - (NCPropertyRef) propertyWithUIName:(CFStringRef)propUIName
  {
    //  Do a binary search through our localized list:
    NCPropertyRef*    result = bsearch(
                                  (void*)propUIName,
                                  (const void*)_propertyList,
                                  (size_t)_propertyCount,
                                  sizeof(NCPropertyRef),
                                  __NCPropCmp
                                );
    if (result)
      return (*result);
    return NULL;
  }

//

  - (NCPropertyRef) propertyWithSCName:(CFStringRef)propSCName
  {
    CFIndex         count = _propertyCount;
    NCPropertyRef*  prop = _propertyList;
    
    while (count--) {
      if (CFStringCompare(propSCName,NCPropertyGetSCName(*prop),0) == kCFCompareEqualTo)
        return *prop;
      prop++;
    }
    return NULL;
  }

//

  - (NCPropertyEnumerator*) propertyEnumerator
  {
    return [[[NCPropertyEnumerator alloc] initWithBaseProperty:_propertyList count:_propertyCount] autorelease];
  }
  
//

  - (void) summarizeHandledPropertiesToStream:(FILE*)stream
  {
    [self summarizeHandledPropertiesToStream:stream locked:NO];
  }
  - (void) summarizeHandledPropertiesToStream:(FILE*)stream
    locked:(BOOL)locked
  {
    CFIndex         count = _propertyCount;
    NCPropertyRef*  prop = _propertyList;
    
    while (count--) {
      NCPropertySummarize(*prop,stream,locked);
      prop++;
    }
  }

@end
