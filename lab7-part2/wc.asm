
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
   6:	83 ec 3c             	sub    $0x3c,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
   9:	bf 00 00 00 00       	mov    $0x0,%edi
  l = w = c = 0;
   e:	be 00 00 00 00       	mov    $0x0,%esi
  13:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  21:	eb 4b                	jmp    6e <wc+0x6e>
    for(i=0; i<n; i++){
      c++;
  23:	83 c6 01             	add    $0x1,%esi
      if(buf[i] == '\n')
  26:	0f b6 83 a0 06 00 00 	movzbl 0x6a0(%ebx),%eax
  2d:	3c 0a                	cmp    $0xa,%al
  2f:	75 04                	jne    35 <wc+0x35>
        l++;
  31:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  35:	0f be c0             	movsbl %al,%eax
  38:	89 44 24 04          	mov    %eax,0x4(%esp)
  3c:	c7 04 24 e8 05 00 00 	movl   $0x5e8,(%esp)
  43:	e8 a9 01 00 00       	call   1f1 <strchr>
  48:	85 c0                	test   %eax,%eax
  4a:	75 0e                	jne    5a <wc+0x5a>
        inword = 0;
      else if(!inword){
  4c:	85 ff                	test   %edi,%edi
  4e:	75 0f                	jne    5f <wc+0x5f>
        w++;
  50:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
        inword = 1;
  54:	66 bf 01 00          	mov    $0x1,%di
  58:	eb 05                	jmp    5f <wc+0x5f>
        inword = 0;
  5a:	bf 00 00 00 00       	mov    $0x0,%edi
    for(i=0; i<n; i++){
  5f:	83 c3 01             	add    $0x1,%ebx
  62:	eb 05                	jmp    69 <wc+0x69>
  64:	bb 00 00 00 00       	mov    $0x0,%ebx
  69:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  6c:	7c b5                	jl     23 <wc+0x23>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  75:	00 
  76:	c7 44 24 04 a0 06 00 	movl   $0x6a0,0x4(%esp)
  7d:	00 
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 a2 02 00 00       	call   32b <read>
  89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8c:	85 c0                	test   %eax,%eax
  8e:	7f d4                	jg     64 <wc+0x64>
      }
    }
  }
  if(n < 0){
  90:	85 c0                	test   %eax,%eax
  92:	79 19                	jns    ad <wc+0xad>
    printf(1, "wc: read error\n");
  94:	c7 44 24 04 ee 05 00 	movl   $0x5ee,0x4(%esp)
  9b:	00 
  9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a3:	e8 d8 03 00 00       	call   480 <printf>
    exit();
  a8:	e8 66 02 00 00       	call   313 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  b0:	89 44 24 14          	mov    %eax,0x14(%esp)
  b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  c6:	c7 44 24 04 fe 05 00 	movl   $0x5fe,0x4(%esp)
  cd:	00 
  ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d5:	e8 a6 03 00 00       	call   480 <printf>
}
  da:	83 c4 3c             	add    $0x3c,%esp
  dd:	5b                   	pop    %ebx
  de:	5e                   	pop    %esi
  df:	5f                   	pop    %edi
  e0:	5d                   	pop    %ebp
  e1:	c3                   	ret    

000000e2 <main>:

