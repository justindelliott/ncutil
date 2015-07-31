//
//  ncutil3 - network configuration utility, version 3
//  NCTree
//
//  An Objective-C class that represents a node in a tree
//  structure.
//
//  Created by Jeffrey Frey on Mon May 9 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCTree.h"

@interface NCTree(NCTreePrivate)

- (void) setParent:(NCTree*)parent;
- (void) setChild:(NCTree*)child;
- (void) setSibling:(NCTree*)sibling;

- (void) removeChild:(NCTree*)child;

- (void) writeSummaryToStream:(FILE*)stream indent:(unsigned int)indent;

@end

@implementation NCTree(NCTreePrivate)

  - (void) setParent:(NCTree*)parent
  {
    _parent = parent;
  }
  - (void) setChild:(NCTree*)child
  {
    if (child != _child) {
      if (child) child = [child retain];
      if (_child) [_child release];
      _child = child;
    }
  }
  - (void) setSibling:(NCTree*)sibling
  {
    if (sibling != _sibling) {
      if (sibling) sibling = [sibling retain];
      if (_sibling) [_sibling release];
      _sibling = sibling;
    }
  }
  
//

  - (void) removeChild:(NCTree*)child
  {
    NCTree*     children = _child;
    NCTree*     prevChild = nil;
    BOOL        removed = YES;
    id          delegate = (_delegate ? _delegate : [[self root] delegate]);
    
    if (delegate && [delegate respondsToSelector:@selector(shouldRemoveChildNode:)])
      removed = [delegate shouldRemoveChildNode:child];
    else if ([self respondsToSelector:@selector(shouldRemoveChildNode:)])
      removed = [self shouldRemoveChildNode:child];
    
    fprintf(stddbg,"{ removeChild(%d,%p,%p)...",removed,children,child); fflush(stddbg);
    
    if (removed) {
      while (children) {
        if (children == child) {
          if (prevChild) {
            prevChild->_sibling = child->_sibling;
            child->_sibling = nil;
            child->_parent = nil;
          } else {
            //  Primary child:
            _child = _child->_sibling;
            child->_sibling = nil;
            child->_parent = nil;
          }
          break;
        }
        prevChild = children;
        children = [children sibling];
      }
      fprintf(stddbg,"notifying delegates..."); fflush(stddbg);
      if (delegate && [delegate respondsToSelector:@selector(didRemoveChildNode:)])
        [delegate didRemoveChildNode:child];
      else if ([self respondsToSelector:@selector(didRemoveChildNode:)])
        [self didRemoveChildNode:child];
    }
    fprintf(stddbg,"done. }"); fflush(stddbg);
  }
  
//

  - (void) writeSummaryToStream:(FILE*)stream
    indent:(unsigned int)indent
  {
    int   count = indent;
    
    while (count--) fputc(' ',stream);
    fprintf(stream,"|-NCTree@%p(%u) { %p }\n",self,[self retainCount],_object);
    if (_child) [_child writeSummaryToStream:stream indent:indent + 2];
    if (_sibling) [_sibling writeSummaryToStream:stream indent:indent];
  }

@end

//
#pragma mark -
//

@implementation NCTree

  + (NCTree*) rootTreeNodeWithObject:(id)object
  {
    return [[[NCTree alloc] initWithObject:object] autorelease];
  }
  
//

  + (NCTree*) treeNodeWithParent:(NCTree*)parent
    object:(id)object
  {
    return [[[NCTree alloc] initWithParent:parent object:object] autorelease];
  }
  
//

  + (NCTree*) treeNodeAsSiblingOf:(NCTree*)sibling
    object:(id)object
  {
    return [[[NCTree alloc] initAsSiblingOf:sibling object:object] autorelease];
  }

//

  - (id) initWithObject:(id)object
  {
    if (self = [super init])
      [self setObject:object];
    return self;
  }
  
//

  - (id) initWithParent:(NCTree*)parent
    object:(id)object
  {
    if (self = [self initWithObject:object])
      [parent appendChild:self];
    return self;
  }

//

  - (id) initAsSiblingOf:(NCTree*)sibling
    object:(id)object
  {
    if (self = [self initWithObject:object])
      [sibling insertSibling:self];
    return self;
  }
  
