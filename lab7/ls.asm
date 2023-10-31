
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	83 ec 10             	sub    $0x10,%esp
   8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   b:	89 1c 24             	mov    %ebx,(%esp)
   e:	e8 5b 03 00 00       	call   36e <strlen>
  13:	01 d8                	add    %ebx,%eax
  15:	eb 03                	jmp    1a <fmtname+0x1a>
  17:	83 e8 01             	sub    $0x1,%eax
  1a:	39 d8                	cmp    %ebx,%eax
  1c:	72 05                	jb     23 <fmtname+0x23>
  1e:	80 38 2f             	cmpb   $0x2f,(%eax)
  21:	75 f4                	jne    17 <fmtname+0x17>
    ;
  p++;
  23:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  26:	89 1c 24             	mov    %ebx,(%esp)
  29:	e8 40 03 00 00       	call   36e <strlen>
  2e:	83 f8 0d             	cmp    $0xd,%eax
  31:	77 55                	ja     88 <fmtname+0x88>
    return p;
  memmove(buf, p, strlen(p));
  33:	89 1c 24             	mov    %ebx,(%esp)
  36:	e8 33 03 00 00       	call   36e <strlen>
  3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  43:	c7 04 24 17 08 00 00 	movl   $0x817,(%esp)
  4a:	e8 4a 04 00 00       	call   499 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  4f:	89 1c 24             	mov    %ebx,(%esp)
  52:	e8 17 03 00 00       	call   36e <strlen>
  57:	89 c6                	mov    %eax,%esi
  59:	89 1c 24             	mov    %ebx,(%esp)
  5c:	e8 0d 03 00 00       	call   36e <strlen>
  61:	ba 0e 00 00 00       	mov    $0xe,%edx
  66:	29 f2                	sub    %esi,%edx
  68:	89 54 24 08          	mov    %edx,0x8(%esp)
  6c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  73:	00 
  74:	05 17 08 00 00       	add    $0x817,%eax
  79:	89 04 24             	mov    %eax,(%esp)
  7c:	e8 07 03 00 00       	call   388 <memset>
  return buf;
  81:	b8 17 08 00 00       	mov    $0x817,%eax
  86:	eb 02                	jmp    8a <fmtname+0x8a>
    return p;
  88:	89 d8                	mov    %ebx,%eax
}
  8a:	83 c4 10             	add    $0x10,%esp
  8d:	5b                   	pop    %ebx
  8e:	5e                   	pop    %esi
  8f:	5d                   	pop    %ebp
  90:	c3                   	ret    

00000091 <ls>:

