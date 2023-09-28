
_setwritecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[]) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
  11:	8b 41 04             	mov    0x4(%ecx),%eax
  if (argc > 2) {
  14:	83 39 02             	cmpl   $0x2,(%ecx)
  17:	7e 05                	jle    1e <main+0x1e>
    exit();
  19:	e8 c7 01 00 00       	call   1e5 <exit>
  }


  printf(1, "%d\n", setwritecount(atoi(argv[1])));
  1e:	83 ec 0c             	sub    $0xc,%esp
  21:	ff 70 04             	push   0x4(%eax)
  24:	e8 58 01 00 00       	call   181 <atoi>
  29:	89 04 24             	mov    %eax,(%esp)
  2c:	e8 6c 02 00 00       	call   29d <setwritecount>
  31:	83 c4 0c             	add    $0xc,%esp
  34:	50                   	push   %eax
  35:	68 c0 04 00 00       	push   $0x4c0
  3a:	6a 01                	push   $0x1
  3c:	e8 19 03 00 00       	call   35a <printf>
 
  exit();
  41:	e8 9f 01 00 00       	call   1e5 <exit>

00000046 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  46:	55                   	push   %ebp
  47:	89 e5                	mov    %esp,%ebp
  49:	56                   	push   %esi
  4a:	53                   	push   %ebx
  4b:	8b 75 08             	mov    0x8(%ebp),%esi
  4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  51:	89 f0                	mov    %esi,%eax
  53:	89 d1                	mov    %edx,%ecx
  55:	83 c2 01             	add    $0x1,%edx
  58:	89 c3                	mov    %eax,%ebx
  5a:	83 c0 01             	add    $0x1,%eax
  5d:	0f b6 09             	movzbl (%ecx),%ecx
  60:	88 0b                	mov    %cl,(%ebx)
  62:	84 c9                	test   %cl,%cl
  64:	75 ed                	jne    53 <strcpy+0xd>
    ;
  return os;
}
  66:	89 f0                	mov    %esi,%eax
  68:	5b                   	pop    %ebx
  69:	5e                   	pop    %esi
  6a:	5d                   	pop    %ebp
  6b:	c3                   	ret    

0000006c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  72:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  75:	eb 06                	jmp    7d <strcmp+0x11>
    p++, q++;
  77:	83 c1 01             	add    $0x1,%ecx
  7a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  7d:	0f b6 01             	movzbl (%ecx),%eax
  80:	84 c0                	test   %al,%al
  82:	74 04                	je     88 <strcmp+0x1c>
  84:	3a 02                	cmp    (%edx),%al
  86:	74 ef                	je     77 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  88:	0f b6 c0             	movzbl %al,%eax
  8b:	0f b6 12             	movzbl (%edx),%edx
  8e:	29 d0                	sub    %edx,%eax
}
  90:	5d                   	pop    %ebp
  91:	c3                   	ret    

00000092 <strlen>:

uint
strlen(const char *s)
{
  92:	55                   	push   %ebp
  93:	89 e5                	mov    %esp,%ebp
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  98:	b8 00 00 00 00       	mov    $0x0,%eax
  9d:	eb 03                	jmp    a2 <strlen+0x10>
  9f:	83 c0 01             	add    $0x1,%eax
  a2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  a6:	75 f7                	jne    9f <strlen+0xd>
    ;
  return n;
}
  a8:	5d                   	pop    %ebp
  a9:	c3                   	ret    

000000aa <memset>:

void*
memset(void *dst, int c, uint n)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	57                   	push   %edi
  ae:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  b1:	89 d7                	mov    %edx,%edi
  b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  b9:	fc                   	cld    
  ba:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  bc:	89 d0                	mov    %edx,%eax
  be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  c1:	c9                   	leave  
  c2:	c3                   	ret    

000000c3 <strchr>:

