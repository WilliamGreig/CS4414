
_writecount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"


int
main(int argc, char *argv[]) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if (argc > 1) {
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7e 05                	jle    14 <main+0x14>
    exit();
   f:	e8 2a 00 00 00       	call   3e <exit>
  }


  printf(1, "%d\n", writecount());
  14:	e8 d5 00 00 00       	call   ee <writecount>
  19:	89 44 24 08          	mov    %eax,0x8(%esp)
  1d:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
  24:	00 
  25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  2c:	e8 9b 01 00 00       	call   1cc <printf>
 
  exit();
  31:	e8 08 00 00 00       	call   3e <exit>

00000036 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  36:	b8 01 00 00 00       	mov    $0x1,%eax
  3b:	cd 40                	int    $0x40
  3d:	c3                   	ret    

0000003e <exit>:
SYSCALL(exit)
  3e:	b8 02 00 00 00       	mov    $0x2,%eax
  43:	cd 40                	int    $0x40
  45:	c3                   	ret    

00000046 <wait>:
SYSCALL(wait)
  46:	b8 03 00 00 00       	mov    $0x3,%eax
  4b:	cd 40                	int    $0x40
  4d:	c3                   	ret    

0000004e <pipe>:
SYSCALL(pipe)
  4e:	b8 04 00 00 00       	mov    $0x4,%eax
  53:	cd 40                	int    $0x40
  55:	c3                   	ret    

00000056 <read>:
SYSCALL(read)
  56:	b8 05 00 00 00       	mov    $0x5,%eax
  5b:	cd 40                	int    $0x40
  5d:	c3                   	ret    

0000005e <write>:
SYSCALL(write)
  5e:	b8 10 00 00 00       	mov    $0x10,%eax
  63:	cd 40                	int    $0x40
  65:	c3                   	ret    

00000066 <close>:
SYSCALL(close)
  66:	b8 15 00 00 00       	mov    $0x15,%eax
  6b:	cd 40                	int    $0x40
  6d:	c3                   	ret    

0000006e <kill>:
SYSCALL(kill)
  6e:	b8 06 00 00 00       	mov    $0x6,%eax
  73:	cd 40                	int    $0x40
  75:	c3                   	ret    

00000076 <exec>:
SYSCALL(exec)
  76:	b8 07 00 00 00       	mov    $0x7,%eax
  7b:	cd 40                	int    $0x40
  7d:	c3                   	ret    

0000007e <open>:
SYSCALL(open)
  7e:	b8 0f 00 00 00       	mov    $0xf,%eax
  83:	cd 40                	int    $0x40
  85:	c3                   	ret    

00000086 <mknod>:
SYSCALL(mknod)
  86:	b8 11 00 00 00       	mov    $0x11,%eax
  8b:	cd 40                	int    $0x40
  8d:	c3                   	ret    

0000008e <unlink>:
SYSCALL(unlink)
  8e:	b8 12 00 00 00       	mov    $0x12,%eax
  93:	cd 40                	int    $0x40
  95:	c3                   	ret    

00000096 <fstat>:
SYSCALL(fstat)
  96:	b8 08 00 00 00       	mov    $0x8,%eax
  9b:	cd 40                	int    $0x40
  9d:	c3                   	ret    

0000009e <link>:
SYSCALL(link)
  9e:	b8 13 00 00 00       	mov    $0x13,%eax
  a3:	cd 40                	int    $0x40
  a5:	c3                   	ret    

000000a6 <mkdir>:
SYSCALL(mkdir)
  a6:	b8 14 00 00 00       	mov    $0x14,%eax
  ab:	cd 40                	int    $0x40
  ad:	c3                   	ret    

000000ae <chdir>:
SYSCALL(chdir)
  ae:	b8 09 00 00 00       	mov    $0x9,%eax
  b3:	cd 40                	int    $0x40
  b5:	c3                   	ret    

