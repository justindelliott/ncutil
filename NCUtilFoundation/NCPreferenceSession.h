//
//  ncutil3 - network configuration utility, version 3
//  NCPreferenceSession
//
//  Class that manages a preference session.
//
//  Created by Jeffrey Frey on Sun May 22 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCObject.h"
#include <SystemConfiguration/SystemConfiguration.h>

/*!
  @function SCPathCreateFromComponents
  The <TT>SystemConfiguration</TT> framework provides several functions
  which store/read/destroy components of a preference store based upon
  key-paths -- nested dictionary key strings, separated by a '/'
  character.  The <TT>SCPathCreateFromComponents</TT> function can be used to
  quickly and easily construct such a path from a series of path
  components passed to it:
<PRE>
      CFStringRef    keyPath = SCPathCreateFromComponents(kSCPrefSets,CFSTR("0"),kSCCompNetwork);
      
      if (keyPath)
        CFShow(keyPath);
</PRE>
  The code segement above will successfully create the key path and display
  <TT>/Sets/0/Network</TT>.
  @result Any error in the creation of the key path will result in the
  function's returning <TT>NULL</TT> to your code.  Note that your code owns
  the resulting <TT>CFString</TT> and is responsible for releasing it.
*/
CFStringRef SCPathCreateFromComponents(CFStringRef firstStr,...);
/*!
  @function SCCurrentLocationName
  Returns the user-defined name of the location which is currently
  marked as active in the context of the provided preference session.
  @param scSession a preference session (created by <TT>SCPreferencesCreate</TT>)
  @result In the case of an error (no current location defined, etc)
  <TT>NULL</TT> will be returned.  The returned <TT>CFString</TT> is
  not owned by your code and should not be released
*/
CFStringRef SCCurrentLocationName(SCPreferencesRef scSession);

@class NCRootDirectory;

/*!
  @class NCPreferenceSession
  An instance of <TT>NCPreferenceSession</TT> provides an Objective-C wrapper
  to a SystemConfiguration preference session.  The class also implements
  methods equivalent to the basic path-handling utility functions available
  in <TT>SCPreferences.h</TT>.
*/
@interface NCPreferenceSession : NCObject
{
  SCPreferencesRef        _sessionReference;
  BOOL                    _isSystemDefault;
  
  CFStringRef             _pathSeparator;
  NCRootDirectory*        _directoryTree;
  
  CFMutableBitVectorRef   _directoryIDs;
}

/*!
  @method init
  Initializes a newly-allocated instance of <TT>NCPreferenceSession</TT> to wrap
  the default SystemConfiguration preference store.
*/
- (id) init;
/*!
  @method initWithPreferencesAtPath:
  Initializes a newly-allocated instance of <TT>NCPreferenceSession</TT> to wrap
  the preference store located at <TT>prefPath</TT>.  If <TT>prefPath</TT> is
  <TT>NULL</TT> then the default SystemConfiguration store is used.
*/
- (id) initWithPreferencesAtPath:(CFStringRef)prefPath;
/*!
  @method initWithPreferenceRef:
  Initializes a newly-allocated instance of <TT>NCPreferenceSession</TT> to wrap
  an already-open preference session.  If <TT>prefSess</TT> is <TT>NULL</TT> then
  the default SystemConfiguration preference store is used instead.
*/
- (id) initWithPreferenceRef:(SCPreferencesRef)prefSess;
/*!
  @method sessionReference
  Returns the SystemConfiguration preference session reference associated with the
  receiver.
*/
- (SCPreferencesRef) sessionReference;
/*!
  @method isSystemDefault
  Returns <TT>YES</TT> if the receiver wraps the default preference store for
  the system.
*/
- (BOOL) isSystemDefault;
/*!
  @method pathSeparatorForDirectoryTree
  Returns the path separator string that should be used when decomposing textual
  paths into the directory tree.  Note that paths used by THIS CLASS are
  SystemConfiguration paths and as such use the '/' character!  An entire string
  is allowed, so a path separator like ':::' is a viable choice.  The default
  value for this string is '/'.
*/
- (CFStringRef) pathSeparatorForDirectoryTree;
/*!
  @method setPathSeparatorForDirectoryTree:
  Use <TT>sepStr</TT> as the characters which indicate breaks between subdirectory
  names in a directory tree path.  This property is maintained by the
  <TT>NCPreferenceSession</TT> for a directory tree because the tree node class
  cluster is complicated and we don't want EVERY node to have a path separator
  associated with it.<BR>
  <BR>
  If <TT>sepStr</TT> is <TT>NULL</TT> then the receiver will revert to using
  '/' as its directory tree separator string.
*/
- (void) setPathSeparatorForDirectoryTree:(CFStringRef)sepStr;
/*!
  @method directoryTree
  Returns the root node of the directory tree that's been initialized via the
  preference session that the receiver wraps.  The directory tree contains nodes
  for all of the configurable network interfaces, network sets (locations), network
  services, and protocol configuration entities available in the receiver's preference
  store.
*/
- (NCRootDirectory*) directoryTree;

