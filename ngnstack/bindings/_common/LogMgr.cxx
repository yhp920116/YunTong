//
//  LogMgr.cpp
//  ios-ngn-stack
//
//  Created by Vincent on 12-1-17.
//  Copyright (c) 2012年 WeiCall. All rights reserved.
//

#include "LogMgr.h"
#include <string>

//Max log file size is 1 M
#define MAX_FILE_LOG_LEN (1 * 1024 * 1024)

class LogDebugCallback : public DDebugCallback {
public:
    LogDebugCallback(LogMgr* logmgr) : DDebugCallback(), logmgr(logmgr) {
        if (logmgr) setDebugCallback();
    }
    ~LogDebugCallback() { clearDebugCallback(); }
    
    bool setDebugCallback()
    {
        tsk_debug_set_arg_data(this);
        tsk_debug_set_info_cb(debug_info_cb);
        tsk_debug_set_warn_cb(debug_warn_cb);
        tsk_debug_set_error_cb(debug_error_cb);
        tsk_debug_set_fatal_cb(debug_fatal_cb);
        return true;
    }
    
    void clearDebugCallback()
    {
        tsk_debug_set_arg_data(tsk_null);
        tsk_debug_set_info_cb(tsk_null);
        tsk_debug_set_warn_cb(tsk_null);
        tsk_debug_set_error_cb(tsk_null);
        tsk_debug_set_fatal_cb(tsk_null);
    }
    
    virtual int OnDebugInfo(const char* message) const {
#ifdef DEBUG
        if (logmgr) logmgr->log(LogMgr::TText, message, strlen(message));
#endif
        return 0;    
    }
    virtual int OnDebugWarn(const char* message) const {
#ifdef DEBUG
        if (logmgr) logmgr->log(LogMgr::TText, message, strlen(message));
#endif
        return 0;
    }
    virtual int OnDebugError(const char* message) const {
        if (logmgr) logmgr->log(LogMgr::TText, message, strlen(message));
        return 0;
    }
    virtual int OnDebugFatal(const char* message) const {
        if (logmgr) logmgr->log(LogMgr::TText, message, strlen(message));
        return 0;
    }
    
private:
    LogMgr* logmgr;
};


LogMgr::LogMgr(const char* filepath, unsigned long maxentsize1)
    : maxentsize(maxentsize1), logrun(false), dbgCB(0), suspend(false) 
{
    if (!(qsuspend = tsk_mutex_create())) {
        TSK_DEBUG_ERROR("Failed to create mutex variable - qsuspend");
        return;
    }
    if (!(qlock = tsk_mutex_create())) {
        TSK_DEBUG_ERROR("Failed to create mutex variable");
        return;
    }
    if (!(qwait = tsk_condwait_create())) {
		TSK_DEBUG_ERROR("Failed to create conditional variable");
        return;
	}
    TSK_DEBUG_INFO("LogMgr: log file path '%s'", filepath ? filepath : "<null>");
    if (filepath) {
        memset(filename, 0, sizeof(filename));
        strncpy(filename, filepath, sizeof(filename) - 1);
    }
    
    tsk_mutex_lock(qlock);
    for (int i = 0; i < 300; i++) freeq.push(new LogEnt(maxentsize));
    tsk_mutex_unlock(qlock);
    
    logrun = true;
    tsk_thread_create(logthr, SLogLoop, this);
    
    dbgCB = new LogDebugCallback(this);
}

LogMgr::~LogMgr() {
    TSK_DEBUG_INFO("~LogMgr");    
    if (qlock) {
        tsk_mutex_unlock(qlock);
    }
    if (qwait) {
		tsk_condwait_signal(qwait);
	}
    
    logrun = false;
    tsk_thread_join(logthr);
    
    if (dbgCB) delete dbgCB;
    
    while (!freeq.empty()) {
        delete freeq.front();
        freeq.pop();
    }
    while (!logq.empty()) {
        delete logq.front();
        logq.pop();
    }
    
    if (qsuspend) tsk_mutex_destroy(&qsuspend);
    if (qlock) tsk_mutex_destroy(&qlock);
    if (qwait) tsk_condwait_destroy(&qwait);
}

