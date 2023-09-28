
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 14                	je     2b <main+0x2b>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 40 03 00 00       	push   $0x340
  1f:	6a 02                	push   $0x2
  21:	e8 b3 01 00 00       	call   1d9 <printf>
    exit();
  26:	e8 39 00 00 00       	call   64 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 73 08             	push   0x8(%ebx)
  31:	ff 73 04             	push   0x4(%ebx)
  34:	e8 8b 00 00 00       	call   c4 <link>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	85 c0                	test   %eax,%eax
  3e:	78 05                	js     45 <main+0x45>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  40:	e8 1f 00 00 00       	call   64 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  45:	ff 73 08             	push   0x8(%ebx)
  48:	ff 73 04             	push   0x4(%ebx)
  4b:	68 53 03 00 00       	push   $0x353
  50:	6a 02                	push   $0x2
  52:	e8 82 01 00 00       	call   1d9 <printf>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	eb e4                	jmp    40 <main+0x40>

0000005c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  5c:	b8 01 00 00 00       	mov    $0x1,%eax
  61:	cd 40                	int    $0x40
  63:	c3                   	ret    

00000064 <exit>:
SYSCALL(exit)
  64:	b8 02 00 00 00       	mov    $0x2,%eax
  69:	cd 40                	int    $0x40
  6b:	c3                   	ret    

0000006c <wait>:
SYSCALL(wait)
  6c:	b8 03 00 00 00       	mov    $0x3,%eax
  71:	cd 40                	int    $0x40
  73:	c3                   	ret    

00000074 <pipe>:
SYSCALL(pipe)
  74:	b8 04 00 00 00       	mov    $0x4,%eax
  79:	cd 40                	int    $0x40
  7b:	c3                   	ret    

0000007c <read>:
SYSCALL(read)
  7c:	b8 05 00 00 00       	mov    $0x5,%eax
  81:	cd 40                	int    $0x40
  83:	c3                   	ret    

00000084 <write>:
SYSCALL(write)
  84:	b8 10 00 00 00       	mov    $0x10,%eax
  89:	cd 40                	int    $0x40
  8b:	c3                   	ret    

0000008c <close>:
SYSCALL(close)
  8c:	b8 15 00 00 00       	mov    $0x15,%eax
  91:	cd 40                	int    $0x40
  93:	c3                   	ret    

00000094 <kill>:
SYSCALL(kill)
  94:	b8 06 00 00 00       	mov    $0x6,%eax
  99:	cd 40                	int    $0x40
  9b:	c3                   	ret    

0000009c <exec>:
SYSCALL(exec)
  9c:	b8 07 00 00 00       	mov    $0x7,%eax
  a1:	cd 40                	int    $0x40
  a3:	c3                   	ret    

000000a4 <open>:
SYSCALL(open)
  a4:	b8 0f 00 00 00       	mov    $0xf,%eax
  a9:	cd 40                	int    $0x40
  ab:	c3                   	ret    

000000ac <mknod>:
SYSCALL(mknod)
  ac:	b8 11 00 00 00       	mov    $0x11,%eax
  b1:	cd 40                	int    $0x40
  b3:	c3                   	ret    

000000b4 <unlink>:
SYSCALL(unlink)
  b4:	b8 12 00 00 00       	mov    $0x12,%eax
  b9:	cd 40                	int    $0x40
  bb:	c3                   	ret    

000000bc <fstat>:
SYSCALL(fstat)
  bc:	b8 08 00 00 00       	mov    $0x8,%eax
  c1:	cd 40                	int    $0x40
  c3:	c3                   	ret    

000000c4 <link>:
SYSCALL(link)
  c4:	b8 13 00 00 00       	mov    $0x13,%eax
  c9:	cd 40                	int    $0x40
  cb:	c3                   	ret    

000000cc <mkdir>:
SYSCALL(mkdir)
  cc:	b8 14 00 00 00       	mov    $0x14,%eax
  d1:	cd 40                	int    $0x40
  d3:	c3                   	ret    

000000d4 <chdir>:
SYSCALL(chdir)
  d4:	b8 09 00 00 00       	mov    $0x9,%eax
  d9:	cd 40                	int    $0x40
  db:	c3                   	ret    

000000dc <dup>:
SYSCALL(dup)
  dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  e1:	cd 40                	int    $0x40
  e3:	c3                   	ret    

000000e4 <getpid>:
SYSCALL(getpid)
  e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  e9:	cd 40                	int    $0x40
  eb:	c3                   	ret    

000000ec <sbrk>:
SYSCALL(sbrk)
  ec:	b8 0c 00 00 00       	mov    $0xc,%eax
  f1:	cd 40                	int    $0x40
  f3:	c3                   	ret    

000000f4 <sleep>:
SYSCALL(sleep)
  f4:	b8 0d 00 00 00       	mov    $0xd,%eax
  f9:	cd 40                	int    $0x40
  fb:	c3                   	ret    

000000fc <uptime>:
SYSCALL(uptime)
  fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 101:	cd 40                	int    $0x40
 103:	c3                   	ret    

