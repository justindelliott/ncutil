//
//  ncutil3 - network configuration utility, version 3
//  NCDirectoryNode
//
//  Abstract base class for representing nodes in the virtual
//  SystemConfiguration preference directory.
//
//  Created by Jeffrey Frey on Tue May 31 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCTree.h"
#import "NCPreferenceSession.h"
#import "NCPropertyHandler.h"
#import "CFAdditions.h"

/*!
  @class NCDirectoryNode
  <TT>NCDirectoryNode</TT> is a somewhat abstract base class for all nodes
  that appear in a preference store's directory tree.  It defines some basic
  methods for reading and writing a dictionary of preference key-value pairs
  from or to the preference store.  Subclasses essentially must only override
  two methods in <TT>NCDirectoryNode</TT> to implement their own functionality:
  <UL>
    <LI>
      <TT>readPropertiesDictionary</TT> -- create a mutable dictionary of key-value
      pairs read from the receiver's realm of the preference store
    </LI>
    <LI>
      <TT>writePropertiesDictionary:</TT> -- use the key-value pairs the provided
      dictionary to modify properties in receiver's realm of the preference store
    </LI>
  </UL>
  <TT>NCDirectoryNode</TT> itself uses a SystemConfiguration dictionary path
  (accessible via the <TT>preferencePath</TT> and <TT>setPreferencePath:</TT> methods)
  to load/store a properties dictionary from/to the actual preference store.<BR>
  <BR>
  These two methods should never be directly called by consumer code, though.  Rather
  the <TT>properties</TT> and <TT>setProperties:</TT> methods should be used since
  they implement caching of the dictionary of property key-value pairs.  At any time
  the cached property values can be:
  <UL>
    <LI>
      committed to the preference store using the <TT>commitUpdates</TT> method
    </LI>
    <LI>
      discarded, so that unmodified values are loaded from the preference store,
      using the <TT>refresh</TT> method
    </LI>
  </UL>
  An extensive set of methods are implemented to retrieve/set property values in the
  property cache; all of those methods use the <TT>properties</TT> and <TT>setProperties:</TT>
  methods.  Thus, as long as a subclass has functional <TT>readPropertiesDictionary</TT> and
  <TT>writePropertiesDictionary:</TT> methods the property accessors need not be
  overridden.<BR>
  <BR>
  Each directory node can have a property handler associated with it.  A property
  handler provides both user-level and SystemConfiguration-level names for properties;
  a data type for each property; and facilitates conversions from plain text to the
  appropriate CoreFoundation type for a property.  Some directory nodes may have a
  static property handler, i.e. none of its properties are context-dependent.  For such
  subclasses, override the <TT>propertyHandler</TT> class method to return a shared
  <TT>NCPropertyHandler</TT> instance; the <TT>propertyHandler</TT> instance method
  simply calls the class method.  If, however, a subclass requires a property handler
  that depends on its state/properties, override the <TT>propertyHandler</TT> instance
  method.  When you wish to get the property handler for a directory node, you should thus
  always use the instance method to do so.  To force a directory node to reconstruct its
  property handler you can invoke the <TT>invalidatePropertyHandler</TT> method (and thus
  any subclass that implements a dynamic property handler should override this method).<BR>
  <BR>
  Every directory node can also be locked to prevent any changes being made to its
  properties.  This locking mechanism is external to the property locks associated with
  <TT>NCProperty</TT> objects.  Even if property-locking is disabled at the <TT>NCProperty</TT>
  level (via <TT>NCPropertySetOverrideLocking()</TT>), directory node locks will still
  be honored.<BR>
  <BR>
  Each directory node has a numerical directory ID associated with it.  Directory IDs
  are not intrinsically necessary to the functioning of a directory tree, and it is left
  up to subclasses and/or consumer code to allocate and assign IDs to directory nodes.
*/
@interface NCDirectoryNode : NCTree
{
  CFStringRef             _preferencePath;
  CFIndex                 _directoryID;
  CFMutableDictionaryRef  _propertyCache;
  BOOL                    _isLocked;
  BOOL                    _wasModified;
}
/*!
  @method directoryType
  Returns a human-readable string that describes the nature of the receiver as a
  directory node (e.g. root directory, interface, protocol, etc).
*/
+ (CFStringRef) directoryType;
/*!
  @method initWithPreferenceSession:
  Initialize a newly-allocated directory node instance.  The receiver is associated with
  <TT>prefSess</TT> and has a directory ID of zero.
*/
- (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess;
/*!
  @method initWithPreferenceSession:andDirectoryID:
  Initialize a newly-allocated directory node instance.  The receiver is associated with
  <TT>prefSess</TT> and has a directory ID of <TT>dirID</TT>.
*/
- (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess andDirectoryID:(CFIndex)dirID;
/*!
  @method preferenceSession
  Returns the <TT>NCPreferenceSession</TT> that the receiver uses to interact with a
  preference store.
*/
- (NCPreferenceSession*) preferenceSession;
/*!
  @method setPreferenceSession:
  Set the receiver to use <TT>prefSess</TT> for its interactions with a preference store.
*/
- (void) setPreferenceSession:(NCPreferenceSession*)prefSess;
/*!
  @method preferencePath
  Returns the SystemConfiguration dictionary path associated with the receiver.
*/
- (CFStringRef) preferencePath;
/*!
  @method setPreferencePath:
  Sets the SystemConfiguration dictionary path associated with the receiver.
*/
- (void) setPreferencePath:(CFStringRef)path;
/*!
  @method directoryID
  Returns the numerical directory ID associated with the receiver.
*/
- (CFIndex) directoryID;
/*!
  @method setDirectoryID:
  Sets the numerical directory ID associated with the receiver.  Note that
  no cross-checking for the uniqueness of <TT>dirID</TT> is performed;
  subclasses and/or consumer code are responsible for allocation and
  assignement of directory IDs.
*/
- (void) setDirectoryID:(CFIndex)dirID;
/*!
  @method readPropertiesDictionary
  Subclasses should override this method!  Constructs a mutable dictionary
  containing key-value pairs for the properties associated with the
  receiver's realm of the preference store.<BR>
  <BR>
  This method should NOT be called directly; use the <TT>properties</TT>
  method instead.
*/
- (CFMutableDictionaryRef) readPropertiesDictionary;
/*!
  @method properties
  Returns a mutable dictionary containing key-value pairs for the receiver's
  properties.
*/
- (CFMutableDictionaryRef) properties;
/*!
  @method writePropertiesDictionary:
  Subclasses should override this method!  Uses the key-value pairs in <TT>propDict</TT>
  to set the values of those properties associated with the receiver's realm of the
  preference store.<BR>
  <BR>
  This method should NOT be called directly; use the <TT>setProperties:</TT>
  method instead.
*/
- (void) writePropertiesDictionary:(CFDictionaryRef)propDict;
/*!
  @method setProperties:
  Commit the key-value pairs in <TT>propDict</TT> to the receiver's properties in
  the preference store.
*/
- (void) setProperties:(CFDictionaryRef)propDict;
/*!
  @method propertyHandler
  Return a shared <TT>NCPropertyHandler</TT> instance for this node class' properties.  Override
  this method if a directory node has no need for dynamic, per-instance property handling.
*/
+ (NCPropertyHandler*) propertyHandler;
/*!
  @method propertyHandler
  Return a <TT>NCPropertyHandler</TT> instance for this node's properties.  Override
  this method if a directory node requires dynamic, per-instance property handling.
*/
- (NCPropertyHandler*) propertyHandler;
/*!
  @method invalidatePropertyHandler
  For nodes that use dynamic, per-instance property handlers, force the receiver to
  reconstruct it's property handler at the next invocation of <TT>propertyHandler</TT>.
*/
- (void) invalidatePropertyHandler;
/*!
  @method isLocked
  Returns <TT>YES</TT> if the receiver is read-only.
*/
- (BOOL) isLocked;
/*!
  @method setIsLocked:
  Pass <TT>YES</TT> if the receiver should be treated as read-only.
*/
- (void) setIsLocked:(BOOL)locked;
/*!
  @method wasModified
  Returns <TT>YES</TT> if the receiver has been modified since it was initialized or
  last committed to the preference store.
*/
- (BOOL) wasModified;

@end

@interface NCDirectoryNode(NCDirectoryNodeProperties)

/*!
  @method setDefaultProperties
  Resets the protocol's property dictionary to contain the default
  properties for that protocol.
*/
- (void) setDefaultProperties;
/*!
  @method valueOfProperty:
  Returns the value of the property keyed by <TT>property</TT> in the receiver's
  property dictionary.
*/
- (CFPropertyListRef) valueOfProperty:(CFStringRef)property;
/*!
  @method valueAtIndex:inProperty:
  For array-type properties in a property dictionary, this method
  can be used to retrieve the value at a particular index in the
  property's array.  If the property is not an array, does not
  exist, or the index is out-of-range, <TT>NULL</TT> is returned.
*/
- (CFPropertyListRef) valueAtIndex:(CFIndex)index inProperty:(CFStringRef)property;
/*!
  @method valueExists:inProperty:
  For array-type properties in a property dictionary, this method
  can be used to determine whether a given value already exists in
  the array of values for the property.
*/
- (BOOL) valueExists:(CFPropertyListRef)value inProperty:(CFStringRef)property;
/*!
  @method indexOfValue:inProperty:
  For array-type properties in a property dictionary, this method
  will return the array index at which the given value is found in
  the array of values for the property.  If the value does not
  exist, if the property does not exist, or the property is not an array,
  <TT>kCFNotFound</TT> is returned.
*/
- (CFIndex) indexOfValue:(CFPropertyListRef)value inProperty:(CFStringRef)property;
/*!
  @method setValue:ofProperty:
  Sets the value of the property keyed by <TT>property</TT> in the receiver's
  property dictionary to <TT>value</TT>.
*/
- (BOOL) setValue:(CFPropertyListRef)value ofProperty:(CFStringRef)property;
/*!
  @method appendValue:toProperty
  Adds a new value to the specified array-oriented property.  If the property
  already has a value associated with it, then the new value will only be
  added if the current value is an array and the new value is unique to that array.
  If the property has not been assigned then a new array is created containing
  <TT>value</TT> and is set as the property's value.<BR>
  <BR>
  If <TT>value</TT> is an array itself, then all the values contained therein
  are added.
*/
- (BOOL) appendValue:(CFPropertyListRef)value toProperty:(CFStringRef)property;
/*!
  @method removeProperty:
  Deletes the specified property (both key and value) from the property
  dictionary.
*/
- (BOOL) removeProperty:(CFStringRef)property;
/*!
  @method removeValue:fromProperty:
  For an array-based property, removes the specified value.  If the
  property's value is not an array then <TT>NO</TT> is returned.  If
  the value does not exist in the array then <TT>NO</TT> is also
  returned.<BR>
  <BR>
  If <TT>value</TT> is an array itself, then all the values contained therein
  are removes.
*/
- (BOOL) removeValue:(CFPropertyListRef)value fromProperty:(CFStringRef)property;
/*!
  @method removeAllProperties
  Removes all key-value pairs from the property dictionary.
*/
- (BOOL) removeAllProperties;
/*!
  @method directoryIsActive
  Returns <TT>YES</TT> if the property dictionary for the receiver does not
  indicate that the node is marked inactive (via the <TT>kSCResvInactive</TT>
  SystemConfiguration property).
*/
- (BOOL) directoryIsActive;
/*!
  @method setDirectoryIsActive:
  Enables or disables the node based upon the value of the <TT>active</TT>
  parameter.  If <TT>active</TT> is <TT>YES</TT> then the <TT>kSCResvInactive</TT>
  SystemConfiguration property, if it exists, is removed from the property
  dictionary.  Otherwise, that property is added/replaced accordingly.
*/
- (BOOL) setDirectoryIsActive:(BOOL)active;
/*!
  @method directoryName
  Returns the human-readable name associated with the receiver (via the
  <TT>kSCPropUserDefinedName</TT> SystemConfiguration property).
*/
- (CFStringRef) directoryName;
/*!
  @method setDirectoryName:
  Set the human-readable name (via <TT>kSCPropUserDefinedName</TT>
  SystemConfiguration property).
*/
- (BOOL) setDirectoryName:(CFStringRef)name;
/*!
  @method listProperty:toStream:
  Display the property value using the receiver's property handler.  The format
  also includes a UNIX-like "drw" triplet to indicate the nature of a
  property:  <TT>-r-</TT> for a read-only property and <TT>-rw</TT> for a
  read-write property.
*/
- (void) listProperty:(CFStringRef)propertyName toStream:(FILE*)stream;
/*!
  @method listPropertiesToStream:
  Write a list of the properties defined in this node's property dictionary
  and their values.<BR>
  <BR>
  The values are displayed by the receiver's property handler.  The format
  also includes a UNIX-like "drw" triplet to indicate the nature of a
  property:  <TT>-r-</TT> for a read-only property and <TT>-rw</TT> for a
  read-write property.
*/
- (void) listPropertiesToStream:(FILE*)stream;
/*!
  @method summarizePropertiesToStream:
  Write a list of the properties that the receiver's property handler is
  configured to accept.<BR>
  <BR>
  Each property is displayed with its type, user-level name, and any supporting
  data (such as enumeration values, numerical range).  The format
  also includes a UNIX-like "drw" triplet to indicate the nature of the
  property:  <TT>-r-</TT> for a read-only property and <TT>-rw</TT> for a
  read-write property.
*/
- (void) summarizePropertiesToStream:(FILE*)stream;

@end

@interface NCDirectoryNode(NCDirectoryNodeUpdating)

/*!
  @method refresh
  Dispose of the cached property dictionary for the receiver and reload
  the properties contained in the preference store.
*/
- (void) refresh;
/*!
  @method refreshNodes:
  Invoke the <TT>refresh</TT> method on those nodes indicated by the
  OR'ed flags from the NCTree node selection enumeration (see <TT>NCTree</TT>).
*/
- (void) refreshNodes:(int)nodesToRefresh;
/*!
  @method commitUpdates
  Write the cached property dictionary for the receiver back to the preference
  store.
*/
- (void) commitUpdates;
/*!
  @method commitUpdatesToNodes:
  Invoke the <TT>commitUpdates</TT> method on those nodes indicated by the
  OR'ed flags from the NCTree node selection enumeration (see <TT>NCTree</TT>).
*/
- (void) commitUpdatesToNodes:(int)nodesToUpdate;

@end

@interface NCDirectoryNode(NCDirectoryNodeSearch)

/*!
  @method listSubdirectoriesToStream:
  Convenience method that lists with an indent level of zero and non-recursively.
*/
- (void) listSubdirectoriesToStream:(FILE*)stream;
/*!
  @method listSubdirectoriesToStream:recursive:
  Convenience method that lists with an indent level of zero and recursively as indicated.
*/
- (void) listSubdirectoriesToStream:(FILE*)stream recursive:(BOOL)recursive;
/*!
  @method listSubdirectoriesToStream:recursive:indent:
  Lists subdirectories of the receiver.  Subdirectories are represented by the sibling
  chain rooted at the direct child of the receiver.  If <TT>recursive</TT> is <TT>YES</TT>
  then each node in the sibling chain is also sent the <TT>listSubdirectoriesToStream:recursive:indent:</TT>
  message with the same arguments.<BR>
  <BR>
  For recursive listings, each sublevel is indented by prefixing '|-' characters for each
  level of indentation indicated by <TT>indent</TT>.
*/
- (void) listSubdirectoriesToStream:(FILE*)stream recursive:(BOOL)recursive indent:(CFIndex)indent;

/*!
  @method pathToNode
  Returns the canonical directory tree path (NOT a SystemConfiguration dictionary path!) that
  leads to this node.  The <TT>NCPreferenceSession</TT>'s separator string is used between
  path components.  Your code owns the returned <TT>CFString</TT> and should release it.
*/
- (CFStringRef) pathToNode;
/*!
  @method searchForNodeWithPath:
  Given a directory tree path (NOT a SystemConfiguration dictionary path!) attempt to
  isolate a subdirectory node using the components of <TT>nodePath</TT>.  If <TT>nodePath</TT>
  begins with the <TT>NCPreferenceSession</TT>'s separator string then the path is assumed to
  be canonical; otherwise, it is relative to the receiver.
*/
- (NCDirectoryNode*) searchForNodeWithPath:(CFStringRef)nodePath;
/*!
  @method searchForNodeWithDirectoryID:
  Convenience method that performs a deep search for a node that has the specified
  directory ID and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchForNodeWithDirectoryID:(CFIndex)dirID;
/*!
  @method searchForNodeWithDirectoryID:andClass:
  Convenience method that performs a deep search for a node that has the specified
  directory ID and is a descendent of the specified class.
*/
- (NCDirectoryNode*) searchForNodeWithDirectoryID:(CFIndex)dirID andClass:(Class)aClass;
/*!
  @method searchDeep:forNodeWithDirectoryID:
  Convenience method that performs a shallow or deep search for a node that has the
  specified directory ID and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchDeep:(BOOL)goDeep forNodeWithDirectoryID:(CFIndex)dirID;
/*!
  @method searchDeep:forNodeWithDirectoryID:andClass:
  Searches the receiver, its child chain, and its sibling chain for the specified directory
  ID.  If <TT>goDeep</TT> is <TT>YES</TT> then each node of the child chain will also have
  <TT>searchDeep:forNodeWithDirectoryID:andClass:</TT> invoked on it with the same
  arguments.<BR>
  <BR>
  If <TT>aClass</TT> is not <TT>Nil</TT> then the node must also be of a class descended
  from <TT>aClass</TT> to match. 
*/
- (NCDirectoryNode*) searchDeep:(BOOL)goDeep forNodeWithDirectoryID:(CFIndex)dirID andClass:(Class)aClass;
/*!
  @method searchForNodeWithDirectoryName:
  Convenience method that performs a shallow search for a node that has the specified
  directory name and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchForNodeWithDirectoryName:(CFStringRef)dirName;
/*!
  @method searchForNodeWithDirectoryName:andClass:
  Convenience method that performs a shallow search for a node that has the specified
  directory name and is a descendent of the specified class.
*/
- (NCDirectoryNode*) searchForNodeWithDirectoryName:(CFStringRef)dirName andClass:(Class)aClass;
/*!
  @method searchDeep:forNodeWithDirectoryName:
  Convenience method that performs a shallow or deep search for a node that has the
  specified directory name and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchDeep:(BOOL)goDeep forNodeWithDirectoryName:(CFStringRef)dirName;
/*!
  @method searchDeep:forNodeWithDirectoryName:andClass:
  Searches the receiver, its child chain, and its sibling chain for the specified directory
  name.  If <TT>goDeep</TT> is <TT>YES</TT> then each node of the child chain will
  also have <TT>searchDeep:forNodeWithDirectoryName:andClass:</TT> invoked on it with the
  same arguments.<BR>
  <BR>
  If <TT>aClass</TT> is not <TT>Nil</TT> then the node must also be of a class descended
  from <TT>aClass</TT> to match. 
*/
- (NCDirectoryNode*) searchDeep:(BOOL)goDeep forNodeWithDirectoryName:(CFStringRef)dirName andClass:(Class)aClass;

/*!
  @method searchForModifiedNode
  Convenience method that performs a deep search for the first node that has been modified
  and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchForModifiedNode;
/*!
  @method searchDeepForModifiedNode:
  Convenience method that performs a shallow or deep search for the first node that has
  been modified and is a descendent of <TT>NCDirectoryNode</TT>.
*/
- (NCDirectoryNode*) searchDeepForModifiedNode:(BOOL)goDeep;
/*!
  @method searchDeepForModifiedNode:withClass:
  Searches the receiver, its child chain, and its sibling chain for the first node that
  has been modified.  If <TT>goDeep</TT> is <TT>YES</TT> then each node of the child
  chain will also have <TT>searchDeepForModifiedNode:withClass:</TT> invoked on it with
  the same arguments.<BR>
  <BR>
  If <TT>aClass</TT> is not <TT>Nil</TT> then the node must also be of a class descended
  from <TT>aClass</TT> to match. 
*/
- (NCDirectoryNode*) searchDeepForModifiedNode:(BOOL)goDeep withClass:(Class)aClass;

/*!
  @method searchForNodeWithClass:
  Convenience method that performs a deep search for the first node that is of the
  specified class.
*/
- (NCDirectoryNode*) searchForNodeWithClass:(Class)aClass;
/*!
  @method searchDeep:forNodeWithClass:
  Convenience method that performs a shallow or deep search for the first node that is
  of the specified class.
*/
- (NCDirectoryNode*) searchDeep:(BOOL)goDeep forNodeWithClass:(Class)aClass;

@end

/*!
  @const kSCPropBSDDevice
  SystemConfiguration name for a property that references the BSD device name
  for an interface object.  There's no such value defined by SystemConfiguration
  itself, hence the reason it appears here.
*/
CF_EXPORT CFStringRef kSCPropBSDDevice;