int
main(int argc, char *argv[])
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	57                   	push   %edi
  e6:	56                   	push   %esi
  e7:	53                   	push   %ebx
  e8:	83 e4 f0             	and    $0xfffffff0,%esp
  eb:	83 ec 10             	sub    $0x10,%esp
  int fd, i;

  if(argc <= 1){
  ee:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  f2:	7f 71                	jg     165 <main+0x83>
    wc(0, "");
  f4:	c7 44 24 04 fd 05 00 	movl   $0x5fd,0x4(%esp)
  fb:	00 
  fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 103:	e8 f8 fe ff ff       	call   0 <wc>
    exit();
 108:	e8 06 02 00 00       	call   313 <exit>
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 113:	8b 07                	mov    (%edi),%eax
 115:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 11c:	00 
 11d:	89 04 24             	mov    %eax,(%esp)
 120:	e8 2e 02 00 00       	call   353 <open>
 125:	89 c6                	mov    %eax,%esi
 127:	85 c0                	test   %eax,%eax
 129:	79 1f                	jns    14a <main+0x68>
      printf(1, "wc: cannot open %s\n", argv[i]);
 12b:	8b 07                	mov    (%edi),%eax
 12d:	89 44 24 08          	mov    %eax,0x8(%esp)
 131:	c7 44 24 04 0b 06 00 	movl   $0x60b,0x4(%esp)
 138:	00 
 139:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 140:	e8 3b 03 00 00       	call   480 <printf>
      exit();
 145:	e8 c9 01 00 00       	call   313 <exit>
    }
    wc(fd, argv[i]);
 14a:	8b 07                	mov    (%edi),%eax
 14c:	89 44 24 04          	mov    %eax,0x4(%esp)
 150:	89 34 24             	mov    %esi,(%esp)
 153:	e8 a8 fe ff ff       	call   0 <wc>
    close(fd);
 158:	89 34 24             	mov    %esi,(%esp)
 15b:	e8 db 01 00 00       	call   33b <close>
  for(i = 1; i < argc; i++){
 160:	83 c3 01             	add    $0x1,%ebx
 163:	eb 05                	jmp    16a <main+0x88>
 165:	bb 01 00 00 00       	mov    $0x1,%ebx
 16a:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 16d:	7c 9e                	jl     10d <main+0x2b>
  }
  exit();
 16f:	e8 9f 01 00 00       	call   313 <exit>

00000174 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
 177:	56                   	push   %esi
 178:	53                   	push   %ebx
 179:	8b 75 08             	mov    0x8(%ebp),%esi
 17c:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 17f:	89 f0                	mov    %esi,%eax
 181:	89 d1                	mov    %edx,%ecx
 183:	83 c2 01             	add    $0x1,%edx
 186:	89 c3                	mov    %eax,%ebx
 188:	83 c0 01             	add    $0x1,%eax
 18b:	0f b6 09             	movzbl (%ecx),%ecx
 18e:	88 0b                	mov    %cl,(%ebx)
 190:	84 c9                	test   %cl,%cl
 192:	75 ed                	jne    181 <strcpy+0xd>
    ;
  return os;
}
 194:	89 f0                	mov    %esi,%eax
 196:	5b                   	pop    %ebx
 197:	5e                   	pop    %esi
 198:	5d                   	pop    %ebp
 199:	c3                   	ret    

0000019a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19a:	55                   	push   %ebp
 19b:	89 e5                	mov    %esp,%ebp
 19d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 1a3:	eb 06                	jmp    1ab <strcmp+0x11>
    p++, q++;
 1a5:	83 c1 01             	add    $0x1,%ecx
 1a8:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1ab:	0f b6 01             	movzbl (%ecx),%eax
 1ae:	84 c0                	test   %al,%al
 1b0:	74 04                	je     1b6 <strcmp+0x1c>
 1b2:	3a 02                	cmp    (%edx),%al
 1b4:	74 ef                	je     1a5 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 1b6:	0f b6 c0             	movzbl %al,%eax
 1b9:	0f b6 12             	movzbl (%edx),%edx
 1bc:	29 d0                	sub    %edx,%eax
}
 1be:	5d                   	pop    %ebp
 1bf:	c3                   	ret    

000001c0 <strlen>:

uint
strlen(const char *s)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1c6:	b8 00 00 00 00       	mov    $0x0,%eax
 1cb:	eb 03                	jmp    1d0 <strlen+0x10>
 1cd:	83 c0 01             	add    $0x1,%eax
 1d0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
 1d4:	75 f7                	jne    1cd <strlen+0xd>
    ;
  return n;
}
 1d6:	5d                   	pop    %ebp
 1d7:	c3                   	ret    

