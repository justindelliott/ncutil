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

#import "NCObject.h"

/*!
  @enum NCTree node selection
  The values in this enumeration are used with the <TT>makeNodes:performSelector:</TT>
  methods of <TT>NCTree</TT>.
  @constant kNCTreeNodeApplyToSelf Invoke the selector on the node itself
  
  @constant kNCTreeNodeApplyToSibling Invoke the selector on the node's sibling
  @constant kNCTreeNodeApplyToSiblings Invoke the selector on the node's sibling chain
  @constant kNCTreeNodeDeepApplyToSiblings Invoke the selector on the node's sibling chain and all sibling's children
  
  @constant kNCTreeNodeApplyToChild Invoke the selector on the node's child
  @constant kNCTreeNodeApplyToChildren Invoke the selector on the node's chain of children
  @constant kNCTreeNodeDeepApplyToChildren Invoke the selector on the node's chain of children and all children's children
  
  @constant kNCTreeNodeApplyToAll Invoke the selector on all nodes attached to the receiver
*/
enum {
  kNCTreeNodeApplyToSelf            = 1 << 0,
  kNCTreeNodeApplyToSibling         = 1 << 1,
  kNCTreeNodeApplyToSiblings        = 1 << 1 | 1 << 2,
  kNCTreeNodeDeepApplyToSiblings    = 1 << 1 | 1 << 2 | 1 << 3,
  kNCTreeNodeApplyToChild           = 1 << 4,
  kNCTreeNodeApplyToChildren        = 1 << 4 | 1 << 5,
  kNCTreeNodeDeepApplyToChildren    = 1 << 4 | 1 << 5 | 1 << 6,
  kNCTreeNodeApplyToAll             = kNCTreeNodeApplyToSelf | kNCTreeNodeDeepApplyToSiblings | kNCTreeNodeDeepApplyToChildren
};

