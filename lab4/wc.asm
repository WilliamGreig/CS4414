
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 1c             	sub    $0x1c,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
   9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  l = w = c = 0;
  10:	be 00 00 00 00       	mov    $0x0,%esi
  15:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  23:	83 ec 04             	sub    $0x4,%esp
  26:	68 00 02 00 00       	push   $0x200
  2b:	68 a0 06 00 00       	push   $0x6a0
  30:	ff 75 08             	push   0x8(%ebp)
  33:	e8 e1 02 00 00       	call   319 <read>
  38:	89 c7                	mov    %eax,%edi
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	85 c0                	test   %eax,%eax
  3f:	7e 54                	jle    95 <wc+0x95>
    for(i=0; i<n; i++){
  41:	bb 00 00 00 00       	mov    $0x0,%ebx
  46:	eb 22                	jmp    6a <wc+0x6a>
      c++;
      if(buf[i] == '\n')
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  48:	83 ec 08             	sub    $0x8,%esp
  4b:	0f be c0             	movsbl %al,%eax
  4e:	50                   	push   %eax
  4f:	68 dc 05 00 00       	push   $0x5dc
  54:	e8 86 01 00 00       	call   1df <strchr>
  59:	83 c4 10             	add    $0x10,%esp
  5c:	85 c0                	test   %eax,%eax
  5e:	74 22                	je     82 <wc+0x82>
        inword = 0;
  60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    for(i=0; i<n; i++){
  67:	83 c3 01             	add    $0x1,%ebx
  6a:	39 fb                	cmp    %edi,%ebx
  6c:	7d b5                	jge    23 <wc+0x23>
      c++;
  6e:	83 c6 01             	add    $0x1,%esi
      if(buf[i] == '\n')
  71:	0f b6 83 a0 06 00 00 	movzbl 0x6a0(%ebx),%eax
  78:	3c 0a                	cmp    $0xa,%al
  7a:	75 cc                	jne    48 <wc+0x48>
        l++;
  7c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80:	eb c6                	jmp    48 <wc+0x48>
      else if(!inword){
  82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  86:	75 df                	jne    67 <wc+0x67>
        w++;
  88:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
        inword = 1;
  8c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  93:	eb d2                	jmp    67 <wc+0x67>
      }
    }
  }
  if(n < 0){
  95:	78 24                	js     bb <wc+0xbb>
    printf(1, "wc: read error\n");
    exit();
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  97:	83 ec 08             	sub    $0x8,%esp
  9a:	ff 75 0c             	push   0xc(%ebp)
  9d:	56                   	push   %esi
  9e:	ff 75 dc             	push   -0x24(%ebp)
  a1:	ff 75 e0             	push   -0x20(%ebp)
  a4:	68 f2 05 00 00       	push   $0x5f2
  a9:	6a 01                	push   $0x1
  ab:	e8 c6 03 00 00       	call   476 <printf>
}
  b0:	83 c4 20             	add    $0x20,%esp
  b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  b6:	5b                   	pop    %ebx
  b7:	5e                   	pop    %esi
  b8:	5f                   	pop    %edi
  b9:	5d                   	pop    %ebp
  ba:	c3                   	ret    
    printf(1, "wc: read error\n");
  bb:	83 ec 08             	sub    $0x8,%esp
  be:	68 e2 05 00 00       	push   $0x5e2
  c3:	6a 01                	push   $0x1
  c5:	e8 ac 03 00 00       	call   476 <printf>
    exit();
  ca:	e8 32 02 00 00       	call   301 <exit>

000000cf <main>:

