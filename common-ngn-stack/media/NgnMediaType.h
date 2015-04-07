
/* Vincent, GZ, 2012-03-07 */

#ifndef NGN_MEDIATYPE_H
#define NGN_MEDIATYPE_H

typedef enum NgnMediaType_e {
	// Very Important: These values are stored in the data base and MUST never
	// be changed. If you want to add new type, please add it after "MediaType_Msrp"
	MediaType_None = 0,
	MediaType_Audio = (0x01<<0),
	MediaType_Video = (0x01<<1),
	MediaType_AudioVideo = MediaType_Audio | MediaType_Video,
	MediaType_SMS = (0x01<<2),
	MediaType_Chat = (0x01<<3),
	MediaType_FileTransfer = (0x01<<4),
	MediaType_Msrp = MediaType_Chat | MediaType_FileTransfer,
	
	// --- Add you media type after THIS LINE ---
	
	// --- Add you media type before THIS LINE ---
	
	MediaType_All = MediaType_AudioVideo | MediaType_Msrp
}
NgnMediaType_t;

static bool isAudioVideoType(NgnMediaType_t type){
	return (type & MediaType_AudioVideo);
}
static bool isAudioType(NgnMediaType_t type){
	return (type & MediaType_Audio);
}
static bool isVideoType(NgnMediaType_t type){
	return (type & MediaType_Video);
}
static bool isFileTransfer(NgnMediaType_t type){
	return type == MediaType_FileTransfer;
}
static bool isChat(NgnMediaType_t type){
	return type == MediaType_Chat;
}
static bool isMsrpType(NgnMediaType_t type){
	return (type & MediaType_Msrp);
}


#endif /* NGN_MEDIATYPE_H */
