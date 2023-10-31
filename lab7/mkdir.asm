
_mkdir:     file format elf32-i386


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
   c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
   f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  13:	7f 4b                	jg     60 <main+0x60>
    printf(2, "Usage: mkdir files...\n");
  15:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
  1c:	00 
  1d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  24:	e8 d3 01 00 00       	call   1fc <printf>
    exit();
  29:	e8 49 00 00 00       	call   77 <exit>
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  2e:	8d 34 9f             	lea    (%edi,%ebx,4),%esi
  31:	8b 06                	mov    (%esi),%eax
  33:	89 04 24             	mov    %eax,(%esp)
  36:	e8 a4 00 00 00       	call   df <mkdir>
  3b:	85 c0                	test   %eax,%eax
  3d:	79 1c                	jns    5b <main+0x5b>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  3f:	8b 06                	mov    (%esi),%eax
  41:	89 44 24 08          	mov    %eax,0x8(%esp)
  45:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
  4c:	00 
  4d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  54:	e8 a3 01 00 00       	call   1fc <printf>
      break;
  59:	eb 0f                	jmp    6a <main+0x6a>
  for(i = 1; i < argc; i++){
  5b:	83 c3 01             	add    $0x1,%ebx
  5e:	eb 05                	jmp    65 <main+0x65>
  60:	bb 01 00 00 00       	mov    $0x1,%ebx
  65:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  68:	7c c4                	jl     2e <main+0x2e>
    }
  }

  exit();
  6a:	e8 08 00 00 00       	call   77 <exit>

0000006f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  6f:	b8 01 00 00 00       	mov    $0x1,%eax
  74:	cd 40                	int    $0x40
  76:	c3                   	ret    

00000077 <exit>:
SYSCALL(exit)
  77:	b8 02 00 00 00       	mov    $0x2,%eax
  7c:	cd 40                	int    $0x40
  7e:	c3                   	ret    

0000007f <wait>:
SYSCALL(wait)
  7f:	b8 03 00 00 00       	mov    $0x3,%eax
  84:	cd 40                	int    $0x40
  86:	c3                   	ret    

00000087 <pipe>:
SYSCALL(pipe)
  87:	b8 04 00 00 00       	mov    $0x4,%eax
  8c:	cd 40                	int    $0x40
  8e:	c3                   	ret    

0000008f <read>:
SYSCALL(read)
  8f:	b8 05 00 00 00       	mov    $0x5,%eax
  94:	cd 40                	int    $0x40
  96:	c3                   	ret    

00000097 <write>:
SYSCALL(write)
  97:	b8 10 00 00 00       	mov    $0x10,%eax
  9c:	cd 40                	int    $0x40
  9e:	c3                   	ret    

0000009f <close>:
SYSCALL(close)
  9f:	b8 15 00 00 00       	mov    $0x15,%eax
  a4:	cd 40                	int    $0x40
  a6:	c3                   	ret    

000000a7 <kill>:
SYSCALL(kill)
  a7:	b8 06 00 00 00       	mov    $0x6,%eax
  ac:	cd 40                	int    $0x40
  ae:	c3                   	ret    

000000af <exec>:
SYSCALL(exec)
  af:	b8 07 00 00 00       	mov    $0x7,%eax
  b4:	cd 40                	int    $0x40
  b6:	c3                   	ret    

000000b7 <open>:
SYSCALL(open)
  b7:	b8 0f 00 00 00       	mov    $0xf,%eax
  bc:	cd 40                	int    $0x40
  be:	c3                   	ret    

000000bf <mknod>:
SYSCALL(mknod)
  bf:	b8 11 00 00 00       	mov    $0x11,%eax
  c4:	cd 40                	int    $0x40
  c6:	c3                   	ret    

000000c7 <unlink>:
SYSCALL(unlink)
  c7:	b8 12 00 00 00       	mov    $0x12,%eax
  cc:	cd 40                	int    $0x40
  ce:	c3                   	ret    