void
ls(char *path)
{
  91:	55                   	push   %ebp
  92:	89 e5                	mov    %esp,%ebp
  94:	57                   	push   %edi
  95:	56                   	push   %esi
  96:	53                   	push   %ebx
  97:	81 ec 6c 02 00 00    	sub    $0x26c,%esp
  9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  a7:	00 
  a8:	89 1c 24             	mov    %ebx,(%esp)
  ab:	e8 5b 04 00 00       	call   50b <open>
  b0:	89 c7                	mov    %eax,%edi
  b2:	85 c0                	test   %eax,%eax
  b4:	79 1d                	jns    d3 <ls+0x42>
    printf(2, "ls: cannot open %s\n", path);
  b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  ba:	c7 44 24 04 b5 07 00 	movl   $0x7b5,0x4(%esp)
  c1:	00 
  c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  c9:	e8 8e 05 00 00       	call   65c <printf>
    return;
  ce:	e9 06 02 00 00       	jmp    2d9 <ls+0x248>
  }

  if(fstat(fd, &st) < 0){
  d3:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  dd:	89 3c 24             	mov    %edi,(%esp)
  e0:	e8 3e 04 00 00       	call   523 <fstat>
  e5:	85 c0                	test   %eax,%eax
  e7:	79 25                	jns    10e <ls+0x7d>
    printf(2, "ls: cannot stat %s\n", path);
  e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  ed:	c7 44 24 04 c9 07 00 	movl   $0x7c9,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  fc:	e8 5b 05 00 00       	call   65c <printf>
    close(fd);
 101:	89 3c 24             	mov    %edi,(%esp)
 104:	e8 ea 03 00 00       	call   4f3 <close>
    return;
 109:	e9 cb 01 00 00       	jmp    2d9 <ls+0x248>
  }

  switch(st.type){
 10e:	0f b7 b5 c4 fd ff ff 	movzwl -0x23c(%ebp),%esi
 115:	66 83 fe 01          	cmp    $0x1,%si
 119:	74 62                	je     17d <ls+0xec>
 11b:	66 83 fe 02          	cmp    $0x2,%si
 11f:	0f 85 ac 01 00 00    	jne    2d1 <ls+0x240>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 125:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
 12b:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 131:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
 137:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
 13d:	89 1c 24             	mov    %ebx,(%esp)
 140:	e8 bb fe ff ff       	call   0 <fmtname>
 145:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 14b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 14f:	8b 95 b0 fd ff ff    	mov    -0x250(%ebp),%edx
 155:	89 54 24 10          	mov    %edx,0x10(%esp)
 159:	0f bf f6             	movswl %si,%esi
 15c:	89 74 24 0c          	mov    %esi,0xc(%esp)
 160:	89 44 24 08          	mov    %eax,0x8(%esp)
 164:	c7 44 24 04 dd 07 00 	movl   $0x7dd,0x4(%esp)
 16b:	00 
 16c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 173:	e8 e4 04 00 00       	call   65c <printf>
    break;
 178:	e9 54 01 00 00       	jmp    2d1 <ls+0x240>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 17d:	89 1c 24             	mov    %ebx,(%esp)
 180:	e8 e9 01 00 00       	call   36e <strlen>
 185:	83 c0 10             	add    $0x10,%eax
 188:	3d 00 02 00 00       	cmp    $0x200,%eax
 18d:	76 19                	jbe    1a8 <ls+0x117>
      printf(1, "ls: path too long\n");
 18f:	c7 44 24 04 ea 07 00 	movl   $0x7ea,0x4(%esp)
 196:	00 
 197:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19e:	e8 b9 04 00 00       	call   65c <printf>
      break;
 1a3:	e9 29 01 00 00       	jmp    2d1 <ls+0x240>
    }
    strcpy(buf, path);
 1a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
 1ac:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
 1b2:	89 1c 24             	mov    %ebx,(%esp)
 1b5:	e8 70 01 00 00       	call   32a <strcpy>
    p = buf+strlen(buf);
 1ba:	89 1c 24             	mov    %ebx,(%esp)
 1bd:	e8 ac 01 00 00       	call   36e <strlen>
 1c2:	01 d8                	add    %ebx,%eax
 1c4:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
    *p++ = '/';
 1ca:	8d 48 01             	lea    0x1(%eax),%ecx
 1cd:	89 8d a8 fd ff ff    	mov    %ecx,-0x258(%ebp)
 1d3:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1d6:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
 1dc:	e9 d3 00 00 00       	jmp    2b4 <ls+0x223>
      if(de.inum == 0)
 1e1:	66 83 bd d8 fd ff ff 	cmpw   $0x0,-0x228(%ebp)
 1e8:	00 
 1e9:	0f 84 c5 00 00 00    	je     2b4 <ls+0x223>
        continue;
      memmove(p, de.name, DIRSIZ);
 1ef:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 1f6:	00 
 1f7:	8d 85 da fd ff ff    	lea    -0x226(%ebp),%eax
 1fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 201:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
 207:	89 04 24             	mov    %eax,(%esp)
 20a:	e8 8a 02 00 00       	call   499 <memmove>
      p[DIRSIZ] = 0;
 20f:	8b 85 ac fd ff ff    	mov    -0x254(%ebp),%eax
 215:	c6 40 0f 00          	movb   $0x0,0xf(%eax)
      if(stat(buf, &st) < 0){
 219:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 21f:	89 44 24 04          	mov    %eax,0x4(%esp)
 223:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 229:	89 04 24             	mov    %eax,(%esp)
 22c:	e8 f3 01 00 00       	call   424 <stat>
 231:	85 c0                	test   %eax,%eax
 233:	79 20                	jns    255 <ls+0x1c4>
        printf(1, "ls: cannot stat %s\n", buf);
 235:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 23b:	89 44 24 08          	mov    %eax,0x8(%esp)
 23f:	c7 44 24 04 c9 07 00 	movl   $0x7c9,0x4(%esp)
 246:	00 
 247:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 24e:	e8 09 04 00 00       	call   65c <printf>
        continue;
 253:	eb 5f                	jmp    2b4 <ls+0x223>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 255:	8b 9d d4 fd ff ff    	mov    -0x22c(%ebp),%ebx
 25b:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
 261:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 267:	0f b7 95 c4 fd ff ff 	movzwl -0x23c(%ebp),%edx
 26e:	66 89 95 b0 fd ff ff 	mov    %dx,-0x250(%ebp)
 275:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 27b:	89 04 24             	mov    %eax,(%esp)
 27e:	e8 7d fd ff ff       	call   0 <fmtname>
 283:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 287:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 28d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 291:	0f bf 95 b0 fd ff ff 	movswl -0x250(%ebp),%edx
 298:	89 54 24 0c          	mov    %edx,0xc(%esp)
 29c:	89 44 24 08          	mov    %eax,0x8(%esp)
 2a0:	c7 44 24 04 dd 07 00 	movl   $0x7dd,0x4(%esp)
 2a7:	00 
 2a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2af:	e8 a8 03 00 00       	call   65c <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2b4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2bb:	00 
 2bc:	89 74 24 04          	mov    %esi,0x4(%esp)
 2c0:	89 3c 24             	mov    %edi,(%esp)
 2c3:	e8 1b 02 00 00       	call   4e3 <read>
 2c8:	83 f8 10             	cmp    $0x10,%eax
 2cb:	0f 84 10 ff ff ff    	je     1e1 <ls+0x150>
    }
    break;
  }
  close(fd);
 2d1:	89 3c 24             	mov    %edi,(%esp)
 2d4:	e8 1a 02 00 00       	call   4f3 <close>
}
 2d9:	81 c4 6c 02 00 00    	add    $0x26c,%esp
 2df:	5b                   	pop    %ebx
 2e0:	5e                   	pop    %esi
 2e1:	5f                   	pop    %edi
 2e2:	5d                   	pop    %ebp
 2e3:	c3                   	ret    

