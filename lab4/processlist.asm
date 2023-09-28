
_processlist:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "param.h"
#include "processesinfo.h"
#include "user.h"

int main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	81 ec 1c 03 00 00    	sub    $0x31c,%esp
    struct processes_info info;
    info.num_processes = -9999;  // to make sure getprocessesinfo() doesn't
  15:	c7 85 f4 fc ff ff f1 	movl   $0xffffd8f1,-0x30c(%ebp)
  1c:	d8 ff ff 
                                 // depend on its initial value
    getprocessesinfo(&info);
  1f:	8d 85 f4 fc ff ff    	lea    -0x30c(%ebp),%eax
  25:	50                   	push   %eax
  26:	e8 55 01 00 00       	call   180 <getprocessesinfo>
    if (info.num_processes < 0) {
  2b:	83 c4 10             	add    $0x10,%esp
  2e:	83 bd f4 fc ff ff 00 	cmpl   $0x0,-0x30c(%ebp)
  35:	78 2e                	js     65 <main+0x65>
        printf(1, "ERROR: negative number of processes!\n"
                  "Myabe getprocessesinfo() assumes that num_processes is\n"
                  "always initialized to 0?\n");
    }
    printf(1, "%d running processes\n", info.num_processes);
  37:	83 ec 04             	sub    $0x4,%esp
  3a:	ff b5 f4 fc ff ff    	push   -0x30c(%ebp)
  40:	68 0a 04 00 00       	push   $0x40a
  45:	6a 01                	push   $0x1
  47:	e8 e1 01 00 00       	call   22d <printf>
    printf(1, "PID\tTICKETS\tTIMES-SCHEDULED\n");
  4c:	83 c4 08             	add    $0x8,%esp
  4f:	68 20 04 00 00       	push   $0x420
  54:	6a 01                	push   $0x1
  56:	e8 d2 01 00 00       	call   22d <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  63:	eb 3e                	jmp    a3 <main+0xa3>
        printf(1, "ERROR: negative number of processes!\n"
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 94 03 00 00       	push   $0x394
  6d:	6a 01                	push   $0x1
  6f:	e8 b9 01 00 00       	call   22d <printf>
  74:	83 c4 10             	add    $0x10,%esp
  77:	eb be                	jmp    37 <main+0x37>
        printf(1, "%d\t%d\t%d\n", info.pids[i], info.tickets[i], info.times_scheduled[i]);
  79:	83 ec 0c             	sub    $0xc,%esp
  7c:	ff b4 9d f8 fd ff ff 	push   -0x208(%ebp,%ebx,4)
  83:	ff b4 9d f8 fe ff ff 	push   -0x108(%ebp,%ebx,4)
  8a:	ff b4 9d f8 fc ff ff 	push   -0x308(%ebp,%ebx,4)
  91:	68 3d 04 00 00       	push   $0x43d
  96:	6a 01                	push   $0x1
  98:	e8 90 01 00 00       	call   22d <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  9d:	83 c3 01             	add    $0x1,%ebx
  a0:	83 c4 20             	add    $0x20,%esp
  a3:	39 9d f4 fc ff ff    	cmp    %ebx,-0x30c(%ebp)
  a9:	7f ce                	jg     79 <main+0x79>
    }
    exit();
  ab:	e8 08 00 00 00       	call   b8 <exit>

000000b0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  b0:	b8 01 00 00 00       	mov    $0x1,%eax
  b5:	cd 40                	int    $0x40
  b7:	c3                   	ret    

000000b8 <exit>:
SYSCALL(exit)
  b8:	b8 02 00 00 00       	mov    $0x2,%eax
  bd:	cd 40                	int    $0x40
  bf:	c3                   	ret    

000000c0 <wait>:
SYSCALL(wait)
  c0:	b8 03 00 00 00       	mov    $0x3,%eax
  c5:	cd 40                	int    $0x40
  c7:	c3                   	ret    

000000c8 <pipe>:
SYSCALL(pipe)
  c8:	b8 04 00 00 00       	mov    $0x4,%eax
  cd:	cd 40                	int    $0x40
  cf:	c3                   	ret    

000000d0 <read>:
SYSCALL(read)
  d0:	b8 05 00 00 00       	mov    $0x5,%eax
  d5:	cd 40                	int    $0x40
  d7:	c3                   	ret    

000000d8 <write>:
SYSCALL(write)
  d8:	b8 10 00 00 00       	mov    $0x10,%eax
  dd:	cd 40                	int    $0x40
  df:	c3                   	ret    

