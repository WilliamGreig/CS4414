
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	81 ec 20 02 00 00    	sub    $0x220,%esp
  int fd, i;
  char path[] = "stressfs0";
   f:	c7 84 24 16 02 00 00 	movl   $0x65727473,0x216(%esp)
  16:	73 74 72 65 
  1a:	c7 84 24 1a 02 00 00 	movl   $0x73667373,0x21a(%esp)
  21:	73 73 66 73 
  25:	66 c7 84 24 1e 02 00 	movw   $0x30,0x21e(%esp)
  2c:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2f:	c7 44 24 04 c5 05 00 	movl   $0x5c5,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 29 04 00 00       	call   46c <printf>
  memset(data, 'a', sizeof(data));
  43:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  4a:	00 
  4b:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  52:	00 
  53:	8d 44 24 16          	lea    0x16(%esp),%eax
  57:	89 04 24             	mov    %eax,(%esp)
  5a:	e8 43 01 00 00       	call   1a2 <memset>

  for(i = 0; i < 4; i++)
  5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  64:	eb 0c                	jmp    72 <main+0x72>
    if(fork() > 0)
  66:	e8 72 02 00 00       	call   2dd <fork>
  6b:	85 c0                	test   %eax,%eax
  6d:	7f 08                	jg     77 <main+0x77>
  for(i = 0; i < 4; i++)
  6f:	83 c3 01             	add    $0x1,%ebx
  72:	83 fb 03             	cmp    $0x3,%ebx
  75:	7e ef                	jle    66 <main+0x66>
      break;

  printf(1, "write %d\n", i);
  77:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  7b:	c7 44 24 04 d8 05 00 	movl   $0x5d8,0x4(%esp)
  82:	00 
  83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8a:	e8 dd 03 00 00       	call   46c <printf>

  path[8] += i;
  8f:	00 9c 24 1e 02 00 00 	add    %bl,0x21e(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  96:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  9d:	00 
  9e:	8d 84 24 16 02 00 00 	lea    0x216(%esp),%eax
  a5:	89 04 24             	mov    %eax,(%esp)
  a8:	e8 78 02 00 00       	call   325 <open>
  ad:	89 c6                	mov    %eax,%esi
  for(i = 0; i < 20; i++)
  af:	bb 00 00 00 00       	mov    $0x0,%ebx
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  b4:	8d 7c 24 16          	lea    0x16(%esp),%edi
  for(i = 0; i < 20; i++)
  b8:	eb 17                	jmp    d1 <main+0xd1>
    write(fd, data, sizeof(data));
  ba:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  c1:	00 
  c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  c6:	89 34 24             	mov    %esi,(%esp)
  c9:	e8 37 02 00 00       	call   305 <write>
  for(i = 0; i < 20; i++)
  ce:	83 c3 01             	add    $0x1,%ebx
  d1:	83 fb 13             	cmp    $0x13,%ebx
  d4:	7e e4                	jle    ba <main+0xba>
  close(fd);
  d6:	89 34 24             	mov    %esi,(%esp)
  d9:	e8 2f 02 00 00       	call   30d <close>

  printf(1, "read\n");
  de:	c7 44 24 04 e2 05 00 	movl   $0x5e2,0x4(%esp)
  e5:	00 
  e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ed:	e8 7a 03 00 00       	call   46c <printf>

  fd = open(path, O_RDONLY);
  f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  f9:	00 
  fa:	8d 84 24 16 02 00 00 	lea    0x216(%esp),%eax
 101:	89 04 24             	mov    %eax,(%esp)
 104:	e8 1c 02 00 00       	call   325 <open>
 109:	89 c6                	mov    %eax,%esi
  for (i = 0; i < 20; i++)
 10b:	bb 00 00 00 00       	mov    $0x0,%ebx
    read(fd, data, sizeof(data));
 110:	8d 7c 24 16          	lea    0x16(%esp),%edi
  for (i = 0; i < 20; i++)
 114:	eb 17                	jmp    12d <main+0x12d>
    read(fd, data, sizeof(data));
 116:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 11d:	00 
 11e:	89 7c 24 04          	mov    %edi,0x4(%esp)
 122:	89 34 24             	mov    %esi,(%esp)
 125:	e8 d3 01 00 00       	call   2fd <read>
  for (i = 0; i < 20; i++)
 12a:	83 c3 01             	add    $0x1,%ebx
 12d:	83 fb 13             	cmp    $0x13,%ebx
 130:	7e e4                	jle    116 <main+0x116>
  close(fd);
 132:	89 34 24             	mov    %esi,(%esp)
 135:	e8 d3 01 00 00       	call   30d <close>

  wait();
 13a:	e8 ae 01 00 00       	call   2ed <wait>

  exit();
 13f:	e8 a1 01 00 00       	call   2e5 <exit>

00000144 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
 147:	53                   	push   %ebx
 148:	8b 45 08             	mov    0x8(%ebp),%eax
 14b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 14e:	89 c2                	mov    %eax,%edx
 150:	0f b6 19             	movzbl (%ecx),%ebx
 153:	88 1a                	mov    %bl,(%edx)
 155:	8d 52 01             	lea    0x1(%edx),%edx
 158:	8d 49 01             	lea    0x1(%ecx),%ecx
 15b:	84 db                	test   %bl,%bl
 15d:	75 f1                	jne    150 <strcpy+0xc>
    ;
  return os;
}
 15f:	5b                   	pop    %ebx
 160:	5d                   	pop    %ebp
 161:	c3                   	ret    