000002e4 <main>:

int
main(int argc, char *argv[])
{
 2e4:	55                   	push   %ebp
 2e5:	89 e5                	mov    %esp,%ebp
 2e7:	57                   	push   %edi
 2e8:	56                   	push   %esi
 2e9:	53                   	push   %ebx
 2ea:	83 e4 f0             	and    $0xfffffff0,%esp
 2ed:	83 ec 10             	sub    $0x10,%esp
 2f0:	8b 75 08             	mov    0x8(%ebp),%esi
 2f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
 2f6:	83 fe 01             	cmp    $0x1,%esi
 2f9:	7f 21                	jg     31c <main+0x38>
    ls(".");
 2fb:	c7 04 24 fd 07 00 00 	movl   $0x7fd,(%esp)
 302:	e8 8a fd ff ff       	call   91 <ls>
    exit();
 307:	e8 bf 01 00 00       	call   4cb <exit>
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 30c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
 30f:	89 04 24             	mov    %eax,(%esp)
 312:	e8 7a fd ff ff       	call   91 <ls>
  for(i=1; i<argc; i++)
 317:	83 c3 01             	add    $0x1,%ebx
 31a:	eb 05                	jmp    321 <main+0x3d>
 31c:	bb 01 00 00 00       	mov    $0x1,%ebx
 321:	39 f3                	cmp    %esi,%ebx
 323:	7c e7                	jl     30c <main+0x28>
  exit();
 325:	e8 a1 01 00 00       	call   4cb <exit>

0000032a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 32a:	55                   	push   %ebp
 32b:	89 e5                	mov    %esp,%ebp
 32d:	53                   	push   %ebx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 334:	89 c2                	mov    %eax,%edx
 336:	0f b6 19             	movzbl (%ecx),%ebx
 339:	88 1a                	mov    %bl,(%edx)
 33b:	8d 52 01             	lea    0x1(%edx),%edx
 33e:	8d 49 01             	lea    0x1(%ecx),%ecx
 341:	84 db                	test   %bl,%bl
 343:	75 f1                	jne    336 <strcpy+0xc>
    ;
  return os;
}
 345:	5b                   	pop    %ebx
 346:	5d                   	pop    %ebp
 347:	c3                   	ret    

