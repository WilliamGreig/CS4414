
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 10             	sub    $0x10,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  11:	00 
  12:	c7 04 24 e5 03 00 00 	movl   $0x3e5,(%esp)
  19:	e8 27 01 00 00       	call   145 <open>
  1e:	85 c0                	test   %eax,%eax
  20:	79 30                	jns    52 <main+0x52>
    mknod("console", 1, 1);
  22:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  29:	00 
  2a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  31:	00 
  32:	c7 04 24 e5 03 00 00 	movl   $0x3e5,(%esp)
  39:	e8 0f 01 00 00       	call   14d <mknod>
    open("console", O_RDWR);
  3e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  45:	00 
  46:	c7 04 24 e5 03 00 00 	movl   $0x3e5,(%esp)
  4d:	e8 f3 00 00 00       	call   145 <open>
  }
  dup(0);  // stdout
  52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  59:	e8 1f 01 00 00       	call   17d <dup>
  dup(0);  // stderr
  5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  65:	e8 13 01 00 00       	call   17d <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  6a:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
  71:	00 
  72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  79:	e8 0e 02 00 00       	call   28c <printf>
    pid = fork();
  7e:	e8 7a 00 00 00       	call   fd <fork>
  83:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  85:	85 c0                	test   %eax,%eax
  87:	79 19                	jns    a2 <main+0xa2>
      printf(1, "init: fork failed\n");
  89:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  90:	00 
  91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  98:	e8 ef 01 00 00       	call   28c <printf>
      exit();
  9d:	e8 63 00 00 00       	call   105 <exit>
    }
    if(pid == 0){
  a2:	85 c0                	test   %eax,%eax
  a4:	75 41                	jne    e7 <main+0xe7>
      exec("sh", argv);
  a6:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
  ad:	00 
  ae:	c7 04 24 13 04 00 00 	movl   $0x413,(%esp)
  b5:	e8 83 00 00 00       	call   13d <exec>
      printf(1, "init: exec sh failed\n");
  ba:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
  c1:	00 
  c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c9:	e8 be 01 00 00       	call   28c <printf>
      exit();
  ce:	e8 32 00 00 00       	call   105 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  d3:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
  da:	00 
  db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e2:	e8 a5 01 00 00       	call   28c <printf>
    while((wpid=wait()) >= 0 && wpid != pid)
  e7:	e8 21 00 00 00       	call   10d <wait>
  ec:	85 c0                	test   %eax,%eax
  ee:	0f 88 76 ff ff ff    	js     6a <main+0x6a>
  f4:	39 d8                	cmp    %ebx,%eax
  f6:	75 db                	jne    d3 <main+0xd3>
  f8:	e9 6d ff ff ff       	jmp    6a <main+0x6a>

000000fd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  fd:	b8 01 00 00 00       	mov    $0x1,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <exit>:
SYSCALL(exit)
 105:	b8 02 00 00 00       	mov    $0x2,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <wait>:
SYSCALL(wait)
 10d:	b8 03 00 00 00       	mov    $0x3,%eax
 112:	cd 40                	int    $0x40
 114:	c3                   	ret    

00000115 <pipe>:
SYSCALL(pipe)
 115:	b8 04 00 00 00       	mov    $0x4,%eax
 11a:	cd 40                	int    $0x40
 11c:	c3                   	ret    

0000011d <read>:
SYSCALL(read)
 11d:	b8 05 00 00 00       	mov    $0x5,%eax
 122:	cd 40                	int    $0x40
 124:	c3                   	ret    

00000125 <write>:
SYSCALL(write)
 125:	b8 10 00 00 00       	mov    $0x10,%eax
 12a:	cd 40                	int    $0x40
 12c:	c3                   	ret    

0000012d <close>:
SYSCALL(close)
 12d:	b8 15 00 00 00       	mov    $0x15,%eax
 132:	cd 40                	int    $0x40
 134:	c3                   	ret    

00000135 <kill>:
SYSCALL(kill)
 135:	b8 06 00 00 00       	mov    $0x6,%eax
 13a:	cd 40                	int    $0x40
 13c:	c3                   	ret    

0000013d <exec>:
SYSCALL(exec)
 13d:	b8 07 00 00 00       	mov    $0x7,%eax
 142:	cd 40                	int    $0x40
 144:	c3                   	ret    

00000145 <open>:
SYSCALL(open)
 145:	b8 0f 00 00 00       	mov    $0xf,%eax
 14a:	cd 40                	int    $0x40
 14c:	c3                   	ret    

0000014d <mknod>:
SYSCALL(mknod)
 14d:	b8 11 00 00 00       	mov    $0x11,%eax
 152:	cd 40                	int    $0x40
 154:	c3                   	ret    

00000155 <unlink>:
SYSCALL(unlink)
 155:	b8 12 00 00 00       	mov    $0x12,%eax
 15a:	cd 40                	int    $0x40
 15c:	c3                   	ret    

0000015d <fstat>:
SYSCALL(fstat)
 15d:	b8 08 00 00 00       	mov    $0x8,%eax
 162:	cd 40                	int    $0x40
 164:	c3                   	ret    

00000165 <link>:
SYSCALL(link)
 165:	b8 13 00 00 00       	mov    $0x13,%eax
 16a:	cd 40                	int    $0x40
 16c:	c3                   	ret    

0000016d <mkdir>:
SYSCALL(mkdir)
 16d:	b8 14 00 00 00       	mov    $0x14,%eax
 172:	cd 40                	int    $0x40
 174:	c3                   	ret    

00000175 <chdir>:
SYSCALL(chdir)
 175:	b8 09 00 00 00       	mov    $0x9,%eax
 17a:	cd 40                	int    $0x40
 17c:	c3                   	ret    

0000017d <dup>:
SYSCALL(dup)
 17d:	b8 0a 00 00 00       	mov    $0xa,%eax
 182:	cd 40                	int    $0x40
 184:	c3                   	ret    

00000185 <getpid>:
SYSCALL(getpid)
 185:	b8 0b 00 00 00       	mov    $0xb,%eax
 18a:	cd 40                	int    $0x40
 18c:	c3                   	ret    

0000018d <sbrk>:
SYSCALL(sbrk)
 18d:	b8 0c 00 00 00       	mov    $0xc,%eax
 192:	cd 40                	int    $0x40
 194:	c3                   	ret    

00000195 <sleep>:
SYSCALL(sleep)
 195:	b8 0d 00 00 00       	mov    $0xd,%eax
 19a:	cd 40                	int    $0x40
 19c:	c3                   	ret    

0000019d <uptime>:
SYSCALL(uptime)
 19d:	b8 0e 00 00 00       	mov    $0xe,%eax
 1a2:	cd 40                	int    $0x40
 1a4:	c3                   	ret    

000001a5 <yield>:
SYSCALL(yield)
 1a5:	b8 16 00 00 00       	mov    $0x16,%eax
 1aa:	cd 40                	int    $0x40
 1ac:	c3                   	ret    

000001ad <shutdown>:
SYSCALL(shutdown)
 1ad:	b8 17 00 00 00       	mov    $0x17,%eax
 1b2:	cd 40                	int    $0x40
 1b4:	c3                   	ret    

000001b5 <writecount>:
SYSCALL(writecount)
 1b5:	b8 18 00 00 00       	mov    $0x18,%eax
 1ba:	cd 40                	int    $0x40
 1bc:	c3                   	ret    

000001bd <setwritecount>:
SYSCALL(setwritecount)
 1bd:	b8 19 00 00 00       	mov    $0x19,%eax
 1c2:	cd 40                	int    $0x40
 1c4:	c3                   	ret    

000001c5 <settickets>:
SYSCALL(settickets)
 1c5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 1ca:	cd 40                	int    $0x40
 1cc:	c3                   	ret    

000001cd <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 1cd:	b8 1b 00 00 00       	mov    $0x1b,%eax
 1d2:	cd 40                	int    $0x40
 1d4:	c3                   	ret    

000001d5 <getpagetableentry>:
SYSCALL(getpagetableentry)
 1d5:	b8 1c 00 00 00       	mov    $0x1c,%eax
 1da:	cd 40                	int    $0x40
 1dc:	c3                   	ret    

000001dd <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 1dd:	b8 1d 00 00 00       	mov    $0x1d,%eax
 1e2:	cd 40                	int    $0x40
 1e4:	c3                   	ret    

000001e5 <dumppagetable>:
 1e5:	b8 1e 00 00 00       	mov    $0x1e,%eax
 1ea:	cd 40                	int    $0x40
 1ec:	c3                   	ret    
 1ed:	66 90                	xchg   %ax,%ax
 1ef:	90                   	nop

000001f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	83 ec 18             	sub    $0x18,%esp
 1f6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 200:	00 
 201:	8d 55 f4             	lea    -0xc(%ebp),%edx
 204:	89 54 24 04          	mov    %edx,0x4(%esp)
 208:	89 04 24             	mov    %eax,(%esp)
 20b:	e8 15 ff ff ff       	call   125 <write>
}
 210:	c9                   	leave  
 211:	c3                   	ret    

