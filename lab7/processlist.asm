
_processlist:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "param.h"
#include "processesinfo.h"
#include "user.h"

int main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	81 ec 30 03 00 00    	sub    $0x330,%esp
    struct processes_info info;
    info.num_processes = -9999;  // to make sure getprocessesinfo() doesn't
   d:	c7 44 24 2c f1 d8 ff 	movl   $0xffffd8f1,0x2c(%esp)
  14:	ff 
                                 // depend on its initial value
    getprocessesinfo(&info);
  15:	8d 44 24 2c          	lea    0x2c(%esp),%eax
  19:	89 04 24             	mov    %eax,(%esp)
  1c:	e8 62 01 00 00       	call   183 <getprocessesinfo>
    if (info.num_processes < 0) {
  21:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
  26:	79 14                	jns    3c <main+0x3c>
        printf(1, "ERROR: negative number of processes!\n"
  28:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
  2f:	00 
  30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  37:	e8 10 02 00 00       	call   24c <printf>
                  "Myabe getprocessesinfo() assumes that num_processes is\n"
                  "always initialized to 0?\n");
    }
    printf(1, "%d running processes\n", info.num_processes);
  3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  40:	89 44 24 08          	mov    %eax,0x8(%esp)
  44:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
  4b:	00 
  4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  53:	e8 f4 01 00 00       	call   24c <printf>
    printf(1, "PID\tTICKETS\tTIMES-SCHEDULED\n");
  58:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
  5f:	00 
  60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  67:	e8 e0 01 00 00       	call   24c <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  71:	eb 35                	jmp    a8 <main+0xa8>
        printf(1, "%d\t%d\t%d\n", info.pids[i], info.tickets[i], info.times_scheduled[i]);
  73:	8b 84 9c 30 01 00 00 	mov    0x130(%esp,%ebx,4),%eax
  7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  7e:	8b 84 9c 30 02 00 00 	mov    0x230(%esp,%ebx,4),%eax
  85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  89:	8b 44 9c 30          	mov    0x30(%esp,%ebx,4),%eax
  8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  91:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 a7 01 00 00       	call   24c <printf>
    for (int i = 0; i < info.num_processes; ++i) {
  a5:	83 c3 01             	add    $0x1,%ebx
  a8:	39 5c 24 2c          	cmp    %ebx,0x2c(%esp)
  ac:	7f c5                	jg     73 <main+0x73>
    }
    exit();
  ae:	e8 08 00 00 00       	call   bb <exit>

000000b3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
  b3:	b8 01 00 00 00       	mov    $0x1,%eax
  b8:	cd 40                	int    $0x40
  ba:	c3                   	ret    

000000bb <exit>:
SYSCALL(exit)
  bb:	b8 02 00 00 00       	mov    $0x2,%eax
  c0:	cd 40                	int    $0x40
  c2:	c3                   	ret    

000000c3 <wait>:
SYSCALL(wait)
  c3:	b8 03 00 00 00       	mov    $0x3,%eax
  c8:	cd 40                	int    $0x40
  ca:	c3                   	ret    

000000cb <pipe>:
SYSCALL(pipe)
  cb:	b8 04 00 00 00       	mov    $0x4,%eax
  d0:	cd 40                	int    $0x40
  d2:	c3                   	ret    

000000d3 <read>:
SYSCALL(read)
  d3:	b8 05 00 00 00       	mov    $0x5,%eax
  d8:	cd 40                	int    $0x40
  da:	c3                   	ret    

000000db <write>:
SYSCALL(write)
  db:	b8 10 00 00 00       	mov    $0x10,%eax
  e0:	cd 40                	int    $0x40
  e2:	c3                   	ret    

000000e3 <close>:
SYSCALL(close)
  e3:	b8 15 00 00 00       	mov    $0x15,%eax
  e8:	cd 40                	int    $0x40
  ea:	c3                   	ret    

000000eb <kill>:
SYSCALL(kill)
  eb:	b8 06 00 00 00       	mov    $0x6,%eax
  f0:	cd 40                	int    $0x40
  f2:	c3                   	ret    

000000f3 <exec>:
SYSCALL(exec)
  f3:	b8 07 00 00 00       	mov    $0x7,%eax
  f8:	cd 40                	int    $0x40
  fa:	c3                   	ret    

000000fb <open>:
SYSCALL(open)
  fb:	b8 0f 00 00 00       	mov    $0xf,%eax
 100:	cd 40                	int    $0x40
 102:	c3                   	ret    

00000103 <mknod>:
SYSCALL(mknod)
 103:	b8 11 00 00 00       	mov    $0x11,%eax
 108:	cd 40                	int    $0x40
 10a:	c3                   	ret    

