
_setwritecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[]) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if (argc > 2) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7e 05                	jle    14 <main+0x14>
    exit();
   f:	e8 d4 01 00 00       	call   1e8 <exit>
  }


  printf(1, "%d\n", setwritecount(atoi(argv[1])));
  14:	8b 45 0c             	mov    0xc(%ebp),%eax
  17:	8b 40 04             	mov    0x4(%eax),%eax
  1a:	89 04 24             	mov    %eax,(%esp)
  1d:	e8 69 01 00 00       	call   18b <atoi>
  22:	89 04 24             	mov    %eax,(%esp)
  25:	e8 76 02 00 00       	call   2a0 <setwritecount>
  2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  2e:	c7 44 24 04 c5 04 00 	movl   $0x4c5,0x4(%esp)
  35:	00 
  36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3d:	e8 2a 03 00 00       	call   36c <printf>
 
  exit();
  42:	e8 a1 01 00 00       	call   1e8 <exit>

00000047 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  47:	55                   	push   %ebp
  48:	89 e5                	mov    %esp,%ebp
  4a:	53                   	push   %ebx
  4b:	8b 45 08             	mov    0x8(%ebp),%eax
  4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  51:	89 c2                	mov    %eax,%edx
  53:	0f b6 19             	movzbl (%ecx),%ebx
  56:	88 1a                	mov    %bl,(%edx)
  58:	8d 52 01             	lea    0x1(%edx),%edx
  5b:	8d 49 01             	lea    0x1(%ecx),%ecx
  5e:	84 db                	test   %bl,%bl
  60:	75 f1                	jne    53 <strcpy+0xc>
    ;
  return os;
}
  62:	5b                   	pop    %ebx
  63:	5d                   	pop    %ebp
  64:	c3                   	ret    

00000065 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  65:	55                   	push   %ebp
  66:	89 e5                	mov    %esp,%ebp
  68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  6e:	eb 06                	jmp    76 <strcmp+0x11>
    p++, q++;
  70:	83 c1 01             	add    $0x1,%ecx
  73:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  76:	0f b6 01             	movzbl (%ecx),%eax
  79:	84 c0                	test   %al,%al
  7b:	74 04                	je     81 <strcmp+0x1c>
  7d:	3a 02                	cmp    (%edx),%al
  7f:	74 ef                	je     70 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  81:	0f b6 c0             	movzbl %al,%eax
  84:	0f b6 12             	movzbl (%edx),%edx
  87:	29 d0                	sub    %edx,%eax
}
  89:	5d                   	pop    %ebp
  8a:	c3                   	ret    

0000008b <strlen>:

uint
strlen(const char *s)
{
  8b:	55                   	push   %ebp
  8c:	89 e5                	mov    %esp,%ebp
  8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  91:	ba 00 00 00 00       	mov    $0x0,%edx
  96:	eb 03                	jmp    9b <strlen+0x10>
  98:	83 c2 01             	add    $0x1,%edx
  9b:	89 d0                	mov    %edx,%eax
  9d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  a1:	75 f5                	jne    98 <strlen+0xd>
    ;
  return n;
}
  a3:	5d                   	pop    %ebp
  a4:	c3                   	ret    

000000a5 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a5:	55                   	push   %ebp
  a6:	89 e5                	mov    %esp,%ebp
  a8:	57                   	push   %edi
  a9:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  ac:	89 d7                	mov    %edx,%edi
  ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  b4:	fc                   	cld    
  b5:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  b7:	89 d0                	mov    %edx,%eax
  b9:	5f                   	pop    %edi
  ba:	5d                   	pop    %ebp
  bb:	c3                   	ret    

000000bc <strchr>:

char*
strchr(const char *s, char c)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  bf:	8b 45 08             	mov    0x8(%ebp),%eax
  c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  c6:	eb 07                	jmp    cf <strchr+0x13>
    if(*s == c)
  c8:	38 ca                	cmp    %cl,%dl
  ca:	74 0f                	je     db <strchr+0x1f>
  for(; *s; s++)
  cc:	83 c0 01             	add    $0x1,%eax
  cf:	0f b6 10             	movzbl (%eax),%edx
  d2:	84 d2                	test   %dl,%dl
  d4:	75 f2                	jne    c8 <strchr+0xc>
      return (char*)s;
  return 0;
  d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  db:	5d                   	pop    %ebp
  dc:	c3                   	ret    