int
main(int argc, char *argv[])
{
  cf:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  d3:	83 e4 f0             	and    $0xfffffff0,%esp
  d6:	ff 71 fc             	push   -0x4(%ecx)
  d9:	55                   	push   %ebp
  da:	89 e5                	mov    %esp,%ebp
  dc:	57                   	push   %edi
  dd:	56                   	push   %esi
  de:	53                   	push   %ebx
  df:	51                   	push   %ecx
  e0:	83 ec 18             	sub    $0x18,%esp
  e3:	8b 01                	mov    (%ecx),%eax
  e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  e8:	8b 51 04             	mov    0x4(%ecx),%edx
  eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  int fd, i;

  if(argc <= 1){
  ee:	83 f8 01             	cmp    $0x1,%eax
  f1:	7e 07                	jle    fa <main+0x2b>
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
  f3:	be 01 00 00 00       	mov    $0x1,%esi
  f8:	eb 2d                	jmp    127 <main+0x58>
    wc(0, "");
  fa:	83 ec 08             	sub    $0x8,%esp
  fd:	68 f1 05 00 00       	push   $0x5f1
 102:	6a 00                	push   $0x0
 104:	e8 f7 fe ff ff       	call   0 <wc>
    exit();
 109:	e8 f3 01 00 00       	call   301 <exit>
    if((fd = open(argv[i], 0)) < 0){
      printf(1, "wc: cannot open %s\n", argv[i]);
      exit();
    }
    wc(fd, argv[i]);
 10e:	83 ec 08             	sub    $0x8,%esp
 111:	ff 37                	push   (%edi)
 113:	50                   	push   %eax
 114:	e8 e7 fe ff ff       	call   0 <wc>
    close(fd);
 119:	89 1c 24             	mov    %ebx,(%esp)
 11c:	e8 08 02 00 00       	call   329 <close>
  for(i = 1; i < argc; i++){
 121:	83 c6 01             	add    $0x1,%esi
 124:	83 c4 10             	add    $0x10,%esp
 127:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
 12a:	7d 31                	jge    15d <main+0x8e>
    if((fd = open(argv[i], 0)) < 0){
 12c:	8b 45 e0             	mov    -0x20(%ebp),%eax
 12f:	8d 3c b0             	lea    (%eax,%esi,4),%edi
 132:	83 ec 08             	sub    $0x8,%esp
 135:	6a 00                	push   $0x0
 137:	ff 37                	push   (%edi)
 139:	e8 03 02 00 00       	call   341 <open>
 13e:	89 c3                	mov    %eax,%ebx
 140:	83 c4 10             	add    $0x10,%esp
 143:	85 c0                	test   %eax,%eax
 145:	79 c7                	jns    10e <main+0x3f>
      printf(1, "wc: cannot open %s\n", argv[i]);
 147:	83 ec 04             	sub    $0x4,%esp
 14a:	ff 37                	push   (%edi)
 14c:	68 ff 05 00 00       	push   $0x5ff
 151:	6a 01                	push   $0x1
 153:	e8 1e 03 00 00       	call   476 <printf>
      exit();
 158:	e8 a4 01 00 00       	call   301 <exit>
  }
  exit();
 15d:	e8 9f 01 00 00       	call   301 <exit>

00000162 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
 165:	56                   	push   %esi
 166:	53                   	push   %ebx
 167:	8b 75 08             	mov    0x8(%ebp),%esi
 16a:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16d:	89 f0                	mov    %esi,%eax
 16f:	89 d1                	mov    %edx,%ecx
 171:	83 c2 01             	add    $0x1,%edx
 174:	89 c3                	mov    %eax,%ebx
 176:	83 c0 01             	add    $0x1,%eax
 179:	0f b6 09             	movzbl (%ecx),%ecx
 17c:	88 0b                	mov    %cl,(%ebx)
 17e:	84 c9                	test   %cl,%cl
 180:	75 ed                	jne    16f <strcpy+0xd>
    ;
  return os;
}
 182:	89 f0                	mov    %esi,%eax
 184:	5b                   	pop    %ebx
 185:	5e                   	pop    %esi
 186:	5d                   	pop    %ebp
 187:	c3                   	ret    

00000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 18e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 191:	eb 06                	jmp    199 <strcmp+0x11>
    p++, q++;
 193:	83 c1 01             	add    $0x1,%ecx
 196:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 199:	0f b6 01             	movzbl (%ecx),%eax
 19c:	84 c0                	test   %al,%al
 19e:	74 04                	je     1a4 <strcmp+0x1c>
 1a0:	3a 02                	cmp    (%edx),%al
 1a2:	74 ef                	je     193 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 1a4:	0f b6 c0             	movzbl %al,%eax
 1a7:	0f b6 12             	movzbl (%edx),%edx
 1aa:	29 d0                	sub    %edx,%eax
}
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    

000001ae <strlen>:

uint
strlen(const char *s)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1b4:	b8 00 00 00 00       	mov    $0x0,%eax
 1b9:	eb 03                	jmp    1be <strlen+0x10>
 1bb:	83 c0 01             	add    $0x1,%eax
 1be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 1c2:	75 f7                	jne    1bb <strlen+0xd>
    ;
  return n;
}
 1c4:	5d                   	pop    %ebp
 1c5:	c3                   	ret    