00000104 <yield>:
SYSCALL(yield)
 104:	b8 16 00 00 00       	mov    $0x16,%eax
 109:	cd 40                	int    $0x40
 10b:	c3                   	ret    

0000010c <shutdown>:
SYSCALL(shutdown)
 10c:	b8 17 00 00 00       	mov    $0x17,%eax
 111:	cd 40                	int    $0x40
 113:	c3                   	ret    

00000114 <writecount>:
SYSCALL(writecount)
 114:	b8 18 00 00 00       	mov    $0x18,%eax
 119:	cd 40                	int    $0x40
 11b:	c3                   	ret    

0000011c <setwritecount>:
SYSCALL(setwritecount)
 11c:	b8 19 00 00 00       	mov    $0x19,%eax
 121:	cd 40                	int    $0x40
 123:	c3                   	ret    

00000124 <settickets>:
SYSCALL(settickets)
 124:	b8 1a 00 00 00       	mov    $0x1a,%eax
 129:	cd 40                	int    $0x40
 12b:	c3                   	ret    

0000012c <getprocessesinfo>:
 12c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 131:	cd 40                	int    $0x40
 133:	c3                   	ret    

00000134 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 1c             	sub    $0x1c,%esp
 13a:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 13d:	6a 01                	push   $0x1
 13f:	8d 55 f4             	lea    -0xc(%ebp),%edx
 142:	52                   	push   %edx
 143:	50                   	push   %eax
 144:	e8 3b ff ff ff       	call   84 <write>
}
 149:	83 c4 10             	add    $0x10,%esp
 14c:	c9                   	leave  
 14d:	c3                   	ret    

0000014e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 14e:	55                   	push   %ebp
 14f:	89 e5                	mov    %esp,%ebp
 151:	57                   	push   %edi
 152:	56                   	push   %esi
 153:	53                   	push   %ebx
 154:	83 ec 2c             	sub    $0x2c,%esp
 157:	89 45 d0             	mov    %eax,-0x30(%ebp)
 15a:	89 d0                	mov    %edx,%eax
 15c:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 15e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 162:	0f 95 c1             	setne  %cl
 165:	c1 ea 1f             	shr    $0x1f,%edx
 168:	84 d1                	test   %dl,%cl
 16a:	74 44                	je     1b0 <printint+0x62>
    neg = 1;
    x = -xx;
 16c:	f7 d8                	neg    %eax
 16e:	89 c1                	mov    %eax,%ecx
    neg = 1;
 170:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 177:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 17c:	89 c8                	mov    %ecx,%eax
 17e:	ba 00 00 00 00       	mov    $0x0,%edx
 183:	f7 f6                	div    %esi
 185:	89 df                	mov    %ebx,%edi
 187:	83 c3 01             	add    $0x1,%ebx
 18a:	0f b6 92 c8 03 00 00 	movzbl 0x3c8(%edx),%edx
 191:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 195:	89 ca                	mov    %ecx,%edx
 197:	89 c1                	mov    %eax,%ecx
 199:	39 d6                	cmp    %edx,%esi
 19b:	76 df                	jbe    17c <printint+0x2e>
  if(neg)
 19d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1a1:	74 31                	je     1d4 <printint+0x86>
    buf[i++] = '-';
 1a3:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1a8:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1ae:	eb 17                	jmp    1c7 <printint+0x79>
    x = xx;
 1b0:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1b2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1b9:	eb bc                	jmp    177 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1bb:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1c0:	89 f0                	mov    %esi,%eax
 1c2:	e8 6d ff ff ff       	call   134 <putc>
  while(--i >= 0)
 1c7:	83 eb 01             	sub    $0x1,%ebx
 1ca:	79 ef                	jns    1bb <printint+0x6d>
}
 1cc:	83 c4 2c             	add    $0x2c,%esp
 1cf:	5b                   	pop    %ebx
 1d0:	5e                   	pop    %esi
 1d1:	5f                   	pop    %edi
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    
 1d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1d7:	eb ee                	jmp    1c7 <printint+0x79>

