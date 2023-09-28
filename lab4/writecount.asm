
_writecount:     file format elf32-i386


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
  if (argc > 1) {
  11:	83 39 01             	cmpl   $0x1,(%ecx)
  14:	7e 05                	jle    1b <main+0x1b>
    exit();
  16:	e8 22 00 00 00       	call   3d <exit>
  }


  printf(1, "%d\n", writecount());
  1b:	e8 cd 00 00 00       	call   ed <writecount>
  20:	83 ec 04             	sub    $0x4,%esp
  23:	50                   	push   %eax
  24:	68 18 03 00 00       	push   $0x318
  29:	6a 01                	push   $0x1
  2b:	e8 82 01 00 00       	call   1b2 <printf>
 
  exit();
  30:	e8 08 00 00 00       	call   3d <exit>

00000035 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  35:	b8 01 00 00 00       	mov    $0x1,%eax
  3a:	cd 40                	int    $0x40
  3c:	c3                   	ret    

0000003d <exit>:
SYSCALL(exit)
  3d:	b8 02 00 00 00       	mov    $0x2,%eax
  42:	cd 40                	int    $0x40
  44:	c3                   	ret    

00000045 <wait>:
SYSCALL(wait)
  45:	b8 03 00 00 00       	mov    $0x3,%eax
  4a:	cd 40                	int    $0x40
  4c:	c3                   	ret    

0000004d <pipe>:
SYSCALL(pipe)
  4d:	b8 04 00 00 00       	mov    $0x4,%eax
  52:	cd 40                	int    $0x40
  54:	c3                   	ret    

00000055 <read>:
SYSCALL(read)
  55:	b8 05 00 00 00       	mov    $0x5,%eax
  5a:	cd 40                	int    $0x40
  5c:	c3                   	ret    

0000005d <write>:
SYSCALL(write)
  5d:	b8 10 00 00 00       	mov    $0x10,%eax
  62:	cd 40                	int    $0x40
  64:	c3                   	ret    

00000065 <close>:
SYSCALL(close)
  65:	b8 15 00 00 00       	mov    $0x15,%eax
  6a:	cd 40                	int    $0x40
  6c:	c3                   	ret    

0000006d <kill>:
SYSCALL(kill)
  6d:	b8 06 00 00 00       	mov    $0x6,%eax
  72:	cd 40                	int    $0x40
  74:	c3                   	ret    

00000075 <exec>:
SYSCALL(exec)
  75:	b8 07 00 00 00       	mov    $0x7,%eax
  7a:	cd 40                	int    $0x40
  7c:	c3                   	ret    

0000007d <open>:
SYSCALL(open)
  7d:	b8 0f 00 00 00       	mov    $0xf,%eax
  82:	cd 40                	int    $0x40
  84:	c3                   	ret    

00000085 <mknod>:
SYSCALL(mknod)
  85:	b8 11 00 00 00       	mov    $0x11,%eax
  8a:	cd 40                	int    $0x40
  8c:	c3                   	ret    

0000008d <unlink>:
SYSCALL(unlink)
  8d:	b8 12 00 00 00       	mov    $0x12,%eax
  92:	cd 40                	int    $0x40
  94:	c3                   	ret    

00000095 <fstat>:
SYSCALL(fstat)
  95:	b8 08 00 00 00       	mov    $0x8,%eax
  9a:	cd 40                	int    $0x40
  9c:	c3                   	ret    

0000009d <link>:
SYSCALL(link)
  9d:	b8 13 00 00 00       	mov    $0x13,%eax
  a2:	cd 40                	int    $0x40
  a4:	c3                   	ret    

000000a5 <mkdir>:
SYSCALL(mkdir)
  a5:	b8 14 00 00 00       	mov    $0x14,%eax
  aa:	cd 40                	int    $0x40
  ac:	c3                   	ret    

000000ad <chdir>:
SYSCALL(chdir)
  ad:	b8 09 00 00 00       	mov    $0x9,%eax
  b2:	cd 40                	int    $0x40
  b4:	c3                   	ret    

000000b5 <dup>:
SYSCALL(dup)
  b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  ba:	cd 40                	int    $0x40
  bc:	c3                   	ret    

000000bd <getpid>:
SYSCALL(getpid)
  bd:	b8 0b 00 00 00       	mov    $0xb,%eax
  c2:	cd 40                	int    $0x40
  c4:	c3                   	ret    

000000c5 <sbrk>:
SYSCALL(sbrk)
  c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  ca:	cd 40                	int    $0x40
  cc:	c3                   	ret    

000000cd <sleep>:
SYSCALL(sleep)
  cd:	b8 0d 00 00 00       	mov    $0xd,%eax
  d2:	cd 40                	int    $0x40
  d4:	c3                   	ret    

000000d5 <uptime>:
SYSCALL(uptime)
  d5:	b8 0e 00 00 00       	mov    $0xe,%eax
  da:	cd 40                	int    $0x40
  dc:	c3                   	ret    

000000dd <yield>:
SYSCALL(yield)
  dd:	b8 16 00 00 00       	mov    $0x16,%eax
  e2:	cd 40                	int    $0x40
  e4:	c3                   	ret    

