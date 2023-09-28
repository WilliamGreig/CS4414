
_rm:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 39                	mov    (%ecx),%edi
  16:	8b 41 04             	mov    0x4(%ecx),%eax
  19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int i;

  if(argc < 2){
  1c:	83 ff 01             	cmp    $0x1,%edi
  1f:	7e 07                	jle    28 <main+0x28>
    printf(2, "Usage: rm files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  21:	bb 01 00 00 00       	mov    $0x1,%ebx
  26:	eb 17                	jmp    3f <main+0x3f>
    printf(2, "Usage: rm files...\n");
  28:	83 ec 08             	sub    $0x8,%esp
  2b:	68 58 03 00 00       	push   $0x358
  30:	6a 02                	push   $0x2
  32:	e8 b9 01 00 00       	call   1f0 <printf>
    exit();
  37:	e8 3f 00 00 00       	call   7b <exit>
  for(i = 1; i < argc; i++){
  3c:	83 c3 01             	add    $0x1,%ebx
  3f:	39 fb                	cmp    %edi,%ebx
  41:	7d 2b                	jge    6e <main+0x6e>
    if(unlink(argv[i]) < 0){
  43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  46:	8d 34 98             	lea    (%eax,%ebx,4),%esi
  49:	83 ec 0c             	sub    $0xc,%esp
  4c:	ff 36                	push   (%esi)
  4e:	e8 78 00 00 00       	call   cb <unlink>
  53:	83 c4 10             	add    $0x10,%esp
  56:	85 c0                	test   %eax,%eax
  58:	79 e2                	jns    3c <main+0x3c>
      printf(2, "rm: %s failed to delete\n", argv[i]);
  5a:	83 ec 04             	sub    $0x4,%esp
  5d:	ff 36                	push   (%esi)
  5f:	68 6c 03 00 00       	push   $0x36c
  64:	6a 02                	push   $0x2
  66:	e8 85 01 00 00       	call   1f0 <printf>
      break;
  6b:	83 c4 10             	add    $0x10,%esp
    }
  }

  exit();
  6e:	e8 08 00 00 00       	call   7b <exit>

00000073 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  73:	b8 01 00 00 00       	mov    $0x1,%eax
  78:	cd 40                	int    $0x40
  7a:	c3                   	ret    

0000007b <exit>:
SYSCALL(exit)
  7b:	b8 02 00 00 00       	mov    $0x2,%eax
  80:	cd 40                	int    $0x40
  82:	c3                   	ret    

00000083 <wait>:
SYSCALL(wait)
  83:	b8 03 00 00 00       	mov    $0x3,%eax
  88:	cd 40                	int    $0x40
  8a:	c3                   	ret    

0000008b <pipe>:
SYSCALL(pipe)
  8b:	b8 04 00 00 00       	mov    $0x4,%eax
  90:	cd 40                	int    $0x40
  92:	c3                   	ret    

00000093 <read>:
SYSCALL(read)
  93:	b8 05 00 00 00       	mov    $0x5,%eax
  98:	cd 40                	int    $0x40
  9a:	c3                   	ret    

0000009b <write>:
SYSCALL(write)
  9b:	b8 10 00 00 00       	mov    $0x10,%eax
  a0:	cd 40                	int    $0x40
  a2:	c3                   	ret    

000000a3 <close>:
SYSCALL(close)
  a3:	b8 15 00 00 00       	mov    $0x15,%eax
  a8:	cd 40                	int    $0x40
  aa:	c3                   	ret    

000000ab <kill>:
SYSCALL(kill)
  ab:	b8 06 00 00 00       	mov    $0x6,%eax
  b0:	cd 40                	int    $0x40
  b2:	c3                   	ret    

000000b3 <exec>:
SYSCALL(exec)
  b3:	b8 07 00 00 00       	mov    $0x7,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <open>:
SYSCALL(open)
  bb:	b8 0f 00 00 00       	mov    $0xf,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <mknod>:
SYSCALL(mknod)
  c3:	b8 11 00 00 00       	mov    $0x11,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <unlink>:
SYSCALL(unlink)
  cb:	b8 12 00 00 00       	mov    $0x12,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <fstat>:
SYSCALL(fstat)
  d3:	b8 08 00 00 00       	mov    $0x8,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <link>:
SYSCALL(link)
  db:	b8 13 00 00 00       	mov    $0x13,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <mkdir>:
SYSCALL(mkdir)
  e3:	b8 14 00 00 00       	mov    $0x14,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <chdir>:
SYSCALL(chdir)
  eb:	b8 09 00 00 00       	mov    $0x9,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    

000000f3 <dup>:
SYSCALL(dup)
  f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <getpid>:
SYSCALL(getpid)
  fb:	b8 0b 00 00 00       	mov    $0xb,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <sbrk>:
SYSCALL(sbrk)
 103:	b8 0c 00 00 00       	mov    $0xc,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <sleep>:
SYSCALL(sleep)
 10b:	b8 0d 00 00 00       	mov    $0xd,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <uptime>:
SYSCALL(uptime)
 113:	b8 0e 00 00 00       	mov    $0xe,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <yield>:
SYSCALL(yield)
 11b:	b8 16 00 00 00       	mov    $0x16,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <shutdown>:
SYSCALL(shutdown)
 123:	b8 17 00 00 00       	mov    $0x17,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <writecount>:
SYSCALL(writecount)
 12b:	b8 18 00 00 00       	mov    $0x18,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <setwritecount>:
SYSCALL(setwritecount)
 133:	b8 19 00 00 00       	mov    $0x19,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <settickets>:
SYSCALL(settickets)
 13b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <getprocessesinfo>:
 143:	b8 1b 00 00 00       	mov    $0x1b,%eax
 148:	cd 40                	int    $0x40
 14a:	c3                   	ret    

0000014b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 1c             	sub    $0x1c,%esp
 151:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 154:	6a 01                	push   $0x1
 156:	8d 55 f4             	lea    -0xc(%ebp),%edx
 159:	52                   	push   %edx
 15a:	50                   	push   %eax
 15b:	e8 3b ff ff ff       	call   9b <write>
}
 160:	83 c4 10             	add    $0x10,%esp
 163:	c9                   	leave  
 164:	c3                   	ret    

00000165 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 165:	55                   	push   %ebp
 166:	89 e5                	mov    %esp,%ebp
 168:	57                   	push   %edi
 169:	56                   	push   %esi
 16a:	53                   	push   %ebx
 16b:	83 ec 2c             	sub    $0x2c,%esp
 16e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 171:	89 d0                	mov    %edx,%eax
 173:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 175:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 179:	0f 95 c1             	setne  %cl
 17c:	c1 ea 1f             	shr    $0x1f,%edx
 17f:	84 d1                	test   %dl,%cl
 181:	74 44                	je     1c7 <printint+0x62>
    neg = 1;
    x = -xx;
 183:	f7 d8                	neg    %eax
 185:	89 c1                	mov    %eax,%ecx
    neg = 1;
 187:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 18e:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 193:	89 c8                	mov    %ecx,%eax
 195:	ba 00 00 00 00       	mov    $0x0,%edx
 19a:	f7 f6                	div    %esi
 19c:	89 df                	mov    %ebx,%edi
 19e:	83 c3 01             	add    $0x1,%ebx
 1a1:	0f b6 92 e4 03 00 00 	movzbl 0x3e4(%edx),%edx
 1a8:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1ac:	89 ca                	mov    %ecx,%edx
 1ae:	89 c1                	mov    %eax,%ecx
 1b0:	39 d6                	cmp    %edx,%esi
 1b2:	76 df                	jbe    193 <printint+0x2e>
  if(neg)
 1b4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1b8:	74 31                	je     1eb <printint+0x86>
    buf[i++] = '-';
 1ba:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1bf:	8d 5f 02             	lea    0x2(%edi),%ebx
 1c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1c5:	eb 17                	jmp    1de <printint+0x79>
    x = xx;
 1c7:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1d0:	eb bc                	jmp    18e <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1d2:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1d7:	89 f0                	mov    %esi,%eax
 1d9:	e8 6d ff ff ff       	call   14b <putc>
  while(--i >= 0)
 1de:	83 eb 01             	sub    $0x1,%ebx
 1e1:	79 ef                	jns    1d2 <printint+0x6d>
}
 1e3:	83 c4 2c             	add    $0x2c,%esp
 1e6:	5b                   	pop    %ebx
 1e7:	5e                   	pop    %esi
 1e8:	5f                   	pop    %edi
 1e9:	5d                   	pop    %ebp
 1ea:	c3                   	ret    
 1eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1ee:	eb ee                	jmp    1de <printint+0x79>

