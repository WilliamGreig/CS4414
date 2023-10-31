
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  for(i = 1; i < argc; i++)
  12:	b8 01 00 00 00       	mov    $0x1,%eax
  17:	eb 34                	jmp    4d <main+0x4d>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  19:	8d 58 01             	lea    0x1(%eax),%ebx
  1c:	39 f3                	cmp    %esi,%ebx
  1e:	7d 07                	jge    27 <main+0x27>
  20:	ba 45 03 00 00       	mov    $0x345,%edx
  25:	eb 05                	jmp    2c <main+0x2c>
  27:	ba 47 03 00 00       	mov    $0x347,%edx
  2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  30:	8b 04 87             	mov    (%edi,%eax,4),%eax
  33:	89 44 24 08          	mov    %eax,0x8(%esp)
  37:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
  3e:	00 
  3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  46:	e8 a1 01 00 00       	call   1ec <printf>
  for(i = 1; i < argc; i++)
  4b:	89 d8                	mov    %ebx,%eax
  4d:	39 f0                	cmp    %esi,%eax
  4f:	7c c8                	jl     19 <main+0x19>
  exit();
  51:	e8 08 00 00 00       	call   5e <exit>

00000056 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  56:	b8 01 00 00 00       	mov    $0x1,%eax
  5b:	cd 40                	int    $0x40
  5d:	c3                   	ret    

0000005e <exit>:
SYSCALL(exit)
  5e:	b8 02 00 00 00       	mov    $0x2,%eax
  63:	cd 40                	int    $0x40
  65:	c3                   	ret    

00000066 <wait>:
SYSCALL(wait)
  66:	b8 03 00 00 00       	mov    $0x3,%eax
  6b:	cd 40                	int    $0x40
  6d:	c3                   	ret    

0000006e <pipe>:
SYSCALL(pipe)
  6e:	b8 04 00 00 00       	mov    $0x4,%eax
  73:	cd 40                	int    $0x40
  75:	c3                   	ret    

00000076 <read>:
SYSCALL(read)
  76:	b8 05 00 00 00       	mov    $0x5,%eax
  7b:	cd 40                	int    $0x40
  7d:	c3                   	ret    

0000007e <write>:
SYSCALL(write)
  7e:	b8 10 00 00 00       	mov    $0x10,%eax
  83:	cd 40                	int    $0x40
  85:	c3                   	ret    

00000086 <close>:
SYSCALL(close)
  86:	b8 15 00 00 00       	mov    $0x15,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <kill>:
SYSCALL(kill)
  8e:	b8 06 00 00 00       	mov    $0x6,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <exec>:
SYSCALL(exec)
  96:	b8 07 00 00 00       	mov    $0x7,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <open>:
SYSCALL(open)
  9e:	b8 0f 00 00 00       	mov    $0xf,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <mknod>:
SYSCALL(mknod)
  a6:	b8 11 00 00 00       	mov    $0x11,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <unlink>:
SYSCALL(unlink)
  ae:	b8 12 00 00 00       	mov    $0x12,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <fstat>:
SYSCALL(fstat)
  b6:	b8 08 00 00 00       	mov    $0x8,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <link>:
SYSCALL(link)
  be:	b8 13 00 00 00       	mov    $0x13,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <mkdir>:
SYSCALL(mkdir)
  c6:	b8 14 00 00 00       	mov    $0x14,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <chdir>:
SYSCALL(chdir)
  ce:	b8 09 00 00 00       	mov    $0x9,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <dup>:
SYSCALL(dup)
  d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <getpid>:
SYSCALL(getpid)
  de:	b8 0b 00 00 00       	mov    $0xb,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <sbrk>:
SYSCALL(sbrk)
  e6:	b8 0c 00 00 00       	mov    $0xc,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <sleep>:
SYSCALL(sleep)
  ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <uptime>:
SYSCALL(uptime)
  f6:	b8 0e 00 00 00       	mov    $0xe,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <yield>:
SYSCALL(yield)
  fe:	b8 16 00 00 00       	mov    $0x16,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <shutdown>:
SYSCALL(shutdown)
 106:	b8 17 00 00 00       	mov    $0x17,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <writecount>:
SYSCALL(writecount)
 10e:	b8 18 00 00 00       	mov    $0x18,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <setwritecount>:
SYSCALL(setwritecount)
 116:	b8 19 00 00 00       	mov    $0x19,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <settickets>:
SYSCALL(settickets)
 11e:	b8 1a 00 00 00       	mov    $0x1a,%eax
 123:	cd 40                	int    $0x40
 125:	c3                   	ret    

00000126 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 126:	b8 1b 00 00 00       	mov    $0x1b,%eax
 12b:	cd 40                	int    $0x40
 12d:	c3                   	ret    