000001c6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c6:	55                   	push   %ebp
 1c7:	89 e5                	mov    %esp,%ebp
 1c9:	57                   	push   %edi
 1ca:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1cd:	89 d7                	mov    %edx,%edi
 1cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d5:	fc                   	cld    
 1d6:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1d8:	89 d0                	mov    %edx,%eax
 1da:	8b 7d fc             	mov    -0x4(%ebp),%edi
 1dd:	c9                   	leave  
 1de:	c3                   	ret    

000001df <strchr>:

char*
strchr(const char *s, char c)
{
 1df:	55                   	push   %ebp
 1e0:	89 e5                	mov    %esp,%ebp
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1e9:	eb 03                	jmp    1ee <strchr+0xf>
 1eb:	83 c0 01             	add    $0x1,%eax
 1ee:	0f b6 10             	movzbl (%eax),%edx
 1f1:	84 d2                	test   %dl,%dl
 1f3:	74 06                	je     1fb <strchr+0x1c>
    if(*s == c)
 1f5:	38 ca                	cmp    %cl,%dl
 1f7:	75 f2                	jne    1eb <strchr+0xc>
 1f9:	eb 05                	jmp    200 <strchr+0x21>
      return (char*)s;
  return 0;
 1fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 200:	5d                   	pop    %ebp
 201:	c3                   	ret    

00000202 <gets>:

char*
gets(char *buf, int max)
{
 202:	55                   	push   %ebp
 203:	89 e5                	mov    %esp,%ebp
 205:	57                   	push   %edi
 206:	56                   	push   %esi
 207:	53                   	push   %ebx
 208:	83 ec 1c             	sub    $0x1c,%esp
 20b:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	bb 00 00 00 00       	mov    $0x0,%ebx
 213:	89 de                	mov    %ebx,%esi
 215:	83 c3 01             	add    $0x1,%ebx
 218:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 21b:	7d 2e                	jge    24b <gets+0x49>
    cc = read(0, &c, 1);
 21d:	83 ec 04             	sub    $0x4,%esp
 220:	6a 01                	push   $0x1
 222:	8d 45 e7             	lea    -0x19(%ebp),%eax
 225:	50                   	push   %eax
 226:	6a 00                	push   $0x0
 228:	e8 ec 00 00 00       	call   319 <read>
    if(cc < 1)
 22d:	83 c4 10             	add    $0x10,%esp
 230:	85 c0                	test   %eax,%eax
 232:	7e 17                	jle    24b <gets+0x49>
      break;
    buf[i++] = c;
 234:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 238:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 23b:	3c 0a                	cmp    $0xa,%al
 23d:	0f 94 c2             	sete   %dl
 240:	3c 0d                	cmp    $0xd,%al
 242:	0f 94 c0             	sete   %al
 245:	08 c2                	or     %al,%dl
 247:	74 ca                	je     213 <gets+0x11>
    buf[i++] = c;
 249:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 24b:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 24f:	89 f8                	mov    %edi,%eax
 251:	8d 65 f4             	lea    -0xc(%ebp),%esp
 254:	5b                   	pop    %ebx
 255:	5e                   	pop    %esi
 256:	5f                   	pop    %edi
 257:	5d                   	pop    %ebp
 258:	c3                   	ret    

00000259 <stat>:

int
stat(const char *n, struct stat *st)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	56                   	push   %esi
 25d:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25e:	83 ec 08             	sub    $0x8,%esp
 261:	6a 00                	push   $0x0
 263:	ff 75 08             	push   0x8(%ebp)
 266:	e8 d6 00 00 00       	call   341 <open>
  if(fd < 0)
 26b:	83 c4 10             	add    $0x10,%esp
 26e:	85 c0                	test   %eax,%eax
 270:	78 24                	js     296 <stat+0x3d>
 272:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 274:	83 ec 08             	sub    $0x8,%esp
 277:	ff 75 0c             	push   0xc(%ebp)
 27a:	50                   	push   %eax
 27b:	e8 d9 00 00 00       	call   359 <fstat>
 280:	89 c6                	mov    %eax,%esi
  close(fd);
 282:	89 1c 24             	mov    %ebx,(%esp)
 285:	e8 9f 00 00 00       	call   329 <close>
  return r;
 28a:	83 c4 10             	add    $0x10,%esp
}
 28d:	89 f0                	mov    %esi,%eax
 28f:	8d 65 f8             	lea    -0x8(%ebp),%esp
 292:	5b                   	pop    %ebx
 293:	5e                   	pop    %esi
 294:	5d                   	pop    %ebp
 295:	c3                   	ret    
    return -1;
 296:	be ff ff ff ff       	mov    $0xffffffff,%esi
 29b:	eb f0                	jmp    28d <stat+0x34>

0000029d <atoi>:

int
atoi(const char *s)
{
 29d:	55                   	push   %ebp
 29e:	89 e5                	mov    %esp,%ebp
 2a0:	53                   	push   %ebx
 2a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 2a4:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 2a9:	eb 10                	jmp    2bb <atoi+0x1e>
    n = n*10 + *s++ - '0';
 2ab:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 2ae:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 2b1:	83 c1 01             	add    $0x1,%ecx
 2b4:	0f be c0             	movsbl %al,%eax
 2b7:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 2bb:	0f b6 01             	movzbl (%ecx),%eax
 2be:	8d 58 d0             	lea    -0x30(%eax),%ebx
 2c1:	80 fb 09             	cmp    $0x9,%bl
 2c4:	76 e5                	jbe    2ab <atoi+0xe>
  return n;
}
 2c6:	89 d0                	mov    %edx,%eax
 2c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2cb:	c9                   	leave  
 2cc:	c3                   	ret    

000002cd <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	56                   	push   %esi
 2d1:	53                   	push   %ebx
 2d2:	8b 75 08             	mov    0x8(%ebp),%esi
 2d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 2d8:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 2db:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 2dd:	eb 0d                	jmp    2ec <memmove+0x1f>
    *dst++ = *src++;
 2df:	0f b6 01             	movzbl (%ecx),%eax
 2e2:	88 02                	mov    %al,(%edx)
 2e4:	8d 49 01             	lea    0x1(%ecx),%ecx
 2e7:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 2ea:	89 d8                	mov    %ebx,%eax
 2ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
 2ef:	85 c0                	test   %eax,%eax
 2f1:	7f ec                	jg     2df <memmove+0x12>
  return vdst;
}
 2f3:	89 f0                	mov    %esi,%eax
 2f5:	5b                   	pop    %ebx
 2f6:	5e                   	pop    %esi
 2f7:	5d                   	pop    %ebp
 2f8:	c3                   	ret    