000001f0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	57                   	push   %edi
 1f4:	56                   	push   %esi
 1f5:	53                   	push   %ebx
 1f6:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1f9:	8d 45 10             	lea    0x10(%ebp),%eax
 1fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1ff:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 204:	bb 00 00 00 00       	mov    $0x0,%ebx
 209:	eb 14                	jmp    21f <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 20b:	89 fa                	mov    %edi,%edx
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	e8 36 ff ff ff       	call   14b <putc>
 215:	eb 05                	jmp    21c <printf+0x2c>
      }
    } else if(state == '%'){
 217:	83 fe 25             	cmp    $0x25,%esi
 21a:	74 25                	je     241 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 21c:	83 c3 01             	add    $0x1,%ebx
 21f:	8b 45 0c             	mov    0xc(%ebp),%eax
 222:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 226:	84 c0                	test   %al,%al
 228:	0f 84 20 01 00 00    	je     34e <printf+0x15e>
    c = fmt[i] & 0xff;
 22e:	0f be f8             	movsbl %al,%edi
 231:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 234:	85 f6                	test   %esi,%esi
 236:	75 df                	jne    217 <printf+0x27>
      if(c == '%'){
 238:	83 f8 25             	cmp    $0x25,%eax
 23b:	75 ce                	jne    20b <printf+0x1b>
        state = '%';
 23d:	89 c6                	mov    %eax,%esi
 23f:	eb db                	jmp    21c <printf+0x2c>
      if(c == 'd'){
 241:	83 f8 25             	cmp    $0x25,%eax
 244:	0f 84 cf 00 00 00    	je     319 <printf+0x129>
 24a:	0f 8c dd 00 00 00    	jl     32d <printf+0x13d>
 250:	83 f8 78             	cmp    $0x78,%eax
 253:	0f 8f d4 00 00 00    	jg     32d <printf+0x13d>
 259:	83 f8 63             	cmp    $0x63,%eax
 25c:	0f 8c cb 00 00 00    	jl     32d <printf+0x13d>
 262:	83 e8 63             	sub    $0x63,%eax
 265:	83 f8 15             	cmp    $0x15,%eax
 268:	0f 87 bf 00 00 00    	ja     32d <printf+0x13d>
 26e:	ff 24 85 8c 03 00 00 	jmp    *0x38c(,%eax,4)
        printint(fd, *ap, 10, 1);
 275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 278:	8b 17                	mov    (%edi),%edx
 27a:	83 ec 0c             	sub    $0xc,%esp
 27d:	6a 01                	push   $0x1
 27f:	b9 0a 00 00 00       	mov    $0xa,%ecx
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	e8 d9 fe ff ff       	call   165 <printint>
        ap++;
 28c:	83 c7 04             	add    $0x4,%edi
 28f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 292:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 295:	be 00 00 00 00       	mov    $0x0,%esi
 29a:	eb 80                	jmp    21c <printf+0x2c>
        printint(fd, *ap, 16, 0);
 29c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 29f:	8b 17                	mov    (%edi),%edx
 2a1:	83 ec 0c             	sub    $0xc,%esp
 2a4:	6a 00                	push   $0x0
 2a6:	b9 10 00 00 00       	mov    $0x10,%ecx
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	e8 b2 fe ff ff       	call   165 <printint>
        ap++;
 2b3:	83 c7 04             	add    $0x4,%edi
 2b6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2b9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2bc:	be 00 00 00 00       	mov    $0x0,%esi
 2c1:	e9 56 ff ff ff       	jmp    21c <printf+0x2c>
        s = (char*)*ap;
 2c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2c9:	8b 30                	mov    (%eax),%esi
        ap++;
 2cb:	83 c0 04             	add    $0x4,%eax
 2ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2d1:	85 f6                	test   %esi,%esi
 2d3:	75 15                	jne    2ea <printf+0xfa>
          s = "(null)";
 2d5:	be 85 03 00 00       	mov    $0x385,%esi
 2da:	eb 0e                	jmp    2ea <printf+0xfa>
          putc(fd, *s);
 2dc:	0f be d2             	movsbl %dl,%edx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	e8 64 fe ff ff       	call   14b <putc>
          s++;
 2e7:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2ea:	0f b6 16             	movzbl (%esi),%edx
 2ed:	84 d2                	test   %dl,%dl
 2ef:	75 eb                	jne    2dc <printf+0xec>
      state = 0;
 2f1:	be 00 00 00 00       	mov    $0x0,%esi
 2f6:	e9 21 ff ff ff       	jmp    21c <printf+0x2c>
        putc(fd, *ap);
 2fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2fe:	0f be 17             	movsbl (%edi),%edx
 301:	8b 45 08             	mov    0x8(%ebp),%eax
 304:	e8 42 fe ff ff       	call   14b <putc>
        ap++;
 309:	83 c7 04             	add    $0x4,%edi
 30c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 30f:	be 00 00 00 00       	mov    $0x0,%esi
 314:	e9 03 ff ff ff       	jmp    21c <printf+0x2c>
        putc(fd, c);
 319:	89 fa                	mov    %edi,%edx
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	e8 28 fe ff ff       	call   14b <putc>
      state = 0;
 323:	be 00 00 00 00       	mov    $0x0,%esi
 328:	e9 ef fe ff ff       	jmp    21c <printf+0x2c>
        putc(fd, '%');
 32d:	ba 25 00 00 00       	mov    $0x25,%edx
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	e8 11 fe ff ff       	call   14b <putc>
        putc(fd, c);
 33a:	89 fa                	mov    %edi,%edx
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	e8 07 fe ff ff       	call   14b <putc>
      state = 0;
 344:	be 00 00 00 00       	mov    $0x0,%esi
 349:	e9 ce fe ff ff       	jmp    21c <printf+0x2c>
    }
  }
}
 34e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 351:	5b                   	pop    %ebx
 352:	5e                   	pop    %esi
 353:	5f                   	pop    %edi
 354:	5d                   	pop    %ebp
 355:	c3                   	ret    