0000012e <getpagetableentry>:
SYSCALL(getpagetableentry)
 12e:	b8 1c 00 00 00       	mov    $0x1c,%eax
 133:	cd 40                	int    $0x40
 135:	c3                   	ret    

00000136 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 136:	b8 1d 00 00 00       	mov    $0x1d,%eax
 13b:	cd 40                	int    $0x40
 13d:	c3                   	ret    

0000013e <dumppagetable>:
 13e:	b8 1e 00 00 00       	mov    $0x1e,%eax
 143:	cd 40                	int    $0x40
 145:	c3                   	ret    
 146:	66 90                	xchg   %ax,%ax
 148:	66 90                	xchg   %ax,%ax
 14a:	66 90                	xchg   %ax,%ax
 14c:	66 90                	xchg   %ax,%ax
 14e:	66 90                	xchg   %ax,%ax

00000150 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 150:	55                   	push   %ebp
 151:	89 e5                	mov    %esp,%ebp
 153:	83 ec 18             	sub    $0x18,%esp
 156:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 159:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 160:	00 
 161:	8d 55 f4             	lea    -0xc(%ebp),%edx
 164:	89 54 24 04          	mov    %edx,0x4(%esp)
 168:	89 04 24             	mov    %eax,(%esp)
 16b:	e8 0e ff ff ff       	call   7e <write>
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
 175:	57                   	push   %edi
 176:	56                   	push   %esi
 177:	53                   	push   %ebx
 178:	83 ec 2c             	sub    $0x2c,%esp
 17b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 17d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 181:	0f 95 c3             	setne  %bl
 184:	89 d0                	mov    %edx,%eax
 186:	c1 e8 1f             	shr    $0x1f,%eax
 189:	84 c3                	test   %al,%bl
 18b:	74 0b                	je     198 <printint+0x26>
    neg = 1;
    x = -xx;
 18d:	f7 da                	neg    %edx
    neg = 1;
 18f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 196:	eb 07                	jmp    19f <printint+0x2d>
  neg = 0;
 198:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 19f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 1a4:	8d 5e 01             	lea    0x1(%esi),%ebx
 1a7:	89 d0                	mov    %edx,%eax
 1a9:	ba 00 00 00 00       	mov    $0x0,%edx
 1ae:	f7 f1                	div    %ecx
 1b0:	0f b6 92 55 03 00 00 	movzbl 0x355(%edx),%edx
 1b7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 1bb:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 1bd:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 1bf:	85 c0                	test   %eax,%eax
 1c1:	75 e1                	jne    1a4 <printint+0x32>
  if(neg)
 1c3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1c7:	74 16                	je     1df <printint+0x6d>
    buf[i++] = '-';
 1c9:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1ce:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d1:	eb 0c                	jmp    1df <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 1d3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1d8:	89 f8                	mov    %edi,%eax
 1da:	e8 71 ff ff ff       	call   150 <putc>
  while(--i >= 0)
 1df:	83 eb 01             	sub    $0x1,%ebx
 1e2:	79 ef                	jns    1d3 <printint+0x61>
}
 1e4:	83 c4 2c             	add    $0x2c,%esp
 1e7:	5b                   	pop    %ebx
 1e8:	5e                   	pop    %esi
 1e9:	5f                   	pop    %edi
 1ea:	5d                   	pop    %ebp
 1eb:	c3                   	ret    

