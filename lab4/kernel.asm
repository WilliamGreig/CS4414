
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 54 11 80       	mov    $0x801154d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7f 2a 10 80       	mov    $0x80102a7f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 20 a5 10 80       	push   $0x8010a520
80100046:	e8 6c 3b 00 00       	call   80103bb7 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 70 ec 10 80    	mov    0x8010ec70,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 20 a5 10 80       	push   $0x8010a520
8010007c:	e8 9b 3b 00 00       	call   80103c1c <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 17 39 00 00       	call   801039a3 <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 6c ec 10 80    	mov    0x8010ec6c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 20 a5 10 80       	push   $0x8010a520
801000ca:	e8 4d 3b 00 00       	call   80103c1c <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 c9 38 00 00       	call   801039a3 <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 60 67 10 80       	push   $0x80106760
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 67 10 80       	push   $0x80106771
80100100:	68 20 a5 10 80       	push   $0x8010a520
80100105:	e8 71 39 00 00       	call   80103a7b <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 6c ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec6c
80100111:	ec 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 70 ec 10 80 1c 	movl   $0x8010ec1c,0x8010ec70
8010011b:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 54 a5 10 80       	mov    $0x8010a554,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 78 67 10 80       	push   $0x80106778
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 28 38 00 00       	call   80103970 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb 1c ec 10 80    	cmp    $0x8010ec1c,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 62 1c 00 00       	call   80101df7 <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 80 38 00 00       	call   80103a2d <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 37 1c 00 00       	call   80101df7 <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 7f 67 10 80       	push   $0x8010677f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 44 38 00 00       	call   80103a2d <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 f9 37 00 00       	call   801039f2 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100200:	e8 b2 39 00 00       	call   80103bb7 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 1c ec 10 80 	movl   $0x8010ec1c,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 70 ec 10 80       	mov    0x8010ec70,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 70 ec 10 80    	mov    %ebx,0x8010ec70
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 20 a5 10 80       	push   $0x8010a520
8010024c:	e8 cb 39 00 00       	call   80103c1c <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 67 10 80       	push   $0x80106786
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 b1 13 00 00       	call   80101631 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
8010028a:	e8 28 39 00 00       	call   80103bb7 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029f:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 6e 2f 00 00       	call   8010321a <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 ef 10 80       	push   $0x8010ef20
801002ba:	68 00 ef 10 80       	push   $0x8010ef00
801002bf:	e8 f8 33 00 00       	call   801036bc <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ef 10 80       	push   $0x8010ef20
801002d1:	e8 46 39 00 00       	call   80103c1c <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 91 12 00 00       	call   8010156f <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 00 ef 10 80    	mov    %edx,0x8010ef00
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 92 80 ee 10 80 	movzbl -0x7fef1180(%edx),%edx
80100303:	0f be ca             	movsbl %dl,%ecx
    if(c == C('D')){  // EOF
80100306:	80 fa 04             	cmp    $0x4,%dl
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 16                	mov    %dl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 f9 0a             	cmp    $0xa,%ecx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 00 ef 10 80       	mov    %eax,0x8010ef00
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 ef 10 80       	push   $0x8010ef20
80100331:	e8 e6 38 00 00       	call   80103c1c <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 31 12 00 00       	call   8010156f <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 ef 10 80 00 	movl   $0x0,0x8010ef54
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 33 20 00 00       	call   80102392 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 67 10 80       	push   $0x8010678d
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 8f 71 10 80 	movl   $0x8010718f,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 02 37 00 00       	call   80103a96 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 a1 67 10 80       	push   $0x801067a1
801003aa:	e8 58 02 00 00       	call   80100607 <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 ef 10 80 01 	movl   $0x1,0x8010ef58
801003c1:	00 00 00 
  for(;;)
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c3                	mov    %eax,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	bf d4 03 00 00       	mov    $0x3d4,%edi
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 fa                	mov    %edi,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801003e3:	89 ca                	mov    %ecx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f0             	movzbl %al,%esi
801003e9:	c1 e6 08             	shl    $0x8,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 fa                	mov    %edi,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 ca                	mov    %ecx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f1                	or     %esi,%ecx
  if(c == '\n')
801003fc:	83 fb 0a             	cmp    $0xa,%ebx
801003ff:	74 60                	je     80100461 <cgaputc+0x9b>
  else if(c == BACKSPACE){
80100401:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
80100407:	74 79                	je     80100482 <cgaputc+0xbc>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100409:	0f b6 c3             	movzbl %bl,%eax
8010040c:	8d 59 01             	lea    0x1(%ecx),%ebx
8010040f:	80 cc 07             	or     $0x7,%ah
80100412:	66 89 84 09 00 80 0b 	mov    %ax,-0x7ff48000(%ecx,%ecx,1)
80100419:	80 
  if(pos < 0 || pos > 25*80)
8010041a:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100420:	77 6d                	ja     8010048f <cgaputc+0xc9>
  if((pos/80) >= 24){  // Scroll up.
80100422:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100428:	7f 72                	jg     8010049c <cgaputc+0xd6>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010042a:	be d4 03 00 00       	mov    $0x3d4,%esi
8010042f:	b8 0e 00 00 00       	mov    $0xe,%eax
80100434:	89 f2                	mov    %esi,%edx
80100436:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
80100437:	0f b6 c7             	movzbl %bh,%eax
8010043a:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010043f:	89 ca                	mov    %ecx,%edx
80100441:	ee                   	out    %al,(%dx)
80100442:	b8 0f 00 00 00       	mov    $0xf,%eax
80100447:	89 f2                	mov    %esi,%edx
80100449:	ee                   	out    %al,(%dx)
8010044a:	89 d8                	mov    %ebx,%eax
8010044c:	89 ca                	mov    %ecx,%edx
8010044e:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
8010044f:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100456:	80 20 07 
}
80100459:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010045c:	5b                   	pop    %ebx
8010045d:	5e                   	pop    %esi
8010045e:	5f                   	pop    %edi
8010045f:	5d                   	pop    %ebp
80100460:	c3                   	ret    
    pos += 80 - pos%80;
80100461:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100466:	89 c8                	mov    %ecx,%eax
80100468:	f7 ea                	imul   %edx
8010046a:	c1 fa 05             	sar    $0x5,%edx
8010046d:	8d 04 92             	lea    (%edx,%edx,4),%eax
80100470:	c1 e0 04             	shl    $0x4,%eax
80100473:	89 ca                	mov    %ecx,%edx
80100475:	29 c2                	sub    %eax,%edx
80100477:	bb 50 00 00 00       	mov    $0x50,%ebx
8010047c:	29 d3                	sub    %edx,%ebx
8010047e:	01 cb                	add    %ecx,%ebx
80100480:	eb 98                	jmp    8010041a <cgaputc+0x54>
    if(pos > 0) --pos;
80100482:	85 c9                	test   %ecx,%ecx
80100484:	7e 05                	jle    8010048b <cgaputc+0xc5>
80100486:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100489:	eb 8f                	jmp    8010041a <cgaputc+0x54>
  pos |= inb(CRTPORT+1);
8010048b:	89 cb                	mov    %ecx,%ebx
8010048d:	eb 8b                	jmp    8010041a <cgaputc+0x54>
    panic("pos under/overflow");
8010048f:	83 ec 0c             	sub    $0xc,%esp
80100492:	68 a5 67 10 80       	push   $0x801067a5
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 28 38 00 00       	call   80103cdb <memmove>
    pos -= 80;
801004b3:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004b6:	b8 80 07 00 00       	mov    $0x780,%eax
801004bb:	29 d8                	sub    %ebx,%eax
801004bd:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004c4:	83 c4 0c             	add    $0xc,%esp
801004c7:	01 c0                	add    %eax,%eax
801004c9:	50                   	push   %eax
801004ca:	6a 00                	push   $0x0
801004cc:	52                   	push   %edx
801004cd:	e8 91 37 00 00       	call   80103c63 <memset>
801004d2:	83 c4 10             	add    $0x10,%esp
801004d5:	e9 50 ff ff ff       	jmp    8010042a <cgaputc+0x64>

801004da <consputc>:
  if(panicked){
801004da:	83 3d 58 ef 10 80 00 	cmpl   $0x0,0x8010ef58
801004e1:	74 03                	je     801004e6 <consputc+0xc>
  asm volatile("cli");
801004e3:	fa                   	cli    
    for(;;)
801004e4:	eb fe                	jmp    801004e4 <consputc+0xa>
{
801004e6:	55                   	push   %ebp
801004e7:	89 e5                	mov    %esp,%ebp
801004e9:	53                   	push   %ebx
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004ef:	3d 00 01 00 00       	cmp    $0x100,%eax
801004f4:	74 18                	je     8010050e <consputc+0x34>
    uartputc(c);
801004f6:	83 ec 0c             	sub    $0xc,%esp
801004f9:	50                   	push   %eax
801004fa:	e8 cc 4b 00 00       	call   801050cb <uartputc>
801004ff:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100502:	89 d8                	mov    %ebx,%eax
80100504:	e8 bd fe ff ff       	call   801003c6 <cgaputc>
}
80100509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010050c:	c9                   	leave  
8010050d:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010050e:	83 ec 0c             	sub    $0xc,%esp
80100511:	6a 08                	push   $0x8
80100513:	e8 b3 4b 00 00       	call   801050cb <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 a7 4b 00 00       	call   801050cb <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 9b 4b 00 00       	call   801050cb <uartputc>
80100530:	83 c4 10             	add    $0x10,%esp
80100533:	eb cd                	jmp    80100502 <consputc+0x28>

80100535 <printint>:
{
80100535:	55                   	push   %ebp
80100536:	89 e5                	mov    %esp,%ebp
80100538:	57                   	push   %edi
80100539:	56                   	push   %esi
8010053a:	53                   	push   %ebx
8010053b:	83 ec 2c             	sub    $0x2c,%esp
8010053e:	89 d6                	mov    %edx,%esi
80100540:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100543:	85 c9                	test   %ecx,%ecx
80100545:	74 0c                	je     80100553 <printint+0x1e>
80100547:	89 c7                	mov    %eax,%edi
80100549:	c1 ef 1f             	shr    $0x1f,%edi
8010054c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
8010054f:	85 c0                	test   %eax,%eax
80100551:	78 38                	js     8010058b <printint+0x56>
    x = xx;
80100553:	89 c1                	mov    %eax,%ecx
  i = 0;
80100555:	bb 00 00 00 00       	mov    $0x0,%ebx
    buf[i++] = digits[x % base];
8010055a:	89 c8                	mov    %ecx,%eax
8010055c:	ba 00 00 00 00       	mov    $0x0,%edx
80100561:	f7 f6                	div    %esi
80100563:	89 df                	mov    %ebx,%edi
80100565:	83 c3 01             	add    $0x1,%ebx
80100568:	0f b6 92 d0 67 10 80 	movzbl -0x7fef9830(%edx),%edx
8010056f:	88 54 3d d8          	mov    %dl,-0x28(%ebp,%edi,1)
  }while((x /= base) != 0);
80100573:	89 ca                	mov    %ecx,%edx
80100575:	89 c1                	mov    %eax,%ecx
80100577:	39 d6                	cmp    %edx,%esi
80100579:	76 df                	jbe    8010055a <printint+0x25>
  if(sign)
8010057b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010057f:	74 1a                	je     8010059b <printint+0x66>
    buf[i++] = '-';
80100581:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100586:	8d 5f 02             	lea    0x2(%edi),%ebx
80100589:	eb 10                	jmp    8010059b <printint+0x66>
    x = -xx;
8010058b:	f7 d8                	neg    %eax
8010058d:	89 c1                	mov    %eax,%ecx
8010058f:	eb c4                	jmp    80100555 <printint+0x20>
    consputc(buf[i]);
80100591:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
80100596:	e8 3f ff ff ff       	call   801004da <consputc>
  while(--i >= 0)
8010059b:	83 eb 01             	sub    $0x1,%ebx
8010059e:	79 f1                	jns    80100591 <printint+0x5c>
}
801005a0:	83 c4 2c             	add    $0x2c,%esp
801005a3:	5b                   	pop    %ebx
801005a4:	5e                   	pop    %esi
801005a5:	5f                   	pop    %edi
801005a6:	5d                   	pop    %ebp
801005a7:	c3                   	ret    

801005a8 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005a8:	55                   	push   %ebp
801005a9:	89 e5                	mov    %esp,%ebp
801005ab:	57                   	push   %edi
801005ac:	56                   	push   %esi
801005ad:	53                   	push   %ebx
801005ae:	83 ec 18             	sub    $0x18,%esp
801005b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b4:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005b7:	ff 75 08             	push   0x8(%ebp)
801005ba:	e8 72 10 00 00       	call   80101631 <iunlock>
  acquire(&cons.lock);
801005bf:	c7 04 24 20 ef 10 80 	movl   $0x8010ef20,(%esp)
801005c6:	e8 ec 35 00 00       	call   80103bb7 <acquire>
  for(i = 0; i < n; i++)
801005cb:	83 c4 10             	add    $0x10,%esp
801005ce:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d3:	eb 0c                	jmp    801005e1 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d5:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005d9:	e8 fc fe ff ff       	call   801004da <consputc>
  for(i = 0; i < n; i++)
801005de:	83 c3 01             	add    $0x1,%ebx
801005e1:	39 f3                	cmp    %esi,%ebx
801005e3:	7c f0                	jl     801005d5 <consolewrite+0x2d>
  release(&cons.lock);
801005e5:	83 ec 0c             	sub    $0xc,%esp
801005e8:	68 20 ef 10 80       	push   $0x8010ef20
801005ed:	e8 2a 36 00 00       	call   80103c1c <release>
  ilock(ip);
801005f2:	83 c4 04             	add    $0x4,%esp
801005f5:	ff 75 08             	push   0x8(%ebp)
801005f8:	e8 72 0f 00 00       	call   8010156f <ilock>

  return n;
}
801005fd:	89 f0                	mov    %esi,%eax
801005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100602:	5b                   	pop    %ebx
80100603:	5e                   	pop    %esi
80100604:	5f                   	pop    %edi
80100605:	5d                   	pop    %ebp
80100606:	c3                   	ret    

80100607 <cprintf>:
{
80100607:	55                   	push   %ebp
80100608:	89 e5                	mov    %esp,%ebp
8010060a:	57                   	push   %edi
8010060b:	56                   	push   %esi
8010060c:	53                   	push   %ebx
8010060d:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100610:	a1 54 ef 10 80       	mov    0x8010ef54,%eax
80100615:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
80100618:	85 c0                	test   %eax,%eax
8010061a:	75 10                	jne    8010062c <cprintf+0x25>
  if (fmt == 0)
8010061c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100620:	74 1c                	je     8010063e <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100622:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100625:	be 00 00 00 00       	mov    $0x0,%esi
8010062a:	eb 27                	jmp    80100653 <cprintf+0x4c>
    acquire(&cons.lock);
8010062c:	83 ec 0c             	sub    $0xc,%esp
8010062f:	68 20 ef 10 80       	push   $0x8010ef20
80100634:	e8 7e 35 00 00       	call   80103bb7 <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 bf 67 10 80       	push   $0x801067bf
80100646:	e8 fd fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064b:	e8 8a fe ff ff       	call   801004da <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100650:	83 c6 01             	add    $0x1,%esi
80100653:	8b 55 08             	mov    0x8(%ebp),%edx
80100656:	0f b6 04 32          	movzbl (%edx,%esi,1),%eax
8010065a:	85 c0                	test   %eax,%eax
8010065c:	0f 84 b1 00 00 00    	je     80100713 <cprintf+0x10c>
    if(c != '%'){
80100662:	83 f8 25             	cmp    $0x25,%eax
80100665:	75 e4                	jne    8010064b <cprintf+0x44>
    c = fmt[++i] & 0xff;
80100667:	83 c6 01             	add    $0x1,%esi
8010066a:	0f b6 1c 32          	movzbl (%edx,%esi,1),%ebx
    if(c == 0)
8010066e:	85 db                	test   %ebx,%ebx
80100670:	0f 84 9d 00 00 00    	je     80100713 <cprintf+0x10c>
    switch(c){
80100676:	83 fb 70             	cmp    $0x70,%ebx
80100679:	74 2e                	je     801006a9 <cprintf+0xa2>
8010067b:	7f 22                	jg     8010069f <cprintf+0x98>
8010067d:	83 fb 25             	cmp    $0x25,%ebx
80100680:	74 6c                	je     801006ee <cprintf+0xe7>
80100682:	83 fb 64             	cmp    $0x64,%ebx
80100685:	75 76                	jne    801006fd <cprintf+0xf6>
      printint(*argp++, 10, 1);
80100687:	8d 5f 04             	lea    0x4(%edi),%ebx
8010068a:	8b 07                	mov    (%edi),%eax
8010068c:	b9 01 00 00 00       	mov    $0x1,%ecx
80100691:	ba 0a 00 00 00       	mov    $0xa,%edx
80100696:	e8 9a fe ff ff       	call   80100535 <printint>
8010069b:	89 df                	mov    %ebx,%edi
      break;
8010069d:	eb b1                	jmp    80100650 <cprintf+0x49>
    switch(c){
8010069f:	83 fb 73             	cmp    $0x73,%ebx
801006a2:	74 1d                	je     801006c1 <cprintf+0xba>
801006a4:	83 fb 78             	cmp    $0x78,%ebx
801006a7:	75 54                	jne    801006fd <cprintf+0xf6>
      printint(*argp++, 16, 0);
801006a9:	8d 5f 04             	lea    0x4(%edi),%ebx
801006ac:	8b 07                	mov    (%edi),%eax
801006ae:	b9 00 00 00 00       	mov    $0x0,%ecx
801006b3:	ba 10 00 00 00       	mov    $0x10,%edx
801006b8:	e8 78 fe ff ff       	call   80100535 <printint>
801006bd:	89 df                	mov    %ebx,%edi
      break;
801006bf:	eb 8f                	jmp    80100650 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006c1:	8d 47 04             	lea    0x4(%edi),%eax
801006c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006c7:	8b 1f                	mov    (%edi),%ebx
801006c9:	85 db                	test   %ebx,%ebx
801006cb:	75 12                	jne    801006df <cprintf+0xd8>
        s = "(null)";
801006cd:	bb b8 67 10 80       	mov    $0x801067b8,%ebx
801006d2:	eb 0b                	jmp    801006df <cprintf+0xd8>
        consputc(*s);
801006d4:	0f be c0             	movsbl %al,%eax
801006d7:	e8 fe fd ff ff       	call   801004da <consputc>
      for(; *s; s++)
801006dc:	83 c3 01             	add    $0x1,%ebx
801006df:	0f b6 03             	movzbl (%ebx),%eax
801006e2:	84 c0                	test   %al,%al
801006e4:	75 ee                	jne    801006d4 <cprintf+0xcd>
      if((s = (char*)*argp++) == 0)
801006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801006e9:	e9 62 ff ff ff       	jmp    80100650 <cprintf+0x49>
      consputc('%');
801006ee:	b8 25 00 00 00       	mov    $0x25,%eax
801006f3:	e8 e2 fd ff ff       	call   801004da <consputc>
      break;
801006f8:	e9 53 ff ff ff       	jmp    80100650 <cprintf+0x49>
      consputc('%');
801006fd:	b8 25 00 00 00       	mov    $0x25,%eax
80100702:	e8 d3 fd ff ff       	call   801004da <consputc>
      consputc(c);
80100707:	89 d8                	mov    %ebx,%eax
80100709:	e8 cc fd ff ff       	call   801004da <consputc>
      break;
8010070e:	e9 3d ff ff ff       	jmp    80100650 <cprintf+0x49>
  if(locking)
80100713:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100717:	75 08                	jne    80100721 <cprintf+0x11a>
}
80100719:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010071c:	5b                   	pop    %ebx
8010071d:	5e                   	pop    %esi
8010071e:	5f                   	pop    %edi
8010071f:	5d                   	pop    %ebp
80100720:	c3                   	ret    
    release(&cons.lock);
80100721:	83 ec 0c             	sub    $0xc,%esp
80100724:	68 20 ef 10 80       	push   $0x8010ef20
80100729:	e8 ee 34 00 00       	call   80103c1c <release>
8010072e:	83 c4 10             	add    $0x10,%esp
}
80100731:	eb e6                	jmp    80100719 <cprintf+0x112>

80100733 <consoleintr>:
{
80100733:	55                   	push   %ebp
80100734:	89 e5                	mov    %esp,%ebp
80100736:	57                   	push   %edi
80100737:	56                   	push   %esi
80100738:	53                   	push   %ebx
80100739:	83 ec 18             	sub    $0x18,%esp
8010073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010073f:	68 20 ef 10 80       	push   $0x8010ef20
80100744:	e8 6e 34 00 00       	call   80103bb7 <acquire>
  while((c = getc()) >= 0){
80100749:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
8010074c:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
80100751:	eb 13                	jmp    80100766 <consoleintr+0x33>
    switch(c){
80100753:	83 ff 08             	cmp    $0x8,%edi
80100756:	0f 84 d9 00 00 00    	je     80100835 <consoleintr+0x102>
8010075c:	83 ff 10             	cmp    $0x10,%edi
8010075f:	75 25                	jne    80100786 <consoleintr+0x53>
80100761:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100766:	ff d3                	call   *%ebx
80100768:	89 c7                	mov    %eax,%edi
8010076a:	85 c0                	test   %eax,%eax
8010076c:	0f 88 f5 00 00 00    	js     80100867 <consoleintr+0x134>
    switch(c){
80100772:	83 ff 15             	cmp    $0x15,%edi
80100775:	0f 84 93 00 00 00    	je     8010080e <consoleintr+0xdb>
8010077b:	7e d6                	jle    80100753 <consoleintr+0x20>
8010077d:	83 ff 7f             	cmp    $0x7f,%edi
80100780:	0f 84 af 00 00 00    	je     80100835 <consoleintr+0x102>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100786:	85 ff                	test   %edi,%edi
80100788:	74 dc                	je     80100766 <consoleintr+0x33>
8010078a:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
8010078f:	89 c2                	mov    %eax,%edx
80100791:	2b 15 00 ef 10 80    	sub    0x8010ef00,%edx
80100797:	83 fa 7f             	cmp    $0x7f,%edx
8010079a:	77 ca                	ja     80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010079c:	83 ff 0d             	cmp    $0xd,%edi
8010079f:	0f 84 b8 00 00 00    	je     8010085d <consoleintr+0x12a>
        input.buf[input.e++ % INPUT_BUF] = c;
801007a5:	8d 50 01             	lea    0x1(%eax),%edx
801007a8:	89 15 08 ef 10 80    	mov    %edx,0x8010ef08
801007ae:	83 e0 7f             	and    $0x7f,%eax
801007b1:	89 f9                	mov    %edi,%ecx
801007b3:	88 88 80 ee 10 80    	mov    %cl,-0x7fef1180(%eax)
        consputc(c);
801007b9:	89 f8                	mov    %edi,%eax
801007bb:	e8 1a fd ff ff       	call   801004da <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007c0:	83 ff 0a             	cmp    $0xa,%edi
801007c3:	0f 94 c0             	sete   %al
801007c6:	83 ff 04             	cmp    $0x4,%edi
801007c9:	0f 94 c2             	sete   %dl
801007cc:	08 d0                	or     %dl,%al
801007ce:	75 10                	jne    801007e0 <consoleintr+0xad>
801007d0:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
801007d5:	83 e8 80             	sub    $0xffffff80,%eax
801007d8:	39 05 08 ef 10 80    	cmp    %eax,0x8010ef08
801007de:	75 86                	jne    80100766 <consoleintr+0x33>
          input.w = input.e;
801007e0:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
801007e5:	a3 04 ef 10 80       	mov    %eax,0x8010ef04
          wakeup(&input.r);
801007ea:	83 ec 0c             	sub    $0xc,%esp
801007ed:	68 00 ef 10 80       	push   $0x8010ef00
801007f2:	e8 2a 30 00 00       	call   80103821 <wakeup>
801007f7:	83 c4 10             	add    $0x10,%esp
801007fa:	e9 67 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        input.e--;
801007ff:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
80100804:	b8 00 01 00 00       	mov    $0x100,%eax
80100809:	e8 cc fc ff ff       	call   801004da <consputc>
      while(input.e != input.w &&
8010080e:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
80100813:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100819:	0f 84 47 ff ff ff    	je     80100766 <consoleintr+0x33>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	83 e8 01             	sub    $0x1,%eax
80100822:	89 c2                	mov    %eax,%edx
80100824:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100827:	80 ba 80 ee 10 80 0a 	cmpb   $0xa,-0x7fef1180(%edx)
8010082e:	75 cf                	jne    801007ff <consoleintr+0xcc>
80100830:	e9 31 ff ff ff       	jmp    80100766 <consoleintr+0x33>
      if(input.e != input.w){
80100835:	a1 08 ef 10 80       	mov    0x8010ef08,%eax
8010083a:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
80100840:	0f 84 20 ff ff ff    	je     80100766 <consoleintr+0x33>
        input.e--;
80100846:	83 e8 01             	sub    $0x1,%eax
80100849:	a3 08 ef 10 80       	mov    %eax,0x8010ef08
        consputc(BACKSPACE);
8010084e:	b8 00 01 00 00       	mov    $0x100,%eax
80100853:	e8 82 fc ff ff       	call   801004da <consputc>
80100858:	e9 09 ff ff ff       	jmp    80100766 <consoleintr+0x33>
        c = (c == '\r') ? '\n' : c;
8010085d:	bf 0a 00 00 00       	mov    $0xa,%edi
80100862:	e9 3e ff ff ff       	jmp    801007a5 <consoleintr+0x72>
  release(&cons.lock);
80100867:	83 ec 0c             	sub    $0xc,%esp
8010086a:	68 20 ef 10 80       	push   $0x8010ef20
8010086f:	e8 a8 33 00 00       	call   80103c1c <release>
  if(doprocdump) {
80100874:	83 c4 10             	add    $0x10,%esp
80100877:	85 f6                	test   %esi,%esi
80100879:	75 08                	jne    80100883 <consoleintr+0x150>
}
8010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010087e:	5b                   	pop    %ebx
8010087f:	5e                   	pop    %esi
80100880:	5f                   	pop    %edi
80100881:	5d                   	pop    %ebp
80100882:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100883:	e8 36 30 00 00       	call   801038be <procdump>
}
80100888:	eb f1                	jmp    8010087b <consoleintr+0x148>

8010088a <consoleinit>:

void
consoleinit(void)
{
8010088a:	55                   	push   %ebp
8010088b:	89 e5                	mov    %esp,%ebp
8010088d:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100890:	68 c8 67 10 80       	push   $0x801067c8
80100895:	68 20 ef 10 80       	push   $0x8010ef20
8010089a:	e8 dc 31 00 00       	call   80103a7b <initlock>

  devsw[CONSOLE].write = consolewrite;
8010089f:	c7 05 0c f9 10 80 a8 	movl   $0x801005a8,0x8010f90c
801008a6:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008a9:	c7 05 08 f9 10 80 68 	movl   $0x80100268,0x8010f908
801008b0:	02 10 80 
  cons.locking = 1;
801008b3:	c7 05 54 ef 10 80 01 	movl   $0x1,0x8010ef54
801008ba:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008bd:	83 c4 08             	add    $0x8,%esp
801008c0:	6a 00                	push   $0x0
801008c2:	6a 01                	push   $0x1
801008c4:	e8 98 16 00 00       	call   80101f61 <ioapicenable>
}
801008c9:	83 c4 10             	add    $0x10,%esp
801008cc:	c9                   	leave  
801008cd:	c3                   	ret    

801008ce <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	57                   	push   %edi
801008d2:	56                   	push   %esi
801008d3:	53                   	push   %ebx
801008d4:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008da:	e8 3b 29 00 00       	call   8010321a <myproc>
801008df:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
801008e5:	e8 c6 1e 00 00       	call   801027b0 <begin_op>

  if((ip = namei(path)) == 0){
801008ea:	83 ec 0c             	sub    $0xc,%esp
801008ed:	ff 75 08             	push   0x8(%ebp)
801008f0:	e8 d8 12 00 00       	call   80101bcd <namei>
801008f5:	83 c4 10             	add    $0x10,%esp
801008f8:	85 c0                	test   %eax,%eax
801008fa:	74 56                	je     80100952 <exec+0x84>
801008fc:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
801008fe:	83 ec 0c             	sub    $0xc,%esp
80100901:	50                   	push   %eax
80100902:	e8 68 0c 00 00       	call   8010156f <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100907:	6a 34                	push   $0x34
80100909:	6a 00                	push   $0x0
8010090b:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100911:	50                   	push   %eax
80100912:	53                   	push   %ebx
80100913:	e8 49 0e 00 00       	call   80101761 <readi>
80100918:	83 c4 20             	add    $0x20,%esp
8010091b:	83 f8 34             	cmp    $0x34,%eax
8010091e:	75 0c                	jne    8010092c <exec+0x5e>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100920:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100927:	45 4c 46 
8010092a:	74 42                	je     8010096e <exec+0xa0>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
8010092c:	85 db                	test   %ebx,%ebx
8010092e:	0f 84 c5 02 00 00    	je     80100bf9 <exec+0x32b>
    iunlockput(ip);
80100934:	83 ec 0c             	sub    $0xc,%esp
80100937:	53                   	push   %ebx
80100938:	e8 d9 0d 00 00       	call   80101716 <iunlockput>
    end_op();
8010093d:	e8 e8 1e 00 00       	call   8010282a <end_op>
80100942:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010094a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010094d:	5b                   	pop    %ebx
8010094e:	5e                   	pop    %esi
8010094f:	5f                   	pop    %edi
80100950:	5d                   	pop    %ebp
80100951:	c3                   	ret    
    end_op();
80100952:	e8 d3 1e 00 00       	call   8010282a <end_op>
    cprintf("exec: fail\n");
80100957:	83 ec 0c             	sub    $0xc,%esp
8010095a:	68 e1 67 10 80       	push   $0x801067e1
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 3f 5b 00 00       	call   801064b2 <setupkvm>
80100973:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100979:	85 c0                	test   %eax,%eax
8010097b:	0f 84 09 01 00 00    	je     80100a8a <exec+0x1bc>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100981:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
80100987:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
8010098c:	be 00 00 00 00       	mov    $0x0,%esi
80100991:	eb 0c                	jmp    8010099f <exec+0xd1>
80100993:	83 c6 01             	add    $0x1,%esi
80100996:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
8010099c:	83 c0 20             	add    $0x20,%eax
8010099f:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009a6:	39 f2                	cmp    %esi,%edx
801009a8:	0f 8e 98 00 00 00    	jle    80100a46 <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009ae:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
801009b4:	6a 20                	push   $0x20
801009b6:	50                   	push   %eax
801009b7:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009bd:	50                   	push   %eax
801009be:	53                   	push   %ebx
801009bf:	e8 9d 0d 00 00       	call   80101761 <readi>
801009c4:	83 c4 10             	add    $0x10,%esp
801009c7:	83 f8 20             	cmp    $0x20,%eax
801009ca:	0f 85 ba 00 00 00    	jne    80100a8a <exec+0x1bc>
    if(ph.type != ELF_PROG_LOAD)
801009d0:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009d7:	75 ba                	jne    80100993 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009d9:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009df:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e5:	0f 82 9f 00 00 00    	jb     80100a8a <exec+0x1bc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009eb:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f1:	0f 82 93 00 00 00    	jb     80100a8a <exec+0x1bc>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009f7:	83 ec 04             	sub    $0x4,%esp
801009fa:	50                   	push   %eax
801009fb:	57                   	push   %edi
801009fc:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100a02:	e8 27 59 00 00       	call   8010632e <allocuvm>
80100a07:	89 c7                	mov    %eax,%edi
80100a09:	83 c4 10             	add    $0x10,%esp
80100a0c:	85 c0                	test   %eax,%eax
80100a0e:	74 7a                	je     80100a8a <exec+0x1bc>
    if(ph.vaddr % PGSIZE != 0)
80100a10:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a16:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1b:	75 6d                	jne    80100a8a <exec+0x1bc>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a1d:	83 ec 0c             	sub    $0xc,%esp
80100a20:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100a26:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100a2c:	53                   	push   %ebx
80100a2d:	50                   	push   %eax
80100a2e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100a34:	e8 a0 57 00 00       	call   801061d9 <loaduvm>
80100a39:	83 c4 20             	add    $0x20,%esp
80100a3c:	85 c0                	test   %eax,%eax
80100a3e:	0f 89 4f ff ff ff    	jns    80100993 <exec+0xc5>
80100a44:	eb 44                	jmp    80100a8a <exec+0x1bc>
  iunlockput(ip);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	53                   	push   %ebx
80100a4a:	e8 c7 0c 00 00       	call   80101716 <iunlockput>
  end_op();
80100a4f:	e8 d6 1d 00 00       	call   8010282a <end_op>
  sz = PGROUNDUP(sz);
80100a54:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a5f:	83 c4 0c             	add    $0xc,%esp
80100a62:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a68:	52                   	push   %edx
80100a69:	50                   	push   %eax
80100a6a:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100a70:	57                   	push   %edi
80100a71:	e8 b8 58 00 00       	call   8010632e <allocuvm>
80100a76:	89 c6                	mov    %eax,%esi
80100a78:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100a7e:	83 c4 10             	add    $0x10,%esp
80100a81:	85 c0                	test   %eax,%eax
80100a83:	75 24                	jne    80100aa9 <exec+0x1db>
  ip = 0;
80100a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a90:	85 c0                	test   %eax,%eax
80100a92:	0f 84 94 fe ff ff    	je     8010092c <exec+0x5e>
    freevm(pgdir);
80100a98:	83 ec 0c             	sub    $0xc,%esp
80100a9b:	50                   	push   %eax
80100a9c:	e8 8f 59 00 00       	call   80106430 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 7e 5a 00 00       	call   80106537 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ab9:	83 c4 10             	add    $0x10,%esp
80100abc:	bf 00 00 00 00       	mov    $0x0,%edi
80100ac1:	eb 0a                	jmp    80100acd <exec+0x1ff>
    ustack[3+argc] = sp;
80100ac3:	89 b4 bd 64 ff ff ff 	mov    %esi,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100aca:	83 c7 01             	add    $0x1,%edi
80100acd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad0:	8d 1c b8             	lea    (%eax,%edi,4),%ebx
80100ad3:	8b 03                	mov    (%ebx),%eax
80100ad5:	85 c0                	test   %eax,%eax
80100ad7:	74 47                	je     80100b20 <exec+0x252>
    if(argc >= MAXARG)
80100ad9:	83 ff 1f             	cmp    $0x1f,%edi
80100adc:	0f 87 0d 01 00 00    	ja     80100bef <exec+0x321>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	50                   	push   %eax
80100ae6:	e8 21 33 00 00       	call   80103e0c <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 0f 33 00 00       	call   80103e0c <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 b8 5b 00 00       	call   801066c7 <copyout>
80100b0f:	83 c4 20             	add    $0x20,%esp
80100b12:	85 c0                	test   %eax,%eax
80100b14:	79 ad                	jns    80100ac3 <exec+0x1f5>
  ip = 0;
80100b16:	bb 00 00 00 00       	mov    $0x0,%ebx
80100b1b:	e9 6a ff ff ff       	jmp    80100a8a <exec+0x1bc>
  ustack[3+argc] = 0;
80100b20:	89 f1                	mov    %esi,%ecx
80100b22:	89 c3                	mov    %eax,%ebx
80100b24:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100b2b:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2f:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b36:	ff ff ff 
  ustack[1] = argc;
80100b39:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3f:	8d 14 bd 04 00 00 00 	lea    0x4(,%edi,4),%edx
80100b46:	89 f0                	mov    %esi,%eax
80100b48:	29 d0                	sub    %edx,%eax
80100b4a:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b50:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b57:	29 c1                	sub    %eax,%ecx
80100b59:	89 ce                	mov    %ecx,%esi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b5b:	50                   	push   %eax
80100b5c:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b62:	50                   	push   %eax
80100b63:	51                   	push   %ecx
80100b64:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b6a:	e8 58 5b 00 00       	call   801066c7 <copyout>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	85 c0                	test   %eax,%eax
80100b74:	0f 88 10 ff ff ff    	js     80100a8a <exec+0x1bc>
  for(last=s=path; *s; s++)
80100b7a:	8b 55 08             	mov    0x8(%ebp),%edx
80100b7d:	89 d0                	mov    %edx,%eax
80100b7f:	eb 03                	jmp    80100b84 <exec+0x2b6>
80100b81:	83 c0 01             	add    $0x1,%eax
80100b84:	0f b6 08             	movzbl (%eax),%ecx
80100b87:	84 c9                	test   %cl,%cl
80100b89:	74 0a                	je     80100b95 <exec+0x2c7>
    if(*s == '/')
80100b8b:	80 f9 2f             	cmp    $0x2f,%cl
80100b8e:	75 f1                	jne    80100b81 <exec+0x2b3>
      last = s+1;
80100b90:	8d 50 01             	lea    0x1(%eax),%edx
80100b93:	eb ec                	jmp    80100b81 <exec+0x2b3>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b95:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100b9b:	89 f8                	mov    %edi,%eax
80100b9d:	83 c0 6c             	add    $0x6c,%eax
80100ba0:	83 ec 04             	sub    $0x4,%esp
80100ba3:	6a 10                	push   $0x10
80100ba5:	52                   	push   %edx
80100ba6:	50                   	push   %eax
80100ba7:	e8 23 32 00 00       	call   80103dcf <safestrcpy>
  oldpgdir = curproc->pgdir;
80100bac:	8b 5f 04             	mov    0x4(%edi),%ebx
  curproc->pgdir = pgdir;
80100baf:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bb5:	89 4f 04             	mov    %ecx,0x4(%edi)
  curproc->sz = sz;
80100bb8:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100bbe:	89 0f                	mov    %ecx,(%edi)
  curproc->tf->eip = elf.entry;  // main
80100bc0:	8b 47 18             	mov    0x18(%edi),%eax
80100bc3:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc9:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bcc:	8b 47 18             	mov    0x18(%edi),%eax
80100bcf:	89 70 44             	mov    %esi,0x44(%eax)
  switchuvm(curproc);
80100bd2:	89 3c 24             	mov    %edi,(%esp)
80100bd5:	e8 0a 54 00 00       	call   80105fe4 <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 4e 58 00 00       	call   80106430 <freevm>
  return 0;
80100be2:	83 c4 10             	add    $0x10,%esp
80100be5:	b8 00 00 00 00       	mov    $0x0,%eax
80100bea:	e9 5b fd ff ff       	jmp    8010094a <exec+0x7c>
  ip = 0;
80100bef:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf4:	e9 91 fe ff ff       	jmp    80100a8a <exec+0x1bc>
  return -1;
80100bf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bfe:	e9 47 fd ff ff       	jmp    8010094a <exec+0x7c>

80100c03 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c03:	55                   	push   %ebp
80100c04:	89 e5                	mov    %esp,%ebp
80100c06:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c09:	68 ed 67 10 80       	push   $0x801067ed
80100c0e:	68 60 ef 10 80       	push   $0x8010ef60
80100c13:	e8 63 2e 00 00       	call   80103a7b <initlock>
}
80100c18:	83 c4 10             	add    $0x10,%esp
80100c1b:	c9                   	leave  
80100c1c:	c3                   	ret    

80100c1d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c1d:	55                   	push   %ebp
80100c1e:	89 e5                	mov    %esp,%ebp
80100c20:	53                   	push   %ebx
80100c21:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c24:	68 60 ef 10 80       	push   $0x8010ef60
80100c29:	e8 89 2f 00 00       	call   80103bb7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c2e:	83 c4 10             	add    $0x10,%esp
80100c31:	bb 94 ef 10 80       	mov    $0x8010ef94,%ebx
80100c36:	81 fb f4 f8 10 80    	cmp    $0x8010f8f4,%ebx
80100c3c:	73 29                	jae    80100c67 <filealloc+0x4a>
    if(f->ref == 0){
80100c3e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c42:	74 05                	je     80100c49 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c44:	83 c3 18             	add    $0x18,%ebx
80100c47:	eb ed                	jmp    80100c36 <filealloc+0x19>
      f->ref = 1;
80100c49:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c50:	83 ec 0c             	sub    $0xc,%esp
80100c53:	68 60 ef 10 80       	push   $0x8010ef60
80100c58:	e8 bf 2f 00 00       	call   80103c1c <release>
      return f;
80100c5d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c60:	89 d8                	mov    %ebx,%eax
80100c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c65:	c9                   	leave  
80100c66:	c3                   	ret    
  release(&ftable.lock);
80100c67:	83 ec 0c             	sub    $0xc,%esp
80100c6a:	68 60 ef 10 80       	push   $0x8010ef60
80100c6f:	e8 a8 2f 00 00       	call   80103c1c <release>
  return 0;
80100c74:	83 c4 10             	add    $0x10,%esp
80100c77:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c7c:	eb e2                	jmp    80100c60 <filealloc+0x43>

80100c7e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c7e:	55                   	push   %ebp
80100c7f:	89 e5                	mov    %esp,%ebp
80100c81:	53                   	push   %ebx
80100c82:	83 ec 10             	sub    $0x10,%esp
80100c85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c88:	68 60 ef 10 80       	push   $0x8010ef60
80100c8d:	e8 25 2f 00 00       	call   80103bb7 <acquire>
  if(f->ref < 1)
80100c92:	8b 43 04             	mov    0x4(%ebx),%eax
80100c95:	83 c4 10             	add    $0x10,%esp
80100c98:	85 c0                	test   %eax,%eax
80100c9a:	7e 1a                	jle    80100cb6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100c9c:	83 c0 01             	add    $0x1,%eax
80100c9f:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ca2:	83 ec 0c             	sub    $0xc,%esp
80100ca5:	68 60 ef 10 80       	push   $0x8010ef60
80100caa:	e8 6d 2f 00 00       	call   80103c1c <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 f4 67 10 80       	push   $0x801067f4
80100cbe:	e8 85 f6 ff ff       	call   80100348 <panic>

80100cc3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cc3:	55                   	push   %ebp
80100cc4:	89 e5                	mov    %esp,%ebp
80100cc6:	53                   	push   %ebx
80100cc7:	83 ec 30             	sub    $0x30,%esp
80100cca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100ccd:	68 60 ef 10 80       	push   $0x8010ef60
80100cd2:	e8 e0 2e 00 00       	call   80103bb7 <acquire>
  if(f->ref < 1)
80100cd7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cda:	83 c4 10             	add    $0x10,%esp
80100cdd:	85 c0                	test   %eax,%eax
80100cdf:	7e 71                	jle    80100d52 <fileclose+0x8f>
    panic("fileclose");
  if(--f->ref > 0){
80100ce1:	83 e8 01             	sub    $0x1,%eax
80100ce4:	89 43 04             	mov    %eax,0x4(%ebx)
80100ce7:	85 c0                	test   %eax,%eax
80100ce9:	7f 74                	jg     80100d5f <fileclose+0x9c>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100ceb:	8b 03                	mov    (%ebx),%eax
80100ced:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cf0:	8b 43 04             	mov    0x4(%ebx),%eax
80100cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100cf6:	8b 43 08             	mov    0x8(%ebx),%eax
80100cf9:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cfc:	8b 43 0c             	mov    0xc(%ebx),%eax
80100cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d02:	8b 43 10             	mov    0x10(%ebx),%eax
80100d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100d08:	8b 43 14             	mov    0x14(%ebx),%eax
80100d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80100d0e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d1b:	83 ec 0c             	sub    $0xc,%esp
80100d1e:	68 60 ef 10 80       	push   $0x8010ef60
80100d23:	e8 f4 2e 00 00       	call   80103c1c <release>

  if(ff.type == FD_PIPE)
80100d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2b:	83 c4 10             	add    $0x10,%esp
80100d2e:	83 f8 01             	cmp    $0x1,%eax
80100d31:	74 41                	je     80100d74 <fileclose+0xb1>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d33:	83 f8 02             	cmp    $0x2,%eax
80100d36:	75 37                	jne    80100d6f <fileclose+0xac>
    begin_op();
80100d38:	e8 73 1a 00 00       	call   801027b0 <begin_op>
    iput(ff.ip);
80100d3d:	83 ec 0c             	sub    $0xc,%esp
80100d40:	ff 75 f0             	push   -0x10(%ebp)
80100d43:	e8 2e 09 00 00       	call   80101676 <iput>
    end_op();
80100d48:	e8 dd 1a 00 00       	call   8010282a <end_op>
80100d4d:	83 c4 10             	add    $0x10,%esp
80100d50:	eb 1d                	jmp    80100d6f <fileclose+0xac>
    panic("fileclose");
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	68 fc 67 10 80       	push   $0x801067fc
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ef 10 80       	push   $0x8010ef60
80100d67:	e8 b0 2e 00 00       	call   80103c1c <release>
    return;
80100d6c:	83 c4 10             	add    $0x10,%esp
  }
}
80100d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d72:	c9                   	leave  
80100d73:	c3                   	ret    
    pipeclose(ff.pipe, ff.writable);
80100d74:	83 ec 08             	sub    $0x8,%esp
80100d77:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7b:	50                   	push   %eax
80100d7c:	ff 75 ec             	push   -0x14(%ebp)
80100d7f:	e8 d2 20 00 00       	call   80102e56 <pipeclose>
80100d84:	83 c4 10             	add    $0x10,%esp
80100d87:	eb e6                	jmp    80100d6f <fileclose+0xac>

80100d89 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d89:	55                   	push   %ebp
80100d8a:	89 e5                	mov    %esp,%ebp
80100d8c:	53                   	push   %ebx
80100d8d:	83 ec 04             	sub    $0x4,%esp
80100d90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d93:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d96:	75 31                	jne    80100dc9 <filestat+0x40>
    ilock(f->ip);
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	ff 73 10             	push   0x10(%ebx)
80100d9e:	e8 cc 07 00 00       	call   8010156f <ilock>
    stati(f->ip, st);
80100da3:	83 c4 08             	add    $0x8,%esp
80100da6:	ff 75 0c             	push   0xc(%ebp)
80100da9:	ff 73 10             	push   0x10(%ebx)
80100dac:	e8 85 09 00 00       	call   80101736 <stati>
    iunlock(f->ip);
80100db1:	83 c4 04             	add    $0x4,%esp
80100db4:	ff 73 10             	push   0x10(%ebx)
80100db7:	e8 75 08 00 00       	call   80101631 <iunlock>
    return 0;
80100dbc:	83 c4 10             	add    $0x10,%esp
80100dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dc7:	c9                   	leave  
80100dc8:	c3                   	ret    
  return -1;
80100dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dce:	eb f4                	jmp    80100dc4 <filestat+0x3b>

80100dd0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd0:	55                   	push   %ebp
80100dd1:	89 e5                	mov    %esp,%ebp
80100dd3:	56                   	push   %esi
80100dd4:	53                   	push   %ebx
80100dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100dd8:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100ddc:	74 70                	je     80100e4e <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100dde:	8b 03                	mov    (%ebx),%eax
80100de0:	83 f8 01             	cmp    $0x1,%eax
80100de3:	74 44                	je     80100e29 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100de5:	83 f8 02             	cmp    $0x2,%eax
80100de8:	75 57                	jne    80100e41 <fileread+0x71>
    ilock(f->ip);
80100dea:	83 ec 0c             	sub    $0xc,%esp
80100ded:	ff 73 10             	push   0x10(%ebx)
80100df0:	e8 7a 07 00 00       	call   8010156f <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100df5:	ff 75 10             	push   0x10(%ebp)
80100df8:	ff 73 14             	push   0x14(%ebx)
80100dfb:	ff 75 0c             	push   0xc(%ebp)
80100dfe:	ff 73 10             	push   0x10(%ebx)
80100e01:	e8 5b 09 00 00       	call   80101761 <readi>
80100e06:	89 c6                	mov    %eax,%esi
80100e08:	83 c4 20             	add    $0x20,%esp
80100e0b:	85 c0                	test   %eax,%eax
80100e0d:	7e 03                	jle    80100e12 <fileread+0x42>
      f->off += r;
80100e0f:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e12:	83 ec 0c             	sub    $0xc,%esp
80100e15:	ff 73 10             	push   0x10(%ebx)
80100e18:	e8 14 08 00 00       	call   80101631 <iunlock>
    return r;
80100e1d:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e20:	89 f0                	mov    %esi,%eax
80100e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e25:	5b                   	pop    %ebx
80100e26:	5e                   	pop    %esi
80100e27:	5d                   	pop    %ebp
80100e28:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e29:	83 ec 04             	sub    $0x4,%esp
80100e2c:	ff 75 10             	push   0x10(%ebp)
80100e2f:	ff 75 0c             	push   0xc(%ebp)
80100e32:	ff 73 0c             	push   0xc(%ebx)
80100e35:	e8 6d 21 00 00       	call   80102fa7 <piperead>
80100e3a:	89 c6                	mov    %eax,%esi
80100e3c:	83 c4 10             	add    $0x10,%esp
80100e3f:	eb df                	jmp    80100e20 <fileread+0x50>
  panic("fileread");
80100e41:	83 ec 0c             	sub    $0xc,%esp
80100e44:	68 06 68 10 80       	push   $0x80106806
80100e49:	e8 fa f4 ff ff       	call   80100348 <panic>
    return -1;
80100e4e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e53:	eb cb                	jmp    80100e20 <fileread+0x50>

80100e55 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e55:	55                   	push   %ebp
80100e56:	89 e5                	mov    %esp,%ebp
80100e58:	57                   	push   %edi
80100e59:	56                   	push   %esi
80100e5a:	53                   	push   %ebx
80100e5b:	83 ec 1c             	sub    $0x1c,%esp
80100e5e:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;

  if(f->writable == 0)
80100e61:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100e65:	0f 84 d0 00 00 00    	je     80100f3b <filewrite+0xe6>
    return -1;
  if(f->type == FD_PIPE)
80100e6b:	8b 06                	mov    (%esi),%eax
80100e6d:	83 f8 01             	cmp    $0x1,%eax
80100e70:	74 12                	je     80100e84 <filewrite+0x2f>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e72:	83 f8 02             	cmp    $0x2,%eax
80100e75:	0f 85 b3 00 00 00    	jne    80100f2e <filewrite+0xd9>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e82:	eb 66                	jmp    80100eea <filewrite+0x95>
    return pipewrite(f->pipe, addr, n);
80100e84:	83 ec 04             	sub    $0x4,%esp
80100e87:	ff 75 10             	push   0x10(%ebp)
80100e8a:	ff 75 0c             	push   0xc(%ebp)
80100e8d:	ff 76 0c             	push   0xc(%esi)
80100e90:	e8 4d 20 00 00       	call   80102ee2 <pipewrite>
80100e95:	83 c4 10             	add    $0x10,%esp
80100e98:	e9 84 00 00 00       	jmp    80100f21 <filewrite+0xcc>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100e9d:	e8 0e 19 00 00       	call   801027b0 <begin_op>
      ilock(f->ip);
80100ea2:	83 ec 0c             	sub    $0xc,%esp
80100ea5:	ff 76 10             	push   0x10(%esi)
80100ea8:	e8 c2 06 00 00       	call   8010156f <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100ead:	57                   	push   %edi
80100eae:	ff 76 14             	push   0x14(%esi)
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	50                   	push   %eax
80100eb8:	ff 76 10             	push   0x10(%esi)
80100ebb:	e8 9e 09 00 00       	call   8010185e <writei>
80100ec0:	89 c3                	mov    %eax,%ebx
80100ec2:	83 c4 20             	add    $0x20,%esp
80100ec5:	85 c0                	test   %eax,%eax
80100ec7:	7e 03                	jle    80100ecc <filewrite+0x77>
        f->off += r;
80100ec9:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
80100ecc:	83 ec 0c             	sub    $0xc,%esp
80100ecf:	ff 76 10             	push   0x10(%esi)
80100ed2:	e8 5a 07 00 00       	call   80101631 <iunlock>
      end_op();
80100ed7:	e8 4e 19 00 00       	call   8010282a <end_op>

      if(r < 0)
80100edc:	83 c4 10             	add    $0x10,%esp
80100edf:	85 db                	test   %ebx,%ebx
80100ee1:	78 31                	js     80100f14 <filewrite+0xbf>
        break;
      if(r != n1)
80100ee3:	39 df                	cmp    %ebx,%edi
80100ee5:	75 20                	jne    80100f07 <filewrite+0xb2>
        panic("short filewrite");
      i += r;
80100ee7:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    while(i < n){
80100eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eed:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ef0:	7d 22                	jge    80100f14 <filewrite+0xbf>
      int n1 = n - i;
80100ef2:	8b 7d 10             	mov    0x10(%ebp),%edi
80100ef5:	2b 7d e4             	sub    -0x1c(%ebp),%edi
      if(n1 > max)
80100ef8:	81 ff 00 06 00 00    	cmp    $0x600,%edi
80100efe:	7e 9d                	jle    80100e9d <filewrite+0x48>
        n1 = max;
80100f00:	bf 00 06 00 00       	mov    $0x600,%edi
80100f05:	eb 96                	jmp    80100e9d <filewrite+0x48>
        panic("short filewrite");
80100f07:	83 ec 0c             	sub    $0xc,%esp
80100f0a:	68 0f 68 10 80       	push   $0x8010680f
80100f0f:	e8 34 f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f17:	3b 45 10             	cmp    0x10(%ebp),%eax
80100f1a:	74 0d                	je     80100f29 <filewrite+0xd4>
80100f1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f24:	5b                   	pop    %ebx
80100f25:	5e                   	pop    %esi
80100f26:	5f                   	pop    %edi
80100f27:	5d                   	pop    %ebp
80100f28:	c3                   	ret    
    return i == n ? n : -1;
80100f29:	8b 45 10             	mov    0x10(%ebp),%eax
80100f2c:	eb f3                	jmp    80100f21 <filewrite+0xcc>
  panic("filewrite");
80100f2e:	83 ec 0c             	sub    $0xc,%esp
80100f31:	68 15 68 10 80       	push   $0x80106815
80100f36:	e8 0d f4 ff ff       	call   80100348 <panic>
    return -1;
80100f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f40:	eb df                	jmp    80100f21 <filewrite+0xcc>

80100f42 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f42:	55                   	push   %ebp
80100f43:	89 e5                	mov    %esp,%ebp
80100f45:	57                   	push   %edi
80100f46:	56                   	push   %esi
80100f47:	53                   	push   %ebx
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	89 d6                	mov    %edx,%esi
  char *s;
  int len;

  while(*path == '/')
80100f4d:	eb 03                	jmp    80100f52 <skipelem+0x10>
    path++;
80100f4f:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f52:	0f b6 10             	movzbl (%eax),%edx
80100f55:	80 fa 2f             	cmp    $0x2f,%dl
80100f58:	74 f5                	je     80100f4f <skipelem+0xd>
  if(*path == 0)
80100f5a:	84 d2                	test   %dl,%dl
80100f5c:	74 53                	je     80100fb1 <skipelem+0x6f>
80100f5e:	89 c3                	mov    %eax,%ebx
80100f60:	eb 03                	jmp    80100f65 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f62:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f65:	0f b6 13             	movzbl (%ebx),%edx
80100f68:	80 fa 2f             	cmp    $0x2f,%dl
80100f6b:	74 04                	je     80100f71 <skipelem+0x2f>
80100f6d:	84 d2                	test   %dl,%dl
80100f6f:	75 f1                	jne    80100f62 <skipelem+0x20>
  len = path - s;
80100f71:	89 df                	mov    %ebx,%edi
80100f73:	29 c7                	sub    %eax,%edi
  if(len >= DIRSIZ)
80100f75:	83 ff 0d             	cmp    $0xd,%edi
80100f78:	7e 11                	jle    80100f8b <skipelem+0x49>
    memmove(name, s, DIRSIZ);
80100f7a:	83 ec 04             	sub    $0x4,%esp
80100f7d:	6a 0e                	push   $0xe
80100f7f:	50                   	push   %eax
80100f80:	56                   	push   %esi
80100f81:	e8 55 2d 00 00       	call   80103cdb <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 45 2d 00 00       	call   80103cdb <memmove>
    name[len] = 0;
80100f96:	c6 04 3e 00          	movb   $0x0,(%esi,%edi,1)
80100f9a:	83 c4 10             	add    $0x10,%esp
80100f9d:	eb 03                	jmp    80100fa2 <skipelem+0x60>
  }
  while(*path == '/')
    path++;
80100f9f:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fa2:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fa5:	74 f8                	je     80100f9f <skipelem+0x5d>
  return path;
}
80100fa7:	89 d8                	mov    %ebx,%eax
80100fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fac:	5b                   	pop    %ebx
80100fad:	5e                   	pop    %esi
80100fae:	5f                   	pop    %edi
80100faf:	5d                   	pop    %ebp
80100fb0:	c3                   	ret    
    return 0;
80100fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fb6:	eb ef                	jmp    80100fa7 <skipelem+0x65>

80100fb8 <bzero>:
{
80100fb8:	55                   	push   %ebp
80100fb9:	89 e5                	mov    %esp,%ebp
80100fbb:	53                   	push   %ebx
80100fbc:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fbf:	52                   	push   %edx
80100fc0:	50                   	push   %eax
80100fc1:	e8 a6 f1 ff ff       	call   8010016c <bread>
80100fc6:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fc8:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fcb:	83 c4 0c             	add    $0xc,%esp
80100fce:	68 00 02 00 00       	push   $0x200
80100fd3:	6a 00                	push   $0x0
80100fd5:	50                   	push   %eax
80100fd6:	e8 88 2c 00 00       	call   80103c63 <memset>
  log_write(bp);
80100fdb:	89 1c 24             	mov    %ebx,(%esp)
80100fde:	e8 f6 18 00 00       	call   801028d9 <log_write>
  brelse(bp);
80100fe3:	89 1c 24             	mov    %ebx,(%esp)
80100fe6:	e8 ea f1 ff ff       	call   801001d5 <brelse>
}
80100feb:	83 c4 10             	add    $0x10,%esp
80100fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ff1:	c9                   	leave  
80100ff2:	c3                   	ret    

80100ff3 <bfree>:
{
80100ff3:	55                   	push   %ebp
80100ff4:	89 e5                	mov    %esp,%ebp
80100ff6:	56                   	push   %esi
80100ff7:	53                   	push   %ebx
80100ff8:	89 c3                	mov    %eax,%ebx
80100ffa:	89 d6                	mov    %edx,%esi
  bp = bread(dev, BBLOCK(b, sb));
80100ffc:	89 d0                	mov    %edx,%eax
80100ffe:	c1 e8 0c             	shr    $0xc,%eax
80101001:	83 ec 08             	sub    $0x8,%esp
80101004:	03 05 cc 15 11 80    	add    0x801115cc,%eax
8010100a:	50                   	push   %eax
8010100b:	53                   	push   %ebx
8010100c:	e8 5b f1 ff ff       	call   8010016c <bread>
80101011:	89 c3                	mov    %eax,%ebx
  bi = b % BPB;
80101013:	89 f2                	mov    %esi,%edx
80101015:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  m = 1 << (bi % 8);
8010101b:	89 f1                	mov    %esi,%ecx
8010101d:	83 e1 07             	and    $0x7,%ecx
80101020:	b8 01 00 00 00       	mov    $0x1,%eax
80101025:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101027:	83 c4 10             	add    $0x10,%esp
8010102a:	c1 fa 03             	sar    $0x3,%edx
8010102d:	0f b6 4c 13 5c       	movzbl 0x5c(%ebx,%edx,1),%ecx
80101032:	0f b6 f1             	movzbl %cl,%esi
80101035:	85 c6                	test   %eax,%esi
80101037:	74 23                	je     8010105c <bfree+0x69>
  bp->data[bi/8] &= ~m;
80101039:	f7 d0                	not    %eax
8010103b:	21 c8                	and    %ecx,%eax
8010103d:	88 44 13 5c          	mov    %al,0x5c(%ebx,%edx,1)
  log_write(bp);
80101041:	83 ec 0c             	sub    $0xc,%esp
80101044:	53                   	push   %ebx
80101045:	e8 8f 18 00 00       	call   801028d9 <log_write>
  brelse(bp);
8010104a:	89 1c 24             	mov    %ebx,(%esp)
8010104d:	e8 83 f1 ff ff       	call   801001d5 <brelse>
}
80101052:	83 c4 10             	add    $0x10,%esp
80101055:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101058:	5b                   	pop    %ebx
80101059:	5e                   	pop    %esi
8010105a:	5d                   	pop    %ebp
8010105b:	c3                   	ret    
    panic("freeing free block");
8010105c:	83 ec 0c             	sub    $0xc,%esp
8010105f:	68 1f 68 10 80       	push   $0x8010681f
80101064:	e8 df f2 ff ff       	call   80100348 <panic>

80101069 <balloc>:
{
80101069:	55                   	push   %ebp
8010106a:	89 e5                	mov    %esp,%ebp
8010106c:	57                   	push   %edi
8010106d:	56                   	push   %esi
8010106e:	53                   	push   %ebx
8010106f:	83 ec 1c             	sub    $0x1c,%esp
80101072:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010107c:	eb 15                	jmp    80101093 <balloc+0x2a>
    brelse(bp);
8010107e:	83 ec 0c             	sub    $0xc,%esp
80101081:	ff 75 e0             	push   -0x20(%ebp)
80101084:	e8 4c f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101089:	81 45 e4 00 10 00 00 	addl   $0x1000,-0x1c(%ebp)
80101090:	83 c4 10             	add    $0x10,%esp
80101093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101096:	39 05 b4 15 11 80    	cmp    %eax,0x801115b4
8010109c:	76 75                	jbe    80101113 <balloc+0xaa>
    bp = bread(dev, BBLOCK(b, sb));
8010109e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801010a1:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
801010a7:	85 db                	test   %ebx,%ebx
801010a9:	0f 49 c3             	cmovns %ebx,%eax
801010ac:	c1 f8 0c             	sar    $0xc,%eax
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	03 05 cc 15 11 80    	add    0x801115cc,%eax
801010b8:	50                   	push   %eax
801010b9:	ff 75 d8             	push   -0x28(%ebp)
801010bc:	e8 ab f0 ff ff       	call   8010016c <bread>
801010c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010c4:	83 c4 10             	add    $0x10,%esp
801010c7:	b8 00 00 00 00       	mov    $0x0,%eax
801010cc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801010d1:	7f ab                	jg     8010107e <balloc+0x15>
801010d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010d6:	8d 1c 07             	lea    (%edi,%eax,1),%ebx
801010d9:	3b 1d b4 15 11 80    	cmp    0x801115b4,%ebx
801010df:	73 9d                	jae    8010107e <balloc+0x15>
      m = 1 << (bi % 8);
801010e1:	89 c1                	mov    %eax,%ecx
801010e3:	83 e1 07             	and    $0x7,%ecx
801010e6:	ba 01 00 00 00       	mov    $0x1,%edx
801010eb:	d3 e2                	shl    %cl,%edx
801010ed:	89 d1                	mov    %edx,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801010ef:	8d 50 07             	lea    0x7(%eax),%edx
801010f2:	85 c0                	test   %eax,%eax
801010f4:	0f 49 d0             	cmovns %eax,%edx
801010f7:	c1 fa 03             	sar    $0x3,%edx
801010fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
801010fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101100:	0f b6 74 16 5c       	movzbl 0x5c(%esi,%edx,1),%esi
80101105:	89 f2                	mov    %esi,%edx
80101107:	0f b6 fa             	movzbl %dl,%edi
8010110a:	85 cf                	test   %ecx,%edi
8010110c:	74 12                	je     80101120 <balloc+0xb7>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010110e:	83 c0 01             	add    $0x1,%eax
80101111:	eb b9                	jmp    801010cc <balloc+0x63>
  panic("balloc: out of blocks");
80101113:	83 ec 0c             	sub    $0xc,%esp
80101116:	68 32 68 10 80       	push   $0x80106832
8010111b:	e8 28 f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
80101120:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101123:	09 f1                	or     %esi,%ecx
80101125:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101128:	88 4c 17 5c          	mov    %cl,0x5c(%edi,%edx,1)
        log_write(bp);
8010112c:	83 ec 0c             	sub    $0xc,%esp
8010112f:	57                   	push   %edi
80101130:	e8 a4 17 00 00       	call   801028d9 <log_write>
        brelse(bp);
80101135:	89 3c 24             	mov    %edi,(%esp)
80101138:	e8 98 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
8010113d:	89 da                	mov    %ebx,%edx
8010113f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101142:	e8 71 fe ff ff       	call   80100fb8 <bzero>
}
80101147:	89 d8                	mov    %ebx,%eax
80101149:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114c:	5b                   	pop    %ebx
8010114d:	5e                   	pop    %esi
8010114e:	5f                   	pop    %edi
8010114f:	5d                   	pop    %ebp
80101150:	c3                   	ret    

80101151 <bmap>:
{
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	57                   	push   %edi
80101155:	56                   	push   %esi
80101156:	53                   	push   %ebx
80101157:	83 ec 1c             	sub    $0x1c,%esp
8010115a:	89 c3                	mov    %eax,%ebx
8010115c:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
8010115e:	83 fa 0b             	cmp    $0xb,%edx
80101161:	76 45                	jbe    801011a8 <bmap+0x57>
  bn -= NDIRECT;
80101163:	8d 72 f4             	lea    -0xc(%edx),%esi
  if(bn < NINDIRECT){
80101166:	83 fe 7f             	cmp    $0x7f,%esi
80101169:	77 7f                	ja     801011ea <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
8010116b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101171:	85 c0                	test   %eax,%eax
80101173:	74 4a                	je     801011bf <bmap+0x6e>
    bp = bread(ip->dev, addr);
80101175:	83 ec 08             	sub    $0x8,%esp
80101178:	50                   	push   %eax
80101179:	ff 33                	push   (%ebx)
8010117b:	e8 ec ef ff ff       	call   8010016c <bread>
80101180:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101182:	8d 44 b0 5c          	lea    0x5c(%eax,%esi,4),%eax
80101186:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101189:	8b 30                	mov    (%eax),%esi
8010118b:	83 c4 10             	add    $0x10,%esp
8010118e:	85 f6                	test   %esi,%esi
80101190:	74 3c                	je     801011ce <bmap+0x7d>
    brelse(bp);
80101192:	83 ec 0c             	sub    $0xc,%esp
80101195:	57                   	push   %edi
80101196:	e8 3a f0 ff ff       	call   801001d5 <brelse>
    return addr;
8010119b:	83 c4 10             	add    $0x10,%esp
}
8010119e:	89 f0                	mov    %esi,%eax
801011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a3:	5b                   	pop    %ebx
801011a4:	5e                   	pop    %esi
801011a5:	5f                   	pop    %edi
801011a6:	5d                   	pop    %ebp
801011a7:	c3                   	ret    
    if((addr = ip->addrs[bn]) == 0)
801011a8:	8b 74 90 5c          	mov    0x5c(%eax,%edx,4),%esi
801011ac:	85 f6                	test   %esi,%esi
801011ae:	75 ee                	jne    8010119e <bmap+0x4d>
      ip->addrs[bn] = addr = balloc(ip->dev);
801011b0:	8b 00                	mov    (%eax),%eax
801011b2:	e8 b2 fe ff ff       	call   80101069 <balloc>
801011b7:	89 c6                	mov    %eax,%esi
801011b9:	89 44 bb 5c          	mov    %eax,0x5c(%ebx,%edi,4)
    return addr;
801011bd:	eb df                	jmp    8010119e <bmap+0x4d>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801011bf:	8b 03                	mov    (%ebx),%eax
801011c1:	e8 a3 fe ff ff       	call   80101069 <balloc>
801011c6:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
801011cc:	eb a7                	jmp    80101175 <bmap+0x24>
      a[bn] = addr = balloc(ip->dev);
801011ce:	8b 03                	mov    (%ebx),%eax
801011d0:	e8 94 fe ff ff       	call   80101069 <balloc>
801011d5:	89 c6                	mov    %eax,%esi
801011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011da:	89 30                	mov    %esi,(%eax)
      log_write(bp);
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	57                   	push   %edi
801011e0:	e8 f4 16 00 00       	call   801028d9 <log_write>
801011e5:	83 c4 10             	add    $0x10,%esp
801011e8:	eb a8                	jmp    80101192 <bmap+0x41>
  panic("bmap: out of range");
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 48 68 10 80       	push   $0x80106848
801011f2:	e8 51 f1 ff ff       	call   80100348 <panic>

801011f7 <iget>:
{
801011f7:	55                   	push   %ebp
801011f8:	89 e5                	mov    %esp,%ebp
801011fa:	57                   	push   %edi
801011fb:	56                   	push   %esi
801011fc:	53                   	push   %ebx
801011fd:	83 ec 28             	sub    $0x28,%esp
80101200:	89 c7                	mov    %eax,%edi
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101205:	68 60 f9 10 80       	push   $0x8010f960
8010120a:	e8 a8 29 00 00       	call   80103bb7 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101212:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101217:	bb 94 f9 10 80       	mov    $0x8010f994,%ebx
8010121c:	eb 0a                	jmp    80101228 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010121e:	85 f6                	test   %esi,%esi
80101220:	74 3b                	je     8010125d <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101228:	81 fb b4 15 11 80    	cmp    $0x801115b4,%ebx
8010122e:	73 35                	jae    80101265 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101230:	8b 43 08             	mov    0x8(%ebx),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	7e e7                	jle    8010121e <iget+0x27>
80101237:	39 3b                	cmp    %edi,(%ebx)
80101239:	75 e3                	jne    8010121e <iget+0x27>
8010123b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010123e:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101241:	75 db                	jne    8010121e <iget+0x27>
      ip->ref++;
80101243:	83 c0 01             	add    $0x1,%eax
80101246:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101249:	83 ec 0c             	sub    $0xc,%esp
8010124c:	68 60 f9 10 80       	push   $0x8010f960
80101251:	e8 c6 29 00 00       	call   80103c1c <release>
      return ip;
80101256:	83 c4 10             	add    $0x10,%esp
80101259:	89 de                	mov    %ebx,%esi
8010125b:	eb 32                	jmp    8010128f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010125d:	85 c0                	test   %eax,%eax
8010125f:	75 c1                	jne    80101222 <iget+0x2b>
      empty = ip;
80101261:	89 de                	mov    %ebx,%esi
80101263:	eb bd                	jmp    80101222 <iget+0x2b>
  if(empty == 0)
80101265:	85 f6                	test   %esi,%esi
80101267:	74 30                	je     80101299 <iget+0xa2>
  ip->dev = dev;
80101269:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010126e:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101271:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101278:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	68 60 f9 10 80       	push   $0x8010f960
80101287:	e8 90 29 00 00       	call   80103c1c <release>
  return ip;
8010128c:	83 c4 10             	add    $0x10,%esp
}
8010128f:	89 f0                	mov    %esi,%eax
80101291:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101294:	5b                   	pop    %ebx
80101295:	5e                   	pop    %esi
80101296:	5f                   	pop    %edi
80101297:	5d                   	pop    %ebp
80101298:	c3                   	ret    
    panic("iget: no inodes");
80101299:	83 ec 0c             	sub    $0xc,%esp
8010129c:	68 5b 68 10 80       	push   $0x8010685b
801012a1:	e8 a2 f0 ff ff       	call   80100348 <panic>

801012a6 <readsb>:
{
801012a6:	55                   	push   %ebp
801012a7:	89 e5                	mov    %esp,%ebp
801012a9:	53                   	push   %ebx
801012aa:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801012ad:	6a 01                	push   $0x1
801012af:	ff 75 08             	push   0x8(%ebp)
801012b2:	e8 b5 ee ff ff       	call   8010016c <bread>
801012b7:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801012b9:	8d 40 5c             	lea    0x5c(%eax),%eax
801012bc:	83 c4 0c             	add    $0xc,%esp
801012bf:	6a 1c                	push   $0x1c
801012c1:	50                   	push   %eax
801012c2:	ff 75 0c             	push   0xc(%ebp)
801012c5:	e8 11 2a 00 00       	call   80103cdb <memmove>
  brelse(bp);
801012ca:	89 1c 24             	mov    %ebx,(%esp)
801012cd:	e8 03 ef ff ff       	call   801001d5 <brelse>
}
801012d2:	83 c4 10             	add    $0x10,%esp
801012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801012d8:	c9                   	leave  
801012d9:	c3                   	ret    

801012da <iinit>:
{
801012da:	55                   	push   %ebp
801012db:	89 e5                	mov    %esp,%ebp
801012dd:	53                   	push   %ebx
801012de:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012e1:	68 6b 68 10 80       	push   $0x8010686b
801012e6:	68 60 f9 10 80       	push   $0x8010f960
801012eb:	e8 8b 27 00 00       	call   80103a7b <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 72 68 10 80       	push   $0x80106872
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 5b 26 00 00       	call   80103970 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101315:	83 c3 01             	add    $0x1,%ebx
80101318:	83 c4 10             	add    $0x10,%esp
8010131b:	83 fb 31             	cmp    $0x31,%ebx
8010131e:	7e da                	jle    801012fa <iinit+0x20>
  readsb(dev, &sb);
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 b4 15 11 80       	push   $0x801115b4
80101328:	ff 75 08             	push   0x8(%ebp)
8010132b:	e8 76 ff ff ff       	call   801012a6 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101330:	ff 35 cc 15 11 80    	push   0x801115cc
80101336:	ff 35 c8 15 11 80    	push   0x801115c8
8010133c:	ff 35 c4 15 11 80    	push   0x801115c4
80101342:	ff 35 c0 15 11 80    	push   0x801115c0
80101348:	ff 35 bc 15 11 80    	push   0x801115bc
8010134e:	ff 35 b8 15 11 80    	push   0x801115b8
80101354:	ff 35 b4 15 11 80    	push   0x801115b4
8010135a:	68 d8 68 10 80       	push   $0x801068d8
8010135f:	e8 a3 f2 ff ff       	call   80100607 <cprintf>
}
80101364:	83 c4 30             	add    $0x30,%esp
80101367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136a:	c9                   	leave  
8010136b:	c3                   	ret    

8010136c <ialloc>:
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	57                   	push   %edi
80101370:	56                   	push   %esi
80101371:	53                   	push   %ebx
80101372:	83 ec 1c             	sub    $0x1c,%esp
80101375:	8b 45 0c             	mov    0xc(%ebp),%eax
80101378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010137b:	bb 01 00 00 00       	mov    $0x1,%ebx
80101380:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101383:	39 1d bc 15 11 80    	cmp    %ebx,0x801115bc
80101389:	76 3f                	jbe    801013ca <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010138b:	89 d8                	mov    %ebx,%eax
8010138d:	c1 e8 03             	shr    $0x3,%eax
80101390:	83 ec 08             	sub    $0x8,%esp
80101393:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101399:	50                   	push   %eax
8010139a:	ff 75 08             	push   0x8(%ebp)
8010139d:	e8 ca ed ff ff       	call   8010016c <bread>
801013a2:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013a4:	89 d8                	mov    %ebx,%eax
801013a6:	83 e0 07             	and    $0x7,%eax
801013a9:	c1 e0 06             	shl    $0x6,%eax
801013ac:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013b0:	83 c4 10             	add    $0x10,%esp
801013b3:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013b7:	74 1e                	je     801013d7 <ialloc+0x6b>
    brelse(bp);
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	56                   	push   %esi
801013bd:	e8 13 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013c2:	83 c3 01             	add    $0x1,%ebx
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	eb b6                	jmp    80101380 <ialloc+0x14>
  panic("ialloc: no inodes");
801013ca:	83 ec 0c             	sub    $0xc,%esp
801013cd:	68 78 68 10 80       	push   $0x80106878
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 7f 28 00 00       	call   80103c63 <memset>
      dip->type = type;
801013e4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013e8:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013eb:	89 34 24             	mov    %esi,(%esp)
801013ee:	e8 e6 14 00 00       	call   801028d9 <log_write>
      brelse(bp);
801013f3:	89 34 24             	mov    %esi,(%esp)
801013f6:	e8 da ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
801013fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	e8 f1 fd ff ff       	call   801011f7 <iget>
}
80101406:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101409:	5b                   	pop    %ebx
8010140a:	5e                   	pop    %esi
8010140b:	5f                   	pop    %edi
8010140c:	5d                   	pop    %ebp
8010140d:	c3                   	ret    

8010140e <iupdate>:
{
8010140e:	55                   	push   %ebp
8010140f:	89 e5                	mov    %esp,%ebp
80101411:	56                   	push   %esi
80101412:	53                   	push   %ebx
80101413:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101416:	8b 43 04             	mov    0x4(%ebx),%eax
80101419:	c1 e8 03             	shr    $0x3,%eax
8010141c:	83 ec 08             	sub    $0x8,%esp
8010141f:	03 05 c8 15 11 80    	add    0x801115c8,%eax
80101425:	50                   	push   %eax
80101426:	ff 33                	push   (%ebx)
80101428:	e8 3f ed ff ff       	call   8010016c <bread>
8010142d:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010142f:	8b 43 04             	mov    0x4(%ebx),%eax
80101432:	83 e0 07             	and    $0x7,%eax
80101435:	c1 e0 06             	shl    $0x6,%eax
80101438:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010143c:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101440:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101443:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101447:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010144b:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010144f:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101453:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101457:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010145b:	8b 53 58             	mov    0x58(%ebx),%edx
8010145e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101461:	83 c3 5c             	add    $0x5c,%ebx
80101464:	83 c0 0c             	add    $0xc,%eax
80101467:	83 c4 0c             	add    $0xc,%esp
8010146a:	6a 34                	push   $0x34
8010146c:	53                   	push   %ebx
8010146d:	50                   	push   %eax
8010146e:	e8 68 28 00 00       	call   80103cdb <memmove>
  log_write(bp);
80101473:	89 34 24             	mov    %esi,(%esp)
80101476:	e8 5e 14 00 00       	call   801028d9 <log_write>
  brelse(bp);
8010147b:	89 34 24             	mov    %esi,(%esp)
8010147e:	e8 52 ed ff ff       	call   801001d5 <brelse>
}
80101483:	83 c4 10             	add    $0x10,%esp
80101486:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101489:	5b                   	pop    %ebx
8010148a:	5e                   	pop    %esi
8010148b:	5d                   	pop    %ebp
8010148c:	c3                   	ret    

8010148d <itrunc>:
{
8010148d:	55                   	push   %ebp
8010148e:	89 e5                	mov    %esp,%ebp
80101490:	57                   	push   %edi
80101491:	56                   	push   %esi
80101492:	53                   	push   %ebx
80101493:	83 ec 1c             	sub    $0x1c,%esp
80101496:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
80101498:	bb 00 00 00 00       	mov    $0x0,%ebx
8010149d:	eb 03                	jmp    801014a2 <itrunc+0x15>
8010149f:	83 c3 01             	add    $0x1,%ebx
801014a2:	83 fb 0b             	cmp    $0xb,%ebx
801014a5:	7f 19                	jg     801014c0 <itrunc+0x33>
    if(ip->addrs[i]){
801014a7:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014ab:	85 d2                	test   %edx,%edx
801014ad:	74 f0                	je     8010149f <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014af:	8b 06                	mov    (%esi),%eax
801014b1:	e8 3d fb ff ff       	call   80100ff3 <bfree>
      ip->addrs[i] = 0;
801014b6:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014bd:	00 
801014be:	eb df                	jmp    8010149f <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014c0:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014c6:	85 c0                	test   %eax,%eax
801014c8:	75 1b                	jne    801014e5 <itrunc+0x58>
  ip->size = 0;
801014ca:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014d1:	83 ec 0c             	sub    $0xc,%esp
801014d4:	56                   	push   %esi
801014d5:	e8 34 ff ff ff       	call   8010140e <iupdate>
}
801014da:	83 c4 10             	add    $0x10,%esp
801014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014e0:	5b                   	pop    %ebx
801014e1:	5e                   	pop    %esi
801014e2:	5f                   	pop    %edi
801014e3:	5d                   	pop    %ebp
801014e4:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014e5:	83 ec 08             	sub    $0x8,%esp
801014e8:	50                   	push   %eax
801014e9:	ff 36                	push   (%esi)
801014eb:	e8 7c ec ff ff       	call   8010016c <bread>
801014f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014f3:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014f6:	83 c4 10             	add    $0x10,%esp
801014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801014fe:	eb 03                	jmp    80101503 <itrunc+0x76>
80101500:	83 c3 01             	add    $0x1,%ebx
80101503:	83 fb 7f             	cmp    $0x7f,%ebx
80101506:	77 10                	ja     80101518 <itrunc+0x8b>
      if(a[j])
80101508:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010150b:	85 d2                	test   %edx,%edx
8010150d:	74 f1                	je     80101500 <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010150f:	8b 06                	mov    (%esi),%eax
80101511:	e8 dd fa ff ff       	call   80100ff3 <bfree>
80101516:	eb e8                	jmp    80101500 <itrunc+0x73>
    brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 e4             	push   -0x1c(%ebp)
8010151e:	e8 b2 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101523:	8b 06                	mov    (%esi),%eax
80101525:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010152b:	e8 c3 fa ff ff       	call   80100ff3 <bfree>
    ip->addrs[NDIRECT] = 0;
80101530:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101537:	00 00 00 
8010153a:	83 c4 10             	add    $0x10,%esp
8010153d:	eb 8b                	jmp    801014ca <itrunc+0x3d>

8010153f <idup>:
{
8010153f:	55                   	push   %ebp
80101540:	89 e5                	mov    %esp,%ebp
80101542:	53                   	push   %ebx
80101543:	83 ec 10             	sub    $0x10,%esp
80101546:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101549:	68 60 f9 10 80       	push   $0x8010f960
8010154e:	e8 64 26 00 00       	call   80103bb7 <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101563:	e8 b4 26 00 00       	call   80103c1c <release>
}
80101568:	89 d8                	mov    %ebx,%eax
8010156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010156d:	c9                   	leave  
8010156e:	c3                   	ret    

8010156f <ilock>:
{
8010156f:	55                   	push   %ebp
80101570:	89 e5                	mov    %esp,%ebp
80101572:	56                   	push   %esi
80101573:	53                   	push   %ebx
80101574:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101577:	85 db                	test   %ebx,%ebx
80101579:	74 22                	je     8010159d <ilock+0x2e>
8010157b:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010157f:	7e 1c                	jle    8010159d <ilock+0x2e>
  acquiresleep(&ip->lock);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	8d 43 0c             	lea    0xc(%ebx),%eax
80101587:	50                   	push   %eax
80101588:	e8 16 24 00 00       	call   801039a3 <acquiresleep>
  if(ip->valid == 0){
8010158d:	83 c4 10             	add    $0x10,%esp
80101590:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101594:	74 14                	je     801015aa <ilock+0x3b>
}
80101596:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101599:	5b                   	pop    %ebx
8010159a:	5e                   	pop    %esi
8010159b:	5d                   	pop    %ebp
8010159c:	c3                   	ret    
    panic("ilock");
8010159d:	83 ec 0c             	sub    $0xc,%esp
801015a0:	68 8a 68 10 80       	push   $0x8010688a
801015a5:	e8 9e ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015aa:	8b 43 04             	mov    0x4(%ebx),%eax
801015ad:	c1 e8 03             	shr    $0x3,%eax
801015b0:	83 ec 08             	sub    $0x8,%esp
801015b3:	03 05 c8 15 11 80    	add    0x801115c8,%eax
801015b9:	50                   	push   %eax
801015ba:	ff 33                	push   (%ebx)
801015bc:	e8 ab eb ff ff       	call   8010016c <bread>
801015c1:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015c3:	8b 43 04             	mov    0x4(%ebx),%eax
801015c6:	83 e0 07             	and    $0x7,%eax
801015c9:	c1 e0 06             	shl    $0x6,%eax
801015cc:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015d0:	0f b7 10             	movzwl (%eax),%edx
801015d3:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015d7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015db:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015df:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015e3:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015eb:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801015ef:	8b 50 08             	mov    0x8(%eax),%edx
801015f2:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015f5:	83 c0 0c             	add    $0xc,%eax
801015f8:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015fb:	83 c4 0c             	add    $0xc,%esp
801015fe:	6a 34                	push   $0x34
80101600:	50                   	push   %eax
80101601:	52                   	push   %edx
80101602:	e8 d4 26 00 00       	call   80103cdb <memmove>
    brelse(bp);
80101607:	89 34 24             	mov    %esi,(%esp)
8010160a:	e8 c6 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010160f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101616:	83 c4 10             	add    $0x10,%esp
80101619:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010161e:	0f 85 72 ff ff ff    	jne    80101596 <ilock+0x27>
      panic("ilock: no type");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 90 68 10 80       	push   $0x80106890
8010162c:	e8 17 ed ff ff       	call   80100348 <panic>

80101631 <iunlock>:
{
80101631:	55                   	push   %ebp
80101632:	89 e5                	mov    %esp,%ebp
80101634:	56                   	push   %esi
80101635:	53                   	push   %ebx
80101636:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101639:	85 db                	test   %ebx,%ebx
8010163b:	74 2c                	je     80101669 <iunlock+0x38>
8010163d:	8d 73 0c             	lea    0xc(%ebx),%esi
80101640:	83 ec 0c             	sub    $0xc,%esp
80101643:	56                   	push   %esi
80101644:	e8 e4 23 00 00       	call   80103a2d <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 93 23 00 00       	call   801039f2 <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 9f 68 10 80       	push   $0x8010689f
80101671:	e8 d2 ec ff ff       	call   80100348 <panic>

80101676 <iput>:
{
80101676:	55                   	push   %ebp
80101677:	89 e5                	mov    %esp,%ebp
80101679:	57                   	push   %edi
8010167a:	56                   	push   %esi
8010167b:	53                   	push   %ebx
8010167c:	83 ec 18             	sub    $0x18,%esp
8010167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101682:	8d 73 0c             	lea    0xc(%ebx),%esi
80101685:	56                   	push   %esi
80101686:	e8 18 23 00 00       	call   801039a3 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 4e 23 00 00       	call   801039f2 <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016ab:	e8 07 25 00 00       	call   80103bb7 <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016c0:	e8 57 25 00 00       	call   80103c1c <release>
}
801016c5:	83 c4 10             	add    $0x10,%esp
801016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016cb:	5b                   	pop    %ebx
801016cc:	5e                   	pop    %esi
801016cd:	5f                   	pop    %edi
801016ce:	5d                   	pop    %ebp
801016cf:	c3                   	ret    
    acquire(&icache.lock);
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 60 f9 10 80       	push   $0x8010f960
801016d8:	e8 da 24 00 00       	call   80103bb7 <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016e7:	e8 30 25 00 00       	call   80103c1c <release>
    if(r == 1){
801016ec:	83 c4 10             	add    $0x10,%esp
801016ef:	83 ff 01             	cmp    $0x1,%edi
801016f2:	75 a7                	jne    8010169b <iput+0x25>
      itrunc(ip);
801016f4:	89 d8                	mov    %ebx,%eax
801016f6:	e8 92 fd ff ff       	call   8010148d <itrunc>
      ip->type = 0;
801016fb:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101701:	83 ec 0c             	sub    $0xc,%esp
80101704:	53                   	push   %ebx
80101705:	e8 04 fd ff ff       	call   8010140e <iupdate>
      ip->valid = 0;
8010170a:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	eb 85                	jmp    8010169b <iput+0x25>

80101716 <iunlockput>:
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	53                   	push   %ebx
8010171a:	83 ec 10             	sub    $0x10,%esp
8010171d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101720:	53                   	push   %ebx
80101721:	e8 0b ff ff ff       	call   80101631 <iunlock>
  iput(ip);
80101726:	89 1c 24             	mov    %ebx,(%esp)
80101729:	e8 48 ff ff ff       	call   80101676 <iput>
}
8010172e:	83 c4 10             	add    $0x10,%esp
80101731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101734:	c9                   	leave  
80101735:	c3                   	ret    

80101736 <stati>:
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	8b 55 08             	mov    0x8(%ebp),%edx
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010173f:	8b 0a                	mov    (%edx),%ecx
80101741:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101744:	8b 4a 04             	mov    0x4(%edx),%ecx
80101747:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010174a:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010174e:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101751:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101755:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101759:	8b 52 58             	mov    0x58(%edx),%edx
8010175c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010175f:	5d                   	pop    %ebp
80101760:	c3                   	ret    

80101761 <readi>:
{
80101761:	55                   	push   %ebp
80101762:	89 e5                	mov    %esp,%ebp
80101764:	57                   	push   %edi
80101765:	56                   	push   %esi
80101766:	53                   	push   %ebx
80101767:	83 ec 1c             	sub    $0x1c,%esp
8010176a:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010176d:	8b 45 08             	mov    0x8(%ebp),%eax
80101770:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101775:	74 2c                	je     801017a3 <readi+0x42>
  if(off > ip->size || off + n < off)
80101777:	8b 45 08             	mov    0x8(%ebp),%eax
8010177a:	8b 40 58             	mov    0x58(%eax),%eax
8010177d:	39 f8                	cmp    %edi,%eax
8010177f:	0f 82 cb 00 00 00    	jb     80101850 <readi+0xef>
80101785:	89 fa                	mov    %edi,%edx
80101787:	03 55 14             	add    0x14(%ebp),%edx
8010178a:	0f 82 c7 00 00 00    	jb     80101857 <readi+0xf6>
  if(off + n > ip->size)
80101790:	39 d0                	cmp    %edx,%eax
80101792:	73 05                	jae    80101799 <readi+0x38>
    n = ip->size - off;
80101794:	29 f8                	sub    %edi,%eax
80101796:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101799:	be 00 00 00 00       	mov    $0x0,%esi
8010179e:	e9 8f 00 00 00       	jmp    80101832 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017a3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017a7:	66 83 f8 09          	cmp    $0x9,%ax
801017ab:	0f 87 91 00 00 00    	ja     80101842 <readi+0xe1>
801017b1:	98                   	cwtl   
801017b2:	8b 04 c5 00 f9 10 80 	mov    -0x7fef0700(,%eax,8),%eax
801017b9:	85 c0                	test   %eax,%eax
801017bb:	0f 84 88 00 00 00    	je     80101849 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017c1:	83 ec 04             	sub    $0x4,%esp
801017c4:	ff 75 14             	push   0x14(%ebp)
801017c7:	ff 75 0c             	push   0xc(%ebp)
801017ca:	ff 75 08             	push   0x8(%ebp)
801017cd:	ff d0                	call   *%eax
801017cf:	83 c4 10             	add    $0x10,%esp
801017d2:	eb 66                	jmp    8010183a <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017d4:	89 fa                	mov    %edi,%edx
801017d6:	c1 ea 09             	shr    $0x9,%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	e8 70 f9 ff ff       	call   80101151 <bmap>
801017e1:	83 ec 08             	sub    $0x8,%esp
801017e4:	50                   	push   %eax
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	ff 30                	push   (%eax)
801017ea:	e8 7d e9 ff ff       	call   8010016c <bread>
801017ef:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
801017f1:	89 f8                	mov    %edi,%eax
801017f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801017f8:	bb 00 02 00 00       	mov    $0x200,%ebx
801017fd:	29 c3                	sub    %eax,%ebx
801017ff:	8b 55 14             	mov    0x14(%ebp),%edx
80101802:	29 f2                	sub    %esi,%edx
80101804:	39 d3                	cmp    %edx,%ebx
80101806:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101809:	83 c4 0c             	add    $0xc,%esp
8010180c:	53                   	push   %ebx
8010180d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101810:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101814:	50                   	push   %eax
80101815:	ff 75 0c             	push   0xc(%ebp)
80101818:	e8 be 24 00 00       	call   80103cdb <memmove>
    brelse(bp);
8010181d:	83 c4 04             	add    $0x4,%esp
80101820:	ff 75 e4             	push   -0x1c(%ebp)
80101823:	e8 ad e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101828:	01 de                	add    %ebx,%esi
8010182a:	01 df                	add    %ebx,%edi
8010182c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	39 75 14             	cmp    %esi,0x14(%ebp)
80101835:	77 9d                	ja     801017d4 <readi+0x73>
  return n;
80101837:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010183a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010183d:	5b                   	pop    %ebx
8010183e:	5e                   	pop    %esi
8010183f:	5f                   	pop    %edi
80101840:	5d                   	pop    %ebp
80101841:	c3                   	ret    
      return -1;
80101842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101847:	eb f1                	jmp    8010183a <readi+0xd9>
80101849:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010184e:	eb ea                	jmp    8010183a <readi+0xd9>
    return -1;
80101850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101855:	eb e3                	jmp    8010183a <readi+0xd9>
80101857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010185c:	eb dc                	jmp    8010183a <readi+0xd9>

8010185e <writei>:
{
8010185e:	55                   	push   %ebp
8010185f:	89 e5                	mov    %esp,%ebp
80101861:	57                   	push   %edi
80101862:	56                   	push   %esi
80101863:	53                   	push   %ebx
80101864:	83 ec 1c             	sub    $0x1c,%esp
80101867:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010186a:	8b 45 08             	mov    0x8(%ebp),%eax
8010186d:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101872:	74 2e                	je     801018a2 <writei+0x44>
  if(off > ip->size || off + n < off)
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	39 78 58             	cmp    %edi,0x58(%eax)
8010187a:	0f 82 f5 00 00 00    	jb     80101975 <writei+0x117>
80101880:	89 f8                	mov    %edi,%eax
80101882:	03 45 14             	add    0x14(%ebp),%eax
80101885:	0f 82 f1 00 00 00    	jb     8010197c <writei+0x11e>
  if(off + n > MAXFILE*BSIZE)
8010188b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101890:	0f 87 ed 00 00 00    	ja     80101983 <writei+0x125>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101896:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010189d:	e9 93 00 00 00       	jmp    80101935 <writei+0xd7>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018a2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018a6:	66 83 f8 09          	cmp    $0x9,%ax
801018aa:	0f 87 b7 00 00 00    	ja     80101967 <writei+0x109>
801018b0:	98                   	cwtl   
801018b1:	8b 04 c5 04 f9 10 80 	mov    -0x7fef06fc(,%eax,8),%eax
801018b8:	85 c0                	test   %eax,%eax
801018ba:	0f 84 ae 00 00 00    	je     8010196e <writei+0x110>
    return devsw[ip->major].write(ip, src, n);
801018c0:	83 ec 04             	sub    $0x4,%esp
801018c3:	ff 75 14             	push   0x14(%ebp)
801018c6:	ff 75 0c             	push   0xc(%ebp)
801018c9:	ff 75 08             	push   0x8(%ebp)
801018cc:	ff d0                	call   *%eax
801018ce:	83 c4 10             	add    $0x10,%esp
801018d1:	eb 7b                	jmp    8010194e <writei+0xf0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018d3:	89 fa                	mov    %edi,%edx
801018d5:	c1 ea 09             	shr    $0x9,%edx
801018d8:	8b 45 08             	mov    0x8(%ebp),%eax
801018db:	e8 71 f8 ff ff       	call   80101151 <bmap>
801018e0:	83 ec 08             	sub    $0x8,%esp
801018e3:	50                   	push   %eax
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	ff 30                	push   (%eax)
801018e9:	e8 7e e8 ff ff       	call   8010016c <bread>
801018ee:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
801018f0:	89 f8                	mov    %edi,%eax
801018f2:	25 ff 01 00 00       	and    $0x1ff,%eax
801018f7:	bb 00 02 00 00       	mov    $0x200,%ebx
801018fc:	29 c3                	sub    %eax,%ebx
801018fe:	8b 55 14             	mov    0x14(%ebp),%edx
80101901:	2b 55 e4             	sub    -0x1c(%ebp),%edx
80101904:	39 d3                	cmp    %edx,%ebx
80101906:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101909:	83 c4 0c             	add    $0xc,%esp
8010190c:	53                   	push   %ebx
8010190d:	ff 75 0c             	push   0xc(%ebp)
80101910:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
80101914:	50                   	push   %eax
80101915:	e8 c1 23 00 00       	call   80103cdb <memmove>
    log_write(bp);
8010191a:	89 34 24             	mov    %esi,(%esp)
8010191d:	e8 b7 0f 00 00       	call   801028d9 <log_write>
    brelse(bp);
80101922:	89 34 24             	mov    %esi,(%esp)
80101925:	e8 ab e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010192a:	01 5d e4             	add    %ebx,-0x1c(%ebp)
8010192d:	01 df                	add    %ebx,%edi
8010192f:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101932:	83 c4 10             	add    $0x10,%esp
80101935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101938:	3b 45 14             	cmp    0x14(%ebp),%eax
8010193b:	72 96                	jb     801018d3 <writei+0x75>
  if(n > 0 && off > ip->size){
8010193d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101941:	74 08                	je     8010194b <writei+0xed>
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	39 78 58             	cmp    %edi,0x58(%eax)
80101949:	72 0b                	jb     80101956 <writei+0xf8>
  return n;
8010194b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010194e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101951:	5b                   	pop    %ebx
80101952:	5e                   	pop    %esi
80101953:	5f                   	pop    %edi
80101954:	5d                   	pop    %ebp
80101955:	c3                   	ret    
    ip->size = off;
80101956:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
80101959:	83 ec 0c             	sub    $0xc,%esp
8010195c:	50                   	push   %eax
8010195d:	e8 ac fa ff ff       	call   8010140e <iupdate>
80101962:	83 c4 10             	add    $0x10,%esp
80101965:	eb e4                	jmp    8010194b <writei+0xed>
      return -1;
80101967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010196c:	eb e0                	jmp    8010194e <writei+0xf0>
8010196e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101973:	eb d9                	jmp    8010194e <writei+0xf0>
    return -1;
80101975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197a:	eb d2                	jmp    8010194e <writei+0xf0>
8010197c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101981:	eb cb                	jmp    8010194e <writei+0xf0>
    return -1;
80101983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101988:	eb c4                	jmp    8010194e <writei+0xf0>

8010198a <namecmp>:
{
8010198a:	55                   	push   %ebp
8010198b:	89 e5                	mov    %esp,%ebp
8010198d:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101990:	6a 0e                	push   $0xe
80101992:	ff 75 0c             	push   0xc(%ebp)
80101995:	ff 75 08             	push   0x8(%ebp)
80101998:	e8 aa 23 00 00       	call   80103d47 <strncmp>
}
8010199d:	c9                   	leave  
8010199e:	c3                   	ret    

8010199f <dirlookup>:
{
8010199f:	55                   	push   %ebp
801019a0:	89 e5                	mov    %esp,%ebp
801019a2:	57                   	push   %edi
801019a3:	56                   	push   %esi
801019a4:	53                   	push   %ebx
801019a5:	83 ec 1c             	sub    $0x1c,%esp
801019a8:	8b 75 08             	mov    0x8(%ebp),%esi
801019ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019ae:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019b3:	75 07                	jne    801019bc <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019b5:	bb 00 00 00 00       	mov    $0x0,%ebx
801019ba:	eb 1d                	jmp    801019d9 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019bc:	83 ec 0c             	sub    $0xc,%esp
801019bf:	68 a7 68 10 80       	push   $0x801068a7
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 b9 68 10 80       	push   $0x801068b9
801019d1:	e8 72 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d6:	83 c3 10             	add    $0x10,%ebx
801019d9:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019dc:	76 48                	jbe    80101a26 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019de:	6a 10                	push   $0x10
801019e0:	53                   	push   %ebx
801019e1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019e4:	50                   	push   %eax
801019e5:	56                   	push   %esi
801019e6:	e8 76 fd ff ff       	call   80101761 <readi>
801019eb:	83 c4 10             	add    $0x10,%esp
801019ee:	83 f8 10             	cmp    $0x10,%eax
801019f1:	75 d6                	jne    801019c9 <dirlookup+0x2a>
    if(de.inum == 0)
801019f3:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019f8:	74 dc                	je     801019d6 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019fa:	83 ec 08             	sub    $0x8,%esp
801019fd:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a00:	50                   	push   %eax
80101a01:	57                   	push   %edi
80101a02:	e8 83 ff ff ff       	call   8010198a <namecmp>
80101a07:	83 c4 10             	add    $0x10,%esp
80101a0a:	85 c0                	test   %eax,%eax
80101a0c:	75 c8                	jne    801019d6 <dirlookup+0x37>
      if(poff)
80101a0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a12:	74 05                	je     80101a19 <dirlookup+0x7a>
        *poff = off;
80101a14:	8b 45 10             	mov    0x10(%ebp),%eax
80101a17:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a19:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a1d:	8b 06                	mov    (%esi),%eax
80101a1f:	e8 d3 f7 ff ff       	call   801011f7 <iget>
80101a24:	eb 05                	jmp    80101a2b <dirlookup+0x8c>
  return 0;
80101a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2e:	5b                   	pop    %ebx
80101a2f:	5e                   	pop    %esi
80101a30:	5f                   	pop    %edi
80101a31:	5d                   	pop    %ebp
80101a32:	c3                   	ret    

80101a33 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a33:	55                   	push   %ebp
80101a34:	89 e5                	mov    %esp,%ebp
80101a36:	57                   	push   %edi
80101a37:	56                   	push   %esi
80101a38:	53                   	push   %ebx
80101a39:	83 ec 1c             	sub    $0x1c,%esp
80101a3c:	89 c3                	mov    %eax,%ebx
80101a3e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a41:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a44:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a47:	74 17                	je     80101a60 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a49:	e8 cc 17 00 00       	call   8010321a <myproc>
80101a4e:	83 ec 0c             	sub    $0xc,%esp
80101a51:	ff 70 68             	push   0x68(%eax)
80101a54:	e8 e6 fa ff ff       	call   8010153f <idup>
80101a59:	89 c6                	mov    %eax,%esi
80101a5b:	83 c4 10             	add    $0x10,%esp
80101a5e:	eb 53                	jmp    80101ab3 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a60:	ba 01 00 00 00       	mov    $0x1,%edx
80101a65:	b8 01 00 00 00       	mov    $0x1,%eax
80101a6a:	e8 88 f7 ff ff       	call   801011f7 <iget>
80101a6f:	89 c6                	mov    %eax,%esi
80101a71:	eb 40                	jmp    80101ab3 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a73:	83 ec 0c             	sub    $0xc,%esp
80101a76:	56                   	push   %esi
80101a77:	e8 9a fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101a7c:	83 c4 10             	add    $0x10,%esp
80101a7f:	be 00 00 00 00       	mov    $0x0,%esi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a84:	89 f0                	mov    %esi,%eax
80101a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a89:	5b                   	pop    %ebx
80101a8a:	5e                   	pop    %esi
80101a8b:	5f                   	pop    %edi
80101a8c:	5d                   	pop    %ebp
80101a8d:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a8e:	83 ec 04             	sub    $0x4,%esp
80101a91:	6a 00                	push   $0x0
80101a93:	ff 75 e4             	push   -0x1c(%ebp)
80101a96:	56                   	push   %esi
80101a97:	e8 03 ff ff ff       	call   8010199f <dirlookup>
80101a9c:	89 c7                	mov    %eax,%edi
80101a9e:	83 c4 10             	add    $0x10,%esp
80101aa1:	85 c0                	test   %eax,%eax
80101aa3:	74 4a                	je     80101aef <namex+0xbc>
    iunlockput(ip);
80101aa5:	83 ec 0c             	sub    $0xc,%esp
80101aa8:	56                   	push   %esi
80101aa9:	e8 68 fc ff ff       	call   80101716 <iunlockput>
80101aae:	83 c4 10             	add    $0x10,%esp
    ip = next;
80101ab1:	89 fe                	mov    %edi,%esi
  while((path = skipelem(path, name)) != 0){
80101ab3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ab6:	89 d8                	mov    %ebx,%eax
80101ab8:	e8 85 f4 ff ff       	call   80100f42 <skipelem>
80101abd:	89 c3                	mov    %eax,%ebx
80101abf:	85 c0                	test   %eax,%eax
80101ac1:	74 3c                	je     80101aff <namex+0xcc>
    ilock(ip);
80101ac3:	83 ec 0c             	sub    $0xc,%esp
80101ac6:	56                   	push   %esi
80101ac7:	e8 a3 fa ff ff       	call   8010156f <ilock>
    if(ip->type != T_DIR){
80101acc:	83 c4 10             	add    $0x10,%esp
80101acf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101ad4:	75 9d                	jne    80101a73 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ad6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ada:	74 b2                	je     80101a8e <namex+0x5b>
80101adc:	80 3b 00             	cmpb   $0x0,(%ebx)
80101adf:	75 ad                	jne    80101a8e <namex+0x5b>
      iunlock(ip);
80101ae1:	83 ec 0c             	sub    $0xc,%esp
80101ae4:	56                   	push   %esi
80101ae5:	e8 47 fb ff ff       	call   80101631 <iunlock>
      return ip;
80101aea:	83 c4 10             	add    $0x10,%esp
80101aed:	eb 95                	jmp    80101a84 <namex+0x51>
      iunlockput(ip);
80101aef:	83 ec 0c             	sub    $0xc,%esp
80101af2:	56                   	push   %esi
80101af3:	e8 1e fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101af8:	83 c4 10             	add    $0x10,%esp
80101afb:	89 fe                	mov    %edi,%esi
80101afd:	eb 85                	jmp    80101a84 <namex+0x51>
  if(nameiparent){
80101aff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b03:	0f 84 7b ff ff ff    	je     80101a84 <namex+0x51>
    iput(ip);
80101b09:	83 ec 0c             	sub    $0xc,%esp
80101b0c:	56                   	push   %esi
80101b0d:	e8 64 fb ff ff       	call   80101676 <iput>
    return 0;
80101b12:	83 c4 10             	add    $0x10,%esp
80101b15:	89 de                	mov    %ebx,%esi
80101b17:	e9 68 ff ff ff       	jmp    80101a84 <namex+0x51>

80101b1c <dirlink>:
{
80101b1c:	55                   	push   %ebp
80101b1d:	89 e5                	mov    %esp,%ebp
80101b1f:	57                   	push   %edi
80101b20:	56                   	push   %esi
80101b21:	53                   	push   %ebx
80101b22:	83 ec 20             	sub    $0x20,%esp
80101b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b28:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b2b:	6a 00                	push   $0x0
80101b2d:	57                   	push   %edi
80101b2e:	53                   	push   %ebx
80101b2f:	e8 6b fe ff ff       	call   8010199f <dirlookup>
80101b34:	83 c4 10             	add    $0x10,%esp
80101b37:	85 c0                	test   %eax,%eax
80101b39:	75 2d                	jne    80101b68 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b3b:	b8 00 00 00 00       	mov    $0x0,%eax
80101b40:	89 c6                	mov    %eax,%esi
80101b42:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b45:	76 41                	jbe    80101b88 <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b47:	6a 10                	push   $0x10
80101b49:	50                   	push   %eax
80101b4a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b4d:	50                   	push   %eax
80101b4e:	53                   	push   %ebx
80101b4f:	e8 0d fc ff ff       	call   80101761 <readi>
80101b54:	83 c4 10             	add    $0x10,%esp
80101b57:	83 f8 10             	cmp    $0x10,%eax
80101b5a:	75 1f                	jne    80101b7b <dirlink+0x5f>
    if(de.inum == 0)
80101b5c:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b61:	74 25                	je     80101b88 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b63:	8d 46 10             	lea    0x10(%esi),%eax
80101b66:	eb d8                	jmp    80101b40 <dirlink+0x24>
    iput(ip);
80101b68:	83 ec 0c             	sub    $0xc,%esp
80101b6b:	50                   	push   %eax
80101b6c:	e8 05 fb ff ff       	call   80101676 <iput>
    return -1;
80101b71:	83 c4 10             	add    $0x10,%esp
80101b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b79:	eb 3d                	jmp    80101bb8 <dirlink+0x9c>
      panic("dirlink read");
80101b7b:	83 ec 0c             	sub    $0xc,%esp
80101b7e:	68 c8 68 10 80       	push   $0x801068c8
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 ec 21 00 00       	call   80103d86 <strncpy>
  de.inum = inum;
80101b9a:	8b 45 10             	mov    0x10(%ebp),%eax
80101b9d:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ba1:	6a 10                	push   $0x10
80101ba3:	56                   	push   %esi
80101ba4:	57                   	push   %edi
80101ba5:	53                   	push   %ebx
80101ba6:	e8 b3 fc ff ff       	call   8010185e <writei>
80101bab:	83 c4 20             	add    $0x20,%esp
80101bae:	83 f8 10             	cmp    $0x10,%eax
80101bb1:	75 0d                	jne    80101bc0 <dirlink+0xa4>
  return 0;
80101bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bbb:	5b                   	pop    %ebx
80101bbc:	5e                   	pop    %esi
80101bbd:	5f                   	pop    %edi
80101bbe:	5d                   	pop    %ebp
80101bbf:	c3                   	ret    
    panic("dirlink");
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	68 88 6f 10 80       	push   $0x80106f88
80101bc8:	e8 7b e7 ff ff       	call   80100348 <panic>

80101bcd <namei>:

struct inode*
namei(char *path)
{
80101bcd:	55                   	push   %ebp
80101bce:	89 e5                	mov    %esp,%ebp
80101bd0:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bd3:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bd6:	ba 00 00 00 00       	mov    $0x0,%edx
80101bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bde:	e8 50 fe ff ff       	call   80101a33 <namex>
}
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101be5:	55                   	push   %ebp
80101be6:	89 e5                	mov    %esp,%ebp
80101be8:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101bee:	ba 01 00 00 00       	mov    $0x1,%edx
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	e8 38 fe ff ff       	call   80101a33 <namex>
}
80101bfb:	c9                   	leave  
80101bfc:	c3                   	ret    

80101bfd <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bfd:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101bff:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c04:	ec                   	in     (%dx),%al
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c05:	89 c2                	mov    %eax,%edx
80101c07:	83 e2 c0             	and    $0xffffffc0,%edx
80101c0a:	80 fa 40             	cmp    $0x40,%dl
80101c0d:	75 f0                	jne    80101bff <idewait+0x2>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c0f:	85 c9                	test   %ecx,%ecx
80101c11:	74 09                	je     80101c1c <idewait+0x1f>
80101c13:	a8 21                	test   $0x21,%al
80101c15:	75 08                	jne    80101c1f <idewait+0x22>
    return -1;
  return 0;
80101c17:	b9 00 00 00 00       	mov    $0x0,%ecx
}
80101c1c:	89 c8                	mov    %ecx,%eax
80101c1e:	c3                   	ret    
    return -1;
80101c1f:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
80101c24:	eb f6                	jmp    80101c1c <idewait+0x1f>

80101c26 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c26:	55                   	push   %ebp
80101c27:	89 e5                	mov    %esp,%ebp
80101c29:	56                   	push   %esi
80101c2a:	53                   	push   %ebx
  if(b == 0)
80101c2b:	85 c0                	test   %eax,%eax
80101c2d:	0f 84 8f 00 00 00    	je     80101cc2 <idestart+0x9c>
80101c33:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c35:	8b 58 08             	mov    0x8(%eax),%ebx
80101c38:	81 fb cf 07 00 00    	cmp    $0x7cf,%ebx
80101c3e:	0f 87 8b 00 00 00    	ja     80101ccf <idestart+0xa9>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c44:	b8 00 00 00 00       	mov    $0x0,%eax
80101c49:	e8 af ff ff ff       	call   80101bfd <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c4e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c53:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c58:	ee                   	out    %al,(%dx)
80101c59:	b8 01 00 00 00       	mov    $0x1,%eax
80101c5e:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c63:	ee                   	out    %al,(%dx)
80101c64:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c69:	89 d8                	mov    %ebx,%eax
80101c6b:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c6c:	0f b6 c7             	movzbl %bh,%eax
80101c6f:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c74:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c75:	89 d8                	mov    %ebx,%eax
80101c77:	c1 f8 10             	sar    $0x10,%eax
80101c7a:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c7f:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c80:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c84:	c1 e0 04             	shl    $0x4,%eax
80101c87:	83 e0 10             	and    $0x10,%eax
80101c8a:	c1 fb 18             	sar    $0x18,%ebx
80101c8d:	83 e3 0f             	and    $0xf,%ebx
80101c90:	09 d8                	or     %ebx,%eax
80101c92:	83 c8 e0             	or     $0xffffffe0,%eax
80101c95:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c9a:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101c9b:	f6 06 04             	testb  $0x4,(%esi)
80101c9e:	74 3c                	je     80101cdc <idestart+0xb6>
80101ca0:	b8 30 00 00 00       	mov    $0x30,%eax
80101ca5:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101caa:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101cab:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cae:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cb3:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cb8:	fc                   	cld    
80101cb9:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cbe:	5b                   	pop    %ebx
80101cbf:	5e                   	pop    %esi
80101cc0:	5d                   	pop    %ebp
80101cc1:	c3                   	ret    
    panic("idestart");
80101cc2:	83 ec 0c             	sub    $0xc,%esp
80101cc5:	68 2b 69 10 80       	push   $0x8010692b
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 34 69 10 80       	push   $0x80106934
80101cd7:	e8 6c e6 ff ff       	call   80100348 <panic>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101cdc:	b8 20 00 00 00       	mov    $0x20,%eax
80101ce1:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ce6:	ee                   	out    %al,(%dx)
}
80101ce7:	eb d2                	jmp    80101cbb <idestart+0x95>

80101ce9 <ideinit>:
{
80101ce9:	55                   	push   %ebp
80101cea:	89 e5                	mov    %esp,%ebp
80101cec:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101cef:	68 46 69 10 80       	push   $0x80106946
80101cf4:	68 00 16 11 80       	push   $0x80111600
80101cf9:	e8 7d 1d 00 00       	call   80103a7b <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101cfe:	83 c4 08             	add    $0x8,%esp
80101d01:	a1 84 17 11 80       	mov    0x80111784,%eax
80101d06:	83 e8 01             	sub    $0x1,%eax
80101d09:	50                   	push   %eax
80101d0a:	6a 0e                	push   $0xe
80101d0c:	e8 50 02 00 00       	call   80101f61 <ioapicenable>
  idewait(0);
80101d11:	b8 00 00 00 00       	mov    $0x0,%eax
80101d16:	e8 e2 fe ff ff       	call   80101bfd <idewait>
80101d1b:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d20:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d25:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d26:	83 c4 10             	add    $0x10,%esp
80101d29:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d2e:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d34:	7f 19                	jg     80101d4f <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d36:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d3b:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d3c:	84 c0                	test   %al,%al
80101d3e:	75 05                	jne    80101d45 <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d40:	83 c1 01             	add    $0x1,%ecx
80101d43:	eb e9                	jmp    80101d2e <ideinit+0x45>
      havedisk1 = 1;
80101d45:	c7 05 e0 15 11 80 01 	movl   $0x1,0x801115e0
80101d4c:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d4f:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d54:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d59:	ee                   	out    %al,(%dx)
}
80101d5a:	c9                   	leave  
80101d5b:	c3                   	ret    

80101d5c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d5c:	55                   	push   %ebp
80101d5d:	89 e5                	mov    %esp,%ebp
80101d5f:	57                   	push   %edi
80101d60:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d61:	83 ec 0c             	sub    $0xc,%esp
80101d64:	68 00 16 11 80       	push   $0x80111600
80101d69:	e8 49 1e 00 00       	call   80103bb7 <acquire>

  if((b = idequeue) == 0){
80101d6e:	8b 1d e4 15 11 80    	mov    0x801115e4,%ebx
80101d74:	83 c4 10             	add    $0x10,%esp
80101d77:	85 db                	test   %ebx,%ebx
80101d79:	74 4a                	je     80101dc5 <ideintr+0x69>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d7b:	8b 43 58             	mov    0x58(%ebx),%eax
80101d7e:	a3 e4 15 11 80       	mov    %eax,0x801115e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d83:	f6 03 04             	testb  $0x4,(%ebx)
80101d86:	74 4f                	je     80101dd7 <ideintr+0x7b>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d88:	8b 03                	mov    (%ebx),%eax
80101d8a:	83 c8 02             	or     $0x2,%eax
80101d8d:	89 03                	mov    %eax,(%ebx)
  b->flags &= ~B_DIRTY;
80101d8f:	83 e0 fb             	and    $0xfffffffb,%eax
80101d92:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d94:	83 ec 0c             	sub    $0xc,%esp
80101d97:	53                   	push   %ebx
80101d98:	e8 84 1a 00 00       	call   80103821 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101d9d:	a1 e4 15 11 80       	mov    0x801115e4,%eax
80101da2:	83 c4 10             	add    $0x10,%esp
80101da5:	85 c0                	test   %eax,%eax
80101da7:	74 05                	je     80101dae <ideintr+0x52>
    idestart(idequeue);
80101da9:	e8 78 fe ff ff       	call   80101c26 <idestart>

  release(&idelock);
80101dae:	83 ec 0c             	sub    $0xc,%esp
80101db1:	68 00 16 11 80       	push   $0x80111600
80101db6:	e8 61 1e 00 00       	call   80103c1c <release>
80101dbb:	83 c4 10             	add    $0x10,%esp
}
80101dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dc1:	5b                   	pop    %ebx
80101dc2:	5f                   	pop    %edi
80101dc3:	5d                   	pop    %ebp
80101dc4:	c3                   	ret    
    release(&idelock);
80101dc5:	83 ec 0c             	sub    $0xc,%esp
80101dc8:	68 00 16 11 80       	push   $0x80111600
80101dcd:	e8 4a 1e 00 00       	call   80103c1c <release>
    return;
80101dd2:	83 c4 10             	add    $0x10,%esp
80101dd5:	eb e7                	jmp    80101dbe <ideintr+0x62>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dd7:	b8 01 00 00 00       	mov    $0x1,%eax
80101ddc:	e8 1c fe ff ff       	call   80101bfd <idewait>
80101de1:	85 c0                	test   %eax,%eax
80101de3:	78 a3                	js     80101d88 <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101de5:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101de8:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ded:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101df2:	fc                   	cld    
80101df3:	f3 6d                	rep insl (%dx),%es:(%edi)
}
80101df5:	eb 91                	jmp    80101d88 <ideintr+0x2c>

80101df7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101df7:	55                   	push   %ebp
80101df8:	89 e5                	mov    %esp,%ebp
80101dfa:	53                   	push   %ebx
80101dfb:	83 ec 10             	sub    $0x10,%esp
80101dfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e01:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e04:	50                   	push   %eax
80101e05:	e8 23 1c 00 00       	call   80103a2d <holdingsleep>
80101e0a:	83 c4 10             	add    $0x10,%esp
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 37                	je     80101e48 <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e11:	8b 03                	mov    (%ebx),%eax
80101e13:	83 e0 06             	and    $0x6,%eax
80101e16:	83 f8 02             	cmp    $0x2,%eax
80101e19:	74 3a                	je     80101e55 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e1b:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e1f:	74 09                	je     80101e2a <iderw+0x33>
80101e21:	83 3d e0 15 11 80 00 	cmpl   $0x0,0x801115e0
80101e28:	74 38                	je     80101e62 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e2a:	83 ec 0c             	sub    $0xc,%esp
80101e2d:	68 00 16 11 80       	push   $0x80111600
80101e32:	e8 80 1d 00 00       	call   80103bb7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 4a 69 10 80       	push   $0x8010694a
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 60 69 10 80       	push   $0x80106960
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 75 69 10 80       	push   $0x80106975
80101e6a:	e8 d9 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e6f:	8d 50 58             	lea    0x58(%eax),%edx
80101e72:	8b 02                	mov    (%edx),%eax
80101e74:	85 c0                	test   %eax,%eax
80101e76:	75 f7                	jne    80101e6f <iderw+0x78>
    ;
  *pp = b;
80101e78:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e7a:	39 1d e4 15 11 80    	cmp    %ebx,0x801115e4
80101e80:	75 1a                	jne    80101e9c <iderw+0xa5>
    idestart(b);
80101e82:	89 d8                	mov    %ebx,%eax
80101e84:	e8 9d fd ff ff       	call   80101c26 <idestart>
80101e89:	eb 11                	jmp    80101e9c <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	68 00 16 11 80       	push   $0x80111600
80101e93:	53                   	push   %ebx
80101e94:	e8 23 18 00 00       	call   801036bc <sleep>
80101e99:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e9c:	8b 03                	mov    (%ebx),%eax
80101e9e:	83 e0 06             	and    $0x6,%eax
80101ea1:	83 f8 02             	cmp    $0x2,%eax
80101ea4:	75 e5                	jne    80101e8b <iderw+0x94>
  }


  release(&idelock);
80101ea6:	83 ec 0c             	sub    $0xc,%esp
80101ea9:	68 00 16 11 80       	push   $0x80111600
80101eae:	e8 69 1d 00 00       	call   80103c1c <release>
}
80101eb3:	83 c4 10             	add    $0x10,%esp
80101eb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101eb9:	c9                   	leave  
80101eba:	c3                   	ret    

80101ebb <ioapicread>:
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101ebb:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101ec1:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ec3:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ec8:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ecb:	c3                   	ret    

80101ecc <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80101ecc:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101ed2:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ed4:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ed9:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edc:	c3                   	ret    

80101edd <ioapicinit>:

void
ioapicinit(void)
{
80101edd:	55                   	push   %ebp
80101ede:	89 e5                	mov    %esp,%ebp
80101ee0:	57                   	push   %edi
80101ee1:	56                   	push   %esi
80101ee2:	53                   	push   %ebx
80101ee3:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101ee6:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101eed:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101ef0:	b8 01 00 00 00       	mov    $0x1,%eax
80101ef5:	e8 c1 ff ff ff       	call   80101ebb <ioapicread>
80101efa:	c1 e8 10             	shr    $0x10,%eax
80101efd:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f00:	b8 00 00 00 00       	mov    $0x0,%eax
80101f05:	e8 b1 ff ff ff       	call   80101ebb <ioapicread>
80101f0a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f0d:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
80101f14:	39 c2                	cmp    %eax,%edx
80101f16:	75 07                	jne    80101f1f <ioapicinit+0x42>
{
80101f18:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f1d:	eb 36                	jmp    80101f55 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f1f:	83 ec 0c             	sub    $0xc,%esp
80101f22:	68 94 69 10 80       	push   $0x80106994
80101f27:	e8 db e6 ff ff       	call   80100607 <cprintf>
80101f2c:	83 c4 10             	add    $0x10,%esp
80101f2f:	eb e7                	jmp    80101f18 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f31:	8d 53 20             	lea    0x20(%ebx),%edx
80101f34:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f3a:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f3e:	89 f0                	mov    %esi,%eax
80101f40:	e8 87 ff ff ff       	call   80101ecc <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f45:	8d 46 01             	lea    0x1(%esi),%eax
80101f48:	ba 00 00 00 00       	mov    $0x0,%edx
80101f4d:	e8 7a ff ff ff       	call   80101ecc <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f52:	83 c3 01             	add    $0x1,%ebx
80101f55:	39 fb                	cmp    %edi,%ebx
80101f57:	7e d8                	jle    80101f31 <ioapicinit+0x54>
  }
}
80101f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f5c:	5b                   	pop    %ebx
80101f5d:	5e                   	pop    %esi
80101f5e:	5f                   	pop    %edi
80101f5f:	5d                   	pop    %ebp
80101f60:	c3                   	ret    

80101f61 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f61:	55                   	push   %ebp
80101f62:	89 e5                	mov    %esp,%ebp
80101f64:	53                   	push   %ebx
80101f65:	83 ec 04             	sub    $0x4,%esp
80101f68:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f6b:	8d 50 20             	lea    0x20(%eax),%edx
80101f6e:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f72:	89 d8                	mov    %ebx,%eax
80101f74:	e8 53 ff ff ff       	call   80101ecc <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f7c:	c1 e2 18             	shl    $0x18,%edx
80101f7f:	8d 43 01             	lea    0x1(%ebx),%eax
80101f82:	e8 45 ff ff ff       	call   80101ecc <ioapicwrite>
}
80101f87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f8a:	c9                   	leave  
80101f8b:	c3                   	ret    

80101f8c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f8c:	55                   	push   %ebp
80101f8d:	89 e5                	mov    %esp,%ebp
80101f8f:	53                   	push   %ebx
80101f90:	83 ec 04             	sub    $0x4,%esp
80101f93:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f96:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101f9c:	75 61                	jne    80101fff <kfree+0x73>
80101f9e:	81 fb d0 54 11 80    	cmp    $0x801154d0,%ebx
80101fa4:	72 59                	jb     80101fff <kfree+0x73>

// Convert kernel virtual address to physical address
static inline uint V2P(void *a) {
    // define panic() here because memlayout.h is included before defs.h
    extern void panic(char*) __attribute__((noreturn));
    if (a < (void*) KERNBASE)
80101fa6:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80101fac:	76 44                	jbe    80101ff2 <kfree+0x66>
        panic("V2P on address < KERNBASE "
              "(not a kernel virtual address; consider walking page "
              "table to determine physical address of a user virtual address)");
    return (uint)a - KERNBASE;
80101fae:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fb4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fb9:	77 44                	ja     80101fff <kfree+0x73>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fbb:	83 ec 04             	sub    $0x4,%esp
80101fbe:	68 00 10 00 00       	push   $0x1000
80101fc3:	6a 01                	push   $0x1
80101fc5:	53                   	push   %ebx
80101fc6:	e8 98 1c 00 00       	call   80103c63 <memset>

  if(kmem.use_lock)
80101fcb:	83 c4 10             	add    $0x10,%esp
80101fce:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101fd5:	75 35                	jne    8010200c <kfree+0x80>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fd7:	a1 78 16 11 80       	mov    0x80111678,%eax
80101fdc:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fde:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101fe4:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101feb:	75 31                	jne    8010201e <kfree+0x92>
    release(&kmem.lock);
}
80101fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ff0:	c9                   	leave  
80101ff1:	c3                   	ret    
        panic("V2P on address < KERNBASE "
80101ff2:	83 ec 0c             	sub    $0xc,%esp
80101ff5:	68 c8 69 10 80       	push   $0x801069c8
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 56 6a 10 80       	push   $0x80106a56
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 16 11 80       	push   $0x80111640
80102014:	e8 9e 1b 00 00       	call   80103bb7 <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 16 11 80       	push   $0x80111640
80102026:	e8 f1 1b 00 00       	call   80103c1c <release>
8010202b:	83 c4 10             	add    $0x10,%esp
}
8010202e:	eb bd                	jmp    80101fed <kfree+0x61>

80102030 <freerange>:
{
80102030:	55                   	push   %ebp
80102031:	89 e5                	mov    %esp,%ebp
80102033:	56                   	push   %esi
80102034:	53                   	push   %ebx
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if (vend < vstart) panic("freerange");
8010203b:	39 c3                	cmp    %eax,%ebx
8010203d:	72 0c                	jb     8010204b <freerange+0x1b>
  p = (char*)PGROUNDUP((uint)vstart);
8010203f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102049:	eb 1b                	jmp    80102066 <freerange+0x36>
  if (vend < vstart) panic("freerange");
8010204b:	83 ec 0c             	sub    $0xc,%esp
8010204e:	68 5c 6a 10 80       	push   $0x80106a5c
80102053:	e8 f0 e2 ff ff       	call   80100348 <panic>
    kfree(p);
80102058:	83 ec 0c             	sub    $0xc,%esp
8010205b:	50                   	push   %eax
8010205c:	e8 2b ff ff ff       	call   80101f8c <kfree>
80102061:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102064:	89 f0                	mov    %esi,%eax
80102066:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010206c:	39 de                	cmp    %ebx,%esi
8010206e:	76 e8                	jbe    80102058 <freerange+0x28>
}
80102070:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102073:	5b                   	pop    %ebx
80102074:	5e                   	pop    %esi
80102075:	5d                   	pop    %ebp
80102076:	c3                   	ret    

80102077 <kinit1>:
{
80102077:	55                   	push   %ebp
80102078:	89 e5                	mov    %esp,%ebp
8010207a:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010207d:	68 66 6a 10 80       	push   $0x80106a66
80102082:	68 40 16 11 80       	push   $0x80111640
80102087:	e8 ef 19 00 00       	call   80103a7b <initlock>
  kmem.use_lock = 0;
8010208c:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102093:	00 00 00 
  freerange(vstart, vend);
80102096:	83 c4 08             	add    $0x8,%esp
80102099:	ff 75 0c             	push   0xc(%ebp)
8010209c:	ff 75 08             	push   0x8(%ebp)
8010209f:	e8 8c ff ff ff       	call   80102030 <freerange>
}
801020a4:	83 c4 10             	add    $0x10,%esp
801020a7:	c9                   	leave  
801020a8:	c3                   	ret    

801020a9 <kinit2>:
{
801020a9:	55                   	push   %ebp
801020aa:	89 e5                	mov    %esp,%ebp
801020ac:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020af:	ff 75 0c             	push   0xc(%ebp)
801020b2:	ff 75 08             	push   0x8(%ebp)
801020b5:	e8 76 ff ff ff       	call   80102030 <freerange>
  kmem.use_lock = 1;
801020ba:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
801020c1:	00 00 00 
}
801020c4:	83 c4 10             	add    $0x10,%esp
801020c7:	c9                   	leave  
801020c8:	c3                   	ret    

801020c9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020c9:	55                   	push   %ebp
801020ca:	89 e5                	mov    %esp,%ebp
801020cc:	53                   	push   %ebx
801020cd:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020d0:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020d7:	75 21                	jne    801020fa <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020d9:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
801020df:	85 db                	test   %ebx,%ebx
801020e1:	74 07                	je     801020ea <kalloc+0x21>
    kmem.freelist = r->next;
801020e3:	8b 03                	mov    (%ebx),%eax
801020e5:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
801020ea:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020f1:	75 19                	jne    8010210c <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020f3:	89 d8                	mov    %ebx,%eax
801020f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020f8:	c9                   	leave  
801020f9:	c3                   	ret    
    acquire(&kmem.lock);
801020fa:	83 ec 0c             	sub    $0xc,%esp
801020fd:	68 40 16 11 80       	push   $0x80111640
80102102:	e8 b0 1a 00 00       	call   80103bb7 <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 16 11 80       	push   $0x80111640
80102114:	e8 03 1b 00 00       	call   80103c1c <release>
80102119:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010211c:	eb d5                	jmp    801020f3 <kalloc+0x2a>

8010211e <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010211e:	ba 64 00 00 00       	mov    $0x64,%edx
80102123:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102124:	a8 01                	test   $0x1,%al
80102126:	0f 84 b4 00 00 00    	je     801021e0 <kbdgetc+0xc2>
8010212c:	ba 60 00 00 00       	mov    $0x60,%edx
80102131:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102132:	0f b6 c8             	movzbl %al,%ecx

  if(data == 0xE0){
80102135:	3c e0                	cmp    $0xe0,%al
80102137:	74 61                	je     8010219a <kbdgetc+0x7c>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102139:	84 c0                	test   %al,%al
8010213b:	78 6a                	js     801021a7 <kbdgetc+0x89>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010213d:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
80102143:	f6 c2 40             	test   $0x40,%dl
80102146:	74 0f                	je     80102157 <kbdgetc+0x39>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102148:	83 c8 80             	or     $0xffffff80,%eax
8010214b:	0f b6 c8             	movzbl %al,%ecx
    shift &= ~E0ESC;
8010214e:	83 e2 bf             	and    $0xffffffbf,%edx
80102151:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  }

  shift |= shiftcode[data];
80102157:	0f b6 91 a0 6b 10 80 	movzbl -0x7fef9460(%ecx),%edx
8010215e:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
80102164:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
8010216a:	0f b6 81 a0 6a 10 80 	movzbl -0x7fef9560(%ecx),%eax
80102171:	31 c2                	xor    %eax,%edx
80102173:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102179:	89 d0                	mov    %edx,%eax
8010217b:	83 e0 03             	and    $0x3,%eax
8010217e:	8b 04 85 80 6a 10 80 	mov    -0x7fef9580(,%eax,4),%eax
80102185:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102189:	f6 c2 08             	test   $0x8,%dl
8010218c:	74 57                	je     801021e5 <kbdgetc+0xc7>
    if('a' <= c && c <= 'z')
8010218e:	8d 50 9f             	lea    -0x61(%eax),%edx
80102191:	83 fa 19             	cmp    $0x19,%edx
80102194:	77 3e                	ja     801021d4 <kbdgetc+0xb6>
      c += 'A' - 'a';
80102196:	83 e8 20             	sub    $0x20,%eax
80102199:	c3                   	ret    
    shift |= E0ESC;
8010219a:	83 0d 7c 16 11 80 40 	orl    $0x40,0x8011167c
    return 0;
801021a1:	b8 00 00 00 00       	mov    $0x0,%eax
801021a6:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021a7:	8b 15 7c 16 11 80    	mov    0x8011167c,%edx
801021ad:	f6 c2 40             	test   $0x40,%dl
801021b0:	75 05                	jne    801021b7 <kbdgetc+0x99>
801021b2:	89 c1                	mov    %eax,%ecx
801021b4:	83 e1 7f             	and    $0x7f,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801021b7:	0f b6 81 a0 6b 10 80 	movzbl -0x7fef9460(%ecx),%eax
801021be:	83 c8 40             	or     $0x40,%eax
801021c1:	0f b6 c0             	movzbl %al,%eax
801021c4:	f7 d0                	not    %eax
801021c6:	21 c2                	and    %eax,%edx
801021c8:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
    return 0;
801021ce:	b8 00 00 00 00       	mov    $0x0,%eax
801021d3:	c3                   	ret    
    else if('A' <= c && c <= 'Z')
801021d4:	8d 50 bf             	lea    -0x41(%eax),%edx
801021d7:	83 fa 19             	cmp    $0x19,%edx
801021da:	77 09                	ja     801021e5 <kbdgetc+0xc7>
      c += 'a' - 'A';
801021dc:	83 c0 20             	add    $0x20,%eax
  }
  return c;
801021df:	c3                   	ret    
    return -1;
801021e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801021e5:	c3                   	ret    

801021e6 <kbdintr>:

void
kbdintr(void)
{
801021e6:	55                   	push   %ebp
801021e7:	89 e5                	mov    %esp,%ebp
801021e9:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021ec:	68 1e 21 10 80       	push   $0x8010211e
801021f1:	e8 3d e5 ff ff       	call   80100733 <consoleintr>
}
801021f6:	83 c4 10             	add    $0x10,%esp
801021f9:	c9                   	leave  
801021fa:	c3                   	ret    

801021fb <shutdown>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021fb:	b8 00 00 00 00       	mov    $0x0,%eax
80102200:	ba 01 05 00 00       	mov    $0x501,%edx
80102205:	ee                   	out    %al,(%dx)
  /*
     This only works in QEMU and assumes QEMU was run 
     with -device isa-debug-exit
   */
  outb(0x501, 0x0);
}
80102206:	c3                   	ret    

80102207 <lapicw>:

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102207:	8b 0d 80 16 11 80    	mov    0x80111680,%ecx
8010220d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102210:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102212:	a1 80 16 11 80       	mov    0x80111680,%eax
80102217:	8b 40 20             	mov    0x20(%eax),%eax
}
8010221a:	c3                   	ret    

8010221b <cmos_read>:
8010221b:	ba 70 00 00 00       	mov    $0x70,%edx
80102220:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102221:	ba 71 00 00 00       	mov    $0x71,%edx
80102226:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102227:	0f b6 c0             	movzbl %al,%eax
}
8010222a:	c3                   	ret    

8010222b <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010222b:	55                   	push   %ebp
8010222c:	89 e5                	mov    %esp,%ebp
8010222e:	53                   	push   %ebx
8010222f:	83 ec 04             	sub    $0x4,%esp
80102232:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102234:	b8 00 00 00 00       	mov    $0x0,%eax
80102239:	e8 dd ff ff ff       	call   8010221b <cmos_read>
8010223e:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102240:	b8 02 00 00 00       	mov    $0x2,%eax
80102245:	e8 d1 ff ff ff       	call   8010221b <cmos_read>
8010224a:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010224d:	b8 04 00 00 00       	mov    $0x4,%eax
80102252:	e8 c4 ff ff ff       	call   8010221b <cmos_read>
80102257:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010225a:	b8 07 00 00 00       	mov    $0x7,%eax
8010225f:	e8 b7 ff ff ff       	call   8010221b <cmos_read>
80102264:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102267:	b8 08 00 00 00       	mov    $0x8,%eax
8010226c:	e8 aa ff ff ff       	call   8010221b <cmos_read>
80102271:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102274:	b8 09 00 00 00       	mov    $0x9,%eax
80102279:	e8 9d ff ff ff       	call   8010221b <cmos_read>
8010227e:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <lapicinit>:
  if(!lapic)
80102286:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
8010228d:	0f 84 fe 00 00 00    	je     80102391 <lapicinit+0x10b>
{
80102293:	55                   	push   %ebp
80102294:	89 e5                	mov    %esp,%ebp
80102296:	83 ec 08             	sub    $0x8,%esp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102299:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010229e:	b8 3c 00 00 00       	mov    $0x3c,%eax
801022a3:	e8 5f ff ff ff       	call   80102207 <lapicw>
  lapicw(TDCR, X1);
801022a8:	ba 0b 00 00 00       	mov    $0xb,%edx
801022ad:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022b2:	e8 50 ff ff ff       	call   80102207 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022b7:	ba 20 00 02 00       	mov    $0x20020,%edx
801022bc:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022c1:	e8 41 ff ff ff       	call   80102207 <lapicw>
  lapicw(TICR, 10000000);
801022c6:	ba 80 96 98 00       	mov    $0x989680,%edx
801022cb:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022d0:	e8 32 ff ff ff       	call   80102207 <lapicw>
  lapicw(LINT0, MASKED);
801022d5:	ba 00 00 01 00       	mov    $0x10000,%edx
801022da:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022df:	e8 23 ff ff ff       	call   80102207 <lapicw>
  lapicw(LINT1, MASKED);
801022e4:	ba 00 00 01 00       	mov    $0x10000,%edx
801022e9:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022ee:	e8 14 ff ff ff       	call   80102207 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022f3:	a1 80 16 11 80       	mov    0x80111680,%eax
801022f8:	8b 40 30             	mov    0x30(%eax),%eax
801022fb:	c1 e8 10             	shr    $0x10,%eax
801022fe:	a8 fc                	test   $0xfc,%al
80102300:	75 7b                	jne    8010237d <lapicinit+0xf7>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102302:	ba 33 00 00 00       	mov    $0x33,%edx
80102307:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010230c:	e8 f6 fe ff ff       	call   80102207 <lapicw>
  lapicw(ESR, 0);
80102311:	ba 00 00 00 00       	mov    $0x0,%edx
80102316:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010231b:	e8 e7 fe ff ff       	call   80102207 <lapicw>
  lapicw(ESR, 0);
80102320:	ba 00 00 00 00       	mov    $0x0,%edx
80102325:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010232a:	e8 d8 fe ff ff       	call   80102207 <lapicw>
  lapicw(EOI, 0);
8010232f:	ba 00 00 00 00       	mov    $0x0,%edx
80102334:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102339:	e8 c9 fe ff ff       	call   80102207 <lapicw>
  lapicw(ICRHI, 0);
8010233e:	ba 00 00 00 00       	mov    $0x0,%edx
80102343:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102348:	e8 ba fe ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010234d:	ba 00 85 08 00       	mov    $0x88500,%edx
80102352:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102357:	e8 ab fe ff ff       	call   80102207 <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010235c:	a1 80 16 11 80       	mov    0x80111680,%eax
80102361:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102367:	f6 c4 10             	test   $0x10,%ah
8010236a:	75 f0                	jne    8010235c <lapicinit+0xd6>
  lapicw(TPR, 0);
8010236c:	ba 00 00 00 00       	mov    $0x0,%edx
80102371:	b8 20 00 00 00       	mov    $0x20,%eax
80102376:	e8 8c fe ff ff       	call   80102207 <lapicw>
}
8010237b:	c9                   	leave  
8010237c:	c3                   	ret    
    lapicw(PCINT, MASKED);
8010237d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102382:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102387:	e8 7b fe ff ff       	call   80102207 <lapicw>
8010238c:	e9 71 ff ff ff       	jmp    80102302 <lapicinit+0x7c>
80102391:	c3                   	ret    

80102392 <lapicid>:
  if (!lapic)
80102392:	a1 80 16 11 80       	mov    0x80111680,%eax
80102397:	85 c0                	test   %eax,%eax
80102399:	74 07                	je     801023a2 <lapicid+0x10>
  return lapic[ID] >> 24;
8010239b:	8b 40 20             	mov    0x20(%eax),%eax
8010239e:	c1 e8 18             	shr    $0x18,%eax
801023a1:	c3                   	ret    
    return 0;
801023a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023a7:	c3                   	ret    

801023a8 <lapiceoi>:
  if(lapic)
801023a8:	83 3d 80 16 11 80 00 	cmpl   $0x0,0x80111680
801023af:	74 17                	je     801023c8 <lapiceoi+0x20>
{
801023b1:	55                   	push   %ebp
801023b2:	89 e5                	mov    %esp,%ebp
801023b4:	83 ec 08             	sub    $0x8,%esp
    lapicw(EOI, 0);
801023b7:	ba 00 00 00 00       	mov    $0x0,%edx
801023bc:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023c1:	e8 41 fe ff ff       	call   80102207 <lapicw>
}
801023c6:	c9                   	leave  
801023c7:	c3                   	ret    
801023c8:	c3                   	ret    

801023c9 <microdelay>:
}
801023c9:	c3                   	ret    

801023ca <lapicstartap>:
{
801023ca:	55                   	push   %ebp
801023cb:	89 e5                	mov    %esp,%ebp
801023cd:	57                   	push   %edi
801023ce:	56                   	push   %esi
801023cf:	53                   	push   %ebx
801023d0:	83 ec 0c             	sub    $0xc,%esp
801023d3:	8b 75 08             	mov    0x8(%ebp),%esi
801023d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023d9:	b8 0f 00 00 00       	mov    $0xf,%eax
801023de:	ba 70 00 00 00       	mov    $0x70,%edx
801023e3:	ee                   	out    %al,(%dx)
801023e4:	b8 0a 00 00 00       	mov    $0xa,%eax
801023e9:	ba 71 00 00 00       	mov    $0x71,%edx
801023ee:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023ef:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023f6:	00 00 
  wrv[1] = addr >> 4;
801023f8:	89 f8                	mov    %edi,%eax
801023fa:	c1 e8 04             	shr    $0x4,%eax
801023fd:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102403:	c1 e6 18             	shl    $0x18,%esi
80102406:	89 f2                	mov    %esi,%edx
80102408:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010240d:	e8 f5 fd ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102412:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102417:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241c:	e8 e6 fd ff ff       	call   80102207 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102421:	ba 00 85 00 00       	mov    $0x8500,%edx
80102426:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010242b:	e8 d7 fd ff ff       	call   80102207 <lapicw>
  for(i = 0; i < 2; i++){
80102430:	bb 00 00 00 00       	mov    $0x0,%ebx
80102435:	eb 21                	jmp    80102458 <lapicstartap+0x8e>
    lapicw(ICRHI, apicid<<24);
80102437:	89 f2                	mov    %esi,%edx
80102439:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010243e:	e8 c4 fd ff ff       	call   80102207 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102443:	89 fa                	mov    %edi,%edx
80102445:	c1 ea 0c             	shr    $0xc,%edx
80102448:	80 ce 06             	or     $0x6,%dh
8010244b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102450:	e8 b2 fd ff ff       	call   80102207 <lapicw>
  for(i = 0; i < 2; i++){
80102455:	83 c3 01             	add    $0x1,%ebx
80102458:	83 fb 01             	cmp    $0x1,%ebx
8010245b:	7e da                	jle    80102437 <lapicstartap+0x6d>
}
8010245d:	83 c4 0c             	add    $0xc,%esp
80102460:	5b                   	pop    %ebx
80102461:	5e                   	pop    %esi
80102462:	5f                   	pop    %edi
80102463:	5d                   	pop    %ebp
80102464:	c3                   	ret    

80102465 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102465:	55                   	push   %ebp
80102466:	89 e5                	mov    %esp,%ebp
80102468:	57                   	push   %edi
80102469:	56                   	push   %esi
8010246a:	53                   	push   %ebx
8010246b:	83 ec 3c             	sub    $0x3c,%esp
8010246e:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102471:	b8 0b 00 00 00       	mov    $0xb,%eax
80102476:	e8 a0 fd ff ff       	call   8010221b <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
8010247b:	83 e0 04             	and    $0x4,%eax
8010247e:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102480:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102483:	e8 a3 fd ff ff       	call   8010222b <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102488:	b8 0a 00 00 00       	mov    $0xa,%eax
8010248d:	e8 89 fd ff ff       	call   8010221b <cmos_read>
80102492:	a8 80                	test   $0x80,%al
80102494:	75 ea                	jne    80102480 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102496:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102499:	89 d8                	mov    %ebx,%eax
8010249b:	e8 8b fd ff ff       	call   8010222b <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801024a0:	83 ec 04             	sub    $0x4,%esp
801024a3:	6a 18                	push   $0x18
801024a5:	53                   	push   %ebx
801024a6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024a9:	50                   	push   %eax
801024aa:	e8 f7 17 00 00       	call   80103ca6 <memcmp>
801024af:	83 c4 10             	add    $0x10,%esp
801024b2:	85 c0                	test   %eax,%eax
801024b4:	75 ca                	jne    80102480 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024b6:	85 ff                	test   %edi,%edi
801024b8:	75 78                	jne    80102532 <cmostime+0xcd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
801024bd:	89 c2                	mov    %eax,%edx
801024bf:	c1 ea 04             	shr    $0x4,%edx
801024c2:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024c5:	83 e0 0f             	and    $0xf,%eax
801024c8:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801024d1:	89 c2                	mov    %eax,%edx
801024d3:	c1 ea 04             	shr    $0x4,%edx
801024d6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024d9:	83 e0 0f             	and    $0xf,%eax
801024dc:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801024e5:	89 c2                	mov    %eax,%edx
801024e7:	c1 ea 04             	shr    $0x4,%edx
801024ea:	8d 14 92             	lea    (%edx,%edx,4),%edx
801024ed:	83 e0 0f             	and    $0xf,%eax
801024f0:	8d 04 50             	lea    (%eax,%edx,2),%eax
801024f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801024f9:	89 c2                	mov    %eax,%edx
801024fb:	c1 ea 04             	shr    $0x4,%edx
801024fe:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102501:	83 e0 0f             	and    $0xf,%eax
80102504:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102507:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010250a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010250d:	89 c2                	mov    %eax,%edx
8010250f:	c1 ea 04             	shr    $0x4,%edx
80102512:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102515:	83 e0 0f             	and    $0xf,%eax
80102518:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010251b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010251e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102521:	89 c2                	mov    %eax,%edx
80102523:	c1 ea 04             	shr    $0x4,%edx
80102526:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102529:	83 e0 0f             	and    $0xf,%eax
8010252c:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010252f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102532:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102535:	89 06                	mov    %eax,(%esi)
80102537:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010253a:	89 46 04             	mov    %eax,0x4(%esi)
8010253d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102540:	89 46 08             	mov    %eax,0x8(%esi)
80102543:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102546:	89 46 0c             	mov    %eax,0xc(%esi)
80102549:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010254c:	89 46 10             	mov    %eax,0x10(%esi)
8010254f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102552:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102555:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010255c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010255f:	5b                   	pop    %ebx
80102560:	5e                   	pop    %esi
80102561:	5f                   	pop    %edi
80102562:	5d                   	pop    %ebp
80102563:	c3                   	ret    

80102564 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102564:	55                   	push   %ebp
80102565:	89 e5                	mov    %esp,%ebp
80102567:	53                   	push   %ebx
80102568:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010256b:	ff 35 d4 16 11 80    	push   0x801116d4
80102571:	ff 35 e4 16 11 80    	push   0x801116e4
80102577:	e8 f0 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010257c:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010257f:	89 1d e8 16 11 80    	mov    %ebx,0x801116e8
  for (i = 0; i < log.lh.n; i++) {
80102585:	83 c4 10             	add    $0x10,%esp
80102588:	ba 00 00 00 00       	mov    $0x0,%edx
8010258d:	eb 0e                	jmp    8010259d <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010258f:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102593:	89 0c 95 ec 16 11 80 	mov    %ecx,-0x7feee914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010259a:	83 c2 01             	add    $0x1,%edx
8010259d:	39 d3                	cmp    %edx,%ebx
8010259f:	7f ee                	jg     8010258f <read_head+0x2b>
  }
  brelse(buf);
801025a1:	83 ec 0c             	sub    $0xc,%esp
801025a4:	50                   	push   %eax
801025a5:	e8 2b dc ff ff       	call   801001d5 <brelse>
}
801025aa:	83 c4 10             	add    $0x10,%esp
801025ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025b0:	c9                   	leave  
801025b1:	c3                   	ret    

801025b2 <install_trans>:
{
801025b2:	55                   	push   %ebp
801025b3:	89 e5                	mov    %esp,%ebp
801025b5:	57                   	push   %edi
801025b6:	56                   	push   %esi
801025b7:	53                   	push   %ebx
801025b8:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025bb:	be 00 00 00 00       	mov    $0x0,%esi
801025c0:	eb 66                	jmp    80102628 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025c2:	89 f0                	mov    %esi,%eax
801025c4:	03 05 d4 16 11 80    	add    0x801116d4,%eax
801025ca:	83 c0 01             	add    $0x1,%eax
801025cd:	83 ec 08             	sub    $0x8,%esp
801025d0:	50                   	push   %eax
801025d1:	ff 35 e4 16 11 80    	push   0x801116e4
801025d7:	e8 90 db ff ff       	call   8010016c <bread>
801025dc:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025de:	83 c4 08             	add    $0x8,%esp
801025e1:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
801025e8:	ff 35 e4 16 11 80    	push   0x801116e4
801025ee:	e8 79 db ff ff       	call   8010016c <bread>
801025f3:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025f5:	8d 57 5c             	lea    0x5c(%edi),%edx
801025f8:	8d 40 5c             	lea    0x5c(%eax),%eax
801025fb:	83 c4 0c             	add    $0xc,%esp
801025fe:	68 00 02 00 00       	push   $0x200
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 d1 16 00 00       	call   80103cdb <memmove>
    bwrite(dbuf);  // write dst to disk
8010260a:	89 1c 24             	mov    %ebx,(%esp)
8010260d:	e8 88 db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102612:	89 3c 24             	mov    %edi,(%esp)
80102615:	e8 bb db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010261a:	89 1c 24             	mov    %ebx,(%esp)
8010261d:	e8 b3 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102622:	83 c6 01             	add    $0x1,%esi
80102625:	83 c4 10             	add    $0x10,%esp
80102628:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
8010262e:	7f 92                	jg     801025c2 <install_trans+0x10>
}
80102630:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102633:	5b                   	pop    %ebx
80102634:	5e                   	pop    %esi
80102635:	5f                   	pop    %edi
80102636:	5d                   	pop    %ebp
80102637:	c3                   	ret    

80102638 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102638:	55                   	push   %ebp
80102639:	89 e5                	mov    %esp,%ebp
8010263b:	53                   	push   %ebx
8010263c:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010263f:	ff 35 d4 16 11 80    	push   0x801116d4
80102645:	ff 35 e4 16 11 80    	push   0x801116e4
8010264b:	e8 1c db ff ff       	call   8010016c <bread>
80102650:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102652:	8b 0d e8 16 11 80    	mov    0x801116e8,%ecx
80102658:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010265b:	83 c4 10             	add    $0x10,%esp
8010265e:	b8 00 00 00 00       	mov    $0x0,%eax
80102663:	eb 0e                	jmp    80102673 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102665:	8b 14 85 ec 16 11 80 	mov    -0x7feee914(,%eax,4),%edx
8010266c:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102670:	83 c0 01             	add    $0x1,%eax
80102673:	39 c1                	cmp    %eax,%ecx
80102675:	7f ee                	jg     80102665 <write_head+0x2d>
  }
  bwrite(buf);
80102677:	83 ec 0c             	sub    $0xc,%esp
8010267a:	53                   	push   %ebx
8010267b:	e8 1a db ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102680:	89 1c 24             	mov    %ebx,(%esp)
80102683:	e8 4d db ff ff       	call   801001d5 <brelse>
}
80102688:	83 c4 10             	add    $0x10,%esp
8010268b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010268e:	c9                   	leave  
8010268f:	c3                   	ret    

80102690 <recover_from_log>:

static void
recover_from_log(void)
{
80102690:	55                   	push   %ebp
80102691:	89 e5                	mov    %esp,%ebp
80102693:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102696:	e8 c9 fe ff ff       	call   80102564 <read_head>
  install_trans(); // if committed, copy from log to disk
8010269b:	e8 12 ff ff ff       	call   801025b2 <install_trans>
  log.lh.n = 0;
801026a0:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
801026a7:	00 00 00 
  write_head(); // clear the log
801026aa:	e8 89 ff ff ff       	call   80102638 <write_head>
}
801026af:	c9                   	leave  
801026b0:	c3                   	ret    

801026b1 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026b1:	55                   	push   %ebp
801026b2:	89 e5                	mov    %esp,%ebp
801026b4:	57                   	push   %edi
801026b5:	56                   	push   %esi
801026b6:	53                   	push   %ebx
801026b7:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026ba:	be 00 00 00 00       	mov    $0x0,%esi
801026bf:	eb 66                	jmp    80102727 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026c1:	89 f0                	mov    %esi,%eax
801026c3:	03 05 d4 16 11 80    	add    0x801116d4,%eax
801026c9:	83 c0 01             	add    $0x1,%eax
801026cc:	83 ec 08             	sub    $0x8,%esp
801026cf:	50                   	push   %eax
801026d0:	ff 35 e4 16 11 80    	push   0x801116e4
801026d6:	e8 91 da ff ff       	call   8010016c <bread>
801026db:	89 c3                	mov    %eax,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026dd:	83 c4 08             	add    $0x8,%esp
801026e0:	ff 34 b5 ec 16 11 80 	push   -0x7feee914(,%esi,4)
801026e7:	ff 35 e4 16 11 80    	push   0x801116e4
801026ed:	e8 7a da ff ff       	call   8010016c <bread>
801026f2:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026f4:	8d 50 5c             	lea    0x5c(%eax),%edx
801026f7:	8d 43 5c             	lea    0x5c(%ebx),%eax
801026fa:	83 c4 0c             	add    $0xc,%esp
801026fd:	68 00 02 00 00       	push   $0x200
80102702:	52                   	push   %edx
80102703:	50                   	push   %eax
80102704:	e8 d2 15 00 00       	call   80103cdb <memmove>
    bwrite(to);  // write the log
80102709:	89 1c 24             	mov    %ebx,(%esp)
8010270c:	e8 89 da ff ff       	call   8010019a <bwrite>
    brelse(from);
80102711:	89 3c 24             	mov    %edi,(%esp)
80102714:	e8 bc da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102719:	89 1c 24             	mov    %ebx,(%esp)
8010271c:	e8 b4 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102721:	83 c6 01             	add    $0x1,%esi
80102724:	83 c4 10             	add    $0x10,%esp
80102727:	39 35 e8 16 11 80    	cmp    %esi,0x801116e8
8010272d:	7f 92                	jg     801026c1 <write_log+0x10>
  }
}
8010272f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102732:	5b                   	pop    %ebx
80102733:	5e                   	pop    %esi
80102734:	5f                   	pop    %edi
80102735:	5d                   	pop    %ebp
80102736:	c3                   	ret    

80102737 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102737:	83 3d e8 16 11 80 00 	cmpl   $0x0,0x801116e8
8010273e:	7f 01                	jg     80102741 <commit+0xa>
80102740:	c3                   	ret    
{
80102741:	55                   	push   %ebp
80102742:	89 e5                	mov    %esp,%ebp
80102744:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102747:	e8 65 ff ff ff       	call   801026b1 <write_log>
    write_head();    // Write header to disk -- the real commit
8010274c:	e8 e7 fe ff ff       	call   80102638 <write_head>
    install_trans(); // Now install writes to home locations
80102751:	e8 5c fe ff ff       	call   801025b2 <install_trans>
    log.lh.n = 0;
80102756:	c7 05 e8 16 11 80 00 	movl   $0x0,0x801116e8
8010275d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102760:	e8 d3 fe ff ff       	call   80102638 <write_head>
  }
}
80102765:	c9                   	leave  
80102766:	c3                   	ret    

80102767 <initlog>:
{
80102767:	55                   	push   %ebp
80102768:	89 e5                	mov    %esp,%ebp
8010276a:	53                   	push   %ebx
8010276b:	83 ec 2c             	sub    $0x2c,%esp
8010276e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102771:	68 a0 6c 10 80       	push   $0x80106ca0
80102776:	68 a0 16 11 80       	push   $0x801116a0
8010277b:	e8 fb 12 00 00       	call   80103a7b <initlock>
  readsb(dev, &sb);
80102780:	83 c4 08             	add    $0x8,%esp
80102783:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102786:	50                   	push   %eax
80102787:	53                   	push   %ebx
80102788:	e8 19 eb ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
8010278d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102790:	a3 d4 16 11 80       	mov    %eax,0x801116d4
  log.size = sb.nlog;
80102795:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102798:	a3 d8 16 11 80       	mov    %eax,0x801116d8
  log.dev = dev;
8010279d:	89 1d e4 16 11 80    	mov    %ebx,0x801116e4
  recover_from_log();
801027a3:	e8 e8 fe ff ff       	call   80102690 <recover_from_log>
}
801027a8:	83 c4 10             	add    $0x10,%esp
801027ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ae:	c9                   	leave  
801027af:	c3                   	ret    

801027b0 <begin_op>:
{
801027b0:	55                   	push   %ebp
801027b1:	89 e5                	mov    %esp,%ebp
801027b3:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027b6:	68 a0 16 11 80       	push   $0x801116a0
801027bb:	e8 f7 13 00 00       	call   80103bb7 <acquire>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 15                	jmp    801027da <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 a0 16 11 80       	push   $0x801116a0
801027cd:	68 a0 16 11 80       	push   $0x801116a0
801027d2:	e8 e5 0e 00 00       	call   801036bc <sleep>
801027d7:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027da:	83 3d e0 16 11 80 00 	cmpl   $0x0,0x801116e0
801027e1:	75 e2                	jne    801027c5 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027e3:	a1 dc 16 11 80       	mov    0x801116dc,%eax
801027e8:	83 c0 01             	add    $0x1,%eax
801027eb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ee:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027f1:	03 15 e8 16 11 80    	add    0x801116e8,%edx
801027f7:	83 fa 1e             	cmp    $0x1e,%edx
801027fa:	7e 17                	jle    80102813 <begin_op+0x63>
      sleep(&log, &log.lock);
801027fc:	83 ec 08             	sub    $0x8,%esp
801027ff:	68 a0 16 11 80       	push   $0x801116a0
80102804:	68 a0 16 11 80       	push   $0x801116a0
80102809:	e8 ae 0e 00 00       	call   801036bc <sleep>
8010280e:	83 c4 10             	add    $0x10,%esp
80102811:	eb c7                	jmp    801027da <begin_op+0x2a>
      log.outstanding += 1;
80102813:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 a0 16 11 80       	push   $0x801116a0
80102820:	e8 f7 13 00 00       	call   80103c1c <release>
}
80102825:	83 c4 10             	add    $0x10,%esp
80102828:	c9                   	leave  
80102829:	c3                   	ret    

8010282a <end_op>:
{
8010282a:	55                   	push   %ebp
8010282b:	89 e5                	mov    %esp,%ebp
8010282d:	53                   	push   %ebx
8010282e:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102831:	68 a0 16 11 80       	push   $0x801116a0
80102836:	e8 7c 13 00 00       	call   80103bb7 <acquire>
  log.outstanding -= 1;
8010283b:	a1 dc 16 11 80       	mov    0x801116dc,%eax
80102840:	83 e8 01             	sub    $0x1,%eax
80102843:	a3 dc 16 11 80       	mov    %eax,0x801116dc
  if(log.committing)
80102848:	8b 1d e0 16 11 80    	mov    0x801116e0,%ebx
8010284e:	83 c4 10             	add    $0x10,%esp
80102851:	85 db                	test   %ebx,%ebx
80102853:	75 2c                	jne    80102881 <end_op+0x57>
  if(log.outstanding == 0){
80102855:	85 c0                	test   %eax,%eax
80102857:	75 35                	jne    8010288e <end_op+0x64>
    log.committing = 1;
80102859:	c7 05 e0 16 11 80 01 	movl   $0x1,0x801116e0
80102860:	00 00 00 
    do_commit = 1;
80102863:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102868:	83 ec 0c             	sub    $0xc,%esp
8010286b:	68 a0 16 11 80       	push   $0x801116a0
80102870:	e8 a7 13 00 00       	call   80103c1c <release>
  if(do_commit){
80102875:	83 c4 10             	add    $0x10,%esp
80102878:	85 db                	test   %ebx,%ebx
8010287a:	75 24                	jne    801028a0 <end_op+0x76>
}
8010287c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010287f:	c9                   	leave  
80102880:	c3                   	ret    
    panic("log.committing");
80102881:	83 ec 0c             	sub    $0xc,%esp
80102884:	68 a4 6c 10 80       	push   $0x80106ca4
80102889:	e8 ba da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 a0 16 11 80       	push   $0x801116a0
80102896:	e8 86 0f 00 00       	call   80103821 <wakeup>
8010289b:	83 c4 10             	add    $0x10,%esp
8010289e:	eb c8                	jmp    80102868 <end_op+0x3e>
    commit();
801028a0:	e8 92 fe ff ff       	call   80102737 <commit>
    acquire(&log.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 a0 16 11 80       	push   $0x801116a0
801028ad:	e8 05 13 00 00       	call   80103bb7 <acquire>
    log.committing = 0;
801028b2:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801028b9:	00 00 00 
    wakeup(&log);
801028bc:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028c3:	e8 59 0f 00 00       	call   80103821 <wakeup>
    release(&log.lock);
801028c8:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028cf:	e8 48 13 00 00       	call   80103c1c <release>
801028d4:	83 c4 10             	add    $0x10,%esp
}
801028d7:	eb a3                	jmp    8010287c <end_op+0x52>

801028d9 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028d9:	55                   	push   %ebp
801028da:	89 e5                	mov    %esp,%ebp
801028dc:	53                   	push   %ebx
801028dd:	83 ec 04             	sub    $0x4,%esp
801028e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028e3:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
801028e9:	83 fa 1d             	cmp    $0x1d,%edx
801028ec:	7f 2c                	jg     8010291a <log_write+0x41>
801028ee:	a1 d8 16 11 80       	mov    0x801116d8,%eax
801028f3:	83 e8 01             	sub    $0x1,%eax
801028f6:	39 c2                	cmp    %eax,%edx
801028f8:	7d 20                	jge    8010291a <log_write+0x41>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028fa:	83 3d dc 16 11 80 00 	cmpl   $0x0,0x801116dc
80102901:	7e 24                	jle    80102927 <log_write+0x4e>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102903:	83 ec 0c             	sub    $0xc,%esp
80102906:	68 a0 16 11 80       	push   $0x801116a0
8010290b:	e8 a7 12 00 00       	call   80103bb7 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102910:	83 c4 10             	add    $0x10,%esp
80102913:	b8 00 00 00 00       	mov    $0x0,%eax
80102918:	eb 1d                	jmp    80102937 <log_write+0x5e>
    panic("too big a transaction");
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 b3 6c 10 80       	push   $0x80106cb3
80102922:	e8 21 da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 c9 6c 10 80       	push   $0x80106cc9
8010292f:	e8 14 da ff ff       	call   80100348 <panic>
  for (i = 0; i < log.lh.n; i++) {
80102934:	83 c0 01             	add    $0x1,%eax
80102937:	8b 15 e8 16 11 80    	mov    0x801116e8,%edx
8010293d:	39 c2                	cmp    %eax,%edx
8010293f:	7e 0c                	jle    8010294d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102941:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102944:	39 0c 85 ec 16 11 80 	cmp    %ecx,-0x7feee914(,%eax,4)
8010294b:	75 e7                	jne    80102934 <log_write+0x5b>
      break;
  }
  log.lh.block[i] = b->blockno;
8010294d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102950:	89 0c 85 ec 16 11 80 	mov    %ecx,-0x7feee914(,%eax,4)
  if (i == log.lh.n)
80102957:	39 c2                	cmp    %eax,%edx
80102959:	74 18                	je     80102973 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010295b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010295e:	83 ec 0c             	sub    $0xc,%esp
80102961:	68 a0 16 11 80       	push   $0x801116a0
80102966:	e8 b1 12 00 00       	call   80103c1c <release>
}
8010296b:	83 c4 10             	add    $0x10,%esp
8010296e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102971:	c9                   	leave  
80102972:	c3                   	ret    
    log.lh.n++;
80102973:	83 c2 01             	add    $0x1,%edx
80102976:	89 15 e8 16 11 80    	mov    %edx,0x801116e8
8010297c:	eb dd                	jmp    8010295b <log_write+0x82>

8010297e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010297e:	55                   	push   %ebp
8010297f:	89 e5                	mov    %esp,%ebp
80102981:	53                   	push   %ebx
80102982:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102985:	68 8a 00 00 00       	push   $0x8a
8010298a:	68 8c a4 10 80       	push   $0x8010a48c
8010298f:	68 00 70 00 80       	push   $0x80007000
80102994:	e8 42 13 00 00       	call   80103cdb <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801029a1:	eb 13                	jmp    801029b6 <startothers+0x38>
801029a3:	83 ec 0c             	sub    $0xc,%esp
801029a6:	68 c8 69 10 80       	push   $0x801069c8
801029ab:	e8 98 d9 ff ff       	call   80100348 <panic>
801029b0:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029b6:	69 05 84 17 11 80 b0 	imul   $0xb0,0x80111784,%eax
801029bd:	00 00 00 
801029c0:	05 a0 17 11 80       	add    $0x801117a0,%eax
801029c5:	39 d8                	cmp    %ebx,%eax
801029c7:	76 58                	jbe    80102a21 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
801029c9:	e8 d5 07 00 00       	call   801031a3 <mycpu>
801029ce:	39 c3                	cmp    %eax,%ebx
801029d0:	74 de                	je     801029b0 <startothers+0x32>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029d2:	e8 f2 f6 ff ff       	call   801020c9 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029d7:	05 00 10 00 00       	add    $0x1000,%eax
801029dc:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029e1:	c7 05 f8 6f 00 80 65 	movl   $0x80102a65,0x80006ff8
801029e8:	2a 10 80 
    if (a < (void*) KERNBASE)
801029eb:	b8 00 90 10 80       	mov    $0x80109000,%eax
801029f0:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801029f5:	76 ac                	jbe    801029a3 <startothers+0x25>
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029f7:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
801029fe:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a01:	83 ec 08             	sub    $0x8,%esp
80102a04:	68 00 70 00 00       	push   $0x7000
80102a09:	0f b6 03             	movzbl (%ebx),%eax
80102a0c:	50                   	push   %eax
80102a0d:	e8 b8 f9 ff ff       	call   801023ca <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a12:	83 c4 10             	add    $0x10,%esp
80102a15:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a1b:	85 c0                	test   %eax,%eax
80102a1d:	74 f6                	je     80102a15 <startothers+0x97>
80102a1f:	eb 8f                	jmp    801029b0 <startothers+0x32>
      ;
  }
}
80102a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a24:	c9                   	leave  
80102a25:	c3                   	ret    

80102a26 <mpmain>:
{
80102a26:	55                   	push   %ebp
80102a27:	89 e5                	mov    %esp,%ebp
80102a29:	53                   	push   %ebx
80102a2a:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a2d:	e8 cd 07 00 00       	call   801031ff <cpuid>
80102a32:	89 c3                	mov    %eax,%ebx
80102a34:	e8 c6 07 00 00       	call   801031ff <cpuid>
80102a39:	83 ec 04             	sub    $0x4,%esp
80102a3c:	53                   	push   %ebx
80102a3d:	50                   	push   %eax
80102a3e:	68 e4 6c 10 80       	push   $0x80106ce4
80102a43:	e8 bf db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102a48:	e8 1c 24 00 00       	call   80104e69 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a4d:	e8 51 07 00 00       	call   801031a3 <mycpu>
80102a52:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a54:	b8 01 00 00 00       	mov    $0x1,%eax
80102a59:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a60:	e8 32 0a 00 00       	call   80103497 <scheduler>

80102a65 <mpenter>:
{
80102a65:	55                   	push   %ebp
80102a66:	89 e5                	mov    %esp,%ebp
80102a68:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a6b:	e8 4f 35 00 00       	call   80105fbf <switchkvm>
  seginit();
80102a70:	e8 d5 32 00 00       	call   80105d4a <seginit>
  lapicinit();
80102a75:	e8 0c f8 ff ff       	call   80102286 <lapicinit>
  mpmain();
80102a7a:	e8 a7 ff ff ff       	call   80102a26 <mpmain>

80102a7f <main>:
{
80102a7f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a83:	83 e4 f0             	and    $0xfffffff0,%esp
80102a86:	ff 71 fc             	push   -0x4(%ecx)
80102a89:	55                   	push   %ebp
80102a8a:	89 e5                	mov    %esp,%ebp
80102a8c:	51                   	push   %ecx
80102a8d:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a90:	68 00 00 40 80       	push   $0x80400000
80102a95:	68 d0 54 11 80       	push   $0x801154d0
80102a9a:	e8 d8 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102a9f:	e8 7c 3a 00 00       	call   80106520 <kvmalloc>
  mpinit();        // detect other processors
80102aa4:	e8 db 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102aa9:	e8 d8 f7 ff ff       	call   80102286 <lapicinit>
  seginit();       // segment descriptors
80102aae:	e8 97 32 00 00       	call   80105d4a <seginit>
  picinit();       // disable pic
80102ab3:	e8 a2 02 00 00       	call   80102d5a <picinit>
  ioapicinit();    // another interrupt controller
80102ab8:	e8 20 f4 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102abd:	e8 c8 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102ac2:	e8 49 26 00 00       	call   80105110 <uartinit>
  pinit();         // process table
80102ac7:	e8 bd 06 00 00       	call   80103189 <pinit>
  tvinit();        // trap vectors
80102acc:	e8 93 22 00 00       	call   80104d64 <tvinit>
  binit();         // buffer cache
80102ad1:	e8 1e d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102ad6:	e8 28 e1 ff ff       	call   80100c03 <fileinit>
  ideinit();       // disk 
80102adb:	e8 09 f2 ff ff       	call   80101ce9 <ideinit>
  startothers();   // start other processors
80102ae0:	e8 99 fe ff ff       	call   8010297e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102ae5:	83 c4 08             	add    $0x8,%esp
80102ae8:	68 00 00 00 8e       	push   $0x8e000000
80102aed:	68 00 00 40 80       	push   $0x80400000
80102af2:	e8 b2 f5 ff ff       	call   801020a9 <kinit2>
  userinit();      // first user process
80102af7:	e8 41 07 00 00       	call   8010323d <userinit>
  mpmain();        // finish this processor's setup
80102afc:	e8 25 ff ff ff       	call   80102a26 <mpmain>

80102b01 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b01:	55                   	push   %ebp
80102b02:	89 e5                	mov    %esp,%ebp
80102b04:	56                   	push   %esi
80102b05:	53                   	push   %ebx
80102b06:	89 c6                	mov    %eax,%esi
  int i, sum;

  sum = 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
  for(i=0; i<len; i++)
80102b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b12:	eb 09                	jmp    80102b1d <sum+0x1c>
    sum += addr[i];
80102b14:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
80102b18:	01 d8                	add    %ebx,%eax
  for(i=0; i<len; i++)
80102b1a:	83 c1 01             	add    $0x1,%ecx
80102b1d:	39 d1                	cmp    %edx,%ecx
80102b1f:	7c f3                	jl     80102b14 <sum+0x13>
  return sum;
}
80102b21:	5b                   	pop    %ebx
80102b22:	5e                   	pop    %esi
80102b23:	5d                   	pop    %ebp
80102b24:	c3                   	ret    

80102b25 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b25:	55                   	push   %ebp
80102b26:	89 e5                	mov    %esp,%ebp
80102b28:	56                   	push   %esi
80102b29:	53                   	push   %ebx
}

// Convert physical address to kernel virtual address
static inline void *P2V(uint a) {
    extern void panic(char*) __attribute__((noreturn));
    if (a > KERNBASE)
80102b2a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80102b2f:	77 0b                	ja     80102b3c <mpsearch1+0x17>
        panic("P2V on address > KERNBASE");
    return (char*)a + KERNBASE;
80102b31:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
80102b37:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b3a:	eb 10                	jmp    80102b4c <mpsearch1+0x27>
        panic("P2V on address > KERNBASE");
80102b3c:	83 ec 0c             	sub    $0xc,%esp
80102b3f:	68 f8 6c 10 80       	push   $0x80106cf8
80102b44:	e8 ff d7 ff ff       	call   80100348 <panic>
80102b49:	83 c3 10             	add    $0x10,%ebx
80102b4c:	39 f3                	cmp    %esi,%ebx
80102b4e:	73 29                	jae    80102b79 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	6a 04                	push   $0x4
80102b55:	68 12 6d 10 80       	push   $0x80106d12
80102b5a:	53                   	push   %ebx
80102b5b:	e8 46 11 00 00       	call   80103ca6 <memcmp>
80102b60:	83 c4 10             	add    $0x10,%esp
80102b63:	85 c0                	test   %eax,%eax
80102b65:	75 e2                	jne    80102b49 <mpsearch1+0x24>
80102b67:	ba 10 00 00 00       	mov    $0x10,%edx
80102b6c:	89 d8                	mov    %ebx,%eax
80102b6e:	e8 8e ff ff ff       	call   80102b01 <sum>
80102b73:	84 c0                	test   %al,%al
80102b75:	75 d2                	jne    80102b49 <mpsearch1+0x24>
80102b77:	eb 05                	jmp    80102b7e <mpsearch1+0x59>
      return (struct mp*)p;
  return 0;
80102b79:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b7e:	89 d8                	mov    %ebx,%eax
80102b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b83:	5b                   	pop    %ebx
80102b84:	5e                   	pop    %esi
80102b85:	5d                   	pop    %ebp
80102b86:	c3                   	ret    

80102b87 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b87:	55                   	push   %ebp
80102b88:	89 e5                	mov    %esp,%ebp
80102b8a:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b8d:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b94:	c1 e0 08             	shl    $0x8,%eax
80102b97:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b9e:	09 d0                	or     %edx,%eax
80102ba0:	c1 e0 04             	shl    $0x4,%eax
80102ba3:	74 1f                	je     80102bc4 <mpsearch+0x3d>
    if((mp = mpsearch1(p, 1024)))
80102ba5:	ba 00 04 00 00       	mov    $0x400,%edx
80102baa:	e8 76 ff ff ff       	call   80102b25 <mpsearch1>
80102baf:	85 c0                	test   %eax,%eax
80102bb1:	75 0f                	jne    80102bc2 <mpsearch+0x3b>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102bb3:	ba 00 00 01 00       	mov    $0x10000,%edx
80102bb8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102bbd:	e8 63 ff ff ff       	call   80102b25 <mpsearch1>
}
80102bc2:	c9                   	leave  
80102bc3:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102bc4:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102bcb:	c1 e0 08             	shl    $0x8,%eax
80102bce:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102bd5:	09 d0                	or     %edx,%eax
80102bd7:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bda:	2d 00 04 00 00       	sub    $0x400,%eax
80102bdf:	ba 00 04 00 00       	mov    $0x400,%edx
80102be4:	e8 3c ff ff ff       	call   80102b25 <mpsearch1>
80102be9:	85 c0                	test   %eax,%eax
80102beb:	75 d5                	jne    80102bc2 <mpsearch+0x3b>
80102bed:	eb c4                	jmp    80102bb3 <mpsearch+0x2c>

80102bef <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bef:	55                   	push   %ebp
80102bf0:	89 e5                	mov    %esp,%ebp
80102bf2:	57                   	push   %edi
80102bf3:	56                   	push   %esi
80102bf4:	53                   	push   %ebx
80102bf5:	83 ec 0c             	sub    $0xc,%esp
80102bf8:	89 c7                	mov    %eax,%edi
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102bfa:	e8 88 ff ff ff       	call   80102b87 <mpsearch>
80102bff:	89 c6                	mov    %eax,%esi
80102c01:	85 c0                	test   %eax,%eax
80102c03:	74 66                	je     80102c6b <mpconfig+0x7c>
80102c05:	8b 58 04             	mov    0x4(%eax),%ebx
80102c08:	85 db                	test   %ebx,%ebx
80102c0a:	74 48                	je     80102c54 <mpconfig+0x65>
    if (a > KERNBASE)
80102c0c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80102c12:	77 4a                	ja     80102c5e <mpconfig+0x6f>
    return (char*)a + KERNBASE;
80102c14:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
80102c1a:	83 ec 04             	sub    $0x4,%esp
80102c1d:	6a 04                	push   $0x4
80102c1f:	68 17 6d 10 80       	push   $0x80106d17
80102c24:	53                   	push   %ebx
80102c25:	e8 7c 10 00 00       	call   80103ca6 <memcmp>
80102c2a:	83 c4 10             	add    $0x10,%esp
80102c2d:	85 c0                	test   %eax,%eax
80102c2f:	75 3e                	jne    80102c6f <mpconfig+0x80>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c31:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
80102c35:	3c 01                	cmp    $0x1,%al
80102c37:	0f 95 c2             	setne  %dl
80102c3a:	3c 04                	cmp    $0x4,%al
80102c3c:	0f 95 c0             	setne  %al
80102c3f:	84 c2                	test   %al,%dl
80102c41:	75 33                	jne    80102c76 <mpconfig+0x87>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c43:	0f b7 53 04          	movzwl 0x4(%ebx),%edx
80102c47:	89 d8                	mov    %ebx,%eax
80102c49:	e8 b3 fe ff ff       	call   80102b01 <sum>
80102c4e:	84 c0                	test   %al,%al
80102c50:	75 2b                	jne    80102c7d <mpconfig+0x8e>
    return 0;
  *pmp = mp;
80102c52:	89 37                	mov    %esi,(%edi)
  return conf;
}
80102c54:	89 d8                	mov    %ebx,%eax
80102c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c59:	5b                   	pop    %ebx
80102c5a:	5e                   	pop    %esi
80102c5b:	5f                   	pop    %edi
80102c5c:	5d                   	pop    %ebp
80102c5d:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80102c5e:	83 ec 0c             	sub    $0xc,%esp
80102c61:	68 f8 6c 10 80       	push   $0x80106cf8
80102c66:	e8 dd d6 ff ff       	call   80100348 <panic>
    return 0;
80102c6b:	89 c3                	mov    %eax,%ebx
80102c6d:	eb e5                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c74:	eb de                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c76:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c7b:	eb d7                	jmp    80102c54 <mpconfig+0x65>
    return 0;
80102c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102c82:	eb d0                	jmp    80102c54 <mpconfig+0x65>

80102c84 <mpinit>:

void
mpinit(void)
{
80102c84:	55                   	push   %ebp
80102c85:	89 e5                	mov    %esp,%ebp
80102c87:	57                   	push   %edi
80102c88:	56                   	push   %esi
80102c89:	53                   	push   %ebx
80102c8a:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c90:	e8 5a ff ff ff       	call   80102bef <mpconfig>
80102c95:	85 c0                	test   %eax,%eax
80102c97:	74 19                	je     80102cb2 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c99:	8b 50 24             	mov    0x24(%eax),%edx
80102c9c:	89 15 80 16 11 80    	mov    %edx,0x80111680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ca2:	8d 50 2c             	lea    0x2c(%eax),%edx
80102ca5:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102ca9:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102cab:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb0:	eb 20                	jmp    80102cd2 <mpinit+0x4e>
    panic("Expect to run on an SMP");
80102cb2:	83 ec 0c             	sub    $0xc,%esp
80102cb5:	68 1c 6d 10 80       	push   $0x80106d1c
80102cba:	e8 89 d6 ff ff       	call   80100348 <panic>
    switch(*p){
80102cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
80102cc4:	eb 0c                	jmp    80102cd2 <mpinit+0x4e>
80102cc6:	83 e8 03             	sub    $0x3,%eax
80102cc9:	3c 01                	cmp    $0x1,%al
80102ccb:	76 1a                	jbe    80102ce7 <mpinit+0x63>
80102ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cd2:	39 ca                	cmp    %ecx,%edx
80102cd4:	73 4d                	jae    80102d23 <mpinit+0x9f>
    switch(*p){
80102cd6:	0f b6 02             	movzbl (%edx),%eax
80102cd9:	3c 02                	cmp    $0x2,%al
80102cdb:	74 38                	je     80102d15 <mpinit+0x91>
80102cdd:	77 e7                	ja     80102cc6 <mpinit+0x42>
80102cdf:	84 c0                	test   %al,%al
80102ce1:	74 09                	je     80102cec <mpinit+0x68>
80102ce3:	3c 01                	cmp    $0x1,%al
80102ce5:	75 d8                	jne    80102cbf <mpinit+0x3b>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102ce7:	83 c2 08             	add    $0x8,%edx
      continue;
80102cea:	eb e6                	jmp    80102cd2 <mpinit+0x4e>
      if(ncpu < NCPU) {
80102cec:	8b 35 84 17 11 80    	mov    0x80111784,%esi
80102cf2:	83 fe 07             	cmp    $0x7,%esi
80102cf5:	7f 19                	jg     80102d10 <mpinit+0x8c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cf7:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cfb:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102d01:	88 87 a0 17 11 80    	mov    %al,-0x7feee860(%edi)
        ncpu++;
80102d07:	83 c6 01             	add    $0x1,%esi
80102d0a:	89 35 84 17 11 80    	mov    %esi,0x80111784
      p += sizeof(struct mpproc);
80102d10:	83 c2 14             	add    $0x14,%edx
      continue;
80102d13:	eb bd                	jmp    80102cd2 <mpinit+0x4e>
      ioapicid = ioapic->apicno;
80102d15:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d19:	a2 80 17 11 80       	mov    %al,0x80111780
      p += sizeof(struct mpioapic);
80102d1e:	83 c2 08             	add    $0x8,%edx
      continue;
80102d21:	eb af                	jmp    80102cd2 <mpinit+0x4e>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102d23:	85 db                	test   %ebx,%ebx
80102d25:	74 26                	je     80102d4d <mpinit+0xc9>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d2a:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d2e:	74 15                	je     80102d45 <mpinit+0xc1>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d30:	b8 70 00 00 00       	mov    $0x70,%eax
80102d35:	ba 22 00 00 00       	mov    $0x22,%edx
80102d3a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3b:	ba 23 00 00 00       	mov    $0x23,%edx
80102d40:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d41:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d44:	ee                   	out    %al,(%dx)
  }
}
80102d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d48:	5b                   	pop    %ebx
80102d49:	5e                   	pop    %esi
80102d4a:	5f                   	pop    %edi
80102d4b:	5d                   	pop    %ebp
80102d4c:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d4d:	83 ec 0c             	sub    $0xc,%esp
80102d50:	68 34 6d 10 80       	push   $0x80106d34
80102d55:	e8 ee d5 ff ff       	call   80100348 <panic>

80102d5a <picinit>:
80102d5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d5f:	ba 21 00 00 00       	mov    $0x21,%edx
80102d64:	ee                   	out    %al,(%dx)
80102d65:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d6a:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d6b:	c3                   	ret    

80102d6c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d6c:	55                   	push   %ebp
80102d6d:	89 e5                	mov    %esp,%ebp
80102d6f:	57                   	push   %edi
80102d70:	56                   	push   %esi
80102d71:	53                   	push   %ebx
80102d72:	83 ec 0c             	sub    $0xc,%esp
80102d75:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d87:	e8 91 de ff ff       	call   80100c1d <filealloc>
80102d8c:	89 03                	mov    %eax,(%ebx)
80102d8e:	85 c0                	test   %eax,%eax
80102d90:	0f 84 88 00 00 00    	je     80102e1e <pipealloc+0xb2>
80102d96:	e8 82 de ff ff       	call   80100c1d <filealloc>
80102d9b:	89 06                	mov    %eax,(%esi)
80102d9d:	85 c0                	test   %eax,%eax
80102d9f:	74 7d                	je     80102e1e <pipealloc+0xb2>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102da1:	e8 23 f3 ff ff       	call   801020c9 <kalloc>
80102da6:	89 c7                	mov    %eax,%edi
80102da8:	85 c0                	test   %eax,%eax
80102daa:	74 72                	je     80102e1e <pipealloc+0xb2>
    goto bad;
  p->readopen = 1;
80102dac:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102db3:	00 00 00 
  p->writeopen = 1;
80102db6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102dbd:	00 00 00 
  p->nwrite = 0;
80102dc0:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102dc7:	00 00 00 
  p->nread = 0;
80102dca:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102dd1:	00 00 00 
  initlock(&p->lock, "pipe");
80102dd4:	83 ec 08             	sub    $0x8,%esp
80102dd7:	68 53 6d 10 80       	push   $0x80106d53
80102ddc:	50                   	push   %eax
80102ddd:	e8 99 0c 00 00       	call   80103a7b <initlock>
  (*f0)->type = FD_PIPE;
80102de2:	8b 03                	mov    (%ebx),%eax
80102de4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102dea:	8b 03                	mov    (%ebx),%eax
80102dec:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102df0:	8b 03                	mov    (%ebx),%eax
80102df2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102df6:	8b 03                	mov    (%ebx),%eax
80102df8:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102dfb:	8b 06                	mov    (%esi),%eax
80102dfd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e03:	8b 06                	mov    (%esi),%eax
80102e05:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e09:	8b 06                	mov    (%esi),%eax
80102e0b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e0f:	8b 06                	mov    (%esi),%eax
80102e11:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e14:	83 c4 10             	add    $0x10,%esp
80102e17:	b8 00 00 00 00       	mov    $0x0,%eax
80102e1c:	eb 29                	jmp    80102e47 <pipealloc+0xdb>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e1e:	8b 03                	mov    (%ebx),%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	74 0c                	je     80102e30 <pipealloc+0xc4>
    fileclose(*f0);
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	50                   	push   %eax
80102e28:	e8 96 de ff ff       	call   80100cc3 <fileclose>
80102e2d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102e30:	8b 06                	mov    (%esi),%eax
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 19                	je     80102e4f <pipealloc+0xe3>
    fileclose(*f1);
80102e36:	83 ec 0c             	sub    $0xc,%esp
80102e39:	50                   	push   %eax
80102e3a:	e8 84 de ff ff       	call   80100cc3 <fileclose>
80102e3f:	83 c4 10             	add    $0x10,%esp
  return -1;
80102e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e4a:	5b                   	pop    %ebx
80102e4b:	5e                   	pop    %esi
80102e4c:	5f                   	pop    %edi
80102e4d:	5d                   	pop    %ebp
80102e4e:	c3                   	ret    
  return -1;
80102e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e54:	eb f1                	jmp    80102e47 <pipealloc+0xdb>

80102e56 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e56:	55                   	push   %ebp
80102e57:	89 e5                	mov    %esp,%ebp
80102e59:	53                   	push   %ebx
80102e5a:	83 ec 10             	sub    $0x10,%esp
80102e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e60:	53                   	push   %ebx
80102e61:	e8 51 0d 00 00       	call   80103bb7 <acquire>
  if(writable){
80102e66:	83 c4 10             	add    $0x10,%esp
80102e69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e6d:	74 3f                	je     80102eae <pipeclose+0x58>
    p->writeopen = 0;
80102e6f:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e76:	00 00 00 
    wakeup(&p->nread);
80102e79:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e7f:	83 ec 0c             	sub    $0xc,%esp
80102e82:	50                   	push   %eax
80102e83:	e8 99 09 00 00       	call   80103821 <wakeup>
80102e88:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e8b:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e92:	75 09                	jne    80102e9d <pipeclose+0x47>
80102e94:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e9b:	74 2f                	je     80102ecc <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e9d:	83 ec 0c             	sub    $0xc,%esp
80102ea0:	53                   	push   %ebx
80102ea1:	e8 76 0d 00 00       	call   80103c1c <release>
80102ea6:	83 c4 10             	add    $0x10,%esp
}
80102ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102eac:	c9                   	leave  
80102ead:	c3                   	ret    
    p->readopen = 0;
80102eae:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102eb5:	00 00 00 
    wakeup(&p->nwrite);
80102eb8:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ebe:	83 ec 0c             	sub    $0xc,%esp
80102ec1:	50                   	push   %eax
80102ec2:	e8 5a 09 00 00       	call   80103821 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 47 0d 00 00       	call   80103c1c <release>
    kfree((char*)p);
80102ed5:	89 1c 24             	mov    %ebx,(%esp)
80102ed8:	e8 af f0 ff ff       	call   80101f8c <kfree>
80102edd:	83 c4 10             	add    $0x10,%esp
80102ee0:	eb c7                	jmp    80102ea9 <pipeclose+0x53>

80102ee2 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ee2:	55                   	push   %ebp
80102ee3:	89 e5                	mov    %esp,%ebp
80102ee5:	57                   	push   %edi
80102ee6:	56                   	push   %esi
80102ee7:	53                   	push   %ebx
80102ee8:	83 ec 18             	sub    $0x18,%esp
80102eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102eee:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  acquire(&p->lock);
80102ef1:	53                   	push   %ebx
80102ef2:	e8 c0 0c 00 00       	call   80103bb7 <acquire>
  for(i = 0; i < n; i++){
80102ef7:	83 c4 10             	add    $0x10,%esp
80102efa:	bf 00 00 00 00       	mov    $0x0,%edi
80102eff:	39 f7                	cmp    %esi,%edi
80102f01:	7c 40                	jl     80102f43 <pipewrite+0x61>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f03:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f09:	83 ec 0c             	sub    $0xc,%esp
80102f0c:	50                   	push   %eax
80102f0d:	e8 0f 09 00 00       	call   80103821 <wakeup>
  release(&p->lock);
80102f12:	89 1c 24             	mov    %ebx,(%esp)
80102f15:	e8 02 0d 00 00       	call   80103c1c <release>
  return n;
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	89 f0                	mov    %esi,%eax
80102f1f:	eb 5c                	jmp    80102f7d <pipewrite+0x9b>
      wakeup(&p->nread);
80102f21:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 f1 08 00 00       	call   80103821 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f30:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f36:	83 c4 08             	add    $0x8,%esp
80102f39:	53                   	push   %ebx
80102f3a:	50                   	push   %eax
80102f3b:	e8 7c 07 00 00       	call   801036bc <sleep>
80102f40:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f43:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f49:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f4f:	05 00 02 00 00       	add    $0x200,%eax
80102f54:	39 c2                	cmp    %eax,%edx
80102f56:	75 2d                	jne    80102f85 <pipewrite+0xa3>
      if(p->readopen == 0 || myproc()->killed){
80102f58:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f5f:	74 0b                	je     80102f6c <pipewrite+0x8a>
80102f61:	e8 b4 02 00 00       	call   8010321a <myproc>
80102f66:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f6a:	74 b5                	je     80102f21 <pipewrite+0x3f>
        release(&p->lock);
80102f6c:	83 ec 0c             	sub    $0xc,%esp
80102f6f:	53                   	push   %ebx
80102f70:	e8 a7 0c 00 00       	call   80103c1c <release>
        return -1;
80102f75:	83 c4 10             	add    $0x10,%esp
80102f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f80:	5b                   	pop    %ebx
80102f81:	5e                   	pop    %esi
80102f82:	5f                   	pop    %edi
80102f83:	5d                   	pop    %ebp
80102f84:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f85:	8d 42 01             	lea    0x1(%edx),%eax
80102f88:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f8e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f97:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f9b:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f9f:	83 c7 01             	add    $0x1,%edi
80102fa2:	e9 58 ff ff ff       	jmp    80102eff <pipewrite+0x1d>

80102fa7 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102fa7:	55                   	push   %ebp
80102fa8:	89 e5                	mov    %esp,%ebp
80102faa:	57                   	push   %edi
80102fab:	56                   	push   %esi
80102fac:	53                   	push   %ebx
80102fad:	83 ec 18             	sub    $0x18,%esp
80102fb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102fb3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80102fb6:	53                   	push   %ebx
80102fb7:	e8 fb 0b 00 00       	call   80103bb7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fbc:	83 c4 10             	add    $0x10,%esp
80102fbf:	eb 13                	jmp    80102fd4 <piperead+0x2d>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fc1:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fc7:	83 ec 08             	sub    $0x8,%esp
80102fca:	53                   	push   %ebx
80102fcb:	50                   	push   %eax
80102fcc:	e8 eb 06 00 00       	call   801036bc <sleep>
80102fd1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fd4:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fda:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fe0:	75 78                	jne    8010305a <piperead+0xb3>
80102fe2:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fe8:	85 f6                	test   %esi,%esi
80102fea:	74 37                	je     80103023 <piperead+0x7c>
    if(myproc()->killed){
80102fec:	e8 29 02 00 00       	call   8010321a <myproc>
80102ff1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102ff5:	74 ca                	je     80102fc1 <piperead+0x1a>
      release(&p->lock);
80102ff7:	83 ec 0c             	sub    $0xc,%esp
80102ffa:	53                   	push   %ebx
80102ffb:	e8 1c 0c 00 00       	call   80103c1c <release>
      return -1;
80103000:	83 c4 10             	add    $0x10,%esp
80103003:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103008:	eb 46                	jmp    80103050 <piperead+0xa9>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010300a:	8d 50 01             	lea    0x1(%eax),%edx
8010300d:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103013:	25 ff 01 00 00       	and    $0x1ff,%eax
80103018:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010301d:	88 04 37             	mov    %al,(%edi,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103020:	83 c6 01             	add    $0x1,%esi
80103023:	3b 75 10             	cmp    0x10(%ebp),%esi
80103026:	7d 0e                	jge    80103036 <piperead+0x8f>
    if(p->nread == p->nwrite)
80103028:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010302e:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103034:	75 d4                	jne    8010300a <piperead+0x63>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103036:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010303c:	83 ec 0c             	sub    $0xc,%esp
8010303f:	50                   	push   %eax
80103040:	e8 dc 07 00 00       	call   80103821 <wakeup>
  release(&p->lock);
80103045:	89 1c 24             	mov    %ebx,(%esp)
80103048:	e8 cf 0b 00 00       	call   80103c1c <release>
  return i;
8010304d:	83 c4 10             	add    $0x10,%esp
}
80103050:	89 f0                	mov    %esi,%eax
80103052:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103055:	5b                   	pop    %ebx
80103056:	5e                   	pop    %esi
80103057:	5f                   	pop    %edi
80103058:	5d                   	pop    %ebp
80103059:	c3                   	ret    
8010305a:	be 00 00 00 00       	mov    $0x0,%esi
8010305f:	eb c2                	jmp    80103023 <piperead+0x7c>

80103061 <wakeup1>:
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103061:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
80103066:	eb 03                	jmp    8010306b <wakeup1+0xa>
80103068:	83 c2 7c             	add    $0x7c,%edx
8010306b:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
80103071:	73 14                	jae    80103087 <wakeup1+0x26>
    if(p->state == SLEEPING && p->chan == chan)
80103073:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103077:	75 ef                	jne    80103068 <wakeup1+0x7>
80103079:	39 42 20             	cmp    %eax,0x20(%edx)
8010307c:	75 ea                	jne    80103068 <wakeup1+0x7>
      p->state = RUNNABLE;
8010307e:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103085:	eb e1                	jmp    80103068 <wakeup1+0x7>
}
80103087:	c3                   	ret    

80103088 <allocproc>:
{
80103088:	55                   	push   %ebp
80103089:	89 e5                	mov    %esp,%ebp
8010308b:	53                   	push   %ebx
8010308c:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010308f:	68 20 1d 11 80       	push   $0x80111d20
80103094:	e8 1e 0b 00 00       	call   80103bb7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103099:	83 c4 10             	add    $0x10,%esp
8010309c:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801030a1:	eb 03                	jmp    801030a6 <allocproc+0x1e>
801030a3:	83 c3 7c             	add    $0x7c,%ebx
801030a6:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801030ac:	73 76                	jae    80103124 <allocproc+0x9c>
    if(p->state == UNUSED)
801030ae:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030b2:	75 ef                	jne    801030a3 <allocproc+0x1b>
  p->state = EMBRYO;
801030b4:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030bb:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801030c0:	8d 50 01             	lea    0x1(%eax),%edx
801030c3:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801030c9:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801030cc:	83 ec 0c             	sub    $0xc,%esp
801030cf:	68 20 1d 11 80       	push   $0x80111d20
801030d4:	e8 43 0b 00 00       	call   80103c1c <release>
  if((p->kstack = kalloc()) == 0){
801030d9:	e8 eb ef ff ff       	call   801020c9 <kalloc>
801030de:	89 43 08             	mov    %eax,0x8(%ebx)
801030e1:	83 c4 10             	add    $0x10,%esp
801030e4:	85 c0                	test   %eax,%eax
801030e6:	74 53                	je     8010313b <allocproc+0xb3>
  sp -= sizeof *p->tf;
801030e8:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801030ee:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801030f1:	c7 80 b0 0f 00 00 59 	movl   $0x80104d59,0xfb0(%eax)
801030f8:	4d 10 80 
  sp -= sizeof *p->context;
801030fb:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103100:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103103:	83 ec 04             	sub    $0x4,%esp
80103106:	6a 14                	push   $0x14
80103108:	6a 00                	push   $0x0
8010310a:	50                   	push   %eax
8010310b:	e8 53 0b 00 00       	call   80103c63 <memset>
  p->context->eip = (uint)forkret;
80103110:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103113:	c7 40 10 46 31 10 80 	movl   $0x80103146,0x10(%eax)
  return p;
8010311a:	83 c4 10             	add    $0x10,%esp
}
8010311d:	89 d8                	mov    %ebx,%eax
8010311f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103122:	c9                   	leave  
80103123:	c3                   	ret    
  release(&ptable.lock);
80103124:	83 ec 0c             	sub    $0xc,%esp
80103127:	68 20 1d 11 80       	push   $0x80111d20
8010312c:	e8 eb 0a 00 00       	call   80103c1c <release>
  return 0;
80103131:	83 c4 10             	add    $0x10,%esp
80103134:	bb 00 00 00 00       	mov    $0x0,%ebx
80103139:	eb e2                	jmp    8010311d <allocproc+0x95>
    p->state = UNUSED;
8010313b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103142:	89 c3                	mov    %eax,%ebx
80103144:	eb d7                	jmp    8010311d <allocproc+0x95>

80103146 <forkret>:
{
80103146:	55                   	push   %ebp
80103147:	89 e5                	mov    %esp,%ebp
80103149:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010314c:	68 20 1d 11 80       	push   $0x80111d20
80103151:	e8 c6 0a 00 00       	call   80103c1c <release>
  if (first) {
80103156:	83 c4 10             	add    $0x10,%esp
80103159:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103160:	75 02                	jne    80103164 <forkret+0x1e>
}
80103162:	c9                   	leave  
80103163:	c3                   	ret    
    first = 0;
80103164:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010316b:	00 00 00 
    iinit(ROOTDEV);
8010316e:	83 ec 0c             	sub    $0xc,%esp
80103171:	6a 01                	push   $0x1
80103173:	e8 62 e1 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
80103178:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010317f:	e8 e3 f5 ff ff       	call   80102767 <initlog>
80103184:	83 c4 10             	add    $0x10,%esp
}
80103187:	eb d9                	jmp    80103162 <forkret+0x1c>

80103189 <pinit>:
{
80103189:	55                   	push   %ebp
8010318a:	89 e5                	mov    %esp,%ebp
8010318c:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010318f:	68 58 6d 10 80       	push   $0x80106d58
80103194:	68 20 1d 11 80       	push   $0x80111d20
80103199:	e8 dd 08 00 00       	call   80103a7b <initlock>
}
8010319e:	83 c4 10             	add    $0x10,%esp
801031a1:	c9                   	leave  
801031a2:	c3                   	ret    

801031a3 <mycpu>:
{
801031a3:	55                   	push   %ebp
801031a4:	89 e5                	mov    %esp,%ebp
801031a6:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031a9:	9c                   	pushf  
801031aa:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031ab:	f6 c4 02             	test   $0x2,%ah
801031ae:	75 28                	jne    801031d8 <mycpu+0x35>
  apicid = lapicid();
801031b0:	e8 dd f1 ff ff       	call   80102392 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801031b5:	ba 00 00 00 00       	mov    $0x0,%edx
801031ba:	39 15 84 17 11 80    	cmp    %edx,0x80111784
801031c0:	7e 23                	jle    801031e5 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801031c2:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801031c8:	0f b6 89 a0 17 11 80 	movzbl -0x7feee860(%ecx),%ecx
801031cf:	39 c1                	cmp    %eax,%ecx
801031d1:	74 1f                	je     801031f2 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801031d3:	83 c2 01             	add    $0x1,%edx
801031d6:	eb e2                	jmp    801031ba <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801031d8:	83 ec 0c             	sub    $0xc,%esp
801031db:	68 3c 6e 10 80       	push   $0x80106e3c
801031e0:	e8 63 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801031e5:	83 ec 0c             	sub    $0xc,%esp
801031e8:	68 5f 6d 10 80       	push   $0x80106d5f
801031ed:	e8 56 d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
801031f2:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801031f8:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
801031fd:	c9                   	leave  
801031fe:	c3                   	ret    

801031ff <cpuid>:
cpuid() {
801031ff:	55                   	push   %ebp
80103200:	89 e5                	mov    %esp,%ebp
80103202:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103205:	e8 99 ff ff ff       	call   801031a3 <mycpu>
8010320a:	2d a0 17 11 80       	sub    $0x801117a0,%eax
8010320f:	c1 f8 04             	sar    $0x4,%eax
80103212:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103218:	c9                   	leave  
80103219:	c3                   	ret    

8010321a <myproc>:
myproc(void) {
8010321a:	55                   	push   %ebp
8010321b:	89 e5                	mov    %esp,%ebp
8010321d:	53                   	push   %ebx
8010321e:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103221:	e8 b6 08 00 00       	call   80103adc <pushcli>
  c = mycpu();
80103226:	e8 78 ff ff ff       	call   801031a3 <mycpu>
  p = c->proc;
8010322b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103231:	e8 e2 08 00 00       	call   80103b18 <popcli>
}
80103236:	89 d8                	mov    %ebx,%eax
80103238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010323b:	c9                   	leave  
8010323c:	c3                   	ret    

8010323d <userinit>:
{
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	53                   	push   %ebx
80103241:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103244:	e8 3f fe ff ff       	call   80103088 <allocproc>
80103249:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010324b:	a3 54 3c 11 80       	mov    %eax,0x80113c54
  if((p->pgdir = setupkvm()) == 0)
80103250:	e8 5d 32 00 00       	call   801064b2 <setupkvm>
80103255:	89 43 04             	mov    %eax,0x4(%ebx)
80103258:	85 c0                	test   %eax,%eax
8010325a:	0f 84 b8 00 00 00    	je     80103318 <userinit+0xdb>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103260:	83 ec 04             	sub    $0x4,%esp
80103263:	68 2c 00 00 00       	push   $0x2c
80103268:	68 60 a4 10 80       	push   $0x8010a460
8010326d:	50                   	push   %eax
8010326e:	e8 e5 2e 00 00       	call   80106158 <inituvm>
  p->sz = PGSIZE;
80103273:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103279:	8b 43 18             	mov    0x18(%ebx),%eax
8010327c:	83 c4 0c             	add    $0xc,%esp
8010327f:	6a 4c                	push   $0x4c
80103281:	6a 00                	push   $0x0
80103283:	50                   	push   %eax
80103284:	e8 da 09 00 00       	call   80103c63 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103289:	8b 43 18             	mov    0x18(%ebx),%eax
8010328c:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103292:	8b 43 18             	mov    0x18(%ebx),%eax
80103295:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010329b:	8b 43 18             	mov    0x18(%ebx),%eax
8010329e:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032a2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032a6:	8b 43 18             	mov    0x18(%ebx),%eax
801032a9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032ad:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032b1:	8b 43 18             	mov    0x18(%ebx),%eax
801032b4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032bb:	8b 43 18             	mov    0x18(%ebx),%eax
801032be:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801032c5:	8b 43 18             	mov    0x18(%ebx),%eax
801032c8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801032cf:	8d 43 6c             	lea    0x6c(%ebx),%eax
801032d2:	83 c4 0c             	add    $0xc,%esp
801032d5:	6a 10                	push   $0x10
801032d7:	68 88 6d 10 80       	push   $0x80106d88
801032dc:	50                   	push   %eax
801032dd:	e8 ed 0a 00 00       	call   80103dcf <safestrcpy>
  p->cwd = namei("/");
801032e2:	c7 04 24 91 6d 10 80 	movl   $0x80106d91,(%esp)
801032e9:	e8 df e8 ff ff       	call   80101bcd <namei>
801032ee:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801032f1:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801032f8:	e8 ba 08 00 00       	call   80103bb7 <acquire>
  p->state = RUNNABLE;
801032fd:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103304:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010330b:	e8 0c 09 00 00       	call   80103c1c <release>
}
80103310:	83 c4 10             	add    $0x10,%esp
80103313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103316:	c9                   	leave  
80103317:	c3                   	ret    
    panic("userinit: out of memory?");
80103318:	83 ec 0c             	sub    $0xc,%esp
8010331b:	68 6f 6d 10 80       	push   $0x80106d6f
80103320:	e8 23 d0 ff ff       	call   80100348 <panic>

80103325 <growproc>:
{
80103325:	55                   	push   %ebp
80103326:	89 e5                	mov    %esp,%ebp
80103328:	56                   	push   %esi
80103329:	53                   	push   %ebx
8010332a:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010332d:	e8 e8 fe ff ff       	call   8010321a <myproc>
80103332:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103334:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103336:	85 f6                	test   %esi,%esi
80103338:	7f 1c                	jg     80103356 <growproc+0x31>
  } else if(n < 0){
8010333a:	78 37                	js     80103373 <growproc+0x4e>
  curproc->sz = sz;
8010333c:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010333e:	83 ec 0c             	sub    $0xc,%esp
80103341:	53                   	push   %ebx
80103342:	e8 9d 2c 00 00       	call   80105fe4 <switchuvm>
  return 0;
80103347:	83 c4 10             	add    $0x10,%esp
8010334a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010334f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103352:	5b                   	pop    %ebx
80103353:	5e                   	pop    %esi
80103354:	5d                   	pop    %ebp
80103355:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103356:	83 ec 04             	sub    $0x4,%esp
80103359:	01 c6                	add    %eax,%esi
8010335b:	56                   	push   %esi
8010335c:	50                   	push   %eax
8010335d:	ff 73 04             	push   0x4(%ebx)
80103360:	e8 c9 2f 00 00       	call   8010632e <allocuvm>
80103365:	83 c4 10             	add    $0x10,%esp
80103368:	85 c0                	test   %eax,%eax
8010336a:	75 d0                	jne    8010333c <growproc+0x17>
      return -1;
8010336c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103371:	eb dc                	jmp    8010334f <growproc+0x2a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103373:	83 ec 04             	sub    $0x4,%esp
80103376:	01 c6                	add    %eax,%esi
80103378:	56                   	push   %esi
80103379:	50                   	push   %eax
8010337a:	ff 73 04             	push   0x4(%ebx)
8010337d:	e8 06 2f 00 00       	call   80106288 <deallocuvm>
80103382:	83 c4 10             	add    $0x10,%esp
80103385:	85 c0                	test   %eax,%eax
80103387:	75 b3                	jne    8010333c <growproc+0x17>
      return -1;
80103389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010338e:	eb bf                	jmp    8010334f <growproc+0x2a>

80103390 <fork>:
{
80103390:	55                   	push   %ebp
80103391:	89 e5                	mov    %esp,%ebp
80103393:	57                   	push   %edi
80103394:	56                   	push   %esi
80103395:	53                   	push   %ebx
80103396:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103399:	e8 7c fe ff ff       	call   8010321a <myproc>
8010339e:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033a0:	e8 e3 fc ff ff       	call   80103088 <allocproc>
801033a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033a8:	85 c0                	test   %eax,%eax
801033aa:	0f 84 e0 00 00 00    	je     80103490 <fork+0x100>
801033b0:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033b2:	83 ec 08             	sub    $0x8,%esp
801033b5:	ff 33                	push   (%ebx)
801033b7:	ff 73 04             	push   0x4(%ebx)
801033ba:	e8 a4 31 00 00       	call   80106563 <copyuvm>
801033bf:	89 47 04             	mov    %eax,0x4(%edi)
801033c2:	83 c4 10             	add    $0x10,%esp
801033c5:	85 c0                	test   %eax,%eax
801033c7:	74 2a                	je     801033f3 <fork+0x63>
  np->sz = curproc->sz;
801033c9:	8b 03                	mov    (%ebx),%eax
801033cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801033ce:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801033d0:	89 c8                	mov    %ecx,%eax
801033d2:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801033d5:	8b 73 18             	mov    0x18(%ebx),%esi
801033d8:	8b 79 18             	mov    0x18(%ecx),%edi
801033db:	b9 13 00 00 00       	mov    $0x13,%ecx
801033e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801033e2:	8b 40 18             	mov    0x18(%eax),%eax
801033e5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801033ec:	be 00 00 00 00       	mov    $0x0,%esi
801033f1:	eb 29                	jmp    8010341c <fork+0x8c>
    kfree(np->kstack);
801033f3:	83 ec 0c             	sub    $0xc,%esp
801033f6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801033f9:	ff 73 08             	push   0x8(%ebx)
801033fc:	e8 8b eb ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
80103401:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103408:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010340f:	83 c4 10             	add    $0x10,%esp
80103412:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103417:	eb 6d                	jmp    80103486 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103419:	83 c6 01             	add    $0x1,%esi
8010341c:	83 fe 0f             	cmp    $0xf,%esi
8010341f:	7f 1d                	jg     8010343e <fork+0xae>
    if(curproc->ofile[i])
80103421:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103425:	85 c0                	test   %eax,%eax
80103427:	74 f0                	je     80103419 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103429:	83 ec 0c             	sub    $0xc,%esp
8010342c:	50                   	push   %eax
8010342d:	e8 4c d8 ff ff       	call   80100c7e <filedup>
80103432:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103435:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103439:	83 c4 10             	add    $0x10,%esp
8010343c:	eb db                	jmp    80103419 <fork+0x89>
  np->cwd = idup(curproc->cwd);
8010343e:	83 ec 0c             	sub    $0xc,%esp
80103441:	ff 73 68             	push   0x68(%ebx)
80103444:	e8 f6 e0 ff ff       	call   8010153f <idup>
80103449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010344c:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010344f:	83 c3 6c             	add    $0x6c,%ebx
80103452:	8d 47 6c             	lea    0x6c(%edi),%eax
80103455:	83 c4 0c             	add    $0xc,%esp
80103458:	6a 10                	push   $0x10
8010345a:	53                   	push   %ebx
8010345b:	50                   	push   %eax
8010345c:	e8 6e 09 00 00       	call   80103dcf <safestrcpy>
  pid = np->pid;
80103461:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103464:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010346b:	e8 47 07 00 00       	call   80103bb7 <acquire>
  np->state = RUNNABLE;
80103470:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103477:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010347e:	e8 99 07 00 00       	call   80103c1c <release>
  return pid;
80103483:	83 c4 10             	add    $0x10,%esp
}
80103486:	89 d8                	mov    %ebx,%eax
80103488:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010348b:	5b                   	pop    %ebx
8010348c:	5e                   	pop    %esi
8010348d:	5f                   	pop    %edi
8010348e:	5d                   	pop    %ebp
8010348f:	c3                   	ret    
    return -1;
80103490:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103495:	eb ef                	jmp    80103486 <fork+0xf6>

80103497 <scheduler>:
{
80103497:	55                   	push   %ebp
80103498:	89 e5                	mov    %esp,%ebp
8010349a:	56                   	push   %esi
8010349b:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010349c:	e8 02 fd ff ff       	call   801031a3 <mycpu>
801034a1:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034a3:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034aa:	00 00 00 
801034ad:	eb 5a                	jmp    80103509 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034af:	83 c3 7c             	add    $0x7c,%ebx
801034b2:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801034b8:	73 3f                	jae    801034f9 <scheduler+0x62>
      if(p->state != RUNNABLE)
801034ba:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801034be:	75 ef                	jne    801034af <scheduler+0x18>
      c->proc = p;
801034c0:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801034c6:	83 ec 0c             	sub    $0xc,%esp
801034c9:	53                   	push   %ebx
801034ca:	e8 15 2b 00 00       	call   80105fe4 <switchuvm>
      p->state = RUNNING;
801034cf:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801034d6:	83 c4 08             	add    $0x8,%esp
801034d9:	ff 73 1c             	push   0x1c(%ebx)
801034dc:	8d 46 04             	lea    0x4(%esi),%eax
801034df:	50                   	push   %eax
801034e0:	e8 3f 09 00 00       	call   80103e24 <swtch>
      switchkvm();
801034e5:	e8 d5 2a 00 00       	call   80105fbf <switchkvm>
      c->proc = 0;
801034ea:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801034f1:	00 00 00 
801034f4:	83 c4 10             	add    $0x10,%esp
801034f7:	eb b6                	jmp    801034af <scheduler+0x18>
    release(&ptable.lock);
801034f9:	83 ec 0c             	sub    $0xc,%esp
801034fc:	68 20 1d 11 80       	push   $0x80111d20
80103501:	e8 16 07 00 00       	call   80103c1c <release>
    sti();
80103506:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103509:	fb                   	sti    
    acquire(&ptable.lock);
8010350a:	83 ec 0c             	sub    $0xc,%esp
8010350d:	68 20 1d 11 80       	push   $0x80111d20
80103512:	e8 a0 06 00 00       	call   80103bb7 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103517:	83 c4 10             	add    $0x10,%esp
8010351a:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010351f:	eb 91                	jmp    801034b2 <scheduler+0x1b>

80103521 <sched>:
{
80103521:	55                   	push   %ebp
80103522:	89 e5                	mov    %esp,%ebp
80103524:	56                   	push   %esi
80103525:	53                   	push   %ebx
  struct proc *p = myproc();
80103526:	e8 ef fc ff ff       	call   8010321a <myproc>
8010352b:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010352d:	83 ec 0c             	sub    $0xc,%esp
80103530:	68 20 1d 11 80       	push   $0x80111d20
80103535:	e8 3e 06 00 00       	call   80103b78 <holding>
8010353a:	83 c4 10             	add    $0x10,%esp
8010353d:	85 c0                	test   %eax,%eax
8010353f:	74 4f                	je     80103590 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103541:	e8 5d fc ff ff       	call   801031a3 <mycpu>
80103546:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010354d:	75 4e                	jne    8010359d <sched+0x7c>
  if(p->state == RUNNING)
8010354f:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103553:	74 55                	je     801035aa <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103555:	9c                   	pushf  
80103556:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103557:	f6 c4 02             	test   $0x2,%ah
8010355a:	75 5b                	jne    801035b7 <sched+0x96>
  intena = mycpu()->intena;
8010355c:	e8 42 fc ff ff       	call   801031a3 <mycpu>
80103561:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103567:	e8 37 fc ff ff       	call   801031a3 <mycpu>
8010356c:	83 ec 08             	sub    $0x8,%esp
8010356f:	ff 70 04             	push   0x4(%eax)
80103572:	83 c3 1c             	add    $0x1c,%ebx
80103575:	53                   	push   %ebx
80103576:	e8 a9 08 00 00       	call   80103e24 <swtch>
  mycpu()->intena = intena;
8010357b:	e8 23 fc ff ff       	call   801031a3 <mycpu>
80103580:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010358c:	5b                   	pop    %ebx
8010358d:	5e                   	pop    %esi
8010358e:	5d                   	pop    %ebp
8010358f:	c3                   	ret    
    panic("sched ptable.lock");
80103590:	83 ec 0c             	sub    $0xc,%esp
80103593:	68 93 6d 10 80       	push   $0x80106d93
80103598:	e8 ab cd ff ff       	call   80100348 <panic>
    panic("sched locks");
8010359d:	83 ec 0c             	sub    $0xc,%esp
801035a0:	68 a5 6d 10 80       	push   $0x80106da5
801035a5:	e8 9e cd ff ff       	call   80100348 <panic>
    panic("sched running");
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 b1 6d 10 80       	push   $0x80106db1
801035b2:	e8 91 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801035b7:	83 ec 0c             	sub    $0xc,%esp
801035ba:	68 bf 6d 10 80       	push   $0x80106dbf
801035bf:	e8 84 cd ff ff       	call   80100348 <panic>

801035c4 <exit>:
{
801035c4:	55                   	push   %ebp
801035c5:	89 e5                	mov    %esp,%ebp
801035c7:	56                   	push   %esi
801035c8:	53                   	push   %ebx
  struct proc *curproc = myproc();
801035c9:	e8 4c fc ff ff       	call   8010321a <myproc>
  if(curproc == initproc)
801035ce:	39 05 54 3c 11 80    	cmp    %eax,0x80113c54
801035d4:	74 09                	je     801035df <exit+0x1b>
801035d6:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035d8:	bb 00 00 00 00       	mov    $0x0,%ebx
801035dd:	eb 24                	jmp    80103603 <exit+0x3f>
    panic("init exiting");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 d3 6d 10 80       	push   $0x80106dd3
801035e7:	e8 5c cd ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
801035ec:	83 ec 0c             	sub    $0xc,%esp
801035ef:	50                   	push   %eax
801035f0:	e8 ce d6 ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
801035f5:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801035fc:	00 
801035fd:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103600:	83 c3 01             	add    $0x1,%ebx
80103603:	83 fb 0f             	cmp    $0xf,%ebx
80103606:	7f 0a                	jg     80103612 <exit+0x4e>
    if(curproc->ofile[fd]){
80103608:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010360c:	85 c0                	test   %eax,%eax
8010360e:	75 dc                	jne    801035ec <exit+0x28>
80103610:	eb ee                	jmp    80103600 <exit+0x3c>
  begin_op();
80103612:	e8 99 f1 ff ff       	call   801027b0 <begin_op>
  iput(curproc->cwd);
80103617:	83 ec 0c             	sub    $0xc,%esp
8010361a:	ff 76 68             	push   0x68(%esi)
8010361d:	e8 54 e0 ff ff       	call   80101676 <iput>
  end_op();
80103622:	e8 03 f2 ff ff       	call   8010282a <end_op>
  curproc->cwd = 0;
80103627:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010362e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103635:	e8 7d 05 00 00       	call   80103bb7 <acquire>
  wakeup1(curproc->parent);
8010363a:	8b 46 14             	mov    0x14(%esi),%eax
8010363d:	e8 1f fa ff ff       	call   80103061 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103642:	83 c4 10             	add    $0x10,%esp
80103645:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010364a:	eb 03                	jmp    8010364f <exit+0x8b>
8010364c:	83 c3 7c             	add    $0x7c,%ebx
8010364f:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103655:	73 1a                	jae    80103671 <exit+0xad>
    if(p->parent == curproc){
80103657:	39 73 14             	cmp    %esi,0x14(%ebx)
8010365a:	75 f0                	jne    8010364c <exit+0x88>
      p->parent = initproc;
8010365c:	a1 54 3c 11 80       	mov    0x80113c54,%eax
80103661:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103664:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103668:	75 e2                	jne    8010364c <exit+0x88>
        wakeup1(initproc);
8010366a:	e8 f2 f9 ff ff       	call   80103061 <wakeup1>
8010366f:	eb db                	jmp    8010364c <exit+0x88>
  curproc->state = ZOMBIE;
80103671:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103678:	e8 a4 fe ff ff       	call   80103521 <sched>
  panic("zombie exit");
8010367d:	83 ec 0c             	sub    $0xc,%esp
80103680:	68 e0 6d 10 80       	push   $0x80106de0
80103685:	e8 be cc ff ff       	call   80100348 <panic>

8010368a <yield>:
{
8010368a:	55                   	push   %ebp
8010368b:	89 e5                	mov    %esp,%ebp
8010368d:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103690:	68 20 1d 11 80       	push   $0x80111d20
80103695:	e8 1d 05 00 00       	call   80103bb7 <acquire>
  myproc()->state = RUNNABLE;
8010369a:	e8 7b fb ff ff       	call   8010321a <myproc>
8010369f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801036a6:	e8 76 fe ff ff       	call   80103521 <sched>
  release(&ptable.lock);
801036ab:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036b2:	e8 65 05 00 00       	call   80103c1c <release>
}
801036b7:	83 c4 10             	add    $0x10,%esp
801036ba:	c9                   	leave  
801036bb:	c3                   	ret    

801036bc <sleep>:
{
801036bc:	55                   	push   %ebp
801036bd:	89 e5                	mov    %esp,%ebp
801036bf:	56                   	push   %esi
801036c0:	53                   	push   %ebx
801036c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801036c4:	e8 51 fb ff ff       	call   8010321a <myproc>
  if(p == 0)
801036c9:	85 c0                	test   %eax,%eax
801036cb:	74 66                	je     80103733 <sleep+0x77>
801036cd:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801036cf:	85 f6                	test   %esi,%esi
801036d1:	74 6d                	je     80103740 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801036d3:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801036d9:	74 18                	je     801036f3 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036db:	83 ec 0c             	sub    $0xc,%esp
801036de:	68 20 1d 11 80       	push   $0x80111d20
801036e3:	e8 cf 04 00 00       	call   80103bb7 <acquire>
    release(lk);
801036e8:	89 34 24             	mov    %esi,(%esp)
801036eb:	e8 2c 05 00 00       	call   80103c1c <release>
801036f0:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801036f3:	8b 45 08             	mov    0x8(%ebp),%eax
801036f6:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
801036f9:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103700:	e8 1c fe ff ff       	call   80103521 <sched>
  p->chan = 0;
80103705:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010370c:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103712:	74 18                	je     8010372c <sleep+0x70>
    release(&ptable.lock);
80103714:	83 ec 0c             	sub    $0xc,%esp
80103717:	68 20 1d 11 80       	push   $0x80111d20
8010371c:	e8 fb 04 00 00       	call   80103c1c <release>
    acquire(lk);
80103721:	89 34 24             	mov    %esi,(%esp)
80103724:	e8 8e 04 00 00       	call   80103bb7 <acquire>
80103729:	83 c4 10             	add    $0x10,%esp
}
8010372c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010372f:	5b                   	pop    %ebx
80103730:	5e                   	pop    %esi
80103731:	5d                   	pop    %ebp
80103732:	c3                   	ret    
    panic("sleep");
80103733:	83 ec 0c             	sub    $0xc,%esp
80103736:	68 ec 6d 10 80       	push   $0x80106dec
8010373b:	e8 08 cc ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103740:	83 ec 0c             	sub    $0xc,%esp
80103743:	68 f2 6d 10 80       	push   $0x80106df2
80103748:	e8 fb cb ff ff       	call   80100348 <panic>

8010374d <wait>:
{
8010374d:	55                   	push   %ebp
8010374e:	89 e5                	mov    %esp,%ebp
80103750:	56                   	push   %esi
80103751:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103752:	e8 c3 fa ff ff       	call   8010321a <myproc>
80103757:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103759:	83 ec 0c             	sub    $0xc,%esp
8010375c:	68 20 1d 11 80       	push   $0x80111d20
80103761:	e8 51 04 00 00       	call   80103bb7 <acquire>
80103766:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103769:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010376e:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103773:	eb 5b                	jmp    801037d0 <wait+0x83>
        pid = p->pid;
80103775:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103778:	83 ec 0c             	sub    $0xc,%esp
8010377b:	ff 73 08             	push   0x8(%ebx)
8010377e:	e8 09 e8 ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
80103783:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
8010378a:	83 c4 04             	add    $0x4,%esp
8010378d:	ff 73 04             	push   0x4(%ebx)
80103790:	e8 9b 2c 00 00       	call   80106430 <freevm>
        p->pid = 0;
80103795:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010379c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801037a3:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801037a7:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801037ae:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801037b5:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801037bc:	e8 5b 04 00 00       	call   80103c1c <release>
        return pid;
801037c1:	83 c4 10             	add    $0x10,%esp
}
801037c4:	89 f0                	mov    %esi,%eax
801037c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037c9:	5b                   	pop    %ebx
801037ca:	5e                   	pop    %esi
801037cb:	5d                   	pop    %ebp
801037cc:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037cd:	83 c3 7c             	add    $0x7c,%ebx
801037d0:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801037d6:	73 12                	jae    801037ea <wait+0x9d>
      if(p->parent != curproc)
801037d8:	39 73 14             	cmp    %esi,0x14(%ebx)
801037db:	75 f0                	jne    801037cd <wait+0x80>
      if(p->state == ZOMBIE){
801037dd:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037e1:	74 92                	je     80103775 <wait+0x28>
      havekids = 1;
801037e3:	b8 01 00 00 00       	mov    $0x1,%eax
801037e8:	eb e3                	jmp    801037cd <wait+0x80>
    if(!havekids || curproc->killed){
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 06                	je     801037f4 <wait+0xa7>
801037ee:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801037f2:	74 17                	je     8010380b <wait+0xbe>
      release(&ptable.lock);
801037f4:	83 ec 0c             	sub    $0xc,%esp
801037f7:	68 20 1d 11 80       	push   $0x80111d20
801037fc:	e8 1b 04 00 00       	call   80103c1c <release>
      return -1;
80103801:	83 c4 10             	add    $0x10,%esp
80103804:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103809:	eb b9                	jmp    801037c4 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010380b:	83 ec 08             	sub    $0x8,%esp
8010380e:	68 20 1d 11 80       	push   $0x80111d20
80103813:	56                   	push   %esi
80103814:	e8 a3 fe ff ff       	call   801036bc <sleep>
    havekids = 0;
80103819:	83 c4 10             	add    $0x10,%esp
8010381c:	e9 48 ff ff ff       	jmp    80103769 <wait+0x1c>

80103821 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103821:	55                   	push   %ebp
80103822:	89 e5                	mov    %esp,%ebp
80103824:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103827:	68 20 1d 11 80       	push   $0x80111d20
8010382c:	e8 86 03 00 00       	call   80103bb7 <acquire>
  wakeup1(chan);
80103831:	8b 45 08             	mov    0x8(%ebp),%eax
80103834:	e8 28 f8 ff ff       	call   80103061 <wakeup1>
  release(&ptable.lock);
80103839:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103840:	e8 d7 03 00 00       	call   80103c1c <release>
}
80103845:	83 c4 10             	add    $0x10,%esp
80103848:	c9                   	leave  
80103849:	c3                   	ret    

8010384a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010384a:	55                   	push   %ebp
8010384b:	89 e5                	mov    %esp,%ebp
8010384d:	53                   	push   %ebx
8010384e:	83 ec 10             	sub    $0x10,%esp
80103851:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103854:	68 20 1d 11 80       	push   $0x80111d20
80103859:	e8 59 03 00 00       	call   80103bb7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010385e:	83 c4 10             	add    $0x10,%esp
80103861:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103866:	eb 0c                	jmp    80103874 <kill+0x2a>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103868:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
8010386f:	eb 1c                	jmp    8010388d <kill+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103871:	83 c0 7c             	add    $0x7c,%eax
80103874:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103879:	73 2c                	jae    801038a7 <kill+0x5d>
    if(p->pid == pid){
8010387b:	39 58 10             	cmp    %ebx,0x10(%eax)
8010387e:	75 f1                	jne    80103871 <kill+0x27>
      p->killed = 1;
80103880:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
80103887:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010388b:	74 db                	je     80103868 <kill+0x1e>
      release(&ptable.lock);
8010388d:	83 ec 0c             	sub    $0xc,%esp
80103890:	68 20 1d 11 80       	push   $0x80111d20
80103895:	e8 82 03 00 00       	call   80103c1c <release>
      return 0;
8010389a:	83 c4 10             	add    $0x10,%esp
8010389d:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038a5:	c9                   	leave  
801038a6:	c3                   	ret    
  release(&ptable.lock);
801038a7:	83 ec 0c             	sub    $0xc,%esp
801038aa:	68 20 1d 11 80       	push   $0x80111d20
801038af:	e8 68 03 00 00       	call   80103c1c <release>
  return -1;
801038b4:	83 c4 10             	add    $0x10,%esp
801038b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038bc:	eb e4                	jmp    801038a2 <kill+0x58>

801038be <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801038be:	55                   	push   %ebp
801038bf:	89 e5                	mov    %esp,%ebp
801038c1:	56                   	push   %esi
801038c2:	53                   	push   %ebx
801038c3:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038c6:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801038cb:	eb 33                	jmp    80103900 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801038cd:	b8 03 6e 10 80       	mov    $0x80106e03,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801038d2:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038d5:	52                   	push   %edx
801038d6:	50                   	push   %eax
801038d7:	ff 73 10             	push   0x10(%ebx)
801038da:	68 07 6e 10 80       	push   $0x80106e07
801038df:	e8 23 cd ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
801038e4:	83 c4 10             	add    $0x10,%esp
801038e7:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801038eb:	74 39                	je     80103926 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801038ed:	83 ec 0c             	sub    $0xc,%esp
801038f0:	68 8f 71 10 80       	push   $0x8010718f
801038f5:	e8 0d cd ff ff       	call   80100607 <cprintf>
801038fa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038fd:	83 c3 7c             	add    $0x7c,%ebx
80103900:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103906:	73 61                	jae    80103969 <procdump+0xab>
    if(p->state == UNUSED)
80103908:	8b 43 0c             	mov    0xc(%ebx),%eax
8010390b:	85 c0                	test   %eax,%eax
8010390d:	74 ee                	je     801038fd <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010390f:	83 f8 05             	cmp    $0x5,%eax
80103912:	77 b9                	ja     801038cd <procdump+0xf>
80103914:	8b 04 85 64 6e 10 80 	mov    -0x7fef919c(,%eax,4),%eax
8010391b:	85 c0                	test   %eax,%eax
8010391d:	75 b3                	jne    801038d2 <procdump+0x14>
      state = "???";
8010391f:	b8 03 6e 10 80       	mov    $0x80106e03,%eax
80103924:	eb ac                	jmp    801038d2 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103926:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103929:	8b 40 0c             	mov    0xc(%eax),%eax
8010392c:	83 c0 08             	add    $0x8,%eax
8010392f:	83 ec 08             	sub    $0x8,%esp
80103932:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103935:	52                   	push   %edx
80103936:	50                   	push   %eax
80103937:	e8 5a 01 00 00       	call   80103a96 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010393c:	83 c4 10             	add    $0x10,%esp
8010393f:	be 00 00 00 00       	mov    $0x0,%esi
80103944:	eb 14                	jmp    8010395a <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103946:	83 ec 08             	sub    $0x8,%esp
80103949:	50                   	push   %eax
8010394a:	68 a1 67 10 80       	push   $0x801067a1
8010394f:	e8 b3 cc ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103954:	83 c6 01             	add    $0x1,%esi
80103957:	83 c4 10             	add    $0x10,%esp
8010395a:	83 fe 09             	cmp    $0x9,%esi
8010395d:	7f 8e                	jg     801038ed <procdump+0x2f>
8010395f:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103963:	85 c0                	test   %eax,%eax
80103965:	75 df                	jne    80103946 <procdump+0x88>
80103967:	eb 84                	jmp    801038ed <procdump+0x2f>
  }
}
80103969:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010396c:	5b                   	pop    %ebx
8010396d:	5e                   	pop    %esi
8010396e:	5d                   	pop    %ebp
8010396f:	c3                   	ret    

80103970 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	53                   	push   %ebx
80103974:	83 ec 0c             	sub    $0xc,%esp
80103977:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010397a:	68 7c 6e 10 80       	push   $0x80106e7c
8010397f:	8d 43 04             	lea    0x4(%ebx),%eax
80103982:	50                   	push   %eax
80103983:	e8 f3 00 00 00       	call   80103a7b <initlock>
  lk->name = name;
80103988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010398b:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
8010398e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103994:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
8010399b:	83 c4 10             	add    $0x10,%esp
8010399e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039a1:	c9                   	leave  
801039a2:	c3                   	ret    

801039a3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801039a3:	55                   	push   %ebp
801039a4:	89 e5                	mov    %esp,%ebp
801039a6:	56                   	push   %esi
801039a7:	53                   	push   %ebx
801039a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801039ab:	8d 73 04             	lea    0x4(%ebx),%esi
801039ae:	83 ec 0c             	sub    $0xc,%esp
801039b1:	56                   	push   %esi
801039b2:	e8 00 02 00 00       	call   80103bb7 <acquire>
  while (lk->locked) {
801039b7:	83 c4 10             	add    $0x10,%esp
801039ba:	eb 0d                	jmp    801039c9 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
801039bc:	83 ec 08             	sub    $0x8,%esp
801039bf:	56                   	push   %esi
801039c0:	53                   	push   %ebx
801039c1:	e8 f6 fc ff ff       	call   801036bc <sleep>
801039c6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801039c9:	83 3b 00             	cmpl   $0x0,(%ebx)
801039cc:	75 ee                	jne    801039bc <acquiresleep+0x19>
  }
  lk->locked = 1;
801039ce:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801039d4:	e8 41 f8 ff ff       	call   8010321a <myproc>
801039d9:	8b 40 10             	mov    0x10(%eax),%eax
801039dc:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801039df:	83 ec 0c             	sub    $0xc,%esp
801039e2:	56                   	push   %esi
801039e3:	e8 34 02 00 00       	call   80103c1c <release>
}
801039e8:	83 c4 10             	add    $0x10,%esp
801039eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039ee:	5b                   	pop    %ebx
801039ef:	5e                   	pop    %esi
801039f0:	5d                   	pop    %ebp
801039f1:	c3                   	ret    

801039f2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801039f2:	55                   	push   %ebp
801039f3:	89 e5                	mov    %esp,%ebp
801039f5:	56                   	push   %esi
801039f6:	53                   	push   %ebx
801039f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801039fa:	8d 73 04             	lea    0x4(%ebx),%esi
801039fd:	83 ec 0c             	sub    $0xc,%esp
80103a00:	56                   	push   %esi
80103a01:	e8 b1 01 00 00       	call   80103bb7 <acquire>
  lk->locked = 0;
80103a06:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a0c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a13:	89 1c 24             	mov    %ebx,(%esp)
80103a16:	e8 06 fe ff ff       	call   80103821 <wakeup>
  release(&lk->lk);
80103a1b:	89 34 24             	mov    %esi,(%esp)
80103a1e:	e8 f9 01 00 00       	call   80103c1c <release>
}
80103a23:	83 c4 10             	add    $0x10,%esp
80103a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a29:	5b                   	pop    %ebx
80103a2a:	5e                   	pop    %esi
80103a2b:	5d                   	pop    %ebp
80103a2c:	c3                   	ret    

80103a2d <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103a2d:	55                   	push   %ebp
80103a2e:	89 e5                	mov    %esp,%ebp
80103a30:	56                   	push   %esi
80103a31:	53                   	push   %ebx
80103a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103a35:	8d 73 04             	lea    0x4(%ebx),%esi
80103a38:	83 ec 0c             	sub    $0xc,%esp
80103a3b:	56                   	push   %esi
80103a3c:	e8 76 01 00 00       	call   80103bb7 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103a41:	83 c4 10             	add    $0x10,%esp
80103a44:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a47:	75 17                	jne    80103a60 <holdingsleep+0x33>
80103a49:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103a4e:	83 ec 0c             	sub    $0xc,%esp
80103a51:	56                   	push   %esi
80103a52:	e8 c5 01 00 00       	call   80103c1c <release>
  return r;
}
80103a57:	89 d8                	mov    %ebx,%eax
80103a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a5c:	5b                   	pop    %ebx
80103a5d:	5e                   	pop    %esi
80103a5e:	5d                   	pop    %ebp
80103a5f:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103a60:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103a63:	e8 b2 f7 ff ff       	call   8010321a <myproc>
80103a68:	3b 58 10             	cmp    0x10(%eax),%ebx
80103a6b:	74 07                	je     80103a74 <holdingsleep+0x47>
80103a6d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a72:	eb da                	jmp    80103a4e <holdingsleep+0x21>
80103a74:	bb 01 00 00 00       	mov    $0x1,%ebx
80103a79:	eb d3                	jmp    80103a4e <holdingsleep+0x21>

80103a7b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103a7b:	55                   	push   %ebp
80103a7c:	89 e5                	mov    %esp,%ebp
80103a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103a81:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a84:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103a87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103a8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103a94:	5d                   	pop    %ebp
80103a95:	c3                   	ret    

80103a96 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103a96:	55                   	push   %ebp
80103a97:	89 e5                	mov    %esp,%ebp
80103a99:	53                   	push   %ebx
80103a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa0:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103aa3:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa8:	83 f8 09             	cmp    $0x9,%eax
80103aab:	7f 25                	jg     80103ad2 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103aad:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103ab3:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103ab9:	77 17                	ja     80103ad2 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103abb:	8b 5a 04             	mov    0x4(%edx),%ebx
80103abe:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103ac1:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103ac3:	83 c0 01             	add    $0x1,%eax
80103ac6:	eb e0                	jmp    80103aa8 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103ac8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103acf:	83 c0 01             	add    $0x1,%eax
80103ad2:	83 f8 09             	cmp    $0x9,%eax
80103ad5:	7e f1                	jle    80103ac8 <getcallerpcs+0x32>
}
80103ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ada:	c9                   	leave  
80103adb:	c3                   	ret    

80103adc <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	53                   	push   %ebx
80103ae0:	83 ec 04             	sub    $0x4,%esp
80103ae3:	9c                   	pushf  
80103ae4:	5b                   	pop    %ebx
  asm volatile("cli");
80103ae5:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103ae6:	e8 b8 f6 ff ff       	call   801031a3 <mycpu>
80103aeb:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103af2:	74 11                	je     80103b05 <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103af4:	e8 aa f6 ff ff       	call   801031a3 <mycpu>
80103af9:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b03:	c9                   	leave  
80103b04:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b05:	e8 99 f6 ff ff       	call   801031a3 <mycpu>
80103b0a:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b10:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103b16:	eb dc                	jmp    80103af4 <pushcli+0x18>

80103b18 <popcli>:

void
popcli(void)
{
80103b18:	55                   	push   %ebp
80103b19:	89 e5                	mov    %esp,%ebp
80103b1b:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b1e:	9c                   	pushf  
80103b1f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103b20:	f6 c4 02             	test   $0x2,%ah
80103b23:	75 28                	jne    80103b4d <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103b25:	e8 79 f6 ff ff       	call   801031a3 <mycpu>
80103b2a:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103b30:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103b33:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103b39:	85 d2                	test   %edx,%edx
80103b3b:	78 1d                	js     80103b5a <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b3d:	e8 61 f6 ff ff       	call   801031a3 <mycpu>
80103b42:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b49:	74 1c                	je     80103b67 <popcli+0x4f>
    sti();
}
80103b4b:	c9                   	leave  
80103b4c:	c3                   	ret    
    panic("popcli - interruptible");
80103b4d:	83 ec 0c             	sub    $0xc,%esp
80103b50:	68 87 6e 10 80       	push   $0x80106e87
80103b55:	e8 ee c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103b5a:	83 ec 0c             	sub    $0xc,%esp
80103b5d:	68 9e 6e 10 80       	push   $0x80106e9e
80103b62:	e8 e1 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b67:	e8 37 f6 ff ff       	call   801031a3 <mycpu>
80103b6c:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103b73:	74 d6                	je     80103b4b <popcli+0x33>
  asm volatile("sti");
80103b75:	fb                   	sti    
}
80103b76:	eb d3                	jmp    80103b4b <popcli+0x33>

80103b78 <holding>:
{
80103b78:	55                   	push   %ebp
80103b79:	89 e5                	mov    %esp,%ebp
80103b7b:	53                   	push   %ebx
80103b7c:	83 ec 04             	sub    $0x4,%esp
80103b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103b82:	e8 55 ff ff ff       	call   80103adc <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103b87:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b8a:	75 11                	jne    80103b9d <holding+0x25>
80103b8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103b91:	e8 82 ff ff ff       	call   80103b18 <popcli>
}
80103b96:	89 d8                	mov    %ebx,%eax
80103b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b9b:	c9                   	leave  
80103b9c:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103b9d:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103ba0:	e8 fe f5 ff ff       	call   801031a3 <mycpu>
80103ba5:	39 c3                	cmp    %eax,%ebx
80103ba7:	74 07                	je     80103bb0 <holding+0x38>
80103ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
80103bae:	eb e1                	jmp    80103b91 <holding+0x19>
80103bb0:	bb 01 00 00 00       	mov    $0x1,%ebx
80103bb5:	eb da                	jmp    80103b91 <holding+0x19>

80103bb7 <acquire>:
{
80103bb7:	55                   	push   %ebp
80103bb8:	89 e5                	mov    %esp,%ebp
80103bba:	53                   	push   %ebx
80103bbb:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103bbe:	e8 19 ff ff ff       	call   80103adc <pushcli>
  if(holding(lk))
80103bc3:	83 ec 0c             	sub    $0xc,%esp
80103bc6:	ff 75 08             	push   0x8(%ebp)
80103bc9:	e8 aa ff ff ff       	call   80103b78 <holding>
80103bce:	83 c4 10             	add    $0x10,%esp
80103bd1:	85 c0                	test   %eax,%eax
80103bd3:	75 3a                	jne    80103c0f <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103bd8:	b8 01 00 00 00       	mov    $0x1,%eax
80103bdd:	f0 87 02             	lock xchg %eax,(%edx)
80103be0:	85 c0                	test   %eax,%eax
80103be2:	75 f1                	jne    80103bd5 <acquire+0x1e>
  __sync_synchronize();
80103be4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103bec:	e8 b2 f5 ff ff       	call   801031a3 <mycpu>
80103bf1:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf7:	83 c0 0c             	add    $0xc,%eax
80103bfa:	83 ec 08             	sub    $0x8,%esp
80103bfd:	50                   	push   %eax
80103bfe:	8d 45 08             	lea    0x8(%ebp),%eax
80103c01:	50                   	push   %eax
80103c02:	e8 8f fe ff ff       	call   80103a96 <getcallerpcs>
}
80103c07:	83 c4 10             	add    $0x10,%esp
80103c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c0d:	c9                   	leave  
80103c0e:	c3                   	ret    
    panic("acquire");
80103c0f:	83 ec 0c             	sub    $0xc,%esp
80103c12:	68 a5 6e 10 80       	push   $0x80106ea5
80103c17:	e8 2c c7 ff ff       	call   80100348 <panic>

80103c1c <release>:
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	53                   	push   %ebx
80103c20:	83 ec 10             	sub    $0x10,%esp
80103c23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103c26:	53                   	push   %ebx
80103c27:	e8 4c ff ff ff       	call   80103b78 <holding>
80103c2c:	83 c4 10             	add    $0x10,%esp
80103c2f:	85 c0                	test   %eax,%eax
80103c31:	74 23                	je     80103c56 <release+0x3a>
  lk->pcs[0] = 0;
80103c33:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103c3a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103c41:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103c46:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103c4c:	e8 c7 fe ff ff       	call   80103b18 <popcli>
}
80103c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c54:	c9                   	leave  
80103c55:	c3                   	ret    
    panic("release");
80103c56:	83 ec 0c             	sub    $0xc,%esp
80103c59:	68 ad 6e 10 80       	push   $0x80106ead
80103c5e:	e8 e5 c6 ff ff       	call   80100348 <panic>

80103c63 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103c63:	55                   	push   %ebp
80103c64:	89 e5                	mov    %esp,%ebp
80103c66:	57                   	push   %edi
80103c67:	53                   	push   %ebx
80103c68:	8b 55 08             	mov    0x8(%ebp),%edx
80103c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103c71:	f6 c2 03             	test   $0x3,%dl
80103c74:	75 25                	jne    80103c9b <memset+0x38>
80103c76:	f6 c1 03             	test   $0x3,%cl
80103c79:	75 20                	jne    80103c9b <memset+0x38>
    c &= 0xFF;
80103c7b:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103c7e:	c1 e9 02             	shr    $0x2,%ecx
80103c81:	c1 e0 18             	shl    $0x18,%eax
80103c84:	89 fb                	mov    %edi,%ebx
80103c86:	c1 e3 10             	shl    $0x10,%ebx
80103c89:	09 d8                	or     %ebx,%eax
80103c8b:	89 fb                	mov    %edi,%ebx
80103c8d:	c1 e3 08             	shl    $0x8,%ebx
80103c90:	09 d8                	or     %ebx,%eax
80103c92:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103c94:	89 d7                	mov    %edx,%edi
80103c96:	fc                   	cld    
80103c97:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103c99:	eb 05                	jmp    80103ca0 <memset+0x3d>
  asm volatile("cld; rep stosb" :
80103c9b:	89 d7                	mov    %edx,%edi
80103c9d:	fc                   	cld    
80103c9e:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103ca0:	89 d0                	mov    %edx,%eax
80103ca2:	5b                   	pop    %ebx
80103ca3:	5f                   	pop    %edi
80103ca4:	5d                   	pop    %ebp
80103ca5:	c3                   	ret    

80103ca6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103ca6:	55                   	push   %ebp
80103ca7:	89 e5                	mov    %esp,%ebp
80103ca9:	56                   	push   %esi
80103caa:	53                   	push   %ebx
80103cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103cae:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103cb4:	eb 08                	jmp    80103cbe <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103cb6:	83 c1 01             	add    $0x1,%ecx
80103cb9:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103cbc:	89 f0                	mov    %esi,%eax
80103cbe:	8d 70 ff             	lea    -0x1(%eax),%esi
80103cc1:	85 c0                	test   %eax,%eax
80103cc3:	74 12                	je     80103cd7 <memcmp+0x31>
    if(*s1 != *s2)
80103cc5:	0f b6 01             	movzbl (%ecx),%eax
80103cc8:	0f b6 1a             	movzbl (%edx),%ebx
80103ccb:	38 d8                	cmp    %bl,%al
80103ccd:	74 e7                	je     80103cb6 <memcmp+0x10>
      return *s1 - *s2;
80103ccf:	0f b6 c0             	movzbl %al,%eax
80103cd2:	0f b6 db             	movzbl %bl,%ebx
80103cd5:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103cd7:	5b                   	pop    %ebx
80103cd8:	5e                   	pop    %esi
80103cd9:	5d                   	pop    %ebp
80103cda:	c3                   	ret    

80103cdb <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103cdb:	55                   	push   %ebp
80103cdc:	89 e5                	mov    %esp,%ebp
80103cde:	56                   	push   %esi
80103cdf:	53                   	push   %ebx
80103ce0:	8b 75 08             	mov    0x8(%ebp),%esi
80103ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ce6:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103ce9:	39 f2                	cmp    %esi,%edx
80103ceb:	73 3c                	jae    80103d29 <memmove+0x4e>
80103ced:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103cf0:	39 f1                	cmp    %esi,%ecx
80103cf2:	76 39                	jbe    80103d2d <memmove+0x52>
    s += n;
    d += n;
80103cf4:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103cf7:	eb 0d                	jmp    80103d06 <memmove+0x2b>
      *--d = *--s;
80103cf9:	83 e9 01             	sub    $0x1,%ecx
80103cfc:	83 ea 01             	sub    $0x1,%edx
80103cff:	0f b6 01             	movzbl (%ecx),%eax
80103d02:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103d04:	89 d8                	mov    %ebx,%eax
80103d06:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103d09:	85 c0                	test   %eax,%eax
80103d0b:	75 ec                	jne    80103cf9 <memmove+0x1e>
80103d0d:	eb 14                	jmp    80103d23 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103d0f:	0f b6 02             	movzbl (%edx),%eax
80103d12:	88 01                	mov    %al,(%ecx)
80103d14:	8d 49 01             	lea    0x1(%ecx),%ecx
80103d17:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103d1a:	89 d8                	mov    %ebx,%eax
80103d1c:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103d1f:	85 c0                	test   %eax,%eax
80103d21:	75 ec                	jne    80103d0f <memmove+0x34>

  return dst;
}
80103d23:	89 f0                	mov    %esi,%eax
80103d25:	5b                   	pop    %ebx
80103d26:	5e                   	pop    %esi
80103d27:	5d                   	pop    %ebp
80103d28:	c3                   	ret    
80103d29:	89 f1                	mov    %esi,%ecx
80103d2b:	eb ef                	jmp    80103d1c <memmove+0x41>
80103d2d:	89 f1                	mov    %esi,%ecx
80103d2f:	eb eb                	jmp    80103d1c <memmove+0x41>

80103d31 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103d31:	55                   	push   %ebp
80103d32:	89 e5                	mov    %esp,%ebp
80103d34:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103d37:	ff 75 10             	push   0x10(%ebp)
80103d3a:	ff 75 0c             	push   0xc(%ebp)
80103d3d:	ff 75 08             	push   0x8(%ebp)
80103d40:	e8 96 ff ff ff       	call   80103cdb <memmove>
}
80103d45:	c9                   	leave  
80103d46:	c3                   	ret    

80103d47 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103d47:	55                   	push   %ebp
80103d48:	89 e5                	mov    %esp,%ebp
80103d4a:	53                   	push   %ebx
80103d4b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d51:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103d54:	eb 09                	jmp    80103d5f <strncmp+0x18>
    n--, p++, q++;
80103d56:	83 e8 01             	sub    $0x1,%eax
80103d59:	83 c2 01             	add    $0x1,%edx
80103d5c:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103d5f:	85 c0                	test   %eax,%eax
80103d61:	74 0b                	je     80103d6e <strncmp+0x27>
80103d63:	0f b6 1a             	movzbl (%edx),%ebx
80103d66:	84 db                	test   %bl,%bl
80103d68:	74 04                	je     80103d6e <strncmp+0x27>
80103d6a:	3a 19                	cmp    (%ecx),%bl
80103d6c:	74 e8                	je     80103d56 <strncmp+0xf>
  if(n == 0)
80103d6e:	85 c0                	test   %eax,%eax
80103d70:	74 0d                	je     80103d7f <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
80103d72:	0f b6 02             	movzbl (%edx),%eax
80103d75:	0f b6 11             	movzbl (%ecx),%edx
80103d78:	29 d0                	sub    %edx,%eax
}
80103d7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d7d:	c9                   	leave  
80103d7e:	c3                   	ret    
    return 0;
80103d7f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d84:	eb f4                	jmp    80103d7a <strncmp+0x33>

80103d86 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103d86:	55                   	push   %ebp
80103d87:	89 e5                	mov    %esp,%ebp
80103d89:	57                   	push   %edi
80103d8a:	56                   	push   %esi
80103d8b:	53                   	push   %ebx
80103d8c:	8b 7d 08             	mov    0x8(%ebp),%edi
80103d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d92:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103d95:	89 fa                	mov    %edi,%edx
80103d97:	eb 04                	jmp    80103d9d <strncpy+0x17>
80103d99:	89 f1                	mov    %esi,%ecx
80103d9b:	89 da                	mov    %ebx,%edx
80103d9d:	89 c3                	mov    %eax,%ebx
80103d9f:	83 e8 01             	sub    $0x1,%eax
80103da2:	85 db                	test   %ebx,%ebx
80103da4:	7e 11                	jle    80103db7 <strncpy+0x31>
80103da6:	8d 71 01             	lea    0x1(%ecx),%esi
80103da9:	8d 5a 01             	lea    0x1(%edx),%ebx
80103dac:	0f b6 09             	movzbl (%ecx),%ecx
80103daf:	88 0a                	mov    %cl,(%edx)
80103db1:	84 c9                	test   %cl,%cl
80103db3:	75 e4                	jne    80103d99 <strncpy+0x13>
80103db5:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
80103db7:	8d 48 ff             	lea    -0x1(%eax),%ecx
80103dba:	85 c0                	test   %eax,%eax
80103dbc:	7e 0a                	jle    80103dc8 <strncpy+0x42>
    *s++ = 0;
80103dbe:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80103dc1:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
80103dc3:	8d 52 01             	lea    0x1(%edx),%edx
80103dc6:	eb ef                	jmp    80103db7 <strncpy+0x31>
  return os;
}
80103dc8:	89 f8                	mov    %edi,%eax
80103dca:	5b                   	pop    %ebx
80103dcb:	5e                   	pop    %esi
80103dcc:	5f                   	pop    %edi
80103dcd:	5d                   	pop    %ebp
80103dce:	c3                   	ret    

80103dcf <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103dcf:	55                   	push   %ebp
80103dd0:	89 e5                	mov    %esp,%ebp
80103dd2:	57                   	push   %edi
80103dd3:	56                   	push   %esi
80103dd4:	53                   	push   %ebx
80103dd5:	8b 7d 08             	mov    0x8(%ebp),%edi
80103dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80103dde:	85 c0                	test   %eax,%eax
80103de0:	7e 23                	jle    80103e05 <safestrcpy+0x36>
80103de2:	89 fa                	mov    %edi,%edx
80103de4:	eb 04                	jmp    80103dea <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103de6:	89 f1                	mov    %esi,%ecx
80103de8:	89 da                	mov    %ebx,%edx
80103dea:	83 e8 01             	sub    $0x1,%eax
80103ded:	85 c0                	test   %eax,%eax
80103def:	7e 11                	jle    80103e02 <safestrcpy+0x33>
80103df1:	8d 71 01             	lea    0x1(%ecx),%esi
80103df4:	8d 5a 01             	lea    0x1(%edx),%ebx
80103df7:	0f b6 09             	movzbl (%ecx),%ecx
80103dfa:	88 0a                	mov    %cl,(%edx)
80103dfc:	84 c9                	test   %cl,%cl
80103dfe:	75 e6                	jne    80103de6 <safestrcpy+0x17>
80103e00:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
80103e02:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80103e05:	89 f8                	mov    %edi,%eax
80103e07:	5b                   	pop    %ebx
80103e08:	5e                   	pop    %esi
80103e09:	5f                   	pop    %edi
80103e0a:	5d                   	pop    %ebp
80103e0b:	c3                   	ret    

80103e0c <strlen>:

int
strlen(const char *s)
{
80103e0c:	55                   	push   %ebp
80103e0d:	89 e5                	mov    %esp,%ebp
80103e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103e12:	b8 00 00 00 00       	mov    $0x0,%eax
80103e17:	eb 03                	jmp    80103e1c <strlen+0x10>
80103e19:	83 c0 01             	add    $0x1,%eax
80103e1c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103e20:	75 f7                	jne    80103e19 <strlen+0xd>
    ;
  return n;
}
80103e22:	5d                   	pop    %ebp
80103e23:	c3                   	ret    

80103e24 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103e24:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103e28:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103e2c:	55                   	push   %ebp
  pushl %ebx
80103e2d:	53                   	push   %ebx
  pushl %esi
80103e2e:	56                   	push   %esi
  pushl %edi
80103e2f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103e30:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103e32:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103e34:	5f                   	pop    %edi
  popl %esi
80103e35:	5e                   	pop    %esi
  popl %ebx
80103e36:	5b                   	pop    %ebx
  popl %ebp
80103e37:	5d                   	pop    %ebp
  ret
80103e38:	c3                   	ret    

80103e39 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103e39:	55                   	push   %ebp
80103e3a:	89 e5                	mov    %esp,%ebp
80103e3c:	53                   	push   %ebx
80103e3d:	83 ec 04             	sub    $0x4,%esp
80103e40:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103e43:	e8 d2 f3 ff ff       	call   8010321a <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103e48:	8b 00                	mov    (%eax),%eax
80103e4a:	39 d8                	cmp    %ebx,%eax
80103e4c:	76 18                	jbe    80103e66 <fetchint+0x2d>
80103e4e:	8d 53 04             	lea    0x4(%ebx),%edx
80103e51:	39 d0                	cmp    %edx,%eax
80103e53:	72 18                	jb     80103e6d <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
80103e55:	8b 13                	mov    (%ebx),%edx
80103e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5a:	89 10                	mov    %edx,(%eax)
  return 0;
80103e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e64:	c9                   	leave  
80103e65:	c3                   	ret    
    return -1;
80103e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e6b:	eb f4                	jmp    80103e61 <fetchint+0x28>
80103e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e72:	eb ed                	jmp    80103e61 <fetchint+0x28>

80103e74 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103e74:	55                   	push   %ebp
80103e75:	89 e5                	mov    %esp,%ebp
80103e77:	53                   	push   %ebx
80103e78:	83 ec 04             	sub    $0x4,%esp
80103e7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103e7e:	e8 97 f3 ff ff       	call   8010321a <myproc>

  if(addr >= curproc->sz)
80103e83:	39 18                	cmp    %ebx,(%eax)
80103e85:	76 25                	jbe    80103eac <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80103e87:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e8a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103e8c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103e8e:	89 d8                	mov    %ebx,%eax
80103e90:	eb 03                	jmp    80103e95 <fetchstr+0x21>
80103e92:	83 c0 01             	add    $0x1,%eax
80103e95:	39 d0                	cmp    %edx,%eax
80103e97:	73 09                	jae    80103ea2 <fetchstr+0x2e>
    if(*s == 0)
80103e99:	80 38 00             	cmpb   $0x0,(%eax)
80103e9c:	75 f4                	jne    80103e92 <fetchstr+0x1e>
      return s - *pp;
80103e9e:	29 d8                	sub    %ebx,%eax
80103ea0:	eb 05                	jmp    80103ea7 <fetchstr+0x33>
  }
  return -1;
80103ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ea7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eaa:	c9                   	leave  
80103eab:	c3                   	ret    
    return -1;
80103eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eb1:	eb f4                	jmp    80103ea7 <fetchstr+0x33>

80103eb3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103eb3:	55                   	push   %ebp
80103eb4:	89 e5                	mov    %esp,%ebp
80103eb6:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103eb9:	e8 5c f3 ff ff       	call   8010321a <myproc>
80103ebe:	8b 50 18             	mov    0x18(%eax),%edx
80103ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec4:	c1 e0 02             	shl    $0x2,%eax
80103ec7:	03 42 44             	add    0x44(%edx),%eax
80103eca:	83 ec 08             	sub    $0x8,%esp
80103ecd:	ff 75 0c             	push   0xc(%ebp)
80103ed0:	83 c0 04             	add    $0x4,%eax
80103ed3:	50                   	push   %eax
80103ed4:	e8 60 ff ff ff       	call   80103e39 <fetchint>
}
80103ed9:	c9                   	leave  
80103eda:	c3                   	ret    

80103edb <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103edb:	55                   	push   %ebp
80103edc:	89 e5                	mov    %esp,%ebp
80103ede:	56                   	push   %esi
80103edf:	53                   	push   %ebx
80103ee0:	83 ec 10             	sub    $0x10,%esp
80103ee3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103ee6:	e8 2f f3 ff ff       	call   8010321a <myproc>
80103eeb:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103eed:	83 ec 08             	sub    $0x8,%esp
80103ef0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103ef3:	50                   	push   %eax
80103ef4:	ff 75 08             	push   0x8(%ebp)
80103ef7:	e8 b7 ff ff ff       	call   80103eb3 <argint>
80103efc:	83 c4 10             	add    $0x10,%esp
80103eff:	85 c0                	test   %eax,%eax
80103f01:	78 24                	js     80103f27 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f03:	85 db                	test   %ebx,%ebx
80103f05:	78 27                	js     80103f2e <argptr+0x53>
80103f07:	8b 16                	mov    (%esi),%edx
80103f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0c:	39 c2                	cmp    %eax,%edx
80103f0e:	76 25                	jbe    80103f35 <argptr+0x5a>
80103f10:	01 c3                	add    %eax,%ebx
80103f12:	39 da                	cmp    %ebx,%edx
80103f14:	72 26                	jb     80103f3c <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f16:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f19:	89 02                	mov    %eax,(%edx)
  return 0;
80103f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f20:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f23:	5b                   	pop    %ebx
80103f24:	5e                   	pop    %esi
80103f25:	5d                   	pop    %ebp
80103f26:	c3                   	ret    
    return -1;
80103f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f2c:	eb f2                	jmp    80103f20 <argptr+0x45>
    return -1;
80103f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f33:	eb eb                	jmp    80103f20 <argptr+0x45>
80103f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3a:	eb e4                	jmp    80103f20 <argptr+0x45>
80103f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f41:	eb dd                	jmp    80103f20 <argptr+0x45>

80103f43 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103f43:	55                   	push   %ebp
80103f44:	89 e5                	mov    %esp,%ebp
80103f46:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f4c:	50                   	push   %eax
80103f4d:	ff 75 08             	push   0x8(%ebp)
80103f50:	e8 5e ff ff ff       	call   80103eb3 <argint>
80103f55:	83 c4 10             	add    $0x10,%esp
80103f58:	85 c0                	test   %eax,%eax
80103f5a:	78 13                	js     80103f6f <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103f5c:	83 ec 08             	sub    $0x8,%esp
80103f5f:	ff 75 0c             	push   0xc(%ebp)
80103f62:	ff 75 f4             	push   -0xc(%ebp)
80103f65:	e8 0a ff ff ff       	call   80103e74 <fetchstr>
80103f6a:	83 c4 10             	add    $0x10,%esp
}
80103f6d:	c9                   	leave  
80103f6e:	c3                   	ret    
    return -1;
80103f6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f74:	eb f7                	jmp    80103f6d <argstr+0x2a>

80103f76 <syscall>:

};

void
syscall(void)
{
80103f76:	55                   	push   %ebp
80103f77:	89 e5                	mov    %esp,%ebp
80103f79:	53                   	push   %ebx
80103f7a:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103f7d:	e8 98 f2 ff ff       	call   8010321a <myproc>
80103f82:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103f84:	8b 40 18             	mov    0x18(%eax),%eax
80103f87:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103f8a:	8d 50 ff             	lea    -0x1(%eax),%edx
80103f8d:	83 fa 1a             	cmp    $0x1a,%edx
80103f90:	77 17                	ja     80103fa9 <syscall+0x33>
80103f92:	8b 14 85 e0 6e 10 80 	mov    -0x7fef9120(,%eax,4),%edx
80103f99:	85 d2                	test   %edx,%edx
80103f9b:	74 0c                	je     80103fa9 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
80103f9d:	ff d2                	call   *%edx
80103f9f:	89 c2                	mov    %eax,%edx
80103fa1:	8b 43 18             	mov    0x18(%ebx),%eax
80103fa4:	89 50 1c             	mov    %edx,0x1c(%eax)
80103fa7:	eb 1f                	jmp    80103fc8 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80103fa9:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103fac:	50                   	push   %eax
80103fad:	52                   	push   %edx
80103fae:	ff 73 10             	push   0x10(%ebx)
80103fb1:	68 b5 6e 10 80       	push   $0x80106eb5
80103fb6:	e8 4c c6 ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
80103fbb:	8b 43 18             	mov    0x18(%ebx),%eax
80103fbe:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103fc5:	83 c4 10             	add    $0x10,%esp
  }
}
80103fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103fcb:	c9                   	leave  
80103fcc:	c3                   	ret    

80103fcd <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
80103fd0:	56                   	push   %esi
80103fd1:	53                   	push   %ebx
80103fd2:	83 ec 18             	sub    $0x18,%esp
80103fd5:	89 d6                	mov    %edx,%esi
80103fd7:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103fd9:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103fdc:	52                   	push   %edx
80103fdd:	50                   	push   %eax
80103fde:	e8 d0 fe ff ff       	call   80103eb3 <argint>
80103fe3:	83 c4 10             	add    $0x10,%esp
80103fe6:	85 c0                	test   %eax,%eax
80103fe8:	78 35                	js     8010401f <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80103fea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80103fee:	77 28                	ja     80104018 <argfd+0x4b>
80103ff0:	e8 25 f2 ff ff       	call   8010321a <myproc>
80103ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ff8:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80103ffc:	85 c0                	test   %eax,%eax
80103ffe:	74 18                	je     80104018 <argfd+0x4b>
    return -1;
  if(pfd)
80104000:	85 f6                	test   %esi,%esi
80104002:	74 02                	je     80104006 <argfd+0x39>
    *pfd = fd;
80104004:	89 16                	mov    %edx,(%esi)
  if(pf)
80104006:	85 db                	test   %ebx,%ebx
80104008:	74 1c                	je     80104026 <argfd+0x59>
    *pf = f;
8010400a:	89 03                	mov    %eax,(%ebx)
  return 0;
8010400c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104011:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104014:	5b                   	pop    %ebx
80104015:	5e                   	pop    %esi
80104016:	5d                   	pop    %ebp
80104017:	c3                   	ret    
    return -1;
80104018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010401d:	eb f2                	jmp    80104011 <argfd+0x44>
    return -1;
8010401f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104024:	eb eb                	jmp    80104011 <argfd+0x44>
  return 0;
80104026:	b8 00 00 00 00       	mov    $0x0,%eax
8010402b:	eb e4                	jmp    80104011 <argfd+0x44>

8010402d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010402d:	55                   	push   %ebp
8010402e:	89 e5                	mov    %esp,%ebp
80104030:	53                   	push   %ebx
80104031:	83 ec 04             	sub    $0x4,%esp
80104034:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104036:	e8 df f1 ff ff       	call   8010321a <myproc>
8010403b:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
8010403d:	b8 00 00 00 00       	mov    $0x0,%eax
80104042:	83 f8 0f             	cmp    $0xf,%eax
80104045:	7f 12                	jg     80104059 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
80104047:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
8010404c:	74 05                	je     80104053 <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
8010404e:	83 c0 01             	add    $0x1,%eax
80104051:	eb ef                	jmp    80104042 <fdalloc+0x15>
      curproc->ofile[fd] = f;
80104053:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
80104057:	eb 05                	jmp    8010405e <fdalloc+0x31>
    }
  }
  return -1;
80104059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010405e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104061:	c9                   	leave  
80104062:	c3                   	ret    

80104063 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104063:	55                   	push   %ebp
80104064:	89 e5                	mov    %esp,%ebp
80104066:	56                   	push   %esi
80104067:	53                   	push   %ebx
80104068:	83 ec 10             	sub    $0x10,%esp
8010406b:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010406d:	b8 20 00 00 00       	mov    $0x20,%eax
80104072:	89 c6                	mov    %eax,%esi
80104074:	39 43 58             	cmp    %eax,0x58(%ebx)
80104077:	76 2e                	jbe    801040a7 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104079:	6a 10                	push   $0x10
8010407b:	50                   	push   %eax
8010407c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010407f:	50                   	push   %eax
80104080:	53                   	push   %ebx
80104081:	e8 db d6 ff ff       	call   80101761 <readi>
80104086:	83 c4 10             	add    $0x10,%esp
80104089:	83 f8 10             	cmp    $0x10,%eax
8010408c:	75 0c                	jne    8010409a <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010408e:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104093:	75 1e                	jne    801040b3 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104095:	8d 46 10             	lea    0x10(%esi),%eax
80104098:	eb d8                	jmp    80104072 <isdirempty+0xf>
      panic("isdirempty: readi");
8010409a:	83 ec 0c             	sub    $0xc,%esp
8010409d:	68 50 6f 10 80       	push   $0x80106f50
801040a2:	e8 a1 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801040a7:	b8 01 00 00 00       	mov    $0x1,%eax
}
801040ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040af:	5b                   	pop    %ebx
801040b0:	5e                   	pop    %esi
801040b1:	5d                   	pop    %ebp
801040b2:	c3                   	ret    
      return 0;
801040b3:	b8 00 00 00 00       	mov    $0x0,%eax
801040b8:	eb f2                	jmp    801040ac <isdirempty+0x49>

801040ba <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801040ba:	55                   	push   %ebp
801040bb:	89 e5                	mov    %esp,%ebp
801040bd:	57                   	push   %edi
801040be:	56                   	push   %esi
801040bf:	53                   	push   %ebx
801040c0:	83 ec 34             	sub    $0x34,%esp
801040c3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801040c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801040c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801040cc:	8d 55 da             	lea    -0x26(%ebp),%edx
801040cf:	52                   	push   %edx
801040d0:	50                   	push   %eax
801040d1:	e8 0f db ff ff       	call   80101be5 <nameiparent>
801040d6:	89 c6                	mov    %eax,%esi
801040d8:	83 c4 10             	add    $0x10,%esp
801040db:	85 c0                	test   %eax,%eax
801040dd:	0f 84 33 01 00 00    	je     80104216 <create+0x15c>
    return 0;
  ilock(dp);
801040e3:	83 ec 0c             	sub    $0xc,%esp
801040e6:	50                   	push   %eax
801040e7:	e8 83 d4 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801040ec:	83 c4 0c             	add    $0xc,%esp
801040ef:	6a 00                	push   $0x0
801040f1:	8d 45 da             	lea    -0x26(%ebp),%eax
801040f4:	50                   	push   %eax
801040f5:	56                   	push   %esi
801040f6:	e8 a4 d8 ff ff       	call   8010199f <dirlookup>
801040fb:	89 c3                	mov    %eax,%ebx
801040fd:	83 c4 10             	add    $0x10,%esp
80104100:	85 c0                	test   %eax,%eax
80104102:	74 3d                	je     80104141 <create+0x87>
    iunlockput(dp);
80104104:	83 ec 0c             	sub    $0xc,%esp
80104107:	56                   	push   %esi
80104108:	e8 09 d6 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
8010410d:	89 1c 24             	mov    %ebx,(%esp)
80104110:	e8 5a d4 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104115:	83 c4 10             	add    $0x10,%esp
80104118:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010411d:	75 07                	jne    80104126 <create+0x6c>
8010411f:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104124:	74 11                	je     80104137 <create+0x7d>
      return ip;
    iunlockput(ip);
80104126:	83 ec 0c             	sub    $0xc,%esp
80104129:	53                   	push   %ebx
8010412a:	e8 e7 d5 ff ff       	call   80101716 <iunlockput>
    return 0;
8010412f:	83 c4 10             	add    $0x10,%esp
80104132:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104137:	89 d8                	mov    %ebx,%eax
80104139:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010413c:	5b                   	pop    %ebx
8010413d:	5e                   	pop    %esi
8010413e:	5f                   	pop    %edi
8010413f:	5d                   	pop    %ebp
80104140:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104141:	83 ec 08             	sub    $0x8,%esp
80104144:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104148:	50                   	push   %eax
80104149:	ff 36                	push   (%esi)
8010414b:	e8 1c d2 ff ff       	call   8010136c <ialloc>
80104150:	89 c3                	mov    %eax,%ebx
80104152:	83 c4 10             	add    $0x10,%esp
80104155:	85 c0                	test   %eax,%eax
80104157:	74 52                	je     801041ab <create+0xf1>
  ilock(ip);
80104159:	83 ec 0c             	sub    $0xc,%esp
8010415c:	50                   	push   %eax
8010415d:	e8 0d d4 ff ff       	call   8010156f <ilock>
  ip->major = major;
80104162:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104166:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010416a:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010416e:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104174:	89 1c 24             	mov    %ebx,(%esp)
80104177:	e8 92 d2 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010417c:	83 c4 10             	add    $0x10,%esp
8010417f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104184:	74 32                	je     801041b8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
80104186:	83 ec 04             	sub    $0x4,%esp
80104189:	ff 73 04             	push   0x4(%ebx)
8010418c:	8d 45 da             	lea    -0x26(%ebp),%eax
8010418f:	50                   	push   %eax
80104190:	56                   	push   %esi
80104191:	e8 86 d9 ff ff       	call   80101b1c <dirlink>
80104196:	83 c4 10             	add    $0x10,%esp
80104199:	85 c0                	test   %eax,%eax
8010419b:	78 6c                	js     80104209 <create+0x14f>
  iunlockput(dp);
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	56                   	push   %esi
801041a1:	e8 70 d5 ff ff       	call   80101716 <iunlockput>
  return ip;
801041a6:	83 c4 10             	add    $0x10,%esp
801041a9:	eb 8c                	jmp    80104137 <create+0x7d>
    panic("create: ialloc");
801041ab:	83 ec 0c             	sub    $0xc,%esp
801041ae:	68 62 6f 10 80       	push   $0x80106f62
801041b3:	e8 90 c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
801041b8:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801041bc:	83 c0 01             	add    $0x1,%eax
801041bf:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801041c3:	83 ec 0c             	sub    $0xc,%esp
801041c6:	56                   	push   %esi
801041c7:	e8 42 d2 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801041cc:	83 c4 0c             	add    $0xc,%esp
801041cf:	ff 73 04             	push   0x4(%ebx)
801041d2:	68 72 6f 10 80       	push   $0x80106f72
801041d7:	53                   	push   %ebx
801041d8:	e8 3f d9 ff ff       	call   80101b1c <dirlink>
801041dd:	83 c4 10             	add    $0x10,%esp
801041e0:	85 c0                	test   %eax,%eax
801041e2:	78 18                	js     801041fc <create+0x142>
801041e4:	83 ec 04             	sub    $0x4,%esp
801041e7:	ff 76 04             	push   0x4(%esi)
801041ea:	68 71 6f 10 80       	push   $0x80106f71
801041ef:	53                   	push   %ebx
801041f0:	e8 27 d9 ff ff       	call   80101b1c <dirlink>
801041f5:	83 c4 10             	add    $0x10,%esp
801041f8:	85 c0                	test   %eax,%eax
801041fa:	79 8a                	jns    80104186 <create+0xcc>
      panic("create dots");
801041fc:	83 ec 0c             	sub    $0xc,%esp
801041ff:	68 74 6f 10 80       	push   $0x80106f74
80104204:	e8 3f c1 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	68 80 6f 10 80       	push   $0x80106f80
80104211:	e8 32 c1 ff ff       	call   80100348 <panic>
    return 0;
80104216:	89 c3                	mov    %eax,%ebx
80104218:	e9 1a ff ff ff       	jmp    80104137 <create+0x7d>

8010421d <sys_settickets>:
int sys_settickets(void) {
8010421d:	55                   	push   %ebp
8010421e:	89 e5                	mov    %esp,%ebp
80104220:	83 ec 20             	sub    $0x20,%esp
  if(argint(0, &i) < 0){
80104223:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104226:	50                   	push   %eax
80104227:	6a 00                	push   $0x0
80104229:	e8 85 fc ff ff       	call   80103eb3 <argint>
8010422e:	83 c4 10             	add    $0x10,%esp
80104231:	85 c0                	test   %eax,%eax
80104233:	78 0f                	js     80104244 <sys_settickets+0x27>
  tickets = i;
80104235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104238:	a3 58 3c 11 80       	mov    %eax,0x80113c58
  return 0;
8010423d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104242:	c9                   	leave  
80104243:	c3                   	ret    
    return -1;
80104244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104249:	eb f7                	jmp    80104242 <sys_settickets+0x25>

8010424b <sys_getprocessesinfo>:
}
8010424b:	b8 00 00 00 00       	mov    $0x0,%eax
80104250:	c3                   	ret    

80104251 <sys_writecount>:
  w_count++;
80104251:	a1 5c 3c 11 80       	mov    0x80113c5c,%eax
80104256:	83 c0 01             	add    $0x1,%eax
80104259:	a3 5c 3c 11 80       	mov    %eax,0x80113c5c
}
8010425e:	c3                   	ret    

8010425f <sys_setwritecount>:
sys_setwritecount(void) {
8010425f:	55                   	push   %ebp
80104260:	89 e5                	mov    %esp,%ebp
80104262:	83 ec 20             	sub    $0x20,%esp
  if(argint(0, &i) < 0){
80104265:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104268:	50                   	push   %eax
80104269:	6a 00                	push   $0x0
8010426b:	e8 43 fc ff ff       	call   80103eb3 <argint>
80104270:	83 c4 10             	add    $0x10,%esp
80104273:	85 c0                	test   %eax,%eax
80104275:	78 0f                	js     80104286 <sys_setwritecount+0x27>
  w_count = i;
80104277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427a:	a3 5c 3c 11 80       	mov    %eax,0x80113c5c
  return 0;
8010427f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104284:	c9                   	leave  
80104285:	c3                   	ret    
    return -1;
80104286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428b:	eb f7                	jmp    80104284 <sys_setwritecount+0x25>

8010428d <sys_dup>:
{
8010428d:	55                   	push   %ebp
8010428e:	89 e5                	mov    %esp,%ebp
80104290:	53                   	push   %ebx
80104291:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104294:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104297:	ba 00 00 00 00       	mov    $0x0,%edx
8010429c:	b8 00 00 00 00       	mov    $0x0,%eax
801042a1:	e8 27 fd ff ff       	call   80103fcd <argfd>
801042a6:	85 c0                	test   %eax,%eax
801042a8:	78 23                	js     801042cd <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	e8 7b fd ff ff       	call   8010402d <fdalloc>
801042b2:	89 c3                	mov    %eax,%ebx
801042b4:	85 c0                	test   %eax,%eax
801042b6:	78 1c                	js     801042d4 <sys_dup+0x47>
  filedup(f);
801042b8:	83 ec 0c             	sub    $0xc,%esp
801042bb:	ff 75 f4             	push   -0xc(%ebp)
801042be:	e8 bb c9 ff ff       	call   80100c7e <filedup>
  return fd;
801042c3:	83 c4 10             	add    $0x10,%esp
}
801042c6:	89 d8                	mov    %ebx,%eax
801042c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042cb:	c9                   	leave  
801042cc:	c3                   	ret    
    return -1;
801042cd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042d2:	eb f2                	jmp    801042c6 <sys_dup+0x39>
    return -1;
801042d4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801042d9:	eb eb                	jmp    801042c6 <sys_dup+0x39>

801042db <sys_read>:
{
801042db:	55                   	push   %ebp
801042dc:	89 e5                	mov    %esp,%ebp
801042de:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801042e1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042e4:	ba 00 00 00 00       	mov    $0x0,%edx
801042e9:	b8 00 00 00 00       	mov    $0x0,%eax
801042ee:	e8 da fc ff ff       	call   80103fcd <argfd>
801042f3:	85 c0                	test   %eax,%eax
801042f5:	78 43                	js     8010433a <sys_read+0x5f>
801042f7:	83 ec 08             	sub    $0x8,%esp
801042fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801042fd:	50                   	push   %eax
801042fe:	6a 02                	push   $0x2
80104300:	e8 ae fb ff ff       	call   80103eb3 <argint>
80104305:	83 c4 10             	add    $0x10,%esp
80104308:	85 c0                	test   %eax,%eax
8010430a:	78 2e                	js     8010433a <sys_read+0x5f>
8010430c:	83 ec 04             	sub    $0x4,%esp
8010430f:	ff 75 f0             	push   -0x10(%ebp)
80104312:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104315:	50                   	push   %eax
80104316:	6a 01                	push   $0x1
80104318:	e8 be fb ff ff       	call   80103edb <argptr>
8010431d:	83 c4 10             	add    $0x10,%esp
80104320:	85 c0                	test   %eax,%eax
80104322:	78 16                	js     8010433a <sys_read+0x5f>
  return fileread(f, p, n);
80104324:	83 ec 04             	sub    $0x4,%esp
80104327:	ff 75 f0             	push   -0x10(%ebp)
8010432a:	ff 75 ec             	push   -0x14(%ebp)
8010432d:	ff 75 f4             	push   -0xc(%ebp)
80104330:	e8 9b ca ff ff       	call   80100dd0 <fileread>
80104335:	83 c4 10             	add    $0x10,%esp
}
80104338:	c9                   	leave  
80104339:	c3                   	ret    
    return -1;
8010433a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010433f:	eb f7                	jmp    80104338 <sys_read+0x5d>

80104341 <sys_write>:
{
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	83 ec 18             	sub    $0x18,%esp
  sys_writecount(); // ADDED THIS LINE
80104347:	e8 05 ff ff ff       	call   80104251 <sys_writecount>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010434c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010434f:	ba 00 00 00 00       	mov    $0x0,%edx
80104354:	b8 00 00 00 00       	mov    $0x0,%eax
80104359:	e8 6f fc ff ff       	call   80103fcd <argfd>
8010435e:	85 c0                	test   %eax,%eax
80104360:	78 43                	js     801043a5 <sys_write+0x64>
80104362:	83 ec 08             	sub    $0x8,%esp
80104365:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104368:	50                   	push   %eax
80104369:	6a 02                	push   $0x2
8010436b:	e8 43 fb ff ff       	call   80103eb3 <argint>
80104370:	83 c4 10             	add    $0x10,%esp
80104373:	85 c0                	test   %eax,%eax
80104375:	78 2e                	js     801043a5 <sys_write+0x64>
80104377:	83 ec 04             	sub    $0x4,%esp
8010437a:	ff 75 f0             	push   -0x10(%ebp)
8010437d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104380:	50                   	push   %eax
80104381:	6a 01                	push   $0x1
80104383:	e8 53 fb ff ff       	call   80103edb <argptr>
80104388:	83 c4 10             	add    $0x10,%esp
8010438b:	85 c0                	test   %eax,%eax
8010438d:	78 16                	js     801043a5 <sys_write+0x64>
  return filewrite(f, p, n);
8010438f:	83 ec 04             	sub    $0x4,%esp
80104392:	ff 75 f0             	push   -0x10(%ebp)
80104395:	ff 75 ec             	push   -0x14(%ebp)
80104398:	ff 75 f4             	push   -0xc(%ebp)
8010439b:	e8 b5 ca ff ff       	call   80100e55 <filewrite>
801043a0:	83 c4 10             	add    $0x10,%esp
}
801043a3:	c9                   	leave  
801043a4:	c3                   	ret    
    return -1;
801043a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043aa:	eb f7                	jmp    801043a3 <sys_write+0x62>

801043ac <sys_close>:
{
801043ac:	55                   	push   %ebp
801043ad:	89 e5                	mov    %esp,%ebp
801043af:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801043b2:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801043b5:	8d 55 f4             	lea    -0xc(%ebp),%edx
801043b8:	b8 00 00 00 00       	mov    $0x0,%eax
801043bd:	e8 0b fc ff ff       	call   80103fcd <argfd>
801043c2:	85 c0                	test   %eax,%eax
801043c4:	78 25                	js     801043eb <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801043c6:	e8 4f ee ff ff       	call   8010321a <myproc>
801043cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ce:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801043d5:	00 
  fileclose(f);
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	ff 75 f0             	push   -0x10(%ebp)
801043dc:	e8 e2 c8 ff ff       	call   80100cc3 <fileclose>
  return 0;
801043e1:	83 c4 10             	add    $0x10,%esp
801043e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043e9:	c9                   	leave  
801043ea:	c3                   	ret    
    return -1;
801043eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043f0:	eb f7                	jmp    801043e9 <sys_close+0x3d>

801043f2 <sys_fstat>:
{
801043f2:	55                   	push   %ebp
801043f3:	89 e5                	mov    %esp,%ebp
801043f5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801043f8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043fb:	ba 00 00 00 00       	mov    $0x0,%edx
80104400:	b8 00 00 00 00       	mov    $0x0,%eax
80104405:	e8 c3 fb ff ff       	call   80103fcd <argfd>
8010440a:	85 c0                	test   %eax,%eax
8010440c:	78 2a                	js     80104438 <sys_fstat+0x46>
8010440e:	83 ec 04             	sub    $0x4,%esp
80104411:	6a 14                	push   $0x14
80104413:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104416:	50                   	push   %eax
80104417:	6a 01                	push   $0x1
80104419:	e8 bd fa ff ff       	call   80103edb <argptr>
8010441e:	83 c4 10             	add    $0x10,%esp
80104421:	85 c0                	test   %eax,%eax
80104423:	78 13                	js     80104438 <sys_fstat+0x46>
  return filestat(f, st);
80104425:	83 ec 08             	sub    $0x8,%esp
80104428:	ff 75 f0             	push   -0x10(%ebp)
8010442b:	ff 75 f4             	push   -0xc(%ebp)
8010442e:	e8 56 c9 ff ff       	call   80100d89 <filestat>
80104433:	83 c4 10             	add    $0x10,%esp
}
80104436:	c9                   	leave  
80104437:	c3                   	ret    
    return -1;
80104438:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010443d:	eb f7                	jmp    80104436 <sys_fstat+0x44>

8010443f <sys_link>:
{
8010443f:	55                   	push   %ebp
80104440:	89 e5                	mov    %esp,%ebp
80104442:	56                   	push   %esi
80104443:	53                   	push   %ebx
80104444:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104447:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010444a:	50                   	push   %eax
8010444b:	6a 00                	push   $0x0
8010444d:	e8 f1 fa ff ff       	call   80103f43 <argstr>
80104452:	83 c4 10             	add    $0x10,%esp
80104455:	85 c0                	test   %eax,%eax
80104457:	0f 88 d3 00 00 00    	js     80104530 <sys_link+0xf1>
8010445d:	83 ec 08             	sub    $0x8,%esp
80104460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104463:	50                   	push   %eax
80104464:	6a 01                	push   $0x1
80104466:	e8 d8 fa ff ff       	call   80103f43 <argstr>
8010446b:	83 c4 10             	add    $0x10,%esp
8010446e:	85 c0                	test   %eax,%eax
80104470:	0f 88 ba 00 00 00    	js     80104530 <sys_link+0xf1>
  begin_op();
80104476:	e8 35 e3 ff ff       	call   801027b0 <begin_op>
  if((ip = namei(old)) == 0){
8010447b:	83 ec 0c             	sub    $0xc,%esp
8010447e:	ff 75 e0             	push   -0x20(%ebp)
80104481:	e8 47 d7 ff ff       	call   80101bcd <namei>
80104486:	89 c3                	mov    %eax,%ebx
80104488:	83 c4 10             	add    $0x10,%esp
8010448b:	85 c0                	test   %eax,%eax
8010448d:	0f 84 a4 00 00 00    	je     80104537 <sys_link+0xf8>
  ilock(ip);
80104493:	83 ec 0c             	sub    $0xc,%esp
80104496:	50                   	push   %eax
80104497:	e8 d3 d0 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
8010449c:	83 c4 10             	add    $0x10,%esp
8010449f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801044a4:	0f 84 99 00 00 00    	je     80104543 <sys_link+0x104>
  ip->nlink++;
801044aa:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801044ae:	83 c0 01             	add    $0x1,%eax
801044b1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044b5:	83 ec 0c             	sub    $0xc,%esp
801044b8:	53                   	push   %ebx
801044b9:	e8 50 cf ff ff       	call   8010140e <iupdate>
  iunlock(ip);
801044be:	89 1c 24             	mov    %ebx,(%esp)
801044c1:	e8 6b d1 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801044c6:	83 c4 08             	add    $0x8,%esp
801044c9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801044cc:	50                   	push   %eax
801044cd:	ff 75 e4             	push   -0x1c(%ebp)
801044d0:	e8 10 d7 ff ff       	call   80101be5 <nameiparent>
801044d5:	89 c6                	mov    %eax,%esi
801044d7:	83 c4 10             	add    $0x10,%esp
801044da:	85 c0                	test   %eax,%eax
801044dc:	0f 84 85 00 00 00    	je     80104567 <sys_link+0x128>
  ilock(dp);
801044e2:	83 ec 0c             	sub    $0xc,%esp
801044e5:	50                   	push   %eax
801044e6:	e8 84 d0 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801044eb:	83 c4 10             	add    $0x10,%esp
801044ee:	8b 03                	mov    (%ebx),%eax
801044f0:	39 06                	cmp    %eax,(%esi)
801044f2:	75 67                	jne    8010455b <sys_link+0x11c>
801044f4:	83 ec 04             	sub    $0x4,%esp
801044f7:	ff 73 04             	push   0x4(%ebx)
801044fa:	8d 45 ea             	lea    -0x16(%ebp),%eax
801044fd:	50                   	push   %eax
801044fe:	56                   	push   %esi
801044ff:	e8 18 d6 ff ff       	call   80101b1c <dirlink>
80104504:	83 c4 10             	add    $0x10,%esp
80104507:	85 c0                	test   %eax,%eax
80104509:	78 50                	js     8010455b <sys_link+0x11c>
  iunlockput(dp);
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	56                   	push   %esi
8010450f:	e8 02 d2 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104514:	89 1c 24             	mov    %ebx,(%esp)
80104517:	e8 5a d1 ff ff       	call   80101676 <iput>
  end_op();
8010451c:	e8 09 e3 ff ff       	call   8010282a <end_op>
  return 0;
80104521:	83 c4 10             	add    $0x10,%esp
80104524:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104529:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010452c:	5b                   	pop    %ebx
8010452d:	5e                   	pop    %esi
8010452e:	5d                   	pop    %ebp
8010452f:	c3                   	ret    
    return -1;
80104530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104535:	eb f2                	jmp    80104529 <sys_link+0xea>
    end_op();
80104537:	e8 ee e2 ff ff       	call   8010282a <end_op>
    return -1;
8010453c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104541:	eb e6                	jmp    80104529 <sys_link+0xea>
    iunlockput(ip);
80104543:	83 ec 0c             	sub    $0xc,%esp
80104546:	53                   	push   %ebx
80104547:	e8 ca d1 ff ff       	call   80101716 <iunlockput>
    end_op();
8010454c:	e8 d9 e2 ff ff       	call   8010282a <end_op>
    return -1;
80104551:	83 c4 10             	add    $0x10,%esp
80104554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104559:	eb ce                	jmp    80104529 <sys_link+0xea>
    iunlockput(dp);
8010455b:	83 ec 0c             	sub    $0xc,%esp
8010455e:	56                   	push   %esi
8010455f:	e8 b2 d1 ff ff       	call   80101716 <iunlockput>
    goto bad;
80104564:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104567:	83 ec 0c             	sub    $0xc,%esp
8010456a:	53                   	push   %ebx
8010456b:	e8 ff cf ff ff       	call   8010156f <ilock>
  ip->nlink--;
80104570:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104574:	83 e8 01             	sub    $0x1,%eax
80104577:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010457b:	89 1c 24             	mov    %ebx,(%esp)
8010457e:	e8 8b ce ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104583:	89 1c 24             	mov    %ebx,(%esp)
80104586:	e8 8b d1 ff ff       	call   80101716 <iunlockput>
  end_op();
8010458b:	e8 9a e2 ff ff       	call   8010282a <end_op>
  return -1;
80104590:	83 c4 10             	add    $0x10,%esp
80104593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104598:	eb 8f                	jmp    80104529 <sys_link+0xea>

8010459a <sys_unlink>:
{
8010459a:	55                   	push   %ebp
8010459b:	89 e5                	mov    %esp,%ebp
8010459d:	57                   	push   %edi
8010459e:	56                   	push   %esi
8010459f:	53                   	push   %ebx
801045a0:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801045a3:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045a6:	50                   	push   %eax
801045a7:	6a 00                	push   $0x0
801045a9:	e8 95 f9 ff ff       	call   80103f43 <argstr>
801045ae:	83 c4 10             	add    $0x10,%esp
801045b1:	85 c0                	test   %eax,%eax
801045b3:	0f 88 83 01 00 00    	js     8010473c <sys_unlink+0x1a2>
  begin_op();
801045b9:	e8 f2 e1 ff ff       	call   801027b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801045be:	83 ec 08             	sub    $0x8,%esp
801045c1:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045c4:	50                   	push   %eax
801045c5:	ff 75 c4             	push   -0x3c(%ebp)
801045c8:	e8 18 d6 ff ff       	call   80101be5 <nameiparent>
801045cd:	89 c6                	mov    %eax,%esi
801045cf:	83 c4 10             	add    $0x10,%esp
801045d2:	85 c0                	test   %eax,%eax
801045d4:	0f 84 ed 00 00 00    	je     801046c7 <sys_unlink+0x12d>
  ilock(dp);
801045da:	83 ec 0c             	sub    $0xc,%esp
801045dd:	50                   	push   %eax
801045de:	e8 8c cf ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801045e3:	83 c4 08             	add    $0x8,%esp
801045e6:	68 72 6f 10 80       	push   $0x80106f72
801045eb:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045ee:	50                   	push   %eax
801045ef:	e8 96 d3 ff ff       	call   8010198a <namecmp>
801045f4:	83 c4 10             	add    $0x10,%esp
801045f7:	85 c0                	test   %eax,%eax
801045f9:	0f 84 fc 00 00 00    	je     801046fb <sys_unlink+0x161>
801045ff:	83 ec 08             	sub    $0x8,%esp
80104602:	68 71 6f 10 80       	push   $0x80106f71
80104607:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010460a:	50                   	push   %eax
8010460b:	e8 7a d3 ff ff       	call   8010198a <namecmp>
80104610:	83 c4 10             	add    $0x10,%esp
80104613:	85 c0                	test   %eax,%eax
80104615:	0f 84 e0 00 00 00    	je     801046fb <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010461b:	83 ec 04             	sub    $0x4,%esp
8010461e:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104621:	50                   	push   %eax
80104622:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104625:	50                   	push   %eax
80104626:	56                   	push   %esi
80104627:	e8 73 d3 ff ff       	call   8010199f <dirlookup>
8010462c:	89 c3                	mov    %eax,%ebx
8010462e:	83 c4 10             	add    $0x10,%esp
80104631:	85 c0                	test   %eax,%eax
80104633:	0f 84 c2 00 00 00    	je     801046fb <sys_unlink+0x161>
  ilock(ip);
80104639:	83 ec 0c             	sub    $0xc,%esp
8010463c:	50                   	push   %eax
8010463d:	e8 2d cf ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
80104642:	83 c4 10             	add    $0x10,%esp
80104645:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010464a:	0f 8e 83 00 00 00    	jle    801046d3 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104650:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104655:	0f 84 85 00 00 00    	je     801046e0 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010465b:	83 ec 04             	sub    $0x4,%esp
8010465e:	6a 10                	push   $0x10
80104660:	6a 00                	push   $0x0
80104662:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104665:	57                   	push   %edi
80104666:	e8 f8 f5 ff ff       	call   80103c63 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010466b:	6a 10                	push   $0x10
8010466d:	ff 75 c0             	push   -0x40(%ebp)
80104670:	57                   	push   %edi
80104671:	56                   	push   %esi
80104672:	e8 e7 d1 ff ff       	call   8010185e <writei>
80104677:	83 c4 20             	add    $0x20,%esp
8010467a:	83 f8 10             	cmp    $0x10,%eax
8010467d:	0f 85 90 00 00 00    	jne    80104713 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104683:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104688:	0f 84 92 00 00 00    	je     80104720 <sys_unlink+0x186>
  iunlockput(dp);
8010468e:	83 ec 0c             	sub    $0xc,%esp
80104691:	56                   	push   %esi
80104692:	e8 7f d0 ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104697:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010469b:	83 e8 01             	sub    $0x1,%eax
8010469e:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046a2:	89 1c 24             	mov    %ebx,(%esp)
801046a5:	e8 64 cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801046aa:	89 1c 24             	mov    %ebx,(%esp)
801046ad:	e8 64 d0 ff ff       	call   80101716 <iunlockput>
  end_op();
801046b2:	e8 73 e1 ff ff       	call   8010282a <end_op>
  return 0;
801046b7:	83 c4 10             	add    $0x10,%esp
801046ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801046c2:	5b                   	pop    %ebx
801046c3:	5e                   	pop    %esi
801046c4:	5f                   	pop    %edi
801046c5:	5d                   	pop    %ebp
801046c6:	c3                   	ret    
    end_op();
801046c7:	e8 5e e1 ff ff       	call   8010282a <end_op>
    return -1;
801046cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d1:	eb ec                	jmp    801046bf <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801046d3:	83 ec 0c             	sub    $0xc,%esp
801046d6:	68 90 6f 10 80       	push   $0x80106f90
801046db:	e8 68 bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046e0:	89 d8                	mov    %ebx,%eax
801046e2:	e8 7c f9 ff ff       	call   80104063 <isdirempty>
801046e7:	85 c0                	test   %eax,%eax
801046e9:	0f 85 6c ff ff ff    	jne    8010465b <sys_unlink+0xc1>
    iunlockput(ip);
801046ef:	83 ec 0c             	sub    $0xc,%esp
801046f2:	53                   	push   %ebx
801046f3:	e8 1e d0 ff ff       	call   80101716 <iunlockput>
    goto bad;
801046f8:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801046fb:	83 ec 0c             	sub    $0xc,%esp
801046fe:	56                   	push   %esi
801046ff:	e8 12 d0 ff ff       	call   80101716 <iunlockput>
  end_op();
80104704:	e8 21 e1 ff ff       	call   8010282a <end_op>
  return -1;
80104709:	83 c4 10             	add    $0x10,%esp
8010470c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104711:	eb ac                	jmp    801046bf <sys_unlink+0x125>
    panic("unlink: writei");
80104713:	83 ec 0c             	sub    $0xc,%esp
80104716:	68 a2 6f 10 80       	push   $0x80106fa2
8010471b:	e8 28 bc ff ff       	call   80100348 <panic>
    dp->nlink--;
80104720:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104724:	83 e8 01             	sub    $0x1,%eax
80104727:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010472b:	83 ec 0c             	sub    $0xc,%esp
8010472e:	56                   	push   %esi
8010472f:	e8 da cc ff ff       	call   8010140e <iupdate>
80104734:	83 c4 10             	add    $0x10,%esp
80104737:	e9 52 ff ff ff       	jmp    8010468e <sys_unlink+0xf4>
    return -1;
8010473c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104741:	e9 79 ff ff ff       	jmp    801046bf <sys_unlink+0x125>

80104746 <sys_open>:

int
sys_open(void)
{
80104746:	55                   	push   %ebp
80104747:	89 e5                	mov    %esp,%ebp
80104749:	57                   	push   %edi
8010474a:	56                   	push   %esi
8010474b:	53                   	push   %ebx
8010474c:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010474f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104752:	50                   	push   %eax
80104753:	6a 00                	push   $0x0
80104755:	e8 e9 f7 ff ff       	call   80103f43 <argstr>
8010475a:	83 c4 10             	add    $0x10,%esp
8010475d:	85 c0                	test   %eax,%eax
8010475f:	0f 88 a0 00 00 00    	js     80104805 <sys_open+0xbf>
80104765:	83 ec 08             	sub    $0x8,%esp
80104768:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010476b:	50                   	push   %eax
8010476c:	6a 01                	push   $0x1
8010476e:	e8 40 f7 ff ff       	call   80103eb3 <argint>
80104773:	83 c4 10             	add    $0x10,%esp
80104776:	85 c0                	test   %eax,%eax
80104778:	0f 88 87 00 00 00    	js     80104805 <sys_open+0xbf>
    return -1;

  begin_op();
8010477e:	e8 2d e0 ff ff       	call   801027b0 <begin_op>

  if(omode & O_CREATE){
80104783:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104787:	0f 84 8b 00 00 00    	je     80104818 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
8010478d:	83 ec 0c             	sub    $0xc,%esp
80104790:	6a 00                	push   $0x0
80104792:	b9 00 00 00 00       	mov    $0x0,%ecx
80104797:	ba 02 00 00 00       	mov    $0x2,%edx
8010479c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010479f:	e8 16 f9 ff ff       	call   801040ba <create>
801047a4:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801047a6:	83 c4 10             	add    $0x10,%esp
801047a9:	85 c0                	test   %eax,%eax
801047ab:	74 5f                	je     8010480c <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801047ad:	e8 6b c4 ff ff       	call   80100c1d <filealloc>
801047b2:	89 c3                	mov    %eax,%ebx
801047b4:	85 c0                	test   %eax,%eax
801047b6:	0f 84 b5 00 00 00    	je     80104871 <sys_open+0x12b>
801047bc:	e8 6c f8 ff ff       	call   8010402d <fdalloc>
801047c1:	89 c7                	mov    %eax,%edi
801047c3:	85 c0                	test   %eax,%eax
801047c5:	0f 88 a6 00 00 00    	js     80104871 <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	56                   	push   %esi
801047cf:	e8 5d ce ff ff       	call   80101631 <iunlock>
  end_op();
801047d4:	e8 51 e0 ff ff       	call   8010282a <end_op>

  f->type = FD_INODE;
801047d9:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801047df:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801047e2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801047e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ec:	83 c4 10             	add    $0x10,%esp
801047ef:	a8 01                	test   $0x1,%al
801047f1:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801047f5:	a8 03                	test   $0x3,%al
801047f7:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
801047fb:	89 f8                	mov    %edi,%eax
801047fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104800:	5b                   	pop    %ebx
80104801:	5e                   	pop    %esi
80104802:	5f                   	pop    %edi
80104803:	5d                   	pop    %ebp
80104804:	c3                   	ret    
    return -1;
80104805:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010480a:	eb ef                	jmp    801047fb <sys_open+0xb5>
      end_op();
8010480c:	e8 19 e0 ff ff       	call   8010282a <end_op>
      return -1;
80104811:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104816:	eb e3                	jmp    801047fb <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104818:	83 ec 0c             	sub    $0xc,%esp
8010481b:	ff 75 e4             	push   -0x1c(%ebp)
8010481e:	e8 aa d3 ff ff       	call   80101bcd <namei>
80104823:	89 c6                	mov    %eax,%esi
80104825:	83 c4 10             	add    $0x10,%esp
80104828:	85 c0                	test   %eax,%eax
8010482a:	74 39                	je     80104865 <sys_open+0x11f>
    ilock(ip);
8010482c:	83 ec 0c             	sub    $0xc,%esp
8010482f:	50                   	push   %eax
80104830:	e8 3a cd ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104835:	83 c4 10             	add    $0x10,%esp
80104838:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010483d:	0f 85 6a ff ff ff    	jne    801047ad <sys_open+0x67>
80104843:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104847:	0f 84 60 ff ff ff    	je     801047ad <sys_open+0x67>
      iunlockput(ip);
8010484d:	83 ec 0c             	sub    $0xc,%esp
80104850:	56                   	push   %esi
80104851:	e8 c0 ce ff ff       	call   80101716 <iunlockput>
      end_op();
80104856:	e8 cf df ff ff       	call   8010282a <end_op>
      return -1;
8010485b:	83 c4 10             	add    $0x10,%esp
8010485e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104863:	eb 96                	jmp    801047fb <sys_open+0xb5>
      end_op();
80104865:	e8 c0 df ff ff       	call   8010282a <end_op>
      return -1;
8010486a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010486f:	eb 8a                	jmp    801047fb <sys_open+0xb5>
    if(f)
80104871:	85 db                	test   %ebx,%ebx
80104873:	74 0c                	je     80104881 <sys_open+0x13b>
      fileclose(f);
80104875:	83 ec 0c             	sub    $0xc,%esp
80104878:	53                   	push   %ebx
80104879:	e8 45 c4 ff ff       	call   80100cc3 <fileclose>
8010487e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104881:	83 ec 0c             	sub    $0xc,%esp
80104884:	56                   	push   %esi
80104885:	e8 8c ce ff ff       	call   80101716 <iunlockput>
    end_op();
8010488a:	e8 9b df ff ff       	call   8010282a <end_op>
    return -1;
8010488f:	83 c4 10             	add    $0x10,%esp
80104892:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104897:	e9 5f ff ff ff       	jmp    801047fb <sys_open+0xb5>

8010489c <sys_mkdir>:

int
sys_mkdir(void)
{
8010489c:	55                   	push   %ebp
8010489d:	89 e5                	mov    %esp,%ebp
8010489f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801048a2:	e8 09 df ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801048a7:	83 ec 08             	sub    $0x8,%esp
801048aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048ad:	50                   	push   %eax
801048ae:	6a 00                	push   $0x0
801048b0:	e8 8e f6 ff ff       	call   80103f43 <argstr>
801048b5:	83 c4 10             	add    $0x10,%esp
801048b8:	85 c0                	test   %eax,%eax
801048ba:	78 36                	js     801048f2 <sys_mkdir+0x56>
801048bc:	83 ec 0c             	sub    $0xc,%esp
801048bf:	6a 00                	push   $0x0
801048c1:	b9 00 00 00 00       	mov    $0x0,%ecx
801048c6:	ba 01 00 00 00       	mov    $0x1,%edx
801048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ce:	e8 e7 f7 ff ff       	call   801040ba <create>
801048d3:	83 c4 10             	add    $0x10,%esp
801048d6:	85 c0                	test   %eax,%eax
801048d8:	74 18                	je     801048f2 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
801048da:	83 ec 0c             	sub    $0xc,%esp
801048dd:	50                   	push   %eax
801048de:	e8 33 ce ff ff       	call   80101716 <iunlockput>
  end_op();
801048e3:	e8 42 df ff ff       	call   8010282a <end_op>
  return 0;
801048e8:	83 c4 10             	add    $0x10,%esp
801048eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048f0:	c9                   	leave  
801048f1:	c3                   	ret    
    end_op();
801048f2:	e8 33 df ff ff       	call   8010282a <end_op>
    return -1;
801048f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fc:	eb f2                	jmp    801048f0 <sys_mkdir+0x54>

801048fe <sys_mknod>:

int
sys_mknod(void)
{
801048fe:	55                   	push   %ebp
801048ff:	89 e5                	mov    %esp,%ebp
80104901:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104904:	e8 a7 de ff ff       	call   801027b0 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104909:	83 ec 08             	sub    $0x8,%esp
8010490c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010490f:	50                   	push   %eax
80104910:	6a 00                	push   $0x0
80104912:	e8 2c f6 ff ff       	call   80103f43 <argstr>
80104917:	83 c4 10             	add    $0x10,%esp
8010491a:	85 c0                	test   %eax,%eax
8010491c:	78 62                	js     80104980 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
8010491e:	83 ec 08             	sub    $0x8,%esp
80104921:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104924:	50                   	push   %eax
80104925:	6a 01                	push   $0x1
80104927:	e8 87 f5 ff ff       	call   80103eb3 <argint>
  if((argstr(0, &path)) < 0 ||
8010492c:	83 c4 10             	add    $0x10,%esp
8010492f:	85 c0                	test   %eax,%eax
80104931:	78 4d                	js     80104980 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104933:	83 ec 08             	sub    $0x8,%esp
80104936:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104939:	50                   	push   %eax
8010493a:	6a 02                	push   $0x2
8010493c:	e8 72 f5 ff ff       	call   80103eb3 <argint>
     argint(1, &major) < 0 ||
80104941:	83 c4 10             	add    $0x10,%esp
80104944:	85 c0                	test   %eax,%eax
80104946:	78 38                	js     80104980 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104948:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
8010494c:	83 ec 0c             	sub    $0xc,%esp
8010494f:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104953:	50                   	push   %eax
80104954:	ba 03 00 00 00       	mov    $0x3,%edx
80104959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495c:	e8 59 f7 ff ff       	call   801040ba <create>
     argint(2, &minor) < 0 ||
80104961:	83 c4 10             	add    $0x10,%esp
80104964:	85 c0                	test   %eax,%eax
80104966:	74 18                	je     80104980 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104968:	83 ec 0c             	sub    $0xc,%esp
8010496b:	50                   	push   %eax
8010496c:	e8 a5 cd ff ff       	call   80101716 <iunlockput>
  end_op();
80104971:	e8 b4 de ff ff       	call   8010282a <end_op>
  return 0;
80104976:	83 c4 10             	add    $0x10,%esp
80104979:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010497e:	c9                   	leave  
8010497f:	c3                   	ret    
    end_op();
80104980:	e8 a5 de ff ff       	call   8010282a <end_op>
    return -1;
80104985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010498a:	eb f2                	jmp    8010497e <sys_mknod+0x80>

8010498c <sys_chdir>:

int
sys_chdir(void)
{
8010498c:	55                   	push   %ebp
8010498d:	89 e5                	mov    %esp,%ebp
8010498f:	56                   	push   %esi
80104990:	53                   	push   %ebx
80104991:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104994:	e8 81 e8 ff ff       	call   8010321a <myproc>
80104999:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010499b:	e8 10 de ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801049a0:	83 ec 08             	sub    $0x8,%esp
801049a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049a6:	50                   	push   %eax
801049a7:	6a 00                	push   $0x0
801049a9:	e8 95 f5 ff ff       	call   80103f43 <argstr>
801049ae:	83 c4 10             	add    $0x10,%esp
801049b1:	85 c0                	test   %eax,%eax
801049b3:	78 52                	js     80104a07 <sys_chdir+0x7b>
801049b5:	83 ec 0c             	sub    $0xc,%esp
801049b8:	ff 75 f4             	push   -0xc(%ebp)
801049bb:	e8 0d d2 ff ff       	call   80101bcd <namei>
801049c0:	89 c3                	mov    %eax,%ebx
801049c2:	83 c4 10             	add    $0x10,%esp
801049c5:	85 c0                	test   %eax,%eax
801049c7:	74 3e                	je     80104a07 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	50                   	push   %eax
801049cd:	e8 9d cb ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
801049d2:	83 c4 10             	add    $0x10,%esp
801049d5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801049da:	75 37                	jne    80104a13 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049dc:	83 ec 0c             	sub    $0xc,%esp
801049df:	53                   	push   %ebx
801049e0:	e8 4c cc ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
801049e5:	83 c4 04             	add    $0x4,%esp
801049e8:	ff 76 68             	push   0x68(%esi)
801049eb:	e8 86 cc ff ff       	call   80101676 <iput>
  end_op();
801049f0:	e8 35 de ff ff       	call   8010282a <end_op>
  curproc->cwd = ip;
801049f5:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
801049f8:	83 c4 10             	add    $0x10,%esp
801049fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a03:	5b                   	pop    %ebx
80104a04:	5e                   	pop    %esi
80104a05:	5d                   	pop    %ebp
80104a06:	c3                   	ret    
    end_op();
80104a07:	e8 1e de ff ff       	call   8010282a <end_op>
    return -1;
80104a0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a11:	eb ed                	jmp    80104a00 <sys_chdir+0x74>
    iunlockput(ip);
80104a13:	83 ec 0c             	sub    $0xc,%esp
80104a16:	53                   	push   %ebx
80104a17:	e8 fa cc ff ff       	call   80101716 <iunlockput>
    end_op();
80104a1c:	e8 09 de ff ff       	call   8010282a <end_op>
    return -1;
80104a21:	83 c4 10             	add    $0x10,%esp
80104a24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a29:	eb d5                	jmp    80104a00 <sys_chdir+0x74>

80104a2b <sys_exec>:

int
sys_exec(void)
{
80104a2b:	55                   	push   %ebp
80104a2c:	89 e5                	mov    %esp,%ebp
80104a2e:	53                   	push   %ebx
80104a2f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a35:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a38:	50                   	push   %eax
80104a39:	6a 00                	push   $0x0
80104a3b:	e8 03 f5 ff ff       	call   80103f43 <argstr>
80104a40:	83 c4 10             	add    $0x10,%esp
80104a43:	85 c0                	test   %eax,%eax
80104a45:	78 38                	js     80104a7f <sys_exec+0x54>
80104a47:	83 ec 08             	sub    $0x8,%esp
80104a4a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104a50:	50                   	push   %eax
80104a51:	6a 01                	push   $0x1
80104a53:	e8 5b f4 ff ff       	call   80103eb3 <argint>
80104a58:	83 c4 10             	add    $0x10,%esp
80104a5b:	85 c0                	test   %eax,%eax
80104a5d:	78 20                	js     80104a7f <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104a5f:	83 ec 04             	sub    $0x4,%esp
80104a62:	68 80 00 00 00       	push   $0x80
80104a67:	6a 00                	push   $0x0
80104a69:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104a6f:	50                   	push   %eax
80104a70:	e8 ee f1 ff ff       	call   80103c63 <memset>
80104a75:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104a78:	bb 00 00 00 00       	mov    $0x0,%ebx
80104a7d:	eb 2c                	jmp    80104aab <sys_exec+0x80>
    return -1;
80104a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a84:	eb 78                	jmp    80104afe <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104a86:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104a8d:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104a91:	83 ec 08             	sub    $0x8,%esp
80104a94:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104a9a:	50                   	push   %eax
80104a9b:	ff 75 f4             	push   -0xc(%ebp)
80104a9e:	e8 2b be ff ff       	call   801008ce <exec>
80104aa3:	83 c4 10             	add    $0x10,%esp
80104aa6:	eb 56                	jmp    80104afe <sys_exec+0xd3>
  for(i=0;; i++){
80104aa8:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104aab:	83 fb 1f             	cmp    $0x1f,%ebx
80104aae:	77 49                	ja     80104af9 <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104ab0:	83 ec 08             	sub    $0x8,%esp
80104ab3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104ab9:	50                   	push   %eax
80104aba:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104ac0:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104ac3:	50                   	push   %eax
80104ac4:	e8 70 f3 ff ff       	call   80103e39 <fetchint>
80104ac9:	83 c4 10             	add    $0x10,%esp
80104acc:	85 c0                	test   %eax,%eax
80104ace:	78 33                	js     80104b03 <sys_exec+0xd8>
    if(uarg == 0){
80104ad0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104ad6:	85 c0                	test   %eax,%eax
80104ad8:	74 ac                	je     80104a86 <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104ada:	83 ec 08             	sub    $0x8,%esp
80104add:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104ae4:	52                   	push   %edx
80104ae5:	50                   	push   %eax
80104ae6:	e8 89 f3 ff ff       	call   80103e74 <fetchstr>
80104aeb:	83 c4 10             	add    $0x10,%esp
80104aee:	85 c0                	test   %eax,%eax
80104af0:	79 b6                	jns    80104aa8 <sys_exec+0x7d>
      return -1;
80104af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af7:	eb 05                	jmp    80104afe <sys_exec+0xd3>
      return -1;
80104af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104afe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b01:	c9                   	leave  
80104b02:	c3                   	ret    
      return -1;
80104b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b08:	eb f4                	jmp    80104afe <sys_exec+0xd3>

80104b0a <sys_pipe>:

int
sys_pipe(void)
{
80104b0a:	55                   	push   %ebp
80104b0b:	89 e5                	mov    %esp,%ebp
80104b0d:	53                   	push   %ebx
80104b0e:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b11:	6a 08                	push   $0x8
80104b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b16:	50                   	push   %eax
80104b17:	6a 00                	push   $0x0
80104b19:	e8 bd f3 ff ff       	call   80103edb <argptr>
80104b1e:	83 c4 10             	add    $0x10,%esp
80104b21:	85 c0                	test   %eax,%eax
80104b23:	78 79                	js     80104b9e <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b25:	83 ec 08             	sub    $0x8,%esp
80104b28:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b2b:	50                   	push   %eax
80104b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b2f:	50                   	push   %eax
80104b30:	e8 37 e2 ff ff       	call   80102d6c <pipealloc>
80104b35:	83 c4 10             	add    $0x10,%esp
80104b38:	85 c0                	test   %eax,%eax
80104b3a:	78 69                	js     80104ba5 <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b3f:	e8 e9 f4 ff ff       	call   8010402d <fdalloc>
80104b44:	89 c3                	mov    %eax,%ebx
80104b46:	85 c0                	test   %eax,%eax
80104b48:	78 21                	js     80104b6b <sys_pipe+0x61>
80104b4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b4d:	e8 db f4 ff ff       	call   8010402d <fdalloc>
80104b52:	85 c0                	test   %eax,%eax
80104b54:	78 15                	js     80104b6b <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b59:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b5e:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104b61:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b69:	c9                   	leave  
80104b6a:	c3                   	ret    
    if(fd0 >= 0)
80104b6b:	85 db                	test   %ebx,%ebx
80104b6d:	79 20                	jns    80104b8f <sys_pipe+0x85>
    fileclose(rf);
80104b6f:	83 ec 0c             	sub    $0xc,%esp
80104b72:	ff 75 f0             	push   -0x10(%ebp)
80104b75:	e8 49 c1 ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
80104b7a:	83 c4 04             	add    $0x4,%esp
80104b7d:	ff 75 ec             	push   -0x14(%ebp)
80104b80:	e8 3e c1 ff ff       	call   80100cc3 <fileclose>
    return -1;
80104b85:	83 c4 10             	add    $0x10,%esp
80104b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b8d:	eb d7                	jmp    80104b66 <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104b8f:	e8 86 e6 ff ff       	call   8010321a <myproc>
80104b94:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104b9b:	00 
80104b9c:	eb d1                	jmp    80104b6f <sys_pipe+0x65>
    return -1;
80104b9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba3:	eb c1                	jmp    80104b66 <sys_pipe+0x5c>
    return -1;
80104ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104baa:	eb ba                	jmp    80104b66 <sys_pipe+0x5c>

80104bac <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104bac:	55                   	push   %ebp
80104bad:	89 e5                	mov    %esp,%ebp
80104baf:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104bb2:	e8 d9 e7 ff ff       	call   80103390 <fork>
}
80104bb7:	c9                   	leave  
80104bb8:	c3                   	ret    

80104bb9 <sys_exit>:

int
sys_exit(void)
{
80104bb9:	55                   	push   %ebp
80104bba:	89 e5                	mov    %esp,%ebp
80104bbc:	83 ec 08             	sub    $0x8,%esp
  exit();
80104bbf:	e8 00 ea ff ff       	call   801035c4 <exit>
  return 0;  // not reached
}
80104bc4:	b8 00 00 00 00       	mov    $0x0,%eax
80104bc9:	c9                   	leave  
80104bca:	c3                   	ret    

80104bcb <sys_wait>:

int
sys_wait(void)
{
80104bcb:	55                   	push   %ebp
80104bcc:	89 e5                	mov    %esp,%ebp
80104bce:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104bd1:	e8 77 eb ff ff       	call   8010374d <wait>
}
80104bd6:	c9                   	leave  
80104bd7:	c3                   	ret    

80104bd8 <sys_kill>:

int
sys_kill(void)
{
80104bd8:	55                   	push   %ebp
80104bd9:	89 e5                	mov    %esp,%ebp
80104bdb:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104be1:	50                   	push   %eax
80104be2:	6a 00                	push   $0x0
80104be4:	e8 ca f2 ff ff       	call   80103eb3 <argint>
80104be9:	83 c4 10             	add    $0x10,%esp
80104bec:	85 c0                	test   %eax,%eax
80104bee:	78 10                	js     80104c00 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104bf0:	83 ec 0c             	sub    $0xc,%esp
80104bf3:	ff 75 f4             	push   -0xc(%ebp)
80104bf6:	e8 4f ec ff ff       	call   8010384a <kill>
80104bfb:	83 c4 10             	add    $0x10,%esp
}
80104bfe:	c9                   	leave  
80104bff:	c3                   	ret    
    return -1;
80104c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c05:	eb f7                	jmp    80104bfe <sys_kill+0x26>

80104c07 <sys_getpid>:

int
sys_getpid(void)
{
80104c07:	55                   	push   %ebp
80104c08:	89 e5                	mov    %esp,%ebp
80104c0a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c0d:	e8 08 e6 ff ff       	call   8010321a <myproc>
80104c12:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <sys_sbrk>:

int
sys_sbrk(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	53                   	push   %ebx
80104c1b:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c21:	50                   	push   %eax
80104c22:	6a 00                	push   $0x0
80104c24:	e8 8a f2 ff ff       	call   80103eb3 <argint>
80104c29:	83 c4 10             	add    $0x10,%esp
80104c2c:	85 c0                	test   %eax,%eax
80104c2e:	78 20                	js     80104c50 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
80104c30:	e8 e5 e5 ff ff       	call   8010321a <myproc>
80104c35:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104c37:	83 ec 0c             	sub    $0xc,%esp
80104c3a:	ff 75 f4             	push   -0xc(%ebp)
80104c3d:	e8 e3 e6 ff ff       	call   80103325 <growproc>
80104c42:	83 c4 10             	add    $0x10,%esp
80104c45:	85 c0                	test   %eax,%eax
80104c47:	78 0e                	js     80104c57 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80104c49:	89 d8                	mov    %ebx,%eax
80104c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c4e:	c9                   	leave  
80104c4f:	c3                   	ret    
    return -1;
80104c50:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c55:	eb f2                	jmp    80104c49 <sys_sbrk+0x32>
    return -1;
80104c57:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c5c:	eb eb                	jmp    80104c49 <sys_sbrk+0x32>

80104c5e <sys_sleep>:

int
sys_sleep(void)
{
80104c5e:	55                   	push   %ebp
80104c5f:	89 e5                	mov    %esp,%ebp
80104c61:	53                   	push   %ebx
80104c62:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c68:	50                   	push   %eax
80104c69:	6a 00                	push   $0x0
80104c6b:	e8 43 f2 ff ff       	call   80103eb3 <argint>
80104c70:	83 c4 10             	add    $0x10,%esp
80104c73:	85 c0                	test   %eax,%eax
80104c75:	78 75                	js     80104cec <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c77:	83 ec 0c             	sub    $0xc,%esp
80104c7a:	68 80 3c 11 80       	push   $0x80113c80
80104c7f:	e8 33 ef ff ff       	call   80103bb7 <acquire>
  ticks0 = ticks;
80104c84:	8b 1d 60 3c 11 80    	mov    0x80113c60,%ebx
  while(ticks - ticks0 < n){
80104c8a:	83 c4 10             	add    $0x10,%esp
80104c8d:	a1 60 3c 11 80       	mov    0x80113c60,%eax
80104c92:	29 d8                	sub    %ebx,%eax
80104c94:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c97:	73 39                	jae    80104cd2 <sys_sleep+0x74>
    if(myproc()->killed){
80104c99:	e8 7c e5 ff ff       	call   8010321a <myproc>
80104c9e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ca2:	75 17                	jne    80104cbb <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104ca4:	83 ec 08             	sub    $0x8,%esp
80104ca7:	68 80 3c 11 80       	push   $0x80113c80
80104cac:	68 60 3c 11 80       	push   $0x80113c60
80104cb1:	e8 06 ea ff ff       	call   801036bc <sleep>
80104cb6:	83 c4 10             	add    $0x10,%esp
80104cb9:	eb d2                	jmp    80104c8d <sys_sleep+0x2f>
      release(&tickslock);
80104cbb:	83 ec 0c             	sub    $0xc,%esp
80104cbe:	68 80 3c 11 80       	push   $0x80113c80
80104cc3:	e8 54 ef ff ff       	call   80103c1c <release>
      return -1;
80104cc8:	83 c4 10             	add    $0x10,%esp
80104ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd0:	eb 15                	jmp    80104ce7 <sys_sleep+0x89>
  }
  release(&tickslock);
80104cd2:	83 ec 0c             	sub    $0xc,%esp
80104cd5:	68 80 3c 11 80       	push   $0x80113c80
80104cda:	e8 3d ef ff ff       	call   80103c1c <release>
  return 0;
80104cdf:	83 c4 10             	add    $0x10,%esp
80104ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cea:	c9                   	leave  
80104ceb:	c3                   	ret    
    return -1;
80104cec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf1:	eb f4                	jmp    80104ce7 <sys_sleep+0x89>

80104cf3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104cf3:	55                   	push   %ebp
80104cf4:	89 e5                	mov    %esp,%ebp
80104cf6:	53                   	push   %ebx
80104cf7:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104cfa:	68 80 3c 11 80       	push   $0x80113c80
80104cff:	e8 b3 ee ff ff       	call   80103bb7 <acquire>
  xticks = ticks;
80104d04:	8b 1d 60 3c 11 80    	mov    0x80113c60,%ebx
  release(&tickslock);
80104d0a:	c7 04 24 80 3c 11 80 	movl   $0x80113c80,(%esp)
80104d11:	e8 06 ef ff ff       	call   80103c1c <release>
  return xticks;
}
80104d16:	89 d8                	mov    %ebx,%eax
80104d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d1b:	c9                   	leave  
80104d1c:	c3                   	ret    

80104d1d <sys_yield>:

int
sys_yield(void)
{
80104d1d:	55                   	push   %ebp
80104d1e:	89 e5                	mov    %esp,%ebp
80104d20:	83 ec 08             	sub    $0x8,%esp
  yield();
80104d23:	e8 62 e9 ff ff       	call   8010368a <yield>
  return 0;
}
80104d28:	b8 00 00 00 00       	mov    $0x0,%eax
80104d2d:	c9                   	leave  
80104d2e:	c3                   	ret    

80104d2f <sys_shutdown>:

int sys_shutdown(void)
{
80104d2f:	55                   	push   %ebp
80104d30:	89 e5                	mov    %esp,%ebp
80104d32:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104d35:	e8 c1 d4 ff ff       	call   801021fb <shutdown>
  return 0;
}
80104d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80104d3f:	c9                   	leave  
80104d40:	c3                   	ret    

80104d41 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104d41:	1e                   	push   %ds
  pushl %es
80104d42:	06                   	push   %es
  pushl %fs
80104d43:	0f a0                	push   %fs
  pushl %gs
80104d45:	0f a8                	push   %gs
  pushal
80104d47:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104d48:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104d4c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104d4e:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104d50:	54                   	push   %esp
  call trap
80104d51:	e8 37 01 00 00       	call   80104e8d <trap>
  addl $4, %esp
80104d56:	83 c4 04             	add    $0x4,%esp

80104d59 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104d59:	61                   	popa   
  popl %gs
80104d5a:	0f a9                	pop    %gs
  popl %fs
80104d5c:	0f a1                	pop    %fs
  popl %es
80104d5e:	07                   	pop    %es
  popl %ds
80104d5f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104d60:	83 c4 08             	add    $0x8,%esp
  iret
80104d63:	cf                   	iret   

80104d64 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
80104d67:	53                   	push   %ebx
80104d68:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104d6b:	b8 00 00 00 00       	mov    $0x0,%eax
80104d70:	eb 76                	jmp    80104de8 <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104d72:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104d79:	66 89 0c c5 c0 3c 11 	mov    %cx,-0x7feec340(,%eax,8)
80104d80:	80 
80104d81:	66 c7 04 c5 c2 3c 11 	movw   $0x8,-0x7feec33e(,%eax,8)
80104d88:	80 08 00 
80104d8b:	0f b6 14 c5 c4 3c 11 	movzbl -0x7feec33c(,%eax,8),%edx
80104d92:	80 
80104d93:	83 e2 e0             	and    $0xffffffe0,%edx
80104d96:	88 14 c5 c4 3c 11 80 	mov    %dl,-0x7feec33c(,%eax,8)
80104d9d:	c6 04 c5 c4 3c 11 80 	movb   $0x0,-0x7feec33c(,%eax,8)
80104da4:	00 
80104da5:	0f b6 14 c5 c5 3c 11 	movzbl -0x7feec33b(,%eax,8),%edx
80104dac:	80 
80104dad:	83 e2 f0             	and    $0xfffffff0,%edx
80104db0:	83 ca 0e             	or     $0xe,%edx
80104db3:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104dba:	89 d3                	mov    %edx,%ebx
80104dbc:	83 e3 ef             	and    $0xffffffef,%ebx
80104dbf:	88 1c c5 c5 3c 11 80 	mov    %bl,-0x7feec33b(,%eax,8)
80104dc6:	83 e2 8f             	and    $0xffffff8f,%edx
80104dc9:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104dd0:	83 ca 80             	or     $0xffffff80,%edx
80104dd3:	88 14 c5 c5 3c 11 80 	mov    %dl,-0x7feec33b(,%eax,8)
80104dda:	c1 e9 10             	shr    $0x10,%ecx
80104ddd:	66 89 0c c5 c6 3c 11 	mov    %cx,-0x7feec33a(,%eax,8)
80104de4:	80 
  for(i = 0; i < 256; i++)
80104de5:	83 c0 01             	add    $0x1,%eax
80104de8:	3d ff 00 00 00       	cmp    $0xff,%eax
80104ded:	7e 83                	jle    80104d72 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104def:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104df5:	66 89 15 c0 3e 11 80 	mov    %dx,0x80113ec0
80104dfc:	66 c7 05 c2 3e 11 80 	movw   $0x8,0x80113ec2
80104e03:	08 00 
80104e05:	0f b6 05 c4 3e 11 80 	movzbl 0x80113ec4,%eax
80104e0c:	83 e0 e0             	and    $0xffffffe0,%eax
80104e0f:	a2 c4 3e 11 80       	mov    %al,0x80113ec4
80104e14:	c6 05 c4 3e 11 80 00 	movb   $0x0,0x80113ec4
80104e1b:	0f b6 05 c5 3e 11 80 	movzbl 0x80113ec5,%eax
80104e22:	83 c8 0f             	or     $0xf,%eax
80104e25:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
80104e2a:	83 e0 ef             	and    $0xffffffef,%eax
80104e2d:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
80104e32:	89 c1                	mov    %eax,%ecx
80104e34:	83 c9 60             	or     $0x60,%ecx
80104e37:	88 0d c5 3e 11 80    	mov    %cl,0x80113ec5
80104e3d:	83 c8 e0             	or     $0xffffffe0,%eax
80104e40:	a2 c5 3e 11 80       	mov    %al,0x80113ec5
80104e45:	c1 ea 10             	shr    $0x10,%edx
80104e48:	66 89 15 c6 3e 11 80 	mov    %dx,0x80113ec6

  initlock(&tickslock, "time");
80104e4f:	83 ec 08             	sub    $0x8,%esp
80104e52:	68 b1 6f 10 80       	push   $0x80106fb1
80104e57:	68 80 3c 11 80       	push   $0x80113c80
80104e5c:	e8 1a ec ff ff       	call   80103a7b <initlock>
}
80104e61:	83 c4 10             	add    $0x10,%esp
80104e64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e67:	c9                   	leave  
80104e68:	c3                   	ret    

80104e69 <idtinit>:

void
idtinit(void)
{
80104e69:	55                   	push   %ebp
80104e6a:	89 e5                	mov    %esp,%ebp
80104e6c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e6f:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e75:	b8 c0 3c 11 80       	mov    $0x80113cc0,%eax
80104e7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e7e:	c1 e8 10             	shr    $0x10,%eax
80104e81:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e85:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e88:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e8b:	c9                   	leave  
80104e8c:	c3                   	ret    

80104e8d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e8d:	55                   	push   %ebp
80104e8e:	89 e5                	mov    %esp,%ebp
80104e90:	57                   	push   %edi
80104e91:	56                   	push   %esi
80104e92:	53                   	push   %ebx
80104e93:	83 ec 1c             	sub    $0x1c,%esp
80104e96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104e99:	8b 43 30             	mov    0x30(%ebx),%eax
80104e9c:	83 f8 40             	cmp    $0x40,%eax
80104e9f:	74 13                	je     80104eb4 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104ea1:	83 e8 20             	sub    $0x20,%eax
80104ea4:	83 f8 1f             	cmp    $0x1f,%eax
80104ea7:	0f 87 3a 01 00 00    	ja     80104fe7 <trap+0x15a>
80104ead:	ff 24 85 58 70 10 80 	jmp    *-0x7fef8fa8(,%eax,4)
    if(myproc()->killed)
80104eb4:	e8 61 e3 ff ff       	call   8010321a <myproc>
80104eb9:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ebd:	75 1f                	jne    80104ede <trap+0x51>
    myproc()->tf = tf;
80104ebf:	e8 56 e3 ff ff       	call   8010321a <myproc>
80104ec4:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104ec7:	e8 aa f0 ff ff       	call   80103f76 <syscall>
    if(myproc()->killed)
80104ecc:	e8 49 e3 ff ff       	call   8010321a <myproc>
80104ed1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ed5:	74 7e                	je     80104f55 <trap+0xc8>
      exit();
80104ed7:	e8 e8 e6 ff ff       	call   801035c4 <exit>
    return;
80104edc:	eb 77                	jmp    80104f55 <trap+0xc8>
      exit();
80104ede:	e8 e1 e6 ff ff       	call   801035c4 <exit>
80104ee3:	eb da                	jmp    80104ebf <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104ee5:	e8 15 e3 ff ff       	call   801031ff <cpuid>
80104eea:	85 c0                	test   %eax,%eax
80104eec:	74 6f                	je     80104f5d <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104eee:	e8 b5 d4 ff ff       	call   801023a8 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ef3:	e8 22 e3 ff ff       	call   8010321a <myproc>
80104ef8:	85 c0                	test   %eax,%eax
80104efa:	74 1c                	je     80104f18 <trap+0x8b>
80104efc:	e8 19 e3 ff ff       	call   8010321a <myproc>
80104f01:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f05:	74 11                	je     80104f18 <trap+0x8b>
80104f07:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f0b:	83 e0 03             	and    $0x3,%eax
80104f0e:	66 83 f8 03          	cmp    $0x3,%ax
80104f12:	0f 84 62 01 00 00    	je     8010507a <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f18:	e8 fd e2 ff ff       	call   8010321a <myproc>
80104f1d:	85 c0                	test   %eax,%eax
80104f1f:	74 0f                	je     80104f30 <trap+0xa3>
80104f21:	e8 f4 e2 ff ff       	call   8010321a <myproc>
80104f26:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f2a:	0f 84 54 01 00 00    	je     80105084 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f30:	e8 e5 e2 ff ff       	call   8010321a <myproc>
80104f35:	85 c0                	test   %eax,%eax
80104f37:	74 1c                	je     80104f55 <trap+0xc8>
80104f39:	e8 dc e2 ff ff       	call   8010321a <myproc>
80104f3e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f42:	74 11                	je     80104f55 <trap+0xc8>
80104f44:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f48:	83 e0 03             	and    $0x3,%eax
80104f4b:	66 83 f8 03          	cmp    $0x3,%ax
80104f4f:	0f 84 43 01 00 00    	je     80105098 <trap+0x20b>
    exit();
}
80104f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f58:	5b                   	pop    %ebx
80104f59:	5e                   	pop    %esi
80104f5a:	5f                   	pop    %edi
80104f5b:	5d                   	pop    %ebp
80104f5c:	c3                   	ret    
      acquire(&tickslock);
80104f5d:	83 ec 0c             	sub    $0xc,%esp
80104f60:	68 80 3c 11 80       	push   $0x80113c80
80104f65:	e8 4d ec ff ff       	call   80103bb7 <acquire>
      ticks++;
80104f6a:	83 05 60 3c 11 80 01 	addl   $0x1,0x80113c60
      wakeup(&ticks);
80104f71:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104f78:	e8 a4 e8 ff ff       	call   80103821 <wakeup>
      release(&tickslock);
80104f7d:	c7 04 24 80 3c 11 80 	movl   $0x80113c80,(%esp)
80104f84:	e8 93 ec ff ff       	call   80103c1c <release>
80104f89:	83 c4 10             	add    $0x10,%esp
80104f8c:	e9 5d ff ff ff       	jmp    80104eee <trap+0x61>
    ideintr();
80104f91:	e8 c6 cd ff ff       	call   80101d5c <ideintr>
    lapiceoi();
80104f96:	e8 0d d4 ff ff       	call   801023a8 <lapiceoi>
    break;
80104f9b:	e9 53 ff ff ff       	jmp    80104ef3 <trap+0x66>
    kbdintr();
80104fa0:	e8 41 d2 ff ff       	call   801021e6 <kbdintr>
    lapiceoi();
80104fa5:	e8 fe d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80104faa:	e9 44 ff ff ff       	jmp    80104ef3 <trap+0x66>
    uartintr();
80104faf:	e8 fe 01 00 00       	call   801051b2 <uartintr>
    lapiceoi();
80104fb4:	e8 ef d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80104fb9:	e9 35 ff ff ff       	jmp    80104ef3 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fbe:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80104fc1:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fc5:	e8 35 e2 ff ff       	call   801031ff <cpuid>
80104fca:	57                   	push   %edi
80104fcb:	0f b7 f6             	movzwl %si,%esi
80104fce:	56                   	push   %esi
80104fcf:	50                   	push   %eax
80104fd0:	68 bc 6f 10 80       	push   $0x80106fbc
80104fd5:	e8 2d b6 ff ff       	call   80100607 <cprintf>
    lapiceoi();
80104fda:	e8 c9 d3 ff ff       	call   801023a8 <lapiceoi>
    break;
80104fdf:	83 c4 10             	add    $0x10,%esp
80104fe2:	e9 0c ff ff ff       	jmp    80104ef3 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80104fe7:	e8 2e e2 ff ff       	call   8010321a <myproc>
80104fec:	85 c0                	test   %eax,%eax
80104fee:	74 5f                	je     8010504f <trap+0x1c2>
80104ff0:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80104ff4:	74 59                	je     8010504f <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104ff6:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104ff9:	8b 43 38             	mov    0x38(%ebx),%eax
80104ffc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104fff:	e8 fb e1 ff ff       	call   801031ff <cpuid>
80105004:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105007:	8b 53 34             	mov    0x34(%ebx),%edx
8010500a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010500d:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105010:	e8 05 e2 ff ff       	call   8010321a <myproc>
80105015:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105018:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010501b:	e8 fa e1 ff ff       	call   8010321a <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105020:	57                   	push   %edi
80105021:	ff 75 e4             	push   -0x1c(%ebp)
80105024:	ff 75 e0             	push   -0x20(%ebp)
80105027:	ff 75 dc             	push   -0x24(%ebp)
8010502a:	56                   	push   %esi
8010502b:	ff 75 d8             	push   -0x28(%ebp)
8010502e:	ff 70 10             	push   0x10(%eax)
80105031:	68 14 70 10 80       	push   $0x80107014
80105036:	e8 cc b5 ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
8010503b:	83 c4 20             	add    $0x20,%esp
8010503e:	e8 d7 e1 ff ff       	call   8010321a <myproc>
80105043:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010504a:	e9 a4 fe ff ff       	jmp    80104ef3 <trap+0x66>
8010504f:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105052:	8b 73 38             	mov    0x38(%ebx),%esi
80105055:	e8 a5 e1 ff ff       	call   801031ff <cpuid>
8010505a:	83 ec 0c             	sub    $0xc,%esp
8010505d:	57                   	push   %edi
8010505e:	56                   	push   %esi
8010505f:	50                   	push   %eax
80105060:	ff 73 30             	push   0x30(%ebx)
80105063:	68 e0 6f 10 80       	push   $0x80106fe0
80105068:	e8 9a b5 ff ff       	call   80100607 <cprintf>
      panic("trap");
8010506d:	83 c4 14             	add    $0x14,%esp
80105070:	68 b6 6f 10 80       	push   $0x80106fb6
80105075:	e8 ce b2 ff ff       	call   80100348 <panic>
    exit();
8010507a:	e8 45 e5 ff ff       	call   801035c4 <exit>
8010507f:	e9 94 fe ff ff       	jmp    80104f18 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105084:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105088:	0f 85 a2 fe ff ff    	jne    80104f30 <trap+0xa3>
    yield();
8010508e:	e8 f7 e5 ff ff       	call   8010368a <yield>
80105093:	e9 98 fe ff ff       	jmp    80104f30 <trap+0xa3>
    exit();
80105098:	e8 27 e5 ff ff       	call   801035c4 <exit>
8010509d:	e9 b3 fe ff ff       	jmp    80104f55 <trap+0xc8>

801050a2 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
801050a2:	83 3d c0 44 11 80 00 	cmpl   $0x0,0x801144c0
801050a9:	74 14                	je     801050bf <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050ab:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050b0:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801050b1:	a8 01                	test   $0x1,%al
801050b3:	74 10                	je     801050c5 <uartgetc+0x23>
801050b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801050ba:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801050bb:	0f b6 c0             	movzbl %al,%eax
801050be:	c3                   	ret    
    return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	c3                   	ret    
    return -1;
801050c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050ca:	c3                   	ret    

801050cb <uartputc>:
  if(!uart)
801050cb:	83 3d c0 44 11 80 00 	cmpl   $0x0,0x801144c0
801050d2:	74 3b                	je     8010510f <uartputc+0x44>
{
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
801050d7:	53                   	push   %ebx
801050d8:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050db:	bb 00 00 00 00       	mov    $0x0,%ebx
801050e0:	eb 10                	jmp    801050f2 <uartputc+0x27>
    microdelay(10);
801050e2:	83 ec 0c             	sub    $0xc,%esp
801050e5:	6a 0a                	push   $0xa
801050e7:	e8 dd d2 ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050ec:	83 c3 01             	add    $0x1,%ebx
801050ef:	83 c4 10             	add    $0x10,%esp
801050f2:	83 fb 7f             	cmp    $0x7f,%ebx
801050f5:	7f 0a                	jg     80105101 <uartputc+0x36>
801050f7:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050fc:	ec                   	in     (%dx),%al
801050fd:	a8 20                	test   $0x20,%al
801050ff:	74 e1                	je     801050e2 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105101:	8b 45 08             	mov    0x8(%ebp),%eax
80105104:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105109:	ee                   	out    %al,(%dx)
}
8010510a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010510d:	c9                   	leave  
8010510e:	c3                   	ret    
8010510f:	c3                   	ret    

80105110 <uartinit>:
{
80105110:	55                   	push   %ebp
80105111:	89 e5                	mov    %esp,%ebp
80105113:	56                   	push   %esi
80105114:	53                   	push   %ebx
80105115:	b9 00 00 00 00       	mov    $0x0,%ecx
8010511a:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010511f:	89 c8                	mov    %ecx,%eax
80105121:	ee                   	out    %al,(%dx)
80105122:	be fb 03 00 00       	mov    $0x3fb,%esi
80105127:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010512c:	89 f2                	mov    %esi,%edx
8010512e:	ee                   	out    %al,(%dx)
8010512f:	b8 0c 00 00 00       	mov    $0xc,%eax
80105134:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105139:	ee                   	out    %al,(%dx)
8010513a:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010513f:	89 c8                	mov    %ecx,%eax
80105141:	89 da                	mov    %ebx,%edx
80105143:	ee                   	out    %al,(%dx)
80105144:	b8 03 00 00 00       	mov    $0x3,%eax
80105149:	89 f2                	mov    %esi,%edx
8010514b:	ee                   	out    %al,(%dx)
8010514c:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105151:	89 c8                	mov    %ecx,%eax
80105153:	ee                   	out    %al,(%dx)
80105154:	b8 01 00 00 00       	mov    $0x1,%eax
80105159:	89 da                	mov    %ebx,%edx
8010515b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010515c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105161:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105162:	3c ff                	cmp    $0xff,%al
80105164:	74 45                	je     801051ab <uartinit+0x9b>
  uart = 1;
80105166:	c7 05 c0 44 11 80 01 	movl   $0x1,0x801144c0
8010516d:	00 00 00 
80105170:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105175:	ec                   	in     (%dx),%al
80105176:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010517b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010517c:	83 ec 08             	sub    $0x8,%esp
8010517f:	6a 00                	push   $0x0
80105181:	6a 04                	push   $0x4
80105183:	e8 d9 cd ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105188:	83 c4 10             	add    $0x10,%esp
8010518b:	bb d8 70 10 80       	mov    $0x801070d8,%ebx
80105190:	eb 12                	jmp    801051a4 <uartinit+0x94>
    uartputc(*p);
80105192:	83 ec 0c             	sub    $0xc,%esp
80105195:	0f be c0             	movsbl %al,%eax
80105198:	50                   	push   %eax
80105199:	e8 2d ff ff ff       	call   801050cb <uartputc>
  for(p="xv6...\n"; *p; p++)
8010519e:	83 c3 01             	add    $0x1,%ebx
801051a1:	83 c4 10             	add    $0x10,%esp
801051a4:	0f b6 03             	movzbl (%ebx),%eax
801051a7:	84 c0                	test   %al,%al
801051a9:	75 e7                	jne    80105192 <uartinit+0x82>
}
801051ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051ae:	5b                   	pop    %ebx
801051af:	5e                   	pop    %esi
801051b0:	5d                   	pop    %ebp
801051b1:	c3                   	ret    

801051b2 <uartintr>:

void
uartintr(void)
{
801051b2:	55                   	push   %ebp
801051b3:	89 e5                	mov    %esp,%ebp
801051b5:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801051b8:	68 a2 50 10 80       	push   $0x801050a2
801051bd:	e8 71 b5 ff ff       	call   80100733 <consoleintr>
}
801051c2:	83 c4 10             	add    $0x10,%esp
801051c5:	c9                   	leave  
801051c6:	c3                   	ret    

801051c7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801051c7:	6a 00                	push   $0x0
  pushl $0
801051c9:	6a 00                	push   $0x0
  jmp alltraps
801051cb:	e9 71 fb ff ff       	jmp    80104d41 <alltraps>

801051d0 <vector1>:
.globl vector1
vector1:
  pushl $0
801051d0:	6a 00                	push   $0x0
  pushl $1
801051d2:	6a 01                	push   $0x1
  jmp alltraps
801051d4:	e9 68 fb ff ff       	jmp    80104d41 <alltraps>

801051d9 <vector2>:
.globl vector2
vector2:
  pushl $0
801051d9:	6a 00                	push   $0x0
  pushl $2
801051db:	6a 02                	push   $0x2
  jmp alltraps
801051dd:	e9 5f fb ff ff       	jmp    80104d41 <alltraps>

801051e2 <vector3>:
.globl vector3
vector3:
  pushl $0
801051e2:	6a 00                	push   $0x0
  pushl $3
801051e4:	6a 03                	push   $0x3
  jmp alltraps
801051e6:	e9 56 fb ff ff       	jmp    80104d41 <alltraps>

801051eb <vector4>:
.globl vector4
vector4:
  pushl $0
801051eb:	6a 00                	push   $0x0
  pushl $4
801051ed:	6a 04                	push   $0x4
  jmp alltraps
801051ef:	e9 4d fb ff ff       	jmp    80104d41 <alltraps>

801051f4 <vector5>:
.globl vector5
vector5:
  pushl $0
801051f4:	6a 00                	push   $0x0
  pushl $5
801051f6:	6a 05                	push   $0x5
  jmp alltraps
801051f8:	e9 44 fb ff ff       	jmp    80104d41 <alltraps>

801051fd <vector6>:
.globl vector6
vector6:
  pushl $0
801051fd:	6a 00                	push   $0x0
  pushl $6
801051ff:	6a 06                	push   $0x6
  jmp alltraps
80105201:	e9 3b fb ff ff       	jmp    80104d41 <alltraps>

80105206 <vector7>:
.globl vector7
vector7:
  pushl $0
80105206:	6a 00                	push   $0x0
  pushl $7
80105208:	6a 07                	push   $0x7
  jmp alltraps
8010520a:	e9 32 fb ff ff       	jmp    80104d41 <alltraps>

8010520f <vector8>:
.globl vector8
vector8:
  pushl $8
8010520f:	6a 08                	push   $0x8
  jmp alltraps
80105211:	e9 2b fb ff ff       	jmp    80104d41 <alltraps>

80105216 <vector9>:
.globl vector9
vector9:
  pushl $0
80105216:	6a 00                	push   $0x0
  pushl $9
80105218:	6a 09                	push   $0x9
  jmp alltraps
8010521a:	e9 22 fb ff ff       	jmp    80104d41 <alltraps>

8010521f <vector10>:
.globl vector10
vector10:
  pushl $10
8010521f:	6a 0a                	push   $0xa
  jmp alltraps
80105221:	e9 1b fb ff ff       	jmp    80104d41 <alltraps>

80105226 <vector11>:
.globl vector11
vector11:
  pushl $11
80105226:	6a 0b                	push   $0xb
  jmp alltraps
80105228:	e9 14 fb ff ff       	jmp    80104d41 <alltraps>

8010522d <vector12>:
.globl vector12
vector12:
  pushl $12
8010522d:	6a 0c                	push   $0xc
  jmp alltraps
8010522f:	e9 0d fb ff ff       	jmp    80104d41 <alltraps>

80105234 <vector13>:
.globl vector13
vector13:
  pushl $13
80105234:	6a 0d                	push   $0xd
  jmp alltraps
80105236:	e9 06 fb ff ff       	jmp    80104d41 <alltraps>

8010523b <vector14>:
.globl vector14
vector14:
  pushl $14
8010523b:	6a 0e                	push   $0xe
  jmp alltraps
8010523d:	e9 ff fa ff ff       	jmp    80104d41 <alltraps>

80105242 <vector15>:
.globl vector15
vector15:
  pushl $0
80105242:	6a 00                	push   $0x0
  pushl $15
80105244:	6a 0f                	push   $0xf
  jmp alltraps
80105246:	e9 f6 fa ff ff       	jmp    80104d41 <alltraps>

8010524b <vector16>:
.globl vector16
vector16:
  pushl $0
8010524b:	6a 00                	push   $0x0
  pushl $16
8010524d:	6a 10                	push   $0x10
  jmp alltraps
8010524f:	e9 ed fa ff ff       	jmp    80104d41 <alltraps>

80105254 <vector17>:
.globl vector17
vector17:
  pushl $17
80105254:	6a 11                	push   $0x11
  jmp alltraps
80105256:	e9 e6 fa ff ff       	jmp    80104d41 <alltraps>

8010525b <vector18>:
.globl vector18
vector18:
  pushl $0
8010525b:	6a 00                	push   $0x0
  pushl $18
8010525d:	6a 12                	push   $0x12
  jmp alltraps
8010525f:	e9 dd fa ff ff       	jmp    80104d41 <alltraps>

80105264 <vector19>:
.globl vector19
vector19:
  pushl $0
80105264:	6a 00                	push   $0x0
  pushl $19
80105266:	6a 13                	push   $0x13
  jmp alltraps
80105268:	e9 d4 fa ff ff       	jmp    80104d41 <alltraps>

8010526d <vector20>:
.globl vector20
vector20:
  pushl $0
8010526d:	6a 00                	push   $0x0
  pushl $20
8010526f:	6a 14                	push   $0x14
  jmp alltraps
80105271:	e9 cb fa ff ff       	jmp    80104d41 <alltraps>

80105276 <vector21>:
.globl vector21
vector21:
  pushl $0
80105276:	6a 00                	push   $0x0
  pushl $21
80105278:	6a 15                	push   $0x15
  jmp alltraps
8010527a:	e9 c2 fa ff ff       	jmp    80104d41 <alltraps>

8010527f <vector22>:
.globl vector22
vector22:
  pushl $0
8010527f:	6a 00                	push   $0x0
  pushl $22
80105281:	6a 16                	push   $0x16
  jmp alltraps
80105283:	e9 b9 fa ff ff       	jmp    80104d41 <alltraps>

80105288 <vector23>:
.globl vector23
vector23:
  pushl $0
80105288:	6a 00                	push   $0x0
  pushl $23
8010528a:	6a 17                	push   $0x17
  jmp alltraps
8010528c:	e9 b0 fa ff ff       	jmp    80104d41 <alltraps>

80105291 <vector24>:
.globl vector24
vector24:
  pushl $0
80105291:	6a 00                	push   $0x0
  pushl $24
80105293:	6a 18                	push   $0x18
  jmp alltraps
80105295:	e9 a7 fa ff ff       	jmp    80104d41 <alltraps>

8010529a <vector25>:
.globl vector25
vector25:
  pushl $0
8010529a:	6a 00                	push   $0x0
  pushl $25
8010529c:	6a 19                	push   $0x19
  jmp alltraps
8010529e:	e9 9e fa ff ff       	jmp    80104d41 <alltraps>

801052a3 <vector26>:
.globl vector26
vector26:
  pushl $0
801052a3:	6a 00                	push   $0x0
  pushl $26
801052a5:	6a 1a                	push   $0x1a
  jmp alltraps
801052a7:	e9 95 fa ff ff       	jmp    80104d41 <alltraps>

801052ac <vector27>:
.globl vector27
vector27:
  pushl $0
801052ac:	6a 00                	push   $0x0
  pushl $27
801052ae:	6a 1b                	push   $0x1b
  jmp alltraps
801052b0:	e9 8c fa ff ff       	jmp    80104d41 <alltraps>

801052b5 <vector28>:
.globl vector28
vector28:
  pushl $0
801052b5:	6a 00                	push   $0x0
  pushl $28
801052b7:	6a 1c                	push   $0x1c
  jmp alltraps
801052b9:	e9 83 fa ff ff       	jmp    80104d41 <alltraps>

801052be <vector29>:
.globl vector29
vector29:
  pushl $0
801052be:	6a 00                	push   $0x0
  pushl $29
801052c0:	6a 1d                	push   $0x1d
  jmp alltraps
801052c2:	e9 7a fa ff ff       	jmp    80104d41 <alltraps>

801052c7 <vector30>:
.globl vector30
vector30:
  pushl $0
801052c7:	6a 00                	push   $0x0
  pushl $30
801052c9:	6a 1e                	push   $0x1e
  jmp alltraps
801052cb:	e9 71 fa ff ff       	jmp    80104d41 <alltraps>

801052d0 <vector31>:
.globl vector31
vector31:
  pushl $0
801052d0:	6a 00                	push   $0x0
  pushl $31
801052d2:	6a 1f                	push   $0x1f
  jmp alltraps
801052d4:	e9 68 fa ff ff       	jmp    80104d41 <alltraps>

801052d9 <vector32>:
.globl vector32
vector32:
  pushl $0
801052d9:	6a 00                	push   $0x0
  pushl $32
801052db:	6a 20                	push   $0x20
  jmp alltraps
801052dd:	e9 5f fa ff ff       	jmp    80104d41 <alltraps>

801052e2 <vector33>:
.globl vector33
vector33:
  pushl $0
801052e2:	6a 00                	push   $0x0
  pushl $33
801052e4:	6a 21                	push   $0x21
  jmp alltraps
801052e6:	e9 56 fa ff ff       	jmp    80104d41 <alltraps>

801052eb <vector34>:
.globl vector34
vector34:
  pushl $0
801052eb:	6a 00                	push   $0x0
  pushl $34
801052ed:	6a 22                	push   $0x22
  jmp alltraps
801052ef:	e9 4d fa ff ff       	jmp    80104d41 <alltraps>

801052f4 <vector35>:
.globl vector35
vector35:
  pushl $0
801052f4:	6a 00                	push   $0x0
  pushl $35
801052f6:	6a 23                	push   $0x23
  jmp alltraps
801052f8:	e9 44 fa ff ff       	jmp    80104d41 <alltraps>

801052fd <vector36>:
.globl vector36
vector36:
  pushl $0
801052fd:	6a 00                	push   $0x0
  pushl $36
801052ff:	6a 24                	push   $0x24
  jmp alltraps
80105301:	e9 3b fa ff ff       	jmp    80104d41 <alltraps>

80105306 <vector37>:
.globl vector37
vector37:
  pushl $0
80105306:	6a 00                	push   $0x0
  pushl $37
80105308:	6a 25                	push   $0x25
  jmp alltraps
8010530a:	e9 32 fa ff ff       	jmp    80104d41 <alltraps>

8010530f <vector38>:
.globl vector38
vector38:
  pushl $0
8010530f:	6a 00                	push   $0x0
  pushl $38
80105311:	6a 26                	push   $0x26
  jmp alltraps
80105313:	e9 29 fa ff ff       	jmp    80104d41 <alltraps>

80105318 <vector39>:
.globl vector39
vector39:
  pushl $0
80105318:	6a 00                	push   $0x0
  pushl $39
8010531a:	6a 27                	push   $0x27
  jmp alltraps
8010531c:	e9 20 fa ff ff       	jmp    80104d41 <alltraps>

80105321 <vector40>:
.globl vector40
vector40:
  pushl $0
80105321:	6a 00                	push   $0x0
  pushl $40
80105323:	6a 28                	push   $0x28
  jmp alltraps
80105325:	e9 17 fa ff ff       	jmp    80104d41 <alltraps>

8010532a <vector41>:
.globl vector41
vector41:
  pushl $0
8010532a:	6a 00                	push   $0x0
  pushl $41
8010532c:	6a 29                	push   $0x29
  jmp alltraps
8010532e:	e9 0e fa ff ff       	jmp    80104d41 <alltraps>

80105333 <vector42>:
.globl vector42
vector42:
  pushl $0
80105333:	6a 00                	push   $0x0
  pushl $42
80105335:	6a 2a                	push   $0x2a
  jmp alltraps
80105337:	e9 05 fa ff ff       	jmp    80104d41 <alltraps>

8010533c <vector43>:
.globl vector43
vector43:
  pushl $0
8010533c:	6a 00                	push   $0x0
  pushl $43
8010533e:	6a 2b                	push   $0x2b
  jmp alltraps
80105340:	e9 fc f9 ff ff       	jmp    80104d41 <alltraps>

80105345 <vector44>:
.globl vector44
vector44:
  pushl $0
80105345:	6a 00                	push   $0x0
  pushl $44
80105347:	6a 2c                	push   $0x2c
  jmp alltraps
80105349:	e9 f3 f9 ff ff       	jmp    80104d41 <alltraps>

8010534e <vector45>:
.globl vector45
vector45:
  pushl $0
8010534e:	6a 00                	push   $0x0
  pushl $45
80105350:	6a 2d                	push   $0x2d
  jmp alltraps
80105352:	e9 ea f9 ff ff       	jmp    80104d41 <alltraps>

80105357 <vector46>:
.globl vector46
vector46:
  pushl $0
80105357:	6a 00                	push   $0x0
  pushl $46
80105359:	6a 2e                	push   $0x2e
  jmp alltraps
8010535b:	e9 e1 f9 ff ff       	jmp    80104d41 <alltraps>

80105360 <vector47>:
.globl vector47
vector47:
  pushl $0
80105360:	6a 00                	push   $0x0
  pushl $47
80105362:	6a 2f                	push   $0x2f
  jmp alltraps
80105364:	e9 d8 f9 ff ff       	jmp    80104d41 <alltraps>

80105369 <vector48>:
.globl vector48
vector48:
  pushl $0
80105369:	6a 00                	push   $0x0
  pushl $48
8010536b:	6a 30                	push   $0x30
  jmp alltraps
8010536d:	e9 cf f9 ff ff       	jmp    80104d41 <alltraps>

80105372 <vector49>:
.globl vector49
vector49:
  pushl $0
80105372:	6a 00                	push   $0x0
  pushl $49
80105374:	6a 31                	push   $0x31
  jmp alltraps
80105376:	e9 c6 f9 ff ff       	jmp    80104d41 <alltraps>

8010537b <vector50>:
.globl vector50
vector50:
  pushl $0
8010537b:	6a 00                	push   $0x0
  pushl $50
8010537d:	6a 32                	push   $0x32
  jmp alltraps
8010537f:	e9 bd f9 ff ff       	jmp    80104d41 <alltraps>

80105384 <vector51>:
.globl vector51
vector51:
  pushl $0
80105384:	6a 00                	push   $0x0
  pushl $51
80105386:	6a 33                	push   $0x33
  jmp alltraps
80105388:	e9 b4 f9 ff ff       	jmp    80104d41 <alltraps>

8010538d <vector52>:
.globl vector52
vector52:
  pushl $0
8010538d:	6a 00                	push   $0x0
  pushl $52
8010538f:	6a 34                	push   $0x34
  jmp alltraps
80105391:	e9 ab f9 ff ff       	jmp    80104d41 <alltraps>

80105396 <vector53>:
.globl vector53
vector53:
  pushl $0
80105396:	6a 00                	push   $0x0
  pushl $53
80105398:	6a 35                	push   $0x35
  jmp alltraps
8010539a:	e9 a2 f9 ff ff       	jmp    80104d41 <alltraps>

8010539f <vector54>:
.globl vector54
vector54:
  pushl $0
8010539f:	6a 00                	push   $0x0
  pushl $54
801053a1:	6a 36                	push   $0x36
  jmp alltraps
801053a3:	e9 99 f9 ff ff       	jmp    80104d41 <alltraps>

801053a8 <vector55>:
.globl vector55
vector55:
  pushl $0
801053a8:	6a 00                	push   $0x0
  pushl $55
801053aa:	6a 37                	push   $0x37
  jmp alltraps
801053ac:	e9 90 f9 ff ff       	jmp    80104d41 <alltraps>

801053b1 <vector56>:
.globl vector56
vector56:
  pushl $0
801053b1:	6a 00                	push   $0x0
  pushl $56
801053b3:	6a 38                	push   $0x38
  jmp alltraps
801053b5:	e9 87 f9 ff ff       	jmp    80104d41 <alltraps>

801053ba <vector57>:
.globl vector57
vector57:
  pushl $0
801053ba:	6a 00                	push   $0x0
  pushl $57
801053bc:	6a 39                	push   $0x39
  jmp alltraps
801053be:	e9 7e f9 ff ff       	jmp    80104d41 <alltraps>

801053c3 <vector58>:
.globl vector58
vector58:
  pushl $0
801053c3:	6a 00                	push   $0x0
  pushl $58
801053c5:	6a 3a                	push   $0x3a
  jmp alltraps
801053c7:	e9 75 f9 ff ff       	jmp    80104d41 <alltraps>

801053cc <vector59>:
.globl vector59
vector59:
  pushl $0
801053cc:	6a 00                	push   $0x0
  pushl $59
801053ce:	6a 3b                	push   $0x3b
  jmp alltraps
801053d0:	e9 6c f9 ff ff       	jmp    80104d41 <alltraps>

801053d5 <vector60>:
.globl vector60
vector60:
  pushl $0
801053d5:	6a 00                	push   $0x0
  pushl $60
801053d7:	6a 3c                	push   $0x3c
  jmp alltraps
801053d9:	e9 63 f9 ff ff       	jmp    80104d41 <alltraps>

801053de <vector61>:
.globl vector61
vector61:
  pushl $0
801053de:	6a 00                	push   $0x0
  pushl $61
801053e0:	6a 3d                	push   $0x3d
  jmp alltraps
801053e2:	e9 5a f9 ff ff       	jmp    80104d41 <alltraps>

801053e7 <vector62>:
.globl vector62
vector62:
  pushl $0
801053e7:	6a 00                	push   $0x0
  pushl $62
801053e9:	6a 3e                	push   $0x3e
  jmp alltraps
801053eb:	e9 51 f9 ff ff       	jmp    80104d41 <alltraps>

801053f0 <vector63>:
.globl vector63
vector63:
  pushl $0
801053f0:	6a 00                	push   $0x0
  pushl $63
801053f2:	6a 3f                	push   $0x3f
  jmp alltraps
801053f4:	e9 48 f9 ff ff       	jmp    80104d41 <alltraps>

801053f9 <vector64>:
.globl vector64
vector64:
  pushl $0
801053f9:	6a 00                	push   $0x0
  pushl $64
801053fb:	6a 40                	push   $0x40
  jmp alltraps
801053fd:	e9 3f f9 ff ff       	jmp    80104d41 <alltraps>

80105402 <vector65>:
.globl vector65
vector65:
  pushl $0
80105402:	6a 00                	push   $0x0
  pushl $65
80105404:	6a 41                	push   $0x41
  jmp alltraps
80105406:	e9 36 f9 ff ff       	jmp    80104d41 <alltraps>

8010540b <vector66>:
.globl vector66
vector66:
  pushl $0
8010540b:	6a 00                	push   $0x0
  pushl $66
8010540d:	6a 42                	push   $0x42
  jmp alltraps
8010540f:	e9 2d f9 ff ff       	jmp    80104d41 <alltraps>

80105414 <vector67>:
.globl vector67
vector67:
  pushl $0
80105414:	6a 00                	push   $0x0
  pushl $67
80105416:	6a 43                	push   $0x43
  jmp alltraps
80105418:	e9 24 f9 ff ff       	jmp    80104d41 <alltraps>

8010541d <vector68>:
.globl vector68
vector68:
  pushl $0
8010541d:	6a 00                	push   $0x0
  pushl $68
8010541f:	6a 44                	push   $0x44
  jmp alltraps
80105421:	e9 1b f9 ff ff       	jmp    80104d41 <alltraps>

80105426 <vector69>:
.globl vector69
vector69:
  pushl $0
80105426:	6a 00                	push   $0x0
  pushl $69
80105428:	6a 45                	push   $0x45
  jmp alltraps
8010542a:	e9 12 f9 ff ff       	jmp    80104d41 <alltraps>

8010542f <vector70>:
.globl vector70
vector70:
  pushl $0
8010542f:	6a 00                	push   $0x0
  pushl $70
80105431:	6a 46                	push   $0x46
  jmp alltraps
80105433:	e9 09 f9 ff ff       	jmp    80104d41 <alltraps>

80105438 <vector71>:
.globl vector71
vector71:
  pushl $0
80105438:	6a 00                	push   $0x0
  pushl $71
8010543a:	6a 47                	push   $0x47
  jmp alltraps
8010543c:	e9 00 f9 ff ff       	jmp    80104d41 <alltraps>

80105441 <vector72>:
.globl vector72
vector72:
  pushl $0
80105441:	6a 00                	push   $0x0
  pushl $72
80105443:	6a 48                	push   $0x48
  jmp alltraps
80105445:	e9 f7 f8 ff ff       	jmp    80104d41 <alltraps>

8010544a <vector73>:
.globl vector73
vector73:
  pushl $0
8010544a:	6a 00                	push   $0x0
  pushl $73
8010544c:	6a 49                	push   $0x49
  jmp alltraps
8010544e:	e9 ee f8 ff ff       	jmp    80104d41 <alltraps>

80105453 <vector74>:
.globl vector74
vector74:
  pushl $0
80105453:	6a 00                	push   $0x0
  pushl $74
80105455:	6a 4a                	push   $0x4a
  jmp alltraps
80105457:	e9 e5 f8 ff ff       	jmp    80104d41 <alltraps>

8010545c <vector75>:
.globl vector75
vector75:
  pushl $0
8010545c:	6a 00                	push   $0x0
  pushl $75
8010545e:	6a 4b                	push   $0x4b
  jmp alltraps
80105460:	e9 dc f8 ff ff       	jmp    80104d41 <alltraps>

80105465 <vector76>:
.globl vector76
vector76:
  pushl $0
80105465:	6a 00                	push   $0x0
  pushl $76
80105467:	6a 4c                	push   $0x4c
  jmp alltraps
80105469:	e9 d3 f8 ff ff       	jmp    80104d41 <alltraps>

8010546e <vector77>:
.globl vector77
vector77:
  pushl $0
8010546e:	6a 00                	push   $0x0
  pushl $77
80105470:	6a 4d                	push   $0x4d
  jmp alltraps
80105472:	e9 ca f8 ff ff       	jmp    80104d41 <alltraps>

80105477 <vector78>:
.globl vector78
vector78:
  pushl $0
80105477:	6a 00                	push   $0x0
  pushl $78
80105479:	6a 4e                	push   $0x4e
  jmp alltraps
8010547b:	e9 c1 f8 ff ff       	jmp    80104d41 <alltraps>

80105480 <vector79>:
.globl vector79
vector79:
  pushl $0
80105480:	6a 00                	push   $0x0
  pushl $79
80105482:	6a 4f                	push   $0x4f
  jmp alltraps
80105484:	e9 b8 f8 ff ff       	jmp    80104d41 <alltraps>

80105489 <vector80>:
.globl vector80
vector80:
  pushl $0
80105489:	6a 00                	push   $0x0
  pushl $80
8010548b:	6a 50                	push   $0x50
  jmp alltraps
8010548d:	e9 af f8 ff ff       	jmp    80104d41 <alltraps>

80105492 <vector81>:
.globl vector81
vector81:
  pushl $0
80105492:	6a 00                	push   $0x0
  pushl $81
80105494:	6a 51                	push   $0x51
  jmp alltraps
80105496:	e9 a6 f8 ff ff       	jmp    80104d41 <alltraps>

8010549b <vector82>:
.globl vector82
vector82:
  pushl $0
8010549b:	6a 00                	push   $0x0
  pushl $82
8010549d:	6a 52                	push   $0x52
  jmp alltraps
8010549f:	e9 9d f8 ff ff       	jmp    80104d41 <alltraps>

801054a4 <vector83>:
.globl vector83
vector83:
  pushl $0
801054a4:	6a 00                	push   $0x0
  pushl $83
801054a6:	6a 53                	push   $0x53
  jmp alltraps
801054a8:	e9 94 f8 ff ff       	jmp    80104d41 <alltraps>

801054ad <vector84>:
.globl vector84
vector84:
  pushl $0
801054ad:	6a 00                	push   $0x0
  pushl $84
801054af:	6a 54                	push   $0x54
  jmp alltraps
801054b1:	e9 8b f8 ff ff       	jmp    80104d41 <alltraps>

801054b6 <vector85>:
.globl vector85
vector85:
  pushl $0
801054b6:	6a 00                	push   $0x0
  pushl $85
801054b8:	6a 55                	push   $0x55
  jmp alltraps
801054ba:	e9 82 f8 ff ff       	jmp    80104d41 <alltraps>

801054bf <vector86>:
.globl vector86
vector86:
  pushl $0
801054bf:	6a 00                	push   $0x0
  pushl $86
801054c1:	6a 56                	push   $0x56
  jmp alltraps
801054c3:	e9 79 f8 ff ff       	jmp    80104d41 <alltraps>

801054c8 <vector87>:
.globl vector87
vector87:
  pushl $0
801054c8:	6a 00                	push   $0x0
  pushl $87
801054ca:	6a 57                	push   $0x57
  jmp alltraps
801054cc:	e9 70 f8 ff ff       	jmp    80104d41 <alltraps>

801054d1 <vector88>:
.globl vector88
vector88:
  pushl $0
801054d1:	6a 00                	push   $0x0
  pushl $88
801054d3:	6a 58                	push   $0x58
  jmp alltraps
801054d5:	e9 67 f8 ff ff       	jmp    80104d41 <alltraps>

801054da <vector89>:
.globl vector89
vector89:
  pushl $0
801054da:	6a 00                	push   $0x0
  pushl $89
801054dc:	6a 59                	push   $0x59
  jmp alltraps
801054de:	e9 5e f8 ff ff       	jmp    80104d41 <alltraps>

801054e3 <vector90>:
.globl vector90
vector90:
  pushl $0
801054e3:	6a 00                	push   $0x0
  pushl $90
801054e5:	6a 5a                	push   $0x5a
  jmp alltraps
801054e7:	e9 55 f8 ff ff       	jmp    80104d41 <alltraps>

801054ec <vector91>:
.globl vector91
vector91:
  pushl $0
801054ec:	6a 00                	push   $0x0
  pushl $91
801054ee:	6a 5b                	push   $0x5b
  jmp alltraps
801054f0:	e9 4c f8 ff ff       	jmp    80104d41 <alltraps>

801054f5 <vector92>:
.globl vector92
vector92:
  pushl $0
801054f5:	6a 00                	push   $0x0
  pushl $92
801054f7:	6a 5c                	push   $0x5c
  jmp alltraps
801054f9:	e9 43 f8 ff ff       	jmp    80104d41 <alltraps>

801054fe <vector93>:
.globl vector93
vector93:
  pushl $0
801054fe:	6a 00                	push   $0x0
  pushl $93
80105500:	6a 5d                	push   $0x5d
  jmp alltraps
80105502:	e9 3a f8 ff ff       	jmp    80104d41 <alltraps>

80105507 <vector94>:
.globl vector94
vector94:
  pushl $0
80105507:	6a 00                	push   $0x0
  pushl $94
80105509:	6a 5e                	push   $0x5e
  jmp alltraps
8010550b:	e9 31 f8 ff ff       	jmp    80104d41 <alltraps>

80105510 <vector95>:
.globl vector95
vector95:
  pushl $0
80105510:	6a 00                	push   $0x0
  pushl $95
80105512:	6a 5f                	push   $0x5f
  jmp alltraps
80105514:	e9 28 f8 ff ff       	jmp    80104d41 <alltraps>

80105519 <vector96>:
.globl vector96
vector96:
  pushl $0
80105519:	6a 00                	push   $0x0
  pushl $96
8010551b:	6a 60                	push   $0x60
  jmp alltraps
8010551d:	e9 1f f8 ff ff       	jmp    80104d41 <alltraps>

80105522 <vector97>:
.globl vector97
vector97:
  pushl $0
80105522:	6a 00                	push   $0x0
  pushl $97
80105524:	6a 61                	push   $0x61
  jmp alltraps
80105526:	e9 16 f8 ff ff       	jmp    80104d41 <alltraps>

8010552b <vector98>:
.globl vector98
vector98:
  pushl $0
8010552b:	6a 00                	push   $0x0
  pushl $98
8010552d:	6a 62                	push   $0x62
  jmp alltraps
8010552f:	e9 0d f8 ff ff       	jmp    80104d41 <alltraps>

80105534 <vector99>:
.globl vector99
vector99:
  pushl $0
80105534:	6a 00                	push   $0x0
  pushl $99
80105536:	6a 63                	push   $0x63
  jmp alltraps
80105538:	e9 04 f8 ff ff       	jmp    80104d41 <alltraps>

8010553d <vector100>:
.globl vector100
vector100:
  pushl $0
8010553d:	6a 00                	push   $0x0
  pushl $100
8010553f:	6a 64                	push   $0x64
  jmp alltraps
80105541:	e9 fb f7 ff ff       	jmp    80104d41 <alltraps>

80105546 <vector101>:
.globl vector101
vector101:
  pushl $0
80105546:	6a 00                	push   $0x0
  pushl $101
80105548:	6a 65                	push   $0x65
  jmp alltraps
8010554a:	e9 f2 f7 ff ff       	jmp    80104d41 <alltraps>

8010554f <vector102>:
.globl vector102
vector102:
  pushl $0
8010554f:	6a 00                	push   $0x0
  pushl $102
80105551:	6a 66                	push   $0x66
  jmp alltraps
80105553:	e9 e9 f7 ff ff       	jmp    80104d41 <alltraps>

80105558 <vector103>:
.globl vector103
vector103:
  pushl $0
80105558:	6a 00                	push   $0x0
  pushl $103
8010555a:	6a 67                	push   $0x67
  jmp alltraps
8010555c:	e9 e0 f7 ff ff       	jmp    80104d41 <alltraps>

80105561 <vector104>:
.globl vector104
vector104:
  pushl $0
80105561:	6a 00                	push   $0x0
  pushl $104
80105563:	6a 68                	push   $0x68
  jmp alltraps
80105565:	e9 d7 f7 ff ff       	jmp    80104d41 <alltraps>

8010556a <vector105>:
.globl vector105
vector105:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $105
8010556c:	6a 69                	push   $0x69
  jmp alltraps
8010556e:	e9 ce f7 ff ff       	jmp    80104d41 <alltraps>

80105573 <vector106>:
.globl vector106
vector106:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $106
80105575:	6a 6a                	push   $0x6a
  jmp alltraps
80105577:	e9 c5 f7 ff ff       	jmp    80104d41 <alltraps>

8010557c <vector107>:
.globl vector107
vector107:
  pushl $0
8010557c:	6a 00                	push   $0x0
  pushl $107
8010557e:	6a 6b                	push   $0x6b
  jmp alltraps
80105580:	e9 bc f7 ff ff       	jmp    80104d41 <alltraps>

80105585 <vector108>:
.globl vector108
vector108:
  pushl $0
80105585:	6a 00                	push   $0x0
  pushl $108
80105587:	6a 6c                	push   $0x6c
  jmp alltraps
80105589:	e9 b3 f7 ff ff       	jmp    80104d41 <alltraps>

8010558e <vector109>:
.globl vector109
vector109:
  pushl $0
8010558e:	6a 00                	push   $0x0
  pushl $109
80105590:	6a 6d                	push   $0x6d
  jmp alltraps
80105592:	e9 aa f7 ff ff       	jmp    80104d41 <alltraps>

80105597 <vector110>:
.globl vector110
vector110:
  pushl $0
80105597:	6a 00                	push   $0x0
  pushl $110
80105599:	6a 6e                	push   $0x6e
  jmp alltraps
8010559b:	e9 a1 f7 ff ff       	jmp    80104d41 <alltraps>

801055a0 <vector111>:
.globl vector111
vector111:
  pushl $0
801055a0:	6a 00                	push   $0x0
  pushl $111
801055a2:	6a 6f                	push   $0x6f
  jmp alltraps
801055a4:	e9 98 f7 ff ff       	jmp    80104d41 <alltraps>

801055a9 <vector112>:
.globl vector112
vector112:
  pushl $0
801055a9:	6a 00                	push   $0x0
  pushl $112
801055ab:	6a 70                	push   $0x70
  jmp alltraps
801055ad:	e9 8f f7 ff ff       	jmp    80104d41 <alltraps>

801055b2 <vector113>:
.globl vector113
vector113:
  pushl $0
801055b2:	6a 00                	push   $0x0
  pushl $113
801055b4:	6a 71                	push   $0x71
  jmp alltraps
801055b6:	e9 86 f7 ff ff       	jmp    80104d41 <alltraps>

801055bb <vector114>:
.globl vector114
vector114:
  pushl $0
801055bb:	6a 00                	push   $0x0
  pushl $114
801055bd:	6a 72                	push   $0x72
  jmp alltraps
801055bf:	e9 7d f7 ff ff       	jmp    80104d41 <alltraps>

801055c4 <vector115>:
.globl vector115
vector115:
  pushl $0
801055c4:	6a 00                	push   $0x0
  pushl $115
801055c6:	6a 73                	push   $0x73
  jmp alltraps
801055c8:	e9 74 f7 ff ff       	jmp    80104d41 <alltraps>

801055cd <vector116>:
.globl vector116
vector116:
  pushl $0
801055cd:	6a 00                	push   $0x0
  pushl $116
801055cf:	6a 74                	push   $0x74
  jmp alltraps
801055d1:	e9 6b f7 ff ff       	jmp    80104d41 <alltraps>

801055d6 <vector117>:
.globl vector117
vector117:
  pushl $0
801055d6:	6a 00                	push   $0x0
  pushl $117
801055d8:	6a 75                	push   $0x75
  jmp alltraps
801055da:	e9 62 f7 ff ff       	jmp    80104d41 <alltraps>

801055df <vector118>:
.globl vector118
vector118:
  pushl $0
801055df:	6a 00                	push   $0x0
  pushl $118
801055e1:	6a 76                	push   $0x76
  jmp alltraps
801055e3:	e9 59 f7 ff ff       	jmp    80104d41 <alltraps>

801055e8 <vector119>:
.globl vector119
vector119:
  pushl $0
801055e8:	6a 00                	push   $0x0
  pushl $119
801055ea:	6a 77                	push   $0x77
  jmp alltraps
801055ec:	e9 50 f7 ff ff       	jmp    80104d41 <alltraps>

801055f1 <vector120>:
.globl vector120
vector120:
  pushl $0
801055f1:	6a 00                	push   $0x0
  pushl $120
801055f3:	6a 78                	push   $0x78
  jmp alltraps
801055f5:	e9 47 f7 ff ff       	jmp    80104d41 <alltraps>

801055fa <vector121>:
.globl vector121
vector121:
  pushl $0
801055fa:	6a 00                	push   $0x0
  pushl $121
801055fc:	6a 79                	push   $0x79
  jmp alltraps
801055fe:	e9 3e f7 ff ff       	jmp    80104d41 <alltraps>

80105603 <vector122>:
.globl vector122
vector122:
  pushl $0
80105603:	6a 00                	push   $0x0
  pushl $122
80105605:	6a 7a                	push   $0x7a
  jmp alltraps
80105607:	e9 35 f7 ff ff       	jmp    80104d41 <alltraps>

8010560c <vector123>:
.globl vector123
vector123:
  pushl $0
8010560c:	6a 00                	push   $0x0
  pushl $123
8010560e:	6a 7b                	push   $0x7b
  jmp alltraps
80105610:	e9 2c f7 ff ff       	jmp    80104d41 <alltraps>

80105615 <vector124>:
.globl vector124
vector124:
  pushl $0
80105615:	6a 00                	push   $0x0
  pushl $124
80105617:	6a 7c                	push   $0x7c
  jmp alltraps
80105619:	e9 23 f7 ff ff       	jmp    80104d41 <alltraps>

8010561e <vector125>:
.globl vector125
vector125:
  pushl $0
8010561e:	6a 00                	push   $0x0
  pushl $125
80105620:	6a 7d                	push   $0x7d
  jmp alltraps
80105622:	e9 1a f7 ff ff       	jmp    80104d41 <alltraps>

80105627 <vector126>:
.globl vector126
vector126:
  pushl $0
80105627:	6a 00                	push   $0x0
  pushl $126
80105629:	6a 7e                	push   $0x7e
  jmp alltraps
8010562b:	e9 11 f7 ff ff       	jmp    80104d41 <alltraps>

80105630 <vector127>:
.globl vector127
vector127:
  pushl $0
80105630:	6a 00                	push   $0x0
  pushl $127
80105632:	6a 7f                	push   $0x7f
  jmp alltraps
80105634:	e9 08 f7 ff ff       	jmp    80104d41 <alltraps>

80105639 <vector128>:
.globl vector128
vector128:
  pushl $0
80105639:	6a 00                	push   $0x0
  pushl $128
8010563b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105640:	e9 fc f6 ff ff       	jmp    80104d41 <alltraps>

80105645 <vector129>:
.globl vector129
vector129:
  pushl $0
80105645:	6a 00                	push   $0x0
  pushl $129
80105647:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010564c:	e9 f0 f6 ff ff       	jmp    80104d41 <alltraps>

80105651 <vector130>:
.globl vector130
vector130:
  pushl $0
80105651:	6a 00                	push   $0x0
  pushl $130
80105653:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105658:	e9 e4 f6 ff ff       	jmp    80104d41 <alltraps>

8010565d <vector131>:
.globl vector131
vector131:
  pushl $0
8010565d:	6a 00                	push   $0x0
  pushl $131
8010565f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105664:	e9 d8 f6 ff ff       	jmp    80104d41 <alltraps>

80105669 <vector132>:
.globl vector132
vector132:
  pushl $0
80105669:	6a 00                	push   $0x0
  pushl $132
8010566b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105670:	e9 cc f6 ff ff       	jmp    80104d41 <alltraps>

80105675 <vector133>:
.globl vector133
vector133:
  pushl $0
80105675:	6a 00                	push   $0x0
  pushl $133
80105677:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010567c:	e9 c0 f6 ff ff       	jmp    80104d41 <alltraps>

80105681 <vector134>:
.globl vector134
vector134:
  pushl $0
80105681:	6a 00                	push   $0x0
  pushl $134
80105683:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105688:	e9 b4 f6 ff ff       	jmp    80104d41 <alltraps>

8010568d <vector135>:
.globl vector135
vector135:
  pushl $0
8010568d:	6a 00                	push   $0x0
  pushl $135
8010568f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105694:	e9 a8 f6 ff ff       	jmp    80104d41 <alltraps>

80105699 <vector136>:
.globl vector136
vector136:
  pushl $0
80105699:	6a 00                	push   $0x0
  pushl $136
8010569b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056a0:	e9 9c f6 ff ff       	jmp    80104d41 <alltraps>

801056a5 <vector137>:
.globl vector137
vector137:
  pushl $0
801056a5:	6a 00                	push   $0x0
  pushl $137
801056a7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056ac:	e9 90 f6 ff ff       	jmp    80104d41 <alltraps>

801056b1 <vector138>:
.globl vector138
vector138:
  pushl $0
801056b1:	6a 00                	push   $0x0
  pushl $138
801056b3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801056b8:	e9 84 f6 ff ff       	jmp    80104d41 <alltraps>

801056bd <vector139>:
.globl vector139
vector139:
  pushl $0
801056bd:	6a 00                	push   $0x0
  pushl $139
801056bf:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801056c4:	e9 78 f6 ff ff       	jmp    80104d41 <alltraps>

801056c9 <vector140>:
.globl vector140
vector140:
  pushl $0
801056c9:	6a 00                	push   $0x0
  pushl $140
801056cb:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801056d0:	e9 6c f6 ff ff       	jmp    80104d41 <alltraps>

801056d5 <vector141>:
.globl vector141
vector141:
  pushl $0
801056d5:	6a 00                	push   $0x0
  pushl $141
801056d7:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801056dc:	e9 60 f6 ff ff       	jmp    80104d41 <alltraps>

801056e1 <vector142>:
.globl vector142
vector142:
  pushl $0
801056e1:	6a 00                	push   $0x0
  pushl $142
801056e3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801056e8:	e9 54 f6 ff ff       	jmp    80104d41 <alltraps>

801056ed <vector143>:
.globl vector143
vector143:
  pushl $0
801056ed:	6a 00                	push   $0x0
  pushl $143
801056ef:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801056f4:	e9 48 f6 ff ff       	jmp    80104d41 <alltraps>

801056f9 <vector144>:
.globl vector144
vector144:
  pushl $0
801056f9:	6a 00                	push   $0x0
  pushl $144
801056fb:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105700:	e9 3c f6 ff ff       	jmp    80104d41 <alltraps>

80105705 <vector145>:
.globl vector145
vector145:
  pushl $0
80105705:	6a 00                	push   $0x0
  pushl $145
80105707:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010570c:	e9 30 f6 ff ff       	jmp    80104d41 <alltraps>

80105711 <vector146>:
.globl vector146
vector146:
  pushl $0
80105711:	6a 00                	push   $0x0
  pushl $146
80105713:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105718:	e9 24 f6 ff ff       	jmp    80104d41 <alltraps>

8010571d <vector147>:
.globl vector147
vector147:
  pushl $0
8010571d:	6a 00                	push   $0x0
  pushl $147
8010571f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105724:	e9 18 f6 ff ff       	jmp    80104d41 <alltraps>

80105729 <vector148>:
.globl vector148
vector148:
  pushl $0
80105729:	6a 00                	push   $0x0
  pushl $148
8010572b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105730:	e9 0c f6 ff ff       	jmp    80104d41 <alltraps>

80105735 <vector149>:
.globl vector149
vector149:
  pushl $0
80105735:	6a 00                	push   $0x0
  pushl $149
80105737:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010573c:	e9 00 f6 ff ff       	jmp    80104d41 <alltraps>

80105741 <vector150>:
.globl vector150
vector150:
  pushl $0
80105741:	6a 00                	push   $0x0
  pushl $150
80105743:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105748:	e9 f4 f5 ff ff       	jmp    80104d41 <alltraps>

8010574d <vector151>:
.globl vector151
vector151:
  pushl $0
8010574d:	6a 00                	push   $0x0
  pushl $151
8010574f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105754:	e9 e8 f5 ff ff       	jmp    80104d41 <alltraps>

80105759 <vector152>:
.globl vector152
vector152:
  pushl $0
80105759:	6a 00                	push   $0x0
  pushl $152
8010575b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105760:	e9 dc f5 ff ff       	jmp    80104d41 <alltraps>

80105765 <vector153>:
.globl vector153
vector153:
  pushl $0
80105765:	6a 00                	push   $0x0
  pushl $153
80105767:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010576c:	e9 d0 f5 ff ff       	jmp    80104d41 <alltraps>

80105771 <vector154>:
.globl vector154
vector154:
  pushl $0
80105771:	6a 00                	push   $0x0
  pushl $154
80105773:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105778:	e9 c4 f5 ff ff       	jmp    80104d41 <alltraps>

8010577d <vector155>:
.globl vector155
vector155:
  pushl $0
8010577d:	6a 00                	push   $0x0
  pushl $155
8010577f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105784:	e9 b8 f5 ff ff       	jmp    80104d41 <alltraps>

80105789 <vector156>:
.globl vector156
vector156:
  pushl $0
80105789:	6a 00                	push   $0x0
  pushl $156
8010578b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105790:	e9 ac f5 ff ff       	jmp    80104d41 <alltraps>

80105795 <vector157>:
.globl vector157
vector157:
  pushl $0
80105795:	6a 00                	push   $0x0
  pushl $157
80105797:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010579c:	e9 a0 f5 ff ff       	jmp    80104d41 <alltraps>

801057a1 <vector158>:
.globl vector158
vector158:
  pushl $0
801057a1:	6a 00                	push   $0x0
  pushl $158
801057a3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057a8:	e9 94 f5 ff ff       	jmp    80104d41 <alltraps>

801057ad <vector159>:
.globl vector159
vector159:
  pushl $0
801057ad:	6a 00                	push   $0x0
  pushl $159
801057af:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801057b4:	e9 88 f5 ff ff       	jmp    80104d41 <alltraps>

801057b9 <vector160>:
.globl vector160
vector160:
  pushl $0
801057b9:	6a 00                	push   $0x0
  pushl $160
801057bb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801057c0:	e9 7c f5 ff ff       	jmp    80104d41 <alltraps>

801057c5 <vector161>:
.globl vector161
vector161:
  pushl $0
801057c5:	6a 00                	push   $0x0
  pushl $161
801057c7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801057cc:	e9 70 f5 ff ff       	jmp    80104d41 <alltraps>

801057d1 <vector162>:
.globl vector162
vector162:
  pushl $0
801057d1:	6a 00                	push   $0x0
  pushl $162
801057d3:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801057d8:	e9 64 f5 ff ff       	jmp    80104d41 <alltraps>

801057dd <vector163>:
.globl vector163
vector163:
  pushl $0
801057dd:	6a 00                	push   $0x0
  pushl $163
801057df:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801057e4:	e9 58 f5 ff ff       	jmp    80104d41 <alltraps>

801057e9 <vector164>:
.globl vector164
vector164:
  pushl $0
801057e9:	6a 00                	push   $0x0
  pushl $164
801057eb:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801057f0:	e9 4c f5 ff ff       	jmp    80104d41 <alltraps>

801057f5 <vector165>:
.globl vector165
vector165:
  pushl $0
801057f5:	6a 00                	push   $0x0
  pushl $165
801057f7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801057fc:	e9 40 f5 ff ff       	jmp    80104d41 <alltraps>

80105801 <vector166>:
.globl vector166
vector166:
  pushl $0
80105801:	6a 00                	push   $0x0
  pushl $166
80105803:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105808:	e9 34 f5 ff ff       	jmp    80104d41 <alltraps>

8010580d <vector167>:
.globl vector167
vector167:
  pushl $0
8010580d:	6a 00                	push   $0x0
  pushl $167
8010580f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105814:	e9 28 f5 ff ff       	jmp    80104d41 <alltraps>

80105819 <vector168>:
.globl vector168
vector168:
  pushl $0
80105819:	6a 00                	push   $0x0
  pushl $168
8010581b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105820:	e9 1c f5 ff ff       	jmp    80104d41 <alltraps>

80105825 <vector169>:
.globl vector169
vector169:
  pushl $0
80105825:	6a 00                	push   $0x0
  pushl $169
80105827:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010582c:	e9 10 f5 ff ff       	jmp    80104d41 <alltraps>

80105831 <vector170>:
.globl vector170
vector170:
  pushl $0
80105831:	6a 00                	push   $0x0
  pushl $170
80105833:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105838:	e9 04 f5 ff ff       	jmp    80104d41 <alltraps>

8010583d <vector171>:
.globl vector171
vector171:
  pushl $0
8010583d:	6a 00                	push   $0x0
  pushl $171
8010583f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105844:	e9 f8 f4 ff ff       	jmp    80104d41 <alltraps>

80105849 <vector172>:
.globl vector172
vector172:
  pushl $0
80105849:	6a 00                	push   $0x0
  pushl $172
8010584b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105850:	e9 ec f4 ff ff       	jmp    80104d41 <alltraps>

80105855 <vector173>:
.globl vector173
vector173:
  pushl $0
80105855:	6a 00                	push   $0x0
  pushl $173
80105857:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010585c:	e9 e0 f4 ff ff       	jmp    80104d41 <alltraps>

80105861 <vector174>:
.globl vector174
vector174:
  pushl $0
80105861:	6a 00                	push   $0x0
  pushl $174
80105863:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105868:	e9 d4 f4 ff ff       	jmp    80104d41 <alltraps>

8010586d <vector175>:
.globl vector175
vector175:
  pushl $0
8010586d:	6a 00                	push   $0x0
  pushl $175
8010586f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105874:	e9 c8 f4 ff ff       	jmp    80104d41 <alltraps>

80105879 <vector176>:
.globl vector176
vector176:
  pushl $0
80105879:	6a 00                	push   $0x0
  pushl $176
8010587b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105880:	e9 bc f4 ff ff       	jmp    80104d41 <alltraps>

80105885 <vector177>:
.globl vector177
vector177:
  pushl $0
80105885:	6a 00                	push   $0x0
  pushl $177
80105887:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010588c:	e9 b0 f4 ff ff       	jmp    80104d41 <alltraps>

80105891 <vector178>:
.globl vector178
vector178:
  pushl $0
80105891:	6a 00                	push   $0x0
  pushl $178
80105893:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105898:	e9 a4 f4 ff ff       	jmp    80104d41 <alltraps>

8010589d <vector179>:
.globl vector179
vector179:
  pushl $0
8010589d:	6a 00                	push   $0x0
  pushl $179
8010589f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058a4:	e9 98 f4 ff ff       	jmp    80104d41 <alltraps>

801058a9 <vector180>:
.globl vector180
vector180:
  pushl $0
801058a9:	6a 00                	push   $0x0
  pushl $180
801058ab:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801058b0:	e9 8c f4 ff ff       	jmp    80104d41 <alltraps>

801058b5 <vector181>:
.globl vector181
vector181:
  pushl $0
801058b5:	6a 00                	push   $0x0
  pushl $181
801058b7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801058bc:	e9 80 f4 ff ff       	jmp    80104d41 <alltraps>

801058c1 <vector182>:
.globl vector182
vector182:
  pushl $0
801058c1:	6a 00                	push   $0x0
  pushl $182
801058c3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801058c8:	e9 74 f4 ff ff       	jmp    80104d41 <alltraps>

801058cd <vector183>:
.globl vector183
vector183:
  pushl $0
801058cd:	6a 00                	push   $0x0
  pushl $183
801058cf:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801058d4:	e9 68 f4 ff ff       	jmp    80104d41 <alltraps>

801058d9 <vector184>:
.globl vector184
vector184:
  pushl $0
801058d9:	6a 00                	push   $0x0
  pushl $184
801058db:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801058e0:	e9 5c f4 ff ff       	jmp    80104d41 <alltraps>

801058e5 <vector185>:
.globl vector185
vector185:
  pushl $0
801058e5:	6a 00                	push   $0x0
  pushl $185
801058e7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801058ec:	e9 50 f4 ff ff       	jmp    80104d41 <alltraps>

801058f1 <vector186>:
.globl vector186
vector186:
  pushl $0
801058f1:	6a 00                	push   $0x0
  pushl $186
801058f3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801058f8:	e9 44 f4 ff ff       	jmp    80104d41 <alltraps>

801058fd <vector187>:
.globl vector187
vector187:
  pushl $0
801058fd:	6a 00                	push   $0x0
  pushl $187
801058ff:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105904:	e9 38 f4 ff ff       	jmp    80104d41 <alltraps>

80105909 <vector188>:
.globl vector188
vector188:
  pushl $0
80105909:	6a 00                	push   $0x0
  pushl $188
8010590b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105910:	e9 2c f4 ff ff       	jmp    80104d41 <alltraps>

80105915 <vector189>:
.globl vector189
vector189:
  pushl $0
80105915:	6a 00                	push   $0x0
  pushl $189
80105917:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010591c:	e9 20 f4 ff ff       	jmp    80104d41 <alltraps>

80105921 <vector190>:
.globl vector190
vector190:
  pushl $0
80105921:	6a 00                	push   $0x0
  pushl $190
80105923:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105928:	e9 14 f4 ff ff       	jmp    80104d41 <alltraps>

8010592d <vector191>:
.globl vector191
vector191:
  pushl $0
8010592d:	6a 00                	push   $0x0
  pushl $191
8010592f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105934:	e9 08 f4 ff ff       	jmp    80104d41 <alltraps>

80105939 <vector192>:
.globl vector192
vector192:
  pushl $0
80105939:	6a 00                	push   $0x0
  pushl $192
8010593b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105940:	e9 fc f3 ff ff       	jmp    80104d41 <alltraps>

80105945 <vector193>:
.globl vector193
vector193:
  pushl $0
80105945:	6a 00                	push   $0x0
  pushl $193
80105947:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010594c:	e9 f0 f3 ff ff       	jmp    80104d41 <alltraps>

80105951 <vector194>:
.globl vector194
vector194:
  pushl $0
80105951:	6a 00                	push   $0x0
  pushl $194
80105953:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105958:	e9 e4 f3 ff ff       	jmp    80104d41 <alltraps>

8010595d <vector195>:
.globl vector195
vector195:
  pushl $0
8010595d:	6a 00                	push   $0x0
  pushl $195
8010595f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105964:	e9 d8 f3 ff ff       	jmp    80104d41 <alltraps>

80105969 <vector196>:
.globl vector196
vector196:
  pushl $0
80105969:	6a 00                	push   $0x0
  pushl $196
8010596b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105970:	e9 cc f3 ff ff       	jmp    80104d41 <alltraps>

80105975 <vector197>:
.globl vector197
vector197:
  pushl $0
80105975:	6a 00                	push   $0x0
  pushl $197
80105977:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010597c:	e9 c0 f3 ff ff       	jmp    80104d41 <alltraps>

80105981 <vector198>:
.globl vector198
vector198:
  pushl $0
80105981:	6a 00                	push   $0x0
  pushl $198
80105983:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105988:	e9 b4 f3 ff ff       	jmp    80104d41 <alltraps>

8010598d <vector199>:
.globl vector199
vector199:
  pushl $0
8010598d:	6a 00                	push   $0x0
  pushl $199
8010598f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105994:	e9 a8 f3 ff ff       	jmp    80104d41 <alltraps>

80105999 <vector200>:
.globl vector200
vector200:
  pushl $0
80105999:	6a 00                	push   $0x0
  pushl $200
8010599b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059a0:	e9 9c f3 ff ff       	jmp    80104d41 <alltraps>

801059a5 <vector201>:
.globl vector201
vector201:
  pushl $0
801059a5:	6a 00                	push   $0x0
  pushl $201
801059a7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059ac:	e9 90 f3 ff ff       	jmp    80104d41 <alltraps>

801059b1 <vector202>:
.globl vector202
vector202:
  pushl $0
801059b1:	6a 00                	push   $0x0
  pushl $202
801059b3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801059b8:	e9 84 f3 ff ff       	jmp    80104d41 <alltraps>

801059bd <vector203>:
.globl vector203
vector203:
  pushl $0
801059bd:	6a 00                	push   $0x0
  pushl $203
801059bf:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801059c4:	e9 78 f3 ff ff       	jmp    80104d41 <alltraps>

801059c9 <vector204>:
.globl vector204
vector204:
  pushl $0
801059c9:	6a 00                	push   $0x0
  pushl $204
801059cb:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801059d0:	e9 6c f3 ff ff       	jmp    80104d41 <alltraps>

801059d5 <vector205>:
.globl vector205
vector205:
  pushl $0
801059d5:	6a 00                	push   $0x0
  pushl $205
801059d7:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801059dc:	e9 60 f3 ff ff       	jmp    80104d41 <alltraps>

801059e1 <vector206>:
.globl vector206
vector206:
  pushl $0
801059e1:	6a 00                	push   $0x0
  pushl $206
801059e3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801059e8:	e9 54 f3 ff ff       	jmp    80104d41 <alltraps>

801059ed <vector207>:
.globl vector207
vector207:
  pushl $0
801059ed:	6a 00                	push   $0x0
  pushl $207
801059ef:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801059f4:	e9 48 f3 ff ff       	jmp    80104d41 <alltraps>

801059f9 <vector208>:
.globl vector208
vector208:
  pushl $0
801059f9:	6a 00                	push   $0x0
  pushl $208
801059fb:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a00:	e9 3c f3 ff ff       	jmp    80104d41 <alltraps>

80105a05 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a05:	6a 00                	push   $0x0
  pushl $209
80105a07:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a0c:	e9 30 f3 ff ff       	jmp    80104d41 <alltraps>

80105a11 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a11:	6a 00                	push   $0x0
  pushl $210
80105a13:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a18:	e9 24 f3 ff ff       	jmp    80104d41 <alltraps>

80105a1d <vector211>:
.globl vector211
vector211:
  pushl $0
80105a1d:	6a 00                	push   $0x0
  pushl $211
80105a1f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a24:	e9 18 f3 ff ff       	jmp    80104d41 <alltraps>

80105a29 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a29:	6a 00                	push   $0x0
  pushl $212
80105a2b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a30:	e9 0c f3 ff ff       	jmp    80104d41 <alltraps>

80105a35 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a35:	6a 00                	push   $0x0
  pushl $213
80105a37:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a3c:	e9 00 f3 ff ff       	jmp    80104d41 <alltraps>

80105a41 <vector214>:
.globl vector214
vector214:
  pushl $0
80105a41:	6a 00                	push   $0x0
  pushl $214
80105a43:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a48:	e9 f4 f2 ff ff       	jmp    80104d41 <alltraps>

80105a4d <vector215>:
.globl vector215
vector215:
  pushl $0
80105a4d:	6a 00                	push   $0x0
  pushl $215
80105a4f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105a54:	e9 e8 f2 ff ff       	jmp    80104d41 <alltraps>

80105a59 <vector216>:
.globl vector216
vector216:
  pushl $0
80105a59:	6a 00                	push   $0x0
  pushl $216
80105a5b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105a60:	e9 dc f2 ff ff       	jmp    80104d41 <alltraps>

80105a65 <vector217>:
.globl vector217
vector217:
  pushl $0
80105a65:	6a 00                	push   $0x0
  pushl $217
80105a67:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105a6c:	e9 d0 f2 ff ff       	jmp    80104d41 <alltraps>

80105a71 <vector218>:
.globl vector218
vector218:
  pushl $0
80105a71:	6a 00                	push   $0x0
  pushl $218
80105a73:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105a78:	e9 c4 f2 ff ff       	jmp    80104d41 <alltraps>

80105a7d <vector219>:
.globl vector219
vector219:
  pushl $0
80105a7d:	6a 00                	push   $0x0
  pushl $219
80105a7f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105a84:	e9 b8 f2 ff ff       	jmp    80104d41 <alltraps>

80105a89 <vector220>:
.globl vector220
vector220:
  pushl $0
80105a89:	6a 00                	push   $0x0
  pushl $220
80105a8b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105a90:	e9 ac f2 ff ff       	jmp    80104d41 <alltraps>

80105a95 <vector221>:
.globl vector221
vector221:
  pushl $0
80105a95:	6a 00                	push   $0x0
  pushl $221
80105a97:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105a9c:	e9 a0 f2 ff ff       	jmp    80104d41 <alltraps>

80105aa1 <vector222>:
.globl vector222
vector222:
  pushl $0
80105aa1:	6a 00                	push   $0x0
  pushl $222
80105aa3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105aa8:	e9 94 f2 ff ff       	jmp    80104d41 <alltraps>

80105aad <vector223>:
.globl vector223
vector223:
  pushl $0
80105aad:	6a 00                	push   $0x0
  pushl $223
80105aaf:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ab4:	e9 88 f2 ff ff       	jmp    80104d41 <alltraps>

80105ab9 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ab9:	6a 00                	push   $0x0
  pushl $224
80105abb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105ac0:	e9 7c f2 ff ff       	jmp    80104d41 <alltraps>

80105ac5 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ac5:	6a 00                	push   $0x0
  pushl $225
80105ac7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105acc:	e9 70 f2 ff ff       	jmp    80104d41 <alltraps>

80105ad1 <vector226>:
.globl vector226
vector226:
  pushl $0
80105ad1:	6a 00                	push   $0x0
  pushl $226
80105ad3:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105ad8:	e9 64 f2 ff ff       	jmp    80104d41 <alltraps>

80105add <vector227>:
.globl vector227
vector227:
  pushl $0
80105add:	6a 00                	push   $0x0
  pushl $227
80105adf:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105ae4:	e9 58 f2 ff ff       	jmp    80104d41 <alltraps>

80105ae9 <vector228>:
.globl vector228
vector228:
  pushl $0
80105ae9:	6a 00                	push   $0x0
  pushl $228
80105aeb:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105af0:	e9 4c f2 ff ff       	jmp    80104d41 <alltraps>

80105af5 <vector229>:
.globl vector229
vector229:
  pushl $0
80105af5:	6a 00                	push   $0x0
  pushl $229
80105af7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105afc:	e9 40 f2 ff ff       	jmp    80104d41 <alltraps>

80105b01 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b01:	6a 00                	push   $0x0
  pushl $230
80105b03:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b08:	e9 34 f2 ff ff       	jmp    80104d41 <alltraps>

80105b0d <vector231>:
.globl vector231
vector231:
  pushl $0
80105b0d:	6a 00                	push   $0x0
  pushl $231
80105b0f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b14:	e9 28 f2 ff ff       	jmp    80104d41 <alltraps>

80105b19 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b19:	6a 00                	push   $0x0
  pushl $232
80105b1b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b20:	e9 1c f2 ff ff       	jmp    80104d41 <alltraps>

80105b25 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b25:	6a 00                	push   $0x0
  pushl $233
80105b27:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b2c:	e9 10 f2 ff ff       	jmp    80104d41 <alltraps>

80105b31 <vector234>:
.globl vector234
vector234:
  pushl $0
80105b31:	6a 00                	push   $0x0
  pushl $234
80105b33:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b38:	e9 04 f2 ff ff       	jmp    80104d41 <alltraps>

80105b3d <vector235>:
.globl vector235
vector235:
  pushl $0
80105b3d:	6a 00                	push   $0x0
  pushl $235
80105b3f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b44:	e9 f8 f1 ff ff       	jmp    80104d41 <alltraps>

80105b49 <vector236>:
.globl vector236
vector236:
  pushl $0
80105b49:	6a 00                	push   $0x0
  pushl $236
80105b4b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105b50:	e9 ec f1 ff ff       	jmp    80104d41 <alltraps>

80105b55 <vector237>:
.globl vector237
vector237:
  pushl $0
80105b55:	6a 00                	push   $0x0
  pushl $237
80105b57:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105b5c:	e9 e0 f1 ff ff       	jmp    80104d41 <alltraps>

80105b61 <vector238>:
.globl vector238
vector238:
  pushl $0
80105b61:	6a 00                	push   $0x0
  pushl $238
80105b63:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105b68:	e9 d4 f1 ff ff       	jmp    80104d41 <alltraps>

80105b6d <vector239>:
.globl vector239
vector239:
  pushl $0
80105b6d:	6a 00                	push   $0x0
  pushl $239
80105b6f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105b74:	e9 c8 f1 ff ff       	jmp    80104d41 <alltraps>

80105b79 <vector240>:
.globl vector240
vector240:
  pushl $0
80105b79:	6a 00                	push   $0x0
  pushl $240
80105b7b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105b80:	e9 bc f1 ff ff       	jmp    80104d41 <alltraps>

80105b85 <vector241>:
.globl vector241
vector241:
  pushl $0
80105b85:	6a 00                	push   $0x0
  pushl $241
80105b87:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105b8c:	e9 b0 f1 ff ff       	jmp    80104d41 <alltraps>

80105b91 <vector242>:
.globl vector242
vector242:
  pushl $0
80105b91:	6a 00                	push   $0x0
  pushl $242
80105b93:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105b98:	e9 a4 f1 ff ff       	jmp    80104d41 <alltraps>

80105b9d <vector243>:
.globl vector243
vector243:
  pushl $0
80105b9d:	6a 00                	push   $0x0
  pushl $243
80105b9f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105ba4:	e9 98 f1 ff ff       	jmp    80104d41 <alltraps>

80105ba9 <vector244>:
.globl vector244
vector244:
  pushl $0
80105ba9:	6a 00                	push   $0x0
  pushl $244
80105bab:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105bb0:	e9 8c f1 ff ff       	jmp    80104d41 <alltraps>

80105bb5 <vector245>:
.globl vector245
vector245:
  pushl $0
80105bb5:	6a 00                	push   $0x0
  pushl $245
80105bb7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105bbc:	e9 80 f1 ff ff       	jmp    80104d41 <alltraps>

80105bc1 <vector246>:
.globl vector246
vector246:
  pushl $0
80105bc1:	6a 00                	push   $0x0
  pushl $246
80105bc3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105bc8:	e9 74 f1 ff ff       	jmp    80104d41 <alltraps>

80105bcd <vector247>:
.globl vector247
vector247:
  pushl $0
80105bcd:	6a 00                	push   $0x0
  pushl $247
80105bcf:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105bd4:	e9 68 f1 ff ff       	jmp    80104d41 <alltraps>

80105bd9 <vector248>:
.globl vector248
vector248:
  pushl $0
80105bd9:	6a 00                	push   $0x0
  pushl $248
80105bdb:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105be0:	e9 5c f1 ff ff       	jmp    80104d41 <alltraps>

80105be5 <vector249>:
.globl vector249
vector249:
  pushl $0
80105be5:	6a 00                	push   $0x0
  pushl $249
80105be7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105bec:	e9 50 f1 ff ff       	jmp    80104d41 <alltraps>

80105bf1 <vector250>:
.globl vector250
vector250:
  pushl $0
80105bf1:	6a 00                	push   $0x0
  pushl $250
80105bf3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105bf8:	e9 44 f1 ff ff       	jmp    80104d41 <alltraps>

80105bfd <vector251>:
.globl vector251
vector251:
  pushl $0
80105bfd:	6a 00                	push   $0x0
  pushl $251
80105bff:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c04:	e9 38 f1 ff ff       	jmp    80104d41 <alltraps>

80105c09 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c09:	6a 00                	push   $0x0
  pushl $252
80105c0b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c10:	e9 2c f1 ff ff       	jmp    80104d41 <alltraps>

80105c15 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c15:	6a 00                	push   $0x0
  pushl $253
80105c17:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c1c:	e9 20 f1 ff ff       	jmp    80104d41 <alltraps>

80105c21 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c21:	6a 00                	push   $0x0
  pushl $254
80105c23:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c28:	e9 14 f1 ff ff       	jmp    80104d41 <alltraps>

80105c2d <vector255>:
.globl vector255
vector255:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $255
80105c2f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c34:	e9 08 f1 ff ff       	jmp    80104d41 <alltraps>

80105c39 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c39:	55                   	push   %ebp
80105c3a:	89 e5                	mov    %esp,%ebp
80105c3c:	57                   	push   %edi
80105c3d:	56                   	push   %esi
80105c3e:	53                   	push   %ebx
80105c3f:	83 ec 0c             	sub    $0xc,%esp
80105c42:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c44:	c1 ea 16             	shr    $0x16,%edx
80105c47:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c4a:	8b 37                	mov    (%edi),%esi
80105c4c:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105c52:	74 35                	je     80105c89 <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105c54:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
80105c5a:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80105c60:	77 1a                	ja     80105c7c <walkpgdir+0x43>
    return (char*)a + KERNBASE;
80105c62:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105c68:	c1 eb 0c             	shr    $0xc,%ebx
80105c6b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105c71:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c77:	5b                   	pop    %ebx
80105c78:	5e                   	pop    %esi
80105c79:	5f                   	pop    %edi
80105c7a:	5d                   	pop    %ebp
80105c7b:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105c7c:	83 ec 0c             	sub    $0xc,%esp
80105c7f:	68 f8 6c 10 80       	push   $0x80106cf8
80105c84:	e8 bf a6 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105c89:	85 c9                	test   %ecx,%ecx
80105c8b:	74 33                	je     80105cc0 <walkpgdir+0x87>
80105c8d:	e8 37 c4 ff ff       	call   801020c9 <kalloc>
80105c92:	89 c6                	mov    %eax,%esi
80105c94:	85 c0                	test   %eax,%eax
80105c96:	74 28                	je     80105cc0 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
80105c98:	83 ec 04             	sub    $0x4,%esp
80105c9b:	68 00 10 00 00       	push   $0x1000
80105ca0:	6a 00                	push   $0x0
80105ca2:	50                   	push   %eax
80105ca3:	e8 bb df ff ff       	call   80103c63 <memset>
    if (a < (void*) KERNBASE)
80105ca8:	83 c4 10             	add    $0x10,%esp
80105cab:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
80105cb1:	76 14                	jbe    80105cc7 <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
80105cb3:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105cb9:	83 c8 07             	or     $0x7,%eax
80105cbc:	89 07                	mov    %eax,(%edi)
80105cbe:	eb a8                	jmp    80105c68 <walkpgdir+0x2f>
      return 0;
80105cc0:	b8 00 00 00 00       	mov    $0x0,%eax
80105cc5:	eb ad                	jmp    80105c74 <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
80105cc7:	83 ec 0c             	sub    $0xc,%esp
80105cca:	68 c8 69 10 80       	push   $0x801069c8
80105ccf:	e8 74 a6 ff ff       	call   80100348 <panic>

80105cd4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cd4:	55                   	push   %ebp
80105cd5:	89 e5                	mov    %esp,%ebp
80105cd7:	57                   	push   %edi
80105cd8:	56                   	push   %esi
80105cd9:	53                   	push   %ebx
80105cda:	83 ec 1c             	sub    $0x1c,%esp
80105cdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ce0:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ce3:	89 d3                	mov    %edx,%ebx
80105ce5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105ceb:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105cef:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105cf5:	b9 01 00 00 00       	mov    $0x1,%ecx
80105cfa:	89 da                	mov    %ebx,%edx
80105cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cff:	e8 35 ff ff ff       	call   80105c39 <walkpgdir>
80105d04:	85 c0                	test   %eax,%eax
80105d06:	74 2e                	je     80105d36 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105d08:	f6 00 01             	testb  $0x1,(%eax)
80105d0b:	75 1c                	jne    80105d29 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105d0d:	89 f2                	mov    %esi,%edx
80105d0f:	0b 55 0c             	or     0xc(%ebp),%edx
80105d12:	83 ca 01             	or     $0x1,%edx
80105d15:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d17:	39 fb                	cmp    %edi,%ebx
80105d19:	74 28                	je     80105d43 <mappages+0x6f>
      break;
    a += PGSIZE;
80105d1b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d21:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d27:	eb cc                	jmp    80105cf5 <mappages+0x21>
      panic("remap");
80105d29:	83 ec 0c             	sub    $0xc,%esp
80105d2c:	68 e0 70 10 80       	push   $0x801070e0
80105d31:	e8 12 a6 ff ff       	call   80100348 <panic>
      return -1;
80105d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d3e:	5b                   	pop    %ebx
80105d3f:	5e                   	pop    %esi
80105d40:	5f                   	pop    %edi
80105d41:	5d                   	pop    %ebp
80105d42:	c3                   	ret    
  return 0;
80105d43:	b8 00 00 00 00       	mov    $0x0,%eax
80105d48:	eb f1                	jmp    80105d3b <mappages+0x67>

80105d4a <seginit>:
{
80105d4a:	55                   	push   %ebp
80105d4b:	89 e5                	mov    %esp,%ebp
80105d4d:	57                   	push   %edi
80105d4e:	56                   	push   %esi
80105d4f:	53                   	push   %ebx
80105d50:	83 ec 1c             	sub    $0x1c,%esp
  c = &cpus[cpuid()];
80105d53:	e8 a7 d4 ff ff       	call   801031ff <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d58:	69 f8 b0 00 00 00    	imul   $0xb0,%eax,%edi
80105d5e:	66 c7 87 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%edi)
80105d65:	ff ff 
80105d67:	66 c7 87 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%edi)
80105d6e:	00 00 
80105d70:	c6 87 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%edi)
80105d77:	0f b6 8f 1d 18 11 80 	movzbl -0x7feee7e3(%edi),%ecx
80105d7e:	83 e1 f0             	and    $0xfffffff0,%ecx
80105d81:	89 ce                	mov    %ecx,%esi
80105d83:	83 ce 0a             	or     $0xa,%esi
80105d86:	89 f2                	mov    %esi,%edx
80105d88:	88 97 1d 18 11 80    	mov    %dl,-0x7feee7e3(%edi)
80105d8e:	83 c9 1a             	or     $0x1a,%ecx
80105d91:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105d97:	83 e1 9f             	and    $0xffffff9f,%ecx
80105d9a:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105da0:	83 c9 80             	or     $0xffffff80,%ecx
80105da3:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105da9:	0f b6 8f 1e 18 11 80 	movzbl -0x7feee7e2(%edi),%ecx
80105db0:	83 c9 0f             	or     $0xf,%ecx
80105db3:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105db9:	89 ce                	mov    %ecx,%esi
80105dbb:	83 e6 ef             	and    $0xffffffef,%esi
80105dbe:	89 f2                	mov    %esi,%edx
80105dc0:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105dc6:	83 e1 cf             	and    $0xffffffcf,%ecx
80105dc9:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105dcf:	89 ce                	mov    %ecx,%esi
80105dd1:	83 ce 40             	or     $0x40,%esi
80105dd4:	89 f2                	mov    %esi,%edx
80105dd6:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105ddc:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ddf:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105de5:	c6 87 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105dec:	66 c7 87 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%edi)
80105df3:	ff ff 
80105df5:	66 c7 87 22 18 11 80 	movw   $0x0,-0x7feee7de(%edi)
80105dfc:	00 00 
80105dfe:	c6 87 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%edi)
80105e05:	0f b6 8f 25 18 11 80 	movzbl -0x7feee7db(%edi),%ecx
80105e0c:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e0f:	89 ce                	mov    %ecx,%esi
80105e11:	83 ce 02             	or     $0x2,%esi
80105e14:	89 f2                	mov    %esi,%edx
80105e16:	88 97 25 18 11 80    	mov    %dl,-0x7feee7db(%edi)
80105e1c:	83 c9 12             	or     $0x12,%ecx
80105e1f:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e25:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e28:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e2e:	83 c9 80             	or     $0xffffff80,%ecx
80105e31:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105e37:	0f b6 8f 26 18 11 80 	movzbl -0x7feee7da(%edi),%ecx
80105e3e:	83 c9 0f             	or     $0xf,%ecx
80105e41:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105e47:	89 ce                	mov    %ecx,%esi
80105e49:	83 e6 ef             	and    $0xffffffef,%esi
80105e4c:	89 f2                	mov    %esi,%edx
80105e4e:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105e54:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e57:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105e5d:	89 ce                	mov    %ecx,%esi
80105e5f:	83 ce 40             	or     $0x40,%esi
80105e62:	89 f2                	mov    %esi,%edx
80105e64:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80105e6a:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e6d:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105e73:	c6 87 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105e7a:	66 c7 87 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%edi)
80105e81:	ff ff 
80105e83:	66 c7 87 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%edi)
80105e8a:	00 00 
80105e8c:	c6 87 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%edi)
80105e93:	0f b6 9f 2d 18 11 80 	movzbl -0x7feee7d3(%edi),%ebx
80105e9a:	83 e3 f0             	and    $0xfffffff0,%ebx
80105e9d:	89 de                	mov    %ebx,%esi
80105e9f:	83 ce 0a             	or     $0xa,%esi
80105ea2:	89 f2                	mov    %esi,%edx
80105ea4:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105eaa:	89 de                	mov    %ebx,%esi
80105eac:	83 ce 1a             	or     $0x1a,%esi
80105eaf:	89 f2                	mov    %esi,%edx
80105eb1:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80105eb7:	83 cb 7a             	or     $0x7a,%ebx
80105eba:	88 9f 2d 18 11 80    	mov    %bl,-0x7feee7d3(%edi)
80105ec0:	c6 87 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%edi)
80105ec7:	0f b6 9f 2e 18 11 80 	movzbl -0x7feee7d2(%edi),%ebx
80105ece:	83 cb 0f             	or     $0xf,%ebx
80105ed1:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105ed7:	89 de                	mov    %ebx,%esi
80105ed9:	83 e6 ef             	and    $0xffffffef,%esi
80105edc:	89 f2                	mov    %esi,%edx
80105ede:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105ee4:	83 e3 cf             	and    $0xffffffcf,%ebx
80105ee7:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105eed:	89 de                	mov    %ebx,%esi
80105eef:	83 ce 40             	or     $0x40,%esi
80105ef2:	89 f2                	mov    %esi,%edx
80105ef4:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80105efa:	83 cb c0             	or     $0xffffffc0,%ebx
80105efd:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80105f03:	c6 87 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f0a:	66 c7 87 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%edi)
80105f11:	ff ff 
80105f13:	66 c7 87 32 18 11 80 	movw   $0x0,-0x7feee7ce(%edi)
80105f1a:	00 00 
80105f1c:	c6 87 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%edi)
80105f23:	0f b6 9f 35 18 11 80 	movzbl -0x7feee7cb(%edi),%ebx
80105f2a:	83 e3 f0             	and    $0xfffffff0,%ebx
80105f2d:	89 de                	mov    %ebx,%esi
80105f2f:	83 ce 02             	or     $0x2,%esi
80105f32:	89 f2                	mov    %esi,%edx
80105f34:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
80105f3a:	89 de                	mov    %ebx,%esi
80105f3c:	83 ce 12             	or     $0x12,%esi
80105f3f:	89 f2                	mov    %esi,%edx
80105f41:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
80105f47:	83 cb 72             	or     $0x72,%ebx
80105f4a:	88 9f 35 18 11 80    	mov    %bl,-0x7feee7cb(%edi)
80105f50:	c6 87 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%edi)
80105f57:	0f b6 9f 36 18 11 80 	movzbl -0x7feee7ca(%edi),%ebx
80105f5e:	83 cb 0f             	or     $0xf,%ebx
80105f61:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105f67:	89 de                	mov    %ebx,%esi
80105f69:	83 e6 ef             	and    $0xffffffef,%esi
80105f6c:	89 f2                	mov    %esi,%edx
80105f6e:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80105f74:	83 e3 cf             	and    $0xffffffcf,%ebx
80105f77:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105f7d:	89 de                	mov    %ebx,%esi
80105f7f:	83 ce 40             	or     $0x40,%esi
80105f82:	89 f2                	mov    %esi,%edx
80105f84:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80105f8a:	83 cb c0             	or     $0xffffffc0,%ebx
80105f8d:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80105f93:	c6 87 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
80105f9a:	8d 97 10 18 11 80    	lea    -0x7feee7f0(%edi),%edx
  pd[0] = size-1;
80105fa0:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
80105fa6:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
80105faa:	c1 ea 10             	shr    $0x10,%edx
80105fad:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fb1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fb4:	0f 01 10             	lgdtl  (%eax)
}
80105fb7:	83 c4 1c             	add    $0x1c,%esp
80105fba:	5b                   	pop    %ebx
80105fbb:	5e                   	pop    %esi
80105fbc:	5f                   	pop    %edi
80105fbd:	5d                   	pop    %ebp
80105fbe:	c3                   	ret    

80105fbf <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fbf:	a1 c4 44 11 80       	mov    0x801144c4,%eax
    if (a < (void*) KERNBASE)
80105fc4:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
80105fc9:	76 09                	jbe    80105fd4 <switchkvm+0x15>
    return (uint)a - KERNBASE;
80105fcb:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fd0:	0f 22 d8             	mov    %eax,%cr3
80105fd3:	c3                   	ret    
{
80105fd4:	55                   	push   %ebp
80105fd5:	89 e5                	mov    %esp,%ebp
80105fd7:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
80105fda:	68 c8 69 10 80       	push   $0x801069c8
80105fdf:	e8 64 a3 ff ff       	call   80100348 <panic>

80105fe4 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fe4:	55                   	push   %ebp
80105fe5:	89 e5                	mov    %esp,%ebp
80105fe7:	57                   	push   %edi
80105fe8:	56                   	push   %esi
80105fe9:	53                   	push   %ebx
80105fea:	83 ec 1c             	sub    $0x1c,%esp
80105fed:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ff0:	85 f6                	test   %esi,%esi
80105ff2:	0f 84 2c 01 00 00    	je     80106124 <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105ff8:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105ffc:	0f 84 2f 01 00 00    	je     80106131 <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106002:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106006:	0f 84 32 01 00 00    	je     8010613e <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
8010600c:	e8 cb da ff ff       	call   80103adc <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106011:	e8 8d d1 ff ff       	call   801031a3 <mycpu>
80106016:	89 c3                	mov    %eax,%ebx
80106018:	e8 86 d1 ff ff       	call   801031a3 <mycpu>
8010601d:	8d 78 08             	lea    0x8(%eax),%edi
80106020:	e8 7e d1 ff ff       	call   801031a3 <mycpu>
80106025:	83 c0 08             	add    $0x8,%eax
80106028:	c1 e8 10             	shr    $0x10,%eax
8010602b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010602e:	e8 70 d1 ff ff       	call   801031a3 <mycpu>
80106033:	83 c0 08             	add    $0x8,%eax
80106036:	c1 e8 18             	shr    $0x18,%eax
80106039:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106040:	67 00 
80106042:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106049:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010604d:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106053:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010605a:	83 e2 f0             	and    $0xfffffff0,%edx
8010605d:	89 d1                	mov    %edx,%ecx
8010605f:	83 c9 09             	or     $0x9,%ecx
80106062:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
80106068:	83 ca 19             	or     $0x19,%edx
8010606b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106071:	83 e2 9f             	and    $0xffffff9f,%edx
80106074:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010607a:	83 ca 80             	or     $0xffffff80,%edx
8010607d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106083:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
8010608a:	89 d1                	mov    %edx,%ecx
8010608c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010608f:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106095:	89 d1                	mov    %edx,%ecx
80106097:	83 e1 e0             	and    $0xffffffe0,%ecx
8010609a:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
801060a0:	83 e2 c0             	and    $0xffffffc0,%edx
801060a3:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801060a9:	83 ca 40             	or     $0x40,%edx
801060ac:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801060b2:	83 e2 7f             	and    $0x7f,%edx
801060b5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801060bb:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801060c1:	e8 dd d0 ff ff       	call   801031a3 <mycpu>
801060c6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801060cd:	83 e2 ef             	and    $0xffffffef,%edx
801060d0:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801060d6:	e8 c8 d0 ff ff       	call   801031a3 <mycpu>
801060db:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801060e1:	8b 5e 08             	mov    0x8(%esi),%ebx
801060e4:	e8 ba d0 ff ff       	call   801031a3 <mycpu>
801060e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060ef:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801060f2:	e8 ac d0 ff ff       	call   801031a3 <mycpu>
801060f7:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060fd:	b8 28 00 00 00       	mov    $0x28,%eax
80106102:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106105:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
80106108:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010610d:	76 3c                	jbe    8010614b <switchuvm+0x167>
    return (uint)a - KERNBASE;
8010610f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106114:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106117:	e8 fc d9 ff ff       	call   80103b18 <popcli>
}
8010611c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010611f:	5b                   	pop    %ebx
80106120:	5e                   	pop    %esi
80106121:	5f                   	pop    %edi
80106122:	5d                   	pop    %ebp
80106123:	c3                   	ret    
    panic("switchuvm: no process");
80106124:	83 ec 0c             	sub    $0xc,%esp
80106127:	68 e6 70 10 80       	push   $0x801070e6
8010612c:	e8 17 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106131:	83 ec 0c             	sub    $0xc,%esp
80106134:	68 fc 70 10 80       	push   $0x801070fc
80106139:	e8 0a a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
8010613e:	83 ec 0c             	sub    $0xc,%esp
80106141:	68 11 71 10 80       	push   $0x80107111
80106146:	e8 fd a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010614b:	83 ec 0c             	sub    $0xc,%esp
8010614e:	68 c8 69 10 80       	push   $0x801069c8
80106153:	e8 f0 a1 ff ff       	call   80100348 <panic>

80106158 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106158:	55                   	push   %ebp
80106159:	89 e5                	mov    %esp,%ebp
8010615b:	56                   	push   %esi
8010615c:	53                   	push   %ebx
8010615d:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106160:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106166:	77 57                	ja     801061bf <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
80106168:	e8 5c bf ff ff       	call   801020c9 <kalloc>
8010616d:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010616f:	83 ec 04             	sub    $0x4,%esp
80106172:	68 00 10 00 00       	push   $0x1000
80106177:	6a 00                	push   $0x0
80106179:	50                   	push   %eax
8010617a:	e8 e4 da ff ff       	call   80103c63 <memset>
    if (a < (void*) KERNBASE)
8010617f:	83 c4 10             	add    $0x10,%esp
80106182:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106188:	76 42                	jbe    801061cc <inituvm+0x74>
    return (uint)a - KERNBASE;
8010618a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106190:	83 ec 08             	sub    $0x8,%esp
80106193:	6a 06                	push   $0x6
80106195:	50                   	push   %eax
80106196:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010619b:	ba 00 00 00 00       	mov    $0x0,%edx
801061a0:	8b 45 08             	mov    0x8(%ebp),%eax
801061a3:	e8 2c fb ff ff       	call   80105cd4 <mappages>
  memmove(mem, init, sz);
801061a8:	83 c4 0c             	add    $0xc,%esp
801061ab:	56                   	push   %esi
801061ac:	ff 75 0c             	push   0xc(%ebp)
801061af:	53                   	push   %ebx
801061b0:	e8 26 db ff ff       	call   80103cdb <memmove>
}
801061b5:	83 c4 10             	add    $0x10,%esp
801061b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801061bb:	5b                   	pop    %ebx
801061bc:	5e                   	pop    %esi
801061bd:	5d                   	pop    %ebp
801061be:	c3                   	ret    
    panic("inituvm: more than a page");
801061bf:	83 ec 0c             	sub    $0xc,%esp
801061c2:	68 25 71 10 80       	push   $0x80107125
801061c7:	e8 7c a1 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801061cc:	83 ec 0c             	sub    $0xc,%esp
801061cf:	68 c8 69 10 80       	push   $0x801069c8
801061d4:	e8 6f a1 ff ff       	call   80100348 <panic>

801061d9 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801061d9:	55                   	push   %ebp
801061da:	89 e5                	mov    %esp,%ebp
801061dc:	57                   	push   %edi
801061dd:	56                   	push   %esi
801061de:	53                   	push   %ebx
801061df:	83 ec 0c             	sub    $0xc,%esp
801061e2:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801061e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801061e8:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801061ee:	74 43                	je     80106233 <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
801061f0:	83 ec 0c             	sub    $0xc,%esp
801061f3:	68 e0 71 10 80       	push   $0x801071e0
801061f8:	e8 4b a1 ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801061fd:	83 ec 0c             	sub    $0xc,%esp
80106200:	68 3f 71 10 80       	push   $0x8010713f
80106205:	e8 3e a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010620a:	89 da                	mov    %ebx,%edx
8010620c:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
8010620f:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106214:	77 51                	ja     80106267 <loaduvm+0x8e>
    return (char*)a + KERNBASE;
80106216:	05 00 00 00 80       	add    $0x80000000,%eax
8010621b:	56                   	push   %esi
8010621c:	52                   	push   %edx
8010621d:	50                   	push   %eax
8010621e:	ff 75 10             	push   0x10(%ebp)
80106221:	e8 3b b5 ff ff       	call   80101761 <readi>
80106226:	83 c4 10             	add    $0x10,%esp
80106229:	39 f0                	cmp    %esi,%eax
8010622b:	75 54                	jne    80106281 <loaduvm+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
8010622d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106233:	39 fb                	cmp    %edi,%ebx
80106235:	73 3d                	jae    80106274 <loaduvm+0x9b>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106237:	89 da                	mov    %ebx,%edx
80106239:	03 55 0c             	add    0xc(%ebp),%edx
8010623c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106241:	8b 45 08             	mov    0x8(%ebp),%eax
80106244:	e8 f0 f9 ff ff       	call   80105c39 <walkpgdir>
80106249:	85 c0                	test   %eax,%eax
8010624b:	74 b0                	je     801061fd <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
8010624d:	8b 00                	mov    (%eax),%eax
8010624f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106254:	89 fe                	mov    %edi,%esi
80106256:	29 de                	sub    %ebx,%esi
80106258:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010625e:	76 aa                	jbe    8010620a <loaduvm+0x31>
      n = PGSIZE;
80106260:	be 00 10 00 00       	mov    $0x1000,%esi
80106265:	eb a3                	jmp    8010620a <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
80106267:	83 ec 0c             	sub    $0xc,%esp
8010626a:	68 f8 6c 10 80       	push   $0x80106cf8
8010626f:	e8 d4 a0 ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106274:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106279:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010627c:	5b                   	pop    %ebx
8010627d:	5e                   	pop    %esi
8010627e:	5f                   	pop    %edi
8010627f:	5d                   	pop    %ebp
80106280:	c3                   	ret    
      return -1;
80106281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106286:	eb f1                	jmp    80106279 <loaduvm+0xa0>

80106288 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106288:	55                   	push   %ebp
80106289:	89 e5                	mov    %esp,%ebp
8010628b:	57                   	push   %edi
8010628c:	56                   	push   %esi
8010628d:	53                   	push   %ebx
8010628e:	83 ec 0c             	sub    $0xc,%esp
80106291:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106294:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106297:	73 11                	jae    801062aa <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106299:	8b 45 10             	mov    0x10(%ebp),%eax
8010629c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062a2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062a8:	eb 19                	jmp    801062c3 <deallocuvm+0x3b>
    return oldsz;
801062aa:	89 f8                	mov    %edi,%eax
801062ac:	eb 78                	jmp    80106326 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801062ae:	c1 eb 16             	shr    $0x16,%ebx
801062b1:	83 c3 01             	add    $0x1,%ebx
801062b4:	c1 e3 16             	shl    $0x16,%ebx
801062b7:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801062bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062c3:	39 fb                	cmp    %edi,%ebx
801062c5:	73 5c                	jae    80106323 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
801062c7:	b9 00 00 00 00       	mov    $0x0,%ecx
801062cc:	89 da                	mov    %ebx,%edx
801062ce:	8b 45 08             	mov    0x8(%ebp),%eax
801062d1:	e8 63 f9 ff ff       	call   80105c39 <walkpgdir>
801062d6:	89 c6                	mov    %eax,%esi
    if(!pte)
801062d8:	85 c0                	test   %eax,%eax
801062da:	74 d2                	je     801062ae <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801062dc:	8b 00                	mov    (%eax),%eax
801062de:	a8 01                	test   $0x1,%al
801062e0:	74 db                	je     801062bd <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801062e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801062e7:	74 20                	je     80106309 <deallocuvm+0x81>
    if (a > KERNBASE)
801062e9:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801062ee:	77 26                	ja     80106316 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
801062f0:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801062f5:	83 ec 0c             	sub    $0xc,%esp
801062f8:	50                   	push   %eax
801062f9:	e8 8e bc ff ff       	call   80101f8c <kfree>
      *pte = 0;
801062fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106304:	83 c4 10             	add    $0x10,%esp
80106307:	eb b4                	jmp    801062bd <deallocuvm+0x35>
        panic("kfree");
80106309:	83 ec 0c             	sub    $0xc,%esp
8010630c:	68 56 6a 10 80       	push   $0x80106a56
80106311:	e8 32 a0 ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
80106316:	83 ec 0c             	sub    $0xc,%esp
80106319:	68 f8 6c 10 80       	push   $0x80106cf8
8010631e:	e8 25 a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106323:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106326:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106329:	5b                   	pop    %ebx
8010632a:	5e                   	pop    %esi
8010632b:	5f                   	pop    %edi
8010632c:	5d                   	pop    %ebp
8010632d:	c3                   	ret    

8010632e <allocuvm>:
{
8010632e:	55                   	push   %ebp
8010632f:	89 e5                	mov    %esp,%ebp
80106331:	57                   	push   %edi
80106332:	56                   	push   %esi
80106333:	53                   	push   %ebx
80106334:	83 ec 1c             	sub    $0x1c,%esp
80106337:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
8010633a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010633d:	85 ff                	test   %edi,%edi
8010633f:	0f 88 d9 00 00 00    	js     8010641e <allocuvm+0xf0>
  if(newsz < oldsz)
80106345:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106348:	72 67                	jb     801063b1 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
8010634a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010634d:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106353:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106359:	39 fe                	cmp    %edi,%esi
8010635b:	0f 83 c4 00 00 00    	jae    80106425 <allocuvm+0xf7>
    mem = kalloc();
80106361:	e8 63 bd ff ff       	call   801020c9 <kalloc>
80106366:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106368:	85 c0                	test   %eax,%eax
8010636a:	74 4d                	je     801063b9 <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
8010636c:	83 ec 04             	sub    $0x4,%esp
8010636f:	68 00 10 00 00       	push   $0x1000
80106374:	6a 00                	push   $0x0
80106376:	50                   	push   %eax
80106377:	e8 e7 d8 ff ff       	call   80103c63 <memset>
    if (a < (void*) KERNBASE)
8010637c:	83 c4 10             	add    $0x10,%esp
8010637f:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106385:	76 5a                	jbe    801063e1 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106387:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010638d:	83 ec 08             	sub    $0x8,%esp
80106390:	6a 06                	push   $0x6
80106392:	50                   	push   %eax
80106393:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106398:	89 f2                	mov    %esi,%edx
8010639a:	8b 45 08             	mov    0x8(%ebp),%eax
8010639d:	e8 32 f9 ff ff       	call   80105cd4 <mappages>
801063a2:	83 c4 10             	add    $0x10,%esp
801063a5:	85 c0                	test   %eax,%eax
801063a7:	78 45                	js     801063ee <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
801063a9:	81 c6 00 10 00 00    	add    $0x1000,%esi
801063af:	eb a8                	jmp    80106359 <allocuvm+0x2b>
    return oldsz;
801063b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801063b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801063b7:	eb 6c                	jmp    80106425 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
801063b9:	83 ec 0c             	sub    $0xc,%esp
801063bc:	68 5d 71 10 80       	push   $0x8010715d
801063c1:	e8 41 a2 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801063c6:	83 c4 0c             	add    $0xc,%esp
801063c9:	ff 75 0c             	push   0xc(%ebp)
801063cc:	57                   	push   %edi
801063cd:	ff 75 08             	push   0x8(%ebp)
801063d0:	e8 b3 fe ff ff       	call   80106288 <deallocuvm>
      return 0;
801063d5:	83 c4 10             	add    $0x10,%esp
801063d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801063df:	eb 44                	jmp    80106425 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
801063e1:	83 ec 0c             	sub    $0xc,%esp
801063e4:	68 c8 69 10 80       	push   $0x801069c8
801063e9:	e8 5a 9f ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
801063ee:	83 ec 0c             	sub    $0xc,%esp
801063f1:	68 75 71 10 80       	push   $0x80107175
801063f6:	e8 0c a2 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801063fb:	83 c4 0c             	add    $0xc,%esp
801063fe:	ff 75 0c             	push   0xc(%ebp)
80106401:	57                   	push   %edi
80106402:	ff 75 08             	push   0x8(%ebp)
80106405:	e8 7e fe ff ff       	call   80106288 <deallocuvm>
      kfree(mem);
8010640a:	89 1c 24             	mov    %ebx,(%esp)
8010640d:	e8 7a bb ff ff       	call   80101f8c <kfree>
      return 0;
80106412:	83 c4 10             	add    $0x10,%esp
80106415:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010641c:	eb 07                	jmp    80106425 <allocuvm+0xf7>
    return 0;
8010641e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106428:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010642b:	5b                   	pop    %ebx
8010642c:	5e                   	pop    %esi
8010642d:	5f                   	pop    %edi
8010642e:	5d                   	pop    %ebp
8010642f:	c3                   	ret    

80106430 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106430:	55                   	push   %ebp
80106431:	89 e5                	mov    %esp,%ebp
80106433:	56                   	push   %esi
80106434:	53                   	push   %ebx
80106435:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106438:	85 f6                	test   %esi,%esi
8010643a:	74 1a                	je     80106456 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010643c:	83 ec 04             	sub    $0x4,%esp
8010643f:	6a 00                	push   $0x0
80106441:	68 00 00 00 80       	push   $0x80000000
80106446:	56                   	push   %esi
80106447:	e8 3c fe ff ff       	call   80106288 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010644c:	83 c4 10             	add    $0x10,%esp
8010644f:	bb 00 00 00 00       	mov    $0x0,%ebx
80106454:	eb 21                	jmp    80106477 <freevm+0x47>
    panic("freevm: no pgdir");
80106456:	83 ec 0c             	sub    $0xc,%esp
80106459:	68 91 71 10 80       	push   $0x80107191
8010645e:	e8 e5 9e ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
80106463:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106468:	83 ec 0c             	sub    $0xc,%esp
8010646b:	50                   	push   %eax
8010646c:	e8 1b bb ff ff       	call   80101f8c <kfree>
80106471:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106474:	83 c3 01             	add    $0x1,%ebx
80106477:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
8010647d:	77 20                	ja     8010649f <freevm+0x6f>
    if(pgdir[i] & PTE_P){
8010647f:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106482:	a8 01                	test   $0x1,%al
80106484:	74 ee                	je     80106474 <freevm+0x44>
80106486:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010648b:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106490:	76 d1                	jbe    80106463 <freevm+0x33>
        panic("P2V on address > KERNBASE");
80106492:	83 ec 0c             	sub    $0xc,%esp
80106495:	68 f8 6c 10 80       	push   $0x80106cf8
8010649a:	e8 a9 9e ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
8010649f:	83 ec 0c             	sub    $0xc,%esp
801064a2:	56                   	push   %esi
801064a3:	e8 e4 ba ff ff       	call   80101f8c <kfree>
}
801064a8:	83 c4 10             	add    $0x10,%esp
801064ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064ae:	5b                   	pop    %ebx
801064af:	5e                   	pop    %esi
801064b0:	5d                   	pop    %ebp
801064b1:	c3                   	ret    

801064b2 <setupkvm>:
{
801064b2:	55                   	push   %ebp
801064b3:	89 e5                	mov    %esp,%ebp
801064b5:	56                   	push   %esi
801064b6:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801064b7:	e8 0d bc ff ff       	call   801020c9 <kalloc>
801064bc:	89 c6                	mov    %eax,%esi
801064be:	85 c0                	test   %eax,%eax
801064c0:	74 55                	je     80106517 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801064c2:	83 ec 04             	sub    $0x4,%esp
801064c5:	68 00 10 00 00       	push   $0x1000
801064ca:	6a 00                	push   $0x0
801064cc:	50                   	push   %eax
801064cd:	e8 91 d7 ff ff       	call   80103c63 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801064d2:	83 c4 10             	add    $0x10,%esp
801064d5:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801064da:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801064e0:	73 35                	jae    80106517 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801064e2:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801064e5:	8b 4b 08             	mov    0x8(%ebx),%ecx
801064e8:	29 c1                	sub    %eax,%ecx
801064ea:	83 ec 08             	sub    $0x8,%esp
801064ed:	ff 73 0c             	push   0xc(%ebx)
801064f0:	50                   	push   %eax
801064f1:	8b 13                	mov    (%ebx),%edx
801064f3:	89 f0                	mov    %esi,%eax
801064f5:	e8 da f7 ff ff       	call   80105cd4 <mappages>
801064fa:	83 c4 10             	add    $0x10,%esp
801064fd:	85 c0                	test   %eax,%eax
801064ff:	78 05                	js     80106506 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106501:	83 c3 10             	add    $0x10,%ebx
80106504:	eb d4                	jmp    801064da <setupkvm+0x28>
      freevm(pgdir);
80106506:	83 ec 0c             	sub    $0xc,%esp
80106509:	56                   	push   %esi
8010650a:	e8 21 ff ff ff       	call   80106430 <freevm>
      return 0;
8010650f:	83 c4 10             	add    $0x10,%esp
80106512:	be 00 00 00 00       	mov    $0x0,%esi
}
80106517:	89 f0                	mov    %esi,%eax
80106519:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010651c:	5b                   	pop    %ebx
8010651d:	5e                   	pop    %esi
8010651e:	5d                   	pop    %ebp
8010651f:	c3                   	ret    

80106520 <kvmalloc>:
{
80106520:	55                   	push   %ebp
80106521:	89 e5                	mov    %esp,%ebp
80106523:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106526:	e8 87 ff ff ff       	call   801064b2 <setupkvm>
8010652b:	a3 c4 44 11 80       	mov    %eax,0x801144c4
  switchkvm();
80106530:	e8 8a fa ff ff       	call   80105fbf <switchkvm>
}
80106535:	c9                   	leave  
80106536:	c3                   	ret    

80106537 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106537:	55                   	push   %ebp
80106538:	89 e5                	mov    %esp,%ebp
8010653a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010653d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106542:	8b 55 0c             	mov    0xc(%ebp),%edx
80106545:	8b 45 08             	mov    0x8(%ebp),%eax
80106548:	e8 ec f6 ff ff       	call   80105c39 <walkpgdir>
  if(pte == 0)
8010654d:	85 c0                	test   %eax,%eax
8010654f:	74 05                	je     80106556 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106551:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106554:	c9                   	leave  
80106555:	c3                   	ret    
    panic("clearpteu");
80106556:	83 ec 0c             	sub    $0xc,%esp
80106559:	68 a2 71 10 80       	push   $0x801071a2
8010655e:	e8 e5 9d ff ff       	call   80100348 <panic>

80106563 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106563:	55                   	push   %ebp
80106564:	89 e5                	mov    %esp,%ebp
80106566:	57                   	push   %edi
80106567:	56                   	push   %esi
80106568:	53                   	push   %ebx
80106569:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010656c:	e8 41 ff ff ff       	call   801064b2 <setupkvm>
80106571:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106574:	85 c0                	test   %eax,%eax
80106576:	0f 84 f2 00 00 00    	je     8010666e <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010657c:	bf 00 00 00 00       	mov    $0x0,%edi
80106581:	eb 3a                	jmp    801065bd <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106583:	83 ec 0c             	sub    $0xc,%esp
80106586:	68 ac 71 10 80       	push   $0x801071ac
8010658b:	e8 b8 9d ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106590:	83 ec 0c             	sub    $0xc,%esp
80106593:	68 c6 71 10 80       	push   $0x801071c6
80106598:	e8 ab 9d ff ff       	call   80100348 <panic>
8010659d:	83 ec 0c             	sub    $0xc,%esp
801065a0:	68 f8 6c 10 80       	push   $0x80106cf8
801065a5:	e8 9e 9d ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801065aa:	83 ec 0c             	sub    $0xc,%esp
801065ad:	68 c8 69 10 80       	push   $0x801069c8
801065b2:	e8 91 9d ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801065b7:	81 c7 00 10 00 00    	add    $0x1000,%edi
801065bd:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801065c0:	0f 83 a8 00 00 00    	jae    8010666e <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801065c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801065c9:	b9 00 00 00 00       	mov    $0x0,%ecx
801065ce:	89 fa                	mov    %edi,%edx
801065d0:	8b 45 08             	mov    0x8(%ebp),%eax
801065d3:	e8 61 f6 ff ff       	call   80105c39 <walkpgdir>
801065d8:	85 c0                	test   %eax,%eax
801065da:	74 a7                	je     80106583 <copyuvm+0x20>
    if(!(*pte & PTE_P))
801065dc:	8b 00                	mov    (%eax),%eax
801065de:	a8 01                	test   $0x1,%al
801065e0:	74 ae                	je     80106590 <copyuvm+0x2d>
801065e2:	89 c6                	mov    %eax,%esi
801065e4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
801065ea:	25 ff 0f 00 00       	and    $0xfff,%eax
801065ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801065f2:	e8 d2 ba ff ff       	call   801020c9 <kalloc>
801065f7:	89 c3                	mov    %eax,%ebx
801065f9:	85 c0                	test   %eax,%eax
801065fb:	74 5c                	je     80106659 <copyuvm+0xf6>
    if (a > KERNBASE)
801065fd:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80106603:	77 98                	ja     8010659d <copyuvm+0x3a>
    return (char*)a + KERNBASE;
80106605:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010660b:	83 ec 04             	sub    $0x4,%esp
8010660e:	68 00 10 00 00       	push   $0x1000
80106613:	56                   	push   %esi
80106614:	50                   	push   %eax
80106615:	e8 c1 d6 ff ff       	call   80103cdb <memmove>
    if (a < (void*) KERNBASE)
8010661a:	83 c4 10             	add    $0x10,%esp
8010661d:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106623:	76 85                	jbe    801065aa <copyuvm+0x47>
    return (uint)a - KERNBASE;
80106625:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010662b:	83 ec 08             	sub    $0x8,%esp
8010662e:	ff 75 e0             	push   -0x20(%ebp)
80106631:	50                   	push   %eax
80106632:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106637:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010663a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010663d:	e8 92 f6 ff ff       	call   80105cd4 <mappages>
80106642:	83 c4 10             	add    $0x10,%esp
80106645:	85 c0                	test   %eax,%eax
80106647:	0f 89 6a ff ff ff    	jns    801065b7 <copyuvm+0x54>
      kfree(mem);
8010664d:	83 ec 0c             	sub    $0xc,%esp
80106650:	53                   	push   %ebx
80106651:	e8 36 b9 ff ff       	call   80101f8c <kfree>
      goto bad;
80106656:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106659:	83 ec 0c             	sub    $0xc,%esp
8010665c:	ff 75 dc             	push   -0x24(%ebp)
8010665f:	e8 cc fd ff ff       	call   80106430 <freevm>
  return 0;
80106664:	83 c4 10             	add    $0x10,%esp
80106667:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010666e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106671:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106674:	5b                   	pop    %ebx
80106675:	5e                   	pop    %esi
80106676:	5f                   	pop    %edi
80106677:	5d                   	pop    %ebp
80106678:	c3                   	ret    

80106679 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010667f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106684:	8b 55 0c             	mov    0xc(%ebp),%edx
80106687:	8b 45 08             	mov    0x8(%ebp),%eax
8010668a:	e8 aa f5 ff ff       	call   80105c39 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010668f:	8b 00                	mov    (%eax),%eax
80106691:	a8 01                	test   $0x1,%al
80106693:	74 24                	je     801066b9 <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106695:	a8 04                	test   $0x4,%al
80106697:	74 27                	je     801066c0 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80106699:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010669e:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801066a3:	77 07                	ja     801066ac <uva2ka+0x33>
    return (char*)a + KERNBASE;
801066a5:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
801066aa:	c9                   	leave  
801066ab:	c3                   	ret    
        panic("P2V on address > KERNBASE");
801066ac:	83 ec 0c             	sub    $0xc,%esp
801066af:	68 f8 6c 10 80       	push   $0x80106cf8
801066b4:	e8 8f 9c ff ff       	call   80100348 <panic>
    return 0;
801066b9:	b8 00 00 00 00       	mov    $0x0,%eax
801066be:	eb ea                	jmp    801066aa <uva2ka+0x31>
    return 0;
801066c0:	b8 00 00 00 00       	mov    $0x0,%eax
801066c5:	eb e3                	jmp    801066aa <uva2ka+0x31>

801066c7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801066c7:	55                   	push   %ebp
801066c8:	89 e5                	mov    %esp,%ebp
801066ca:	57                   	push   %edi
801066cb:	56                   	push   %esi
801066cc:	53                   	push   %ebx
801066cd:	83 ec 0c             	sub    $0xc,%esp
801066d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801066d3:	eb 25                	jmp    801066fa <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801066d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801066d8:	29 f2                	sub    %esi,%edx
801066da:	01 d0                	add    %edx,%eax
801066dc:	83 ec 04             	sub    $0x4,%esp
801066df:	53                   	push   %ebx
801066e0:	ff 75 10             	push   0x10(%ebp)
801066e3:	50                   	push   %eax
801066e4:	e8 f2 d5 ff ff       	call   80103cdb <memmove>
    len -= n;
801066e9:	29 df                	sub    %ebx,%edi
    buf += n;
801066eb:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801066ee:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801066f4:	89 45 0c             	mov    %eax,0xc(%ebp)
801066f7:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801066fa:	85 ff                	test   %edi,%edi
801066fc:	74 2f                	je     8010672d <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801066fe:	8b 75 0c             	mov    0xc(%ebp),%esi
80106701:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106707:	83 ec 08             	sub    $0x8,%esp
8010670a:	56                   	push   %esi
8010670b:	ff 75 08             	push   0x8(%ebp)
8010670e:	e8 66 ff ff ff       	call   80106679 <uva2ka>
    if(pa0 == 0)
80106713:	83 c4 10             	add    $0x10,%esp
80106716:	85 c0                	test   %eax,%eax
80106718:	74 20                	je     8010673a <copyout+0x73>
    n = PGSIZE - (va - va0);
8010671a:	89 f3                	mov    %esi,%ebx
8010671c:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010671f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106725:	39 df                	cmp    %ebx,%edi
80106727:	73 ac                	jae    801066d5 <copyout+0xe>
      n = len;
80106729:	89 fb                	mov    %edi,%ebx
8010672b:	eb a8                	jmp    801066d5 <copyout+0xe>
  }
  return 0;
8010672d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106732:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106735:	5b                   	pop    %ebx
80106736:	5e                   	pop    %esi
80106737:	5f                   	pop    %edi
80106738:	5d                   	pop    %ebp
80106739:	c3                   	ret    
      return -1;
8010673a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673f:	eb f1                	jmp    80106732 <copyout+0x6b>