000000b6 <dup>:
SYSCALL(dup)
  b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  bb:	cd 40                	int    $0x40
  bd:	c3                   	ret    

000000be <getpid>:
SYSCALL(getpid)
  be:	b8 0b 00 00 00       	mov    $0xb,%eax
  c3:	cd 40                	int    $0x40
  c5:	c3                   	ret    

000000c6 <sbrk>:
SYSCALL(sbrk)
  c6:	b8 0c 00 00 00       	mov    $0xc,%eax
  cb:	cd 40                	int    $0x40
  cd:	c3                   	ret    

000000ce <sleep>:
SYSCALL(sleep)
  ce:	b8 0d 00 00 00       	mov    $0xd,%eax
  d3:	cd 40                	int    $0x40
  d5:	c3                   	ret    

000000d6 <uptime>:
SYSCALL(uptime)
  d6:	b8 0e 00 00 00       	mov    $0xe,%eax
  db:	cd 40                	int    $0x40
  dd:	c3                   	ret    

000000de <yield>:
SYSCALL(yield)
  de:	b8 16 00 00 00       	mov    $0x16,%eax
  e3:	cd 40                	int    $0x40
  e5:	c3                   	ret    

000000e6 <shutdown>:
SYSCALL(shutdown)
  e6:	b8 17 00 00 00       	mov    $0x17,%eax
  eb:	cd 40                	int    $0x40
  ed:	c3                   	ret    

000000ee <writecount>:
SYSCALL(writecount)
  ee:	b8 18 00 00 00       	mov    $0x18,%eax
  f3:	cd 40                	int    $0x40
  f5:	c3                   	ret    

000000f6 <setwritecount>:
SYSCALL(setwritecount)
  f6:	b8 19 00 00 00       	mov    $0x19,%eax
  fb:	cd 40                	int    $0x40
  fd:	c3                   	ret    

000000fe <settickets>:
SYSCALL(settickets)
  fe:	b8 1a 00 00 00       	mov    $0x1a,%eax
 103:	cd 40                	int    $0x40
 105:	c3                   	ret    

00000106 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 106:	b8 1b 00 00 00       	mov    $0x1b,%eax
 10b:	cd 40                	int    $0x40
 10d:	c3                   	ret    

0000010e <getpagetableentry>:
SYSCALL(getpagetableentry)
 10e:	b8 1c 00 00 00       	mov    $0x1c,%eax
 113:	cd 40                	int    $0x40
 115:	c3                   	ret    

00000116 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 116:	b8 1d 00 00 00       	mov    $0x1d,%eax
 11b:	cd 40                	int    $0x40
 11d:	c3                   	ret    

0000011e <dumppagetable>:
 11e:	b8 1e 00 00 00       	mov    $0x1e,%eax
 123:	cd 40                	int    $0x40
 125:	c3                   	ret    
 126:	66 90                	xchg   %ax,%ax
 128:	66 90                	xchg   %ax,%ax
 12a:	66 90                	xchg   %ax,%ax
 12c:	66 90                	xchg   %ax,%ax
 12e:	66 90                	xchg   %ax,%ax

00000130 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	83 ec 18             	sub    $0x18,%esp
 136:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 139:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 140:	00 
 141:	8d 55 f4             	lea    -0xc(%ebp),%edx
 144:	89 54 24 04          	mov    %edx,0x4(%esp)
 148:	89 04 24             	mov    %eax,(%esp)
 14b:	e8 0e ff ff ff       	call   5e <write>
}
 150:	c9                   	leave  
 151:	c3                   	ret    