000001d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	57                   	push   %edi
 1dc:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1df:	89 d7                	mov    %edx,%edi
 1e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e7:	fc                   	cld    
 1e8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1ea:	89 d0                	mov    %edx,%eax
 1ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
 1ef:	c9                   	leave  
 1f0:	c3                   	ret    

000001f1 <strchr>:

char*
strchr(const char *s, char c)
{
 1f1:	55                   	push   %ebp
 1f2:	89 e5                	mov    %esp,%ebp
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
 1f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1fb:	eb 03                	jmp    200 <strchr+0xf>
 1fd:	83 c0 01             	add    $0x1,%eax
 200:	0f b6 10             	movzbl (%eax),%edx
 203:	84 d2                	test   %dl,%dl
 205:	74 06                	je     20d <strchr+0x1c>
    if(*s == c)
 207:	38 ca                	cmp    %cl,%dl
 209:	75 f2                	jne    1fd <strchr+0xc>
 20b:	eb 05                	jmp    212 <strchr+0x21>
      return (char*)s;
  return 0;
 20d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 212:	5d                   	pop    %ebp
 213:	c3                   	ret    

00000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	57                   	push   %edi
 218:	56                   	push   %esi
 219:	53                   	push   %ebx
 21a:	83 ec 1c             	sub    $0x1c,%esp
 21d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 220:	bb 00 00 00 00       	mov    $0x0,%ebx
 225:	89 de                	mov    %ebx,%esi
 227:	83 c3 01             	add    $0x1,%ebx
 22a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 22d:	7d 2e                	jge    25d <gets+0x49>
    cc = read(0, &c, 1);
 22f:	83 ec 04             	sub    $0x4,%esp
 232:	6a 01                	push   $0x1
 234:	8d 45 e7             	lea    -0x19(%ebp),%eax
 237:	50                   	push   %eax
 238:	6a 00                	push   $0x0
 23a:	e8 ec 00 00 00       	call   32b <read>
    if(cc < 1)
 23f:	83 c4 10             	add    $0x10,%esp
 242:	85 c0                	test   %eax,%eax
 244:	7e 17                	jle    25d <gets+0x49>
      break;
    buf[i++] = c;
 246:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 24a:	88 04 37             	mov    %al,(%edi,%esi,1)
    if(c == '\n' || c == '\r')
 24d:	3c 0a                	cmp    $0xa,%al
 24f:	0f 94 c2             	sete   %dl
 252:	3c 0d                	cmp    $0xd,%al
 254:	0f 94 c0             	sete   %al
 257:	08 c2                	or     %al,%dl
 259:	74 ca                	je     225 <gets+0x11>
    buf[i++] = c;
 25b:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 25d:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 261:	89 f8                	mov    %edi,%eax
 263:	8d 65 f4             	lea    -0xc(%ebp),%esp
 266:	5b                   	pop    %ebx
 267:	5e                   	pop    %esi
 268:	5f                   	pop    %edi
 269:	5d                   	pop    %ebp
 26a:	c3                   	ret    

0000026b <stat>:

int
stat(const char *n, struct stat *st)
{
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	56                   	push   %esi
 26f:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 270:	83 ec 08             	sub    $0x8,%esp
 273:	6a 00                	push   $0x0
 275:	ff 75 08             	push   0x8(%ebp)
 278:	e8 d6 00 00 00       	call   353 <open>
  if(fd < 0)
 27d:	83 c4 10             	add    $0x10,%esp
 280:	85 c0                	test   %eax,%eax
 282:	78 24                	js     2a8 <stat+0x3d>
 284:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 286:	83 ec 08             	sub    $0x8,%esp
 289:	ff 75 0c             	push   0xc(%ebp)
 28c:	50                   	push   %eax
 28d:	e8 d9 00 00 00       	call   36b <fstat>
 292:	89 c6                	mov    %eax,%esi
  close(fd);
 294:	89 1c 24             	mov    %ebx,(%esp)
 297:	e8 9f 00 00 00       	call   33b <close>
  return r;
 29c:	83 c4 10             	add    $0x10,%esp
}
 29f:	89 f0                	mov    %esi,%eax
 2a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
 2a4:	5b                   	pop    %ebx
 2a5:	5e                   	pop    %esi
 2a6:	5d                   	pop    %ebp
 2a7:	c3                   	ret    
    return -1;
 2a8:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2ad:	eb f0                	jmp    29f <stat+0x34>

000002af <atoi>:

int
atoi(const char *s)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	53                   	push   %ebx
 2b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 2b6:	ba 00 00 00 00       	mov    $0x0,%edx
  while('0' <= *s && *s <= '9')
 2bb:	eb 10                	jmp    2cd <atoi+0x1e>
    n = n*10 + *s++ - '0';
 2bd:	8d 1c 92             	lea    (%edx,%edx,4),%ebx
 2c0:	8d 14 1b             	lea    (%ebx,%ebx,1),%edx
 2c3:	83 c1 01             	add    $0x1,%ecx
 2c6:	0f be c0             	movsbl %al,%eax
 2c9:	8d 54 10 d0          	lea    -0x30(%eax,%edx,1),%edx
  while('0' <= *s && *s <= '9')
 2cd:	0f b6 01             	movzbl (%ecx),%eax
 2d0:	8d 58 d0             	lea    -0x30(%eax),%ebx
 2d3:	80 fb 09             	cmp    $0x9,%bl
 2d6:	76 e5                	jbe    2bd <atoi+0xe>
  return n;
}
 2d8:	89 d0                	mov    %edx,%eax
 2da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 2dd:	c9                   	leave  
 2de:	c3                   	ret    