int LogMgr::Suspend() {
    tsk_mutex_lock(qsuspend);
    suspend = true;
    tsk_mutex_unlock(qsuspend);
    return 0;
}

int LogMgr::Resume() {
    tsk_mutex_lock(qsuspend);
    suspend = false;
    tsk_mutex_unlock(qsuspend);
    return 0;
}

unsigned long long qanum = 0;
unsigned long long wnum = 0;
unsigned long long condnum = 0;
unsigned long long condenum = 0;
void LogMgr::LogLoop() {    
    for (;;) {        
        //while (logq.empty() && logrun)
        //    tsk_condwait_wait(qwait);
#if 1
        if (logq.empty()) {
            struct timespec interval;
            interval.tv_sec = (long)(1/1000); // 1 ms 
            interval.tv_nsec = (long)(1%1000) * 1000000; 
            nanosleep(&interval, 0);
            continue;
        }
#endif
        
        if (!logrun)
            break;
        condenum++;
        
        while (logq.size()) {
            LogEnt* ent = logq.front();
            tsk_mutex_lock(qlock);
            logq.pop();
            tsk_mutex_unlock(qlock);
        
            wnum++;
            SaveLogEnt(ent->type, ent->data, ent->size, ent->time);
        
            tsk_mutex_lock(qlock);
            freeq.push(ent);
            tsk_mutex_unlock(qlock);
        }
    }
	tsk_mutex_unlock(qlock);
}

void* LogMgr::SLogLoop(void* p) {
    ((LogMgr*)p)->LogLoop();
	return tsk_null;
}

int LogMgr::_log(bool imm, LogType type, const void* buf, unsigned long size) {    
    if (size > maxentsize) {
        //TSK_DEBUG_ERROR("Flash log entry is too large: %lu\n", size);
        size = maxentsize;
    }
    
    if (imm) {
        time_t aclock;
        time(&aclock); //获取系统时间    
        return SaveLogEnt(type, buf, size, aclock);
    }
    
    int err = 0;
    tsk_mutex_lock(qlock);
    int fnum = freeq.size();
    int queuenum = logq.size();
    unsigned long long anum = qanum;
    unsigned long long writenun = wnum;
    unsigned long long cnum = condnum;
    unsigned long long enuma = condenum;
    if (freeq.empty()) {
        err = -1;
    } else {
        LogEnt* ent = freeq.front();
        freeq.pop();
        
        time_t t;
        time(&t);
        ent->type = type;
        ent->time = t;
        memcpy(ent->data, buf, size);
        ent->size = size;
        logq.push(ent);
        qanum++;
    }
    tsk_mutex_unlock(qlock);
    // signal
	if (err==0 && qwait) {
		//tsk_condwait_signal(qwait);
        condnum++;
	}
    return err;
}

//volatile int flfail = 0;
int LogMgr::SaveLogEnt(unsigned short type, const void* buf, unsigned long size, time_t time) {
    tsk_mutex_lock(qsuspend);
    if (suspend) {        
        tsk_mutex_unlock(qsuspend);
        return 0;
    }    
    
    int err = 0;
    FILE* fp =  fopen(filename, "a");
    if (!fp)
    {
        //TSK_DEBUG_ERROR("LogMgr Open file failed!");
        tsk_mutex_unlock(qsuspend);
        return -1;
    }

    char strtime[128];
    struct tm* newtime;
    newtime = localtime(&time); //将time中的数值转换后存于结构体中
    strftime(strtime, sizeof(strtime), "%Y%m%d %H:%M:%S ", newtime);//可加上时间%H:%M:%S
    
    fwrite(strtime, sizeof(char), strlen(strtime), fp);
    fwrite(buf, sizeof(char), size, fp);
    fflush(fp);
    if (ftell(fp) > MAX_FILE_LOG_LEN)
    {
        fclose(fp);
        
        std::string strbkfile = filename;
        strbkfile.append(".bak");
        remove(strbkfile.c_str());
        rename(filename, strbkfile.c_str());
    } else {
        fclose(fp);
    }
    tsk_mutex_unlock(qsuspend);
    return err;
}

