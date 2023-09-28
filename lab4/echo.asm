
_echo:     file format elf32-i386


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
  11:	83 ec 08             	sub    $0x8,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  for(i = 1; i < argc; i++)
  19:	b8 01 00 00 00       	mov    $0x1,%eax
  1e:	eb 1a                	jmp    3a <main+0x3a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  20:	ba 36 03 00 00       	mov    $0x336,%edx
  25:	52                   	push   %edx
  26:	ff 34 87             	push   (%edi,%eax,4)
  29:	68 38 03 00 00       	push   $0x338
  2e:	6a 01                	push   $0x1
  30:	e8 99 01 00 00       	call   1ce <printf>
  35:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  38:	89 d8                	mov    %ebx,%eax
  3a:	39 f0                	cmp    %esi,%eax
  3c:	7d 0e                	jge    4c <main+0x4c>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  3e:	8d 58 01             	lea    0x1(%eax),%ebx
  41:	39 f3                	cmp    %esi,%ebx
  43:	7d db                	jge    20 <main+0x20>
  45:	ba 34 03 00 00       	mov    $0x334,%edx
  4a:	eb d9                	jmp    25 <main+0x25>
  exit();
  4c:	e8 08 00 00 00       	call   59 <exit>

00000051 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  51:	b8 01 00 00 00       	mov    $0x1,%eax
  56:	cd 40                	int    $0x40
  58:	c3                   	ret    

00000059 <exit>:
SYSCALL(exit)
  59:	b8 02 00 00 00       	mov    $0x2,%eax
  5e:	cd 40                	int    $0x40
  60:	c3                   	ret    

00000061 <wait>:
SYSCALL(wait)
  61:	b8 03 00 00 00       	mov    $0x3,%eax
  66:	cd 40                	int    $0x40
  68:	c3                   	ret    

00000069 <pipe>:
SYSCALL(pipe)
  69:	b8 04 00 00 00       	mov    $0x4,%eax
  6e:	cd 40                	int    $0x40
  70:	c3                   	ret    

00000071 <read>:
SYSCALL(read)
  71:	b8 05 00 00 00       	mov    $0x5,%eax
  76:	cd 40                	int    $0x40
  78:	c3                   	ret    

00000079 <write>:
SYSCALL(write)
  79:	b8 10 00 00 00       	mov    $0x10,%eax
  7e:	cd 40                	int    $0x40
  80:	c3                   	ret    

00000081 <close>:
SYSCALL(close)
  81:	b8 15 00 00 00       	mov    $0x15,%eax
  86:	cd 40                	int    $0x40
  88:	c3                   	ret    

00000089 <kill>:
SYSCALL(kill)
  89:	b8 06 00 00 00       	mov    $0x6,%eax
  8e:	cd 40                	int    $0x40
  90:	c3                   	ret    

00000091 <exec>:
SYSCALL(exec)
  91:	b8 07 00 00 00       	mov    $0x7,%eax
  96:	cd 40                	int    $0x40
  98:	c3                   	ret    

00000099 <open>:
SYSCALL(open)
  99:	b8 0f 00 00 00       	mov    $0xf,%eax
  9e:	cd 40                	int    $0x40
  a0:	c3                   	ret    

000000a1 <mknod>:
SYSCALL(mknod)
  a1:	b8 11 00 00 00       	mov    $0x11,%eax
  a6:	cd 40                	int    $0x40
  a8:	c3                   	ret    

000000a9 <unlink>:
SYSCALL(unlink)
  a9:	b8 12 00 00 00       	mov    $0x12,%eax
  ae:	cd 40                	int    $0x40
  b0:	c3                   	ret    

000000b1 <fstat>:
SYSCALL(fstat)
  b1:	b8 08 00 00 00       	mov    $0x8,%eax
  b6:	cd 40                	int    $0x40
  b8:	c3                   	ret    

000000b9 <link>:
SYSCALL(link)
  b9:	b8 13 00 00 00       	mov    $0x13,%eax
  be:	cd 40                	int    $0x40
  c0:	c3                   	ret    

000000c1 <mkdir>:
SYSCALL(mkdir)
  c1:	b8 14 00 00 00       	mov    $0x14,%eax
  c6:	cd 40                	int    $0x40
  c8:	c3                   	ret    

000000c9 <chdir>:
SYSCALL(chdir)
  c9:	b8 09 00 00 00       	mov    $0x9,%eax
  ce:	cd 40                	int    $0x40
  d0:	c3                   	ret    

000000d1 <dup>:
SYSCALL(dup)
  d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  d6:	cd 40                	int    $0x40
  d8:	c3                   	ret    

000000d9 <getpid>:
SYSCALL(getpid)
  d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  de:	cd 40                	int    $0x40
  e0:	c3                   	ret    

000000e1 <sbrk>:
SYSCALL(sbrk)
  e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  e6:	cd 40                	int    $0x40
  e8:	c3                   	ret    

000000e9 <sleep>:
SYSCALL(sleep)
  e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <uptime>:
SYSCALL(uptime)
  f1:	b8 0e 00 00 00       	mov    $0xe,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <yield>:
SYSCALL(yield)
  f9:	b8 16 00 00 00       	mov    $0x16,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <shutdown>:
SYSCALL(shutdown)
 101:	b8 17 00 00 00       	mov    $0x17,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <writecount>:
SYSCALL(writecount)
 109:	b8 18 00 00 00       	mov    $0x18,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <setwritecount>:
SYSCALL(setwritecount)
 111:	b8 19 00 00 00       	mov    $0x19,%eax
 116:	cd 40                	int    $0x40
 118:	c3                   	ret    

00000119 <settickets>:
SYSCALL(settickets)
 119:	b8 1a 00 00 00       	mov    $0x1a,%eax
 11e:	cd 40                	int    $0x40
 120:	c3                   	ret    

00000121 <getprocessesinfo>:
 121:	b8 1b 00 00 00       	mov    $0x1b,%eax
 126:	cd 40                	int    $0x40
 128:	c3                   	ret    

00000129 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 129:	55                   	push   %ebp
 12a:	89 e5                	mov    %esp,%ebp
 12c:	83 ec 1c             	sub    $0x1c,%esp
 12f:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 132:	6a 01                	push   $0x1
 134:	8d 55 f4             	lea    -0xc(%ebp),%edx
 137:	52                   	push   %edx
 138:	50                   	push   %eax
 139:	e8 3b ff ff ff       	call   79 <write>
}
 13e:	83 c4 10             	add    $0x10,%esp
 141:	c9                   	leave  
 142:	c3                   	ret    

00000143 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	57                   	push   %edi
 147:	56                   	push   %esi
 148:	53                   	push   %ebx
 149:	83 ec 2c             	sub    $0x2c,%esp
 14c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 14f:	89 d0                	mov    %edx,%eax
 151:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 153:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 157:	0f 95 c1             	setne  %cl
 15a:	c1 ea 1f             	shr    $0x1f,%edx
 15d:	84 d1                	test   %dl,%cl
 15f:	74 44                	je     1a5 <printint+0x62>
    neg = 1;
    x = -xx;
 161:	f7 d8                	neg    %eax
 163:	89 c1                	mov    %eax,%ecx
    neg = 1;
 165:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 16c:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 171:	89 c8                	mov    %ecx,%eax
 173:	ba 00 00 00 00       	mov    $0x0,%edx
 178:	f7 f6                	div    %esi
 17a:	89 df                	mov    %ebx,%edi
 17c:	83 c3 01             	add    $0x1,%ebx
 17f:	0f b6 92 9c 03 00 00 	movzbl 0x39c(%edx),%edx
 186:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 18a:	89 ca                	mov    %ecx,%edx
 18c:	89 c1                	mov    %eax,%ecx
 18e:	39 d6                	cmp    %edx,%esi
 190:	76 df                	jbe    171 <printint+0x2e>
  if(neg)
 192:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 196:	74 31                	je     1c9 <printint+0x86>
    buf[i++] = '-';
 198:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 19d:	8d 5f 02             	lea    0x2(%edi),%ebx
 1a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1a3:	eb 17                	jmp    1bc <printint+0x79>
    x = xx;
 1a5:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1ae:	eb bc                	jmp    16c <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1b0:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1b5:	89 f0                	mov    %esi,%eax
 1b7:	e8 6d ff ff ff       	call   129 <putc>
  while(--i >= 0)
 1bc:	83 eb 01             	sub    $0x1,%ebx
 1bf:	79 ef                	jns    1b0 <printint+0x6d>
}
 1c1:	83 c4 2c             	add    $0x2c,%esp
 1c4:	5b                   	pop    %ebx
 1c5:	5e                   	pop    %esi
 1c6:	5f                   	pop    %edi
 1c7:	5d                   	pop    %ebp
 1c8:	c3                   	ret    
 1c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1cc:	eb ee                	jmp    1bc <printint+0x79>

