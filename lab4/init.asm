
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 c0 03 00 00       	push   $0x3c0
  19:	e8 07 01 00 00       	call   125 <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	78 1b                	js     40 <main+0x40>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	6a 00                	push   $0x0
  2a:	e8 2e 01 00 00       	call   15d <dup>
  dup(0);  // stderr
  2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  36:	e8 22 01 00 00       	call   15d <dup>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb 58                	jmp    98 <main+0x98>
    mknod("console", 1, 1);
  40:	83 ec 04             	sub    $0x4,%esp
  43:	6a 01                	push   $0x1
  45:	6a 01                	push   $0x1
  47:	68 c0 03 00 00       	push   $0x3c0
  4c:	e8 dc 00 00 00       	call   12d <mknod>
    open("console", O_RDWR);
  51:	83 c4 08             	add    $0x8,%esp
  54:	6a 02                	push   $0x2
  56:	68 c0 03 00 00       	push   $0x3c0
  5b:	e8 c5 00 00 00       	call   125 <open>
  60:	83 c4 10             	add    $0x10,%esp
  63:	eb c0                	jmp    25 <main+0x25>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 db 03 00 00       	push   $0x3db
  6d:	6a 01                	push   $0x1
  6f:	e8 e6 01 00 00       	call   25a <printf>
      exit();
  74:	e8 6c 00 00 00       	call   e5 <exit>
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 07 04 00 00       	push   $0x407
  81:	6a 01                	push   $0x1
  83:	e8 d2 01 00 00       	call   25a <printf>
  88:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  8b:	e8 5d 00 00 00       	call   ed <wait>
  90:	85 c0                	test   %eax,%eax
  92:	78 04                	js     98 <main+0x98>
  94:	39 c3                	cmp    %eax,%ebx
  96:	75 e1                	jne    79 <main+0x79>
    printf(1, "init: starting sh\n");
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 c8 03 00 00       	push   $0x3c8
  a0:	6a 01                	push   $0x1
  a2:	e8 b3 01 00 00       	call   25a <printf>
    pid = fork();
  a7:	e8 31 00 00 00       	call   dd <fork>
  ac:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	85 c0                	test   %eax,%eax
  b3:	78 b0                	js     65 <main+0x65>
    if(pid == 0){
  b5:	75 d4                	jne    8b <main+0x8b>
      exec("sh", argv);
  b7:	83 ec 08             	sub    $0x8,%esp
  ba:	68 84 04 00 00       	push   $0x484
  bf:	68 ee 03 00 00       	push   $0x3ee
  c4:	e8 54 00 00 00       	call   11d <exec>
      printf(1, "init: exec sh failed\n");
  c9:	83 c4 08             	add    $0x8,%esp
  cc:	68 f1 03 00 00       	push   $0x3f1
  d1:	6a 01                	push   $0x1
  d3:	e8 82 01 00 00       	call   25a <printf>
      exit();
  d8:	e8 08 00 00 00       	call   e5 <exit>

000000dd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  dd:	b8 01 00 00 00       	mov    $0x1,%eax
  e2:	cd 40                	int    $0x40
  e4:	c3                   	ret    

000000e5 <exit>:
SYSCALL(exit)
  e5:	b8 02 00 00 00       	mov    $0x2,%eax
  ea:	cd 40                	int    $0x40
  ec:	c3                   	ret    

000000ed <wait>:
SYSCALL(wait)
  ed:	b8 03 00 00 00       	mov    $0x3,%eax
  f2:	cd 40                	int    $0x40
  f4:	c3                   	ret    

000000f5 <pipe>:
SYSCALL(pipe)
  f5:	b8 04 00 00 00       	mov    $0x4,%eax
  fa:	cd 40                	int    $0x40
  fc:	c3                   	ret    

000000fd <read>:
SYSCALL(read)
  fd:	b8 05 00 00 00       	mov    $0x5,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <write>:
SYSCALL(write)
 105:	b8 10 00 00 00       	mov    $0x10,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <close>:
SYSCALL(close)
 10d:	b8 15 00 00 00       	mov    $0x15,%eax
 112:	cd 40                	int    $0x40
 114:	c3                   	ret    

00000115 <kill>:
SYSCALL(kill)
 115:	b8 06 00 00 00       	mov    $0x6,%eax
 11a:	cd 40                	int    $0x40
 11c:	c3                   	ret    

0000011d <exec>:
SYSCALL(exec)
 11d:	b8 07 00 00 00       	mov    $0x7,%eax
 122:	cd 40                	int    $0x40
 124:	c3                   	ret    

00000125 <open>:
SYSCALL(open)
 125:	b8 0f 00 00 00       	mov    $0xf,%eax
 12a:	cd 40                	int    $0x40
 12c:	c3                   	ret    

0000012d <mknod>:
SYSCALL(mknod)
 12d:	b8 11 00 00 00       	mov    $0x11,%eax
 132:	cd 40                	int    $0x40
 134:	c3                   	ret    

00000135 <unlink>:
SYSCALL(unlink)
 135:	b8 12 00 00 00       	mov    $0x12,%eax
 13a:	cd 40                	int    $0x40
 13c:	c3                   	ret    

0000013d <fstat>:
SYSCALL(fstat)
 13d:	b8 08 00 00 00       	mov    $0x8,%eax
 142:	cd 40                	int    $0x40
 144:	c3                   	ret    

00000145 <link>:
SYSCALL(link)
 145:	b8 13 00 00 00       	mov    $0x13,%eax
 14a:	cd 40                	int    $0x40
 14c:	c3                   	ret    

0000014d <mkdir>:
SYSCALL(mkdir)
 14d:	b8 14 00 00 00       	mov    $0x14,%eax
 152:	cd 40                	int    $0x40
 154:	c3                   	ret    

00000155 <chdir>:
SYSCALL(chdir)
 155:	b8 09 00 00 00       	mov    $0x9,%eax
 15a:	cd 40                	int    $0x40
 15c:	c3                   	ret    

0000015d <dup>:
SYSCALL(dup)
 15d:	b8 0a 00 00 00       	mov    $0xa,%eax
 162:	cd 40                	int    $0x40
 164:	c3                   	ret    

00000165 <getpid>:
SYSCALL(getpid)
 165:	b8 0b 00 00 00       	mov    $0xb,%eax
 16a:	cd 40                	int    $0x40
 16c:	c3                   	ret    

0000016d <sbrk>:
SYSCALL(sbrk)
 16d:	b8 0c 00 00 00       	mov    $0xc,%eax
 172:	cd 40                	int    $0x40
 174:	c3                   	ret    

00000175 <sleep>:
SYSCALL(sleep)
 175:	b8 0d 00 00 00       	mov    $0xd,%eax
 17a:	cd 40                	int    $0x40
 17c:	c3                   	ret    

0000017d <uptime>:
SYSCALL(uptime)
 17d:	b8 0e 00 00 00       	mov    $0xe,%eax
 182:	cd 40                	int    $0x40
 184:	c3                   	ret    

00000185 <yield>:
SYSCALL(yield)
 185:	b8 16 00 00 00       	mov    $0x16,%eax
 18a:	cd 40                	int    $0x40
 18c:	c3                   	ret    

0000018d <shutdown>:
SYSCALL(shutdown)
 18d:	b8 17 00 00 00       	mov    $0x17,%eax
 192:	cd 40                	int    $0x40
 194:	c3                   	ret    

00000195 <writecount>:
SYSCALL(writecount)
 195:	b8 18 00 00 00       	mov    $0x18,%eax
 19a:	cd 40                	int    $0x40
 19c:	c3                   	ret    

0000019d <setwritecount>:
SYSCALL(setwritecount)
 19d:	b8 19 00 00 00       	mov    $0x19,%eax
 1a2:	cd 40                	int    $0x40
 1a4:	c3                   	ret    

000001a5 <settickets>:
SYSCALL(settickets)
 1a5:	b8 1a 00 00 00       	mov    $0x1a,%eax
 1aa:	cd 40                	int    $0x40
 1ac:	c3                   	ret    

000001ad <getprocessesinfo>:
 1ad:	b8 1b 00 00 00       	mov    $0x1b,%eax
 1b2:	cd 40                	int    $0x40
 1b4:	c3                   	ret    

000001b5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
 1b8:	83 ec 1c             	sub    $0x1c,%esp
 1bb:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1be:	6a 01                	push   $0x1
 1c0:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1c3:	52                   	push   %edx
 1c4:	50                   	push   %eax
 1c5:	e8 3b ff ff ff       	call   105 <write>
}
 1ca:	83 c4 10             	add    $0x10,%esp
 1cd:	c9                   	leave  
 1ce:	c3                   	ret    