000000dd <gets>:

char*
gets(char *buf, int max)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  e0:	57                   	push   %edi
  e1:	56                   	push   %esi
  e2:	53                   	push   %ebx
  e3:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  e6:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
  eb:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
  ee:	eb 36                	jmp    126 <gets+0x49>
    cc = read(0, &c, 1);
  f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  f7:	00 
  f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 103:	e8 f8 00 00 00       	call   200 <read>
    if(cc < 1)
 108:	85 c0                	test   %eax,%eax
 10a:	7e 26                	jle    132 <gets+0x55>
      break;
    buf[i++] = c;
 10c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 110:	8b 4d 08             	mov    0x8(%ebp),%ecx
 113:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 116:	3c 0a                	cmp    $0xa,%al
 118:	0f 94 c2             	sete   %dl
 11b:	3c 0d                	cmp    $0xd,%al
 11d:	0f 94 c0             	sete   %al
    buf[i++] = c;
 120:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 122:	08 c2                	or     %al,%dl
 124:	75 0a                	jne    130 <gets+0x53>
  for(i=0; i+1 < max; ){
 126:	8d 73 01             	lea    0x1(%ebx),%esi
 129:	3b 75 0c             	cmp    0xc(%ebp),%esi
 12c:	7c c2                	jl     f0 <gets+0x13>
 12e:	eb 02                	jmp    132 <gets+0x55>
    buf[i++] = c;
 130:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 139:	83 c4 2c             	add    $0x2c,%esp
 13c:	5b                   	pop    %ebx
 13d:	5e                   	pop    %esi
 13e:	5f                   	pop    %edi
 13f:	5d                   	pop    %ebp
 140:	c3                   	ret    

00000141 <stat>:

int
stat(const char *n, struct stat *st)
{
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
 144:	56                   	push   %esi
 145:	53                   	push   %ebx
 146:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 150:	00 
 151:	8b 45 08             	mov    0x8(%ebp),%eax
 154:	89 04 24             	mov    %eax,(%esp)
 157:	e8 cc 00 00 00       	call   228 <open>
 15c:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 15e:	85 c0                	test   %eax,%eax
 160:	78 1d                	js     17f <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 162:	8b 45 0c             	mov    0xc(%ebp),%eax
 165:	89 44 24 04          	mov    %eax,0x4(%esp)
 169:	89 1c 24             	mov    %ebx,(%esp)
 16c:	e8 cf 00 00 00       	call   240 <fstat>
 171:	89 c6                	mov    %eax,%esi
  close(fd);
 173:	89 1c 24             	mov    %ebx,(%esp)
 176:	e8 95 00 00 00       	call   210 <close>
  return r;
 17b:	89 f0                	mov    %esi,%eax
 17d:	eb 05                	jmp    184 <stat+0x43>
    return -1;
 17f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 184:	83 c4 10             	add    $0x10,%esp
 187:	5b                   	pop    %ebx
 188:	5e                   	pop    %esi
 189:	5d                   	pop    %ebp
 18a:	c3                   	ret    

0000018b <atoi>:

int
atoi(const char *s)
{
 18b:	55                   	push   %ebp
 18c:	89 e5                	mov    %esp,%ebp
 18e:	53                   	push   %ebx
 18f:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 192:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 197:	eb 0f                	jmp    1a8 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 199:	8d 04 80             	lea    (%eax,%eax,4),%eax
 19c:	01 c0                	add    %eax,%eax
 19e:	83 c2 01             	add    $0x1,%edx
 1a1:	0f be c9             	movsbl %cl,%ecx
 1a4:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 1a8:	0f b6 0a             	movzbl (%edx),%ecx
 1ab:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 1ae:	80 fb 09             	cmp    $0x9,%bl
 1b1:	76 e6                	jbe    199 <atoi+0xe>
  return n;
}
 1b3:	5b                   	pop    %ebx
 1b4:	5d                   	pop    %ebp
 1b5:	c3                   	ret    

000001b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b6:	55                   	push   %ebp
 1b7:	89 e5                	mov    %esp,%ebp
 1b9:	56                   	push   %esi
 1ba:	53                   	push   %ebx
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
 1be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1c1:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c4:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c6:	eb 0d                	jmp    1d5 <memmove+0x1f>
    *dst++ = *src++;
 1c8:	0f b6 13             	movzbl (%ebx),%edx
 1cb:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 1cd:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 1cf:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d2:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d5:	8d 72 ff             	lea    -0x1(%edx),%esi
 1d8:	85 d2                	test   %edx,%edx
 1da:	7f ec                	jg     1c8 <memmove+0x12>
  return vdst;
}
 1dc:	5b                   	pop    %ebx
 1dd:	5e                   	pop    %esi
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e0:	b8 01 00 00 00       	mov    $0x1,%eax
 1e5:	cd 40                	int    $0x40
 1e7:	c3                   	ret    

000001e8 <exit>:
SYSCALL(exit)
 1e8:	b8 02 00 00 00       	mov    $0x2,%eax
 1ed:	cd 40                	int    $0x40
 1ef:	c3                   	ret    

000001f0 <wait>:
SYSCALL(wait)
 1f0:	b8 03 00 00 00       	mov    $0x3,%eax
 1f5:	cd 40                	int    $0x40
 1f7:	c3                   	ret    

000001f8 <pipe>:
SYSCALL(pipe)
 1f8:	b8 04 00 00 00       	mov    $0x4,%eax
 1fd:	cd 40                	int    $0x40
 1ff:	c3                   	ret    

00000200 <read>:
SYSCALL(read)
 200:	b8 05 00 00 00       	mov    $0x5,%eax
 205:	cd 40                	int    $0x40
 207:	c3                   	ret    

00000208 <write>:
SYSCALL(write)
 208:	b8 10 00 00 00       	mov    $0x10,%eax
 20d:	cd 40                	int    $0x40
 20f:	c3                   	ret    

00000210 <close>:
SYSCALL(close)
 210:	b8 15 00 00 00       	mov    $0x15,%eax
 215:	cd 40                	int    $0x40
 217:	c3                   	ret    

00000218 <kill>:
SYSCALL(kill)
 218:	b8 06 00 00 00       	mov    $0x6,%eax
 21d:	cd 40                	int    $0x40
 21f:	c3                   	ret    

00000220 <exec>:
SYSCALL(exec)
 220:	b8 07 00 00 00       	mov    $0x7,%eax
 225:	cd 40                	int    $0x40
 227:	c3                   	ret    

00000228 <open>:
SYSCALL(open)
 228:	b8 0f 00 00 00       	mov    $0xf,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <mknod>:
SYSCALL(mknod)
 230:	b8 11 00 00 00       	mov    $0x11,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <unlink>:
SYSCALL(unlink)
 238:	b8 12 00 00 00       	mov    $0x12,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <fstat>:
SYSCALL(fstat)
 240:	b8 08 00 00 00       	mov    $0x8,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <link>:
SYSCALL(link)
 248:	b8 13 00 00 00       	mov    $0x13,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <mkdir>:
SYSCALL(mkdir)
 250:	b8 14 00 00 00       	mov    $0x14,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <chdir>:
SYSCALL(chdir)
 258:	b8 09 00 00 00       	mov    $0x9,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <dup>:
SYSCALL(dup)
 260:	b8 0a 00 00 00       	mov    $0xa,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <getpid>:
SYSCALL(getpid)
 268:	b8 0b 00 00 00       	mov    $0xb,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <sbrk>:
SYSCALL(sbrk)
 270:	b8 0c 00 00 00       	mov    $0xc,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <sleep>:
SYSCALL(sleep)
 278:	b8 0d 00 00 00       	mov    $0xd,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <uptime>:
SYSCALL(uptime)
 280:	b8 0e 00 00 00       	mov    $0xe,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <yield>:
SYSCALL(yield)
 288:	b8 16 00 00 00       	mov    $0x16,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <shutdown>:
SYSCALL(shutdown)
 290:	b8 17 00 00 00       	mov    $0x17,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <writecount>:
SYSCALL(writecount)
 298:	b8 18 00 00 00       	mov    $0x18,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <setwritecount>:
SYSCALL(setwritecount)
 2a0:	b8 19 00 00 00       	mov    $0x19,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <settickets>:
SYSCALL(settickets)
 2a8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 2b0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <getpagetableentry>:
SYSCALL(getpagetableentry)
 2b8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 2c0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <dumppagetable>:
 2c8:	b8 1e 00 00 00       	mov    $0x1e,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
 2d3:	83 ec 18             	sub    $0x18,%esp
 2d6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2e0:	00 
 2e1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2e4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2e8:	89 04 24             	mov    %eax,(%esp)
 2eb:	e8 18 ff ff ff       	call   208 <write>
}
 2f0:	c9                   	leave  
 2f1:	c3                   	ret    