000000e0 <close>:
SYSCALL(close)
  e0:	b8 15 00 00 00       	mov    $0x15,%eax
  e5:	cd 40                	int    $0x40
  e7:	c3                   	ret    

000000e8 <kill>:
SYSCALL(kill)
  e8:	b8 06 00 00 00       	mov    $0x6,%eax
  ed:	cd 40                	int    $0x40
  ef:	c3                   	ret    

000000f0 <exec>:
SYSCALL(exec)
  f0:	b8 07 00 00 00       	mov    $0x7,%eax
  f5:	cd 40                	int    $0x40
  f7:	c3                   	ret    

000000f8 <open>:
SYSCALL(open)
  f8:	b8 0f 00 00 00       	mov    $0xf,%eax
  fd:	cd 40                	int    $0x40
  ff:	c3                   	ret    

00000100 <mknod>:
SYSCALL(mknod)
 100:	b8 11 00 00 00       	mov    $0x11,%eax
 105:	cd 40                	int    $0x40
 107:	c3                   	ret    

00000108 <unlink>:
SYSCALL(unlink)
 108:	b8 12 00 00 00       	mov    $0x12,%eax
 10d:	cd 40                	int    $0x40
 10f:	c3                   	ret    

00000110 <fstat>:
SYSCALL(fstat)
 110:	b8 08 00 00 00       	mov    $0x8,%eax
 115:	cd 40                	int    $0x40
 117:	c3                   	ret    

00000118 <link>:
SYSCALL(link)
 118:	b8 13 00 00 00       	mov    $0x13,%eax
 11d:	cd 40                	int    $0x40
 11f:	c3                   	ret    

00000120 <mkdir>:
SYSCALL(mkdir)
 120:	b8 14 00 00 00       	mov    $0x14,%eax
 125:	cd 40                	int    $0x40
 127:	c3                   	ret    

00000128 <chdir>:
SYSCALL(chdir)
 128:	b8 09 00 00 00       	mov    $0x9,%eax
 12d:	cd 40                	int    $0x40
 12f:	c3                   	ret    

00000130 <dup>:
SYSCALL(dup)
 130:	b8 0a 00 00 00       	mov    $0xa,%eax
 135:	cd 40                	int    $0x40
 137:	c3                   	ret    

00000138 <getpid>:
SYSCALL(getpid)
 138:	b8 0b 00 00 00       	mov    $0xb,%eax
 13d:	cd 40                	int    $0x40
 13f:	c3                   	ret    

00000140 <sbrk>:
SYSCALL(sbrk)
 140:	b8 0c 00 00 00       	mov    $0xc,%eax
 145:	cd 40                	int    $0x40
 147:	c3                   	ret    

00000148 <sleep>:
SYSCALL(sleep)
 148:	b8 0d 00 00 00       	mov    $0xd,%eax
 14d:	cd 40                	int    $0x40
 14f:	c3                   	ret    

00000150 <uptime>:
SYSCALL(uptime)
 150:	b8 0e 00 00 00       	mov    $0xe,%eax
 155:	cd 40                	int    $0x40
 157:	c3                   	ret    

00000158 <yield>:
SYSCALL(yield)
 158:	b8 16 00 00 00       	mov    $0x16,%eax
 15d:	cd 40                	int    $0x40
 15f:	c3                   	ret    

00000160 <shutdown>:
SYSCALL(shutdown)
 160:	b8 17 00 00 00       	mov    $0x17,%eax
 165:	cd 40                	int    $0x40
 167:	c3                   	ret    

00000168 <writecount>:
SYSCALL(writecount)
 168:	b8 18 00 00 00       	mov    $0x18,%eax
 16d:	cd 40                	int    $0x40
 16f:	c3                   	ret    

00000170 <setwritecount>:
SYSCALL(setwritecount)
 170:	b8 19 00 00 00       	mov    $0x19,%eax
 175:	cd 40                	int    $0x40
 177:	c3                   	ret    

00000178 <settickets>:
SYSCALL(settickets)
 178:	b8 1a 00 00 00       	mov    $0x1a,%eax
 17d:	cd 40                	int    $0x40
 17f:	c3                   	ret    

00000180 <getprocessesinfo>:
 180:	b8 1b 00 00 00       	mov    $0x1b,%eax
 185:	cd 40                	int    $0x40
 187:	c3                   	ret    

00000188 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	83 ec 1c             	sub    $0x1c,%esp
 18e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 191:	6a 01                	push   $0x1
 193:	8d 55 f4             	lea    -0xc(%ebp),%edx
 196:	52                   	push   %edx
 197:	50                   	push   %eax
 198:	e8 3b ff ff ff       	call   d8 <write>
}
 19d:	83 c4 10             	add    $0x10,%esp
 1a0:	c9                   	leave  
 1a1:	c3                   	ret    

