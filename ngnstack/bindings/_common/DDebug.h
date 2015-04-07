
#ifndef TINYWRAP_SIP_DEBUG_H
#define TINYWRAP_SIP_DEBUG_H

class DDebugCallback
{
public:
	DDebugCallback() {  }
	virtual ~DDebugCallback() {}


	virtual int OnDebugInfo(const char* message) const { return -1; }
	virtual int OnDebugWarn(const char* message) const { return -1; }
	virtual int OnDebugError(const char* message) const { return -1; }
	virtual int OnDebugFatal(const char* message) const { return -1; }

#if !defined(SWIG)
public:
	static int debug_info_cb(const void* arg, const char* fmt, ...);
	static int debug_warn_cb(const void* arg, const char* fmt, ...);
	static int debug_error_cb(const void* arg, const char* fmt, ...);
	static int debug_fatal_cb(const void* arg, const char* fmt, ...);
#endif

private:
	
};

#endif /* TINYWRAP_SIP_DEBUG_H */