00000162 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
 165:	8b 4d 08             	mov    0x8(%ebp),%ecx
 168:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 16b:	eb 06                	jmp    173 <strcmp+0x11>
    p++, q++;
 16d:	83 c1 01             	add    $0x1,%ecx
 170:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 173:	0f b6 01             	movzbl (%ecx),%eax
 176:	84 c0                	test   %al,%al
 178:	74 04                	je     17e <strcmp+0x1c>
 17a:	3a 02                	cmp    (%edx),%al
 17c:	74 ef                	je     16d <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 17e:	0f b6 c0             	movzbl %al,%eax
 181:	0f b6 12             	movzbl (%edx),%edx
 184:	29 d0                	sub    %edx,%eax
}
 186:	5d                   	pop    %ebp
 187:	c3                   	ret    

00000188 <strlen>:

uint
strlen(const char *s)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 18e:	ba 00 00 00 00       	mov    $0x0,%edx
 193:	eb 03                	jmp    198 <strlen+0x10>
 195:	83 c2 01             	add    $0x1,%edx
 198:	89 d0                	mov    %edx,%eax
 19a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 19e:	75 f5                	jne    195 <strlen+0xd>
    ;
  return n;
}
 1a0:	5d                   	pop    %ebp
 1a1:	c3                   	ret    

000001a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	57                   	push   %edi
 1a6:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1a9:	89 d7                	mov    %edx,%edi
 1ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b1:	fc                   	cld    
 1b2:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1b4:	89 d0                	mov    %edx,%eax
 1b6:	5f                   	pop    %edi
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <strchr>:

char*
strchr(const char *s, char c)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1c3:	eb 07                	jmp    1cc <strchr+0x13>
    if(*s == c)
 1c5:	38 ca                	cmp    %cl,%dl
 1c7:	74 0f                	je     1d8 <strchr+0x1f>
  for(; *s; s++)
 1c9:	83 c0 01             	add    $0x1,%eax
 1cc:	0f b6 10             	movzbl (%eax),%edx
 1cf:	84 d2                	test   %dl,%dl
 1d1:	75 f2                	jne    1c5 <strchr+0xc>
      return (char*)s;
  return 0;
 1d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d8:	5d                   	pop    %ebp
 1d9:	c3                   	ret    

000001da <gets>:

