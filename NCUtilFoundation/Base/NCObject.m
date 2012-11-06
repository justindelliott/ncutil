//
//  ncutil3 - network configuration utility, version 3
//  NCObject
//
//  Base-level Objective-C class for ncutil plus the autorelease
//  pool class definition.
//
//  Created by Jeffrey Frey on Mon May 9 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCObject.h"
#include "NCError.h"
#include <stdlib.h>

FILE* stddbg = NULL;

#ifdef NCUTIL_USE_FOUNDATION

@interface NSDummyClass : NCObject
{}

@end

@implementation NSDummyClass

  + (void) load
  {
#ifdef NCUTIL_DEBUG
    char      fname[32];
    
    snprintf(fname,31,"ncutil-%d.debug",getpid());
    if ((stddbg = fopen(fname,"w")) == NULL)
      stddbg = stderr;
    NCLog(CFSTR("Debugging stream opened"));
#else
    stddbg = fopen("/dev/null","w");
#endif
  }

@end

@implementation NSObject(NCObjectExtensions)

  - (void) summarizeToStream:(FILE*)stream
  {
  }

@end

@implementation NSAutoreleasePool(NCAutoreleasePoolExtensions)

  - (id)drainButRetain
  {
    [self release];
    return [[NCAutoreleasePool alloc] init];
  }

@end

id
NCAllocateObject(
  Class     aClass,
  unsigned  extraBytes
)
{
  return NSAllocateObject(aClass,extraBytes,NSDefaultMallocZone());
}

#else

//
//  The default autorelease pool.  Just like in Foundation, it's up to the
//  consumer code to initially allocate an instance, e.g. in the main()
//  function:
//
//    int main(int argc,const char* argv[])
//    {
//      NCAutoreleasePool*    pool = [[NCAutoreleasePool alloc] init];
//        :
//    }
//
//  Each time a pool is sent the "init" message that pool becomes the
//  current default; when an instance is sent the "dealloc" message all
//  dependent objects are released.  The implementation works like that
//  of Mac OS X 10.4 in that a "drain" method is included to empty the pool
//  without deallocating it.
//
NCAutoreleasePool*    NCDefaultAutoreleasePool = nil;

@implementation NCObject

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    static BOOL NCObjectStandardDebugChannelOpened = NO;
    
    if (!NCObjectStandardDebugChannelOpened) {
#ifdef NCUTIL_DEBUG
      char      fname[32];
      
      snprintf(fname,31,"ncutil-%d.debug",getpid());
      if ((stddbg = fopen(fname,"w")) == NULL)
        stddbg = stderr;
      NCLog(CFSTR("Debugging stream opened"));
#else
      stddbg = fopen("/dev/null","w");
#endif
      NCObjectStandardDebugChannelOpened = YES;
    }
    
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }

//

  - (id) init
  {
    if (self = [super init])
      _references = 1;
    return self;
  }

//

  - (void) dealloc
  {
    [super free];
  }
  
//

  - (unsigned int) retainCount
  {
    return _references;
  }

//

  - (id) retain
  {
    _references++;
    return self;
  }

//

  - (void) release
  {
    if ((--_references) == 0)
      [self dealloc];
  }
  
//

  - (id) autorelease
  {
    [NCAutoreleasePool addObject:self];
    return self;
  }

//

  - (id) copy
  {
    return nil;
  }
  
//

  - (id) mutableCopy
  {
    return nil;
  }

//

  - (BOOL) isKindOfClass:(Class)aClass
  {
    return [self isKindOf:aClass];
  }
  
//

  - (BOOL) respondsToSelector:(SEL)aSelector
  {
    return [self respondsTo:aSelector];
  }

//

  - (id) performSelector:(SEL)aSelector
  {
    return [self perform:aSelector];
  }
  - (id) performSelector:(SEL)aSelector
    withObject:(id)object
  {
    return [self perform:aSelector with:object];
  }
  - (id) performSelector:(SEL)aSelector
    withObject:(id)object1
    withObject:(id)object2
  {
    return [self perform:aSelector with:object1 with:object2];
  }

//

  - (void) summarizeToStream:(FILE*)stream
  {
  }

@end

//
#pragma mark -
//

typedef struct _NCAutoreleasePoolNode {
  struct _NCAutoreleasePoolNode*  _link;
  
  unsigned int    _capacity,_count;
  id              _objects[];
} NCAutoreleasePoolNode;

