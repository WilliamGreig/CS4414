
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 10             	sub    $0x10,%esp
   a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(argc != 3){
   d:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  11:	74 19                	je     2c <main+0x2c>
    printf(2, "Usage: ln old new\n");
  13:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
  1a:	00 
  1b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  22:	e8 d5 01 00 00       	call   1fc <printf>
    exit();
  27:	e8 45 00 00 00       	call   71 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2c:	8b 43 08             	mov    0x8(%ebx),%eax
  2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  33:	8b 43 04             	mov    0x4(%ebx),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 93 00 00 00       	call   d1 <link>
  3e:	85 c0                	test   %eax,%eax
  40:	79 22                	jns    64 <main+0x64>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  42:	8b 43 08             	mov    0x8(%ebx),%eax
  45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  49:	8b 43 04             	mov    0x4(%ebx),%eax
  4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  50:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
  57:	00 
  58:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  5f:	e8 98 01 00 00       	call   1fc <printf>
  exit();
  64:	e8 08 00 00 00       	call   71 <exit>

00000069 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  69:	b8 01 00 00 00       	mov    $0x1,%eax
  6e:	cd 40                	int    $0x40
  70:	c3                   	ret    

00000071 <exit>:
SYSCALL(exit)
  71:	b8 02 00 00 00       	mov    $0x2,%eax
  76:	cd 40                	int    $0x40
  78:	c3                   	ret    

00000079 <wait>:
SYSCALL(wait)
  79:	b8 03 00 00 00       	mov    $0x3,%eax
  7e:	cd 40                	int    $0x40
  80:	c3                   	ret    

00000081 <pipe>:
SYSCALL(pipe)
  81:	b8 04 00 00 00       	mov    $0x4,%eax
  86:	cd 40                	int    $0x40
  88:	c3                   	ret    

00000089 <read>:
SYSCALL(read)
  89:	b8 05 00 00 00       	mov    $0x5,%eax
  8e:	cd 40                	int    $0x40
  90:	c3                   	ret    

00000091 <write>:
SYSCALL(write)
  91:	b8 10 00 00 00       	mov    $0x10,%eax
  96:	cd 40                	int    $0x40
  98:	c3                   	ret    

00000099 <close>:
SYSCALL(close)
  99:	b8 15 00 00 00       	mov    $0x15,%eax
  9e:	cd 40                	int    $0x40
  a0:	c3                   	ret    

000000a1 <kill>:
SYSCALL(kill)
  a1:	b8 06 00 00 00       	mov    $0x6,%eax
  a6:	cd 40                	int    $0x40
  a8:	c3                   	ret    

000000a9 <exec>:
SYSCALL(exec)
  a9:	b8 07 00 00 00       	mov    $0x7,%eax
  ae:	cd 40                	int    $0x40
  b0:	c3                   	ret    

000000b1 <open>:
SYSCALL(open)
  b1:	b8 0f 00 00 00       	mov    $0xf,%eax
  b6:	cd 40                	int    $0x40
  b8:	c3                   	ret    

000000b9 <mknod>:
SYSCALL(mknod)
  b9:	b8 11 00 00 00       	mov    $0x11,%eax
  be:	cd 40                	int    $0x40
  c0:	c3                   	ret    

000000c1 <unlink>:
SYSCALL(unlink)
  c1:	b8 12 00 00 00       	mov    $0x12,%eax
  c6:	cd 40                	int    $0x40
  c8:	c3                   	ret    

000000c9 <fstat>:
SYSCALL(fstat)
  c9:	b8 08 00 00 00       	mov    $0x8,%eax
  ce:	cd 40                	int    $0x40
  d0:	c3                   	ret    

000000d1 <link>:
SYSCALL(link)
  d1:	b8 13 00 00 00       	mov    $0x13,%eax
  d6:	cd 40                	int    $0x40
  d8:	c3                   	ret    

000000d9 <mkdir>:
SYSCALL(mkdir)
  d9:	b8 14 00 00 00       	mov    $0x14,%eax
  de:	cd 40                	int    $0x40
  e0:	c3                   	ret    

000000e1 <chdir>:
SYSCALL(chdir)
  e1:	b8 09 00 00 00       	mov    $0x9,%eax
  e6:	cd 40                	int    $0x40
  e8:	c3                   	ret    

000000e9 <dup>:
SYSCALL(dup)
  e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  ee:	cd 40                	int    $0x40
  f0:	c3                   	ret    

000000f1 <getpid>:
SYSCALL(getpid)
  f1:	b8 0b 00 00 00       	mov    $0xb,%eax
  f6:	cd 40                	int    $0x40
  f8:	c3                   	ret    

000000f9 <sbrk>:
SYSCALL(sbrk)
  f9:	b8 0c 00 00 00       	mov    $0xc,%eax
  fe:	cd 40                	int    $0x40
 100:	c3                   	ret    

00000101 <sleep>:
SYSCALL(sleep)
 101:	b8 0d 00 00 00       	mov    $0xd,%eax
 106:	cd 40                	int    $0x40
 108:	c3                   	ret    

00000109 <uptime>:
SYSCALL(uptime)
 109:	b8 0e 00 00 00       	mov    $0xe,%eax
 10e:	cd 40                	int    $0x40
 110:	c3                   	ret    

00000111 <yield>:
SYSCALL(yield)
 111:	b8 16 00 00 00       	mov    $0x16,%eax
 116:	cd 40                	int    $0x40
 118:	c3                   	ret    

00000119 <shutdown>:
SYSCALL(shutdown)
 119:	b8 17 00 00 00       	mov    $0x17,%eax
 11e:	cd 40                	int    $0x40
 120:	c3                   	ret    

00000121 <writecount>:
SYSCALL(writecount)
 121:	b8 18 00 00 00       	mov    $0x18,%eax
 126:	cd 40                	int    $0x40
 128:	c3                   	ret    

00000129 <setwritecount>:
SYSCALL(setwritecount)
 129:	b8 19 00 00 00       	mov    $0x19,%eax
 12e:	cd 40                	int    $0x40
 130:	c3                   	ret    

00000131 <settickets>:
SYSCALL(settickets)
 131:	b8 1a 00 00 00       	mov    $0x1a,%eax
 136:	cd 40                	int    $0x40
 138:	c3                   	ret    

00000139 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 139:	b8 1b 00 00 00       	mov    $0x1b,%eax
 13e:	cd 40                	int    $0x40
 140:	c3                   	ret    

00000141 <getpagetableentry>:
SYSCALL(getpagetableentry)
 141:	b8 1c 00 00 00       	mov    $0x1c,%eax
 146:	cd 40                	int    $0x40
 148:	c3                   	ret    

00000149 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 149:	b8 1d 00 00 00       	mov    $0x1d,%eax
 14e:	cd 40                	int    $0x40
 150:	c3                   	ret    

00000151 <dumppagetable>:
 151:	b8 1e 00 00 00       	mov    $0x1e,%eax
 156:	cd 40                	int    $0x40
 158:	c3                   	ret    
 159:	66 90                	xchg   %ax,%ax
 15b:	66 90                	xchg   %ax,%ax
 15d:	66 90                	xchg   %ax,%ax
 15f:	90                   	nop

00000160 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 18             	sub    $0x18,%esp
 166:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 169:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 170:	00 
 171:	8d 55 f4             	lea    -0xc(%ebp),%edx
 174:	89 54 24 04          	mov    %edx,0x4(%esp)
 178:	89 04 24             	mov    %eax,(%esp)
 17b:	e8 11 ff ff ff       	call   91 <write>
}
 180:	c9                   	leave  
 181:	c3                   	ret    