00000152 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	57                   	push   %edi
 156:	56                   	push   %esi
 157:	53                   	push   %ebx
 158:	83 ec 2c             	sub    $0x2c,%esp
 15b:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 15d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 161:	0f 95 c3             	setne  %bl
 164:	89 d0                	mov    %edx,%eax
 166:	c1 e8 1f             	shr    $0x1f,%eax
 169:	84 c3                	test   %al,%bl
 16b:	74 0b                	je     178 <printint+0x26>
    neg = 1;
    x = -xx;
 16d:	f7 da                	neg    %edx
    neg = 1;
 16f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 176:	eb 07                	jmp    17f <printint+0x2d>
  neg = 0;
 178:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 17f:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 184:	8d 5e 01             	lea    0x1(%esi),%ebx
 187:	89 d0                	mov    %edx,%eax
 189:	ba 00 00 00 00       	mov    $0x0,%edx
 18e:	f7 f1                	div    %ecx
 190:	0f b6 92 30 03 00 00 	movzbl 0x330(%edx),%edx
 197:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 19b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 19d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 19f:	85 c0                	test   %eax,%eax
 1a1:	75 e1                	jne    184 <printint+0x32>
  if(neg)
 1a3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1a7:	74 16                	je     1bf <printint+0x6d>
    buf[i++] = '-';
 1a9:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1ae:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1b1:	eb 0c                	jmp    1bf <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 1b3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1b8:	89 f8                	mov    %edi,%eax
 1ba:	e8 71 ff ff ff       	call   130 <putc>
  while(--i >= 0)
 1bf:	83 eb 01             	sub    $0x1,%ebx
 1c2:	79 ef                	jns    1b3 <printint+0x61>
}
 1c4:	83 c4 2c             	add    $0x2c,%esp
 1c7:	5b                   	pop    %ebx
 1c8:	5e                   	pop    %esi
 1c9:	5f                   	pop    %edi
 1ca:	5d                   	pop    %ebp
 1cb:	c3                   	ret    