000002f9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f9:	b8 01 00 00 00       	mov    $0x1,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <exit>:
SYSCALL(exit)
 301:	b8 02 00 00 00       	mov    $0x2,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <wait>:
SYSCALL(wait)
 309:	b8 03 00 00 00       	mov    $0x3,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <pipe>:
SYSCALL(pipe)
 311:	b8 04 00 00 00       	mov    $0x4,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <read>:
SYSCALL(read)
 319:	b8 05 00 00 00       	mov    $0x5,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <write>:
SYSCALL(write)
 321:	b8 10 00 00 00       	mov    $0x10,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <close>:
SYSCALL(close)
 329:	b8 15 00 00 00       	mov    $0x15,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <kill>:
SYSCALL(kill)
 331:	b8 06 00 00 00       	mov    $0x6,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <exec>:
SYSCALL(exec)
 339:	b8 07 00 00 00       	mov    $0x7,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <open>:
SYSCALL(open)
 341:	b8 0f 00 00 00       	mov    $0xf,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <mknod>:
SYSCALL(mknod)
 349:	b8 11 00 00 00       	mov    $0x11,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <unlink>:
SYSCALL(unlink)
 351:	b8 12 00 00 00       	mov    $0x12,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <fstat>:
SYSCALL(fstat)
 359:	b8 08 00 00 00       	mov    $0x8,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <link>:
