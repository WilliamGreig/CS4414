
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
  2b:	68 50 03 00 00       	push   $0x350
  30:	6a 02                	push   $0x2
  32:	e8 b1 01 00 00       	call   1e8 <printf>
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
  5f:	68 64 03 00 00       	push   $0x364
  64:	6a 02                	push   $0x2
  66:	e8 7d 01 00 00       	call   1e8 <printf>
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

0000012b <getpagetableentry>:
SYSCALL(getpagetableentry)
 12b:	b8 18 00 00 00       	mov    $0x18,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 133:	b8 19 00 00 00       	mov    $0x19,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <dumppagetable>:
 13b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 143:	55                   	push   %ebp
 144:	89 e5                	mov    %esp,%ebp
 146:	83 ec 1c             	sub    $0x1c,%esp
 149:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 14c:	6a 01                	push   $0x1
 14e:	8d 55 f4             	lea    -0xc(%ebp),%edx
 151:	52                   	push   %edx
 152:	50                   	push   %eax
 153:	e8 43 ff ff ff       	call   9b <write>
}
 158:	83 c4 10             	add    $0x10,%esp
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 15d:	55                   	push   %ebp
 15e:	89 e5                	mov    %esp,%ebp
 160:	57                   	push   %edi
 161:	56                   	push   %esi
 162:	53                   	push   %ebx
 163:	83 ec 2c             	sub    $0x2c,%esp
 166:	89 45 d0             	mov    %eax,-0x30(%ebp)
 169:	89 d0                	mov    %edx,%eax
 16b:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 16d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 171:	0f 95 c1             	setne  %cl
 174:	c1 ea 1f             	shr    $0x1f,%edx
 177:	84 d1                	test   %dl,%cl
 179:	74 44                	je     1bf <printint+0x62>
    neg = 1;
    x = -xx;
 17b:	f7 d8                	neg    %eax
 17d:	89 c1                	mov    %eax,%ecx
    neg = 1;
 17f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 186:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 18b:	89 c8                	mov    %ecx,%eax
 18d:	ba 00 00 00 00       	mov    $0x0,%edx
 192:	f7 f6                	div    %esi
 194:	89 df                	mov    %ebx,%edi
 196:	83 c3 01             	add    $0x1,%ebx
 199:	0f b6 92 dc 03 00 00 	movzbl 0x3dc(%edx),%edx
 1a0:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1a4:	89 ca                	mov    %ecx,%edx
 1a6:	89 c1                	mov    %eax,%ecx
 1a8:	39 d6                	cmp    %edx,%esi
 1aa:	76 df                	jbe    18b <printint+0x2e>
  if(neg)
 1ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1b0:	74 31                	je     1e3 <printint+0x86>
    buf[i++] = '-';
 1b2:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1b7:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1bd:	eb 17                	jmp    1d6 <printint+0x79>
    x = xx;
 1bf:	89 c1                	mov    %eax,%ecx
  neg = 0;
 1c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1c8:	eb bc                	jmp    186 <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 1ca:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 1cf:	89 f0                	mov    %esi,%eax
 1d1:	e8 6d ff ff ff       	call   143 <putc>
  while(--i >= 0)
 1d6:	83 eb 01             	sub    $0x1,%ebx
 1d9:	79 ef                	jns    1ca <printint+0x6d>
}
 1db:	83 c4 2c             	add    $0x2c,%esp
 1de:	5b                   	pop    %ebx
 1df:	5e                   	pop    %esi
 1e0:	5f                   	pop    %edi
 1e1:	5d                   	pop    %ebp
 1e2:	c3                   	ret    
 1e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
 1e6:	eb ee                	jmp    1d6 <printint+0x79>