00000182 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	57                   	push   %edi
 186:	56                   	push   %esi
 187:	53                   	push   %ebx
 188:	83 ec 2c             	sub    $0x2c,%esp
 18b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 18d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 191:	0f 95 c3             	setne  %bl
 194:	89 d0                	mov    %edx,%eax
 196:	c1 e8 1f             	shr    $0x1f,%eax
 199:	84 c3                	test   %al,%bl
 19b:	74 0b                	je     1a8 <printint+0x26>
    neg = 1;
    x = -xx;
 19d:	f7 da                	neg    %edx
    neg = 1;
 19f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 1a6:	eb 07                	jmp    1af <printint+0x2d>
  neg = 0;
 1a8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1af:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 1b4:	8d 5e 01             	lea    0x1(%esi),%ebx
 1b7:	89 d0                	mov    %edx,%eax
 1b9:	ba 00 00 00 00       	mov    $0x0,%edx
 1be:	f7 f1                	div    %ecx
 1c0:	0f b6 92 83 03 00 00 	movzbl 0x383(%edx),%edx
 1c7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 1cb:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 1cd:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 1cf:	85 c0                	test   %eax,%eax
 1d1:	75 e1                	jne    1b4 <printint+0x32>
  if(neg)
 1d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1d7:	74 16                	je     1ef <printint+0x6d>
    buf[i++] = '-';
 1d9:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1de:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1e1:	eb 0c                	jmp    1ef <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 1e3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1e8:	89 f8                	mov    %edi,%eax
 1ea:	e8 71 ff ff ff       	call   160 <putc>
  while(--i >= 0)
 1ef:	83 eb 01             	sub    $0x1,%ebx
 1f2:	79 ef                	jns    1e3 <printint+0x61>
}
 1f4:	83 c4 2c             	add    $0x2c,%esp
 1f7:	5b                   	pop    %ebx
 1f8:	5e                   	pop    %esi
 1f9:	5f                   	pop    %edi
 1fa:	5d                   	pop    %ebp
 1fb:	c3                   	ret    