000001d9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	57                   	push   %edi
 1dd:	56                   	push   %esi
 1de:	53                   	push   %ebx
 1df:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1e2:	8d 45 10             	lea    0x10(%ebp),%eax
 1e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1e8:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1ed:	bb 00 00 00 00       	mov    $0x0,%ebx
 1f2:	eb 14                	jmp    208 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1f4:	89 fa                	mov    %edi,%edx
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	e8 36 ff ff ff       	call   134 <putc>
 1fe:	eb 05                	jmp    205 <printf+0x2c>
      }
    } else if(state == '%'){
 200:	83 fe 25             	cmp    $0x25,%esi
 203:	74 25                	je     22a <printf+0x51>
  for(i = 0; fmt[i]; i++){
 205:	83 c3 01             	add    $0x1,%ebx
 208:	8b 45 0c             	mov    0xc(%ebp),%eax
 20b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 20f:	84 c0                	test   %al,%al
 211:	0f 84 20 01 00 00    	je     337 <printf+0x15e>
    c = fmt[i] & 0xff;
 217:	0f be f8             	movsbl %al,%edi
 21a:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 21d:	85 f6                	test   %esi,%esi
 21f:	75 df                	jne    200 <printf+0x27>
      if(c == '%'){
 221:	83 f8 25             	cmp    $0x25,%eax
 224:	75 ce                	jne    1f4 <printf+0x1b>
        state = '%';
 226:	89 c6                	mov    %eax,%esi
 228:	eb db                	jmp    205 <printf+0x2c>
      if(c == 'd'){
 22a:	83 f8 25             	cmp    $0x25,%eax
 22d:	0f 84 cf 00 00 00    	je     302 <printf+0x129>
 233:	0f 8c dd 00 00 00    	jl     316 <printf+0x13d>
 239:	83 f8 78             	cmp    $0x78,%eax
 23c:	0f 8f d4 00 00 00    	jg     316 <printf+0x13d>
 242:	83 f8 63             	cmp    $0x63,%eax
 245:	0f 8c cb 00 00 00    	jl     316 <printf+0x13d>
 24b:	83 e8 63             	sub    $0x63,%eax
 24e:	83 f8 15             	cmp    $0x15,%eax
 251:	0f 87 bf 00 00 00    	ja     316 <printf+0x13d>
 257:	ff 24 85 70 03 00 00 	jmp    *0x370(,%eax,4)
        printint(fd, *ap, 10, 1);
 25e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 261:	8b 17                	mov    (%edi),%edx
 263:	83 ec 0c             	sub    $0xc,%esp
 266:	6a 01                	push   $0x1
 268:	b9 0a 00 00 00       	mov    $0xa,%ecx
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	e8 d9 fe ff ff       	call   14e <printint>
        ap++;
 275:	83 c7 04             	add    $0x4,%edi
 278:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 27b:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 27e:	be 00 00 00 00       	mov    $0x0,%esi
 283:	eb 80                	jmp    205 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 285:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 288:	8b 17                	mov    (%edi),%edx
 28a:	83 ec 0c             	sub    $0xc,%esp
 28d:	6a 00                	push   $0x0
 28f:	b9 10 00 00 00       	mov    $0x10,%ecx
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	e8 b2 fe ff ff       	call   14e <printint>
        ap++;
 29c:	83 c7 04             	add    $0x4,%edi
 29f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2a2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2a5:	be 00 00 00 00       	mov    $0x0,%esi
 2aa:	e9 56 ff ff ff       	jmp    205 <printf+0x2c>
        s = (char*)*ap;
 2af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2b2:	8b 30                	mov    (%eax),%esi
        ap++;
 2b4:	83 c0 04             	add    $0x4,%eax
 2b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2ba:	85 f6                	test   %esi,%esi
 2bc:	75 15                	jne    2d3 <printf+0xfa>
          s = "(null)";
 2be:	be 67 03 00 00       	mov    $0x367,%esi
 2c3:	eb 0e                	jmp    2d3 <printf+0xfa>
          putc(fd, *s);
 2c5:	0f be d2             	movsbl %dl,%edx
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	e8 64 fe ff ff       	call   134 <putc>
          s++;
 2d0:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2d3:	0f b6 16             	movzbl (%esi),%edx
 2d6:	84 d2                	test   %dl,%dl
 2d8:	75 eb                	jne    2c5 <printf+0xec>
      state = 0;
 2da:	be 00 00 00 00       	mov    $0x0,%esi
 2df:	e9 21 ff ff ff       	jmp    205 <printf+0x2c>
        putc(fd, *ap);
 2e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2e7:	0f be 17             	movsbl (%edi),%edx
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	e8 42 fe ff ff       	call   134 <putc>
        ap++;
 2f2:	83 c7 04             	add    $0x4,%edi
 2f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2f8:	be 00 00 00 00       	mov    $0x0,%esi
 2fd:	e9 03 ff ff ff       	jmp    205 <printf+0x2c>
        putc(fd, c);
 302:	89 fa                	mov    %edi,%edx
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	e8 28 fe ff ff       	call   134 <putc>
      state = 0;
 30c:	be 00 00 00 00       	mov    $0x0,%esi
 311:	e9 ef fe ff ff       	jmp    205 <printf+0x2c>
        putc(fd, '%');
 316:	ba 25 00 00 00       	mov    $0x25,%edx
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	e8 11 fe ff ff       	call   134 <putc>
        putc(fd, c);
 323:	89 fa                	mov    %edi,%edx
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	e8 07 fe ff ff       	call   134 <putc>
      state = 0;
 32d:	be 00 00 00 00       	mov    $0x0,%esi
 332:	e9 ce fe ff ff       	jmp    205 <printf+0x2c>
    }
  }
}
 337:	8d 65 f4             	lea    -0xc(%ebp),%esp
 33a:	5b                   	pop    %ebx
 33b:	5e                   	pop    %esi
 33c:	5f                   	pop    %edi
 33d:	5d                   	pop    %ebp
 33e:	c3                   	ret    