0000010b <unlink>:
SYSCALL(unlink)
 10b:	b8 12 00 00 00       	mov    $0x12,%eax
 110:	cd 40                	int    $0x40
 112:	c3                   	ret    

00000113 <fstat>:
SYSCALL(fstat)
 113:	b8 08 00 00 00       	mov    $0x8,%eax
 118:	cd 40                	int    $0x40
 11a:	c3                   	ret    

0000011b <link>:
SYSCALL(link)
 11b:	b8 13 00 00 00       	mov    $0x13,%eax
 120:	cd 40                	int    $0x40
 122:	c3                   	ret    

00000123 <mkdir>:
SYSCALL(mkdir)
 123:	b8 14 00 00 00       	mov    $0x14,%eax
 128:	cd 40                	int    $0x40
 12a:	c3                   	ret    

0000012b <chdir>:
SYSCALL(chdir)
 12b:	b8 09 00 00 00       	mov    $0x9,%eax
 130:	cd 40                	int    $0x40
 132:	c3                   	ret    

00000133 <dup>:
SYSCALL(dup)
 133:	b8 0a 00 00 00       	mov    $0xa,%eax
 138:	cd 40                	int    $0x40
 13a:	c3                   	ret    

0000013b <getpid>:
SYSCALL(getpid)
 13b:	b8 0b 00 00 00       	mov    $0xb,%eax
 140:	cd 40                	int    $0x40
 142:	c3                   	ret    

00000143 <sbrk>:
SYSCALL(sbrk)
 143:	b8 0c 00 00 00       	mov    $0xc,%eax
 148:	cd 40                	int    $0x40
 14a:	c3                   	ret    

0000014b <sleep>:
SYSCALL(sleep)
 14b:	b8 0d 00 00 00       	mov    $0xd,%eax
 150:	cd 40                	int    $0x40
 152:	c3                   	ret    

00000153 <uptime>:
SYSCALL(uptime)
 153:	b8 0e 00 00 00       	mov    $0xe,%eax
 158:	cd 40                	int    $0x40
 15a:	c3                   	ret    

0000015b <yield>:
SYSCALL(yield)
 15b:	b8 16 00 00 00       	mov    $0x16,%eax
 160:	cd 40                	int    $0x40
 162:	c3                   	ret    

00000163 <shutdown>:
SYSCALL(shutdown)
 163:	b8 17 00 00 00       	mov    $0x17,%eax
 168:	cd 40                	int    $0x40
 16a:	c3                   	ret    

0000016b <writecount>:
SYSCALL(writecount)
 16b:	b8 18 00 00 00       	mov    $0x18,%eax
 170:	cd 40                	int    $0x40
 172:	c3                   	ret    

00000173 <setwritecount>:
SYSCALL(setwritecount)
 173:	b8 19 00 00 00       	mov    $0x19,%eax
 178:	cd 40                	int    $0x40
 17a:	c3                   	ret    

0000017b <settickets>:
SYSCALL(settickets)
 17b:	b8 1a 00 00 00       	mov    $0x1a,%eax
 180:	cd 40                	int    $0x40
 182:	c3                   	ret    

00000183 <getprocessesinfo>:
SYSCALL(getprocessesinfo)
 183:	b8 1b 00 00 00       	mov    $0x1b,%eax
 188:	cd 40                	int    $0x40
 18a:	c3                   	ret    

0000018b <getpagetableentry>:
SYSCALL(getpagetableentry)
 18b:	b8 1c 00 00 00       	mov    $0x1c,%eax
 190:	cd 40                	int    $0x40
 192:	c3                   	ret    

00000193 <isphysicalpagefree>:
SYSCALL(isphysicalpagefree)
 193:	b8 1d 00 00 00       	mov    $0x1d,%eax
 198:	cd 40                	int    $0x40
 19a:	c3                   	ret    

0000019b <dumppagetable>:
 19b:	b8 1e 00 00 00       	mov    $0x1e,%eax
 1a0:	cd 40                	int    $0x40
 1a2:	c3                   	ret    
 1a3:	66 90                	xchg   %ax,%ax
 1a5:	66 90                	xchg   %ax,%ax
 1a7:	66 90                	xchg   %ax,%ax
 1a9:	66 90                	xchg   %ax,%ax
 1ab:	66 90                	xchg   %ax,%ax
 1ad:	66 90                	xchg   %ax,%ax
 1af:	90                   	nop

