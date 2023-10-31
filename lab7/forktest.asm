
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, const char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 14             	sub    $0x14,%esp
   7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  write(fd, s, strlen(s));
   a:	89 1c 24             	mov    %ebx,(%esp)
   d:	e8 41 01 00 00       	call   153 <strlen>
  12:	89 44 24 08          	mov    %eax,0x8(%esp)
  16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1a:	8b 45 08             	mov    0x8(%ebp),%eax
  1d:	89 04 24             	mov    %eax,(%esp)
  20:	e8 ab 02 00 00       	call   2d0 <write>
}
  25:	83 c4 14             	add    $0x14,%esp
  28:	5b                   	pop    %ebx
  29:	5d                   	pop    %ebp
  2a:	c3                   	ret    

0000002b <forktest>:

void
forktest(void)
{
  2b:	55                   	push   %ebp
  2c:	89 e5                	mov    %esp,%ebp
  2e:	53                   	push   %ebx
  2f:	83 ec 14             	sub    $0x14,%esp
  int n, pid;

  printf(1, "fork test\n");
  32:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
  39:	00 
  3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  41:	e8 ba ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  46:	bb 00 00 00 00       	mov    $0x0,%ebx
  4b:	eb 1b                	jmp    68 <forktest+0x3d>
    pid = fork();
  4d:	e8 56 02 00 00       	call   2a8 <fork>
    if(pid < 0)
  52:	85 c0                	test   %eax,%eax
  54:	78 1a                	js     70 <forktest+0x45>
      break;
    if(pid == 0)
  56:	85 c0                	test   %eax,%eax
  58:	75 0b                	jne    65 <forktest+0x3a>
  5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
  60:	e8 4b 02 00 00       	call   2b0 <exit>
  for(n=0; n<N; n++){
  65:	83 c3 01             	add    $0x1,%ebx
  68:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  6e:	7e dd                	jle    4d <forktest+0x22>
  }

  if(n == N){
  70:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  76:	75 46                	jne    be <forktest+0x93>
    printf(1, "fork claimed to work N times!\n", N);
  78:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  7f:	00 
  80:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
  87:	00 
  88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8f:	e8 6c ff ff ff       	call   0 <printf>
    exit();
  94:	e8 17 02 00 00       	call   2b0 <exit>
  }

  for(; n > 0; n--){
    if(wait() < 0){
  99:	e8 1a 02 00 00       	call   2b8 <wait>
  9e:	85 c0                	test   %eax,%eax
  a0:	79 19                	jns    bb <forktest+0x90>
      printf(1, "wait stopped early\n");
  a2:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
  a9:	00 
  aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b1:	e8 4a ff ff ff       	call   0 <printf>
      exit();
  b6:	e8 f5 01 00 00       	call   2b0 <exit>
  for(; n > 0; n--){
  bb:	83 eb 01             	sub    $0x1,%ebx
  be:	85 db                	test   %ebx,%ebx
  c0:	7f d7                	jg     99 <forktest+0x6e>
    }
  }

  if(wait() != -1){
  c2:	e8 f1 01 00 00       	call   2b8 <wait>
  c7:	83 f8 ff             	cmp    $0xffffffff,%eax
  ca:	74 19                	je     e5 <forktest+0xba>
    printf(1, "wait got too many\n");
  cc:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
  d3:	00 
  d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  db:	e8 20 ff ff ff       	call   0 <printf>
    exit();
  e0:	e8 cb 01 00 00       	call   2b0 <exit>
  }

  printf(1, "fork test OK\n");
  e5:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
  ec:	00 
  ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f4:	e8 07 ff ff ff       	call   0 <printf>
}
  f9:	83 c4 14             	add    $0x14,%esp
  fc:	5b                   	pop    %ebx
  fd:	5d                   	pop    %ebp
  fe:	c3                   	ret    

000000ff <main>:

int
main(void)
{
  ff:	55                   	push   %ebp
 100:	89 e5                	mov    %esp,%ebp
 102:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 105:	e8 21 ff ff ff       	call   2b <forktest>
  exit();
 10a:	e8 a1 01 00 00       	call   2b0 <exit>

0000010f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	53                   	push   %ebx
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 119:	89 c2                	mov    %eax,%edx
 11b:	0f b6 19             	movzbl (%ecx),%ebx
 11e:	88 1a                	mov    %bl,(%edx)
 120:	8d 52 01             	lea    0x1(%edx),%edx
 123:	8d 49 01             	lea    0x1(%ecx),%ecx
 126:	84 db                	test   %bl,%bl
 128:	75 f1                	jne    11b <strcpy+0xc>
    ;
  return os;
}
 12a:	5b                   	pop    %ebx
 12b:	5d                   	pop    %ebp
 12c:	c3                   	ret    

0000012d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	8b 4d 08             	mov    0x8(%ebp),%ecx
 133:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 136:	eb 06                	jmp    13e <strcmp+0x11>
    p++, q++;
 138:	83 c1 01             	add    $0x1,%ecx
 13b:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 13e:	0f b6 01             	movzbl (%ecx),%eax
 141:	84 c0                	test   %al,%al
 143:	74 04                	je     149 <strcmp+0x1c>
 145:	3a 02                	cmp    (%edx),%al
 147:	74 ef                	je     138 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 149:	0f b6 c0             	movzbl %al,%eax
 14c:	0f b6 12             	movzbl (%edx),%edx
 14f:	29 d0                	sub    %edx,%eax
}
 151:	5d                   	pop    %ebp
 152:	c3                   	ret    