//

  - (void) dealloc
  {
    //  Try deallocating a child, then a sibling, then our object, and finally
    //  just remove us from our parent:
    fprintf(stddbg,"{\n  self = %p (%u)\n",self,[self retainCount]);
    if (_child) {
      fprintf(stddbg,"  dealloc child %p\n",_child);
      [_child release]; _child = nil;
    }
    
    if (_sibling) {
      fprintf(stddbg,"  dealloc sibling %p\n",_sibling);
      [_sibling release]; _sibling = nil;
    }
    
    if (_parent) {
      fprintf(stddbg,"  remove %p from parent %p\n",self,_parent);
      [_parent removeChild:self]; _parent = nil;
    }
    
    if (_object) {
      fprintf(stddbg,"  dealloc object %p\n",_object);
      [_object release]; _object = nil;
    }
    
    fprintf(stddbg,"}\n");
    
    if (_delegate) [_delegate release];
    [super dealloc];
  }

//

  - (void) summarizeToStream:(FILE*)stream
  {
    [self writeSummaryToStream:stream indent:0];
  }

//

  - (NCTree*) root
  {
    if (_parent)
      return [_parent root];
    return self;
  }
  
//

  - (NCTree*) parent { return _parent; }
  - (NCTree*) sibling { return _sibling; }
  - (NCTree*) child { return _child; }

//

  - (id) object { return _object; }
  - (void) setObject:(id)object
  {
    if (object != _object) {
      if (object) object = [object retain];
      if (_object) [_object release];
      _object = object;
    }
  }

//

  - (id) delegate { return _delegate; }
  - (void) setDelegate:(id)delgate
  {
    if (delgate != _delegate) {
      if (delgate) delgate = [delgate retain];
      if (_delegate) [_delegate release];
      _delegate = delgate;
    }
  }

//

  - (unsigned int) childCount
  {
    unsigned int    count = 0;
    NCTree*         child = _child;
    
    while (child) {
      count++;
      child = [child sibling];
    }
    return count;
  }
  
//

  - (NCTree*) childAtIndex:(unsigned int)index
  {
    if (_child) {
      NCTree*         child = _child;
      
      while (child && index--)
        child = [child sibling];
      return child;
    }
    return nil;
  }
  
//

  - (void) prependChild:(NCTree*)child
  {
    BOOL      added = YES;
    id        delegate = (_delegate ? _delegate : [[self root] delegate]);
    
    if (delegate && [delegate respondsToSelector:@selector(shouldAddChildNode:)])
      added = [delegate shouldAddChildNode:child];
    else if ([self respondsToSelector:@selector(shouldAddChildNode:)])
      added = [self shouldAddChildNode:child];
    
    if (added) {
      if (_child) {
        [child setSibling:_child];
        [_child release];
      }
      _child = [child retain];
      [_child setParent:self];
      if (delegate && [delegate respondsToSelector:@selector(didAddChildNode:)])
        [delegate didAddChildNode:_child];
      else if ([self respondsToSelector:@selector(didAddChildNode:)])
        [self didAddChildNode:_child];
    }
  }
  
//

  - (void) appendChild:(NCTree*)child
  {
    BOOL      added = YES;
    id        delegate = (_delegate ? _delegate : [[self root] delegate]);
    
    if (delegate && [delegate respondsToSelector:@selector(shouldAddChildNode:)])
      added = [delegate shouldAddChildNode:child];
    else if ([self respondsToSelector:@selector(shouldAddChildNode:)])
      added = [self shouldAddChildNode:child];
    
    if (added) {
      if (_child) {
        NCTree*   curChild = _child;
        NCTree*   nextChild;
        
        while ((nextChild = [curChild sibling]))
          curChild = nextChild;
        [curChild setSibling:child];
      } else
        _child = [child retain];
      [child setParent:self];
      if (delegate && [delegate respondsToSelector:@selector(didAddChildNode:)])
        [delegate didAddChildNode:_child];
      else if ([self respondsToSelector:@selector(didAddChildNode:)])
        [self didAddChildNode:_child];
    }
  }
  