000001b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 1b0:	55                   	push   %ebp
 1b1:	89 e5                	mov    %esp,%ebp
 1b3:	83 ec 18             	sub    $0x18,%esp
 1b6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 1b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c0:	00 
 1c1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 1c4:	89 54 24 04          	mov    %edx,0x4(%esp)
 1c8:	89 04 24             	mov    %eax,(%esp)
 1cb:	e8 0b ff ff ff       	call   db <write>
}
 1d0:	c9                   	leave  
 1d1:	c3                   	ret    

000001d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	57                   	push   %edi
 1d6:	56                   	push   %esi
 1d7:	53                   	push   %ebx
 1d8:	83 ec 2c             	sub    $0x2c,%esp
 1db:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 1dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 1e1:	0f 95 c3             	setne  %bl
 1e4:	89 d0                	mov    %edx,%eax
 1e6:	c1 e8 1f             	shr    $0x1f,%eax
 1e9:	84 c3                	test   %al,%bl
 1eb:	74 0b                	je     1f8 <printint+0x26>
    neg = 1;
    x = -xx;
 1ed:	f7 da                	neg    %edx
    neg = 1;
 1ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
 1f6:	eb 07                	jmp    1ff <printint+0x2d>
  neg = 0;
 1f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 1ff:	be 00 00 00 00       	mov    $0x0,%esi
  do{
    buf[i++] = digits[x % base];
 204:	8d 5e 01             	lea    0x1(%esi),%ebx
 207:	89 d0                	mov    %edx,%eax
 209:	ba 00 00 00 00       	mov    $0x0,%edx
 20e:	f7 f1                	div    %ecx
 210:	0f b6 92 64 04 00 00 	movzbl 0x464(%edx),%edx
 217:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 21b:	89 c2                	mov    %eax,%edx
    buf[i++] = digits[x % base];
 21d:	89 de                	mov    %ebx,%esi
  }while((x /= base) != 0);
 21f:	85 c0                	test   %eax,%eax
 221:	75 e1                	jne    204 <printint+0x32>
  if(neg)
 223:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 227:	74 16                	je     23f <printint+0x6d>
    buf[i++] = '-';
 229:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 22e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 231:	eb 0c                	jmp    23f <printint+0x6d>

  while(--i >= 0)
    putc(fd, buf[i]);
 233:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 238:	89 f8                	mov    %edi,%eax
 23a:	e8 71 ff ff ff       	call   1b0 <putc>
  while(--i >= 0)
 23f:	83 eb 01             	sub    $0x1,%ebx
 242:	79 ef                	jns    233 <printint+0x61>
}
 244:	83 c4 2c             	add    $0x2c,%esp
 247:	5b                   	pop    %ebx
 248:	5e                   	pop    %esi
 249:	5f                   	pop    %edi
 24a:	5d                   	pop    %ebp
 24b:	c3                   	ret    