00000348 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 34e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 351:	eb 06                	jmp    359 <strcmp+0x11>
    p++, q++;
 353:	83 c1 01             	add    $0x1,%ecx
 356:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 359:	0f b6 01             	movzbl (%ecx),%eax
 35c:	84 c0                	test   %al,%al
 35e:	74 04                	je     364 <strcmp+0x1c>
 360:	3a 02                	cmp    (%edx),%al
 362:	74 ef                	je     353 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 364:	0f b6 c0             	movzbl %al,%eax
 367:	0f b6 12             	movzbl (%edx),%edx
 36a:	29 d0                	sub    %edx,%eax
}
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    

0000036e <strlen>:

uint
strlen(const char *s)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
 371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 374:	ba 00 00 00 00       	mov    $0x0,%edx
 379:	eb 03                	jmp    37e <strlen+0x10>
 37b:	83 c2 01             	add    $0x1,%edx
 37e:	89 d0                	mov    %edx,%eax
 380:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 384:	75 f5                	jne    37b <strlen+0xd>
    ;
  return n;
}
 386:	5d                   	pop    %ebp
 387:	c3                   	ret    

00000388 <memset>:

void*
memset(void *dst, int c, uint n)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	57                   	push   %edi
 38c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 38f:	89 d7                	mov    %edx,%edi
 391:	8b 4d 10             	mov    0x10(%ebp),%ecx
 394:	8b 45 0c             	mov    0xc(%ebp),%eax
 397:	fc                   	cld    
 398:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 39a:	89 d0                	mov    %edx,%eax
 39c:	5f                   	pop    %edi
 39d:	5d                   	pop    %ebp
 39e:	c3                   	ret    

0000039f <strchr>:

char*
strchr(const char *s, char c)
{
 39f:	55                   	push   %ebp
 3a0:	89 e5                	mov    %esp,%ebp
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 3a9:	eb 07                	jmp    3b2 <strchr+0x13>
    if(*s == c)
 3ab:	38 ca                	cmp    %cl,%dl
 3ad:	74 0f                	je     3be <strchr+0x1f>
  for(; *s; s++)
 3af:	83 c0 01             	add    $0x1,%eax
 3b2:	0f b6 10             	movzbl (%eax),%edx
 3b5:	84 d2                	test   %dl,%dl
 3b7:	75 f2                	jne    3ab <strchr+0xc>
      return (char*)s;
  return 0;
 3b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3be:	5d                   	pop    %ebp
 3bf:	c3                   	ret    

000003c0 <gets>:

char*
gets(char *buf, int max)
{
 3c0:	55                   	push   %ebp
 3c1:	89 e5                	mov    %esp,%ebp
 3c3:	57                   	push   %edi
 3c4:	56                   	push   %esi
 3c5:	53                   	push   %ebx
 3c6:	83 ec 2c             	sub    $0x2c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c9:	bb 00 00 00 00       	mov    $0x0,%ebx
    cc = read(0, &c, 1);
 3ce:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 3d1:	eb 36                	jmp    409 <gets+0x49>
    cc = read(0, &c, 1);
 3d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3da:	00 
 3db:	89 7c 24 04          	mov    %edi,0x4(%esp)
 3df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3e6:	e8 f8 00 00 00       	call   4e3 <read>
    if(cc < 1)
 3eb:	85 c0                	test   %eax,%eax
 3ed:	7e 26                	jle    415 <gets+0x55>
      break;
    buf[i++] = c;
 3ef:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3f6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
    if(c == '\n' || c == '\r')
 3f9:	3c 0a                	cmp    $0xa,%al
 3fb:	0f 94 c2             	sete   %dl
 3fe:	3c 0d                	cmp    $0xd,%al
 400:	0f 94 c0             	sete   %al
    buf[i++] = c;
 403:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 405:	08 c2                	or     %al,%dl
 407:	75 0a                	jne    413 <gets+0x53>
  for(i=0; i+1 < max; ){
 409:	8d 73 01             	lea    0x1(%ebx),%esi
 40c:	3b 75 0c             	cmp    0xc(%ebp),%esi
 40f:	7c c2                	jl     3d3 <gets+0x13>
 411:	eb 02                	jmp    415 <gets+0x55>
    buf[i++] = c;
 413:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
  return buf;
}
 41c:	83 c4 2c             	add    $0x2c,%esp
 41f:	5b                   	pop    %ebx
 420:	5e                   	pop    %esi
 421:	5f                   	pop    %edi
 422:	5d                   	pop    %ebp
 423:	c3                   	ret    

00000424 <stat>:

int
stat(const char *n, struct stat *st)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	56                   	push   %esi
 428:	53                   	push   %ebx
 429:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 433:	00 
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	89 04 24             	mov    %eax,(%esp)
 43a:	e8 cc 00 00 00       	call   50b <open>
 43f:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 441:	85 c0                	test   %eax,%eax
 443:	78 1d                	js     462 <stat+0x3e>
    return -1;
  r = fstat(fd, st);
 445:	8b 45 0c             	mov    0xc(%ebp),%eax
 448:	89 44 24 04          	mov    %eax,0x4(%esp)
 44c:	89 1c 24             	mov    %ebx,(%esp)
 44f:	e8 cf 00 00 00       	call   523 <fstat>
 454:	89 c6                	mov    %eax,%esi
  close(fd);
 456:	89 1c 24             	mov    %ebx,(%esp)
 459:	e8 95 00 00 00       	call   4f3 <close>
  return r;
 45e:	89 f0                	mov    %esi,%eax
 460:	eb 05                	jmp    467 <stat+0x43>
    return -1;
 462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
 467:	83 c4 10             	add    $0x10,%esp
 46a:	5b                   	pop    %ebx
 46b:	5e                   	pop    %esi
 46c:	5d                   	pop    %ebp
 46d:	c3                   	ret    

0000046e <atoi>:

int
atoi(const char *s)
{
 46e:	55                   	push   %ebp
 46f:	89 e5                	mov    %esp,%ebp
 471:	53                   	push   %ebx
 472:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
 475:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 47a:	eb 0f                	jmp    48b <atoi+0x1d>
    n = n*10 + *s++ - '0';
 47c:	8d 04 80             	lea    (%eax,%eax,4),%eax
 47f:	01 c0                	add    %eax,%eax
 481:	83 c2 01             	add    $0x1,%edx
 484:	0f be c9             	movsbl %cl,%ecx
 487:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
  while('0' <= *s && *s <= '9')
 48b:	0f b6 0a             	movzbl (%edx),%ecx
 48e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
 491:	80 fb 09             	cmp    $0x9,%bl
 494:	76 e6                	jbe    47c <atoi+0xe>
  return n;
}
 496:	5b                   	pop    %ebx
 497:	5d                   	pop    %ebp
 498:	c3                   	ret    

00000499 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 499:	55                   	push   %ebp
 49a:	89 e5                	mov    %esp,%ebp
 49c:	56                   	push   %esi
 49d:	53                   	push   %ebx
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 4a4:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 4a7:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 4a9:	eb 0d                	jmp    4b8 <memmove+0x1f>
    *dst++ = *src++;
 4ab:	0f b6 13             	movzbl (%ebx),%edx
 4ae:	88 11                	mov    %dl,(%ecx)
  while(n-- > 0)
 4b0:	89 f2                	mov    %esi,%edx
    *dst++ = *src++;
 4b2:	8d 5b 01             	lea    0x1(%ebx),%ebx
 4b5:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 4b8:	8d 72 ff             	lea    -0x1(%edx),%esi
 4bb:	85 d2                	test   %edx,%edx
 4bd:	7f ec                	jg     4ab <memmove+0x12>
  return vdst;
}
 4bf:	5b                   	pop    %ebx
 4c0:	5e                   	pop    %esi
 4c1:	5d                   	pop    %ebp
 4c2:	c3                   	ret    

000004c3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4c3:	b8 01 00 00 00       	mov    $0x1,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <exit>:
SYSCALL(exit)
 4cb:	b8 02 00 00 00       	mov    $0x2,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret    

000004d3 <wait>:
SYSCALL(wait)
 4d3:	b8 03 00 00 00       	mov    $0x3,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret    

000004db <pipe>:
SYSCALL(pipe)
 4db:	b8 04 00 00 00       	mov    $0x4,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret    

000004e3 <read>:
SYSCALL(read)
 4e3:	b8 05 00 00 00       	mov    $0x5,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret    

000004eb <write>:
SYSCALL(write)
 4eb:	b8 10 00 00 00       	mov    $0x10,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret    

000004f3 <close>:
SYSCALL(close)
 4f3:	b8 15 00 00 00       	mov    $0x15,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret    

000004fb <kill>:
SYSCALL(kill)
 4fb:	b8 06 00 00 00       	mov    $0x6,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret    

00000503 <exec>:
SYSCALL(exec)
 503:	b8 07 00 00 00       	mov    $0x7,%eax
 508:	cd 40                	int    $0x40
 50a:	c3                   	ret    

0000050b <open>:
SYSCALL(open)
 50b:	b8 0f 00 00 00       	mov    $0xf,%eax
 510:	cd 40                	int    $0x40
 512:	c3                   	ret    

00000513 <mknod>:
SYSCALL(mknod)
 513:	b8 11 00 00 00       	mov    $0x11,%eax
 518:	cd 40                	int    $0x40
 51a:	c3                   	ret    

0000051b <unlink>:
SYSCALL(unlink)
 51b:	b8 12 00 00 00       	mov    $0x12,%eax
 520:	cd 40                	int    $0x40
 522:	c3                   	ret    

00000523 <fstat>:
SYSCALL(fstat)
 523:	b8 08 00 00 00       	mov    $0x8,%eax
 528:	cd 40                	int    $0x40
 52a:	c3                   	ret    

0000052b <link>:
SYSCALL(link)
 52b:	b8 13 00 00 00       	mov    $0x13,%eax
 530:	cd 40                	int    $0x40
 532:	c3                   	ret    

00000533 <mkdir>:
SYSCALL(mkdir)
 533:	b8 14 00 00 00       	mov    $0x14,%eax
 538:	cd 40                	int    $0x40
 53a:	c3                   	ret    

0000053b <chdir>:
SYSCALL(chdir)
 53b:	b8 09 00 00 00       	mov    $0x9,%eax
 540:	cd 40                	int    $0x40
 542:	c3                   	ret    

00000543 <dup>:
SYSCALL(dup)
 543:	b8 0a 00 00 00       	mov    $0xa,%eax
 548:	cd 40                	int    $0x40
 54a:	c3                   	ret    

0000054b <getpid>:
SYSCALL(getpid)
 54b:	b8 0b 00 00 00       	mov    $0xb,%eax
 550:	cd 40                	int    $0x40
 552:	c3                   	ret    

00000553 <sbrk>:
SYSCALL(sbrk)
 553:	b8 0c 00 00 00       	mov    $0xc,%eax
 558:	cd 40                	int    $0x40
 55a:	c3                   	ret    

0000055b <sleep>:
SYSCALL(sleep)
 55b:	b8 0d 00 00 00       	mov    $0xd,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret    

00000563 <uptime>:
SYSCALL(uptime)
 563:	b8 0e 00 00 00       	mov    $0xe,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret    

0000056b <yield>:
SYSCALL(yield)
 56b:	b8 16 00 00 00       	mov    $0x16,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret    

00000573 <shutdown>:
SYSCALL(shutdown)
 573:	b8 17 00 00 00       	mov    $0x17,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret    

0000057b <writecount>:
SYSCALL(writecount)
 57b:	b8 18 00 00 00       	mov    $0x18,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret    

00000583 <setwritecount>:
SYSCALL(setwritecount)
 583:	b8 19 00 00 00       	mov    $0x19,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret    

0000058b <settickets>:
SYSCALL(settickets)
 58b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret    

00000593 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 593:	b8 1b 00 00 00       	mov    $0x1b,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret    

0000059b <getpagetableentry>:
SYSCALL(getpagetableentry)
 59b:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret    

000005a3 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 5a3:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret    

000005ab <dumppagetable>:
 5ab:	b8 1e 00 00 00       	mov    $0x1e,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret    
 5b3:	66 90                	xchg   %ax,%ax
 5b5:	66 90                	xchg   %ax,%ax
 5b7:	66 90                	xchg   %ax,%ax
 5b9:	66 90                	xchg   %ax,%ax
 5bb:	66 90                	xchg   %ax,%ax
 5bd:	66 90                	xchg   %ax,%ax
 5bf:	90                   	nop

000005c0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	83 ec 18             	sub    $0x18,%esp
 5c6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 5c9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5d0:	00 
 5d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 5d4:	89 54 24 04          	mov    %edx,0x4(%esp)
 5d8:	89 04 24             	mov    %eax,(%esp)
 5db:	e8 0b ff ff ff       	call   4eb <write>
}
 5e0:	c9                   	leave  
 5e1:	c3                   	ret    