00000212 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 212:	55                   	push   %ebp
 213:	89 e5                	mov    %esp,%ebp
 215:	57                   	push   %edi
 216:	56                   	push   %esi
 217:	53                   	push   %ebx
 218:	83 ec 2c             	sub    $0x2c,%esp
 21b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 21d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 221:	0f 95 c3             	setne  %bl
 224:	89 d0                	mov    %edx,%eax
 226:	c1 e8 1f             	shr    $0x1f,%eax
 229:	84 c3                	test   %al,%bl
 22b:	74 0b                	je     238 <printint+0x26>
    neg = 1;
    x = -xx;
 22d:	f7 da                	neg    %edx
    neg = 1;
 22f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 236:	eb 07                	jmp    23f <printint+0x2d>
  neg = 0;
 238:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 23f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 244:	8d 5e 01             	lea    0x1(%esi),%ebx
 247:	89 d0                	mov    %edx,%eax
 249:	ba 00 00 00 00       	mov    $0x0,%edx
 24e:	f7 f1                	div    %ecx
 250:	0f b6 92 3c 04 00 00 	movzbl 0x43c(%edx),%edx
 257:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 25b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 25d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 25f:	85 c0                	test   %eax,%eax
 261:	75 e1                	jne    244 <printint+0x32>
  if(neg)
 263:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 267:	74 16                	je     27f <printint+0x6d>
    buf[i++] = '-';
 269:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 26e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 271:	eb 0c                	jmp    27f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 273:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 278:	89 f8                	mov    %edi,%eax
 27a:	e8 71 ff ff ff       	call   1f0 <putc>
  while(--i >= 0)
 27f:	83 eb 01             	sub    $0x1,%ebx
 282:	79 ef                	jns    273 <printint+0x61>
}
 284:	83 c4 2c             	add    $0x2c,%esp
 287:	5b                   	pop    %ebx
 288:	5e                   	pop    %esi
 289:	5f                   	pop    %edi
 28a:	5d                   	pop    %ebp
 28b:	c3                   	ret    