000001a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	57                   	push   %edi
 1a6:	56                   	push   %esi
 1a7:	53                   	push   %ebx
 1a8:	83 ec 2c             	sub    $0x2c,%esp
 1ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
 1ae:	89 d0                	mov    %edx,%eax
 1b0:	89 ce                	mov    %ecx,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1b6:	0f 95 c1             	setne  %cl
 1b9:	c1 ea 1f             	shr    $0x1f,%edx
 1bc:	84 d1                	test   %dl,%cl
 1be:	74 44                	je     204 <printint+0x62>
    neg = 1;
    x = -xx;
 1c0:	f7 d8                	neg    %eax
 1c2:	89 c1                	mov    %eax,%ecx
    neg = 1;
 1c4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  do{
    buf[i++] = digits[x % base];
 1d0:	89 c8                	mov    %ecx,%eax
 1d2:	ba 00 00 00 00       	mov    $0x0,%edx
 1d7:	f7 f6                	div    %esi
 1d9:	89 df                	mov    %ebx,%edi
 1db:	83 c3 01             	add    $0x1,%ebx
 1de:	0f b6 92 a8 04 00 00 	movzbl 0x4a8(%edx),%edx
 1e5:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
 1e9:	89 ca                	mov    %ecx,%edx
 1eb:	89 c1                	mov    %eax,%ecx
 1ed:	39 d6                	cmp    %edx,%esi
 1ef:	76 df                	jbe    1d0 <printint+0x2e>
  if(neg)
 1f1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 1f5:	74 31                	je     228 <printint+0x86>
    buf[i++] = '-';
 1f7:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 1fc:	8d 5f 02             	lea    0x2(%edi),%ebx
 1ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
 202:	eb 17                	jmp    21b <printint+0x79>
    x = xx;
 204:	89 c1                	mov    %eax,%ecx
  neg = 0;
 206:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 20d:	eb bc                	jmp    1cb <printint+0x29>

  while(--i >= 0)
    putc(fd, buf[i]);
 20f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 214:	89 f0                	mov    %esi,%eax
 216:	e8 6d ff ff ff       	call   188 <putc>
  while(--i >= 0)
 21b:	83 eb 01             	sub    $0x1,%ebx
 21e:	79 ef                	jns    20f <printint+0x6d>
}
 220:	83 c4 2c             	add    $0x2c,%esp
 223:	5b                   	pop    %ebx
 224:	5e                   	pop    %esi
 225:	5f                   	pop    %edi
 226:	5d                   	pop    %ebp
 227:	c3                   	ret    
 228:	8b 75 d0             	mov    -0x30(%ebp),%esi
 22b:	eb ee                	jmp    21b <printint+0x79>