/*!
  @class NCTree
  An instance of the <TT>NCTree</TT> class represents a single
  node in a tree hierarchy.  A <I>root node</I> is an instance that
  has no parent node associated with it.  Every node can have one
  <I>sibling node</I> that shares its parent node but has its own
  child node.  A <I>sibling node</I> exists at the same level of
  the tree hierarchy while a <I>child node</I> lives in the next
  lower level of the hierarchy.  An <TT>NCTree</TT> node sends
  <TT>retain</TT> and <TT>release</TT> messages to its sibling and
  child nodes, but never to its parent node.<BR>
  <BR>
  It is possible to have more than one root node in a tree since
  sibling nodes are allowed for any node.<BR>
  <BR>
  Every node can have an object associated with it.  You should
  only use objects that descend from the <TT>NCObject</TT> class.
*/
@interface NCTree : NCObject
{
  NCTree      *_parent,*_sibling,*_child;
  id          _object;
  id          _delegate;
}
/*!
  @method rootTreeNodeWithObject:
  Creates a new tree node associated with <TT>object</TT> that has no parent
  node.
*/
+ (NCTree*) rootTreeNodeWithObject:(id)object;
/*!
  @method treeNodeWithParent:object:
  Creates a new tree node associated with <TT>object</TT> that is a child of
  <TT>parent</TT>.
*/
+ (NCTree*) treeNodeWithParent:(NCTree*)parent object:(id)object;
/*!
  @method treeNodeAsSiblingOf:object:
  Creates a new tree node associated with <TT>object</TT> that is a sibling to
  <TT>sibling</TT>.
*/
+ (NCTree*) treeNodeAsSiblingOf:(NCTree*)sibling object:(id)object;
/*!
  @method initWithObject:
  Initializes an instance of <TT>NCTree</TT> to be associated with <TT>object</TT>
  and have no parent, sibling, or child nodes.
*/
- (id) initWithObject:(id)object;
/*!
  @method initWithParent:object:
  Initializes an instance of <TT>NCTree</TT> to be associated with <TT>object</TT>
  and be a child of <TT>parent</TT>.
*/
- (id) initWithParent:(NCTree*)parent object:(id)object;
/*!
  @method initAsSiblingOf:object:
  Initializes an instance of <TT>NCTree</TT> to be associated with <TT>object</TT>
  and be a sibling to <TT>sibling</TT>.
*/
- (id) initAsSiblingOf:(NCTree*)sibling object:(id)object;
/*!
  @method root
  Returns the first-encountered <TT>NCTree</TT> node along the
  receiver's chain of parentage that has a <TT>nil</TT> parent.
*/
- (NCTree*) root;
/*!
  @method parent
  Returns the receiver's parent node.
*/
- (NCTree*) parent;
/*!
  @method sibling
  Returns the receiver's sibling node.
*/
- (NCTree*) sibling;
/*!
  @method child
  Returns the receiver's child node.
*/
- (NCTree*) child;
/*!
  @method object
  Returns the object associated with the receiver.
*/
- (id) object;
/*!
  @method setObject:
  Associates <TT>object</TT> with the receiver.  <TT>object</TT> is
  sent a <TT>retain</TT> message; an extant object associated with the
  receiver is sent a <TT>release</TT> message.
*/
- (void) setObject:(id)object;
/*!
  @method delegate
  Returns the delegate object associated with the receiver.
*/
- (id) delegate;
/*!
  @method setDelegate:
  <TT>delegate</TT> becomes the delegate of the receiver.  <TT>delegate</TT>
  is sent a <TT>retain</TT> message; any extant delegate object for the
  receiver is sent a <TT>release</TT> message.
*/
- (void) setDelegate:(id)delegate;
/*!
  @method childCount
  Returns the number of children associated with the receiver.  Children
  appear as a line of siblings rooted at the receiver's child node.
*/
- (unsigned int) childCount;
/*!
  @method childAtIndex:
  Attempts to retrieve the <TT>index</TT><SUP>th</SUP> child of the receiver.
  The direct child node of the receiver is at an index of zero and that child's
  first sibling at one, second sibling at two, etc.
*/
- (NCTree*) childAtIndex:(unsigned int)index;
/*!
  @method prependChild:
  Attaches <TT>child</TT> at the head of the sibling chain of the
  receiver's child node.
*/
- (void) prependChild:(NCTree*)child;
/*!
  @method appendChild:
  Attaches <TT>child</TT> at the tail of the sibling chain of the
  receiver's child node.
*/
- (void) appendChild:(NCTree*)child;
/*!
  @method insertSibling:
  Attaches <TT>sibling</TT> at the head of the sibling chain of the
  receiver.
*/
- (void) insertSibling:(NCTree*)sibling;
/*!
  @method removeFromParent
  Detaches the receiver from its parent, making the receiver a root
  node.  Any siblings of the receiver will remain children of the
  parent node.
*/
- (void) removeFromParent;
/*!
  @method removeAllChildren
  Sends a <TT>release</TT> message to the direct child of the receiver
  and to all siblings of the direct child.
*/
- (void) removeAllChildren;
/*!
  @method makeNodes:performSelector:
  Invokes <TT>aSelector</TT> on all those nodes -- starting from the
  receiver -- indicated in the <TT>nodesToTouch</TT> argument.  The value
  of the <TT>nodesToTouch</TT> argument should be OR'ed values from the
  NCTree node selection enumeration.<BR>
  <BR>
  The given selector should reference a method that takes no arguments.
*/
- (void) makeNodes:(int)nodesToTouch performSelector:(SEL)aSelector;
/*!
  @method makeNodes:performSelector:withObject:
  Invokes <TT>aSelector</TT> on all those nodes -- starting from the
  receiver -- indicated in the <TT>nodesToTouch</TT> argument.  The value
  of the <TT>nodesToTouch</TT> argument should be OR'ed values from the
  NCTree node selection enumeration.<BR>
  <BR>
  The given selector should reference a method that takes a single object
  as its argument.
*/
- (void) makeNodes:(int)nodesToTouch performSelector:(SEL)aSelector withObject:(id)object;
/*!
  @method makeNodes:performSelector:withObject:withObject:
  Invokes <TT>aSelector</TT> on all those nodes -- starting from the
  receiver -- indicated in the <TT>nodesToTouch</TT> argument.  The value
  of the <TT>nodesToTouch</TT> argument should be OR'ed values from the
  NCTree node selection enumeration.<BR>
  <BR>
  The given selector should reference a method that takes two objects as
  its arguments.
*/
- (void) makeNodes:(int)nodesToTouch performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

/*!
  @method descendsFromNode:
  Returns <TT>YES</TT> if <TT>parent</TT> is somewhere along the receiver's
  chain of parent nodes.  The equality of nodes is established by pointer
  comparison.
*/
- (BOOL) descendsFromNode:(NCTree*)parent;
/*!
  @method isDirectChildOfNode:
  Returns <TT>YES</TT> if <TT>parent</TT> is the receiver's parent node.
  The equality of nodes is established by pointer comparison.
*/
- (BOOL) isDirectChildOfNode:(NCTree*)parent;

@end

@interface NCObject(NCTreeDelegate)

- (BOOL) shouldAddChildNode:(NCTree*)newNode;
- (void) didAddChildNode:(NCTree*)newNode;
- (BOOL) shouldAddSiblingNode:(NCTree*)newNode;
- (void) didAddSiblingNode:(NCTree*)newNode;
- (BOOL) shouldRemoveChildNode:(NCTree*)node;
- (void) didRemoveChildNode:(NCTree*)node;

@end