000000cf <fstat>:
SYSCALL(fstat)
  cf:	b8 08 00 00 00       	mov    $0x8,%eax
  d4:	cd 40                	int    $0x40
  d6:	c3                   	ret    

000000d7 <link>:
SYSCALL(link)
  d7:	b8 13 00 00 00       	mov    $0x13,%eax
  dc:	cd 40                	int    $0x40
  de:	c3                   	ret    

000000df <mkdir>:
SYSCALL(mkdir)
  df:	b8 14 00 00 00       	mov    $0x14,%eax
  e4:	cd 40                	int    $0x40
  e6:	c3                   	ret    

000000e7 <chdir>:
SYSCALL(chdir)
  e7:	b8 09 00 00 00       	mov    $0x9,%eax
  ec:	cd 40                	int    $0x40
  ee:	c3                   	ret    

000000ef <dup>:
SYSCALL(dup)
  ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  f4:	cd 40                	int    $0x40
  f6:	c3                   	ret    

000000f7 <getpid>:
SYSCALL(getpid)
  f7:	b8 0b 00 00 00       	mov    $0xb,%eax
  fc:	cd 40                	int    $0x40
  fe:	c3                   	ret    

000000ff <sbrk>:
SYSCALL(sbrk)
  ff:	b8 0c 00 00 00       	mov    $0xc,%eax
 104:	cd 40                	int    $0x40
 106:	c3                   	ret    

00000107 <sleep>:
SYSCALL(sleep)
 107:	b8 0d 00 00 00       	mov    $0xd,%eax
 10c:	cd 40                	int    $0x40
 10e:	c3                   	ret    

0000010f <uptime>:
SYSCALL(uptime)
 10f:	b8 0e 00 00 00       	mov    $0xe,%eax
 114:	cd 40                	int    $0x40
 116:	c3                   	ret    

00000117 <yield>:
SYSCALL(yield)
 117:	b8 16 00 00 00       	mov    $0x16,%eax
 11c:	cd 40                	int    $0x40
 11e:	c3                   	ret    

0000011f <shutdown>:
SYSCALL(shutdown)
 11f:	b8 17 00 00 00       	mov    $0x17,%eax
 124:	cd 40                	int    $0x40
 126:	c3                   	ret    

00000127 <writecount>:
SYSCALL(writecount)
 127:	b8 18 00 00 00       	mov    $0x18,%eax
 12c:	cd 40                	int    $0x40
 12e:	c3                   	ret    

0000012f <setwritecount>:
SYSCALL(setwritecount)
 12f:	b8 19 00 00 00       	mov    $0x19,%eax
 134:	cd 40                	int    $0x40
 136:	c3                   	ret    

00000137 <settickets>:
SYSCALL(settickets)
 137:	b8 1a 00 00 00       	mov    $0x1a,%eax
 13c:	cd 40                	int    $0x40
 13e:	c3                   	ret    

0000013f <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 13f:	b8 1b 00 00 00       	mov    $0x1b,%eax
 144:	cd 40                	int    $0x40
 146:	c3                   	ret    

00000147 <getpagetableentry>:
SYSCALL(getpagetableentry)
 147:	b8 1c 00 00 00       	mov    $0x1c,%eax
 14c:	cd 40                	int    $0x40
 14e:	c3                   	ret    

0000014f <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 14f:	b8 1d 00 00 00       	mov    $0x1d,%eax
 154:	cd 40                	int    $0x40
 156:	c3                   	ret    

00000157 <dumppagetable>:
 157:	b8 1e 00 00 00       	mov    $0x1e,%eax
 15c:	cd 40                	int    $0x40
 15e:	c3                   	ret    
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
 17b:	e8 17 ff ff ff       	call   97 <write>
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
 1c0:	0f b6 92 8f 03 00 00 	movzbl 0x38f(%edx),%edx
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
 2b7:	bb 88 03 00 00       	mov    $0x388,%ebx
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