0000028c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	57                   	push   %edi
 290:	56                   	push   %esi
 291:	53                   	push   %ebx
 292:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 295:	8d 45 10             	lea    0x10(%ebp),%eax
 298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 29b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 2a0:	be 00 00 00 00       	mov    $0x0,%esi
 2a5:	e9 23 01 00 00       	jmp    3cd <printf+0x141>
    c = fmt[i] & 0xff;
 2aa:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 2ad:	85 ff                	test   %edi,%edi
 2af:	75 19                	jne    2ca <printf+0x3e>
      if(c == '%'){
 2b1:	83 f8 25             	cmp    $0x25,%eax
 2b4:	0f 84 0b 01 00 00    	je     3c5 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 2ba:	0f be d3             	movsbl %bl,%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	e8 2b ff ff ff       	call   1f0 <putc>
 2c5:	e9 00 01 00 00       	jmp    3ca <printf+0x13e>
      }
    } else if(state == '%'){
 2ca:	83 ff 25             	cmp    $0x25,%edi
 2cd:	0f 85 f7 00 00 00    	jne    3ca <printf+0x13e>
      if(c == 'd'){
 2d3:	83 f8 64             	cmp    $0x64,%eax
 2d6:	75 26                	jne    2fe <printf+0x72>
        printint(fd, *ap, 10, 1);
 2d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2db:	8b 10                	mov    (%eax),%edx
 2dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	e8 21 ff ff ff       	call   212 <printint>
        ap++;
 2f1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2f5:	66 bf 00 00          	mov    $0x0,%di
 2f9:	e9 cc 00 00 00       	jmp    3ca <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 2fe:	83 f8 78             	cmp    $0x78,%eax
 301:	0f 94 c1             	sete   %cl
 304:	83 f8 70             	cmp    $0x70,%eax
 307:	0f 94 c2             	sete   %dl
 30a:	08 d1                	or     %dl,%cl
 30c:	74 27                	je     335 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 30e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 311:	8b 10                	mov    (%eax),%edx
 313:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 31a:	b9 10 00 00 00       	mov    $0x10,%ecx
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	e8 eb fe ff ff       	call   212 <printint>
        ap++;
 327:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 32b:	bf 00 00 00 00       	mov    $0x0,%edi
 330:	e9 95 00 00 00       	jmp    3ca <printf+0x13e>
      } else if(c == 's'){
 335:	83 f8 73             	cmp    $0x73,%eax
 338:	75 37                	jne    371 <printf+0xe5>
        s = (char*)*ap;
 33a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 33d:	8b 18                	mov    (%eax),%ebx
        ap++;
 33f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 343:	85 db                	test   %ebx,%ebx
 345:	75 19                	jne    360 <printf+0xd4>
          s = "(null)";
 347:	bb 35 04 00 00       	mov    $0x435,%ebx
 34c:	8b 7d 08             	mov    0x8(%ebp),%edi
 34f:	eb 12                	jmp    363 <printf+0xd7>
          putc(fd, *s);
 351:	0f be d2             	movsbl %dl,%edx
 354:	89 f8                	mov    %edi,%eax
 356:	e8 95 fe ff ff       	call   1f0 <putc>
          s++;
 35b:	83 c3 01             	add    $0x1,%ebx
 35e:	eb 03                	jmp    363 <printf+0xd7>
 360:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 363:	0f b6 13             	movzbl (%ebx),%edx
 366:	84 d2                	test   %dl,%dl
 368:	75 e7                	jne    351 <printf+0xc5>
      state = 0;
 36a:	bf 00 00 00 00       	mov    $0x0,%edi
 36f:	eb 59                	jmp    3ca <printf+0x13e>
      } else if(c == 'c'){
 371:	83 f8 63             	cmp    $0x63,%eax
 374:	75 19                	jne    38f <printf+0x103>
        putc(fd, *ap);
 376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 379:	0f be 10             	movsbl (%eax),%edx
 37c:	8b 45 08             	mov    0x8(%ebp),%eax
 37f:	e8 6c fe ff ff       	call   1f0 <putc>
        ap++;
 384:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 388:	bf 00 00 00 00       	mov    $0x0,%edi
 38d:	eb 3b                	jmp    3ca <printf+0x13e>
      } else if(c == '%'){
 38f:	83 f8 25             	cmp    $0x25,%eax
 392:	75 12                	jne    3a6 <printf+0x11a>
        putc(fd, c);
 394:	0f be d3             	movsbl %bl,%edx
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	e8 51 fe ff ff       	call   1f0 <putc>
      state = 0;
 39f:	bf 00 00 00 00       	mov    $0x0,%edi
 3a4:	eb 24                	jmp    3ca <printf+0x13e>
        putc(fd, '%');
 3a6:	ba 25 00 00 00       	mov    $0x25,%edx
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	e8 3d fe ff ff       	call   1f0 <putc>
        putc(fd, c);
 3b3:	0f be d3             	movsbl %bl,%edx
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	e8 32 fe ff ff       	call   1f0 <putc>
      state = 0;
 3be:	bf 00 00 00 00       	mov    $0x0,%edi
 3c3:	eb 05                	jmp    3ca <printf+0x13e>
        state = '%';
 3c5:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 3ca:	83 c6 01             	add    $0x1,%esi
 3cd:	89 f0                	mov    %esi,%eax
 3cf:	03 45 0c             	add    0xc(%ebp),%eax
 3d2:	0f b6 18             	movzbl (%eax),%ebx
 3d5:	84 db                	test   %bl,%bl
 3d7:	0f 85 cd fe ff ff    	jne    2aa <printf+0x1e>
    }
  }
}
 3dd:	83 c4 1c             	add    $0x1c,%esp
 3e0:	5b                   	pop    %ebx
 3e1:	5e                   	pop    %esi
 3e2:	5f                   	pop    %edi
 3e3:	5d                   	pop    %ebp
 3e4:	c3                   	ret    