char*
strchr(const char *s, char c)
{
  c3:	55                   	push   %ebp
  c4:	89 e5                	mov    %esp,%ebp
  c6:	8b 45 08             	mov    0x8(%ebp),%eax
  c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  cd:	eb 03                	jmp    d2 <strchr+0xf>
  cf:	83 c0 01             	add    $0x1,%eax
  d2:	0f b6 10             	movzbl (%eax),%edx
  d5:	84 d2                	test   %dl,%dl
  d7:	74 06                	je     df <strchr+0x1c>
    if(*s == c)
  d9:	38 ca                	cmp    %cl,%dl
  db:	75 f2                	jne    cf <strchr+0xc>
  dd:	eb 05                	jmp    e4 <strchr+0x21>
      return (char*)s;
  return 0;
  df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  e4:	5d                   	pop    %ebp
  e5:	c3                   	ret    

000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	55                   	push   %ebp
  e7:	89 e5                	mov    %esp,%ebp
  e9:	57                   	push   %edi
  ea:	56                   	push   %esi
  eb:	53                   	push   %ebx
  ec:	83 ec 1c             	sub    $0x1c,%esp
  ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  f7:	89 de                	mov    %ebx,%esi
  f9:	83 c3 01             	add    $0x1,%ebx
  fc:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
  ff:	7d 2e                	jge    12f <gets+0x49>
    cc = read(0, &c, 1);
 101:	83 ec 04             	sub    $0x4,%esp
 104:	6a 01                	push   $0x1
 106:	8d 45 e7             	lea    -0x19(%ebp),%eax
 109:	50                   	push   %eax
 10a:	6a 00                	push   $0x0
 10c:	e8 ec 00 00 00       	call   1fd <read>
    if(cc < 1)
 111:	83 c4 10             	add    $0x10,%esp
 114:	85 c0                	test   %eax,%eax
 116:	7e 17                	jle    12f <gets+0x49>
      break;
    buf[i++] = c;
 118:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 11c:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 11f:	3c 0a                	cmp    $0xa,%al
 121:	0f 94 c2             	sete   %dl
 124:	3c 0d                	cmp    $0xd,%al
 126:	0f 94 c0             	sete   %al
 129:	08 c2                	or     %al,%dl
 12b:	74 ca                	je     f7 <gets+0x11>
    buf[i++] = c;
 12d:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 12f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 133:	89 f8                	mov    %edi,%eax
 135:	8d 65 f4             	lea    -0xc(%ebp),%esp
 138:	5b                   	pop    %ebx
 139:	5e                   	pop    %esi
 13a:	5f                   	pop    %edi
 13b:	5d                   	pop    %ebp
 13c:	c3                   	ret    

0000013d <stat>:

int
stat(const char *n, struct stat *st)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	56                   	push   %esi
 141:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 142:	83 ec 08             	sub    $0x8,%esp
 145:	6a 00                	push   $0x0
 147:	ff 75 08             	push   0x8(%ebp)
 14a:	e8 d6 00 00 00       	call   225 <open>
  if(fd < 0)
 14f:	83 c4 10             	add    $0x10,%esp
 152:	85 c0                	test   %eax,%eax
 154:	78 24                	js     17a <stat+0x3d>
 156:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 158:	83 ec 08             	sub    $0x8,%esp
 15b:	ff 75 0c             	push   0xc(%ebp)
 15e:	50                   	push   %eax
 15f:	e8 d9 00 00 00       	call   23d <fstat>
 164:	89 c6                	mov    %eax,%esi
  close(fd);
 166:	89 1c 24             	mov    %ebx,(%esp)
 169:	e8 9f 00 00 00       	call   20d <close>
  return r;
 16e:	83 c4 10             	add    $0x10,%esp
}
 171:	89 f0                	mov    %esi,%eax
 173:	8d 65 f8             	lea    -0x8(%ebp),%esp
 176:	5b                   	pop    %ebx
 177:	5e                   	pop    %esi
 178:	5d                   	pop    %ebp
 179:	c3                   	ret    
    return -1;
 17a:	be ff ff ff ff       	mov    $0xffffffff,%esi
 17f:	eb f0                	jmp    171 <stat+0x34>

00000181 <atoi>:

int
atoi(const char *s)
{
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
 184:	53                   	push   %ebx
 185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 188:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 18d:	eb 10                	jmp    19f <atoi+0x1e>
    n = n*10 + *s++ - '0';
 18f:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 192:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 195:	83 c1 01             	add    $0x1,%ecx
 198:	0f be c0             	movsbl %al,%eax
 19b:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 19f:	0f b6 01             	movzbl (%ecx),%eax
 1a2:	8d 58 d0             	lea    -0x30(%eax),%ebx
 1a5:	80 fb 09             	cmp    $0x9,%bl
 1a8:	76 e5                	jbe    18f <atoi+0xe>
  return n;
}
 1aa:	89 d0                	mov    %edx,%eax
 1ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 1af:	c9                   	leave  
 1b0:	c3                   	ret    