char*
gets(char *buf, int max)
{
 1da:	55                   	push   %ebp
 1db:	89 e5                	mov    %esp,%ebp
 1dd:	57                   	push   %edi
 1de:	56                   	push   %esi
 1df:	53                   	push   %ebx
 1e0:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e3:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 1e8:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 1eb:	eb 36                	jmp    223 <gets+0x49>
    cc = read(0, &c, 1);
 1ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1f4:	00 
 1f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
 1f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 200:	e8 f8 00 00 00       	call   2fd <read>
    if(cc < 1)
 205:	85 c0                	test   %eax,%eax
 207:	7e 26                	jle    22f <gets+0x55>
      break;
    buf[i++] = c;
 209:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 20d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 210:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 213:	3c 0a                	cmp    $0xa,%al
 215:	0f 94 c2             	sete   %dl
 218:	3c 0d                	cmp    $0xd,%al
 21a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 21d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 21f:	08 c2                	or     %al,%dl
 221:	75 0a                	jne    22d <gets+0x53>
  for(i=0; i+1 < max; ){
 223:	8d 73 01             	lea    0x1(%ebx),%esi
 226:	3b 75 0c             	cmp    0xc(%ebp),%esi
 229:	7c c2                	jl     1ed <gets+0x13>
 22b:	eb 02                	jmp    22f <gets+0x55>
    buf[i++] = c;
 22d:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 236:	83 c4 2c             	add    $0x2c,%esp
 239:	5b                   	pop    %ebx
 23a:	5e                   	pop    %esi
 23b:	5f                   	pop    %edi
 23c:	5d                   	pop    %ebp
 23d:	c3                   	ret    

0000023e <stat>:

int
stat(const char *n, struct stat *st)
{
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	56                   	push   %esi
 242:	53                   	push   %ebx
 243:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 246:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 24d:	00 
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	89 04 24             	mov    %eax,(%esp)
 254:	e8 cc 00 00 00       	call   325 <open>
 259:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 25b:	85 c0                	test   %eax,%eax
 25d:	78 1d                	js     27c <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 25f:	8b 45 0c             	mov    0xc(%ebp),%eax
 262:	89 44 24 04          	mov    %eax,0x4(%esp)
 266:	89 1c 24             	mov    %ebx,(%esp)
 269:	e8 cf 00 00 00       	call   33d <fstat>
 26e:	89 c6                	mov    %eax,%esi
  close(fd);
 270:	89 1c 24             	mov    %ebx,(%esp)
 273:	e8 95 00 00 00       	call   30d <close>
  return r;
 278:	89 f0                	mov    %esi,%eax
 27a:	eb 05                	jmp    281 <stat+0x43>
    return -1;
 27c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 281:	83 c4 10             	add    $0x10,%esp
 284:	5b                   	pop    %ebx
 285:	5e                   	pop    %esi
 286:	5d                   	pop    %ebp
 287:	c3                   	ret    

00000288 <atoi>:

int
atoi(const char *s)
{
 288:	55                   	push   %ebp
 289:	89 e5                	mov    %esp,%ebp
 28b:	53                   	push   %ebx
 28c:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 28f:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 294:	eb 0f                	jmp    2a5 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 296:	8d 04 80             	lea    (%eax,%eax,4),%eax
 299:	01 c0                	add    %eax,%eax
 29b:	83 c2 01             	add    $0x1,%edx
 29e:	0f be c9             	movsbl %cl,%ecx
 2a1:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 2a5:	0f b6 0a             	movzbl (%edx),%ecx
 2a8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 2ab:	80 fb 09             	cmp    $0x9,%bl
 2ae:	76 e6                	jbe    296 <atoi+0xe>
  return n;
}
 2b0:	5b                   	pop    %ebx
 2b1:	5d                   	pop    %ebp
 2b2:	c3                   	ret    

000002b3 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	56                   	push   %esi
 2b7:	53                   	push   %ebx
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2be:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2c1:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2c3:	eb 0d                	jmp    2d2 <memmove+0x1f>
    *dst++ = *src++;
 2c5:	0f b6 13             	movzbl (%ebx),%edx
 2c8:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 2ca:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 2cc:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2cf:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2d2:	8d 72 ff             	lea    -0x1(%edx),%esi
 2d5:	85 d2                	test   %edx,%edx
 2d7:	7f ec                	jg     2c5 <memmove+0x12>
  return vdst;
}
 2d9:	5b                   	pop    %ebx
 2da:	5e                   	pop    %esi
 2db:	5d                   	pop    %ebp
 2dc:	c3                   	ret    

000002dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2dd:	b8 01 00 00 00       	mov    $0x1,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <exit>:
SYSCALL(exit)
 2e5:	b8 02 00 00 00       	mov    $0x2,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <wait>:
SYSCALL(wait)
 2ed:	b8 03 00 00 00       	mov    $0x3,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <pipe>:
SYSCALL(pipe)
 2f5:	b8 04 00 00 00       	mov    $0x4,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <read>:
SYSCALL(read)
 2fd:	b8 05 00 00 00       	mov    $0x5,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <write>:
SYSCALL(write)
 305:	b8 10 00 00 00       	mov    $0x10,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <close>:
SYSCALL(close)
 30d:	b8 15 00 00 00       	mov    $0x15,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <kill>:
SYSCALL(kill)
 315:	b8 06 00 00 00       	mov    $0x6,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <exec>:
SYSCALL(exec)
 31d:	b8 07 00 00 00       	mov    $0x7,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <open>:
SYSCALL(open)
 325:	b8 0f 00 00 00       	mov    $0xf,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <mknod>:
SYSCALL(mknod)
 32d:	b8 11 00 00 00       	mov    $0x11,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <unlink>:
SYSCALL(unlink)
 335:	b8 12 00 00 00       	mov    $0x12,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <fstat>:
SYSCALL(fstat)
 33d:	b8 08 00 00 00       	mov    $0x8,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <link>:
SYSCALL(link)
 345:	b8 13 00 00 00       	mov    $0x13,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <mkdir>:
SYSCALL(mkdir)
 34d:	b8 14 00 00 00       	mov    $0x14,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <chdir>:
SYSCALL(chdir)
 355:	b8 09 00 00 00       	mov    $0x9,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <dup>:
SYSCALL(dup)
 35d:	b8 0a 00 00 00       	mov    $0xa,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <getpid>:
SYSCALL(getpid)
 365:	b8 0b 00 00 00       	mov    $0xb,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <sbrk>:
SYSCALL(sbrk)
 36d:	b8 0c 00 00 00       	mov    $0xc,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <sleep>:
SYSCALL(sleep)
 375:	b8 0d 00 00 00       	mov    $0xd,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <uptime>:
SYSCALL(uptime)
 37d:	b8 0e 00 00 00       	mov    $0xe,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <yield>:
SYSCALL(yield)
 385:	b8 16 00 00 00       	mov    $0x16,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <shutdown>:
SYSCALL(shutdown)
 38d:	b8 17 00 00 00       	mov    $0x17,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <writecount>:
SYSCALL(writecount)
 395:	b8 18 00 00 00       	mov    $0x18,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <setwritecount>:
SYSCALL(setwritecount)
 39d:	b8 19 00 00 00       	mov    $0x19,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <settickets>:
SYSCALL(settickets)
 3a5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 3ad:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <getpagetableentry>:
SYSCALL(getpagetableentry)
 3b5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 3bd:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <dumppagetable>:
 3c5:	b8 1e 00 00 00       	mov    $0x1e,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    
 3cd:	66 90                	xchg   %ax,%ax
 3cf:	90                   	nop

000003d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 18             	sub    $0x18,%esp
 3d6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3e0:	00 
 3e1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3e4:	89 54 24 04          	mov    %edx,0x4(%esp)
 3e8:	89 04 24             	mov    %eax,(%esp)
 3eb:	e8 15 ff ff ff       	call   305 <write>
}
 3f0:	c9                   	leave  
 3f1:	c3                   	ret    

000003f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f2:	55                   	push   %ebp
 3f3:	89 e5                	mov    %esp,%ebp
 3f5:	57                   	push   %edi
 3f6:	56                   	push   %esi
 3f7:	53                   	push   %ebx
 3f8:	83 ec 2c             	sub    $0x2c,%esp
 3fb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 401:	0f 95 c3             	setne  %bl
 404:	89 d0                	mov    %edx,%eax
 406:	c1 e8 1f             	shr    $0x1f,%eax
 409:	84 c3                	test   %al,%bl
 40b:	74 0b                	je     418 <printint+0x26>
    neg = 1;
    x = -xx;
 40d:	f7 da                	neg    %edx
    neg = 1;
 40f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 416:	eb 07                	jmp    41f <printint+0x2d>
  neg = 0;
 418:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 41f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 424:	8d 5e 01             	lea    0x1(%esi),%ebx
 427:	89 d0                	mov    %edx,%eax
 429:	ba 00 00 00 00       	mov    $0x0,%edx
 42e:	f7 f1                	div    %ecx
 430:	0f b6 92 ef 05 00 00 	movzbl 0x5ef(%edx),%edx
 437:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 43b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 43d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 43f:	85 c0                	test   %eax,%eax
 441:	75 e1                	jne    424 <printint+0x32>
  if(neg)
 443:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 447:	74 16                	je     45f <printint+0x6d>
    buf[i++] = '-';
 449:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 44e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 451:	eb 0c                	jmp    45f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 453:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 458:	89 f8                	mov    %edi,%eax
 45a:	e8 71 ff ff ff       	call   3d0 <putc>
  while(--i >= 0)
 45f:	83 eb 01             	sub    $0x1,%ebx
 462:	79 ef                	jns    453 <printint+0x61>
}
 464:	83 c4 2c             	add    $0x2c,%esp
 467:	5b                   	pop    %ebx
 468:	5e                   	pop    %esi
 469:	5f                   	pop    %edi
 46a:	5d                   	pop    %ebp
 46b:	c3                   	ret    