000002df <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2df:	55                   	push   %ebp
 2e0:	89 e5                	mov    %esp,%ebp
 2e2:	56                   	push   %esi
 2e3:	53                   	push   %ebx
 2e4:	8b 75 08             	mov    0x8(%ebp),%esi
 2e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 2ea:	8b 45 10             	mov    0x10(%ebp),%eax
  char *dst;
  const char *src;

  dst = vdst;
 2ed:	89 f2                	mov    %esi,%edx
  src = vsrc;
  while(n-- > 0)
 2ef:	eb 0d                	jmp    2fe <memmove+0x1f>
    *dst++ = *src++;
 2f1:	0f b6 01             	movzbl (%ecx),%eax
 2f4:	88 02                	mov    %al,(%edx)
 2f6:	8d 49 01             	lea    0x1(%ecx),%ecx
 2f9:	8d 52 01             	lea    0x1(%edx),%edx
  while(n-- > 0)
 2fc:	89 d8                	mov    %ebx,%eax
 2fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
 301:	85 c0                	test   %eax,%eax
 303:	7f ec                	jg     2f1 <memmove+0x12>
  return vdst;
}
 305:	89 f0                	mov    %esi,%eax
 307:	5b                   	pop    %ebx
 308:	5e                   	pop    %esi
 309:	5d                   	pop    %ebp
 30a:	c3                   	ret    

0000030b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 30b:	b8 01 00 00 00       	mov    $0x1,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <exit>:
SYSCALL(exit)
 313:	b8 02 00 00 00       	mov    $0x2,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <wait>:
SYSCALL(wait)
 31b:	b8 03 00 00 00       	mov    $0x3,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <pipe>:
SYSCALL(pipe)
 323:	b8 04 00 00 00       	mov    $0x4,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <read>:
SYSCALL(read)
 32b:	b8 05 00 00 00       	mov    $0x5,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <write>:
