//
//  LogMgr.h
//  ios-ngn-stack
//
//  Created by Vincent on 12-1-17.
//  Copyright (c) 2012年 WeiCall. All rights reserved.
//

#ifndef TINYWRAP_LOGMGR_H
#define TINYWRAP_LOGMGR_H

#include <queue>
#include "tsk.h"
#include "DDebug.h"

class LogMgr {
public:
    LogMgr(const char* filepath, unsigned long usersize);
    ~LogMgr();
    
    bool setDebugCallback();
    
    enum LogType { TStats = 0, TEvent, TError, TText, TCall, TLast };
    int log(bool imm, LogType type, const void* buf, unsigned long size) {
        return _log(imm, type, buf, size);
    }
    int log(LogType type, const void* buf, unsigned long size) {
        return _log(false, type, buf, size);
    }
    bool OK() { return logrun; }
    
    int Suspend();
    int Resume();

protected:
    char filename[256];
    unsigned long maxentsize;
    
    DDebugCallback* dbgCB;
    
    void clearDebugCallback();

    static const unsigned short TEmpty = 0xffff;
    struct LogEnt {
        unsigned short type;
        char* data;
        unsigned long size;
        time_t time;
        
        LogEnt(unsigned long maxsz) : size(0), time(0) { data = new char[maxsz]; }
        ~LogEnt() { delete data; }
    };
    
    typedef std::queue<LogEnt*> LogQueue;
    LogQueue logq;
    LogQueue freeq;
    tsk_mutex_handle_t* qsuspend;
    tsk_mutex_handle_t* qlock;
    tsk_condwait_handle_t* qwait;
    
    void LogLoop();
    static void* SLogLoop(void* p);
    bool logrun;
    bool suspend;
    void* logthr[1];
    
    int _log(bool imm, LogType type, const void* buf, unsigned long size);
    int SaveLogEnt(unsigned short type, const void* buf, unsigned long size, time_t time);
};

#endif // TINYWRAP_LOGMGR_H
