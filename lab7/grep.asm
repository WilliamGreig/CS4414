
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 1c             	sub    $0x1c,%esp
   9:	8b 75 08             	mov    0x8(%ebp),%esi
   c:	8b 7d 0c             	mov    0xc(%ebp),%edi
   f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
  12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  16:	89 3c 24             	mov    %edi,(%esp)
  19:	e8 29 00 00 00       	call   47 <matchhere>
  1e:	85 c0                	test   %eax,%eax
  20:	75 18                	jne    3a <matchstar+0x3a>
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  22:	0f b6 13             	movzbl (%ebx),%edx
  25:	84 d2                	test   %dl,%dl
  27:	74 16                	je     3f <matchstar+0x3f>
  29:	83 c3 01             	add    $0x1,%ebx
  2c:	0f be d2             	movsbl %dl,%edx
  2f:	39 f2                	cmp    %esi,%edx
  31:	74 df                	je     12 <matchstar+0x12>
  33:	83 fe 2e             	cmp    $0x2e,%esi
  36:	74 da                	je     12 <matchstar+0x12>
  38:	eb 05                	jmp    3f <matchstar+0x3f>
      return 1;
  3a:	b8 01 00 00 00       	mov    $0x1,%eax
  return 0;
}
  3f:	83 c4 1c             	add    $0x1c,%esp
  42:	5b                   	pop    %ebx
  43:	5e                   	pop    %esi
  44:	5f                   	pop    %edi
  45:	5d                   	pop    %ebp
  46:	c3                   	ret    

00000047 <matchhere>:
{
  47:	55                   	push   %ebp
  48:	89 e5                	mov    %esp,%ebp
  4a:	83 ec 18             	sub    $0x18,%esp
  4d:	8b 55 08             	mov    0x8(%ebp),%edx
  if(re[0] == '\0')
  50:	0f b6 02             	movzbl (%edx),%eax
  53:	84 c0                	test   %al,%al
  55:	74 63                	je     ba <matchhere+0x73>
  if(re[1] == '*')
  57:	0f b6 4a 01          	movzbl 0x1(%edx),%ecx
  5b:	80 f9 2a             	cmp    $0x2a,%cl
  5e:	75 1b                	jne    7b <matchhere+0x34>
    return matchstar(re[0], re+2, text);
  60:	83 c2 02             	add    $0x2,%edx
  63:	0f be c0             	movsbl %al,%eax
  66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  69:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  71:	89 04 24             	mov    %eax,(%esp)
  74:	e8 87 ff ff ff       	call   0 <matchstar>
  79:	eb 52                	jmp    cd <matchhere+0x86>
  if(re[0] == '$' && re[1] == '\0')
  7b:	3c 24                	cmp    $0x24,%al
  7d:	75 12                	jne    91 <matchhere+0x4a>
  7f:	84 c9                	test   %cl,%cl
  81:	75 0e                	jne    91 <matchhere+0x4a>
    return *text == '\0';
  83:	8b 45 0c             	mov    0xc(%ebp),%eax
  86:	80 38 00             	cmpb   $0x0,(%eax)
  89:	0f 94 c0             	sete   %al
  8c:	0f b6 c0             	movzbl %al,%eax
  8f:	eb 3c                	jmp    cd <matchhere+0x86>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  94:	0f b6 09             	movzbl (%ecx),%ecx
  97:	84 c9                	test   %cl,%cl
  99:	74 26                	je     c1 <matchhere+0x7a>
  9b:	3c 2e                	cmp    $0x2e,%al
  9d:	74 04                	je     a3 <matchhere+0x5c>
  9f:	38 c8                	cmp    %cl,%al
  a1:	75 25                	jne    c8 <matchhere+0x81>
    return matchhere(re+1, text+1);
  a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  a6:	83 c0 01             	add    $0x1,%eax
  a9:	83 c2 01             	add    $0x1,%edx
  ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  b0:	89 14 24             	mov    %edx,(%esp)
  b3:	e8 8f ff ff ff       	call   47 <matchhere>
  b8:	eb 13                	jmp    cd <matchhere+0x86>
    return 1;
  ba:	b8 01 00 00 00       	mov    $0x1,%eax
  bf:	eb 0c                	jmp    cd <matchhere+0x86>
  return 0;
  c1:	b8 00 00 00 00       	mov    $0x0,%eax
  c6:	eb 05                	jmp    cd <matchhere+0x86>
  c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  cd:	c9                   	leave  
  ce:	c3                   	ret    

000000cf <match>:
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	56                   	push   %esi
  d3:	53                   	push   %ebx
  d4:	83 ec 10             	sub    $0x10,%esp
  d7:	8b 75 08             	mov    0x8(%ebp),%esi
  da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(re[0] == '^')
  dd:	80 3e 5e             	cmpb   $0x5e,(%esi)
  e0:	75 13                	jne    f5 <match+0x26>
    return matchhere(re+1, text);
  e2:	83 c6 01             	add    $0x1,%esi
  e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  e9:	89 34 24             	mov    %esi,(%esp)
  ec:	e8 56 ff ff ff       	call   47 <matchhere>
  f1:	eb 24                	jmp    117 <match+0x48>
  }while(*text++ != '\0');
  f3:	89 d3                	mov    %edx,%ebx
    if(matchhere(re, text))
  f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  f9:	89 34 24             	mov    %esi,(%esp)
  fc:	e8 46 ff ff ff       	call   47 <matchhere>
 101:	85 c0                	test   %eax,%eax
 103:	75 0d                	jne    112 <match+0x43>
  }while(*text++ != '\0');
 105:	8d 53 01             	lea    0x1(%ebx),%edx
 108:	80 3b 00             	cmpb   $0x0,(%ebx)
 10b:	75 e6                	jne    f3 <match+0x24>
 10d:	8d 76 00             	lea    0x0(%esi),%esi
 110:	eb 05                	jmp    117 <match+0x48>
      return 1;
 112:	b8 01 00 00 00       	mov    $0x1,%eax
}
 117:	83 c4 10             	add    $0x10,%esp
 11a:	5b                   	pop    %ebx
 11b:	5e                   	pop    %esi
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    