SYSCALL(write)
 333:	b8 10 00 00 00       	mov    $0x10,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <close>:
SYSCALL(close)
 33b:	b8 15 00 00 00       	mov    $0x15,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <kill>:
SYSCALL(kill)
 343:	b8 06 00 00 00       	mov    $0x6,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <exec>:
SYSCALL(exec)
 34b:	b8 07 00 00 00       	mov    $0x7,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <open>:
SYSCALL(open)
 353:	b8 0f 00 00 00       	mov    $0xf,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <mknod>:
SYSCALL(mknod)
 35b:	b8 11 00 00 00       	mov    $0x11,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <unlink>:
SYSCALL(unlink)
 363:	b8 12 00 00 00       	mov    $0x12,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <fstat>:
SYSCALL(fstat)
 36b:	b8 08 00 00 00       	mov    $0x8,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <link>:
SYSCALL(link)
 373:	b8 13 00 00 00       	mov    $0x13,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <mkdir>:
SYSCALL(mkdir)
 37b:	b8 14 00 00 00       	mov    $0x14,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <chdir>:
SYSCALL(chdir)
 383:	b8 09 00 00 00       	mov    $0x9,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <dup>:
SYSCALL(dup)
 38b:	b8 0a 00 00 00       	mov    $0xa,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <getpid>:
SYSCALL(getpid)
 393:	b8 0b 00 00 00       	mov    $0xb,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <sbrk>:
SYSCALL(sbrk)
 39b:	b8 0c 00 00 00       	mov    $0xc,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <sleep>:
SYSCALL(sleep)
 3a3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <uptime>:
SYSCALL(uptime)
 3ab:	b8 0e 00 00 00       	mov    $0xe,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <yield>:
SYSCALL(yield)
 3b3:	b8 16 00 00 00       	mov    $0x16,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <shutdown>:
SYSCALL(shutdown)
 3bb:	b8 17 00 00 00       	mov    $0x17,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <getpagetableentry>:
SYSCALL(getpagetableentry)
 3c3:	b8 18 00 00 00       	mov    $0x18,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 3cb:	b8 19 00 00 00       	mov    $0x19,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <dumppagetable>:
 3d3:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3db:	55                   	push   %ebp
 3dc:	89 e5                	mov    %esp,%ebp
 3de:	83 ec 1c             	sub    $0x1c,%esp
 3e1:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3e4:	6a 01                	push   $0x1
 3e6:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3e9:	52                   	push   %edx
 3ea:	50                   	push   %eax
 3eb:	e8 43 ff ff ff       	call   333 <write>
}
 3f0:	83 c4 10             	add    $0x10,%esp
 3f3:	c9                   	leave  
 3f4:	c3                   	ret    