000001e8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	57                   	push   %edi
 1ec:	56                   	push   %esi
 1ed:	53                   	push   %ebx
 1ee:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 1f1:	8d 45 10             	lea    0x10(%ebp),%eax
 1f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 1f7:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 1fc:	bb 00 00 00 00       	mov    $0x0,%ebx
 201:	eb 14                	jmp    217 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 203:	89 fa                	mov    %edi,%edx
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	e8 36 ff ff ff       	call   143 <putc>
 20d:	eb 05                	jmp    214 <printf+0x2c>
      }
    } else if(state == '%'){
 20f:	83 fe 25             	cmp    $0x25,%esi
 212:	74 25                	je     239 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 214:	83 c3 01             	add    $0x1,%ebx
 217:	8b 45 0c             	mov    0xc(%ebp),%eax
 21a:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 21e:	84 c0                	test   %al,%al
 220:	0f 84 20 01 00 00    	je     346 <printf+0x15e>
    c = fmt[i] & 0xff;
 226:	0f be f8             	movsbl %al,%edi
 229:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 22c:	85 f6                	test   %esi,%esi
 22e:	75 df                	jne    20f <printf+0x27>
      if(c == '%'){
 230:	83 f8 25             	cmp    $0x25,%eax
 233:	75 ce                	jne    203 <printf+0x1b>
        state = '%';
 235:	89 c6                	mov    %eax,%esi
 237:	eb db                	jmp    214 <printf+0x2c>
      if(c == 'd'){
 239:	83 f8 25             	cmp    $0x25,%eax
 23c:	0f 84 cf 00 00 00    	je     311 <printf+0x129>
 242:	0f 8c dd 00 00 00    	jl     325 <printf+0x13d>
 248:	83 f8 78             	cmp    $0x78,%eax
 24b:	0f 8f d4 00 00 00    	jg     325 <printf+0x13d>
 251:	83 f8 63             	cmp    $0x63,%eax
 254:	0f 8c cb 00 00 00    	jl     325 <printf+0x13d>
 25a:	83 e8 63             	sub    $0x63,%eax
 25d:	83 f8 15             	cmp    $0x15,%eax
 260:	0f 87 bf 00 00 00    	ja     325 <printf+0x13d>
 266:	ff 24 85 84 03 00 00 	jmp    *0x384(,%eax,4)
        printint(fd, *ap, 10, 1);
 26d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 270:	8b 17                	mov    (%edi),%edx
 272:	83 ec 0c             	sub    $0xc,%esp
 275:	6a 01                	push   $0x1
 277:	b9 0a 00 00 00       	mov    $0xa,%ecx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	e8 d9 fe ff ff       	call   15d <printint>
        ap++;
 284:	83 c7 04             	add    $0x4,%edi
 287:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 28a:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 28d:	be 00 00 00 00       	mov    $0x0,%esi
 292:	eb 80                	jmp    214 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 294:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 297:	8b 17                	mov    (%edi),%edx
 299:	83 ec 0c             	sub    $0xc,%esp
 29c:	6a 00                	push   $0x0
 29e:	b9 10 00 00 00       	mov    $0x10,%ecx
 2a3:	8b 45 08             	mov    0x8(%ebp),%eax
 2a6:	e8 b2 fe ff ff       	call   15d <printint>
        ap++;
 2ab:	83 c7 04             	add    $0x4,%edi
 2ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2b1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2b4:	be 00 00 00 00       	mov    $0x0,%esi
 2b9:	e9 56 ff ff ff       	jmp    214 <printf+0x2c>
        s = (char*)*ap;
 2be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2c1:	8b 30                	mov    (%eax),%esi
        ap++;
 2c3:	83 c0 04             	add    $0x4,%eax
 2c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 2c9:	85 f6                	test   %esi,%esi
 2cb:	75 15                	jne    2e2 <printf+0xfa>
          s = "(null)";
 2cd:	be 7d 03 00 00       	mov    $0x37d,%esi
 2d2:	eb 0e                	jmp    2e2 <printf+0xfa>
          putc(fd, *s);
 2d4:	0f be d2             	movsbl %dl,%edx
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	e8 64 fe ff ff       	call   143 <putc>
          s++;
 2df:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 2e2:	0f b6 16             	movzbl (%esi),%edx
 2e5:	84 d2                	test   %dl,%dl
 2e7:	75 eb                	jne    2d4 <printf+0xec>
      state = 0;
 2e9:	be 00 00 00 00       	mov    $0x0,%esi
 2ee:	e9 21 ff ff ff       	jmp    214 <printf+0x2c>
        putc(fd, *ap);
 2f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2f6:	0f be 17             	movsbl (%edi),%edx
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	e8 42 fe ff ff       	call   143 <putc>
        ap++;
 301:	83 c7 04             	add    $0x4,%edi
 304:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 307:	be 00 00 00 00       	mov    $0x0,%esi
 30c:	e9 03 ff ff ff       	jmp    214 <printf+0x2c>
        putc(fd, c);
 311:	89 fa                	mov    %edi,%edx
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	e8 28 fe ff ff       	call   143 <putc>
      state = 0;
 31b:	be 00 00 00 00       	mov    $0x0,%esi
 320:	e9 ef fe ff ff       	jmp    214 <printf+0x2c>
        putc(fd, '%');
 325:	ba 25 00 00 00       	mov    $0x25,%edx
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
 32d:	e8 11 fe ff ff       	call   143 <putc>
        putc(fd, c);
 332:	89 fa                	mov    %edi,%edx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	e8 07 fe ff ff       	call   143 <putc>
      state = 0;
 33c:	be 00 00 00 00       	mov    $0x0,%esi
 341:	e9 ce fe ff ff       	jmp    214 <printf+0x2c>
    }
  }
}
 346:	8d 65 f4             	lea    -0xc(%ebp),%esp
 349:	5b                   	pop    %ebx
 34a:	5e                   	pop    %esi
 34b:	5f                   	pop    %edi
 34c:	5d                   	pop    %ebp
 34d:	c3                   	ret    