000000e5 <shutdown>:
SYSCALL(shutdown)
  e5:	b8 17 00 00 00       	mov    $0x17,%eax
  ea:	cd 40                	int    $0x40
  ec:	c3                   	ret    

000000ed <writecount>:
SYSCALL(writecount)
  ed:	b8 18 00 00 00       	mov    $0x18,%eax
  f2:	cd 40                	int    $0x40
  f4:	c3                   	ret    

000000f5 <setwritecount>:
SYSCALL(setwritecount)
  f5:	b8 19 00 00 00       	mov    $0x19,%eax
  fa:	cd 40                	int    $0x40
  fc:	c3                   	ret    

000000fd <settickets>:
SYSCALL(settickets)
  fd:	b8 1a 00 00 00       	mov    $0x1a,%eax
 102:	cd 40                	int    $0x40
 104:	c3                   	ret    

00000105 <getprocessesinfo>:
 105:	b8 1b 00 00 00       	mov    $0x1b,%eax
 10a:	cd 40                	int    $0x40
 10c:	c3                   	ret    

0000010d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 1c             	sub    $0x1c,%esp
 113:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 116:	6a 01                	push   $0x1
 118:	8d 55 f4             	lea    -0xc(%ebp),%edx
 11b:	52                   	push   %edx
 11c:	50                   	push   %eax
 11d:	e8 3b ff ff ff       	call   5d <write>
}
 122:	83 c4 10             	add    $0x10,%esp
 125:	c9                   	leave  
 126:	c3                   	ret    

00000127 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	57                   	push   %edi
 12b:	56                   	push   %esi
 12c:	53                   	push   %ebx
 12d:	83 ec 2c             	sub    $0x2c,%esp
 130:	89 45 d0             	mov    %eax,-0x30(%ebp)
 133:	89 d0                	mov    %edx,%eax
 135:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 137:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 13b:	0f 95 c1             	setne  %cl
 13e:	c1 ea 1f             	shr    $0x1f,%edx
 141:	84 d1                	test   %dl,%cl
 143:	74 44                	je     189 <printint+0x62>
    neg = 1;
    x = -xx;
 145:	f7 d8                	neg    %eax
 147:	89 c1                	mov    %eax,%ecx
    neg = 1;
 149:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 150:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 155:	89 c8                	mov    %ecx,%eax
 157:	ba 00 00 00 00       	mov    $0x0,%edx
 15c:	f7 f6                	div    %esi
 15e:	89 df                	mov    %ebx,%edi
 160:	83 c3 01             	add    $0x1,%ebx
 163:	0f b6 92 7c 03 00 00 	movzbl 0x37c(%edx),%edx
 16a:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 16e:	89 ca                	mov    %ecx,%edx
 170:	89 c1                	mov    %eax,%ecx
 172:	39 d6                	cmp    %edx,%esi
 174:	76 df                	jbe    155 <printint+0x2e>
  if(neg)
 176:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 17a:	74 31                	je     1ad <printint+0x86>
    buf[i++] = '-';
 17c:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 181:	8d 5f 02             	lea    0x2(%edi),%ebx
 184:	8b 75 d0             	mov    -0x30(%ebp),%esi
 187:	eb 17                	jmp    1a0 <printint+0x79>
    x = xx;
 189:	89 c1                	mov    %eax,%ecx
  neg = 0;
 18b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 192:	eb bc                	jmp    150 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 194:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 199:	89 f0                	mov    %esi,%eax
 19b:	e8 6d ff ff ff       	call   10d <putc>
  while(--i >= 0)
 1a0:	83 eb 01             	sub    $0x1,%ebx
 1a3:	79 ef                	jns    194 <printint+0x6d>
}
 1a5:	83 c4 2c             	add    $0x2c,%esp
 1a8:	5b                   	pop    %ebx
 1a9:	5e                   	pop    %esi
 1aa:	5f                   	pop    %edi
 1ab:	5d                   	pop    %ebp
 1ac:	c3                   	ret    
 1ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1b0:	eb ee                	jmp    1a0 <printint+0x79>