000001cf <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	57                   	push   %edi
 1d3:	56                   	push   %esi
 1d4:	53                   	push   %ebx
 1d5:	83 ec 2c             	sub    $0x2c,%esp
 1d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1db:	89 d0                	mov    %edx,%eax
 1dd:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1e3:	0f 95 c1             	setne  %cl
 1e6:	c1 ea 1f             	shr    $0x1f,%edx
 1e9:	84 d1                	test   %dl,%cl
 1eb:	74 44                	je     231 <printint+0x62>
    neg = 1;
    x = -xx;
 1ed:	f7 d8                	neg    %eax
 1ef:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1fd:	89 c8                	mov    %ecx,%eax
 1ff:	ba 00 00 00 00       	mov    $0x0,%edx
 204:	f7 f6                	div    %esi
 206:	89 df                	mov    %ebx,%edi
 208:	83 c3 01             	add    $0x1,%ebx
 20b:	0f b6 92 70 04 00 00 	movzbl 0x470(%edx),%edx
 212:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 216:	89 ca                	mov    %ecx,%edx
 218:	89 c1                	mov    %eax,%ecx
 21a:	39 d6                	cmp    %edx,%esi
 21c:	76 df                	jbe    1fd <printint+0x2e>
  if(neg)
 21e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 222:	74 31                	je     255 <printint+0x86>
    buf[i++] = '-';
 224:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 229:	8d 5f 02             	lea    0x2(%edi),%ebx
 22c:	8b 75 d0             	mov    -0x30(%ebp),%esi
 22f:	eb 17                	jmp    248 <printint+0x79>
    x = xx;
 231:	89 c1                	mov    %eax,%ecx
  neg = 0;
 233:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 23a:	eb bc                	jmp    1f8 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 23c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 241:	89 f0                	mov    %esi,%eax
 243:	e8 6d ff ff ff       	call   1b5 <putc>
  while(--i >= 0)
 248:	83 eb 01             	sub    $0x1,%ebx
 24b:	79 ef                	jns    23c <printint+0x6d>
}
 24d:	83 c4 2c             	add    $0x2c,%esp
 250:	5b                   	pop    %ebx
 251:	5e                   	pop    %esi
 252:	5f                   	pop    %edi
 253:	5d                   	pop    %ebp
 254:	c3                   	ret    
 255:	8b 75 d0             	mov    -0x30(%ebp),%esi
 258:	eb ee                	jmp    248 <printint+0x79>