SYSCALL(link)
 361:	b8 13 00 00 00       	mov    $0x13,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <mkdir>:
SYSCALL(mkdir)
 369:	b8 14 00 00 00       	mov    $0x14,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <chdir>:
SYSCALL(chdir)
 371:	b8 09 00 00 00       	mov    $0x9,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <dup>:
SYSCALL(dup)
 379:	b8 0a 00 00 00       	mov    $0xa,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <getpid>:
SYSCALL(getpid)
 381:	b8 0b 00 00 00       	mov    $0xb,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <sbrk>:
SYSCALL(sbrk)
 389:	b8 0c 00 00 00       	mov    $0xc,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <sleep>:
SYSCALL(sleep)
 391:	b8 0d 00 00 00       	mov    $0xd,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret    

00000399 <uptime>:
SYSCALL(uptime)
 399:	b8 0e 00 00 00       	mov    $0xe,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret    

000003a1 <yield>:
SYSCALL(yield)
 3a1:	b8 16 00 00 00       	mov    $0x16,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret    

000003a9 <shutdown>:
SYSCALL(shutdown)
 3a9:	b8 17 00 00 00       	mov    $0x17,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret    

000003b1 <writecount>:
SYSCALL(writecount)
 3b1:	b8 18 00 00 00       	mov    $0x18,%eax
 3b6:	cd 40                	int    $0x40
 3b8:	c3                   	ret    

000003b9 <setwritecount>:
SYSCALL(setwritecount)
 3b9:	b8 19 00 00 00       	mov    $0x19,%eax
 3be:	cd 40                	int    $0x40
 3c0:	c3                   	ret    

000003c1 <settickets>:
SYSCALL(settickets)
 3c1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3c6:	cd 40                	int    $0x40
 3c8:	c3                   	ret    

000003c9 <getprocessesinfo>:
 3c9:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret    

000003d1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3d1:	55                   	push   %ebp
 3d2:	89 e5                	mov    %esp,%ebp
 3d4:	83 ec 1c             	sub    $0x1c,%esp
 3d7:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3da:	6a 01                	push   $0x1
 3dc:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3df:	52                   	push   %edx
 3e0:	50                   	push   %eax
 3e1:	e8 3b ff ff ff       	call   321 <write>
}
 3e6:	83 c4 10             	add    $0x10,%esp
 3e9:	c9                   	leave  
 3ea:	c3                   	ret    