000003f5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	57                   	push   %edi
 3f9:	56                   	push   %esi
 3fa:	53                   	push   %ebx
 3fb:	83 ec 2c             	sub    $0x2c,%esp
 3fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
 401:	89 d0                	mov    %edx,%eax
 403:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 405:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 409:	0f 95 c1             	setne  %cl
 40c:	c1 ea 1f             	shr    $0x1f,%edx
 40f:	84 d1                	test   %dl,%cl
 411:	74 44                	je     457 <printint+0x62>
    neg = 1;
    x = -xx;
 413:	f7 d8                	neg    %eax
 415:	89 c1                	mov    %eax,%ecx
    neg = 1;
 417:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 41e:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 423:	89 c8                	mov    %ecx,%eax
 425:	ba 00 00 00 00       	mov    $0x0,%edx
 42a:	f7 f6                	div    %esi
 42c:	89 df                	mov    %ebx,%edi
 42e:	83 c3 01             	add    $0x1,%ebx
 431:	0f b6 92 80 06 00 00 	movzbl 0x680(%edx),%edx
 438:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 43c:	89 ca                	mov    %ecx,%edx
 43e:	89 c1                	mov    %eax,%ecx
 440:	39 d6                	cmp    %edx,%esi
 442:	76 df                	jbe    423 <printint+0x2e>
  if(neg)
 444:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 448:	74 31                	je     47b <printint+0x86>
    buf[i++] = '-';
 44a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 44f:	8d 5f 02             	lea    0x2(%edi),%ebx
 452:	8b 75 d0             	mov    -0x30(%ebp),%esi
 455:	eb 17                	jmp    46e <printint+0x79>
    x = xx;
 457:	89 c1                	mov    %eax,%ecx
  neg = 0;
 459:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 460:	eb bc                	jmp    41e <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 462:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 467:	89 f0                	mov    %esi,%eax
 469:	e8 6d ff ff ff       	call   3db <putc>
  while(--i >= 0)
 46e:	83 eb 01             	sub    $0x1,%ebx
 471:	79 ef                	jns    462 <printint+0x6d>
}
 473:	83 c4 2c             	add    $0x2c,%esp
 476:	5b                   	pop    %ebx
 477:	5e                   	pop    %esi
 478:	5f                   	pop    %edi
 479:	5d                   	pop    %ebp
 47a:	c3                   	ret    
 47b:	8b 75 d0             	mov    -0x30(%ebp),%esi
 47e:	eb ee                	jmp    46e <printint+0x79>