0000046c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 46c:	55                   	push   %ebp
 46d:	89 e5                	mov    %esp,%ebp
 46f:	57                   	push   %edi
 470:	56                   	push   %esi
 471:	53                   	push   %ebx
 472:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 475:	8d 45 10             	lea    0x10(%ebp),%eax
 478:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 47b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 480:	be 00 00 00 00       	mov    $0x0,%esi
 485:	e9 23 01 00 00       	jmp    5ad <printf+0x141>
    c = fmt[i] & 0xff;
 48a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 48d:	85 ff                	test   %edi,%edi
 48f:	75 19                	jne    4aa <printf+0x3e>
      if(c == '%'){
 491:	83 f8 25             	cmp    $0x25,%eax
 494:	0f 84 0b 01 00 00    	je     5a5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 49a:	0f be d3             	movsbl %bl,%edx
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	e8 2b ff ff ff       	call   3d0 <putc>
 4a5:	e9 00 01 00 00       	jmp    5aa <printf+0x13e>
      }
    } else if(state == '%'){
 4aa:	83 ff 25             	cmp    $0x25,%edi
 4ad:	0f 85 f7 00 00 00    	jne    5aa <printf+0x13e>
      if(c == 'd'){
 4b3:	83 f8 64             	cmp    $0x64,%eax
 4b6:	75 26                	jne    4de <printf+0x72>
        printint(fd, *ap, 10, 1);
 4b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4bb:	8b 10                	mov    (%eax),%edx
 4bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	e8 21 ff ff ff       	call   3f2 <printint>
        ap++;
 4d1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4d5:	66 bf 00 00          	mov    $0x0,%di
 4d9:	e9 cc 00 00 00       	jmp    5aa <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 4de:	83 f8 78             	cmp    $0x78,%eax
 4e1:	0f 94 c1             	sete   %cl
 4e4:	83 f8 70             	cmp    $0x70,%eax
 4e7:	0f 94 c2             	sete   %dl
 4ea:	08 d1                	or     %dl,%cl
 4ec:	74 27                	je     515 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 4ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f1:	8b 10                	mov    (%eax),%edx
 4f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4fa:	b9 10 00 00 00       	mov    $0x10,%ecx
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
 502:	e8 eb fe ff ff       	call   3f2 <printint>
        ap++;
 507:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 50b:	bf 00 00 00 00       	mov    $0x0,%edi
 510:	e9 95 00 00 00       	jmp    5aa <printf+0x13e>
      } else if(c == 's'){
 515:	83 f8 73             	cmp    $0x73,%eax
 518:	75 37                	jne    551 <printf+0xe5>
        s = (char*)*ap;
 51a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51d:	8b 18                	mov    (%eax),%ebx
        ap++;
 51f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 523:	85 db                	test   %ebx,%ebx
 525:	75 19                	jne    540 <printf+0xd4>
          s = "(null)";
 527:	bb e8 05 00 00       	mov    $0x5e8,%ebx
 52c:	8b 7d 08             	mov    0x8(%ebp),%edi
 52f:	eb 12                	jmp    543 <printf+0xd7>
          putc(fd, *s);
 531:	0f be d2             	movsbl %dl,%edx
 534:	89 f8                	mov    %edi,%eax
 536:	e8 95 fe ff ff       	call   3d0 <putc>
          s++;
 53b:	83 c3 01             	add    $0x1,%ebx
 53e:	eb 03                	jmp    543 <printf+0xd7>
 540:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 543:	0f b6 13             	movzbl (%ebx),%edx
 546:	84 d2                	test   %dl,%dl
 548:	75 e7                	jne    531 <printf+0xc5>
      state = 0;
 54a:	bf 00 00 00 00       	mov    $0x0,%edi
 54f:	eb 59                	jmp    5aa <printf+0x13e>
      } else if(c == 'c'){
 551:	83 f8 63             	cmp    $0x63,%eax
 554:	75 19                	jne    56f <printf+0x103>
        putc(fd, *ap);
 556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 559:	0f be 10             	movsbl (%eax),%edx
 55c:	8b 45 08             	mov    0x8(%ebp),%eax
 55f:	e8 6c fe ff ff       	call   3d0 <putc>
        ap++;
 564:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 568:	bf 00 00 00 00       	mov    $0x0,%edi
 56d:	eb 3b                	jmp    5aa <printf+0x13e>
      } else if(c == '%'){
 56f:	83 f8 25             	cmp    $0x25,%eax
 572:	75 12                	jne    586 <printf+0x11a>
        putc(fd, c);
 574:	0f be d3             	movsbl %bl,%edx
 577:	8b 45 08             	mov    0x8(%ebp),%eax
 57a:	e8 51 fe ff ff       	call   3d0 <putc>
      state = 0;
 57f:	bf 00 00 00 00       	mov    $0x0,%edi
 584:	eb 24                	jmp    5aa <printf+0x13e>
        putc(fd, '%');
 586:	ba 25 00 00 00       	mov    $0x25,%edx
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	e8 3d fe ff ff       	call   3d0 <putc>
        putc(fd, c);
 593:	0f be d3             	movsbl %bl,%edx
 596:	8b 45 08             	mov    0x8(%ebp),%eax
 599:	e8 32 fe ff ff       	call   3d0 <putc>
      state = 0;
 59e:	bf 00 00 00 00       	mov    $0x0,%edi
 5a3:	eb 05                	jmp    5aa <printf+0x13e>
        state = '%';
 5a5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 5aa:	83 c6 01             	add    $0x1,%esi
 5ad:	89 f0                	mov    %esi,%eax
 5af:	03 45 0c             	add    0xc(%ebp),%eax
 5b2:	0f b6 18             	movzbl (%eax),%ebx
 5b5:	84 db                	test   %bl,%bl
 5b7:	0f 85 cd fe ff ff    	jne    48a <printf+0x1e>
    }
  }
}
 5bd:	83 c4 1c             	add    $0x1c,%esp
 5c0:	5b                   	pop    %ebx
 5c1:	5e                   	pop    %esi
 5c2:	5f                   	pop    %edi
 5c3:	5d                   	pop    %ebp
 5c4:	c3                   	ret    