0000022d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 22d:	55                   	push   %ebp
 22e:	89 e5                	mov    %esp,%ebp
 230:	57                   	push   %edi
 231:	56                   	push   %esi
 232:	53                   	push   %ebx
 233:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 236:	8d 45 10             	lea    0x10(%ebp),%eax
 239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 23c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 241:	bb 00 00 00 00       	mov    $0x0,%ebx
 246:	eb 14                	jmp    25c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 248:	89 fa                	mov    %edi,%edx
 24a:	8b 45 08             	mov    0x8(%ebp),%eax
 24d:	e8 36 ff ff ff       	call   188 <putc>
 252:	eb 05                	jmp    259 <printf+0x2c>
      }
    } else if(state == '%'){
 254:	83 fe 25             	cmp    $0x25,%esi
 257:	74 25                	je     27e <printf+0x51>
  for(i = 0; fmt[i]; i++){
 259:	83 c3 01             	add    $0x1,%ebx
 25c:	8b 45 0c             	mov    0xc(%ebp),%eax
 25f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 263:	84 c0                	test   %al,%al
 265:	0f 84 20 01 00 00    	je     38b <printf+0x15e>
    c = fmt[i] & 0xff;
 26b:	0f be f8             	movsbl %al,%edi
 26e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 271:	85 f6                	test   %esi,%esi
 273:	75 df                	jne    254 <printf+0x27>
      if(c == '%'){
 275:	83 f8 25             	cmp    $0x25,%eax
 278:	75 ce                	jne    248 <printf+0x1b>
        state = '%';
 27a:	89 c6                	mov    %eax,%esi
 27c:	eb db                	jmp    259 <printf+0x2c>
      if(c == 'd'){
 27e:	83 f8 25             	cmp    $0x25,%eax
 281:	0f 84 cf 00 00 00    	je     356 <printf+0x129>
 287:	0f 8c dd 00 00 00    	jl     36a <printf+0x13d>
 28d:	83 f8 78             	cmp    $0x78,%eax
 290:	0f 8f d4 00 00 00    	jg     36a <printf+0x13d>
 296:	83 f8 63             	cmp    $0x63,%eax
 299:	0f 8c cb 00 00 00    	jl     36a <printf+0x13d>
 29f:	83 e8 63             	sub    $0x63,%eax
 2a2:	83 f8 15             	cmp    $0x15,%eax
 2a5:	0f 87 bf 00 00 00    	ja     36a <printf+0x13d>
 2ab:	ff 24 85 50 04 00 00 	jmp    *0x450(,%eax,4)
        printint(fd, *ap, 10, 1);
 2b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2b5:	8b 17                	mov    (%edi),%edx
 2b7:	83 ec 0c             	sub    $0xc,%esp
 2ba:	6a 01                	push   $0x1
 2bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2c1:	8b 45 08             	mov    0x8(%ebp),%eax
 2c4:	e8 d9 fe ff ff       	call   1a2 <printint>
        ap++;
 2c9:	83 c7 04             	add    $0x4,%edi
 2cc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2cf:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2d2:	be 00 00 00 00       	mov    $0x0,%esi
 2d7:	eb 80                	jmp    259 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 2d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 2dc:	8b 17                	mov    (%edi),%edx
 2de:	83 ec 0c             	sub    $0xc,%esp
 2e1:	6a 00                	push   $0x0
 2e3:	b9 10 00 00 00       	mov    $0x10,%ecx
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	e8 b2 fe ff ff       	call   1a2 <printint>
        ap++;
 2f0:	83 c7 04             	add    $0x4,%edi
 2f3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 2f6:	83 c4 10             	add    $0x10,%esp
      state = 0;
 2f9:	be 00 00 00 00       	mov    $0x0,%esi
 2fe:	e9 56 ff ff ff       	jmp    259 <printf+0x2c>
        s = (char*)*ap;
 303:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 306:	8b 30                	mov    (%eax),%esi
        ap++;
 308:	83 c0 04             	add    $0x4,%eax
 30b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 30e:	85 f6                	test   %esi,%esi
 310:	75 15                	jne    327 <printf+0xfa>
          s = "(null)";
 312:	be 47 04 00 00       	mov    $0x447,%esi
 317:	eb 0e                	jmp    327 <printf+0xfa>
          putc(fd, *s);
 319:	0f be d2             	movsbl %dl,%edx
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	e8 64 fe ff ff       	call   188 <putc>
          s++;
 324:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 327:	0f b6 16             	movzbl (%esi),%edx
 32a:	84 d2                	test   %dl,%dl
 32c:	75 eb                	jne    319 <printf+0xec>
      state = 0;
 32e:	be 00 00 00 00       	mov    $0x0,%esi
 333:	e9 21 ff ff ff       	jmp    259 <printf+0x2c>
        putc(fd, *ap);
 338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 33b:	0f be 17             	movsbl (%edi),%edx
 33e:	8b 45 08             	mov    0x8(%ebp),%eax
 341:	e8 42 fe ff ff       	call   188 <putc>
        ap++;
 346:	83 c7 04             	add    $0x4,%edi
 349:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 34c:	be 00 00 00 00       	mov    $0x0,%esi
 351:	e9 03 ff ff ff       	jmp    259 <printf+0x2c>
        putc(fd, c);
 356:	89 fa                	mov    %edi,%edx
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	e8 28 fe ff ff       	call   188 <putc>
      state = 0;
 360:	be 00 00 00 00       	mov    $0x0,%esi
 365:	e9 ef fe ff ff       	jmp    259 <printf+0x2c>
        putc(fd, '%');
 36a:	ba 25 00 00 00       	mov    $0x25,%edx
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	e8 11 fe ff ff       	call   188 <putc>
        putc(fd, c);
 377:	89 fa                	mov    %edi,%edx
 379:	8b 45 08             	mov    0x8(%ebp),%eax
 37c:	e8 07 fe ff ff       	call   188 <putc>
      state = 0;
 381:	be 00 00 00 00       	mov    $0x0,%esi
 386:	e9 ce fe ff ff       	jmp    259 <printf+0x2c>
    }
  }
}
 38b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 38e:	5b                   	pop    %ebx
 38f:	5e                   	pop    %esi
 390:	5f                   	pop    %edi
 391:	5d                   	pop    %ebp
 392:	c3                   	ret    
