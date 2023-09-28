
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
80100028:	bc d0 56 11 80       	mov    $0x801156d0,%esp

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
80100046:	e8 19 3d 00 00       	call   80103d64 <acquire>

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
8010007c:	e8 48 3d 00 00       	call   80103dc9 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 c4 3a 00 00       	call   80103b50 <acquiresleep>
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
801000ca:	e8 fa 3c 00 00       	call   80103dc9 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 76 3a 00 00       	call   80103b50 <acquiresleep>
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
801000ea:	68 00 69 10 80       	push   $0x80106900
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 69 10 80       	push   $0x80106911
80100100:	68 20 a5 10 80       	push   $0x8010a520
80100105:	e8 1e 3b 00 00       	call   80103c28 <initlock>
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
8010013a:	68 18 69 10 80       	push   $0x80106918
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 d5 39 00 00       	call   80103b1d <initsleeplock>
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
801001a8:	e8 2d 3a 00 00       	call   80103bda <holdingsleep>
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
801001cb:	68 1f 69 10 80       	push   $0x8010691f
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
801001e4:	e8 f1 39 00 00       	call   80103bda <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 a6 39 00 00       	call   80103b9f <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100200:	e8 5f 3b 00 00       	call   80103d64 <acquire>
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
8010024c:	e8 78 3b 00 00       	call   80103dc9 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 69 10 80       	push   $0x80106926
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
8010028a:	e8 d5 3a 00 00       	call   80103d64 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 00 ef 10 80       	mov    0x8010ef00,%eax
8010029f:	3b 05 04 ef 10 80    	cmp    0x8010ef04,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 fd 2f 00 00       	call   801032a9 <myproc>
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
801002bf:	e8 fa 34 00 00       	call   801037be <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 ef 10 80       	push   $0x8010ef20
801002d1:	e8 f3 3a 00 00       	call   80103dc9 <release>
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
80100331:	e8 93 3a 00 00       	call   80103dc9 <release>
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
80100363:	68 2d 69 10 80       	push   $0x8010692d
80100368:	e8 9a 02 00 00       	call   80100607 <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	push   0x8(%ebp)
80100373:	e8 8f 02 00 00       	call   80100607 <cprintf>
  cprintf("\n");
80100378:	c7 04 24 2f 73 10 80 	movl   $0x8010732f,(%esp)
8010037f:	e8 83 02 00 00       	call   80100607 <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 af 38 00 00       	call   80103c43 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	push   -0x30(%ebp,%ebx,4)
801003a5:	68 41 69 10 80       	push   $0x80106941
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
80100492:	68 45 69 10 80       	push   $0x80106945
80100497:	e8 ac fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	68 60 0e 00 00       	push   $0xe60
801004a4:	68 a0 80 0b 80       	push   $0x800b80a0
801004a9:	68 00 80 0b 80       	push   $0x800b8000
801004ae:	e8 d5 39 00 00       	call   80103e88 <memmove>
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
801004cd:	e8 3e 39 00 00       	call   80103e10 <memset>
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
801004fa:	e8 7d 4d 00 00       	call   8010527c <uartputc>
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
80100513:	e8 64 4d 00 00       	call   8010527c <uartputc>
80100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010051f:	e8 58 4d 00 00       	call   8010527c <uartputc>
80100524:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010052b:	e8 4c 4d 00 00       	call   8010527c <uartputc>
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
80100568:	0f b6 92 70 69 10 80 	movzbl -0x7fef9690(%edx),%edx
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
801005c6:	e8 99 37 00 00       	call   80103d64 <acquire>
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
801005ed:	e8 d7 37 00 00       	call   80103dc9 <release>
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
80100634:	e8 2b 37 00 00       	call   80103d64 <acquire>
80100639:	83 c4 10             	add    $0x10,%esp
8010063c:	eb de                	jmp    8010061c <cprintf+0x15>
    panic("null fmt");
8010063e:	83 ec 0c             	sub    $0xc,%esp
80100641:	68 5f 69 10 80       	push   $0x8010695f
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
801006cd:	bb 58 69 10 80       	mov    $0x80106958,%ebx
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
80100729:	e8 9b 36 00 00       	call   80103dc9 <release>
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
80100744:	e8 1b 36 00 00       	call   80103d64 <acquire>
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
801007f2:	e8 2f 31 00 00       	call   80103926 <wakeup>
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
8010086f:	e8 55 35 00 00       	call   80103dc9 <release>
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
80100883:	e8 3d 31 00 00       	call   801039c5 <procdump>
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
80100890:	68 68 69 10 80       	push   $0x80106968
80100895:	68 20 ef 10 80       	push   $0x8010ef20
8010089a:	e8 89 33 00 00       	call   80103c28 <initlock>

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
801008da:	e8 ca 29 00 00       	call   801032a9 <myproc>
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
8010095a:	68 81 69 10 80       	push   $0x80106981
8010095f:	e8 a3 fc ff ff       	call   80100607 <cprintf>
    return -1;
80100964:	83 c4 10             	add    $0x10,%esp
80100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096c:	eb dc                	jmp    8010094a <exec+0x7c>
  if((pgdir = setupkvm()) == 0)
8010096e:	e8 f0 5c 00 00       	call   80106663 <setupkvm>
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
80100a02:	e8 d8 5a 00 00       	call   801064df <allocuvm>
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
80100a34:	e8 51 59 00 00       	call   8010638a <loaduvm>
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
80100a71:	e8 69 5a 00 00       	call   801064df <allocuvm>
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
80100a9c:	e8 40 5b 00 00       	call   801065e1 <freevm>
80100aa1:	83 c4 10             	add    $0x10,%esp
80100aa4:	e9 83 fe ff ff       	jmp    8010092c <exec+0x5e>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aa9:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100aaf:	83 ec 08             	sub    $0x8,%esp
80100ab2:	50                   	push   %eax
80100ab3:	57                   	push   %edi
80100ab4:	e8 2f 5c 00 00       	call   801066e8 <clearpteu>
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
80100ae6:	e8 ce 34 00 00       	call   80103fb9 <strlen>
80100aeb:	29 c6                	sub    %eax,%esi
80100aed:	83 ee 01             	sub    $0x1,%esi
80100af0:	83 e6 fc             	and    $0xfffffffc,%esi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100af3:	83 c4 04             	add    $0x4,%esp
80100af6:	ff 33                	push   (%ebx)
80100af8:	e8 bc 34 00 00       	call   80103fb9 <strlen>
80100afd:	83 c0 01             	add    $0x1,%eax
80100b00:	50                   	push   %eax
80100b01:	ff 33                	push   (%ebx)
80100b03:	56                   	push   %esi
80100b04:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b0a:	e8 69 5d 00 00       	call   80106878 <copyout>
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
80100b6a:	e8 09 5d 00 00       	call   80106878 <copyout>
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
80100ba7:	e8 d0 33 00 00       	call   80103f7c <safestrcpy>
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
80100bd5:	e8 bb 55 00 00       	call   80106195 <switchuvm>
  freevm(oldpgdir);
80100bda:	89 1c 24             	mov    %ebx,(%esp)
80100bdd:	e8 ff 59 00 00       	call   801065e1 <freevm>
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
80100c09:	68 8d 69 10 80       	push   $0x8010698d
80100c0e:	68 60 ef 10 80       	push   $0x8010ef60
80100c13:	e8 10 30 00 00       	call   80103c28 <initlock>
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
80100c29:	e8 36 31 00 00       	call   80103d64 <acquire>
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
80100c58:	e8 6c 31 00 00       	call   80103dc9 <release>
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
80100c6f:	e8 55 31 00 00       	call   80103dc9 <release>
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
80100c8d:	e8 d2 30 00 00       	call   80103d64 <acquire>
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
80100caa:	e8 1a 31 00 00       	call   80103dc9 <release>
  return f;
}
80100caf:	89 d8                	mov    %ebx,%eax
80100cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cb4:	c9                   	leave  
80100cb5:	c3                   	ret    
    panic("filedup");
80100cb6:	83 ec 0c             	sub    $0xc,%esp
80100cb9:	68 94 69 10 80       	push   $0x80106994
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
80100cd2:	e8 8d 30 00 00       	call   80103d64 <acquire>
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
80100d23:	e8 a1 30 00 00       	call   80103dc9 <release>

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
80100d55:	68 9c 69 10 80       	push   $0x8010699c
80100d5a:	e8 e9 f5 ff ff       	call   80100348 <panic>
    release(&ftable.lock);