000001b1 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b1:	55                   	push   %ebp
 1b2:	89 e5                	mov    %esp,%ebp
 1b4:	56                   	push   %esi
 1b5:	53                   	push   %ebx
 1b6:	8b 75 08             	mov    0x8(%ebp),%esi
 1b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 1bc:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 1bf:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 1c1:	eb 0d                	jmp    1d0 <memmove+0x1f>
    *dst++ = *src++;
 1c3:	0f b6 01             	movzbl (%ecx),%eax
 1c6:	88 02                	mov    %al,(%edx)
 1c8:	8d 49 01             	lea    0x1(%ecx),%ecx
 1cb:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 1ce:	89 d8                	mov    %ebx,%eax
 1d0:	8d 58 ff             	lea    -0x1(%eax),%ebx
 1d3:	85 c0                	test   %eax,%eax
 1d5:	7f ec                	jg     1c3 <memmove+0x12>
  return vdst;
}
 1d7:	89 f0                	mov    %esi,%eax
 1d9:	5b                   	pop    %ebx
 1da:	5e                   	pop    %esi
 1db:	5d                   	pop    %ebp
 1dc:	c3                   	ret    

000001dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1dd:	b8 01 00 00 00       	mov    $0x1,%eax
 1e2:	cd 40                	int    $0x40
 1e4:	c3                   	ret    

000001e5 <exit>:
SYSCALL(exit)
 1e5:	b8 02 00 00 00       	mov    $0x2,%eax
 1ea:	cd 40                	int    $0x40
 1ec:	c3                   	ret    

000001ed <wait>:
SYSCALL(wait)
 1ed:	b8 03 00 00 00       	mov    $0x3,%eax
 1f2:	cd 40                	int    $0x40
 1f4:	c3                   	ret    

000001f5 <pipe>:
SYSCALL(pipe)
 1f5:	b8 04 00 00 00       	mov    $0x4,%eax
 1fa:	cd 40                	int    $0x40
 1fc:	c3                   	ret    

000001fd <read>:
SYSCALL(read)
 1fd:	b8 05 00 00 00       	mov    $0x5,%eax
 202:	cd 40                	int    $0x40
 204:	c3                   	ret    

00000205 <write>:
SYSCALL(write)
 205:	b8 10 00 00 00       	mov    $0x10,%eax
 20a:	cd 40                	int    $0x40
 20c:	c3                   	ret    

0000020d <close>:
SYSCALL(close)
 20d:	b8 15 00 00 00       	mov    $0x15,%eax
 212:	cd 40                	int    $0x40
 214:	c3                   	ret    

00000215 <kill>:
SYSCALL(kill)
 215:	b8 06 00 00 00       	mov    $0x6,%eax
 21a:	cd 40                	int    $0x40
 21c:	c3                   	ret    

0000021d <exec>:
SYSCALL(exec)
 21d:	b8 07 00 00 00       	mov    $0x7,%eax
 222:	cd 40                	int    $0x40
 224:	c3                   	ret    

00000225 <open>:
SYSCALL(open)
 225:	b8 0f 00 00 00       	mov    $0xf,%eax
 22a:	cd 40                	int    $0x40
 22c:	c3                   	ret    

0000022d <mknod>:
SYSCALL(mknod)
 22d:	b8 11 00 00 00       	mov    $0x11,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <unlink>:
SYSCALL(unlink)
 235:	b8 12 00 00 00       	mov    $0x12,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <fstat>:
SYSCALL(fstat)
 23d:	b8 08 00 00 00       	mov    $0x8,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <link>:
SYSCALL(link)
 245:	b8 13 00 00 00       	mov    $0x13,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <mkdir>:
SYSCALL(mkdir)
 24d:	b8 14 00 00 00       	mov    $0x14,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <chdir>:
SYSCALL(chdir)
 255:	b8 09 00 00 00       	mov    $0x9,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <dup>:
SYSCALL(dup)
 25d:	b8 0a 00 00 00       	mov    $0xa,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <getpid>:
SYSCALL(getpid)
 265:	b8 0b 00 00 00       	mov    $0xb,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <sbrk>:
SYSCALL(sbrk)
 26d:	b8 0c 00 00 00       	mov    $0xc,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <sleep>:
SYSCALL(sleep)
 275:	b8 0d 00 00 00       	mov    $0xd,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <uptime>:
SYSCALL(uptime)
 27d:	b8 0e 00 00 00       	mov    $0xe,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <yield>:
SYSCALL(yield)
 285:	b8 16 00 00 00       	mov    $0x16,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <shutdown>:
SYSCALL(shutdown)
 28d:	b8 17 00 00 00       	mov    $0x17,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <writecount>:
SYSCALL(writecount)
 295:	b8 18 00 00 00       	mov    $0x18,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <setwritecount>:
SYSCALL(setwritecount)
 29d:	b8 19 00 00 00       	mov    $0x19,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <settickets>:
