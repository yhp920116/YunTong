
/* Vincent, GZ, 2012-03-07 */


#ifndef _TINYSIGCOMPP_RFC5049_H_
#define _TINYSIGCOMPP_RFC5049_H_

/*****
Applying Signaling Compression (SigComp)
                to the Session Initiation Protocol (SIP)
*****/
/**  4.1.  decompression_memory_size (DMS) for SIP/SigComp*/
#define SIP_RFC5049_DECOMPRESSION_MEMORY_SIZE 8192

/** 4.2.  state_memory_size (SMS) for SIP/SigComp (per compartment) */
#define SIP_RFC5049_STATE_MEMORY_SIZE 2048

/** 4.3.  cycles_per_bit (CPB) for SIP/SigComp */
#define SIP_RFC5049_CYCLES_PER_BIT 16

/** 4.4.  SigComp_version (SV) for SIP/SigComp */
#define SIP_RFC5049_SIGCOMP_VERSION 0x02 // (at least SigComp + NACK)

// 4.5.  locally available state (LAS) for SIP/SigComp
// Minimum LAS for SIP/SigComp: the SIP/SDP static dictionary as defined
   //in [RFC3485].

#endif /* _TINYSIGCOMPP_RFC5049_H_ */
