
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 15 00 00 00       	call   23 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 9d 00 00 00       	call   bb <sleep>
  exit();
  1e:	e8 08 00 00 00       	call   2b <exit>

00000023 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  23:	b8 01 00 00 00       	mov    $0x1,%eax
  28:	cd 40                	int    $0x40
  2a:	c3                   	ret    

0000002b <exit>:
SYSCALL(exit)
  2b:	b8 02 00 00 00       	mov    $0x2,%eax
  30:	cd 40                	int    $0x40
  32:	c3                   	ret    

00000033 <wait>:
SYSCALL(wait)
  33:	b8 03 00 00 00       	mov    $0x3,%eax
  38:	cd 40                	int    $0x40
  3a:	c3                   	ret    

0000003b <pipe>:
SYSCALL(pipe)
  3b:	b8 04 00 00 00       	mov    $0x4,%eax
  40:	cd 40                	int    $0x40
  42:	c3                   	ret    

00000043 <read>:
SYSCALL(read)
  43:	b8 05 00 00 00       	mov    $0x5,%eax
  48:	cd 40                	int    $0x40
  4a:	c3                   	ret    

0000004b <write>:
SYSCALL(write)
  4b:	b8 10 00 00 00       	mov    $0x10,%eax
  50:	cd 40                	int    $0x40
  52:	c3                   	ret    

00000053 <close>:
SYSCALL(close)
  53:	b8 15 00 00 00       	mov    $0x15,%eax
  58:	cd 40                	int    $0x40
  5a:	c3                   	ret    

0000005b <kill>:
SYSCALL(kill)
  5b:	b8 06 00 00 00       	mov    $0x6,%eax
  60:	cd 40                	int    $0x40
  62:	c3                   	ret    

00000063 <exec>:
SYSCALL(exec)
  63:	b8 07 00 00 00       	mov    $0x7,%eax
  68:	cd 40                	int    $0x40
  6a:	c3                   	ret    

0000006b <open>:
SYSCALL(open)
  6b:	b8 0f 00 00 00       	mov    $0xf,%eax
  70:	cd 40                	int    $0x40
  72:	c3                   	ret    

00000073 <mknod>:
SYSCALL(mknod)
  73:	b8 11 00 00 00       	mov    $0x11,%eax
  78:	cd 40                	int    $0x40
  7a:	c3                   	ret    

0000007b <unlink>:
SYSCALL(unlink)
  7b:	b8 12 00 00 00       	mov    $0x12,%eax
  80:	cd 40                	int    $0x40
  82:	c3                   	ret    

00000083 <fstat>:
SYSCALL(fstat)
  83:	b8 08 00 00 00       	mov    $0x8,%eax
  88:	cd 40                	int    $0x40
  8a:	c3                   	ret    

0000008b <link>:
SYSCALL(link)
  8b:	b8 13 00 00 00       	mov    $0x13,%eax
  90:	cd 40                	int    $0x40
  92:	c3                   	ret    

00000093 <mkdir>:
SYSCALL(mkdir)
  93:	b8 14 00 00 00       	mov    $0x14,%eax
  98:	cd 40                	int    $0x40
  9a:	c3                   	ret    

0000009b <chdir>:
SYSCALL(chdir)
  9b:	b8 09 00 00 00       	mov    $0x9,%eax
  a0:	cd 40                	int    $0x40
  a2:	c3                   	ret    

000000a3 <dup>:
SYSCALL(dup)
  a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  a8:	cd 40                	int    $0x40
  aa:	c3                   	ret    

000000ab <getpid>:
SYSCALL(getpid)
  ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  b0:	cd 40                	int    $0x40
  b2:	c3                   	ret    

000000b3 <sbrk>:
SYSCALL(sbrk)
  b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <sleep>:
SYSCALL(sleep)
  bb:	b8 0d 00 00 00       	mov    $0xd,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <uptime>:
SYSCALL(uptime)
  c3:	b8 0e 00 00 00       	mov    $0xe,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <yield>:
SYSCALL(yield)
  cb:	b8 16 00 00 00       	mov    $0x16,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <shutdown>:
SYSCALL(shutdown)
  d3:	b8 17 00 00 00       	mov    $0x17,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <getpagetableentry>:
SYSCALL(getpagetableentry)
  db:	b8 18 00 00 00       	mov    $0x18,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
  e3:	b8 19 00 00 00       	mov    $0x19,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <dumppagetable>:
  eb:	b8 1a 00 00 00       	mov    $0x1a,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    