SYSCALL(settickets)
 2a5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <getprocessesinfo>:
 2ad:	b8 1b 00 00 00       	mov    $0x1b,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	83 ec 1c             	sub    $0x1c,%esp
 2bb:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2be:	6a 01                	push   $0x1
 2c0:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2c3:	52                   	push   %edx
 2c4:	50                   	push   %eax
 2c5:	e8 3b ff ff ff       	call   205 <write>
}
 2ca:	83 c4 10             	add    $0x10,%esp
 2cd:	c9                   	leave  
 2ce:	c3                   	ret    

000002cf <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2cf:	55                   	push   %ebp
 2d0:	89 e5                	mov    %esp,%ebp
 2d2:	57                   	push   %edi
 2d3:	56                   	push   %esi
 2d4:	53                   	push   %ebx
 2d5:	83 ec 2c             	sub    $0x2c,%esp
 2d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 2db:	89 d0                	mov    %edx,%eax
 2dd:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e3:	0f 95 c1             	setne  %cl
 2e6:	c1 ea 1f             	shr    $0x1f,%edx
 2e9:	84 d1                	test   %dl,%cl
 2eb:	74 44                	je     331 <printint+0x62>
    neg = 1;
    x = -xx;
 2ed:	f7 d8                	neg    %eax
 2ef:	89 c1                	mov    %eax,%ecx
    neg = 1;
 2f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 2fd:	89 c8                	mov    %ecx,%eax
 2ff:	ba 00 00 00 00       	mov    $0x0,%edx
 304:	f7 f6                	div    %esi
 306:	89 df                	mov    %ebx,%edi
 308:	83 c3 01             	add    $0x1,%ebx
 30b:	0f b6 92 24 05 00 00 	movzbl 0x524(%edx),%edx
 312:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 316:	89 ca                	mov    %ecx,%edx
 318:	89 c1                	mov    %eax,%ecx
 31a:	39 d6                	cmp    %edx,%esi
 31c:	76 df                	jbe    2fd <printint+0x2e>
  if(neg)
 31e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 322:	74 31                	je     355 <printint+0x86>
    buf[i++] = '-';
 324:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 329:	8d 5f 02             	lea    0x2(%edi),%ebx
 32c:	8b 75 d0             	mov    -0x30(%ebp),%esi
 32f:	eb 17                	jmp    348 <printint+0x79>
    x = xx;
 331:	89 c1                	mov    %eax,%ecx
  neg = 0;
 333:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 33a:	eb bc                	jmp    2f8 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 33c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 341:	89 f0                	mov    %esi,%eax
 343:	e8 6d ff ff ff       	call   2b5 <putc>
  while(--i >= 0)
 348:	83 eb 01             	sub    $0x1,%ebx
 34b:	79 ef                	jns    33c <printint+0x6d>
}
 34d:	83 c4 2c             	add    $0x2c,%esp
 350:	5b                   	pop    %ebx
 351:	5e                   	pop    %esi
 352:	5f                   	pop    %edi
 353:	5d                   	pop    %ebp
 354:	c3                   	ret    
 355:	8b 75 d0             	mov    -0x30(%ebp),%esi
 358:	eb ee                	jmp    348 <printint+0x79>