00000480 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	57                   	push   %edi
 484:	56                   	push   %esi
 485:	53                   	push   %ebx
 486:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 489:	8d 45 10             	lea    0x10(%ebp),%eax
 48c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 48f:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 494:	bb 00 00 00 00       	mov    $0x0,%ebx
 499:	eb 14                	jmp    4af <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 49b:	89 fa                	mov    %edi,%edx
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	e8 36 ff ff ff       	call   3db <putc>
 4a5:	eb 05                	jmp    4ac <printf+0x2c>
      }
    } else if(state == '%'){
 4a7:	83 fe 25             	cmp    $0x25,%esi
 4aa:	74 25                	je     4d1 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 4ac:	83 c3 01             	add    $0x1,%ebx
 4af:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b2:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 4b6:	84 c0                	test   %al,%al
 4b8:	0f 84 20 01 00 00    	je     5de <printf+0x15e>
    c = fmt[i] & 0xff;
 4be:	0f be f8             	movsbl %al,%edi
 4c1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4c4:	85 f6                	test   %esi,%esi
 4c6:	75 df                	jne    4a7 <printf+0x27>
      if(c == '%'){
 4c8:	83 f8 25             	cmp    $0x25,%eax
 4cb:	75 ce                	jne    49b <printf+0x1b>
        state = '%';
 4cd:	89 c6                	mov    %eax,%esi
 4cf:	eb db                	jmp    4ac <printf+0x2c>
      if(c == 'd'){
 4d1:	83 f8 25             	cmp    $0x25,%eax
 4d4:	0f 84 cf 00 00 00    	je     5a9 <printf+0x129>
 4da:	0f 8c dd 00 00 00    	jl     5bd <printf+0x13d>
 4e0:	83 f8 78             	cmp    $0x78,%eax
 4e3:	0f 8f d4 00 00 00    	jg     5bd <printf+0x13d>
 4e9:	83 f8 63             	cmp    $0x63,%eax
 4ec:	0f 8c cb 00 00 00    	jl     5bd <printf+0x13d>
 4f2:	83 e8 63             	sub    $0x63,%eax
 4f5:	83 f8 15             	cmp    $0x15,%eax
 4f8:	0f 87 bf 00 00 00    	ja     5bd <printf+0x13d>
 4fe:	ff 24 85 28 06 00 00 	jmp    *0x628(,%eax,4)
        printint(fd, *ap, 10, 1);
 505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 508:	8b 17                	mov    (%edi),%edx
 50a:	83 ec 0c             	sub    $0xc,%esp
 50d:	6a 01                	push   $0x1
 50f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	e8 d9 fe ff ff       	call   3f5 <printint>
        ap++;
 51c:	83 c7 04             	add    $0x4,%edi
 51f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 522:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 525:	be 00 00 00 00       	mov    $0x0,%esi
 52a:	eb 80                	jmp    4ac <printf+0x2c>
        printint(fd, *ap, 16, 0);
 52c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 52f:	8b 17                	mov    (%edi),%edx
 531:	83 ec 0c             	sub    $0xc,%esp
 534:	6a 00                	push   $0x0
 536:	b9 10 00 00 00       	mov    $0x10,%ecx
 53b:	8b 45 08             	mov    0x8(%ebp),%eax
 53e:	e8 b2 fe ff ff       	call   3f5 <printint>
        ap++;
 543:	83 c7 04             	add    $0x4,%edi
 546:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 549:	83 c4 10             	add    $0x10,%esp
      state = 0;
 54c:	be 00 00 00 00       	mov    $0x0,%esi
 551:	e9 56 ff ff ff       	jmp    4ac <printf+0x2c>
        s = (char*)*ap;
 556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 559:	8b 30                	mov    (%eax),%esi
        ap++;
 55b:	83 c0 04             	add    $0x4,%eax
 55e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 561:	85 f6                	test   %esi,%esi
 563:	75 15                	jne    57a <printf+0xfa>
          s = "(null)";
 565:	be 1f 06 00 00       	mov    $0x61f,%esi
 56a:	eb 0e                	jmp    57a <printf+0xfa>
          putc(fd, *s);
 56c:	0f be d2             	movsbl %dl,%edx
 56f:	8b 45 08             	mov    0x8(%ebp),%eax
 572:	e8 64 fe ff ff       	call   3db <putc>
          s++;
 577:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 57a:	0f b6 16             	movzbl (%esi),%edx
 57d:	84 d2                	test   %dl,%dl
 57f:	75 eb                	jne    56c <printf+0xec>
      state = 0;
 581:	be 00 00 00 00       	mov    $0x0,%esi
 586:	e9 21 ff ff ff       	jmp    4ac <printf+0x2c>
        putc(fd, *ap);
 58b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 58e:	0f be 17             	movsbl (%edi),%edx
 591:	8b 45 08             	mov    0x8(%ebp),%eax
 594:	e8 42 fe ff ff       	call   3db <putc>
        ap++;
 599:	83 c7 04             	add    $0x4,%edi
 59c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 59f:	be 00 00 00 00       	mov    $0x0,%esi
 5a4:	e9 03 ff ff ff       	jmp    4ac <printf+0x2c>
        putc(fd, c);
 5a9:	89 fa                	mov    %edi,%edx
 5ab:	8b 45 08             	mov    0x8(%ebp),%eax
 5ae:	e8 28 fe ff ff       	call   3db <putc>
      state = 0;
 5b3:	be 00 00 00 00       	mov    $0x0,%esi
 5b8:	e9 ef fe ff ff       	jmp    4ac <printf+0x2c>
        putc(fd, '%');
 5bd:	ba 25 00 00 00       	mov    $0x25,%edx
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	e8 11 fe ff ff       	call   3db <putc>
        putc(fd, c);
 5ca:	89 fa                	mov    %edi,%edx
 5cc:	8b 45 08             	mov    0x8(%ebp),%eax
 5cf:	e8 07 fe ff ff       	call   3db <putc>
      state = 0;
 5d4:	be 00 00 00 00       	mov    $0x0,%esi
 5d9:	e9 ce fe ff ff       	jmp    4ac <printf+0x2c>
    }
  }
}
 5de:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5e1:	5b                   	pop    %ebx
 5e2:	5e                   	pop    %esi
 5e3:	5f                   	pop    %edi
 5e4:	5d                   	pop    %ebp
 5e5:	c3                   	ret    
