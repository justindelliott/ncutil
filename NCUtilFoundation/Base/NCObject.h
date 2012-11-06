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

/*!
  @header NCObject
  <TT>NCObject</TT> is the root-class for all classes defined in the
  NCUtilFoundation.  In this release of the library the <TT>NCObject</TT>
  class is defined such that all of the methods directly declared by
  it are named according to <TT>NSObject</TT> conventions.  With the specification
  of a single compile-time flag, <TT>NCUTIL_USE_FOUNDATION</TT> you can compile
  the NCUtilFoundation library on top of the Foundation.  This is, of course,
  quite useful for those who wish to use the NCUtilFoundation in Cocoa-based
  applications.
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include <CoreFoundation/CoreFoundation.h>

#ifdef NCUTIL_USE_FOUNDATION

#pragma warn "Using Mac OS X Foundation classes!"

#import <Foundation/NSObject.h>
#import <Foundation/NSAutoreleasePool.h>

#define NCObject            NSObject
#define NCAutoreleasePool   NSAutoreleasePool
#define NCComparisonResult  NSComparisonResult
#define NCOrderedAscending  NSOrderedAscending
#define NCOrderedSame       NSOrderedSame
#define NCOrderedDescending NSOrderedDescending
#define NCNotFound          NSNotFound

@interface NSObject(NCObjectExtensions)

- (void) summarizeToStream:(FILE*)stream;

@end

@interface NSAutoreleasePool(NCAutoreleasePoolExtensions)

- (id) drainButRetain;

@end

#else

#import <objc/Object.h>

#ifndef FOUNDATION_STATIC_INLINE
#define FOUNDATION_STATIC_INLINE static inline
#endif

#ifndef FOUNDATION_EXPORT
#define FOUNDATION_EXPORT extern
#endif

typedef enum _NCComparisonResult {
  NCOrderedAscending = -1,
  NCOrderedSame,
  NCOrderedDescending
} NCComparisonResult;

enum {NCNotFound = 0x7fffffff};

@interface NCObject : Object
{
  unsigned int      _references;
}

- (void) dealloc;
- (unsigned int) retainCount;
- (id) retain;
- (void) release;
- (id) autorelease;

- (id) copy;
- (id) mutableCopy;

- (BOOL) isKindOfClass:(Class)aClass;

- (BOOL) respondsToSelector:(SEL)aSelector;

- (id) performSelector:(SEL)aSelector;
- (id) performSelector:(SEL)aSelector withObject:(id)object;
- (id) performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (void) summarizeToStream:(FILE*)stream;

@end

/*!
  @class NCAutoreleasePool
  Implements an autorelease pool.  Objects are stored as a linked-list of
  individual object reference arrays.  Each node of the list is allocated
  as a single page of memory for efficiency.
*/
@interface NCAutoreleasePool : NCObject
{
  @private
  void*           _reserved1;
  void*           _reserved2;
}

+ (void) addObject:(id)anObject;
- (void) addObject:(id)anObject;

- (void) drain;
- (id) drainButRetain;

@end

#endif

FOUNDATION_EXPORT id NCAllocateObject(Class aClass,unsigned extraBytes);

extern FILE* stddbg;