00000153 <strlen>:

uint
strlen(const char *s)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 159:	ba 00 00 00 00       	mov    $0x0,%edx
 15e:	eb 03                	jmp    163 <strlen+0x10>
 160:	83 c2 01             	add    $0x1,%edx
 163:	89 d0                	mov    %edx,%eax
 165:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 169:	75 f5                	jne    160 <strlen+0xd>
    ;
  return n;
}
 16b:	5d                   	pop    %ebp
 16c:	c3                   	ret    

0000016d <memset>:

void*
memset(void *dst, int c, uint n)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
 170:	57                   	push   %edi
 171:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 174:	89 d7                	mov    %edx,%edi
 176:	8b 4d 10             	mov    0x10(%ebp),%ecx
 179:	8b 45 0c             	mov    0xc(%ebp),%eax
 17c:	fc                   	cld    
 17d:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 17f:	89 d0                	mov    %edx,%eax
 181:	5f                   	pop    %edi
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    

00000184 <strchr>:

char*
strchr(const char *s, char c)
{
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 18e:	eb 07                	jmp    197 <strchr+0x13>
    if(*s == c)
 190:	38 ca                	cmp    %cl,%dl
 192:	74 0f                	je     1a3 <strchr+0x1f>
  for(; *s; s++)
 194:	83 c0 01             	add    $0x1,%eax
 197:	0f b6 10             	movzbl (%eax),%edx
 19a:	84 d2                	test   %dl,%dl
 19c:	75 f2                	jne    190 <strchr+0xc>
      return (char*)s;
  return 0;
 19e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a3:	5d                   	pop    %ebp
 1a4:	c3                   	ret    

000001a5 <gets>:

char*
gets(char *buf, int max)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	57                   	push   %edi
 1a9:	56                   	push   %esi
 1aa:	53                   	push   %ebx
 1ab:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ae:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 1b3:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 1b6:	eb 36                	jmp    1ee <gets+0x49>
    cc = read(0, &c, 1);
 1b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1bf:	00 
 1c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
 1c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1cb:	e8 f8 00 00 00       	call   2c8 <read>
    if(cc < 1)
 1d0:	85 c0                	test   %eax,%eax
 1d2:	7e 26                	jle    1fa <gets+0x55>
      break;
    buf[i++] = c;
 1d4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1db:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 1de:	3c 0a                	cmp    $0xa,%al
 1e0:	0f 94 c2             	sete   %dl
 1e3:	3c 0d                	cmp    $0xd,%al
 1e5:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1e8:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1ea:	08 c2                	or     %al,%dl
 1ec:	75 0a                	jne    1f8 <gets+0x53>
  for(i=0; i+1 < max; ){
 1ee:	8d 73 01             	lea    0x1(%ebx),%esi
 1f1:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1f4:	7c c2                	jl     1b8 <gets+0x13>
 1f6:	eb 02                	jmp    1fa <gets+0x55>
    buf[i++] = c;
 1f8:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 201:	83 c4 2c             	add    $0x2c,%esp
 204:	5b                   	pop    %ebx
 205:	5e                   	pop    %esi
 206:	5f                   	pop    %edi
 207:	5d                   	pop    %ebp
 208:	c3                   	ret    

00000209 <stat>:

int
stat(const char *n, struct stat *st)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
 20c:	56                   	push   %esi
 20d:	53                   	push   %ebx
 20e:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 211:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 218:	00 
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	89 04 24             	mov    %eax,(%esp)
 21f:	e8 cc 00 00 00       	call   2f0 <open>
 224:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 226:	85 c0                	test   %eax,%eax
 228:	78 1d                	js     247 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 44 24 04          	mov    %eax,0x4(%esp)
 231:	89 1c 24             	mov    %ebx,(%esp)
 234:	e8 cf 00 00 00       	call   308 <fstat>
 239:	89 c6                	mov    %eax,%esi
  close(fd);
 23b:	89 1c 24             	mov    %ebx,(%esp)
 23e:	e8 95 00 00 00       	call   2d8 <close>
  return r;
 243:	89 f0                	mov    %esi,%eax
 245:	eb 05                	jmp    24c <stat+0x43>
    return -1;
 247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 24c:	83 c4 10             	add    $0x10,%esp
 24f:	5b                   	pop    %ebx
 250:	5e                   	pop    %esi
 251:	5d                   	pop    %ebp
 252:	c3                   	ret    

00000253 <atoi>:

int
atoi(const char *s)
{
 253:	55                   	push   %ebp
 254:	89 e5                	mov    %esp,%ebp
 256:	53                   	push   %ebx
 257:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 25a:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 25f:	eb 0f                	jmp    270 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 261:	8d 04 80             	lea    (%eax,%eax,4),%eax
 264:	01 c0                	add    %eax,%eax
 266:	83 c2 01             	add    $0x1,%edx
 269:	0f be c9             	movsbl %cl,%ecx
 26c:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 270:	0f b6 0a             	movzbl (%edx),%ecx
 273:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 276:	80 fb 09             	cmp    $0x9,%bl
 279:	76 e6                	jbe    261 <atoi+0xe>
  return n;
}
 27b:	5b                   	pop    %ebx
 27c:	5d                   	pop    %ebp
 27d:	c3                   	ret    

0000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	56                   	push   %esi
 282:	53                   	push   %ebx
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 289:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 28c:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 28e:	eb 0d                	jmp    29d <memmove+0x1f>
    *dst++ = *src++;
 290:	0f b6 13             	movzbl (%ebx),%edx
 293:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 295:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 297:	8d 5b 01             	lea    0x1(%ebx),%ebx
 29a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 29d:	8d 72 ff             	lea    -0x1(%edx),%esi
 2a0:	85 d2                	test   %edx,%edx
 2a2:	7f ec                	jg     290 <memmove+0x12>
  return vdst;
}
 2a4:	5b                   	pop    %ebx
 2a5:	5e                   	pop    %esi
 2a6:	5d                   	pop    %ebp
 2a7:	c3                   	ret    

000002a8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a8:	b8 01 00 00 00       	mov    $0x1,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <exit>:
SYSCALL(exit)
 2b0:	b8 02 00 00 00       	mov    $0x2,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <wait>:
SYSCALL(wait)
 2b8:	b8 03 00 00 00       	mov    $0x3,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <pipe>:
SYSCALL(pipe)
 2c0:	b8 04 00 00 00       	mov    $0x4,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <read>:
SYSCALL(read)
 2c8:	b8 05 00 00 00       	mov    $0x5,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <write>:
SYSCALL(write)
 2d0:	b8 10 00 00 00       	mov    $0x10,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <close>:
SYSCALL(close)
 2d8:	b8 15 00 00 00       	mov    $0x15,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <kill>:
SYSCALL(kill)
 2e0:	b8 06 00 00 00       	mov    $0x6,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <exec>:
SYSCALL(exec)
 2e8:	b8 07 00 00 00       	mov    $0x7,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <open>:
SYSCALL(open)
 2f0:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <mknod>:
SYSCALL(mknod)
 2f8:	b8 11 00 00 00       	mov    $0x11,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <unlink>:
SYSCALL(unlink)
 300:	b8 12 00 00 00       	mov    $0x12,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <fstat>:
SYSCALL(fstat)
 308:	b8 08 00 00 00       	mov    $0x8,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <link>:
SYSCALL(link)
 310:	b8 13 00 00 00       	mov    $0x13,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <mkdir>:
SYSCALL(mkdir)
 318:	b8 14 00 00 00       	mov    $0x14,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <chdir>:
SYSCALL(chdir)
 320:	b8 09 00 00 00       	mov    $0x9,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <dup>:
SYSCALL(dup)
 328:	b8 0a 00 00 00       	mov    $0xa,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <getpid>:
SYSCALL(getpid)
 330:	b8 0b 00 00 00       	mov    $0xb,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <sbrk>:
SYSCALL(sbrk)
 338:	b8 0c 00 00 00       	mov    $0xc,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <sleep>:
SYSCALL(sleep)
 340:	b8 0d 00 00 00       	mov    $0xd,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <uptime>:
SYSCALL(uptime)
 348:	b8 0e 00 00 00       	mov    $0xe,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <yield>:
SYSCALL(yield)
 350:	b8 16 00 00 00       	mov    $0x16,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <shutdown>:
SYSCALL(shutdown)
 358:	b8 17 00 00 00       	mov    $0x17,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <writecount>:
SYSCALL(writecount)
 360:	b8 18 00 00 00       	mov    $0x18,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <setwritecount>:
SYSCALL(setwritecount)
 368:	b8 19 00 00 00       	mov    $0x19,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <settickets>:
SYSCALL(settickets)
 370:	b8 1a 00 00 00       	mov    $0x1a,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 378:	b8 1b 00 00 00       	mov    $0x1b,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <getpagetableentry>:
SYSCALL(getpagetableentry)
 380:	b8 1c 00 00 00       	mov    $0x1c,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 388:	b8 1d 00 00 00       	mov    $0x1d,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <dumppagetable>:
 390:	b8 1e 00 00 00       	mov    $0x1e,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    