000001ec <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	57                   	push   %edi
 1f0:	56                   	push   %esi
 1f1:	53                   	push   %ebx
 1f2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1f5:	8d 45 10             	lea    0x10(%ebp),%eax
 1f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1fb:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 200:	be 00 00 00 00       	mov    $0x0,%esi
 205:	e9 23 01 00 00       	jmp    32d <printf+0x141>
    c = fmt[i] & 0xff;
 20a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 20d:	85 ff                	test   %edi,%edi
 20f:	75 19                	jne    22a <printf+0x3e>
      if(c == '%'){
 211:	83 f8 25             	cmp    $0x25,%eax
 214:	0f 84 0b 01 00 00    	je     325 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 21a:	0f be d3             	movsbl %bl,%edx
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	e8 2b ff ff ff       	call   150 <putc>
 225:	e9 00 01 00 00       	jmp    32a <printf+0x13e>
      }
    } else if(state == '%'){
 22a:	83 ff 25             	cmp    $0x25,%edi
 22d:	0f 85 f7 00 00 00    	jne    32a <printf+0x13e>
      if(c == 'd'){
 233:	83 f8 64             	cmp    $0x64,%eax
 236:	75 26                	jne    25e <printf+0x72>
        printint(fd, *ap, 10, 1);
 238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 23b:	8b 10                	mov    (%eax),%edx
 23d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 244:	b9 0a 00 00 00       	mov    $0xa,%ecx
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	e8 21 ff ff ff       	call   172 <printint>
        ap++;
 251:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 255:	66 bf 00 00          	mov    $0x0,%di
 259:	e9 cc 00 00 00       	jmp    32a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 25e:	83 f8 78             	cmp    $0x78,%eax
 261:	0f 94 c1             	sete   %cl
 264:	83 f8 70             	cmp    $0x70,%eax
 267:	0f 94 c2             	sete   %dl
 26a:	08 d1                	or     %dl,%cl
 26c:	74 27                	je     295 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 26e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 271:	8b 10                	mov    (%eax),%edx
 273:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 27a:	b9 10 00 00 00       	mov    $0x10,%ecx
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	e8 eb fe ff ff       	call   172 <printint>
        ap++;
 287:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 28b:	bf 00 00 00 00       	mov    $0x0,%edi
 290:	e9 95 00 00 00       	jmp    32a <printf+0x13e>
      } else if(c == 's'){
 295:	83 f8 73             	cmp    $0x73,%eax
 298:	75 37                	jne    2d1 <printf+0xe5>
        s = (char*)*ap;
 29a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 29d:	8b 18                	mov    (%eax),%ebx
        ap++;
 29f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 2a3:	85 db                	test   %ebx,%ebx
 2a5:	75 19                	jne    2c0 <printf+0xd4>
          s = "(null)";
 2a7:	bb 4e 03 00 00       	mov    $0x34e,%ebx
 2ac:	8b 7d 08             	mov    0x8(%ebp),%edi
 2af:	eb 12                	jmp    2c3 <printf+0xd7>
          putc(fd, *s);
 2b1:	0f be d2             	movsbl %dl,%edx
 2b4:	89 f8                	mov    %edi,%eax
 2b6:	e8 95 fe ff ff       	call   150 <putc>
          s++;
 2bb:	83 c3 01             	add    $0x1,%ebx
 2be:	eb 03                	jmp    2c3 <printf+0xd7>
 2c0:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 2c3:	0f b6 13             	movzbl (%ebx),%edx
 2c6:	84 d2                	test   %dl,%dl
 2c8:	75 e7                	jne    2b1 <printf+0xc5>
      state = 0;
 2ca:	bf 00 00 00 00       	mov    $0x0,%edi
 2cf:	eb 59                	jmp    32a <printf+0x13e>
      } else if(c == 'c'){
 2d1:	83 f8 63             	cmp    $0x63,%eax
 2d4:	75 19                	jne    2ef <printf+0x103>
        putc(fd, *ap);
 2d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d9:	0f be 10             	movsbl (%eax),%edx
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	e8 6c fe ff ff       	call   150 <putc>
        ap++;
 2e4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 2e8:	bf 00 00 00 00       	mov    $0x0,%edi
 2ed:	eb 3b                	jmp    32a <printf+0x13e>
      } else if(c == '%'){
 2ef:	83 f8 25             	cmp    $0x25,%eax
 2f2:	75 12                	jne    306 <printf+0x11a>
        putc(fd, c);
 2f4:	0f be d3             	movsbl %bl,%edx
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	e8 51 fe ff ff       	call   150 <putc>
      state = 0;
 2ff:	bf 00 00 00 00       	mov    $0x0,%edi
 304:	eb 24                	jmp    32a <printf+0x13e>
        putc(fd, '%');
 306:	ba 25 00 00 00       	mov    $0x25,%edx
 30b:	8b 45 08             	mov    0x8(%ebp),%eax
 30e:	e8 3d fe ff ff       	call   150 <putc>
        putc(fd, c);
 313:	0f be d3             	movsbl %bl,%edx
 316:	8b 45 08             	mov    0x8(%ebp),%eax
 319:	e8 32 fe ff ff       	call   150 <putc>
      state = 0;
 31e:	bf 00 00 00 00       	mov    $0x0,%edi
 323:	eb 05                	jmp    32a <printf+0x13e>
        state = '%';
 325:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 32a:	83 c6 01             	add    $0x1,%esi
 32d:	89 f0                	mov    %esi,%eax
 32f:	03 45 0c             	add    0xc(%ebp),%eax
 332:	0f b6 18             	movzbl (%eax),%ebx
 335:	84 db                	test   %bl,%bl
 337:	0f 85 cd fe ff ff    	jne    20a <printf+0x1e>
    }
  }
}
 33d:	83 c4 1c             	add    $0x1c,%esp
 340:	5b                   	pop    %ebx
 341:	5e                   	pop    %esi
 342:	5f                   	pop    %edi
 343:	5d                   	pop    %ebp
 344:	c3                   	ret    
