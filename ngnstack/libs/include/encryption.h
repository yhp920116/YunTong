

#ifndef ENCRYPTION_H__
#define ENCRYPTION_H__

void EncryptSetup();
void EncryptPacket(char* s, int len);
void DecryptPacket(char* s, int len);

#endif /* ENCRYPTION_H__ */