0000011e <grep>:
{
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	57                   	push   %edi
 122:	56                   	push   %esi
 123:	53                   	push   %ebx
 124:	83 ec 1c             	sub    $0x1c,%esp
 127:	8b 7d 08             	mov    0x8(%ebp),%edi
  m = 0;
 12a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 131:	e9 93 00 00 00       	jmp    1c9 <grep+0xab>
    m += n;
 136:	01 45 e4             	add    %eax,-0x1c(%ebp)
    buf[m] = '\0';
 139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 13c:	c6 80 a0 07 00 00 00 	movb   $0x0,0x7a0(%eax)
    p = buf;
 143:	be a0 07 00 00       	mov    $0x7a0,%esi
    while((q = strchr(p, '\n')) != 0){
 148:	eb 32                	jmp    17c <grep+0x5e>
      *q = 0;
 14a:	c6 03 00             	movb   $0x0,(%ebx)
      if(match(pattern, p)){
 14d:	89 74 24 04          	mov    %esi,0x4(%esp)
 151:	89 3c 24             	mov    %edi,(%esp)
 154:	e8 76 ff ff ff       	call   cf <match>
 159:	85 c0                	test   %eax,%eax
 15b:	74 1c                	je     179 <grep+0x5b>
        *q = '\n';
 15d:	c6 03 0a             	movb   $0xa,(%ebx)
        write(1, p, q+1 - p);
 160:	8d 43 01             	lea    0x1(%ebx),%eax
 163:	29 f0                	sub    %esi,%eax
 165:	89 44 24 08          	mov    %eax,0x8(%esp)
 169:	89 74 24 04          	mov    %esi,0x4(%esp)
 16d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 174:	e8 fc 02 00 00       	call   475 <write>
      p = q+1;
 179:	8d 73 01             	lea    0x1(%ebx),%esi
    while((q = strchr(p, '\n')) != 0){
 17c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
 183:	00 
 184:	89 34 24             	mov    %esi,(%esp)
 187:	e8 9d 01 00 00       	call   329 <strchr>
 18c:	89 c3                	mov    %eax,%ebx
 18e:	85 c0                	test   %eax,%eax
 190:	75 b8                	jne    14a <grep+0x2c>
    if(p == buf)
 192:	81 fe a0 07 00 00    	cmp    $0x7a0,%esi
 198:	75 07                	jne    1a1 <grep+0x83>
      m = 0;
 19a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    if(m > 0){
 1a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 1a5:	7e 22                	jle    1c9 <grep+0xab>
      m -= p - buf;
 1a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1aa:	29 f0                	sub    %esi,%eax
 1ac:	8d 80 a0 07 00 00    	lea    0x7a0(%eax),%eax
 1b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      memmove(buf, p, m);
 1b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 1b9:	89 74 24 04          	mov    %esi,0x4(%esp)
 1bd:	c7 04 24 a0 07 00 00 	movl   $0x7a0,(%esp)
 1c4:	e8 5a 02 00 00       	call   423 <memmove>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 1c9:	ba ff 03 00 00       	mov    $0x3ff,%edx
 1ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1d1:	29 c2                	sub    %eax,%edx
 1d3:	05 a0 07 00 00       	add    $0x7a0,%eax
 1d8:	89 54 24 08          	mov    %edx,0x8(%esp)
 1dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e3:	89 04 24             	mov    %eax,(%esp)
 1e6:	e8 82 02 00 00       	call   46d <read>
 1eb:	85 c0                	test   %eax,%eax
 1ed:	0f 8f 43 ff ff ff    	jg     136 <grep+0x18>
}
 1f3:	83 c4 1c             	add    $0x1c,%esp
 1f6:	5b                   	pop    %ebx
 1f7:	5e                   	pop    %esi
 1f8:	5f                   	pop    %edi
 1f9:	5d                   	pop    %ebp
 1fa:	c3                   	ret    

000001fb <main>:
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	57                   	push   %edi
 1ff:	56                   	push   %esi
 200:	53                   	push   %ebx
 201:	83 e4 f0             	and    $0xfffffff0,%esp
 204:	83 ec 10             	sub    $0x10,%esp
  if(argc <= 1){
 207:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 20b:	7f 19                	jg     226 <main+0x2b>
    printf(2, "usage: grep pattern [file ...]\n");
 20d:	c7 44 24 04 38 07 00 	movl   $0x738,0x4(%esp)
 214:	00 
 215:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 21c:	e8 bb 03 00 00       	call   5dc <printf>
    exit();
 221:	e8 2f 02 00 00       	call   455 <exit>
  pattern = argv[1];
 226:	8b 45 0c             	mov    0xc(%ebp),%eax
 229:	8b 40 04             	mov    0x4(%eax),%eax
 22c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  if(argc <= 2){
 230:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 234:	7f 6f                	jg     2a5 <main+0xaa>
    grep(pattern, 0);
 236:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 23d:	00 
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 d8 fe ff ff       	call   11e <grep>
    exit();
 246:	e8 0a 02 00 00       	call   455 <exit>
    if((fd = open(argv[i], 0)) < 0){
 24b:	8b 45 0c             	mov    0xc(%ebp),%eax
 24e:	8d 3c 98             	lea    (%eax,%ebx,4),%edi
 251:	8b 07                	mov    (%edi),%eax
 253:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 25a:	00 
 25b:	89 04 24             	mov    %eax,(%esp)
 25e:	e8 32 02 00 00       	call   495 <open>
 263:	89 c6                	mov    %eax,%esi
 265:	85 c0                	test   %eax,%eax
 267:	79 1f                	jns    288 <main+0x8d>
      printf(1, "grep: cannot open %s\n", argv[i]);
 269:	8b 07                	mov    (%edi),%eax
 26b:	89 44 24 08          	mov    %eax,0x8(%esp)
 26f:	c7 44 24 04 58 07 00 	movl   $0x758,0x4(%esp)
 276:	00 
 277:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 27e:	e8 59 03 00 00       	call   5dc <printf>
      exit();
 283:	e8 cd 01 00 00       	call   455 <exit>
    grep(pattern, fd);
 288:	89 44 24 04          	mov    %eax,0x4(%esp)
 28c:	8b 44 24 0c          	mov    0xc(%esp),%eax
 290:	89 04 24             	mov    %eax,(%esp)
 293:	e8 86 fe ff ff       	call   11e <grep>
    close(fd);
 298:	89 34 24             	mov    %esi,(%esp)
 29b:	e8 dd 01 00 00       	call   47d <close>
  for(i = 2; i < argc; i++){
 2a0:	83 c3 01             	add    $0x1,%ebx
 2a3:	eb 05                	jmp    2aa <main+0xaf>
 2a5:	bb 02 00 00 00       	mov    $0x2,%ebx
 2aa:	3b 5d 08             	cmp    0x8(%ebp),%ebx
 2ad:	7c 9c                	jl     24b <main+0x50>
  exit();
 2af:	e8 a1 01 00 00       	call   455 <exit>

000002b4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	53                   	push   %ebx
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2be:	89 c2                	mov    %eax,%edx
 2c0:	0f b6 19             	movzbl (%ecx),%ebx
 2c3:	88 1a                	mov    %bl,(%edx)
 2c5:	8d 52 01             	lea    0x1(%edx),%edx
 2c8:	8d 49 01             	lea    0x1(%ecx),%ecx
 2cb:	84 db                	test   %bl,%bl
 2cd:	75 f1                	jne    2c0 <strcpy+0xc>
    ;
  return os;
}
 2cf:	5b                   	pop    %ebx
 2d0:	5d                   	pop    %ebp
 2d1:	c3                   	ret    

000002d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d2:	55                   	push   %ebp
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 2db:	eb 06                	jmp    2e3 <strcmp+0x11>
    p++, q++;
 2dd:	83 c1 01             	add    $0x1,%ecx
 2e0:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 2e3:	0f b6 01             	movzbl (%ecx),%eax
 2e6:	84 c0                	test   %al,%al
 2e8:	74 04                	je     2ee <strcmp+0x1c>
 2ea:	3a 02                	cmp    (%edx),%al
 2ec:	74 ef                	je     2dd <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 2ee:	0f b6 c0             	movzbl %al,%eax
 2f1:	0f b6 12             	movzbl (%edx),%edx
 2f4:	29 d0                	sub    %edx,%eax
}
 2f6:	5d                   	pop    %ebp
 2f7:	c3                   	ret    

000002f8 <strlen>:

uint
strlen(const char *s)
{
 2f8:	55                   	push   %ebp
 2f9:	89 e5                	mov    %esp,%ebp
 2fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 2fe:	ba 00 00 00 00       	mov    $0x0,%edx
 303:	eb 03                	jmp    308 <strlen+0x10>
 305:	83 c2 01             	add    $0x1,%edx
 308:	89 d0                	mov    %edx,%eax
 30a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 30e:	75 f5                	jne    305 <strlen+0xd>
    ;
  return n;
}
 310:	5d                   	pop    %ebp
 311:	c3                   	ret    

00000312 <memset>:

void*
memset(void *dst, int c, uint n)
{
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	57                   	push   %edi
 316:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 319:	89 d7                	mov    %edx,%edi
 31b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 31e:	8b 45 0c             	mov    0xc(%ebp),%eax
 321:	fc                   	cld    
 322:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 324:	89 d0                	mov    %edx,%eax
 326:	5f                   	pop    %edi
 327:	5d                   	pop    %ebp
 328:	c3                   	ret    

00000329 <strchr>:

char*
strchr(const char *s, char c)
{
 329:	55                   	push   %ebp
 32a:	89 e5                	mov    %esp,%ebp
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 333:	eb 07                	jmp    33c <strchr+0x13>
    if(*s == c)
 335:	38 ca                	cmp    %cl,%dl
 337:	74 0f                	je     348 <strchr+0x1f>
  for(; *s; s++)
 339:	83 c0 01             	add    $0x1,%eax
 33c:	0f b6 10             	movzbl (%eax),%edx
 33f:	84 d2                	test   %dl,%dl
 341:	75 f2                	jne    335 <strchr+0xc>
      return (char*)s;
  return 0;
 343:	b8 00 00 00 00       	mov    $0x0,%eax
}
 348:	5d                   	pop    %ebp
 349:	c3                   	ret    

0000034a <gets>:

char*
gets(char *buf, int max)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	57                   	push   %edi
 34e:	56                   	push   %esi
 34f:	53                   	push   %ebx
 350:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 353:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 358:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 35b:	eb 36                	jmp    393 <gets+0x49>
    cc = read(0, &c, 1);
 35d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 364:	00 
 365:	89 7c 24 04          	mov    %edi,0x4(%esp)
 369:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 370:	e8 f8 00 00 00       	call   46d <read>
    if(cc < 1)
 375:	85 c0                	test   %eax,%eax
 377:	7e 26                	jle    39f <gets+0x55>
      break;
    buf[i++] = c;
 379:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 37d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 380:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 383:	3c 0a                	cmp    $0xa,%al
 385:	0f 94 c2             	sete   %dl
 388:	3c 0d                	cmp    $0xd,%al
 38a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 38d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 38f:	08 c2                	or     %al,%dl
 391:	75 0a                	jne    39d <gets+0x53>
  for(i=0; i+1 < max; ){
 393:	8d 73 01             	lea    0x1(%ebx),%esi
 396:	3b 75 0c             	cmp    0xc(%ebp),%esi
 399:	7c c2                	jl     35d <gets+0x13>
 39b:	eb 02                	jmp    39f <gets+0x55>
    buf[i++] = c;
 39d:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 3a6:	83 c4 2c             	add    $0x2c,%esp
 3a9:	5b                   	pop    %ebx
 3aa:	5e                   	pop    %esi
 3ab:	5f                   	pop    %edi
 3ac:	5d                   	pop    %ebp
 3ad:	c3                   	ret    

000003ae <stat>:

int
stat(const char *n, struct stat *st)
{
 3ae:	55                   	push   %ebp
 3af:	89 e5                	mov    %esp,%ebp
 3b1:	56                   	push   %esi
 3b2:	53                   	push   %ebx
 3b3:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3bd:	00 
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
 3c1:	89 04 24             	mov    %eax,(%esp)
 3c4:	e8 cc 00 00 00       	call   495 <open>
 3c9:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 3cb:	85 c0                	test   %eax,%eax
 3cd:	78 1d                	js     3ec <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 3cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d2:	89 44 24 04          	mov    %eax,0x4(%esp)
 3d6:	89 1c 24             	mov    %ebx,(%esp)
 3d9:	e8 cf 00 00 00       	call   4ad <fstat>
 3de:	89 c6                	mov    %eax,%esi
  close(fd);
 3e0:	89 1c 24             	mov    %ebx,(%esp)
 3e3:	e8 95 00 00 00       	call   47d <close>
  return r;
 3e8:	89 f0                	mov    %esi,%eax
 3ea:	eb 05                	jmp    3f1 <stat+0x43>
    return -1;
 3ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 3f1:	83 c4 10             	add    $0x10,%esp
 3f4:	5b                   	pop    %ebx
 3f5:	5e                   	pop    %esi
 3f6:	5d                   	pop    %ebp
 3f7:	c3                   	ret    

000003f8 <atoi>:

int
atoi(const char *s)
{
 3f8:	55                   	push   %ebp
 3f9:	89 e5                	mov    %esp,%ebp
 3fb:	53                   	push   %ebx
 3fc:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 3ff:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 404:	eb 0f                	jmp    415 <atoi+0x1d>
    n = n*10 + *s++ - '0';
 406:	8d 04 80             	lea    (%eax,%eax,4),%eax
 409:	01 c0                	add    %eax,%eax
 40b:	83 c2 01             	add    $0x1,%edx
 40e:	0f be c9             	movsbl %cl,%ecx
 411:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 415:	0f b6 0a             	movzbl (%edx),%ecx
 418:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 41b:	80 fb 09             	cmp    $0x9,%bl
 41e:	76 e6                	jbe    406 <atoi+0xe>
  return n;
}
 420:	5b                   	pop    %ebx
 421:	5d                   	pop    %ebp
 422:	c3                   	ret    

00000423 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 423:	55                   	push   %ebp
 424:	89 e5                	mov    %esp,%ebp
 426:	56                   	push   %esi
 427:	53                   	push   %ebx
 428:	8b 45 08             	mov    0x8(%ebp),%eax
 42b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 42e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 431:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 433:	eb 0d                	jmp    442 <memmove+0x1f>
    *dst++ = *src++;
 435:	0f b6 13             	movzbl (%ebx),%edx
 438:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 43a:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 43c:	8d 5b 01             	lea    0x1(%ebx),%ebx
 43f:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 442:	8d 72 ff             	lea    -0x1(%edx),%esi
 445:	85 d2                	test   %edx,%edx
 447:	7f ec                	jg     435 <memmove+0x12>
  return vdst;
}
 449:	5b                   	pop    %ebx
 44a:	5e                   	pop    %esi
 44b:	5d                   	pop    %ebp
 44c:	c3                   	ret    

0000044d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 44d:	b8 01 00 00 00       	mov    $0x1,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret    

00000455 <exit>:
SYSCALL(exit)
 455:	b8 02 00 00 00       	mov    $0x2,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret    

0000045d <wait>:
SYSCALL(wait)
 45d:	b8 03 00 00 00       	mov    $0x3,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret    

00000465 <pipe>:
SYSCALL(pipe)
 465:	b8 04 00 00 00       	mov    $0x4,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret    

0000046d <read>:
SYSCALL(read)
 46d:	b8 05 00 00 00       	mov    $0x5,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret    

00000475 <write>:
SYSCALL(write)
 475:	b8 10 00 00 00       	mov    $0x10,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret    

0000047d <close>:
SYSCALL(close)
 47d:	b8 15 00 00 00       	mov    $0x15,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret    

00000485 <kill>:
SYSCALL(kill)
 485:	b8 06 00 00 00       	mov    $0x6,%eax
 48a:	cd 40                	int    $0x40
 48c:	c3                   	ret    

0000048d <exec>:
SYSCALL(exec)
 48d:	b8 07 00 00 00       	mov    $0x7,%eax
 492:	cd 40                	int    $0x40
 494:	c3                   	ret    

00000495 <open>:
SYSCALL(open)
 495:	b8 0f 00 00 00       	mov    $0xf,%eax
 49a:	cd 40                	int    $0x40
 49c:	c3                   	ret    

0000049d <mknod>:
SYSCALL(mknod)
 49d:	b8 11 00 00 00       	mov    $0x11,%eax
 4a2:	cd 40                	int    $0x40
 4a4:	c3                   	ret    

000004a5 <unlink>:
SYSCALL(unlink)
 4a5:	b8 12 00 00 00       	mov    $0x12,%eax
 4aa:	cd 40                	int    $0x40
 4ac:	c3                   	ret    

000004ad <fstat>:
SYSCALL(fstat)
 4ad:	b8 08 00 00 00       	mov    $0x8,%eax
 4b2:	cd 40                	int    $0x40
 4b4:	c3                   	ret    

000004b5 <link>:
SYSCALL(link)
 4b5:	b8 13 00 00 00       	mov    $0x13,%eax
 4ba:	cd 40                	int    $0x40
 4bc:	c3                   	ret    

000004bd <mkdir>:
SYSCALL(mkdir)
 4bd:	b8 14 00 00 00       	mov    $0x14,%eax
 4c2:	cd 40                	int    $0x40
 4c4:	c3                   	ret    

000004c5 <chdir>:
SYSCALL(chdir)
 4c5:	b8 09 00 00 00       	mov    $0x9,%eax
 4ca:	cd 40                	int    $0x40
 4cc:	c3                   	ret    

000004cd <dup>:
SYSCALL(dup)
 4cd:	b8 0a 00 00 00       	mov    $0xa,%eax
 4d2:	cd 40                	int    $0x40
 4d4:	c3                   	ret    

000004d5 <getpid>:
SYSCALL(getpid)
 4d5:	b8 0b 00 00 00       	mov    $0xb,%eax
 4da:	cd 40                	int    $0x40
 4dc:	c3                   	ret    

000004dd <sbrk>:
SYSCALL(sbrk)
 4dd:	b8 0c 00 00 00       	mov    $0xc,%eax
 4e2:	cd 40                	int    $0x40
 4e4:	c3                   	ret    

000004e5 <sleep>:
SYSCALL(sleep)
 4e5:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ea:	cd 40                	int    $0x40
 4ec:	c3                   	ret    

000004ed <uptime>:
SYSCALL(uptime)
 4ed:	b8 0e 00 00 00       	mov    $0xe,%eax
 4f2:	cd 40                	int    $0x40
 4f4:	c3                   	ret    

000004f5 <yield>:
SYSCALL(yield)
 4f5:	b8 16 00 00 00       	mov    $0x16,%eax
 4fa:	cd 40                	int    $0x40
 4fc:	c3                   	ret    

000004fd <shutdown>:
SYSCALL(shutdown)
 4fd:	b8 17 00 00 00       	mov    $0x17,%eax
 502:	cd 40                	int    $0x40
 504:	c3                   	ret    

00000505 <writecount>:
SYSCALL(writecount)
 505:	b8 18 00 00 00       	mov    $0x18,%eax
 50a:	cd 40                	int    $0x40
 50c:	c3                   	ret    

0000050d <setwritecount>:
SYSCALL(setwritecount)
 50d:	b8 19 00 00 00       	mov    $0x19,%eax
 512:	cd 40                	int    $0x40
 514:	c3                   	ret    

00000515 <settickets>:
SYSCALL(settickets)
 515:	b8 1a 00 00 00       	mov    $0x1a,%eax
 51a:	cd 40                	int    $0x40
 51c:	c3                   	ret    

0000051d <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 51d:	b8 1b 00 00 00       	mov    $0x1b,%eax
 522:	cd 40                	int    $0x40
 524:	c3                   	ret    

00000525 <getpagetableentry>:
SYSCALL(getpagetableentry)
 525:	b8 1c 00 00 00       	mov    $0x1c,%eax
 52a:	cd 40                	int    $0x40
 52c:	c3                   	ret    

0000052d <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 52d:	b8 1d 00 00 00       	mov    $0x1d,%eax
 532:	cd 40                	int    $0x40
 534:	c3                   	ret    

00000535 <dumppagetable>:
 535:	b8 1e 00 00 00       	mov    $0x1e,%eax
 53a:	cd 40                	int    $0x40
 53c:	c3                   	ret    
 53d:	66 90                	xchg   %ax,%ax
 53f:	90                   	nop

00000540 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 540:	55                   	push   %ebp
 541:	89 e5                	mov    %esp,%ebp
 543:	83 ec 18             	sub    $0x18,%esp
 546:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 549:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 550:	00 
 551:	8d 55 f4             	lea    -0xc(%ebp),%edx
 554:	89 54 24 04          	mov    %edx,0x4(%esp)
 558:	89 04 24             	mov    %eax,(%esp)
 55b:	e8 15 ff ff ff       	call   475 <write>
}
 560:	c9                   	leave  
 561:	c3                   	ret    

00000562 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 562:	55                   	push   %ebp
 563:	89 e5                	mov    %esp,%ebp
 565:	57                   	push   %edi
 566:	56                   	push   %esi
 567:	53                   	push   %ebx
 568:	83 ec 2c             	sub    $0x2c,%esp
 56b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 56d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 571:	0f 95 c3             	setne  %bl
 574:	89 d0                	mov    %edx,%eax
 576:	c1 e8 1f             	shr    $0x1f,%eax
 579:	84 c3                	test   %al,%bl
 57b:	74 0b                	je     588 <printint+0x26>
    neg = 1;
    x = -xx;
 57d:	f7 da                	neg    %edx
    neg = 1;
 57f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 586:	eb 07                	jmp    58f <printint+0x2d>
  neg = 0;
 588:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 58f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 594:	8d 5e 01             	lea    0x1(%esi),%ebx
 597:	89 d0                	mov    %edx,%eax
 599:	ba 00 00 00 00       	mov    $0x0,%edx
 59e:	f7 f1                	div    %ecx
 5a0:	0f b6 92 75 07 00 00 	movzbl 0x775(%edx),%edx
 5a7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 5ab:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 5ad:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 5af:	85 c0                	test   %eax,%eax
 5b1:	75 e1                	jne    594 <printint+0x32>
  if(neg)
 5b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 5b7:	74 16                	je     5cf <printint+0x6d>
    buf[i++] = '-';
 5b9:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 5be:	8d 5b 01             	lea    0x1(%ebx),%ebx
 5c1:	eb 0c                	jmp    5cf <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 5c3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 5c8:	89 f8                	mov    %edi,%eax
 5ca:	e8 71 ff ff ff       	call   540 <putc>
  while(--i >= 0)
 5cf:	83 eb 01             	sub    $0x1,%ebx
 5d2:	79 ef                	jns    5c3 <printint+0x61>
}
 5d4:	83 c4 2c             	add    $0x2c,%esp
 5d7:	5b                   	pop    %ebx
 5d8:	5e                   	pop    %esi
 5d9:	5f                   	pop    %edi
 5da:	5d                   	pop    %ebp
 5db:	c3                   	ret    

000005dc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	57                   	push   %edi
 5e0:	56                   	push   %esi
 5e1:	53                   	push   %ebx
 5e2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 5e5:	8d 45 10             	lea    0x10(%ebp),%eax
 5e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 5eb:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 5f0:	be 00 00 00 00       	mov    $0x0,%esi
 5f5:	e9 23 01 00 00       	jmp    71d <printf+0x141>
    c = fmt[i] & 0xff;
 5fa:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 5fd:	85 ff                	test   %edi,%edi
 5ff:	75 19                	jne    61a <printf+0x3e>
      if(c == '%'){
 601:	83 f8 25             	cmp    $0x25,%eax
 604:	0f 84 0b 01 00 00    	je     715 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 60a:	0f be d3             	movsbl %bl,%edx
 60d:	8b 45 08             	mov    0x8(%ebp),%eax
 610:	e8 2b ff ff ff       	call   540 <putc>
 615:	e9 00 01 00 00       	jmp    71a <printf+0x13e>
      }
    } else if(state == '%'){
 61a:	83 ff 25             	cmp    $0x25,%edi
 61d:	0f 85 f7 00 00 00    	jne    71a <printf+0x13e>
      if(c == 'd'){
 623:	83 f8 64             	cmp    $0x64,%eax
 626:	75 26                	jne    64e <printf+0x72>
        printint(fd, *ap, 10, 1);
 628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62b:	8b 10                	mov    (%eax),%edx
 62d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 634:	b9 0a 00 00 00       	mov    $0xa,%ecx
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	e8 21 ff ff ff       	call   562 <printint>
        ap++;
 641:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 645:	66 bf 00 00          	mov    $0x0,%di
 649:	e9 cc 00 00 00       	jmp    71a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 64e:	83 f8 78             	cmp    $0x78,%eax
 651:	0f 94 c1             	sete   %cl
 654:	83 f8 70             	cmp    $0x70,%eax
 657:	0f 94 c2             	sete   %dl
 65a:	08 d1                	or     %dl,%cl
 65c:	74 27                	je     685 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 65e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 661:	8b 10                	mov    (%eax),%edx
 663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 66a:	b9 10 00 00 00       	mov    $0x10,%ecx
 66f:	8b 45 08             	mov    0x8(%ebp),%eax
 672:	e8 eb fe ff ff       	call   562 <printint>
        ap++;
 677:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 67b:	bf 00 00 00 00       	mov    $0x0,%edi
 680:	e9 95 00 00 00       	jmp    71a <printf+0x13e>
      } else if(c == 's'){
 685:	83 f8 73             	cmp    $0x73,%eax
 688:	75 37                	jne    6c1 <printf+0xe5>
        s = (char*)*ap;
 68a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68d:	8b 18                	mov    (%eax),%ebx
        ap++;
 68f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 693:	85 db                	test   %ebx,%ebx
 695:	75 19                	jne    6b0 <printf+0xd4>
          s = "(null)";
 697:	bb 6e 07 00 00       	mov    $0x76e,%ebx
 69c:	8b 7d 08             	mov    0x8(%ebp),%edi
 69f:	eb 12                	jmp    6b3 <printf+0xd7>
          putc(fd, *s);
 6a1:	0f be d2             	movsbl %dl,%edx
 6a4:	89 f8                	mov    %edi,%eax
 6a6:	e8 95 fe ff ff       	call   540 <putc>
          s++;
 6ab:	83 c3 01             	add    $0x1,%ebx
 6ae:	eb 03                	jmp    6b3 <printf+0xd7>
 6b0:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 6b3:	0f b6 13             	movzbl (%ebx),%edx
 6b6:	84 d2                	test   %dl,%dl
 6b8:	75 e7                	jne    6a1 <printf+0xc5>
      state = 0;
 6ba:	bf 00 00 00 00       	mov    $0x0,%edi
 6bf:	eb 59                	jmp    71a <printf+0x13e>
      } else if(c == 'c'){
 6c1:	83 f8 63             	cmp    $0x63,%eax
 6c4:	75 19                	jne    6df <printf+0x103>
        putc(fd, *ap);
 6c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c9:	0f be 10             	movsbl (%eax),%edx
 6cc:	8b 45 08             	mov    0x8(%ebp),%eax
 6cf:	e8 6c fe ff ff       	call   540 <putc>
        ap++;
 6d4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 6d8:	bf 00 00 00 00       	mov    $0x0,%edi
 6dd:	eb 3b                	jmp    71a <printf+0x13e>
      } else if(c == '%'){
 6df:	83 f8 25             	cmp    $0x25,%eax
 6e2:	75 12                	jne    6f6 <printf+0x11a>
        putc(fd, c);
 6e4:	0f be d3             	movsbl %bl,%edx
 6e7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ea:	e8 51 fe ff ff       	call   540 <putc>
      state = 0;
 6ef:	bf 00 00 00 00       	mov    $0x0,%edi
 6f4:	eb 24                	jmp    71a <printf+0x13e>
        putc(fd, '%');
 6f6:	ba 25 00 00 00       	mov    $0x25,%edx
 6fb:	8b 45 08             	mov    0x8(%ebp),%eax
 6fe:	e8 3d fe ff ff       	call   540 <putc>
        putc(fd, c);
 703:	0f be d3             	movsbl %bl,%edx
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	e8 32 fe ff ff       	call   540 <putc>
      state = 0;
 70e:	bf 00 00 00 00       	mov    $0x0,%edi
 713:	eb 05                	jmp    71a <printf+0x13e>
        state = '%';
 715:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 71a:	83 c6 01             	add    $0x1,%esi
 71d:	89 f0                	mov    %esi,%eax
 71f:	03 45 0c             	add    0xc(%ebp),%eax
 722:	0f b6 18             	movzbl (%eax),%ebx
 725:	84 db                	test   %bl,%bl
 727:	0f 85 cd fe ff ff    	jne    5fa <printf+0x1e>
    }
  }
}
 72d:	83 c4 1c             	add    $0x1c,%esp
 730:	5b                   	pop    %ebx
 731:	5e                   	pop    %esi
 732:	5f                   	pop    %edi
 733:	5d                   	pop    %ebp
 734:	c3                   	ret    