80100d5f:	83 ec 0c             	sub    $0xc,%esp
80100d62:	68 60 ef 10 80       	push   $0x8010ef60
80100d67:	e8 5d 30 00 00       	call   80103dc9 <release>
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
80100e44:	68 a6 69 10 80       	push   $0x801069a6
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
80100f0a:	68 af 69 10 80       	push   $0x801069af
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
80100f31:	68 b5 69 10 80       	push   $0x801069b5
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
80100f81:	e8 02 2f 00 00       	call   80103e88 <memmove>
80100f86:	83 c4 10             	add    $0x10,%esp
80100f89:	eb 17                	jmp    80100fa2 <skipelem+0x60>
  else {
    memmove(name, s, len);
80100f8b:	83 ec 04             	sub    $0x4,%esp
80100f8e:	57                   	push   %edi
80100f8f:	50                   	push   %eax
80100f90:	56                   	push   %esi
80100f91:	e8 f2 2e 00 00       	call   80103e88 <memmove>
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
80100fd6:	e8 35 2e 00 00       	call   80103e10 <memset>
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
8010105f:	68 bf 69 10 80       	push   $0x801069bf
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
80101116:	68 d2 69 10 80       	push   $0x801069d2
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
801011ed:	68 e8 69 10 80       	push   $0x801069e8
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
8010120a:	e8 55 2b 00 00       	call   80103d64 <acquire>
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
80101251:	e8 73 2b 00 00       	call   80103dc9 <release>
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
80101287:	e8 3d 2b 00 00       	call   80103dc9 <release>
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
8010129c:	68 fb 69 10 80       	push   $0x801069fb
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
801012c5:	e8 be 2b 00 00       	call   80103e88 <memmove>
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
801012e1:	68 0b 6a 10 80       	push   $0x80106a0b
801012e6:	68 60 f9 10 80       	push   $0x8010f960
801012eb:	e8 38 29 00 00       	call   80103c28 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 12 6a 10 80       	push   $0x80106a12
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 a0 f9 10 80       	add    $0x8010f9a0,%eax
8010130f:	50                   	push   %eax
80101310:	e8 08 28 00 00       	call   80103b1d <initsleeplock>
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
8010135a:	68 78 6a 10 80       	push   $0x80106a78
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
801013cd:	68 18 6a 10 80       	push   $0x80106a18
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 2c 2a 00 00       	call   80103e10 <memset>
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
8010146e:	e8 15 2a 00 00       	call   80103e88 <memmove>
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
8010154e:	e8 11 28 00 00       	call   80103d64 <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
80101563:	e8 61 28 00 00       	call   80103dc9 <release>
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
80101588:	e8 c3 25 00 00       	call   80103b50 <acquiresleep>
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
801015a0:	68 2a 6a 10 80       	push   $0x80106a2a
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
80101602:	e8 81 28 00 00       	call   80103e88 <memmove>
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
80101627:	68 30 6a 10 80       	push   $0x80106a30
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
80101644:	e8 91 25 00 00       	call   80103bda <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 40 25 00 00       	call   80103b9f <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 3f 6a 10 80       	push   $0x80106a3f
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
80101686:	e8 c5 24 00 00       	call   80103b50 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 fb 24 00 00       	call   80103b9f <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016ab:	e8 b4 26 00 00       	call   80103d64 <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016c0:	e8 04 27 00 00       	call   80103dc9 <release>
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
801016d8:	e8 87 26 00 00       	call   80103d64 <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 60 f9 10 80 	movl   $0x8010f960,(%esp)
801016e7:	e8 dd 26 00 00       	call   80103dc9 <release>
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
80101818:	e8 6b 26 00 00       	call   80103e88 <memmove>
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
80101915:	e8 6e 25 00 00       	call   80103e88 <memmove>
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
80101998:	e8 57 25 00 00       	call   80103ef4 <strncmp>
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
801019bf:	68 47 6a 10 80       	push   $0x80106a47
801019c4:	e8 7f e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	68 59 6a 10 80       	push   $0x80106a59
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
80101a49:	e8 5b 18 00 00       	call   801032a9 <myproc>
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
80101b7e:	68 68 6a 10 80       	push   $0x80106a68
80101b83:	e8 c0 e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b88:	83 ec 04             	sub    $0x4,%esp
80101b8b:	6a 0e                	push   $0xe
80101b8d:	57                   	push   %edi
80101b8e:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b91:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b94:	50                   	push   %eax
80101b95:	e8 99 23 00 00       	call   80103f33 <strncpy>
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
80101bc3:	68 28 71 10 80       	push   $0x80107128
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
80101cc5:	68 cb 6a 10 80       	push   $0x80106acb
80101cca:	e8 79 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101ccf:	83 ec 0c             	sub    $0xc,%esp
80101cd2:	68 d4 6a 10 80       	push   $0x80106ad4
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
80101cef:	68 e6 6a 10 80       	push   $0x80106ae6
80101cf4:	68 00 16 11 80       	push   $0x80111600
80101cf9:	e8 2a 1f 00 00       	call   80103c28 <initlock>
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
80101d69:	e8 f6 1f 00 00       	call   80103d64 <acquire>

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
80101d98:	e8 89 1b 00 00       	call   80103926 <wakeup>

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
80101db6:	e8 0e 20 00 00       	call   80103dc9 <release>
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
80101dcd:	e8 f7 1f 00 00       	call   80103dc9 <release>
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
80101e05:	e8 d0 1d 00 00       	call   80103bda <holdingsleep>
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
80101e32:	e8 2d 1f 00 00       	call   80103d64 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e37:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e3e:	83 c4 10             	add    $0x10,%esp
80101e41:	ba e4 15 11 80       	mov    $0x801115e4,%edx
80101e46:	eb 2a                	jmp    80101e72 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e48:	83 ec 0c             	sub    $0xc,%esp
80101e4b:	68 ea 6a 10 80       	push   $0x80106aea
80101e50:	e8 f3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e55:	83 ec 0c             	sub    $0xc,%esp
80101e58:	68 00 6b 10 80       	push   $0x80106b00
80101e5d:	e8 e6 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e62:	83 ec 0c             	sub    $0xc,%esp
80101e65:	68 15 6b 10 80       	push   $0x80106b15
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
80101e94:	e8 25 19 00 00       	call   801037be <sleep>
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
80101eae:	e8 16 1f 00 00       	call   80103dc9 <release>
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
80101f22:	68 34 6b 10 80       	push   $0x80106b34
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
80101f9e:	81 fb d0 56 11 80    	cmp    $0x801156d0,%ebx
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
80101fc6:	e8 45 1e 00 00       	call   80103e10 <memset>

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
80101ff5:	68 68 6b 10 80       	push   $0x80106b68
80101ffa:	e8 49 e3 ff ff       	call   80100348 <panic>
    panic("kfree");
80101fff:	83 ec 0c             	sub    $0xc,%esp
80102002:	68 f6 6b 10 80       	push   $0x80106bf6
80102007:	e8 3c e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200c:	83 ec 0c             	sub    $0xc,%esp
8010200f:	68 40 16 11 80       	push   $0x80111640
80102014:	e8 4b 1d 00 00       	call   80103d64 <acquire>
80102019:	83 c4 10             	add    $0x10,%esp
8010201c:	eb b9                	jmp    80101fd7 <kfree+0x4b>
    release(&kmem.lock);
8010201e:	83 ec 0c             	sub    $0xc,%esp
80102021:	68 40 16 11 80       	push   $0x80111640
80102026:	e8 9e 1d 00 00       	call   80103dc9 <release>
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
8010204e:	68 fc 6b 10 80       	push   $0x80106bfc
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
8010207d:	68 06 6c 10 80       	push   $0x80106c06
80102082:	68 40 16 11 80       	push   $0x80111640
80102087:	e8 9c 1b 00 00       	call   80103c28 <initlock>
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
80102102:	e8 5d 1c 00 00       	call   80103d64 <acquire>
80102107:	83 c4 10             	add    $0x10,%esp
8010210a:	eb cd                	jmp    801020d9 <kalloc+0x10>
    release(&kmem.lock);
8010210c:	83 ec 0c             	sub    $0xc,%esp
8010210f:	68 40 16 11 80       	push   $0x80111640
80102114:	e8 b0 1c 00 00       	call   80103dc9 <release>
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
80102157:	0f b6 91 40 6d 10 80 	movzbl -0x7fef92c0(%ecx),%edx
8010215e:	0b 15 7c 16 11 80    	or     0x8011167c,%edx
80102164:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  shift ^= togglecode[data];
8010216a:	0f b6 81 40 6c 10 80 	movzbl -0x7fef93c0(%ecx),%eax
80102171:	31 c2                	xor    %eax,%edx
80102173:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  c = charcode[shift & (CTL | SHIFT)][data];
80102179:	89 d0                	mov    %edx,%eax
8010217b:	83 e0 03             	and    $0x3,%eax
8010217e:	8b 04 85 20 6c 10 80 	mov    -0x7fef93e0(,%eax,4),%eax
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
801021b7:	0f b6 81 40 6d 10 80 	movzbl -0x7fef92c0(%ecx),%eax
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
801024aa:	e8 a4 19 00 00       	call   80103e53 <memcmp>
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
80102605:	e8 7e 18 00 00       	call   80103e88 <memmove>
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
80102704:	e8 7f 17 00 00       	call   80103e88 <memmove>
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
80102771:	68 40 6e 10 80       	push   $0x80106e40
80102776:	68 a0 16 11 80       	push   $0x801116a0
8010277b:	e8 a8 14 00 00       	call   80103c28 <initlock>
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
801027bb:	e8 a4 15 00 00       	call   80103d64 <acquire>
801027c0:	83 c4 10             	add    $0x10,%esp
801027c3:	eb 15                	jmp    801027da <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c5:	83 ec 08             	sub    $0x8,%esp
801027c8:	68 a0 16 11 80       	push   $0x801116a0
801027cd:	68 a0 16 11 80       	push   $0x801116a0
801027d2:	e8 e7 0f 00 00       	call   801037be <sleep>
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
80102809:	e8 b0 0f 00 00       	call   801037be <sleep>
8010280e:	83 c4 10             	add    $0x10,%esp
80102811:	eb c7                	jmp    801027da <begin_op+0x2a>
      log.outstanding += 1;
80102813:	a3 dc 16 11 80       	mov    %eax,0x801116dc
      release(&log.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 a0 16 11 80       	push   $0x801116a0
80102820:	e8 a4 15 00 00       	call   80103dc9 <release>
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
80102836:	e8 29 15 00 00       	call   80103d64 <acquire>
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
80102870:	e8 54 15 00 00       	call   80103dc9 <release>
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
80102884:	68 44 6e 10 80       	push   $0x80106e44
80102889:	e8 ba da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288e:	83 ec 0c             	sub    $0xc,%esp
80102891:	68 a0 16 11 80       	push   $0x801116a0
80102896:	e8 8b 10 00 00       	call   80103926 <wakeup>
8010289b:	83 c4 10             	add    $0x10,%esp
8010289e:	eb c8                	jmp    80102868 <end_op+0x3e>
    commit();
801028a0:	e8 92 fe ff ff       	call   80102737 <commit>
    acquire(&log.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 a0 16 11 80       	push   $0x801116a0
801028ad:	e8 b2 14 00 00       	call   80103d64 <acquire>
    log.committing = 0;
801028b2:	c7 05 e0 16 11 80 00 	movl   $0x0,0x801116e0
801028b9:	00 00 00 
    wakeup(&log);
801028bc:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028c3:	e8 5e 10 00 00       	call   80103926 <wakeup>
    release(&log.lock);
801028c8:	c7 04 24 a0 16 11 80 	movl   $0x801116a0,(%esp)
801028cf:	e8 f5 14 00 00       	call   80103dc9 <release>
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
8010290b:	e8 54 14 00 00       	call   80103d64 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102910:	83 c4 10             	add    $0x10,%esp
80102913:	b8 00 00 00 00       	mov    $0x0,%eax
80102918:	eb 1d                	jmp    80102937 <log_write+0x5e>
    panic("too big a transaction");
8010291a:	83 ec 0c             	sub    $0xc,%esp
8010291d:	68 53 6e 10 80       	push   $0x80106e53
80102922:	e8 21 da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102927:	83 ec 0c             	sub    $0xc,%esp
8010292a:	68 69 6e 10 80       	push   $0x80106e69
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
80102966:	e8 5e 14 00 00       	call   80103dc9 <release>
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
80102994:	e8 ef 14 00 00       	call   80103e88 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102999:	83 c4 10             	add    $0x10,%esp
8010299c:	bb a0 17 11 80       	mov    $0x801117a0,%ebx
801029a1:	eb 13                	jmp    801029b6 <startothers+0x38>
801029a3:	83 ec 0c             	sub    $0xc,%esp
801029a6:	68 68 6b 10 80       	push   $0x80106b68
801029ab:	e8 98 d9 ff ff       	call   80100348 <panic>
801029b0:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029b6:	69 05 84 17 11 80 b0 	imul   $0xb0,0x80111784,%eax
801029bd:	00 00 00 
801029c0:	05 a0 17 11 80       	add    $0x801117a0,%eax
801029c5:	39 d8                	cmp    %ebx,%eax
801029c7:	76 58                	jbe    80102a21 <startothers+0xa3>
    if(c == mycpu())  // We've started already.
801029c9:	e8 64 08 00 00       	call   80103232 <mycpu>
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
80102a2d:	e8 5c 08 00 00       	call   8010328e <cpuid>
80102a32:	89 c3                	mov    %eax,%ebx
80102a34:	e8 55 08 00 00       	call   8010328e <cpuid>
80102a39:	83 ec 04             	sub    $0x4,%esp
80102a3c:	53                   	push   %ebx
80102a3d:	50                   	push   %eax
80102a3e:	68 84 6e 10 80       	push   $0x80106e84
80102a43:	e8 bf db ff ff       	call   80100607 <cprintf>
  idtinit();       // load idt register
80102a48:	e8 cd 25 00 00       	call   8010501a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a4d:	e8 e0 07 00 00       	call   80103232 <mycpu>
80102a52:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a54:	b8 01 00 00 00       	mov    $0x1,%eax
80102a59:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a60:	e8 e4 0a 00 00       	call   80103549 <scheduler>

80102a65 <mpenter>:
{
80102a65:	55                   	push   %ebp
80102a66:	89 e5                	mov    %esp,%ebp
80102a68:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a6b:	e8 00 37 00 00       	call   80106170 <switchkvm>
  seginit();
80102a70:	e8 86 34 00 00       	call   80105efb <seginit>
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
80102a95:	68 d0 56 11 80       	push   $0x801156d0
80102a9a:	e8 d8 f5 ff ff       	call   80102077 <kinit1>
  kvmalloc();      // kernel page table
80102a9f:	e8 2d 3c 00 00       	call   801066d1 <kvmalloc>
  mpinit();        // detect other processors
80102aa4:	e8 db 01 00 00       	call   80102c84 <mpinit>
  lapicinit();     // interrupt controller
80102aa9:	e8 d8 f7 ff ff       	call   80102286 <lapicinit>
  seginit();       // segment descriptors
80102aae:	e8 48 34 00 00       	call   80105efb <seginit>
  picinit();       // disable pic
80102ab3:	e8 a2 02 00 00       	call   80102d5a <picinit>
  ioapicinit();    // another interrupt controller
80102ab8:	e8 20 f4 ff ff       	call   80101edd <ioapicinit>
  consoleinit();   // console hardware
80102abd:	e8 c8 dd ff ff       	call   8010088a <consoleinit>
  uartinit();      // serial port
80102ac2:	e8 fa 27 00 00       	call   801052c1 <uartinit>
  pinit();         // process table
80102ac7:	e8 4c 07 00 00       	call   80103218 <pinit>
  tvinit();        // trap vectors
80102acc:	e8 44 24 00 00       	call   80104f15 <tvinit>
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
80102af7:	e8 d0 07 00 00       	call   801032cc <userinit>
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
80102b3f:	68 98 6e 10 80       	push   $0x80106e98
80102b44:	e8 ff d7 ff ff       	call   80100348 <panic>
80102b49:	83 c3 10             	add    $0x10,%ebx
80102b4c:	39 f3                	cmp    %esi,%ebx
80102b4e:	73 29                	jae    80102b79 <mpsearch1+0x54>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b50:	83 ec 04             	sub    $0x4,%esp
80102b53:	6a 04                	push   $0x4
80102b55:	68 b2 6e 10 80       	push   $0x80106eb2
80102b5a:	53                   	push   %ebx
80102b5b:	e8 f3 12 00 00       	call   80103e53 <memcmp>
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
80102c1f:	68 b7 6e 10 80       	push   $0x80106eb7
80102c24:	53                   	push   %ebx
80102c25:	e8 29 12 00 00       	call   80103e53 <memcmp>
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
80102c61:	68 98 6e 10 80       	push   $0x80106e98
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
80102cb5:	68 bc 6e 10 80       	push   $0x80106ebc
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
80102d50:	68 d4 6e 10 80       	push   $0x80106ed4
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
80102dd7:	68 f3 6e 10 80       	push   $0x80106ef3
80102ddc:	50                   	push   %eax
80102ddd:	e8 46 0e 00 00       	call   80103c28 <initlock>
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
80102e61:	e8 fe 0e 00 00       	call   80103d64 <acquire>
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
80102e83:	e8 9e 0a 00 00       	call   80103926 <wakeup>
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
80102ea1:	e8 23 0f 00 00       	call   80103dc9 <release>
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
80102ec2:	e8 5f 0a 00 00       	call   80103926 <wakeup>
80102ec7:	83 c4 10             	add    $0x10,%esp
80102eca:	eb bf                	jmp    80102e8b <pipeclose+0x35>
    release(&p->lock);
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	53                   	push   %ebx
80102ed0:	e8 f4 0e 00 00       	call   80103dc9 <release>
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
80102ef2:	e8 6d 0e 00 00       	call   80103d64 <acquire>
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
80102f0d:	e8 14 0a 00 00       	call   80103926 <wakeup>
  release(&p->lock);
80102f12:	89 1c 24             	mov    %ebx,(%esp)
80102f15:	e8 af 0e 00 00       	call   80103dc9 <release>
  return n;
80102f1a:	83 c4 10             	add    $0x10,%esp
80102f1d:	89 f0                	mov    %esi,%eax
80102f1f:	eb 5c                	jmp    80102f7d <pipewrite+0x9b>
      wakeup(&p->nread);
80102f21:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f27:	83 ec 0c             	sub    $0xc,%esp
80102f2a:	50                   	push   %eax
80102f2b:	e8 f6 09 00 00       	call   80103926 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f30:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f36:	83 c4 08             	add    $0x8,%esp
80102f39:	53                   	push   %ebx
80102f3a:	50                   	push   %eax
80102f3b:	e8 7e 08 00 00       	call   801037be <sleep>
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
80102f61:	e8 43 03 00 00       	call   801032a9 <myproc>
80102f66:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f6a:	74 b5                	je     80102f21 <pipewrite+0x3f>
        release(&p->lock);
80102f6c:	83 ec 0c             	sub    $0xc,%esp
80102f6f:	53                   	push   %ebx
80102f70:	e8 54 0e 00 00       	call   80103dc9 <release>
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
80102fb7:	e8 a8 0d 00 00       	call   80103d64 <acquire>
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
80102fcc:	e8 ed 07 00 00       	call   801037be <sleep>
80102fd1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fd4:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fda:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fe0:	75 78                	jne    8010305a <piperead+0xb3>
80102fe2:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fe8:	85 f6                	test   %esi,%esi
80102fea:	74 37                	je     80103023 <piperead+0x7c>
    if(myproc()->killed){
80102fec:	e8 b8 02 00 00       	call   801032a9 <myproc>
80102ff1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102ff5:	74 ca                	je     80102fc1 <piperead+0x1a>
      release(&p->lock);
80102ff7:	83 ec 0c             	sub    $0xc,%esp
80102ffa:	53                   	push   %ebx
80102ffb:	e8 c9 0d 00 00       	call   80103dc9 <release>
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
80103040:	e8 e1 08 00 00       	call   80103926 <wakeup>
  release(&p->lock);
80103045:	89 1c 24             	mov    %ebx,(%esp)
80103048:	e8 7c 0d 00 00       	call   80103dc9 <release>
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
80103066:	eb 06                	jmp    8010306e <wakeup1+0xd>
80103068:	81 c2 84 00 00 00    	add    $0x84,%edx
8010306e:	81 fa 54 3e 11 80    	cmp    $0x80113e54,%edx
80103074:	73 14                	jae    8010308a <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103076:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010307a:	75 ec                	jne    80103068 <wakeup1+0x7>
8010307c:	39 42 20             	cmp    %eax,0x20(%edx)
8010307f:	75 e7                	jne    80103068 <wakeup1+0x7>
      p->state = RUNNABLE;
80103081:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103088:	eb de                	jmp    80103068 <wakeup1+0x7>
}
8010308a:	c3                   	ret    

8010308b <allocproc>:
allocproc(void) {
8010308b:	55                   	push   %ebp
8010308c:	89 e5                	mov    %esp,%ebp
8010308e:	53                   	push   %ebx
8010308f:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103092:	68 20 1d 11 80       	push   $0x80111d20
80103097:	e8 c8 0c 00 00       	call   80103d64 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010309c:	83 c4 10             	add    $0x10,%esp
8010309f:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801030a4:	eb 06                	jmp    801030ac <allocproc+0x21>
801030a6:	81 c3 84 00 00 00    	add    $0x84,%ebx
801030ac:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
801030b2:	73 76                	jae    8010312a <allocproc+0x9f>
    if(p->state == UNUSED)
801030b4:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030b8:	75 ec                	jne    801030a6 <allocproc+0x1b>
  p->state = EMBRYO;
801030ba:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030c1:	a1 08 a0 10 80       	mov    0x8010a008,%eax
801030c6:	8d 50 01             	lea    0x1(%eax),%edx
801030c9:	89 15 08 a0 10 80    	mov    %edx,0x8010a008
801030cf:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801030d2:	83 ec 0c             	sub    $0xc,%esp
801030d5:	68 20 1d 11 80       	push   $0x80111d20
801030da:	e8 ea 0c 00 00       	call   80103dc9 <release>
  if((p->kstack = kalloc()) == 0){
801030df:	e8 e5 ef ff ff       	call   801020c9 <kalloc>
801030e4:	89 43 08             	mov    %eax,0x8(%ebx)
801030e7:	83 c4 10             	add    $0x10,%esp
801030ea:	85 c0                	test   %eax,%eax
801030ec:	74 53                	je     80103141 <allocproc+0xb6>
  sp -= sizeof *p->tf;
801030ee:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801030f4:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801030f7:	c7 80 b0 0f 00 00 0a 	movl   $0x80104f0a,0xfb0(%eax)
801030fe:	4f 10 80 
  sp -= sizeof *p->context;
80103101:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103106:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103109:	83 ec 04             	sub    $0x4,%esp
8010310c:	6a 14                	push   $0x14
8010310e:	6a 00                	push   $0x0
80103110:	50                   	push   %eax
80103111:	e8 fa 0c 00 00       	call   80103e10 <memset>
  p->context->eip = (uint)forkret;
80103116:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103119:	c7 40 10 4c 31 10 80 	movl   $0x8010314c,0x10(%eax)
  return p;
80103120:	83 c4 10             	add    $0x10,%esp
}
80103123:	89 d8                	mov    %ebx,%eax
80103125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103128:	c9                   	leave  
80103129:	c3                   	ret    
  release(&ptable.lock);
8010312a:	83 ec 0c             	sub    $0xc,%esp
8010312d:	68 20 1d 11 80       	push   $0x80111d20
80103132:	e8 92 0c 00 00       	call   80103dc9 <release>
  return 0;
80103137:	83 c4 10             	add    $0x10,%esp
8010313a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010313f:	eb e2                	jmp    80103123 <allocproc+0x98>
    p->state = UNUSED;
80103141:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103148:	89 c3                	mov    %eax,%ebx
8010314a:	eb d7                	jmp    80103123 <allocproc+0x98>

8010314c <forkret>:
{
8010314c:	55                   	push   %ebp
8010314d:	89 e5                	mov    %esp,%ebp
8010314f:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103152:	68 20 1d 11 80       	push   $0x80111d20
80103157:	e8 6d 0c 00 00       	call   80103dc9 <release>
  if (first) {
8010315c:	83 c4 10             	add    $0x10,%esp
8010315f:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103166:	75 02                	jne    8010316a <forkret+0x1e>
}
80103168:	c9                   	leave  
80103169:	c3                   	ret    
    first = 0;
8010316a:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103171:	00 00 00 
    iinit(ROOTDEV);
80103174:	83 ec 0c             	sub    $0xc,%esp
80103177:	6a 01                	push   $0x1
80103179:	e8 5c e1 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
8010317e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103185:	e8 dd f5 ff ff       	call   80102767 <initlog>
8010318a:	83 c4 10             	add    $0x10,%esp
}
8010318d:	eb d9                	jmp    80103168 <forkret+0x1c>

8010318f <lcg_parkmiller>:
{
8010318f:	55                   	push   %ebp
80103190:	89 e5                	mov    %esp,%ebp
80103192:	56                   	push   %esi
80103193:	53                   	push   %ebx
80103194:	8b 4d 08             	mov    0x8(%ebp),%ecx
    unsigned div = *state / (N / G);  /* max : 2,147,483,646 / 44,488 = 48,271 */
80103197:	8b 19                	mov    (%ecx),%ebx
80103199:	ba 91 13 8f bc       	mov    $0xbc8f1391,%edx
8010319e:	89 d8                	mov    %ebx,%eax
801031a0:	f7 e2                	mul    %edx
801031a2:	c1 ea 0f             	shr    $0xf,%edx
    unsigned rem = *state % (N / G);  /* max : 2,147,483,646 % 44,488 = 44,487 */
801031a5:	69 f2 c8 ad 00 00    	imul   $0xadc8,%edx,%esi
801031ab:	89 d8                	mov    %ebx,%eax
801031ad:	29 f0                	sub    %esi,%eax
    unsigned a = rem * G;        /* max : 44,487 * 48,271 = 2,147,431,977 */
801031af:	69 c0 8f bc 00 00    	imul   $0xbc8f,%eax,%eax
    unsigned b = div * (N % G);  /* max : 48,271 * 3,399 = 164,073,129 */
801031b5:	69 d2 47 0d 00 00    	imul   $0xd47,%edx,%edx
    return *state = (a > b) ? (a - b) : (a + (N - b));
801031bb:	39 d0                	cmp    %edx,%eax
801031bd:	76 08                	jbe    801031c7 <lcg_parkmiller+0x38>
801031bf:	29 d0                	sub    %edx,%eax
801031c1:	89 01                	mov    %eax,(%ecx)
}
801031c3:	5b                   	pop    %ebx
801031c4:	5e                   	pop    %esi
801031c5:	5d                   	pop    %ebp
801031c6:	c3                   	ret    
    return *state = (a > b) ? (a - b) : (a + (N - b));
801031c7:	29 d0                	sub    %edx,%eax
801031c9:	05 ff ff ff 7f       	add    $0x7fffffff,%eax
801031ce:	eb f1                	jmp    801031c1 <lcg_parkmiller+0x32>

801031d0 <next_random>:
unsigned next_random() {
801031d0:	55                   	push   %ebp
801031d1:	89 e5                	mov    %esp,%ebp
801031d3:	83 ec 14             	sub    $0x14,%esp
    return lcg_parkmiller(&random_seed);
801031d6:	68 04 a0 10 80       	push   $0x8010a004
801031db:	e8 af ff ff ff       	call   8010318f <lcg_parkmiller>
}
801031e0:	c9                   	leave  
801031e1:	c3                   	ret    

801031e2 <random_at_most>:
unsigned random_at_most(unsigned max) {
801031e2:	55                   	push   %ebp
801031e3:	89 e5                	mov    %esp,%ebp
801031e5:	56                   	push   %esi
801031e6:	53                   	push   %ebx
  unsigned num_bins = (max + 1);
801031e7:	8b 45 08             	mov    0x8(%ebp),%eax
801031ea:	8d 48 01             	lea    0x1(%eax),%ecx
  unsigned bin_size = num_rand / num_bins;
801031ed:	b8 00 00 00 80       	mov    $0x80000000,%eax
801031f2:	ba 00 00 00 00       	mov    $0x0,%edx
801031f7:	f7 f1                	div    %ecx
801031f9:	89 d3                	mov    %edx,%ebx
801031fb:	89 c6                	mov    %eax,%esi
  x = next_random();
801031fd:	e8 ce ff ff ff       	call   801031d0 <next_random>
  } while (num_rand - defect <= x);
80103202:	ba 00 00 00 80       	mov    $0x80000000,%edx
80103207:	29 da                	sub    %ebx,%edx
80103209:	39 c2                	cmp    %eax,%edx
8010320b:	76 f0                	jbe    801031fd <random_at_most+0x1b>
  retval = x/bin_size;
8010320d:	ba 00 00 00 00       	mov    $0x0,%edx
80103212:	f7 f6                	div    %esi
}
80103214:	5b                   	pop    %ebx
80103215:	5e                   	pop    %esi
80103216:	5d                   	pop    %ebp
80103217:	c3                   	ret    

80103218 <pinit>:
{
80103218:	55                   	push   %ebp
80103219:	89 e5                	mov    %esp,%ebp
8010321b:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
8010321e:	68 f8 6e 10 80       	push   $0x80106ef8
80103223:	68 20 1d 11 80       	push   $0x80111d20
80103228:	e8 fb 09 00 00       	call   80103c28 <initlock>
}
8010322d:	83 c4 10             	add    $0x10,%esp
80103230:	c9                   	leave  
80103231:	c3                   	ret    

80103232 <mycpu>:
{
80103232:	55                   	push   %ebp
80103233:	89 e5                	mov    %esp,%ebp
80103235:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103238:	9c                   	pushf  
80103239:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010323a:	f6 c4 02             	test   $0x2,%ah
8010323d:	75 28                	jne    80103267 <mycpu+0x35>
  apicid = lapicid();
8010323f:	e8 4e f1 ff ff       	call   80102392 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103244:	ba 00 00 00 00       	mov    $0x0,%edx
80103249:	39 15 84 17 11 80    	cmp    %edx,0x80111784
8010324f:	7e 23                	jle    80103274 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103251:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103257:	0f b6 89 a0 17 11 80 	movzbl -0x7feee860(%ecx),%ecx
8010325e:	39 c1                	cmp    %eax,%ecx
80103260:	74 1f                	je     80103281 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103262:	83 c2 01             	add    $0x1,%edx
80103265:	eb e2                	jmp    80103249 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103267:	83 ec 0c             	sub    $0xc,%esp
8010326a:	68 dc 6f 10 80       	push   $0x80106fdc
8010326f:	e8 d4 d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103274:	83 ec 0c             	sub    $0xc,%esp
80103277:	68 ff 6e 10 80       	push   $0x80106eff
8010327c:	e8 c7 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103281:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103287:	05 a0 17 11 80       	add    $0x801117a0,%eax
}
8010328c:	c9                   	leave  
8010328d:	c3                   	ret    

8010328e <cpuid>:
cpuid() {
8010328e:	55                   	push   %ebp
8010328f:	89 e5                	mov    %esp,%ebp
80103291:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103294:	e8 99 ff ff ff       	call   80103232 <mycpu>
80103299:	2d a0 17 11 80       	sub    $0x801117a0,%eax
8010329e:	c1 f8 04             	sar    $0x4,%eax
801032a1:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801032a7:	c9                   	leave  
801032a8:	c3                   	ret    

801032a9 <myproc>:
myproc(void) {
801032a9:	55                   	push   %ebp
801032aa:	89 e5                	mov    %esp,%ebp
801032ac:	53                   	push   %ebx
801032ad:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801032b0:	e8 d4 09 00 00       	call   80103c89 <pushcli>
  c = mycpu();
801032b5:	e8 78 ff ff ff       	call   80103232 <mycpu>
  p = c->proc;
801032ba:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032c0:	e8 00 0a 00 00       	call   80103cc5 <popcli>
}
801032c5:	89 d8                	mov    %ebx,%eax
801032c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032ca:	c9                   	leave  
801032cb:	c3                   	ret    

801032cc <userinit>:
{
801032cc:	55                   	push   %ebp
801032cd:	89 e5                	mov    %esp,%ebp
801032cf:	53                   	push   %ebx
801032d0:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032d3:	e8 b3 fd ff ff       	call   8010308b <allocproc>
801032d8:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032da:	a3 54 3e 11 80       	mov    %eax,0x80113e54
  if((p->pgdir = setupkvm()) == 0)
801032df:	e8 7f 33 00 00       	call   80106663 <setupkvm>
801032e4:	89 43 04             	mov    %eax,0x4(%ebx)
801032e7:	85 c0                	test   %eax,%eax
801032e9:	0f 84 c9 00 00 00    	je     801033b8 <userinit+0xec>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032ef:	83 ec 04             	sub    $0x4,%esp
801032f2:	68 2c 00 00 00       	push   $0x2c
801032f7:	68 60 a4 10 80       	push   $0x8010a460
801032fc:	50                   	push   %eax
801032fd:	e8 07 30 00 00       	call   80106309 <inituvm>
  p->sz = PGSIZE;
80103302:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103308:	8b 43 18             	mov    0x18(%ebx),%eax
8010330b:	83 c4 0c             	add    $0xc,%esp
8010330e:	6a 4c                	push   $0x4c
80103310:	6a 00                	push   $0x0
80103312:	50                   	push   %eax
80103313:	e8 f8 0a 00 00       	call   80103e10 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103318:	8b 43 18             	mov    0x18(%ebx),%eax
8010331b:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103321:	8b 43 18             	mov    0x18(%ebx),%eax
80103324:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010332a:	8b 43 18             	mov    0x18(%ebx),%eax
8010332d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103331:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103335:	8b 43 18             	mov    0x18(%ebx),%eax
80103338:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010333c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103340:	8b 43 18             	mov    0x18(%ebx),%eax
80103343:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010334a:	8b 43 18             	mov    0x18(%ebx),%eax
8010334d:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103354:	8b 43 18             	mov    0x18(%ebx),%eax
80103357:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010335e:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103361:	83 c4 0c             	add    $0xc,%esp
80103364:	6a 10                	push   $0x10
80103366:	68 28 6f 10 80       	push   $0x80106f28
8010336b:	50                   	push   %eax
8010336c:	e8 0b 0c 00 00       	call   80103f7c <safestrcpy>
  p->cwd = namei("/");
80103371:	c7 04 24 31 6f 10 80 	movl   $0x80106f31,(%esp)
80103378:	e8 50 e8 ff ff       	call   80101bcd <namei>
8010337d:	89 43 68             	mov    %eax,0x68(%ebx)
  p->times_scheduled = 0;
80103380:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  p->tickets = 10;
80103387:	c7 83 80 00 00 00 0a 	movl   $0xa,0x80(%ebx)
8010338e:	00 00 00 
  acquire(&ptable.lock);
80103391:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103398:	e8 c7 09 00 00       	call   80103d64 <acquire>
  p->state = RUNNABLE;
8010339d:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801033a4:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801033ab:	e8 19 0a 00 00       	call   80103dc9 <release>
}
801033b0:	83 c4 10             	add    $0x10,%esp
801033b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033b6:	c9                   	leave  
801033b7:	c3                   	ret    
    panic("userinit: out of memory?");
801033b8:	83 ec 0c             	sub    $0xc,%esp
801033bb:	68 0f 6f 10 80       	push   $0x80106f0f
801033c0:	e8 83 cf ff ff       	call   80100348 <panic>

801033c5 <growproc>:
{
801033c5:	55                   	push   %ebp
801033c6:	89 e5                	mov    %esp,%ebp
801033c8:	56                   	push   %esi
801033c9:	53                   	push   %ebx
801033ca:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801033cd:	e8 d7 fe ff ff       	call   801032a9 <myproc>
801033d2:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801033d4:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033d6:	85 f6                	test   %esi,%esi
801033d8:	7f 1c                	jg     801033f6 <growproc+0x31>
  } else if(n < 0){
801033da:	78 37                	js     80103413 <growproc+0x4e>
  curproc->sz = sz;
801033dc:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033de:	83 ec 0c             	sub    $0xc,%esp
801033e1:	53                   	push   %ebx
801033e2:	e8 ae 2d 00 00       	call   80106195 <switchuvm>
  return 0;
801033e7:	83 c4 10             	add    $0x10,%esp
801033ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033f2:	5b                   	pop    %ebx
801033f3:	5e                   	pop    %esi
801033f4:	5d                   	pop    %ebp
801033f5:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033f6:	83 ec 04             	sub    $0x4,%esp
801033f9:	01 c6                	add    %eax,%esi
801033fb:	56                   	push   %esi
801033fc:	50                   	push   %eax
801033fd:	ff 73 04             	push   0x4(%ebx)
80103400:	e8 da 30 00 00       	call   801064df <allocuvm>
80103405:	83 c4 10             	add    $0x10,%esp
80103408:	85 c0                	test   %eax,%eax
8010340a:	75 d0                	jne    801033dc <growproc+0x17>
      return -1;
8010340c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103411:	eb dc                	jmp    801033ef <growproc+0x2a>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103413:	83 ec 04             	sub    $0x4,%esp
80103416:	01 c6                	add    %eax,%esi
80103418:	56                   	push   %esi
80103419:	50                   	push   %eax
8010341a:	ff 73 04             	push   0x4(%ebx)
8010341d:	e8 17 30 00 00       	call   80106439 <deallocuvm>
80103422:	83 c4 10             	add    $0x10,%esp
80103425:	85 c0                	test   %eax,%eax
80103427:	75 b3                	jne    801033dc <growproc+0x17>
      return -1;
80103429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010342e:	eb bf                	jmp    801033ef <growproc+0x2a>

80103430 <fork>:
{
80103430:	55                   	push   %ebp
80103431:	89 e5                	mov    %esp,%ebp
80103433:	57                   	push   %edi
80103434:	56                   	push   %esi
80103435:	53                   	push   %ebx
80103436:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103439:	e8 6b fe ff ff       	call   801032a9 <myproc>
8010343e:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103440:	e8 46 fc ff ff       	call   8010308b <allocproc>
80103445:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103448:	85 c0                	test   %eax,%eax
8010344a:	0f 84 ea 00 00 00    	je     8010353a <fork+0x10a>
80103450:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103452:	83 ec 08             	sub    $0x8,%esp
80103455:	ff 33                	push   (%ebx)
80103457:	ff 73 04             	push   0x4(%ebx)
8010345a:	e8 b5 32 00 00       	call   80106714 <copyuvm>
8010345f:	89 47 04             	mov    %eax,0x4(%edi)
80103462:	83 c4 10             	add    $0x10,%esp
80103465:	85 c0                	test   %eax,%eax
80103467:	74 34                	je     8010349d <fork+0x6d>
  np->sz = curproc->sz;
80103469:	8b 03                	mov    (%ebx),%eax
8010346b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010346e:	89 02                	mov    %eax,(%edx)
  np->parent = curproc;
80103470:	89 5a 14             	mov    %ebx,0x14(%edx)
  *np->tf = *curproc->tf;
80103473:	8b 73 18             	mov    0x18(%ebx),%esi
80103476:	8b 7a 18             	mov    0x18(%edx),%edi
80103479:	b9 13 00 00 00       	mov    $0x13,%ecx
8010347e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tickets = curproc->tickets;
80103480:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
80103486:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)
  np->tf->eax = 0;
8010348c:	8b 42 18             	mov    0x18(%edx),%eax
8010348f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103496:	be 00 00 00 00       	mov    $0x0,%esi
8010349b:	eb 29                	jmp    801034c6 <fork+0x96>
    kfree(np->kstack);
8010349d:	83 ec 0c             	sub    $0xc,%esp
801034a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034a3:	ff 73 08             	push   0x8(%ebx)
801034a6:	e8 e1 ea ff ff       	call   80101f8c <kfree>
    np->kstack = 0;
801034ab:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801034b2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801034b9:	83 c4 10             	add    $0x10,%esp
801034bc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034c1:	eb 6d                	jmp    80103530 <fork+0x100>
  for(i = 0; i < NOFILE; i++)
801034c3:	83 c6 01             	add    $0x1,%esi
801034c6:	83 fe 0f             	cmp    $0xf,%esi
801034c9:	7f 1d                	jg     801034e8 <fork+0xb8>
    if(curproc->ofile[i])
801034cb:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034cf:	85 c0                	test   %eax,%eax
801034d1:	74 f0                	je     801034c3 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034d3:	83 ec 0c             	sub    $0xc,%esp
801034d6:	50                   	push   %eax
801034d7:	e8 a2 d7 ff ff       	call   80100c7e <filedup>
801034dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034df:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801034e3:	83 c4 10             	add    $0x10,%esp
801034e6:	eb db                	jmp    801034c3 <fork+0x93>
  np->cwd = idup(curproc->cwd);
801034e8:	83 ec 0c             	sub    $0xc,%esp
801034eb:	ff 73 68             	push   0x68(%ebx)
801034ee:	e8 4c e0 ff ff       	call   8010153f <idup>
801034f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801034f6:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034f9:	83 c3 6c             	add    $0x6c,%ebx
801034fc:	8d 47 6c             	lea    0x6c(%edi),%eax
801034ff:	83 c4 0c             	add    $0xc,%esp
80103502:	6a 10                	push   $0x10
80103504:	53                   	push   %ebx
80103505:	50                   	push   %eax
80103506:	e8 71 0a 00 00       	call   80103f7c <safestrcpy>
  pid = np->pid;
8010350b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010350e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103515:	e8 4a 08 00 00       	call   80103d64 <acquire>
  np->state = RUNNABLE;
8010351a:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103521:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103528:	e8 9c 08 00 00       	call   80103dc9 <release>
  return pid;
8010352d:	83 c4 10             	add    $0x10,%esp
}
80103530:	89 d8                	mov    %ebx,%eax
80103532:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103535:	5b                   	pop    %ebx
80103536:	5e                   	pop    %esi
80103537:	5f                   	pop    %edi
80103538:	5d                   	pop    %ebp
80103539:	c3                   	ret    
    return -1;
8010353a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010353f:	eb ef                	jmp    80103530 <fork+0x100>

80103541 <abs>:
unsigned abs(unsigned n) {
80103541:	55                   	push   %ebp
80103542:	89 e5                	mov    %esp,%ebp
}
80103544:	8b 45 08             	mov    0x8(%ebp),%eax
80103547:	5d                   	pop    %ebp
80103548:	c3                   	ret    

80103549 <scheduler>:
{
80103549:	55                   	push   %ebp
8010354a:	89 e5                	mov    %esp,%ebp
8010354c:	56                   	push   %esi
8010354d:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010354e:	e8 df fc ff ff       	call   80103232 <mycpu>
80103553:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103555:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010355c:	00 00 00 
8010355f:	e9 ac 00 00 00       	jmp    80103610 <scheduler+0xc7>
      total_tickets = total_tickets + p->tickets;
80103564:	03 98 80 00 00 00    	add    0x80(%eax),%ebx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010356a:	05 84 00 00 00       	add    $0x84,%eax
8010356f:	3d 54 3e 11 80       	cmp    $0x80113e54,%eax
80103574:	73 08                	jae    8010357e <scheduler+0x35>
      if(p->state != RUNNABLE)
80103576:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
8010357a:	74 e8                	je     80103564 <scheduler+0x1b>
8010357c:	eb ec                	jmp    8010356a <scheduler+0x21>
    acquire(&ptable.lock);
8010357e:	83 ec 0c             	sub    $0xc,%esp
80103581:	68 20 1d 11 80       	push   $0x80111d20
80103586:	e8 d9 07 00 00       	call   80103d64 <acquire>
    unsigned int golden_ticket = random_at_most(total_tickets);
8010358b:	89 1c 24             	mov    %ebx,(%esp)
8010358e:	e8 4f fc ff ff       	call   801031e2 <random_at_most>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103593:	83 c4 10             	add    $0x10,%esp
    int ticket_count = 0;
80103596:	b9 00 00 00 00       	mov    $0x0,%ecx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010359b:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801035a0:	eb 06                	jmp    801035a8 <scheduler+0x5f>
801035a2:	81 c3 84 00 00 00    	add    $0x84,%ebx
801035a8:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
801035ae:	73 50                	jae    80103600 <scheduler+0xb7>
      if(p->state != RUNNABLE)
801035b0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035b4:	75 ec                	jne    801035a2 <scheduler+0x59>
      ticket_count += p->tickets;
801035b6:	03 8b 80 00 00 00    	add    0x80(%ebx),%ecx
      if (ticket_count <= golden_ticket) {
801035bc:	39 c1                	cmp    %eax,%ecx
801035be:	76 e2                	jbe    801035a2 <scheduler+0x59>
      p->times_scheduled++;
801035c0:	8b 43 7c             	mov    0x7c(%ebx),%eax
801035c3:	83 c0 01             	add    $0x1,%eax
801035c6:	89 43 7c             	mov    %eax,0x7c(%ebx)
      c->proc = p;
801035c9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801035cf:	83 ec 0c             	sub    $0xc,%esp
801035d2:	53                   	push   %ebx
801035d3:	e8 bd 2b 00 00       	call   80106195 <switchuvm>
      p->state = RUNNING;
801035d8:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801035df:	83 c4 08             	add    $0x8,%esp
801035e2:	ff 73 1c             	push   0x1c(%ebx)
801035e5:	8d 46 04             	lea    0x4(%esi),%eax
801035e8:	50                   	push   %eax
801035e9:	e8 e3 09 00 00       	call   80103fd1 <swtch>
      switchkvm();
801035ee:	e8 7d 2b 00 00       	call   80106170 <switchkvm>
      c->proc = 0;
801035f3:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035fa:	00 00 00 
      break;
801035fd:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
80103600:	83 ec 0c             	sub    $0xc,%esp
80103603:	68 20 1d 11 80       	push   $0x80111d20
80103608:	e8 bc 07 00 00       	call   80103dc9 <release>
  for(;;){
8010360d:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103610:	fb                   	sti    
    unsigned int total_tickets = 0;
80103611:	bb 00 00 00 00       	mov    $0x0,%ebx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103616:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010361b:	e9 4f ff ff ff       	jmp    8010356f <scheduler+0x26>

80103620 <sched>:
{
80103620:	55                   	push   %ebp
80103621:	89 e5                	mov    %esp,%ebp
80103623:	56                   	push   %esi
80103624:	53                   	push   %ebx
  struct proc *p = myproc();
80103625:	e8 7f fc ff ff       	call   801032a9 <myproc>
8010362a:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010362c:	83 ec 0c             	sub    $0xc,%esp
8010362f:	68 20 1d 11 80       	push   $0x80111d20
80103634:	e8 ec 06 00 00       	call   80103d25 <holding>
80103639:	83 c4 10             	add    $0x10,%esp
8010363c:	85 c0                	test   %eax,%eax
8010363e:	74 4f                	je     8010368f <sched+0x6f>
  if(mycpu()->ncli != 1)
80103640:	e8 ed fb ff ff       	call   80103232 <mycpu>
80103645:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010364c:	75 4e                	jne    8010369c <sched+0x7c>
  if(p->state == RUNNING)
8010364e:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103652:	74 55                	je     801036a9 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103654:	9c                   	pushf  
80103655:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103656:	f6 c4 02             	test   $0x2,%ah
80103659:	75 5b                	jne    801036b6 <sched+0x96>
  intena = mycpu()->intena;
8010365b:	e8 d2 fb ff ff       	call   80103232 <mycpu>
80103660:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103666:	e8 c7 fb ff ff       	call   80103232 <mycpu>
8010366b:	83 ec 08             	sub    $0x8,%esp
8010366e:	ff 70 04             	push   0x4(%eax)
80103671:	83 c3 1c             	add    $0x1c,%ebx
80103674:	53                   	push   %ebx
80103675:	e8 57 09 00 00       	call   80103fd1 <swtch>
  mycpu()->intena = intena;
8010367a:	e8 b3 fb ff ff       	call   80103232 <mycpu>
8010367f:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103685:	83 c4 10             	add    $0x10,%esp
80103688:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010368b:	5b                   	pop    %ebx
8010368c:	5e                   	pop    %esi
8010368d:	5d                   	pop    %ebp
8010368e:	c3                   	ret    
    panic("sched ptable.lock");
8010368f:	83 ec 0c             	sub    $0xc,%esp
80103692:	68 33 6f 10 80       	push   $0x80106f33
80103697:	e8 ac cc ff ff       	call   80100348 <panic>
    panic("sched locks");
8010369c:	83 ec 0c             	sub    $0xc,%esp
8010369f:	68 45 6f 10 80       	push   $0x80106f45
801036a4:	e8 9f cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036a9:	83 ec 0c             	sub    $0xc,%esp
801036ac:	68 51 6f 10 80       	push   $0x80106f51
801036b1:	e8 92 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036b6:	83 ec 0c             	sub    $0xc,%esp
801036b9:	68 5f 6f 10 80       	push   $0x80106f5f
801036be:	e8 85 cc ff ff       	call   80100348 <panic>

801036c3 <exit>:
{
801036c3:	55                   	push   %ebp
801036c4:	89 e5                	mov    %esp,%ebp
801036c6:	56                   	push   %esi
801036c7:	53                   	push   %ebx
  struct proc *curproc = myproc();
801036c8:	e8 dc fb ff ff       	call   801032a9 <myproc>
  if(curproc == initproc)
801036cd:	39 05 54 3e 11 80    	cmp    %eax,0x80113e54
801036d3:	74 09                	je     801036de <exit+0x1b>
801036d5:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801036d7:	bb 00 00 00 00       	mov    $0x0,%ebx
801036dc:	eb 24                	jmp    80103702 <exit+0x3f>
    panic("init exiting");
801036de:	83 ec 0c             	sub    $0xc,%esp
801036e1:	68 73 6f 10 80       	push   $0x80106f73
801036e6:	e8 5d cc ff ff       	call   80100348 <panic>
      fileclose(curproc->ofile[fd]);
801036eb:	83 ec 0c             	sub    $0xc,%esp
801036ee:	50                   	push   %eax
801036ef:	e8 cf d5 ff ff       	call   80100cc3 <fileclose>
      curproc->ofile[fd] = 0;
801036f4:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801036fb:	00 
801036fc:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
801036ff:	83 c3 01             	add    $0x1,%ebx
80103702:	83 fb 0f             	cmp    $0xf,%ebx
80103705:	7f 0a                	jg     80103711 <exit+0x4e>
    if(curproc->ofile[fd]){
80103707:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
8010370b:	85 c0                	test   %eax,%eax
8010370d:	75 dc                	jne    801036eb <exit+0x28>
8010370f:	eb ee                	jmp    801036ff <exit+0x3c>
  begin_op();
80103711:	e8 9a f0 ff ff       	call   801027b0 <begin_op>
  iput(curproc->cwd);
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	ff 76 68             	push   0x68(%esi)
8010371c:	e8 55 df ff ff       	call   80101676 <iput>
  end_op();
80103721:	e8 04 f1 ff ff       	call   8010282a <end_op>
  curproc->cwd = 0;
80103726:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010372d:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103734:	e8 2b 06 00 00       	call   80103d64 <acquire>
  wakeup1(curproc->parent);
80103739:	8b 46 14             	mov    0x14(%esi),%eax
8010373c:	e8 20 f9 ff ff       	call   80103061 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103741:	83 c4 10             	add    $0x10,%esp
80103744:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103749:	eb 06                	jmp    80103751 <exit+0x8e>
8010374b:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103751:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80103757:	73 1a                	jae    80103773 <exit+0xb0>
    if(p->parent == curproc){
80103759:	39 73 14             	cmp    %esi,0x14(%ebx)
8010375c:	75 ed                	jne    8010374b <exit+0x88>
      p->parent = initproc;
8010375e:	a1 54 3e 11 80       	mov    0x80113e54,%eax
80103763:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103766:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010376a:	75 df                	jne    8010374b <exit+0x88>
        wakeup1(initproc);
8010376c:	e8 f0 f8 ff ff       	call   80103061 <wakeup1>
80103771:	eb d8                	jmp    8010374b <exit+0x88>
  curproc->state = ZOMBIE;
80103773:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
8010377a:	e8 a1 fe ff ff       	call   80103620 <sched>
  panic("zombie exit");
8010377f:	83 ec 0c             	sub    $0xc,%esp
80103782:	68 80 6f 10 80       	push   $0x80106f80
80103787:	e8 bc cb ff ff       	call   80100348 <panic>

8010378c <yield>:
{
8010378c:	55                   	push   %ebp
8010378d:	89 e5                	mov    %esp,%ebp
8010378f:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103792:	68 20 1d 11 80       	push   $0x80111d20
80103797:	e8 c8 05 00 00       	call   80103d64 <acquire>
  myproc()->state = RUNNABLE;
8010379c:	e8 08 fb ff ff       	call   801032a9 <myproc>
801037a1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037a8:	e8 73 fe ff ff       	call   80103620 <sched>
  release(&ptable.lock);
801037ad:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801037b4:	e8 10 06 00 00       	call   80103dc9 <release>
}
801037b9:	83 c4 10             	add    $0x10,%esp
801037bc:	c9                   	leave  
801037bd:	c3                   	ret    

801037be <sleep>:
{
801037be:	55                   	push   %ebp
801037bf:	89 e5                	mov    %esp,%ebp
801037c1:	56                   	push   %esi
801037c2:	53                   	push   %ebx
801037c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p = myproc();
801037c6:	e8 de fa ff ff       	call   801032a9 <myproc>
  if(p == 0)
801037cb:	85 c0                	test   %eax,%eax
801037cd:	74 66                	je     80103835 <sleep+0x77>
801037cf:	89 c3                	mov    %eax,%ebx
  if(lk == 0)
801037d1:	85 f6                	test   %esi,%esi
801037d3:	74 6d                	je     80103842 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801037d5:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
801037db:	74 18                	je     801037f5 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037dd:	83 ec 0c             	sub    $0xc,%esp
801037e0:	68 20 1d 11 80       	push   $0x80111d20
801037e5:	e8 7a 05 00 00       	call   80103d64 <acquire>
    release(lk);
801037ea:	89 34 24             	mov    %esi,(%esp)
801037ed:	e8 d7 05 00 00       	call   80103dc9 <release>
801037f2:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801037f5:	8b 45 08             	mov    0x8(%ebp),%eax
801037f8:	89 43 20             	mov    %eax,0x20(%ebx)
  p->state = SLEEPING;
801037fb:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103802:	e8 19 fe ff ff       	call   80103620 <sched>
  p->chan = 0;
80103807:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010380e:	81 fe 20 1d 11 80    	cmp    $0x80111d20,%esi
80103814:	74 18                	je     8010382e <sleep+0x70>
    release(&ptable.lock);
80103816:	83 ec 0c             	sub    $0xc,%esp
80103819:	68 20 1d 11 80       	push   $0x80111d20
8010381e:	e8 a6 05 00 00       	call   80103dc9 <release>
    acquire(lk);
80103823:	89 34 24             	mov    %esi,(%esp)
80103826:	e8 39 05 00 00       	call   80103d64 <acquire>
8010382b:	83 c4 10             	add    $0x10,%esp
}
8010382e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103831:	5b                   	pop    %ebx
80103832:	5e                   	pop    %esi
80103833:	5d                   	pop    %ebp
80103834:	c3                   	ret    
    panic("sleep");
80103835:	83 ec 0c             	sub    $0xc,%esp
80103838:	68 8c 6f 10 80       	push   $0x80106f8c
8010383d:	e8 06 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103842:	83 ec 0c             	sub    $0xc,%esp
80103845:	68 92 6f 10 80       	push   $0x80106f92
8010384a:	e8 f9 ca ff ff       	call   80100348 <panic>

8010384f <wait>:
{
8010384f:	55                   	push   %ebp
80103850:	89 e5                	mov    %esp,%ebp
80103852:	56                   	push   %esi
80103853:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103854:	e8 50 fa ff ff       	call   801032a9 <myproc>
80103859:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	68 20 1d 11 80       	push   $0x80111d20
80103863:	e8 fc 04 00 00       	call   80103d64 <acquire>
80103868:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010386b:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103870:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103875:	eb 5e                	jmp    801038d5 <wait+0x86>
        pid = p->pid;
80103877:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	ff 73 08             	push   0x8(%ebx)
80103880:	e8 07 e7 ff ff       	call   80101f8c <kfree>
        p->kstack = 0;
80103885:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
8010388c:	83 c4 04             	add    $0x4,%esp
8010388f:	ff 73 04             	push   0x4(%ebx)
80103892:	e8 4a 2d 00 00       	call   801065e1 <freevm>
        p->pid = 0;
80103897:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010389e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038a5:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038a9:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038b0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038b7:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801038be:	e8 06 05 00 00       	call   80103dc9 <release>
        return pid;
801038c3:	83 c4 10             	add    $0x10,%esp
}
801038c6:	89 f0                	mov    %esi,%eax
801038c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038cb:	5b                   	pop    %ebx
801038cc:	5e                   	pop    %esi
801038cd:	5d                   	pop    %ebp
801038ce:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038cf:	81 c3 84 00 00 00    	add    $0x84,%ebx
801038d5:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
801038db:	73 12                	jae    801038ef <wait+0xa0>
      if(p->parent != curproc)
801038dd:	39 73 14             	cmp    %esi,0x14(%ebx)
801038e0:	75 ed                	jne    801038cf <wait+0x80>
      if(p->state == ZOMBIE){
801038e2:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801038e6:	74 8f                	je     80103877 <wait+0x28>
      havekids = 1;
801038e8:	b8 01 00 00 00       	mov    $0x1,%eax
801038ed:	eb e0                	jmp    801038cf <wait+0x80>
    if(!havekids || curproc->killed){
801038ef:	85 c0                	test   %eax,%eax
801038f1:	74 06                	je     801038f9 <wait+0xaa>
801038f3:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801038f7:	74 17                	je     80103910 <wait+0xc1>
      release(&ptable.lock);
801038f9:	83 ec 0c             	sub    $0xc,%esp
801038fc:	68 20 1d 11 80       	push   $0x80111d20
80103901:	e8 c3 04 00 00       	call   80103dc9 <release>
      return -1;
80103906:	83 c4 10             	add    $0x10,%esp
80103909:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010390e:	eb b6                	jmp    801038c6 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103910:	83 ec 08             	sub    $0x8,%esp
80103913:	68 20 1d 11 80       	push   $0x80111d20
80103918:	56                   	push   %esi
80103919:	e8 a0 fe ff ff       	call   801037be <sleep>
    havekids = 0;
8010391e:	83 c4 10             	add    $0x10,%esp
80103921:	e9 45 ff ff ff       	jmp    8010386b <wait+0x1c>

80103926 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103926:	55                   	push   %ebp
80103927:	89 e5                	mov    %esp,%ebp
80103929:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
8010392c:	68 20 1d 11 80       	push   $0x80111d20
80103931:	e8 2e 04 00 00       	call   80103d64 <acquire>
  wakeup1(chan);
80103936:	8b 45 08             	mov    0x8(%ebp),%eax
80103939:	e8 23 f7 ff ff       	call   80103061 <wakeup1>
  release(&ptable.lock);
8010393e:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103945:	e8 7f 04 00 00       	call   80103dc9 <release>
}
8010394a:	83 c4 10             	add    $0x10,%esp
8010394d:	c9                   	leave  
8010394e:	c3                   	ret    

8010394f <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010394f:	55                   	push   %ebp
80103950:	89 e5                	mov    %esp,%ebp
80103952:	53                   	push   %ebx
80103953:	83 ec 10             	sub    $0x10,%esp
80103956:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103959:	68 20 1d 11 80       	push   $0x80111d20
8010395e:	e8 01 04 00 00       	call   80103d64 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103963:	83 c4 10             	add    $0x10,%esp
80103966:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010396b:	eb 0e                	jmp    8010397b <kill+0x2c>
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
8010396d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103974:	eb 1e                	jmp    80103994 <kill+0x45>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103976:	05 84 00 00 00       	add    $0x84,%eax
8010397b:	3d 54 3e 11 80       	cmp    $0x80113e54,%eax
80103980:	73 2c                	jae    801039ae <kill+0x5f>
    if(p->pid == pid){
80103982:	39 58 10             	cmp    %ebx,0x10(%eax)
80103985:	75 ef                	jne    80103976 <kill+0x27>
      p->killed = 1;
80103987:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010398e:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103992:	74 d9                	je     8010396d <kill+0x1e>
      release(&ptable.lock);
80103994:	83 ec 0c             	sub    $0xc,%esp
80103997:	68 20 1d 11 80       	push   $0x80111d20
8010399c:	e8 28 04 00 00       	call   80103dc9 <release>
      return 0;
801039a1:	83 c4 10             	add    $0x10,%esp
801039a4:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039ac:	c9                   	leave  
801039ad:	c3                   	ret    
  release(&ptable.lock);
801039ae:	83 ec 0c             	sub    $0xc,%esp
801039b1:	68 20 1d 11 80       	push   $0x80111d20
801039b6:	e8 0e 04 00 00       	call   80103dc9 <release>
  return -1;
801039bb:	83 c4 10             	add    $0x10,%esp
801039be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039c3:	eb e4                	jmp    801039a9 <kill+0x5a>

801039c5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039c5:	55                   	push   %ebp
801039c6:	89 e5                	mov    %esp,%ebp
801039c8:	56                   	push   %esi
801039c9:	53                   	push   %ebx
801039ca:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039cd:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801039d2:	eb 36                	jmp    80103a0a <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801039d4:	b8 a3 6f 10 80       	mov    $0x80106fa3,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801039d9:	8d 53 6c             	lea    0x6c(%ebx),%edx
801039dc:	52                   	push   %edx
801039dd:	50                   	push   %eax
801039de:	ff 73 10             	push   0x10(%ebx)
801039e1:	68 a7 6f 10 80       	push   $0x80106fa7
801039e6:	e8 1c cc ff ff       	call   80100607 <cprintf>
    if(p->state == SLEEPING){
801039eb:	83 c4 10             	add    $0x10,%esp
801039ee:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801039f2:	74 3c                	je     80103a30 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801039f4:	83 ec 0c             	sub    $0xc,%esp
801039f7:	68 2f 73 10 80       	push   $0x8010732f
801039fc:	e8 06 cc ff ff       	call   80100607 <cprintf>
80103a01:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a04:	81 c3 84 00 00 00    	add    $0x84,%ebx
80103a0a:	81 fb 54 3e 11 80    	cmp    $0x80113e54,%ebx
80103a10:	73 61                	jae    80103a73 <procdump+0xae>
    if(p->state == UNUSED)
80103a12:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a15:	85 c0                	test   %eax,%eax
80103a17:	74 eb                	je     80103a04 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a19:	83 f8 05             	cmp    $0x5,%eax
80103a1c:	77 b6                	ja     801039d4 <procdump+0xf>
80103a1e:	8b 04 85 04 70 10 80 	mov    -0x7fef8ffc(,%eax,4),%eax
80103a25:	85 c0                	test   %eax,%eax
80103a27:	75 b0                	jne    801039d9 <procdump+0x14>
      state = "???";
80103a29:	b8 a3 6f 10 80       	mov    $0x80106fa3,%eax
80103a2e:	eb a9                	jmp    801039d9 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a30:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a33:	8b 40 0c             	mov    0xc(%eax),%eax
80103a36:	83 c0 08             	add    $0x8,%eax
80103a39:	83 ec 08             	sub    $0x8,%esp
80103a3c:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a3f:	52                   	push   %edx
80103a40:	50                   	push   %eax
80103a41:	e8 fd 01 00 00       	call   80103c43 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a46:	83 c4 10             	add    $0x10,%esp
80103a49:	be 00 00 00 00       	mov    $0x0,%esi
80103a4e:	eb 14                	jmp    80103a64 <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103a50:	83 ec 08             	sub    $0x8,%esp
80103a53:	50                   	push   %eax
80103a54:	68 41 69 10 80       	push   $0x80106941
80103a59:	e8 a9 cb ff ff       	call   80100607 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a5e:	83 c6 01             	add    $0x1,%esi
80103a61:	83 c4 10             	add    $0x10,%esp
80103a64:	83 fe 09             	cmp    $0x9,%esi
80103a67:	7f 8b                	jg     801039f4 <procdump+0x2f>
80103a69:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a6d:	85 c0                	test   %eax,%eax
80103a6f:	75 df                	jne    80103a50 <procdump+0x8b>
80103a71:	eb 81                	jmp    801039f4 <procdump+0x2f>
  }
}
80103a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a76:	5b                   	pop    %ebx
80103a77:	5e                   	pop    %esi
80103a78:	5d                   	pop    %ebp
80103a79:	c3                   	ret    

80103a7a <sys_getprocessesinfo>:


int sys_getprocessesinfo(void) {
80103a7a:	55                   	push   %ebp
80103a7b:	89 e5                	mov    %esp,%ebp
80103a7d:	56                   	push   %esi
80103a7e:	53                   	push   %ebx
80103a7f:	83 ec 14             	sub    $0x14,%esp
  struct processes_info *p;
  if (argptr(0, (void*)&p, sizeof(*p)) < 0) {
80103a82:	68 04 03 00 00       	push   $0x304
80103a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103a8a:	50                   	push   %eax
80103a8b:	6a 00                	push   $0x0
80103a8d:	e8 f6 05 00 00       	call   80104088 <argptr>
80103a92:	83 c4 10             	add    $0x10,%esp
80103a95:	85 c0                	test   %eax,%eax
80103a97:	78 7d                	js     80103b16 <sys_getprocessesinfo+0x9c>
    return -1; //error
  }
  int count_unused = 0;
  struct proc *v;
  acquire(&ptable.lock);
80103a99:	83 ec 0c             	sub    $0xc,%esp
80103a9c:	68 20 1d 11 80       	push   $0x80111d20
80103aa1:	e8 be 02 00 00       	call   80103d64 <acquire>
  int i = 0;
  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
80103aa6:	83 c4 10             	add    $0x10,%esp
  int i = 0;
80103aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
80103aae:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
  int count_unused = 0;
80103ab3:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
80103ab8:	eb 08                	jmp    80103ac2 <sys_getprocessesinfo+0x48>
      count_unused++;
      p->pids[i] = v->pid;
      p->times_scheduled[i] = v->times_scheduled;
      p->tickets[i] = v->tickets;
    }
    i++;
80103aba:	83 c2 01             	add    $0x1,%edx
  for(v = ptable.proc; v < &ptable.proc[NPROC]; v++){
80103abd:	05 84 00 00 00       	add    $0x84,%eax
80103ac2:	3d 54 3e 11 80       	cmp    $0x80113e54,%eax
80103ac7:	73 2c                	jae    80103af5 <sys_getprocessesinfo+0x7b>
    if(v->state != UNUSED) {
80103ac9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
80103acd:	74 eb                	je     80103aba <sys_getprocessesinfo+0x40>
      count_unused++;
80103acf:	83 c3 01             	add    $0x1,%ebx
      p->pids[i] = v->pid;
80103ad2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80103ad5:	8b 70 10             	mov    0x10(%eax),%esi
80103ad8:	89 74 91 04          	mov    %esi,0x4(%ecx,%edx,4)
      p->times_scheduled[i] = v->times_scheduled;
80103adc:	8b 70 7c             	mov    0x7c(%eax),%esi
80103adf:	89 b4 91 04 01 00 00 	mov    %esi,0x104(%ecx,%edx,4)
      p->tickets[i] = v->tickets;
80103ae6:	8b b0 80 00 00 00    	mov    0x80(%eax),%esi
80103aec:	89 b4 91 04 02 00 00 	mov    %esi,0x204(%ecx,%edx,4)
80103af3:	eb c5                	jmp    80103aba <sys_getprocessesinfo+0x40>
  }
  p->num_processes = count_unused;
80103af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af8:	89 18                	mov    %ebx,(%eax)
  release(&ptable.lock);
80103afa:	83 ec 0c             	sub    $0xc,%esp
80103afd:	68 20 1d 11 80       	push   $0x80111d20
80103b02:	e8 c2 02 00 00       	call   80103dc9 <release>
  return 0;
80103b07:	83 c4 10             	add    $0x10,%esp
80103b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b12:	5b                   	pop    %ebx
80103b13:	5e                   	pop    %esi
80103b14:	5d                   	pop    %ebp
80103b15:	c3                   	ret    
    return -1; //error
80103b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b1b:	eb f2                	jmp    80103b0f <sys_getprocessesinfo+0x95>

80103b1d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b1d:	55                   	push   %ebp
80103b1e:	89 e5                	mov    %esp,%ebp
80103b20:	53                   	push   %ebx
80103b21:	83 ec 0c             	sub    $0xc,%esp
80103b24:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b27:	68 1c 70 10 80       	push   $0x8010701c
80103b2c:	8d 43 04             	lea    0x4(%ebx),%eax
80103b2f:	50                   	push   %eax
80103b30:	e8 f3 00 00 00       	call   80103c28 <initlock>
  lk->name = name;
80103b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b38:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b41:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b48:	83 c4 10             	add    $0x10,%esp
80103b4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b4e:	c9                   	leave  
80103b4f:	c3                   	ret    

80103b50 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b50:	55                   	push   %ebp
80103b51:	89 e5                	mov    %esp,%ebp
80103b53:	56                   	push   %esi
80103b54:	53                   	push   %ebx
80103b55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b58:	8d 73 04             	lea    0x4(%ebx),%esi
80103b5b:	83 ec 0c             	sub    $0xc,%esp
80103b5e:	56                   	push   %esi
80103b5f:	e8 00 02 00 00       	call   80103d64 <acquire>
  while (lk->locked) {
80103b64:	83 c4 10             	add    $0x10,%esp
80103b67:	eb 0d                	jmp    80103b76 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b69:	83 ec 08             	sub    $0x8,%esp
80103b6c:	56                   	push   %esi
80103b6d:	53                   	push   %ebx
80103b6e:	e8 4b fc ff ff       	call   801037be <sleep>
80103b73:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b76:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b79:	75 ee                	jne    80103b69 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b7b:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b81:	e8 23 f7 ff ff       	call   801032a9 <myproc>
80103b86:	8b 40 10             	mov    0x10(%eax),%eax
80103b89:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b8c:	83 ec 0c             	sub    $0xc,%esp
80103b8f:	56                   	push   %esi
80103b90:	e8 34 02 00 00       	call   80103dc9 <release>
}
80103b95:	83 c4 10             	add    $0x10,%esp
80103b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b9b:	5b                   	pop    %ebx
80103b9c:	5e                   	pop    %esi
80103b9d:	5d                   	pop    %ebp
80103b9e:	c3                   	ret    

80103b9f <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b9f:	55                   	push   %ebp
80103ba0:	89 e5                	mov    %esp,%ebp
80103ba2:	56                   	push   %esi
80103ba3:	53                   	push   %ebx
80103ba4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ba7:	8d 73 04             	lea    0x4(%ebx),%esi
80103baa:	83 ec 0c             	sub    $0xc,%esp
80103bad:	56                   	push   %esi
80103bae:	e8 b1 01 00 00       	call   80103d64 <acquire>
  lk->locked = 0;
80103bb3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103bb9:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103bc0:	89 1c 24             	mov    %ebx,(%esp)
80103bc3:	e8 5e fd ff ff       	call   80103926 <wakeup>
  release(&lk->lk);
80103bc8:	89 34 24             	mov    %esi,(%esp)
80103bcb:	e8 f9 01 00 00       	call   80103dc9 <release>
}
80103bd0:	83 c4 10             	add    $0x10,%esp
80103bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bd6:	5b                   	pop    %ebx
80103bd7:	5e                   	pop    %esi
80103bd8:	5d                   	pop    %ebp
80103bd9:	c3                   	ret    

80103bda <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	56                   	push   %esi
80103bde:	53                   	push   %ebx
80103bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103be2:	8d 73 04             	lea    0x4(%ebx),%esi
80103be5:	83 ec 0c             	sub    $0xc,%esp
80103be8:	56                   	push   %esi
80103be9:	e8 76 01 00 00       	call   80103d64 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bee:	83 c4 10             	add    $0x10,%esp
80103bf1:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bf4:	75 17                	jne    80103c0d <holdingsleep+0x33>
80103bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103bfb:	83 ec 0c             	sub    $0xc,%esp
80103bfe:	56                   	push   %esi
80103bff:	e8 c5 01 00 00       	call   80103dc9 <release>
  return r;
}
80103c04:	89 d8                	mov    %ebx,%eax
80103c06:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c09:	5b                   	pop    %ebx
80103c0a:	5e                   	pop    %esi
80103c0b:	5d                   	pop    %ebp
80103c0c:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103c0d:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103c10:	e8 94 f6 ff ff       	call   801032a9 <myproc>
80103c15:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c18:	74 07                	je     80103c21 <holdingsleep+0x47>
80103c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c1f:	eb da                	jmp    80103bfb <holdingsleep+0x21>
80103c21:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c26:	eb d3                	jmp    80103bfb <holdingsleep+0x21>

80103c28 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c28:	55                   	push   %ebp
80103c29:	89 e5                	mov    %esp,%ebp
80103c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c2e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c31:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c3a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c41:	5d                   	pop    %ebp
80103c42:	c3                   	ret    

80103c43 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c43:	55                   	push   %ebp
80103c44:	89 e5                	mov    %esp,%ebp
80103c46:	53                   	push   %ebx
80103c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c4d:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c50:	b8 00 00 00 00       	mov    $0x0,%eax
80103c55:	83 f8 09             	cmp    $0x9,%eax
80103c58:	7f 25                	jg     80103c7f <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c5a:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c60:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c66:	77 17                	ja     80103c7f <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c68:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c6b:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c6e:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c70:	83 c0 01             	add    $0x1,%eax
80103c73:	eb e0                	jmp    80103c55 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c75:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c7c:	83 c0 01             	add    $0x1,%eax
80103c7f:	83 f8 09             	cmp    $0x9,%eax
80103c82:	7e f1                	jle    80103c75 <getcallerpcs+0x32>
}
80103c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c87:	c9                   	leave  
80103c88:	c3                   	ret    

80103c89 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c89:	55                   	push   %ebp
80103c8a:	89 e5                	mov    %esp,%ebp
80103c8c:	53                   	push   %ebx
80103c8d:	83 ec 04             	sub    $0x4,%esp
80103c90:	9c                   	pushf  
80103c91:	5b                   	pop    %ebx
  asm volatile("cli");
80103c92:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c93:	e8 9a f5 ff ff       	call   80103232 <mycpu>
80103c98:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c9f:	74 11                	je     80103cb2 <pushcli+0x29>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103ca1:	e8 8c f5 ff ff       	call   80103232 <mycpu>
80103ca6:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cb0:	c9                   	leave  
80103cb1:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103cb2:	e8 7b f5 ff ff       	call   80103232 <mycpu>
80103cb7:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103cbd:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103cc3:	eb dc                	jmp    80103ca1 <pushcli+0x18>

80103cc5 <popcli>:

void
popcli(void)
{
80103cc5:	55                   	push   %ebp
80103cc6:	89 e5                	mov    %esp,%ebp
80103cc8:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ccb:	9c                   	pushf  
80103ccc:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103ccd:	f6 c4 02             	test   $0x2,%ah
80103cd0:	75 28                	jne    80103cfa <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103cd2:	e8 5b f5 ff ff       	call   80103232 <mycpu>
80103cd7:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cdd:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ce0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103ce6:	85 d2                	test   %edx,%edx
80103ce8:	78 1d                	js     80103d07 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cea:	e8 43 f5 ff ff       	call   80103232 <mycpu>
80103cef:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cf6:	74 1c                	je     80103d14 <popcli+0x4f>
    sti();
}
80103cf8:	c9                   	leave  
80103cf9:	c3                   	ret    
    panic("popcli - interruptible");
80103cfa:	83 ec 0c             	sub    $0xc,%esp
80103cfd:	68 27 70 10 80       	push   $0x80107027
80103d02:	e8 41 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103d07:	83 ec 0c             	sub    $0xc,%esp
80103d0a:	68 3e 70 10 80       	push   $0x8010703e
80103d0f:	e8 34 c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d14:	e8 19 f5 ff ff       	call   80103232 <mycpu>
80103d19:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d20:	74 d6                	je     80103cf8 <popcli+0x33>
  asm volatile("sti");
80103d22:	fb                   	sti    
}
80103d23:	eb d3                	jmp    80103cf8 <popcli+0x33>

80103d25 <holding>:
{
80103d25:	55                   	push   %ebp
80103d26:	89 e5                	mov    %esp,%ebp
80103d28:	53                   	push   %ebx
80103d29:	83 ec 04             	sub    $0x4,%esp
80103d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d2f:	e8 55 ff ff ff       	call   80103c89 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d34:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d37:	75 11                	jne    80103d4a <holding+0x25>
80103d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d3e:	e8 82 ff ff ff       	call   80103cc5 <popcli>
}
80103d43:	89 d8                	mov    %ebx,%eax
80103d45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d48:	c9                   	leave  
80103d49:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d4a:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d4d:	e8 e0 f4 ff ff       	call   80103232 <mycpu>
80103d52:	39 c3                	cmp    %eax,%ebx
80103d54:	74 07                	je     80103d5d <holding+0x38>
80103d56:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d5b:	eb e1                	jmp    80103d3e <holding+0x19>
80103d5d:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d62:	eb da                	jmp    80103d3e <holding+0x19>

80103d64 <acquire>:
{
80103d64:	55                   	push   %ebp
80103d65:	89 e5                	mov    %esp,%ebp
80103d67:	53                   	push   %ebx
80103d68:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d6b:	e8 19 ff ff ff       	call   80103c89 <pushcli>
  if(holding(lk))
80103d70:	83 ec 0c             	sub    $0xc,%esp
80103d73:	ff 75 08             	push   0x8(%ebp)
80103d76:	e8 aa ff ff ff       	call   80103d25 <holding>
80103d7b:	83 c4 10             	add    $0x10,%esp
80103d7e:	85 c0                	test   %eax,%eax
80103d80:	75 3a                	jne    80103dbc <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d82:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d85:	b8 01 00 00 00       	mov    $0x1,%eax
80103d8a:	f0 87 02             	lock xchg %eax,(%edx)
80103d8d:	85 c0                	test   %eax,%eax
80103d8f:	75 f1                	jne    80103d82 <acquire+0x1e>
  __sync_synchronize();
80103d91:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d96:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d99:	e8 94 f4 ff ff       	call   80103232 <mycpu>
80103d9e:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103da1:	8b 45 08             	mov    0x8(%ebp),%eax
80103da4:	83 c0 0c             	add    $0xc,%eax
80103da7:	83 ec 08             	sub    $0x8,%esp
80103daa:	50                   	push   %eax
80103dab:	8d 45 08             	lea    0x8(%ebp),%eax
80103dae:	50                   	push   %eax
80103daf:	e8 8f fe ff ff       	call   80103c43 <getcallerpcs>
}
80103db4:	83 c4 10             	add    $0x10,%esp
80103db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dba:	c9                   	leave  
80103dbb:	c3                   	ret    
    panic("acquire");
80103dbc:	83 ec 0c             	sub    $0xc,%esp
80103dbf:	68 45 70 10 80       	push   $0x80107045
80103dc4:	e8 7f c5 ff ff       	call   80100348 <panic>

80103dc9 <release>:
{
80103dc9:	55                   	push   %ebp
80103dca:	89 e5                	mov    %esp,%ebp
80103dcc:	53                   	push   %ebx
80103dcd:	83 ec 10             	sub    $0x10,%esp
80103dd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103dd3:	53                   	push   %ebx
80103dd4:	e8 4c ff ff ff       	call   80103d25 <holding>
80103dd9:	83 c4 10             	add    $0x10,%esp
80103ddc:	85 c0                	test   %eax,%eax
80103dde:	74 23                	je     80103e03 <release+0x3a>
  lk->pcs[0] = 0;
80103de0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103de7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dee:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103df3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103df9:	e8 c7 fe ff ff       	call   80103cc5 <popcli>
}
80103dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e01:	c9                   	leave  
80103e02:	c3                   	ret    
    panic("release");
80103e03:	83 ec 0c             	sub    $0xc,%esp
80103e06:	68 4d 70 10 80       	push   $0x8010704d
80103e0b:	e8 38 c5 ff ff       	call   80100348 <panic>

80103e10 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	57                   	push   %edi
80103e14:	53                   	push   %ebx
80103e15:	8b 55 08             	mov    0x8(%ebp),%edx
80103e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e1e:	f6 c2 03             	test   $0x3,%dl
80103e21:	75 25                	jne    80103e48 <memset+0x38>
80103e23:	f6 c1 03             	test   $0x3,%cl
80103e26:	75 20                	jne    80103e48 <memset+0x38>
    c &= 0xFF;
80103e28:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e2b:	c1 e9 02             	shr    $0x2,%ecx
80103e2e:	c1 e0 18             	shl    $0x18,%eax
80103e31:	89 fb                	mov    %edi,%ebx
80103e33:	c1 e3 10             	shl    $0x10,%ebx
80103e36:	09 d8                	or     %ebx,%eax
80103e38:	89 fb                	mov    %edi,%ebx
80103e3a:	c1 e3 08             	shl    $0x8,%ebx
80103e3d:	09 d8                	or     %ebx,%eax
80103e3f:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e41:	89 d7                	mov    %edx,%edi
80103e43:	fc                   	cld    
80103e44:	f3 ab                	rep stos %eax,%es:(%edi)
}
80103e46:	eb 05                	jmp    80103e4d <memset+0x3d>
  asm volatile("cld; rep stosb" :
80103e48:	89 d7                	mov    %edx,%edi
80103e4a:	fc                   	cld    
80103e4b:	f3 aa                	rep stos %al,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103e4d:	89 d0                	mov    %edx,%eax
80103e4f:	5b                   	pop    %ebx
80103e50:	5f                   	pop    %edi
80103e51:	5d                   	pop    %ebp
80103e52:	c3                   	ret    

80103e53 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e53:	55                   	push   %ebp
80103e54:	89 e5                	mov    %esp,%ebp
80103e56:	56                   	push   %esi
80103e57:	53                   	push   %ebx
80103e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e5e:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e61:	eb 08                	jmp    80103e6b <memcmp+0x18>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80103e63:	83 c1 01             	add    $0x1,%ecx
80103e66:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e69:	89 f0                	mov    %esi,%eax
80103e6b:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e6e:	85 c0                	test   %eax,%eax
80103e70:	74 12                	je     80103e84 <memcmp+0x31>
    if(*s1 != *s2)
80103e72:	0f b6 01             	movzbl (%ecx),%eax
80103e75:	0f b6 1a             	movzbl (%edx),%ebx
80103e78:	38 d8                	cmp    %bl,%al
80103e7a:	74 e7                	je     80103e63 <memcmp+0x10>
      return *s1 - *s2;
80103e7c:	0f b6 c0             	movzbl %al,%eax
80103e7f:	0f b6 db             	movzbl %bl,%ebx
80103e82:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e84:	5b                   	pop    %ebx
80103e85:	5e                   	pop    %esi
80103e86:	5d                   	pop    %ebp
80103e87:	c3                   	ret    

80103e88 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e88:	55                   	push   %ebp
80103e89:	89 e5                	mov    %esp,%ebp
80103e8b:	56                   	push   %esi
80103e8c:	53                   	push   %ebx
80103e8d:	8b 75 08             	mov    0x8(%ebp),%esi
80103e90:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e93:	8b 45 10             	mov    0x10(%ebp),%eax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e96:	39 f2                	cmp    %esi,%edx
80103e98:	73 3c                	jae    80103ed6 <memmove+0x4e>
80103e9a:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103e9d:	39 f1                	cmp    %esi,%ecx
80103e9f:	76 39                	jbe    80103eda <memmove+0x52>
    s += n;
    d += n;
80103ea1:	8d 14 06             	lea    (%esi,%eax,1),%edx
    while(n-- > 0)
80103ea4:	eb 0d                	jmp    80103eb3 <memmove+0x2b>
      *--d = *--s;
80103ea6:	83 e9 01             	sub    $0x1,%ecx
80103ea9:	83 ea 01             	sub    $0x1,%edx
80103eac:	0f b6 01             	movzbl (%ecx),%eax
80103eaf:	88 02                	mov    %al,(%edx)
    while(n-- > 0)
80103eb1:	89 d8                	mov    %ebx,%eax
80103eb3:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103eb6:	85 c0                	test   %eax,%eax
80103eb8:	75 ec                	jne    80103ea6 <memmove+0x1e>
80103eba:	eb 14                	jmp    80103ed0 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103ebc:	0f b6 02             	movzbl (%edx),%eax
80103ebf:	88 01                	mov    %al,(%ecx)
80103ec1:	8d 49 01             	lea    0x1(%ecx),%ecx
80103ec4:	8d 52 01             	lea    0x1(%edx),%edx
    while(n-- > 0)
80103ec7:	89 d8                	mov    %ebx,%eax
80103ec9:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103ecc:	85 c0                	test   %eax,%eax
80103ece:	75 ec                	jne    80103ebc <memmove+0x34>

  return dst;
}
80103ed0:	89 f0                	mov    %esi,%eax
80103ed2:	5b                   	pop    %ebx
80103ed3:	5e                   	pop    %esi
80103ed4:	5d                   	pop    %ebp
80103ed5:	c3                   	ret    
80103ed6:	89 f1                	mov    %esi,%ecx
80103ed8:	eb ef                	jmp    80103ec9 <memmove+0x41>
80103eda:	89 f1                	mov    %esi,%ecx
80103edc:	eb eb                	jmp    80103ec9 <memmove+0x41>

80103ede <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103ede:	55                   	push   %ebp
80103edf:	89 e5                	mov    %esp,%ebp
80103ee1:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80103ee4:	ff 75 10             	push   0x10(%ebp)
80103ee7:	ff 75 0c             	push   0xc(%ebp)
80103eea:	ff 75 08             	push   0x8(%ebp)
80103eed:	e8 96 ff ff ff       	call   80103e88 <memmove>
}
80103ef2:	c9                   	leave  
80103ef3:	c3                   	ret    

80103ef4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103ef4:	55                   	push   %ebp
80103ef5:	89 e5                	mov    %esp,%ebp
80103ef7:	53                   	push   %ebx
80103ef8:	8b 55 08             	mov    0x8(%ebp),%edx
80103efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103efe:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103f01:	eb 09                	jmp    80103f0c <strncmp+0x18>
    n--, p++, q++;
80103f03:	83 e8 01             	sub    $0x1,%eax
80103f06:	83 c2 01             	add    $0x1,%edx
80103f09:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103f0c:	85 c0                	test   %eax,%eax
80103f0e:	74 0b                	je     80103f1b <strncmp+0x27>
80103f10:	0f b6 1a             	movzbl (%edx),%ebx
80103f13:	84 db                	test   %bl,%bl
80103f15:	74 04                	je     80103f1b <strncmp+0x27>
80103f17:	3a 19                	cmp    (%ecx),%bl
80103f19:	74 e8                	je     80103f03 <strncmp+0xf>
  if(n == 0)
80103f1b:	85 c0                	test   %eax,%eax
80103f1d:	74 0d                	je     80103f2c <strncmp+0x38>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f1f:	0f b6 02             	movzbl (%edx),%eax
80103f22:	0f b6 11             	movzbl (%ecx),%edx
80103f25:	29 d0                	sub    %edx,%eax
}
80103f27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f2a:	c9                   	leave  
80103f2b:	c3                   	ret    
    return 0;
80103f2c:	b8 00 00 00 00       	mov    $0x0,%eax
80103f31:	eb f4                	jmp    80103f27 <strncmp+0x33>

80103f33 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f33:	55                   	push   %ebp
80103f34:	89 e5                	mov    %esp,%ebp
80103f36:	57                   	push   %edi
80103f37:	56                   	push   %esi
80103f38:	53                   	push   %ebx
80103f39:	8b 7d 08             	mov    0x8(%ebp),%edi
80103f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f3f:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f42:	89 fa                	mov    %edi,%edx
80103f44:	eb 04                	jmp    80103f4a <strncpy+0x17>
80103f46:	89 f1                	mov    %esi,%ecx
80103f48:	89 da                	mov    %ebx,%edx
80103f4a:	89 c3                	mov    %eax,%ebx
80103f4c:	83 e8 01             	sub    $0x1,%eax
80103f4f:	85 db                	test   %ebx,%ebx
80103f51:	7e 11                	jle    80103f64 <strncpy+0x31>
80103f53:	8d 71 01             	lea    0x1(%ecx),%esi
80103f56:	8d 5a 01             	lea    0x1(%edx),%ebx
80103f59:	0f b6 09             	movzbl (%ecx),%ecx
80103f5c:	88 0a                	mov    %cl,(%edx)
80103f5e:	84 c9                	test   %cl,%cl
80103f60:	75 e4                	jne    80103f46 <strncpy+0x13>
80103f62:	89 da                	mov    %ebx,%edx
    ;
  while(n-- > 0)
80103f64:	8d 48 ff             	lea    -0x1(%eax),%ecx
80103f67:	85 c0                	test   %eax,%eax
80103f69:	7e 0a                	jle    80103f75 <strncpy+0x42>
    *s++ = 0;
80103f6b:	c6 02 00             	movb   $0x0,(%edx)
  while(n-- > 0)
80103f6e:	89 c8                	mov    %ecx,%eax
    *s++ = 0;
80103f70:	8d 52 01             	lea    0x1(%edx),%edx
80103f73:	eb ef                	jmp    80103f64 <strncpy+0x31>
  return os;
}
80103f75:	89 f8                	mov    %edi,%eax
80103f77:	5b                   	pop    %ebx
80103f78:	5e                   	pop    %esi
80103f79:	5f                   	pop    %edi
80103f7a:	5d                   	pop    %ebp
80103f7b:	c3                   	ret    

80103f7c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f7c:	55                   	push   %ebp
80103f7d:	89 e5                	mov    %esp,%ebp
80103f7f:	57                   	push   %edi
80103f80:	56                   	push   %esi
80103f81:	53                   	push   %ebx
80103f82:	8b 7d 08             	mov    0x8(%ebp),%edi
80103f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f88:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80103f8b:	85 c0                	test   %eax,%eax
80103f8d:	7e 23                	jle    80103fb2 <safestrcpy+0x36>
80103f8f:	89 fa                	mov    %edi,%edx
80103f91:	eb 04                	jmp    80103f97 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f93:	89 f1                	mov    %esi,%ecx
80103f95:	89 da                	mov    %ebx,%edx
80103f97:	83 e8 01             	sub    $0x1,%eax
80103f9a:	85 c0                	test   %eax,%eax
80103f9c:	7e 11                	jle    80103faf <safestrcpy+0x33>
80103f9e:	8d 71 01             	lea    0x1(%ecx),%esi
80103fa1:	8d 5a 01             	lea    0x1(%edx),%ebx
80103fa4:	0f b6 09             	movzbl (%ecx),%ecx
80103fa7:	88 0a                	mov    %cl,(%edx)
80103fa9:	84 c9                	test   %cl,%cl
80103fab:	75 e6                	jne    80103f93 <safestrcpy+0x17>
80103fad:	89 da                	mov    %ebx,%edx
    ;
  *s = 0;
80103faf:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80103fb2:	89 f8                	mov    %edi,%eax
80103fb4:	5b                   	pop    %ebx
80103fb5:	5e                   	pop    %esi
80103fb6:	5f                   	pop    %edi
80103fb7:	5d                   	pop    %ebp
80103fb8:	c3                   	ret    

80103fb9 <strlen>:

int
strlen(const char *s)
{
80103fb9:	55                   	push   %ebp
80103fba:	89 e5                	mov    %esp,%ebp
80103fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fbf:	b8 00 00 00 00       	mov    $0x0,%eax
80103fc4:	eb 03                	jmp    80103fc9 <strlen+0x10>
80103fc6:	83 c0 01             	add    $0x1,%eax
80103fc9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103fcd:	75 f7                	jne    80103fc6 <strlen+0xd>
    ;
  return n;
}
80103fcf:	5d                   	pop    %ebp
80103fd0:	c3                   	ret    

80103fd1 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fd1:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fd5:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fd9:	55                   	push   %ebp
  pushl %ebx
80103fda:	53                   	push   %ebx
  pushl %esi
80103fdb:	56                   	push   %esi
  pushl %edi
80103fdc:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fdd:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fdf:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fe1:	5f                   	pop    %edi
  popl %esi
80103fe2:	5e                   	pop    %esi
  popl %ebx
80103fe3:	5b                   	pop    %ebx
  popl %ebp
80103fe4:	5d                   	pop    %ebp
  ret
80103fe5:	c3                   	ret    

80103fe6 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fe6:	55                   	push   %ebp
80103fe7:	89 e5                	mov    %esp,%ebp
80103fe9:	53                   	push   %ebx
80103fea:	83 ec 04             	sub    $0x4,%esp
80103fed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103ff0:	e8 b4 f2 ff ff       	call   801032a9 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103ff5:	8b 00                	mov    (%eax),%eax
80103ff7:	39 d8                	cmp    %ebx,%eax
80103ff9:	76 18                	jbe    80104013 <fetchint+0x2d>
80103ffb:	8d 53 04             	lea    0x4(%ebx),%edx
80103ffe:	39 d0                	cmp    %edx,%eax
80104000:	72 18                	jb     8010401a <fetchint+0x34>
    return -1;
  *ip = *(int*)(addr);
80104002:	8b 13                	mov    (%ebx),%edx
80104004:	8b 45 0c             	mov    0xc(%ebp),%eax
80104007:	89 10                	mov    %edx,(%eax)
  return 0;
80104009:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010400e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104011:	c9                   	leave  
80104012:	c3                   	ret    
    return -1;
80104013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104018:	eb f4                	jmp    8010400e <fetchint+0x28>
8010401a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010401f:	eb ed                	jmp    8010400e <fetchint+0x28>

80104021 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104021:	55                   	push   %ebp
80104022:	89 e5                	mov    %esp,%ebp
80104024:	53                   	push   %ebx
80104025:	83 ec 04             	sub    $0x4,%esp
80104028:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010402b:	e8 79 f2 ff ff       	call   801032a9 <myproc>

  if(addr >= curproc->sz)
80104030:	39 18                	cmp    %ebx,(%eax)
80104032:	76 25                	jbe    80104059 <fetchstr+0x38>
    return -1;
  *pp = (char*)addr;
80104034:	8b 55 0c             	mov    0xc(%ebp),%edx
80104037:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104039:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010403b:	89 d8                	mov    %ebx,%eax
8010403d:	eb 03                	jmp    80104042 <fetchstr+0x21>
8010403f:	83 c0 01             	add    $0x1,%eax
80104042:	39 d0                	cmp    %edx,%eax
80104044:	73 09                	jae    8010404f <fetchstr+0x2e>
    if(*s == 0)
80104046:	80 38 00             	cmpb   $0x0,(%eax)
80104049:	75 f4                	jne    8010403f <fetchstr+0x1e>
      return s - *pp;
8010404b:	29 d8                	sub    %ebx,%eax
8010404d:	eb 05                	jmp    80104054 <fetchstr+0x33>
  }
  return -1;
8010404f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104057:	c9                   	leave  
80104058:	c3                   	ret    
    return -1;
80104059:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010405e:	eb f4                	jmp    80104054 <fetchstr+0x33>

80104060 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104060:	55                   	push   %ebp
80104061:	89 e5                	mov    %esp,%ebp
80104063:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104066:	e8 3e f2 ff ff       	call   801032a9 <myproc>
8010406b:	8b 50 18             	mov    0x18(%eax),%edx
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	c1 e0 02             	shl    $0x2,%eax
80104074:	03 42 44             	add    0x44(%edx),%eax
80104077:	83 ec 08             	sub    $0x8,%esp
8010407a:	ff 75 0c             	push   0xc(%ebp)
8010407d:	83 c0 04             	add    $0x4,%eax
80104080:	50                   	push   %eax
80104081:	e8 60 ff ff ff       	call   80103fe6 <fetchint>
}
80104086:	c9                   	leave  
80104087:	c3                   	ret    

80104088 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104088:	55                   	push   %ebp
80104089:	89 e5                	mov    %esp,%ebp
8010408b:	56                   	push   %esi
8010408c:	53                   	push   %ebx
8010408d:	83 ec 10             	sub    $0x10,%esp
80104090:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104093:	e8 11 f2 ff ff       	call   801032a9 <myproc>
80104098:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010409a:	83 ec 08             	sub    $0x8,%esp
8010409d:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040a0:	50                   	push   %eax
801040a1:	ff 75 08             	push   0x8(%ebp)
801040a4:	e8 b7 ff ff ff       	call   80104060 <argint>
801040a9:	83 c4 10             	add    $0x10,%esp
801040ac:	85 c0                	test   %eax,%eax
801040ae:	78 24                	js     801040d4 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801040b0:	85 db                	test   %ebx,%ebx
801040b2:	78 27                	js     801040db <argptr+0x53>
801040b4:	8b 16                	mov    (%esi),%edx
801040b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b9:	39 c2                	cmp    %eax,%edx
801040bb:	76 25                	jbe    801040e2 <argptr+0x5a>
801040bd:	01 c3                	add    %eax,%ebx
801040bf:	39 da                	cmp    %ebx,%edx
801040c1:	72 26                	jb     801040e9 <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801040c6:	89 02                	mov    %eax,(%edx)
  return 0;
801040c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040d0:	5b                   	pop    %ebx
801040d1:	5e                   	pop    %esi
801040d2:	5d                   	pop    %ebp
801040d3:	c3                   	ret    
    return -1;
801040d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d9:	eb f2                	jmp    801040cd <argptr+0x45>
    return -1;
801040db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e0:	eb eb                	jmp    801040cd <argptr+0x45>
801040e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e7:	eb e4                	jmp    801040cd <argptr+0x45>
801040e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040ee:	eb dd                	jmp    801040cd <argptr+0x45>

801040f0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040f0:	55                   	push   %ebp
801040f1:	89 e5                	mov    %esp,%ebp
801040f3:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040f9:	50                   	push   %eax
801040fa:	ff 75 08             	push   0x8(%ebp)
801040fd:	e8 5e ff ff ff       	call   80104060 <argint>
80104102:	83 c4 10             	add    $0x10,%esp
80104105:	85 c0                	test   %eax,%eax
80104107:	78 13                	js     8010411c <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104109:	83 ec 08             	sub    $0x8,%esp
8010410c:	ff 75 0c             	push   0xc(%ebp)
8010410f:	ff 75 f4             	push   -0xc(%ebp)
80104112:	e8 0a ff ff ff       	call   80104021 <fetchstr>
80104117:	83 c4 10             	add    $0x10,%esp
}
8010411a:	c9                   	leave  
8010411b:	c3                   	ret    
    return -1;
8010411c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104121:	eb f7                	jmp    8010411a <argstr+0x2a>

80104123 <syscall>:

};

void
syscall(void)
{
80104123:	55                   	push   %ebp
80104124:	89 e5                	mov    %esp,%ebp
80104126:	53                   	push   %ebx
80104127:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010412a:	e8 7a f1 ff ff       	call   801032a9 <myproc>
8010412f:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104131:	8b 40 18             	mov    0x18(%eax),%eax
80104134:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104137:	8d 50 ff             	lea    -0x1(%eax),%edx
8010413a:	83 fa 1a             	cmp    $0x1a,%edx
8010413d:	77 17                	ja     80104156 <syscall+0x33>
8010413f:	8b 14 85 80 70 10 80 	mov    -0x7fef8f80(,%eax,4),%edx
80104146:	85 d2                	test   %edx,%edx
80104148:	74 0c                	je     80104156 <syscall+0x33>
    curproc->tf->eax = syscalls[num]();
8010414a:	ff d2                	call   *%edx
8010414c:	89 c2                	mov    %eax,%edx
8010414e:	8b 43 18             	mov    0x18(%ebx),%eax
80104151:	89 50 1c             	mov    %edx,0x1c(%eax)
80104154:	eb 1f                	jmp    80104175 <syscall+0x52>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104156:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104159:	50                   	push   %eax
8010415a:	52                   	push   %edx
8010415b:	ff 73 10             	push   0x10(%ebx)
8010415e:	68 55 70 10 80       	push   $0x80107055
80104163:	e8 9f c4 ff ff       	call   80100607 <cprintf>
    curproc->tf->eax = -1;
80104168:	8b 43 18             	mov    0x18(%ebx),%eax
8010416b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104172:	83 c4 10             	add    $0x10,%esp
  }
}
80104175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104178:	c9                   	leave  
80104179:	c3                   	ret    

8010417a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010417a:	55                   	push   %ebp
8010417b:	89 e5                	mov    %esp,%ebp
8010417d:	56                   	push   %esi
8010417e:	53                   	push   %ebx
8010417f:	83 ec 18             	sub    $0x18,%esp
80104182:	89 d6                	mov    %edx,%esi
80104184:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104186:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104189:	52                   	push   %edx
8010418a:	50                   	push   %eax
8010418b:	e8 d0 fe ff ff       	call   80104060 <argint>
80104190:	83 c4 10             	add    $0x10,%esp
80104193:	85 c0                	test   %eax,%eax
80104195:	78 35                	js     801041cc <argfd+0x52>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104197:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010419b:	77 28                	ja     801041c5 <argfd+0x4b>
8010419d:	e8 07 f1 ff ff       	call   801032a9 <myproc>
801041a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a5:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
801041a9:	85 c0                	test   %eax,%eax
801041ab:	74 18                	je     801041c5 <argfd+0x4b>
    return -1;
  if(pfd)
801041ad:	85 f6                	test   %esi,%esi
801041af:	74 02                	je     801041b3 <argfd+0x39>
    *pfd = fd;
801041b1:	89 16                	mov    %edx,(%esi)
  if(pf)
801041b3:	85 db                	test   %ebx,%ebx
801041b5:	74 1c                	je     801041d3 <argfd+0x59>
    *pf = f;
801041b7:	89 03                	mov    %eax,(%ebx)
  return 0;
801041b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041c1:	5b                   	pop    %ebx
801041c2:	5e                   	pop    %esi
801041c3:	5d                   	pop    %ebp
801041c4:	c3                   	ret    
    return -1;
801041c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ca:	eb f2                	jmp    801041be <argfd+0x44>
    return -1;
801041cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d1:	eb eb                	jmp    801041be <argfd+0x44>
  return 0;
801041d3:	b8 00 00 00 00       	mov    $0x0,%eax
801041d8:	eb e4                	jmp    801041be <argfd+0x44>

801041da <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041da:	55                   	push   %ebp
801041db:	89 e5                	mov    %esp,%ebp
801041dd:	53                   	push   %ebx
801041de:	83 ec 04             	sub    $0x4,%esp
801041e1:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041e3:	e8 c1 f0 ff ff       	call   801032a9 <myproc>
801041e8:	89 c2                	mov    %eax,%edx

  for(fd = 0; fd < NOFILE; fd++){
801041ea:	b8 00 00 00 00       	mov    $0x0,%eax
801041ef:	83 f8 0f             	cmp    $0xf,%eax
801041f2:	7f 12                	jg     80104206 <fdalloc+0x2c>
    if(curproc->ofile[fd] == 0){
801041f4:	83 7c 82 28 00       	cmpl   $0x0,0x28(%edx,%eax,4)
801041f9:	74 05                	je     80104200 <fdalloc+0x26>
  for(fd = 0; fd < NOFILE; fd++){
801041fb:	83 c0 01             	add    $0x1,%eax
801041fe:	eb ef                	jmp    801041ef <fdalloc+0x15>
      curproc->ofile[fd] = f;
80104200:	89 5c 82 28          	mov    %ebx,0x28(%edx,%eax,4)
      return fd;
80104204:	eb 05                	jmp    8010420b <fdalloc+0x31>
    }
  }
  return -1;
80104206:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010420b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010420e:	c9                   	leave  
8010420f:	c3                   	ret    

80104210 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	56                   	push   %esi
80104214:	53                   	push   %ebx
80104215:	83 ec 10             	sub    $0x10,%esp
80104218:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010421a:	b8 20 00 00 00       	mov    $0x20,%eax
8010421f:	89 c6                	mov    %eax,%esi
80104221:	39 43 58             	cmp    %eax,0x58(%ebx)
80104224:	76 2e                	jbe    80104254 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104226:	6a 10                	push   $0x10
80104228:	50                   	push   %eax
80104229:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010422c:	50                   	push   %eax
8010422d:	53                   	push   %ebx
8010422e:	e8 2e d5 ff ff       	call   80101761 <readi>
80104233:	83 c4 10             	add    $0x10,%esp
80104236:	83 f8 10             	cmp    $0x10,%eax
80104239:	75 0c                	jne    80104247 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010423b:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104240:	75 1e                	jne    80104260 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104242:	8d 46 10             	lea    0x10(%esi),%eax
80104245:	eb d8                	jmp    8010421f <isdirempty+0xf>
      panic("isdirempty: readi");
80104247:	83 ec 0c             	sub    $0xc,%esp
8010424a:	68 f0 70 10 80       	push   $0x801070f0
8010424f:	e8 f4 c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104254:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104259:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010425c:	5b                   	pop    %ebx
8010425d:	5e                   	pop    %esi
8010425e:	5d                   	pop    %ebp
8010425f:	c3                   	ret    
      return 0;
80104260:	b8 00 00 00 00       	mov    $0x0,%eax
80104265:	eb f2                	jmp    80104259 <isdirempty+0x49>

80104267 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104267:	55                   	push   %ebp
80104268:	89 e5                	mov    %esp,%ebp
8010426a:	57                   	push   %edi
8010426b:	56                   	push   %esi
8010426c:	53                   	push   %ebx
8010426d:	83 ec 34             	sub    $0x34,%esp
80104270:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104273:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104276:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104279:	8d 55 da             	lea    -0x26(%ebp),%edx
8010427c:	52                   	push   %edx
8010427d:	50                   	push   %eax
8010427e:	e8 62 d9 ff ff       	call   80101be5 <nameiparent>
80104283:	89 c6                	mov    %eax,%esi
80104285:	83 c4 10             	add    $0x10,%esp
80104288:	85 c0                	test   %eax,%eax
8010428a:	0f 84 33 01 00 00    	je     801043c3 <create+0x15c>
    return 0;
  ilock(dp);
80104290:	83 ec 0c             	sub    $0xc,%esp
80104293:	50                   	push   %eax
80104294:	e8 d6 d2 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104299:	83 c4 0c             	add    $0xc,%esp
8010429c:	6a 00                	push   $0x0
8010429e:	8d 45 da             	lea    -0x26(%ebp),%eax
801042a1:	50                   	push   %eax
801042a2:	56                   	push   %esi
801042a3:	e8 f7 d6 ff ff       	call   8010199f <dirlookup>
801042a8:	89 c3                	mov    %eax,%ebx
801042aa:	83 c4 10             	add    $0x10,%esp
801042ad:	85 c0                	test   %eax,%eax
801042af:	74 3d                	je     801042ee <create+0x87>
    iunlockput(dp);
801042b1:	83 ec 0c             	sub    $0xc,%esp
801042b4:	56                   	push   %esi
801042b5:	e8 5c d4 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801042ba:	89 1c 24             	mov    %ebx,(%esp)
801042bd:	e8 ad d2 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042c2:	83 c4 10             	add    $0x10,%esp
801042c5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801042ca:	75 07                	jne    801042d3 <create+0x6c>
801042cc:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042d1:	74 11                	je     801042e4 <create+0x7d>
      return ip;
    iunlockput(ip);
801042d3:	83 ec 0c             	sub    $0xc,%esp
801042d6:	53                   	push   %ebx
801042d7:	e8 3a d4 ff ff       	call   80101716 <iunlockput>
    return 0;
801042dc:	83 c4 10             	add    $0x10,%esp
801042df:	bb 00 00 00 00       	mov    $0x0,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042e4:	89 d8                	mov    %ebx,%eax
801042e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042e9:	5b                   	pop    %ebx
801042ea:	5e                   	pop    %esi
801042eb:	5f                   	pop    %edi
801042ec:	5d                   	pop    %ebp
801042ed:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
801042ee:	83 ec 08             	sub    $0x8,%esp
801042f1:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801042f5:	50                   	push   %eax
801042f6:	ff 36                	push   (%esi)
801042f8:	e8 6f d0 ff ff       	call   8010136c <ialloc>
801042fd:	89 c3                	mov    %eax,%ebx
801042ff:	83 c4 10             	add    $0x10,%esp
80104302:	85 c0                	test   %eax,%eax
80104304:	74 52                	je     80104358 <create+0xf1>
  ilock(ip);
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	50                   	push   %eax
8010430a:	e8 60 d2 ff ff       	call   8010156f <ilock>
  ip->major = major;
8010430f:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104313:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104317:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010431b:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104321:	89 1c 24             	mov    %ebx,(%esp)
80104324:	e8 e5 d0 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104329:	83 c4 10             	add    $0x10,%esp
8010432c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104331:	74 32                	je     80104365 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
80104333:	83 ec 04             	sub    $0x4,%esp
80104336:	ff 73 04             	push   0x4(%ebx)
80104339:	8d 45 da             	lea    -0x26(%ebp),%eax
8010433c:	50                   	push   %eax
8010433d:	56                   	push   %esi
8010433e:	e8 d9 d7 ff ff       	call   80101b1c <dirlink>
80104343:	83 c4 10             	add    $0x10,%esp
80104346:	85 c0                	test   %eax,%eax
80104348:	78 6c                	js     801043b6 <create+0x14f>
  iunlockput(dp);
8010434a:	83 ec 0c             	sub    $0xc,%esp
8010434d:	56                   	push   %esi
8010434e:	e8 c3 d3 ff ff       	call   80101716 <iunlockput>
  return ip;
80104353:	83 c4 10             	add    $0x10,%esp
80104356:	eb 8c                	jmp    801042e4 <create+0x7d>
    panic("create: ialloc");
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 02 71 10 80       	push   $0x80107102
80104360:	e8 e3 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104365:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104369:	83 c0 01             	add    $0x1,%eax
8010436c:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104370:	83 ec 0c             	sub    $0xc,%esp
80104373:	56                   	push   %esi
80104374:	e8 95 d0 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104379:	83 c4 0c             	add    $0xc,%esp
8010437c:	ff 73 04             	push   0x4(%ebx)
8010437f:	68 12 71 10 80       	push   $0x80107112
80104384:	53                   	push   %ebx
80104385:	e8 92 d7 ff ff       	call   80101b1c <dirlink>
8010438a:	83 c4 10             	add    $0x10,%esp
8010438d:	85 c0                	test   %eax,%eax
8010438f:	78 18                	js     801043a9 <create+0x142>
80104391:	83 ec 04             	sub    $0x4,%esp
80104394:	ff 76 04             	push   0x4(%esi)
80104397:	68 11 71 10 80       	push   $0x80107111
8010439c:	53                   	push   %ebx
8010439d:	e8 7a d7 ff ff       	call   80101b1c <dirlink>
801043a2:	83 c4 10             	add    $0x10,%esp
801043a5:	85 c0                	test   %eax,%eax
801043a7:	79 8a                	jns    80104333 <create+0xcc>
      panic("create dots");
801043a9:	83 ec 0c             	sub    $0xc,%esp
801043ac:	68 14 71 10 80       	push   $0x80107114
801043b1:	e8 92 bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043b6:	83 ec 0c             	sub    $0xc,%esp
801043b9:	68 20 71 10 80       	push   $0x80107120
801043be:	e8 85 bf ff ff       	call   80100348 <panic>
    return 0;
801043c3:	89 c3                	mov    %eax,%ebx
801043c5:	e9 1a ff ff ff       	jmp    801042e4 <create+0x7d>

801043ca <sys_writecount>:
  w_count++;
801043ca:	a1 58 3e 11 80       	mov    0x80113e58,%eax
801043cf:	83 c0 01             	add    $0x1,%eax
801043d2:	a3 58 3e 11 80       	mov    %eax,0x80113e58
}
801043d7:	c3                   	ret    

801043d8 <sys_setwritecount>:
sys_setwritecount(void) {
801043d8:	55                   	push   %ebp
801043d9:	89 e5                	mov    %esp,%ebp
801043db:	83 ec 20             	sub    $0x20,%esp
  if(argint(0, &i) < 0){
801043de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043e1:	50                   	push   %eax
801043e2:	6a 00                	push   $0x0
801043e4:	e8 77 fc ff ff       	call   80104060 <argint>
801043e9:	83 c4 10             	add    $0x10,%esp
801043ec:	85 c0                	test   %eax,%eax
801043ee:	78 0f                	js     801043ff <sys_setwritecount+0x27>
  w_count = i;
801043f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f3:	a3 58 3e 11 80       	mov    %eax,0x80113e58
  return 0;
801043f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043fd:	c9                   	leave  
801043fe:	c3                   	ret    
    return -1;
801043ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104404:	eb f7                	jmp    801043fd <sys_setwritecount+0x25>

80104406 <sys_dup>:
{
80104406:	55                   	push   %ebp
80104407:	89 e5                	mov    %esp,%ebp
80104409:	53                   	push   %ebx
8010440a:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010440d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104410:	ba 00 00 00 00       	mov    $0x0,%edx
80104415:	b8 00 00 00 00       	mov    $0x0,%eax
8010441a:	e8 5b fd ff ff       	call   8010417a <argfd>
8010441f:	85 c0                	test   %eax,%eax
80104421:	78 23                	js     80104446 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104426:	e8 af fd ff ff       	call   801041da <fdalloc>
8010442b:	89 c3                	mov    %eax,%ebx
8010442d:	85 c0                	test   %eax,%eax
8010442f:	78 1c                	js     8010444d <sys_dup+0x47>
  filedup(f);
80104431:	83 ec 0c             	sub    $0xc,%esp
80104434:	ff 75 f4             	push   -0xc(%ebp)
80104437:	e8 42 c8 ff ff       	call   80100c7e <filedup>
  return fd;
8010443c:	83 c4 10             	add    $0x10,%esp
}
8010443f:	89 d8                	mov    %ebx,%eax
80104441:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104444:	c9                   	leave  
80104445:	c3                   	ret    
    return -1;
80104446:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010444b:	eb f2                	jmp    8010443f <sys_dup+0x39>
    return -1;
8010444d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104452:	eb eb                	jmp    8010443f <sys_dup+0x39>

80104454 <sys_read>:
{
80104454:	55                   	push   %ebp
80104455:	89 e5                	mov    %esp,%ebp
80104457:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010445a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010445d:	ba 00 00 00 00       	mov    $0x0,%edx
80104462:	b8 00 00 00 00       	mov    $0x0,%eax
80104467:	e8 0e fd ff ff       	call   8010417a <argfd>
8010446c:	85 c0                	test   %eax,%eax
8010446e:	78 43                	js     801044b3 <sys_read+0x5f>
80104470:	83 ec 08             	sub    $0x8,%esp
80104473:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104476:	50                   	push   %eax
80104477:	6a 02                	push   $0x2
80104479:	e8 e2 fb ff ff       	call   80104060 <argint>
8010447e:	83 c4 10             	add    $0x10,%esp
80104481:	85 c0                	test   %eax,%eax
80104483:	78 2e                	js     801044b3 <sys_read+0x5f>
80104485:	83 ec 04             	sub    $0x4,%esp
80104488:	ff 75 f0             	push   -0x10(%ebp)
8010448b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010448e:	50                   	push   %eax
8010448f:	6a 01                	push   $0x1
80104491:	e8 f2 fb ff ff       	call   80104088 <argptr>
80104496:	83 c4 10             	add    $0x10,%esp
80104499:	85 c0                	test   %eax,%eax
8010449b:	78 16                	js     801044b3 <sys_read+0x5f>
  return fileread(f, p, n);
8010449d:	83 ec 04             	sub    $0x4,%esp
801044a0:	ff 75 f0             	push   -0x10(%ebp)
801044a3:	ff 75 ec             	push   -0x14(%ebp)
801044a6:	ff 75 f4             	push   -0xc(%ebp)
801044a9:	e8 22 c9 ff ff       	call   80100dd0 <fileread>
801044ae:	83 c4 10             	add    $0x10,%esp
}
801044b1:	c9                   	leave  
801044b2:	c3                   	ret    
    return -1;
801044b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044b8:	eb f7                	jmp    801044b1 <sys_read+0x5d>

801044ba <sys_write>:
{
801044ba:	55                   	push   %ebp
801044bb:	89 e5                	mov    %esp,%ebp
801044bd:	83 ec 18             	sub    $0x18,%esp
  sys_writecount(); // ADDED THIS LINE
801044c0:	e8 05 ff ff ff       	call   801043ca <sys_writecount>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044c5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044c8:	ba 00 00 00 00       	mov    $0x0,%edx
801044cd:	b8 00 00 00 00       	mov    $0x0,%eax
801044d2:	e8 a3 fc ff ff       	call   8010417a <argfd>
801044d7:	85 c0                	test   %eax,%eax
801044d9:	78 43                	js     8010451e <sys_write+0x64>
801044db:	83 ec 08             	sub    $0x8,%esp
801044de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044e1:	50                   	push   %eax
801044e2:	6a 02                	push   $0x2
801044e4:	e8 77 fb ff ff       	call   80104060 <argint>
801044e9:	83 c4 10             	add    $0x10,%esp
801044ec:	85 c0                	test   %eax,%eax
801044ee:	78 2e                	js     8010451e <sys_write+0x64>
801044f0:	83 ec 04             	sub    $0x4,%esp
801044f3:	ff 75 f0             	push   -0x10(%ebp)
801044f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044f9:	50                   	push   %eax
801044fa:	6a 01                	push   $0x1
801044fc:	e8 87 fb ff ff       	call   80104088 <argptr>
80104501:	83 c4 10             	add    $0x10,%esp
80104504:	85 c0                	test   %eax,%eax
80104506:	78 16                	js     8010451e <sys_write+0x64>
  return filewrite(f, p, n);
80104508:	83 ec 04             	sub    $0x4,%esp
8010450b:	ff 75 f0             	push   -0x10(%ebp)
8010450e:	ff 75 ec             	push   -0x14(%ebp)
80104511:	ff 75 f4             	push   -0xc(%ebp)
80104514:	e8 3c c9 ff ff       	call   80100e55 <filewrite>
80104519:	83 c4 10             	add    $0x10,%esp
}
8010451c:	c9                   	leave  
8010451d:	c3                   	ret    
    return -1;
8010451e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104523:	eb f7                	jmp    8010451c <sys_write+0x62>

80104525 <sys_close>:
{
80104525:	55                   	push   %ebp
80104526:	89 e5                	mov    %esp,%ebp
80104528:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010452b:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010452e:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104531:	b8 00 00 00 00       	mov    $0x0,%eax
80104536:	e8 3f fc ff ff       	call   8010417a <argfd>
8010453b:	85 c0                	test   %eax,%eax
8010453d:	78 25                	js     80104564 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010453f:	e8 65 ed ff ff       	call   801032a9 <myproc>
80104544:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104547:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010454e:	00 
  fileclose(f);
8010454f:	83 ec 0c             	sub    $0xc,%esp
80104552:	ff 75 f0             	push   -0x10(%ebp)
80104555:	e8 69 c7 ff ff       	call   80100cc3 <fileclose>
  return 0;
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104562:	c9                   	leave  
80104563:	c3                   	ret    
    return -1;
80104564:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104569:	eb f7                	jmp    80104562 <sys_close+0x3d>

8010456b <sys_fstat>:
{
8010456b:	55                   	push   %ebp
8010456c:	89 e5                	mov    %esp,%ebp
8010456e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104571:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104574:	ba 00 00 00 00       	mov    $0x0,%edx
80104579:	b8 00 00 00 00       	mov    $0x0,%eax
8010457e:	e8 f7 fb ff ff       	call   8010417a <argfd>
80104583:	85 c0                	test   %eax,%eax
80104585:	78 2a                	js     801045b1 <sys_fstat+0x46>
80104587:	83 ec 04             	sub    $0x4,%esp
8010458a:	6a 14                	push   $0x14
8010458c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010458f:	50                   	push   %eax
80104590:	6a 01                	push   $0x1
80104592:	e8 f1 fa ff ff       	call   80104088 <argptr>
80104597:	83 c4 10             	add    $0x10,%esp
8010459a:	85 c0                	test   %eax,%eax
8010459c:	78 13                	js     801045b1 <sys_fstat+0x46>
  return filestat(f, st);
8010459e:	83 ec 08             	sub    $0x8,%esp
801045a1:	ff 75 f0             	push   -0x10(%ebp)
801045a4:	ff 75 f4             	push   -0xc(%ebp)
801045a7:	e8 dd c7 ff ff       	call   80100d89 <filestat>
801045ac:	83 c4 10             	add    $0x10,%esp
}
801045af:	c9                   	leave  
801045b0:	c3                   	ret    
    return -1;
801045b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b6:	eb f7                	jmp    801045af <sys_fstat+0x44>

801045b8 <sys_link>:
{
801045b8:	55                   	push   %ebp
801045b9:	89 e5                	mov    %esp,%ebp
801045bb:	56                   	push   %esi
801045bc:	53                   	push   %ebx
801045bd:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801045c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801045c3:	50                   	push   %eax
801045c4:	6a 00                	push   $0x0
801045c6:	e8 25 fb ff ff       	call   801040f0 <argstr>
801045cb:	83 c4 10             	add    $0x10,%esp
801045ce:	85 c0                	test   %eax,%eax
801045d0:	0f 88 d3 00 00 00    	js     801046a9 <sys_link+0xf1>
801045d6:	83 ec 08             	sub    $0x8,%esp
801045d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045dc:	50                   	push   %eax
801045dd:	6a 01                	push   $0x1
801045df:	e8 0c fb ff ff       	call   801040f0 <argstr>
801045e4:	83 c4 10             	add    $0x10,%esp
801045e7:	85 c0                	test   %eax,%eax
801045e9:	0f 88 ba 00 00 00    	js     801046a9 <sys_link+0xf1>
  begin_op();
801045ef:	e8 bc e1 ff ff       	call   801027b0 <begin_op>
  if((ip = namei(old)) == 0){
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	ff 75 e0             	push   -0x20(%ebp)
801045fa:	e8 ce d5 ff ff       	call   80101bcd <namei>
801045ff:	89 c3                	mov    %eax,%ebx
80104601:	83 c4 10             	add    $0x10,%esp
80104604:	85 c0                	test   %eax,%eax
80104606:	0f 84 a4 00 00 00    	je     801046b0 <sys_link+0xf8>
  ilock(ip);
8010460c:	83 ec 0c             	sub    $0xc,%esp
8010460f:	50                   	push   %eax
80104610:	e8 5a cf ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
80104615:	83 c4 10             	add    $0x10,%esp
80104618:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010461d:	0f 84 99 00 00 00    	je     801046bc <sys_link+0x104>
  ip->nlink++;
80104623:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104627:	83 c0 01             	add    $0x1,%eax
8010462a:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010462e:	83 ec 0c             	sub    $0xc,%esp
80104631:	53                   	push   %ebx
80104632:	e8 d7 cd ff ff       	call   8010140e <iupdate>
  iunlock(ip);
80104637:	89 1c 24             	mov    %ebx,(%esp)
8010463a:	e8 f2 cf ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
8010463f:	83 c4 08             	add    $0x8,%esp
80104642:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104645:	50                   	push   %eax
80104646:	ff 75 e4             	push   -0x1c(%ebp)
80104649:	e8 97 d5 ff ff       	call   80101be5 <nameiparent>
8010464e:	89 c6                	mov    %eax,%esi
80104650:	83 c4 10             	add    $0x10,%esp
80104653:	85 c0                	test   %eax,%eax
80104655:	0f 84 85 00 00 00    	je     801046e0 <sys_link+0x128>
  ilock(dp);
8010465b:	83 ec 0c             	sub    $0xc,%esp
8010465e:	50                   	push   %eax
8010465f:	e8 0b cf ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104664:	83 c4 10             	add    $0x10,%esp
80104667:	8b 03                	mov    (%ebx),%eax
80104669:	39 06                	cmp    %eax,(%esi)
8010466b:	75 67                	jne    801046d4 <sys_link+0x11c>
8010466d:	83 ec 04             	sub    $0x4,%esp
80104670:	ff 73 04             	push   0x4(%ebx)
80104673:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104676:	50                   	push   %eax
80104677:	56                   	push   %esi
80104678:	e8 9f d4 ff ff       	call   80101b1c <dirlink>
8010467d:	83 c4 10             	add    $0x10,%esp
80104680:	85 c0                	test   %eax,%eax
80104682:	78 50                	js     801046d4 <sys_link+0x11c>
  iunlockput(dp);
80104684:	83 ec 0c             	sub    $0xc,%esp
80104687:	56                   	push   %esi
80104688:	e8 89 d0 ff ff       	call   80101716 <iunlockput>
  iput(ip);
8010468d:	89 1c 24             	mov    %ebx,(%esp)
80104690:	e8 e1 cf ff ff       	call   80101676 <iput>
  end_op();
80104695:	e8 90 e1 ff ff       	call   8010282a <end_op>
  return 0;
8010469a:	83 c4 10             	add    $0x10,%esp
8010469d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046a5:	5b                   	pop    %ebx
801046a6:	5e                   	pop    %esi
801046a7:	5d                   	pop    %ebp
801046a8:	c3                   	ret    
    return -1;
801046a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ae:	eb f2                	jmp    801046a2 <sys_link+0xea>
    end_op();
801046b0:	e8 75 e1 ff ff       	call   8010282a <end_op>
    return -1;
801046b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ba:	eb e6                	jmp    801046a2 <sys_link+0xea>
    iunlockput(ip);
801046bc:	83 ec 0c             	sub    $0xc,%esp
801046bf:	53                   	push   %ebx
801046c0:	e8 51 d0 ff ff       	call   80101716 <iunlockput>
    end_op();
801046c5:	e8 60 e1 ff ff       	call   8010282a <end_op>
    return -1;
801046ca:	83 c4 10             	add    $0x10,%esp
801046cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d2:	eb ce                	jmp    801046a2 <sys_link+0xea>
    iunlockput(dp);
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	56                   	push   %esi
801046d8:	e8 39 d0 ff ff       	call   80101716 <iunlockput>
    goto bad;
801046dd:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046e0:	83 ec 0c             	sub    $0xc,%esp
801046e3:	53                   	push   %ebx
801046e4:	e8 86 ce ff ff       	call   8010156f <ilock>
  ip->nlink--;
801046e9:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046ed:	83 e8 01             	sub    $0x1,%eax
801046f0:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046f4:	89 1c 24             	mov    %ebx,(%esp)
801046f7:	e8 12 cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801046fc:	89 1c 24             	mov    %ebx,(%esp)
801046ff:	e8 12 d0 ff ff       	call   80101716 <iunlockput>
  end_op();
80104704:	e8 21 e1 ff ff       	call   8010282a <end_op>
  return -1;
80104709:	83 c4 10             	add    $0x10,%esp
8010470c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104711:	eb 8f                	jmp    801046a2 <sys_link+0xea>

80104713 <sys_unlink>:
{
80104713:	55                   	push   %ebp
80104714:	89 e5                	mov    %esp,%ebp
80104716:	57                   	push   %edi
80104717:	56                   	push   %esi
80104718:	53                   	push   %ebx
80104719:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010471c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010471f:	50                   	push   %eax
80104720:	6a 00                	push   $0x0
80104722:	e8 c9 f9 ff ff       	call   801040f0 <argstr>
80104727:	83 c4 10             	add    $0x10,%esp
8010472a:	85 c0                	test   %eax,%eax
8010472c:	0f 88 83 01 00 00    	js     801048b5 <sys_unlink+0x1a2>
  begin_op();
80104732:	e8 79 e0 ff ff       	call   801027b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104737:	83 ec 08             	sub    $0x8,%esp
8010473a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010473d:	50                   	push   %eax
8010473e:	ff 75 c4             	push   -0x3c(%ebp)
80104741:	e8 9f d4 ff ff       	call   80101be5 <nameiparent>
80104746:	89 c6                	mov    %eax,%esi
80104748:	83 c4 10             	add    $0x10,%esp
8010474b:	85 c0                	test   %eax,%eax
8010474d:	0f 84 ed 00 00 00    	je     80104840 <sys_unlink+0x12d>
  ilock(dp);
80104753:	83 ec 0c             	sub    $0xc,%esp
80104756:	50                   	push   %eax
80104757:	e8 13 ce ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010475c:	83 c4 08             	add    $0x8,%esp
8010475f:	68 12 71 10 80       	push   $0x80107112
80104764:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104767:	50                   	push   %eax
80104768:	e8 1d d2 ff ff       	call   8010198a <namecmp>
8010476d:	83 c4 10             	add    $0x10,%esp
80104770:	85 c0                	test   %eax,%eax
80104772:	0f 84 fc 00 00 00    	je     80104874 <sys_unlink+0x161>
80104778:	83 ec 08             	sub    $0x8,%esp
8010477b:	68 11 71 10 80       	push   $0x80107111
80104780:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104783:	50                   	push   %eax
80104784:	e8 01 d2 ff ff       	call   8010198a <namecmp>
80104789:	83 c4 10             	add    $0x10,%esp
8010478c:	85 c0                	test   %eax,%eax
8010478e:	0f 84 e0 00 00 00    	je     80104874 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104794:	83 ec 04             	sub    $0x4,%esp
80104797:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010479a:	50                   	push   %eax
8010479b:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010479e:	50                   	push   %eax
8010479f:	56                   	push   %esi
801047a0:	e8 fa d1 ff ff       	call   8010199f <dirlookup>
801047a5:	89 c3                	mov    %eax,%ebx
801047a7:	83 c4 10             	add    $0x10,%esp
801047aa:	85 c0                	test   %eax,%eax
801047ac:	0f 84 c2 00 00 00    	je     80104874 <sys_unlink+0x161>
  ilock(ip);
801047b2:	83 ec 0c             	sub    $0xc,%esp
801047b5:	50                   	push   %eax
801047b6:	e8 b4 cd ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
801047bb:	83 c4 10             	add    $0x10,%esp
801047be:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801047c3:	0f 8e 83 00 00 00    	jle    8010484c <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047c9:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047ce:	0f 84 85 00 00 00    	je     80104859 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047d4:	83 ec 04             	sub    $0x4,%esp
801047d7:	6a 10                	push   $0x10
801047d9:	6a 00                	push   $0x0
801047db:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047de:	57                   	push   %edi
801047df:	e8 2c f6 ff ff       	call   80103e10 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047e4:	6a 10                	push   $0x10
801047e6:	ff 75 c0             	push   -0x40(%ebp)
801047e9:	57                   	push   %edi
801047ea:	56                   	push   %esi
801047eb:	e8 6e d0 ff ff       	call   8010185e <writei>
801047f0:	83 c4 20             	add    $0x20,%esp
801047f3:	83 f8 10             	cmp    $0x10,%eax
801047f6:	0f 85 90 00 00 00    	jne    8010488c <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047fc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104801:	0f 84 92 00 00 00    	je     80104899 <sys_unlink+0x186>
  iunlockput(dp);
80104807:	83 ec 0c             	sub    $0xc,%esp
8010480a:	56                   	push   %esi
8010480b:	e8 06 cf ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
80104810:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104814:	83 e8 01             	sub    $0x1,%eax
80104817:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010481b:	89 1c 24             	mov    %ebx,(%esp)
8010481e:	e8 eb cb ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
80104823:	89 1c 24             	mov    %ebx,(%esp)
80104826:	e8 eb ce ff ff       	call   80101716 <iunlockput>
  end_op();
8010482b:	e8 fa df ff ff       	call   8010282a <end_op>
  return 0;
80104830:	83 c4 10             	add    $0x10,%esp
80104833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104838:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010483b:	5b                   	pop    %ebx
8010483c:	5e                   	pop    %esi
8010483d:	5f                   	pop    %edi
8010483e:	5d                   	pop    %ebp
8010483f:	c3                   	ret    
    end_op();
80104840:	e8 e5 df ff ff       	call   8010282a <end_op>
    return -1;
80104845:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010484a:	eb ec                	jmp    80104838 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
8010484c:	83 ec 0c             	sub    $0xc,%esp
8010484f:	68 30 71 10 80       	push   $0x80107130
80104854:	e8 ef ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104859:	89 d8                	mov    %ebx,%eax
8010485b:	e8 b0 f9 ff ff       	call   80104210 <isdirempty>
80104860:	85 c0                	test   %eax,%eax
80104862:	0f 85 6c ff ff ff    	jne    801047d4 <sys_unlink+0xc1>
    iunlockput(ip);
80104868:	83 ec 0c             	sub    $0xc,%esp
8010486b:	53                   	push   %ebx
8010486c:	e8 a5 ce ff ff       	call   80101716 <iunlockput>
    goto bad;
80104871:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104874:	83 ec 0c             	sub    $0xc,%esp
80104877:	56                   	push   %esi
80104878:	e8 99 ce ff ff       	call   80101716 <iunlockput>
  end_op();
8010487d:	e8 a8 df ff ff       	call   8010282a <end_op>
  return -1;
80104882:	83 c4 10             	add    $0x10,%esp
80104885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010488a:	eb ac                	jmp    80104838 <sys_unlink+0x125>
    panic("unlink: writei");
8010488c:	83 ec 0c             	sub    $0xc,%esp
8010488f:	68 42 71 10 80       	push   $0x80107142
80104894:	e8 af ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104899:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010489d:	83 e8 01             	sub    $0x1,%eax
801048a0:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801048a4:	83 ec 0c             	sub    $0xc,%esp
801048a7:	56                   	push   %esi
801048a8:	e8 61 cb ff ff       	call   8010140e <iupdate>
801048ad:	83 c4 10             	add    $0x10,%esp
801048b0:	e9 52 ff ff ff       	jmp    80104807 <sys_unlink+0xf4>
    return -1;
801048b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ba:	e9 79 ff ff ff       	jmp    80104838 <sys_unlink+0x125>

801048bf <sys_open>:

int
sys_open(void)
{
801048bf:	55                   	push   %ebp
801048c0:	89 e5                	mov    %esp,%ebp
801048c2:	57                   	push   %edi
801048c3:	56                   	push   %esi
801048c4:	53                   	push   %ebx
801048c5:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801048c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048cb:	50                   	push   %eax
801048cc:	6a 00                	push   $0x0
801048ce:	e8 1d f8 ff ff       	call   801040f0 <argstr>
801048d3:	83 c4 10             	add    $0x10,%esp
801048d6:	85 c0                	test   %eax,%eax
801048d8:	0f 88 a0 00 00 00    	js     8010497e <sys_open+0xbf>
801048de:	83 ec 08             	sub    $0x8,%esp
801048e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048e4:	50                   	push   %eax
801048e5:	6a 01                	push   $0x1
801048e7:	e8 74 f7 ff ff       	call   80104060 <argint>
801048ec:	83 c4 10             	add    $0x10,%esp
801048ef:	85 c0                	test   %eax,%eax
801048f1:	0f 88 87 00 00 00    	js     8010497e <sys_open+0xbf>
    return -1;

  begin_op();
801048f7:	e8 b4 de ff ff       	call   801027b0 <begin_op>

  if(omode & O_CREATE){
801048fc:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104900:	0f 84 8b 00 00 00    	je     80104991 <sys_open+0xd2>
    ip = create(path, T_FILE, 0, 0);
80104906:	83 ec 0c             	sub    $0xc,%esp
80104909:	6a 00                	push   $0x0
8010490b:	b9 00 00 00 00       	mov    $0x0,%ecx
80104910:	ba 02 00 00 00       	mov    $0x2,%edx
80104915:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104918:	e8 4a f9 ff ff       	call   80104267 <create>
8010491d:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010491f:	83 c4 10             	add    $0x10,%esp
80104922:	85 c0                	test   %eax,%eax
80104924:	74 5f                	je     80104985 <sys_open+0xc6>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104926:	e8 f2 c2 ff ff       	call   80100c1d <filealloc>
8010492b:	89 c3                	mov    %eax,%ebx
8010492d:	85 c0                	test   %eax,%eax
8010492f:	0f 84 b5 00 00 00    	je     801049ea <sys_open+0x12b>
80104935:	e8 a0 f8 ff ff       	call   801041da <fdalloc>
8010493a:	89 c7                	mov    %eax,%edi
8010493c:	85 c0                	test   %eax,%eax
8010493e:	0f 88 a6 00 00 00    	js     801049ea <sys_open+0x12b>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104944:	83 ec 0c             	sub    $0xc,%esp
80104947:	56                   	push   %esi
80104948:	e8 e4 cc ff ff       	call   80101631 <iunlock>
  end_op();
8010494d:	e8 d8 de ff ff       	call   8010282a <end_op>

  f->type = FD_INODE;
80104952:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104958:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010495b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104962:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104965:	83 c4 10             	add    $0x10,%esp
80104968:	a8 01                	test   $0x1,%al
8010496a:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010496e:	a8 03                	test   $0x3,%al
80104970:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104974:	89 f8                	mov    %edi,%eax
80104976:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104979:	5b                   	pop    %ebx
8010497a:	5e                   	pop    %esi
8010497b:	5f                   	pop    %edi
8010497c:	5d                   	pop    %ebp
8010497d:	c3                   	ret    
    return -1;
8010497e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104983:	eb ef                	jmp    80104974 <sys_open+0xb5>
      end_op();
80104985:	e8 a0 de ff ff       	call   8010282a <end_op>
      return -1;
8010498a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010498f:	eb e3                	jmp    80104974 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104991:	83 ec 0c             	sub    $0xc,%esp
80104994:	ff 75 e4             	push   -0x1c(%ebp)
80104997:	e8 31 d2 ff ff       	call   80101bcd <namei>
8010499c:	89 c6                	mov    %eax,%esi
8010499e:	83 c4 10             	add    $0x10,%esp
801049a1:	85 c0                	test   %eax,%eax
801049a3:	74 39                	je     801049de <sys_open+0x11f>
    ilock(ip);
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	50                   	push   %eax
801049a9:	e8 c1 cb ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801049ae:	83 c4 10             	add    $0x10,%esp
801049b1:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801049b6:	0f 85 6a ff ff ff    	jne    80104926 <sys_open+0x67>
801049bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801049c0:	0f 84 60 ff ff ff    	je     80104926 <sys_open+0x67>
      iunlockput(ip);
801049c6:	83 ec 0c             	sub    $0xc,%esp
801049c9:	56                   	push   %esi
801049ca:	e8 47 cd ff ff       	call   80101716 <iunlockput>
      end_op();
801049cf:	e8 56 de ff ff       	call   8010282a <end_op>
      return -1;
801049d4:	83 c4 10             	add    $0x10,%esp
801049d7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049dc:	eb 96                	jmp    80104974 <sys_open+0xb5>
      end_op();
801049de:	e8 47 de ff ff       	call   8010282a <end_op>
      return -1;
801049e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049e8:	eb 8a                	jmp    80104974 <sys_open+0xb5>
    if(f)
801049ea:	85 db                	test   %ebx,%ebx
801049ec:	74 0c                	je     801049fa <sys_open+0x13b>
      fileclose(f);
801049ee:	83 ec 0c             	sub    $0xc,%esp
801049f1:	53                   	push   %ebx
801049f2:	e8 cc c2 ff ff       	call   80100cc3 <fileclose>
801049f7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049fa:	83 ec 0c             	sub    $0xc,%esp
801049fd:	56                   	push   %esi
801049fe:	e8 13 cd ff ff       	call   80101716 <iunlockput>
    end_op();
80104a03:	e8 22 de ff ff       	call   8010282a <end_op>
    return -1;
80104a08:	83 c4 10             	add    $0x10,%esp
80104a0b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a10:	e9 5f ff ff ff       	jmp    80104974 <sys_open+0xb5>

80104a15 <sys_mkdir>:

int
sys_mkdir(void)
{
80104a15:	55                   	push   %ebp
80104a16:	89 e5                	mov    %esp,%ebp
80104a18:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a1b:	e8 90 dd ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a20:	83 ec 08             	sub    $0x8,%esp
80104a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a26:	50                   	push   %eax
80104a27:	6a 00                	push   $0x0
80104a29:	e8 c2 f6 ff ff       	call   801040f0 <argstr>
80104a2e:	83 c4 10             	add    $0x10,%esp
80104a31:	85 c0                	test   %eax,%eax
80104a33:	78 36                	js     80104a6b <sys_mkdir+0x56>
80104a35:	83 ec 0c             	sub    $0xc,%esp
80104a38:	6a 00                	push   $0x0
80104a3a:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a3f:	ba 01 00 00 00       	mov    $0x1,%edx
80104a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a47:	e8 1b f8 ff ff       	call   80104267 <create>
80104a4c:	83 c4 10             	add    $0x10,%esp
80104a4f:	85 c0                	test   %eax,%eax
80104a51:	74 18                	je     80104a6b <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a53:	83 ec 0c             	sub    $0xc,%esp
80104a56:	50                   	push   %eax
80104a57:	e8 ba cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104a5c:	e8 c9 dd ff ff       	call   8010282a <end_op>
  return 0;
80104a61:	83 c4 10             	add    $0x10,%esp
80104a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a69:	c9                   	leave  
80104a6a:	c3                   	ret    
    end_op();
80104a6b:	e8 ba dd ff ff       	call   8010282a <end_op>
    return -1;
80104a70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a75:	eb f2                	jmp    80104a69 <sys_mkdir+0x54>

80104a77 <sys_mknod>:

int
sys_mknod(void)
{
80104a77:	55                   	push   %ebp
80104a78:	89 e5                	mov    %esp,%ebp
80104a7a:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a7d:	e8 2e dd ff ff       	call   801027b0 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a82:	83 ec 08             	sub    $0x8,%esp
80104a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a88:	50                   	push   %eax
80104a89:	6a 00                	push   $0x0
80104a8b:	e8 60 f6 ff ff       	call   801040f0 <argstr>
80104a90:	83 c4 10             	add    $0x10,%esp
80104a93:	85 c0                	test   %eax,%eax
80104a95:	78 62                	js     80104af9 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a97:	83 ec 08             	sub    $0x8,%esp
80104a9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a9d:	50                   	push   %eax
80104a9e:	6a 01                	push   $0x1
80104aa0:	e8 bb f5 ff ff       	call   80104060 <argint>
  if((argstr(0, &path)) < 0 ||
80104aa5:	83 c4 10             	add    $0x10,%esp
80104aa8:	85 c0                	test   %eax,%eax
80104aaa:	78 4d                	js     80104af9 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104aac:	83 ec 08             	sub    $0x8,%esp
80104aaf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ab2:	50                   	push   %eax
80104ab3:	6a 02                	push   $0x2
80104ab5:	e8 a6 f5 ff ff       	call   80104060 <argint>
     argint(1, &major) < 0 ||
80104aba:	83 c4 10             	add    $0x10,%esp
80104abd:	85 c0                	test   %eax,%eax
80104abf:	78 38                	js     80104af9 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104ac1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104ac5:	83 ec 0c             	sub    $0xc,%esp
80104ac8:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104acc:	50                   	push   %eax
80104acd:	ba 03 00 00 00       	mov    $0x3,%edx
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	e8 8d f7 ff ff       	call   80104267 <create>
     argint(2, &minor) < 0 ||
80104ada:	83 c4 10             	add    $0x10,%esp
80104add:	85 c0                	test   %eax,%eax
80104adf:	74 18                	je     80104af9 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ae1:	83 ec 0c             	sub    $0xc,%esp
80104ae4:	50                   	push   %eax
80104ae5:	e8 2c cc ff ff       	call   80101716 <iunlockput>
  end_op();
80104aea:	e8 3b dd ff ff       	call   8010282a <end_op>
  return 0;
80104aef:	83 c4 10             	add    $0x10,%esp
80104af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104af7:	c9                   	leave  
80104af8:	c3                   	ret    
    end_op();
80104af9:	e8 2c dd ff ff       	call   8010282a <end_op>
    return -1;
80104afe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b03:	eb f2                	jmp    80104af7 <sys_mknod+0x80>

80104b05 <sys_chdir>:

int
sys_chdir(void)
{
80104b05:	55                   	push   %ebp
80104b06:	89 e5                	mov    %esp,%ebp
80104b08:	56                   	push   %esi
80104b09:	53                   	push   %ebx
80104b0a:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b0d:	e8 97 e7 ff ff       	call   801032a9 <myproc>
80104b12:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104b14:	e8 97 dc ff ff       	call   801027b0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b19:	83 ec 08             	sub    $0x8,%esp
80104b1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b1f:	50                   	push   %eax
80104b20:	6a 00                	push   $0x0
80104b22:	e8 c9 f5 ff ff       	call   801040f0 <argstr>
80104b27:	83 c4 10             	add    $0x10,%esp
80104b2a:	85 c0                	test   %eax,%eax
80104b2c:	78 52                	js     80104b80 <sys_chdir+0x7b>
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	ff 75 f4             	push   -0xc(%ebp)
80104b34:	e8 94 d0 ff ff       	call   80101bcd <namei>
80104b39:	89 c3                	mov    %eax,%ebx
80104b3b:	83 c4 10             	add    $0x10,%esp
80104b3e:	85 c0                	test   %eax,%eax
80104b40:	74 3e                	je     80104b80 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b42:	83 ec 0c             	sub    $0xc,%esp
80104b45:	50                   	push   %eax
80104b46:	e8 24 ca ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104b4b:	83 c4 10             	add    $0x10,%esp
80104b4e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b53:	75 37                	jne    80104b8c <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b55:	83 ec 0c             	sub    $0xc,%esp
80104b58:	53                   	push   %ebx
80104b59:	e8 d3 ca ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104b5e:	83 c4 04             	add    $0x4,%esp
80104b61:	ff 76 68             	push   0x68(%esi)
80104b64:	e8 0d cb ff ff       	call   80101676 <iput>
  end_op();
80104b69:	e8 bc dc ff ff       	call   8010282a <end_op>
  curproc->cwd = ip;
80104b6e:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b71:	83 c4 10             	add    $0x10,%esp
80104b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b79:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b7c:	5b                   	pop    %ebx
80104b7d:	5e                   	pop    %esi
80104b7e:	5d                   	pop    %ebp
80104b7f:	c3                   	ret    
    end_op();
80104b80:	e8 a5 dc ff ff       	call   8010282a <end_op>
    return -1;
80104b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b8a:	eb ed                	jmp    80104b79 <sys_chdir+0x74>
    iunlockput(ip);
80104b8c:	83 ec 0c             	sub    $0xc,%esp
80104b8f:	53                   	push   %ebx
80104b90:	e8 81 cb ff ff       	call   80101716 <iunlockput>
    end_op();
80104b95:	e8 90 dc ff ff       	call   8010282a <end_op>
    return -1;
80104b9a:	83 c4 10             	add    $0x10,%esp
80104b9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba2:	eb d5                	jmp    80104b79 <sys_chdir+0x74>

80104ba4 <sys_exec>:

int
sys_exec(void)
{
80104ba4:	55                   	push   %ebp
80104ba5:	89 e5                	mov    %esp,%ebp
80104ba7:	53                   	push   %ebx
80104ba8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104bae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bb1:	50                   	push   %eax
80104bb2:	6a 00                	push   $0x0
80104bb4:	e8 37 f5 ff ff       	call   801040f0 <argstr>
80104bb9:	83 c4 10             	add    $0x10,%esp
80104bbc:	85 c0                	test   %eax,%eax
80104bbe:	78 38                	js     80104bf8 <sys_exec+0x54>
80104bc0:	83 ec 08             	sub    $0x8,%esp
80104bc3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bc9:	50                   	push   %eax
80104bca:	6a 01                	push   $0x1
80104bcc:	e8 8f f4 ff ff       	call   80104060 <argint>
80104bd1:	83 c4 10             	add    $0x10,%esp
80104bd4:	85 c0                	test   %eax,%eax
80104bd6:	78 20                	js     80104bf8 <sys_exec+0x54>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bd8:	83 ec 04             	sub    $0x4,%esp
80104bdb:	68 80 00 00 00       	push   $0x80
80104be0:	6a 00                	push   $0x0
80104be2:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104be8:	50                   	push   %eax
80104be9:	e8 22 f2 ff ff       	call   80103e10 <memset>
80104bee:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
80104bf6:	eb 2c                	jmp    80104c24 <sys_exec+0x80>
    return -1;
80104bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfd:	eb 78                	jmp    80104c77 <sys_exec+0xd3>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104bff:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c06:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104c0a:	83 ec 08             	sub    $0x8,%esp
80104c0d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c13:	50                   	push   %eax
80104c14:	ff 75 f4             	push   -0xc(%ebp)
80104c17:	e8 b2 bc ff ff       	call   801008ce <exec>
80104c1c:	83 c4 10             	add    $0x10,%esp
80104c1f:	eb 56                	jmp    80104c77 <sys_exec+0xd3>
  for(i=0;; i++){
80104c21:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c24:	83 fb 1f             	cmp    $0x1f,%ebx
80104c27:	77 49                	ja     80104c72 <sys_exec+0xce>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c29:	83 ec 08             	sub    $0x8,%esp
80104c2c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104c32:	50                   	push   %eax
80104c33:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104c39:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104c3c:	50                   	push   %eax
80104c3d:	e8 a4 f3 ff ff       	call   80103fe6 <fetchint>
80104c42:	83 c4 10             	add    $0x10,%esp
80104c45:	85 c0                	test   %eax,%eax
80104c47:	78 33                	js     80104c7c <sys_exec+0xd8>
    if(uarg == 0){
80104c49:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c4f:	85 c0                	test   %eax,%eax
80104c51:	74 ac                	je     80104bff <sys_exec+0x5b>
    if(fetchstr(uarg, &argv[i]) < 0)
80104c53:	83 ec 08             	sub    $0x8,%esp
80104c56:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c5d:	52                   	push   %edx
80104c5e:	50                   	push   %eax
80104c5f:	e8 bd f3 ff ff       	call   80104021 <fetchstr>
80104c64:	83 c4 10             	add    $0x10,%esp
80104c67:	85 c0                	test   %eax,%eax
80104c69:	79 b6                	jns    80104c21 <sys_exec+0x7d>
      return -1;
80104c6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c70:	eb 05                	jmp    80104c77 <sys_exec+0xd3>
      return -1;
80104c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c7a:	c9                   	leave  
80104c7b:	c3                   	ret    
      return -1;
80104c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c81:	eb f4                	jmp    80104c77 <sys_exec+0xd3>

80104c83 <sys_pipe>:

int
sys_pipe(void)
{
80104c83:	55                   	push   %ebp
80104c84:	89 e5                	mov    %esp,%ebp
80104c86:	53                   	push   %ebx
80104c87:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c8a:	6a 08                	push   $0x8
80104c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c8f:	50                   	push   %eax
80104c90:	6a 00                	push   $0x0
80104c92:	e8 f1 f3 ff ff       	call   80104088 <argptr>
80104c97:	83 c4 10             	add    $0x10,%esp
80104c9a:	85 c0                	test   %eax,%eax
80104c9c:	78 79                	js     80104d17 <sys_pipe+0x94>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c9e:	83 ec 08             	sub    $0x8,%esp
80104ca1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ca4:	50                   	push   %eax
80104ca5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ca8:	50                   	push   %eax
80104ca9:	e8 be e0 ff ff       	call   80102d6c <pipealloc>
80104cae:	83 c4 10             	add    $0x10,%esp
80104cb1:	85 c0                	test   %eax,%eax
80104cb3:	78 69                	js     80104d1e <sys_pipe+0x9b>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cb8:	e8 1d f5 ff ff       	call   801041da <fdalloc>
80104cbd:	89 c3                	mov    %eax,%ebx
80104cbf:	85 c0                	test   %eax,%eax
80104cc1:	78 21                	js     80104ce4 <sys_pipe+0x61>
80104cc3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cc6:	e8 0f f5 ff ff       	call   801041da <fdalloc>
80104ccb:	85 c0                	test   %eax,%eax
80104ccd:	78 15                	js     80104ce4 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ccf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd2:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd7:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce2:	c9                   	leave  
80104ce3:	c3                   	ret    
    if(fd0 >= 0)
80104ce4:	85 db                	test   %ebx,%ebx
80104ce6:	79 20                	jns    80104d08 <sys_pipe+0x85>
    fileclose(rf);
80104ce8:	83 ec 0c             	sub    $0xc,%esp
80104ceb:	ff 75 f0             	push   -0x10(%ebp)
80104cee:	e8 d0 bf ff ff       	call   80100cc3 <fileclose>
    fileclose(wf);
80104cf3:	83 c4 04             	add    $0x4,%esp
80104cf6:	ff 75 ec             	push   -0x14(%ebp)
80104cf9:	e8 c5 bf ff ff       	call   80100cc3 <fileclose>
    return -1;
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d06:	eb d7                	jmp    80104cdf <sys_pipe+0x5c>
      myproc()->ofile[fd0] = 0;
80104d08:	e8 9c e5 ff ff       	call   801032a9 <myproc>
80104d0d:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104d14:	00 
80104d15:	eb d1                	jmp    80104ce8 <sys_pipe+0x65>
    return -1;
80104d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1c:	eb c1                	jmp    80104cdf <sys_pipe+0x5c>
    return -1;
80104d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d23:	eb ba                	jmp    80104cdf <sys_pipe+0x5c>

80104d25 <sys_settickets>:
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_settickets(void) {
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
80104d28:	53                   	push   %ebx
80104d29:	83 ec 1c             	sub    $0x1c,%esp
  int i;
  if(argint(0, &i) < 0){
80104d2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d2f:	50                   	push   %eax
80104d30:	6a 00                	push   $0x0
80104d32:	e8 29 f3 ff ff       	call   80104060 <argint>
80104d37:	83 c4 10             	add    $0x10,%esp
80104d3a:	85 c0                	test   %eax,%eax
80104d3c:	78 18                	js     80104d56 <sys_settickets+0x31>
    return -1;
  }
  myproc()->tickets = i;
80104d3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80104d41:	e8 63 e5 ff ff       	call   801032a9 <myproc>
80104d46:	89 98 80 00 00 00    	mov    %ebx,0x80(%eax)
  return 0;
80104d4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d54:	c9                   	leave  
80104d55:	c3                   	ret    
    return -1;
80104d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d5b:	eb f4                	jmp    80104d51 <sys_settickets+0x2c>

80104d5d <sys_fork>:

int
sys_fork(void)
{
80104d5d:	55                   	push   %ebp
80104d5e:	89 e5                	mov    %esp,%ebp
80104d60:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d63:	e8 c8 e6 ff ff       	call   80103430 <fork>
}
80104d68:	c9                   	leave  
80104d69:	c3                   	ret    

80104d6a <sys_exit>:

int
sys_exit(void)
{
80104d6a:	55                   	push   %ebp
80104d6b:	89 e5                	mov    %esp,%ebp
80104d6d:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d70:	e8 4e e9 ff ff       	call   801036c3 <exit>
  return 0;  // not reached
}
80104d75:	b8 00 00 00 00       	mov    $0x0,%eax
80104d7a:	c9                   	leave  
80104d7b:	c3                   	ret    

80104d7c <sys_wait>:

int
sys_wait(void)
{
80104d7c:	55                   	push   %ebp
80104d7d:	89 e5                	mov    %esp,%ebp
80104d7f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d82:	e8 c8 ea ff ff       	call   8010384f <wait>
}
80104d87:	c9                   	leave  
80104d88:	c3                   	ret    

80104d89 <sys_kill>:

int
sys_kill(void)
{
80104d89:	55                   	push   %ebp
80104d8a:	89 e5                	mov    %esp,%ebp
80104d8c:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d92:	50                   	push   %eax
80104d93:	6a 00                	push   $0x0
80104d95:	e8 c6 f2 ff ff       	call   80104060 <argint>
80104d9a:	83 c4 10             	add    $0x10,%esp
80104d9d:	85 c0                	test   %eax,%eax
80104d9f:	78 10                	js     80104db1 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104da1:	83 ec 0c             	sub    $0xc,%esp
80104da4:	ff 75 f4             	push   -0xc(%ebp)
80104da7:	e8 a3 eb ff ff       	call   8010394f <kill>
80104dac:	83 c4 10             	add    $0x10,%esp
}
80104daf:	c9                   	leave  
80104db0:	c3                   	ret    
    return -1;
80104db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104db6:	eb f7                	jmp    80104daf <sys_kill+0x26>

80104db8 <sys_getpid>:

int
sys_getpid(void)
{
80104db8:	55                   	push   %ebp
80104db9:	89 e5                	mov    %esp,%ebp
80104dbb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104dbe:	e8 e6 e4 ff ff       	call   801032a9 <myproc>
80104dc3:	8b 40 10             	mov    0x10(%eax),%eax
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <sys_sbrk>:

int
sys_sbrk(void)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	53                   	push   %ebx
80104dcc:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104dcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dd2:	50                   	push   %eax
80104dd3:	6a 00                	push   $0x0
80104dd5:	e8 86 f2 ff ff       	call   80104060 <argint>
80104dda:	83 c4 10             	add    $0x10,%esp
80104ddd:	85 c0                	test   %eax,%eax
80104ddf:	78 20                	js     80104e01 <sys_sbrk+0x39>
    return -1;
  addr = myproc()->sz;
80104de1:	e8 c3 e4 ff ff       	call   801032a9 <myproc>
80104de6:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104de8:	83 ec 0c             	sub    $0xc,%esp
80104deb:	ff 75 f4             	push   -0xc(%ebp)
80104dee:	e8 d2 e5 ff ff       	call   801033c5 <growproc>
80104df3:	83 c4 10             	add    $0x10,%esp
80104df6:	85 c0                	test   %eax,%eax
80104df8:	78 0e                	js     80104e08 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80104dfa:	89 d8                	mov    %ebx,%eax
80104dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dff:	c9                   	leave  
80104e00:	c3                   	ret    
    return -1;
80104e01:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e06:	eb f2                	jmp    80104dfa <sys_sbrk+0x32>
    return -1;
80104e08:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e0d:	eb eb                	jmp    80104dfa <sys_sbrk+0x32>

80104e0f <sys_sleep>:

int
sys_sleep(void)
{
80104e0f:	55                   	push   %ebp
80104e10:	89 e5                	mov    %esp,%ebp
80104e12:	53                   	push   %ebx
80104e13:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e19:	50                   	push   %eax
80104e1a:	6a 00                	push   $0x0
80104e1c:	e8 3f f2 ff ff       	call   80104060 <argint>
80104e21:	83 c4 10             	add    $0x10,%esp
80104e24:	85 c0                	test   %eax,%eax
80104e26:	78 75                	js     80104e9d <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104e28:	83 ec 0c             	sub    $0xc,%esp
80104e2b:	68 80 3e 11 80       	push   $0x80113e80
80104e30:	e8 2f ef ff ff       	call   80103d64 <acquire>
  ticks0 = ticks;
80104e35:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  while(ticks - ticks0 < n){
80104e3b:	83 c4 10             	add    $0x10,%esp
80104e3e:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104e43:	29 d8                	sub    %ebx,%eax
80104e45:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e48:	73 39                	jae    80104e83 <sys_sleep+0x74>
    if(myproc()->killed){
80104e4a:	e8 5a e4 ff ff       	call   801032a9 <myproc>
80104e4f:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e53:	75 17                	jne    80104e6c <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e55:	83 ec 08             	sub    $0x8,%esp
80104e58:	68 80 3e 11 80       	push   $0x80113e80
80104e5d:	68 60 3e 11 80       	push   $0x80113e60
80104e62:	e8 57 e9 ff ff       	call   801037be <sleep>
80104e67:	83 c4 10             	add    $0x10,%esp
80104e6a:	eb d2                	jmp    80104e3e <sys_sleep+0x2f>
      release(&tickslock);
80104e6c:	83 ec 0c             	sub    $0xc,%esp
80104e6f:	68 80 3e 11 80       	push   $0x80113e80
80104e74:	e8 50 ef ff ff       	call   80103dc9 <release>
      return -1;
80104e79:	83 c4 10             	add    $0x10,%esp
80104e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e81:	eb 15                	jmp    80104e98 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e83:	83 ec 0c             	sub    $0xc,%esp
80104e86:	68 80 3e 11 80       	push   $0x80113e80
80104e8b:	e8 39 ef ff ff       	call   80103dc9 <release>
  return 0;
80104e90:	83 c4 10             	add    $0x10,%esp
80104e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e9b:	c9                   	leave  
80104e9c:	c3                   	ret    
    return -1;
80104e9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ea2:	eb f4                	jmp    80104e98 <sys_sleep+0x89>

80104ea4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104ea4:	55                   	push   %ebp
80104ea5:	89 e5                	mov    %esp,%ebp
80104ea7:	53                   	push   %ebx
80104ea8:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104eab:	68 80 3e 11 80       	push   $0x80113e80
80104eb0:	e8 af ee ff ff       	call   80103d64 <acquire>
  xticks = ticks;
80104eb5:	8b 1d 60 3e 11 80    	mov    0x80113e60,%ebx
  release(&tickslock);
80104ebb:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80104ec2:	e8 02 ef ff ff       	call   80103dc9 <release>
  return xticks;
}
80104ec7:	89 d8                	mov    %ebx,%eax
80104ec9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ecc:	c9                   	leave  
80104ecd:	c3                   	ret    

80104ece <sys_yield>:

int
sys_yield(void)
{
80104ece:	55                   	push   %ebp
80104ecf:	89 e5                	mov    %esp,%ebp
80104ed1:	83 ec 08             	sub    $0x8,%esp
  yield();
80104ed4:	e8 b3 e8 ff ff       	call   8010378c <yield>
  return 0;
}
80104ed9:	b8 00 00 00 00       	mov    $0x0,%eax
80104ede:	c9                   	leave  
80104edf:	c3                   	ret    

80104ee0 <sys_shutdown>:

int sys_shutdown(void)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
80104ee3:	83 ec 08             	sub    $0x8,%esp
  shutdown();
80104ee6:	e8 10 d3 ff ff       	call   801021fb <shutdown>
  return 0;
}
80104eeb:	b8 00 00 00 00       	mov    $0x0,%eax
80104ef0:	c9                   	leave  
80104ef1:	c3                   	ret    

80104ef2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104ef2:	1e                   	push   %ds
  pushl %es
80104ef3:	06                   	push   %es
  pushl %fs
80104ef4:	0f a0                	push   %fs
  pushl %gs
80104ef6:	0f a8                	push   %gs
  pushal
80104ef8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104ef9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104efd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104eff:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f01:	54                   	push   %esp
  call trap
80104f02:	e8 37 01 00 00       	call   8010503e <trap>
  addl $4, %esp
80104f07:	83 c4 04             	add    $0x4,%esp

80104f0a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f0a:	61                   	popa   
  popl %gs
80104f0b:	0f a9                	pop    %gs
  popl %fs
80104f0d:	0f a1                	pop    %fs
  popl %es
80104f0f:	07                   	pop    %es
  popl %ds
80104f10:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f11:	83 c4 08             	add    $0x8,%esp
  iret
80104f14:	cf                   	iret   

80104f15 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f15:	55                   	push   %ebp
80104f16:	89 e5                	mov    %esp,%ebp
80104f18:	53                   	push   %ebx
80104f19:	83 ec 04             	sub    $0x4,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f1c:	b8 00 00 00 00       	mov    $0x0,%eax
80104f21:	eb 76                	jmp    80104f99 <tvinit+0x84>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f23:	8b 0c 85 0c a0 10 80 	mov    -0x7fef5ff4(,%eax,4),%ecx
80104f2a:	66 89 0c c5 c0 3e 11 	mov    %cx,-0x7feec140(,%eax,8)
80104f31:	80 
80104f32:	66 c7 04 c5 c2 3e 11 	movw   $0x8,-0x7feec13e(,%eax,8)
80104f39:	80 08 00 
80104f3c:	0f b6 14 c5 c4 3e 11 	movzbl -0x7feec13c(,%eax,8),%edx
80104f43:	80 
80104f44:	83 e2 e0             	and    $0xffffffe0,%edx
80104f47:	88 14 c5 c4 3e 11 80 	mov    %dl,-0x7feec13c(,%eax,8)
80104f4e:	c6 04 c5 c4 3e 11 80 	movb   $0x0,-0x7feec13c(,%eax,8)
80104f55:	00 
80104f56:	0f b6 14 c5 c5 3e 11 	movzbl -0x7feec13b(,%eax,8),%edx
80104f5d:	80 
80104f5e:	83 e2 f0             	and    $0xfffffff0,%edx
80104f61:	83 ca 0e             	or     $0xe,%edx
80104f64:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104f6b:	89 d3                	mov    %edx,%ebx
80104f6d:	83 e3 ef             	and    $0xffffffef,%ebx
80104f70:	88 1c c5 c5 3e 11 80 	mov    %bl,-0x7feec13b(,%eax,8)
80104f77:	83 e2 8f             	and    $0xffffff8f,%edx
80104f7a:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104f81:	83 ca 80             	or     $0xffffff80,%edx
80104f84:	88 14 c5 c5 3e 11 80 	mov    %dl,-0x7feec13b(,%eax,8)
80104f8b:	c1 e9 10             	shr    $0x10,%ecx
80104f8e:	66 89 0c c5 c6 3e 11 	mov    %cx,-0x7feec13a(,%eax,8)
80104f95:	80 
  for(i = 0; i < 256; i++)
80104f96:	83 c0 01             	add    $0x1,%eax
80104f99:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f9e:	7e 83                	jle    80104f23 <tvinit+0xe>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104fa0:	8b 15 0c a1 10 80    	mov    0x8010a10c,%edx
80104fa6:	66 89 15 c0 40 11 80 	mov    %dx,0x801140c0
80104fad:	66 c7 05 c2 40 11 80 	movw   $0x8,0x801140c2
80104fb4:	08 00 
80104fb6:	0f b6 05 c4 40 11 80 	movzbl 0x801140c4,%eax
80104fbd:	83 e0 e0             	and    $0xffffffe0,%eax
80104fc0:	a2 c4 40 11 80       	mov    %al,0x801140c4
80104fc5:	c6 05 c4 40 11 80 00 	movb   $0x0,0x801140c4
80104fcc:	0f b6 05 c5 40 11 80 	movzbl 0x801140c5,%eax
80104fd3:	83 c8 0f             	or     $0xf,%eax
80104fd6:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104fdb:	83 e0 ef             	and    $0xffffffef,%eax
80104fde:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104fe3:	89 c1                	mov    %eax,%ecx
80104fe5:	83 c9 60             	or     $0x60,%ecx
80104fe8:	88 0d c5 40 11 80    	mov    %cl,0x801140c5
80104fee:	83 c8 e0             	or     $0xffffffe0,%eax
80104ff1:	a2 c5 40 11 80       	mov    %al,0x801140c5
80104ff6:	c1 ea 10             	shr    $0x10,%edx
80104ff9:	66 89 15 c6 40 11 80 	mov    %dx,0x801140c6

  initlock(&tickslock, "time");
80105000:	83 ec 08             	sub    $0x8,%esp
80105003:	68 51 71 10 80       	push   $0x80107151
80105008:	68 80 3e 11 80       	push   $0x80113e80
8010500d:	e8 16 ec ff ff       	call   80103c28 <initlock>
}
80105012:	83 c4 10             	add    $0x10,%esp
80105015:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105018:	c9                   	leave  
80105019:	c3                   	ret    

8010501a <idtinit>:

void
idtinit(void)
{
8010501a:	55                   	push   %ebp
8010501b:	89 e5                	mov    %esp,%ebp
8010501d:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105020:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105026:	b8 c0 3e 11 80       	mov    $0x80113ec0,%eax
8010502b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010502f:	c1 e8 10             	shr    $0x10,%eax
80105032:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105036:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105039:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010503c:	c9                   	leave  
8010503d:	c3                   	ret    

8010503e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010503e:	55                   	push   %ebp
8010503f:	89 e5                	mov    %esp,%ebp
80105041:	57                   	push   %edi
80105042:	56                   	push   %esi
80105043:	53                   	push   %ebx
80105044:	83 ec 1c             	sub    $0x1c,%esp
80105047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010504a:	8b 43 30             	mov    0x30(%ebx),%eax
8010504d:	83 f8 40             	cmp    $0x40,%eax
80105050:	74 13                	je     80105065 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105052:	83 e8 20             	sub    $0x20,%eax
80105055:	83 f8 1f             	cmp    $0x1f,%eax
80105058:	0f 87 3a 01 00 00    	ja     80105198 <trap+0x15a>
8010505e:	ff 24 85 f8 71 10 80 	jmp    *-0x7fef8e08(,%eax,4)
    if(myproc()->killed)
80105065:	e8 3f e2 ff ff       	call   801032a9 <myproc>
8010506a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010506e:	75 1f                	jne    8010508f <trap+0x51>
    myproc()->tf = tf;
80105070:	e8 34 e2 ff ff       	call   801032a9 <myproc>
80105075:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105078:	e8 a6 f0 ff ff       	call   80104123 <syscall>
    if(myproc()->killed)
8010507d:	e8 27 e2 ff ff       	call   801032a9 <myproc>
80105082:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105086:	74 7e                	je     80105106 <trap+0xc8>
      exit();
80105088:	e8 36 e6 ff ff       	call   801036c3 <exit>
    return;
8010508d:	eb 77                	jmp    80105106 <trap+0xc8>
      exit();
8010508f:	e8 2f e6 ff ff       	call   801036c3 <exit>
80105094:	eb da                	jmp    80105070 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105096:	e8 f3 e1 ff ff       	call   8010328e <cpuid>
8010509b:	85 c0                	test   %eax,%eax
8010509d:	74 6f                	je     8010510e <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
8010509f:	e8 04 d3 ff ff       	call   801023a8 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050a4:	e8 00 e2 ff ff       	call   801032a9 <myproc>
801050a9:	85 c0                	test   %eax,%eax
801050ab:	74 1c                	je     801050c9 <trap+0x8b>
801050ad:	e8 f7 e1 ff ff       	call   801032a9 <myproc>
801050b2:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050b6:	74 11                	je     801050c9 <trap+0x8b>
801050b8:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050bc:	83 e0 03             	and    $0x3,%eax
801050bf:	66 83 f8 03          	cmp    $0x3,%ax
801050c3:	0f 84 62 01 00 00    	je     8010522b <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801050c9:	e8 db e1 ff ff       	call   801032a9 <myproc>
801050ce:	85 c0                	test   %eax,%eax
801050d0:	74 0f                	je     801050e1 <trap+0xa3>
801050d2:	e8 d2 e1 ff ff       	call   801032a9 <myproc>
801050d7:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801050db:	0f 84 54 01 00 00    	je     80105235 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050e1:	e8 c3 e1 ff ff       	call   801032a9 <myproc>
801050e6:	85 c0                	test   %eax,%eax
801050e8:	74 1c                	je     80105106 <trap+0xc8>
801050ea:	e8 ba e1 ff ff       	call   801032a9 <myproc>
801050ef:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050f3:	74 11                	je     80105106 <trap+0xc8>
801050f5:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050f9:	83 e0 03             	and    $0x3,%eax
801050fc:	66 83 f8 03          	cmp    $0x3,%ax
80105100:	0f 84 43 01 00 00    	je     80105249 <trap+0x20b>
    exit();
}
80105106:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105109:	5b                   	pop    %ebx
8010510a:	5e                   	pop    %esi
8010510b:	5f                   	pop    %edi
8010510c:	5d                   	pop    %ebp
8010510d:	c3                   	ret    
      acquire(&tickslock);
8010510e:	83 ec 0c             	sub    $0xc,%esp
80105111:	68 80 3e 11 80       	push   $0x80113e80
80105116:	e8 49 ec ff ff       	call   80103d64 <acquire>
      ticks++;
8010511b:	83 05 60 3e 11 80 01 	addl   $0x1,0x80113e60
      wakeup(&ticks);
80105122:	c7 04 24 60 3e 11 80 	movl   $0x80113e60,(%esp)
80105129:	e8 f8 e7 ff ff       	call   80103926 <wakeup>
      release(&tickslock);
8010512e:	c7 04 24 80 3e 11 80 	movl   $0x80113e80,(%esp)
80105135:	e8 8f ec ff ff       	call   80103dc9 <release>
8010513a:	83 c4 10             	add    $0x10,%esp
8010513d:	e9 5d ff ff ff       	jmp    8010509f <trap+0x61>
    ideintr();
80105142:	e8 15 cc ff ff       	call   80101d5c <ideintr>
    lapiceoi();
80105147:	e8 5c d2 ff ff       	call   801023a8 <lapiceoi>
    break;
8010514c:	e9 53 ff ff ff       	jmp    801050a4 <trap+0x66>
    kbdintr();
80105151:	e8 90 d0 ff ff       	call   801021e6 <kbdintr>
    lapiceoi();
80105156:	e8 4d d2 ff ff       	call   801023a8 <lapiceoi>
    break;
8010515b:	e9 44 ff ff ff       	jmp    801050a4 <trap+0x66>
    uartintr();
80105160:	e8 fe 01 00 00       	call   80105363 <uartintr>
    lapiceoi();
80105165:	e8 3e d2 ff ff       	call   801023a8 <lapiceoi>
    break;
8010516a:	e9 35 ff ff ff       	jmp    801050a4 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010516f:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105172:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105176:	e8 13 e1 ff ff       	call   8010328e <cpuid>
8010517b:	57                   	push   %edi
8010517c:	0f b7 f6             	movzwl %si,%esi
8010517f:	56                   	push   %esi
80105180:	50                   	push   %eax
80105181:	68 5c 71 10 80       	push   $0x8010715c
80105186:	e8 7c b4 ff ff       	call   80100607 <cprintf>
    lapiceoi();
8010518b:	e8 18 d2 ff ff       	call   801023a8 <lapiceoi>
    break;
80105190:	83 c4 10             	add    $0x10,%esp
80105193:	e9 0c ff ff ff       	jmp    801050a4 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105198:	e8 0c e1 ff ff       	call   801032a9 <myproc>
8010519d:	85 c0                	test   %eax,%eax
8010519f:	74 5f                	je     80105200 <trap+0x1c2>
801051a1:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801051a5:	74 59                	je     80105200 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801051a7:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051aa:	8b 43 38             	mov    0x38(%ebx),%eax
801051ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801051b0:	e8 d9 e0 ff ff       	call   8010328e <cpuid>
801051b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801051b8:	8b 53 34             	mov    0x34(%ebx),%edx
801051bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
801051be:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801051c1:	e8 e3 e0 ff ff       	call   801032a9 <myproc>
801051c6:	8d 48 6c             	lea    0x6c(%eax),%ecx
801051c9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801051cc:	e8 d8 e0 ff ff       	call   801032a9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051d1:	57                   	push   %edi
801051d2:	ff 75 e4             	push   -0x1c(%ebp)
801051d5:	ff 75 e0             	push   -0x20(%ebp)
801051d8:	ff 75 dc             	push   -0x24(%ebp)
801051db:	56                   	push   %esi
801051dc:	ff 75 d8             	push   -0x28(%ebp)
801051df:	ff 70 10             	push   0x10(%eax)
801051e2:	68 b4 71 10 80       	push   $0x801071b4
801051e7:	e8 1b b4 ff ff       	call   80100607 <cprintf>
    myproc()->killed = 1;
801051ec:	83 c4 20             	add    $0x20,%esp
801051ef:	e8 b5 e0 ff ff       	call   801032a9 <myproc>
801051f4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801051fb:	e9 a4 fe ff ff       	jmp    801050a4 <trap+0x66>
80105200:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105203:	8b 73 38             	mov    0x38(%ebx),%esi
80105206:	e8 83 e0 ff ff       	call   8010328e <cpuid>
8010520b:	83 ec 0c             	sub    $0xc,%esp
8010520e:	57                   	push   %edi
8010520f:	56                   	push   %esi
80105210:	50                   	push   %eax
80105211:	ff 73 30             	push   0x30(%ebx)
80105214:	68 80 71 10 80       	push   $0x80107180
80105219:	e8 e9 b3 ff ff       	call   80100607 <cprintf>
      panic("trap");
8010521e:	83 c4 14             	add    $0x14,%esp
80105221:	68 56 71 10 80       	push   $0x80107156
80105226:	e8 1d b1 ff ff       	call   80100348 <panic>
    exit();
8010522b:	e8 93 e4 ff ff       	call   801036c3 <exit>
80105230:	e9 94 fe ff ff       	jmp    801050c9 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105235:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105239:	0f 85 a2 fe ff ff    	jne    801050e1 <trap+0xa3>
    yield();
8010523f:	e8 48 e5 ff ff       	call   8010378c <yield>
80105244:	e9 98 fe ff ff       	jmp    801050e1 <trap+0xa3>
    exit();
80105249:	e8 75 e4 ff ff       	call   801036c3 <exit>
8010524e:	e9 b3 fe ff ff       	jmp    80105106 <trap+0xc8>

80105253 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105253:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
8010525a:	74 14                	je     80105270 <uartgetc+0x1d>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010525c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105261:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105262:	a8 01                	test   $0x1,%al
80105264:	74 10                	je     80105276 <uartgetc+0x23>
80105266:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010526b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010526c:	0f b6 c0             	movzbl %al,%eax
8010526f:	c3                   	ret    
    return -1;
80105270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105275:	c3                   	ret    
    return -1;
80105276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010527b:	c3                   	ret    

8010527c <uartputc>:
  if(!uart)
8010527c:	83 3d c0 46 11 80 00 	cmpl   $0x0,0x801146c0
80105283:	74 3b                	je     801052c0 <uartputc+0x44>
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	53                   	push   %ebx
80105289:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010528c:	bb 00 00 00 00       	mov    $0x0,%ebx
80105291:	eb 10                	jmp    801052a3 <uartputc+0x27>
    microdelay(10);
80105293:	83 ec 0c             	sub    $0xc,%esp
80105296:	6a 0a                	push   $0xa
80105298:	e8 2c d1 ff ff       	call   801023c9 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010529d:	83 c3 01             	add    $0x1,%ebx
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	83 fb 7f             	cmp    $0x7f,%ebx
801052a6:	7f 0a                	jg     801052b2 <uartputc+0x36>
801052a8:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052ad:	ec                   	in     (%dx),%al
801052ae:	a8 20                	test   $0x20,%al
801052b0:	74 e1                	je     80105293 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801052b2:	8b 45 08             	mov    0x8(%ebp),%eax
801052b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052ba:	ee                   	out    %al,(%dx)
}
801052bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801052be:	c9                   	leave  
801052bf:	c3                   	ret    
801052c0:	c3                   	ret    

801052c1 <uartinit>:
{
801052c1:	55                   	push   %ebp
801052c2:	89 e5                	mov    %esp,%ebp
801052c4:	56                   	push   %esi
801052c5:	53                   	push   %ebx
801052c6:	b9 00 00 00 00       	mov    $0x0,%ecx
801052cb:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052d0:	89 c8                	mov    %ecx,%eax
801052d2:	ee                   	out    %al,(%dx)
801052d3:	be fb 03 00 00       	mov    $0x3fb,%esi
801052d8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801052dd:	89 f2                	mov    %esi,%edx
801052df:	ee                   	out    %al,(%dx)
801052e0:	b8 0c 00 00 00       	mov    $0xc,%eax
801052e5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052ea:	ee                   	out    %al,(%dx)
801052eb:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801052f0:	89 c8                	mov    %ecx,%eax
801052f2:	89 da                	mov    %ebx,%edx
801052f4:	ee                   	out    %al,(%dx)
801052f5:	b8 03 00 00 00       	mov    $0x3,%eax
801052fa:	89 f2                	mov    %esi,%edx
801052fc:	ee                   	out    %al,(%dx)
801052fd:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105302:	89 c8                	mov    %ecx,%eax
80105304:	ee                   	out    %al,(%dx)
80105305:	b8 01 00 00 00       	mov    $0x1,%eax
8010530a:	89 da                	mov    %ebx,%edx
8010530c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010530d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105312:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105313:	3c ff                	cmp    $0xff,%al
80105315:	74 45                	je     8010535c <uartinit+0x9b>
  uart = 1;
80105317:	c7 05 c0 46 11 80 01 	movl   $0x1,0x801146c0
8010531e:	00 00 00 
80105321:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105326:	ec                   	in     (%dx),%al
80105327:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010532c:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010532d:	83 ec 08             	sub    $0x8,%esp
80105330:	6a 00                	push   $0x0
80105332:	6a 04                	push   $0x4
80105334:	e8 28 cc ff ff       	call   80101f61 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105339:	83 c4 10             	add    $0x10,%esp
8010533c:	bb 78 72 10 80       	mov    $0x80107278,%ebx
80105341:	eb 12                	jmp    80105355 <uartinit+0x94>
    uartputc(*p);
80105343:	83 ec 0c             	sub    $0xc,%esp
80105346:	0f be c0             	movsbl %al,%eax
80105349:	50                   	push   %eax
8010534a:	e8 2d ff ff ff       	call   8010527c <uartputc>
  for(p="xv6...\n"; *p; p++)
8010534f:	83 c3 01             	add    $0x1,%ebx
80105352:	83 c4 10             	add    $0x10,%esp
80105355:	0f b6 03             	movzbl (%ebx),%eax
80105358:	84 c0                	test   %al,%al
8010535a:	75 e7                	jne    80105343 <uartinit+0x82>
}
8010535c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010535f:	5b                   	pop    %ebx
80105360:	5e                   	pop    %esi
80105361:	5d                   	pop    %ebp
80105362:	c3                   	ret    

80105363 <uartintr>:

void
uartintr(void)
{
80105363:	55                   	push   %ebp
80105364:	89 e5                	mov    %esp,%ebp
80105366:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105369:	68 53 52 10 80       	push   $0x80105253
8010536e:	e8 c0 b3 ff ff       	call   80100733 <consoleintr>
}
80105373:	83 c4 10             	add    $0x10,%esp
80105376:	c9                   	leave  
80105377:	c3                   	ret    

80105378 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105378:	6a 00                	push   $0x0
  pushl $0
8010537a:	6a 00                	push   $0x0
  jmp alltraps
8010537c:	e9 71 fb ff ff       	jmp    80104ef2 <alltraps>

80105381 <vector1>:
.globl vector1
vector1:
  pushl $0
80105381:	6a 00                	push   $0x0
  pushl $1
80105383:	6a 01                	push   $0x1
  jmp alltraps
80105385:	e9 68 fb ff ff       	jmp    80104ef2 <alltraps>

8010538a <vector2>:
.globl vector2
vector2:
  pushl $0
8010538a:	6a 00                	push   $0x0
  pushl $2
8010538c:	6a 02                	push   $0x2
  jmp alltraps
8010538e:	e9 5f fb ff ff       	jmp    80104ef2 <alltraps>

80105393 <vector3>:
.globl vector3
vector3:
  pushl $0
80105393:	6a 00                	push   $0x0
  pushl $3
80105395:	6a 03                	push   $0x3
  jmp alltraps
80105397:	e9 56 fb ff ff       	jmp    80104ef2 <alltraps>

8010539c <vector4>:
.globl vector4
vector4:
  pushl $0
8010539c:	6a 00                	push   $0x0
  pushl $4
8010539e:	6a 04                	push   $0x4
  jmp alltraps
801053a0:	e9 4d fb ff ff       	jmp    80104ef2 <alltraps>

801053a5 <vector5>:
.globl vector5
vector5:
  pushl $0
801053a5:	6a 00                	push   $0x0
  pushl $5
801053a7:	6a 05                	push   $0x5
  jmp alltraps
801053a9:	e9 44 fb ff ff       	jmp    80104ef2 <alltraps>

801053ae <vector6>:
.globl vector6
vector6:
  pushl $0
801053ae:	6a 00                	push   $0x0
  pushl $6
801053b0:	6a 06                	push   $0x6
  jmp alltraps
801053b2:	e9 3b fb ff ff       	jmp    80104ef2 <alltraps>

801053b7 <vector7>:
.globl vector7
vector7:
  pushl $0
801053b7:	6a 00                	push   $0x0
  pushl $7
801053b9:	6a 07                	push   $0x7
  jmp alltraps
801053bb:	e9 32 fb ff ff       	jmp    80104ef2 <alltraps>

801053c0 <vector8>:
.globl vector8
vector8:
  pushl $8
801053c0:	6a 08                	push   $0x8
  jmp alltraps
801053c2:	e9 2b fb ff ff       	jmp    80104ef2 <alltraps>

801053c7 <vector9>:
.globl vector9
vector9:
  pushl $0
801053c7:	6a 00                	push   $0x0
  pushl $9
801053c9:	6a 09                	push   $0x9
  jmp alltraps
801053cb:	e9 22 fb ff ff       	jmp    80104ef2 <alltraps>

801053d0 <vector10>:
.globl vector10
vector10:
  pushl $10
801053d0:	6a 0a                	push   $0xa
  jmp alltraps
801053d2:	e9 1b fb ff ff       	jmp    80104ef2 <alltraps>

801053d7 <vector11>:
.globl vector11
vector11:
  pushl $11
801053d7:	6a 0b                	push   $0xb
  jmp alltraps
801053d9:	e9 14 fb ff ff       	jmp    80104ef2 <alltraps>

801053de <vector12>:
.globl vector12
vector12:
  pushl $12
801053de:	6a 0c                	push   $0xc
  jmp alltraps
801053e0:	e9 0d fb ff ff       	jmp    80104ef2 <alltraps>

801053e5 <vector13>:
.globl vector13
vector13:
  pushl $13
801053e5:	6a 0d                	push   $0xd
  jmp alltraps
801053e7:	e9 06 fb ff ff       	jmp    80104ef2 <alltraps>

801053ec <vector14>:
.globl vector14
vector14:
  pushl $14
801053ec:	6a 0e                	push   $0xe
  jmp alltraps
801053ee:	e9 ff fa ff ff       	jmp    80104ef2 <alltraps>

801053f3 <vector15>:
.globl vector15
vector15:
  pushl $0
801053f3:	6a 00                	push   $0x0
  pushl $15
801053f5:	6a 0f                	push   $0xf
  jmp alltraps
801053f7:	e9 f6 fa ff ff       	jmp    80104ef2 <alltraps>

801053fc <vector16>:
.globl vector16
vector16:
  pushl $0
801053fc:	6a 00                	push   $0x0
  pushl $16
801053fe:	6a 10                	push   $0x10
  jmp alltraps
80105400:	e9 ed fa ff ff       	jmp    80104ef2 <alltraps>

80105405 <vector17>:
.globl vector17
vector17:
  pushl $17
80105405:	6a 11                	push   $0x11
  jmp alltraps
80105407:	e9 e6 fa ff ff       	jmp    80104ef2 <alltraps>

8010540c <vector18>:
.globl vector18
vector18:
  pushl $0
8010540c:	6a 00                	push   $0x0
  pushl $18
8010540e:	6a 12                	push   $0x12
  jmp alltraps
80105410:	e9 dd fa ff ff       	jmp    80104ef2 <alltraps>

80105415 <vector19>:
.globl vector19
vector19:
  pushl $0
80105415:	6a 00                	push   $0x0
  pushl $19
80105417:	6a 13                	push   $0x13
  jmp alltraps
80105419:	e9 d4 fa ff ff       	jmp    80104ef2 <alltraps>

8010541e <vector20>:
.globl vector20
vector20:
  pushl $0
8010541e:	6a 00                	push   $0x0
  pushl $20
80105420:	6a 14                	push   $0x14
  jmp alltraps
80105422:	e9 cb fa ff ff       	jmp    80104ef2 <alltraps>

80105427 <vector21>:
.globl vector21
vector21:
  pushl $0
80105427:	6a 00                	push   $0x0
  pushl $21
80105429:	6a 15                	push   $0x15
  jmp alltraps
8010542b:	e9 c2 fa ff ff       	jmp    80104ef2 <alltraps>

80105430 <vector22>:
.globl vector22
vector22:
  pushl $0
80105430:	6a 00                	push   $0x0
  pushl $22
80105432:	6a 16                	push   $0x16
  jmp alltraps
80105434:	e9 b9 fa ff ff       	jmp    80104ef2 <alltraps>

80105439 <vector23>:
.globl vector23
vector23:
  pushl $0
80105439:	6a 00                	push   $0x0
  pushl $23
8010543b:	6a 17                	push   $0x17
  jmp alltraps
8010543d:	e9 b0 fa ff ff       	jmp    80104ef2 <alltraps>

80105442 <vector24>:
.globl vector24
vector24:
  pushl $0
80105442:	6a 00                	push   $0x0
  pushl $24
80105444:	6a 18                	push   $0x18
  jmp alltraps
80105446:	e9 a7 fa ff ff       	jmp    80104ef2 <alltraps>

8010544b <vector25>:
.globl vector25
vector25:
  pushl $0
8010544b:	6a 00                	push   $0x0
  pushl $25
8010544d:	6a 19                	push   $0x19
  jmp alltraps
8010544f:	e9 9e fa ff ff       	jmp    80104ef2 <alltraps>

80105454 <vector26>:
.globl vector26
vector26:
  pushl $0
80105454:	6a 00                	push   $0x0
  pushl $26
80105456:	6a 1a                	push   $0x1a
  jmp alltraps
80105458:	e9 95 fa ff ff       	jmp    80104ef2 <alltraps>

8010545d <vector27>:
.globl vector27
vector27:
  pushl $0
8010545d:	6a 00                	push   $0x0
  pushl $27
8010545f:	6a 1b                	push   $0x1b
  jmp alltraps
80105461:	e9 8c fa ff ff       	jmp    80104ef2 <alltraps>

80105466 <vector28>:
.globl vector28
vector28:
  pushl $0
80105466:	6a 00                	push   $0x0
  pushl $28
80105468:	6a 1c                	push   $0x1c
  jmp alltraps
8010546a:	e9 83 fa ff ff       	jmp    80104ef2 <alltraps>

8010546f <vector29>:
.globl vector29
vector29:
  pushl $0
8010546f:	6a 00                	push   $0x0
  pushl $29
80105471:	6a 1d                	push   $0x1d
  jmp alltraps
80105473:	e9 7a fa ff ff       	jmp    80104ef2 <alltraps>

80105478 <vector30>:
.globl vector30
vector30:
  pushl $0
80105478:	6a 00                	push   $0x0
  pushl $30
8010547a:	6a 1e                	push   $0x1e
  jmp alltraps
8010547c:	e9 71 fa ff ff       	jmp    80104ef2 <alltraps>

80105481 <vector31>:
.globl vector31
vector31:
  pushl $0
80105481:	6a 00                	push   $0x0
  pushl $31
80105483:	6a 1f                	push   $0x1f
  jmp alltraps
80105485:	e9 68 fa ff ff       	jmp    80104ef2 <alltraps>

8010548a <vector32>:
.globl vector32
vector32:
  pushl $0
8010548a:	6a 00                	push   $0x0
  pushl $32
8010548c:	6a 20                	push   $0x20
  jmp alltraps
8010548e:	e9 5f fa ff ff       	jmp    80104ef2 <alltraps>

80105493 <vector33>:
.globl vector33
vector33:
  pushl $0
80105493:	6a 00                	push   $0x0
  pushl $33
80105495:	6a 21                	push   $0x21
  jmp alltraps
80105497:	e9 56 fa ff ff       	jmp    80104ef2 <alltraps>

8010549c <vector34>:
.globl vector34
vector34:
  pushl $0
8010549c:	6a 00                	push   $0x0
  pushl $34
8010549e:	6a 22                	push   $0x22
  jmp alltraps
801054a0:	e9 4d fa ff ff       	jmp    80104ef2 <alltraps>

801054a5 <vector35>:
.globl vector35
vector35:
  pushl $0
801054a5:	6a 00                	push   $0x0
  pushl $35
801054a7:	6a 23                	push   $0x23
  jmp alltraps
801054a9:	e9 44 fa ff ff       	jmp    80104ef2 <alltraps>

801054ae <vector36>:
.globl vector36
vector36:
  pushl $0
801054ae:	6a 00                	push   $0x0
  pushl $36
801054b0:	6a 24                	push   $0x24
  jmp alltraps
801054b2:	e9 3b fa ff ff       	jmp    80104ef2 <alltraps>

801054b7 <vector37>:
.globl vector37
vector37:
  pushl $0
801054b7:	6a 00                	push   $0x0
  pushl $37
801054b9:	6a 25                	push   $0x25
  jmp alltraps
801054bb:	e9 32 fa ff ff       	jmp    80104ef2 <alltraps>

801054c0 <vector38>:
.globl vector38
vector38:
  pushl $0
801054c0:	6a 00                	push   $0x0
  pushl $38
801054c2:	6a 26                	push   $0x26
  jmp alltraps
801054c4:	e9 29 fa ff ff       	jmp    80104ef2 <alltraps>

801054c9 <vector39>:
.globl vector39
vector39:
  pushl $0
801054c9:	6a 00                	push   $0x0
  pushl $39
801054cb:	6a 27                	push   $0x27
  jmp alltraps
801054cd:	e9 20 fa ff ff       	jmp    80104ef2 <alltraps>

801054d2 <vector40>:
.globl vector40
vector40:
  pushl $0
801054d2:	6a 00                	push   $0x0
  pushl $40
801054d4:	6a 28                	push   $0x28
  jmp alltraps
801054d6:	e9 17 fa ff ff       	jmp    80104ef2 <alltraps>

801054db <vector41>:
.globl vector41
vector41:
  pushl $0
801054db:	6a 00                	push   $0x0
  pushl $41
801054dd:	6a 29                	push   $0x29
  jmp alltraps
801054df:	e9 0e fa ff ff       	jmp    80104ef2 <alltraps>

801054e4 <vector42>:
.globl vector42
vector42:
  pushl $0
801054e4:	6a 00                	push   $0x0
  pushl $42
801054e6:	6a 2a                	push   $0x2a
  jmp alltraps
801054e8:	e9 05 fa ff ff       	jmp    80104ef2 <alltraps>

801054ed <vector43>:
.globl vector43
vector43:
  pushl $0
801054ed:	6a 00                	push   $0x0
  pushl $43
801054ef:	6a 2b                	push   $0x2b
  jmp alltraps
801054f1:	e9 fc f9 ff ff       	jmp    80104ef2 <alltraps>

801054f6 <vector44>:
.globl vector44
vector44:
  pushl $0
801054f6:	6a 00                	push   $0x0
  pushl $44
801054f8:	6a 2c                	push   $0x2c
  jmp alltraps
801054fa:	e9 f3 f9 ff ff       	jmp    80104ef2 <alltraps>

801054ff <vector45>:
.globl vector45
vector45:
  pushl $0
801054ff:	6a 00                	push   $0x0
  pushl $45
80105501:	6a 2d                	push   $0x2d
  jmp alltraps
80105503:	e9 ea f9 ff ff       	jmp    80104ef2 <alltraps>

80105508 <vector46>:
.globl vector46
vector46:
  pushl $0
80105508:	6a 00                	push   $0x0
  pushl $46
8010550a:	6a 2e                	push   $0x2e
  jmp alltraps
8010550c:	e9 e1 f9 ff ff       	jmp    80104ef2 <alltraps>

80105511 <vector47>:
.globl vector47
vector47:
  pushl $0
80105511:	6a 00                	push   $0x0
  pushl $47
80105513:	6a 2f                	push   $0x2f
  jmp alltraps
80105515:	e9 d8 f9 ff ff       	jmp    80104ef2 <alltraps>

8010551a <vector48>:
.globl vector48
vector48:
  pushl $0
8010551a:	6a 00                	push   $0x0
  pushl $48
8010551c:	6a 30                	push   $0x30
  jmp alltraps
8010551e:	e9 cf f9 ff ff       	jmp    80104ef2 <alltraps>

80105523 <vector49>:
.globl vector49
vector49:
  pushl $0
80105523:	6a 00                	push   $0x0
  pushl $49
80105525:	6a 31                	push   $0x31
  jmp alltraps
80105527:	e9 c6 f9 ff ff       	jmp    80104ef2 <alltraps>

8010552c <vector50>:
.globl vector50
vector50:
  pushl $0
8010552c:	6a 00                	push   $0x0
  pushl $50
8010552e:	6a 32                	push   $0x32
  jmp alltraps
80105530:	e9 bd f9 ff ff       	jmp    80104ef2 <alltraps>

80105535 <vector51>:
.globl vector51
vector51:
  pushl $0
80105535:	6a 00                	push   $0x0
  pushl $51
80105537:	6a 33                	push   $0x33
  jmp alltraps
80105539:	e9 b4 f9 ff ff       	jmp    80104ef2 <alltraps>

8010553e <vector52>:
.globl vector52
vector52:
  pushl $0
8010553e:	6a 00                	push   $0x0
  pushl $52
80105540:	6a 34                	push   $0x34
  jmp alltraps
80105542:	e9 ab f9 ff ff       	jmp    80104ef2 <alltraps>

80105547 <vector53>:
.globl vector53
vector53:
  pushl $0
80105547:	6a 00                	push   $0x0
  pushl $53
80105549:	6a 35                	push   $0x35
  jmp alltraps
8010554b:	e9 a2 f9 ff ff       	jmp    80104ef2 <alltraps>

80105550 <vector54>:
.globl vector54
vector54:
  pushl $0
80105550:	6a 00                	push   $0x0
  pushl $54
80105552:	6a 36                	push   $0x36
  jmp alltraps
80105554:	e9 99 f9 ff ff       	jmp    80104ef2 <alltraps>

80105559 <vector55>:
.globl vector55
vector55:
  pushl $0
80105559:	6a 00                	push   $0x0
  pushl $55
8010555b:	6a 37                	push   $0x37
  jmp alltraps
8010555d:	e9 90 f9 ff ff       	jmp    80104ef2 <alltraps>

80105562 <vector56>:
.globl vector56
vector56:
  pushl $0
80105562:	6a 00                	push   $0x0
  pushl $56
80105564:	6a 38                	push   $0x38
  jmp alltraps
80105566:	e9 87 f9 ff ff       	jmp    80104ef2 <alltraps>

8010556b <vector57>:
.globl vector57
vector57:
  pushl $0
8010556b:	6a 00                	push   $0x0
  pushl $57
8010556d:	6a 39                	push   $0x39
  jmp alltraps
8010556f:	e9 7e f9 ff ff       	jmp    80104ef2 <alltraps>

80105574 <vector58>:
.globl vector58
vector58:
  pushl $0
80105574:	6a 00                	push   $0x0
  pushl $58
80105576:	6a 3a                	push   $0x3a
  jmp alltraps
80105578:	e9 75 f9 ff ff       	jmp    80104ef2 <alltraps>

8010557d <vector59>:
.globl vector59
vector59:
  pushl $0
8010557d:	6a 00                	push   $0x0
  pushl $59
8010557f:	6a 3b                	push   $0x3b
  jmp alltraps
80105581:	e9 6c f9 ff ff       	jmp    80104ef2 <alltraps>

80105586 <vector60>:
.globl vector60
vector60:
  pushl $0
80105586:	6a 00                	push   $0x0
  pushl $60
80105588:	6a 3c                	push   $0x3c
  jmp alltraps
8010558a:	e9 63 f9 ff ff       	jmp    80104ef2 <alltraps>

8010558f <vector61>:
.globl vector61
vector61:
  pushl $0
8010558f:	6a 00                	push   $0x0
  pushl $61
80105591:	6a 3d                	push   $0x3d
  jmp alltraps
80105593:	e9 5a f9 ff ff       	jmp    80104ef2 <alltraps>

80105598 <vector62>:
.globl vector62
vector62:
  pushl $0
80105598:	6a 00                	push   $0x0
  pushl $62
8010559a:	6a 3e                	push   $0x3e
  jmp alltraps
8010559c:	e9 51 f9 ff ff       	jmp    80104ef2 <alltraps>

801055a1 <vector63>:
.globl vector63
vector63:
  pushl $0
801055a1:	6a 00                	push   $0x0
  pushl $63
801055a3:	6a 3f                	push   $0x3f
  jmp alltraps
801055a5:	e9 48 f9 ff ff       	jmp    80104ef2 <alltraps>

801055aa <vector64>:
.globl vector64
vector64:
  pushl $0
801055aa:	6a 00                	push   $0x0
  pushl $64
801055ac:	6a 40                	push   $0x40
  jmp alltraps
801055ae:	e9 3f f9 ff ff       	jmp    80104ef2 <alltraps>

801055b3 <vector65>:
.globl vector65
vector65:
  pushl $0
801055b3:	6a 00                	push   $0x0
  pushl $65
801055b5:	6a 41                	push   $0x41
  jmp alltraps
801055b7:	e9 36 f9 ff ff       	jmp    80104ef2 <alltraps>

801055bc <vector66>:
.globl vector66
vector66:
  pushl $0
801055bc:	6a 00                	push   $0x0
  pushl $66
801055be:	6a 42                	push   $0x42
  jmp alltraps
801055c0:	e9 2d f9 ff ff       	jmp    80104ef2 <alltraps>

801055c5 <vector67>:
.globl vector67
vector67:
  pushl $0
801055c5:	6a 00                	push   $0x0
  pushl $67
801055c7:	6a 43                	push   $0x43
  jmp alltraps
801055c9:	e9 24 f9 ff ff       	jmp    80104ef2 <alltraps>

801055ce <vector68>:
.globl vector68
vector68:
  pushl $0
801055ce:	6a 00                	push   $0x0
  pushl $68
801055d0:	6a 44                	push   $0x44
  jmp alltraps
801055d2:	e9 1b f9 ff ff       	jmp    80104ef2 <alltraps>

801055d7 <vector69>:
.globl vector69
vector69:
  pushl $0
801055d7:	6a 00                	push   $0x0
  pushl $69
801055d9:	6a 45                	push   $0x45
  jmp alltraps
801055db:	e9 12 f9 ff ff       	jmp    80104ef2 <alltraps>

801055e0 <vector70>:
.globl vector70
vector70:
  pushl $0
801055e0:	6a 00                	push   $0x0
  pushl $70
801055e2:	6a 46                	push   $0x46
  jmp alltraps
801055e4:	e9 09 f9 ff ff       	jmp    80104ef2 <alltraps>

801055e9 <vector71>:
.globl vector71
vector71:
  pushl $0
801055e9:	6a 00                	push   $0x0
  pushl $71
801055eb:	6a 47                	push   $0x47
  jmp alltraps
801055ed:	e9 00 f9 ff ff       	jmp    80104ef2 <alltraps>

801055f2 <vector72>:
.globl vector72
vector72:
  pushl $0
801055f2:	6a 00                	push   $0x0
  pushl $72
801055f4:	6a 48                	push   $0x48
  jmp alltraps
801055f6:	e9 f7 f8 ff ff       	jmp    80104ef2 <alltraps>

801055fb <vector73>:
.globl vector73
vector73:
  pushl $0
801055fb:	6a 00                	push   $0x0
  pushl $73
801055fd:	6a 49                	push   $0x49
  jmp alltraps
801055ff:	e9 ee f8 ff ff       	jmp    80104ef2 <alltraps>

80105604 <vector74>:
.globl vector74
vector74:
  pushl $0
80105604:	6a 00                	push   $0x0
  pushl $74
80105606:	6a 4a                	push   $0x4a
  jmp alltraps
80105608:	e9 e5 f8 ff ff       	jmp    80104ef2 <alltraps>

8010560d <vector75>:
.globl vector75
vector75:
  pushl $0
8010560d:	6a 00                	push   $0x0
  pushl $75
8010560f:	6a 4b                	push   $0x4b
  jmp alltraps
80105611:	e9 dc f8 ff ff       	jmp    80104ef2 <alltraps>

80105616 <vector76>:
.globl vector76
vector76:
  pushl $0
80105616:	6a 00                	push   $0x0
  pushl $76
80105618:	6a 4c                	push   $0x4c
  jmp alltraps
8010561a:	e9 d3 f8 ff ff       	jmp    80104ef2 <alltraps>

8010561f <vector77>:
.globl vector77
vector77:
  pushl $0
8010561f:	6a 00                	push   $0x0
  pushl $77
80105621:	6a 4d                	push   $0x4d
  jmp alltraps
80105623:	e9 ca f8 ff ff       	jmp    80104ef2 <alltraps>

80105628 <vector78>:
.globl vector78
vector78:
  pushl $0
80105628:	6a 00                	push   $0x0
  pushl $78
8010562a:	6a 4e                	push   $0x4e
  jmp alltraps
8010562c:	e9 c1 f8 ff ff       	jmp    80104ef2 <alltraps>

80105631 <vector79>:
.globl vector79
vector79:
  pushl $0
80105631:	6a 00                	push   $0x0
  pushl $79
80105633:	6a 4f                	push   $0x4f
  jmp alltraps
80105635:	e9 b8 f8 ff ff       	jmp    80104ef2 <alltraps>

8010563a <vector80>:
.globl vector80
vector80:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $80
8010563c:	6a 50                	push   $0x50
  jmp alltraps
8010563e:	e9 af f8 ff ff       	jmp    80104ef2 <alltraps>

80105643 <vector81>:
.globl vector81
vector81:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $81
80105645:	6a 51                	push   $0x51
  jmp alltraps
80105647:	e9 a6 f8 ff ff       	jmp    80104ef2 <alltraps>

8010564c <vector82>:
.globl vector82
vector82:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $82
8010564e:	6a 52                	push   $0x52
  jmp alltraps
80105650:	e9 9d f8 ff ff       	jmp    80104ef2 <alltraps>

80105655 <vector83>:
.globl vector83
vector83:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $83
80105657:	6a 53                	push   $0x53
  jmp alltraps
80105659:	e9 94 f8 ff ff       	jmp    80104ef2 <alltraps>

8010565e <vector84>:
.globl vector84
vector84:
  pushl $0
8010565e:	6a 00                	push   $0x0
  pushl $84
80105660:	6a 54                	push   $0x54
  jmp alltraps
80105662:	e9 8b f8 ff ff       	jmp    80104ef2 <alltraps>

80105667 <vector85>:
.globl vector85
vector85:
  pushl $0
80105667:	6a 00                	push   $0x0
  pushl $85
80105669:	6a 55                	push   $0x55
  jmp alltraps
8010566b:	e9 82 f8 ff ff       	jmp    80104ef2 <alltraps>

80105670 <vector86>:
.globl vector86
vector86:
  pushl $0
80105670:	6a 00                	push   $0x0
  pushl $86
80105672:	6a 56                	push   $0x56
  jmp alltraps
80105674:	e9 79 f8 ff ff       	jmp    80104ef2 <alltraps>

80105679 <vector87>:
.globl vector87
vector87:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $87
8010567b:	6a 57                	push   $0x57
  jmp alltraps
8010567d:	e9 70 f8 ff ff       	jmp    80104ef2 <alltraps>

80105682 <vector88>:
.globl vector88
vector88:
  pushl $0
80105682:	6a 00                	push   $0x0
  pushl $88
80105684:	6a 58                	push   $0x58
  jmp alltraps
80105686:	e9 67 f8 ff ff       	jmp    80104ef2 <alltraps>

8010568b <vector89>:
.globl vector89
vector89:
  pushl $0
8010568b:	6a 00                	push   $0x0
  pushl $89
8010568d:	6a 59                	push   $0x59
  jmp alltraps
8010568f:	e9 5e f8 ff ff       	jmp    80104ef2 <alltraps>

80105694 <vector90>:
.globl vector90
vector90:
  pushl $0
80105694:	6a 00                	push   $0x0
  pushl $90
80105696:	6a 5a                	push   $0x5a
  jmp alltraps
80105698:	e9 55 f8 ff ff       	jmp    80104ef2 <alltraps>

8010569d <vector91>:
.globl vector91
vector91:
  pushl $0
8010569d:	6a 00                	push   $0x0
  pushl $91
8010569f:	6a 5b                	push   $0x5b
  jmp alltraps
801056a1:	e9 4c f8 ff ff       	jmp    80104ef2 <alltraps>

801056a6 <vector92>:
.globl vector92
vector92:
  pushl $0
801056a6:	6a 00                	push   $0x0
  pushl $92
801056a8:	6a 5c                	push   $0x5c
  jmp alltraps
801056aa:	e9 43 f8 ff ff       	jmp    80104ef2 <alltraps>

801056af <vector93>:
.globl vector93
vector93:
  pushl $0
801056af:	6a 00                	push   $0x0
  pushl $93
801056b1:	6a 5d                	push   $0x5d
  jmp alltraps
801056b3:	e9 3a f8 ff ff       	jmp    80104ef2 <alltraps>

801056b8 <vector94>:
.globl vector94
vector94:
  pushl $0
801056b8:	6a 00                	push   $0x0
  pushl $94
801056ba:	6a 5e                	push   $0x5e
  jmp alltraps
801056bc:	e9 31 f8 ff ff       	jmp    80104ef2 <alltraps>

801056c1 <vector95>:
.globl vector95
vector95:
  pushl $0
801056c1:	6a 00                	push   $0x0
  pushl $95
801056c3:	6a 5f                	push   $0x5f
  jmp alltraps
801056c5:	e9 28 f8 ff ff       	jmp    80104ef2 <alltraps>

801056ca <vector96>:
.globl vector96
vector96:
  pushl $0
801056ca:	6a 00                	push   $0x0
  pushl $96
801056cc:	6a 60                	push   $0x60
  jmp alltraps
801056ce:	e9 1f f8 ff ff       	jmp    80104ef2 <alltraps>

801056d3 <vector97>:
.globl vector97
vector97:
  pushl $0
801056d3:	6a 00                	push   $0x0
  pushl $97
801056d5:	6a 61                	push   $0x61
  jmp alltraps
801056d7:	e9 16 f8 ff ff       	jmp    80104ef2 <alltraps>

801056dc <vector98>:
.globl vector98
vector98:
  pushl $0
801056dc:	6a 00                	push   $0x0
  pushl $98
801056de:	6a 62                	push   $0x62
  jmp alltraps
801056e0:	e9 0d f8 ff ff       	jmp    80104ef2 <alltraps>

801056e5 <vector99>:
.globl vector99
vector99:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $99
801056e7:	6a 63                	push   $0x63
  jmp alltraps
801056e9:	e9 04 f8 ff ff       	jmp    80104ef2 <alltraps>

801056ee <vector100>:
.globl vector100
vector100:
  pushl $0
801056ee:	6a 00                	push   $0x0
  pushl $100
801056f0:	6a 64                	push   $0x64
  jmp alltraps
801056f2:	e9 fb f7 ff ff       	jmp    80104ef2 <alltraps>

801056f7 <vector101>:
.globl vector101
vector101:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $101
801056f9:	6a 65                	push   $0x65
  jmp alltraps
801056fb:	e9 f2 f7 ff ff       	jmp    80104ef2 <alltraps>

80105700 <vector102>:
.globl vector102
vector102:
  pushl $0
80105700:	6a 00                	push   $0x0
  pushl $102
80105702:	6a 66                	push   $0x66
  jmp alltraps
80105704:	e9 e9 f7 ff ff       	jmp    80104ef2 <alltraps>

80105709 <vector103>:
.globl vector103
vector103:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $103
8010570b:	6a 67                	push   $0x67
  jmp alltraps
8010570d:	e9 e0 f7 ff ff       	jmp    80104ef2 <alltraps>

80105712 <vector104>:
.globl vector104
vector104:
  pushl $0
80105712:	6a 00                	push   $0x0
  pushl $104
80105714:	6a 68                	push   $0x68
  jmp alltraps
80105716:	e9 d7 f7 ff ff       	jmp    80104ef2 <alltraps>

8010571b <vector105>:
.globl vector105
vector105:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $105
8010571d:	6a 69                	push   $0x69
  jmp alltraps
8010571f:	e9 ce f7 ff ff       	jmp    80104ef2 <alltraps>

80105724 <vector106>:
.globl vector106
vector106:
  pushl $0
80105724:	6a 00                	push   $0x0
  pushl $106
80105726:	6a 6a                	push   $0x6a
  jmp alltraps
80105728:	e9 c5 f7 ff ff       	jmp    80104ef2 <alltraps>

8010572d <vector107>:
.globl vector107
vector107:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $107
8010572f:	6a 6b                	push   $0x6b
  jmp alltraps
80105731:	e9 bc f7 ff ff       	jmp    80104ef2 <alltraps>

80105736 <vector108>:
.globl vector108
vector108:
  pushl $0
80105736:	6a 00                	push   $0x0
  pushl $108
80105738:	6a 6c                	push   $0x6c
  jmp alltraps
8010573a:	e9 b3 f7 ff ff       	jmp    80104ef2 <alltraps>

8010573f <vector109>:
.globl vector109
vector109:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $109
80105741:	6a 6d                	push   $0x6d
  jmp alltraps
80105743:	e9 aa f7 ff ff       	jmp    80104ef2 <alltraps>

80105748 <vector110>:
.globl vector110
vector110:
  pushl $0
80105748:	6a 00                	push   $0x0
  pushl $110
8010574a:	6a 6e                	push   $0x6e
  jmp alltraps
8010574c:	e9 a1 f7 ff ff       	jmp    80104ef2 <alltraps>

80105751 <vector111>:
.globl vector111
vector111:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $111
80105753:	6a 6f                	push   $0x6f
  jmp alltraps
80105755:	e9 98 f7 ff ff       	jmp    80104ef2 <alltraps>

8010575a <vector112>:
.globl vector112
vector112:
  pushl $0
8010575a:	6a 00                	push   $0x0
  pushl $112
8010575c:	6a 70                	push   $0x70
  jmp alltraps
8010575e:	e9 8f f7 ff ff       	jmp    80104ef2 <alltraps>

80105763 <vector113>:
.globl vector113
vector113:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $113
80105765:	6a 71                	push   $0x71
  jmp alltraps
80105767:	e9 86 f7 ff ff       	jmp    80104ef2 <alltraps>

8010576c <vector114>:
.globl vector114
vector114:
  pushl $0
8010576c:	6a 00                	push   $0x0
  pushl $114
8010576e:	6a 72                	push   $0x72
  jmp alltraps
80105770:	e9 7d f7 ff ff       	jmp    80104ef2 <alltraps>

80105775 <vector115>:
.globl vector115
vector115:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $115
80105777:	6a 73                	push   $0x73
  jmp alltraps
80105779:	e9 74 f7 ff ff       	jmp    80104ef2 <alltraps>

8010577e <vector116>:
.globl vector116
vector116:
  pushl $0
8010577e:	6a 00                	push   $0x0
  pushl $116
80105780:	6a 74                	push   $0x74
  jmp alltraps
80105782:	e9 6b f7 ff ff       	jmp    80104ef2 <alltraps>

80105787 <vector117>:
.globl vector117
vector117:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $117
80105789:	6a 75                	push   $0x75
  jmp alltraps
8010578b:	e9 62 f7 ff ff       	jmp    80104ef2 <alltraps>

80105790 <vector118>:
.globl vector118
vector118:
  pushl $0
80105790:	6a 00                	push   $0x0
  pushl $118
80105792:	6a 76                	push   $0x76
  jmp alltraps
80105794:	e9 59 f7 ff ff       	jmp    80104ef2 <alltraps>

80105799 <vector119>:
.globl vector119
vector119:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $119
8010579b:	6a 77                	push   $0x77
  jmp alltraps
8010579d:	e9 50 f7 ff ff       	jmp    80104ef2 <alltraps>

801057a2 <vector120>:
.globl vector120
vector120:
  pushl $0
801057a2:	6a 00                	push   $0x0
  pushl $120
801057a4:	6a 78                	push   $0x78
  jmp alltraps
801057a6:	e9 47 f7 ff ff       	jmp    80104ef2 <alltraps>

801057ab <vector121>:
.globl vector121
vector121:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $121
801057ad:	6a 79                	push   $0x79
  jmp alltraps
801057af:	e9 3e f7 ff ff       	jmp    80104ef2 <alltraps>

801057b4 <vector122>:
.globl vector122
vector122:
  pushl $0
801057b4:	6a 00                	push   $0x0
  pushl $122
801057b6:	6a 7a                	push   $0x7a
  jmp alltraps
801057b8:	e9 35 f7 ff ff       	jmp    80104ef2 <alltraps>

801057bd <vector123>:
.globl vector123
vector123:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $123
801057bf:	6a 7b                	push   $0x7b
  jmp alltraps
801057c1:	e9 2c f7 ff ff       	jmp    80104ef2 <alltraps>

801057c6 <vector124>:
.globl vector124
vector124:
  pushl $0
801057c6:	6a 00                	push   $0x0
  pushl $124
801057c8:	6a 7c                	push   $0x7c
  jmp alltraps
801057ca:	e9 23 f7 ff ff       	jmp    80104ef2 <alltraps>

801057cf <vector125>:
.globl vector125
vector125:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $125
801057d1:	6a 7d                	push   $0x7d
  jmp alltraps
801057d3:	e9 1a f7 ff ff       	jmp    80104ef2 <alltraps>

801057d8 <vector126>:
.globl vector126
vector126:
  pushl $0
801057d8:	6a 00                	push   $0x0
  pushl $126
801057da:	6a 7e                	push   $0x7e
  jmp alltraps
801057dc:	e9 11 f7 ff ff       	jmp    80104ef2 <alltraps>

801057e1 <vector127>:
.globl vector127
vector127:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $127
801057e3:	6a 7f                	push   $0x7f
  jmp alltraps
801057e5:	e9 08 f7 ff ff       	jmp    80104ef2 <alltraps>

801057ea <vector128>:
.globl vector128
vector128:
  pushl $0
801057ea:	6a 00                	push   $0x0
  pushl $128
801057ec:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801057f1:	e9 fc f6 ff ff       	jmp    80104ef2 <alltraps>

801057f6 <vector129>:
.globl vector129
vector129:
  pushl $0
801057f6:	6a 00                	push   $0x0
  pushl $129
801057f8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801057fd:	e9 f0 f6 ff ff       	jmp    80104ef2 <alltraps>

80105802 <vector130>:
.globl vector130
vector130:
  pushl $0
80105802:	6a 00                	push   $0x0
  pushl $130
80105804:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105809:	e9 e4 f6 ff ff       	jmp    80104ef2 <alltraps>

8010580e <vector131>:
.globl vector131
vector131:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $131
80105810:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105815:	e9 d8 f6 ff ff       	jmp    80104ef2 <alltraps>

8010581a <vector132>:
.globl vector132
vector132:
  pushl $0
8010581a:	6a 00                	push   $0x0
  pushl $132
8010581c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105821:	e9 cc f6 ff ff       	jmp    80104ef2 <alltraps>

80105826 <vector133>:
.globl vector133
vector133:
  pushl $0
80105826:	6a 00                	push   $0x0
  pushl $133
80105828:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010582d:	e9 c0 f6 ff ff       	jmp    80104ef2 <alltraps>

80105832 <vector134>:
.globl vector134
vector134:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $134
80105834:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105839:	e9 b4 f6 ff ff       	jmp    80104ef2 <alltraps>

8010583e <vector135>:
.globl vector135
vector135:
  pushl $0
8010583e:	6a 00                	push   $0x0
  pushl $135
80105840:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105845:	e9 a8 f6 ff ff       	jmp    80104ef2 <alltraps>

8010584a <vector136>:
.globl vector136
vector136:
  pushl $0
8010584a:	6a 00                	push   $0x0
  pushl $136
8010584c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105851:	e9 9c f6 ff ff       	jmp    80104ef2 <alltraps>

80105856 <vector137>:
.globl vector137
vector137:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $137
80105858:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010585d:	e9 90 f6 ff ff       	jmp    80104ef2 <alltraps>

80105862 <vector138>:
.globl vector138
vector138:
  pushl $0
80105862:	6a 00                	push   $0x0
  pushl $138
80105864:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105869:	e9 84 f6 ff ff       	jmp    80104ef2 <alltraps>

8010586e <vector139>:
.globl vector139
vector139:
  pushl $0
8010586e:	6a 00                	push   $0x0
  pushl $139
80105870:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105875:	e9 78 f6 ff ff       	jmp    80104ef2 <alltraps>

8010587a <vector140>:
.globl vector140
vector140:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $140
8010587c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105881:	e9 6c f6 ff ff       	jmp    80104ef2 <alltraps>

80105886 <vector141>:
.globl vector141
vector141:
  pushl $0
80105886:	6a 00                	push   $0x0
  pushl $141
80105888:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010588d:	e9 60 f6 ff ff       	jmp    80104ef2 <alltraps>

80105892 <vector142>:
.globl vector142
vector142:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $142
80105894:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105899:	e9 54 f6 ff ff       	jmp    80104ef2 <alltraps>

8010589e <vector143>:
.globl vector143
vector143:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $143
801058a0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801058a5:	e9 48 f6 ff ff       	jmp    80104ef2 <alltraps>

801058aa <vector144>:
.globl vector144
vector144:
  pushl $0
801058aa:	6a 00                	push   $0x0
  pushl $144
801058ac:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801058b1:	e9 3c f6 ff ff       	jmp    80104ef2 <alltraps>

801058b6 <vector145>:
.globl vector145
vector145:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $145
801058b8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801058bd:	e9 30 f6 ff ff       	jmp    80104ef2 <alltraps>

801058c2 <vector146>:
.globl vector146
vector146:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $146
801058c4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801058c9:	e9 24 f6 ff ff       	jmp    80104ef2 <alltraps>

801058ce <vector147>:
.globl vector147
vector147:
  pushl $0
801058ce:	6a 00                	push   $0x0
  pushl $147
801058d0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801058d5:	e9 18 f6 ff ff       	jmp    80104ef2 <alltraps>

801058da <vector148>:
.globl vector148
vector148:
  pushl $0
801058da:	6a 00                	push   $0x0
  pushl $148
801058dc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801058e1:	e9 0c f6 ff ff       	jmp    80104ef2 <alltraps>

801058e6 <vector149>:
.globl vector149
vector149:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $149
801058e8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801058ed:	e9 00 f6 ff ff       	jmp    80104ef2 <alltraps>

801058f2 <vector150>:
.globl vector150
vector150:
  pushl $0
801058f2:	6a 00                	push   $0x0
  pushl $150
801058f4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801058f9:	e9 f4 f5 ff ff       	jmp    80104ef2 <alltraps>

801058fe <vector151>:
.globl vector151
vector151:
  pushl $0
801058fe:	6a 00                	push   $0x0
  pushl $151
80105900:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105905:	e9 e8 f5 ff ff       	jmp    80104ef2 <alltraps>

8010590a <vector152>:
.globl vector152
vector152:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $152
8010590c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105911:	e9 dc f5 ff ff       	jmp    80104ef2 <alltraps>

80105916 <vector153>:
.globl vector153
vector153:
  pushl $0
80105916:	6a 00                	push   $0x0
  pushl $153
80105918:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010591d:	e9 d0 f5 ff ff       	jmp    80104ef2 <alltraps>

80105922 <vector154>:
.globl vector154
vector154:
  pushl $0
80105922:	6a 00                	push   $0x0
  pushl $154
80105924:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105929:	e9 c4 f5 ff ff       	jmp    80104ef2 <alltraps>

8010592e <vector155>:
.globl vector155
vector155:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $155
80105930:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105935:	e9 b8 f5 ff ff       	jmp    80104ef2 <alltraps>

8010593a <vector156>:
.globl vector156
vector156:
  pushl $0
8010593a:	6a 00                	push   $0x0
  pushl $156
8010593c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105941:	e9 ac f5 ff ff       	jmp    80104ef2 <alltraps>

80105946 <vector157>:
.globl vector157
vector157:
  pushl $0
80105946:	6a 00                	push   $0x0
  pushl $157
80105948:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010594d:	e9 a0 f5 ff ff       	jmp    80104ef2 <alltraps>

80105952 <vector158>:
.globl vector158
vector158:
  pushl $0
80105952:	6a 00                	push   $0x0
  pushl $158
80105954:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105959:	e9 94 f5 ff ff       	jmp    80104ef2 <alltraps>

8010595e <vector159>:
.globl vector159
vector159:
  pushl $0
8010595e:	6a 00                	push   $0x0
  pushl $159
80105960:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105965:	e9 88 f5 ff ff       	jmp    80104ef2 <alltraps>

8010596a <vector160>:
.globl vector160
vector160:
  pushl $0
8010596a:	6a 00                	push   $0x0
  pushl $160
8010596c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105971:	e9 7c f5 ff ff       	jmp    80104ef2 <alltraps>

80105976 <vector161>:
.globl vector161
vector161:
  pushl $0
80105976:	6a 00                	push   $0x0
  pushl $161
80105978:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010597d:	e9 70 f5 ff ff       	jmp    80104ef2 <alltraps>

80105982 <vector162>:
.globl vector162
vector162:
  pushl $0
80105982:	6a 00                	push   $0x0
  pushl $162
80105984:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105989:	e9 64 f5 ff ff       	jmp    80104ef2 <alltraps>

8010598e <vector163>:
.globl vector163
vector163:
  pushl $0
8010598e:	6a 00                	push   $0x0
  pushl $163
80105990:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105995:	e9 58 f5 ff ff       	jmp    80104ef2 <alltraps>

8010599a <vector164>:
.globl vector164
vector164:
  pushl $0
8010599a:	6a 00                	push   $0x0
  pushl $164
8010599c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801059a1:	e9 4c f5 ff ff       	jmp    80104ef2 <alltraps>

801059a6 <vector165>:
.globl vector165
vector165:
  pushl $0
801059a6:	6a 00                	push   $0x0
  pushl $165
801059a8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801059ad:	e9 40 f5 ff ff       	jmp    80104ef2 <alltraps>

801059b2 <vector166>:
.globl vector166
vector166:
  pushl $0
801059b2:	6a 00                	push   $0x0
  pushl $166
801059b4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801059b9:	e9 34 f5 ff ff       	jmp    80104ef2 <alltraps>

801059be <vector167>:
.globl vector167
vector167:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $167
801059c0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801059c5:	e9 28 f5 ff ff       	jmp    80104ef2 <alltraps>

801059ca <vector168>:
.globl vector168
vector168:
  pushl $0
801059ca:	6a 00                	push   $0x0
  pushl $168
801059cc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801059d1:	e9 1c f5 ff ff       	jmp    80104ef2 <alltraps>

801059d6 <vector169>:
.globl vector169
vector169:
  pushl $0
801059d6:	6a 00                	push   $0x0
  pushl $169
801059d8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801059dd:	e9 10 f5 ff ff       	jmp    80104ef2 <alltraps>

801059e2 <vector170>:
.globl vector170
vector170:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $170
801059e4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801059e9:	e9 04 f5 ff ff       	jmp    80104ef2 <alltraps>

801059ee <vector171>:
.globl vector171
vector171:
  pushl $0
801059ee:	6a 00                	push   $0x0
  pushl $171
801059f0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801059f5:	e9 f8 f4 ff ff       	jmp    80104ef2 <alltraps>

801059fa <vector172>:
.globl vector172
vector172:
  pushl $0
801059fa:	6a 00                	push   $0x0
  pushl $172
801059fc:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a01:	e9 ec f4 ff ff       	jmp    80104ef2 <alltraps>

80105a06 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $173
80105a08:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a0d:	e9 e0 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a12 <vector174>:
.globl vector174
vector174:
  pushl $0
80105a12:	6a 00                	push   $0x0
  pushl $174
80105a14:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105a19:	e9 d4 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a1e <vector175>:
.globl vector175
vector175:
  pushl $0
80105a1e:	6a 00                	push   $0x0
  pushl $175
80105a20:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105a25:	e9 c8 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a2a <vector176>:
.globl vector176
vector176:
  pushl $0
80105a2a:	6a 00                	push   $0x0
  pushl $176
80105a2c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a31:	e9 bc f4 ff ff       	jmp    80104ef2 <alltraps>

80105a36 <vector177>:
.globl vector177
vector177:
  pushl $0
80105a36:	6a 00                	push   $0x0
  pushl $177
80105a38:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a3d:	e9 b0 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a42 <vector178>:
.globl vector178
vector178:
  pushl $0
80105a42:	6a 00                	push   $0x0
  pushl $178
80105a44:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a49:	e9 a4 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a4e <vector179>:
.globl vector179
vector179:
  pushl $0
80105a4e:	6a 00                	push   $0x0
  pushl $179
80105a50:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a55:	e9 98 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a5a <vector180>:
.globl vector180
vector180:
  pushl $0
80105a5a:	6a 00                	push   $0x0
  pushl $180
80105a5c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a61:	e9 8c f4 ff ff       	jmp    80104ef2 <alltraps>

80105a66 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a66:	6a 00                	push   $0x0
  pushl $181
80105a68:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a6d:	e9 80 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a72 <vector182>:
.globl vector182
vector182:
  pushl $0
80105a72:	6a 00                	push   $0x0
  pushl $182
80105a74:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a79:	e9 74 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a7e <vector183>:
.globl vector183
vector183:
  pushl $0
80105a7e:	6a 00                	push   $0x0
  pushl $183
80105a80:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a85:	e9 68 f4 ff ff       	jmp    80104ef2 <alltraps>

80105a8a <vector184>:
.globl vector184
vector184:
  pushl $0
80105a8a:	6a 00                	push   $0x0
  pushl $184
80105a8c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a91:	e9 5c f4 ff ff       	jmp    80104ef2 <alltraps>

80105a96 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a96:	6a 00                	push   $0x0
  pushl $185
80105a98:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a9d:	e9 50 f4 ff ff       	jmp    80104ef2 <alltraps>

80105aa2 <vector186>:
.globl vector186
vector186:
  pushl $0
80105aa2:	6a 00                	push   $0x0
  pushl $186
80105aa4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105aa9:	e9 44 f4 ff ff       	jmp    80104ef2 <alltraps>

80105aae <vector187>:
.globl vector187
vector187:
  pushl $0
80105aae:	6a 00                	push   $0x0
  pushl $187
80105ab0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105ab5:	e9 38 f4 ff ff       	jmp    80104ef2 <alltraps>

80105aba <vector188>:
.globl vector188
vector188:
  pushl $0
80105aba:	6a 00                	push   $0x0
  pushl $188
80105abc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105ac1:	e9 2c f4 ff ff       	jmp    80104ef2 <alltraps>

80105ac6 <vector189>:
.globl vector189
vector189:
  pushl $0
80105ac6:	6a 00                	push   $0x0
  pushl $189
80105ac8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105acd:	e9 20 f4 ff ff       	jmp    80104ef2 <alltraps>

80105ad2 <vector190>:
.globl vector190
vector190:
  pushl $0
80105ad2:	6a 00                	push   $0x0
  pushl $190
80105ad4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105ad9:	e9 14 f4 ff ff       	jmp    80104ef2 <alltraps>

80105ade <vector191>:
.globl vector191
vector191:
  pushl $0
80105ade:	6a 00                	push   $0x0
  pushl $191
80105ae0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105ae5:	e9 08 f4 ff ff       	jmp    80104ef2 <alltraps>

80105aea <vector192>:
.globl vector192
vector192:
  pushl $0
80105aea:	6a 00                	push   $0x0
  pushl $192
80105aec:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105af1:	e9 fc f3 ff ff       	jmp    80104ef2 <alltraps>

80105af6 <vector193>:
.globl vector193
vector193:
  pushl $0
80105af6:	6a 00                	push   $0x0
  pushl $193
80105af8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105afd:	e9 f0 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b02 <vector194>:
.globl vector194
vector194:
  pushl $0
80105b02:	6a 00                	push   $0x0
  pushl $194
80105b04:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b09:	e9 e4 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b0e <vector195>:
.globl vector195
vector195:
  pushl $0
80105b0e:	6a 00                	push   $0x0
  pushl $195
80105b10:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105b15:	e9 d8 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b1a <vector196>:
.globl vector196
vector196:
  pushl $0
80105b1a:	6a 00                	push   $0x0
  pushl $196
80105b1c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105b21:	e9 cc f3 ff ff       	jmp    80104ef2 <alltraps>

80105b26 <vector197>:
.globl vector197
vector197:
  pushl $0
80105b26:	6a 00                	push   $0x0
  pushl $197
80105b28:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b2d:	e9 c0 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b32 <vector198>:
.globl vector198
vector198:
  pushl $0
80105b32:	6a 00                	push   $0x0
  pushl $198
80105b34:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b39:	e9 b4 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b3e <vector199>:
.globl vector199
vector199:
  pushl $0
80105b3e:	6a 00                	push   $0x0
  pushl $199
80105b40:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b45:	e9 a8 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b4a <vector200>:
.globl vector200
vector200:
  pushl $0
80105b4a:	6a 00                	push   $0x0
  pushl $200
80105b4c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b51:	e9 9c f3 ff ff       	jmp    80104ef2 <alltraps>

80105b56 <vector201>:
.globl vector201
vector201:
  pushl $0
80105b56:	6a 00                	push   $0x0
  pushl $201
80105b58:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b5d:	e9 90 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b62 <vector202>:
.globl vector202
vector202:
  pushl $0
80105b62:	6a 00                	push   $0x0
  pushl $202
80105b64:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b69:	e9 84 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b6e <vector203>:
.globl vector203
vector203:
  pushl $0
80105b6e:	6a 00                	push   $0x0
  pushl $203
80105b70:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b75:	e9 78 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b7a <vector204>:
.globl vector204
vector204:
  pushl $0
80105b7a:	6a 00                	push   $0x0
  pushl $204
80105b7c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b81:	e9 6c f3 ff ff       	jmp    80104ef2 <alltraps>

80105b86 <vector205>:
.globl vector205
vector205:
  pushl $0
80105b86:	6a 00                	push   $0x0
  pushl $205
80105b88:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b8d:	e9 60 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b92 <vector206>:
.globl vector206
vector206:
  pushl $0
80105b92:	6a 00                	push   $0x0
  pushl $206
80105b94:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b99:	e9 54 f3 ff ff       	jmp    80104ef2 <alltraps>

80105b9e <vector207>:
.globl vector207
vector207:
  pushl $0
80105b9e:	6a 00                	push   $0x0
  pushl $207
80105ba0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105ba5:	e9 48 f3 ff ff       	jmp    80104ef2 <alltraps>

80105baa <vector208>:
.globl vector208
vector208:
  pushl $0
80105baa:	6a 00                	push   $0x0
  pushl $208
80105bac:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105bb1:	e9 3c f3 ff ff       	jmp    80104ef2 <alltraps>

80105bb6 <vector209>:
.globl vector209
vector209:
  pushl $0
80105bb6:	6a 00                	push   $0x0
  pushl $209
80105bb8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105bbd:	e9 30 f3 ff ff       	jmp    80104ef2 <alltraps>

80105bc2 <vector210>:
.globl vector210
vector210:
  pushl $0
80105bc2:	6a 00                	push   $0x0
  pushl $210
80105bc4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105bc9:	e9 24 f3 ff ff       	jmp    80104ef2 <alltraps>

80105bce <vector211>:
.globl vector211
vector211:
  pushl $0
80105bce:	6a 00                	push   $0x0
  pushl $211
80105bd0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105bd5:	e9 18 f3 ff ff       	jmp    80104ef2 <alltraps>

80105bda <vector212>:
.globl vector212
vector212:
  pushl $0
80105bda:	6a 00                	push   $0x0
  pushl $212
80105bdc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105be1:	e9 0c f3 ff ff       	jmp    80104ef2 <alltraps>

80105be6 <vector213>:
.globl vector213
vector213:
  pushl $0
80105be6:	6a 00                	push   $0x0
  pushl $213
80105be8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105bed:	e9 00 f3 ff ff       	jmp    80104ef2 <alltraps>

80105bf2 <vector214>:
.globl vector214
vector214:
  pushl $0
80105bf2:	6a 00                	push   $0x0
  pushl $214
80105bf4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105bf9:	e9 f4 f2 ff ff       	jmp    80104ef2 <alltraps>

80105bfe <vector215>:
.globl vector215
vector215:
  pushl $0
80105bfe:	6a 00                	push   $0x0
  pushl $215
80105c00:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c05:	e9 e8 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c0a <vector216>:
.globl vector216
vector216:
  pushl $0
80105c0a:	6a 00                	push   $0x0
  pushl $216
80105c0c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c11:	e9 dc f2 ff ff       	jmp    80104ef2 <alltraps>

80105c16 <vector217>:
.globl vector217
vector217:
  pushl $0
80105c16:	6a 00                	push   $0x0
  pushl $217
80105c18:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105c1d:	e9 d0 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c22 <vector218>:
.globl vector218
vector218:
  pushl $0
80105c22:	6a 00                	push   $0x0
  pushl $218
80105c24:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c29:	e9 c4 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c2e <vector219>:
.globl vector219
vector219:
  pushl $0
80105c2e:	6a 00                	push   $0x0
  pushl $219
80105c30:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c35:	e9 b8 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c3a <vector220>:
.globl vector220
vector220:
  pushl $0
80105c3a:	6a 00                	push   $0x0
  pushl $220
80105c3c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c41:	e9 ac f2 ff ff       	jmp    80104ef2 <alltraps>

80105c46 <vector221>:
.globl vector221
vector221:
  pushl $0
80105c46:	6a 00                	push   $0x0
  pushl $221
80105c48:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c4d:	e9 a0 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c52 <vector222>:
.globl vector222
vector222:
  pushl $0
80105c52:	6a 00                	push   $0x0
  pushl $222
80105c54:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c59:	e9 94 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c5e <vector223>:
.globl vector223
vector223:
  pushl $0
80105c5e:	6a 00                	push   $0x0
  pushl $223
80105c60:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c65:	e9 88 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c6a <vector224>:
.globl vector224
vector224:
  pushl $0
80105c6a:	6a 00                	push   $0x0
  pushl $224
80105c6c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c71:	e9 7c f2 ff ff       	jmp    80104ef2 <alltraps>

80105c76 <vector225>:
.globl vector225
vector225:
  pushl $0
80105c76:	6a 00                	push   $0x0
  pushl $225
80105c78:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c7d:	e9 70 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c82 <vector226>:
.globl vector226
vector226:
  pushl $0
80105c82:	6a 00                	push   $0x0
  pushl $226
80105c84:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c89:	e9 64 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c8e <vector227>:
.globl vector227
vector227:
  pushl $0
80105c8e:	6a 00                	push   $0x0
  pushl $227
80105c90:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c95:	e9 58 f2 ff ff       	jmp    80104ef2 <alltraps>

80105c9a <vector228>:
.globl vector228
vector228:
  pushl $0
80105c9a:	6a 00                	push   $0x0
  pushl $228
80105c9c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105ca1:	e9 4c f2 ff ff       	jmp    80104ef2 <alltraps>

80105ca6 <vector229>:
.globl vector229
vector229:
  pushl $0
80105ca6:	6a 00                	push   $0x0
  pushl $229
80105ca8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105cad:	e9 40 f2 ff ff       	jmp    80104ef2 <alltraps>

80105cb2 <vector230>:
.globl vector230
vector230:
  pushl $0
80105cb2:	6a 00                	push   $0x0
  pushl $230
80105cb4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105cb9:	e9 34 f2 ff ff       	jmp    80104ef2 <alltraps>

80105cbe <vector231>:
.globl vector231
vector231:
  pushl $0
80105cbe:	6a 00                	push   $0x0
  pushl $231
80105cc0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105cc5:	e9 28 f2 ff ff       	jmp    80104ef2 <alltraps>

80105cca <vector232>:
.globl vector232
vector232:
  pushl $0
80105cca:	6a 00                	push   $0x0
  pushl $232
80105ccc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105cd1:	e9 1c f2 ff ff       	jmp    80104ef2 <alltraps>

80105cd6 <vector233>:
.globl vector233
vector233:
  pushl $0
80105cd6:	6a 00                	push   $0x0
  pushl $233
80105cd8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105cdd:	e9 10 f2 ff ff       	jmp    80104ef2 <alltraps>

80105ce2 <vector234>:
.globl vector234
vector234:
  pushl $0
80105ce2:	6a 00                	push   $0x0
  pushl $234
80105ce4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105ce9:	e9 04 f2 ff ff       	jmp    80104ef2 <alltraps>

80105cee <vector235>:
.globl vector235
vector235:
  pushl $0
80105cee:	6a 00                	push   $0x0
  pushl $235
80105cf0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105cf5:	e9 f8 f1 ff ff       	jmp    80104ef2 <alltraps>

80105cfa <vector236>:
.globl vector236
vector236:
  pushl $0
80105cfa:	6a 00                	push   $0x0
  pushl $236
80105cfc:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d01:	e9 ec f1 ff ff       	jmp    80104ef2 <alltraps>

80105d06 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d06:	6a 00                	push   $0x0
  pushl $237
80105d08:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d0d:	e9 e0 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d12 <vector238>:
.globl vector238
vector238:
  pushl $0
80105d12:	6a 00                	push   $0x0
  pushl $238
80105d14:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105d19:	e9 d4 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d1e <vector239>:
.globl vector239
vector239:
  pushl $0
80105d1e:	6a 00                	push   $0x0
  pushl $239
80105d20:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105d25:	e9 c8 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d2a <vector240>:
.globl vector240
vector240:
  pushl $0
80105d2a:	6a 00                	push   $0x0
  pushl $240
80105d2c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d31:	e9 bc f1 ff ff       	jmp    80104ef2 <alltraps>

80105d36 <vector241>:
.globl vector241
vector241:
  pushl $0
80105d36:	6a 00                	push   $0x0
  pushl $241
80105d38:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d3d:	e9 b0 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d42 <vector242>:
.globl vector242
vector242:
  pushl $0
80105d42:	6a 00                	push   $0x0
  pushl $242
80105d44:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d49:	e9 a4 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d4e <vector243>:
.globl vector243
vector243:
  pushl $0
80105d4e:	6a 00                	push   $0x0
  pushl $243
80105d50:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d55:	e9 98 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d5a <vector244>:
.globl vector244
vector244:
  pushl $0
80105d5a:	6a 00                	push   $0x0
  pushl $244
80105d5c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d61:	e9 8c f1 ff ff       	jmp    80104ef2 <alltraps>

80105d66 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d66:	6a 00                	push   $0x0
  pushl $245
80105d68:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d6d:	e9 80 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d72 <vector246>:
.globl vector246
vector246:
  pushl $0
80105d72:	6a 00                	push   $0x0
  pushl $246
80105d74:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d79:	e9 74 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d7e <vector247>:
.globl vector247
vector247:
  pushl $0
80105d7e:	6a 00                	push   $0x0
  pushl $247
80105d80:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d85:	e9 68 f1 ff ff       	jmp    80104ef2 <alltraps>

80105d8a <vector248>:
.globl vector248
vector248:
  pushl $0
80105d8a:	6a 00                	push   $0x0
  pushl $248
80105d8c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d91:	e9 5c f1 ff ff       	jmp    80104ef2 <alltraps>

80105d96 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d96:	6a 00                	push   $0x0
  pushl $249
80105d98:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d9d:	e9 50 f1 ff ff       	jmp    80104ef2 <alltraps>

80105da2 <vector250>:
.globl vector250
vector250:
  pushl $0
80105da2:	6a 00                	push   $0x0
  pushl $250
80105da4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105da9:	e9 44 f1 ff ff       	jmp    80104ef2 <alltraps>

80105dae <vector251>:
.globl vector251
vector251:
  pushl $0
80105dae:	6a 00                	push   $0x0
  pushl $251
80105db0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105db5:	e9 38 f1 ff ff       	jmp    80104ef2 <alltraps>

80105dba <vector252>:
.globl vector252
vector252:
  pushl $0
80105dba:	6a 00                	push   $0x0
  pushl $252
80105dbc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105dc1:	e9 2c f1 ff ff       	jmp    80104ef2 <alltraps>

80105dc6 <vector253>:
.globl vector253
vector253:
  pushl $0
80105dc6:	6a 00                	push   $0x0
  pushl $253
80105dc8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105dcd:	e9 20 f1 ff ff       	jmp    80104ef2 <alltraps>

80105dd2 <vector254>:
.globl vector254
vector254:
  pushl $0
80105dd2:	6a 00                	push   $0x0
  pushl $254
80105dd4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105dd9:	e9 14 f1 ff ff       	jmp    80104ef2 <alltraps>

80105dde <vector255>:
.globl vector255
vector255:
  pushl $0
80105dde:	6a 00                	push   $0x0
  pushl $255
80105de0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105de5:	e9 08 f1 ff ff       	jmp    80104ef2 <alltraps>

80105dea <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105dea:	55                   	push   %ebp
80105deb:	89 e5                	mov    %esp,%ebp
80105ded:	57                   	push   %edi
80105dee:	56                   	push   %esi
80105def:	53                   	push   %ebx
80105df0:	83 ec 0c             	sub    $0xc,%esp
80105df3:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105df5:	c1 ea 16             	shr    $0x16,%edx
80105df8:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105dfb:	8b 37                	mov    (%edi),%esi
80105dfd:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105e03:	74 35                	je     80105e3a <walkpgdir+0x50>

#ifndef __ASSEMBLER__
// Address in page table or page directory entry
//   I changes these from macros into inline functions to make sure we
//   consistently get an error if a pointer is erroneously passed to them.
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
80105e05:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (a > KERNBASE)
80105e0b:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
80105e11:	77 1a                	ja     80105e2d <walkpgdir+0x43>
    return (char*)a + KERNBASE;
80105e13:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e19:	c1 eb 0c             	shr    $0xc,%ebx
80105e1c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
80105e22:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
}
80105e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e28:	5b                   	pop    %ebx
80105e29:	5e                   	pop    %esi
80105e2a:	5f                   	pop    %edi
80105e2b:	5d                   	pop    %ebp
80105e2c:	c3                   	ret    
        panic("P2V on address > KERNBASE");
80105e2d:	83 ec 0c             	sub    $0xc,%esp
80105e30:	68 98 6e 10 80       	push   $0x80106e98
80105e35:	e8 0e a5 ff ff       	call   80100348 <panic>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105e3a:	85 c9                	test   %ecx,%ecx
80105e3c:	74 33                	je     80105e71 <walkpgdir+0x87>
80105e3e:	e8 86 c2 ff ff       	call   801020c9 <kalloc>
80105e43:	89 c6                	mov    %eax,%esi
80105e45:	85 c0                	test   %eax,%eax
80105e47:	74 28                	je     80105e71 <walkpgdir+0x87>
    memset(pgtab, 0, PGSIZE);
80105e49:	83 ec 04             	sub    $0x4,%esp
80105e4c:	68 00 10 00 00       	push   $0x1000
80105e51:	6a 00                	push   $0x0
80105e53:	50                   	push   %eax
80105e54:	e8 b7 df ff ff       	call   80103e10 <memset>
    if (a < (void*) KERNBASE)
80105e59:	83 c4 10             	add    $0x10,%esp
80105e5c:	81 fe ff ff ff 7f    	cmp    $0x7fffffff,%esi
80105e62:	76 14                	jbe    80105e78 <walkpgdir+0x8e>
    return (uint)a - KERNBASE;
80105e64:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e6a:	83 c8 07             	or     $0x7,%eax
80105e6d:	89 07                	mov    %eax,(%edi)
80105e6f:	eb a8                	jmp    80105e19 <walkpgdir+0x2f>
      return 0;
80105e71:	b8 00 00 00 00       	mov    $0x0,%eax
80105e76:	eb ad                	jmp    80105e25 <walkpgdir+0x3b>
        panic("V2P on address < KERNBASE "
80105e78:	83 ec 0c             	sub    $0xc,%esp
80105e7b:	68 68 6b 10 80       	push   $0x80106b68
80105e80:	e8 c3 a4 ff ff       	call   80100348 <panic>

80105e85 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e85:	55                   	push   %ebp
80105e86:	89 e5                	mov    %esp,%ebp
80105e88:	57                   	push   %edi
80105e89:	56                   	push   %esi
80105e8a:	53                   	push   %ebx
80105e8b:	83 ec 1c             	sub    $0x1c,%esp
80105e8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e91:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e94:	89 d3                	mov    %edx,%ebx
80105e96:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e9c:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105ea0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ea6:	b9 01 00 00 00       	mov    $0x1,%ecx
80105eab:	89 da                	mov    %ebx,%edx
80105ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eb0:	e8 35 ff ff ff       	call   80105dea <walkpgdir>
80105eb5:	85 c0                	test   %eax,%eax
80105eb7:	74 2e                	je     80105ee7 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105eb9:	f6 00 01             	testb  $0x1,(%eax)
80105ebc:	75 1c                	jne    80105eda <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105ebe:	89 f2                	mov    %esi,%edx
80105ec0:	0b 55 0c             	or     0xc(%ebp),%edx
80105ec3:	83 ca 01             	or     $0x1,%edx
80105ec6:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105ec8:	39 fb                	cmp    %edi,%ebx
80105eca:	74 28                	je     80105ef4 <mappages+0x6f>
      break;
    a += PGSIZE;
80105ecc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105ed2:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ed8:	eb cc                	jmp    80105ea6 <mappages+0x21>
      panic("remap");
80105eda:	83 ec 0c             	sub    $0xc,%esp
80105edd:	68 80 72 10 80       	push   $0x80107280
80105ee2:	e8 61 a4 ff ff       	call   80100348 <panic>
      return -1;
80105ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105eef:	5b                   	pop    %ebx
80105ef0:	5e                   	pop    %esi
80105ef1:	5f                   	pop    %edi
80105ef2:	5d                   	pop    %ebp
80105ef3:	c3                   	ret    
  return 0;
80105ef4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ef9:	eb f1                	jmp    80105eec <mappages+0x67>

80105efb <seginit>:
{
80105efb:	55                   	push   %ebp
80105efc:	89 e5                	mov    %esp,%ebp
80105efe:	57                   	push   %edi
80105eff:	56                   	push   %esi
80105f00:	53                   	push   %ebx
80105f01:	83 ec 1c             	sub    $0x1c,%esp
  c = &cpus[cpuid()];
80105f04:	e8 85 d3 ff ff       	call   8010328e <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f09:	69 f8 b0 00 00 00    	imul   $0xb0,%eax,%edi
80105f0f:	66 c7 87 18 18 11 80 	movw   $0xffff,-0x7feee7e8(%edi)
80105f16:	ff ff 
80105f18:	66 c7 87 1a 18 11 80 	movw   $0x0,-0x7feee7e6(%edi)
80105f1f:	00 00 
80105f21:	c6 87 1c 18 11 80 00 	movb   $0x0,-0x7feee7e4(%edi)
80105f28:	0f b6 8f 1d 18 11 80 	movzbl -0x7feee7e3(%edi),%ecx
80105f2f:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f32:	89 ce                	mov    %ecx,%esi
80105f34:	83 ce 0a             	or     $0xa,%esi
80105f37:	89 f2                	mov    %esi,%edx
80105f39:	88 97 1d 18 11 80    	mov    %dl,-0x7feee7e3(%edi)
80105f3f:	83 c9 1a             	or     $0x1a,%ecx
80105f42:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105f48:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f4b:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105f51:	83 c9 80             	or     $0xffffff80,%ecx
80105f54:	88 8f 1d 18 11 80    	mov    %cl,-0x7feee7e3(%edi)
80105f5a:	0f b6 8f 1e 18 11 80 	movzbl -0x7feee7e2(%edi),%ecx
80105f61:	83 c9 0f             	or     $0xf,%ecx
80105f64:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105f6a:	89 ce                	mov    %ecx,%esi
80105f6c:	83 e6 ef             	and    $0xffffffef,%esi
80105f6f:	89 f2                	mov    %esi,%edx
80105f71:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105f77:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f7a:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105f80:	89 ce                	mov    %ecx,%esi
80105f82:	83 ce 40             	or     $0x40,%esi
80105f85:	89 f2                	mov    %esi,%edx
80105f87:	88 97 1e 18 11 80    	mov    %dl,-0x7feee7e2(%edi)
80105f8d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f90:	88 8f 1e 18 11 80    	mov    %cl,-0x7feee7e2(%edi)
80105f96:	c6 87 1f 18 11 80 00 	movb   $0x0,-0x7feee7e1(%edi)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105f9d:	66 c7 87 20 18 11 80 	movw   $0xffff,-0x7feee7e0(%edi)
80105fa4:	ff ff 
80105fa6:	66 c7 87 22 18 11 80 	movw   $0x0,-0x7feee7de(%edi)
80105fad:	00 00 
80105faf:	c6 87 24 18 11 80 00 	movb   $0x0,-0x7feee7dc(%edi)
80105fb6:	0f b6 8f 25 18 11 80 	movzbl -0x7feee7db(%edi),%ecx
80105fbd:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fc0:	89 ce                	mov    %ecx,%esi
80105fc2:	83 ce 02             	or     $0x2,%esi
80105fc5:	89 f2                	mov    %esi,%edx
80105fc7:	88 97 25 18 11 80    	mov    %dl,-0x7feee7db(%edi)
80105fcd:	83 c9 12             	or     $0x12,%ecx
80105fd0:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105fd6:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fd9:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105fdf:	83 c9 80             	or     $0xffffff80,%ecx
80105fe2:	88 8f 25 18 11 80    	mov    %cl,-0x7feee7db(%edi)
80105fe8:	0f b6 8f 26 18 11 80 	movzbl -0x7feee7da(%edi),%ecx
80105fef:	83 c9 0f             	or     $0xf,%ecx
80105ff2:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80105ff8:	89 ce                	mov    %ecx,%esi
80105ffa:	83 e6 ef             	and    $0xffffffef,%esi
80105ffd:	89 f2                	mov    %esi,%edx
80105fff:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
80106005:	83 e1 cf             	and    $0xffffffcf,%ecx
80106008:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
8010600e:	89 ce                	mov    %ecx,%esi
80106010:	83 ce 40             	or     $0x40,%esi
80106013:	89 f2                	mov    %esi,%edx
80106015:	88 97 26 18 11 80    	mov    %dl,-0x7feee7da(%edi)
8010601b:	83 c9 c0             	or     $0xffffffc0,%ecx
8010601e:	88 8f 26 18 11 80    	mov    %cl,-0x7feee7da(%edi)
80106024:	c6 87 27 18 11 80 00 	movb   $0x0,-0x7feee7d9(%edi)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010602b:	66 c7 87 28 18 11 80 	movw   $0xffff,-0x7feee7d8(%edi)
80106032:	ff ff 
80106034:	66 c7 87 2a 18 11 80 	movw   $0x0,-0x7feee7d6(%edi)
8010603b:	00 00 
8010603d:	c6 87 2c 18 11 80 00 	movb   $0x0,-0x7feee7d4(%edi)
80106044:	0f b6 9f 2d 18 11 80 	movzbl -0x7feee7d3(%edi),%ebx
8010604b:	83 e3 f0             	and    $0xfffffff0,%ebx
8010604e:	89 de                	mov    %ebx,%esi
80106050:	83 ce 0a             	or     $0xa,%esi
80106053:	89 f2                	mov    %esi,%edx
80106055:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
8010605b:	89 de                	mov    %ebx,%esi
8010605d:	83 ce 1a             	or     $0x1a,%esi
80106060:	89 f2                	mov    %esi,%edx
80106062:	88 97 2d 18 11 80    	mov    %dl,-0x7feee7d3(%edi)
80106068:	83 cb 7a             	or     $0x7a,%ebx
8010606b:	88 9f 2d 18 11 80    	mov    %bl,-0x7feee7d3(%edi)
80106071:	c6 87 2d 18 11 80 fa 	movb   $0xfa,-0x7feee7d3(%edi)
80106078:	0f b6 9f 2e 18 11 80 	movzbl -0x7feee7d2(%edi),%ebx
8010607f:	83 cb 0f             	or     $0xf,%ebx
80106082:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
80106088:	89 de                	mov    %ebx,%esi
8010608a:	83 e6 ef             	and    $0xffffffef,%esi
8010608d:	89 f2                	mov    %esi,%edx
8010608f:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
80106095:	83 e3 cf             	and    $0xffffffcf,%ebx
80106098:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
8010609e:	89 de                	mov    %ebx,%esi
801060a0:	83 ce 40             	or     $0x40,%esi
801060a3:	89 f2                	mov    %esi,%edx
801060a5:	88 97 2e 18 11 80    	mov    %dl,-0x7feee7d2(%edi)
801060ab:	83 cb c0             	or     $0xffffffc0,%ebx
801060ae:	88 9f 2e 18 11 80    	mov    %bl,-0x7feee7d2(%edi)
801060b4:	c6 87 2f 18 11 80 00 	movb   $0x0,-0x7feee7d1(%edi)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801060bb:	66 c7 87 30 18 11 80 	movw   $0xffff,-0x7feee7d0(%edi)
801060c2:	ff ff 
801060c4:	66 c7 87 32 18 11 80 	movw   $0x0,-0x7feee7ce(%edi)
801060cb:	00 00 
801060cd:	c6 87 34 18 11 80 00 	movb   $0x0,-0x7feee7cc(%edi)
801060d4:	0f b6 9f 35 18 11 80 	movzbl -0x7feee7cb(%edi),%ebx
801060db:	83 e3 f0             	and    $0xfffffff0,%ebx
801060de:	89 de                	mov    %ebx,%esi
801060e0:	83 ce 02             	or     $0x2,%esi
801060e3:	89 f2                	mov    %esi,%edx
801060e5:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
801060eb:	89 de                	mov    %ebx,%esi
801060ed:	83 ce 12             	or     $0x12,%esi
801060f0:	89 f2                	mov    %esi,%edx
801060f2:	88 97 35 18 11 80    	mov    %dl,-0x7feee7cb(%edi)
801060f8:	83 cb 72             	or     $0x72,%ebx
801060fb:	88 9f 35 18 11 80    	mov    %bl,-0x7feee7cb(%edi)
80106101:	c6 87 35 18 11 80 f2 	movb   $0xf2,-0x7feee7cb(%edi)
80106108:	0f b6 9f 36 18 11 80 	movzbl -0x7feee7ca(%edi),%ebx
8010610f:	83 cb 0f             	or     $0xf,%ebx
80106112:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106118:	89 de                	mov    %ebx,%esi
8010611a:	83 e6 ef             	and    $0xffffffef,%esi
8010611d:	89 f2                	mov    %esi,%edx
8010611f:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
80106125:	83 e3 cf             	and    $0xffffffcf,%ebx
80106128:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
8010612e:	89 de                	mov    %ebx,%esi
80106130:	83 ce 40             	or     $0x40,%esi
80106133:	89 f2                	mov    %esi,%edx
80106135:	88 97 36 18 11 80    	mov    %dl,-0x7feee7ca(%edi)
8010613b:	83 cb c0             	or     $0xffffffc0,%ebx
8010613e:	88 9f 36 18 11 80    	mov    %bl,-0x7feee7ca(%edi)
80106144:	c6 87 37 18 11 80 00 	movb   $0x0,-0x7feee7c9(%edi)
  lgdt(c->gdt, sizeof(c->gdt));
8010614b:	8d 97 10 18 11 80    	lea    -0x7feee7f0(%edi),%edx
  pd[0] = size-1;
80106151:	66 c7 45 e2 2f 00    	movw   $0x2f,-0x1e(%ebp)
  pd[1] = (uint)p;
80106157:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
  pd[2] = (uint)p >> 16;
8010615b:	c1 ea 10             	shr    $0x10,%edx
8010615e:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106162:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106165:	0f 01 10             	lgdtl  (%eax)
}
80106168:	83 c4 1c             	add    $0x1c,%esp
8010616b:	5b                   	pop    %ebx
8010616c:	5e                   	pop    %esi
8010616d:	5f                   	pop    %edi
8010616e:	5d                   	pop    %ebp
8010616f:	c3                   	ret    

80106170 <switchkvm>:
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106170:	a1 c4 46 11 80       	mov    0x801146c4,%eax
    if (a < (void*) KERNBASE)
80106175:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
8010617a:	76 09                	jbe    80106185 <switchkvm+0x15>
    return (uint)a - KERNBASE;
8010617c:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106181:	0f 22 d8             	mov    %eax,%cr3
80106184:	c3                   	ret    
{
80106185:	55                   	push   %ebp
80106186:	89 e5                	mov    %esp,%ebp
80106188:	83 ec 14             	sub    $0x14,%esp
        panic("V2P on address < KERNBASE "
8010618b:	68 68 6b 10 80       	push   $0x80106b68
80106190:	e8 b3 a1 ff ff       	call   80100348 <panic>

80106195 <switchuvm>:
}

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106195:	55                   	push   %ebp
80106196:	89 e5                	mov    %esp,%ebp
80106198:	57                   	push   %edi
80106199:	56                   	push   %esi
8010619a:	53                   	push   %ebx
8010619b:	83 ec 1c             	sub    $0x1c,%esp
8010619e:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801061a1:	85 f6                	test   %esi,%esi
801061a3:	0f 84 2c 01 00 00    	je     801062d5 <switchuvm+0x140>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801061a9:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801061ad:	0f 84 2f 01 00 00    	je     801062e2 <switchuvm+0x14d>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801061b3:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801061b7:	0f 84 32 01 00 00    	je     801062ef <switchuvm+0x15a>
    panic("switchuvm: no pgdir");

  pushcli();
801061bd:	e8 c7 da ff ff       	call   80103c89 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801061c2:	e8 6b d0 ff ff       	call   80103232 <mycpu>
801061c7:	89 c3                	mov    %eax,%ebx
801061c9:	e8 64 d0 ff ff       	call   80103232 <mycpu>
801061ce:	8d 78 08             	lea    0x8(%eax),%edi
801061d1:	e8 5c d0 ff ff       	call   80103232 <mycpu>
801061d6:	83 c0 08             	add    $0x8,%eax
801061d9:	c1 e8 10             	shr    $0x10,%eax
801061dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061df:	e8 4e d0 ff ff       	call   80103232 <mycpu>
801061e4:	83 c0 08             	add    $0x8,%eax
801061e7:	c1 e8 18             	shr    $0x18,%eax
801061ea:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801061f1:	67 00 
801061f3:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801061fa:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801061fe:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106204:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010620b:	83 e2 f0             	and    $0xfffffff0,%edx
8010620e:	89 d1                	mov    %edx,%ecx
80106210:	83 c9 09             	or     $0x9,%ecx
80106213:	88 8b 9d 00 00 00    	mov    %cl,0x9d(%ebx)
80106219:	83 ca 19             	or     $0x19,%edx
8010621c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106222:	83 e2 9f             	and    $0xffffff9f,%edx
80106225:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010622b:	83 ca 80             	or     $0xffffff80,%edx
8010622e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106234:	0f b6 93 9e 00 00 00 	movzbl 0x9e(%ebx),%edx
8010623b:	89 d1                	mov    %edx,%ecx
8010623d:	83 e1 f0             	and    $0xfffffff0,%ecx
80106240:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106246:	89 d1                	mov    %edx,%ecx
80106248:	83 e1 e0             	and    $0xffffffe0,%ecx
8010624b:	88 8b 9e 00 00 00    	mov    %cl,0x9e(%ebx)
80106251:	83 e2 c0             	and    $0xffffffc0,%edx
80106254:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010625a:	83 ca 40             	or     $0x40,%edx
8010625d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80106263:	83 e2 7f             	and    $0x7f,%edx
80106266:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010626c:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106272:	e8 bb cf ff ff       	call   80103232 <mycpu>
80106277:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010627e:	83 e2 ef             	and    $0xffffffef,%edx
80106281:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106287:	e8 a6 cf ff ff       	call   80103232 <mycpu>
8010628c:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106292:	8b 5e 08             	mov    0x8(%esi),%ebx
80106295:	e8 98 cf ff ff       	call   80103232 <mycpu>
8010629a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062a0:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801062a3:	e8 8a cf ff ff       	call   80103232 <mycpu>
801062a8:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801062ae:	b8 28 00 00 00       	mov    $0x28,%eax
801062b3:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801062b6:	8b 46 04             	mov    0x4(%esi),%eax
    if (a < (void*) KERNBASE)
801062b9:	3d ff ff ff 7f       	cmp    $0x7fffffff,%eax
801062be:	76 3c                	jbe    801062fc <switchuvm+0x167>
    return (uint)a - KERNBASE;
801062c0:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801062c5:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801062c8:	e8 f8 d9 ff ff       	call   80103cc5 <popcli>
}
801062cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062d0:	5b                   	pop    %ebx
801062d1:	5e                   	pop    %esi
801062d2:	5f                   	pop    %edi
801062d3:	5d                   	pop    %ebp
801062d4:	c3                   	ret    
    panic("switchuvm: no process");
801062d5:	83 ec 0c             	sub    $0xc,%esp
801062d8:	68 86 72 10 80       	push   $0x80107286
801062dd:	e8 66 a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801062e2:	83 ec 0c             	sub    $0xc,%esp
801062e5:	68 9c 72 10 80       	push   $0x8010729c
801062ea:	e8 59 a0 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	68 b1 72 10 80       	push   $0x801072b1
801062f7:	e8 4c a0 ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
801062fc:	83 ec 0c             	sub    $0xc,%esp
801062ff:	68 68 6b 10 80       	push   $0x80106b68
80106304:	e8 3f a0 ff ff       	call   80100348 <panic>

80106309 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106309:	55                   	push   %ebp
8010630a:	89 e5                	mov    %esp,%ebp
8010630c:	56                   	push   %esi
8010630d:	53                   	push   %ebx
8010630e:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106311:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106317:	77 57                	ja     80106370 <inituvm+0x67>
    panic("inituvm: more than a page");
  mem = kalloc();
80106319:	e8 ab bd ff ff       	call   801020c9 <kalloc>
8010631e:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106320:	83 ec 04             	sub    $0x4,%esp
80106323:	68 00 10 00 00       	push   $0x1000
80106328:	6a 00                	push   $0x0
8010632a:	50                   	push   %eax
8010632b:	e8 e0 da ff ff       	call   80103e10 <memset>
    if (a < (void*) KERNBASE)
80106330:	83 c4 10             	add    $0x10,%esp
80106333:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106339:	76 42                	jbe    8010637d <inituvm+0x74>
    return (uint)a - KERNBASE;
8010633b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106341:	83 ec 08             	sub    $0x8,%esp
80106344:	6a 06                	push   $0x6
80106346:	50                   	push   %eax
80106347:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010634c:	ba 00 00 00 00       	mov    $0x0,%edx
80106351:	8b 45 08             	mov    0x8(%ebp),%eax
80106354:	e8 2c fb ff ff       	call   80105e85 <mappages>
  memmove(mem, init, sz);
80106359:	83 c4 0c             	add    $0xc,%esp
8010635c:	56                   	push   %esi
8010635d:	ff 75 0c             	push   0xc(%ebp)
80106360:	53                   	push   %ebx
80106361:	e8 22 db ff ff       	call   80103e88 <memmove>
}
80106366:	83 c4 10             	add    $0x10,%esp
80106369:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010636c:	5b                   	pop    %ebx
8010636d:	5e                   	pop    %esi
8010636e:	5d                   	pop    %ebp
8010636f:	c3                   	ret    
    panic("inituvm: more than a page");
80106370:	83 ec 0c             	sub    $0xc,%esp
80106373:	68 c5 72 10 80       	push   $0x801072c5
80106378:	e8 cb 9f ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010637d:	83 ec 0c             	sub    $0xc,%esp
80106380:	68 68 6b 10 80       	push   $0x80106b68
80106385:	e8 be 9f ff ff       	call   80100348 <panic>

8010638a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010638a:	55                   	push   %ebp
8010638b:	89 e5                	mov    %esp,%ebp
8010638d:	57                   	push   %edi
8010638e:	56                   	push   %esi
8010638f:	53                   	push   %ebx
80106390:	83 ec 0c             	sub    $0xc,%esp
80106393:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106399:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
8010639f:	74 43                	je     801063e4 <loaduvm+0x5a>
    panic("loaduvm: addr must be page aligned");
801063a1:	83 ec 0c             	sub    $0xc,%esp
801063a4:	68 80 73 10 80       	push   $0x80107380
801063a9:	e8 9a 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801063ae:	83 ec 0c             	sub    $0xc,%esp
801063b1:	68 df 72 10 80       	push   $0x801072df
801063b6:	e8 8d 9f ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801063bb:	89 da                	mov    %ebx,%edx
801063bd:	03 55 14             	add    0x14(%ebp),%edx
    if (a > KERNBASE)
801063c0:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801063c5:	77 51                	ja     80106418 <loaduvm+0x8e>
    return (char*)a + KERNBASE;
801063c7:	05 00 00 00 80       	add    $0x80000000,%eax
801063cc:	56                   	push   %esi
801063cd:	52                   	push   %edx
801063ce:	50                   	push   %eax
801063cf:	ff 75 10             	push   0x10(%ebp)
801063d2:	e8 8a b3 ff ff       	call   80101761 <readi>
801063d7:	83 c4 10             	add    $0x10,%esp
801063da:	39 f0                	cmp    %esi,%eax
801063dc:	75 54                	jne    80106432 <loaduvm+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
801063de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063e4:	39 fb                	cmp    %edi,%ebx
801063e6:	73 3d                	jae    80106425 <loaduvm+0x9b>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801063e8:	89 da                	mov    %ebx,%edx
801063ea:	03 55 0c             	add    0xc(%ebp),%edx
801063ed:	b9 00 00 00 00       	mov    $0x0,%ecx
801063f2:	8b 45 08             	mov    0x8(%ebp),%eax
801063f5:	e8 f0 f9 ff ff       	call   80105dea <walkpgdir>
801063fa:	85 c0                	test   %eax,%eax
801063fc:	74 b0                	je     801063ae <loaduvm+0x24>
    pa = PTE_ADDR(*pte);
801063fe:	8b 00                	mov    (%eax),%eax
80106400:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106405:	89 fe                	mov    %edi,%esi
80106407:	29 de                	sub    %ebx,%esi
80106409:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010640f:	76 aa                	jbe    801063bb <loaduvm+0x31>
      n = PGSIZE;
80106411:	be 00 10 00 00       	mov    $0x1000,%esi
80106416:	eb a3                	jmp    801063bb <loaduvm+0x31>
        panic("P2V on address > KERNBASE");
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	68 98 6e 10 80       	push   $0x80106e98
80106420:	e8 23 9f ff ff       	call   80100348 <panic>
      return -1;
  }
  return 0;
80106425:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010642a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010642d:	5b                   	pop    %ebx
8010642e:	5e                   	pop    %esi
8010642f:	5f                   	pop    %edi
80106430:	5d                   	pop    %ebp
80106431:	c3                   	ret    
      return -1;
80106432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106437:	eb f1                	jmp    8010642a <loaduvm+0xa0>

80106439 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106439:	55                   	push   %ebp
8010643a:	89 e5                	mov    %esp,%ebp
8010643c:	57                   	push   %edi
8010643d:	56                   	push   %esi
8010643e:	53                   	push   %ebx
8010643f:	83 ec 0c             	sub    $0xc,%esp
80106442:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106445:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106448:	73 11                	jae    8010645b <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010644a:	8b 45 10             	mov    0x10(%ebp),%eax
8010644d:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106453:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106459:	eb 19                	jmp    80106474 <deallocuvm+0x3b>
    return oldsz;
8010645b:	89 f8                	mov    %edi,%eax
8010645d:	eb 78                	jmp    801064d7 <deallocuvm+0x9e>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010645f:	c1 eb 16             	shr    $0x16,%ebx
80106462:	83 c3 01             	add    $0x1,%ebx
80106465:	c1 e3 16             	shl    $0x16,%ebx
80106468:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010646e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106474:	39 fb                	cmp    %edi,%ebx
80106476:	73 5c                	jae    801064d4 <deallocuvm+0x9b>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106478:	b9 00 00 00 00       	mov    $0x0,%ecx
8010647d:	89 da                	mov    %ebx,%edx
8010647f:	8b 45 08             	mov    0x8(%ebp),%eax
80106482:	e8 63 f9 ff ff       	call   80105dea <walkpgdir>
80106487:	89 c6                	mov    %eax,%esi
    if(!pte)
80106489:	85 c0                	test   %eax,%eax
8010648b:	74 d2                	je     8010645f <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010648d:	8b 00                	mov    (%eax),%eax
8010648f:	a8 01                	test   $0x1,%al
80106491:	74 db                	je     8010646e <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106493:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106498:	74 20                	je     801064ba <deallocuvm+0x81>
    if (a > KERNBASE)
8010649a:	3d 00 00 00 80       	cmp    $0x80000000,%eax
8010649f:	77 26                	ja     801064c7 <deallocuvm+0x8e>
    return (char*)a + KERNBASE;
801064a1:	05 00 00 00 80       	add    $0x80000000,%eax
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801064a6:	83 ec 0c             	sub    $0xc,%esp
801064a9:	50                   	push   %eax
801064aa:	e8 dd ba ff ff       	call   80101f8c <kfree>
      *pte = 0;
801064af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801064b5:	83 c4 10             	add    $0x10,%esp
801064b8:	eb b4                	jmp    8010646e <deallocuvm+0x35>
        panic("kfree");
801064ba:	83 ec 0c             	sub    $0xc,%esp
801064bd:	68 f6 6b 10 80       	push   $0x80106bf6
801064c2:	e8 81 9e ff ff       	call   80100348 <panic>
        panic("P2V on address > KERNBASE");
801064c7:	83 ec 0c             	sub    $0xc,%esp
801064ca:	68 98 6e 10 80       	push   $0x80106e98
801064cf:	e8 74 9e ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801064d4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801064d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064da:	5b                   	pop    %ebx
801064db:	5e                   	pop    %esi
801064dc:	5f                   	pop    %edi
801064dd:	5d                   	pop    %ebp
801064de:	c3                   	ret    

801064df <allocuvm>:
{
801064df:	55                   	push   %ebp
801064e0:	89 e5                	mov    %esp,%ebp
801064e2:	57                   	push   %edi
801064e3:	56                   	push   %esi
801064e4:	53                   	push   %ebx
801064e5:	83 ec 1c             	sub    $0x1c,%esp
801064e8:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801064eb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801064ee:	85 ff                	test   %edi,%edi
801064f0:	0f 88 d9 00 00 00    	js     801065cf <allocuvm+0xf0>
  if(newsz < oldsz)
801064f6:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801064f9:	72 67                	jb     80106562 <allocuvm+0x83>
  a = PGROUNDUP(oldsz);
801064fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801064fe:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106504:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
8010650a:	39 fe                	cmp    %edi,%esi
8010650c:	0f 83 c4 00 00 00    	jae    801065d6 <allocuvm+0xf7>
    mem = kalloc();
80106512:	e8 b2 bb ff ff       	call   801020c9 <kalloc>
80106517:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106519:	85 c0                	test   %eax,%eax
8010651b:	74 4d                	je     8010656a <allocuvm+0x8b>
    memset(mem, 0, PGSIZE);
8010651d:	83 ec 04             	sub    $0x4,%esp
80106520:	68 00 10 00 00       	push   $0x1000
80106525:	6a 00                	push   $0x0
80106527:	50                   	push   %eax
80106528:	e8 e3 d8 ff ff       	call   80103e10 <memset>
    if (a < (void*) KERNBASE)
8010652d:	83 c4 10             	add    $0x10,%esp
80106530:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
80106536:	76 5a                	jbe    80106592 <allocuvm+0xb3>
    return (uint)a - KERNBASE;
80106538:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010653e:	83 ec 08             	sub    $0x8,%esp
80106541:	6a 06                	push   $0x6
80106543:	50                   	push   %eax
80106544:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106549:	89 f2                	mov    %esi,%edx
8010654b:	8b 45 08             	mov    0x8(%ebp),%eax
8010654e:	e8 32 f9 ff ff       	call   80105e85 <mappages>
80106553:	83 c4 10             	add    $0x10,%esp
80106556:	85 c0                	test   %eax,%eax
80106558:	78 45                	js     8010659f <allocuvm+0xc0>
  for(; a < newsz; a += PGSIZE){
8010655a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106560:	eb a8                	jmp    8010650a <allocuvm+0x2b>
    return oldsz;
80106562:	8b 45 0c             	mov    0xc(%ebp),%eax
80106565:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106568:	eb 6c                	jmp    801065d6 <allocuvm+0xf7>
      cprintf("allocuvm out of memory\n");
8010656a:	83 ec 0c             	sub    $0xc,%esp
8010656d:	68 fd 72 10 80       	push   $0x801072fd
80106572:	e8 90 a0 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106577:	83 c4 0c             	add    $0xc,%esp
8010657a:	ff 75 0c             	push   0xc(%ebp)
8010657d:	57                   	push   %edi
8010657e:	ff 75 08             	push   0x8(%ebp)
80106581:	e8 b3 fe ff ff       	call   80106439 <deallocuvm>
      return 0;
80106586:	83 c4 10             	add    $0x10,%esp
80106589:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106590:	eb 44                	jmp    801065d6 <allocuvm+0xf7>
        panic("V2P on address < KERNBASE "
80106592:	83 ec 0c             	sub    $0xc,%esp
80106595:	68 68 6b 10 80       	push   $0x80106b68
8010659a:	e8 a9 9d ff ff       	call   80100348 <panic>
      cprintf("allocuvm out of memory (2)\n");
8010659f:	83 ec 0c             	sub    $0xc,%esp
801065a2:	68 15 73 10 80       	push   $0x80107315
801065a7:	e8 5b a0 ff ff       	call   80100607 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801065ac:	83 c4 0c             	add    $0xc,%esp
801065af:	ff 75 0c             	push   0xc(%ebp)
801065b2:	57                   	push   %edi
801065b3:	ff 75 08             	push   0x8(%ebp)
801065b6:	e8 7e fe ff ff       	call   80106439 <deallocuvm>
      kfree(mem);
801065bb:	89 1c 24             	mov    %ebx,(%esp)
801065be:	e8 c9 b9 ff ff       	call   80101f8c <kfree>
      return 0;
801065c3:	83 c4 10             	add    $0x10,%esp
801065c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065cd:	eb 07                	jmp    801065d6 <allocuvm+0xf7>
    return 0;
801065cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801065d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065dc:	5b                   	pop    %ebx
801065dd:	5e                   	pop    %esi
801065de:	5f                   	pop    %edi
801065df:	5d                   	pop    %ebp
801065e0:	c3                   	ret    

801065e1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801065e1:	55                   	push   %ebp
801065e2:	89 e5                	mov    %esp,%ebp
801065e4:	56                   	push   %esi
801065e5:	53                   	push   %ebx
801065e6:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801065e9:	85 f6                	test   %esi,%esi
801065eb:	74 1a                	je     80106607 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801065ed:	83 ec 04             	sub    $0x4,%esp
801065f0:	6a 00                	push   $0x0
801065f2:	68 00 00 00 80       	push   $0x80000000
801065f7:	56                   	push   %esi
801065f8:	e8 3c fe ff ff       	call   80106439 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801065fd:	83 c4 10             	add    $0x10,%esp
80106600:	bb 00 00 00 00       	mov    $0x0,%ebx
80106605:	eb 21                	jmp    80106628 <freevm+0x47>
    panic("freevm: no pgdir");
80106607:	83 ec 0c             	sub    $0xc,%esp
8010660a:	68 31 73 10 80       	push   $0x80107331
8010660f:	e8 34 9d ff ff       	call   80100348 <panic>
    return (char*)a + KERNBASE;
80106614:	05 00 00 00 80       	add    $0x80000000,%eax
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
80106619:	83 ec 0c             	sub    $0xc,%esp
8010661c:	50                   	push   %eax
8010661d:	e8 6a b9 ff ff       	call   80101f8c <kfree>
80106622:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106625:	83 c3 01             	add    $0x1,%ebx
80106628:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
8010662e:	77 20                	ja     80106650 <freevm+0x6f>
    if(pgdir[i] & PTE_P){
80106630:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106633:	a8 01                	test   $0x1,%al
80106635:	74 ee                	je     80106625 <freevm+0x44>
80106637:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010663c:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106641:	76 d1                	jbe    80106614 <freevm+0x33>
        panic("P2V on address > KERNBASE");
80106643:	83 ec 0c             	sub    $0xc,%esp
80106646:	68 98 6e 10 80       	push   $0x80106e98
8010664b:	e8 f8 9c ff ff       	call   80100348 <panic>
    }
  }
  kfree((char*)pgdir);
80106650:	83 ec 0c             	sub    $0xc,%esp
80106653:	56                   	push   %esi
80106654:	e8 33 b9 ff ff       	call   80101f8c <kfree>
}
80106659:	83 c4 10             	add    $0x10,%esp
8010665c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010665f:	5b                   	pop    %ebx
80106660:	5e                   	pop    %esi
80106661:	5d                   	pop    %ebp
80106662:	c3                   	ret    

80106663 <setupkvm>:
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	56                   	push   %esi
80106667:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106668:	e8 5c ba ff ff       	call   801020c9 <kalloc>
8010666d:	89 c6                	mov    %eax,%esi
8010666f:	85 c0                	test   %eax,%eax
80106671:	74 55                	je     801066c8 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106673:	83 ec 04             	sub    $0x4,%esp
80106676:	68 00 10 00 00       	push   $0x1000
8010667b:	6a 00                	push   $0x0
8010667d:	50                   	push   %eax
8010667e:	e8 8d d7 ff ff       	call   80103e10 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106683:	83 c4 10             	add    $0x10,%esp
80106686:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010668b:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106691:	73 35                	jae    801066c8 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106693:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106696:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106699:	29 c1                	sub    %eax,%ecx
8010669b:	83 ec 08             	sub    $0x8,%esp
8010669e:	ff 73 0c             	push   0xc(%ebx)
801066a1:	50                   	push   %eax
801066a2:	8b 13                	mov    (%ebx),%edx
801066a4:	89 f0                	mov    %esi,%eax
801066a6:	e8 da f7 ff ff       	call   80105e85 <mappages>
801066ab:	83 c4 10             	add    $0x10,%esp
801066ae:	85 c0                	test   %eax,%eax
801066b0:	78 05                	js     801066b7 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066b2:	83 c3 10             	add    $0x10,%ebx
801066b5:	eb d4                	jmp    8010668b <setupkvm+0x28>
      freevm(pgdir);
801066b7:	83 ec 0c             	sub    $0xc,%esp
801066ba:	56                   	push   %esi
801066bb:	e8 21 ff ff ff       	call   801065e1 <freevm>
      return 0;
801066c0:	83 c4 10             	add    $0x10,%esp
801066c3:	be 00 00 00 00       	mov    $0x0,%esi
}
801066c8:	89 f0                	mov    %esi,%eax
801066ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
801066cd:	5b                   	pop    %ebx
801066ce:	5e                   	pop    %esi
801066cf:	5d                   	pop    %ebp
801066d0:	c3                   	ret    

801066d1 <kvmalloc>:
{
801066d1:	55                   	push   %ebp
801066d2:	89 e5                	mov    %esp,%ebp
801066d4:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801066d7:	e8 87 ff ff ff       	call   80106663 <setupkvm>
801066dc:	a3 c4 46 11 80       	mov    %eax,0x801146c4
  switchkvm();
801066e1:	e8 8a fa ff ff       	call   80106170 <switchkvm>
}
801066e6:	c9                   	leave  
801066e7:	c3                   	ret    

801066e8 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801066e8:	55                   	push   %ebp
801066e9:	89 e5                	mov    %esp,%ebp
801066eb:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066ee:	b9 00 00 00 00       	mov    $0x0,%ecx
801066f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801066f6:	8b 45 08             	mov    0x8(%ebp),%eax
801066f9:	e8 ec f6 ff ff       	call   80105dea <walkpgdir>
  if(pte == 0)
801066fe:	85 c0                	test   %eax,%eax
80106700:	74 05                	je     80106707 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106702:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106705:	c9                   	leave  
80106706:	c3                   	ret    
    panic("clearpteu");
80106707:	83 ec 0c             	sub    $0xc,%esp
8010670a:	68 42 73 10 80       	push   $0x80107342
8010670f:	e8 34 9c ff ff       	call   80100348 <panic>

80106714 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
80106717:	57                   	push   %edi
80106718:	56                   	push   %esi
80106719:	53                   	push   %ebx
8010671a:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010671d:	e8 41 ff ff ff       	call   80106663 <setupkvm>
80106722:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106725:	85 c0                	test   %eax,%eax
80106727:	0f 84 f2 00 00 00    	je     8010681f <copyuvm+0x10b>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010672d:	bf 00 00 00 00       	mov    $0x0,%edi
80106732:	eb 3a                	jmp    8010676e <copyuvm+0x5a>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106734:	83 ec 0c             	sub    $0xc,%esp
80106737:	68 4c 73 10 80       	push   $0x8010734c
8010673c:	e8 07 9c ff ff       	call   80100348 <panic>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
80106741:	83 ec 0c             	sub    $0xc,%esp
80106744:	68 66 73 10 80       	push   $0x80107366
80106749:	e8 fa 9b ff ff       	call   80100348 <panic>
8010674e:	83 ec 0c             	sub    $0xc,%esp
80106751:	68 98 6e 10 80       	push   $0x80106e98
80106756:	e8 ed 9b ff ff       	call   80100348 <panic>
        panic("V2P on address < KERNBASE "
8010675b:	83 ec 0c             	sub    $0xc,%esp
8010675e:	68 68 6b 10 80       	push   $0x80106b68
80106763:	e8 e0 9b ff ff       	call   80100348 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80106768:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010676e:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106771:	0f 83 a8 00 00 00    	jae    8010681f <copyuvm+0x10b>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106777:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010677a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010677f:	89 fa                	mov    %edi,%edx
80106781:	8b 45 08             	mov    0x8(%ebp),%eax
80106784:	e8 61 f6 ff ff       	call   80105dea <walkpgdir>
80106789:	85 c0                	test   %eax,%eax
8010678b:	74 a7                	je     80106734 <copyuvm+0x20>
    if(!(*pte & PTE_P))
8010678d:	8b 00                	mov    (%eax),%eax
8010678f:	a8 01                	test   $0x1,%al
80106791:	74 ae                	je     80106741 <copyuvm+0x2d>
80106793:	89 c6                	mov    %eax,%esi
80106795:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
static inline uint PTE_FLAGS(uint pte) { return pte & 0xFFF; }
8010679b:	25 ff 0f 00 00       	and    $0xfff,%eax
801067a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801067a3:	e8 21 b9 ff ff       	call   801020c9 <kalloc>
801067a8:	89 c3                	mov    %eax,%ebx
801067aa:	85 c0                	test   %eax,%eax
801067ac:	74 5c                	je     8010680a <copyuvm+0xf6>
    if (a > KERNBASE)
801067ae:	81 fe 00 00 00 80    	cmp    $0x80000000,%esi
801067b4:	77 98                	ja     8010674e <copyuvm+0x3a>
    return (char*)a + KERNBASE;
801067b6:	81 c6 00 00 00 80    	add    $0x80000000,%esi
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801067bc:	83 ec 04             	sub    $0x4,%esp
801067bf:	68 00 10 00 00       	push   $0x1000
801067c4:	56                   	push   %esi
801067c5:	50                   	push   %eax
801067c6:	e8 bd d6 ff ff       	call   80103e88 <memmove>
    if (a < (void*) KERNBASE)
801067cb:	83 c4 10             	add    $0x10,%esp
801067ce:	81 fb ff ff ff 7f    	cmp    $0x7fffffff,%ebx
801067d4:	76 85                	jbe    8010675b <copyuvm+0x47>
    return (uint)a - KERNBASE;
801067d6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801067dc:	83 ec 08             	sub    $0x8,%esp
801067df:	ff 75 e0             	push   -0x20(%ebp)
801067e2:	50                   	push   %eax
801067e3:	b9 00 10 00 00       	mov    $0x1000,%ecx
801067e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801067ee:	e8 92 f6 ff ff       	call   80105e85 <mappages>
801067f3:	83 c4 10             	add    $0x10,%esp
801067f6:	85 c0                	test   %eax,%eax
801067f8:	0f 89 6a ff ff ff    	jns    80106768 <copyuvm+0x54>
      kfree(mem);
801067fe:	83 ec 0c             	sub    $0xc,%esp
80106801:	53                   	push   %ebx
80106802:	e8 85 b7 ff ff       	call   80101f8c <kfree>
      goto bad;
80106807:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010680a:	83 ec 0c             	sub    $0xc,%esp
8010680d:	ff 75 dc             	push   -0x24(%ebp)
80106810:	e8 cc fd ff ff       	call   801065e1 <freevm>
  return 0;
80106815:	83 c4 10             	add    $0x10,%esp
80106818:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010681f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106822:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106825:	5b                   	pop    %ebx
80106826:	5e                   	pop    %esi
80106827:	5f                   	pop    %edi
80106828:	5d                   	pop    %ebp
80106829:	c3                   	ret    

8010682a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010682a:	55                   	push   %ebp
8010682b:	89 e5                	mov    %esp,%ebp
8010682d:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106830:	b9 00 00 00 00       	mov    $0x0,%ecx
80106835:	8b 55 0c             	mov    0xc(%ebp),%edx
80106838:	8b 45 08             	mov    0x8(%ebp),%eax
8010683b:	e8 aa f5 ff ff       	call   80105dea <walkpgdir>
  if((*pte & PTE_P) == 0)
80106840:	8b 00                	mov    (%eax),%eax
80106842:	a8 01                	test   $0x1,%al
80106844:	74 24                	je     8010686a <uva2ka+0x40>
    return 0;
  if((*pte & PTE_U) == 0)
80106846:	a8 04                	test   $0x4,%al
80106848:	74 27                	je     80106871 <uva2ka+0x47>
static inline uint PTE_ADDR(uint pte)  { return pte & ~0xFFF; }
8010684a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if (a > KERNBASE)
8010684f:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80106854:	77 07                	ja     8010685d <uva2ka+0x33>
    return (char*)a + KERNBASE;
80106856:	05 00 00 00 80       	add    $0x80000000,%eax
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
8010685b:	c9                   	leave  
8010685c:	c3                   	ret    
        panic("P2V on address > KERNBASE");
8010685d:	83 ec 0c             	sub    $0xc,%esp
80106860:	68 98 6e 10 80       	push   $0x80106e98
80106865:	e8 de 9a ff ff       	call   80100348 <panic>
    return 0;
8010686a:	b8 00 00 00 00       	mov    $0x0,%eax
8010686f:	eb ea                	jmp    8010685b <uva2ka+0x31>
    return 0;
80106871:	b8 00 00 00 00       	mov    $0x0,%eax
80106876:	eb e3                	jmp    8010685b <uva2ka+0x31>

80106878 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106878:	55                   	push   %ebp
80106879:	89 e5                	mov    %esp,%ebp
8010687b:	57                   	push   %edi
8010687c:	56                   	push   %esi
8010687d:	53                   	push   %ebx
8010687e:	83 ec 0c             	sub    $0xc,%esp
80106881:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106884:	eb 25                	jmp    801068ab <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106886:	8b 55 0c             	mov    0xc(%ebp),%edx
80106889:	29 f2                	sub    %esi,%edx
8010688b:	01 d0                	add    %edx,%eax
8010688d:	83 ec 04             	sub    $0x4,%esp
80106890:	53                   	push   %ebx
80106891:	ff 75 10             	push   0x10(%ebp)
80106894:	50                   	push   %eax
80106895:	e8 ee d5 ff ff       	call   80103e88 <memmove>
    len -= n;
8010689a:	29 df                	sub    %ebx,%edi
    buf += n;
8010689c:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010689f:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801068a5:	89 45 0c             	mov    %eax,0xc(%ebp)
801068a8:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801068ab:	85 ff                	test   %edi,%edi
801068ad:	74 2f                	je     801068de <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801068af:	8b 75 0c             	mov    0xc(%ebp),%esi
801068b2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801068b8:	83 ec 08             	sub    $0x8,%esp
801068bb:	56                   	push   %esi
801068bc:	ff 75 08             	push   0x8(%ebp)
801068bf:	e8 66 ff ff ff       	call   8010682a <uva2ka>
    if(pa0 == 0)
801068c4:	83 c4 10             	add    $0x10,%esp
801068c7:	85 c0                	test   %eax,%eax
801068c9:	74 20                	je     801068eb <copyout+0x73>
    n = PGSIZE - (va - va0);
801068cb:	89 f3                	mov    %esi,%ebx
801068cd:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801068d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801068d6:	39 df                	cmp    %ebx,%edi
801068d8:	73 ac                	jae    80106886 <copyout+0xe>
      n = len;
801068da:	89 fb                	mov    %edi,%ebx
801068dc:	eb a8                	jmp    80106886 <copyout+0xe>
  }
  return 0;
801068de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068e6:	5b                   	pop    %ebx
801068e7:	5e                   	pop    %esi
801068e8:	5f                   	pop    %edi
801068e9:	5d                   	pop    %ebp
801068ea:	c3                   	ret    
      return -1;
801068eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f0:	eb f1                	jmp    801068e3 <copyout+0x6b>