0000025a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	57                   	push   %edi
 25e:	56                   	push   %esi
 25f:	53                   	push   %ebx
 260:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 263:	8d 45 10             	lea    0x10(%ebp),%eax
 266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 269:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 26e:	bb 00 00 00 00       	mov    $0x0,%ebx
 273:	eb 14                	jmp    289 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 275:	89 fa                	mov    %edi,%edx
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	e8 36 ff ff ff       	call   1b5 <putc>
 27f:	eb 05                	jmp    286 <printf+0x2c>
      }
    } else if(state == '%'){
 281:	83 fe 25             	cmp    $0x25,%esi
 284:	74 25                	je     2ab <printf+0x51>
  for(i = 0; fmt[i]; i++){
 286:	83 c3 01             	add    $0x1,%ebx
 289:	8b 45 0c             	mov    0xc(%ebp),%eax
 28c:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 290:	84 c0                	test   %al,%al
 292:	0f 84 20 01 00 00    	je     3b8 <printf+0x15e>
    c = fmt[i] & 0xff;
 298:	0f be f8             	movsbl %al,%edi
 29b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 29e:	85 f6                	test   %esi,%esi
 2a0:	75 df                	jne    281 <printf+0x27>
      if(c == '%'){
 2a2:	83 f8 25             	cmp    $0x25,%eax
 2a5:	75 ce                	jne    275 <printf+0x1b>
        state = '%';
 2a7:	89 c6                	mov    %eax,%esi
 2a9:	eb db                	jmp    286 <printf+0x2c>
      if(c == 'd'){
 2ab:	83 f8 25             	cmp    $0x25,%eax
 2ae:	0f 84 cf 00 00 00    	je     383 <printf+0x129>
 2b4:	0f 8c dd 00 00 00    	jl     397 <printf+0x13d>
 2ba:	83 f8 78             	cmp    $0x78,%eax
 2bd:	0f 8f d4 00 00 00    	jg     397 <printf+0x13d>
 2c3:	83 f8 63             	cmp    $0x63,%eax
 2c6:	0f 8c cb 00 00 00    	jl     397 <printf+0x13d>
 2cc:	83 e8 63             	sub    $0x63,%eax
 2cf:	83 f8 15             	cmp    $0x15,%eax
 2d2:	0f 87 bf 00 00 00    	ja     397 <printf+0x13d>
 2d8:	ff 24 85 18 04 00 00 	jmp    *0x418(,%eax,4)
        printint(fd, *ap, 10, 1);
 2df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2e2:	8b 17                	mov    (%edi),%edx
 2e4:	83 ec 0c             	sub    $0xc,%esp
 2e7:	6a 01                	push   $0x1
 2e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2ee:	8b 45 08             	mov    0x8(%ebp),%eax
 2f1:	e8 d9 fe ff ff       	call   1cf <printint>
        ap++;
 2f6:	83 c7 04             	add    $0x4,%edi
 2f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2fc:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2ff:	be 00 00 00 00       	mov    $0x0,%esi
 304:	eb 80                	jmp    286 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 309:	8b 17                	mov    (%edi),%edx
 30b:	83 ec 0c             	sub    $0xc,%esp
 30e:	6a 00                	push   $0x0
 310:	b9 10 00 00 00       	mov    $0x10,%ecx
 315:	8b 45 08             	mov    0x8(%ebp),%eax
 318:	e8 b2 fe ff ff       	call   1cf <printint>
        ap++;
 31d:	83 c7 04             	add    $0x4,%edi
 320:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 323:	83 c4 10             	add    $0x10,%esp
      state = 0;
 326:	be 00 00 00 00       	mov    $0x0,%esi
 32b:	e9 56 ff ff ff       	jmp    286 <printf+0x2c>
        s = (char*)*ap;
 330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 333:	8b 30                	mov    (%eax),%esi
        ap++;
 335:	83 c0 04             	add    $0x4,%eax
 338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 33b:	85 f6                	test   %esi,%esi
 33d:	75 15                	jne    354 <printf+0xfa>
          s = "(null)";
 33f:	be 10 04 00 00       	mov    $0x410,%esi
 344:	eb 0e                	jmp    354 <printf+0xfa>
          putc(fd, *s);
 346:	0f be d2             	movsbl %dl,%edx
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	e8 64 fe ff ff       	call   1b5 <putc>
          s++;
 351:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 354:	0f b6 16             	movzbl (%esi),%edx
 357:	84 d2                	test   %dl,%dl
 359:	75 eb                	jne    346 <printf+0xec>
      state = 0;
 35b:	be 00 00 00 00       	mov    $0x0,%esi
 360:	e9 21 ff ff ff       	jmp    286 <printf+0x2c>
        putc(fd, *ap);
 365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 368:	0f be 17             	movsbl (%edi),%edx
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
 36e:	e8 42 fe ff ff       	call   1b5 <putc>
        ap++;
 373:	83 c7 04             	add    $0x4,%edi
 376:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 379:	be 00 00 00 00       	mov    $0x0,%esi
 37e:	e9 03 ff ff ff       	jmp    286 <printf+0x2c>
        putc(fd, c);
 383:	89 fa                	mov    %edi,%edx
 385:	8b 45 08             	mov    0x8(%ebp),%eax
 388:	e8 28 fe ff ff       	call   1b5 <putc>
      state = 0;
 38d:	be 00 00 00 00       	mov    $0x0,%esi
 392:	e9 ef fe ff ff       	jmp    286 <printf+0x2c>
        putc(fd, '%');
 397:	ba 25 00 00 00       	mov    $0x25,%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	e8 11 fe ff ff       	call   1b5 <putc>
        putc(fd, c);
 3a4:	89 fa                	mov    %edi,%edx
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	e8 07 fe ff ff       	call   1b5 <putc>
      state = 0;
 3ae:	be 00 00 00 00       	mov    $0x0,%esi
 3b3:	e9 ce fe ff ff       	jmp    286 <printf+0x2c>
    }
  }
}
 3b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3bb:	5b                   	pop    %ebx
 3bc:	5e                   	pop    %esi
 3bd:	5f                   	pop    %edi
 3be:	5d                   	pop    %ebp
 3bf:	c3                   	ret    