000005e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5e2:	55                   	push   %ebp
 5e3:	89 e5                	mov    %esp,%ebp
 5e5:	57                   	push   %edi
 5e6:	56                   	push   %esi
 5e7:	53                   	push   %ebx
 5e8:	83 ec 2c             	sub    $0x2c,%esp
 5eb:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 5f1:	0f 95 c3             	setne  %bl
 5f4:	89 d0                	mov    %edx,%eax
 5f6:	c1 e8 1f             	shr    $0x1f,%eax
 5f9:	84 c3                	test   %al,%bl
 5fb:	74 0b                	je     608 <printint+0x26>
    neg = 1;
    x = -xx;
 5fd:	f7 da                	neg    %edx
    neg = 1;
 5ff:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 606:	eb 07                	jmp    60f <printint+0x2d>
  neg = 0;
 608:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 60f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 614:	8d 5e 01             	lea    0x1(%esi),%ebx
 617:	89 d0                	mov    %edx,%eax
 619:	ba 00 00 00 00       	mov    $0x0,%edx
 61e:	f7 f1                	div    %ecx
 620:	0f b6 92 06 08 00 00 	movzbl 0x806(%edx),%edx
 627:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 62b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 62d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 62f:	85 c0                	test   %eax,%eax
 631:	75 e1                	jne    614 <printint+0x32>
  if(neg)
 633:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 637:	74 16                	je     64f <printint+0x6d>
    buf[i++] = '-';
 639:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 63e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 641:	eb 0c                	jmp    64f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 643:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 648:	89 f8                	mov    %edi,%eax
 64a:	e8 71 ff ff ff       	call   5c0 <putc>
  while(--i >= 0)
 64f:	83 eb 01             	sub    $0x1,%ebx
 652:	79 ef                	jns    643 <printint+0x61>
}
 654:	83 c4 2c             	add    $0x2c,%esp
 657:	5b                   	pop    %ebx
 658:	5e                   	pop    %esi
 659:	5f                   	pop    %edi
 65a:	5d                   	pop    %ebp
 65b:	c3                   	ret    