000001fc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1fc:	55                   	push   %ebp
 1fd:	89 e5                	mov    %esp,%ebp
 1ff:	57                   	push   %edi
 200:	56                   	push   %esi
 201:	53                   	push   %ebx
 202:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 205:	8d 45 10             	lea    0x10(%ebp),%eax
 208:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 20b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 210:	be 00 00 00 00       	mov    $0x0,%esi
 215:	e9 23 01 00 00       	jmp    33d <printf+0x141>
    c = fmt[i] & 0xff;
 21a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 21d:	85 ff                	test   %edi,%edi
 21f:	75 19                	jne    23a <printf+0x3e>
      if(c == '%'){
 221:	83 f8 25             	cmp    $0x25,%eax
 224:	0f 84 0b 01 00 00    	je     335 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 22a:	0f be d3             	movsbl %bl,%edx
 22d:	8b 45 08             	mov    0x8(%ebp),%eax
 230:	e8 2b ff ff ff       	call   160 <putc>
 235:	e9 00 01 00 00       	jmp    33a <printf+0x13e>
      }
    } else if(state == '%'){
 23a:	83 ff 25             	cmp    $0x25,%edi
 23d:	0f 85 f7 00 00 00    	jne    33a <printf+0x13e>
      if(c == 'd'){
 243:	83 f8 64             	cmp    $0x64,%eax
 246:	75 26                	jne    26e <printf+0x72>
        printint(fd, *ap, 10, 1);
 248:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 24b:	8b 10                	mov    (%eax),%edx
 24d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 254:	b9 0a 00 00 00       	mov    $0xa,%ecx
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	e8 21 ff ff ff       	call   182 <printint>
        ap++;
 261:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 265:	66 bf 00 00          	mov    $0x0,%di
 269:	e9 cc 00 00 00       	jmp    33a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 26e:	83 f8 78             	cmp    $0x78,%eax
 271:	0f 94 c1             	sete   %cl
 274:	83 f8 70             	cmp    $0x70,%eax
 277:	0f 94 c2             	sete   %dl
 27a:	08 d1                	or     %dl,%cl
 27c:	74 27                	je     2a5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 27e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 281:	8b 10                	mov    (%eax),%edx
 283:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 28a:	b9 10 00 00 00       	mov    $0x10,%ecx
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	e8 eb fe ff ff       	call   182 <printint>
        ap++;
 297:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 29b:	bf 00 00 00 00       	mov    $0x0,%edi
 2a0:	e9 95 00 00 00       	jmp    33a <printf+0x13e>
      } else if(c == 's'){
 2a5:	83 f8 73             	cmp    $0x73,%eax
 2a8:	75 37                	jne    2e1 <printf+0xe5>
        s = (char*)*ap;
 2aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ad:	8b 18                	mov    (%eax),%ebx
        ap++;
 2af:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 2b3:	85 db                	test   %ebx,%ebx
 2b5:	75 19                	jne    2d0 <printf+0xd4>
          s = "(null)";
 2b7:	bb 7c 03 00 00       	mov    $0x37c,%ebx
 2bc:	8b 7d 08             	mov    0x8(%ebp),%edi
 2bf:	eb 12                	jmp    2d3 <printf+0xd7>
          putc(fd, *s);
 2c1:	0f be d2             	movsbl %dl,%edx
 2c4:	89 f8                	mov    %edi,%eax
 2c6:	e8 95 fe ff ff       	call   160 <putc>
          s++;
 2cb:	83 c3 01             	add    $0x1,%ebx
 2ce:	eb 03                	jmp    2d3 <printf+0xd7>
 2d0:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 2d3:	0f b6 13             	movzbl (%ebx),%edx
 2d6:	84 d2                	test   %dl,%dl
 2d8:	75 e7                	jne    2c1 <printf+0xc5>
      state = 0;
 2da:	bf 00 00 00 00       	mov    $0x0,%edi
 2df:	eb 59                	jmp    33a <printf+0x13e>
      } else if(c == 'c'){
 2e1:	83 f8 63             	cmp    $0x63,%eax
 2e4:	75 19                	jne    2ff <printf+0x103>
        putc(fd, *ap);
 2e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2e9:	0f be 10             	movsbl (%eax),%edx
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	e8 6c fe ff ff       	call   160 <putc>
        ap++;
 2f4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 2f8:	bf 00 00 00 00       	mov    $0x0,%edi
 2fd:	eb 3b                	jmp    33a <printf+0x13e>
      } else if(c == '%'){
 2ff:	83 f8 25             	cmp    $0x25,%eax
 302:	75 12                	jne    316 <printf+0x11a>
        putc(fd, c);
 304:	0f be d3             	movsbl %bl,%edx
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	e8 51 fe ff ff       	call   160 <putc>
      state = 0;
 30f:	bf 00 00 00 00       	mov    $0x0,%edi
 314:	eb 24                	jmp    33a <printf+0x13e>
        putc(fd, '%');
 316:	ba 25 00 00 00       	mov    $0x25,%edx
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	e8 3d fe ff ff       	call   160 <putc>
        putc(fd, c);
 323:	0f be d3             	movsbl %bl,%edx
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	e8 32 fe ff ff       	call   160 <putc>
      state = 0;
 32e:	bf 00 00 00 00       	mov    $0x0,%edi
 333:	eb 05                	jmp    33a <printf+0x13e>
        state = '%';
 335:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 33a:	83 c6 01             	add    $0x1,%esi
 33d:	89 f0                	mov    %esi,%eax
 33f:	03 45 0c             	add    0xc(%ebp),%eax
 342:	0f b6 18             	movzbl (%eax),%ebx
 345:	84 db                	test   %bl,%bl
 347:	0f 85 cd fe ff ff    	jne    21a <printf+0x1e>
    }
  }
}
 34d:	83 c4 1c             	add    $0x1c,%esp
 350:	5b                   	pop    %ebx
 351:	5e                   	pop    %esi
 352:	5f                   	pop    %edi
 353:	5d                   	pop    %ebp
 354:	c3                   	ret    