000003eb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3eb:	55                   	push   %ebp
 3ec:	89 e5                	mov    %esp,%ebp
 3ee:	57                   	push   %edi
 3ef:	56                   	push   %esi
 3f0:	53                   	push   %ebx
 3f1:	83 ec 2c             	sub    $0x2c,%esp
 3f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
 3f7:	89 d0                	mov    %edx,%eax
 3f9:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3ff:	0f 95 c1             	setne  %cl
 402:	c1 ea 1f             	shr    $0x1f,%edx
 405:	84 d1                	test   %dl,%cl
 407:	74 44                	je     44d <printint+0x62>
    neg = 1;
    x = -xx;
 409:	f7 d8                	neg    %eax
 40b:	89 c1                	mov    %eax,%ecx
    neg = 1;
 40d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 414:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 419:	89 c8                	mov    %ecx,%eax
 41b:	ba 00 00 00 00       	mov    $0x0,%edx
 420:	f7 f6                	div    %esi
 422:	89 df                	mov    %ebx,%edi
 424:	83 c3 01             	add    $0x1,%ebx
 427:	0f b6 92 74 06 00 00 	movzbl 0x674(%edx),%edx
 42e:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 432:	89 ca                	mov    %ecx,%edx
 434:	89 c1                	mov    %eax,%ecx
 436:	39 d6                	cmp    %edx,%esi
 438:	76 df                	jbe    419 <printint+0x2e>
  if(neg)
 43a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 43e:	74 31                	je     471 <printint+0x86>
    buf[i++] = '-';
 440:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 445:	8d 5f 02             	lea    0x2(%edi),%ebx
 448:	8b 75 d0             	mov    -0x30(%ebp),%esi
 44b:	eb 17                	jmp    464 <printint+0x79>
    x = xx;
 44d:	89 c1                	mov    %eax,%ecx
  neg = 0;
 44f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 456:	eb bc                	jmp    414 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 458:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 45d:	89 f0                	mov    %esi,%eax
 45f:	e8 6d ff ff ff       	call   3d1 <putc>
  while(--i >= 0)
 464:	83 eb 01             	sub    $0x1,%ebx
 467:	79 ef                	jns    458 <printint+0x6d>
}
 469:	83 c4 2c             	add    $0x2c,%esp
 46c:	5b                   	pop    %ebx
 46d:	5e                   	pop    %esi
 46e:	5f                   	pop    %edi
 46f:	5d                   	pop    %ebp
 470:	c3                   	ret    
 471:	8b 75 d0             	mov    -0x30(%ebp),%esi
 474:	eb ee                	jmp    464 <printint+0x79>