0000065c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	57                   	push   %edi
 660:	56                   	push   %esi
 661:	53                   	push   %ebx
 662:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 665:	8d 45 10             	lea    0x10(%ebp),%eax
 668:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 66b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 670:	be 00 00 00 00       	mov    $0x0,%esi
 675:	e9 23 01 00 00       	jmp    79d <printf+0x141>
    c = fmt[i] & 0xff;
 67a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 67d:	85 ff                	test   %edi,%edi
 67f:	75 19                	jne    69a <printf+0x3e>
      if(c == '%'){
 681:	83 f8 25             	cmp    $0x25,%eax
 684:	0f 84 0b 01 00 00    	je     795 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 68a:	0f be d3             	movsbl %bl,%edx
 68d:	8b 45 08             	mov    0x8(%ebp),%eax
 690:	e8 2b ff ff ff       	call   5c0 <putc>
 695:	e9 00 01 00 00       	jmp    79a <printf+0x13e>
      }
    } else if(state == '%'){
 69a:	83 ff 25             	cmp    $0x25,%edi
 69d:	0f 85 f7 00 00 00    	jne    79a <printf+0x13e>
      if(c == 'd'){
 6a3:	83 f8 64             	cmp    $0x64,%eax
 6a6:	75 26                	jne    6ce <printf+0x72>
        printint(fd, *ap, 10, 1);
 6a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ab:	8b 10                	mov    (%eax),%edx
 6ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 6b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 6b9:	8b 45 08             	mov    0x8(%ebp),%eax
 6bc:	e8 21 ff ff ff       	call   5e2 <printint>
        ap++;
 6c1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6c5:	66 bf 00 00          	mov    $0x0,%di
 6c9:	e9 cc 00 00 00       	jmp    79a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 6ce:	83 f8 78             	cmp    $0x78,%eax
 6d1:	0f 94 c1             	sete   %cl
 6d4:	83 f8 70             	cmp    $0x70,%eax
 6d7:	0f 94 c2             	sete   %dl
 6da:	08 d1                	or     %dl,%cl
 6dc:	74 27                	je     705 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 6de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e1:	8b 10                	mov    (%eax),%edx
 6e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6ea:	b9 10 00 00 00       	mov    $0x10,%ecx
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	e8 eb fe ff ff       	call   5e2 <printint>
        ap++;
 6f7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 6fb:	bf 00 00 00 00       	mov    $0x0,%edi
 700:	e9 95 00 00 00       	jmp    79a <printf+0x13e>
      } else if(c == 's'){
 705:	83 f8 73             	cmp    $0x73,%eax
 708:	75 37                	jne    741 <printf+0xe5>
        s = (char*)*ap;
 70a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70d:	8b 18                	mov    (%eax),%ebx
        ap++;
 70f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 713:	85 db                	test   %ebx,%ebx
 715:	75 19                	jne    730 <printf+0xd4>
          s = "(null)";
 717:	bb ff 07 00 00       	mov    $0x7ff,%ebx
 71c:	8b 7d 08             	mov    0x8(%ebp),%edi
 71f:	eb 12                	jmp    733 <printf+0xd7>
          putc(fd, *s);
 721:	0f be d2             	movsbl %dl,%edx
 724:	89 f8                	mov    %edi,%eax
 726:	e8 95 fe ff ff       	call   5c0 <putc>
          s++;
 72b:	83 c3 01             	add    $0x1,%ebx
 72e:	eb 03                	jmp    733 <printf+0xd7>
 730:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 733:	0f b6 13             	movzbl (%ebx),%edx
 736:	84 d2                	test   %dl,%dl
 738:	75 e7                	jne    721 <printf+0xc5>
      state = 0;
 73a:	bf 00 00 00 00       	mov    $0x0,%edi
 73f:	eb 59                	jmp    79a <printf+0x13e>
      } else if(c == 'c'){
 741:	83 f8 63             	cmp    $0x63,%eax
 744:	75 19                	jne    75f <printf+0x103>
        putc(fd, *ap);
 746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 749:	0f be 10             	movsbl (%eax),%edx
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
 74f:	e8 6c fe ff ff       	call   5c0 <putc>
        ap++;
 754:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 758:	bf 00 00 00 00       	mov    $0x0,%edi
 75d:	eb 3b                	jmp    79a <printf+0x13e>
      } else if(c == '%'){
 75f:	83 f8 25             	cmp    $0x25,%eax
 762:	75 12                	jne    776 <printf+0x11a>
        putc(fd, c);
 764:	0f be d3             	movsbl %bl,%edx
 767:	8b 45 08             	mov    0x8(%ebp),%eax
 76a:	e8 51 fe ff ff       	call   5c0 <putc>
      state = 0;
 76f:	bf 00 00 00 00       	mov    $0x0,%edi
 774:	eb 24                	jmp    79a <printf+0x13e>
        putc(fd, '%');
 776:	ba 25 00 00 00       	mov    $0x25,%edx
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	e8 3d fe ff ff       	call   5c0 <putc>
        putc(fd, c);
 783:	0f be d3             	movsbl %bl,%edx
 786:	8b 45 08             	mov    0x8(%ebp),%eax
 789:	e8 32 fe ff ff       	call   5c0 <putc>
      state = 0;
 78e:	bf 00 00 00 00       	mov    $0x0,%edi
 793:	eb 05                	jmp    79a <printf+0x13e>
        state = '%';
 795:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 79a:	83 c6 01             	add    $0x1,%esi
 79d:	89 f0                	mov    %esi,%eax
 79f:	03 45 0c             	add    0xc(%ebp),%eax
 7a2:	0f b6 18             	movzbl (%eax),%ebx
 7a5:	84 db                	test   %bl,%bl
 7a7:	0f 85 cd fe ff ff    	jne    67a <printf+0x1e>
    }
  }
}
 7ad:	83 c4 1c             	add    $0x1c,%esp
 7b0:	5b                   	pop    %ebx
 7b1:	5e                   	pop    %esi
 7b2:	5f                   	pop    %edi
 7b3:	5d                   	pop    %ebp
 7b4:	c3                   	ret    