000001ce <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
 1d1:	57                   	push   %edi
 1d2:	56                   	push   %esi
 1d3:	53                   	push   %ebx
 1d4:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1d7:	8d 45 10             	lea    0x10(%ebp),%eax
 1da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1dd:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1e2:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e7:	eb 14                	jmp    1fd <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 1e9:	89 fa                	mov    %edi,%edx
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ee:	e8 36 ff ff ff       	call   129 <putc>
 1f3:	eb 05                	jmp    1fa <printf+0x2c>
      }
    } else if(state == '%'){
 1f5:	83 fe 25             	cmp    $0x25,%esi
 1f8:	74 25                	je     21f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 1fa:	83 c3 01             	add    $0x1,%ebx
 1fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 200:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 204:	84 c0                	test   %al,%al
 206:	0f 84 20 01 00 00    	je     32c <printf+0x15e>
    c = fmt[i] & 0xff;
 20c:	0f be f8             	movsbl %al,%edi
 20f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 212:	85 f6                	test   %esi,%esi
 214:	75 df                	jne    1f5 <printf+0x27>
      if(c == '%'){
 216:	83 f8 25             	cmp    $0x25,%eax
 219:	75 ce                	jne    1e9 <printf+0x1b>
        state = '%';
 21b:	89 c6                	mov    %eax,%esi
 21d:	eb db                	jmp    1fa <printf+0x2c>
      if(c == 'd'){
 21f:	83 f8 25             	cmp    $0x25,%eax
 222:	0f 84 cf 00 00 00    	je     2f7 <printf+0x129>
 228:	0f 8c dd 00 00 00    	jl     30b <printf+0x13d>
 22e:	83 f8 78             	cmp    $0x78,%eax
 231:	0f 8f d4 00 00 00    	jg     30b <printf+0x13d>
 237:	83 f8 63             	cmp    $0x63,%eax
 23a:	0f 8c cb 00 00 00    	jl     30b <printf+0x13d>
 240:	83 e8 63             	sub    $0x63,%eax
 243:	83 f8 15             	cmp    $0x15,%eax
 246:	0f 87 bf 00 00 00    	ja     30b <printf+0x13d>
 24c:	ff 24 85 44 03 00 00 	jmp    *0x344(,%eax,4)
        printint(fd, *ap, 10, 1);
 253:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 256:	8b 17                	mov    (%edi),%edx
 258:	83 ec 0c             	sub    $0xc,%esp
 25b:	6a 01                	push   $0x1
 25d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	e8 d9 fe ff ff       	call   143 <printint>
        ap++;
 26a:	83 c7 04             	add    $0x4,%edi
 26d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 270:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 273:	be 00 00 00 00       	mov    $0x0,%esi
 278:	eb 80                	jmp    1fa <printf+0x2c>
        printint(fd, *ap, 16, 0);
 27a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 27d:	8b 17                	mov    (%edi),%edx
 27f:	83 ec 0c             	sub    $0xc,%esp
 282:	6a 00                	push   $0x0
 284:	b9 10 00 00 00       	mov    $0x10,%ecx
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	e8 b2 fe ff ff       	call   143 <printint>
        ap++;
 291:	83 c7 04             	add    $0x4,%edi
 294:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 297:	83 c4 10             	add    $0x10,%esp
      state = 0;
 29a:	be 00 00 00 00       	mov    $0x0,%esi
 29f:	e9 56 ff ff ff       	jmp    1fa <printf+0x2c>
        s = (char*)*ap;
 2a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2a7:	8b 30                	mov    (%eax),%esi
        ap++;
 2a9:	83 c0 04             	add    $0x4,%eax
 2ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2af:	85 f6                	test   %esi,%esi
 2b1:	75 15                	jne    2c8 <printf+0xfa>
          s = "(null)";
 2b3:	be 3d 03 00 00       	mov    $0x33d,%esi
 2b8:	eb 0e                	jmp    2c8 <printf+0xfa>
          putc(fd, *s);
 2ba:	0f be d2             	movsbl %dl,%edx
 2bd:	8b 45 08             	mov    0x8(%ebp),%eax
 2c0:	e8 64 fe ff ff       	call   129 <putc>
          s++;
 2c5:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2c8:	0f b6 16             	movzbl (%esi),%edx
 2cb:	84 d2                	test   %dl,%dl
 2cd:	75 eb                	jne    2ba <printf+0xec>
      state = 0;
 2cf:	be 00 00 00 00       	mov    $0x0,%esi
 2d4:	e9 21 ff ff ff       	jmp    1fa <printf+0x2c>
        putc(fd, *ap);
 2d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2dc:	0f be 17             	movsbl (%edi),%edx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	e8 42 fe ff ff       	call   129 <putc>
        ap++;
 2e7:	83 c7 04             	add    $0x4,%edi
 2ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 2ed:	be 00 00 00 00       	mov    $0x0,%esi
 2f2:	e9 03 ff ff ff       	jmp    1fa <printf+0x2c>
        putc(fd, c);
 2f7:	89 fa                	mov    %edi,%edx
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	e8 28 fe ff ff       	call   129 <putc>
      state = 0;
 301:	be 00 00 00 00       	mov    $0x0,%esi
 306:	e9 ef fe ff ff       	jmp    1fa <printf+0x2c>
        putc(fd, '%');
 30b:	ba 25 00 00 00       	mov    $0x25,%edx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	e8 11 fe ff ff       	call   129 <putc>
        putc(fd, c);
 318:	89 fa                	mov    %edi,%edx
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	e8 07 fe ff ff       	call   129 <putc>
      state = 0;
 322:	be 00 00 00 00       	mov    $0x0,%esi
 327:	e9 ce fe ff ff       	jmp    1fa <printf+0x2c>
    }
  }
}
 32c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 32f:	5b                   	pop    %ebx
 330:	5e                   	pop    %esi
 331:	5f                   	pop    %edi
 332:	5d                   	pop    %ebp
 333:	c3                   	ret    