0000035a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	57                   	push   %edi
 35e:	56                   	push   %esi
 35f:	53                   	push   %ebx
 360:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 363:	8d 45 10             	lea    0x10(%ebp),%eax
 366:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 369:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 36e:	bb 00 00 00 00       	mov    $0x0,%ebx
 373:	eb 14                	jmp    389 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 375:	89 fa                	mov    %edi,%edx
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	e8 36 ff ff ff       	call   2b5 <putc>
 37f:	eb 05                	jmp    386 <printf+0x2c>
      }
    } else if(state == '%'){
 381:	83 fe 25             	cmp    $0x25,%esi
 384:	74 25                	je     3ab <printf+0x51>
  for(i = 0; fmt[i]; i++){
 386:	83 c3 01             	add    $0x1,%ebx
 389:	8b 45 0c             	mov    0xc(%ebp),%eax
 38c:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 390:	84 c0                	test   %al,%al
 392:	0f 84 20 01 00 00    	je     4b8 <printf+0x15e>
    c = fmt[i] & 0xff;
 398:	0f be f8             	movsbl %al,%edi
 39b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 39e:	85 f6                	test   %esi,%esi
 3a0:	75 df                	jne    381 <printf+0x27>
      if(c == '%'){
 3a2:	83 f8 25             	cmp    $0x25,%eax
 3a5:	75 ce                	jne    375 <printf+0x1b>
        state = '%';
 3a7:	89 c6                	mov    %eax,%esi
 3a9:	eb db                	jmp    386 <printf+0x2c>
      if(c == 'd'){
 3ab:	83 f8 25             	cmp    $0x25,%eax
 3ae:	0f 84 cf 00 00 00    	je     483 <printf+0x129>
 3b4:	0f 8c dd 00 00 00    	jl     497 <printf+0x13d>
 3ba:	83 f8 78             	cmp    $0x78,%eax
 3bd:	0f 8f d4 00 00 00    	jg     497 <printf+0x13d>
 3c3:	83 f8 63             	cmp    $0x63,%eax
 3c6:	0f 8c cb 00 00 00    	jl     497 <printf+0x13d>
 3cc:	83 e8 63             	sub    $0x63,%eax
 3cf:	83 f8 15             	cmp    $0x15,%eax
 3d2:	0f 87 bf 00 00 00    	ja     497 <printf+0x13d>
 3d8:	ff 24 85 cc 04 00 00 	jmp    *0x4cc(,%eax,4)
        printint(fd, *ap, 10, 1);
 3df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e2:	8b 17                	mov    (%edi),%edx
 3e4:	83 ec 0c             	sub    $0xc,%esp
 3e7:	6a 01                	push   $0x1
 3e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	e8 d9 fe ff ff       	call   2cf <printint>
        ap++;
 3f6:	83 c7 04             	add    $0x4,%edi
 3f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fc:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 3ff:	be 00 00 00 00       	mov    $0x0,%esi
 404:	eb 80                	jmp    386 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 409:	8b 17                	mov    (%edi),%edx
 40b:	83 ec 0c             	sub    $0xc,%esp
 40e:	6a 00                	push   $0x0
 410:	b9 10 00 00 00       	mov    $0x10,%ecx
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	e8 b2 fe ff ff       	call   2cf <printint>
        ap++;
 41d:	83 c7 04             	add    $0x4,%edi
 420:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 423:	83 c4 10             	add    $0x10,%esp
      state = 0;
 426:	be 00 00 00 00       	mov    $0x0,%esi
 42b:	e9 56 ff ff ff       	jmp    386 <printf+0x2c>
        s = (char*)*ap;
 430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 433:	8b 30                	mov    (%eax),%esi
        ap++;
 435:	83 c0 04             	add    $0x4,%eax
 438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 43b:	85 f6                	test   %esi,%esi
 43d:	75 15                	jne    454 <printf+0xfa>
          s = "(null)";
 43f:	be c4 04 00 00       	mov    $0x4c4,%esi
 444:	eb 0e                	jmp    454 <printf+0xfa>
          putc(fd, *s);
 446:	0f be d2             	movsbl %dl,%edx
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	e8 64 fe ff ff       	call   2b5 <putc>
          s++;
 451:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 454:	0f b6 16             	movzbl (%esi),%edx
 457:	84 d2                	test   %dl,%dl
 459:	75 eb                	jne    446 <printf+0xec>
      state = 0;
 45b:	be 00 00 00 00       	mov    $0x0,%esi
 460:	e9 21 ff ff ff       	jmp    386 <printf+0x2c>
        putc(fd, *ap);
 465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 468:	0f be 17             	movsbl (%edi),%edx
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	e8 42 fe ff ff       	call   2b5 <putc>
        ap++;
 473:	83 c7 04             	add    $0x4,%edi
 476:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 479:	be 00 00 00 00       	mov    $0x0,%esi
 47e:	e9 03 ff ff ff       	jmp    386 <printf+0x2c>
        putc(fd, c);
 483:	89 fa                	mov    %edi,%edx
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	e8 28 fe ff ff       	call   2b5 <putc>
      state = 0;
 48d:	be 00 00 00 00       	mov    $0x0,%esi
 492:	e9 ef fe ff ff       	jmp    386 <printf+0x2c>
        putc(fd, '%');
 497:	ba 25 00 00 00       	mov    $0x25,%edx
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	e8 11 fe ff ff       	call   2b5 <putc>
        putc(fd, c);
 4a4:	89 fa                	mov    %edi,%edx
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
 4a9:	e8 07 fe ff ff       	call   2b5 <putc>
      state = 0;
 4ae:	be 00 00 00 00       	mov    $0x0,%esi
 4b3:	e9 ce fe ff ff       	jmp    386 <printf+0x2c>
    }
  }
}
 4b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4bb:	5b                   	pop    %ebx
 4bc:	5e                   	pop    %esi
 4bd:	5f                   	pop    %edi
 4be:	5d                   	pop    %ebp
 4bf:	c3                   	ret    
