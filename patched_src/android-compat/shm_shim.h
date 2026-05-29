#ifndef _HOJUIX_SHMSHIM_H
#define _HOJUIX_SHMSHIM_H

int bionic_shm_unlink(const char *name);
int bionic_shm_open(const char *name, int oflag, mode_t mode);

#endif