000001b2 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	57                   	push   %edi
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1bb:	8d 45 10             	lea    0x10(%ebp),%eax
 1be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1c1:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1c6:	bb 00 00 00 00       	mov    $0x0,%ebx
 1cb:	eb 14                	jmp    1e1 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1cd:	89 fa                	mov    %edi,%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	e8 36 ff ff ff       	call   10d <putc>
 1d7:	eb 05                	jmp    1de <printf+0x2c>
      }
    } else if(state == '%'){
 1d9:	83 fe 25             	cmp    $0x25,%esi
 1dc:	74 25                	je     203 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1de:	83 c3 01             	add    $0x1,%ebx
 1e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e4:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 1e8:	84 c0                	test   %al,%al
 1ea:	0f 84 20 01 00 00    	je     310 <printf+0x15e>
    c = fmt[i] & 0xff;
 1f0:	0f be f8             	movsbl %al,%edi
 1f3:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 1f6:	85 f6                	test   %esi,%esi
 1f8:	75 df                	jne    1d9 <printf+0x27>
      if(c == '%'){
 1fa:	83 f8 25             	cmp    $0x25,%eax
 1fd:	75 ce                	jne    1cd <printf+0x1b>
        state = '%';
 1ff:	89 c6                	mov    %eax,%esi
 201:	eb db                	jmp    1de <printf+0x2c>
      if(c == 'd'){
 203:	83 f8 25             	cmp    $0x25,%eax
 206:	0f 84 cf 00 00 00    	je     2db <printf+0x129>
 20c:	0f 8c dd 00 00 00    	jl     2ef <printf+0x13d>
 212:	83 f8 78             	cmp    $0x78,%eax
 215:	0f 8f d4 00 00 00    	jg     2ef <printf+0x13d>
 21b:	83 f8 63             	cmp    $0x63,%eax
 21e:	0f 8c cb 00 00 00    	jl     2ef <printf+0x13d>
 224:	83 e8 63             	sub    $0x63,%eax
 227:	83 f8 15             	cmp    $0x15,%eax
 22a:	0f 87 bf 00 00 00    	ja     2ef <printf+0x13d>
 230:	ff 24 85 24 03 00 00 	jmp    *0x324(,%eax,4)
        printint(fd, *ap, 10, 1);
 237:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 23a:	8b 17                	mov    (%edi),%edx
 23c:	83 ec 0c             	sub    $0xc,%esp
 23f:	6a 01                	push   $0x1
 241:	b9 0a 00 00 00       	mov    $0xa,%ecx
 246:	8b 45 08             	mov    0x8(%ebp),%eax
 249:	e8 d9 fe ff ff       	call   127 <printint>
        ap++;
 24e:	83 c7 04             	add    $0x4,%edi
 251:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 254:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 257:	be 00 00 00 00       	mov    $0x0,%esi
 25c:	eb 80                	jmp    1de <printf+0x2c>
        printint(fd, *ap, 16, 0);
 25e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 261:	8b 17                	mov    (%edi),%edx
 263:	83 ec 0c             	sub    $0xc,%esp
 266:	6a 00                	push   $0x0
 268:	b9 10 00 00 00       	mov    $0x10,%ecx
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	e8 b2 fe ff ff       	call   127 <printint>
        ap++;
 275:	83 c7 04             	add    $0x4,%edi
 278:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 27b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 27e:	be 00 00 00 00       	mov    $0x0,%esi
 283:	e9 56 ff ff ff       	jmp    1de <printf+0x2c>
        s = (char*)*ap;
 288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 28b:	8b 30                	mov    (%eax),%esi
        ap++;
 28d:	83 c0 04             	add    $0x4,%eax
 290:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 293:	85 f6                	test   %esi,%esi
 295:	75 15                	jne    2ac <printf+0xfa>
          s = "(null)";
 297:	be 1c 03 00 00       	mov    $0x31c,%esi
 29c:	eb 0e                	jmp    2ac <printf+0xfa>
          putc(fd, *s);
 29e:	0f be d2             	movsbl %dl,%edx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	e8 64 fe ff ff       	call   10d <putc>
          s++;
 2a9:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2ac:	0f b6 16             	movzbl (%esi),%edx
 2af:	84 d2                	test   %dl,%dl
 2b1:	75 eb                	jne    29e <printf+0xec>
      state = 0;
 2b3:	be 00 00 00 00       	mov    $0x0,%esi
 2b8:	e9 21 ff ff ff       	jmp    1de <printf+0x2c>
        putc(fd, *ap);
 2bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2c0:	0f be 17             	movsbl (%edi),%edx
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	e8 42 fe ff ff       	call   10d <putc>
        ap++;
 2cb:	83 c7 04             	add    $0x4,%edi
 2ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2d1:	be 00 00 00 00       	mov    $0x0,%esi
 2d6:	e9 03 ff ff ff       	jmp    1de <printf+0x2c>
        putc(fd, c);
 2db:	89 fa                	mov    %edi,%edx
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	e8 28 fe ff ff       	call   10d <putc>
      state = 0;
 2e5:	be 00 00 00 00       	mov    $0x0,%esi
 2ea:	e9 ef fe ff ff       	jmp    1de <printf+0x2c>
        putc(fd, '%');
 2ef:	ba 25 00 00 00       	mov    $0x25,%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	e8 11 fe ff ff       	call   10d <putc>
        putc(fd, c);
 2fc:	89 fa                	mov    %edi,%edx
 2fe:	8b 45 08             	mov    0x8(%ebp),%eax
 301:	e8 07 fe ff ff       	call   10d <putc>
      state = 0;
 306:	be 00 00 00 00       	mov    $0x0,%esi
 30b:	e9 ce fe ff ff       	jmp    1de <printf+0x2c>
    }
  }
}
 310:	8d 65 f4             	lea    -0xc(%ebp),%esp
 313:	5b                   	pop    %ebx
 314:	5e                   	pop    %esi
 315:	5f                   	pop    %edi
 316:	5d                   	pop    %ebp
 317:	c3                   	ret    