#define AUTORELEASE_POOL_CAPACITY   32
#define AUTORELEASE_POOL_HEADNODE   ((NCAutoreleasePoolNode*)_reserved1)
#define AUTORELEASE_POOL_CURNODE    ((NCAutoreleasePoolNode*)_reserved2)

NCAutoreleasePoolNode*
NCAutoreleasePoolNodeAlloc(
  unsigned int            capacity,
  NCAutoreleasePoolNode*  parent
)
{
  if ((parent == NULL) || (parent && parent->_link == NULL)) {
    size_t                  bytes = sizeof(NCAutoreleasePoolNode) + capacity * sizeof(id);
    NCAutoreleasePoolNode*  node;
    
    //  Round the bytes up to nearest 4K:
    bytes = bytes + ( (bytes % 4096) ? (4096 - (bytes % 4096)) : 0 );
    node = (NCAutoreleasePoolNode*)malloc(bytes);
    
    fprintf(stddbg,":: NCAutoreleasePoolNodeAlloc:  requested capacity: %u\n",capacity);
    fprintf(stddbg,":: NCAutoreleasePoolNodeAlloc:  requested bytes:    %ld\n",bytes); 
    if (node) {
      if (parent)
        parent->_link = node;
      
      node->_link = NULL;
      node->_capacity = (bytes - sizeof(NCAutoreleasePoolNode)) / sizeof(id);
      node->_count = 0;
      fprintf(stddbg,":: NCAutoreleasePoolNodeAlloc:  granted capacity:   %u\n",node->_capacity);
    }
    return node;
  }
  return NULL;
}

//

NCAutoreleasePoolNode*
NCAutoreleasePoolNodeAddObject(
  NCAutoreleasePoolNode*  node,
  id                      object
)
{
  if (node) {
    //  Have we been filled-up?
    if (node->_capacity == node->_count) {
      //  Try to make a new node:
      NCAutoreleasePoolNode*  newNode = NCAutoreleasePoolNodeAlloc(AUTORELEASE_POOL_CAPACITY,node);
      
      if (newNode == NULL)
        return node;
      node = newNode;
    }
    //  Add the object:
    node->_objects[node->_count++] = object;
  }
  return node;
}

//

void
NCAutoreleasePoolNodeRelease(
  NCAutoreleasePoolNode*  node
)
{
  if (node) {
    //  Let our child release any objects first:
    if (node->_link)
      NCAutoreleasePoolNodeRelease(node->_link);
    //  Send all objects in this node a "release" message:
    while(node->_count--)
      [node->_objects[node->_count] release];
    //  Set the object count to zero:
    node->_count = 0;
  }
}

//

void
NCAutoreleasePoolNodeDealloc(
  NCAutoreleasePoolNode*  node
)
{
  if (node) {
    //  Deallocate our child first:
    if (node->_link)
      NCAutoreleasePoolNodeDealloc(node->_link);
    //  Send all objects in this node a "release" message:
    while (node->_count--)
      [node->_objects[node->_count] release];
    //  Deallocate this node:
    free(node);
  }
}

//

@implementation NCAutoreleasePool

  - (id) init
  {
    if (self = [super init]) {
      _reserved1 = _reserved2 = (void*)NCAutoreleasePoolNodeAlloc(AUTORELEASE_POOL_CAPACITY,NULL);
      if (AUTORELEASE_POOL_HEADNODE == NULL) {
        [self release];
        return nil;
      }
      NCDefaultAutoreleasePool = self;
    }
    return self;
  }
  
//

  - (void) dealloc
  {
    NCAutoreleasePoolNodeDealloc(AUTORELEASE_POOL_HEADNODE);
    [super dealloc];
  }

//

  + (void) addObject:(id)anObject
  {
    if (NCDefaultAutoreleasePool == nil)
      NCDefaultAutoreleasePool = [[NCAutoreleasePool alloc] init];
    [NCDefaultAutoreleasePool addObject:anObject];
  }

//

  - (void) addObject:(id)anObject
  {
    _reserved2 = NCAutoreleasePoolNodeAddObject(_reserved2,anObject);
  }
  
//

  - (void)drain
  {
    [self release];
  }

//

  - (id)drainButRetain
  {
    NCAutoreleasePoolNodeRelease(AUTORELEASE_POOL_HEADNODE);
    _reserved2 = _reserved1;
    return self;
  }

@end

id
NCAllocateObject(
  Class     aClass,
  unsigned  extraBytes
)
{
  return class_createInstance(aClass,extraBytes);
}

#endif // !NCUTIL_USE_FOUNDATION