000002f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2f2:	55                   	push   %ebp
 2f3:	89 e5                	mov    %esp,%ebp
 2f5:	57                   	push   %edi
 2f6:	56                   	push   %esi
 2f7:	53                   	push   %ebx
 2f8:	83 ec 2c             	sub    $0x2c,%esp
 2fb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 301:	0f 95 c3             	setne  %bl
 304:	89 d0                	mov    %edx,%eax
 306:	c1 e8 1f             	shr    $0x1f,%eax
 309:	84 c3                	test   %al,%bl
 30b:	74 0b                	je     318 <printint+0x26>
    neg = 1;
    x = -xx;
 30d:	f7 da                	neg    %edx
    neg = 1;
 30f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 316:	eb 07                	jmp    31f <printint+0x2d>
  neg = 0;
 318:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 31f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 324:	8d 5e 01             	lea    0x1(%esi),%ebx
 327:	89 d0                	mov    %edx,%eax
 329:	ba 00 00 00 00       	mov    $0x0,%edx
 32e:	f7 f1                	div    %ecx
 330:	0f b6 92 d0 04 00 00 	movzbl 0x4d0(%edx),%edx
 337:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 33b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 33d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 33f:	85 c0                	test   %eax,%eax
 341:	75 e1                	jne    324 <printint+0x32>
  if(neg)
 343:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 347:	74 16                	je     35f <printint+0x6d>
    buf[i++] = '-';
 349:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 34e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 351:	eb 0c                	jmp    35f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 353:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 358:	89 f8                	mov    %edi,%eax
 35a:	e8 71 ff ff ff       	call   2d0 <putc>
  while(--i >= 0)
 35f:	83 eb 01             	sub    $0x1,%ebx
 362:	79 ef                	jns    353 <printint+0x61>
}
 364:	83 c4 2c             	add    $0x2c,%esp
 367:	5b                   	pop    %ebx
 368:	5e                   	pop    %esi
 369:	5f                   	pop    %edi
 36a:	5d                   	pop    %ebp
 36b:	c3                   	ret    