000001cc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1cc:	55                   	push   %ebp
 1cd:	89 e5                	mov    %esp,%ebp
 1cf:	57                   	push   %edi
 1d0:	56                   	push   %esi
 1d1:	53                   	push   %ebx
 1d2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1d5:	8d 45 10             	lea    0x10(%ebp),%eax
 1d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1db:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 1e0:	be 00 00 00 00       	mov    $0x0,%esi
 1e5:	e9 23 01 00 00       	jmp    30d <printf+0x141>
    c = fmt[i] & 0xff;
 1ea:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 1ed:	85 ff                	test   %edi,%edi
 1ef:	75 19                	jne    20a <printf+0x3e>
      if(c == '%'){
 1f1:	83 f8 25             	cmp    $0x25,%eax
 1f4:	0f 84 0b 01 00 00    	je     305 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 1fa:	0f be d3             	movsbl %bl,%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	e8 2b ff ff ff       	call   130 <putc>
 205:	e9 00 01 00 00       	jmp    30a <printf+0x13e>
      }
    } else if(state == '%'){
 20a:	83 ff 25             	cmp    $0x25,%edi
 20d:	0f 85 f7 00 00 00    	jne    30a <printf+0x13e>
      if(c == 'd'){
 213:	83 f8 64             	cmp    $0x64,%eax
 216:	75 26                	jne    23e <printf+0x72>
        printint(fd, *ap, 10, 1);
 218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 21b:	8b 10                	mov    (%eax),%edx
 21d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 224:	b9 0a 00 00 00       	mov    $0xa,%ecx
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	e8 21 ff ff ff       	call   152 <printint>
        ap++;
 231:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 235:	66 bf 00 00          	mov    $0x0,%di
 239:	e9 cc 00 00 00       	jmp    30a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 23e:	83 f8 78             	cmp    $0x78,%eax
 241:	0f 94 c1             	sete   %cl
 244:	83 f8 70             	cmp    $0x70,%eax
 247:	0f 94 c2             	sete   %dl
 24a:	08 d1                	or     %dl,%cl
 24c:	74 27                	je     275 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 24e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 251:	8b 10                	mov    (%eax),%edx
 253:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25a:	b9 10 00 00 00       	mov    $0x10,%ecx
 25f:	8b 45 08             	mov    0x8(%ebp),%eax
 262:	e8 eb fe ff ff       	call   152 <printint>
        ap++;
 267:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 26b:	bf 00 00 00 00       	mov    $0x0,%edi
 270:	e9 95 00 00 00       	jmp    30a <printf+0x13e>
      } else if(c == 's'){
 275:	83 f8 73             	cmp    $0x73,%eax
 278:	75 37                	jne    2b1 <printf+0xe5>
        s = (char*)*ap;
 27a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 27d:	8b 18                	mov    (%eax),%ebx
        ap++;
 27f:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 283:	85 db                	test   %ebx,%ebx
 285:	75 19                	jne    2a0 <printf+0xd4>
          s = "(null)";
 287:	bb 29 03 00 00       	mov    $0x329,%ebx
 28c:	8b 7d 08             	mov    0x8(%ebp),%edi
 28f:	eb 12                	jmp    2a3 <printf+0xd7>
          putc(fd, *s);
 291:	0f be d2             	movsbl %dl,%edx
 294:	89 f8                	mov    %edi,%eax
 296:	e8 95 fe ff ff       	call   130 <putc>
          s++;
 29b:	83 c3 01             	add    $0x1,%ebx
 29e:	eb 03                	jmp    2a3 <printf+0xd7>
 2a0:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 2a3:	0f b6 13             	movzbl (%ebx),%edx
 2a6:	84 d2                	test   %dl,%dl
 2a8:	75 e7                	jne    291 <printf+0xc5>
      state = 0;
 2aa:	bf 00 00 00 00       	mov    $0x0,%edi
 2af:	eb 59                	jmp    30a <printf+0x13e>
      } else if(c == 'c'){
 2b1:	83 f8 63             	cmp    $0x63,%eax
 2b4:	75 19                	jne    2cf <printf+0x103>
        putc(fd, *ap);
 2b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2b9:	0f be 10             	movsbl (%eax),%edx
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	e8 6c fe ff ff       	call   130 <putc>
        ap++;
 2c4:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 2c8:	bf 00 00 00 00       	mov    $0x0,%edi
 2cd:	eb 3b                	jmp    30a <printf+0x13e>
      } else if(c == '%'){
 2cf:	83 f8 25             	cmp    $0x25,%eax
 2d2:	75 12                	jne    2e6 <printf+0x11a>
        putc(fd, c);
 2d4:	0f be d3             	movsbl %bl,%edx
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	e8 51 fe ff ff       	call   130 <putc>
      state = 0;
 2df:	bf 00 00 00 00       	mov    $0x0,%edi
 2e4:	eb 24                	jmp    30a <printf+0x13e>
        putc(fd, '%');
 2e6:	ba 25 00 00 00       	mov    $0x25,%edx
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ee:	e8 3d fe ff ff       	call   130 <putc>
        putc(fd, c);
 2f3:	0f be d3             	movsbl %bl,%edx
 2f6:	8b 45 08             	mov    0x8(%ebp),%eax
 2f9:	e8 32 fe ff ff       	call   130 <putc>
      state = 0;
 2fe:	bf 00 00 00 00       	mov    $0x0,%edi
 303:	eb 05                	jmp    30a <printf+0x13e>
        state = '%';
 305:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 30a:	83 c6 01             	add    $0x1,%esi
 30d:	89 f0                	mov    %esi,%eax
 30f:	03 45 0c             	add    0xc(%ebp),%eax
 312:	0f b6 18             	movzbl (%eax),%ebx
 315:	84 db                	test   %bl,%bl
 317:	0f 85 cd fe ff ff    	jne    1ea <printf+0x1e>
    }
  }
}
 31d:	83 c4 1c             	add    $0x1c,%esp
 320:	5b                   	pop    %ebx
 321:	5e                   	pop    %esi
 322:	5f                   	pop    %edi
 323:	5d                   	pop    %ebp
 324:	c3                   	ret    