//

  - (void) insertSibling:(NCTree*)sibling
  {
    BOOL      added = YES;
    id        delegate = (_delegate ? _delegate : [[self root] delegate]);
    
    if (delegate && [delegate respondsToSelector:@selector(shouldAddSiblingNode:)])
      added = [delegate shouldAddSiblingNode:sibling];
    else if ([self respondsToSelector:@selector(shouldAddSiblingNode:)])
      added = [self shouldAddSiblingNode:sibling];
    
    if (added) {
      if (_sibling) {
        [sibling setSibling:_sibling];
        [_sibling release];
      }
      _sibling = [sibling retain];
      [_sibling setParent:_parent];
      if (delegate && [delegate respondsToSelector:@selector(didAddSiblingNode:)])
        [delegate didAddSiblingNode:_sibling];
      else if ([self respondsToSelector:@selector(didAddSiblingNode:)])
        [self didAddSiblingNode:_sibling];
    }
  }
  
//

  - (void) removeFromParent
  {
    if (_parent)
      [_parent removeChild:self];
  }
  
//

  - (void) removeAllChildren
  {
    NCTree*         child = _child;
    
    while (child) {
      NCTree*       nextChild = [child sibling];
      
      [child release];
      child = nextChild;
    }
    _child = nil;
  }
  
//

  - (void) makeNodes:(int)nodesToTouch
    performSelector:(SEL)aSelector
  {
    NCTree*       target;
    
    if (nodesToTouch & kNCTreeNodeApplyToSelf)
      [self performSelector:aSelector];
      
    if (nodesToTouch & kNCTreeNodeApplyToSibling && (target = (NCTree*)[self sibling])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToSiblings) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToSiblings)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf performSelector:aSelector];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToSiblings) | kNCTreeNodeApplyToSelf) performSelector:aSelector];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector];
    }
    
    if (nodesToTouch & kNCTreeNodeApplyToChild && (target = (NCTree*)[self child])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToChildren) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToChildren)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings performSelector:aSelector];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToChildren) | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings) performSelector:aSelector];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector];
    }
  }
  
//

  - (void) makeNodes:(int)nodesToTouch
    performSelector:(SEL)aSelector
    withObject:(id)object
  {
    NCTree*       target;
    
    if (nodesToTouch & kNCTreeNodeApplyToSelf)
      [self performSelector:aSelector withObject:object];
      
    if (nodesToTouch & kNCTreeNodeApplyToSibling && (target = (NCTree*)[self sibling])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToSiblings) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToSiblings)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToSiblings) | kNCTreeNodeApplyToSelf) performSelector:aSelector withObject:object];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object];
    }
    
    if (nodesToTouch & kNCTreeNodeApplyToChild && (target = (NCTree*)[self child])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToChildren) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToChildren)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings performSelector:aSelector withObject:object];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToChildren) | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings) performSelector:aSelector withObject:object];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object];
    }
  }
  
//

  - (void) makeNodes:(int)nodesToTouch
    performSelector:(SEL)aSelector
    withObject:(id)object1
    withObject:(id)object2
  {
    NCTree*       target;
    
    if (nodesToTouch & kNCTreeNodeApplyToSelf)
      [self performSelector:aSelector withObject:object1 withObject:object2];
      
    if (nodesToTouch & kNCTreeNodeApplyToSibling && (target = (NCTree*)[self sibling])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToSiblings) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToSiblings)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object1 withObject:object2];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToSiblings) | kNCTreeNodeApplyToSelf) performSelector:aSelector withObject:object1 withObject:object2];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object1 withObject:object2];
    }
    
    if (nodesToTouch & kNCTreeNodeApplyToChild && (target = (NCTree*)[self child])) {
      //  Look for the plurality:
      if (nodesToTouch & kNCTreeNodeApplyToChildren) {
        if (nodesToTouch & kNCTreeNodeDeepApplyToChildren)
          [target makeNodes:nodesToTouch | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings performSelector:aSelector withObject:object1 withObject:object2];
        else
          [target makeNodes:((nodesToTouch & ~kNCTreeNodeApplyToChildren) | kNCTreeNodeApplyToSelf | kNCTreeNodeApplyToSiblings) performSelector:aSelector withObject:object1 withObject:object2];
      } else
        [target makeNodes:kNCTreeNodeApplyToSelf performSelector:aSelector withObject:object1 withObject:object2];
    }
  }

//

  - (BOOL) descendsFromNode:(NCTree*)parent
  {
    NCTree*     pChain = _parent;
    
    while (pChain) {
      if (pChain == parent)
        return YES;
      pChain = [pChain parent];
    }
    return NO;
  }
  
//

  - (BOOL) isDirectChildOfNode:(NCTree*)parent
  {
    if (_parent == parent)
      return YES;
    return NO;
  }

@end