0000024c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 24c:	55                   	push   %ebp
 24d:	89 e5                	mov    %esp,%ebp
 24f:	57                   	push   %edi
 250:	56                   	push   %esi
 251:	53                   	push   %ebx
 252:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 255:	8d 45 10             	lea    0x10(%ebp),%eax
 258:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 25b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i = 0; fmt[i]; i++){
 260:	be 00 00 00 00       	mov    $0x0,%esi
 265:	e9 23 01 00 00       	jmp    38d <printf+0x141>
    c = fmt[i] & 0xff;
 26a:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 26d:	85 ff                	test   %edi,%edi
 26f:	75 19                	jne    28a <printf+0x3e>
      if(c == '%'){
 271:	83 f8 25             	cmp    $0x25,%eax
 274:	0f 84 0b 01 00 00    	je     385 <printf+0x139>
        state = '%';
      } else {
        putc(fd, c);
 27a:	0f be d3             	movsbl %bl,%edx
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	e8 2b ff ff ff       	call   1b0 <putc>
 285:	e9 00 01 00 00       	jmp    38a <printf+0x13e>
      }
    } else if(state == '%'){
 28a:	83 ff 25             	cmp    $0x25,%edi
 28d:	0f 85 f7 00 00 00    	jne    38a <printf+0x13e>
      if(c == 'd'){
 293:	83 f8 64             	cmp    $0x64,%eax
 296:	75 26                	jne    2be <printf+0x72>
        printint(fd, *ap, 10, 1);
 298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 29b:	8b 10                	mov    (%eax),%edx
 29d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ac:	e8 21 ff ff ff       	call   1d2 <printint>
        ap++;
 2b1:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 2b5:	66 bf 00 00          	mov    $0x0,%di
 2b9:	e9 cc 00 00 00       	jmp    38a <printf+0x13e>
      } else if(c == 'x' || c == 'p'){
 2be:	83 f8 78             	cmp    $0x78,%eax
 2c1:	0f 94 c1             	sete   %cl
 2c4:	83 f8 70             	cmp    $0x70,%eax
 2c7:	0f 94 c2             	sete   %dl
 2ca:	08 d1                	or     %dl,%cl
 2cc:	74 27                	je     2f5 <printf+0xa9>
        printint(fd, *ap, 16, 0);
 2ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d1:	8b 10                	mov    (%eax),%edx
 2d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2da:	b9 10 00 00 00       	mov    $0x10,%ecx
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	e8 eb fe ff ff       	call   1d2 <printint>
        ap++;
 2e7:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 2eb:	bf 00 00 00 00       	mov    $0x0,%edi
 2f0:	e9 95 00 00 00       	jmp    38a <printf+0x13e>
      } else if(c == 's'){
 2f5:	83 f8 73             	cmp    $0x73,%eax
 2f8:	75 37                	jne    331 <printf+0xe5>
        s = (char*)*ap;
 2fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2fd:	8b 18                	mov    (%eax),%ebx
        ap++;
 2ff:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
        if(s == 0)
 303:	85 db                	test   %ebx,%ebx
 305:	75 19                	jne    320 <printf+0xd4>
          s = "(null)";
 307:	bb 5d 04 00 00       	mov    $0x45d,%ebx
 30c:	8b 7d 08             	mov    0x8(%ebp),%edi
 30f:	eb 12                	jmp    323 <printf+0xd7>
          putc(fd, *s);
 311:	0f be d2             	movsbl %dl,%edx
 314:	89 f8                	mov    %edi,%eax
 316:	e8 95 fe ff ff       	call   1b0 <putc>
          s++;
 31b:	83 c3 01             	add    $0x1,%ebx
 31e:	eb 03                	jmp    323 <printf+0xd7>
 320:	8b 7d 08             	mov    0x8(%ebp),%edi
        while(*s != 0){
 323:	0f b6 13             	movzbl (%ebx),%edx
 326:	84 d2                	test   %dl,%dl
 328:	75 e7                	jne    311 <printf+0xc5>
      state = 0;
 32a:	bf 00 00 00 00       	mov    $0x0,%edi
 32f:	eb 59                	jmp    38a <printf+0x13e>
      } else if(c == 'c'){
 331:	83 f8 63             	cmp    $0x63,%eax
 334:	75 19                	jne    34f <printf+0x103>
        putc(fd, *ap);
 336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 339:	0f be 10             	movsbl (%eax),%edx
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	e8 6c fe ff ff       	call   1b0 <putc>
        ap++;
 344:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      state = 0;
 348:	bf 00 00 00 00       	mov    $0x0,%edi
 34d:	eb 3b                	jmp    38a <printf+0x13e>
      } else if(c == '%'){
 34f:	83 f8 25             	cmp    $0x25,%eax
 352:	75 12                	jne    366 <printf+0x11a>
        putc(fd, c);
 354:	0f be d3             	movsbl %bl,%edx
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	e8 51 fe ff ff       	call   1b0 <putc>
      state = 0;
 35f:	bf 00 00 00 00       	mov    $0x0,%edi
 364:	eb 24                	jmp    38a <printf+0x13e>
        putc(fd, '%');
 366:	ba 25 00 00 00       	mov    $0x25,%edx
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
 36e:	e8 3d fe ff ff       	call   1b0 <putc>
        putc(fd, c);
 373:	0f be d3             	movsbl %bl,%edx
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	e8 32 fe ff ff       	call   1b0 <putc>
      state = 0;
 37e:	bf 00 00 00 00       	mov    $0x0,%edi
 383:	eb 05                	jmp    38a <printf+0x13e>
        state = '%';
 385:	bf 25 00 00 00       	mov    $0x25,%edi
  for(i = 0; fmt[i]; i++){
 38a:	83 c6 01             	add    $0x1,%esi
 38d:	89 f0                	mov    %esi,%eax
 38f:	03 45 0c             	add    0xc(%ebp),%eax
 392:	0f b6 18             	movzbl (%eax),%ebx
 395:	84 db                	test   %bl,%bl
 397:	0f 85 cd fe ff ff    	jne    26a <printf+0x1e>
    }
  }
}
 39d:	83 c4 1c             	add    $0x1c,%esp
 3a0:	5b                   	pop    %ebx
 3a1:	5e                   	pop    %esi
 3a2:	5f                   	pop    %edi
 3a3:	5d                   	pop    %ebp
 3a4:	c3                   	ret    
