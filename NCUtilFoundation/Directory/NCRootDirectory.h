//
//  ncutil3 - network configuration utility, version 3
//  NCRootDirectory
//
//  Concrete directory node class that represents the root
//  node of a preference store.
//
//  Created by Jeffrey Frey on Thu Jun  2 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

@class NCLocationDirectory;

/*!
  @class NCRootDirectory
  A subclass of <TT>NCDirectoryNode</TT> that acts as the root node of a
  directory tree derived from a SystemConfiguration preference store.
  <TT>NCRootDirectory</TT> handles the allocation of directory IDs for
  the entire tree using a mutable bit-vector to store the currently-assigned
  directory IDs.<BR>
  <BR>
  The root node has the following kinds of children associated with it:
  <UL>
    <LI>
      A read-only <TT>NCDirectoryNode</TT> that contains all of the
      configurable network interfaces for the system.
    </LI>
    <LI>
      Each network set (also called a "location") defined in the
      preference store, as <TT>NCLocationDirectory</TT> instances.
    </LI>
  </UL>
*/
@interface NCRootDirectory : NCDirectoryNode
{
}

/*!
  @method initWithPreferenceSession:
  Initializes a newly-allocated <TT>NCRootDirectory</TT> using the preference store
  wrapped by <TT>prefSess</TT>.  This method populates all of the subdirectories in
  a directory tree hierarchy, so the allocation and initialization of a <TT>NCRootDirectory</TT>
  instance will actually create an entire directory tree.
*/
- (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess;

/*!
  @method refreshEntireTree
  Discards all cached property dictionaries in all nodes of the directory tree rooted
  at the receiver.
*/
- (void) refreshEntireTree;
/*!
  @method commitUpdatesToEntireTree
  Writes all cached properties in all nodes of the directory tree rooted
  at the receiver to the preference store.
*/
- (void) commitUpdatesToEntireTree;

/*!
  @method addLocationWithName:
  Add a new location (network set, in the parlance) to the tree.  The new
  location must be uniquely named, and will appear <B>immediately</B> in the
  preference store. 
*/
- (BOOL) addLocationWithName:(CFStringRef)name;

/*!
  @method locationWithName:
  Convenience method that does a shallow search from the receiver, looking for a
  node descended from <TT>NCLocationDirectory</TT> with <TT>locationName</TT>
  as it's directory name.
*/
- (NCLocationDirectory*) locationWithName:(CFStringRef)locationName;
/*!
  @method currentLocation
  Convenience method that returns the <TT>NCLocationDirectory</TT> that is
  the currently selected network set.
*/
- (NCLocationDirectory*) currentLocation;
/*!
  @method firstLocationDirectory
  Returns the first directory in this directory's child chain that is a
  location directory.
*/
- (NCLocationDirectory*) firstLocationDirectory;

/*!
  @method treeHasBeenModified
  Returns <TT>YES</TT> if any of the location directories (or their manifold
  children) have been modified.
*/
- (BOOL) treeHasBeenModified;
/*!
  @method interfaceTemplateDirectory
  Returns a reference to the <TT>NCDirectoryNode</TT> that contains the interface
  templates for this system.
*/
- (NCDirectoryNode*) interfaceTemplateDirectory;
@end

CF_EXPORT CFStringRef NCRootDirectory_LocName;
CF_EXPORT CFStringRef NCRootDirectory_CompName;
CF_EXPORT CFStringRef NCRootDirectory_HostName;
CF_EXPORT CFStringRef NCRootDirectory_InterfacesDirName;