0000036c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	57                   	push   %edi
 370:	56                   	push   %esi
 371:	53                   	push   %ebx
 372:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 375:	8d 45 10             	lea    0x10(%ebp),%eax
 378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 37b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 380:	be 00 00 00 00       	mov    $0x0,%esi
 385:	e9 23 01 00 00       	jmp    4ad <printf+0x141>
    c = fmt[i] & 0xff;
 38a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 38d:	85 ff                	test   %edi,%edi
 38f:	75 19                	jne    3aa <printf+0x3e>
      if(c == '%'){
 391:	83 f8 25             	cmp    $0x25,%eax
 394:	0f 84 0b 01 00 00    	je     4a5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 39a:	0f be d3             	movsbl %bl,%edx
 39d:	8b 45 08             	mov    0x8(%ebp),%eax
 3a0:	e8 2b ff ff ff       	call   2d0 <putc>
 3a5:	e9 00 01 00 00       	jmp    4aa <printf+0x13e>
      }
    } else if(state == '%'){
 3aa:	83 ff 25             	cmp    $0x25,%edi
 3ad:	0f 85 f7 00 00 00    	jne    4aa <printf+0x13e>
      if(c == 'd'){
 3b3:	83 f8 64             	cmp    $0x64,%eax
 3b6:	75 26                	jne    3de <printf+0x72>
        printint(fd, *ap, 10, 1);
 3b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3bb:	8b 10                	mov    (%eax),%edx
 3bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	e8 21 ff ff ff       	call   2f2 <printint>
        ap++;
 3d1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3d5:	66 bf 00 00          	mov    $0x0,%di
 3d9:	e9 cc 00 00 00       	jmp    4aa <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 3de:	83 f8 78             	cmp    $0x78,%eax
 3e1:	0f 94 c1             	sete   %cl
 3e4:	83 f8 70             	cmp    $0x70,%eax
 3e7:	0f 94 c2             	sete   %dl
 3ea:	08 d1                	or     %dl,%cl
 3ec:	74 27                	je     415 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 3ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3f1:	8b 10                	mov    (%eax),%edx
 3f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3fa:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
 402:	e8 eb fe ff ff       	call   2f2 <printint>
        ap++;
 407:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 40b:	bf 00 00 00 00       	mov    $0x0,%edi
 410:	e9 95 00 00 00       	jmp    4aa <printf+0x13e>
      } else if(c == 's'){
 415:	83 f8 73             	cmp    $0x73,%eax
 418:	75 37                	jne    451 <printf+0xe5>
        s = (char*)*ap;
 41a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 41d:	8b 18                	mov    (%eax),%ebx
        ap++;
 41f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 423:	85 db                	test   %ebx,%ebx
 425:	75 19                	jne    440 <printf+0xd4>
          s = "(null)";
 427:	bb c9 04 00 00       	mov    $0x4c9,%ebx
 42c:	8b 7d 08             	mov    0x8(%ebp),%edi
 42f:	eb 12                	jmp    443 <printf+0xd7>
          putc(fd, *s);
 431:	0f be d2             	movsbl %dl,%edx
 434:	89 f8                	mov    %edi,%eax
 436:	e8 95 fe ff ff       	call   2d0 <putc>
          s++;
 43b:	83 c3 01             	add    $0x1,%ebx
 43e:	eb 03                	jmp    443 <printf+0xd7>
 440:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 443:	0f b6 13             	movzbl (%ebx),%edx
 446:	84 d2                	test   %dl,%dl
 448:	75 e7                	jne    431 <printf+0xc5>
      state = 0;
 44a:	bf 00 00 00 00       	mov    $0x0,%edi
 44f:	eb 59                	jmp    4aa <printf+0x13e>
      } else if(c == 'c'){
 451:	83 f8 63             	cmp    $0x63,%eax
 454:	75 19                	jne    46f <printf+0x103>
        putc(fd, *ap);
 456:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 459:	0f be 10             	movsbl (%eax),%edx
 45c:	8b 45 08             	mov    0x8(%ebp),%eax
 45f:	e8 6c fe ff ff       	call   2d0 <putc>
        ap++;
 464:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 468:	bf 00 00 00 00       	mov    $0x0,%edi
 46d:	eb 3b                	jmp    4aa <printf+0x13e>
      } else if(c == '%'){
 46f:	83 f8 25             	cmp    $0x25,%eax
 472:	75 12                	jne    486 <printf+0x11a>
        putc(fd, c);
 474:	0f be d3             	movsbl %bl,%edx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	e8 51 fe ff ff       	call   2d0 <putc>
      state = 0;
 47f:	bf 00 00 00 00       	mov    $0x0,%edi
 484:	eb 24                	jmp    4aa <printf+0x13e>
        putc(fd, '%');
 486:	ba 25 00 00 00       	mov    $0x25,%edx
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	e8 3d fe ff ff       	call   2d0 <putc>
        putc(fd, c);
 493:	0f be d3             	movsbl %bl,%edx
 496:	8b 45 08             	mov    0x8(%ebp),%eax
 499:	e8 32 fe ff ff       	call   2d0 <putc>
      state = 0;
 49e:	bf 00 00 00 00       	mov    $0x0,%edi
 4a3:	eb 05                	jmp    4aa <printf+0x13e>
        state = '%';
 4a5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 4aa:	83 c6 01             	add    $0x1,%esi
 4ad:	89 f0                	mov    %esi,%eax
 4af:	03 45 0c             	add    0xc(%ebp),%eax
 4b2:	0f b6 18             	movzbl (%eax),%ebx
 4b5:	84 db                	test   %bl,%bl
 4b7:	0f 85 cd fe ff ff    	jne    38a <printf+0x1e>
    }
  }
}
 4bd:	83 c4 1c             	add    $0x1c,%esp
 4c0:	5b                   	pop    %ebx
 4c1:	5e                   	pop    %esi
 4c2:	5f                   	pop    %edi
 4c3:	5d                   	pop    %ebp
 4c4:	c3                   	ret    
