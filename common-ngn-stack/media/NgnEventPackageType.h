
#ifndef NGN_EVENT_PACKAGE_TYPE_H
#define NGN_EVENT_PACKAGE_TYPE_H

typedef enum NgnEventPackageType_e {
	EventPackage_None,
	
	EventPackage_Conference, 
	EventPackage_Dialog, 
	EventPackage_MessageSummary, 
	EventPackage_Presence, 
	EventPackage_PresenceList, 
	EventPackage_RegInfo, 
	EventPackage_SipProfile, 
	EventPackage_UAProfile, 
	EventPackage_WInfo, 
	EventPackage_XcapDiff
}
NgnEventPackageType_t;

#endif /* NGN_EVENT_PACKAGE_TYPE_H */