00000476 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 476:	55                   	push   %ebp
 477:	89 e5                	mov    %esp,%ebp
 479:	57                   	push   %edi
 47a:	56                   	push   %esi
 47b:	53                   	push   %ebx
 47c:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 47f:	8d 45 10             	lea    0x10(%ebp),%eax
 482:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 485:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 48a:	bb 00 00 00 00       	mov    $0x0,%ebx
 48f:	eb 14                	jmp    4a5 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 491:	89 fa                	mov    %edi,%edx
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	e8 36 ff ff ff       	call   3d1 <putc>
 49b:	eb 05                	jmp    4a2 <printf+0x2c>
      }
    } else if(state == '%'){
 49d:	83 fe 25             	cmp    $0x25,%esi
 4a0:	74 25                	je     4c7 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 4a2:	83 c3 01             	add    $0x1,%ebx
 4a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a8:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 4ac:	84 c0                	test   %al,%al
 4ae:	0f 84 20 01 00 00    	je     5d4 <printf+0x15e>
    c = fmt[i] & 0xff;
 4b4:	0f be f8             	movsbl %al,%edi
 4b7:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4ba:	85 f6                	test   %esi,%esi
 4bc:	75 df                	jne    49d <printf+0x27>
      if(c == '%'){
 4be:	83 f8 25             	cmp    $0x25,%eax
 4c1:	75 ce                	jne    491 <printf+0x1b>
        state = '%';
 4c3:	89 c6                	mov    %eax,%esi
 4c5:	eb db                	jmp    4a2 <printf+0x2c>
      if(c == 'd'){
 4c7:	83 f8 25             	cmp    $0x25,%eax
 4ca:	0f 84 cf 00 00 00    	je     59f <printf+0x129>
 4d0:	0f 8c dd 00 00 00    	jl     5b3 <printf+0x13d>
 4d6:	83 f8 78             	cmp    $0x78,%eax
 4d9:	0f 8f d4 00 00 00    	jg     5b3 <printf+0x13d>
 4df:	83 f8 63             	cmp    $0x63,%eax
 4e2:	0f 8c cb 00 00 00    	jl     5b3 <printf+0x13d>
 4e8:	83 e8 63             	sub    $0x63,%eax
 4eb:	83 f8 15             	cmp    $0x15,%eax
 4ee:	0f 87 bf 00 00 00    	ja     5b3 <printf+0x13d>
 4f4:	ff 24 85 1c 06 00 00 	jmp    *0x61c(,%eax,4)
        printint(fd, *ap, 10, 1);
 4fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4fe:	8b 17                	mov    (%edi),%edx
 500:	83 ec 0c             	sub    $0xc,%esp
 503:	6a 01                	push   $0x1
 505:	b9 0a 00 00 00       	mov    $0xa,%ecx
 50a:	8b 45 08             	mov    0x8(%ebp),%eax
 50d:	e8 d9 fe ff ff       	call   3eb <printint>
        ap++;
 512:	83 c7 04             	add    $0x4,%edi
 515:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 518:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 51b:	be 00 00 00 00       	mov    $0x0,%esi
 520:	eb 80                	jmp    4a2 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 525:	8b 17                	mov    (%edi),%edx
 527:	83 ec 0c             	sub    $0xc,%esp
 52a:	6a 00                	push   $0x0
 52c:	b9 10 00 00 00       	mov    $0x10,%ecx
 531:	8b 45 08             	mov    0x8(%ebp),%eax
 534:	e8 b2 fe ff ff       	call   3eb <printint>
        ap++;
 539:	83 c7 04             	add    $0x4,%edi
 53c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 53f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 542:	be 00 00 00 00       	mov    $0x0,%esi
 547:	e9 56 ff ff ff       	jmp    4a2 <printf+0x2c>
        s = (char*)*ap;
 54c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54f:	8b 30                	mov    (%eax),%esi
        ap++;
 551:	83 c0 04             	add    $0x4,%eax
 554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 557:	85 f6                	test   %esi,%esi
 559:	75 15                	jne    570 <printf+0xfa>
          s = "(null)";
 55b:	be 13 06 00 00       	mov    $0x613,%esi
 560:	eb 0e                	jmp    570 <printf+0xfa>
          putc(fd, *s);
 562:	0f be d2             	movsbl %dl,%edx
 565:	8b 45 08             	mov    0x8(%ebp),%eax
 568:	e8 64 fe ff ff       	call   3d1 <putc>
          s++;
 56d:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 570:	0f b6 16             	movzbl (%esi),%edx
 573:	84 d2                	test   %dl,%dl
 575:	75 eb                	jne    562 <printf+0xec>
      state = 0;
 577:	be 00 00 00 00       	mov    $0x0,%esi
 57c:	e9 21 ff ff ff       	jmp    4a2 <printf+0x2c>
        putc(fd, *ap);
 581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 584:	0f be 17             	movsbl (%edi),%edx
 587:	8b 45 08             	mov    0x8(%ebp),%eax
 58a:	e8 42 fe ff ff       	call   3d1 <putc>
        ap++;
 58f:	83 c7 04             	add    $0x4,%edi
 592:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 595:	be 00 00 00 00       	mov    $0x0,%esi
 59a:	e9 03 ff ff ff       	jmp    4a2 <printf+0x2c>
        putc(fd, c);
 59f:	89 fa                	mov    %edi,%edx
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
 5a4:	e8 28 fe ff ff       	call   3d1 <putc>
      state = 0;
 5a9:	be 00 00 00 00       	mov    $0x0,%esi
 5ae:	e9 ef fe ff ff       	jmp    4a2 <printf+0x2c>
        putc(fd, '%');
 5b3:	ba 25 00 00 00       	mov    $0x25,%edx
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	e8 11 fe ff ff       	call   3d1 <putc>
        putc(fd, c);
 5c0:	89 fa                	mov    %edi,%edx
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	e8 07 fe ff ff       	call   3d1 <putc>
      state = 0;
 5ca:	be 00 00 00 00       	mov    $0x0,%esi
 5cf:	e9 ce fe ff ff       	jmp    4a2 <printf+0x2c>
    }
  }
}
 5d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5d7:	5b                   	pop    %ebx
 5d8:	5e                   	pop    %esi
 5d9:	5f                   	pop    %edi
 5da:	5d                   	pop    %ebp
 5db:	c3                   	ret    