/*!
  @method allocateDirectoryID
  Finds the next available numerical directory ID and marks it as assigned.  Once
  you are done with this directory ID, deallocate it so that it may be used again.
*/
- (CFIndex) allocateDirectoryID;
/*!
  @method deallocateDirectoryID:
  Marks <TT>dirID</TT> as unused, so that it may be recycled in later directory ID
  allocations.
*/
- (void) deallocateDirectoryID:(CFIndex)dirID;

/*!
  @method createUniqueSubpathAtPath:
  See <TT>SCPreferencesPathCreateUniqueChild()</TT>.
*/
- (CFStringRef) createUniqueSubpathAtPath:(CFStringRef)parentPath;
/*!
  @method getValueAtPath:
  See <TT>SCPreferencesPathGetValue()</TT>.
*/
- (CFDictionaryRef) getValueAtPath:(CFStringRef)path;
/*!
  @method setValue:atPath:
  See <TT>SCPreferencesPathSetValue()</TT>.
*/
- (BOOL) setValue:(CFDictionaryRef)dict atPath:(CFStringRef)path;
/*!
  @method removeValueAtPath:
  See <TT>SCPreferencesPathRemoveValue()</TT>.
*/
- (BOOL) removeValueAtPath:(CFStringRef)path;
/*!
  @method createPathIfNotPresent:
  Makes certain that a dictionary exists at <TT>path</TT>.  If not, adds an empty, mutable
  dictionary.
*/
- (BOOL) createPathIfNotPresent:(CFStringRef)path;
/*!
  @method getValueOfProperty:atPath:
  Uses <TT>getValueAtPath:</TT> to read the property dictionary at <TT>path</TT> and returns
  the value in that dictionary keyed by <TT>property</TT>.
*/
- (CFPropertyListRef) getValueOfProperty:(CFStringRef)property atPath:(CFStringRef)path;
/*!
  @method setValue:ofProperty:atPath:
  Uses <TT>getValueAtPath:</TT> to read the property dictionary at <TT>path</TT> and adds/replaces
  the value keyed by <TT>property</TT> with <TT>value</TT>.  Commits the modified dictionary
  back to the preference store via <TT>setValue:atPath:</TT>.
*/
- (void) setValue:(CFPropertyListRef)value ofProperty:(CFStringRef)property atPath:(CFStringRef)path;
/*!
  @method removeProperty:atPath:
  Uses <TT>getValueAtPath:</TT> to read the property dictionary at <TT>path</TT> and removes
  the value keyed by <TT>property</TT>.  Commits the modified dictionary back to the preference
  store via <TT>setValue:atPath:</TT>.
*/
- (void) removeProperty:(CFStringRef)property atPath:(CFStringRef)path;
/*!
  @method getLinkAtPath:
  See <TT>SCPreferencesPathGetLink()</TT>.
*/
- (CFStringRef) getLinkAtPath:(CFStringRef)path;
/*!
  @method setLinkToPath:atPath:
  See <TT>SCPreferencesPathSetLink()</TT>.
*/
- (BOOL) setLinkToPath:(CFStringRef)linkPath atPath:(CFStringRef)path;
/*!
  @method commitChanges
  Attempts to commit all changes to the preference store back to the
  file from which the store originated.  Returns <TT>YES</TT> when
  successful, <TT>NO</TT> otherwise.
*/
- (BOOL) commitChanges;
/*!
  @method applyChanges
  Attempts to activate the modifications that have been made to the
  preference store.  Changes to IP address, selected location, etc, will
  be applied to the network state of the machine.  Returns <TT>YES</TT>
  when successful, <TT>NO</TT> otherwise.<BR>
  <BR>
  This method implicitly includes an invocation of <TT>commitChanges</TT>
  so your code need not invoke both.
*/
- (BOOL) applyChanges;

@end
